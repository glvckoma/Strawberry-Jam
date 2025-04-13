package org.osmf.net.rtmpstreaming
{
   import flash.net.NetStream;
   import org.osmf.net.NetStreamMetricsBase;
   
   public class RTMPNetStreamMetrics extends NetStreamMetricsBase
   {
      private static const DEFAULT_AVG_MAX_BYTES_SAMPLE_SIZE:Number = 50;
      
      private var _averageMaxBytesPerSecondArray:Array;
      
      private var _averageMaxBytesPerSecond:Number;
      
      public function RTMPNetStreamMetrics(param1:NetStream)
      {
         super(param1);
         _averageMaxBytesPerSecondArray = [];
      }
      
      public function get averageMaxBytesPerSecond() : Number
      {
         return _averageMaxBytesPerSecond;
      }
      
      override protected function calculateMetrics() : void
      {
         var _loc4_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc2_:* = 0;
         super.calculateMetrics();
         try
         {
            _loc4_ = netStream.info.maxBytesPerSecond;
            _averageMaxBytesPerSecondArray.unshift(_loc4_);
            if(_averageMaxBytesPerSecondArray.length > 50)
            {
               _averageMaxBytesPerSecondArray.pop();
            }
            _loc1_ = 0;
            _loc3_ = 0;
            _loc2_ = 0;
            while(_loc2_ < _averageMaxBytesPerSecondArray.length)
            {
               _loc1_ += _averageMaxBytesPerSecondArray[_loc2_];
               _loc3_ = Number(_averageMaxBytesPerSecondArray[_loc2_] > _loc3_ ? _averageMaxBytesPerSecondArray[_loc2_] : _loc3_);
               _loc2_++;
            }
            _averageMaxBytesPerSecond = _averageMaxBytesPerSecondArray.length < 50 ? 0 : (isLive ? _loc3_ : _loc1_ / _averageMaxBytesPerSecondArray.length);
         }
         catch(error:Error)
         {
            throw error;
         }
      }
      
      private function get isLive() : Boolean
      {
         return resource && resource.streamType == "live";
      }
   }
}

