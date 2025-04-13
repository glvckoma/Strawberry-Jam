package game.pVP_Bowling
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class PVP_Bowling extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LOADING_AVATAR1:int = 1;
      
      public static const GAMESTATE_LOADING_AVATAR2:int = 2;
      
      public static const GAMESTATE_READY_TO_START:int = 3;
      
      public static const GAMESTATE_WAITING_FOR_START:int = 4;
      
      public static const GAMESTATE_PHASE_WAIT_RESULTS:int = 5;
      
      public static const GAMESTATE_PHASE_RESULTS_COMPLETE:int = 7;
      
      public static const GAMESTATE_ROUND_COMPLETE:int = 8;
      
      public static const GAMESTATE_GAME_OVER_RESULTS:int = 9;
      
      public static const GAMESTATE_GAME_OVER:int = 10;
      
      public static const TURN_TIME:int = 15;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _playerAvatar1:Avatar;
      
      private var _playerAvatar2:Avatar;
      
      private var _playerAvatarView1:AvatarView;
      
      private var _playerAvatarView2:AvatarView;
      
      public var _layerMain:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      public var _currentBowl:int;
      
      public var _currentFrame:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _timeout:Boolean;
      
      private var _timeoutTimer:Number;
      
      private var _isFrameDone:Boolean;
      
      public var _theGame:Object;
      
      public var _players:Array;
      
      public var _iGameResult:int;
      
      public var _gameCompleteTimer:Number;
      
      public var _turnTimer:Number;
      
      public var _emoteTimer:Number;
      
      public var _boardSelectDelayTimer:Number;
      
      public var _messageCache:Array;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["aj_bowlBallRoll_2.mp3","aj_bowlGutterBall.mp3","aj_bowlPinDbleHit.mp3","aj_bowlPinMultiHit.mp3","aj_bowlPinSngleHit.mp3","aj_bowlPinSngleHitStars.mp3","aj_bowlPlayerFail.mp3","aj_bowlPlayerWin.mp3","aj_bowlSpare.mp3","aj_bowlStrike.mp3","aj_pinSingleHitWall.mp3","pvp_emojiRollover.mp3","pvp_emojiSelect.mp3","pvp_RedTexExit.mp3","pvp_RedTextEnter.mp3","pvp_timerRedCountdown.mp3","pvp_timeUpBuzzer.mp3","pvp_TurnEnter.mp3","pvp_TurnExit.mp3"];
      
      private var _soundNameBallRoll2:String = _audio[0];
      
      private var _soundNameGutterBall:String = _audio[1];
      
      private var _soundNamePinDbleHit:String = _audio[2];
      
      private var _soundNamePinMultiHit:String = _audio[3];
      
      private var _soundNamePinSngleHit:String = _audio[4];
      
      private var _soundNamePinSngleHitStars:String = _audio[5];
      
      private var _soundNamePlayerFail:String = _audio[6];
      
      private var _soundNamePlayerWin:String = _audio[7];
      
      private var _soundNameSpare:String = _audio[8];
      
      private var _soundNameStrike:String = _audio[9];
      
      private var _soundNamePinSingleHitWall:String = _audio[10];
      
      private var _soundNameEmojiRollover:String = _audio[11];
      
      private var _soundNameEmojiSelect:String = _audio[12];
      
      private var _soundNameRedTexExit:String = _audio[13];
      
      private var _soundNameRedTextEnter:String = _audio[14];
      
      private var _soundNameTimerRedCountdown:String = _audio[15];
      
      private var _soundNameTimeUpBuzzer:String = _audio[16];
      
      private var _soundNameTurnEnter:String = _audio[17];
      
      private var _soundNameTurnExit:String = _audio[18];
      
      public function PVP_Bowling()
      {
         super();
         _iGameResult = 0;
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameBallRoll2],_soundNameBallRoll2,0.69);
         _soundMan.addSoundByName(_audioByName[_soundNameGutterBall],_soundNameGutterBall,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNamePinDbleHit],_soundNamePinDbleHit,1.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePinMultiHit],_soundNamePinMultiHit,0.96);
         _soundMan.addSoundByName(_audioByName[_soundNamePinSngleHit],_soundNamePinSngleHit,1.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePinSngleHitStars],_soundNamePinSngleHitStars,1.15);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerFail],_soundNamePlayerFail,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerWin],_soundNamePlayerWin,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNameSpare],_soundNameSpare,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameStrike],_soundNameStrike,0.63);
         _soundMan.addSoundByName(_audioByName[_soundNamePinSingleHitWall],_soundNamePinSingleHitWall,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameEmojiRollover],_soundNameEmojiRollover,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameEmojiSelect],_soundNameEmojiSelect,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTexExit],_soundNameRedTexExit,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextEnter],_soundNameRedTextEnter,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerRedCountdown],_soundNameTimerRedCountdown,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameTimeUpBuzzer],_soundNameTimeUpBuzzer,1.1);
         _soundMan.addSoundByName(_audioByName[_soundNameTurnEnter],_soundNameTurnEnter,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameTurnExit],_soundNameTurnExit,0.25);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         var _loc2_:Array = null;
         if(_gameTime > 5 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(86,1);
         }
         _loc2_ = [];
         _loc2_[0] = "quit";
         MinigameManager.msg(_loc2_);
         releaseBase();
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",onKeyDown);
         resetGame();
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               if(_theGame.loader.content.localTurn)
               {
                  _theGame.loader.content.playerInput();
                  break;
               }
         }
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("PVP_Bowling/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
            if(_sceneLoaded && MainFrame.isInitialized())
            {
               setGameState(1);
            }
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _theGame = _scene.getLayer("theGame");
         _closeBtn = addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _layerMain.addChild(_theGame.loader);
         _sceneLoaded = true;
         _emoteTimer = 0;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",onKeyDown,false,0,true);
         super.sceneLoaded(param1);
         startGame();
         if(MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1[0] == "ml")
         {
            _iGameResult = 1;
            if(_gameState <= 4)
            {
               end(null);
            }
            else
            {
               setGameState(9);
            }
         }
         else if(param1[0] == "ms")
         {
            _serverStarted = true;
            _dbIDs = [];
            _userNames = [];
            _loc2_ = 1;
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _dbIDs[_loc3_] = param1[_loc2_++];
               _userNames[_loc3_] = param1[_loc2_++];
               _loc3_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "round")
            {
               _players = new Array(2);
               _players[0] = parseInt(param1[3]);
               _players[1] = parseInt(param1[4]);
               _currentBowl = 1;
               _currentFrame = 0;
               if(_players[0] == myId)
               {
                  _theGame.loader.content.startTurn(true,_currentFrame + 1,_currentBowl);
               }
               else
               {
                  _theGame.loader.content.startTurn(false,_currentFrame + 1,_currentBowl);
               }
               setGameState(5);
               hideDlg();
               if(_theGame)
               {
                  _theGame.loader.content.unPauseGame();
               }
            }
            else if(param1[2] == "ball")
            {
               _theGame.loader.content.bowlRemote(parseFloat(param1[3]),parseFloat(param1[4]),parseFloat(param1[5]));
               _turnTimer = 0;
               _theGame.loader.content.time(15,15);
            }
            else if(param1[2] == "time")
            {
               _theGame.loader.content.lane1Sim.simBall.moveActive = 3;
               _theGame.loader.content.bowlScore = 0;
               _timeout = true;
               if(!_theGame.loader.content.localTurn)
               {
                  _theGame.loader.content.time(_turnTimer,15);
               }
            }
            else if(param1[2] == "nextround")
            {
               setGameState(5);
               _theGame.loader.content.startTurn(_theGame.loader.content.localTurn,_currentFrame / 2 + 1,_currentBowl);
            }
            else if(param1[2] == "emote")
            {
               if(_theGame != null && _theGame.loader != null && _theGame.loader.content != null)
               {
                  _theGame.loader.content.opponentEmote(parseInt(param1[3]));
               }
            }
         }
      }
      
      private function avatarAdCallback(param1:String = null) : void
      {
         var _loc2_:Point = null;
         switch(_gameState - 1)
         {
            case 0:
               _playerAvatarView1.playAnim(15,false,1,null);
               _loc2_ = AvatarUtility.getAvatarHudPosition(_playerAvatarView1.avTypeId);
               _playerAvatarView1.x = _loc2_.x;
               _playerAvatarView1.y = _loc2_.y;
               setGameState(2);
               break;
            case 1:
               _playerAvatarView2.playAnim(15,false,1,null);
               _loc2_ = AvatarUtility.getAvatarHudPosition(_playerAvatarView2.avTypeId);
               _playerAvatarView2.x = _loc2_.x;
               _playerAvatarView2.y = _loc2_.y;
               if(_theGame.loader.content.portrait1 != null)
               {
                  _theGame.loader.content.portrait1.portraitContainer.addChild(_playerAvatarView1);
                  _theGame.loader.content.portrait2.portraitContainer.addChild(_playerAvatarView2);
               }
               setGameState(3);
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         if(_gameState != 10)
         {
            _gameState = param1;
            switch(param1 - 1)
            {
               case 0:
                  _playerAvatar1 = new Avatar();
                  if(_pIDs[0] == myId)
                  {
                     _playerAvatar1.init(_dbIDs[0],-1,"pvp" + _dbIDs[0],1,[0,0,0],-1,null,_userNames[0]);
                     _playerAvatarView1 = new AvatarView();
                     _playerAvatarView1.init(_playerAvatar1);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[0],true,avatarAdCallback,_playerAvatar1);
                     break;
                  }
                  _playerAvatar1.init(_dbIDs[1],-1,"pvp" + _dbIDs[1],1,[0,0,0],-1,null,_userNames[1]);
                  _playerAvatarView1 = new AvatarView();
                  _playerAvatarView1.init(_playerAvatar1);
                  AvatarXtCommManager.requestADForAvatar(_dbIDs[1],true,avatarAdCallback,_playerAvatar1);
                  break;
               case 1:
                  _playerAvatar2 = new Avatar();
                  if(_pIDs[0] == myId)
                  {
                     _playerAvatar2.init(_dbIDs[1],-1,"pvp" + _dbIDs[1],1,[0,0,0],-1,null,_userNames[1]);
                     _playerAvatarView2 = new AvatarView();
                     _playerAvatarView2.init(_playerAvatar2);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[1],true,avatarAdCallback,_playerAvatar2);
                     break;
                  }
                  _playerAvatar2.init(_dbIDs[0],-1,"pvp" + _dbIDs[0],1,[0,0,0],-1,null,_userNames[0]);
                  _playerAvatarView2 = new AvatarView();
                  _playerAvatarView2.init(_playerAvatar2);
                  AvatarXtCommManager.requestADForAvatar(_dbIDs[0],true,avatarAdCallback,_playerAvatar2);
                  break;
               case 2:
                  if(_theGame)
                  {
                     _theGame.loader.content.pauseGame();
                  }
                  _loc2_ = showDlg("PVPBowling_waiting",[]);
                  if(_loc2_)
                  {
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                  }
                  break;
               case 4:
                  _turnTimer = 15;
                  break;
               case 8:
                  if(_closeBtn)
                  {
                     _closeBtn.visible = false;
                  }
                  switch(_iGameResult)
                  {
                     case 0:
                        _theGame.loader.content.setLose();
                        break;
                     case 1:
                        _theGame.loader.content.setWin();
                        break;
                     case 2:
                        _theGame.loader.content.setTie();
                  }
                  _gameCompleteTimer = 3;
                  break;
               case 9:
                  switch(_iGameResult)
                  {
                     case 0:
                        MinigameManager._pvpPromptReplay = true;
                        addGemsToBalance(5);
                        _loc2_ = showDlg("PVPBowling_win",[]);
                        if(_loc2_)
                        {
                           LocalizationManager.translateIdAndInsert(_loc2_.gemsEarned,11577,5);
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                        }
                        break;
                     case 1:
                        if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                        {
                           AchievementXtCommManager.requestSetUserVar(87,1);
                        }
                        addGemsToBalance(20);
                        _loc2_ = showDlg("PVPBowling_win",[]);
                        if(_loc2_)
                        {
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                        }
                        break;
                     case 2:
                        if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                        {
                           AchievementXtCommManager.requestSetUserVar(87,1);
                        }
                        addGemsToBalance(10);
                        _loc2_ = showDlg("PVPBowling_tie",[]);
                        if(_loc2_)
                        {
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                           break;
                        }
                  }
                  _gameCompleteTimer = 5;
            }
         }
      }
      
      public function startGame() : void
      {
         resetGame();
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      public function resetGame() : void
      {
      }
      
      public function startRound() : void
      {
         var _loc1_:Array = null;
         _boardSelectDelayTimer = 0;
         _messageCache = [];
         _loc1_ = [];
         _loc1_[0] = "ready";
         MinigameManager.msg(_loc1_);
         setGameState(4);
         if(_pIDs[0] == myId)
         {
            _theGame.loader.content.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
            _theGame.loader.content.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
         }
         else
         {
            _theGame.loader.content.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
            _theGame.loader.content.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
         }
      }
      
      private function processResults() : void
      {
         var _loc1_:Array = null;
         if(_isFrameDone)
         {
            if(_currentFrame >= 5)
            {
               handleEndGame();
               return;
            }
            _currentFrame++;
            _currentBowl = 1;
            _theGame.loader.content.localTurn = !_theGame.loader.content.localTurn;
         }
         _loc1_ = [];
         _loc1_[0] = "rp";
         MinigameManager.msg(_loc1_);
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         if(_sceneLoaded)
         {
            if(_serverStarted)
            {
               if(_gameState == 3)
               {
                  startRound();
               }
               _frameTime = (getTimer() - _lastTime) / 1000;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
               _gameTime += _frameTime;
               if(_emoteTimer > 0)
               {
                  _emoteTimer -= _frameTime;
               }
               if(_emoteTimer <= 0 && _theGame.loader.content.emoteClicked > 0)
               {
                  _emoteTimer = 1.5;
                  _loc2_ = [];
                  _loc2_[0] = "emote";
                  _loc2_[1] = _theGame.loader.content.emoteClicked;
                  MinigameManager.msg(_loc2_);
                  _theGame.loader.content.emoteClicked = 0;
               }
               if(_theGame.loader.content.aj_bowlBallRoll_2)
               {
                  _soundMan.playByName(_soundNameBallRoll2);
                  _theGame.loader.content.aj_bowlBallRoll_2 = false;
               }
               if(_theGame.loader.content.aj_bowlGutterBall)
               {
                  _soundMan.playByName(_soundNameGutterBall);
                  _theGame.loader.content.aj_bowlGutterBall = false;
               }
               if(_theGame.loader.content.aj_bowlPinDbleHit)
               {
                  _soundMan.playByName(_soundNamePinDbleHit);
                  _theGame.loader.content.aj_bowlPinDbleHit = false;
               }
               if(_theGame.loader.content.aj_bowlPinMultiHit)
               {
                  _soundMan.playByName(_soundNamePinMultiHit);
                  _theGame.loader.content.aj_bowlPinMultiHit = false;
               }
               if(_theGame.loader.content.aj_bowlPinSngleHit)
               {
                  _soundMan.playByName(_soundNamePinSngleHit);
                  _theGame.loader.content.aj_bowlPinSngleHit = false;
               }
               if(_theGame.loader.content.aj_bowlPinSngleHitStars)
               {
                  _soundMan.playByName(_soundNamePinSngleHitStars);
                  _theGame.loader.content.aj_bowlPinSngleHitStars = false;
               }
               if(_theGame.loader.content.aj_bowlPlayerFail)
               {
                  _soundMan.playByName(_soundNamePlayerFail);
                  _theGame.loader.content.aj_bowlPlayerFail = false;
               }
               if(_theGame.loader.content.aj_bowlPlayerWin)
               {
                  _soundMan.playByName(_soundNamePlayerWin);
                  _theGame.loader.content.aj_bowlPlayerWin = false;
               }
               if(_theGame.loader.content.aj_bowlSpare)
               {
                  _soundMan.playByName(_soundNameSpare);
                  _theGame.loader.content.aj_bowlSpare = false;
               }
               if(_theGame.loader.content.aj_bowlStrike)
               {
                  _soundMan.playByName(_soundNameStrike);
                  _theGame.loader.content.aj_bowlStrike = false;
               }
               if(_theGame.loader.content.aj_pinSingleHitWall)
               {
                  _soundMan.playByName(_soundNamePinSingleHitWall);
                  _theGame.loader.content.aj_pinSingleHitWall = false;
               }
               if(_theGame.loader.content.pvp_emojiRollover)
               {
                  _soundMan.playByName(_soundNameEmojiRollover);
                  _theGame.loader.content.pvp_emojiRollover = false;
               }
               if(_theGame.loader.content.pvp_emojiSelect)
               {
                  _soundMan.playByName(_soundNameEmojiSelect);
                  _theGame.loader.content.pvp_emojiSelect = false;
               }
               if(_theGame.loader.content.pvp_RedTexExit)
               {
                  _soundMan.playByName(_soundNameRedTexExit);
                  _theGame.loader.content.pvp_RedTexExit = false;
               }
               if(_theGame.loader.content.pvp_RedTextEnter)
               {
                  _soundMan.playByName(_soundNameRedTextEnter);
                  _theGame.loader.content.pvp_RedTextEnter = false;
               }
               if(_theGame.loader.content.pvp_timerRedCountdown)
               {
                  _soundMan.playByName(_soundNameTimerRedCountdown);
                  _theGame.loader.content.pvp_timerRedCountdown = false;
               }
               if(_theGame.loader.content.pvp_timeUpBuzzer)
               {
                  _soundMan.playByName(_soundNameTimeUpBuzzer);
                  _theGame.loader.content.pvp_timeUpBuzzer = false;
               }
               if(_theGame.loader.content.pvp_TurnEnter)
               {
                  _soundMan.playByName(_soundNameTurnEnter);
                  _theGame.loader.content.pvp_TurnEnter = false;
               }
               if(_theGame.loader.content.pvp_TurnExit)
               {
                  _soundMan.playByName(_soundNameTurnExit);
                  _theGame.loader.content.pvp_TurnExit = false;
               }
               switch(_gameState - 5)
               {
                  case 0:
                     _theGame.loader.content.stageHeartbeat();
                     if(_timeoutTimer > 0)
                     {
                        _timeoutTimer -= _frameTime;
                        if(_timeoutTimer <= 0)
                        {
                           processResults();
                        }
                     }
                     else
                     {
                        if(_theGame.loader.content.lane1Sim.simBall.moveActive == 3)
                        {
                           _isFrameDone = _theGame.loader.content.recordScore(_theGame.loader.content.localTurn,_currentFrame / 2 + 1,_currentBowl++);
                           _theGame.loader.content.lane1Sim.simBall.moveActive = 4;
                           if(_timeout)
                           {
                              _timeout = false;
                              _timeoutTimer = 1.5;
                           }
                           else
                           {
                              processResults();
                           }
                        }
                        if(_theGame.loader.content.localTurn && _theGame.loader.content.ballThrown)
                        {
                           _theGame.loader.content.ballThrown = false;
                           _loc2_ = [];
                           _loc2_[0] = "ball";
                           _loc2_[1] = _theGame.loader.content.ballThrown_Angle;
                           _loc2_[2] = _theGame.loader.content.ballThrown_x;
                           _loc2_[3] = _theGame.loader.content.ballThrown_y;
                           MinigameManager.msg(_loc2_);
                           _turnTimer = 0;
                           _theGame.loader.content.time(15,15);
                        }
                     }
                     if(_turnTimer > 0)
                     {
                        _turnTimer -= _frameTime;
                        if(_turnTimer <= 0)
                        {
                           if(_theGame.loader.content.myTurn)
                           {
                              _turnTimer = 0;
                              _loc2_ = [];
                              _loc2_[0] = "time";
                              MinigameManager.msg(_loc2_);
                              _theGame.loader.content.time(_turnTimer,15);
                           }
                           break;
                        }
                        _theGame.loader.content.time(_turnTimer,15);
                     }
                     break;
                  case 4:
                     if(_gameCompleteTimer > 0)
                     {
                        _gameCompleteTimer -= _frameTime;
                        if(_gameCompleteTimer <= 0)
                        {
                           setGameState(10);
                        }
                     }
                     break;
                  case 5:
                     if(_gameCompleteTimer > 0)
                     {
                        _gameCompleteTimer -= _frameTime;
                        if(_gameCompleteTimer <= 0)
                        {
                           end(null);
                        }
                        break;
                     }
               }
            }
         }
      }
      
      private function handleEndGame() : void
      {
         if(_theGame.loader.content.totalScoreL > _theGame.loader.content.totalScoreR)
         {
            _iGameResult = 1;
         }
         else if(_theGame.loader.content.totalScoreL == _theGame.loader.content.totalScoreR)
         {
            _iGameResult = 2;
         }
         else
         {
            _iGameResult = 0;
         }
         setGameState(9);
      }
      
      public function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(_gameState != 10)
         {
            if(_theGame)
            {
               _theGame.loader.content.pauseGame();
            }
            _loc1_ = showDlg("ExitConfirmationDlg",[{
               "name":"button_yes",
               "f":onExit_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            }]);
            if(_loc1_)
            {
               _loc1_.x = 450;
               _loc1_.y = 275;
            }
         }
         else
         {
            end(null);
         }
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         if(_theGame)
         {
            _theGame.loader.content.unPauseGame();
         }
         hideDlg();
      }
      
      private function onExitButton() : void
      {
         hideDlg();
         end(null);
      }
   }
}

