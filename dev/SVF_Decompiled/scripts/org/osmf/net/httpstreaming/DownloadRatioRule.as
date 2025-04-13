package org.osmf.net.httpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class DownloadRatioRule extends SwitchingRuleBase
   {
      private var aggressiveUpswitch:Boolean = false;
      
      public function DownloadRatioRule(param1:HTTPNetStreamMetrics, param2:Boolean = true)
      {
         super(param1);
         this.aggressiveUpswitch = param2;
      }
      
      override public function getNewIndex() : int
      {
         var _loc2_:Number = NaN;
         var _loc1_:int = -1;
         if(httpMetrics.downloadRatio < 1)
         {
            if(httpMetrics.currentIndex > 0)
            {
               _loc2_ = getSwitchRatio(httpMetrics.currentIndex - 1);
               if(httpMetrics.downloadRatio < _loc2_)
               {
                  _loc1_ = 0;
               }
               else
               {
                  _loc1_ = httpMetrics.currentIndex - 1;
               }
            }
         }
         else if(httpMetrics.currentIndex < httpMetrics.maxAllowedIndex)
         {
            _loc2_ = getSwitchRatio(httpMetrics.currentIndex + 1);
            if(httpMetrics.downloadRatio >= _loc2_)
            {
               if(httpMetrics.downloadRatio > 100 || !aggressiveUpswitch)
               {
                  _loc1_ = httpMetrics.currentIndex + 1;
               }
               else
               {
                  do
                  {
                     _loc1_++;
                     if(_loc1_ >= httpMetrics.maxAllowedIndex + 1)
                     {
                        break;
                     }
                     _loc2_ = getSwitchRatio(_loc1_);
                  }
                  while(httpMetrics.downloadRatio >= _loc2_);
                  
                  _loc1_--;
               }
            }
         }
         return _loc1_;
      }
      
      private function getSwitchRatio(param1:int) : Number
      {
         return httpMetrics.getBitrateForIndex(param1) / httpMetrics.getBitrateForIndex(metrics.currentIndex);
      }
      
      private function get httpMetrics() : HTTPNetStreamMetrics
      {
         return metrics as HTTPNetStreamMetrics;
      }
   }
}

