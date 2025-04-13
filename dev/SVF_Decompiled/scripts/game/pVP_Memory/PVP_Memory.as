package game.pVP_Memory
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class PVP_Memory extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LOADING_AVATAR1:int = 1;
      
      public static const GAMESTATE_LOADING_AVATAR2:int = 2;
      
      public static const GAMESTATE_READY_TO_START:int = 3;
      
      public static const GAMESTATE_WAITING_FOR_START:int = 4;
      
      public static const GAMESTATE_PHASE_WAIT_RESULTS:int = 5;
      
      public static const GAMESTATE_PHASE_PROCESS_RESULTS:int = 6;
      
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
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _players:Array;
      
      public var _iGameResult:int;
      
      public var _cardPickedStatus:int;
      
      public var _gameCompleteTimer:Number;
      
      public var _turnTimer:Number;
      
      public var _emoteTimer:Number;
      
      public var _boardSelectDelayTimer:Number;
      
      public var _messageCache:Array;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["pvp_stinger_draw.mp3","pvp_matchFail.mp3","pvp_matchFlip.mp3","pvp_matchRollOver.mp3","pvp_matchSelect.mp3","pvp_matchSuccess.mp3","pvp_stingerFail.mp3","pvp_stingerWin.mp3","pvp_stingerYourTurn.mp3","pvp_timerCountdown.mp3","pvp_timeUpBuzzer.mp3","pvp_RedTextEnter.mp3","pvp_RedTextExit.mp3","pvp_emojiRollover.mp3","pvp_emojiSelect.mp3","pvp_TurnEnter.mp3","pvp_TurnExit.mp3","pvp_textAwesome.mp3","pvp_textFindMatch.mp3"];
      
      private var _soundNameTie:String = _audio[0];
      
      private var _soundNameMatchNo:String = _audio[1];
      
      private var _soundNameMatchFlip:String = _audio[2];
      
      private var _soundNameMatchRollOver:String = _audio[3];
      
      private var _soundNameMatchSelect:String = _audio[4];
      
      private var _soundNameMatchYes:String = _audio[5];
      
      private var _soundNameLose:String = _audio[6];
      
      private var _soundNameWin:String = _audio[7];
      
      private var _soundNameYourTurn:String = _audio[8];
      
      private var _soundNameTimerCountdown:String = _audio[9];
      
      private var _soundNameTimerZero:String = _audio[10];
      
      private var _soundNameRedTextEnter:String = _audio[11];
      
      private var _soundNameRedTextExit:String = _audio[12];
      
      private var _soundNameEmojiRollover:String = _audio[13];
      
      private var _soundNameEmojiSelect:String = _audio[14];
      
      private var _soundNameTurnEnter:String = _audio[15];
      
      private var _soundNameTurnExit:String = _audio[16];
      
      private var _soundNameTextAwesome:String = _audio[17];
      
      private var _soundNameTextFindMatch:String = _audio[18];
      
      public function PVP_Memory()
      {
         super();
         _iGameResult = 0;
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameTie],_soundNameTie,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameMatchNo],_soundNameMatchNo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameMatchFlip],_soundNameMatchFlip,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNameMatchRollOver],_soundNameMatchRollOver,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameMatchSelect],_soundNameMatchSelect,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameMatchYes],_soundNameMatchYes,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameLose],_soundNameLose,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameWin],_soundNameWin,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameYourTurn],_soundNameYourTurn,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerCountdown],_soundNameTimerCountdown,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerZero],_soundNameTimerZero,1.2);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextEnter],_soundNameRedTextEnter,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextExit],_soundNameRedTextExit,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameEmojiRollover],_soundNameEmojiRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameEmojiSelect],_soundNameEmojiSelect,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTurnEnter],_soundNameTurnEnter,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTurnExit],_soundNameTurnExit,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTextAwesome],_soundNameTextAwesome,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTextFindMatch],_soundNameTextFindMatch,0.3);
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
         resetGame();
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("PVP_Memory/room_main.xroom",_audio);
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
         super.sceneLoaded(param1);
         startGame();
         if(MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc12_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:* = false;
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
            _loc5_ = 1;
            _loc9_ = 0;
            while(_loc9_ < _pIDs.length)
            {
               _dbIDs[_loc9_] = param1[_loc5_++];
               _userNames[_loc9_] = param1[_loc5_++];
               _loc9_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "round")
            {
               _players = new Array(2);
               _players[0] = parseInt(param1[3]);
               _players[1] = parseInt(param1[4]);
               _loc2_ = parseInt(param1[5]);
               _loc3_ = new Array(_loc2_);
               _loc12_ = 0;
               while(_loc12_ < _loc2_)
               {
                  _loc3_[_loc12_] = parseInt(param1[6 + _loc12_]);
                  _loc12_++;
               }
               _theGame.loader.content.setCards(_loc3_);
               _theGame.loader.content.myTurn = _players[0] == myId ? 1 : 0;
               _theGame.loader.content.newPhase(1);
               _cardPickedStatus = 0;
               setGameState(5);
               hideDlg();
               if(_theGame)
               {
                  _theGame.loader.content.unPauseGame();
               }
            }
            else if(param1[2] == "c1" || param1[2] == "c2")
            {
               _turnTimer = 15;
               _cardPickedStatus++;
               _loc4_ = parseInt(param1[3]);
               _loc7_ = _loc4_ / 4 + 1;
               _loc10_ = _loc4_ % 4 + 1;
               _theGame.loader.content.cardPicked(_loc10_,_loc7_);
               _soundMan.playByName(_soundNameMatchSelect);
            }
            else if(param1[2] == "time")
            {
               setGameState(6);
               _theGame.loader.content.setResult(false);
            }
            else if(param1[2] == "results")
            {
               setGameState(6);
               if(param1[3] == "1")
               {
                  _theGame.loader.content.setResult(true);
                  _loc6_ = parseInt(param1[4]);
                  if(_loc6_ == myId)
                  {
                     _iGameResult = 1;
                  }
                  else if(_loc6_ == 0)
                  {
                     _iGameResult = 2;
                  }
                  else
                  {
                     _iGameResult = 0;
                  }
                  setGameState(9);
               }
               else
               {
                  _loc8_ = param1[4] == "1";
                  _theGame.loader.content.setResult(_loc8_);
                  if(!_loc8_)
                  {
                     _soundMan.playByName(_soundNameMatchNo);
                  }
                  else
                  {
                     _soundMan.playByName(_soundNameMatchYes);
                  }
               }
            }
            else if(param1[2] == "nextround")
            {
               _theGame.loader.content.newPhase(9);
               setGameState(5);
               if(_theGame.loader.content.myTurn)
               {
                  _soundMan.playByName(_soundNameYourTurn);
               }
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
         if(_gameState != 10 && _gameState != param1)
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
                  _loc2_ = showDlg("PVPMemory_waiting",[]);
                  if(_loc2_)
                  {
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                  }
                  break;
               case 4:
                  _cardPickedStatus = 0;
                  _theGame.loader.content.card1X = 0;
                  _theGame.loader.content.card2X = 0;
                  _theGame.loader.content.card1Y = 0;
                  _theGame.loader.content.card2Y = 0;
                  _turnTimer = 15;
                  break;
               case 5:
                  _cardPickedStatus = 3;
                  break;
               case 8:
                  if(_closeBtn)
                  {
                     _closeBtn.visible = false;
                  }
                  switch(_iGameResult)
                  {
                     case 0:
                        _soundMan.playByName(_soundNameLose);
                        _theGame.loader.content.setLose();
                        break;
                     case 1:
                        _soundMan.playByName(_soundNameWin);
                        _theGame.loader.content.setWin();
                        break;
                     case 2:
                        _soundMan.playByName(_soundNameTie);
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
                        _loc2_ = showDlg("PVPMemory_win",[]);
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
                        _loc2_ = showDlg("PVPMemory_win",[]);
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
                        _loc2_ = showDlg("PVPMemory_tie",[]);
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
         if(!_theGame)
         {
         }
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
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
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
                  _soundMan.playByName(_soundNameEmojiSelect);
               }
               if(_theGame.loader.content.RedText_enter)
               {
                  _soundMan.playByName(_soundNameRedTextEnter);
                  _theGame.loader.content.RedText_enter = false;
               }
               if(_theGame.loader.content.RedText_exit)
               {
                  _soundMan.playByName(_soundNameRedTextExit);
                  _theGame.loader.content.RedText_exit = false;
               }
               if(_theGame.loader.content.rolloverSound)
               {
                  _soundMan.playByName(_soundNameMatchRollOver);
                  _theGame.loader.content.rolloverSound = false;
               }
               if(_theGame.loader.content.emojiRolloverSound)
               {
                  _soundMan.playByName(_soundNameEmojiRollover);
                  _theGame.loader.content.emojiRolloverSound = false;
               }
               if(_theGame.loader.content.YourTurn_enter)
               {
                  _soundMan.playByName(_soundNameTurnEnter);
                  _theGame.loader.content.YourTurn_enter = false;
               }
               if(_theGame.loader.content.YourTurn_exit)
               {
                  _soundMan.playByName(_soundNameTurnExit);
                  _theGame.loader.content.YourTurn_exit = false;
               }
               if(_theGame.loader.content.matchFlipSound)
               {
                  _soundMan.playByName(_soundNameMatchFlip);
                  _theGame.loader.content.matchFlipSound = false;
               }
               if(_theGame.loader.content.textAwesomeSound)
               {
                  _soundMan.playByName(_soundNameTextAwesome);
                  _theGame.loader.content.textAwesomeSound = false;
               }
               if(_theGame.loader.content.textFindMatchSound)
               {
                  _soundMan.playByName(_soundNameTextFindMatch);
                  _theGame.loader.content.textFindMatchSound = false;
               }
               loop0:
               switch(_gameState - 5)
               {
                  case 0:
                     switch(_cardPickedStatus)
                     {
                        case 0:
                           if(_theGame.loader.content.card1X != 0 && _theGame.loader.content.card1Y != 0)
                           {
                              _turnTimer = 15;
                              _cardPickedStatus = 1;
                              _loc2_ = [];
                              _loc2_[0] = "c1";
                              _loc2_[1] = (_theGame.loader.content.card1Y - 1) * 4 + (_theGame.loader.content.card1X - 1);
                              MinigameManager.msg(_loc2_);
                              _soundMan.playByName(_soundNameMatchSelect);
                              break loop0;
                           }
                           if(_turnTimer > 0)
                           {
                              _loc3_ = _turnTimer;
                              _turnTimer -= _frameTime;
                              if(_loc3_ >= 3 && _turnTimer < 3 || _loc3_ >= 2 && _turnTimer < 2 || _loc3_ >= 1 && _turnTimer < 1)
                              {
                                 _soundMan.playByName(_soundNameTimerCountdown);
                              }
                              if(_turnTimer <= 0)
                              {
                                 _soundMan.playByName(_soundNameTimerZero);
                                 if(_theGame.loader.content.myTurn)
                                 {
                                    _cardPickedStatus = 2;
                                    _turnTimer = 0;
                                    _loc2_ = [];
                                    _loc2_[0] = "time";
                                    MinigameManager.msg(_loc2_);
                                 }
                              }
                              _theGame.loader.content.time(_turnTimer,15);
                           }
                           break loop0;
                        case 1:
                           if(_theGame.loader.content.card2X > 0 && _theGame.loader.content.card2Y > 0)
                           {
                              _cardPickedStatus = 2;
                              _loc2_ = [];
                              _loc2_[0] = "c2";
                              _loc2_[1] = (_theGame.loader.content.card2Y - 1) * 4 + (_theGame.loader.content.card2X - 1);
                              MinigameManager.msg(_loc2_);
                              _soundMan.playByName(_soundNameMatchSelect);
                              break loop0;
                           }
                           if(_turnTimer > 0)
                           {
                              _loc3_ = _turnTimer;
                              _turnTimer -= _frameTime;
                              if(_loc3_ >= 3 && _turnTimer < 3 || _loc3_ >= 2 && _turnTimer < 2 || _loc3_ >= 1 && _turnTimer < 1)
                              {
                                 _soundMan.playByName(_soundNameTimerCountdown);
                              }
                              if(_turnTimer <= 0)
                              {
                                 _soundMan.playByName(_soundNameTimerZero);
                                 if(_theGame.loader.content.myTurn)
                                 {
                                    _cardPickedStatus = 2;
                                    _turnTimer = 0;
                                    _loc2_ = [];
                                    _loc2_[0] = "time";
                                    MinigameManager.msg(_loc2_);
                                 }
                              }
                              _theGame.loader.content.time(_turnTimer,15);
                              break;
                           }
                           break loop0;
                     }
                     break;
                  case 1:
                     if(_theGame.loader.content.phase == 8)
                     {
                        setGameState(7);
                        _loc2_ = [];
                        _loc2_[0] = "rp";
                        MinigameManager.msg(_loc2_);
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

