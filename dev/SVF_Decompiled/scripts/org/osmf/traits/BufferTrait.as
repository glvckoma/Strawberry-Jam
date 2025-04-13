package org.osmf.traits
{
   import org.osmf.events.BufferEvent;
   
   public class BufferTrait extends MediaTraitBase
   {
      private var _buffering:Boolean = false;
      
      private var _bufferLength:Number = 0;
      
      private var _bufferTime:Number = 0;
      
      public function BufferTrait()
      {
         super("buffer");
      }
      
      public function get buffering() : Boolean
      {
         return _buffering;
      }
      
      public function get bufferLength() : Number
      {
         return _bufferLength;
      }
      
      public function get bufferTime() : Number
      {
         return _bufferTime;
      }
      
      public function set bufferTime(param1:Number) : void
      {
         if(isNaN(param1) || param1 < 0)
         {
            param1 = 0;
         }
         if(param1 != _bufferTime)
         {
            bufferTimeChangeStart(param1);
            _bufferTime = param1;
            bufferTimeChangeEnd();
         }
      }
      
      final protected function setBufferLength(param1:Number) : void
      {
         if(param1 != _bufferLength)
         {
            bufferLengthChangeStart(param1);
            _bufferLength = param1;
            bufferLengthChangeEnd();
         }
      }
      
      final protected function setBuffering(param1:Boolean) : void
      {
         if(param1 != _buffering)
         {
            bufferingChangeStart(param1);
            _buffering = param1;
            bufferingChangeEnd();
         }
      }
      
      protected function bufferingChangeStart(param1:Boolean) : void
      {
      }
      
      protected function bufferingChangeEnd() : void
      {
         dispatchEvent(new BufferEvent("bufferingChange",false,false,_buffering));
      }
      
      protected function bufferLengthChangeStart(param1:Number) : void
      {
      }
      
      protected function bufferLengthChangeEnd() : void
      {
         dispatchEvent(new BufferEvent("bufferLengthChange",false,false,false,NaN,_bufferLength));
      }
      
      protected function bufferTimeChangeStart(param1:Number) : void
      {
      }
      
      protected function bufferTimeChangeEnd() : void
      {
         dispatchEvent(new BufferEvent("bufferTimeChange",false,false,false,_bufferTime));
      }
   }
}

