package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class InsufficientBandwidthRule extends SwitchingRuleBase
   {
      private var bitrateMultiplier:Number;
      
      public function InsufficientBandwidthRule(param1:RTMPNetStreamMetrics, param2:Number = 1.15)
      {
         super(param1);
         this.bitrateMultiplier = param2;
      }
      
      override public function getNewIndex() : int
      {
         var _loc1_:int = 0;
         var _loc2_:* = -1;
         if(rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            _loc1_ = rtmpMetrics.currentIndex;
            while(_loc1_ >= 0)
            {
               if(rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > rtmpMetrics.resource.streamItems[_loc1_].bitrate * bitrateMultiplier)
               {
                  _loc2_ = _loc1_;
                  break;
               }
               _loc1_--;
            }
            _loc2_ = int(_loc2_ == rtmpMetrics.currentIndex ? -1 : _loc2_);
         }
         return _loc2_;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

