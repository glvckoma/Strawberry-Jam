package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import org.osmf.traits.PlayTrait;
   
   public class AudioPlayTrait extends PlayTrait
   {
      private var lastPlayFailed:Boolean = false;
      
      private var soundAdapter:SoundAdapter;
      
      public function AudioPlayTrait(param1:SoundAdapter)
      {
         super();
         this.soundAdapter = param1;
         param1.addEventListener("complete",onPlaybackComplete,false,1,true);
      }
      
      override protected function playStateChangeStart(param1:String) : void
      {
         if(param1 == "playing")
         {
            lastPlayFailed = !soundAdapter.play();
         }
         else if(param1 == "paused")
         {
            soundAdapter.pause();
         }
         else if(param1 == "stopped")
         {
            soundAdapter.stop();
         }
      }
      
      override protected function playStateChangeEnd() : void
      {
         if(lastPlayFailed)
         {
            stop();
            lastPlayFailed = false;
         }
         else
         {
            super.playStateChangeEnd();
         }
      }
      
      private function onPlaybackComplete(param1:Event) : void
      {
         stop();
      }
   }
}

