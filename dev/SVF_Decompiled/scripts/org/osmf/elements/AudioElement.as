package org.osmf.elements
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.elements.audioClasses.AudioAudioTrait;
   import org.osmf.elements.audioClasses.AudioPlayTrait;
   import org.osmf.elements.audioClasses.AudioSeekTrait;
   import org.osmf.elements.audioClasses.AudioTimeTrait;
   import org.osmf.elements.audioClasses.SoundAdapter;
   import org.osmf.elements.audioClasses.SoundLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.DefaultTraitResolver;
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.net.*;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class AudioElement extends LoadableElementBase
   {
      private var soundAdapter:SoundAdapter;
      
      private var stream:NetStream;
      
      private var defaultTimeTrait:ModifiableTimeTrait;
      
      private var _alternateLoaders:Vector.<LoaderBase>;
      
      public function AudioElement(param1:URLResource = null, param2:LoaderBase = null)
      {
         super(param1,param2);
         if(!(param2 == null || param2 is NetLoader || param2 is SoundLoader))
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
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
      
      override public function set resource(param1:MediaResourceBase) : void
      {
         loader = getLoaderForResource(param1,alternateLoaders);
         super.resource = param1;
      }
      
      override protected function createLoadTrait(param1:MediaResourceBase, param2:LoaderBase) : LoadTrait
      {
         return param2 is NetLoader ? new NetStreamLoadTrait(param2,param1) : new SoundLoadTrait(param2,param1);
      }
      
      override protected function processReadyState() : void
      {
         var _loc1_:TimeTrait = null;
         var _loc2_:Boolean = false;
         var _loc3_:SoundLoadTrait = null;
         var _loc5_:LoadTrait = getTrait("load") as LoadTrait;
         soundAdapter = null;
         stream = null;
         var _loc4_:NetStreamLoadTrait = _loc5_ as NetStreamLoadTrait;
         if(_loc4_)
         {
            stream = _loc4_.netStream;
            stream.addEventListener("netStatus",onNetStatusEvent);
            _loc4_.connection.addEventListener("netStatus",onNetStatusEvent,false,0,true);
            _loc2_ = false;
            if(loader is NetLoader)
            {
               _loc2_ = (loader as NetLoader).reconnectStreams;
            }
            addTrait("play",new NetStreamPlayTrait(stream,resource,_loc2_,_loc4_.connection));
            _loc1_ = new NetStreamTimeTrait(stream,resource,defaultDuration);
            addTrait("time",_loc1_);
            addTrait("seek",new NetStreamSeekTrait(_loc1_,_loc5_,stream));
            addTrait("audio",new NetStreamAudioTrait(stream));
            addTrait("buffer",new NetStreamBufferTrait(stream));
         }
         else
         {
            _loc3_ = _loc5_ as SoundLoadTrait;
            soundAdapter = new SoundAdapter(this,_loc3_.sound);
            addTrait("play",new AudioPlayTrait(soundAdapter));
            _loc1_ = new AudioTimeTrait(soundAdapter);
            addTrait("time",_loc1_);
            addTrait("seek",new AudioSeekTrait(_loc1_,soundAdapter));
            addTrait("audio",new AudioAudioTrait(soundAdapter));
         }
      }
      
      override protected function processUnloadingState() : void
      {
         if(stream != null)
         {
            stream.removeEventListener("netStatus",onNetStatusEvent);
         }
         var _loc1_:NetStreamLoadTrait = getTrait("load") as NetStreamLoadTrait;
         if(_loc1_ != null)
         {
            _loc1_.connection.removeEventListener("netStatus",onNetStatusEvent);
         }
         removeTrait("play");
         removeTrait("seek");
         removeTrait("time");
         removeTrait("audio");
         removeTrait("buffer");
         if(soundAdapter != null)
         {
            soundAdapter.pause();
         }
         soundAdapter = null;
         stream = null;
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
         if(_loc2_ != null)
         {
            dispatchEvent(new MediaErrorEvent("mediaError",false,false,_loc2_));
         }
      }
      
      private function get alternateLoaders() : Vector.<LoaderBase>
      {
         if(_alternateLoaders == null)
         {
            _alternateLoaders = new Vector.<LoaderBase>();
            _alternateLoaders.push(new SoundLoader());
            _alternateLoaders.push(new NetLoader());
         }
         return _alternateLoaders;
      }
   }
}

