package org.osmf.net
{
   import flash.events.EventDispatcher;
   
   public class NetStreamSwitchManagerBase extends EventDispatcher
   {
      private var _autoSwitch:Boolean;
      
      private var _maxAllowedIndex:int;
      
      public function NetStreamSwitchManagerBase()
      {
         super();
         _autoSwitch = true;
         _maxAllowedIndex = 2147483647;
      }
      
      public function get autoSwitch() : Boolean
      {
         return _autoSwitch;
      }
      
      public function set autoSwitch(param1:Boolean) : void
      {
         _autoSwitch = param1;
      }
      
      public function get currentIndex() : uint
      {
         return 0;
      }
      
      public function get maxAllowedIndex() : int
      {
         return _maxAllowedIndex;
      }
      
      public function set maxAllowedIndex(param1:int) : void
      {
         _maxAllowedIndex = param1;
      }
      
      public function switchTo(param1:int) : void
      {
      }
   }
}

