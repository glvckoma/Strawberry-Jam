package org.osmf.net.rtmpstreaming
{
   import flash.events.NetStatusEvent;
   import org.osmf.net.SwitchingRuleBase;
   
   public class InsufficientBufferRule extends SwitchingRuleBase
   {
      private var _panic:Boolean;
      
      private var _moreDetail:String;
      
      private var minBufferLength:Number;
      
      public function InsufficientBufferRule(param1:RTMPNetStreamMetrics, param2:Number = 2)
      {
         super(param1);
         _panic = false;
         this.minBufferLength = param2;
         param1.netStream.addEventListener("netStatus",monitorNetStatus,false,0,true);
      }
      
      override public function getNewIndex() : int
      {
         var _loc1_:int = -1;
         if(_panic || rtmpMetrics.netStream.bufferLength < minBufferLength && rtmpMetrics.netStream.bufferLength > rtmpMetrics.netStream.bufferTime)
         {
            _loc1_ = 0;
         }
         return _loc1_;
      }
      
      private function monitorNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Buffer.Full":
               _panic = false;
               break;
            case "NetStream.Buffer.Empty":
               if(Math.round(rtmpMetrics.netStream.time) != 0)
               {
                  _panic = true;
                  _moreDetail = "Buffer was empty";
               }
               break;
            case "NetStream.Play.InsufficientBW":
               _panic = true;
               _moreDetail = "Stream had insufficient bandwidth";
         }
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

