package game.pVP_ShellGame
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
   
   public class PVP_ShellGame extends GameBase implements IMinigame
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
      
      public static const TURN_TIME:int = 6;
      
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
      
      public var _winningShell:int;
      
      public var _iWon:Boolean;
      
      public var _iTieCounter:int;
      
      public var _gameOverTimer:Number;
      
      public var _roundCompleteTimer:Number;
      
      public var _turnTimer:Number;
      
      public var _boardSelectDelayTimer:Number;
      
      public var _messageCache:Array;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["pvp_stinger_draw.mp3","shells_timer_countdown.mp3","shells_popup.mp3","shells_player_wins_flash.mp3","shells_coconut_shuffle_short2.mp3","shells_coconut_shuffle_short1.mp3","shells_coconut_shuffle_long.mp3","shells_coconut_select.mp3","shells_coconut_rollover.mp3","shells_coconut_open.mp3","shells_coconut_close.mp3","pvp_stinger_win.mp3","pvp_stinger_fail.mp3","popup_pvp_RedText_exit.mp3","popup_pvp_RedText_enter.mp3"];
      
      private var _soundNameStingerDraw:String = _audio[0];
      
      private var _soundNameTimerCountdown:String = _audio[1];
      
      private var _soundNamePopup:String = _audio[2];
      
      private var _soundNamePlayerWinsFlash:String = _audio[3];
      
      private var _soundNameCoconutShuffleShort2:String = _audio[4];
      
      private var _soundNameCoconutShuffleShort1:String = _audio[5];
      
      private var _soundNameCoconutShuffleLong:String = _audio[6];
      
      private var _soundNameSelect:String = _audio[7];
      
      private var _soundNameRollover:String = _audio[8];
      
      private var _soundNameOpen:String = _audio[9];
      
      private var _soundNameClose:String = _audio[10];
      
      private var _soundNameStingerWin:String = _audio[11];
      
      private var _soundNameStingerFail:String = _audio[12];
      
      private var _soundNameRedTextExit:String = _audio[13];
      
      private var _soundNameRedTextEnter:String = _audio[14];
      
      public function PVP_ShellGame()
      {
         super();
         _iTieCounter = 0;
         _iWon = false;
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameStingerDraw],_soundNameStingerDraw,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerCountdown],_soundNameTimerCountdown,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNamePopup],_soundNamePopup,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerWinsFlash],_soundNamePlayerWinsFlash,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameCoconutShuffleShort2],_soundNameCoconutShuffleShort2,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameCoconutShuffleShort1],_soundNameCoconutShuffleShort1,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameCoconutShuffleLong],_soundNameCoconutShuffleLong,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameSelect],_soundNameSelect,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameOpen],_soundNameOpen,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameClose],_soundNameClose,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerWin],_soundNameStingerWin,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextExit],_soundNameRedTextExit,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextEnter],_soundNameRedTextEnter,0.15);
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
            loadScene("PVP_ShellGame/room_main.xroom",_audio);
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
            if(_iTieCounter < 3)
            {
               _iWon = true;
               if(_theGame && _theGame.loader.content)
               {
                  _theGame.loader.content.setWin();
                  _theGame.loader.content.setPlayerInactive();
               }
            }
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
               _players[0] = parseInt(param1[3]);
               _players[1] = parseInt(param1[4]);
               _winningShell = parseInt(param1[5]);
               _turnTimer = 6;
               setGameState(5);
            }
            else if(param1[2] == "mark")
            {
               _boardSelectDelayTimer = 1.75;
               _loc3_ = 0;
               while(_loc3_ < param1.length)
               {
                  _messageCache[_loc3_] = param1[_loc3_];
                  _loc3_++;
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
                  _loc2_ = showDlg("shells_waiting",[]);
                  _loc2_.x = 450;
                  _loc2_.y = 275;
                  break;
               case 4:
                  hideDlg();
                  _theGame.loader.content.startRound(_winningShell);
                  break;
               case 5:
                  _roundCompleteTimer = 3;
                  break;
               case 6:
                  if(_iTieCounter >= 3)
                  {
                     addGemsToBalance(10);
                  }
                  else if(_iWon)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(87,1);
                     }
                     addGemsToBalance(20);
                  }
                  else
                  {
                     addGemsToBalance(5);
                     MinigameManager._pvpPromptReplay = true;
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
         _theGame.loader.content.timerReady = false;
         _boardSelectDelayTimer = 0;
         _messageCache = [];
         _loc1_ = [];
         _loc1_[0] = "ready";
         MinigameManager.msg(_loc1_);
         setGameState(4);
         if(_pIDs[0] == myId)
         {
            _theGame.loader.content.names(gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName);
         }
         else
         {
            _theGame.loader.content.names(gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName);
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc4_:MovieClip = null;
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
               if(_theGame.loader.content.coconut_close)
               {
                  _theGame.loader.content.coconut_close = false;
                  _soundMan.playByName(_soundNameClose);
               }
               if(_theGame.loader.content.coconut_open)
               {
                  _theGame.loader.content.coconut_open = false;
                  _soundMan.playByName(_soundNameOpen);
               }
               if(_theGame.loader.content.coconut_rollover)
               {
                  _theGame.loader.content.coconut_rollover = false;
                  _soundMan.playByName(_soundNameRollover);
               }
               if(_theGame.loader.content.coconut_select)
               {
                  _theGame.loader.content.coconut_select = false;
                  _soundMan.playByName(_soundNameSelect);
               }
               if(_theGame.loader.content.coconut_shuffle_long)
               {
                  _theGame.loader.content.coconut_shuffle_long = false;
                  _soundMan.playByName(_soundNameCoconutShuffleLong);
               }
               if(_theGame.loader.content.coconut_shuffle_short1)
               {
                  _theGame.loader.content.coconut_shuffle_short1 = false;
                  _soundMan.playByName(_soundNameCoconutShuffleShort1);
               }
               if(_theGame.loader.content.coconut_shuffle_short2)
               {
                  _theGame.loader.content.coconut_shuffle_short2 = false;
                  _soundMan.playByName(_soundNameCoconutShuffleShort2);
               }
               if(_theGame.loader.content.player_wins_flash)
               {
                  _theGame.loader.content.player_wins_flash = false;
                  _soundMan.playByName(_soundNamePlayerWinsFlash);
               }
               if(_theGame.loader.content.popup)
               {
                  _theGame.loader.content.popup = false;
                  _soundMan.playByName(_soundNamePopup);
               }
               if(_theGame.loader.content.timer_countdown)
               {
                  _theGame.loader.content.timer_countdown = false;
                  _soundMan.playByName(_soundNameTimerCountdown);
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
               if(_theGame.loader.content.stinger_draw)
               {
                  _theGame.loader.content.stinger_draw = false;
                  _soundMan.playByName(_soundNameStingerDraw);
               }
               if(_theGame.loader.content.stinger_fail)
               {
                  _theGame.loader.content.stinger_fail = false;
                  _soundMan.playByName(_soundNameStingerFail);
               }
               if(_theGame.loader.content.stinger_win)
               {
                  _theGame.loader.content.stinger_win = false;
                  _soundMan.playByName(_soundNameStingerWin);
               }
               if(_gameState == 5)
               {
                  if(_boardSelectDelayTimer > 0)
                  {
                     _loc3_ = _boardSelectDelayTimer;
                     _boardSelectDelayTimer -= _frameTime;
                     if(_loc3_ >= 1 && _boardSelectDelayTimer < 1)
                     {
                        if(_players[0] == myId)
                        {
                           _theGame.loader.content.setMark(_messageCache[3],_messageCache[4]);
                        }
                        else
                        {
                           _theGame.loader.content.setMark(_messageCache[4],_messageCache[3]);
                        }
                     }
                     if(_boardSelectDelayTimer <= 0)
                     {
                        if(_messageCache[5] == "1")
                        {
                           if(_players[parseInt(_messageCache[6])] == myId)
                           {
                              _theGame.loader.content.setWin();
                              _iWon = true;
                           }
                           else
                           {
                              _theGame.loader.content.setLose();
                           }
                           setGameState(7);
                        }
                        else if(_messageCache[6] == "1")
                        {
                           if(_players[parseInt(_messageCache[7])] == myId)
                           {
                              _theGame.loader.content.setWin();
                           }
                           else
                           {
                              _theGame.loader.content.setLose();
                           }
                           setGameState(6);
                        }
                        else
                        {
                           _iTieCounter++;
                           if(_iTieCounter >= 3)
                           {
                              _theGame.loader.content.setTie();
                              setGameState(7);
                           }
                           else
                           {
                              setGameState(6);
                           }
                        }
                     }
                  }
                  else if(_turnTimer > 0)
                  {
                     if(_theGame.loader.content.timerReady)
                     {
                        _turnTimer -= _frameTime;
                        if(_turnTimer <= 0)
                        {
                           _turnTimer = 0;
                           _loc2_ = [];
                           _loc2_[0] = "time";
                           _loc2_[1] = _theGame.loader.content.marked;
                           MinigameManager.msg(_loc2_);
                        }
                        _theGame.loader.content.time(_turnTimer,6);
                     }
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
                        if(_iTieCounter >= 3)
                        {
                           _loc4_ = showDlg("shells_tie",[]);
                           if(_loc4_)
                           {
                              _loc4_.x = 450;
                              _loc4_.y = 275;
                           }
                        }
                        else if(_iWon)
                        {
                           _loc4_ = showDlg("shells_win",[]);
                           if(_loc4_)
                           {
                              _loc4_.x = 450;
                              _loc4_.y = 275;
                           }
                        }
                        else
                        {
                           _loc4_ = showDlg("shells_win",[]);
                           if(_loc4_)
                           {
                              _loc4_.x = 450;
                              _loc4_.y = 275;
                              LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11577,5);
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
            _loc1_.x = 450;
            _loc1_.y = 275;
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

