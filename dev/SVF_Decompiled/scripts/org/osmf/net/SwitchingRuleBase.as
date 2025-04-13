package org.osmf.net
{
   public class SwitchingRuleBase
   {
      private var _metrics:NetStreamMetricsBase;
      
      public function SwitchingRuleBase(param1:NetStreamMetricsBase)
      {
         super();
         _metrics = param1;
      }
      
      public function getNewIndex() : int
      {
         return -1;
      }
      
      protected function get metrics() : NetStreamMetricsBase
      {
         return _metrics;
      }
   }
}

