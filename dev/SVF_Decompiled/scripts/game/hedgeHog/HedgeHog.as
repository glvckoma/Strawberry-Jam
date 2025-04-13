package game.hedgeHog
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class HedgeHog extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_WAITINGFORPOPUP:int = 1;
      
      public static const GAMESTATE_DEATHANIM:int = 2;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      private static const RIGHT:int = 0;
      
      private static const UP:int = 1;
      
      private static const LEFT:int = 2;
      
      private static const DOWN:int = 3;
      
      public static const TYPE_NONE:int = 0;
      
      public static const TYPE_PELLET:int = 1;
      
      public static const TYPE_ENERGIZER:int = 2;
      
      public static const TYPE_SPAWN:int = 3;
      
      public static const TYPE_START:int = 4;
      
      public static const TYPE_BONUS:int = 5;
      
      private static const ENERGIZER_TIME:int = 9;
      
      private static const THRESHOLD:int = 2;
      
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
      
      private var _moveSpeed:Number = 135;
      
      public var _phantomBaseSpeed:Number = 43;
      
      private var _pellets:Array = [];
      
      private var _numPellets:int;
      
      private var _energizers:Array = [];
      
      public var _offsetX:Number = 17;
      
      public var _offsetY:Number = 80;
      
      public var _gridX:Number = 36;
      
      public var _gridY:Number = 37.8;
      
      private var _inputStack:Array = [];
      
      public var _enemies:Array = [];
      
      public var _bonusObject:Object;
      
      public var _bonusTimer:Number;
      
      public var _energizerTimer:Number = 0;
      
      public var _numConsecPhantoms:int = 1;
      
      private var _tutorialShown:int = 0;
      
      private var _inputOverride:int = -1;
      
      public var _phantomModeSwitchTime:int = 10;
      
      public var _phantomRespawnTime:int = 5;
      
      private var _phantomSpawnIndex:int = 0;
      
      private var _gemsEarned:int;
      
      private var _gemsAwarded:int;
      
      private var _displayAchievementTimer:Number = 0;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _factImageMediaObject:MovieClip;
      
      public var _powerUpWarningTime:int = 2;
      
      private var _lives:int;
      
      public var _currentLevelIndex:int;
      
      private var _extraLifeScoreThresholds:Array = [50000,100000,250000,500000,250000];
      
      private var _extraLifeIndex:int;
      
      private var _nextExtraLife:int;
      
      private var _phantomSpeedRampup:Array = [0.52,0.58,0.62,0.643,0.679,0.029];
      
      public var _numPhantoms:Array = [5,5,5,5,5];
      
      public var _bonusItemIndices:Array;
      
      public var _currentBonusItemIndex:int = 0;
      
      private var _bonusItemsCollected:int;
      
      public var _phantomSpawnIndices:Array;
      
      private var _facts:Array = [{
         "imageID":1698,
         "text":11587
      },{
         "imageID":1699,
         "text":11588
      },{
         "imageID":1700,
         "text":11589
      },{
         "imageID":1701,
         "text":11590
      },{
         "imageID":1702,
         "text":11591
      },{
         "imageID":1703,
         "text":11592
      },{
         "imageID":1704,
         "text":11593
      },{
         "imageID":1705,
         "text":11594
      },{
         "imageID":1706,
         "text":11595
      },{
         "imageID":1707,
         "text":11596
      },{
         "imageID":1708,
         "text":11597
      },{
         "imageID":1709,
         "text":11598
      },{
         "imageID":1710,
         "text":11599
      },{
         "imageID":1711,
         "text":11600
      },{
         "imageID":1712,
         "text":11601
      }];
      
      public var _levels:Array = [[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,1,3,1,2,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,2,1,3,1,0],[0,1,0,1,0,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0],[0,1,0,1,1,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,1,1,0,1,0],[0,1,0,0,1,0,0,1,0,0,1,1,5,1,1,0,0,1,0,0,1,0,0,1,0],[0,1,0,0,1,0,1,5,1,0,0,1,0,1,0,0,1,5,1,0,1,0,0,1,0],[1,1,5,1,1,1,1,0,1,1,1,1,0,1,1,1,1,0,1,1,1,1,5,1,1],[0,1,0,0,1,0,1,5,1,0,0,1,0,1,0,0,1,5,1,0,1,0,0,1,0],[0,1,0,0,1,0,0,1,0,0,1,1,4,1,1,0,0,1,0,0,1,0,0,1,0],[0,1,0,1,1,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,1,1,0,1,0],[0,1,0,1,0,1,0,1,0,0,1,0,5,0,1,0,0,1,0,1,0,1,0,1,0],[0,1,3,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,3,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,1,1,3,1,1,1,1,0,1,1,1,2,1,1,1,0,1,1,1,1,3,1,1,0],[1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1],[0,1,5,1,1,1,1,1,0,1,1,1,3,1,1,1,0,1,1,1,1,1,5,1,0],[0,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,1,0,0],[0,0,1,0,0,1,0,1,1,1,5,1,1,1,5,1,1
      ,1,0,1,0,0,1,0,0],[0,0,2,1,1,1,1,1,0,0,1,0,1,0,1,0,0,1,1,1,1,1,2,0,0],[0,0,1,0,0,1,0,1,1,1,5,1,4,1,5,1,1,1,0,1,0,0,1,0,0],[0,0,1,0,0,1,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,1,0,0],[0,1,5,1,1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1,1,5,1,0],[1,1,0,0,0,0,0,1,1,1,0,0,1,0,0,1,1,1,0,0,0,0,0,1,1],[0,1,1,3,1,1,1,1,0,1,1,1,2,1,1,1,0,1,1,1,1,3,1,1,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],[[0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0],[0,3,1,1,1,5,1,1,1,0,1,1,1,1,1,0,1,1,1,5,1,1,1,3,0],[0,1,0,0,0,1,0,0,1,1,5,0,1,0,5,1,1,0,0,1,0,0,0,1,0],[0,1,1,1,1,1,0,0,1,0,1,0,1,0,1,0,1,0,0,1,1,1,1,1,0],[0,1,0,0,0,1,1,1,2,1,1,0,3,0,1,1,2,1,1,1,0,0,0,1,0],[0,1,1,1,0,1,0,0,0,0,1,1,1,1,1,0,0,0,0,1,0,1,1,1,0],[0,1,0,1,1,1,1,1,1,1,1,0,1,0,1,1,1,1,1,1,1,1,0,1,0],[0,1,1,1,0,1,0,0,0,0,1,0,1,0,1,0,0,0,0,1,0,1,1,1,0],[0,1,0,0,0,1,1,1,2,1,1,1,4,1,1,1,2,1,1,1,0,0,0,1,0],[0,1,1,1,1,1,0,0,1,0,1,0,1,0,1,0,1,0,0,1,1,1,1,1,0],[0,1,0,0,0,1,0,0,1,1,5,0,1,0,5,1,1,0,0,1,0,0,0,1,0],[0,3,1,1,1,5,1,1,1,0,1,1,1,1,1,0,1,1,1,5,1,1,1
      ,3,0],[0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0]],[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,0,0,2,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,2,0,0,0],[0,1,1,1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,1,1,1,0],[1,1,0,1,0,1,0,0,1,0,0,1,3,1,0,0,1,0,0,1,0,1,0,1,1],[0,1,0,1,1,1,1,5,1,1,1,1,0,1,1,1,1,5,1,1,1,1,0,1,0],[0,1,0,0,0,0,0,1,0,1,0,1,1,1,0,1,0,1,0,0,0,0,0,1,0],[0,5,1,1,1,5,1,1,0,1,0,0,1,0,0,1,0,1,1,5,1,1,1,5,0],[0,1,0,0,0,0,0,1,0,1,0,1,1,1,0,1,0,1,0,0,0,0,0,1,0],[0,1,0,1,1,1,1,5,1,1,1,1,0,1,1,1,1,5,1,1,1,1,0,1,0],[1,1,0,1,0,1,0,0,1,0,0,1,4,1,0,0,1,0,0,1,0,1,0,1,1],[0,1,1,1,0,1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0,1,1,1,0],[0,0,0,2,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,2,0,0,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],[[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],[0,2,1,1,0,0,0,0,0,0,0,1,5,1,0,0,0,0,0,0,0,1,1,2,0],[0,1,0,1,1,3,1,1,1,1,1,1,0,1,1,1,1,1,1,3,1,1,0,1,0],[0,1,1,1,0,1,0,0,0,1,0,1,3,1,0,1,0,0,0,1,0,1,1,1,0],[0,0,5,0,0,1,1,1,1,1,0,0,1,0,0,1,1,1,1,1,0,0,5,0,0],[0,1
      ,1,1,0,1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,0,1,1,1,0],[0,1,0,1,1,1,1,1,1,5,1,1,0,1,1,5,1,1,1,1,1,1,0,1,0],[0,1,1,1,0,1,0,0,0,1,0,1,4,1,0,1,0,0,0,1,0,1,1,1,0],[0,0,5,0,0,1,1,1,1,1,0,0,1,0,0,1,1,1,1,1,0,0,5,0,0],[0,1,1,1,0,1,0,0,0,1,0,1,1,1,0,1,0,0,0,1,0,1,1,1,0],[0,1,0,1,1,3,1,1,1,1,1,1,0,1,1,1,1,1,1,3,1,1,0,1,0],[0,2,1,1,0,0,0,0,0,0,0,1,5,1,0,0,0,0,0,0,0,1,1,2,0],[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]]];
      
      private var _rightArrow:Boolean;
      
      private var _leftArrow:Boolean;
      
      private var _upArrow:Boolean;
      
      private var _downArrow:Boolean;
      
      private var _currentDirection:int;
      
      private var _audio:Array = ["aj_hh_itemCrystal.mp3","aj_hh_pellet.mp3","aj_hh_phantomSpawn1.mp3","aj_hh_phantomSpawn2.mp3","aj_hh_phantomSpawn3.mp3","aj_hh_phantomDeath.mp3","aj_hh_phantomDeath1.mp3","aj_hh_phantomDeath2.mp3","aj_hh_gem.mp3","aj_hh_itemExtraLife.mp3","aj_hh_phntm_shield_start.mp3","aj_gemSpawnIn.mp3","aj_gemSpawnOut.mp3","aj_hh_portal.mp3","aj_PopUp_Go.mp3","aj_PopUp_ReadySet.mp3","aj_PU_LevelEnter.mp3","aj_PU_LevelExit.mp3","aj_StingerFail.mp3","aj_StingerSuccess.mp3","aj_hh_hogDeath.mp3"];
      
      private var _soundNameCrystal:String = _audio[0];
      
      private var _soundNamePellet:String = _audio[1];
      
      private var _soundNamePhantom1:String = _audio[2];
      
      private var _soundNamePhantom2:String = _audio[3];
      
      private var _soundNamePhantom3:String = _audio[4];
      
      private var _soundNamePhantomDeath1:String = _audio[5];
      
      private var _soundNamePhantomDeath2:String = _audio[6];
      
      private var _soundNamePhantomDeath3:String = _audio[7];
      
      private var _soundNameGem:String = _audio[8];
      
      private var _soundNameItemExtraLife:String = _audio[9];
      
      private var _soundNamePhntmShieldStart:String = _audio[10];
      
      private var _soundNameSpawnIn:String = _audio[11];
      
      private var _soundNameSpawnOut:String = _audio[12];
      
      private var _soundNamePortal:String = _audio[13];
      
      private var _soundNamePopUpGo:String = _audio[14];
      
      private var _soundNamePopUpReadySet:String = _audio[15];
      
      private var _soundNamePULevelEnter:String = _audio[16];
      
      private var _soundNamePULevelExit:String = _audio[17];
      
      private var _soundNameStingerFail:String = _audio[18];
      
      private var _soundNameStingerSuccess:String = _audio[19];
      
      private var _soundNameHogDeath:String = _audio[20];
      
      public var SFX_aj_hh_shieldDownLp:Class;
      
      public var _soundMan:SoundManager;
      
      private var _portalSound:SoundChannel;
      
      private var _phantomSpawnSound:SoundChannel;
      
      private var _SFX_Music:SBMusic;
      
      private var _SFX_Music_Instance:SoundChannel;
      
      private var _shieldSound:SoundChannel;
      
      public function HedgeHog()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_mus_hedgehog",0.28);
         _soundMan.addSoundByName(_audioByName[_soundNameCrystal],_soundNameCrystal,0.27);
         _soundMan.addSoundByName(_audioByName[_soundNamePellet],_soundNamePellet,0.27);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantom1],_soundNamePhantom1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantom2],_soundNamePhantom2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantom3],_soundNamePhantom3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDeath1],_soundNamePhantomDeath1,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDeath2],_soundNamePhantomDeath2,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDeath3],_soundNamePhantomDeath3,0.35);
         _soundMan.addSound(SFX_aj_hh_shieldDownLp,0.3,"SFX_aj_hh_shieldDownLp");
         _soundMan.addSoundByName(_audioByName[_soundNameGem],_soundNameGem,0.53);
         _soundMan.addSoundByName(_audioByName[_soundNameItemExtraLife],_soundNameItemExtraLife,0.23);
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmShieldStart],_soundNamePhntmShieldStart,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSpawnIn],_soundNameSpawnIn,0.14);
         _soundMan.addSoundByName(_audioByName[_soundNameSpawnOut],_soundNameSpawnOut,0.14);
         _soundMan.addSoundByName(_audioByName[_soundNamePortal],_soundNamePortal,0.18);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpGo],_soundNamePopUpGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpReadySet],_soundNamePopUpReadySet,0.22);
         _soundMan.addSoundByName(_audioByName[_soundNamePULevelEnter],_soundNamePULevelEnter,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePULevelExit],_soundNamePULevelExit,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerSuccess],_soundNameStingerSuccess,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameHogDeath],_soundNameHogDeath,0.52);
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
      
      public function loadNextFactImage() : void
      {
         if(!_loadingImage)
         {
            _factsIndex++;
            if(_factsIndex >= _facts.length)
            {
               _factsIndex = 0;
            }
            _loadingImage = true;
            if(_mediaObjectHelper != null)
            {
               _mediaObjectHelper.destroy();
            }
            _mediaObjectHelper = new MediaHelper();
            _mediaObjectHelper.init(_facts[_factsIndex].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
         _loadingImage = false;
      }
      
      private function doGameOver() : void
      {
         setGameState(6);
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15)
         {
            AchievementXtCommManager.requestSetUserVar(349,1);
         }
         _factImageMediaObject = null;
         if(_shieldSound)
         {
            _shieldSound.stop();
            _shieldSound = null;
         }
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         hideDlg();
         releaseBase();
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",onKeyDown);
         stage.removeEventListener("keyUp",onKeyUp);
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
            loadScene("HedgeHogAssets/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         SFX_aj_hh_shieldDownLp = getDefinitionByName("shieldDown") as Class;
         if(SFX_aj_hh_shieldDownLp == null)
         {
            throw new Error("Sound not found! name:shieldDown");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,999999);
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _bgContent = _scene.getLayer("bg").loader;
         _bgContent = _bgContent.content;
         _layerMain.addChild(_bgContent as DisplayObject);
         _factsIndex = 0;
         randomizeArray(_facts);
         if(gMainFrame)
         {
            _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(354),0);
            _bgContent.highScoreText.text = _highScore;
         }
         stage.addEventListener("enterFrame",heartbeat);
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("keyDown",onKeyDown);
         _player.j = -1;
         _player.i = -1;
         _bonusObject = GETDEFINITIONBYNAME("hedgeHog_bonus");
         _bgContent.level.x = 0;
         _nextExtraLife = _extraLifeScoreThresholds[0];
         _currentLevelIndex = 0;
         _lives = 3;
         _bgContent.scoreText.text = "0";
         setupLevel();
         _scorePopup = GETDEFINITIONBYNAME("hedgeHog_scorePopup");
         _guiLayer.addChild(_scorePopup);
         _player._clone = _bgContent.player;
         _sceneLoaded = true;
         super.sceneLoaded(param1);
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      public function getPhantomSpawnIndex() : int
      {
         if(_phantomSpawnIndex >= _phantomSpawnIndices.length)
         {
            randomizeArray(_phantomSpawnIndices);
            _phantomSpawnIndex = 0;
         }
         return _phantomSpawnIndex++;
      }
      
      private function setupLevel(param1:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         if(param1)
         {
            _energizerTimer = 0;
            _numConsecPhantoms = 1;
            while(_bgContent.levelContainer.numChildren)
            {
               _bgContent.levelContainer.removeChildAt(0);
            }
            _bgContent.levelContainer.drawMap(getCurrentLevelArray(),_gridX,_gridY,_currentLevelIndex % 3 + 1);
            while(_pellets.length)
            {
               if(_pellets[0].parent)
               {
                  _pellets[0].parent.removeChild(_pellets[0]);
               }
               _pellets.splice(0,1);
            }
            while(_energizers.length)
            {
               if(_energizers[0].parent)
               {
                  _energizers[0].parent.removeChild(_energizers[0]);
               }
               _energizers.splice(0,1);
            }
            _bonusItemIndices = [];
            _phantomSpawnIndices = [];
            _currentBonusItemIndex = 0;
            _bonusItemsCollected = 0;
            _bgContent.levelText.text = _currentLevelIndex + 1;
         }
         while(_enemies.length)
         {
            if(_enemies[0]._clone.parent)
            {
               _enemies[0]._clone.parent.removeChild(_enemies[0]._clone);
            }
            _enemies.splice(0,1);
         }
         if(_shieldSound)
         {
            _shieldSound.stop();
            _shieldSound = null;
         }
         _inputStack.splice(0,_inputStack.length);
         changeDirection(0);
         _bgContent.extraLives.lives(_lives - 1);
         var _loc2_:Array = getCurrentLevelArray();
         if(param1)
         {
            if(_currentLevelIndex < 5)
            {
               _phantomBaseSpeed = _moveSpeed * _phantomSpeedRampup[_currentLevelIndex];
            }
            else
            {
               _phantomBaseSpeed += _moveSpeed * _phantomSpeedRampup[5];
            }
            _numPellets = 0;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc2_[_loc3_].length)
               {
                  if(_loc2_[_loc3_][_loc4_] != 0 && _loc2_[_loc3_][_loc4_] != 4)
                  {
                     _pellets.push(GETDEFINITIONBYNAME("hedgeHog_pellet"));
                     _bgContent.level.addChild(_pellets[_pellets.length - 1]);
                     _pellets[_pellets.length - 1].x = _loc4_ * _gridX + _offsetX;
                     _pellets[_pellets.length - 1].y = _loc3_ * _gridY + _offsetY;
                     _numPellets++;
                  }
                  else
                  {
                     _pellets.push(GETDEFINITIONBYNAME("hedgeHog_pellet"));
                     _bgContent.level.addChild(_pellets[_pellets.length - 1]);
                     _pellets[_pellets.length - 1].x = _loc4_ * _gridX + _offsetX;
                     _pellets[_pellets.length - 1].y = _loc3_ * _gridY + _offsetY;
                     _pellets[_pellets.length - 1].visible = false;
                  }
                  if(_loc2_[_loc3_][_loc4_] == 2)
                  {
                     _energizers.push(GETDEFINITIONBYNAME("hedgeHog_energizer"));
                     _bgContent.level.addChild(_energizers[_energizers.length - 1]);
                     _energizers[_energizers.length - 1].x = _loc4_ * _gridX + _offsetX;
                     _energizers[_energizers.length - 1].y = _loc3_ * _gridY + _offsetY;
                  }
                  if(_loc2_[_loc3_][_loc4_] == 5)
                  {
                     _bonusItemIndices.push(_loc3_ * _loc2_[0].length + _loc4_);
                  }
                  if(_loc2_[_loc3_][_loc4_] == 3)
                  {
                     _phantomSpawnIndices.push(_loc3_ * _loc2_[0].length + _loc4_);
                  }
                  _loc4_++;
               }
               _loc3_++;
            }
         }
         randomizeArray(_phantomSpawnIndices);
         _loc3_ = 0;
         while(_loc3_ < _numPhantoms[_currentLevelIndex % _numPhantoms.length])
         {
            _loc5_ = new HedgeHogEnemy(this,Math.floor(_phantomSpawnIndices[_loc3_] / _loc2_[0].length),_phantomSpawnIndices[_loc3_] % _loc2_[0].length,_loc3_ + 1);
            _layerMain.addChild(_loc5_._clone);
            _enemies.push(_loc5_);
            _loc3_++;
         }
         if(param1)
         {
            randomizeArray(_bonusItemIndices);
            spawnBonus();
         }
         setPlayerIJ();
         _player.turnX = _player.turnY = _player.turnDirection = -1;
         _bgContent.player.x = _player.j * _gridX + _offsetX;
         _bgContent.player.y = _player.i * _gridY + _offsetY;
         _bgContent.player.spawn();
         _bgContent.player.powerDown();
         if(param1)
         {
            if(_currentLevelIndex != 0)
            {
               showFactPopup();
            }
            else
            {
               showNextLevel();
            }
         }
         else
         {
            showCountdown();
         }
         setGameState(1);
      }
      
      private function spawnBonus() : void
      {
         var _loc1_:Array = null;
         if(_bonusItemsCollected < 4)
         {
            _loc1_ = getCurrentLevelArray();
            _bgContent.level.addChild(_bonusObject);
            _bonusObject.x = _bonusItemIndices[_currentBonusItemIndex] % _loc1_[0].length * _gridX + _offsetX;
            _bonusObject.y = Math.floor(_bonusItemIndices[_currentBonusItemIndex] / _loc1_[0].length) * _gridY + _offsetY;
            _currentBonusItemIndex++;
            if(_currentBonusItemIndex >= _bonusItemIndices.length)
            {
               _currentBonusItemIndex = 0;
            }
            _bonusTimer = 30;
            _soundMan.playByName(_soundNameSpawnIn);
         }
      }
      
      private function randomizeArray(param1:Array) : Array
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
      
      private function setPlayerIJ() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Array = getCurrentLevelArray();
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc1_[0].length)
            {
               if(_loc1_[_loc2_][_loc3_] == 4)
               {
                  _player.i = _loc2_;
                  _player.j = _loc3_;
                  break;
               }
               _loc3_++;
            }
            if(_loc3_ != _loc1_[0].length)
            {
               break;
            }
            _loc2_++;
         }
         if(_player.i < 0)
         {
            _player.j = 1;
            _player.i = 1;
         }
      }
      
      private function adjustPellets() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:Array = _levels[_currentLevelIndex];
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc1_[_loc2_].length)
            {
               _pellets[_loc2_ * _loc1_[_loc2_].length + _loc3_].x = _loc3_ * _gridX + _offsetX;
               _pellets[_loc2_ * _loc1_[_loc2_].length + _loc3_].y = _loc2_ * _gridY + _offsetY;
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      private function gameOverKeyDown(param1:KeyboardEvent) : void
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
      
      private function keyboardPressedDlg(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 13)
         {
            case 0:
               if(_currentPopup.hasOwnProperty("continue_btn"))
               {
                  showGreatJob();
               }
               else
               {
                  showNextLevel();
               }
               stage.focus = this;
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrow = true;
               if(_gameState == 4 && _inputStack.indexOf(2) == -1)
               {
                  _inputStack.push(2);
               }
               if(_tutorialShown == 1)
               {
                  _inputOverride = 2;
                  _tutorialShown = 2;
                  setGameState(4);
               }
               break;
            case 1:
               _upArrow = true;
               if(_gameState == 4 && _inputStack.indexOf(1) == -1)
               {
                  _inputStack.push(1);
               }
               if(_tutorialShown == 1)
               {
                  _inputOverride = 1;
                  _tutorialShown = 2;
                  setGameState(4);
               }
               break;
            case 2:
               _rightArrow = true;
               if(_gameState == 4 && _inputStack.indexOf(0) == -1)
               {
                  _inputStack.push(0);
               }
               if(_tutorialShown == 1)
               {
                  _inputOverride = 0;
                  _tutorialShown = 2;
                  setGameState(4);
               }
               break;
            case 3:
               _downArrow = true;
               if(_gameState == 4 && _inputStack.indexOf(3) == -1)
               {
                  _inputStack.push(3);
               }
               if(_tutorialShown == 1)
               {
                  _inputOverride = 3;
                  _tutorialShown = 2;
                  setGameState(4);
                  break;
               }
         }
      }
      
      private function changeDirection(param1:int) : void
      {
         if(_inputOverride > 0)
         {
            param1 = _inputOverride;
            _inputOverride = -1;
         }
         _currentDirection = param1;
         switch(param1)
         {
            case 0:
               _bgContent.player.runRight();
               break;
            case 1:
               _bgContent.player.runUp();
               break;
            case 2:
               _bgContent.player.runLeft();
               break;
            case 3:
               _bgContent.player.runDown();
         }
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:int = -1;
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrow = false;
               _loc2_ = int(_inputStack.indexOf(2));
               break;
            case 1:
               _upArrow = false;
               _loc2_ = int(_inputStack.indexOf(1));
               break;
            case 2:
               _rightArrow = false;
               _loc2_ = int(_inputStack.indexOf(0));
               break;
            case 3:
               _downArrow = false;
               _loc2_ = int(_inputStack.indexOf(3));
         }
         if(_loc2_ != -1)
         {
            _inputStack.splice(_loc2_,1);
         }
      }
      
      private function showGameOver() : void
      {
         stage.addEventListener("keyDown",gameOverKeyDown);
         _currentPopup = showDlg("hedgeHog_Game_Over",[{
            "name":"button_yes",
            "f":onRetry
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         LocalizationManager.translateIdAndInsert(_currentPopup.points,11550,_score);
         _gemsEarned = Math.max(Math.floor(_score / 600),5);
         addGemsToBalance(_gemsEarned - _gemsAwarded);
         _gemsAwarded = _gemsEarned;
         LocalizationManager.translateIdAndInsert(_currentPopup.text_score,11432,_gemsEarned);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         _soundMan.playByName(_soundNameStingerFail);
         if(_score > _highScore)
         {
            _highScore = _score;
            _bgContent.highScoreText.text = _highScore;
            AchievementXtCommManager.requestSetUserVar(354,_highScore);
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
      }
      
      private function showNextLevel() : void
      {
         hideDlg();
         _scoreThisLevel = 0;
         _currentPopup = showDlg("hedgeHog_nextLevel",[]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         LocalizationManager.translateIdAndInsert(_currentPopup.nextLevel.nextLevelText,11548,_currentLevelIndex + 1);
         _currentPopup.gotoAndPlay("on");
         if(!_loadingImage)
         {
            loadNextFactImage();
         }
      }
      
      private function showFactPopup() : void
      {
         _currentPopup = showDlg("hedgeHog_factPopup",[{
            "name":"continue_btn",
            "f":showGreatJob
         }]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         if(_factImageMediaObject)
         {
            _currentPopup.result_pic.addChild(_factImageMediaObject);
         }
         LocalizationManager.translateId(_currentPopup.result_factCont.result_fact,_facts[_factsIndex].text);
         _currentPopup.updateText();
         _currentPopup.addEventListener("keyDown",keyboardPressedDlg);
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         _soundMan.playByName(_soundNameStingerSuccess);
      }
      
      private function showGreatJob() : void
      {
         if(_factImageMediaObject && _factImageMediaObject.parent != null)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
            _factImageMediaObject = null;
         }
         var _loc2_:int = Math.floor(_score / 600);
         var _loc1_:int = Math.floor(_scoreThisLevel / 600);
         _currentPopup = showDlg("hedgeHog_Great_Job",[{
            "name":"nextLevelButton",
            "f":showNextLevel
         }]);
         LocalizationManager.translateIdAndInsert(_currentPopup.points,11550,_score);
         LocalizationManager.translateIdAndInsert(_currentPopup.Gems_Earned,11432,_loc1_);
         LocalizationManager.translateIdAndInsert(_currentPopup.Total_Gems,11549,_loc2_);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         _currentPopup.addEventListener("keyDown",keyboardPressedDlg);
         if(_score > _highScore)
         {
            _highScore = _score;
            _bgContent.highScoreText.text = _highScore;
            AchievementXtCommManager.requestSetUserVar(354,_highScore);
         }
      }
      
      private function showCountdown() : void
      {
         _currentPopup = showDlg("hedgeHog_countdown",[]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         _currentPopup.gotoAndPlay("on");
      }
      
      private function showTutorial() : void
      {
         hideDlg();
         _currentPopup = showDlg("hedgeHog_controls",[]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         _currentLevelIndex = 0;
         _lives = 3;
         _extraLifeIndex = 0;
         _nextExtraLife = _extraLifeScoreThresholds[0];
         _score = 0;
         _bgContent.scoreText.text = "0";
         setupLevel();
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
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
      
      public function setGameState(param1:int) : void
      {
         if(_gameState != param1)
         {
            switch(param1 - 1)
            {
               case 0:
                  break;
               case 1:
                  _bgContent.player.die();
                  break;
               case 3:
                  hideDlg();
                  changeDirection(0);
                  _gameOver = false;
                  if(_SFX_Music_Instance == null)
                  {
                     _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,999999);
                  }
                  break;
               case 5:
                  _bgContent.player.die();
                  showGameOver();
                  _gameOver = true;
            }
            _gameState = param1;
         }
      }
      
      private function doScorePopup(param1:Number, param2:Number, param3:int) : void
      {
         if(_scoreMultiplier > 1)
         {
            _scorePopup.combo.gotoAndStop("multi");
            _scorePopup.combo.comboMult.text = _scoreMultiplier.toString();
         }
         else
         {
            _scorePopup.combo.gotoAndStop("single");
         }
         _scorePopup.combo.comboNum.text = param3.toString();
         _scorePopup.x = param1;
         _scorePopup.y = param2;
         _scorePopup.gotoAndPlay("on");
      }
      
      public function setTurnXY(param1:int, param2:int, param3:Object) : void
      {
         var _loc4_:Array = getCurrentLevelArray();
         if(param1 >= 0 && param1 < _loc4_.length && param2 >= 0 && param2 < _loc4_[0].length && _loc4_[param1][param2] != 0)
         {
            param3.turnX = param2 * _gridX + _offsetX;
            param3.turnY = param1 * _gridY + _offsetY;
         }
      }
      
      public function setTurningPointXY(param1:int, param2:int, param3:Object) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param2 == 2 || param2 == 0)
         {
            _loc4_ = param2 == 2 ? 1 : -1;
            _loc5_ = param1 == 1 ? 1 : -1;
            if(_loc4_ * (param3.j * _gridX + _offsetX - param3._clone.x) > 2)
            {
               setTurnXY(param3.i - _loc5_,param3.j - _loc4_,param3);
            }
            else
            {
               setTurnXY(param3.i - _loc5_,param3.j,param3);
            }
         }
         else
         {
            _loc5_ = param2 == 1 ? 1 : -1;
            _loc4_ = param1 == 2 ? 1 : -1;
            if(_loc5_ * (param3.i * _gridY + _offsetY - param3._clone.y) > 2)
            {
               setTurnXY(param3.i - _loc5_,param3.j - _loc4_,param3);
            }
            else
            {
               setTurnXY(param3.i,param3.j - _loc4_,param3);
            }
         }
      }
      
      public function getLevelExtent(param1:int) : Number
      {
         var _loc2_:Array = getCurrentLevelArray();
         switch(param1)
         {
            case 0:
               return (_loc2_[0].length - 0.5) * _gridX + _offsetX;
            case 1:
               return -0.5 * _gridY + _offsetY;
            case 2:
               return -0.5 * _gridX + _offsetX;
            case 3:
               return (_loc2_.length - 0.5) * _gridY + _offsetY;
            default:
               return 0;
         }
      }
      
      public function resetTurnXY(param1:Object) : void
      {
         param1.turnY = -1;
         param1.turnX = -1;
      }
      
      public function getGridIndices(param1:Number, param2:Number, param3:Object) : void
      {
         param3.i = Math.round((param2 - _offsetY) / _gridY);
         param3.j = Math.round((param1 - _offsetX) / _gridX);
         var _loc4_:Array = getCurrentLevelArray();
         if(param3.i < 0)
         {
            param3.i = _loc4_.length - 1;
         }
         if(param3.i >= _loc4_.length)
         {
            param3.i = 0;
         }
         if(param3.j < 0)
         {
            param3.j = _loc4_[0].length;
         }
         if(param3.j >= _loc4_[0].length)
         {
            param3.j = _loc4_[0].length - 1;
         }
      }
      
      private function setScore(param1:int, param2:Boolean = true) : void
      {
         while(_score < _nextExtraLife && param1 >= _nextExtraLife)
         {
            _soundMan.playByName(_soundNameItemExtraLife);
            _lives++;
            _bgContent.extraLives.lives(_lives - 1);
            _extraLifeIndex++;
            if(_extraLifeIndex >= _extraLifeScoreThresholds.length)
            {
               _extraLifeIndex = _extraLifeScoreThresholds.length - 1;
               _nextExtraLife += _extraLifeScoreThresholds[_extraLifeIndex];
            }
            else
            {
               _nextExtraLife = _extraLifeScoreThresholds[_extraLifeIndex];
            }
         }
         if(param2)
         {
            _scorePopup.turnOn(param1 - _score);
            _scorePopup.x = _bgContent.player.x;
            _scorePopup.y = _bgContent.player.y;
         }
         _scoreThisLevel += param1 - _score;
         _score = param1;
         _bgContent.scoreText.text = param1;
      }
      
      public function getCurrentLevelArray() : Array
      {
         return _levels[Math.floor(_currentLevelIndex / 3) % _levels.length];
      }
      
      public function playPhantomSpawn() : void
      {
         if(_phantomSpawnSound == null)
         {
            _phantomSpawnSound = _soundMan.playByName(this["_soundNamePhantom" + (Math.floor(Math.random() * 3) + 1)]);
            if(_phantomSpawnSound)
            {
               _phantomSpawnSound.addEventListener("soundComplete",phantomSpawnComplete);
            }
         }
      }
      
      public function phantomSpawnComplete(param1:Event) : void
      {
         _phantomSpawnSound.removeEventListener("soundComplete",phantomSpawnComplete);
         _phantomSpawnSound = null;
      }
      
      public function playPortal() : void
      {
         if(_portalSound == null)
         {
            _portalSound = _soundMan.playByName(_soundNamePortal);
            if(_portalSound)
            {
               _portalSound.addEventListener("soundComplete",portalComplete);
            }
         }
      }
      
      private function portalComplete(param1:Event) : void
      {
         _portalSound.removeEventListener("soundComplete",portalComplete);
         _portalSound = null;
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc13_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc16_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc12_:int = 0;
         var _loc4_:Array = null;
         if(_sceneLoaded)
         {
            if(_serverStarted)
            {
               _frameTime = 0.04166666666667;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
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
               if(_gameState == 4 && !_gameOver && !_pauseGame)
               {
                  _loc7_ = false;
                  _loc8_ = false;
                  _loc3_ = false;
                  _loc16_ = Number(_bgContent.player.x);
                  _loc11_ = Number(_bgContent.player.y);
                  _loc14_ = -1;
                  _loc15_ = -1;
                  if(stage.focus != this)
                  {
                     stage.stageFocusRect = false;
                     stage.focus = this;
                  }
                  _bonusTimer -= _frameTime;
                  if(_bonusTimer + _frameTime > 20 && _bonusTimer <= 20)
                  {
                     if(_bonusObject.parent)
                     {
                        _bonusObject.parent.removeChild(_bonusObject);
                        _soundMan.playByName(_soundNameSpawnOut);
                     }
                  }
                  else if(_bonusTimer <= 0)
                  {
                     spawnBonus();
                  }
                  if(_bonusObject.parent && Math.abs(_loc16_ - _bonusObject.x) < 10 && Math.abs(_loc11_ - _bonusObject.y) < 10)
                  {
                     _bonusObject.parent.removeChild(_bonusObject);
                     setScore(_score + 5000);
                     _bonusItemsCollected++;
                     AchievementXtCommManager.requestSetUserVar(352,1);
                     _displayAchievementTimer = 1;
                     _soundMan.playByName(_soundNameGem);
                  }
                  _loc5_ = 0;
                  while(_loc5_ < _energizers.length)
                  {
                     if(Math.abs(_loc16_ - _energizers[_loc5_].x) < 15 && Math.abs(_loc11_ - _energizers[_loc5_].y) < 15)
                     {
                        if(_energizers[_loc5_].visible)
                        {
                           _energizers[_loc5_].visible = false;
                           _energizerTimer = 9 - (_currentLevelIndex < 6 ? _currentLevelIndex * 0.5 : 2.5 + (_currentLevelIndex - 5) * 0.1);
                           _loc6_ = 0;
                           while(_loc6_ < _enemies.length)
                           {
                              if(_enemies[_loc6_].isSeekingPlayer() || _enemies[_loc6_]._mode == 2)
                              {
                                 _enemies[_loc6_].changeMode(2);
                              }
                              _loc6_++;
                           }
                           setScore(_score + 5000);
                           _player._clone.powerUp();
                           _soundMan.playByName(_soundNameCrystal);
                           if(_shieldSound == null)
                           {
                              _shieldSound = _soundMan.play(SFX_aj_hh_shieldDownLp,0,99999);
                           }
                        }
                        break;
                     }
                     _loc5_++;
                  }
                  if(_energizerTimer > 0)
                  {
                     _energizerTimer -= _frameTime;
                     if(_energizerTimer <= 0)
                     {
                        if(_shieldSound)
                        {
                           _shieldSound.stop();
                           _shieldSound = null;
                        }
                        _player._clone.powerDown();
                        _loc6_ = 0;
                        while(_loc6_ < _enemies.length)
                        {
                           if(_enemies[_loc6_]._mode == 2)
                           {
                              _enemies[_loc6_]._clone.powerUp();
                              _enemies[_loc6_].changeMode(0);
                           }
                           _loc6_++;
                        }
                        _numConsecPhantoms = 1;
                     }
                     else
                     {
                        _loc9_ = false;
                        if(_energizerTimer < _powerUpWarningTime && _energizerTimer + _frameTime >= _powerUpWarningTime)
                        {
                           _player._clone.powerDownWarning();
                           _loc9_ = true;
                           _soundMan.playByName(_soundNamePhntmShieldStart);
                        }
                        _loc6_ = 0;
                        while(_loc6_ < _enemies.length)
                        {
                           if(_enemies[_loc6_]._mode == 2 && Math.abs(_loc16_ - _enemies[_loc6_]._clone.x) < 20 && Math.abs(_loc11_ - _enemies[_loc6_]._clone.y) < 20)
                           {
                              AchievementXtCommManager.requestSetUserVar(351,1);
                              _enemies[_loc6_]._clone.die();
                              _enemies[_loc6_].changeMode(3);
                              setScore(_score + Math.min(250 * Math.pow(2,_numConsecPhantoms - 1),8000));
                              AchievementXtCommManager.requestSetUserVar(353,_numConsecPhantoms);
                              _numConsecPhantoms++;
                              _displayAchievementTimer = 1;
                              _soundMan.playByName(this["_soundNamePhantomDeath" + (Math.floor(Math.random() * 3) + 1)]);
                           }
                           else if(_loc9_ && _enemies[_loc6_]._mode == 2)
                           {
                              _enemies[_loc6_]._clone.powerUpWarning();
                           }
                           _loc6_++;
                        }
                     }
                  }
                  _loc5_ = 0;
                  while(_loc5_ < _pellets.length)
                  {
                     if(_pellets[_loc5_].visible)
                     {
                        _pellets[_loc5_];
                     }
                     if(Math.abs(_loc16_ - _pellets[_loc5_].x) < 15 && Math.abs(_loc11_ - _pellets[_loc5_].y) < 15)
                     {
                        if(_pellets[_loc5_].visible)
                        {
                           _soundMan.playByName(_soundNamePellet);
                           _pellets[_loc5_].visible = false;
                           setScore(_score + 10,false);
                           _numPellets--;
                           if(_numPellets <= 0)
                           {
                              _currentLevelIndex++;
                              _loc7_ = true;
                              AchievementXtCommManager.requestSetUserVar(350,_currentLevelIndex);
                              _displayAchievementTimer = 1;
                           }
                        }
                        break;
                     }
                     _loc5_++;
                  }
                  _loc5_ = 0;
                  while(_loc5_ < _enemies.length)
                  {
                     _enemies[_loc5_].heartbeat(_frameTime);
                     if(_energizerTimer <= 0)
                     {
                        if(_enemies[_loc5_].isSeekingPlayer() && Math.abs(_loc16_ - _enemies[_loc5_]._clone.x) < 20 && Math.abs(_loc11_ - _enemies[_loc5_]._clone.y) < 20)
                        {
                           _lives--;
                           _soundMan.playByName(_soundNameHogDeath);
                           if(_shieldSound)
                           {
                              _shieldSound.stop();
                              _shieldSound = null;
                           }
                           if(_lives <= 0)
                           {
                              _loc3_ = true;
                              setGameState(6);
                              break;
                           }
                           _loc8_ = true;
                           break;
                        }
                     }
                     _loc5_++;
                  }
                  getGridIndices(_loc16_,_loc11_,_player);
                  if(_inputStack.length > 0)
                  {
                     _loc12_ = int(_inputStack[_inputStack.length - 1]);
                     if(_currentDirection != _loc12_)
                     {
                        if((_currentDirection + _loc12_) % 2 == 0)
                        {
                           changeDirection(_loc12_);
                           _player.turnX = _player.turnY = -1;
                        }
                        else
                        {
                           setTurningPointXY(_loc12_,_currentDirection,_player);
                           _player.turnDirection = _loc12_;
                        }
                     }
                  }
                  _loc4_ = getCurrentLevelArray();
                  if(_currentDirection == 0)
                  {
                     if(_player.j + 1 < _loc4_[0].length && _loc4_[_player.i][_player.j + 1] == 0)
                     {
                        _loc14_ = _player.j * _gridX + _offsetX;
                     }
                     _bgContent.player.x += _moveSpeed * _frameTime;
                     if(_bgContent.player.x > getLevelExtent(0))
                     {
                        _bgContent.player.x = getLevelExtent(2);
                     }
                     else if(_player.turnX >= 0 && _bgContent.player.x >= _player.turnX)
                     {
                        _bgContent.player.x = _player.turnX;
                        resetTurnXY(_player);
                        changeDirection(_player.turnDirection);
                     }
                     else if(_loc14_ >= 0 && _bgContent.player.x > _loc14_)
                     {
                        _bgContent.player.x = _loc14_;
                        _bgContent.player.stopRun();
                     }
                  }
                  else if(_currentDirection == 2)
                  {
                     if(_player.j - 1 >= 0 && _loc4_[_player.i][_player.j - 1] == 0)
                     {
                        _loc14_ = _player.j * _gridX + _offsetX;
                     }
                     _bgContent.player.x -= _moveSpeed * _frameTime;
                     if(_bgContent.player.x < getLevelExtent(2))
                     {
                        _bgContent.player.x = getLevelExtent(0);
                     }
                     else if(_player.turnX >= 0 && _bgContent.player.x <= _player.turnX)
                     {
                        _bgContent.player.x = _player.turnX;
                        resetTurnXY(_player);
                        changeDirection(_player.turnDirection);
                     }
                     else if(_loc14_ >= 0 && _bgContent.player.x < _loc14_)
                     {
                        _bgContent.player.x = _loc14_;
                        _bgContent.player.stopRun();
                     }
                  }
                  else if(_currentDirection == 1)
                  {
                     if(_player.i - 1 >= 0 && _loc4_[_player.i - 1][_player.j] == 0)
                     {
                        _loc15_ = _player.i * _gridY + _offsetY;
                     }
                     _bgContent.player.y -= _moveSpeed * _frameTime;
                     if(_bgContent.player.y < getLevelExtent(1))
                     {
                        _bgContent.player.y = getLevelExtent(3);
                     }
                     else if(_player.turnY >= 0 && _bgContent.player.y <= _player.turnY)
                     {
                        _bgContent.player.y = _player.turnY;
                        resetTurnXY(_player);
                        changeDirection(_player.turnDirection);
                     }
                     else if(_loc15_ >= 0 && _bgContent.player.y < _loc15_)
                     {
                        _bgContent.player.y = _loc15_;
                        _bgContent.player.stopRun();
                     }
                  }
                  else
                  {
                     if(_player.i + 1 < _loc4_.length && _loc4_[_player.i + 1][_player.j] == 0)
                     {
                        _loc15_ = _player.i * _gridY + _offsetY;
                     }
                     _bgContent.player.y += _moveSpeed * _frameTime;
                     if(_bgContent.player.y > getLevelExtent(3))
                     {
                        _bgContent.player.y = getLevelExtent(1);
                     }
                     else if(_player.turnY >= 0 && _bgContent.player.y >= _player.turnY)
                     {
                        _bgContent.player.y = _player.turnY;
                        resetTurnXY(_player);
                        changeDirection(_player.turnDirection);
                     }
                     else if(_loc15_ >= 0 && _bgContent.player.y > _loc15_)
                     {
                        _bgContent.player.y = _loc15_;
                        _bgContent.player.stopRun();
                     }
                  }
                  if(_loc3_)
                  {
                     setGameState(6);
                  }
                  else if(_loc8_)
                  {
                     setGameState(2);
                  }
                  else if(_loc7_)
                  {
                     _gemsEarned = Math.floor(_score / 600);
                     addGemsToBalance(_gemsEarned - _gemsAwarded);
                     _gemsAwarded = _gemsEarned;
                     if(_SFX_Music_Instance)
                     {
                        _SFX_Music_Instance.stop();
                        _SFX_Music_Instance = null;
                     }
                     setupLevel();
                  }
               }
               else if(_gameState == 2)
               {
                  if(_bgContent.player.busy == false)
                  {
                     setupLevel(false);
                  }
               }
               else if(_gameState == 1)
               {
                  if(stage.focus != _currentPopup)
                  {
                     stage.stageFocusRect = false;
                     stage.focus = _currentPopup;
                  }
                  if(_currentPopup.hasOwnProperty("countGo"))
                  {
                     if(_currentPopup.count3 || _currentPopup.count2 || _currentPopup.count1)
                     {
                        _soundMan.playByName(_soundNamePopUpReadySet);
                        _currentPopup.count3 = _currentPopup.count2 = _currentPopup.count1 = false;
                     }
                     if(_currentPopup.countGo)
                     {
                        _soundMan.playByName(_soundNamePopUpGo);
                        _currentPopup.countGo = false;
                     }
                  }
                  if(_currentPopup.hasOwnProperty("enterSound"))
                  {
                     if(_currentPopup.enterSound)
                     {
                        _soundMan.playByName(_soundNamePULevelEnter);
                        _currentPopup.enterSound = false;
                     }
                     if(_currentPopup.exitSound)
                     {
                        _soundMan.playByName(_soundNamePULevelExit);
                        _currentPopup.exitSound = false;
                     }
                  }
                  if(_currentPopup.hasOwnProperty("active"))
                  {
                     if(_currentPopup.active == false)
                     {
                        if(_tutorialShown == 2)
                        {
                           setGameState(4);
                        }
                        else
                        {
                           _tutorialShown = 1;
                           showTutorial();
                        }
                     }
                  }
               }
               else if(_gameState == 6)
               {
               }
            }
         }
      }
   }
}

