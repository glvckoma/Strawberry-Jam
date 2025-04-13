package movie
{
   import Enums.StreamDef;
   import avatar.UserCommXtCommManager;
   import collection.StreamDefCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import game.MinigameManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptionFormat;
   import org.osmf.captioning.model.CaptionStyle;
   import org.osmf.containers.MediaContainer;
   import org.osmf.elements.VideoElement;
   import org.osmf.events.BufferEvent;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.MediaPlayerCapabilityChangeEvent;
   import org.osmf.events.MediaPlayerStateChangeEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.events.TimelineMetadataEvent;
   import org.osmf.media.DefaultMediaFactory;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.MediaPlayer;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfoResource;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.TimelineMetadata;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetLoader;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.utils.FCSubscribeHandler;
   
   public class VideoPlayerOSMF extends Sprite
   {
      private var _videoMediaHelper:MediaHelper;
      
      private var _playerPopup:MovieClip;
      
      private var _videoLayer:Sprite;
      
      private var _videoPlayer:MediaPlayer;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _streamDefs:StreamDefCollection;
      
      private var _currStreamDef:StreamDef;
      
      private var _currVideoIdx:int;
      
      private var _loadText:TextField;
      
      private var _hasMediaId:Boolean;
      
      private var _skinFrameId:int = 1;
      
      private var _subTitleTextField:TextField;
      
      private var _graySubtitleBox:MovieClip;
      
      private var _musicMutedByPlayer:Boolean;
      
      private var _isReady:Boolean;
      
      private var _pausedByUser:Boolean;
      
      private var _readyToStart:Boolean;
      
      private var _popupLoaded:Boolean;
      
      private var _netConnected:Boolean;
      
      private var _playerWidth:int;
      
      private var _playerHeight:int;
      
      private var _info:Object;
      
      private var _shouldRepeatSingleMovie:Boolean;
      
      private var _container:MediaContainer;
      
      private var _videoElement:MediaElement;
      
      private var _mediaFactory:DefaultMediaFactory;
      
      private var _FCS:FCSubscribeHandler;
      
      private var _isLive:Boolean;
      
      private var _bufferTimer:Timer;
      
      private var _startUpTimer:Timer;
      
      private var _captionMetadata:TimelineMetadata;
      
      private var _theaterWindow:MovieClip;
      
      private var _mouseOverTimer:Timer;
      
      private var _closeCallback:Function;
      
      public function VideoPlayerOSMF()
      {
         super();
      }
      
      public function init(param1:StreamDefCollection, param2:int = -1, param3:int = -1, param4:Boolean = true, param5:Number = 512, param6:Number = 288, param7:Function = null) : void
      {
         _streamDefs = param1;
         _playerWidth = param5;
         _playerHeight = param6;
         _shouldRepeatSingleMovie = param4;
         _currVideoIdx = param3;
         _closeCallback = param7;
         _mouseOverTimer = new Timer(10,300);
         _mouseOverTimer.addEventListener("timer",onMouseOverTimer,false,0,true);
         if(_currVideoIdx >= _streamDefs.length || _currVideoIdx < 0)
         {
            _currVideoIdx = Math.round(Math.random() * (_streamDefs.length - 1));
         }
         _currStreamDef = _streamDefs.getStreamDefItem(_currVideoIdx);
         if(param2 >= 0)
         {
            _videoMediaHelper = new MediaHelper();
            _videoMediaHelper.init(param2,mediaHelperCallback);
            _hasMediaId = true;
         }
         _startUpTimer = new Timer(5000);
         _videoPlayer = new MediaPlayer();
         _container = new MediaContainer();
         _mediaFactory = new DefaultMediaFactory();
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            loadPlugin("org.osmf.captioning.CaptioningPluginInfo");
         }
         _container.width = _playerWidth;
         _container.height = _playerHeight;
         _videoPlayer.autoPlay = true;
         _videoPlayer.autoRewind = param4;
         _videoPlayer.addEventListener("canPlayChange",canPlay,false,0,true);
         _videoPlayer.addEventListener("playStateChange",onStateChange,false,0,true);
         _videoPlayer.addEventListener("bufferingChange",onBufferChange,false,0,true);
         _videoPlayer.addEventListener("mediaPlayerStateChange",onMediaPlayerStateChange,false,0,true);
         _videoPlayer.addEventListener("mediaSizeChange",onMediaSizeChange,false,0,true);
         _videoPlayer.addEventListener("complete",completeHandler,false,0,true);
         if(_hasMediaId)
         {
            _videoPlayer.addEventListener("bytesLoadedChange",onBytesLoadedChange,false,0,true);
         }
         if(_isLive)
         {
            _videoPlayer.addEventListener("bufferLengthChange",onBufferLengthChange,false,0,true);
         }
         _videoPlayer.currentTimeUpdateInterval = 100;
         if(_hasMediaId)
         {
            _container.x -= _playerWidth * 0.5;
            _container.y -= _playerHeight * 0.5;
            UserCommXtCommManager.sendPermEmote(542);
            SBTracker.push();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            _theaterWindow = MovieClip(this.parent);
            _theaterWindow.parent.mouseEnabled = true;
            _theaterWindow.parent.mouseChildren = true;
            _loadingSpiral = new LoadingSpiral(_theaterWindow,_theaterWindow.width * 0.5,_theaterWindow.height * 0.5);
            _theaterWindow.hoverState.addEventListener("mouseDown",onPlayPauseBtn,false,0,true);
            _theaterWindow.hoverState.addEventListener("rollOut",onRollOut,false,0,true);
            _theaterWindow.hoverState.addEventListener("rollOver",onRollOver,false,0,true);
            _theaterWindow.playPauseBtn.visible = false;
            _theaterWindow.playPauseBtn.gotoAndStop("pause");
            _theaterWindow.videoLayer.addChild(_container);
            _subTitleTextField = _theaterWindow.subtitle;
            _subTitleTextField.htmlText = "";
            _graySubtitleBox = _theaterWindow.grayBox;
            _graySubtitleBox.visible = false;
            _popupLoaded = true;
            playVideoIdx(_currVideoIdx);
         }
      }
      
      private function loadPlugin(param1:String) : void
      {
         var _loc2_:MediaResourceBase = null;
         var _loc3_:Class = null;
         if(param1.substr(0,4) == "http" || param1.substr(0,4) == "file")
         {
            _loc2_ = new URLResource(param1);
         }
         else
         {
            _loc3_ = getDefinitionByName(param1) as Class;
            _loc2_ = new PluginInfoResource(new _loc3_());
         }
         loadPluginFromResource(_loc2_);
      }
      
      private function loadPluginFromResource(param1:MediaResourceBase) : void
      {
         _mediaFactory.addEventListener("pluginLoad",onPluginLoaded);
         _mediaFactory.addEventListener("pluginLoadError",onPluginLoadFailed);
         _mediaFactory.loadPlugin(param1);
      }
      
      private function onPluginLoaded(param1:MediaFactoryEvent) : void
      {
         trace("Plugin LOADED!");
      }
      
      private function onPluginLoadFailed(param1:MediaFactoryEvent) : void
      {
         trace("Plugin LOAD FAILED!");
      }
      
      private function onPlayPauseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            _videoPlayer.pause();
            _mouseOverTimer.reset();
            param1.currentTarget.parent.playPauseBtn.gotoAndStop("play");
            _pausedByUser = true;
         }
         else if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "pause")
         {
            param1.currentTarget.parent.playPauseBtn.gotoAndStop("pause");
            _videoPlayer.play();
            _mouseOverTimer.start();
            param1.currentTarget.parent.playPauseBtn.alpha = 1;
            _pausedByUser = false;
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            _mouseOverTimer.reset();
            param1.currentTarget.parent.playPauseBtn.visible = false;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            _mouseOverTimer.start();
            param1.currentTarget.parent.playPauseBtn.alpha = 1;
            param1.currentTarget.parent.playPauseBtn.visible = true;
         }
      }
      
      private function onMouseOverTimer(param1:TimerEvent) : void
      {
         if(param1.currentTarget.currentCount > 200)
         {
            if(_theaterWindow)
            {
               _theaterWindow.playPauseBtn.alpha -= 0.01;
            }
            else if(_playerPopup)
            {
               _playerPopup.playPauseBtn.alpha -= 0.01;
            }
            if(param1.currentTarget.currentCount == _mouseOverTimer.repeatCount)
            {
               _mouseOverTimer.reset();
            }
         }
      }
      
      private function onBytesLoadedChange(param1:LoadEvent) : void
      {
         param1.stopPropagation();
         if(_playerPopup.loadTxt)
         {
            _playerPopup.loadTxt.text = int(param1.bytes / param1.currentTarget.bytesTotal * 100) + "%";
         }
      }
      
      private function onBufferLengthChange(param1:BufferEvent) : void
      {
         if(param1.bufferLength <= 0.01)
         {
            _bufferTimer = new Timer(10000);
            _bufferTimer.addEventListener("timer",onCheckBufferLength);
            _bufferTimer.start();
         }
         else if(_bufferTimer)
         {
            _bufferTimer.stop();
            _bufferTimer.removeEventListener("timer",onCheckBufferLength);
            _bufferTimer = null;
         }
      }
      
      private function onMediaPlayerStateChange(param1:MediaPlayerStateChangeEvent) : void
      {
         param1.stopPropagation();
         if(param1.state == "buffering")
         {
         }
         if(param1.state == "playing")
         {
         }
      }
      
      private function onCheckBufferLength(param1:TimerEvent) : void
      {
         new SBOkPopup(GuiManager.guiLayer,"This video is not available anymore.");
      }
      
      private function onBufferChange(param1:BufferEvent) : void
      {
         param1.stopPropagation();
         if(param1.buffering)
         {
            addSpiral();
         }
         else
         {
            removeSpiral();
         }
      }
      
      private function onTimeEvent(param1:TimeEvent) : void
      {
      }
      
      private function canPlay(param1:MediaPlayerCapabilityChangeEvent) : void
      {
         if(_startUpTimer)
         {
            _startUpTimer.addEventListener("timer",onStartupCheck);
            _startUpTimer.start();
         }
      }
      
      private function onMediaSizeChange(param1:DisplayObjectEvent) : void
      {
         if(_startUpTimer)
         {
            _startUpTimer.stop();
            _startUpTimer.removeEventListener("timer",onStartupCheck);
            _startUpTimer = null;
         }
      }
      
      private function onStartupCheck(param1:TimerEvent) : void
      {
         _startUpTimer.stop();
         _startUpTimer.removeEventListener("timer",onStartupCheck);
         _startUpTimer = null;
      }
      
      private function onStateChange(param1:PlayEvent) : void
      {
         if(param1.playState == "playing")
         {
            SBTracker.trackPageview("/game/play/video/#" + _currStreamDef.defId);
         }
      }
      
      public function destroy() : void
      {
         destroyPlayerItems();
         if(_videoMediaHelper)
         {
            _videoMediaHelper.destroy();
            _videoMediaHelper = null;
         }
         if(_playerPopup)
         {
            _playerPopup.removeEventListener("mouseDown",mouseDown);
            _playerPopup["bx"].removeEventListener("mouseDown",onClose);
            _playerPopup.hoverState.removeEventListener("mouseDown",onPlayPauseBtn);
            _playerPopup.hoverState.removeEventListener("rollOut",onRollOut);
            _playerPopup.hoverState.removeEventListener("rollOver",onRollOver);
            DarkenManager.unDarken(_playerPopup);
            GuiManager.guiLayer.removeChild(_playerPopup);
            _playerPopup.visible = false;
            _playerPopup = null;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         _currStreamDef = null;
         if(_musicMutedByPlayer)
         {
            _musicMutedByPlayer = false;
            SBAudio.unmuteMusic(false);
         }
         if(_theaterWindow)
         {
            _theaterWindow.hoverState.removeEventListener("mouseDown",onPlayPauseBtn);
            _theaterWindow.hoverState.removeEventListener("rollOut",onRollOut);
            _theaterWindow.hoverState.removeEventListener("rollOver",onRollOver);
            _theaterWindow = null;
         }
         if(!MinigameManager.inMinigame() && _hasMediaId)
         {
            UserCommXtCommManager.sendPermEmote(-1);
         }
      }
      
      public function toggleSound() : void
      {
         if(_videoPlayer.volume == 0)
         {
            _videoPlayer.volume = 1;
         }
         else
         {
            _videoPlayer.volume = 0;
         }
      }
      
      public function setSkinFrame(param1:int) : void
      {
         _skinFrameId = param1;
         if(_playerPopup && _playerPopup.currentFrame != _skinFrameId)
         {
            _playerPopup.gotoAndPlay(_skinFrameId);
         }
      }
      
      public function togglePlayPause(param1:Boolean) : void
      {
         if(param1 && !_pausedByUser)
         {
            _videoPlayer.play();
         }
         else
         {
            _videoPlayer.pause();
         }
      }
      
      private function destroyPlayerItems() : void
      {
         if(_startUpTimer)
         {
            _startUpTimer.stop();
            _startUpTimer.removeEventListener("timer",onStartupCheck);
            _startUpTimer = null;
         }
         if(_bufferTimer)
         {
            _bufferTimer.stop();
            _bufferTimer.removeEventListener("timer",onCheckBufferLength);
            _bufferTimer = null;
         }
         if(_videoPlayer)
         {
            _videoPlayer.stop();
            _videoPlayer.media = null;
            if(_container.containsMediaElement(_videoElement))
            {
               _container.removeMediaElement(_videoElement);
            }
            while(_container.numChildren > 0)
            {
               _container.removeChildAt(0);
            }
            _videoPlayer.removeEventListener("canPlayChange",canPlay);
            _videoPlayer.removeEventListener("playStateChange",onStateChange);
            _videoPlayer.removeEventListener("bufferingChange",onBufferChange);
            _videoPlayer.removeEventListener("mediaPlayerStateChange",onMediaPlayerStateChange);
            _videoPlayer.removeEventListener("mediaSizeChange",onMediaSizeChange);
            if(_isLive)
            {
               _videoPlayer.removeEventListener("bufferLengthChange",onBufferLengthChange);
            }
            _videoElement = null;
            _container = null;
            _videoPlayer = null;
            _mediaFactory = null;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _playerPopup = MovieClip(param1.getChildAt(0));
            if(_playerPopup.currentFrame != _skinFrameId)
            {
               _playerPopup.gotoAndPlay(_skinFrameId);
            }
            GuiManager.guiLayer.addChild(_playerPopup);
            if(_currStreamDef && _currStreamDef.individualTitleId)
            {
               LocalizationManager.translateId(_playerPopup.videoTitleTxt,_currStreamDef.individualTitleId);
            }
            else
            {
               LocalizationManager.translateId(_playerPopup.videoTitleTxt,11392);
            }
            _playerPopup.x = 900 * 0.5;
            _playerPopup.y = 550 * 0.5;
            _playerPopup.itemLayer.addChild(_container);
            _playerPopup["bx"].addEventListener("mouseDown",onClose);
            _playerPopup.hoverState.addEventListener("mouseDown",onPlayPauseBtn);
            _playerPopup.hoverState.addEventListener("rollOut",onRollOut,false,0,true);
            _playerPopup.hoverState.addEventListener("rollOver",onRollOver,false,0,true);
            _playerPopup.playPauseBtn.visible = false;
            _playerPopup.playPauseBtn.gotoAndStop("pause");
            _playerPopup.loadTxt.text = "0%";
            _subTitleTextField = _playerPopup.subtitle;
            _subTitleTextField.htmlText = "";
            _graySubtitleBox = _playerPopup.grayBox;
            _graySubtitleBox.visible = false;
            _playerPopup.addEventListener("mouseDown",mouseDown);
            DarkenManager.darken(_playerPopup);
            _loadingSpiral = new LoadingSpiral(_playerPopup.itemLayer);
            _popupLoaded = true;
            playVideoIdx(_currVideoIdx);
         }
      }
      
      public function playVideoIdx(param1:int) : void
      {
         addSpiral();
         _currVideoIdx = param1;
         _currStreamDef = _streamDefs.getStreamDefItem(_currVideoIdx);
         playNonStreaming();
      }
      
      private function playNonStreaming() : void
      {
         var _loc1_:Metadata = null;
         var _loc2_:URLResource = new URLResource(LoaderCache.fetchCDNURL("streams/" + _currStreamDef.defId + ".flv"));
         onHideCaption(null);
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG && _currStreamDef.subtitleId != 0)
         {
            _loc1_ = new Metadata();
            _loc1_.addValue("uri",LoaderCache.fetchCDNURL("subtitle/" + _currStreamDef.subtitleId + "/" + LocalizationManager.currentLanguage));
            MediaResourceBase(_loc2_).addMetadataValue("http://www.osmf.org/captioning/1.0",_loc1_);
         }
         var _loc3_:NetLoader = new NetLoader();
         _mediaFactory.addItem(new MediaFactoryItem("org.osmf.elements.video",_loc3_.canHandleResource,createVideoElement));
         _videoElement = _mediaFactory.createMediaElement(_loc2_);
         _videoElement.addEventListener("traitAdd",onTraitAdd);
         _captionMetadata = _videoElement.getMetadata("http://www.osmf.org/temporal/captioning") as TimelineMetadata;
         if(_captionMetadata == null)
         {
            _captionMetadata = new TimelineMetadata(_videoElement);
            _videoElement.addMetadata("http://www.osmf.org/temporal/captioning",_captionMetadata);
         }
         _captionMetadata.addEventListener("markerTimeReached",onShowCaption);
         _captionMetadata.addEventListener("markerAdd",onHideCaption);
         _videoElement.addEventListener("mediaError",onMediaError,false,0,true);
         setMediaElement(_videoElement);
         enablePlayerControls(true);
         if(!SBAudio.isMusicMuted)
         {
            SBAudio.muteMusic(false);
            _musicMutedByPlayer = true;
         }
         else
         {
            _videoPlayer.volume = 0;
         }
      }
      
      private function setMediaElement(param1:MediaElement) : void
      {
         if(_videoPlayer.media != null && _container.containsMediaElement(_videoPlayer.media))
         {
            _container.removeMediaElement(_videoPlayer.media);
         }
         if(param1 != null)
         {
            _container.addMediaElement(param1);
         }
         _videoPlayer.media = param1;
      }
      
      private function enablePlayerControls(param1:Boolean = true) : void
      {
      }
      
      private function createVideoElement() : MediaElement
      {
         return new VideoElement();
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         var _loc2_:* = param1.traitType;
         if("seek" !== _loc2_)
         {
         }
      }
      
      private function onShowCaption(param1:TimelineMetadataEvent) : void
      {
         var _loc2_:Caption = param1.marker as Caption;
         if(_loc2_ != null)
         {
            _subTitleTextField.htmlText = _loc2_.text;
            if(!_graySubtitleBox.visible)
            {
               _graySubtitleBox.visible = true;
            }
         }
      }
      
      private function onHideCaption(param1:TimelineMetadataEvent) : void
      {
         _subTitleTextField.htmlText = "";
         _graySubtitleBox.visible = false;
      }
      
      private function onMediaError(param1:MediaErrorEvent) : void
      {
         trace("Media Load Error : " + param1.error.errorID + " - " + param1.error.message);
      }
      
      private function formatCaption(param1:Caption) : void
      {
         var _loc3_:* = 0;
         var _loc5_:CaptionFormat = null;
         var _loc2_:TextFormat = null;
         var _loc4_:CaptionStyle = null;
         _loc3_ = 0;
         while(_loc3_ < param1.numCaptionFormats)
         {
            _loc5_ = param1.getCaptionFormatAt(_loc3_);
            _loc2_ = new TextFormat();
            _loc4_ = _loc5_.style;
            if(_loc4_.textColor != null)
            {
               _loc2_.color = _loc4_.textColor;
            }
            if(_loc4_.fontFamily != "")
            {
               _loc2_.font = _loc4_.fontFamily;
            }
            if(_loc4_.fontSize > 0)
            {
               _loc2_.size = _loc4_.fontSize;
            }
            if(_loc4_.fontStyle != "")
            {
               _loc2_.italic = _loc4_.fontStyle == "italic" ? true : false;
            }
            if(_loc4_.fontWeight != "")
            {
               _loc2_.bold = _loc4_.fontWeight == "bold" ? true : false;
            }
            if(_loc4_.textAlign != "")
            {
               _loc2_.align = _loc4_.textAlign;
            }
            _playerPopup.subtitle.setTextFormat(_loc2_,_loc5_.startIndex,_loc5_.endIndex);
            if(_playerPopup.subtitle.wordWrap != _loc4_.wrapOption)
            {
               _playerPopup.subtitle.wordWrap = _loc4_.wrapOption;
            }
            _loc3_++;
         }
      }
      
      private function onSMILPluginLoaded(param1:MediaFactoryEvent) : void
      {
         var _loc2_:DynamicStreamingResource = new DynamicStreamingResource("http://wac.6A16.edgecastcdn.net/006A16/IntroVideo/manifest.smil","recorded");
         _loc2_.urlIncludesFMSApplicationInstance = true;
         _videoElement = _mediaFactory.createMediaElement(_loc2_);
         _videoPlayer.media = _videoElement;
         _videoPlayer.bufferTime = 6;
         _container.addMediaElement(_videoElement);
         if(SBAudio.isMusicMuted)
         {
            _videoPlayer.volume = 0;
         }
      }
      
      private function playLiveStream(param1:int) : void
      {
         _FCS = new FCSubscribeHandler();
         _FCS.run("mba_opensea","rtmp://fml.6A16.edgecastcdn.net/206A16",this);
      }
      
      public function fcSubscribeDone() : void
      {
         var _loc1_:StreamingURLResource = new StreamingURLResource("rtmp://fml.6A16.edgecastcdn.net/206A16/mba_opensea","live");
         _videoElement = _mediaFactory.createMediaElement(_loc1_);
         _videoPlayer.media = _videoElement;
         _videoPlayer.bufferTime = 6;
         _container.addMediaElement(_videoElement);
         if(SBAudio.isMusicMuted)
         {
            _videoPlayer.volume = 0;
         }
      }
      
      private function onPluginLoadError(param1:MediaFactoryEvent) : void
      {
         trace("FAILED TO LOAD PLUGIN");
      }
      
      private function completeHandler(param1:TimeEvent) : void
      {
         addSpiral();
         _videoPlayer.stop();
         _container.removeMediaElement(_videoElement);
         if(_currVideoIdx < _streamDefs.length - 1)
         {
            _currVideoIdx++;
         }
         else
         {
            _currVideoIdx = 0;
         }
         _currStreamDef = _streamDefs.getStreamDefItem(_currVideoIdx);
         if(_shouldRepeatSingleMovie)
         {
            playVideoIdx(_currVideoIdx);
         }
         else
         {
            onClose(null);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(_playerPopup);
         if(_hasMediaId)
         {
            SBTracker.pop();
         }
         destroy();
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
      }
      
      private function removeSpiral() : void
      {
         if(_hasMediaId)
         {
            if(_playerPopup.itemLayer.contains(_loadingSpiral))
            {
               _playerPopup.itemLayer.removeChild(_loadingSpiral);
            }
         }
         else if(_theaterWindow.contains(_loadingSpiral))
         {
            _theaterWindow.removeChild(_loadingSpiral);
         }
      }
      
      private function addSpiral() : void
      {
         if(_hasMediaId)
         {
            if(_loadingSpiral && !_playerPopup.itemLayer.contains(_loadingSpiral))
            {
               _playerPopup.itemLayer.addChild(_loadingSpiral);
            }
         }
         else if(_loadingSpiral && !_theaterWindow.contains(_loadingSpiral))
         {
            _theaterWindow.addChild(_loadingSpiral);
         }
      }
      
      private function mouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

