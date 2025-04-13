package game.fallingPhantoms
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import collection.IitemCollection;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class FallingPhantoms extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MAX_PLAYERS:int = 6;
      
      private static const STATE_LOADING_ASSETS:int = 0;
      
      private static const STATE_LOADING_ITEMLISTS:int = 1;
      
      private static const STATE_WAITING_FOR_START:int = 2;
      
      private static const STATE_RACE_INTRO:int = 3;
      
      private static const STATE_WAITING_FOR_INTRO_COMPLETE:int = 4;
      
      public static const STATE_RACING:int = 5;
      
      public static const STATE_AWAITING_RESULTS:int = 6;
      
      private static const STATE_RACE_RESULTS:int = 7;
      
      private static const ACCESSORY_LIST_LAND:int = 49;
      
      private static const GEM_TIME:int = 5;
      
      public var _proMode:int;
      
      public var _gameState:int = 0;
      
      private var _displayAchievementTimer:Number;
      
      public var _myId:uint;
      
      public var _pIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _availableItems:Array;
      
      public var _availableItemColors:Array;
      
      public var _layerBackgroundGround:Sprite;
      
      public var _layerMidGUI:Sprite;
      
      public var _layerLaneTextures:Sprite;
      
      public var _layerHurdles:Sprite;
      
      public var _layerPlayerMarker:Sprite;
      
      public var _layerPlayerMarkers:Array;
      
      public var _layerPlayer:Sprite;
      
      public var _layerPlayers:Array;
      
      public var _layerAIPlayers:Array;
      
      public var _phantoms:Array = [];
      
      public var _phantomPool:Array = [];
      
      private var _lastTime:Number;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _gameRandomizer:RandomSeed;
      
      public var _raceRandomizer:RandomSeed;
      
      private var _numPlayers:uint;
      
      private var _currentGameTime:Number;
      
      private var _newPlayersJoined:Boolean = false;
      
      private var _invincible:Boolean = false;
      
      private var _aiplayers:Array;
      
      private var _players:Array;
      
      public var _myPlayer:FallingPhantomsPlayer;
      
      public var _aiProfileHard:FallingPhantomsAIProfile = new FallingPhantomsAIProfile(2);
      
      public var _aiProfileMed:FallingPhantomsAIProfile = new FallingPhantomsAIProfile(1);
      
      public var _aiProfileEasy:FallingPhantomsAIProfile = new FallingPhantomsAIProfile(0);
      
      public var _aiProfiles:Array = [_aiProfileHard];
      
      private var _jumpButtonDown:Boolean;
      
      private var _newGameButton:MovieClip;
      
      private var _tutorialEnabled:Boolean;
      
      public var _startingLineX:int;
      
      public var _waitingPopup:MovieClip;
      
      public var _countdownTimer:Number;
      
      public var _lastEmoteTimer:Number;
      
      public var _raceResultsTimer:Number;
      
      public var _trackLength:int;
      
      public var _debugText:TextField;
      
      public var _leftArrow:Boolean;
      
      public var _rightArrow:Boolean;
      
      public var _largePhantomProbabilityWeight:Number = -100;
      
      public var _minAngle:Number = 0;
      
      public var _maxAngle:Number = 45;
      
      public var _minScale:Number = 1;
      
      public var _maxScale:Number = 5;
      
      public var _minFallTime:Number = 2;
      
      public var _maxFallTime:Number = 3.5;
      
      private var _bonusGems:int;
      
      private var _gemTimer:Number;
      
      private var _gem:MovieClip;
      
      private var _tempGem:MovieClip;
      
      private var _fpKeepAliveTimer:Number;
      
      public var _showBBs:Boolean = false;
      
      private var _resultsPopup:MovieClip;
      
      public var _factsOrder:Array;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _factImageMediaObject:MovieClip;
      
      private var _surfaceSoundDefault:int;
      
      private var _surfaceSoundSplash:int;
      
      public var _soundMan:SoundManager;
      
      public var _SFX_Music:SBMusic;
      
      public var _SFX_StartMusic:SBMusic;
      
      public var _SFX_EndMusic:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public var _jumpSounds:Array;
      
      public var _whineSounds:Array;
      
      private var _numFallingSounds:int;
      
      public var _gemPayouts:Array = [40,30,20,10,5,3];
      
      private var _audio:Array = ["aj_fp_deathLar1.mp3","aj_fp_deathLar2.mp3","aj_fp_deathLar3.mp3","aj_fp_deathLar4.mp3","aj_fp_deathSm1.mp3","aj_fp_deathSm2.mp3","aj_fp_deathSm3.mp3","aj_fp_deathSm4.mp3","aj_fp_fallLar1.mp3","aj_fp_fallLar2.mp3","aj_fp_fallLar3.mp3","aj_fp_fallLar4.mp3","aj_fp_fallSm1.mp3","aj_fp_fallSm2.mp3","aj_fp_fallSm3.mp3","aj_fp_fallSm4.mp3","aj_fp_popUpGameOver.mp3","aj_fp_stingerDeath.mp3","aj_PopUp_Go.mp3","aj_PopUp_ReadySet.mp3","play_timer_tick.mp3","play_timer_tickRed.mp3","play_time_up.mp3","aj_playerJoinsGame.mp3","aj_fp_eruption.mp3","aj_fp_flameLarge1.mp3","aj_fp_flameLarge2.mp3","aj_fp_flameSmall1.mp3","aj_fp_flameSmall2.mp3","aj_gem_new.mp3"];
      
      internal var _soundNameFPDeathLar1:String = _audio[0];
      
      internal var _soundNameFPDeathLar2:String = _audio[1];
      
      internal var _soundNameFPDeathLar3:String = _audio[2];
      
      internal var _soundNameFPDeathLar4:String = _audio[3];
      
      internal var _soundNameFPDeathSm1:String = _audio[4];
      
      internal var _soundNameFPDeathSm2:String = _audio[5];
      
      internal var _soundNameFPDeathSm3:String = _audio[6];
      
      internal var _soundNameFPDeathSm4:String = _audio[7];
      
      internal var _soundNameFPFallLar1:String = _audio[8];
      
      internal var _soundNameFPFallLar2:String = _audio[9];
      
      internal var _soundNameFPFallLar3:String = _audio[10];
      
      internal var _soundNameFPFallLar4:String = _audio[11];
      
      internal var _soundNameFPFallSm1:String = _audio[12];
      
      internal var _soundNameFPFallSm2:String = _audio[13];
      
      internal var _soundNameFPFallSm3:String = _audio[14];
      
      internal var _soundNameFPFallSm4:String = _audio[15];
      
      internal var _soundNameFPPopUpGameOver:String = _audio[16];
      
      internal var _soundNameFPStingerDeath:String = _audio[17];
      
      internal var _soundNameFPPopUpGo:String = _audio[18];
      
      internal var _soundNameFPPopUpReadySet:String = _audio[19];
      
      internal var _soundNamePlayTimerTick:String = _audio[20];
      
      internal var _soundNamePlayTimerTickRed:String = _audio[21];
      
      internal var _soundNamePlayTimeUp:String = _audio[22];
      
      internal var _soundNamePlayerJoinsGame:String = _audio[23];
      
      internal var _soundNameFPEruption:String = _audio[24];
      
      internal var _soundNameFPFallLar5:String = _audio[25];
      
      internal var _soundNameFPFallLar6:String = _audio[26];
      
      internal var _soundNameFPFallSm5:String = _audio[27];
      
      internal var _soundNameFPFallSm6:String = _audio[28];
      
      internal var _soundNameGemNew:String = _audio[29];
      
      public function FallingPhantoms()
      {
         super();
         _displayAchievementTimer = 0;
      }
      
      private function loadSounds() : void
      {
         var _loc1_:int = 0;
         _SFX_Music = _soundMan.addStream("aj_fallingPhantoms",0.6);
         _loc1_ = 1;
         while(_loc1_ < 5)
         {
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPDeathLar" + _loc1_]],this["_soundNameFPDeathLar" + _loc1_],0.7);
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPDeathSm" + _loc1_]],this["_soundNameFPDeathSm" + _loc1_],1.3);
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPFallLar" + _loc1_]],this["_soundNameFPFallLar" + _loc1_],0.38);
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPFallSm" + _loc1_]],this["_soundNameFPFallSm" + _loc1_],0.17);
            _loc1_++;
         }
         _loc1_ = 5;
         while(_loc1_ < 7)
         {
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPFallLar" + _loc1_]],this["_soundNameFPFallLar" + _loc1_],0.38);
            _soundMan.addSoundByName(_audioByName[this["_soundNameFPFallSm" + _loc1_]],this["_soundNameFPFallSm" + _loc1_],0.26);
            _loc1_++;
         }
         _soundMan.addSoundByName(_audioByName[_soundNameFPPopUpGameOver],_soundNameFPPopUpGameOver,1.25);
         _soundMan.addSoundByName(_audioByName[_soundNameFPStingerDeath],_soundNameFPStingerDeath,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameFPPopUpGo],_soundNameFPPopUpGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameFPPopUpReadySet],_soundNameFPPopUpReadySet,0.27);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayTimerTick],_soundNamePlayTimerTick,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayTimerTickRed],_soundNamePlayTimerTickRed,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayTimeUp],_soundNamePlayTimeUp,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerJoinsGame],_soundNamePlayerJoinsGame,0.37);
         _soundMan.addSoundByName(_audioByName[_soundNameFPEruption],_soundNameFPEruption,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGemNew],_soundNameGemNew,0.3);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         _myId = param1;
         _pIDs = param2;
         _numPlayers = param2.length;
         init();
      }
      
      public function startNewGame() : void
      {
         killGame();
         var _loc1_:Array = [];
         _loc1_[0] = "sng";
         MinigameManager.msg(_loc1_);
         MinigameManager.setPrimaryRoomNameBypass();
      }
      
      public function end(param1:Array) : void
      {
         killGame();
         MinigameManager.leave();
      }
      
      public function killGame() : void
      {
         var _loc1_:int = 0;
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         while(_players.length > 0)
         {
            if(_players[0] != null)
            {
               _players[0].cleanup();
            }
            _players.splice(0,1);
         }
         while(_aiplayers.length > 0)
         {
            if(_aiplayers[0] != null)
            {
               _aiplayers[0].cleanup();
            }
            _aiplayers.splice(0,1);
         }
         while(_phantoms.length > 0)
         {
            if(_phantoms[0].parent)
            {
               _phantoms[0].parent.removeChild(_phantoms[0]);
               _phantoms.splice(0,1);
            }
         }
         while(_phantomPool.length > 0)
         {
            if(_phantomPool[0].parent)
            {
               _phantomPool[0].parent.removeChild(_phantomPool[0]);
               _phantomPool.splice(0,1);
            }
         }
         releaseBase();
         _bInit = false;
         _loc1_ = 0;
         while(_loc1_ < _availableItems.length)
         {
            if(_availableItems[_loc1_])
            {
               _availableItems[_loc1_].destroy();
               _availableItems[_loc1_] = null;
            }
            _loc1_++;
         }
         removeLayer(_layerMidGUI);
         removeLayer(_layerBackgroundGround);
         removeLayer(_layerLaneTextures);
         removeLayer(_layerHurdles);
         removeLayer(_layerPlayer);
         removeLayer(_layerPlayerMarker);
         removeLayer(_guiLayer);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("mouseDown",showTutorial);
      }
      
      private function showTutorial(param1:MouseEvent) : void
      {
         if(_tutorialEnabled && _gameState == 5 && !_pauseGame && !_closeBtn.hitTestPoint(mouseX,mouseY,true) && _newGameButton == null)
         {
            Object(_scene.getLayer("bg").loader).content.tutorialOn();
         }
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         var _loc5_:Number = param1.length - 1;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc2_ = Math.round(Math.random() * _loc5_);
            _loc3_ = param1[_loc4_];
            param1[_loc4_] = param1[_loc2_];
            param1[_loc2_] = _loc3_;
            _loc4_++;
         }
         return param1;
      }
      
      private function init() : void
      {
         var _loc1_:int = 0;
         _jumpButtonDown = false;
         _lastEmoteTimer = 0;
         _displayAchievementTimer = 0;
         _factsIndex = 0;
         _surfaceSoundDefault = 0;
         _surfaceSoundSplash = 0;
         if(!_bInit)
         {
            _factImageMediaObject = null;
            _mediaObjectHelper = null;
            _loadingImage = false;
            _resultsPopup = null;
            _layerMidGUI = new Sprite();
            _layerBackgroundGround = new Sprite();
            _layerLaneTextures = new Sprite();
            _layerHurdles = new Sprite();
            _layerPlayer = new Sprite();
            _layerPlayerMarker = new Sprite();
            _layerPlayerMarkers = new Array(6);
            _layerPlayers = new Array(6);
            _layerAIPlayers = new Array(6);
            _loc1_ = 0;
            while(_loc1_ < 6)
            {
               _layerPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerPlayers[_loc1_]);
               _layerAIPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerAIPlayers[_loc1_]);
               _loc1_++;
            }
            if(_numPlayers <= 0 || _numPlayers > 6)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            _layerMidGUI.mouseEnabled = true;
            _layerBackgroundGround.mouseEnabled = false;
            _layerHurdles.mouseEnabled = false;
            _layerLaneTextures.mouseEnabled = false;
            _layerPlayer.mouseEnabled = false;
            _layerPlayerMarker.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBackgroundGround);
            addChild(_layerLaneTextures);
            addChild(_layerPlayerMarker);
            addChild(_layerHurdles);
            addChild(_layerMidGUI);
            addChild(_layerPlayer);
            addChild(_guiLayer);
            _aiplayers = new Array(6);
            _players = new Array(6);
            loadScene("FallingPhantoms/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _tempGem = GETDEFINITIONBYNAME("fallingPhantoms_gem");
         _guiLayer.addChild(_tempGem);
         _guiLayer.addChild(Object(_scene.getLayer("bg").loader).content.foreground1);
         _guiLayer.addChild(Object(_scene.getLayer("bg").loader).content.foreground2);
         _guiLayer.addChild(Object(_scene.getLayer("bg").loader).content.tutorial);
         _guiLayer.addChild(Object(_scene.getLayer("bg").loader).content.timer);
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _layerBackgroundGround.addChild(_scene.getLayer("bg").loader);
         _sceneLoaded = true;
         _tutorialEnabled = true;
         _currentGameTime = 0;
         _bonusGems = 0;
         _gemTimer = 0;
         _gem = null;
         _tempGem.visible = false;
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseDown",showTutorial);
         _waitingPopup = GETDEFINITIONBYNAME("fallingPhantoms_waiting");
         _waitingPopup.x = 450;
         _waitingPopup.y = 275;
         _waitingPopup.gotoAndPlay("waiting");
         _guiLayer.addChild(_waitingPopup);
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc9_:* = 0;
         var _loc23_:int = 0;
         var _loc26_:int = 0;
         var _loc24_:int = 0;
         var _loc3_:int = 0;
         var _loc40_:int = 0;
         var _loc29_:Object = null;
         var _loc20_:int = 0;
         var _loc2_:* = 0;
         var _loc7_:* = false;
         var _loc38_:Number = NaN;
         var _loc6_:int = 0;
         var _loc15_:DisplayObject = null;
         var _loc35_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc5_:int = 0;
         var _loc12_:SoundChannel = null;
         var _loc19_:int = 0;
         var _loc36_:int = 0;
         var _loc39_:int = 0;
         var _loc8_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc10_:int = 0;
         var _loc30_:int = 0;
         var _loc37_:String = null;
         var _loc28_:String = null;
         var _loc32_:int = 0;
         var _loc18_:int = 0;
         var _loc21_:int = 0;
         var _loc27_:int = 0;
         var _loc33_:String = null;
         if(param1[0] == "ml")
         {
            _loc26_ = int(param1[2]);
            if(param1[3] == null || param1[3] == "-1")
            {
               if(_players[_loc26_])
               {
                  _players[_loc26_]._finishPlace = param1[4];
                  if(_players[_loc26_]._finishPlace > 0)
                  {
                     _players[_loc26_]._gemMultiplier = getGemMultiplier();
                     _players[_loc26_].remove(param1[5] == "1");
                     if(param1[5] == "1")
                     {
                        _players[_loc26_]._dropped = true;
                     }
                  }
                  else
                  {
                     _players[_loc26_].remove(true);
                     _players[_loc26_] = null;
                     _numPlayers--;
                  }
                  if(_players[_loc26_] == _myPlayer)
                  {
                     Object(_scene.getLayer("shadow").loader).visible = false;
                     addNewGameButton();
                     addGemsToBalance(_gemPayouts[_myPlayer._finishPlace - 1] * getGemMultiplier() + _bonusGems);
                     LocalizationManager.translateIdAndInsert(Object(_scene.getLayer("bg").loader).content.placing.place.gemsEarned,11441,_gemPayouts[_myPlayer._finishPlace - 1] * getGemMultiplier() + _bonusGems);
                  }
               }
            }
            else if(_aiplayers && _aiplayers[param1[3]]._avatar != null && !_aiplayers[param1[3]]._dead)
            {
               _aiplayers[param1[3]].remove();
               _aiplayers[param1[3]]._finishPlace = param1[4];
               _aiplayers[param1[3]]._gemMultiplier = getGemMultiplier();
            }
         }
         else if(param1[0] == "ms")
         {
            _loc23_ = 1;
            _loc20_ = 0;
            _proMode = parseInt(param1[_loc23_++]);
            _loc2_ = parseInt(param1[_loc23_++]);
            _startingLineX = parseInt(param1[_loc23_++]);
            _gameRandomizer = new RandomSeed(_loc2_);
            _loc20_ = 0;
            while(_loc20_ < _numPlayers)
            {
               _loc7_ = param1[_loc23_++] == _myId;
               _loc26_ = int(param1[_loc23_++]);
               _players[_loc26_] = new FallingPhantomsPlayer(this);
               _players[_loc26_].setupHumanPlayer(_loc26_,_loc7_,param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++]);
               if(_loc7_)
               {
                  _myPlayer = _players[_loc26_];
               }
               _newPlayersJoined = true;
               _loc20_++;
            }
            _loc38_ = Number(param1[_loc23_++]);
            _loc6_ = int(param1[_loc23_++]);
            _loc20_ = 0;
            while(_loc20_ < _loc6_)
            {
               _aiplayers[_loc20_] = new FallingPhantomsPlayer(this);
               _aiplayers[_loc20_].setupAIPlayer(_gameRandomizer.integer(9999999),_loc20_,_startingLineX,param1[_loc23_++]);
               _loc20_++;
            }
         }
         else if(param1[0] == "mm")
         {
            _loc23_ = 3;
            if(param1[2] == "ex")
            {
               hideDlg();
               _loc15_ = showDlg("fallingPhantoms_error",[{
                  "name":"exitButton",
                  "f":onErrorExit
               }]);
               _loc15_.x = 450;
               _loc15_.y = 275;
            }
            else if(param1[2] == "fp")
            {
               _loc23_ = 0;
               while(_loc23_ < param1[3])
               {
                  _loc29_ = getPhantom();
                  _loc35_ = _gameRandomizer.random() * 900;
                  _loc34_ = 620 * Math.tan((_gameRandomizer.random() * (_maxAngle - _minAngle) + _minAngle) * 3.141592653589793 / 180);
                  _loc25_ = (_largePhantomProbabilityWeight + param1[4] / 666) / 100;
                  _loc22_ = _maxScale;
                  _loc11_ = _minScale;
                  if(_loc25_ < 0)
                  {
                     _loc25_ += 1;
                     _loc22_ = _loc25_ * (_maxScale - _minScale) + _minScale;
                  }
                  else
                  {
                     _loc11_ = _loc25_ * (_maxScale - _minScale) + _minScale;
                  }
                  _loc4_ = _gameRandomizer.random() * (_loc22_ - _loc11_) + _loc11_;
                  _loc31_ = (_maxScale == _minScale ? 1 : (_loc4_ - _minScale) / (_maxScale - _minScale)) * (_maxFallTime - _minFallTime) + _minFallTime;
                  if(_loc35_ - _loc34_ < 30)
                  {
                     _loc34_ = _loc35_ + _loc34_;
                  }
                  else if(_loc35_ + _loc34_ > 870)
                  {
                     _loc34_ = _loc35_ - _loc34_;
                  }
                  else
                  {
                     _loc34_ = _loc35_ + _loc34_ * (_gameRandomizer.random() < 0.5 ? 1 : -1);
                  }
                  _loc34_ = Math.min(Math.max(_loc34_,30),870);
                  _loc17_ = Math.atan2(_loc34_ - _loc35_,620) * 180 / 3.141592653589793;
                  if(Math.abs(_loc17_) > _maxAngle * 0.666666)
                  {
                     _loc5_ = 0;
                  }
                  else if(Math.abs(_loc17_) > _maxAngle * 0.333333)
                  {
                     _loc5_ = 1;
                  }
                  else
                  {
                     _loc5_ = 2;
                  }
                  _loc29_.phantom.gotoAndPlay("phantom" + (_loc4_ > 2.5 ? "1" : "0") + "_" + _loc5_);
                  _loc29_.fire.rotation = -_loc17_;
                  if(_numFallingSounds < 3)
                  {
                     _numFallingSounds++;
                     if(_loc4_ > 2.5)
                     {
                        _loc12_ = _soundMan.playByName(this["_soundNameFPFallLar" + (Math.floor(Math.random() * 6) + 1)]);
                        if(_loc12_)
                        {
                           _loc12_.addEventListener("soundComplete",soundComplete);
                        }
                     }
                     else
                     {
                        _loc12_ = _soundMan.playByName(this["_soundNameFPFallSm" + (Math.floor(Math.random() * 6) + 1)]);
                        if(_loc12_)
                        {
                           _loc12_.addEventListener("soundComplete",soundComplete);
                        }
                     }
                  }
                  if(_loc29_.rectangle == null)
                  {
                     _loc29_.rectangle = new Shape();
                  }
                  _loc29_.rectangle.x = _loc34_;
                  _loc29_.rectangle.y = 520;
                  _loc29_.rectangle.graphics.clear();
                  _loc29_.rectangle.graphics.beginFill(16711680);
                  _loc29_.rectangle.graphics.drawRect(-_loc29_.collision.width * 0.5 * _loc4_,-_loc29_.collision.height * 0.5 * _loc4_,_loc29_.collision.width * _loc4_,_loc29_.collision.height * _loc4_);
                  _loc29_.rectangle.graphics.endFill();
                  _guiLayer.addChild(_loc29_.rectangle);
                  _loc29_.rectangle.visible = _showBBs;
                  _loc29_.rectangle.alpha = 0.4;
                  _loc29_.scaleX = _loc29_.scaleY = _loc4_;
                  if(_loc17_ < 0)
                  {
                     _loc29_.phantom.scaleX = -Math.abs(_loc29_.phantom.scaleX);
                  }
                  else
                  {
                     _loc29_.phantom.scaleX = Math.abs(_loc29_.phantom.scaleX);
                  }
                  _loc29_.velX = (_loc34_ - _loc35_) / _loc31_;
                  _loc29_.velY = 620 / _loc31_;
                  _loc29_.x = _loc35_;
                  _loc29_.y = -100;
                  _loc29_.rotRate = 400 / _loc4_ * (_gameRandomizer.random() < 0.5 ? 1 : -1);
                  _layerPlayer.addChild(_loc29_ as DisplayObject);
                  _phantoms.push(_loc29_);
                  _loc23_++;
               }
            }
            else if(param1[2] == "uj")
            {
               _numPlayers = param1[_loc23_++];
               _loc19_ = 0;
               while(_loc19_ < _numPlayers)
               {
                  _loc26_ = int(param1[_loc23_++]);
                  _loc36_ = int(param1[_loc23_++]);
                  _loc39_ = int(param1[_loc23_++]);
                  _loc8_ = int(param1[_loc23_++]);
                  _loc13_ = int(param1[_loc23_++]);
                  _loc14_ = int(param1[_loc23_++]);
                  _loc10_ = int(param1[_loc23_++]);
                  _loc30_ = int(param1[_loc23_++]);
                  _loc37_ = param1[_loc23_++];
                  _loc28_ = param1[_loc23_++];
                  _loc32_ = int(param1[_loc23_++]);
                  if(_players[_loc26_] == null)
                  {
                     _players[_loc26_] = new FallingPhantomsPlayer(this);
                     _players[_loc26_].setupHumanPlayer(_loc26_,false,_loc36_,_loc39_,_loc8_,_loc13_,_loc14_,_loc10_,_loc30_,_loc37_,_loc28_,_loc32_);
                     _newPlayersJoined = true;
                  }
                  _loc19_++;
               }
               if(_soundMan)
               {
                  _soundMan.playByName(_soundNamePlayerJoinsGame);
               }
            }
            else if(param1[2] == "pos")
            {
               _loc9_ = uint(int(param1[_loc23_++]));
               if(_loc9_ < 6 && _players[_loc9_] != null && _players[_loc9_]._avatar)
               {
                  _players[_loc9_].receivePositionData(int(param1[_loc23_++]),int(param1[_loc23_++]));
               }
            }
            else if(param1[2] == "cs")
            {
               _soundMan.playByName(_soundNameFPPopUpReadySet);
               _waitingPopup.gotoAndPlay("ready");
               _countdownTimer = 1.5;
            }
            else if(param1[2] == "em")
            {
               if(_myPlayer != null && param1[4] != _myPlayer._playerID)
               {
                  _loc24_ = 0;
                  while(_loc24_ < _players.length)
                  {
                     if(_players[_loc24_] != null && _players[_loc24_]._playerID == param1[4])
                     {
                        _players[_loc24_].showEmote(param1[3]);
                        break;
                     }
                     _loc24_++;
                  }
               }
            }
            else if(param1[2] == "ri")
            {
               _loc18_ = int(param1[_loc23_++]);
               _loc3_ = int(param1[_loc23_++]);
               _raceRandomizer = new RandomSeed(_loc18_);
               _loc24_ = 0;
               while(_loc24_ < _aiplayers.length)
               {
                  _aiplayers[_loc24_].setAIRandomizer(_raceRandomizer.integer(9999999));
                  _loc24_++;
               }
               _loc21_ = 2;
               _loc24_ = 0;
               while(_loc24_ < _loc3_)
               {
                  _loc40_ = int(param1[_loc23_++]);
                  if(_players[_loc40_] != null)
                  {
                     if(_gameState == 7)
                     {
                        _players[_loc40_].prepareForStart(_startingLineX);
                     }
                  }
                  _loc24_++;
               }
               _loc24_ = 0;
               while(_loc24_ < _aiplayers.length)
               {
                  if(_players[_loc24_] == null)
                  {
                     _aiplayers[_loc24_].prepareForStart(_startingLineX);
                  }
                  _loc24_++;
               }
               setGameState(3);
            }
            else if(param1[2] == "rs")
            {
               if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  AchievementXtCommManager.requestSetUserVar(344,1);
               }
               setGameState(5);
            }
            else if(param1[2] == "rr")
            {
               _raceResultsTimer = param1[_loc23_++];
               _loc3_ = int(param1[_loc23_++]);
               _loc24_ = 0;
               while(_loc24_ < 6)
               {
                  _loc27_ = int(param1[_loc23_++]);
                  if(param1[_loc23_] == "1*")
                  {
                     _aiplayers[_loc27_]._finishPlace = 1;
                     _aiplayers[_loc27_]._receiveBonus = true;
                     _aiplayers[_loc27_]._gemMultiplier = getGemMultiplier();
                     _loc23_++;
                  }
                  else
                  {
                     _aiplayers[_loc27_]._finishPlace = param1[_loc23_++];
                  }
                  if(_aiplayers[_loc27_]._finishPlace < 1 || _aiplayers[_loc27_]._finishPlace > 6)
                  {
                     _aiplayers[_loc27_]._finishPlace = 6 + 1;
                  }
                  _loc24_++;
               }
               _loc24_ = 0;
               while(_loc24_ < _loc3_)
               {
                  _loc9_ = uint(int(param1[_loc23_++]));
                  _loc33_ = param1[_loc23_++];
                  if(_loc9_ < 6 && _players[_loc9_] != null)
                  {
                     if(_loc33_ == "1*")
                     {
                        _players[_loc9_]._finishPlace = 1;
                        _players[_loc9_]._receiveBonus = true;
                        _players[_loc9_]._gemMultiplier = getGemMultiplier();
                        if(_players[_loc9_] == _myPlayer)
                        {
                           addGemsToBalance(_gemPayouts[_myPlayer._finishPlace - 1] * getGemMultiplier() + _bonusGems + 50);
                        }
                     }
                     else
                     {
                        _players[_loc9_]._finishPlace = _loc33_;
                     }
                     if(_players[_loc9_]._finishPlace < 1 || _players[_loc9_]._finishPlace > 6)
                     {
                        _players[_loc9_]._finishPlace = 6 + 1;
                     }
                  }
                  _loc24_++;
               }
               _countdownTimer = 1;
               Object(_scene.getLayer("bg").loader).content.endRound();
               setGameState(6);
            }
         }
      }
      
      private function getGemMultiplier() : int
      {
         if(_currentGameTime < 15)
         {
            return 1;
         }
         if(_currentGameTime < 30)
         {
            return 2;
         }
         if(_currentGameTime < 45)
         {
            return 3;
         }
         return 4;
      }
      
      private function soundComplete(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",soundComplete);
         _numFallingSounds--;
      }
      
      private function addNewGameButton(param1:Boolean = true) : void
      {
         _newGameButton = addBtn("fallingPhantoms_newGame",0,0,startNewGame);
         _newGameButton.mouseChildren = false;
         if(param1)
         {
            Object(_scene.getLayer("bg").loader).content.place(_myPlayer._finishPlace);
         }
         Object(_scene.getLayer("bg").loader).content.newGameButton.newGameButtonContainer.addChild(_newGameButton);
         Object(_scene.getLayer("bg").loader).content.newGameButton.gotoAndPlay("on");
         _newGameButton = Object(_scene.getLayer("bg").loader).content.newGameButton;
         _guiLayer.addChild(_newGameButton);
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:FallingPhantomsPlayer = null;
         var _loc2_:Array = null;
         var _loc7_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc4_:Boolean = false;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _loc7_ = false;
            if(_loc7_)
            {
               _loc2_ = [];
               _loc2_[0] = "reset";
               MinigameManager.msg(_loc2_);
            }
            if(_lastEmoteTimer > 0)
            {
               _lastEmoteTimer -= _frameTime;
            }
            if(_newPlayersJoined)
            {
               _loc3_ = 0;
               while(_loc3_ < _players.length)
               {
                  if(_players[_loc3_] != null && _players[_loc3_]._avatar == null)
                  {
                     if(_players[_loc3_] == _myPlayer)
                     {
                        _layerPlayers[_loc3_].addChild(_scene.getLayer("shadow").loader);
                     }
                     _players[_loc3_].init(_layerPlayers[_loc3_]);
                     if(_gameState != 7)
                     {
                        _players[_loc3_].prepareForStart(_startingLineX);
                     }
                  }
                  _loc3_++;
               }
               _loc3_ = 0;
               while(_loc3_ < 6)
               {
                  if(_aiplayers[_loc3_]._avatar == null)
                  {
                     _aiplayers[_loc3_].init(_layerAIPlayers[_loc3_]);
                  }
                  _loc3_++;
               }
               _newPlayersJoined = false;
            }
            if(_myPlayer && _myPlayer._avatar)
            {
               Object(_scene.getLayer("shadow").loader).x = _myPlayer._avatar.x - _myPlayer.getCollisionOffsetX();
               Object(_scene.getLayer("shadow").loader).y = _myPlayer._avatar.y - 5;
            }
            loop11:
            switch(_gameState)
            {
               case 0:
                  if(_myPlayer != null && _myPlayer._animsLoaded)
                  {
                     setGameState(1);
                  }
                  break;
               case 1:
                  if(_availableItems != null)
                  {
                     setGameState(2);
                  }
                  break;
               case 2:
               case 3:
                  _loc6_ = true;
                  _loc3_ = 0;
                  while(_loc3_ < _players.length)
                  {
                     if(_players[_loc3_] != null && _players[_loc3_]._avatar != null)
                     {
                        _loc9_ = _players[_loc3_];
                        if(!_loc9_.heartbeatIntro(_frameTime))
                        {
                           _loc6_ = false;
                        }
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < 6)
                  {
                     if(!_aiplayers[_loc3_].heartbeatIntro(_frameTime))
                     {
                        _loc6_ = false;
                     }
                     _loc3_++;
                  }
                  if(_gameState == 3 && _loc6_)
                  {
                     setGameState(4);
                  }
                  break;
               case 4:
                  if(_countdownTimer > 0)
                  {
                     _countdownTimer -= _frameTime;
                     if(_countdownTimer <= 0)
                     {
                        _soundMan.playByName(_soundNameFPPopUpReadySet);
                        _waitingPopup.gotoAndPlay("set");
                     }
                  }
                  break;
               case 5:
                  _fpKeepAliveTimer -= _frameTime;
                  if(_fpKeepAliveTimer <= 0)
                  {
                     _loc2_ = [];
                     _loc2_[0] = "fpka";
                     MinigameManager.msg(_loc2_);
                     _fpKeepAliveTimer = 5;
                  }
                  if(_currentGameTime < 60)
                  {
                     if(Object(_scene.getLayer("bg").loader).content.eruption.eruption.burpSound)
                     {
                        _soundMan.playByName(_soundNameFPEruption);
                        Object(_scene.getLayer("bg").loader).content.eruption.eruption.burpSound = false;
                     }
                     if(Math.floor(_currentGameTime) < Math.floor(_currentGameTime + _frameTime))
                     {
                        if(_currentGameTime < 43)
                        {
                           _soundMan.playByName(_soundNamePlayTimerTick);
                        }
                        else
                        {
                           _soundMan.playByName(_soundNamePlayTimerTickRed);
                        }
                     }
                     _currentGameTime += _frameTime;
                     if(_currentGameTime >= 60)
                     {
                        _soundMan.playByName(_soundNamePlayTimeUp);
                     }
                  }
                  if(_currentGameTime >= 60)
                  {
                     _currentGameTime = 60;
                     if(_phantoms.length == 0)
                     {
                        _loc2_ = [];
                        _loc2_[0] = "sc";
                        MinigameManager.msg(_loc2_);
                        setGameState(6);
                     }
                  }
                  if(_currentGameTime > 25)
                  {
                     _gemTimer -= _frameTime;
                     if(_gem == null)
                     {
                        if(_gemTimer < 0)
                        {
                           if(!_myPlayer._dead && _myPlayer._avatar)
                           {
                              if(_myPlayer._avatar)
                              {
                                 _gem = _tempGem;
                                 if(_myPlayer._avatar.x > 450)
                                 {
                                    _gem.x = 50;
                                 }
                                 else
                                 {
                                    _gem.x = 850;
                                 }
                                 _gem.y = 490;
                                 _gem.newGem();
                                 _gem.visible = true;
                              }
                           }
                        }
                     }
                     else if(!_myPlayer._dead && _myPlayer._avatar)
                     {
                        if(Math.abs(_myPlayer._avatar.x - _gem.x) < 20)
                        {
                           _gem.collect();
                           _bonusGems += 25;
                           _gem = null;
                           _gemTimer = 5;
                           _soundMan.playByName(_soundNameGemNew);
                        }
                     }
                  }
                  Object(_scene.getLayer("bg").loader).content.time(_currentGameTime,60);
                  _loc3_ = 0;
                  while(_loc3_ < _phantoms.length)
                  {
                     _phantoms[_loc3_].x += _phantoms[_loc3_].velX * _frameTime;
                     _phantoms[_loc3_].y += _phantoms[_loc3_].velY * _frameTime;
                     if(_phantoms[_loc3_].y > 520)
                     {
                        if(_phantoms.scaleX > 2.5)
                        {
                           _soundMan.playByName(this["_soundNameFPDeathLar" + (Math.floor(Math.random() * 4) + 1)]);
                        }
                        else
                        {
                           _soundMan.playByName(this["_soundNameFPDeathSm" + (Math.floor(Math.random() * 4) + 1)]);
                        }
                        _phantoms[_loc3_].y = 520;
                        _phantoms[_loc3_].gotoAndPlay("damage3");
                        _phantoms[_loc3_].phantom.alpha = 0;
                        _phantoms[_loc3_].fire.alpha = 0;
                        _phantoms[_loc3_].rectangle.parent.removeChild(_phantoms[_loc3_].rectangle);
                        _phantomPool.push(_phantoms[_loc3_]);
                        _phantoms.splice(_loc3_--,1);
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _players.length)
                  {
                     if(_players[_loc3_] != null && _players[_loc3_]._avatar != null && !_players[_loc3_]._dead)
                     {
                        _loc9_ = _players[_loc3_];
                        _loc9_.heartbeat(_frameTime);
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _aiplayers.length)
                  {
                     if(_aiplayers[_loc3_]._playerLayer.visible && _aiplayers[_loc3_]._avatar != null && !_aiplayers[_loc3_]._dead)
                     {
                        _aiplayers[_loc3_].heartbeat(_frameTime);
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _phantoms.length)
                  {
                     _loc4_ = false;
                     _loc5_ = -1;
                     while(_loc5_ < _aiplayers.length)
                     {
                        if(_loc5_ == -1 && _myPlayer._avatar && !_myPlayer._dead && !_invincible && boxCollisionTest(_phantoms[_loc3_].collision,_myPlayer._avatar.rectangle) || _loc5_ >= 0 && _aiplayers[_loc5_]._playerLayer.visible && _aiplayers[_loc5_]._avatar && !_aiplayers[_loc5_]._dead && boxCollisionTest(_phantoms[_loc3_].collision,_aiplayers[_loc5_]._avatar.rectangle))
                        {
                           _loc4_ = true;
                           _loc2_ = [];
                           _loc2_[0] = "gh";
                           _loc2_[1] = _loc5_.toString();
                           MinigameManager.msg(_loc2_);
                           if(_loc5_ == -1)
                           {
                              _myPlayer.remove();
                           }
                           else
                           {
                              _aiplayers[_loc5_]._gemMultiplier = getGemMultiplier();
                              _aiplayers[_loc5_].remove();
                           }
                        }
                        _loc5_++;
                     }
                     _loc3_++;
                  }
                  break;
               case 6:
                  _loc3_ = 0;
                  while(_loc3_ < _players.length)
                  {
                     if(_players[_loc3_] != null && _players[_loc3_]._avatar != null && !_players[_loc3_]._dead)
                     {
                        _loc9_ = _players[_loc3_];
                        _loc9_.heartbeat(_frameTime);
                     }
                     _loc3_++;
                  }
                  if(_countdownTimer > 0)
                  {
                     _countdownTimer -= _frameTime;
                     if(_countdownTimer <= 0)
                     {
                        setGameState(7);
                     }
                  }
                  while(true)
                  {
                     if(!_phantoms.length)
                     {
                        break loop11;
                     }
                     _phantoms[0].phantom.alpha = 0;
                     _phantoms[0].fire.alpha = 0;
                     _phantomPool.push(_phantoms[0]);
                     _phantoms.splice(0,1);
                  }
            }
            _gameTime += _frameTime;
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
         }
      }
      
      public function boxCollisionTest(param1:Object, param2:Object) : Boolean
      {
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc15_:Number = param1.x + param1.parent.x;
         var _loc11_:Number = param1.y + param1.parent.y;
         var _loc13_:Number = param1.width * 0.5 * param1.parent.scaleX;
         var _loc18_:Number = param1.height * 0.5 * param1.parent.scaleY;
         var _loc12_:Number = Number(param2.x);
         var _loc14_:Number = Number(param2.y);
         var _loc6_:Number = param2.width * 0.5;
         var _loc5_:Number = param2.height * 0.5;
         _loc9_ = _loc15_ - _loc13_;
         _loc7_ = _loc12_ - _loc6_;
         _loc16_ = _loc15_ + _loc13_;
         _loc17_ = _loc12_ + _loc6_;
         _loc8_ = _loc11_ - _loc18_;
         _loc10_ = _loc14_ - _loc5_;
         _loc4_ = _loc11_ + _loc18_;
         _loc3_ = _loc14_ + _loc5_;
         if(_loc4_ < _loc10_)
         {
            return false;
         }
         if(_loc8_ > _loc3_)
         {
            return false;
         }
         if(_loc16_ < _loc7_)
         {
            return false;
         }
         if(_loc9_ > _loc17_)
         {
            return false;
         }
         return true;
      }
      
      public function resetGame() : void
      {
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         hideDlg();
         _countdownTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      private function playerLeftGame(param1:int) : void
      {
         _players[param1].remove();
         _players[param1] = null;
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onErrorExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function getPhantom() : Object
      {
         var _loc1_:Object = null;
         if(_phantomPool.length < 3)
         {
            return GETDEFINITIONBYNAME("fallingPhantoms_phantom");
         }
         _loc1_ = _phantomPool[0];
         _loc1_.phantom.alpha = 1;
         _loc1_.fire.alpha = 1;
         _phantomPool.splice(0,1);
         return _loc1_;
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               if(_leftArrow)
               {
                  _leftArrow = false;
                  messageMoveState();
               }
               break;
            case 2:
               if(_rightArrow)
               {
                  _rightArrow = false;
                  messageMoveState();
                  break;
               }
         }
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         _tutorialEnabled = false;
         var _loc2_:Object = _scene.getLayer("bg").loader;
         if(_sceneLoaded && _loc2_.content.hasOwnProperty("tutorialOff"))
         {
            _loc2_.content.tutorialOff();
         }
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               if(!_leftArrow)
               {
                  _leftArrow = true;
                  messageMoveState();
               }
               break;
            case 2:
               if(!_rightArrow)
               {
                  _rightArrow = true;
                  messageMoveState();
                  break;
               }
         }
      }
      
      private function messageMoveState() : void
      {
         var _loc1_:Array = null;
         if(_gameState == 5 && _myPlayer._avatar && !_myPlayer._dead)
         {
            _loc1_ = [];
            _loc1_[0] = "pos";
            _loc1_[1] = _myPlayer._playerID + 1;
            _loc1_[2] = String(int(_myPlayer._avatar.x));
            if(_leftArrow)
            {
               _loc1_[3] = "0";
            }
            else if(_rightArrow)
            {
               _loc1_[3] = "1";
            }
            else
            {
               _loc1_[3] = "2";
            }
            MinigameManager.msg(_loc1_);
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Item = null;
         _availableItems = new Array(param1.length);
         var _loc4_:int = 100;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc7_ = param1.getIitem(_loc5_) as Item;
            _availableItems[_loc5_] = new Item();
            _availableItems[_loc5_].init(_loc7_.defId,_loc4_++,_loc7_.color);
            _availableItems[_loc5_].makeSmallIcon();
            _loc5_++;
         }
         _availableItemColors = param3;
         _loc6_ = 0;
         while(_loc6_ < 6)
         {
            if(_aiplayers[_loc6_]._avatar != null)
            {
               _aiplayers[_loc6_].initFinalize();
            }
            _loc6_++;
         }
      }
      
      private function removeSurfaceSoundDefault(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeSurfaceSoundDefault);
         _surfaceSoundDefault--;
         if(_surfaceSoundDefault < 0)
         {
            _surfaceSoundDefault = 0;
         }
      }
      
      private function removeSurfaceSoundSplash(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeSurfaceSoundSplash);
         _surfaceSoundSplash--;
         if(_surfaceSoundSplash < 0)
         {
            _surfaceSoundSplash = 0;
         }
      }
      
      private function setGameState(param1:int) : void
      {
         var _loc6_:int = 0;
         var _loc2_:Array = null;
         var _loc5_:Array = null;
         var _loc4_:Object = null;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         if(_gameState != param1)
         {
            loop2:
            switch(param1)
            {
               case 0:
                  break;
               case 1:
                  resetGame();
                  ItemXtCommManager.requestShopList(gotItemListCallback,49);
                  break;
               case 2:
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
                  break;
               case 3:
                  Object(_scene.getLayer("bg").loader).content.intro();
                  _soundMan.playByName(_soundNameFPEruption);
                  if(_gameState == 7)
                  {
                     resetGame();
                     break;
                  }
                  resetGame();
                  break;
               case 4:
                  _loc2_ = [];
                  _loc2_[0] = "intro";
                  MinigameManager.msg(_loc2_);
                  break;
               case 5:
                  _fpKeepAliveTimer = 5;
                  _soundMan.playByName(_soundNameFPPopUpGo);
                  _waitingPopup.gotoAndPlay("goOff");
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _musicLoop = _soundMan.playStream(_SFX_Music,0,99999);
                  break;
               case 7:
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _soundMan.playByName(_soundNameFPPopUpGameOver);
                  if(_newGameButton == null)
                  {
                     addNewGameButton(false);
                  }
                  hideDlg();
                  _resultsPopup = showDlg("fallingPhantoms_results",[],450,275,false);
                  _closeBtn.parent.setChildIndex(_closeBtn,_closeBtn.parent.numChildren - 1);
                  _newGameButton.parent.setChildIndex(_newGameButton,_newGameButton.parent.numChildren - 1);
                  _loc5_ = [];
                  _loc6_ = 0;
                  while(_loc6_ < _players.length)
                  {
                     if(_players[_loc6_] && _players[_loc6_]._playerLayer.visible)
                     {
                        _loc5_.push(_players[_loc6_]);
                        _players[_loc6_].move(0,false,false);
                     }
                     if(_aiplayers[_loc6_] && _aiplayers[_loc6_]._playerLayer.visible)
                     {
                        _loc5_.push(_aiplayers[_loc6_]);
                        _aiplayers[_loc6_].move(0,false,false);
                     }
                     _loc6_++;
                  }
                  _loc5_.sortOn("_finishPlace",[16]);
                  _loc8_ = 1;
                  _loc6_ = 0;
                  while(true)
                  {
                     if(_loc6_ >= 6)
                     {
                        break loop2;
                     }
                     _loc4_ = _resultsPopup["playerTag" + (_loc6_ + 1)];
                     if(_loc6_ < _loc5_.length)
                     {
                        _loc8_ = int(_loc5_[_loc6_]._finishPlace);
                        if(_loc8_ < 1 && _loc8_ > 6)
                        {
                           _loc8_ = 6;
                        }
                        if(_loc5_[_loc6_] == _myPlayer)
                        {
                           _displayAchievementTimer = 3;
                           _loc4_.setInfo(1,_loc8_,_myPlayer._receiveBonus,_bonusGems);
                           if(_loc8_ == 1)
                           {
                              AchievementXtCommManager.requestSetUserVar(346,gMainFrame.userInfo.userVarCache.getUserVarValueById(346) + 1);
                              AchievementXtCommManager.requestSetUserVar(345,1);
                           }
                           else
                           {
                              AchievementXtCommManager.requestSetUserVar(346,0);
                           }
                        }
                        else
                        {
                           _loc4_.setInfo(0,_loc5_[_loc6_]._finishPlace,_loc5_[_loc6_]._receiveBonus,0);
                        }
                        LocalizationManager.updateToFit(_loc4_.playerName,LocalizationManager.translateAvatarName(_loc5_[_loc6_]._name));
                        LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11097,0);
                        _loc3_ = _gemPayouts[_loc8_ - 1] * _loc5_[_loc6_]._gemMultiplier + (!!_loc5_[_loc6_]._receiveBonus ? 50 : 0);
                        switch(_loc8_ - 1)
                        {
                           case 0:
                              LocalizationManager.translateId(_loc4_.place,11434);
                              break;
                           case 1:
                              LocalizationManager.translateId(_loc4_.place,11435);
                              break;
                           case 2:
                              LocalizationManager.translateId(_loc4_.place,11436);
                              break;
                           case 3:
                              LocalizationManager.translateId(_loc4_.place,11437);
                              break;
                           case 4:
                              LocalizationManager.translateId(_loc4_.place,11438);
                              break;
                           case 5:
                              LocalizationManager.translateId(_loc4_.place,11439);
                        }
                        LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11097,!!_loc5_[_loc6_]._dropped ? 0 : _gemPayouts[_loc8_ - 1] * _loc5_[_loc6_]._gemMultiplier);
                        if(_loc5_[_loc6_] == _myPlayer)
                        {
                           if(_myPlayer._receiveBonus)
                           {
                              AchievementXtCommManager.requestSetUserVar(347,1);
                              MinigameManager.msg(["_a",35]);
                           }
                        }
                        _loc4_.setTagWidth();
                        _loc4_.visible = true;
                     }
                     else
                     {
                        _loc4_.visible = false;
                     }
                     _loc6_++;
                  }
            }
            _gameState = param1;
         }
      }
   }
}

