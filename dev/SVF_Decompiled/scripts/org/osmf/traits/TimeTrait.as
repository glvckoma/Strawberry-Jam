package org.osmf.traits
{
   import org.osmf.events.TimeEvent;
   
   public class TimeTrait extends MediaTraitBase
   {
      private var _duration:Number;
      
      private var _currentTime:Number;
      
      public function TimeTrait(param1:Number = NaN)
      {
         super("time");
         _duration = param1;
      }
      
      public function get duration() : Number
      {
         return _duration;
      }
      
      public function get currentTime() : Number
      {
         return _currentTime;
      }
      
      protected function durationChangeStart(param1:Number) : void
      {
      }
      
      protected function durationChangeEnd(param1:Number) : void
      {
         dispatchEvent(new TimeEvent("durationChange",false,false,_duration));
      }
      
      protected function currentTimeChangeStart(param1:Number) : void
      {
      }
      
      protected function currentTimeChangeEnd(param1:Number) : void
      {
      }
      
      protected function signalComplete() : void
      {
         dispatchEvent(new TimeEvent("complete"));
      }
      
      final protected function setCurrentTime(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(!isNaN(param1))
         {
            if(!isNaN(_duration))
            {
               param1 = Math.min(param1,_duration);
            }
            else
            {
               param1 = 0;
            }
         }
         if(_currentTime != param1 && !(isNaN(_currentTime) && isNaN(param1)))
         {
            currentTimeChangeStart(param1);
            _loc2_ = _currentTime;
            _currentTime = param1;
            currentTimeChangeEnd(_loc2_);
            if(currentTime == duration && currentTime > 0)
            {
               signalComplete();
            }
         }
      }
      
      final protected function setDuration(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_duration != param1)
         {
            durationChangeStart(param1);
            _loc2_ = _duration;
            _duration = param1;
            durationChangeEnd(_loc2_);
            if(!isNaN(_currentTime) && !isNaN(_duration) && _currentTime > _duration)
            {
               setCurrentTime(duration);
            }
         }
      }
   }
}

