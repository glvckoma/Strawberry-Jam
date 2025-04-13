package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.traits.DynamicStreamTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class NetStreamDynamicStreamTrait extends DynamicStreamTrait
   {
      private var netStream:NetStream;
      
      private var switchManager:NetStreamSwitchManagerBase;
      
      private var inSetSwitching:Boolean;
      
      private var dsResource:DynamicStreamingResource;
      
      private var indexToSwitchTo:int;
      
      public function NetStreamDynamicStreamTrait(param1:NetStream, param2:NetStreamSwitchManagerBase, param3:DynamicStreamingResource)
      {
         super(param2.autoSwitch,param2.currentIndex,param3.streamItems.length);
         this.netStream = param1;
         this.switchManager = param2;
         this.dsResource = param3;
         param1.addEventListener("netStatus",onNetStatus);
         NetClient(param1.client).addHandler("onPlayStatus",onPlayStatus);
      }
      
      override public function dispose() : void
      {
         netStream = null;
         switchManager = null;
      }
      
      override public function getBitrateForIndex(param1:int) : Number
      {
         if(param1 > numDynamicStreams - 1 || param1 < 0)
         {
            throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
         }
         return dsResource.streamItems[param1].bitrate;
      }
      
      override protected function switchingChangeStart(param1:Boolean, param2:int) : void
      {
         if(param1 && !inSetSwitching)
         {
            indexToSwitchTo = param2;
         }
      }
      
      override protected function switchingChangeEnd(param1:int) : void
      {
         super.switchingChangeEnd(param1);
         if(switching && !inSetSwitching)
         {
            switchManager.switchTo(indexToSwitchTo);
         }
      }
      
      override protected function autoSwitchChangeStart(param1:Boolean) : void
      {
         switchManager.autoSwitch = param1;
      }
      
      override protected function maxAllowedIndexChangeStart(param1:int) : void
      {
         switchManager.maxAllowedIndex = param1;
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Transition":
               inSetSwitching = true;
               setSwitching(true,dsResource.indexFromName(param1.info.details));
               inSetSwitching = false;
               break;
            case "NetStream.Play.Failed":
               setSwitching(false,currentIndex);
         }
      }
      
      private function onPlayStatus(param1:Object) : void
      {
         var _loc2_:* = param1.code;
         if("NetStream.Play.TransitionComplete" === _loc2_)
         {
            setSwitching(false,switchManager.currentIndex);
         }
      }
   }
}

