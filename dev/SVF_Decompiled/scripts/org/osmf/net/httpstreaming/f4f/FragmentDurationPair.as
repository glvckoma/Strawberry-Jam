package org.osmf.net.httpstreaming.f4f
{
   internal class FragmentDurationPair
   {
      private var _firstFragment:uint;
      
      private var _duration:uint;
      
      private var _durationAccrued:Number;
      
      private var _discontinuityIndicator:uint = 0;
      
      public function FragmentDurationPair()
      {
         super();
      }
      
      public function get firstFragment() : uint
      {
         return _firstFragment;
      }
      
      public function set firstFragment(param1:uint) : void
      {
         _firstFragment = param1;
      }
      
      public function get duration() : uint
      {
         return _duration;
      }
      
      public function set duration(param1:uint) : void
      {
         _duration = param1;
      }
      
      public function get durationAccrued() : Number
      {
         return _durationAccrued;
      }
      
      public function set durationAccrued(param1:Number) : void
      {
         _durationAccrued = param1;
      }
      
      public function get discontinuityIndicator() : uint
      {
         return _discontinuityIndicator;
      }
      
      public function set discontinuityIndicator(param1:uint) : void
      {
         _discontinuityIndicator = param1;
      }
   }
}

