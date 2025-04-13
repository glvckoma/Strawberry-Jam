package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class SufficientBandwidthRule extends SwitchingRuleBase
   {
      private static const BANDWIDTH_SAFETY_MULTIPLE:Number = 1.15;
      
      private static const MIN_DROPPED_FPS:int = 2;
      
      public function SufficientBandwidthRule(param1:RTMPNetStreamMetrics)
      {
         super(param1);
      }
      
      override public function getNewIndex() : int
      {
         var _loc1_:int = 0;
         var _loc2_:* = -1;
         if(rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            _loc1_ = rtmpMetrics.resource.streamItems.length - 1;
            while(_loc1_ >= 0)
            {
               if(rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > rtmpMetrics.resource.streamItems[_loc1_].bitrate * 1.15)
               {
                  _loc2_ = _loc1_;
                  break;
               }
               _loc1_--;
            }
            if(_loc2_ > rtmpMetrics.currentIndex)
            {
               _loc2_ = int(rtmpMetrics.droppedFPS < 2 && rtmpMetrics.netStream.bufferLength > rtmpMetrics.netStream.bufferTime ? _loc2_ : -1);
            }
            else
            {
               _loc2_ = -1;
            }
         }
         return _loc2_;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

