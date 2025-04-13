package gui
{
   import avatar.AvatarUtility;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.LoaderCache;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class FirstFiveMinutes extends Sprite
   {
      public static const MIRA_HIGHLIGHT_MEDIA_ID:int = 45;
      
      public static const GO_HERE_MEDIA_ID:int = 46;
      
      public static const COLOR_TAB_HIGHLIGHT_MEDIA_ID:int = 51;
      
      public static const EYE_TAB_HIGHLIGHT_MEDIA_ID:int = 52;
      
      public static const PATTERN_TAB_HIGHLIGHT_MEDIA_ID:int = 53;
      
      public static const AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID:int = 54;
      
      public static const CHAR_WINDOW_MEDIA_ID:int = 55;
      
      public static const ACHIEVEMENT_POPUP_MEDIA_ID:int = 56;
      
      public static const SKIP_BUTTON:int = 392;
      
      public static const AVATAR_EDITOR_X_BTN:int = 0;
      
      public static const AVATAR_EDITOR_BLOCK:int = 1;
      
      public static const COLOR_FUNCTION_ID:int = 2;
      
      public static const EYE_FUNCTION_ID:int = 3;
      
      public static const PATTERN_FUNCTION_ID:int = 4;
      
      public static const ARROW_U_MEDIA_ID:int = 47;
      
      public static const ARROW_D_MEDIA_ID:int = 48;
      
      public static const ARROW_R_MEDIA_ID:int = 49;
      
      public static const ARROW_L_MEDIA_ID:int = 50;
      
      public var isHelpBubble:Boolean;
      
      private const REPLAY_STREAM_TIME:int = 10;
      
      private var _streamBaseURL:String;
      
      private var _sets:Array;
      
      private var _fullCommandSets:Array;
      
      private var _avtMC:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _worldLayer:SortLayer;
      
      private var _chatLayer:DisplayLayer;
      
      private var _doneCallback:Function;
      
      private var _shardRequestSent:Boolean;
      
      private var _currSetProcessed:Boolean;
      
      private var _setNumber:int;
      
      private var _currSound:Sound;
      
      private var _currSoundChannel:SoundChannel;
      
      private var _currSoundTransform:SoundTransform;
      
      private var _currSoundAdvances:Boolean;
      
      private var _currSoundTimer:Timer;
      
      private var _currSoundMcOn:MovieClip;
      
      private var _currSoundMcOff:MovieClip;
      
      private var _shamanShouldTalk:Boolean;
      
      private var _repeatStream:Boolean;
      
      private var _currSoundMustFinishBeforeAdvancing:Boolean;
      
      private var _advanceOnEventTriggered:Boolean;
      
      private var _advanceOnWalkIn:Boolean;
      
      private var _isSkipping:Boolean;
      
      private var _delayTimer:Timer;
      
      private var _standAloneDelay:Boolean;
      
      private var _timerTriggered:Boolean;
      
      private var _popup:ChatBalloon;
      
      private var _chatPopup:ChatBalloon;
      
      private var _delayPopupVisibility:Boolean;
      
      private var _helpBubble:GuiHelpTextBubble;
      
      private var _mediaHelpers:Array;
      
      private var _modifiedObject:String;
      
      private var _nextControl:String;
      
      private var _soundTimer:Timer;
      
      private var _uArrow:MovieClip;
      
      private var _dArrow:MovieClip;
      
      private var _lArrow:MovieClip;
      
      private var _rArrow:MovieClip;
      
      private var _goToCircle:MovieClip;
      
      private var _miraHighlight:MovieClip;
      
      private var _colorTabHighlight:MovieClip;
      
      private var _eyeTabHighlight:MovieClip;
      
      private var _patternTabHighlight:MovieClip;
      
      private var _avtEditorXBtnHighlight:MovieClip;
      
      private var _charWindowHighlight:MovieClip;
      
      private var _achievementPopup:MovieClip;
      
      private var _skipBtn:MovieClip;
      
      private var _avatarEditor:AvatarEditor;
      
      private var _roomMgr:RoomManagerWorld;
      
      private var _trackingNames:Array;
      
      public function FirstFiveMinutes()
      {
         super();
      }
      
      public function init(param1:Array, param2:MovieClip, param3:DisplayLayer, param4:SortLayer, param5:DisplayLayer, param6:Function, param7:Boolean = false) : void
      {
         _streamBaseURL = gMainFrame.clientInfo.contentURL;
         _sets = param1;
         _fullCommandSets = param1.slice();
         _setNumber = 0;
         _avtMC = param2;
         _guiLayer = param3;
         _worldLayer = param4;
         _chatLayer = param5;
         _roomMgr = RoomManagerWorld.instance;
         _doneCallback = param6;
         _roomMgr.callback_TriggerWalkIn = advanceOnWalkIn;
         _isSkipping = false;
         _mediaHelpers = [];
         _trackingNames = ["Welcome to Jamaa","Click the mouse","Hello there","I am Liza","We Shamans","Do you see that statue","That is Mira","You\'ll learn about Mira","Every animal is special","Make yourself unique","Click on the animal picture","Great job!","Click on the color tab","Click on the eye tab","Click on the pattern tab","Click on the x","Excellent work","By changing your colors","Achievements are awards","You have done so well","I want to give you gems","Gems can be used","Point to the gems","Your training is finished","I think you are ready","Good luck"];
         isHelpBubble = param7;
         initAssets();
         processCurrentSet();
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         _sets.splice(0,_sets.length);
         _sets = null;
         _doneCallback = null;
         _currSound = null;
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = null;
         }
         if(_currSoundTimer)
         {
            _currSoundTimer.stop();
            _currSoundTimer = null;
         }
         if(_delayTimer)
         {
            _delayTimer.stop();
            _delayTimer = null;
         }
         if(_soundTimer)
         {
            _soundTimer.stop();
            _soundTimer = null;
         }
         if(_mediaHelpers)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaHelpers.length)
            {
               _mediaHelpers[0].destroy();
               _loc1_++;
            }
            _mediaHelpers.splice(0,_mediaHelpers.length);
         }
         if(_avatarEditor)
         {
            _avatarEditor = null;
         }
         if(_skipBtn)
         {
            _skipBtn.removeEventListener("mouseDown",skipFFM);
            _guiLayer.removeChild(_skipBtn);
            _skipBtn.visible = false;
            _skipBtn = null;
         }
         if(_avtMC)
         {
            _worldLayer.removeChild(_avtMC.parent);
            _avtMC = null;
         }
      }
      
      public function skipFFM(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _delayPopupVisibility = false;
         _currSoundMustFinishBeforeAdvancing = false;
         _isSkipping = true;
         processAllSets();
         delayCompleteHandler(null);
         _sets.splice(0,_sets.length);
         _doneCallback();
      }
      
      public function processAndSplice(param1:String = null, param2:String = null) : void
      {
         processCurrentSet();
         _sets.splice(0,1);
      }
      
      public function doNextSet(param1:Boolean, param2:Array = null) : void
      {
         if(param1)
         {
            if(param2 != null)
            {
               _sets = param2;
               _currSetProcessed = false;
               processCurrentSet();
            }
         }
         else
         {
            processCurrentSet();
            _sets.splice(0,1);
            processCurrentSet();
         }
      }
      
      public function reloadSets(param1:Array = null) : void
      {
         if(param1 == null)
         {
            processCurrentSet();
         }
         else
         {
            if(_delayTimer)
            {
               _delayTimer.removeEventListener("timer",delayCompleteHandler);
               _delayTimer.stop();
               _delayTimer = null;
            }
            _sets = param1;
            _currSetProcessed = false;
            processCurrentSet();
         }
      }
      
      public function processAllSets() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc1_:int = 0;
         if(_fullCommandSets && _fullCommandSets.length >= _setNumber)
         {
            _loc2_ = 0;
            while(_loc2_ <= _setNumber)
            {
               _loc3_ = _fullCommandSets[_loc2_];
               if(_loc3_ && _loc3_.length > 0)
               {
                  _loc1_ = 0;
                  while(_loc1_ < _loc3_.length)
                  {
                     processCommand(_loc3_[_loc1_]);
                     _loc1_++;
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public function processCurrentSet() : void
      {
         var _loc2_:Array = null;
         var _loc1_:int = 0;
         if(_sets && _sets.length > 0)
         {
            _loc2_ = _sets[0];
            if(_loc2_ && _loc2_.length > 0)
            {
               _loc1_ = 0;
               while(_loc1_ < _loc2_.length)
               {
                  processCommand(_loc2_[_loc1_]);
                  _loc1_++;
               }
               _currSetProcessed = !_currSetProcessed;
            }
         }
         else if(_doneCallback != null)
         {
            _doneCallback();
            _doneCallback = null;
         }
      }
      
      public function setAvatarEditor(param1:AvatarEditor) : void
      {
         _avatarEditor = param1;
      }
      
      public function trackUserFFMStateChange(param1:String) : void
      {
         trace("tracking stateName:" + param1);
         SBTracker.trackPageview("/game/play/FFM/#" + param1);
      }
      
      public function advanceOnCallback() : void
      {
         advanceOnClickHandler(null);
      }
      
      private function initAssets() : void
      {
         if(isHelpBubble)
         {
            _helpBubble = GETDEFINITIONBYNAME("HelpTxtBubble");
            _helpBubble.init();
         }
         else
         {
            _popup = GETDEFINITIONBYNAME("ChatBalloonShamanBlockNEW");
            _popup.init(10,AvatarUtility.getAvatarEmoteBgOffset,true,1,RoomManagerWorld.instance.layerManager.bkg.scaleX);
            _guiLayer.addChild(_popup);
            _popup.visible = false;
            _chatPopup = GETDEFINITIONBYNAME("ChatBalloonShamanNEW");
            _chatPopup.init(10,AvatarUtility.getAvatarEmoteBgOffset,false,1,RoomManagerWorld.instance.layerManager.bkg.scaleX);
            _guiLayer.addChild(_chatPopup);
            _chatPopup.visible = false;
            _uArrow = new MovieClip();
            _dArrow = new MovieClip();
            _lArrow = new MovieClip();
            _rArrow = new MovieClip();
            _goToCircle = new MovieClip();
            _miraHighlight = new MovieClip();
            _colorTabHighlight = new MovieClip();
            _eyeTabHighlight = new MovieClip();
            _patternTabHighlight = new MovieClip();
            _avtEditorXBtnHighlight = new MovieClip();
            _charWindowHighlight = new MovieClip();
            _achievementPopup = new MovieClip();
            _skipBtn = new MovieClip();
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            switch(param1.mediaHelper.id)
            {
               case 47:
                  _uArrow.addChild(param1);
                  break;
               case 48:
                  _dArrow.addChild(param1);
                  break;
               case 50:
                  _lArrow.addChild(param1);
                  break;
               case 49:
                  _rArrow.addChild(param1);
                  break;
               case 46:
                  _goToCircle.addChild(param1);
                  _worldLayer.addChild(_goToCircle);
                  _goToCircle.visible = false;
                  _goToCircle.x = 620;
                  _goToCircle.y = 550;
                  MovieClip(_goToCircle.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(_goToCircle.getChildAt(0)).circle.gotoAndStop(1);
                  break;
               case 45:
                  _miraHighlight.addChild(param1);
                  _worldLayer.addChild(_miraHighlight);
                  _miraHighlight.visible = false;
                  _miraHighlight.x = 352;
                  _miraHighlight.y = 118;
                  break;
               case 51:
                  _colorTabHighlight.addChild(param1);
                  break;
               case 52:
                  _eyeTabHighlight.addChild(param1);
                  break;
               case 53:
                  _patternTabHighlight.addChild(param1);
                  break;
               case 54:
                  _avtEditorXBtnHighlight.addChild(param1);
                  _avtEditorXBtnHighlight.mouseEnabled = false;
                  _avtEditorXBtnHighlight.mouseChildren = false;
                  break;
               case 55:
                  _charWindowHighlight.addChild(param1);
                  _charWindowHighlight.mouseEnabled = false;
                  _charWindowHighlight.mouseChildren = false;
                  break;
               case 56:
                  _achievementPopup.addChild(param1);
                  _guiLayer.addChild(_achievementPopup);
                  _achievementPopup.x = 0;
                  _achievementPopup.visible = false;
                  break;
               case 392:
                  _skipBtn.addChild(param1);
                  _guiLayer.addChild(_skipBtn);
                  _skipBtn.x = 810;
                  _skipBtn.y = 420;
                  _skipBtn.visible = true;
                  _skipBtn.addEventListener("mouseDown",skipFFM,false,0,true);
            }
         }
         if(param1 && param1.mediaHelper)
         {
            _loc2_ = 0;
            while(_loc2_ < _mediaHelpers.length)
            {
               if(param1.mediaHelper == _mediaHelpers[_loc2_])
               {
                  _mediaHelpers.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
      }
      
      private function endSet() : void
      {
         nextSet();
      }
      
      private function nextSet() : void
      {
         if(!_delayTimer)
         {
            if(!_timerTriggered)
            {
               processCurrentSet();
               if(_sets)
               {
                  _sets.splice(0,1);
                  _setNumber++;
               }
            }
            else
            {
               _timerTriggered = false;
            }
            processCurrentSet();
         }
         else
         {
            processCurrentSet();
            if(_sets)
            {
               _sets.splice(0,1);
               _setNumber++;
               _delayTimer.start();
            }
         }
      }
      
      private function processCommand(param1:Object) : void
      {
         if(param1)
         {
            switch(param1.cmd)
            {
               case "preload":
                  processPreload(param1);
                  break;
               case "playStream":
                  processStream(param1);
                  break;
               case "playSound":
                  processSound(param1);
                  break;
               case "shaman":
                  processShaman(param1);
                  break;
               case "avatarPlayAnim":
                  processAvatarPlayAnim(param1);
                  break;
               case "delay":
                  processDelay(param1);
                  break;
               case "popup":
                  processPopup(param1);
                  break;
               case "arrow":
                  processArrow(param1);
                  break;
               case "functionCall":
                  processFunctionCall(param1);
                  break;
               case "visibility":
                  processVisibility(param1);
                  break;
               case "advanceOnEvent":
                  processAdvanceOnEvent(param1);
                  break;
               case "roomSpawn":
                  processRoomSpawn(param1);
                  break;
               case "shamanOut":
                  processShamanOut(param1);
            }
         }
      }
      
      private function processPreload(param1:Object) : void
      {
         var _loc2_:MediaHelper = null;
         if(!_currSetProcessed && !_isSkipping)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(param1.src,mediaHelperCallback,true);
            _mediaHelpers.push(_loc2_);
         }
      }
      
      private function processStream(param1:Object) : void
      {
         var _loc2_:URLRequest = null;
         if(!_currSetProcessed && !_isSkipping)
         {
            if(param1.repeatAfter != null && param1.repeatAfter > 0)
            {
               _currSoundTimer = new Timer(param1.repeatAfter * 1000);
            }
            else
            {
               _currSoundTimer = new Timer(10 * 1000);
            }
            if(!isHelpBubble)
            {
               _currSoundTimer.addEventListener("timer",currSoundTimerCompleteHandler,false,0,true);
            }
            _currSound = new Sound();
            _loc2_ = LoaderCache.fetchCDNURLRequest("/streams/" + param1.src + ".mp3");
            _currSound.load(_loc2_);
            if(param1.repeatStream != null && param1.repeatStream == true)
            {
               _repeatStream = true;
            }
            addEventListener("enterFrame",enterFrameHandler,false,0,true);
            if(param1.shamanTalk != null && param1.shamanTalk == true)
            {
               _shamanShouldTalk = true;
            }
            if(param1.volume != null && param1.volume > 0)
            {
               _currSoundTransform = new SoundTransform();
               _currSoundTransform.volume = param1.volume;
            }
            else
            {
               _currSoundTransform = null;
            }
            if(param1.advances)
            {
               _currSoundAdvances = param1.advances;
            }
            else
            {
               _currSoundAdvances = false;
            }
            if(param1.mustFinish != null && param1.mustFinish == true)
            {
               _currSoundMustFinishBeforeAdvancing = true;
            }
            else
            {
               _currSoundMustFinishBeforeAdvancing = false;
            }
            if(param1.off)
            {
               _currSoundMcOff = param1.off;
               _currSoundMcOff.visible = false;
            }
            if(param1.on)
            {
               _currSoundMcOn = param1.on;
               _currSoundMcOn.visible = true;
            }
         }
         else
         {
            if(_currSoundChannel)
            {
               _currSoundChannel.stop();
               if(_shamanShouldTalk)
               {
                  avatarPlayAnim({
                     "userName":"Liza",
                     "anim":"idle",
                     "hFlip":true
                  });
               }
               _shamanShouldTalk = false;
               if(_shamanShouldTalk)
               {
                  _shamanShouldTalk = false;
               }
               _currSoundChannel = null;
            }
            if(_soundTimer)
            {
               _soundTimer.removeEventListener("timer",soundCompleteHandler,false);
               if(_shamanShouldTalk)
               {
                  avatarPlayAnim({
                     "userName":"Liza",
                     "anim":"idle",
                     "hFlip":true
                  });
               }
               _shamanShouldTalk = false;
               if(_shamanShouldTalk)
               {
                  _shamanShouldTalk = false;
               }
            }
            if(_currSound)
            {
               _currSound = null;
            }
            if(_currSoundTimer && _currSoundTimer.running)
            {
               _currSoundTimer.stop();
            }
            if(_currSoundMcOff)
            {
               _currSoundMcOff.visible = true;
            }
            if(_currSoundMcOn)
            {
               _currSoundMcOn.visible = false;
            }
         }
      }
      
      private function processSound(param1:Object) : void
      {
         if(!_currSetProcessed && !_isSkipping)
         {
            switch(param1.src)
            {
               case "subMenuClick":
                  AJAudio.playSubMenuBtnClick();
                  break;
               case "gemsEarned":
                  AJAudio.playGemsEarnedSound();
            }
         }
      }
      
      private function enterFrameHandler(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(_currSound != null)
         {
            _loc2_ = _currSound.bytesLoaded / _currSound.bytesTotal;
            if(_loc2_ == 1)
            {
               if(!_repeatStream)
               {
                  _currSoundChannel = _currSound.play();
                  _soundTimer = new Timer(_currSound.length + 300);
                  _soundTimer.start();
                  _soundTimer.addEventListener("timer",soundCompleteHandler,false,0,true);
                  if(_currSoundTransform && _currSoundChannel)
                  {
                     _currSoundChannel.soundTransform = _currSoundTransform;
                  }
                  if(_shamanShouldTalk)
                  {
                     avatarPlayAnim({
                        "userName":"Liza",
                        "anim":"sleep",
                        "hFlip":true
                     });
                  }
               }
               else
               {
                  _helpBubble.soundBtn.addEventListener("mouseDown",onSoundBtn,false,0,true);
               }
               removeEventListener("enterFrame",enterFrameHandler);
            }
         }
      }
      
      private function processShaman(param1:Object) : void
      {
         if(!_currSetProcessed && !_isSkipping)
         {
            _avtMC.idle();
            _avtMC.parent.name = _avtMC.getSortHeight();
            _worldLayer.addChild(_avtMC.parent);
            _avtMC.x = param1.x;
            _avtMC.y = param1.y;
            _avtMC.scaleX *= -1;
         }
      }
      
      private function processAvatarPlayAnim(param1:Object) : void
      {
         if(!_currSetProcessed && !_isSkipping)
         {
            avatarPlayAnim(param1);
         }
      }
      
      private function avatarPlayAnim(param1:Object) : void
      {
         if(param1.anim == "sleep")
         {
            _avtMC.talking();
         }
         else if(param1.anim == "idle")
         {
            _avtMC.idle();
         }
      }
      
      private function idForAnim(param1:String) : int
      {
         switch(param1)
         {
            case "sleep":
               return 22;
            case "dance":
               return 23;
            case "idle":
               return 14;
            case "play":
               return 6;
            case "hop":
               return 17;
            default:
               return 14;
         }
      }
      
      private function processDelay(param1:Object) : void
      {
         if(!_currSetProcessed && !_isSkipping)
         {
            if(_delayTimer)
            {
               _delayTimer = null;
            }
            _delayTimer = new Timer(param1.sec * 1000);
            _delayTimer.addEventListener("timer",delayCompleteHandler,false,0,true);
            if(param1.type && param1.type == "standAlone")
            {
               _standAloneDelay = true;
               _timerTriggered = false;
               _delayTimer.start();
            }
            else
            {
               _standAloneDelay = false;
            }
         }
      }
      
      private function processPopup(param1:Object) : void
      {
         var _loc3_:ChatBalloon = null;
         var _loc2_:GuiHelpTextBubble = null;
         if(param1.type == "helpBubble")
         {
            _loc2_ = _helpBubble;
         }
         else if(param1.type == "chat")
         {
            _loc3_ = _chatPopup;
         }
         else
         {
            _loc3_ = _popup;
         }
         _loc3_.addEventListener("mouseDown",onSrcDown,false,0,true);
         if(!_currSetProcessed && !_isSkipping)
         {
            trackUserFFMStateChange(_trackingNames[0]);
            _trackingNames.splice(0,1);
            if(param1.btn != null && GuiManager[param1.btn] == false || param1.btn == "ffmDenCustomizeBtn" && DenEditor.staticEditor.bottomHud.visible == false)
            {
               _currSetProcessed = true;
               nextSet();
               return;
            }
            if(_loc2_)
            {
               if(param1.world && param1.world == true)
               {
                  _worldLayer.addChild(_helpBubble);
               }
               else
               {
                  _guiLayer.addChild(_helpBubble);
               }
               _loc2_.bringToFront();
               _loc2_.setText(param1.txt);
               _loc2_.setPos(param1.x,param1.y);
               _loc2_.visible = true;
               _helpBubble.setTails(param1.top,param1.left,param1.twoTails);
            }
            else
            {
               _loc3_.setText(param1.txt);
               _loc3_.x = param1.x;
               _loc3_.y = param1.y;
               _loc3_.visible = true;
            }
            if(param1.delay != null && param1.delay == true)
            {
               _delayPopupVisibility = true;
            }
         }
         else if(!_delayPopupVisibility)
         {
            if(_loc2_)
            {
               _loc2_.visible = false;
            }
            else
            {
               _loc3_.visible = false;
            }
            _loc3_.removeEventListener("mouseDown",onSrcDown);
         }
      }
      
      private function processVisibility(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.type && (param1.type == "mediaId" || param1.type == "mediaIdAnimated"))
         {
            _loc2_ = getMCForMediaId(param1.src);
         }
         else
         {
            _loc2_ = param1.src;
         }
         if(param1.src != 46)
         {
            _loc2_.addEventListener("mouseDown",onSrcDown,false,0,true);
         }
         if(!_currSetProcessed && !_isSkipping)
         {
            _loc2_.visible = param1.visibility;
            if(param1.goHere != null && param1.goHere == true)
            {
               if(_loc2_.numChildren > 1)
               {
                  MovieClip(_loc2_.getChildAt(0)).arrow.gotoAndPlay(1);
                  MovieClip(_loc2_.getChildAt(0)).circle.gotoAndPlay(1);
               }
            }
            if(param1.type && param1.type == "mediaIdAnimated")
            {
               MovieClip(_loc2_.getChildAt(0)).turnOn();
            }
            if(param1.layer)
            {
               if(param1.layer == "gui")
               {
                  _guiLayer.addChild(_loc2_);
               }
               else
               {
                  _worldLayer.addChild(_loc2_);
               }
            }
            if(param1.x)
            {
               _loc2_.x = param1.x;
            }
            if(param1.y)
            {
               _loc2_.y = param1.y;
            }
         }
         else if(param1.revert != null && param1.revert == true || _isSkipping)
         {
            if(param1.goHere != null && param1.goHere == true)
            {
               if(_loc2_ && _loc2_.numChildren > 0)
               {
                  MovieClip(_loc2_.getChildAt(0)).arrow.gotoAndStop(1);
                  MovieClip(_loc2_.getChildAt(0)).circle.gotoAndStop(1);
               }
            }
            if(param1.type && param1.type == "mediaIdAnimated")
            {
               if(_loc2_ && _loc2_.numChildren > 0)
               {
                  MovieClip(_loc2_.getChildAt(0)).turnOff();
               }
            }
            else if(param1.type && param1.type == "mediaId")
            {
               getMCForMediaId(param1.src).visible = !param1.visibility;
            }
            else
            {
               param1.src.visible = !param1.visibility;
            }
            if(param1.layer && _loc2_ && _loc2_.parent)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
            if(param1.src != 46 && _loc2_)
            {
               _loc2_.removeEventListener("mouseDown",onSrcDown);
            }
         }
      }
      
      private function processFunctionCall(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(!_currSetProcessed && !_isSkipping)
         {
            _loc2_ = getFunctionForFunctionId(param1.src);
            if(param1.param != null)
            {
               _loc2_(param1.param);
            }
            else
            {
               _loc2_();
            }
         }
      }
      
      private function processAdvanceOnEvent(param1:Object) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.type == "mediaId")
         {
            _loc2_ = getMCForMediaId(param1.src);
         }
         else if(param1.type == "mc")
         {
            _loc2_ = param1.src;
         }
         else if(param1.type == "den")
         {
            _loc2_ = DenEditor.staticEditor[param1.src];
         }
         if(param1.modifyOnClick != null)
         {
            _modifiedObject = param1.modifyOnClick;
         }
         if(param1.nextToGo != null)
         {
            _nextControl = param1.nextToGo;
         }
         if(!_currSetProcessed && !_isSkipping)
         {
            if(param1.type == "volume")
            {
               _advanceOnWalkIn = true;
            }
            else if(_loc2_)
            {
               _loc2_.addEventListener(param1.event,advanceOnClickHandler,false,0,true);
            }
         }
         else
         {
            if(_modifiedObject != null)
            {
               _modifiedObject = null;
            }
            if(_nextControl != null)
            {
               _nextControl = null;
            }
            if(param1.type == "volume")
            {
               _advanceOnWalkIn = true;
               _advanceOnEventTriggered = false;
            }
            else
            {
               _advanceOnEventTriggered = false;
               if(_loc2_)
               {
                  _loc2_.removeEventListener(param1.event,advanceOnClickHandler);
               }
            }
         }
      }
      
      private function processArrow(param1:Object) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:MovieClip = null;
         switch(param1.dir)
         {
            case "up":
               _loc3_ = _uArrow;
               break;
            case "down":
               _loc3_ = _dArrow;
               break;
            case "left":
               _loc3_ = _lArrow;
               break;
            case "right":
               _loc3_ = _rArrow;
               break;
            default:
               throw new Error("Arrow type not recognized - type: " + param1.type);
         }
         if(!_currSetProcessed && !_isSkipping)
         {
            if(param1.visibility == true)
            {
               if(param1.layer != null && param1.layer == "world")
               {
                  _worldLayer.addChild(_loc3_);
               }
               else
               {
                  _guiLayer.addChild(_loc3_);
               }
               _loc3_.visible = true;
               if(param1.src != null)
               {
                  if(param1.type != null && param1.type == "mediaId")
                  {
                     _loc2_ = getMCForMediaId(param1.src);
                  }
                  else
                  {
                     _loc2_ = param1.src;
                  }
               }
               if(param1.x != null)
               {
                  if(_loc2_ != null)
                  {
                     _loc3_.x = _loc2_.x + param1.x;
                  }
                  else
                  {
                     _loc3_.x = param1.x;
                  }
               }
               else if(_loc2_ != null)
               {
                  _loc3_.x = _loc2_.x;
               }
               if(param1.y != null)
               {
                  if(_loc2_ != null)
                  {
                     _loc3_.y = _loc2_.y + param1.y;
                  }
                  else
                  {
                     _loc3_.y = param1.y;
                  }
               }
               else if(_loc2_ != null)
               {
                  _loc3_.y = _loc2_.y;
               }
            }
            else
            {
               _loc3_.visible = false;
            }
         }
         else if(param1.revert != null && param1.revert == true || _isSkipping)
         {
            if(_loc3_ && _loc3_.parent)
            {
               _loc3_.parent.removeChild(_loc3_);
            }
            _loc3_.visible = false;
         }
      }
      
      private function processRoomSpawn(param1:Object) : void
      {
         if(!_currSetProcessed && !_isSkipping && !_shardRequestSent)
         {
            _shardRequestSent = true;
            _roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(param1.room + _roomMgr.shardId);
            _currSetProcessed = true;
            endSet();
         }
         else if(_isSkipping && !_shardRequestSent)
         {
            _shardRequestSent = true;
            _currSetProcessed = true;
            _roomMgr.setGotoSpawnPoint("ff1");
            RoomXtCommManager.sendNonDenRoomJoinRequest(param1.room + _roomMgr.shardId);
         }
      }
      
      private function processShamanOut(param1:Object) : void
      {
      }
      
      public function getSets() : Array
      {
         return _sets;
      }
      
      private function onSoundBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currSoundChannel)
         {
            _currSoundChannel.stop();
            _currSoundChannel = _currSound.play();
         }
         else
         {
            _currSoundChannel = _currSound.play();
         }
      }
      
      private function onSrcDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function getMCForMediaId(param1:int) : MovieClip
      {
         switch(param1)
         {
            case 45:
               return _miraHighlight;
            case 46:
               return _goToCircle;
            case 51:
               return _colorTabHighlight;
            case 52:
               return _eyeTabHighlight;
            case 53:
               return _patternTabHighlight;
            case 0:
               return _avatarEditor.xBtn;
            case 1:
               return MovieClip(_avatarEditor.block);
            case 54:
               return _avtEditorXBtnHighlight;
            case 55:
               return _charWindowHighlight;
            case 56:
               return _achievementPopup;
            default:
               return null;
         }
      }
      
      private function getFunctionForFunctionId(param1:int) : Function
      {
         switch(param1 - 2)
         {
            case 0:
            case 1:
            case 2:
               return _avatarEditor.openTab;
            default:
               return null;
         }
      }
      
      private function onBtnClick(param1:MouseEvent) : void
      {
         endSet();
      }
      
      private function soundCompleteHandler(param1:Event) : void
      {
         _currSoundMustFinishBeforeAdvancing = false;
         if(_soundTimer && _soundTimer.running)
         {
            _soundTimer.stop();
         }
         if(_shamanShouldTalk)
         {
            avatarPlayAnim({
               "userName":"Liza",
               "anim":"idle",
               "hFlip":true
            });
         }
         if(_currSoundAdvances || _advanceOnEventTriggered)
         {
            endSet();
         }
         else
         {
            if(_currSoundMcOff)
            {
               _currSoundMcOff.visible = true;
               _currSoundMcOff = null;
            }
            if(_currSoundMcOn)
            {
               _currSoundMcOn.visible = false;
               _currSoundMcOn = null;
            }
            _currSoundTimer.start();
         }
      }
      
      private function delayCompleteHandler(param1:TimerEvent) : void
      {
         if(_delayPopupVisibility || _isSkipping)
         {
            if(_helpBubble)
            {
               _helpBubble.visible = false;
            }
            else
            {
               _popup.visible = false;
            }
            _delayPopupVisibility = false;
         }
         if(_delayTimer)
         {
            _delayTimer.stop();
            _delayTimer.removeEventListener("timer",delayCompleteHandler);
            _delayTimer = null;
         }
         if(!_standAloneDelay)
         {
            _timerTriggered = true;
         }
         else
         {
            _standAloneDelay = false;
         }
         if(!_isSkipping)
         {
            nextSet();
         }
      }
      
      private function currSoundTimerCompleteHandler(param1:TimerEvent) : void
      {
         _currSoundTimer.stop();
         if(_shamanShouldTalk)
         {
            avatarPlayAnim({
               "userName":"Liza",
               "anim":"sleep",
               "hFlip":true
            });
         }
         if(_currSoundChannel != null)
         {
            _currSoundChannel = _currSound.play();
         }
         _soundTimer.start();
         _soundTimer.addEventListener("timer",soundCompleteHandler,false,0,true);
      }
      
      private function advanceOnClickHandler(param1:MouseEvent) : void
      {
         if(!_currSoundMustFinishBeforeAdvancing)
         {
            nextSet();
         }
         else
         {
            _advanceOnEventTriggered = true;
            _delayPopupVisibility = false;
         }
      }
      
      private function advanceOnWalkIn(param1:String) : void
      {
         if(_advanceOnWalkIn)
         {
            _roomMgr.callback_TriggerWalkIn = null;
            if(!_currSoundMustFinishBeforeAdvancing)
            {
               endSet();
            }
            else
            {
               _advanceOnEventTriggered = true;
               _delayPopupVisibility = false;
            }
            _goToCircle.visible = false;
         }
      }
   }
}

