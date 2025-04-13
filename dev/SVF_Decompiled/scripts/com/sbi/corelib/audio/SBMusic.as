package com.sbi.corelib.audio
{
   import com.sbi.loader.LoaderCache;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundLoaderContext;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class SBMusic
   {
      private var _hashKey:String;
      
      private var _previouslyPlayedFilename:String;
      
      private var _currFilename:String;
      
      private var _previousVolume:Number;
      
      private var _currVolume:Number;
      
      public var paused:Boolean = false;
      
      public var muted:Boolean = false;
      
      public var mutedVolume:Number = 1;
      
      public var playVolume:Number = 1;
      
      public var s:Sound;
      
      public var sc:SoundChannel;
      
      public var position:Number;
      
      public function SBMusic(param1:String, param2:Boolean = true, param3:Number = 1, param4:Number = 1000, param5:Boolean = true)
      {
         super();
         playNewMusic(param1,param2,param3,param4,param5);
         SBAudio.addMusic(this);
      }
      
      public function playNewMusic(param1:String, param2:Boolean = true, param3:Number = 1, param4:Number = 1000, param5:Boolean = true) : void
      {
         _previouslyPlayedFilename = _currFilename;
         _currFilename = param1;
         _previousVolume = _currVolume;
         _currVolume = param3 * SBAudio.currentVolume;
         var _loc6_:URLRequest = LoaderCache.fetchCDNURLRequest("audio/" + param1);
         if(s)
         {
            s.removeEventListener("ioError",handleIOError);
            s = null;
         }
         if(sc)
         {
            sc.stop();
            sc = null;
         }
         s = new Sound(_loc6_,new SoundLoaderContext(param4,param5));
         volume = _currVolume;
         if(param2)
         {
            play();
         }
         else
         {
            stop();
         }
         s.addEventListener("ioError",handleIOError,false,0,true);
      }
      
      public function play(param1:Number = 0, param2:int = 2147483647, param3:SoundTransform = null) : void
      {
         if(s == null)
         {
            return;
         }
         sc = s.play(param1,param2,param3);
         if(sc == null)
         {
            return;
         }
         setTransformVolume(playVolume);
      }
      
      public function get volume() : Number
      {
         return !!sc ? sc.soundTransform.volume : -1;
      }
      
      public function set volume(param1:Number) : void
      {
         if(muted)
         {
            mutedVolume = param1;
         }
         else
         {
            playVolume = param1;
         }
         if(sc)
         {
            setTransformVolume(param1);
         }
      }
      
      public function toggleMute() : void
      {
         if(muted)
         {
            unmute();
         }
         else
         {
            mute();
         }
      }
      
      public function mute() : void
      {
         if(!muted)
         {
            mutedVolume = volume;
            volume = 0;
            muted = true;
         }
      }
      
      public function unmute() : void
      {
         if(muted)
         {
            volume = mutedVolume;
            muted = false;
         }
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
         if(s && sc && !paused)
         {
            position = sc.position;
            sc.stop();
            paused = true;
         }
      }
      
      public function unpause() : void
      {
         if(s && sc && paused)
         {
            sc = s.play(position);
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
         muted = false;
      }
      
      public function get previouslyPlayedFilename() : String
      {
         return _previouslyPlayedFilename;
      }
      
      public function get previousVolume() : Number
      {
         return _previousVolume;
      }
      
      public function get currFilename() : String
      {
         return _currFilename;
      }
      
      public function get currVolume() : Number
      {
         return _currVolume;
      }
      
      private function setTransformVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = sc.soundTransform;
         _loc2_.volume = param1;
         sc.soundTransform = _loc2_;
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         if(s)
         {
            trace("WARNING - IOError while attempting to load music:" + s.url);
            s = null;
         }
         if(sc)
         {
            sc.stop();
            sc = null;
         }
         SBAudio.removeMusic(this);
      }
   }
}

