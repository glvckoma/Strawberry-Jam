package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.DynamicStreamEvent;
   import org.osmf.utils.OSMFStrings;
   
   public class DynamicStreamTrait extends MediaTraitBase
   {
      private var _autoSwitch:Boolean;
      
      private var _currentIndex:int = 0;
      
      private var _maxAllowedIndex:int = 0;
      
      private var _numDynamicStreams:int;
      
      private var _switching:Boolean;
      
      public function DynamicStreamTrait(param1:Boolean = true, param2:int = 0, param3:int = 1)
      {
         super("dynamicStream");
         _autoSwitch = param1;
         _currentIndex = param2;
         _numDynamicStreams = param3;
         _maxAllowedIndex = param3 - 1;
         _switching = false;
      }
      
      public function get autoSwitch() : Boolean
      {
         return _autoSwitch;
      }
      
      final public function set autoSwitch(param1:Boolean) : void
      {
         if(autoSwitch != param1)
         {
            autoSwitchChangeStart(param1);
            _autoSwitch = param1;
            autoSwitchChangeEnd();
         }
      }
      
      public function get numDynamicStreams() : int
      {
         return _numDynamicStreams;
      }
      
      public function get currentIndex() : int
      {
         return _currentIndex;
      }
      
      public function get maxAllowedIndex() : int
      {
         return _maxAllowedIndex;
      }
      
      final public function set maxAllowedIndex(param1:int) : void
      {
         if(param1 < 0 || param1 > _numDynamicStreams - 1)
         {
            throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
         }
         if(maxAllowedIndex != param1)
         {
            maxAllowedIndexChangeStart(param1);
            _maxAllowedIndex = param1;
            maxAllowedIndexChangeEnd();
         }
      }
      
      public function getBitrateForIndex(param1:int) : Number
      {
         if(param1 > _numDynamicStreams - 1 || param1 < 0)
         {
            throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
         }
         return 0;
      }
      
      public function get switching() : Boolean
      {
         return _switching;
      }
      
      public function switchTo(param1:int) : void
      {
         if(autoSwitch)
         {
            throw new IllegalOperationError(OSMFStrings.getString("streamSwitchStreamNotInManualMode"));
         }
         if(param1 != currentIndex)
         {
            if(param1 < 0 || param1 > maxAllowedIndex)
            {
               throw new RangeError(OSMFStrings.getString("streamSwitchInvalidIndex"));
            }
            setSwitching(true,param1);
         }
      }
      
      final protected function setNumDynamicStreams(param1:int) : void
      {
         if(param1 != _numDynamicStreams)
         {
            _numDynamicStreams = param1;
            if(maxAllowedIndex >= _numDynamicStreams)
            {
               maxAllowedIndex = Math.max(0,_numDynamicStreams - 1);
            }
            dispatchEvent(new DynamicStreamEvent("numDynamicStreamsChange"));
         }
      }
      
      final protected function setCurrentIndex(param1:int) : void
      {
         _currentIndex = param1;
      }
      
      final protected function setSwitching(param1:Boolean, param2:int) : void
      {
         if(param1 != _switching)
         {
            switchingChangeStart(param1,param2);
            _switching = param1;
            if(param1 == false)
            {
               setCurrentIndex(param2);
            }
            switchingChangeEnd(param2);
         }
      }
      
      protected function autoSwitchChangeStart(param1:Boolean) : void
      {
      }
      
      protected function autoSwitchChangeEnd() : void
      {
         dispatchEvent(new DynamicStreamEvent("autoSwitchChange",false,false,false,_autoSwitch));
      }
      
      protected function switchingChangeStart(param1:Boolean, param2:int) : void
      {
      }
      
      protected function switchingChangeEnd(param1:int) : void
      {
         dispatchEvent(new DynamicStreamEvent("switchingChange",false,false,switching));
      }
      
      protected function maxAllowedIndexChangeStart(param1:int) : void
      {
      }
      
      protected function maxAllowedIndexChangeEnd() : void
      {
      }
   }
}

