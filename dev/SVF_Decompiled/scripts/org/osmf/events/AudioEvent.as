package org.osmf.events
{
   import flash.events.Event;
   
   public class AudioEvent extends Event
   {
      public static const VOLUME_CHANGE:String = "volumeChange";
      
      public static const MUTED_CHANGE:String = "mutedChange";
      
      public static const PAN_CHANGE:String = "panChange";
      
      private var _muted:Boolean;
      
      private var _volume:Number;
      
      private var _pan:Number;
      
      public function AudioEvent(param1:String, param2:Boolean, param3:Boolean, param4:Boolean = false, param5:Number = NaN, param6:Number = NaN)
      {
         super(param1,param2,param3);
         _muted = param4;
         _volume = param5;
         _pan = param6;
      }
      
      public function get muted() : Boolean
      {
         return _muted;
      }
      
      public function get volume() : Number
      {
         return _volume;
      }
      
      public function get pan() : Number
      {
         return _pan;
      }
      
      override public function clone() : Event
      {
         return new AudioEvent(type,bubbles,cancelable,_muted,_volume,_pan);
      }
   }
}

