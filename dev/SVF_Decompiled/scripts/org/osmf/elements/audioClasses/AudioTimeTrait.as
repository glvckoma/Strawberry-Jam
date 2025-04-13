package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import org.osmf.traits.TimeTrait;
   
   public class AudioTimeTrait extends TimeTrait
   {
      private var soundAdapter:SoundAdapter;
      
      public function AudioTimeTrait(param1:SoundAdapter)
      {
         super();
         this.soundAdapter = param1;
         param1.addEventListener("progress",onDownloadProgress,false,0,true);
         param1.addEventListener("downloadComplete",onDownloadComplete,false,0,true);
         param1.addEventListener("complete",onPlaybackComplete,false,0,true);
      }
      
      override public function get currentTime() : Number
      {
         return soundAdapter.currentTime;
      }
      
      private function onDownloadProgress(param1:Event) : void
      {
         if(!isNaN(soundAdapter.estimatedDuration) && soundAdapter.estimatedDuration > 0)
         {
            soundAdapter.removeEventListener("progress",onDownloadProgress);
            setDuration(soundAdapter.estimatedDuration);
         }
      }
      
      private function onDownloadComplete(param1:Event) : void
      {
         setDuration(soundAdapter.estimatedDuration);
      }
      
      private function onPlaybackComplete(param1:Event) : void
      {
         signalComplete();
      }
   }
}

