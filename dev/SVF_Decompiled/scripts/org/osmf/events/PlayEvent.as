package org.osmf.events
{
   import flash.events.Event;
   
   public class PlayEvent extends Event
   {
      public static const CAN_PAUSE_CHANGE:String = "canPauseChange";
      
      public static const PLAY_STATE_CHANGE:String = "playStateChange";
      
      private var _playState:String;
      
      private var _canPause:Boolean;
      
      public function PlayEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:String = null, param5:Boolean = false)
      {
         super(param1,param2,param3);
         _playState = param4;
         _canPause = param5;
      }
      
      override public function clone() : Event
      {
         return new PlayEvent(type,bubbles,cancelable,playState,canPause);
      }
      
      public function get playState() : String
      {
         return _playState;
      }
      
      public function get canPause() : Boolean
      {
         return _canPause;
      }
   }
}

