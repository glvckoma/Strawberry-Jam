package org.osmf.events
{
   import flash.events.Event;
   
   public class BufferEvent extends Event
   {
      public static const BUFFERING_CHANGE:String = "bufferingChange";
      
      public static const BUFFER_TIME_CHANGE:String = "bufferTimeChange";
      
      public static const BUFFER_LENGTH_CHANGE:String = "bufferLengthChange";
      
      private var _buffering:Boolean;
      
      private var _bufferTime:Number;
      
      private var _bufferLength:Number;
      
      public function BufferEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Number = NaN, param6:Number = NaN)
      {
         super(param1,param2,param3);
         _buffering = param4;
         _bufferTime = param5;
         _bufferLength = param6;
      }
      
      public function get buffering() : Boolean
      {
         return _buffering;
      }
      
      public function get bufferTime() : Number
      {
         return _bufferTime;
      }
      
      public function get bufferLength() : Number
      {
         return _bufferLength;
      }
      
      override public function clone() : Event
      {
         return new BufferEvent(type,bubbles,cancelable,_buffering,_bufferTime,_bufferLength);
      }
   }
}

