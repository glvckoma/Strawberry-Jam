package org.osmf.elements
{
   import flash.events.DRMErrorEvent;
   import flash.events.DRMStatusEvent;
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.StatusEvent;
   import flash.media.Video;
   import flash.net.NetStream;
   import flash.system.SystemUpdater;
   import flash.utils.ByteArray;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.media.DefaultTraitResolver;
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.CuePoint;
   import org.osmf.metadata.TimelineMetadata;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.ModifiableTimeTrait;
   import org.osmf.net.NetClient;
   import org.osmf.net.NetLoader;
   import org.osmf.net.NetStreamAudioTrait;
   import org.osmf.net.NetStreamBufferTrait;
   import org.osmf.net.NetStreamDisplayObjectTrait;
   import org.osmf.net.NetStreamDynamicStreamTrait;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamPlayTrait;
   import org.osmf.net.NetStreamSeekTrait;
   import org.osmf.net.NetStreamTimeTrait;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.drm.NetStreamDRMTrait;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class LightweightVideoElement extends LoadableElementBase
   {
      private static const DRM_STATUS_CODE:String = "DRM.encryptedFLV";
      
      private static const DRM_NEEDS_AUTHENTICATION:int = 3330;
      
      private var displayObjectTrait:DisplayObjectTrait;
      
      private var defaultTimeTrait:ModifiableTimeTrait;
      
      private var stream:NetStream;
      
      private var video:Video;
      
      private var embeddedCuePoints:TimelineMetadata;
      
      private var _smoothing:Boolean;
      
      private var _deblocking:int;
      
      private var drmTrait:NetStreamDRMTrait;
      
      public function LightweightVideoElement(param1:MediaResourceBase = null, param2:NetLoader = null)
      {
         if(param2 == null)
         {
            param2 = new NetLoader();
         }
         super(param1,param2);
         if(!(param1 == null || param1 is URLResource))
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
      }
      
      public function get client() : NetClient
      {
         return stream != null ? stream.client as NetClient : null;
      }
      
      public function get defaultDuration() : Number
      {
         return !!defaultTimeTrait ? defaultTimeTrait.duration : NaN;
      }
      
      public function set defaultDuration(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            if(defaultTimeTrait != null)
            {
               removeTraitResolver("time");
               defaultTimeTrait = null;
            }
         }
         else
         {
            if(defaultTimeTrait == null)
            {
               defaultTimeTrait = new ModifiableTimeTrait();
               addTraitResolver("time",new DefaultTraitResolver("time",defaultTimeTrait));
            }
            defaultTimeTrait.duration = param1;
         }
      }
      
      public function get smoothing() : Boolean
      {
         return _smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         _smoothing = param1;
         if(video != null)
         {
            video.smoothing = param1;
         }
      }
      
      public function get deblocking() : int
      {
         return _deblocking;
      }
      
      public function set deblocking(param1:int) : void
      {
         _deblocking = param1;
         if(video != null)
         {
            video.deblocking = param1;
         }
      }
      
      public function get currentFPS() : Number
      {
         return stream != null ? stream.currentFPS : 0;
      }
      
      override protected function createLoadTrait(param1:MediaResourceBase, param2:LoaderBase) : LoadTrait
      {
         return new NetStreamLoadTrait(param2,param1);
      }
      
      protected function createVideo() : Video
      {
         return new Video();
      }
      
      override protected function processReadyState() : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:NetStreamLoadTrait = getTrait("load") as NetStreamLoadTrait;
         stream = _loc3_.netStream;
         video = createVideo();
         video.smoothing = _smoothing;
         video.deblocking = _deblocking;
         video.height = 0;
         video.width = 0;
         video.attachNetStream(stream);
         NetClient(stream.client).addHandler("onMetaData",onMetaData);
         NetClient(stream.client).addHandler("onCuePoint",onCuePoint);
         stream.addEventListener("netStatus",onNetStatusEvent);
         _loc3_.connection.addEventListener("netStatus",onNetStatusEvent,false,0,true);
         stream.addEventListener("drmError",onDRMErrorEvent);
         var _loc1_:StreamingURLResource = resource as StreamingURLResource;
         if(_loc1_ != null && _loc1_.drmContentData)
         {
            _loc2_ = _loc1_.drmContentData;
            setupDRMTrait(_loc2_);
         }
         else
         {
            stream.addEventListener("status",onStatus);
            stream.addEventListener("drmStatus",onDRMStatus);
         }
         finishLoad();
      }
      
      private function onStatus(param1:StatusEvent) : void
      {
         if(param1.code == "DRM.encryptedFLV" && getTrait("drm") == null)
         {
            createDRMTrait();
         }
      }
      
      private function onDRMStatus(param1:DRMStatusEvent) : void
      {
         drmTrait.inlineOnVoucher(param1);
      }
      
      private function reloadAfterAuth(param1:DRMEvent) : void
      {
         var _loc2_:NetStreamLoadTrait = null;
         if(drmTrait.drmState == "authenticationComplete")
         {
            _loc2_ = getTrait("load") as NetStreamLoadTrait;
            if(_loc2_.loadState == "ready")
            {
               _loc2_.unload();
            }
            _loc2_.load();
         }
      }
      
      private function createDRMTrait() : void
      {
         drmTrait = new NetStreamDRMTrait();
         addTrait("drm",drmTrait);
      }
      
      private function setupDRMTrait(param1:ByteArray) : void
      {
         createDRMTrait();
         drmTrait.drmMetadata = param1;
      }
      
      private function onDRMErrorEvent(param1:DRMErrorEvent) : void
      {
         if(param1.errorID == 3330)
         {
            drmTrait.addEventListener("drmStateChange",reloadAfterAuth);
            drmTrait.drmMetadata = param1.contentData;
         }
         else if(param1.drmUpdateNeeded)
         {
            update("drm");
         }
         else if(param1.systemUpdateNeeded)
         {
            update("system");
         }
         else
         {
            drmTrait.inlineDRMFailed(new MediaError(param1.errorID));
         }
      }
      
      private function update(param1:String) : void
      {
         if(drmTrait == null)
         {
            createDRMTrait();
         }
         var _loc2_:SystemUpdater = drmTrait.update(param1);
         _loc2_.addEventListener("complete",onUpdateComplete);
      }
      
      private function finishLoad() : void
      {
         var timeTrait:TimeTrait;
         var reconnectStreams:Boolean;
         var onDurationChange:*;
         var dsResource:DynamicStreamingResource;
         var dsTrait:MediaTraitBase;
         var loadTrait:NetStreamLoadTrait = getTrait("load") as NetStreamLoadTrait;
         var trait:MediaTraitBase = loadTrait.getTrait("dvr");
         if(trait != null)
         {
            addTrait("dvr",trait);
         }
         trait = loadTrait.getTrait("audio");
         addTrait("audio",trait || new NetStreamAudioTrait(stream));
         trait = loadTrait.getTrait("buffer");
         addTrait("buffer",trait || new NetStreamBufferTrait(stream));
         timeTrait = (trait = loadTrait.getTrait("time")) as TimeTrait;
         if(timeTrait == null)
         {
            timeTrait = new NetStreamTimeTrait(stream,loadTrait.resource,defaultDuration);
         }
         addTrait("time",timeTrait);
         trait = loadTrait.getTrait("displayObject");
         addTrait("displayObject",trait || new NetStreamDisplayObjectTrait(stream,video,NaN,NaN));
         trait = loadTrait.getTrait("play");
         reconnectStreams = false;
         reconnectStreams = (loader as NetLoader).reconnectStreams;
         addTrait("play",trait || new NetStreamPlayTrait(stream,resource,reconnectStreams,loadTrait.connection));
         trait = loadTrait.getTrait("seek");
         if(trait == null && NetStreamUtils.getStreamType(resource) != "live")
         {
            trait = new NetStreamSeekTrait(timeTrait,loadTrait,stream,video);
         }
         if(trait != null)
         {
            if(isNaN(timeTrait.duration) || timeTrait.duration == 0)
            {
               onDurationChange = function(param1:TimeEvent):void
               {
                  timeTrait.removeEventListener("durationChange",onDurationChange);
                  addTrait("seek",trait);
               };
               timeTrait.addEventListener("durationChange",onDurationChange);
            }
            else
            {
               addTrait("seek",trait);
            }
         }
         dsResource = resource as DynamicStreamingResource;
         if(dsResource != null && loadTrait.switchManager != null)
         {
            dsTrait = loadTrait.getTrait("dynamicStream");
            addTrait("dynamicStream",dsTrait || new NetStreamDynamicStreamTrait(stream,loadTrait.switchManager,dsResource));
         }
      }
      
      override protected function processUnloadingState() : void
      {
         var _loc1_:NetStreamLoadTrait = getTrait("load") as NetStreamLoadTrait;
         NetClient(stream.client).removeHandler("onMetaData",onMetaData);
         stream.removeEventListener("netStatus",onNetStatusEvent);
         _loc1_.connection.removeEventListener("netStatus",onNetStatusEvent);
         removeTrait("audio");
         removeTrait("buffer");
         removeTrait("play");
         removeTrait("time");
         removeTrait("displayObject");
         removeTrait("seek");
         removeTrait("dynamicStream");
         removeTrait("dvr");
         stream.removeEventListener("drmError",onDRMErrorEvent);
         stream.removeEventListener("drmStatus",onDRMStatus);
         stream.removeEventListener("status",onStatus);
         if(drmTrait != null)
         {
            drmTrait.removeEventListener("drmStateChange",reloadAfterAuth);
            removeTrait("drm");
            drmTrait = null;
         }
         video.attachNetStream(null);
         stream = null;
         video = null;
         displayObjectTrait = null;
      }
      
      private function onMetaData(param1:Object) : void
      {
         var _loc3_:TimelineMetadata = null;
         var _loc4_:int = 0;
         var _loc5_:CuePoint = null;
         var _loc2_:Array = param1.cuePoints;
         if(_loc2_ != null && _loc2_.length > 0)
         {
            _loc3_ = getMetadata("http://www.osmf.org/timeline/dynamicCuePoints/1.0") as TimelineMetadata;
            if(_loc3_ == null)
            {
               _loc3_ = new TimelineMetadata(this);
               addMetadata("http://www.osmf.org/timeline/dynamicCuePoints/1.0",_loc3_);
            }
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               _loc5_ = new CuePoint(_loc2_[_loc4_].type,_loc2_[_loc4_].time,_loc2_[_loc4_].name,_loc2_[_loc4_].parameters);
               try
               {
                  _loc3_.addMarker(_loc5_);
               }
               catch(error:ArgumentError)
               {
               }
               _loc4_++;
            }
         }
      }
      
      private function onCuePoint(param1:Object) : void
      {
         if(embeddedCuePoints == null)
         {
            embeddedCuePoints = new TimelineMetadata(this);
            addMetadata("http://www.osmf.org/timeline/embeddedCuePoints/1.0",embeddedCuePoints);
         }
         var _loc2_:CuePoint = new CuePoint(param1.type,param1.time,param1.name,param1.parameters);
         try
         {
            embeddedCuePoints.addMarker(_loc2_);
         }
         catch(error:ArgumentError)
         {
         }
      }
      
      private function onUpdateComplete(param1:Event) : void
      {
         (getTrait("load") as LoadTrait).unload();
         (getTrait("load") as LoadTrait).load();
      }
      
      private function onNetStatusEvent(param1:NetStatusEvent) : void
      {
         var _loc2_:MediaError = null;
         switch(param1.info.code)
         {
            case "NetStream.Play.Failed":
            case "NetStream.Failed":
               _loc2_ = new MediaError(15,param1.info.description);
               break;
            case "NetStream.Play.StreamNotFound":
               _loc2_ = new MediaError(16,param1.info.description);
               break;
            case "NetStream.Play.FileStructureInvalid":
               _loc2_ = new MediaError(17,param1.info.description);
               break;
            case "NetStream.Play.NoSupportedTrackFound":
               _loc2_ = new MediaError(18,param1.info.description);
               break;
            case "NetConnection.Connect.IdleTimeOut":
               _loc2_ = new MediaError(14,param1.info.description);
         }
         if(param1.info.code == "DRM.UpdateNeeded")
         {
            update("drm");
         }
         if(_loc2_ != null)
         {
            dispatchEvent(new MediaErrorEvent("mediaError",false,false,_loc2_));
         }
      }
   }
}

