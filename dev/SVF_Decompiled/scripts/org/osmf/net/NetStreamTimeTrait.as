package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.TimeTrait;
   
   public class NetStreamTimeTrait extends TimeTrait
   {
      private var durationOffset:Number = 0;
      
      private var _audioDelay:Number = 0;
      
      private var netStream:NetStream;
      
      private var resource:MediaResourceBase;
      
      private var multicast:Boolean = false;
      
      public function NetStreamTimeTrait(param1:NetStream, param2:MediaResourceBase, param3:Number = NaN)
      {
         super();
         this.netStream = param1;
         NetClient(param1.client).addHandler("onMetaData",onMetaData);
         NetClient(param1.client).addHandler("onPlayStatus",onPlayStatus);
         param1.addEventListener("netStatus",onNetStatus,false,0,true);
         this.resource = param2;
         if(isNaN(param3) == false)
         {
            setDuration(param3);
         }
         var _loc4_:MulticastResource = param2 as MulticastResource;
         if(_loc4_ != null && _loc4_.groupspec != null && _loc4_.groupspec.length > 0)
         {
            multicast = true;
            setDuration(1.7976931348623157e+308);
         }
      }
      
      override public function get currentTime() : Number
      {
         if(multicast)
         {
            return 0;
         }
         if(durationOffset == duration - (netStream.time - _audioDelay))
         {
            return netStream.time - _audioDelay + durationOffset;
         }
         return netStream.time - _audioDelay;
      }
      
      private function onMetaData(param1:Object) : void
      {
         var _loc2_:Object = NetStreamUtils.getPlayArgsForResource(resource);
         _audioDelay = !!param1.hasOwnProperty("audiodelay") ? param1.audiodelay : 0;
         var _loc3_:Number = Math.max(0,_loc2_.start);
         var _loc4_:Number = Number(_loc2_.len);
         if(_loc4_ == -1)
         {
            _loc4_ = 1.7976931348623157e+308;
         }
         setDuration(Math.min(param1.duration - _audioDelay - _loc3_,_loc4_));
      }
      
      private function onPlayStatus(param1:Object) : void
      {
         var _loc2_:* = param1.code;
         if("NetStream.Play.Complete" === _loc2_)
         {
            signalComplete();
         }
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Stop":
               if(NetStreamUtils.isStreamingResource(resource) == false)
               {
                  signalComplete();
               }
               break;
            case "NetStream.Play.UnpublishNotify":
               signalComplete();
         }
      }
      
      override protected function signalComplete() : void
      {
         if(netStream.time - _audioDelay != duration)
         {
            durationOffset = duration - (netStream.time - _audioDelay);
         }
         super.signalComplete();
      }
      
      internal function get audioDelay() : Number
      {
         return _audioDelay;
      }
   }
}

