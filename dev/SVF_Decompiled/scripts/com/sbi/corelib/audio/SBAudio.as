package com.sbi.corelib.audio
{
   import flash.media.SoundTransform;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class SBAudio
   {
      private static var _isMusicMuted:Boolean = false;
      
      private static var _areSoundsMuted:Boolean = false;
      
      private static var _isInitialized:Boolean = false;
      
      private static var _volume:Number = 1;
      
      private static var _cachedSounds:Dictionary;
      
      private static var _sharedObj:SharedObject;
      
      private static var _muteCallback:Function;
      
      private static var _guiManager:Object;
      
      private static var _sounds:Array = [];
      
      private static var _music:Array = [];
      
      public function SBAudio()
      {
         super();
      }
      
      public static function init(param1:Object, param2:Function, param3:Object) : void
      {
         var _loc4_:Object = null;
         _guiManager = param3;
         _cachedSounds = new Dictionary();
         for(var _loc5_ in param1)
         {
            _loc4_ = param1[_loc5_];
            addCachedSound(_loc5_,_loc4_.className,_loc4_.volume);
         }
         _muteCallback = param2;
         _isInitialized = true;
      }
      
      public static function setupSharedObject(param1:SharedObject) : void
      {
         if(_sharedObj == null && param1 != null)
         {
            _sharedObj = param1;
            if(_sharedObj.data.volume)
            {
               setVolumeAll(_sharedObj.data.volume);
            }
            if(_sharedObj.data.isMusicMuted)
            {
               muteMusic();
            }
            if(_sharedObj.data.areSoundsMuted)
            {
               muteSounds();
            }
         }
      }
      
      public static function addCachedSound(param1:String, param2:Class, param3:Number = 0.3) : void
      {
         _cachedSounds[param1] = new SBSound(param2,false,param3 * _volume);
      }
      
      public static function get isMusicMuted() : Boolean
      {
         return _isMusicMuted;
      }
      
      public static function get areSoundsMuted() : Boolean
      {
         return _areSoundsMuted;
      }
      
      public static function get isInitialized() : Boolean
      {
         return _isInitialized;
      }
      
      public static function get currentVolume() : Number
      {
         return _volume;
      }
      
      public static function addSound(param1:SBSound) : void
      {
         _sounds.push(param1);
      }
      
      public static function removeSound(param1:SBSound) : void
      {
         _sounds.splice(_sounds.indexOf(param1),1);
      }
      
      public static function addMusic(param1:Object) : void
      {
         _music.push(param1);
      }
      
      public static function removeMusic(param1:Object) : void
      {
         _music.splice(_music.indexOf(param1),1);
      }
      
      public static function playCachedSound(param1:String, param2:int = 1) : void
      {
         if(_isMusicMuted)
         {
            return;
         }
         var _loc3_:SBSound = _cachedSounds[param1];
         if(!_loc3_)
         {
            return;
         }
         _loc3_.play(0,param2,new SoundTransform(_volume));
      }
      
      public static function stopCachedSound(param1:String) : void
      {
         var _loc2_:SBSound = _cachedSounds[param1];
         if(!_loc2_)
         {
            return;
         }
         _loc2_.stop();
      }
      
      public static function setVolumeAll(param1:Number) : void
      {
         setVolumeSounds(param1);
         setVolumeMusic(param1);
         _volume = param1;
      }
      
      public static function setVolumeSounds(param1:Number) : void
      {
         for each(var _loc2_ in _sounds)
         {
            _loc2_.volume = param1;
         }
      }
      
      public static function getVolumeMusic() : Number
      {
         var _loc1_:Number = NaN;
         for each(var _loc2_ in _music)
         {
            _loc1_ = Number(_loc2_.volume);
         }
         return _loc1_;
      }
      
      public static function setVolumeMusic(param1:Number) : void
      {
         for each(var _loc2_ in _music)
         {
            _loc2_.volume = param1;
         }
      }
      
      private static function setSharedObjMusicMuted(param1:Boolean) : void
      {
         if(_sharedObj != null && _sharedObj.data.isMusicMuted != param1)
         {
            _sharedObj.data.isMusicMuted = param1;
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private static function setSharedObjSoundsMuted(param1:Boolean) : void
      {
         if(_sharedObj != null && _sharedObj.data.areSoundsMuted != param1)
         {
            _sharedObj.data.areSoundsMuted = param1;
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function toggleMuteAll() : void
      {
         toggleMuteSounds();
         toggleMuteMusic();
         _muteCallback(_isMusicMuted);
         if(_guiManager != null)
         {
            if(_isMusicMuted)
            {
               _guiManager.mainHud.soundBtn.upToDownState();
            }
            else
            {
               _guiManager.mainHud.soundBtn.downToUpState();
            }
         }
      }
      
      public static function muteAll() : void
      {
         muteSounds();
         muteMusic();
      }
      
      public static function unmuteAll() : void
      {
         unmuteSounds();
         unmuteMusic();
      }
      
      public static function toggleMuteSounds() : void
      {
         _areSoundsMuted = !_areSoundsMuted;
         setSharedObjSoundsMuted(_areSoundsMuted);
      }
      
      public static function muteSounds() : void
      {
         _areSoundsMuted = true;
         setSharedObjSoundsMuted(true);
      }
      
      public static function unmuteSounds() : void
      {
         _areSoundsMuted = false;
         setSharedObjSoundsMuted(false);
      }
      
      public static function toggleMuteMusic() : void
      {
         for each(var _loc1_ in _music)
         {
            _loc1_.toggleMute();
         }
         _isMusicMuted = !_isMusicMuted;
         setSharedObjMusicMuted(_isMusicMuted);
      }
      
      public static function muteMusic(param1:Boolean = true) : void
      {
         for each(var _loc2_ in _music)
         {
            _loc2_.mute();
         }
         if(param1)
         {
            _isMusicMuted = true;
            setSharedObjMusicMuted(true);
         }
      }
      
      public static function unmuteMusic(param1:Boolean = true) : void
      {
         for each(var _loc2_ in _music)
         {
            _loc2_.unmute();
         }
         if(param1)
         {
            _isMusicMuted = false;
            setSharedObjMusicMuted(false);
         }
      }
      
      public static function togglePauseAll() : void
      {
         togglePauseSounds();
         togglePauseMusic();
      }
      
      public static function pauseAll() : void
      {
         pauseSounds();
         pauseMusic();
      }
      
      public static function unpauseAll() : void
      {
         unpauseSounds();
         unpauseMusic();
      }
      
      public static function togglePauseSounds() : void
      {
         for each(var _loc1_ in _sounds)
         {
            _loc1_.togglePause();
         }
      }
      
      public static function pauseSounds() : void
      {
         for each(var _loc1_ in _sounds)
         {
            _loc1_.pause();
         }
      }
      
      public static function unpauseSounds() : void
      {
         for each(var _loc1_ in _sounds)
         {
            _loc1_.unpause();
         }
      }
      
      public static function togglePauseMusic() : void
      {
         for each(var _loc1_ in _music)
         {
            _loc1_.togglePause();
         }
      }
      
      public static function pauseMusic() : void
      {
         for each(var _loc1_ in _music)
         {
            _loc1_.pause();
         }
      }
      
      public static function unpauseMusic() : void
      {
         for each(var _loc1_ in _music)
         {
            _loc1_.unpause();
         }
      }
      
      public static function stopAll() : void
      {
         stopSounds();
         stopMusic();
      }
      
      public static function stopSounds() : void
      {
         for each(var _loc1_ in _sounds)
         {
            _loc1_.stop();
         }
      }
      
      public static function stopMusic() : void
      {
         for each(var _loc1_ in _music)
         {
            _loc1_.stop();
         }
      }
   }
}

