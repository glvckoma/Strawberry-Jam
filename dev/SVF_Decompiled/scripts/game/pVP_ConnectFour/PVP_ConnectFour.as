package game.pVP_ConnectFour
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
   
   public class PVP_ConnectFour extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LOADING_AVATAR1:int = 1;
      
      public static const GAMESTATE_LOADING_AVATAR2:int = 2;
      
      public static const GAMESTATE_READY_TO_START:int = 3;
      
      public static const GAMESTATE_WAITING_FOR_START:int = 4;
      
      public static const GAMESTATE_PLAYING:int = 5;
      
      public static const GAMESTATE_ROUND_COMPLETE:int = 6;
      
      public static const GAMESTATE_GAME_OVER:int = 7;
      
      public static const TURN_TIME:int = 15;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _playerAvatar1:Avatar;
      
      private var _playerAvatar2:Avatar;
      
      private var _playerAvatarView1:AvatarView;
      
      private var _playerAvatarView2:AvatarView;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _players:Array;
      
      public var _roundCompleteTimer:Number;
      
      public var _gameOverTimer:Number;
      
      public var _turnTimer:Number;
      
      public var _myTurn:Boolean;
      
      public var _winState:int;
      
      public var _boardSelectDelayTimer:Number;
      
      public var _messageCache:Array;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["pvp_stinger_draw.mp3","pvp_stinger_fail.mp3","pvp_stinger_win.mp3","pvp_stinger_turn.mp3","connect_four_slide.mp3","connect_four_square_rollover.mp3","connect_four_imp.mp3","popup_pvp_RedText_enter.mp3","popup_pvp_RedText_exit.mp3","popup_pvp_YourTurn_enter.mp3","popup_pvp_YourTurn_exit.mp3","pvp_c4_timer_count_down.mp3","pvp_timeUp_buzzer.mp3"];
      
      private var _soundNameTie:String = _audio[0];
      
      private var _soundNameLose:String = _audio[1];
      
      private var _soundNameWin:String = _audio[2];
      
      private var _soundNameTurn:String = _audio[3];
      
      private var _soundNameSelect:String = _audio[4];
      
      private var _soundNameRollover:String = _audio[5];
      
      private var _soundNameSlideStop:String = _audio[6];
      
      private var _soundNameRedTextEnter:String = _audio[7];
      
      private var _soundNameRedTextExit:String = _audio[8];
      
      private var _soundNameYourTurnEnter:String = _audio[9];
      
      private var _soundNameYourTurnExit:String = _audio[10];
      
      private var _soundNameTimerCount:String = _audio[11];
      
      private var _soundNameTimerDone:String = _audio[12];
      
      public function PVP_ConnectFour()
      {
         super();
         _winState = 0;
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameTie],_soundNameTie,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameLose],_soundNameLose,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameWin],_soundNameWin,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameTurn],_soundNameTurn,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameSelect],_soundNameSelect,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.29);
         _soundMan.addSoundByName(_audioByName[_soundNameSlideStop],_soundNameSlideStop,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextEnter],_soundNameRedTextEnter,0.14);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextExit],_soundNameRedTextExit,0.13);
         _soundMan.addSoundByName(_audioByName[_soundNameYourTurnEnter],_soundNameYourTurnEnter,0.17);
         _soundMan.addSoundByName(_audioByName[_soundNameYourTurnExit],_soundNameYourTurnExit,0.17);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerCount],_soundNameTimerCount,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerDone],_soundNameTimerDone,1);
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
         _gameOverTimer = 0;
         _winState = 0;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("PVP_ConnectFour/room_main.xroom",_audio);
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
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1[0] == "ml")
         {
            if(_soundMan)
            {
               _soundMan.playByName(_soundNameWin);
            }
            if(_theGame && _theGame.loader.content)
            {
               _theGame.loader.content.setWin();
               _theGame.loader.content.setPlayerInactive();
            }
            _winState = 1;
            if(_gameState <= 4)
            {
               end(null);
            }
            else
            {
               setGameState(7);
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
               _players[0] = parseInt(param1[4]);
               _players[1] = parseInt(param1[5]);
               _myTurn = _players[parseInt(param1[3])] == myId;
               if(_myTurn)
               {
                  _soundMan.playByName(_soundNameTurn);
                  _theGame.loader.content.setPlayerActive();
               }
               else
               {
                  _theGame.loader.content.opponentsTurn();
               }
               _turnTimer = 15;
               setGameState(5);
            }
            else if(param1[2] == "mark")
            {
               _soundMan.playByName(_soundNameSelect);
               _theGame.loader.content.setMark(parseInt(param1[3]) == 0,parseInt(param1[4]));
               _boardSelectDelayTimer = 0.5;
               _loc3_ = 0;
               while(_loc3_ < param1.length)
               {
                  _messageCache[_loc3_] = param1[_loc3_];
                  _loc3_++;
               }
            }
            else if(param1[2] == "invalid" || param1[2] == "wp")
            {
               _myTurn = _players[parseInt(param1[3])] == myId;
               if(_myTurn)
               {
                  _soundMan.playByName(_soundNameTurn);
                  _theGame.loader.content.setPlayerActive();
               }
               else
               {
                  _theGame.loader.content.opponentsTurn();
               }
               _turnTimer = 15;
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
         if(_gameState != 7 && _gameState != param1)
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
                  _loc2_ = showDlg("c4_waiting",[]);
                  if(_loc2_)
                  {
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                  }
                  break;
               case 4:
                  hideDlg();
                  break;
               case 5:
                  _roundCompleteTimer = 3;
                  break;
               case 6:
                  if(_winState == 1)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(87,1);
                     }
                     addGemsToBalance(20);
                  }
                  else if(_winState == 2)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(87,1);
                     }
                     addGemsToBalance(10);
                  }
                  else
                  {
                     MinigameManager._pvpPromptReplay = true;
                     addGemsToBalance(5);
                  }
                  _roundCompleteTimer = 2;
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
         _theGame.loader.content.newRound();
         _boardSelectDelayTimer = 0;
         _messageCache = [];
         _loc1_ = [];
         _loc1_[0] = "ready";
         MinigameManager.msg(_loc1_);
         setGameState(4);
         _theGame.loader.content.rolloverSound = false;
         _theGame.loader.content.checkerSound = false;
         if(_pIDs[0] == myId)
         {
            _theGame.loader.content.playerX = true;
            _theGame.loader.content.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
            _theGame.loader.content.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
         }
         else
         {
            _theGame.loader.content.playerX = false;
            _theGame.loader.content.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
            _theGame.loader.content.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:MovieClip = null;
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
               if(_theGame.loader.content.timer_count_down)
               {
                  _theGame.loader.content.timer_count_down = false;
                  _soundMan.playByName(_soundNameTimerCount);
               }
               if(_theGame.loader.content.timer_timeUp)
               {
                  _theGame.loader.content.timer_timeUp = false;
                  _soundMan.playByName(_soundNameTimerDone);
               }
               if(_theGame.loader.content.RedText_enter)
               {
                  _theGame.loader.content.RedText_enter = false;
                  _soundMan.playByName(_soundNameRedTextEnter);
               }
               if(_theGame.loader.content.RedText_exit)
               {
                  _theGame.loader.content.RedText_exit = false;
                  _soundMan.playByName(_soundNameRedTextExit);
               }
               if(_theGame.loader.content.YourTurn_enter)
               {
                  _theGame.loader.content.YourTurn_enter = false;
                  _soundMan.playByName(_soundNameYourTurnEnter);
               }
               if(_theGame.loader.content.YourTurn_exit)
               {
                  _theGame.loader.content.YourTurn_exit = false;
                  _soundMan.playByName(_soundNameYourTurnExit);
               }
               if(_gameState == 5)
               {
                  if(_theGame.loader.content.rolloverSound)
                  {
                     _theGame.loader.content.rolloverSound = false;
                     _soundMan.playByName(_soundNameRollover);
                  }
                  if(_theGame.loader.content.checkerSound)
                  {
                     _theGame.loader.content.checkerSound = false;
                     _soundMan.playByName(_soundNameSlideStop);
                  }
                  if(_theGame.loader.content.marked)
                  {
                     _myTurn = false;
                     _turnTimer = 0;
                     _theGame.loader.content.marked = false;
                     _loc2_ = [];
                     _loc2_[0] = "mark";
                     _loc2_[1] = String(int(_theGame.loader.content.markedX));
                     MinigameManager.msg(_loc2_);
                  }
                  else if(_boardSelectDelayTimer > 0)
                  {
                     _boardSelectDelayTimer -= _frameTime;
                     if(_boardSelectDelayTimer <= 0)
                     {
                        if(_messageCache[5] == "1")
                        {
                           if(_players[parseInt(_messageCache[3])] == myId)
                           {
                              _soundMan.playByName(_soundNameWin);
                              _theGame.loader.content.setWin();
                              _winState = 1;
                           }
                           else
                           {
                              _soundMan.playByName(_soundNameLose);
                              _theGame.loader.content.setLose();
                           }
                           setGameState(7);
                        }
                        else if(_messageCache[6] == "1")
                        {
                           _winState = 2;
                           _soundMan.playByName(_soundNameTie);
                           _theGame.loader.content.setTie();
                           setGameState(7);
                        }
                        else
                        {
                           _myTurn = _players[parseInt(_messageCache[7])] == myId;
                           if(_myTurn)
                           {
                              _soundMan.playByName(_soundNameTurn);
                              _theGame.loader.content.setPlayerActive();
                           }
                           else
                           {
                              _theGame.loader.content.opponentsTurn();
                           }
                           _turnTimer = 15;
                        }
                     }
                  }
                  else if(_turnTimer > 0)
                  {
                     _turnTimer -= _frameTime;
                     if(_turnTimer <= 0)
                     {
                        _turnTimer = 0;
                        if(_myTurn)
                        {
                           _myTurn = false;
                           _loc2_ = [];
                           _loc2_[0] = "time";
                           MinigameManager.msg(_loc2_);
                        }
                     }
                     _theGame.loader.content.time(_turnTimer,15);
                  }
               }
               else if(_gameState == 6)
               {
                  if(_roundCompleteTimer > 0)
                  {
                     _roundCompleteTimer -= _frameTime;
                     if(_roundCompleteTimer <= 0)
                     {
                        startRound();
                     }
                  }
               }
               else if(_gameState == 7)
               {
                  if(_roundCompleteTimer > 0)
                  {
                     _roundCompleteTimer -= _frameTime;
                     if(_roundCompleteTimer <= 0)
                     {
                        if(_winState == 1)
                        {
                           _loc3_ = showDlg("c4_win",[]);
                           if(_loc3_)
                           {
                              _loc3_.x = 450;
                              _loc3_.y = 275;
                           }
                        }
                        else if(_winState == 2)
                        {
                           _loc3_ = showDlg("c4_tie",[]);
                           if(_loc3_)
                           {
                              _loc3_.x = 450;
                              _loc3_.y = 275;
                           }
                        }
                        else
                        {
                           _loc3_ = showDlg("c4_win",[]);
                           if(_loc3_)
                           {
                              LocalizationManager.translateIdAndInsert(_loc3_.gemsEarned,11577,5);
                              _loc3_.x = 450;
                              _loc3_.y = 275;
                           }
                        }
                        _gameOverTimer = 3;
                     }
                  }
                  else if(_gameOverTimer > 0)
                  {
                     _gameOverTimer -= _frameTime;
                     if(_gameOverTimer <= 0)
                     {
                        end(null);
                     }
                  }
               }
            }
         }
      }
      
      public function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(_gameState != 7)
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

