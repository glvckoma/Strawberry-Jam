package org.osmf.net
{
   import flash.events.EventDispatcher;
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetStream;
   import flash.utils.Timer;
   
   public class NetStreamMetricsBase extends EventDispatcher
   {
      private static const DEFAULT_UPDATE_INTERVAL:Number = 100;
      
      private static const DEFAULT_AVG_FRAMERATE_SAMPLE_SIZE:Number = 50;
      
      private var _netStream:NetStream;
      
      private var _resource:DynamicStreamingResource;
      
      private var _currentIndex:int;
      
      private var _maxAllowedIndex:int;
      
      private var _timer:Timer;
      
      private var _averageDroppedFPSArray:Array;
      
      private var _averageDroppedFPS:Number;
      
      private var _droppedFPS:Number;
      
      private var _lastFrameDropValue:Number;
      
      private var _lastFrameDropCounter:Number;
      
      private var _maxFPS:Number;
      
      public function NetStreamMetricsBase(param1:NetStream)
      {
         super();
         _netStream = param1;
         _droppedFPS = 0;
         _lastFrameDropCounter = 0;
         _lastFrameDropValue = 0;
         _maxFPS = 0;
         _averageDroppedFPSArray = [];
         _timer = new Timer(100);
         _timer.addEventListener("timer",onTimerEvent);
         param1.addEventListener("netStatus",onNetStatusEvent);
      }
      
      public function get resource() : DynamicStreamingResource
      {
         return _resource;
      }
      
      public function set resource(param1:DynamicStreamingResource) : void
      {
         _resource = param1;
         _maxAllowedIndex = param1 != null ? param1.streamItems.length - 1 : 0;
      }
      
      public function get netStream() : NetStream
      {
         return _netStream;
      }
      
      public function get currentIndex() : int
      {
         return _currentIndex;
      }
      
      public function set currentIndex(param1:int) : void
      {
         _currentIndex = param1;
      }
      
      public function get maxAllowedIndex() : int
      {
         return _maxAllowedIndex;
      }
      
      public function set maxAllowedIndex(param1:int) : void
      {
         _maxAllowedIndex = param1;
      }
      
      public function get updateInterval() : Number
      {
         return _timer.delay;
      }
      
      public function set updateInterval(param1:Number) : void
      {
         _timer.delay = param1;
         if(param1 <= 0)
         {
            _timer.stop();
         }
      }
      
      public function get maxFPS() : Number
      {
         return _maxFPS;
      }
      
      public function get droppedFPS() : Number
      {
         return _droppedFPS;
      }
      
      public function get averageDroppedFPS() : Number
      {
         return _averageDroppedFPS;
      }
      
      protected function calculateMetrics() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:* = 0;
         try
         {
            _maxFPS = netStream.currentFPS > _maxFPS ? netStream.currentFPS : _maxFPS;
            if(_timer.currentCount - _lastFrameDropCounter > 1000 / _timer.delay)
            {
               _droppedFPS = (netStream.info.droppedFrames - _lastFrameDropValue) / ((_timer.currentCount - _lastFrameDropCounter) * _timer.delay / 1000);
               _lastFrameDropCounter = _timer.currentCount;
               _lastFrameDropValue = netStream.info.droppedFrames;
            }
            _averageDroppedFPSArray.unshift(_droppedFPS);
            if(_averageDroppedFPSArray.length > 50)
            {
               _averageDroppedFPSArray.pop();
            }
            _loc1_ = 0;
            _loc2_ = 0;
            while(_loc2_ < _averageDroppedFPSArray.length)
            {
               _loc1_ += _averageDroppedFPSArray[_loc2_];
               _loc2_++;
            }
            _averageDroppedFPS = _averageDroppedFPSArray.length < 50 ? 0 : _loc1_ / _averageDroppedFPSArray.length;
         }
         catch(error:Error)
         {
            throw error;
         }
      }
      
      private function onNetStatusEvent(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Start":
               if(!_timer.running && updateInterval > 0)
               {
                  _timer.start();
               }
               break;
            case "NetStream.Play.Stop":
               _timer.stop();
         }
      }
      
      private function onTimerEvent(param1:TimerEvent) : void
      {
         if(isNaN(netStream.time))
         {
            _timer.stop();
         }
         else
         {
            calculateMetrics();
         }
      }
   }
}

