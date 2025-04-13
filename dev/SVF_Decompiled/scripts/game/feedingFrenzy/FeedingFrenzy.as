package game.feedingFrenzy
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
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
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class FeedingFrenzy extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LEVELDISPLAY:int = 1;
      
      public static const GAMESTATE_STARTED:int = 2;
      
      public static const GAMESTATE_GAMEOVER:int = 3;
      
      public static const GAMESTATE_SUCCESS:int = 4;
      
      public static const GAMESTATE_FAIL:int = 5;
      
      public static const GAMESTATE_SHOWTITLESCREEN:int = 6;
      
      public var NUM_LEVELS:int;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _loadComplete:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerPlayer:Sprite;
      
      public var _highScore:Number;
      
      public var _fish:Array;
      
      public var _cacheEvent:Event;
      
      public var _currentLevel:int;
      
      public var _currentWave:int;
      
      public var _fishSpawnTimer:Number;
      
      public var _fishToSpawn:Array;
      
      public var _spawnInterval:Number;
      
      public var _respawnTimer:Number;
      
      public var _bonus:Object;
      
      public var _scoreMultiplier:int;
      
      public var _scoreTimer:Number;
      
      public var _nextBonus:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _factImageMediaObject:MovieClip;
      
      private var _factStringId:int;
      
      public var _bg:Object;
      
      public var _ui:Object;
      
      public var _level_popup:Object;
      
      public var _fishPool:Array;
      
      public var _fishEaten:int;
      
      public var _fishEatenThisLevel:int;
      
      public var _difficulty:int;
      
      public var _gemsTotal:int;
      
      public var _currentFact:int;
      
      public var _startingSize:Array = [[1,2,3,4,5,6]];
      
      public var _goalSize:Array = [[2,3,4,5,6,7]];
      
      public var _detectionRadius:Array = [1,1,2,1,1,2,2];
      
      public var _fishSpeed:Array = [95,75,60,50,45,50,55];
      
      public var _levels:Array = [[[1,0,1,1],[2,0,1,1],[2,0,1,1],[2,1,1,1],[2,0,1,1],[7,0,5,2],[3,0,1,1],[4,0,3,2],[2,1,1,1],[8,0,5,1],[2,1,2,1],[9,0,5,2],[1,2,1,1],[2,7,3,1],[8,0,1,6,2],[4,0,1,1],[11,0,3,1],[2,2,1,1],[12,0,3,3],[3,1,1,1],[18,0,6,1],[2,1,2,2,1],[18,0,5,2],[12,0,1,3,3],[6,1,2,3,2],[30,0,1,1],[1,7,1,1],[10,0,1,1]],[[2,0,1,1],[2,0,1,1],[2,1,1,1],[1,2,1,1],[2,1,1,1],[8,0,4,1],[1,2,1,1],[4,1,1,1],[8,0,1,1],[1,2,1,1],[3,1,1,1],[1,2,1,1],[10,1,5,1],[1,2,1,1],[1,2,1,1],[12,0,1,4,1],[6,0,1,2,1],[1,3,1,1],[2,7,2,1],[10,0,1,6,1],[1,3,1,1],[4,2,4,1],[15,1,1,1],[2,7,2,1],[1,3,1,1],[30,0,3,2],[30,0,3,2],[6,2,3,1],[30,0,3,2],[20,1,6,1],[4,2,3,2,1],[20,1,5,2],[14,1,2,3,3],[8,2,3,3,2],[30,1,1,1],[10,1,1,1]],[[4,0,1,1],[2,1,1,1],[2,2,1,1],[2,1,1,1],[2,2,1,1],[12,0,1,1],[12,0,1,1],[1,3,1,1],[4,2,1,1],[8,1,1,1],[1,3,1,1],[1,7,1,1],[3,2,1,1],[1,3,1,1],[10,2,5,1],[1,3,1,1],[1,7,1,1],[1,3,1,1],[12,1,2,4,1],[6,1,2,2,1],[30,0,3,2],[1,4,1,1],[2,7,2,1],[10,1,2,6,1],[1,4,1,1],[4,3,4,1],[15,2,1,1],[2,7,2
      ,1],[1,4,1,1],[30,0,3,2],[3,7,3,2],[6,3,3,1],[3,7,3,2],[20,2,6,1],[4,3,4,2,1],[20,2,5,2],[14,2,3,3,3],[8,3,4,3,2],[30,2,1,1],[10,2,1,1]],[[3,1,1,1],[5,0,1,1],[2,3,2,2],[1,4,1,1],[2,2,1,1],[5,0,1,1],[2,3,1,1],[2,4,2,1],[5,0,1,1],[2,1,1,1],[5,0,1,1],[2,3,1,1],[5,0,1,1],[12,1,1,1],[5,0,1,1],[12,1,1,1],[2,7,1,1],[1,4,1,1],[4,3,1,1],[2,7,1,1],[8,2,1,1],[1,4,1,1],[1,7,1,1],[3,3,1,1],[1,4,1,1],[2,7,1,1],[10,3,5,1],[1,4,1,1],[1,7,1,1],[1,4,1,1],[12,2,3,4,1],[6,2,3,2,1],[30,1,3,2],[1,5,1,1],[2,7,2,1],[10,2,3,6,1],[1,5,1,1],[4,4,4,1],[15,3,1,1],[2,7,2,1],[1,5,1,1],[30,1,3,2],[3,7,3,2],[6,4,3,1],[3,7,3,2],[20,3,6,1],[4,4,5,2,1],[20,3,5,2],[14,3,4,3,3],[8,4,5,3,2],[30,3,1,1],[10,3,1,1]],[[1,7,1,1],[1,7,1,1],[1,4,1,1],[1,7,1,1],[4,2,1,1],[1,5,1,1],[5,1,1,1],[2,3,1,1],[1,7,1,1],[2,5,3,1],[5,1,1,1],[2,4,1,1],[5,1,1,1],[1,7,1,1],[2,2,1,1],[5,1,1,1],[1,5,1,1],[2,4,1,1],[5,1,1,1],[1,7,1,1],[12,2,1,1],[5,1,1,1],[12,2,1,1],[1,7,1,1],[2,7,1,1],[2,5,1,1],[4,4,1,1],[2,7,1,1],[8,3,1,1],[1,5,1,1],[1,7,1,1],[3,4
      ,1,1],[1,5,1,1],[2,7,1,1],[10,4,5,1],[1,7,1,1],[1,7,1,1],[1,5,1,1],[1,7,1,1],[1,5,1,1],[12,3,4,4,1],[6,3,4,2,1],[1,7,1,1],[30,2,3,2],[1,6,1,1],[2,7,2,1],[10,3,4,6,1],[1,6,1,1],[4,5,4,1],[15,4,1,1],[2,7,2,1],[1,6,1,1],[30,2,3,2],[3,7,3,2],[6,5,3,1],[3,7,3,2],[20,4,6,1],[4,5,6,2,1],[20,4,5,2],[14,4,5,3,3],[8,5,6,3,2],[30,4,1,1],[10,4,1,1]],[[1,0,1,1],[2,0,1,1],[1,5,1,1],[4,0,1,1],[8,0,1,1],[15,0,1,1],[1,6,1,2],[80,0,4,2],[1,6,1,2],[5,0,1,1],[4,3,5,2,1],[1,6,1,1],[20,1,5,1],[2,7,2,1],[2,5,1,1],[20,2,5,1],[2,6,1,3],[2,7,1,1],[5,2,1,1],[2,5,1,1],[5,2,1,1],[1,7,1,1],[2,3,1,1],[1,6,1,1],[5,2,1,1],[2,5,1,1],[5,2,1,1],[2,7,1,1],[1,6,1,1],[12,3,4,1],[5,2,1,1],[12,3,4,1],[2,7,1,1],[3,7,2,1],[2,6,1,1],[4,5,1,1],[2,7,1,1],[1,6,1,1],[8,4,1,1],[1,6,1,1],[2,7,1,1],[3,5,1,1],[1,6,1,1],[2,7,1,1],[10,5,5,1],[1,6,1,1],[1,7,1,1],[1,7,1,1],[2,6,3,1],[1,7,1,1],[1,6,1,1],[12,4,5,4,1],[6,4,5,2,1],[1,7,1,1],[30,3,3,2],[1,6,1,1],[2,7,2,1],[10,4,5,6,1],[1,6,1,1],[4,6,4,1],[15,5,1,1],[2,7,2,1],[1,6,1,1],[30,3,3,2],[3
      ,7,3,2],[6,6,3,1],[3,7,3,2],[20,5,6,1],[4,6,2,1],[20,5,5,2],[14,5,6,3,3],[8,6,3,2],[30,5,1,1],[4,6,4,1]]];
      
      public var _growthPoints:Array = [10,7,5,4,3,2,1];
      
      public var _displayAchievementTimer:Number;
      
      public var _player1:FeedingFrenzyFish;
      
      public var _score:int;
      
      public var _lives:int;
      
      public var _soundMan:SoundManager;
      
      public var _gameState:int;
      
      private var _facts:Array = [{
         "imageID":1143,
         "text":11532
      },{
         "imageID":1144,
         "text":11533
      },{
         "imageID":1145,
         "text":11534
      },{
         "imageID":1146,
         "text":11535
      },{
         "imageID":1147,
         "text":11536
      },{
         "imageID":1148,
         "text":11537
      },{
         "imageID":1149,
         "text":11538
      },{
         "imageID":1150,
         "text":11539
      },{
         "imageID":1151,
         "text":11540
      },{
         "imageID":1152,
         "text":11541
      },{
         "imageID":1153,
         "text":11542
      },{
         "imageID":1154,
         "text":11543
      },{
         "imageID":1155,
         "text":11544
      },{
         "imageID":1156,
         "text":11545
      }];
      
      private var _audio:Array = ["eeu_blowfish_puff.mp3","eeu_CameraZoom.mp3","eeu_death.mp3","eeu_smallfish_eats.mp3","eeu_bubble_grow.mp3","eeu_bubble_shrink.mp3","eeu_newLevel_fadeIn.mp3","eeu_newLevel_fadeOut.mp3","eeu_squid_life.mp3","eeu_funFact_popUp.mp3"];
      
      internal var _soundNameBlowfishPuff:String = _audio[0];
      
      internal var _soundNameCameraZoom:String = _audio[1];
      
      internal var _soundNameDeath:String = _audio[2];
      
      internal var _soundNameFishEats:String = _audio[3];
      
      internal var _soundNameBubbleGrow:String = _audio[4];
      
      internal var _soundNameBubbleShrink:String = _audio[5];
      
      internal var _soundNameNewLevelFadeIn:String = _audio[6];
      
      internal var _soundNameNewLevelFadeOut:String = _audio[7];
      
      internal var _soundNameSquidLife:String = _audio[8];
      
      internal var _soundNameFunFactPopUp:String = _audio[9];
      
      public var _SFX_FeedingFrenzy_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function FeedingFrenzy()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_FeedingFrenzy_Music = _soundMan.addStream("aj_eat_em_up",0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBlowfishPuff],_soundNameBlowfishPuff,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameCameraZoom],_soundNameCameraZoom,1);
         _soundMan.addSoundByName(_audioByName[_soundNameDeath],_soundNameDeath,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFishEats],_soundNameFishEats,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBubbleGrow],_soundNameBubbleGrow,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBubbleShrink],_soundNameBubbleShrink,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameNewLevelFadeIn],_soundNameNewLevelFadeIn,1.5);
         _soundMan.addSoundByName(_audioByName[_soundNameNewLevelFadeOut],_soundNameNewLevelFadeOut,1.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSquidLife],_soundNameSquidLife,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFunFactPopUp],_soundNameFunFactPopUp,2);
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
            _displayAchievementTimer = 1;
         }
         if(_score > _highScore)
         {
            _highScore = _score;
            AchievementXtCommManager.requestSetUserVar(286,_highScore);
         }
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         releaseBase();
         stage.removeEventListener("keyDown",nextLevelKeyDown);
         stage.removeEventListener("keyDown",gameCompleteKeyDown);
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",continueKeyDown);
         stage.removeEventListener("keyDown",winKeyDown);
         stage.removeEventListener("keyDown",winHardKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("mouseMove",mouseMove);
         stage.removeEventListener("mouseLeave",mouseLeave);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerPlayer);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerPlayer = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            _loadComplete = true;
            NUM_LEVELS = _levels.length;
            setGameState(0);
            _layerBackground = new Sprite();
            _layerPlayer = new Sprite();
            _guiLayer = new Sprite();
            _highScore = 0;
            addChild(_layerBackground);
            addChild(_layerPlayer);
            addChild(_guiLayer);
            loadScene("FeedingFrenzyAssets/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      public function loadFactImage() : void
      {
         var _loc1_:int = incrementFact();
         _mediaObjectHelper = new MediaHelper();
         _mediaObjectHelper.init(_facts[_loc1_].imageID,mediaObjectLoaded);
         _factStringId = _facts[_loc1_].text;
      }
      
      private function incrementFact() : int
      {
         var _loc1_:int = _currentFact;
         _currentFact++;
         if(_currentFact == _facts.length)
         {
            _currentFact = 0;
         }
         return _loc1_;
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         if(!_loadComplete)
         {
            _cacheEvent = param1;
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_FeedingFrenzy_Music,0,999999);
         _bg = _scene.getLayer("bg");
         _ui = _scene.getLayer("ui");
         _level_popup = _scene.getLayer("level_popup");
         _highScore = gMainFrame.userInfo.userVarCache.getUserVarValueById(286);
         if(_highScore < 0)
         {
            _highScore = 0;
         }
         LocalizationManager.translateIdAndInsert(_ui.loader.content.highScore,11546,_highScore.toString());
         _layerBackground.addChild(_bg.loader);
         _guiLayer.addChild(_ui.loader);
         _guiLayer.addChild(_level_popup.loader);
         _level_popup.loader.visible = false;
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseMove",mouseMove);
         stage.addEventListener("mouseLeave",mouseLeave);
         super.sceneLoaded(param1);
         startGame();
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37)
         {
            while(_fish.length)
            {
               removeFish(_fish[0]);
               _fish.splice(0,1);
            }
            while(_fishToSpawn.length)
            {
               removeFish(_fishToSpawn[0]);
               _fishToSpawn.splice(0,1);
            }
            _currentWave -= 2;
            if(_currentWave < 0)
            {
               _currentWave = 0;
            }
            createNextWave();
            _currentWave++;
            if(_currentWave == _levels[_currentLevel % NUM_LEVELS].length)
            {
               _currentWave -= 2;
            }
         }
         else if(param1.keyCode == 38)
         {
            checkGrowthTarget(true);
         }
         else if(param1.keyCode == 39)
         {
            while(_fish.length)
            {
               removeFish(_fish[0]);
               _fish.splice(0,1);
            }
            while(_fishToSpawn.length)
            {
               removeFish(_fishToSpawn[0]);
               _fishToSpawn.splice(0,1);
            }
            createNextWave();
            _currentWave++;
            if(_currentWave == _levels[_currentLevel % NUM_LEVELS].length)
            {
               _currentWave -= 2;
            }
         }
         else if(param1.keyCode == 40)
         {
            checkGrowthTarget(true,true);
         }
      }
      
      private function mouseMove(param1:MouseEvent) : void
      {
         _player1._prevMouseX = _player1._mouseX;
         _player1._prevMouseY = _player1._mouseY;
         _player1._mouseX = _layerPlayer.mouseX;
         _player1._mouseY = _layerPlayer.mouseY;
      }
      
      private function mouseLeave(param1:Event) : void
      {
         _player1._mouseX = _player1._prevMouseX;
         _player1._mouseY = _player1._prevMouseY;
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         if(_gameState != param1)
         {
            _gameState = param1;
            if(param1 == 1)
            {
               _level_popup.loader.visible = true;
               LocalizationManager.translateIdAndInsert(_level_popup.loader.content.Text_Level.Level_Text,11548,(_currentLevel + 1).toString());
               LocalizationManager.translateIdAndInsert(_ui.loader.content.levelText,11548,(_currentLevel + 1).toString());
               _level_popup.loader.content.gotoAndPlay(1);
               _bg.loader.content.nextLevel(_currentLevel + 1);
               _player1._currentSize = _startingSize[0][_currentLevel % NUM_LEVELS] - 1;
               _level_popup.loader.content.currentFish(_player1._currentSize + 1);
               _ui.loader.content.currentFish.showFish(_player1._currentSize + 1);
               _player1._clone.fishType(_player1._currentSize,true);
               _soundMan.playByName(_soundNameCameraZoom);
               _soundMan.playByName(_soundNameNewLevelFadeIn);
               if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  AchievementXtCommManager.requestSetUserVar(285,_fishEaten);
                  _displayAchievementTimer = 1;
               }
            }
            else if(param1 == 6)
            {
               _loc2_ = showDlg("FF_titleScreen",[{
                  "name":"btnEasy",
                  "f":chooseEasy
               },{
                  "name":"btnMedium",
                  "f":chooseMed
               },{
                  "name":"btnHard",
                  "f":chooseHard
               },{
                  "name":"x_btn",
                  "f":onExit_Yes
               }]);
            }
         }
      }
      
      public function chooseEasy() : void
      {
         hideDlg();
         _difficulty = 0;
         setGameState(1);
      }
      
      public function chooseMed() : void
      {
         hideDlg();
         _difficulty = 1;
         setGameState(1);
      }
      
      public function chooseHard() : void
      {
         hideDlg();
         _difficulty = 2;
         setGameState(1);
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "ml")
         {
            end(param1);
            return;
         }
      }
      
      public function updateGrowth() : void
      {
         _ui.loader.content.growth.fill.width = _player1._currentGrowthPoints / FeedingFrenzyFish.GROWTH_THRESHOLD[_difficulty] * 200;
      }
      
      public function checkGrowthTarget(param1:Boolean = false, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(_player1._currentSize == _goalSize[0][_currentLevel % NUM_LEVELS] - 1 || param1)
         {
            if(param2)
            {
               _currentLevel--;
               if(_currentLevel < 0)
               {
                  _currentLevel = 0;
               }
            }
            else
            {
               _currentLevel++;
            }
            LocalizationManager.translateIdAndInsert(_ui.loader.content.levelText,11548,(_currentLevel + 1).toString());
            _currentWave = 0;
            while(_fish.length)
            {
               removeFish(_fish[0]);
               _fish.splice(0,1);
            }
            while(_fishToSpawn.length)
            {
               removeFish(_fishToSpawn[0]);
               _fishToSpawn.splice(0,1);
            }
            if(_currentLevel != 0 && _currentLevel % _levels.length == 0)
            {
               if(_difficulty == 0)
               {
                  _difficulty++;
                  _currentLevel = -1;
                  showWinEasy();
               }
               else if(_difficulty == 1)
               {
                  _difficulty++;
                  _currentLevel = -1;
                  showWinMed();
               }
               else
               {
                  showWinHard();
               }
            }
            else if(!param3)
            {
               if(param1)
               {
                  setGameState(1);
               }
               else
               {
                  showNextLevelDlg();
               }
            }
         }
      }
      
      private function gameOverKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onExit_No();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function nextLevelKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               setNextLevel();
         }
      }
      
      private function gameCompleteKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGameCompleteDlg2();
         }
      }
      
      private function winKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               resetGame();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function winHardKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               gotoLevelSelect();
         }
      }
      
      private function continueKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGameOverDlg2();
         }
      }
      
      public function showWinEasy() : void
      {
         var _loc2_:int = 0;
         hideDlg();
         stage.addEventListener("keyDown",winKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Win_Easy",[{
            "name":"button_yes",
            "f":resetGame
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.floor(_score / 500);
            addGemsToBalance(_loc2_ - _gemsTotal);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11549,_loc2_.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_score.toString());
            _gemsTotal = _loc2_;
            _fishEatenThisLevel = 0;
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      public function showWinMed() : void
      {
         var _loc2_:int = 0;
         hideDlg();
         stage.addEventListener("keyDown",winKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Win_Medium",[{
            "name":"button_yes",
            "f":resetGame
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.floor(_score / 500);
            addGemsToBalance(_loc2_ - _gemsTotal);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11549,_loc2_.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_score.toString());
            _gemsTotal = _loc2_;
            _fishEatenThisLevel = 0;
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      public function showWinHard() : void
      {
         var _loc2_:int = 0;
         hideDlg();
         stage.addEventListener("keyDown",winHardKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Win_Hard",[{
            "name":"continue_btn",
            "f":gotoLevelSelect
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.floor(_score / 500);
            addGemsToBalance(_loc2_ - _gemsTotal);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11549,_loc2_.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_score.toString());
            _gemsTotal = _loc2_;
            _fishEatenThisLevel = 0;
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      public function gotoLevelSelect() : void
      {
         stage.removeEventListener("keyDown",winHardKeyDown);
         resetGame(true);
      }
      
      public function getFish(param1:int, param2:Boolean = true) : FeedingFrenzyFish
      {
         var _loc3_:FeedingFrenzyFish = null;
         if(_fishPool.length > 0 && param1 < 7)
         {
            _loc3_ = _fishPool.pop();
            if(param2)
            {
               _loc3_.setType(param1);
            }
            return _loc3_;
         }
         return new FeedingFrenzyFish(this,param1,param2);
      }
      
      public function removeFish(param1:FeedingFrenzyFish) : void
      {
         if(param1._type != 7)
         {
            if(param1._clone.parent)
            {
               param1._clone.parent.removeChild(param1._clone);
            }
            param1._groupParent = null;
            _fishPool.push(param1);
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc4_:MovieClip = null;
         if(_sceneLoaded && _loadComplete)
         {
            if(!_pauseGame)
            {
               _bg.loader.content.bubbles();
            }
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
            if(!_pauseGame && _gameState == 2)
            {
               _gameTime += _frameTime;
               _scoreTimer -= _frameTime;
               _player1.heartbeat(_frameTime,-1);
               if(_player1._queueDelete)
               {
                  _player1._queueDelete = false;
                  _lives--;
                  if(_lives == 0)
                  {
                     _player1._clone.alpha = 0;
                     _loc4_ = GETDEFINITIONBYNAME("ff_deathBubble");
                     _layerPlayer.addChild(_loc4_);
                     _loc4_.x = _player1._clone.x;
                     _loc4_.y = _player1._clone.y;
                     setGameState(3);
                  }
                  else
                  {
                     _respawnTimer = 5;
                     _player1._clone.alpha = 0;
                     _loc4_ = GETDEFINITIONBYNAME("ff_deathBubble");
                     _layerPlayer.addChild(_loc4_);
                     _loc4_.x = _player1._clone.x;
                     _loc4_.y = _player1._clone.y;
                  }
                  LocalizationManager.translateIdAndInsert(_ui.loader.content.lives,11551,_lives.toString());
               }
               if(_respawnTimer > 0)
               {
                  _respawnTimer -= _frameTime;
                  if(_respawnTimer + _frameTime > 3 && _respawnTimer <= 3)
                  {
                     _player1._clone.bubbleOn();
                     _soundMan.playByName(_soundNameBubbleGrow);
                     _player1._clone.alpha = 0.99;
                  }
                  if(_respawnTimer <= 0)
                  {
                     _respawnTimer = 0;
                     _player1._clone.bubbleOff();
                     _soundMan.playByName(_soundNameBubbleShrink);
                     _player1._clone.alpha = 1;
                  }
               }
               if(_bonus)
               {
                  if(boxCollisionTest(_bonus.loader,_player1._clone))
                  {
                     _loc4_ = GETDEFINITIONBYNAME("ff_bubblePop");
                     _layerPlayer.addChild(_loc4_);
                     _loc4_.x = _bonus.loader.x;
                     _loc4_.y = _bonus.loader.y;
                     _bonus.loader.parent.removeChild(_bonus.loader);
                     _bonus = null;
                     _lives++;
                     LocalizationManager.translateIdAndInsert(_ui.loader.content.lives,11551,_lives.toString());
                     _soundMan.playByName(_soundNameSquidLife);
                  }
                  else
                  {
                     _bonus.loader.y -= _frameTime * 50;
                     if(_bonus.loader.y < -50 && _bonus.loader.parent)
                     {
                        _bonus.loader.parent.removeChild(_bonus.loader);
                        _bonus = null;
                     }
                  }
               }
               if(_gameState == 2)
               {
                  _loc2_ = 0;
                  while(_loc2_ < _fish.length)
                  {
                     _fish[_loc2_].heartbeat(_frameTime,_loc2_);
                     _loc2_++;
                  }
                  _loc2_ = 0;
                  while(_loc2_ < _fish.length)
                  {
                     if(_fish[_loc2_]._queueDelete)
                     {
                        _fish[_loc2_]._queueDelete = false;
                        removeFish(_fish[_loc2_]);
                        _loc4_ = GETDEFINITIONBYNAME("ff_bubblePop");
                        _layerPlayer.addChild(_loc4_);
                        _loc4_.x = _fish[_loc2_]._clone.x;
                        _loc4_.y = _fish[_loc2_]._clone.y;
                        _fish.splice(_loc2_--,1);
                     }
                     _loc2_++;
                  }
                  if(_fishToSpawn.length > 0)
                  {
                     _fishSpawnTimer += _frameTime;
                     if(_fishSpawnTimer >= _spawnInterval)
                     {
                        _fishSpawnTimer -= _spawnInterval;
                        _fishToSpawn[0]._clone.visible = true;
                        _fish.push(_fishToSpawn[0]);
                        _fishToSpawn.splice(0,1);
                        if(_fishToSpawn.length == 0)
                        {
                           _fishSpawnTimer = _levels[_currentLevel % NUM_LEVELS][_currentWave - 1][_levels[_currentLevel % NUM_LEVELS][_currentWave - 1].length - 1];
                        }
                     }
                  }
                  else
                  {
                     _fishSpawnTimer -= _frameTime;
                     if(_fishSpawnTimer <= 0)
                     {
                        createNextWave();
                        _currentWave++;
                        if(_currentWave == _levels[_currentLevel % NUM_LEVELS].length)
                        {
                           _currentWave -= 2;
                        }
                     }
                  }
               }
            }
            else if(_gameState == 1)
            {
               if(_level_popup.loader.content.zoomOutSound)
               {
                  _level_popup.loader.content.zoomOutSound = false;
                  _soundMan.playByName(_soundNameNewLevelFadeOut);
               }
               if(_level_popup.loader.content.finished)
               {
                  _level_popup.loader.visible = false;
                  setGameState(2);
               }
            }
            else if(_gameState == 3)
            {
               if(!_pauseGame)
               {
                  showGameOverDlg();
               }
            }
            else if(_gameState == 4)
            {
               if(_score > _highScore)
               {
                  _highScore = _score;
               }
               if(!_pauseGame)
               {
                  showGameCompleteDlg2();
               }
            }
            else if(_gameState == 5)
            {
               if(_score > _highScore)
               {
                  _highScore = _score;
               }
            }
         }
      }
      
      public function createNextWave() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_levels[_currentLevel % NUM_LEVELS][_currentWave][0]);
         var _loc3_:Array = [];
         _loc2_ = 1;
         while(_loc2_ < _levels[_currentLevel % NUM_LEVELS][_currentWave].length - 2)
         {
            _loc3_.push(_levels[_currentLevel % NUM_LEVELS][_currentWave][_loc2_]);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _fishToSpawn.push(getFish(_loc3_[_loc2_ % _loc3_.length]));
            _loc2_++;
         }
         _fishSpawnTimer = 0;
         _spawnInterval = _levels[_currentLevel % NUM_LEVELS][_currentWave][_levels[_currentLevel % NUM_LEVELS][_currentWave].length - 2] / _fishToSpawn.length;
      }
      
      private function getWorldCoords(param1:Object) : Point
      {
         var _loc3_:Number = Number(param1.x);
         var _loc2_:Number = Number(param1.y);
         var _loc4_:* = param1;
         while(_loc4_.parent)
         {
            _loc4_ = _loc4_.parent;
            _loc3_ += _loc4_.x;
            _loc2_ += _loc4_.y;
         }
         return new Point(_loc3_,_loc2_);
      }
      
      public function getGrowthPoints(param1:int) : int
      {
         var _loc3_:int = _growthPoints[_player1._currentSize - param1] * 10;
         if(_scoreTimer > 0)
         {
            if(_scoreMultiplier < 6)
            {
               _scoreMultiplier++;
            }
         }
         else
         {
            _scoreMultiplier = 1;
         }
         _fishEaten++;
         _fishEatenThisLevel++;
         _scoreTimer = 1;
         _score += _loc3_ * _scoreMultiplier;
         LocalizationManager.translateIdAndInsert(_ui.loader.content.score,11552,_score.toString());
         var _loc2_:MovieClip = GETDEFINITIONBYNAME("FF_comboPopup");
         _loc2_.turnOn(_loc3_.toString() + " x " + _scoreMultiplier.toString());
         _layerPlayer.addChild(_loc2_);
         _loc2_.x = _player1._clone.x;
         _loc2_.y = _player1._clone.y;
         if(_score >= _nextBonus)
         {
            _nextBonus *= 2;
            _bonus = _scene.getLayer("bonus");
            _layerPlayer.addChild(_bonus.loader);
            _bonus.loader.x = Math.random() * 700 + 100;
            _bonus.loader.y = 650;
            _bonus.loader.scaleY = 0.5;
            _bonus.loader.scaleX = 0.5;
         }
         return _growthPoints[_player1._currentSize - param1];
      }
      
      public function boxCollisionTestLocal(param1:Object, param2:Object) : Boolean
      {
         var _loc4_:Object = {};
         var _loc3_:Object = {};
         _loc4_.x = param1.x * param1.parent.scaleX + param1.parent.x;
         _loc4_.y = param1.y + param1.parent.y;
         _loc4_.width = param1.width;
         _loc4_.height = param1.height;
         _loc3_.x = param2.x * param2.parent.scaleX + param2.parent.x;
         _loc3_.y = param2.y + param2.parent.y;
         _loc3_.width = param2.width;
         _loc3_.height = param2.height;
         return boxCollisionTest(_loc4_,_loc3_);
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
         var _loc15_:Number = Number(param1.x);
         var _loc11_:Number = Number(param1.y);
         var _loc13_:Number = param1.width * 0.5;
         var _loc18_:Number = param1.height * 0.5;
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
      
      private function loadComplete(param1:Event) : void
      {
         var _loc9_:Array = null;
         var _loc10_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc3_:String = param1.target.data;
         var _loc5_:Array = _loc3_.split(" ");
         var _loc4_:int = 1;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = -1;
         while(_loc4_ < _loc5_.length)
         {
            if(_loc5_[_loc4_] == "")
            {
               _loc9_ = _levels;
            }
            else
            {
               _loc9_ = this[_loc5_[_loc4_]];
            }
            _loc4_++;
            if(_loc9_ == _levels)
            {
               _loc2_++;
               if(_loc2_ == _levels.length)
               {
                  _loc9_.push([]);
                  _loc9_[_loc2_].push([]);
               }
            }
            _loc10_ = false;
            _loc8_ = false;
            _loc6_ = _loc7_ = 0;
            while(_loc9_ != null && (_loc5_[_loc4_].search("\n") == -1 || _loc8_))
            {
               if(_loc5_[_loc4_].search("\n") != -1 && _loc8_)
               {
                  _loc5_[_loc4_] = _loc5_[_loc4_].replace("\r\n","");
                  _loc5_[_loc4_] = _loc5_[_loc4_].replace(RegExp(/\t/g),"");
               }
               switch(_loc5_[_loc4_])
               {
                  case "[[":
                     _loc10_ = true;
                     _loc8_ = true;
                     break;
                  case "][":
                     _loc6_++;
                     _loc7_ = 0;
                     if(_loc9_ == _levels)
                     {
                        if(_loc6_ == _loc9_[_loc2_].length)
                        {
                           _loc9_[_loc2_].push([]);
                        }
                        break;
                     }
                     if(_loc6_ == _loc9_.length)
                     {
                        _loc9_.push([]);
                     }
                     break;
                  case "[":
                  case "=":
                  case "":
                     break;
                  default:
                     if(_loc9_ == _levels)
                     {
                        _loc9_[_loc2_][_loc6_][_loc7_++] = parseFloat(_loc5_[_loc4_]);
                        break;
                     }
                     if(_loc10_)
                     {
                        _loc9_[_loc6_][_loc7_++] = parseFloat(_loc5_[_loc4_]);
                        break;
                     }
                     _loc9_[_loc6_++] = parseFloat(_loc5_[_loc4_]);
                     break;
               }
               _loc4_++;
               if(_loc8_ && _loc5_[_loc4_].search("]]") != -1)
               {
                  _loc8_ = false;
               }
            }
            _loc4_++;
         }
         _loadComplete = true;
         NUM_LEVELS = _levels.length;
         if(!_sceneLoaded && _cacheEvent != null)
         {
            sceneLoaded(_cacheEvent);
         }
      }
      
      public function startGame() : void
      {
         _layerBackground.x = 0;
         _layerBackground.y = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _currentLevel = 0;
         _currentWave = 0;
         _fishSpawnTimer = 0;
         _respawnTimer = 0;
         _fishEaten = 0;
         _fishEatenThisLevel = 0;
         _lives = 3;
         _scoreMultiplier = 1;
         _scoreTimer = 1;
         _nextBonus = 25000;
         _fish = [];
         _fishPool = [];
         _fishToSpawn = [];
         _currentFact = Math.floor(Math.random() * _facts.length);
         LocalizationManager.translateIdAndInsert(_ui.loader.content.lives,11551,_lives.toString());
         LocalizationManager.translateIdAndInsert(_ui.loader.content.score,11552,_score.toString());
         LocalizationManager.translateIdAndInsert(_ui.loader.content.levelText,11548,(_currentLevel + 1).toString());
         loadFactImage();
         _player1 = new FeedingFrenzyFish(this,-1);
         setGameState(6);
      }
      
      public function resetGame(param1:Boolean = false) : void
      {
         stage.removeEventListener("keyDown",winKeyDown);
         hideDlg();
         if(_score > _highScore)
         {
            _highScore = _score;
            AchievementXtCommManager.requestSetUserVar(286,_highScore);
         }
         _player1._clone.alpha = 1;
         _currentLevel = -1;
         _fishEaten = 0;
         _score = 0;
         _lives = 3;
         _gemsTotal = 0;
         LocalizationManager.translateIdAndInsert(_ui.loader.content.lives,11553,_lives.toString());
         LocalizationManager.translateIdAndInsert(_ui.loader.content.score,11552,_score.toString());
         _player1._currentGrowthPoints = 0;
         updateGrowth();
         if(param1)
         {
            checkGrowthTarget(true,false,true);
            setGameState(6);
         }
         else
         {
            checkGrowthTarget(true);
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_NoReset
         }]);
         if(_loc1_)
         {
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameOverDlg() : void
      {
         stage.addEventListener("keyDown",continueKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Result",[{
            "name":"continue_btn",
            "f":showGameOverDlg2
         }]);
         if(_loc1_)
         {
            _loc1_.score.text = String(Math.floor(_score));
            _loc1_.result_pic.addChild(_factImageMediaObject);
            LocalizationManager.translateId(_loc1_.result_fact,_factStringId);
            _loc1_.x = 450;
            _loc1_.y = 275;
            _soundMan.playByName(_soundNameFunFactPopUp);
         }
      }
      
      private function showGameOverDlg2() : void
      {
         var _loc2_:int = 0;
         stage.removeEventListener("keyDown",continueKeyDown);
         hideDlg();
         loadFactImage();
         stage.addEventListener("keyDown",gameOverKeyDown);
         var _loc1_:MovieClip = showDlg("FF_GameOver",[{
            "name":"button_yes",
            "f":onExit_No
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.floor(_score / 500);
            addGemsToBalance(_loc2_ - _gemsTotal);
            LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_loc2_.toString());
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameCompleteDlg() : void
      {
         stage.addEventListener("keyDown",gameCompleteKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Result",[{
            "name":"continue_btn",
            "f":showGameCompleteDlg2
         }]);
         if(_loc1_)
         {
            _loc1_.score.text = String(Math.floor(_score));
            _loc1_.result_pic.addChild(_factImageMediaObject);
            LocalizationManager.translateId(_loc1_.result_fact,_factStringId);
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameCompleteDlg2() : void
      {
         stage.removeEventListener("keyDown",gameCompleteKeyDown);
         hideDlg();
         loadFactImage();
         stage.addEventListener("keyDown",gameOverKeyDown);
         var _loc1_:MovieClip = showDlg("FF_GreatJob",[{
            "name":"button_yes",
            "f":onExit_No
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showNextLevelDlg() : void
      {
         var _loc2_:int = 0;
         hideDlg();
         loadFactImage();
         stage.addEventListener("keyDown",nextLevelKeyDown);
         var _loc1_:MovieClip = showDlg("FF_Great_Job",[{
            "name":"button_nextlevel",
            "f":setNextLevel
         }]);
         if(_loc1_)
         {
            _loc2_ = Math.floor(_score / 500);
            addGemsToBalance(_loc2_ - _gemsTotal);
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11554,(_loc2_ - _gemsTotal).toString());
            _gemsTotal = _loc2_;
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Total,11549,_gemsTotal.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.text_hit,11556,_fishEatenThisLevel.toString());
            _fishEatenThisLevel = 0;
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function setNextLevel() : void
      {
         stage.removeEventListener("keyDown",nextLevelKeyDown);
         hideDlg();
         setGameState(1);
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",winKeyDown);
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
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         resetGame();
      }
      
      private function beginEndlessMode() : void
      {
         hideDlg();
         setGameState(1);
      }
      
      private function onExit_NoReset() : void
      {
         hideDlg();
      }
   }
}

