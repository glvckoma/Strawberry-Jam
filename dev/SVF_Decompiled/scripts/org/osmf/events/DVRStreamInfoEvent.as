package org.osmf.events
{
   import flash.events.Event;
   
   public class DVRStreamInfoEvent extends Event
   {
      public static const DVRSTREAMINFO:String = "DVRStreamInfo";
      
      private var _info:Object;
      
      public function DVRStreamInfoEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Object = null)
      {
         super(param1,param2,param3);
         _info = param4;
      }
      
      override public function clone() : Event
      {
         return new DVRStreamInfoEvent(type,bubbles,cancelable,info);
      }
      
      public function get info() : Object
      {
         return _info;
      }
   }
}

