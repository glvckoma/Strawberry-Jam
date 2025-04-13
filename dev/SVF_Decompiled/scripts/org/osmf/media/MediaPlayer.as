package org.osmf.media
{
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.osmf.events.AudioEvent;
   import org.osmf.events.BufferEvent;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.DynamicStreamEvent;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaElementChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaPlayerCapabilityChangeEvent;
   import org.osmf.events.MediaPlayerStateChangeEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.SeekEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.traits.AudioTrait;
   import org.osmf.traits.BufferTrait;
   import org.osmf.traits.DRMTrait;
   import org.osmf.traits.DVRTrait;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.DynamicStreamTrait;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.traits.PlayTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   import org.osmf.traits.TraitEventDispatcher;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaPlayer extends TraitEventDispatcher
   {
      private static const DEFAULT_UPDATE_INTERVAL:Number = 250;
      
      private var lastCurrentTime:Number = 0;
      
      private var lastBytesLoaded:Number = NaN;
      
      private var _autoPlay:Boolean = true;
      
      private var _autoRewind:Boolean = true;
      
      private var _loop:Boolean = false;
      
      private var _currentTimeUpdateInterval:Number = 250;
      
      private var _currentTimeTimer:Timer = new Timer(250);
      
      private var _state:String;
      
      private var _bytesLoadedUpdateInterval:Number = 250;
      
      private var _bytesLoadedTimer:Timer = new Timer(250);
      
      private var inExecuteAutoRewind:Boolean = false;
      
      private var inSeek:Boolean = false;
      
      private var mediaAtEnd:Boolean = false;
      
      private var mediaPlayerVolume:Number = 1;
      
      private var mediaPlayerVolumeSet:Boolean = false;
      
      private var mediaPlayerMuted:Boolean = false;
      
      private var mediaPlayerMutedSet:Boolean = false;
      
      private var mediaPlayerAudioPan:Number = 0;
      
      private var mediaPlayerAudioPanSet:Boolean = false;
      
      private var mediaPlayerBufferTime:Number = 0;
      
      private var mediaPlayerBufferTimeSet:Boolean = false;
      
      private var mediaPlayerMaxAllowedDynamicStreamIndex:int = 0;
      
      private var mediaPlayerMaxAllowedDynamicStreamIndexSet:Boolean = false;
      
      private var mediaPlayerAutoDynamicStreamSwitch:Boolean = true;
      
      private var mediaPlayerAutoDynamicStreamSwitchSet:Boolean = false;
      
      private var _canPlay:Boolean;
      
      private var _canSeek:Boolean;
      
      private var _temporal:Boolean;
      
      private var _hasAudio:Boolean;
      
      private var _hasDisplayObject:Boolean;
      
      private var _canLoad:Boolean;
      
      private var _canBuffer:Boolean;
      
      private var _isDynamicStream:Boolean;
      
      private var _hasDRM:Boolean;
      
      public function MediaPlayer(param1:MediaElement = null)
      {
         super();
         _state = "uninitialized";
         this.media = param1;
         _currentTimeTimer.addEventListener("timer",onCurrentTimeTimer,false,0,true);
         _bytesLoadedTimer.addEventListener("timer",onBytesLoadedTimer,false,0,true);
      }
      
      override public function set media(param1:MediaElement) : void
      {
         var _loc2_:* = null;
         var _loc3_:LoadTrait = null;
         if(param1 != media)
         {
            mediaAtEnd = false;
            if(media != null)
            {
               inExecuteAutoRewind = false;
               if(playing)
               {
                  (getTraitOrThrow("play") as PlayTrait).stop();
               }
               if(canLoad)
               {
                  _loc3_ = media.getTrait("load") as LoadTrait;
                  if(_loc3_.loadState == "ready")
                  {
                     _loc3_.unload();
                  }
               }
               setState("uninitialized");
               if(media)
               {
                  media.removeEventListener("traitAdd",onTraitAdd);
                  media.removeEventListener("traitRemove",onTraitRemove);
                  media.removeEventListener("mediaError",onMediaError);
                  for each(_loc2_ in media.traitTypes)
                  {
                     updateTraitListeners(_loc2_,false);
                  }
               }
            }
            super.media = param1;
            if(media != null)
            {
               media.addEventListener("traitAdd",onTraitAdd);
               media.addEventListener("traitRemove",onTraitRemove);
               media.addEventListener("mediaError",onMediaError);
               if(media.hasTrait("load") == false)
               {
                  processReadyState();
               }
               for each(_loc2_ in media.traitTypes)
               {
                  updateTraitListeners(_loc2_,true);
               }
            }
            dispatchEvent(new MediaElementChangeEvent("mediaElementChange"));
         }
      }
      
      public function set autoRewind(param1:Boolean) : void
      {
         _autoRewind = param1;
      }
      
      public function get autoRewind() : Boolean
      {
         return _autoRewind;
      }
      
      public function set autoPlay(param1:Boolean) : void
      {
         _autoPlay = param1;
      }
      
      public function get autoPlay() : Boolean
      {
         return _autoPlay;
      }
      
      public function set loop(param1:Boolean) : void
      {
         _loop = param1;
      }
      
      public function get loop() : Boolean
      {
         return _loop;
      }
      
      public function set currentTimeUpdateInterval(param1:Number) : void
      {
         if(_currentTimeUpdateInterval != param1)
         {
            _currentTimeUpdateInterval = param1;
            if(isNaN(_currentTimeUpdateInterval) || _currentTimeUpdateInterval <= 0)
            {
               _currentTimeTimer.stop();
            }
            else
            {
               _currentTimeTimer.delay = _currentTimeUpdateInterval;
               if(temporal)
               {
                  _currentTimeTimer.start();
               }
            }
         }
      }
      
      public function get currentTimeUpdateInterval() : Number
      {
         return _currentTimeUpdateInterval;
      }
      
      public function set bytesLoadedUpdateInterval(param1:Number) : void
      {
         if(_bytesLoadedUpdateInterval != param1)
         {
            _bytesLoadedUpdateInterval = param1;
            if(isNaN(_bytesLoadedUpdateInterval) || _bytesLoadedUpdateInterval <= 0)
            {
               _bytesLoadedTimer.stop();
            }
            else
            {
               _bytesLoadedTimer.delay = _bytesLoadedUpdateInterval;
               if(canLoad)
               {
                  _bytesLoadedTimer.start();
               }
            }
         }
      }
      
      public function get bytesLoadedUpdateInterval() : Number
      {
         return _bytesLoadedUpdateInterval;
      }
      
      public function get state() : String
      {
         return _state;
      }
      
      public function get canPlay() : Boolean
      {
         return _canPlay;
      }
      
      public function get canPause() : Boolean
      {
         return canPlay ? (getTraitOrThrow("play") as PlayTrait).canPause : false;
      }
      
      public function get canSeek() : Boolean
      {
         return _canSeek;
      }
      
      public function get temporal() : Boolean
      {
         return _temporal;
      }
      
      public function get hasAudio() : Boolean
      {
         return _hasAudio;
      }
      
      public function get isDynamicStream() : Boolean
      {
         return _isDynamicStream;
      }
      
      public function get canLoad() : Boolean
      {
         return _canLoad;
      }
      
      public function get canBuffer() : Boolean
      {
         return _canBuffer;
      }
      
      public function get hasDRM() : Boolean
      {
         return _hasDRM;
      }
      
      public function get volume() : Number
      {
         return hasAudio ? AudioTrait(getTraitOrThrow("audio")).volume : mediaPlayerVolume;
      }
      
      public function set volume(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         if(hasAudio)
         {
            (getTraitOrThrow("audio") as AudioTrait).volume = param1;
         }
         else if(param1 != mediaPlayerVolume)
         {
            _loc2_ = true;
         }
         mediaPlayerVolume = param1;
         mediaPlayerVolumeSet = true;
         if(_loc2_)
         {
            dispatchEvent(new AudioEvent("volumeChange",false,false,false,param1));
         }
      }
      
      public function get muted() : Boolean
      {
         return hasAudio ? AudioTrait(getTraitOrThrow("audio")).muted : mediaPlayerMuted;
      }
      
      public function set muted(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(hasAudio)
         {
            (getTraitOrThrow("audio") as AudioTrait).muted = param1;
         }
         else if(param1 != mediaPlayerMuted)
         {
            _loc2_ = true;
         }
         mediaPlayerMuted = param1;
         mediaPlayerMutedSet = true;
         if(_loc2_)
         {
            dispatchEvent(new AudioEvent("mutedChange",false,false,param1));
         }
      }
      
      public function get audioPan() : Number
      {
         return hasAudio ? AudioTrait(getTraitOrThrow("audio")).pan : mediaPlayerAudioPan;
      }
      
      public function set audioPan(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         if(hasAudio)
         {
            (getTraitOrThrow("audio") as AudioTrait).pan = param1;
         }
         else if(param1 != mediaPlayerAudioPan)
         {
            _loc2_ = true;
         }
         mediaPlayerAudioPan = param1;
         mediaPlayerAudioPanSet = true;
         if(_loc2_)
         {
            dispatchEvent(new AudioEvent("panChange",false,false,false,NaN,param1));
         }
      }
      
      public function get paused() : Boolean
      {
         return canPlay ? (getTraitOrThrow("play") as PlayTrait).playState == "paused" : false;
      }
      
      public function pause() : void
      {
         (getTraitOrThrow("play") as PlayTrait).pause();
      }
      
      public function get playing() : Boolean
      {
         return canPlay ? (getTraitOrThrow("play") as PlayTrait).playState == "playing" : false;
      }
      
      public function play() : void
      {
         if(canPlay && canSeek && canSeekTo(0) && mediaAtEnd)
         {
            executeAutoRewind(true);
         }
         else
         {
            (getTraitOrThrow("play") as PlayTrait).play();
         }
      }
      
      public function get seeking() : Boolean
      {
         return canSeek ? (getTraitOrThrow("seek") as SeekTrait).seeking : false;
      }
      
      public function seek(param1:Number) : void
      {
         inSeek = true;
         (getTraitOrThrow("seek") as SeekTrait).seek(param1);
         inSeek = false;
      }
      
      public function canSeekTo(param1:Number) : Boolean
      {
         return (getTraitOrThrow("seek") as SeekTrait).canSeekTo(param1);
      }
      
      public function stop() : void
      {
         (getTraitOrThrow("play") as PlayTrait).stop();
         if(canSeek)
         {
            executeAutoRewind(false);
         }
      }
      
      public function get mediaWidth() : Number
      {
         return _hasDisplayObject ? (getTraitOrThrow("displayObject") as DisplayObjectTrait).mediaWidth : NaN;
      }
      
      public function get mediaHeight() : Number
      {
         return _hasDisplayObject ? (getTraitOrThrow("displayObject") as DisplayObjectTrait).mediaHeight : NaN;
      }
      
      public function get autoDynamicStreamSwitch() : Boolean
      {
         return isDynamicStream ? (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).autoSwitch : mediaPlayerAutoDynamicStreamSwitch;
      }
      
      public function set autoDynamicStreamSwitch(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         if(isDynamicStream)
         {
            (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).autoSwitch = param1;
         }
         else if(param1 != mediaPlayerAutoDynamicStreamSwitch)
         {
            _loc2_ = true;
         }
         mediaPlayerAutoDynamicStreamSwitch = param1;
         mediaPlayerAutoDynamicStreamSwitchSet = true;
         if(_loc2_)
         {
            dispatchEvent(new DynamicStreamEvent("autoSwitchChange",false,false,dynamicStreamSwitching,mediaPlayerAutoDynamicStreamSwitch));
         }
      }
      
      public function get currentDynamicStreamIndex() : int
      {
         return isDynamicStream ? (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).currentIndex : 0;
      }
      
      public function get numDynamicStreams() : int
      {
         return isDynamicStream ? (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).numDynamicStreams : 0;
      }
      
      public function getBitrateForDynamicStreamIndex(param1:int) : Number
      {
         return (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).getBitrateForIndex(param1);
      }
      
      public function get maxAllowedDynamicStreamIndex() : int
      {
         return isDynamicStream ? (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).maxAllowedIndex : mediaPlayerMaxAllowedDynamicStreamIndex;
      }
      
      public function set maxAllowedDynamicStreamIndex(param1:int) : void
      {
         if(isDynamicStream)
         {
            (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).maxAllowedIndex = param1;
         }
         mediaPlayerMaxAllowedDynamicStreamIndex = param1;
         mediaPlayerMaxAllowedDynamicStreamIndexSet = true;
      }
      
      public function get dynamicStreamSwitching() : Boolean
      {
         return isDynamicStream ? (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).switching : false;
      }
      
      public function switchDynamicStreamIndex(param1:int) : void
      {
         (getTraitOrThrow("dynamicStream") as DynamicStreamTrait).switchTo(param1);
      }
      
      public function get displayObject() : DisplayObject
      {
         return _hasDisplayObject ? (getTraitOrThrow("displayObject") as DisplayObjectTrait).displayObject : null;
      }
      
      public function get duration() : Number
      {
         return temporal ? (getTraitOrThrow("time") as TimeTrait).duration : 0;
      }
      
      public function get currentTime() : Number
      {
         return temporal ? (getTraitOrThrow("time") as TimeTrait).currentTime : 0;
      }
      
      public function get buffering() : Boolean
      {
         return canBuffer ? (getTraitOrThrow("buffer") as BufferTrait).buffering : false;
      }
      
      public function get bufferLength() : Number
      {
         return canBuffer ? (getTraitOrThrow("buffer") as BufferTrait).bufferLength : 0;
      }
      
      public function get bufferTime() : Number
      {
         return canBuffer ? (getTraitOrThrow("buffer") as BufferTrait).bufferTime : mediaPlayerBufferTime;
      }
      
      public function set bufferTime(param1:Number) : void
      {
         var _loc2_:Boolean = false;
         if(canBuffer)
         {
            (getTraitOrThrow("buffer") as BufferTrait).bufferTime = param1;
         }
         else if(param1 != mediaPlayerBufferTime)
         {
            _loc2_ = true;
         }
         mediaPlayerBufferTime = param1;
         mediaPlayerBufferTimeSet = true;
         if(_loc2_)
         {
            dispatchEvent(new BufferEvent("bufferTimeChange",false,false,buffering,mediaPlayerBufferTime));
         }
      }
      
      public function get bytesLoaded() : Number
      {
         var _loc1_:Number = 0;
         if(canLoad)
         {
            _loc1_ = (getTraitOrThrow("load") as LoadTrait).bytesLoaded;
            if(isNaN(_loc1_))
            {
               _loc1_ = 0;
            }
         }
         return _loc1_;
      }
      
      public function get bytesTotal() : Number
      {
         var _loc1_:Number = 0;
         if(canLoad)
         {
            _loc1_ = (getTraitOrThrow("load") as LoadTrait).bytesTotal;
            if(isNaN(_loc1_))
            {
               _loc1_ = 0;
            }
         }
         return _loc1_;
      }
      
      public function authenticate(param1:String = null, param2:String = null) : void
      {
         (getTraitOrThrow("drm") as DRMTrait).authenticate(param1,param2);
      }
      
      public function authenticateWithToken(param1:Object) : void
      {
         (getTraitOrThrow("drm") as DRMTrait).authenticateWithToken(param1);
      }
      
      public function get drmState() : String
      {
         return hasDRM ? DRMTrait(media.getTrait("drm")).drmState : "uninitialized";
      }
      
      public function get drmStartDate() : Date
      {
         return hasDRM ? DRMTrait(media.getTrait("drm")).startDate : null;
      }
      
      public function get drmEndDate() : Date
      {
         return hasDRM ? DRMTrait(media.getTrait("drm")).endDate : null;
      }
      
      public function get drmPeriod() : Number
      {
         return hasDRM ? DRMTrait(media.getTrait("drm")).period : NaN;
      }
      
      public function get isDVRRecording() : Boolean
      {
         var _loc1_:DVRTrait = media != null ? media.getTrait("dvr") as DVRTrait : null;
         return _loc1_ != null ? _loc1_.isRecording : false;
      }
      
      private function getTraitOrThrow(param1:String) : MediaTraitBase
      {
         var _loc3_:String = null;
         var _loc2_:String = null;
         if(!media || !media.hasTrait(param1))
         {
            _loc3_ = OSMFStrings.getString("capabilityNotSupported");
            _loc2_ = param1.replace("[class ","");
            _loc2_ = _loc2_.replace("]","").toLowerCase();
            _loc3_ = _loc3_.replace("*trait*",_loc2_);
            throw new IllegalOperationError(_loc3_);
         }
         return media.getTrait(param1);
      }
      
      private function onMediaError(param1:MediaErrorEvent) : void
      {
         setState("playbackError");
         dispatchEvent(param1.clone());
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         updateTraitListeners(param1.traitType,true);
      }
      
      private function onTraitRemove(param1:MediaElementEvent) : void
      {
         updateTraitListeners(param1.traitType,false);
      }
      
      private function updateTraitListeners(param1:String, param2:Boolean, param3:Boolean = true) : void
      {
         var _loc6_:TimeTrait = null;
         var _loc4_:PlayTrait = null;
         var _loc8_:AudioTrait = null;
         var _loc10_:DynamicStreamTrait = null;
         var _loc9_:DisplayObjectTrait = null;
         var _loc11_:LoadTrait = null;
         var _loc5_:String = null;
         var _loc7_:BufferTrait = null;
         if(state == "playbackError" && param3 && param1 != "load")
         {
            return;
         }
         if(param2)
         {
            updateCapabilityForTrait(param1,param2);
         }
         switch(param1)
         {
            case "time":
               changeListeners(param2,param1,"complete",onComplete);
               _temporal = param2;
               if(param2 && _currentTimeUpdateInterval > 0 && !isNaN(_currentTimeUpdateInterval))
               {
                  _currentTimeTimer.start();
               }
               else
               {
                  _currentTimeTimer.stop();
               }
               _loc6_ = TimeTrait(media.getTrait("time"));
               if(_loc6_.currentTime != 0 && _currentTimeUpdateInterval > 0 && !isNaN(_currentTimeUpdateInterval))
               {
                  dispatchEvent(new TimeEvent("currentTimeChange",false,false,currentTime));
               }
               if(_loc6_.duration != 0)
               {
                  dispatchEvent(new TimeEvent("durationChange",false,false,duration));
               }
               break;
            case "play":
               changeListeners(param2,param1,"playStateChange",onPlayStateChange);
               _canPlay = param2;
               _loc4_ = PlayTrait(media.getTrait("play"));
               if(autoPlay && canPlay && !playing && !inSeek)
               {
                  play();
               }
               else if(_loc4_.playState != "stopped")
               {
                  dispatchEvent(new PlayEvent("playStateChange",false,false,param2 ? _loc4_.playState : "stopped"));
               }
               if(_loc4_.canPause)
               {
                  dispatchEvent(new PlayEvent("canPauseChange",false,false,null,param2));
               }
               break;
            case "audio":
               _hasAudio = param2;
               _loc8_ = AudioTrait(media.getTrait("audio"));
               if(mediaPlayerVolumeSet)
               {
                  volume = mediaPlayerVolume;
               }
               else if(mediaPlayerVolume != _loc8_.volume)
               {
                  dispatchEvent(new AudioEvent("volumeChange",false,false,muted,volume,audioPan));
               }
               if(mediaPlayerMutedSet)
               {
                  muted = mediaPlayerMuted;
               }
               else if(mediaPlayerMuted != _loc8_.muted)
               {
                  dispatchEvent(new AudioEvent("mutedChange",false,false,muted,volume,audioPan));
               }
               if(mediaPlayerAudioPanSet)
               {
                  audioPan = mediaPlayerAudioPan;
                  break;
               }
               if(mediaPlayerAudioPan != _loc8_.pan)
               {
                  dispatchEvent(new AudioEvent("panChange",false,false,muted,volume,audioPan));
               }
               break;
            case "seek":
               changeListeners(param2,param1,"seekingChange",onSeeking);
               _canSeek = param2;
               if(SeekTrait(media.getTrait("seek")).seeking && !inExecuteAutoRewind)
               {
                  dispatchEvent(new SeekEvent("seekingChange",false,false,param2));
               }
               break;
            case "dynamicStream":
               _isDynamicStream = param2;
               _loc10_ = DynamicStreamTrait(media.getTrait("dynamicStream"));
               if(mediaPlayerMaxAllowedDynamicStreamIndexSet)
               {
                  maxAllowedDynamicStreamIndex = mediaPlayerMaxAllowedDynamicStreamIndex;
               }
               if(mediaPlayerAutoDynamicStreamSwitchSet)
               {
                  autoDynamicStreamSwitch = mediaPlayerAutoDynamicStreamSwitch;
               }
               else if(mediaPlayerAutoDynamicStreamSwitch != _loc10_.autoSwitch)
               {
                  dispatchEvent(new DynamicStreamEvent("autoSwitchChange",false,false,dynamicStreamSwitching,autoDynamicStreamSwitch));
               }
               if(_loc10_.switching)
               {
                  dispatchEvent(new DynamicStreamEvent("switchingChange",false,false,dynamicStreamSwitching,autoDynamicStreamSwitch));
               }
               dispatchEvent(new DynamicStreamEvent("numDynamicStreamsChange",false,false,dynamicStreamSwitching,autoDynamicStreamSwitch));
               break;
            case "displayObject":
               _hasDisplayObject = param2;
               _loc9_ = DisplayObjectTrait(media.getTrait("displayObject"));
               if(_loc9_.displayObject != null)
               {
                  dispatchEvent(new DisplayObjectEvent("displayObjectChange",false,false,null,displayObject,NaN,NaN,mediaWidth,mediaHeight));
               }
               if(!isNaN(_loc9_.mediaHeight) || !isNaN(_loc9_.mediaWidth))
               {
                  dispatchEvent(new DisplayObjectEvent("mediaSizeChange",false,false,null,displayObject,NaN,NaN,mediaWidth,mediaHeight));
               }
               break;
            case "load":
               changeListeners(param2,param1,"loadStateChange",onLoadState);
               _canLoad = param2;
               _loc11_ = LoadTrait(media.getTrait("load"));
               if(_loc11_.bytesLoaded > 0)
               {
                  dispatchEvent(new LoadEvent("bytesLoadedChange",false,false,null,bytesLoaded));
               }
               if(_loc11_.bytesTotal > 0)
               {
                  dispatchEvent(new LoadEvent("bytesTotalChange",false,false,null,bytesTotal));
               }
               if(param2)
               {
                  _loc5_ = (media.getTrait(param1) as LoadTrait).loadState;
                  if(_loc5_ != "ready" && _loc5_ != "loading")
                  {
                     load();
                  }
                  else if(autoPlay && canPlay && !playing)
                  {
                     play();
                  }
                  if(_bytesLoadedUpdateInterval > 0 && !isNaN(_bytesLoadedUpdateInterval))
                  {
                     _bytesLoadedTimer.start();
                     break;
                  }
                  _bytesLoadedTimer.stop();
               }
               break;
            case "buffer":
               changeListeners(param2,param1,"bufferingChange",onBuffering);
               _canBuffer = param2;
               _loc7_ = BufferTrait(media.getTrait("buffer"));
               if(mediaPlayerBufferTimeSet)
               {
                  bufferTime = mediaPlayerBufferTime;
               }
               else if(mediaPlayerBufferTime != _loc7_.bufferTime)
               {
                  dispatchEvent(new BufferEvent("bufferTimeChange",false,false,false,bufferTime));
               }
               if(_loc7_.buffering)
               {
                  dispatchEvent(new BufferEvent("bufferingChange",false,false,buffering));
               }
               break;
            case "drm":
               _hasDRM = param2;
               dispatchEvent(new DRMEvent("drmStateChange",drmState,false,false,drmStartDate,drmEndDate,drmPeriod));
         }
         if(param2 == false)
         {
            updateCapabilityForTrait(param1,false);
         }
      }
      
      private function updateCapabilityForTrait(param1:String, param2:Boolean) : void
      {
         var _loc3_:String = null;
         switch(param1)
         {
            case "audio":
               _loc3_ = "hasAudioChange";
               _hasAudio = param2;
               break;
            case "buffer":
               _loc3_ = "canBufferChange";
               _canBuffer = param2;
               break;
            case "displayObject":
               _loc3_ = "hasDisplayObjectChange";
               break;
            case "drm":
               _loc3_ = "hasDRMChange";
               _hasDRM = param2;
               break;
            case "dynamicStream":
               _loc3_ = "isDynamicStreamChange";
               _isDynamicStream = param2;
               break;
            case "load":
               _loc3_ = "canLoadChange";
               _canLoad = param2;
               break;
            case "play":
               _loc3_ = "canPlayChange";
               _canPlay = param2;
               break;
            case "seek":
               _loc3_ = "canSeekChange";
               _canSeek = param2;
               break;
            case "time":
               _loc3_ = "temporalChange";
               _temporal = param2;
         }
         if(_loc3_ != null)
         {
            dispatchEvent(new MediaPlayerCapabilityChangeEvent(_loc3_,false,false,param2));
         }
      }
      
      private function changeListeners(param1:Boolean, param2:String, param3:String, param4:Function) : void
      {
         var _loc5_:int = 0;
         if(param1)
         {
            _loc5_ = 1;
            media.getTrait(param2).addEventListener(param3,param4,false,_loc5_);
         }
         else if(media.hasTrait(param2))
         {
            media.getTrait(param2).removeEventListener(param3,param4);
         }
      }
      
      private function onSeeking(param1:SeekEvent) : void
      {
         mediaAtEnd = false;
         if(param1.type == "seekingChange" && param1.seeking)
         {
            setState("buffering");
         }
         else if(canPlay && playing)
         {
            setState("playing");
         }
         else if(canPlay && paused)
         {
            setState("paused");
         }
         else if(canBuffer && buffering)
         {
            setState("buffering");
         }
         else if(!inExecuteAutoRewind)
         {
            setState("ready");
         }
      }
      
      private function onPlayStateChange(param1:PlayEvent) : void
      {
         if(param1.playState == "playing")
         {
            if(canBuffer == false || bufferLength > 0 || bufferTime < 0.001)
            {
               setState("playing");
            }
         }
         else if(param1.playState == "paused")
         {
            setState("paused");
         }
      }
      
      private function onLoadState(param1:LoadEvent) : void
      {
         if(param1.loadState == "ready" && state == "loading")
         {
            processReadyState();
         }
         else if(param1.loadState == "uninitialized")
         {
            setState("uninitialized");
         }
         else if(param1.loadState == "loadError")
         {
            setState("playbackError");
         }
         else if(param1.loadState == "loading")
         {
            setState("loading");
         }
      }
      
      private function processReadyState() : void
      {
         setState("ready");
         if(autoPlay && canPlay && !playing)
         {
            play();
         }
      }
      
      private function onComplete(param1:TimeEvent) : void
      {
         mediaAtEnd = true;
         if(loop && canSeek && canPlay)
         {
            executeAutoRewind(true);
         }
         else if(!loop && canPlay)
         {
            (getTraitOrThrow("play") as PlayTrait).stop();
            if(autoRewind && canSeek)
            {
               executeAutoRewind(false);
            }
            else
            {
               setState("ready");
            }
         }
         else
         {
            setState("ready");
         }
      }
      
      private function executeAutoRewind(param1:Boolean) : void
      {
         var onSeekingChange:*;
         var playAfterAutoRewind:Boolean = param1;
         if(inExecuteAutoRewind == false)
         {
            onSeekingChange = function(param1:SeekEvent):void
            {
               if(param1.seeking == false)
               {
                  removeEventListener("seekingChange",onSeekingChange);
                  if(playAfterAutoRewind)
                  {
                     play();
                  }
                  else
                  {
                     setState("ready");
                  }
                  inExecuteAutoRewind = false;
               }
            };
            inExecuteAutoRewind = true;
            mediaAtEnd = false;
            addEventListener("seekingChange",onSeekingChange);
            seek(0);
         }
      }
      
      private function onCurrentTimeTimer(param1:TimerEvent) : void
      {
         if(temporal && currentTime != lastCurrentTime && (!canSeek || !seeking))
         {
            lastCurrentTime = currentTime;
            dispatchEvent(new TimeEvent("currentTimeChange",false,false,currentTime));
         }
      }
      
      private function onBytesLoadedTimer(param1:TimerEvent) : void
      {
         var _loc2_:LoadEvent = null;
         if(canLoad && bytesLoaded != lastBytesLoaded)
         {
            _loc2_ = new LoadEvent("bytesLoadedChange",false,false,null,bytesLoaded);
            lastBytesLoaded = bytesLoaded;
            dispatchEvent(_loc2_);
         }
      }
      
      private function onBuffering(param1:BufferEvent) : void
      {
         if(param1.buffering)
         {
            setState("buffering");
         }
         else if(canPlay && playing)
         {
            setState("playing");
         }
         else if(canPlay && paused)
         {
            setState("paused");
         }
         else
         {
            setState("ready");
         }
      }
      
      private function setState(param1:String) : void
      {
         if(_state != param1)
         {
            _state = param1;
            dispatchEvent(new MediaPlayerStateChangeEvent("mediaPlayerStateChange",false,false,_state));
            if(param1 == "playbackError")
            {
               for each(var _loc2_ in media.traitTypes)
               {
                  if(_loc2_ != "load")
                  {
                     updateTraitListeners(_loc2_,false,false);
                  }
               }
            }
         }
      }
      
      private function load() : void
      {
         var _loc1_:LoadTrait = null;
         try
         {
            _loc1_ = media.getTrait("load") as LoadTrait;
            if(_loc1_.loadState != "loading" && _loc1_.loadState != "ready")
            {
               _loc1_.load();
            }
         }
         catch(error:IllegalOperationError)
         {
            setState("playbackError");
            dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(7,error.message)));
         }
      }
   }
}

