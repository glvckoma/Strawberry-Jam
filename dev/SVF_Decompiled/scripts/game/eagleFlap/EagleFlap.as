package game.eagleFlap
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.AvatarInfo;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.DisplayObject;
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
   
   public class EagleFlap extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_WAITINGFORPOPUP:int = 1;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _timeOutTimer:Number;
      
      private var _currentPopup:MovieClip;
      
      private var _score:int;
      
      private var _scoreThisLevel:int;
      
      private var _scorePopup:MovieClip;
      
      private var _scoreMultiplier:int = 1;
      
      private var _gameOver:Boolean;
      
      private var _highScore:int;
      
      public var _player:Object = {};
      
      public var _bgContent:Object;
      
      private var _gemsEarned:int;
      
      private var _gemsAwarded:int;
      
      private var _displayAchievementTimer:Number = 0;
      
      private var _gameOverPopup:MovieClip;
      
      private var _popupDismissed:Boolean;
      
      private var _exitDismissed:Boolean;
      
      private var _audio:Array = ["aj_eagleFail.mp3","aj_eagleIntro.mp3","aj_eagleFlap.mp3","aj_eagleImp.mp3"];
      
      internal var _soundNameEagleFail:String = _audio[0];
      
      internal var _soundNameEagleIntro:String = _audio[1];
      
      internal var _soundNameEagleFlap:String = _audio[2];
      
      internal var _soundNameEagleImp:String = _audio[3];
      
      public var _soundMan:SoundManager;
      
      private var _SFX_Music:SBMusic;
      
      private var _introSC:SoundChannel;
      
      private var _failSC:SoundChannel;
      
      private var _musicSC:SoundChannel;
      
      public function EagleFlap()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_musEagleLP",0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameEagleFail],_soundNameEagleFail,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameEagleIntro],_soundNameEagleIntro,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameEagleFlap],_soundNameEagleFlap,0.17);
         _soundMan.addSoundByName(_audioByName[_soundNameEagleImp],_soundNameEagleImp,0.67);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] == "ms")
         {
            _serverStarted = true;
            _dbIDs = [];
            _loc2_ = 0;
            while(_loc2_ < _pIDs.length)
            {
               _dbIDs[_loc2_] = param1[_loc2_ + 1];
               _loc2_++;
            }
         }
      }
      
      private function doGameOver() : void
      {
         setGameState(6);
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15)
         {
         }
         if(_introSC)
         {
            _introSC.stop();
            _introSC = null;
         }
         if(_failSC)
         {
            _failSC.stop();
            _failSC = null;
         }
         if(_musicSC)
         {
            _musicSC.stop();
            _musicSC = null;
         }
         hideDlg();
         releaseBase();
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
         stage.removeEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _layerMain = null;
         _layerPopups = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_layerPopups);
            addChild(_guiLayer);
            loadScene("EagleFlapAssets/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc2_:Array = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _bgContent = _scene.getLayer("bg").loader;
         _bgContent = _bgContent.content;
         _layerMain.addChild(_bgContent as DisplayObject);
         stage.addEventListener("enterFrame",heartbeat);
         stage.addEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
         stage.addEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
         _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(376),0);
         _bgContent.hiScoreText.pointsText.text = _highScore;
         var _loc4_:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         if(_loc4_.type == 2)
         {
            _loc2_ = _loc4_.colors;
         }
         else
         {
            _loc2_ = [3228143359,0,16728063];
         }
         var _loc5_:Array = PaletteHelper.getRGBColors(_loc2_[0]);
         _bgContent.eagleColor1RGB(_loc5_[0].r,_loc5_[0].g,_loc5_[0].b);
         _bgContent.eagleColor2RGB(_loc5_[1].r,_loc5_[1].g,_loc5_[1].b);
         _bgContent.eagleColor3RGB(_loc5_[2].r,_loc5_[2].g,_loc5_[2].b);
         _popupDismissed = false;
         _sceneLoaded = true;
         super.sceneLoaded(param1);
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onRetry();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function showGameOver() : void
      {
         var _loc1_:MovieClip = null;
         stage.addEventListener("keyDown",replayKeyDown);
         if(_bgContent.points > 0)
         {
            _loc1_ = showDlg("EagleFlap_Great_Job",[{
               "name":"button_nextlevel",
               "f":onRetry
            },{
               "name":"button_no",
               "f":onExit_Yes
            }]);
         }
         else
         {
            _loc1_ = showDlg("EagleFlap_Try_Again",[{
               "name":"button_yes",
               "f":onRetry
            },{
               "name":"button_no",
               "f":onExit_Yes
            }]);
         }
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.removeEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
         stage.removeEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
         _loc1_.addEventListener("keyDown",spacePressed);
         stage.stageFocusRect = false;
         _gameOverPopup = _loc1_;
         stage.focus = _loc1_;
         if(_bgContent.points >= _highScore)
         {
            _highScore = _bgContent.points;
            _bgContent.hiScoreText.pointsText.text = _highScore;
            AchievementXtCommManager.requestSetUserVar(376,_highScore);
         }
         if(_bgContent.points > 0)
         {
            _gemsEarned = _bgContent.points * 5;
            LocalizationManager.translateIdAndInsert(_loc1_.points,15787,_bgContent.points);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,15788,_bgContent.points);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Total,15789,_gemsEarned);
            AchievementXtCommManager.requestSetUserVar(377,_bgContent.points);
            if(_gemsEarned > 0)
            {
               addGemsToBalance(_gemsEarned);
            }
         }
         AchievementXtCommManager.requestSetUserVar(378,1);
         AchievementManager.displayNewAchievements();
      }
      
      private function spacePressed(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 32)
         {
            onRetry();
         }
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
         _bgContent.xPause = true;
         stage.removeEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
         stage.removeEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
      }
      
      private function showNextLevel() : void
      {
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         _popupDismissed = true;
         if(_failSC)
         {
            _failSC.stop();
            _failSC = null;
         }
         _gameOverPopup.removeEventListener("keyDown",spacePressed);
         stage.addEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
         stage.addEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
         stage.focus = _bgContent as MovieClip;
      }
      
      private function onExit_Yes() : void
      {
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
         _exitDismissed = true;
      }
      
      public function setGameState(param1:int) : void
      {
         if(_gameState != param1)
         {
            switch(param1 - 1)
            {
               case 0:
                  break;
               case 3:
                  hideDlg();
                  _gameOver = false;
                  break;
               case 5:
                  showGameOver();
                  _gameOver = true;
            }
            _gameState = param1;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
            if(_serverStarted && !_pauseGame)
            {
               _frameTime = (getTimer() - _lastTime) / 1000;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
               _gameTime += _frameTime;
               if(_bgContent.highScore > _highScore)
               {
                  _highScore = _bgContent.points;
                  _bgContent.hiScoreText.pointsText.text = _highScore;
               }
               if(_bgContent.playFlap)
               {
                  _soundMan.playByName(_soundNameEagleFlap);
                  _bgContent.playFlap = false;
               }
               if(_bgContent.playImpact)
               {
                  _soundMan.playByName(_soundNameEagleImp);
                  _bgContent.playImpact = false;
               }
               if(_exitDismissed)
               {
                  _bgContent.xPause = false;
                  stage.addEventListener("keyDown",_bgContent.fl_KeyboardDownHandler);
                  stage.addEventListener("mouseDown",_bgContent.fl_MouseClickHandler);
               }
               if(_popupDismissed)
               {
                  _bgContent.reset();
                  _popupDismissed = false;
               }
               if(_bgContent.clickToStart.visible)
               {
                  if(_introSC == null)
                  {
                     if(_failSC)
                     {
                        _failSC.stop();
                        _failSC = null;
                     }
                     _introSC = _soundMan.playByName(_soundNameEagleIntro);
                  }
               }
               else if(!_bgContent.dead)
               {
                  if(_introSC)
                  {
                     _introSC.stop();
                     _introSC = null;
                  }
                  if(_musicSC == null)
                  {
                     _musicSC = _soundMan.playStream(_SFX_Music,0,999999);
                  }
               }
               else if(_failSC == null)
               {
                  if(_musicSC)
                  {
                     _musicSC.stop();
                     _musicSC = null;
                  }
                  _failSC = _soundMan.playByName(_soundNameEagleFail);
               }
               if(_bgContent.eagleOut)
               {
                  showGameOver();
               }
            }
         }
      }
   }
}

