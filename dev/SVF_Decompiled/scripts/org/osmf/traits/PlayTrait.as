package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.PlayEvent;
   import org.osmf.utils.OSMFStrings;
   
   public class PlayTrait extends MediaTraitBase
   {
      private var _playState:String;
      
      private var _canPause:Boolean;
      
      public function PlayTrait()
      {
         super("play");
         _canPause = true;
         _playState = "stopped";
      }
      
      final public function play() : void
      {
         attemptPlayStateChange("playing");
      }
      
      public function get canPause() : Boolean
      {
         return _canPause;
      }
      
      final public function pause() : void
      {
         if(canPause)
         {
            attemptPlayStateChange("paused");
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString("pauseNotSupported"));
      }
      
      final public function stop() : void
      {
         attemptPlayStateChange("stopped");
      }
      
      public function get playState() : String
      {
         return _playState;
      }
      
      final protected function setCanPause(param1:Boolean) : void
      {
         if(param1 != _canPause)
         {
            _canPause = param1;
            dispatchEvent(new PlayEvent("canPauseChange"));
         }
      }
      
      protected function playStateChangeStart(param1:String) : void
      {
      }
      
      protected function playStateChangeEnd() : void
      {
         dispatchEvent(new PlayEvent("playStateChange",false,false,playState));
      }
      
      private function attemptPlayStateChange(param1:String) : void
      {
         if(_playState != param1)
         {
            playStateChangeStart(param1);
            _playState = param1;
            playStateChangeEnd();
         }
      }
   }
}

