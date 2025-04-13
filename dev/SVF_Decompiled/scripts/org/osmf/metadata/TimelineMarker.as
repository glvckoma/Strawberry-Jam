package org.osmf.metadata
{
   public class TimelineMarker
   {
      private var _time:Number;
      
      private var _duration:Number;
      
      public function TimelineMarker(param1:Number, param2:Number = NaN)
      {
         super();
         _time = param1;
         _duration = param2;
      }
      
      public function get time() : Number
      {
         return _time;
      }
      
      public function get duration() : Number
      {
         return _duration;
      }
   }
}

