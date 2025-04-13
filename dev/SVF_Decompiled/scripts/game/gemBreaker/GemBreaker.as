package game.gemBreaker
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class GemBreaker extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_READY_TO_START:int = 1;
      
      public static const GAMESTATE_READY_DISPLAYED:int = 2;
      
      public static const GAMESTATE_LEVEL_DISPLAYED:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_TUTORIAL_DISPLAYED:int = 5;
      
      public static const GAMESTATE_WAITING_DISPLAYED:int = 6;
      
      public static const GAMESTATE_LEVEL_SELECT_DISPLAYED:int = 7;
      
      public static const GAMESTATE_ENDED:int = 10;
      
      public static const LEVEL_SELECT_MEDIUM:int = 4;
      
      public static const LEVEL_SELECT_HARD:int = 9;
      
      public var _levelSelectPopup:Object;
      
      public var _startLevelSelected:int = -1;
      
      public var _levelSelectPopupTimer:Number;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _currentPopup:MovieClip;
      
      public var _displayAchievementTimer:Number = 0;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerPlayers:Sprite;
      
      public var _layerBackground:Sprite;
      
      public var _layerGems:Sprite;
      
      public var _readyLevelDisplayTimer:Number;
      
      public var _readyLevelDisplay:Object;
      
      public var _totalPlayers:int;
      
      public var _gameState:int;
      
      public var _players:Array;
      
      public var _levelIndex:int;
      
      public var _queueGameOver:Boolean;
      
      public var _otherPlayerReady:Boolean;
      
      public var _playerLeft:Boolean;
      
      public var _newRoundSeed:int;
      
      public var _numPlayersOverride:int;
      
      public var _waitingForOtherPlayerDisplay:Object;
      
      public var _soundMan:SoundManager;
      
      public var _rightArrowDown:Boolean;
      
      public var _leftArrowDown:Boolean;
      
      private var _audio:Array = ["gb_combo.mp3","gb_fire_gem.mp3","gb_gem_break1.mp3","gb_gem_collision1.mp3","gb_launcher_rotate.mp3","gb_player_fail.mp3","gb_player_win.mp3","gb_points_awarded.mp3","gb_row_grow.mp3","gb_wall_collision.mp3","gb_player_send_rows_.mp3","GS_Level_next_level.mp3","hud_select.mp3","hud_roll_over.mp3"];
      
      internal var _soundNameCombo:String = _audio[0];
      
      internal var _soundNameShoot:String = _audio[1];
      
      internal var _soundNameGemBreak:String = _audio[2];
      
      internal var _soundNameCollision1:String = _audio[3];
      
      internal var _soundNameLauncherRotate:String = _audio[4];
      
      internal var _soundNameFail:String = _audio[5];
      
      internal var _soundNameSuccess:String = _audio[6];
      
      internal var _soundNameGetPoints:String = _audio[7];
      
      internal var _soundNameRowGrow:String = _audio[8];
      
      internal var _soundNameWallCollision:String = _audio[9];
      
      internal var _soundNameSendRows:String = _audio[10];
      
      internal var _soundNameNextLevel:String = _audio[11];
      
      internal var _soundNameHudSelect:String = _audio[12];
      
      internal var _soundNameHudRollover:String = _audio[13];
      
      public var _SFX_Music:SBMusic;
      
      private var _SFX_Music_Instance:SoundChannel;
      
      public function GemBreaker()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_mus_gem_breaker",1);
         _soundMan.addSoundByName(_audioByName[_soundNameCombo],_soundNameCombo,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameShoot],_soundNameShoot,1);
         _soundMan.addSoundByName(_audioByName[_soundNameGemBreak],_soundNameGemBreak,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCollision1],_soundNameCollision1,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameLauncherRotate],_soundNameLauncherRotate,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFail],_soundNameFail,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSuccess],_soundNameSuccess,0.17);
         _soundMan.addSoundByName(_audioByName[_soundNameGetPoints],_soundNameGetPoints,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRowGrow],_soundNameRowGrow,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameWallCollision],_soundNameWallCollision,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSendRows],_soundNameSendRows,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameNextLevel],_soundNameNextLevel,0.32);
         _soundMan.addSoundByName(_audioByName[_soundNameHudSelect],_soundNameHudSelect,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameHudRollover],_soundNameHudRollover,0.6);
      }
      
      private function unloadSounds() : void
      {
         _SFX_Music = null;
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         releaseBase();
         stage.removeEventListener("keyDown",tutorialKeyDown);
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("keyDown",resultsNextKeyDown);
         stage.removeEventListener("keyDown",nextRoundKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("click",mouseClickHandler);
         stage.removeEventListener("keyDown",gameKeydownHandler);
         stage.removeEventListener("keyUp",gameKeyUpHandler);
         resetGame();
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerGems);
         removeLayer(_layerPlayers);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerGems = null;
         _layerPlayers = null;
         _guiLayer = null;
         unloadSounds();
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            setGameState(0);
            _otherPlayerReady = false;
            _numPlayersOverride = -1;
            _layerBackground = new Sprite();
            _layerGems = new Sprite();
            _layerPlayers = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerGems);
            addChild(_layerPlayers);
            addChild(_guiLayer);
            _layerGems.y = -8;
            _playerLeft = false;
            loadScene("GemBreakerAssets/room_main.xroom",_audio);
            _bInit = true;
         }
         else if(_sceneLoaded && MainFrame.isInitialized())
         {
            setGameState(7);
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         if(_numPlayersOverride > 0)
         {
            _totalPlayers = _numPlayersOverride;
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,999999);
         _levelSelectPopupTimer = 0;
         _levelSelectPopup = _scene.getLayer("levelSelect");
         _levelSelectPopup.loader.x = 0;
         _levelSelectPopup.loader.y = 0;
         _guiLayer.addChild(_levelSelectPopup.loader);
         if(_pIDs && _pIDs.length > 1)
         {
            _startLevelSelected = -1;
            _levelSelectPopup.loader.content.buttonsOff();
            _levelSelectPopupTimer = 2;
         }
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("click",mouseClickHandler);
         stage.addEventListener("keyDown",gameKeydownHandler);
         stage.addEventListener("keyUp",gameKeyUpHandler);
         stage.focus = this;
         stage.stageFocusRect = false;
         _loc4_ = _scene.getLayer("background");
         _layerBackground.addChild(_loc4_.loader);
         if(_totalPlayers == 1)
         {
            _loc4_.loader.content.single();
         }
         else
         {
            _loc4_.loader.content.multi();
            _loc4_.loader.content.showTime(0,1);
         }
         super.sceneLoaded(param1);
         if(MainFrame.isInitialized())
         {
            setGameState(7);
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_gameState != param1)
         {
            if(_readyLevelDisplay && _readyLevelDisplay.loader.parent)
            {
               _readyLevelDisplay.loader.parent.removeChild(_readyLevelDisplay.loader);
               _readyLevelDisplay = null;
            }
            if(_waitingForOtherPlayerDisplay && _waitingForOtherPlayerDisplay.loader.parent)
            {
               _waitingForOtherPlayerDisplay.loader.content.gotoAndPlay("off");
               _waitingForOtherPlayerDisplay.loader.visible = false;
            }
            _loc3_ = _gameState;
            _gameState = param1;
            switch(param1)
            {
               case 0:
                  break;
               case 1:
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
                  if(_totalPlayers == 2)
                  {
                     showWaitingForOtherPlayer();
                  }
                  break;
               case 2:
                  _readyLevelDisplay = _scene.getLayer("winLose");
                  _guiLayer.addChild(_readyLevelDisplay.loader);
                  _currentPopup = _readyLevelDisplay.loader.content;
                  if(_players[0]._localPlayer)
                  {
                     _players[1].forceFinish();
                     break;
                  }
                  _players[0].forceFinish();
                  break;
               case 3:
                  if(_totalPlayers == 1)
                  {
                     _readyLevelDisplayTimer = 3;
                     _readyLevelDisplay = _scene.getLayer("levelPopup");
                     LocalizationManager.translateIdAndInsert(_readyLevelDisplay.loader.content.Text_Level.Level_Text,11548,_levelIndex - (_startLevelSelected + 1) + 1);
                     LocalizationManager.translateIdAndInsert(_readyLevelDisplay.loader.content.Text_Level.Shoot_1,11580,_players[0]._levels[Math.min(_levelIndex,_players[0]._levels.length - 1)][0]);
                     _readyLevelDisplay.loader.content.gotoAndPlay(0);
                  }
                  else
                  {
                     _readyLevelDisplay = _scene.getLayer("readyGo");
                     _readyLevelDisplay.loader.content.turnOn();
                     LocalizationManager.translateIdAndInsert(_readyLevelDisplay.loader.content.Text_Level.Level_Text,11582,(_players[0]._roundsWon + _players[1]._roundsWon + 1).toString());
                     _currentPopup = _readyLevelDisplay.loader.content;
                     if(_players[0]._roundsWon + _players[1]._roundsWon > 0)
                     {
                        _loc4_ = 0;
                        while(_loc4_ < _totalPlayers)
                        {
                           _players[_loc4_].reset(false);
                           _players[_loc4_].buildLevel(_newRoundSeed);
                           _loc4_++;
                        }
                     }
                  }
                  _soundMan.playByName(_soundNameNextLevel);
                  _guiLayer.addChild(_readyLevelDisplay.loader);
                  break;
               case 4:
                  stage.focus = this;
                  stage.stageFocusRect = false;
                  break;
               case 5:
                  showTutorialDlg();
                  break;
               case 6:
                  if(!_otherPlayerReady)
                  {
                     showWaitingForOtherPlayer();
                  }
                  break;
               case 10:
                  if(_totalPlayers == 1)
                  {
                     if(_players)
                     {
                        showGameOverDlg();
                        break;
                     }
                     _queueGameOver = false;
                     setGameState(_loc3_);
                     break;
                  }
                  _queueGameOver = false;
                  if(_players && _players[0] && _players[1])
                  {
                     if(_players[0]._localPlayer)
                     {
                        _players[1].forceFinish();
                     }
                     else
                     {
                        _players[0].forceFinish();
                     }
                  }
                  if(_players && (_players[0]._localPlayer && _players[1]._roundsWon == 2 || _players[1]._localPlayer && _players[0]._roundsWon == 2 || (_players[0]._localPlayer && _players[0]._lost || _players[1]._localPlayer && _players[1]._lost)))
                  {
                     showLoseGameOverDlg();
                     break;
                  }
                  if(!_sceneLoaded)
                  {
                     _numPlayersOverride = 1;
                     _queueGameOver = false;
                     _gameState = _loc3_;
                     break;
                  }
                  showWinGameOverDlg();
                  break;
            }
         }
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onRetry_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function nextRoundKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               doNextRound();
         }
      }
      
      private function resultsNextKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onResults_Next();
         }
      }
      
      private function gameOverKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onExit_Yes();
         }
      }
      
      private function tutorialKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               hideTut();
         }
      }
      
      public function startNextRound() : void
      {
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(93,_levelIndex - (_startLevelSelected + 1) + 1);
            _displayAchievementTimer = 1;
         }
         var _loc2_:int = Math.floor(_players[0]._score / 5000) * 1 + 5;
         stage.addEventListener("keyDown",nextRoundKeyDown);
         var _loc1_:MovieClip = showDlg("GB_Great_Job",[{
            "name":"button_nextlevel",
            "f":doNextRound
         }]);
         LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_players[0]._score);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,_loc2_ == 1 ? 11433 : 11432,_loc2_);
         addGemsToBalance(_loc2_);
         _players[0]._gemCount += _loc2_;
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Total,11554,_players[0]._gemCount);
         _soundMan.playByName(_soundNameSuccess);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      public function doNextRound() : void
      {
         stage.removeEventListener("keyDown",nextRoundKeyDown);
         hideDlg();
         _levelIndex++;
         setGameState(3);
         _players[0].buildLevel();
      }
      
      public function message(param1:Array) : void
      {
         var _loc7_:* = null;
         var _loc6_:* = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1[0] == "ml")
         {
            _playerLeft = true;
            if(_players)
            {
               _loc6_ = uint(int(param1[2]));
               if(_players[0]._netID == _loc6_)
               {
                  _players[0]._lost = true;
               }
               else
               {
                  _players[1]._lost = true;
               }
            }
            else
            {
               _totalPlayers = 2;
               setGameState(10);
            }
            _queueGameOver = true;
         }
         else if(param1[0] == "ms")
         {
            _dbIDs = [];
            _userNames = [];
            _loc3_ = 1;
            _loc2_ = 0;
            while(_loc2_ < _pIDs.length)
            {
               _dbIDs[_loc2_] = param1[_loc3_++];
               _userNames[_loc2_] = param1[_loc3_++];
               _loc2_++;
            }
            _totalPlayers = _dbIDs.length;
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "start")
            {
               if(!_queueGameOver)
               {
                  startGame(param1);
               }
            }
            else if(param1[2] == "pos")
            {
               _loc6_ = uint(int(param1[3]));
               _loc4_ = 4;
               for each(_loc7_ in _players)
               {
                  if(_loc7_._netID == _loc6_)
                  {
                     _loc4_ = _loc7_.receivePositionData(param1,_loc4_);
                     break;
                  }
               }
            }
            else if(param1[2] == "shoot")
            {
               _loc4_ = 3;
               for each(_loc7_ in _players)
               {
                  if(!_loc7_._localPlayer)
                  {
                     _loc4_ = _loc7_.receiveShootData(param1,_loc4_);
                     break;
                  }
               }
               if(param1[_loc4_] == "1")
               {
                  if(_players[0]._localPlayer)
                  {
                     _players[0]._shotsBeforeShift = 5;
                  }
                  else
                  {
                     _players[1]._shotsBeforeShift = 5;
                  }
               }
            }
            else if(param1[2] == "playerLost")
            {
               _queueGameOver = true;
               if(_players[0]._localPlayer)
               {
                  _players[0]._lost = false;
                  _players[1].playerLost();
               }
               else
               {
                  _players[1]._lost = false;
                  _players[0].playerLost();
               }
               _newRoundSeed = int(param1[3]);
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
            if(_gameState == 7)
            {
               if(_levelSelectPopup)
               {
                  if(_levelSelectPopup.loader.content.hud_select)
                  {
                     _levelSelectPopup.loader.content.hud_select = false;
                     _soundMan.playByName(_soundNameHudSelect);
                  }
                  if(_levelSelectPopup.loader.content.hud_rollover)
                  {
                     _levelSelectPopup.loader.content.hud_rollover = false;
                     _soundMan.playByName(_soundNameHudRollover);
                  }
                  if(_levelSelectPopupTimer > 0)
                  {
                     _levelSelectPopupTimer -= _frameTime;
                     if(_levelSelectPopupTimer <= 0)
                     {
                        _guiLayer.removeChild(_levelSelectPopup.loader);
                        _levelSelectPopup = null;
                        if(_totalPlayers == 1)
                        {
                           setGameState(1);
                        }
                        else
                        {
                           setGameState(5);
                        }
                     }
                  }
                  else if(_levelSelectPopup.loader.content.introOn == false)
                  {
                     if(_levelSelectPopup.loader.content.difficulty == "medium")
                     {
                        _startLevelSelected = 4;
                     }
                     else if(_levelSelectPopup.loader.content.difficulty == "hard")
                     {
                        _startLevelSelected = 9;
                     }
                     else
                     {
                        _startLevelSelected = -1;
                     }
                     _levelSelectPopupTimer = 0.25;
                  }
               }
            }
            else
            {
               if(_gameState == 5 && _totalPlayers == 2)
               {
                  _readyLevelDisplayTimer -= _frameTime;
                  _currentPopup.timer.text = Math.ceil(_readyLevelDisplayTimer).toString();
                  if(_readyLevelDisplayTimer <= 0)
                  {
                     hideTut();
                  }
               }
               if(!_pauseGame || _players && _players.length > 1)
               {
                  if(_gameState == 2)
                  {
                     if(_currentPopup.finished)
                     {
                        _currentPopup = null;
                        setGameState(3);
                     }
                  }
                  else if(_gameState == 3)
                  {
                     if(_totalPlayers == 1)
                     {
                        _readyLevelDisplayTimer -= _frameTime;
                        if(_readyLevelDisplayTimer <= 0)
                        {
                           setGameState(4);
                        }
                     }
                     else if(_currentPopup.finished)
                     {
                        _currentPopup = null;
                        setGameState(4);
                     }
                  }
                  else if(_gameState == 4)
                  {
                     _gameTime += _frameTime;
                     heartbeatPlayers();
                  }
                  if(_queueGameOver)
                  {
                     setGameState(10);
                  }
               }
            }
         }
      }
      
      private function heartbeatPlayers() : void
      {
         var _loc1_:* = null;
         for each(_loc1_ in _players)
         {
            _loc1_.heartbeat(_frameTime);
         }
      }
      
      public function startGame(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc7_:GemBreakerPlayer = null;
         _players = [];
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _readyLevelDisplayTimer = 0;
         _queueGameOver = false;
         var _loc4_:int = 3;
         var _loc2_:uint = parseInt(param1[_loc4_++]);
         _guiLayer.addChild(_scene.getLayer("combo1").loader);
         _guiLayer.addChild(_scene.getLayer("combo2").loader);
         _scene.getLayer("combo1").loader.content.gotoAndStop(0);
         _scene.getLayer("combo2").loader.content.gotoAndStop(0);
         _levelIndex = _startLevelSelected;
         _players = [];
         _totalPlayers = parseInt(param1[_loc4_++]);
         _loc3_ = 0;
         while(_loc3_ < _totalPlayers)
         {
            _loc7_ = new GemBreakerPlayer(this);
            _loc4_ = _loc7_.init(_userNames[_loc3_],_dbIDs[_loc3_],param1,_loc4_,_scene.getLayer("cannon" + (_loc3_ + 1)),_loc2_);
            _players.push(_loc7_);
            _loc3_++;
         }
         if(_totalPlayers == 2)
         {
            _players[0]._otherPlayer = _players[1];
            _players[1]._otherPlayer = _players[0];
         }
         buildNextLevel();
         if(_totalPlayers == 1)
         {
            setGameState(5);
         }
         else
         {
            setGameState(3);
         }
         if(_SFX_Music_Instance == null)
         {
            _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,99999);
         }
      }
      
      public function buildNextLevel() : void
      {
         var _loc1_:* = null;
         _levelIndex++;
         for each(_loc1_ in _players)
         {
            _loc1_.buildLevel();
         }
      }
      
      public function resetGame() : void
      {
         var _loc2_:* = null;
         for each(_loc2_ in _players)
         {
            _loc2_.remove();
         }
         if(_readyLevelDisplay && _readyLevelDisplay.loader.parent)
         {
            _readyLevelDisplay.loader.parent.removeChild(_readyLevelDisplay.loader);
            _readyLevelDisplay = null;
         }
         if(_waitingForOtherPlayerDisplay && _waitingForOtherPlayerDisplay.loader.parent)
         {
            _waitingForOtherPlayerDisplay.loader.parent.removeChild(_waitingForOtherPlayerDisplay.loader);
            _waitingForOtherPlayerDisplay = null;
         }
      }
      
      private function gameKeydownHandler(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               if(activeDlgMC == null)
               {
                  mouseClickHandler(param1);
               }
               break;
            case 5:
               _leftArrowDown = true;
               break;
            case 7:
               _rightArrowDown = true;
         }
      }
      
      private function gameKeyUpHandler(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = false;
               break;
            case 2:
               _rightArrowDown = false;
         }
      }
      
      private function mouseClickHandler(param1:Event) : void
      {
         var _loc2_:* = null;
         if(!_pauseGame && _gameState == 4)
         {
            for each(_loc2_ in _players)
            {
               if(_loc2_._localPlayer)
               {
                  _loc2_.shoot();
                  break;
               }
            }
         }
      }
      
      private function showWaitingForOtherPlayer() : void
      {
         if(_waitingForOtherPlayerDisplay == null)
         {
            _waitingForOtherPlayerDisplay = _scene.getLayer("popup_waiting");
            _guiLayer.addChild(_waitingForOtherPlayerDisplay.loader);
         }
         _waitingForOtherPlayerDisplay.loader.visible = true;
         _waitingForOtherPlayerDisplay.loader.x = 450 - _waitingForOtherPlayerDisplay.width / 2;
         _waitingForOtherPlayerDisplay.loader.y = 275 - _waitingForOtherPlayerDisplay.height / 2;
         _waitingForOtherPlayerDisplay.loader.content.gotoAndPlay("on");
      }
      
      private function showWaveResultsDlg() : void
      {
         stage.addEventListener("keyDown",resultsNextKeyDown);
         var _loc1_:MovieClip = showDlg("Great_Job",[{
            "name":"button_nextlevel",
            "f":onResults_Next
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function showGameOverDlg() : void
      {
         stage.addEventListener("keyDown",replayKeyDown);
         var _loc1_:MovieClip = showDlg("GB_Game_Over",[{
            "name":"button_yes",
            "f":onRetry_Yes
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_players[0]._totalScore);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11554,_players[0]._gemCount);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _soundMan.playByName(_soundNameFail);
      }
      
      private function showLoseGameOverDlg() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc1_:int = !!_players[0]._localPlayer ? 1 : 0;
         var _loc4_:GemBreakerPlayer = _players[_loc3_];
         if(_players[0]._roundsWon == 2 || _players[1]._roundsWon == 2)
         {
            stage.addEventListener("keyDown",gameOverKeyDown);
            _loc2_ = showDlg("GB_Game_Over_Multiplayer",[{
               "name":"button_exit",
               "f":onExit_Yes
            }]);
            LocalizationManager.translateIdAndInsert(_loc2_.winnerName,11574,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[_loc1_],_dbIDs[_loc1_]).avName);
            LocalizationManager.translateIdAndInsert(_loc2_.Gems_Total,11554,(Math.floor(_loc4_._score / 5000) * 1).toString());
            addGemsToBalance(Math.floor(_loc4_._score / 5000) * 1);
            _loc2_.x = 450;
            _loc2_.y = 275;
         }
         else
         {
            setGameState(2);
            _scene.getLayer("winLose").loader.content.lose();
         }
         _scene.getLayer("background").loader.content.lose();
         _soundMan.playByName(_soundNameFail);
      }
      
      private function showWinGameOverDlg() : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:GemBreakerPlayer = null;
         if(_players)
         {
            _loc3_ = !!_players[0]._localPlayer ? 0 : 1;
            _loc1_ = !!_players[0]._localPlayer ? 1 : 0;
            _loc4_ = _players[_loc3_];
            if(_playerLeft || _players[0]._roundsWon == 2 || _players[1]._roundsWon == 2)
            {
               stage.addEventListener("keyDown",gameOverKeyDown);
               _loc2_ = showDlg("GB_You_Won_Multiplayer",[{
                  "name":"button_exit",
                  "f":onExit_Yes
               }]);
               LocalizationManager.translateIdAndInsert(_loc2_.gemBonus,11584,15);
               LocalizationManager.translateIdAndInsert(_loc2_.Gems_Total,11554,(Math.floor(_loc4_._score / 5000) * 1 + 15).toString());
               addGemsToBalance(Math.floor(_loc4_._score / 5000) * 1 + 15);
               _loc2_.x = 450;
               _loc2_.y = 275;
               if(!_playerLeft && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  AchievementXtCommManager.requestSetUserVar(92,1);
                  _displayAchievementTimer = 1;
               }
            }
            else
            {
               setGameState(2);
               _scene.getLayer("winLose").loader.content.win();
            }
            _scene.getLayer("background").loader.content.win();
         }
         else
         {
            hideDlg();
            stage.addEventListener("keyDown",gameOverKeyDown);
            _loc2_ = showDlg("GB_You_Won_Multiplayer",[{
               "name":"button_exit",
               "f":onExit_Yes
            }]);
            LocalizationManager.translateIdAndInsert(_loc2_.gemBonus,11584,15);
            LocalizationManager.translateIdAndInsert(_loc2_.Gems_Total,11554,15);
            addGemsToBalance(15);
            _loc2_.x = 450;
            _loc2_.y = 275;
         }
         _soundMan.playByName(_soundNameSuccess);
      }
      
      private function showExitConfirmationDlg() : void
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
         if(_levelSelectPopup && _levelSelectPopup.loader.content)
         {
            _levelSelectPopup.loader.content.introPaused = true;
         }
      }
      
      private function showTutorialDlg() : void
      {
         var _loc1_:MovieClip = null;
         stage.focus = this;
         stage.stageFocusRect = false;
         stage.addEventListener("keyDown",tutorialKeyDown);
         if(_totalPlayers == 1)
         {
            _loc1_ = showDlg("gb_howToPlay_1p",[{
               "name":"x_btn",
               "f":hideTut
            },{
               "name":"doneButton",
               "f":hideTut
            }]);
         }
         else
         {
            _readyLevelDisplayTimer = 10;
            _loc1_ = showDlg("gb_howToPlay_2p",[{
               "name":"x_btn",
               "f":hideTut
            },{
               "name":"doneButton",
               "f":hideTut
            }]);
            _currentPopup = _loc1_;
         }
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function hideTut() : void
      {
         stage.removeEventListener("keyDown",tutorialKeyDown);
         hideDlg();
         if(_totalPlayers == 1)
         {
            setGameState(3);
         }
         else
         {
            _currentPopup = null;
            setGameState(1);
         }
      }
      
      private function onResults_Next() : void
      {
         stage.removeEventListener("keyDown",resultsNextKeyDown);
         hideDlg();
      }
      
      private function onRetry_Yes() : void
      {
         var _loc1_:int = 0;
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         _readyLevelDisplayTimer = 0;
         _queueGameOver = false;
         _scene.getLayer("combo1").loader.content.gotoAndStop(0);
         _scene.getLayer("combo2").loader.content.gotoAndStop(0);
         _levelIndex = _startLevelSelected;
         _loc1_ = 0;
         while(_loc1_ < _totalPlayers)
         {
            _players[_loc1_].reset();
            _players[_loc1_]._totalScore = 0;
            _players[_loc1_].incrementTotalScore(0);
            _loc1_++;
         }
         buildNextLevel();
         setGameState(3);
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",replayKeyDown);
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
         if(_levelSelectPopup && _levelSelectPopup.loader.content)
         {
            _levelSelectPopup.loader.content.introPaused = false;
         }
      }
      
      override protected function showDlg(param1:String, param2:Array, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Boolean = false) : MovieClip
      {
         return super.showDlg(param1,param2,0,0,param5);
      }
      
      override protected function hideDlg() : void
      {
         super.hideDlg();
      }
   }
}

