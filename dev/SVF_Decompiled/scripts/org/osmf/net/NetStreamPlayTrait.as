package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.PlayTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class NetStreamPlayTrait extends PlayTrait
   {
      private static const NETCONNECTION_FAILURE_ERROR_CODE:int = 2154;
      
      private var streamStarted:Boolean;
      
      private var netStream:NetStream;
      
      private var netConnection:NetConnection;
      
      private var urlResource:URLResource;
      
      private var multicastResource:MulticastResource;
      
      private var reconnectStreams:Boolean;
      
      public function NetStreamPlayTrait(param1:NetStream, param2:MediaResourceBase, param3:Boolean, param4:NetConnection)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         this.netStream = param1;
         this.netConnection = param4;
         this.urlResource = param2 as URLResource;
         this.multicastResource = param2 as MulticastResource;
         this.reconnectStreams = param3;
         param1.addEventListener("netStatus",onNetStatus,false,1,true);
         NetClient(param1.client).addHandler("onPlayStatus",onPlayStatus,1);
      }
      
      override protected function playStateChangeStart(param1:String) : void
      {
         var _loc3_:Object = null;
         var _loc2_:StreamingURLResource = null;
         var _loc9_:Boolean = false;
         var _loc8_:String = null;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:DynamicStreamingResource = null;
         var _loc7_:NetStreamPlayOptions = null;
         if(param1 == "playing")
         {
            if(streamStarted)
            {
               if(multicastResource != null)
               {
                  netStream.play(multicastResource.streamName,-1,-1);
               }
               else
               {
                  netStream.resume();
               }
            }
            else if(urlResource != null)
            {
               _loc2_ = urlResource as StreamingURLResource;
               _loc9_ = !!_loc2_ ? _loc2_.urlIncludesFMSApplicationInstance : false;
               _loc8_ = NetStreamUtils.getStreamNameFromURL(urlResource.url,_loc9_);
               _loc3_ = NetStreamUtils.getPlayArgsForResource(urlResource);
               _loc6_ = Number(_loc3_.start);
               _loc4_ = Number(_loc3_.len);
               _loc5_ = urlResource as DynamicStreamingResource;
               if(_loc5_ != null)
               {
                  _loc7_ = new NetStreamPlayOptions();
                  _loc7_.start = _loc6_;
                  _loc7_.len = _loc4_;
                  _loc7_.streamName = _loc5_.streamItems[_loc5_.initialIndex].streamName;
                  _loc7_.transition = "reset";
                  doPlay2(_loc7_);
               }
               else if(reconnectStreams && _loc2_ != null && NetStreamUtils.isRTMPStream(_loc2_.url))
               {
                  _loc7_ = new NetStreamPlayOptions();
                  _loc7_.start = _loc6_;
                  _loc7_.len = _loc4_;
                  _loc7_.transition = "reset";
                  _loc7_.streamName = _loc8_;
                  doPlay2(_loc7_);
               }
               else if(multicastResource != null && multicastResource.groupspec != null && multicastResource.groupspec.length > 0)
               {
                  doPlay(multicastResource.streamName,_loc6_,_loc4_);
               }
               else
               {
                  doPlay(_loc8_,_loc6_,_loc4_);
               }
            }
         }
         else if(multicastResource != null)
         {
            netStream.play(false);
         }
         else
         {
            netStream.pause();
         }
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Failed":
            case "NetStream.Play.FileStructureInvalid":
            case "NetStream.Play.StreamNotFound":
            case "NetStream.Play.NoSupportedTrackFound":
            case "NetStream.Failed":
               netStream.pause();
               streamStarted = false;
               break;
            case "NetStream.Play.Stop":
               if(urlResource != null && NetStreamUtils.isStreamingResource(urlResource) == false)
               {
                  stop();
                  break;
               }
         }
      }
      
      private function onPlayStatus(param1:Object) : void
      {
         var _loc2_:* = param1.code;
         if("NetStream.Play.Complete" === _loc2_)
         {
            stop();
         }
      }
      
      private function doPlay(... rest) : void
      {
         try
         {
            netStream.play.apply(this,rest);
            streamStarted = true;
         }
         catch(error:Error)
         {
            streamStarted = false;
            stop();
            dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(15)));
         }
      }
      
      private function doPlay2(param1:NetStreamPlayOptions) : void
      {
         netStream.play2(param1);
         streamStarted = true;
      }
   }
}

