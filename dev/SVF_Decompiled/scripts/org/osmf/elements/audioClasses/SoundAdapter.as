package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   
   public class SoundAdapter extends EventDispatcher
   {
      public static const DOWNLOAD_COMPLETE:String = "downloadComplete";
      
      private var owner:MediaElement;
      
      private var _soundTransform:SoundTransform;
      
      private var sound:Sound;
      
      private var playing:Boolean = false;
      
      private var channel:SoundChannel;
      
      private var lastStartTime:Number = 0;
      
      public function SoundAdapter(param1:MediaElement, param2:Sound)
      {
         super();
         this.owner = param1;
         this.sound = param2;
         _soundTransform = new SoundTransform();
         param2.addEventListener("complete",onDownloadComplete,false,0,true);
         param2.addEventListener("progress",onProgress,false,0,true);
         param2.addEventListener("ioError",onIOError,false,0,true);
      }
      
      public function get currentTime() : Number
      {
         return channel != null ? channel.position / 1000 : lastStartTime / 1000;
      }
      
      public function get estimatedDuration() : Number
      {
         return sound.length / (1000 * sound.bytesLoaded / sound.bytesTotal);
      }
      
      public function get soundTransform() : SoundTransform
      {
         return _soundTransform;
      }
      
      public function set soundTransform(param1:SoundTransform) : void
      {
         _soundTransform = param1;
         if(channel != null)
         {
            channel.soundTransform = param1;
         }
      }
      
      public function play(param1:Number = -1) : Boolean
      {
         var _loc2_:Boolean = false;
         if(channel == null)
         {
            try
            {
               channel = sound.play(param1 != -1 ? param1 : lastStartTime);
            }
            catch(error:ArgumentError)
            {
               channel = null;
            }
            if(channel != null)
            {
               playing = true;
               channel.soundTransform = _soundTransform;
               channel.addEventListener("soundComplete",onSoundComplete);
               _loc2_ = true;
            }
            else
            {
               owner.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(10)));
            }
         }
         return _loc2_;
      }
      
      public function pause() : void
      {
         if(channel != null)
         {
            lastStartTime = channel.position;
            clearChannel();
            playing = false;
         }
      }
      
      public function stop() : void
      {
         if(channel != null)
         {
            lastStartTime = 0;
            clearChannel();
            playing = false;
         }
      }
      
      public function seek(param1:Number) : void
      {
         var _loc2_:Boolean = playing;
         if(channel != null)
         {
            clearChannel();
         }
         play(param1 * 1000);
         if(_loc2_ == false)
         {
            pause();
         }
      }
      
      private function clearChannel() : void
      {
         if(channel != null)
         {
            channel.removeEventListener("soundComplete",onSoundComplete);
            channel.stop();
            channel = null;
         }
      }
      
      private function onSoundComplete(param1:Event) : void
      {
         lastStartTime = channel.position;
         clearChannel();
         playing = false;
         dispatchEvent(new Event("complete"));
      }
      
      private function onDownloadComplete(param1:Event) : void
      {
         dispatchEvent(new Event("downloadComplete"));
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function onIOError(param1:IOErrorEvent) : void
      {
         owner.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(1)));
      }
   }
}

