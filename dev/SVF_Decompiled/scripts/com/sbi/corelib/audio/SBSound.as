package com.sbi.corelib.audio
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class SBSound
   {
      public var paused:Boolean = false;
      
      public var playVolume:Number = 1;
      
      public var s:Sound;
      
      public var sc:SoundChannel;
      
      private var _soundPlaying:Boolean;
      
      private var _onSoundComplete:Function;
      
      public function SBSound(param1:Class, param2:Boolean = true, param3:Number = 1)
      {
         super();
         s = new param1();
         volume = param3;
         if(param2)
         {
            play();
         }
         else
         {
            stop();
         }
         SBAudio.addSound(this);
      }
      
      public function play(param1:Number = 0, param2:int = 0, param3:SoundTransform = null, param4:Function = null) : void
      {
         if(param2 == -1)
         {
            param2 = 2147483647;
         }
         if(s == null)
         {
            return;
         }
         sc = s.play(param1,param2,param3);
         if(sc == null)
         {
            return;
         }
         _soundPlaying = true;
         _onSoundComplete = param4;
         sc.addEventListener("soundComplete",soundStoppedHandler,false,0,true);
         setTransformVolume(playVolume);
      }
      
      public function destroy() : void
      {
         stop();
         sc = null;
         s = null;
         SBAudio.removeSound(this);
      }
      
      public function get volume() : Number
      {
         return !!sc ? sc.soundTransform.volume : -1;
      }
      
      public function set volume(param1:Number) : void
      {
         playVolume = param1;
         if(sc)
         {
            setTransformVolume(param1);
         }
      }
      
      public function get isPlaying() : Boolean
      {
         return _soundPlaying;
      }
      
      public function togglePause() : void
      {
         if(paused)
         {
            unpause();
         }
         else
         {
            pause();
         }
      }
      
      public function pause() : void
      {
         if(sc && !paused)
         {
            sc.stop();
            paused = true;
            _soundPlaying = false;
         }
      }
      
      public function unpause() : void
      {
         if(s && sc && paused)
         {
            sc = s.play(sc.position);
            if(sc == null)
            {
               return;
            }
            _soundPlaying = true;
            sc.addEventListener("soundComplete",soundStoppedHandler,false,0,true);
            setTransformVolume(playVolume);
            paused = false;
         }
      }
      
      public function stop() : void
      {
         if(sc)
         {
            sc.stop();
         }
         paused = false;
         _soundPlaying = false;
      }
      
      private function setTransformVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = sc.soundTransform;
         if(SBAudio.isMusicMuted)
         {
            _loc2_.volume = 0;
         }
         else
         {
            _loc2_.volume = param1;
         }
         sc.soundTransform = _loc2_;
      }
      
      private function soundStoppedHandler(param1:Event) : void
      {
         _soundPlaying = false;
         if(_onSoundComplete != null)
         {
            _onSoundComplete();
         }
      }
   }
}

