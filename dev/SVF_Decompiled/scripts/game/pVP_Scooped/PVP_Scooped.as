package game.pVP_Scooped
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class PVP_Scooped extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LOADING_AVATAR1:int = 1;
      
      public static const GAMESTATE_LOADING_AVATAR2:int = 2;
      
      public static const GAMESTATE_WAITING_FOR_START:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_PRE_GAME_OVER:int = 5;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      public static const GAMESTATE_WAITINGFORPLAYER:int = 7;
      
      public static const GAMESTATE_COINTOSS:int = 8;
      
      public static const GAMESTATE_HOWTOPLAY:int = 9;
      
      public static const GAMESTATE_PRESTARTED:int = 10;
      
      private var TIMEOUT_TIME:Number = 15;
      
      private var _background:Sprite;
      
      private var _foreground:Sprite;
      
      private var _layerPopups:Sprite;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _ui:Object;
      
      public var _soundMan:SoundManager;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _currentDragger:Object;
      
      private var _playerAvatar1:Avatar;
      
      private var _playerAvatar2:Avatar;
      
      private var _playerAvatarView1:AvatarView;
      
      private var _playerAvatarView2:AvatarView;
      
      private var _bInit:Boolean;
      
      private var _playerLeft:Boolean;
      
      private var _gameState:int;
      
      private var _serverStarted:Boolean;
      
      public var _readyLevelDisplayTimer:Number;
      
      public var _readyLevelDisplay:Object;
      
      public var _timeOutTimer:Number;
      
      private var _currentPopup:MovieClip;
      
      private var _currentConeIndex:Array = [0,0];
      
      private var _cones:Array = [];
      
      private var _conesComplete:Array = [0,0];
      
      private var _queueComplete:Array = [0,0];
      
      private var _queueFail:Array = [0,0];
      
      private var _queueNextScoopSound:Array = [0,0];
      
      private var _queueNewConeSounds:int = 0;
      
      private var _newConeSoundIndex:int = 0;
      
      private var _newConeScoopSoundIndex:int = 0;
      
      private var _currentConeScoopSoundIndex:Array = [0,0];
      
      private var _iWon:Boolean;
      
      private var _tie:Boolean;
      
      private var _roundCompleteTimer:Number;
      
      private var _theGame:MovieClip;
      
      private var _iLost:Boolean;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var _audio:Array = ["aj_SC_fail.mp3","aj_SC_GetReadyEnter.mp3","aj_SC_GetReadyExit.mp3","aj_SC_IceCream1.mp3","aj_SC_IceCream2.mp3","aj_SC_IceCream3.mp3","aj_SC_IceCream4.mp3","aj_SC_IceCream5.mp3","aj_SC_IceCream6.mp3","aj_SC_popupDelciousExit.mp3","aj_SC_popupDeliciousEnter.mp3","aj_SC_popupYouEnter.mp3","aj_SC_popupYouExit.mp3","aj_SC_pourChipsL.mp3","aj_SC_pourChipsM.mp3","aj_SC_PourLiquidL.mp3","aj_SC_PourLiquidM.mp3","aj_SC_pourSprinklesL.mp3","aj_SC_pourSprinklesM.mp3","aj_SC_splatstinger1.mp3","aj_SC_splatstinger2.mp3","aj_SC_splatstinger3.mp3","aj_SC_splatstinger4.mp3","aj_SC_splatstinger5.mp3","aj_SC_splatstinger6.mp3","aj_SC_topping_select.mp3","micro_game_rollover.mp3","pvp_stinger_draw.mp3","pvp_stinger_fail.mp3","pvp_stinger_win.mp3"];
      
      private var _soundNameFail:String = _audio[0];
      
      private var _soundNameGetReadyEnter:String = _audio[1];
      
      private var _soundNameGetReadyExit:String = _audio[2];
      
      private var _soundNameIceCream1:String = _audio[3];
      
      private var _soundNameIceCream2:String = _audio[4];
      
      private var _soundNameIceCream3:String = _audio[5];
      
      private var _soundNameIceCream4:String = _audio[6];
      
      private var _soundNameIceCream5:String = _audio[7];
      
      private var _soundNameIceCream6:String = _audio[8];
      
      private var _soundNameDeliciousExit:String = _audio[9];
      
      private var _soundNameDeliciousEnter:String = _audio[10];
      
      private var _soundNameYouEnter:String = _audio[11];
      
      private var _soundNameYouExit:String = _audio[12];
      
      private var _soundNamePourChipsL:String = _audio[13];
      
      private var _soundNamePourChipsM:String = _audio[14];
      
      private var _soundNamePourLiquidL:String = _audio[15];
      
      private var _soundNamePourLiquidM:String = _audio[16];
      
      private var _soundNamePourSprinklesL:String = _audio[17];
      
      private var _soundNamePourSprinklesM:String = _audio[18];
      
      private var _soundNameSplatStinger1:String = _audio[19];
      
      private var _soundNameSplatStinger2:String = _audio[20];
      
      private var _soundNameSplatStinger3:String = _audio[21];
      
      private var _soundNameSplatStinger4:String = _audio[22];
      
      private var _soundNameSplatStinger5:String = _audio[23];
      
      private var _soundNameSplatStinger6:String = _audio[24];
      
      private var _soundNameToppingSelect:String = _audio[25];
      
      private var _soundNameRollover:String = _audio[26];
      
      private var _soundNameStingerDraw:String = _audio[27];
      
      private var _soundNameStingerFail:String = _audio[28];
      
      private var _soundNameStingerWin:String = _audio[29];
      
      public function PVP_Scooped()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         trace("myID: " + myId);
         init();
      }
      
      private function init() : void
      {
         _lastTime = getTimer();
         if(!_bInit)
         {
            _background = new Sprite();
            _foreground = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_foreground);
            addChild(_layerPopups);
            addChild(_guiLayer);
            loadScene("PVP_Scooped/main_room.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameFail],_soundNameFail,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameGetReadyEnter],_soundNameGetReadyEnter,1.5);
         _soundMan.addSoundByName(_audioByName[_soundNameGetReadyExit],_soundNameGetReadyExit,1.5);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream1],_soundNameIceCream1,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream2],_soundNameIceCream2,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream3],_soundNameIceCream3,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream4],_soundNameIceCream4,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream5],_soundNameIceCream5,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameIceCream6],_soundNameIceCream6,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameDeliciousExit],_soundNameDeliciousExit,0.66);
         _soundMan.addSoundByName(_audioByName[_soundNameDeliciousEnter],_soundNameDeliciousEnter,0.66);
         _soundMan.addSoundByName(_audioByName[_soundNameYouEnter],_soundNameYouEnter,0.66);
         _soundMan.addSoundByName(_audioByName[_soundNameYouExit],_soundNameYouExit,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePourChipsL],_soundNamePourChipsL,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNamePourChipsM],_soundNamePourChipsM,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNamePourLiquidL],_soundNamePourLiquidL,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNamePourLiquidM],_soundNamePourLiquidM,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNamePourSprinklesL],_soundNamePourSprinklesL,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNamePourSprinklesM],_soundNamePourSprinklesM,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger1],_soundNameSplatStinger1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger2],_soundNameSplatStinger2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger3],_soundNameSplatStinger3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger4],_soundNameSplatStinger4,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger5],_soundNameSplatStinger5,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSplatStinger6],_soundNameSplatStinger6,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameToppingSelect],_soundNameToppingSelect,1);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerDraw],_soundNameStingerDraw,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerWin],_soundNameStingerWin,0.45);
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1[0] == "ml")
         {
            _playerLeft = true;
            if(_gameState <= 3)
            {
               end(null);
            }
            else if(!_iLost)
            {
               setGameState(6);
            }
         }
         else if(param1[0] == "ms")
         {
            _serverStarted = true;
            _userNames = [];
            _dbIDs = [];
            _loc2_ = 1;
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _dbIDs[_loc3_] = param1[_loc2_++];
               _userNames[_loc3_] = param1[_loc2_++];
               _loc3_++;
            }
            generateRandomCones(parseInt(param1[_loc3_ + 1]));
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "start")
            {
               setGameState(10);
            }
            else if(param1[2] == "sc_click")
            {
               doNextScoopOrTopping(1,param1[3]);
            }
            else if(param1[2] == "sc_done")
            {
               _iLost = _pIDs[parseInt(param1[3])] != myId;
               setGameState(6);
            }
         }
      }
      
      public function generateRandomCones(param1:int) : void
      {
         var _loc4_:RandomSeed = new RandomSeed(param1);
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = [1,2,3,4,5,6];
         _cones[_loc5_] = [];
         _cones[_loc5_][0] = Math.floor(_loc4_.random() * 6) + 1;
         _loc5_++;
         _cones[_loc5_] = [];
         _cones[_loc5_][0] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][1] = Math.floor(_loc4_.random() * 6) + 1;
         _loc5_++;
         _cones[_loc5_] = [];
         _cones[_loc5_][0] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][1] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][2] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][3] = Math.floor(_loc4_.random() * 3) + 7;
         _loc5_++;
         _cones[_loc5_] = [];
         _loc2_ = shuffle(_loc2_,_loc4_);
         _cones[_loc5_][0] = _loc2_[0];
         _cones[_loc5_][1] = _loc2_[1];
         _cones[_loc5_][2] = _loc2_[2];
         _cones[_loc5_][3] = _loc2_[3];
         _loc3_ = Math.floor(_loc4_.random() * 3);
         _cones[_loc5_][_loc3_] = _cones[_loc5_][_loc3_ + 1];
         _cones[_loc5_][4] = Math.floor(_loc4_.random() * 3) + 7;
         _loc5_++;
         _cones[_loc5_] = [];
         _cones[_loc5_][0] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][1] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][2] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][3] = Math.floor(_loc4_.random() * 6) + 1;
         _cones[_loc5_][4] = Math.floor(_loc4_.random() * 6) + 1;
         _loc3_ = Math.floor(_loc4_.random() * 4);
         _cones[_loc5_][_loc3_] = _cones[_loc5_][_loc3_ + 1];
         _cones[_loc5_].splice(Math.floor(_loc4_.random() * 4) + 1,0,Math.floor(_loc4_.random() * 3) + 7);
         _cones[_loc5_][6] = Math.floor(_loc4_.random() * 3) + 7;
         _loc5_++;
      }
      
      private function shuffle(param1:Array, param2:RandomSeed) : Array
      {
         var _loc3_:Array = [];
         while(param1.length > 0)
         {
            _loc3_.push(param1.splice(Math.round(param2.random() * (param1.length - 1)),1)[0]);
         }
         return _loc3_;
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
               if(_theGame.portrait1 != null)
               {
                  _theGame.portrait1.portraitContainer.addChild(_playerAvatarView1);
                  _theGame.portrait2.portraitContainer.addChild(_playerAvatarView2);
               }
               showHowToPlay();
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:Array = null;
         if(_gameState != 6 && _gameState != param1)
         {
            if(_readyLevelDisplay && _readyLevelDisplay.loader && _readyLevelDisplay.loader.parent)
            {
               _readyLevelDisplay.loader.parent.removeChild(_readyLevelDisplay.loader);
               _readyLevelDisplay = null;
            }
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
                  showWaitingForPlayer();
                  break;
               case 3:
                  newCone();
                  break;
               case 4:
                  _loc2_ = [];
                  _loc2_[0] = "sc_done";
                  MinigameManager.msg(_loc2_);
                  break;
               case 5:
                  _iWon = (_conesComplete[0] >= _cones.length || _playerLeft) && !_iLost;
                  _readyLevelDisplay = GETDEFINITIONBYNAME("Scooped_gameEnd");
                  _layerPopups.addChild(_readyLevelDisplay as DisplayObject);
                  _readyLevelDisplay.x = 450;
                  _readyLevelDisplay.y = 275;
                  if(_iWon)
                  {
                     _readyLevelDisplay.setWin();
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(87,1);
                     }
                     _soundMan.playByName(_soundNameStingerWin);
                     addGemsToBalance(20);
                     _roundCompleteTimer = 5;
                     break;
                  }
                  if(_playerLeft || _iLost && _conesComplete[0] >= _cones.length)
                  {
                     MinigameManager._pvpPromptReplay = true;
                     addGemsToBalance(5);
                     _readyLevelDisplay.setLose();
                     _soundMan.playByName(_soundNameStingerFail);
                     _roundCompleteTimer = 5;
                     break;
                  }
                  _iLost = true;
                  _gameState = 4;
                  break;
               case 7:
                  hideDlg();
                  break;
               case 8:
                  _timeOutTimer = 10;
                  break;
               case 9:
                  hideDlg();
                  _soundMan.playByName(_soundNameYouEnter);
                  _soundMan.playByName(_soundNameGetReadyEnter);
                  _theGame.you();
                  _theGame.getReady();
                  _timeOutTimer = 1;
            }
         }
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function showWaitingForPlayer() : void
      {
         var _loc1_:MovieClip = showDlg("Scooped_Waiting",[]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function exit() : void
      {
         if(_totalGameTime > 5 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(86,1);
         }
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",onHowToPlayKeyDown);
         removeEventListener("enterFrame",Heartbeat);
         removeLayer(_background);
         removeLayer(_foreground);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _background = null;
         _foreground = null;
         _layerPopups = null;
         _guiLayer = null;
         MinigameManager.leave();
         _bInit = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         _soundMan = new SoundManager(this);
         loadSounds();
         _theGame = _scene.getLayer("scooped").loader.content;
         _background.addChild(_scene.getLayer("scooped").loader);
         addEventListener("enterFrame",Heartbeat);
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         var _loc2_:MovieClip = _theGame;
         _loc3_ = 0;
         while(_loc3_ < 6)
         {
            _loc2_["flav" + _loc3_].addEventListener("mouseOver",mouseOverHandler,false,0,true);
            _loc2_["flav" + _loc3_].addEventListener("mouseOut",mouseOutHandler,false,0,true);
            _loc2_["flav" + _loc3_].addEventListener("mouseUp",mouseClick,false,0,true);
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < 3)
         {
            _loc2_["top" + _loc3_].addEventListener("mouseOver",mouseOverHandler,false,0,true);
            _loc2_["top" + _loc3_].addEventListener("mouseOut",mouseOutHandler,false,0,true);
            _loc2_["top" + _loc3_].addEventListener("mouseUp",mouseClick,false,0,true);
            _loc3_++;
         }
         _playerLeft = false;
         if(_dbIDs.length > 1)
         {
            if(_pIDs[0] == myId)
            {
               _theGame.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
               _theGame.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
            }
            else
            {
               _theGame.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
               _theGame.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
            }
         }
         _totalGameTime = 0;
         super.sceneLoaded(param1);
         if(MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      private function newCone() : void
      {
         _theGame.modelCone(_cones[_conesComplete[0]]);
         _queueNewConeSounds = -4;
         _newConeSoundIndex = 0;
         _newConeScoopSoundIndex = 0;
      }
      
      private function fail(param1:int) : void
      {
         _theGame.fail(param1 + 1);
         _currentConeIndex[param1] = 0;
         _soundMan.playByName(_soundNameFail);
      }
      
      private function scoopComplete(param1:int) : void
      {
         _conesComplete[param1]++;
         _theGame["p" + (param1 + 1) + "_score"]["score" + _conesComplete[param1]].gotoAndStop(2);
         _currentConeIndex[param1] = 0;
         _theGame.coneComplete(param1 + 1);
         _soundMan.playByName(_soundNameDeliciousEnter);
         if(_conesComplete[param1] >= _cones.length)
         {
            if(param1 == 0)
            {
               if(_iLost)
               {
                  setGameState(6);
               }
               else
               {
                  setGameState(5);
               }
            }
         }
         else if(param1 == 0)
         {
            newCone();
         }
      }
      
      private function doNextScoopOrTopping(param1:int, param2:String, param3:Boolean = false) : void
      {
         var _loc4_:MovieClip = _theGame;
         var _loc5_:int = int(param2.charAt(param2.length - 1)) + 1;
         param2.charAt(0) == "f" ? _loc4_.dropNext(param1 + 1,_loc5_) : _loc4_.topping(param1 + 1,_loc5_);
         if(param3)
         {
            playNextScoopSound(param1,param2);
         }
         if(_cones[_conesComplete[param1]][_currentConeIndex[param1]++] != _loc5_ + (param2.charAt(0) == "f" ? 0 : 6))
         {
            _queueFail[param1] = 0.4;
            _currentConeScoopSoundIndex[param1] = 0;
         }
         else if(_currentConeIndex[param1] == _cones[_conesComplete[param1]].length)
         {
            _queueComplete[param1] = 0.4;
            _currentConeScoopSoundIndex[param1] = 0;
         }
      }
      
      private function mouseClick(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         if(!_queueFail[0] && !_queueComplete[0] && _gameState == 4)
         {
            _loc2_ = int(_currentConeIndex[0]);
            doNextScoopOrTopping(0,param1.currentTarget.name,true);
            if(_loc2_ != 0 || _queueFail[0] == 0)
            {
               _loc3_ = [];
               _loc3_[0] = "sc_click";
               _loc3_[1] = param1.currentTarget.name;
               MinigameManager.msg(_loc3_);
            }
         }
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop(2);
         _soundMan.playByName(_soundNameRollover);
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.gotoAndStop(1);
      }
      
      private function playNewConeSound() : void
      {
         switch(_cones[_conesComplete[0]][_newConeSoundIndex++])
         {
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
            case 6:
               _soundMan.playByName(this["_soundNameSplatStinger" + ++_newConeScoopSoundIndex]);
               break;
            case 7:
               _soundMan.playByName(_soundNamePourLiquidM);
               break;
            case 8:
               _soundMan.playByName(_soundNamePourChipsM);
               break;
            case 9:
               _soundMan.playByName(_soundNamePourSprinklesM);
         }
         trace("sound:play " + _newConeScoopSoundIndex);
      }
      
      private function playNextScoopSound(param1:int, param2:String) : void
      {
         if(param2.charAt(0) == "f")
         {
            _soundMan.playByName(this["_soundNameIceCream" + ++_currentConeScoopSoundIndex[param1]]);
         }
         else
         {
            switch(param2.charAt(param2.length - 1))
            {
               case "0":
                  _soundMan.playByName(_soundNamePourLiquidL);
                  break;
               case "1":
                  _soundMan.playByName(_soundNamePourChipsL);
                  break;
               case "2":
                  _soundMan.playByName(_soundNamePourSprinklesL);
            }
         }
      }
      
      private function Heartbeat(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Number = (getTimer() - _lastTime) / 1000;
         _lastTime = getTimer();
         if(!_serverStarted)
         {
            return;
         }
         if(_gameState == 8)
         {
            if(_readyLevelDisplay && _readyLevelDisplay.loader.content.finished)
            {
               setGameState(4);
            }
         }
         if(_gameState == 9)
         {
            _timeOutTimer -= _loc3_;
            _currentPopup.timer.text = Math.ceil(_timeOutTimer).toString();
            if(_timeOutTimer <= 0)
            {
               sendReady();
            }
         }
         if(_gameState == 10)
         {
            if(_timeOutTimer > 0)
            {
               _timeOutTimer -= _loc3_;
               if(_timeOutTimer <= 0)
               {
                  _soundMan.playByName(_soundNameYouExit);
                  _soundMan.playByName(_soundNameGetReadyExit);
                  _theGame.readyOff();
                  setGameState(4);
               }
            }
            if(_queueNewConeSounds < 0)
            {
               _queueNewConeSounds++;
               if(_queueNewConeSounds == 0)
               {
                  _queueNewConeSounds = 2 * _cones[_conesComplete[0]].length;
               }
            }
            if(_queueNewConeSounds > 0)
            {
               if(_queueNewConeSounds % 2 == 0)
               {
                  playNewConeSound();
               }
               _queueNewConeSounds--;
            }
         }
         if(_gameState == 4)
         {
            if(_theGame.coneCompleted1.turnOff)
            {
               _theGame.coneCompleted1.turnOff = false;
               _soundMan.playByName(_soundNameDeliciousExit);
            }
            if(_theGame.coneCompleted2.turnOff)
            {
               _theGame.coneCompleted2.turnOff = false;
               _soundMan.playByName(_soundNameDeliciousExit);
            }
            if(_queueFail[0] > 0)
            {
               var _loc6_:* = 0;
               var _loc7_:* = _queueFail[_loc6_] - _loc3_;
               _queueFail[_loc6_] = _loc7_;
               if(_queueFail[0] <= 0)
               {
                  _queueFail[0] = 0;
                  fail(0);
               }
            }
            if(_queueComplete[0] > 0)
            {
               _loc7_ = 0;
               _loc6_ = _queueComplete[_loc7_] - _loc3_;
               _queueComplete[_loc7_] = _loc6_;
               if(_queueComplete[0] <= 0)
               {
                  _queueComplete[0] = 0;
                  scoopComplete(0);
               }
            }
            if(_queueFail[1] > 0)
            {
               _loc6_ = 1;
               _loc7_ = _queueFail[_loc6_] - _loc3_;
               _queueFail[_loc6_] = _loc7_;
               if(_queueFail[1] <= 0)
               {
                  _queueFail[1] = 0;
                  fail(1);
               }
            }
            if(_queueComplete[1] > 0)
            {
               _loc7_ = 1;
               _loc6_ = _queueComplete[_loc7_] - _loc3_;
               _queueComplete[_loc7_] = _loc6_;
               if(_queueComplete[1] <= 0)
               {
                  _queueComplete[1] = 0;
                  scoopComplete(1);
               }
            }
         }
         else if(_gameState == 6)
         {
            if(_roundCompleteTimer > 0)
            {
               _roundCompleteTimer -= _loc3_;
               if(_roundCompleteTimer <= 0)
               {
                  exit();
               }
               else if(_roundCompleteTimer <= 2 && _roundCompleteTimer + _loc3_ > 2)
               {
                  if(_tie)
                  {
                     _loc2_ = showDlg("Scooped_tie",[]);
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                  }
                  else if(_iWon)
                  {
                     _loc2_ = showDlg("Scooped_win",[]);
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                  }
                  else
                  {
                     _loc2_ = showDlg("Scooped_win",[]);
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                     LocalizationManager.translateIdAndInsert(_loc2_.gemsEarned,11577,5);
                  }
               }
            }
         }
         _totalGameTime += _loc3_;
      }
      
      public function sendReady() : void
      {
         var _loc1_:Array = null;
         stage.removeEventListener("keyDown",onHowToPlayKeyDown);
         hideDlg();
         _timeOutTimer = 0;
         _loc1_ = [];
         _loc1_[0] = "ready";
         MinigameManager.msg(_loc1_);
         setGameState(3);
      }
      
      private function onHowToPlayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               sendReady();
               break;
            case 8:
            case 46:
            case 27:
               sendReady();
         }
      }
      
      private function showHowToPlay() : void
      {
         _currentPopup = showDlg("Scooped_HowToPlay",[{
            "name":"doneButton",
            "f":sendReady
         },{
            "name":"x_btn",
            "f":sendReady
         }]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         stage.addEventListener("keyDown",onHowToPlayKeyDown);
         setGameState(9);
      }
      
      private function showExitConfirmationDlg() : void
      {
         exit();
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         exit();
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
   }
}

