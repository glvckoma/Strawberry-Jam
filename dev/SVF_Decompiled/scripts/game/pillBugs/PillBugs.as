package game.pillBugs
{
   import Box2D.Collision.Shapes.b2CircleDef;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2PolygonDef;
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2World;
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PillBugs extends GameBase implements IMinigame
   {
      private static const SCORE_PEGTYPE1:int = 500;
      
      private static const SCORE_PEGTYPE2:int = 100;
      
      private static const SCORE_PEGTYPE3:int = 150;
      
      private static const SCORE_PEGTYPE4:int = 300;
      
      private static const SCORE_PEGTYPE5:int = 500;
      
      private static const SCORE_PEGTYPE1_ACCUMULATOR:int = 500;
      
      private static const SCORE_PEGTYPE1_ACCUMULATORMAX:int = 5000;
      
      private static const MAX_LEVELS:int = 29;
      
      private static const MAX_BALLS:int = 20;
      
      private static const SHOW_DEBUG:Boolean = false;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const DIFFICULTY_EASY:int = 1;
      
      private static const DIFFICULTY_MEDIUM:int = 2;
      
      private static const DIFFICULTY_HARD:int = 3;
      
      private static const AIM_REFERENCE_SPACING:Number = 25;
      
      private static const AIM_REFERENCE_LINE_LENGTH:Number = 125;
      
      private var _world:b2World;
      
      private var _iterations:int = 10;
      
      private var _timeStep:Number = 0.041666666666666664;
      
      private var _phyScale:Number = 0.03333333333333333;
      
      private var _contactListener:PillBugContactListener;
      
      private var _phyWidth:int = 900;
      
      private var _phyHeight:int = 750;
      
      private var _difficulty:int;
      
      public var _factsOrder:Array;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _greatJobPopup:MovieClip;
      
      private var _factImageMediaObject:MovieClip;
      
      private var _background:Sprite;
      
      private var _playfield:Sprite;
      
      private var _foreground:Sprite;
      
      private var _launcherLayer:Sprite;
      
      private var _offset:Point;
      
      private var _clonesToRelease:Array;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _pillBugTypeToHit:int;
      
      private var _totalBugsAvailableToHit:int;
      
      private var _totalBugsToHit:int;
      
      private var _totalBugsHit:int;
      
      private var _level:int;
      
      private var _totalLevels:int;
      
      public var _soundMan:SoundManager;
      
      public var _displayAchievementTimer:Number;
      
      private var _ballLauncherAimVelocity:Number;
      
      private var _restitutionBugType1:Number = 72;
      
      private var _restitutionBugType2:Number = 78;
      
      private var _restitutionBugType3:Number = 80;
      
      private var _restitutionBugType4:Number = 82;
      
      private var _restitutionBugType5:Number = 84;
      
      private var _restitutionBonusItem:Number = 86;
      
      private var _restitutionWall:Number = 90;
      
      private var _gravity:Number = 22;
      
      private var _ballSpeed:Number = 180;
      
      private var _theBalls:Array;
      
      private var _balls:int;
      
      private var _scoreAccumulator:int;
      
      private var _totalScore:int;
      
      private var _levelScore:int;
      
      private var _levelGemsEarned:int;
      
      private var _gemsEarned:int;
      
      private var _aimReferenceBall:Object;
      
      private var _aimReferenceBallsDisplayed:Array;
      
      private var _launcher:Object;
      
      private var _referenceAim:Number;
      
      private var _launcherAim:Number;
      
      private var _initLauncherAim:Boolean;
      
      private var _launcherLength:Number;
      
      private var _levelSelectSet:int;
      
      private var _levelSelectPopup:MovieClip;
      
      private var _levelPopup:MovieClip;
      
      private var _comboPopups:Array;
      
      private var _rightArrowDown:Boolean;
      
      private var _leftArrowDown:Boolean;
      
      private var _turnOffAimReferenceTimer:Number;
      
      private var _bInit:Boolean;
      
      private var _tutorialHasBeenShown:Boolean;
      
      public var _levelData:PillBugsData;
      
      public var _bugsToRemove:Array;
      
      public var _bugsToHide:Array;
      
      public var _allBugsCleared:Boolean;
      
      private var _uiLeft:MovieClip;
      
      private var _uiRight:MovieClip;
      
      private var _remainingPillBugBonus:int;
      
      private var _debugSliderBallSpeed:Object;
      
      private var _debugSliderGravity:Object;
      
      private var _debugSliderRestitution1:Object;
      
      private var _debugSliderRestitution2:Object;
      
      private var _debugSliderRestitution3:Object;
      
      private var _debugSliderRestitution4:Object;
      
      private var _debugSliderRestitution5:Object;
      
      private var _debugSliderBonusItem:Object;
      
      private var _debugSliderWall:Object;
      
      protected var _loadLevelBtn:MovieClip;
      
      protected var _saveLevelBtn:MovieClip;
      
      public var _scores:Array;
      
      public var _stars:Array;
      
      public var _SFX_PillBugs_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var pillbugsLevelConverter:PillBugsLevelConverter;
      
      private var _soundsSmallBugHit:Array;
      
      private var _soundsBigBugHit:Array;
      
      private var _soundsSmallBugHitIndex:int;
      
      private var _soundsBigBugHitIndex:int;
      
      private var _rotation:Number;
      
      private var _prevMouseX:Number;
      
      private var _prevMouseY:Number;
      
      private var _soundNameGoldBug:String = PillBugsData._audio[0];
      
      private var _soundNameGoldenBugAward:String = PillBugsData._audio[1];
      
      private var _soundNameGreenBug:String = PillBugsData._audio[2];
      
      private var _soundNameLaunch:String = PillBugsData._audio[3];
      
      private var _soundNameSmall1:String = PillBugsData._audio[4];
      
      private var _soundNameSmall2:String = PillBugsData._audio[5];
      
      private var _soundNameSmall3:String = PillBugsData._audio[6];
      
      private var _soundNameStingerFail:String = PillBugsData._audio[7];
      
      private var _soundNameStingerSuccess:String = PillBugsData._audio[8];
      
      private var _soundNameBigBug1:String = PillBugsData._audio[9];
      
      private var _soundNameBigBug2:String = PillBugsData._audio[10];
      
      private var _soundNameBigBug3:String = PillBugsData._audio[11];
      
      private var _soundNameBigBug4:String = PillBugsData._audio[12];
      
      private var _soundNameBallOut:String = PillBugsData._audio[13];
      
      private var _soundNameImpWall:String = PillBugsData._audio[14];
      
      private var _soundNameImpPlants1:String = PillBugsData._audio[15];
      
      private var _soundNameImpPlants2:String = PillBugsData._audio[16];
      
      private var _soundNameTextPopup:String = PillBugsData._audio[17];
      
      private var _soundNameLevelSelectSlide:String = PillBugsData._audio[18];
      
      private var _soundNameMeter:String = PillBugsData._audio[19];
      
      public function PillBugs()
      {
         super();
         _levelData = new PillBugsData();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_PillBugs_Music = _soundMan.addStream("aj_mus_pillBug",0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldBug],_soundNameGoldBug,1.15);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldenBugAward],_soundNameGoldenBugAward,1.23);
         _soundMan.addSoundByName(_audioByName[_soundNameGreenBug],_soundNameGreenBug,1.8);
         _soundMan.addSoundByName(_audioByName[_soundNameLaunch],_soundNameLaunch,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall1],_soundNameSmall1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall2],_soundNameSmall2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall3],_soundNameSmall3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.76);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerSuccess],_soundNameStingerSuccess,0.72);
         _soundMan.addSoundByName(_audioByName[_soundNameBigBug1],_soundNameBigBug1,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameBigBug2],_soundNameBigBug2,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameBigBug3],_soundNameBigBug3,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameBigBug4],_soundNameBigBug4,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNameBallOut],_soundNameBallOut,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameImpWall],_soundNameImpWall,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameImpPlants1],_soundNameImpPlants1,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameImpPlants2],_soundNameImpPlants2,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameTextPopup],_soundNameTextPopup,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLevelSelectSlide],_soundNameLevelSelectSlide,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameMeter],_soundNameMeter,0.3);
         _soundsSmallBugHit = new Array(_soundNameSmall1,_soundNameSmall2,_soundNameSmall3);
         _soundsBigBugHit = new Array(_soundNameBigBug1,_soundNameBigBug2,_soundNameBigBug3,_soundNameBigBug4);
         _soundsSmallBugHitIndex = _soundsSmallBugHit.length;
         _soundsBigBugHitIndex = _soundsBigBugHit.length;
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         init();
      }
      
      private function init() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _displayAchievementTimer = 0;
         _turnOffAimReferenceTimer = 0;
         _factsOrder = [];
         _loc3_ = 0;
         while(_loc3_ < _levelData._facts.length)
         {
            _factsOrder.push(_loc3_);
            _loc3_++;
         }
         _factsOrder = randomizeArray(_factsOrder);
         _factsIndex = 0;
         _clonesToRelease = [];
         _lastTime = getTimer();
         _level = 1;
         _world = null;
         _levelPopup = null;
         _gemsEarned = 0;
         _scores = [];
         _stars = [];
         _loc3_ = 1;
         while(_loc3_ <= 30)
         {
            _loc1_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(217 + (_loc3_ - 1)));
            _loc2_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(247 + (_loc3_ - 1)));
            if(_loc1_ < 0)
            {
               _loc1_ = 0;
            }
            _scores[_loc3_] = _loc1_;
            _stars[_loc3_] = _loc2_;
            _loc3_++;
         }
         _tutorialHasBeenShown = _stars[1] >= 1;
         if(!_bInit)
         {
            _theBalls = [];
            _comboPopups = [];
            _background = new Sprite();
            _playfield = new Sprite();
            _foreground = new Sprite();
            _launcherLayer = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_playfield);
            addChild(_foreground);
            addChild(_launcherLayer);
            addChild(_guiLayer);
            loadScene("PillBugs/room_main.xroom",PillBugsData._audio);
            _mediaObjectHelper = null;
            _loadingImage = false;
            _greatJobPopup = null;
            _factImageMediaObject = null;
            _rightArrowDown = false;
            _leftArrowDown = false;
            _initLauncherAim = true;
            _launcherAim = 0;
            _bInit = true;
         }
      }
      
      public function loadNextFactImage() : void
      {
         if(!_loadingImage)
         {
            _factsIndex++;
            if(_factsIndex >= _factsOrder.length)
            {
               _factsIndex = 0;
            }
            _loadingImage = true;
            if(_mediaObjectHelper != null)
            {
               _mediaObjectHelper.destroy();
            }
            _mediaObjectHelper = new MediaHelper();
            _mediaObjectHelper.init(_levelData._facts[_factsOrder[_factsIndex]].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         if(_factImageMediaObject != null && _greatJobPopup)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
         }
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
         if(_greatJobPopup)
         {
            _greatJobPopup.result_pic.addChild(_factImageMediaObject);
         }
         _loadingImage = false;
      }
      
      public function message(param1:Array) : void
      {
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function exit() : void
      {
         if(_totalGameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(277,1);
         }
         if(_aimReferenceBallsDisplayed)
         {
            while(_aimReferenceBallsDisplayed.length > 0)
            {
               if(Loader(_aimReferenceBallsDisplayed[0].loader).parent)
               {
                  Loader(_aimReferenceBallsDisplayed[0].loader).parent.removeChild(_aimReferenceBallsDisplayed[0].loader);
               }
               _scene.releaseCloneAsset(_aimReferenceBallsDisplayed[0].loader);
               _aimReferenceBallsDisplayed.splice(0,1);
            }
            _aimReferenceBallsDisplayed = null;
         }
         while(_clonesToRelease.length > 0)
         {
            _scene.releaseCloneAsset(_clonesToRelease[0].loader);
            _clonesToRelease.splice(0,1);
         }
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",greatJobKeyDown);
         stage.removeEventListener("keyDown",resultsKeyDown);
         stage.removeEventListener("keyDown",hideTutKeyDown);
         removeEventListener("enterFrame",Heartbeat);
         stage.removeEventListener("keyDown",onKeyDown);
         stage.removeEventListener("keyUp",onKeyUp);
         stage.removeEventListener("click",onMouseClick);
         _world = null;
         _launcherLayer.removeChild(_launcher.loader);
         removeLayer(_background);
         removeLayer(_playfield);
         removeLayer(_launcherLayer);
         removeLayer(_foreground);
         removeLayer(_guiLayer);
         _background = null;
         _playfield = null;
         _foreground = null;
         _launcherLayer = null;
         _guiLayer = null;
         MinigameManager.leave();
         _bInit = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc12_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_PillBugs_Music,0,999999);
         _ballLauncherAimVelocity = 0;
         addEventListener("enterFrame",Heartbeat);
         stage.addEventListener("keyDown",onKeyDown);
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("click",onMouseClick);
         _launcherLength = 75;
         _launcher = _scene.getLayer("launcher");
         _launcher.loader.x = 0;
         _launcher.loader.y = 0;
         _launcherLayer.addChild(_launcher.loader);
         _launcherLayer.x = 450;
         _launcherLayer.y = -10;
         _uiLeft = GETDEFINITIONBYNAME("PB_leftUI");
         _uiLeft.x = 0;
         _uiLeft.y = 0;
         _uiRight = GETDEFINITIONBYNAME("PB_rightUI");
         _uiRight.x = 0;
         _uiRight.y = 0;
         _guiLayer.addChild(_uiLeft);
         _guiLayer.addChild(_uiRight);
         _loc12_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         var _loc11_:Array = _scene.getActorList("ActorCollisionPoint");
         var _loc4_:Array = _scene.getActorList("ActorSpawn");
         var _loc7_:Array = _scene.getActorList("ActorVolume");
         var _loc3_:Point = new Point();
         var _loc2_:Point = new Point();
         _totalLevels = _levelData._data.length;
         _totalGameTime = 0;
         showLevelDifficultyPopup();
         super.sceneLoaded(param1);
      }
      
      public function onDebugSliderBallSpeedLoaded(param1:Event) : void
      {
         _debugSliderBallSpeed.loader.content.sliderRange(1,250,_ballSpeed,"Ball Speed");
         param1.target.removeEventListener("complete",onDebugSliderBallSpeedLoaded);
      }
      
      public function onDebugSliderGravityLoaded(param1:Event) : void
      {
         _debugSliderGravity.loader.content.sliderRange(1,50,_gravity,"Gravity");
         param1.target.removeEventListener("complete",onDebugSliderGravityLoaded);
      }
      
      public function onDebugSliderRestitution1Loaded(param1:Event) : void
      {
         _debugSliderRestitution1.loader.content.sliderRange(1,100,_restitutionBugType1,"BugType 1 Bounce");
         param1.target.removeEventListener("complete",onDebugSliderRestitution1Loaded);
      }
      
      public function onDebugSliderRestitution2Loaded(param1:Event) : void
      {
         _debugSliderRestitution2.loader.content.sliderRange(1,100,_restitutionBugType2,"BugType 2 Bounce");
         param1.target.removeEventListener("complete",onDebugSliderRestitution2Loaded);
      }
      
      public function onDebugSliderRestitution3Loaded(param1:Event) : void
      {
         _debugSliderRestitution3.loader.content.sliderRange(1,100,_restitutionBugType3,"BugType 3 Bounce");
         param1.target.removeEventListener("complete",onDebugSliderRestitution3Loaded);
      }
      
      public function onDebugSliderRestitution4Loaded(param1:Event) : void
      {
         _debugSliderRestitution4.loader.content.sliderRange(1,100,_restitutionBugType4,"BugType 4 Bounce");
         param1.target.removeEventListener("complete",onDebugSliderRestitution4Loaded);
      }
      
      public function onDebugSliderRestitution5Loaded(param1:Event) : void
      {
         _debugSliderRestitution5.loader.content.sliderRange(1,100,_restitutionBugType5,"BugType 5 Bounce");
         param1.target.removeEventListener("complete",onDebugSliderRestitution5Loaded);
      }
      
      public function onDebugSliderBonusItemLoaded(param1:Event) : void
      {
         _debugSliderBonusItem.loader.content.sliderRange(1,100,_restitutionBonusItem,"Bonus Items Bounce");
         param1.target.removeEventListener("complete",onDebugSliderBonusItemLoaded);
      }
      
      public function onDebugSliderWallLoaded(param1:Event) : void
      {
         _debugSliderWall.loader.content.sliderRange(1,100,_restitutionWall,"Wall Bounce");
         param1.target.removeEventListener("complete",onDebugSliderWallLoaded);
      }
      
      public function onPillBugLoaded(param1:Event) : void
      {
         param1.target.content.reset();
         param1.target.removeEventListener("complete",onPillBugLoaded);
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
      
      private function setupLevel(param1:int) : void
      {
         var _loc27_:int = 0;
         var _loc29_:Object = null;
         var _loc36_:String = null;
         var _loc37_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc38_:String = null;
         var _loc3_:b2Body = null;
         var _loc8_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc7_:b2Body = null;
         var _loc5_:b2BodyDef = null;
         var _loc32_:Number = NaN;
         var _loc23_:Array = null;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc2_:int = 0;
         var _loc28_:Number = NaN;
         var _loc34_:Object = null;
         var _loc30_:int = 0;
         var _loc31_:int = 0;
         var _loc26_:Array = _scene.getActorList("ActorVolume");
         var _loc16_:Array = _scene.getActorList("ActorLayer");
         var _loc24_:b2PolygonDef = new b2PolygonDef();
         var _loc35_:b2BodyDef = new b2BodyDef();
         var _loc25_:b2Vec2 = new b2Vec2();
         var _loc6_:b2MassData = new b2MassData();
         var _loc44_:Object = {};
         var _loc21_:Object = {};
         var _loc43_:b2CircleDef = new b2CircleDef();
         _loc44_.name = "wall";
         _loc21_.name = "objectCollision";
         _totalBugsToHit = 10;
         _pillBugTypeToHit = 1;
         _balls = 20;
         if(param1 == -1)
         {
            _loc2_ = int(pillbugsLevelConverter._output["level"]);
            _loc23_ = pillbugsLevelConverter._output["gameboard"];
            _loc9_ = int(pillbugsLevelConverter._output["x"]);
            _loc12_ = int(pillbugsLevelConverter._output["y"]);
            if(pillbugsLevelConverter._output["pegs"] != null)
            {
               _totalBugsToHit = pillbugsLevelConverter._output["pegs"];
            }
            switch(_difficulty - 1)
            {
               case 0:
                  _balls = pillbugsLevelConverter._output["easy"];
                  _totalBugsToHit = _totalBugsToHit / 0.25 * 0.1;
                  break;
               case 1:
                  _balls = pillbugsLevelConverter._output["medium"];
                  break;
               case 2:
                  _balls = pillbugsLevelConverter._output["hard"];
                  _totalBugsToHit = _totalBugsToHit / 0.25 * 0.4;
            }
         }
         else
         {
            _loc23_ = _levelData._data[param1][0].gameboard;
            _loc9_ = int(_levelData._data[param1][0].sizeX);
            _loc12_ = int(_levelData._data[param1][0].sizeY);
            _loc2_ = int(_levelData._data[param1][0].level);
            _totalBugsToHit = _levelData._data[param1][0].pegs;
            switch(_difficulty - 1)
            {
               case 0:
                  _balls = _levelData._data[param1][0].easy;
                  _totalBugsToHit = _totalBugsToHit / 0.25 * 0.1;
                  break;
               case 1:
                  _balls = _levelData._data[param1][0].medium;
                  break;
               case 2:
                  _balls = _levelData._data[param1][0].hard;
                  _totalBugsToHit = _totalBugsToHit / 0.25 * 0.4;
            }
         }
         _totalBugsAvailableToHit = _totalBugsToHit;
         _offset = new Point();
         _loc38_ = "background" + _loc2_;
         for each(_loc29_ in _loc16_)
         {
            if(_loc29_.name == _loc38_)
            {
               break;
            }
         }
         _offset.x = int(_loc29_.x);
         _offset.y = int(_loc29_.y);
         _loc29_.s.x = _loc29_.x - _offset.x;
         _loc29_.s.y = _loc29_.y - _offset.y;
         _background.addChild(_loc29_.s);
         _loc36_ = "exit" + _loc2_;
         var _loc22_:String = "oc" + _loc2_ + "_";
         var _loc40_:String = "o" + _loc2_ + "_";
         var _loc13_:String = "gameboard" + _loc2_;
         var _loc41_:int = 99999;
         var _loc42_:int = 99999;
         var _loc14_:int = -99999;
         var _loc15_:int = -99999;
         for each(_loc29_ in _loc26_)
         {
            if(_loc29_.name == _loc36_)
            {
               _loc35_.position.Set(0,0);
               _loc35_.userData = _loc29_;
               _loc24_.vertices = [];
               _loc27_ = 0;
               while(_loc27_ < _loc29_.points.length - 1)
               {
                  _loc37_ = (_loc29_.points[_loc27_].x - _offset.x) * _phyScale;
                  _loc39_ = (_loc29_.points[_loc27_].y - _offset.y) * _phyScale;
                  _loc24_.vertices.push(new b2Vec2(_loc37_,_loc39_));
                  _loc27_++;
               }
               _loc24_.isSensor = true;
               _loc24_.vertexCount = _loc24_.vertices.length;
               _loc3_ = _world.CreateBody(_loc35_);
               _loc3_.CreateShape(_loc24_);
               _loc3_.SetMassFromShapes();
            }
            else if(_loc29_.name == _loc13_)
            {
               _loc27_ = 0;
               while(_loc27_ < _loc29_.points.length - 1)
               {
                  if(_loc29_.points[_loc27_].x - _offset.x < _loc41_)
                  {
                     _loc41_ = _loc29_.points[_loc27_].x - _offset.x;
                  }
                  if(_loc29_.points[_loc27_].x - _offset.x > _loc14_)
                  {
                     _loc14_ = _loc29_.points[_loc27_].x - _offset.x;
                  }
                  if(_loc29_.points[_loc27_].y - _offset.y < _loc42_)
                  {
                     _loc42_ = _loc29_.points[_loc27_].y - _offset.y;
                  }
                  if(_loc29_.points[_loc27_].y - _offset.y > _loc15_)
                  {
                     _loc15_ = _loc29_.points[_loc27_].y - _offset.y;
                  }
                  _loc8_ = Math.sqrt((_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x) * (_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x) + (_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y) * (_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y)) / 2;
                  _loc25_.x = (_loc29_.points[_loc27_].x + _loc29_.points[_loc27_ + 1].x) / 2 - _offset.x;
                  _loc25_.y = (_loc29_.points[_loc27_].y + _loc29_.points[_loc27_ + 1].y) / 2 - _offset.y;
                  _loc17_ = Math.atan2(_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y,_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x);
                  _loc35_.position.Set(_loc25_.x * _phyScale,_loc25_.y * _phyScale);
                  _loc24_.SetAsOrientedBox(_loc8_ * _phyScale,1 * _phyScale,new b2Vec2(0,0),_loc17_);
                  _loc24_.restitution = _restitutionWall / 100;
                  _loc24_.isSensor = false;
                  _loc35_.userData = _loc44_;
                  _loc3_ = _world.CreateBody(_loc35_);
                  _loc3_.CreateShape(_loc24_);
                  _loc3_.SetMassFromShapes();
                  _loc27_++;
               }
            }
            else if(_loc29_.name.search(_loc22_) == 0)
            {
               _loc27_ = 0;
               while(_loc27_ < _loc29_.points.length - 1)
               {
                  _loc8_ = Math.sqrt((_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x) * (_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x) + (_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y) * (_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y)) / 2;
                  _loc25_.x = (_loc29_.points[_loc27_].x + _loc29_.points[_loc27_ + 1].x) / 2 - _offset.x;
                  _loc25_.y = (_loc29_.points[_loc27_].y + _loc29_.points[_loc27_ + 1].y) / 2 - _offset.y;
                  _loc17_ = Math.atan2(_loc29_.points[_loc27_].y - _loc29_.points[_loc27_ + 1].y,_loc29_.points[_loc27_].x - _loc29_.points[_loc27_ + 1].x);
                  _loc35_.position.Set(_loc25_.x * _phyScale,_loc25_.y * _phyScale);
                  _loc24_.SetAsOrientedBox(_loc8_ * _phyScale,1 * _phyScale,new b2Vec2(0,0),_loc17_);
                  _loc24_.restitution = _restitutionWall / 100;
                  _loc35_.userData = _loc21_;
                  _loc24_.isSensor = false;
                  _loc3_ = _world.CreateBody(_loc35_);
                  _loc3_.CreateShape(_loc24_);
                  _loc3_.SetMassFromShapes();
                  _loc27_++;
               }
            }
         }
         for each(_loc29_ in _loc16_)
         {
            if(_loc29_.name.search(_loc40_) == 0)
            {
               _loc29_.s.x = _loc29_.x - _offset.x;
               _loc29_.s.y = _loc29_.y - _offset.y;
               if(_loc29_.flip == 1)
               {
                  _loc29_.s.scaleX = -1;
                  _loc29_.s.x += _loc29_.s.content.width;
               }
               _background.addChild(_loc29_.s);
            }
         }
         var _loc4_:int = 0;
         var _loc10_:Array = [];
         _loc39_ = 0;
         while(_loc39_ < _loc23_.length)
         {
            _loc37_ = 0;
            while(_loc37_ < _loc23_[_loc39_].length)
            {
               if(_loc23_[_loc39_][_loc37_] != 0)
               {
                  if(_loc23_[_loc39_][_loc37_] == 2 || _loc23_[_loc39_][_loc37_] == 3 || _loc23_[_loc39_][_loc37_] == 4 || _loc23_[_loc39_][_loc37_] == 5)
                  {
                     _loc10_.push(_loc4_);
                     _loc4_++;
                  }
               }
               _loc37_++;
            }
            _loc39_++;
         }
         var _loc45_:Array = randomizeArray(_loc10_);
         _loc45_ = randomizeArray(_loc45_);
         _loc45_ = randomizeArray(_loc45_);
         _loc10_ = _loc45_.slice(0,_totalBugsAvailableToHit);
         _loc10_.sort(16);
         var _loc19_:int = 0;
         var _loc33_:int = 0;
         _totalBugsToHit = 0;
         _loc39_ = 0;
         while(_loc39_ < _loc23_.length)
         {
            _loc37_ = 0;
            while(_loc37_ < _loc23_[_loc39_].length)
            {
               if(_loc23_[_loc39_][_loc37_] != 0)
               {
                  switch(_loc23_[_loc39_][_loc37_])
                  {
                     case 2:
                     case 3:
                     case 4:
                     case 5:
                        if(_loc19_ == _loc10_[_totalBugsToHit])
                        {
                           _totalBugsToHit++;
                        }
                        else if(_loc23_[_loc39_][_loc37_] == 2)
                        {
                           _loc33_++;
                        }
                        break;
                  }
                  _loc19_++;
               }
               _loc37_++;
            }
            _loc39_++;
         }
         var _loc11_:int = -1;
         var _loc18_:int = -1;
         var _loc20_:int = -1;
         if(_loc33_ == 1)
         {
            _loc11_ = 0;
         }
         else if(_loc33_ == 2)
         {
            _loc11_ = 0;
            _loc18_ = 1;
         }
         else if(_loc33_ == 3)
         {
            _loc11_ = 0;
            _loc18_ = 1;
            _loc20_ = 2;
         }
         else if(_loc33_ > 3)
         {
            _loc11_ = Math.random() * _loc33_;
            while(true)
            {
               _loc18_ = Math.random() * _loc33_;
               if(_loc18_ != _loc11_)
               {
                  break;
               }
            }
            while(true)
            {
               _loc20_ = Math.random() * _loc33_;
               if(!(_loc20_ == _loc11_ || _loc20_ == _loc18_))
               {
                  break;
               }
            }
         }
         _totalBugsToHit = 0;
         _loc19_ = 0;
         _loc4_ = 0;
         _loc39_ = 0;
         while(_loc39_ < _loc23_.length)
         {
            _loc37_ = 0;
            while(_loc37_ < _loc23_[_loc39_].length)
            {
               if(_loc23_[_loc39_][_loc37_] != 0)
               {
                  switch(_loc23_[_loc39_][_loc37_])
                  {
                     case 2:
                     case 3:
                     case 4:
                     case 5:
                        if(_loc19_ == _loc10_[_totalBugsToHit])
                        {
                           if(_loc23_[_loc39_][_loc37_] == 2)
                           {
                              _loc28_ = _restitutionBugType2;
                              _loc38_ = "peg2a";
                              _loc4_++;
                           }
                           else if(_loc23_[_loc39_][_loc37_] == 3)
                           {
                              _loc28_ = _restitutionBugType3;
                              _loc38_ = "peg3a";
                              _loc4_++;
                           }
                           else if(_loc23_[_loc39_][_loc37_] == 4)
                           {
                              _loc28_ = _restitutionBugType4;
                              _loc38_ = "peg4a";
                              _loc4_++;
                           }
                           else if(_loc23_[_loc39_][_loc37_] == 5)
                           {
                              _loc28_ = _restitutionBugType5;
                              _loc38_ = "peg5a";
                              _loc4_++;
                           }
                           _totalBugsToHit++;
                        }
                        else if(_loc23_[_loc39_][_loc37_] == 2)
                        {
                           if(_loc23_[_loc39_][_loc37_] == 2)
                           {
                              if(_loc11_ == 0 || _loc18_ == 0 || _loc20_ == 0)
                              {
                                 _loc28_ = _restitutionBonusItem;
                                 _loc38_ = "spawn";
                              }
                              else
                              {
                                 _loc28_ = _restitutionBugType2;
                                 _loc38_ = "peg2";
                              }
                              _loc11_--;
                              _loc18_--;
                              _loc20_--;
                           }
                        }
                        else if(_loc23_[_loc39_][_loc37_] == 3)
                        {
                           _loc28_ = _restitutionBugType3;
                           _loc38_ = "peg3";
                        }
                        else if(_loc23_[_loc39_][_loc37_] == 4)
                        {
                           _loc28_ = _restitutionBugType4;
                           _loc38_ = "peg4";
                        }
                        else if(_loc23_[_loc39_][_loc37_] == 5)
                        {
                           _loc28_ = _restitutionBugType5;
                           _loc38_ = "peg5";
                        }
                        _loc19_++;
                        break;
                     case 101:
                     case 102:
                        _loc28_ = _restitutionBonusItem;
                        _loc38_ = "spawn";
                        break;
                     case 103:
                        _loc28_ = _restitutionBonusItem;
                        _loc38_ = "gembonus";
                        break;
                     case 105:
                        _loc28_ = _restitutionBonusItem;
                        _loc38_ = "freeball";
                        break;
                     default:
                        _loc28_ = _restitutionBugType2;
                        _loc38_ = "peg2a";
                  }
                  _loc34_ = _scene.getLayer(_loc38_);
                  _loc30_ = _loc41_ + _loc9_ * _loc37_ + _loc9_ / 2 - _loc34_.loader.content.width / 2;
                  _loc31_ = _loc42_ + _loc12_ * _loc39_ + _loc12_ / 2 - _loc34_.loader.content.height / 2;
                  _loc34_.loader.content.reset();
                  _loc29_ = _scene.cloneAsset(_loc38_);
                  _loc29_.loader.contentLoaderInfo.addEventListener("complete",onPillBugLoaded);
                  _loc29_.name = _loc38_;
                  _loc29_.s = _loc29_.loader;
                  _loc29_.loader.x = _loc30_;
                  _loc29_.loader.y = _loc31_;
                  _clonesToRelease.push(_loc29_);
                  _loc43_ = new b2CircleDef();
                  _loc43_.restitution = _loc28_ / 100;
                  _loc32_ = Math.sqrt(_loc34_.width * _loc34_.width + _loc34_.height * _loc34_.height) * 0.4;
                  _loc32_ = _loc32_ * 0.7;
                  _loc43_.radius = _loc32_ * _phyScale;
                  _loc5_ = new b2BodyDef();
                  _loc5_.position.x = 300;
                  _loc5_.position.y = 300;
                  _loc5_.position.x = (_loc29_.loader.x + _loc34_.loader.content.collision.x) * _phyScale;
                  _loc5_.position.y = (_loc29_.loader.y + _loc34_.loader.content.collision.y) * _phyScale;
                  _loc5_.userData = _loc29_;
                  _loc43_.isSensor = false;
                  _loc7_ = _world.CreateBody(_loc5_);
                  _loc7_.CreateShape(_loc43_);
                  _loc7_.SetMassFromShapes();
                  _background.addChild(_loc29_.loader);
               }
               _loc37_++;
            }
            _loc39_++;
         }
         _totalBugsToHit = _loc4_;
         _totalBugsAvailableToHit = _totalBugsToHit;
         if(pillbugsLevelConverter)
         {
            pillbugsLevelConverter._outputReadyState = 2;
         }
      }
      
      private function createBall(param1:Boolean, param2:int = -1, param3:int = -1, param4:Number = 0, param5:Number = 0) : Boolean
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:b2Body = null;
         var _loc6_:b2BodyDef = null;
         var _loc14_:b2CircleDef = null;
         var _loc13_:b2Vec2 = null;
         var _loc12_:* = NaN;
         var _loc11_:* = NaN;
         if(param1 || _levelPopup == null && _balls > 0)
         {
            _loc7_ = {};
            _loc8_ = _scene.getLayer("ball_default");
            _loc7_.clone = _scene.cloneAsset("ball_default");
            if(param1)
            {
               _loc7_.clone.name = "aimBall";
            }
            else
            {
               _loc7_.clone.name = "ball";
            }
            _loc14_ = new b2CircleDef();
            _loc12_ = _ballSpeed;
            _loc11_ = _ballSpeed;
            if(param3 < 0)
            {
               if(_referenceAim >= 0)
               {
                  _loc7_.clone.loader.x = _launcherLayer.x + _launcher.loader.x - _launcherLength * Math.sin(_referenceAim * 3.141592653589793 / 180) - _loc7_.clone.width / 2;
                  _loc7_.clone.loader.y = _launcherLayer.y + (_launcher.loader.y + _launcherLength * Math.cos(_referenceAim * 3.141592653589793 / 180)) - _loc7_.clone.height / 2;
                  if(_loc7_.clone.loader.y < 2)
                  {
                     _loc7_.clone.loader.y = 2;
                  }
                  _loc12_ *= -Math.sin(_referenceAim * 3.141592653589793 / 180);
                  _loc11_ *= Math.cos(_referenceAim * 3.141592653589793 / 180);
               }
               else
               {
                  _loc7_.clone.loader.x = _launcherLayer.x + _launcher.loader.x + _launcherLength * Math.sin(-_referenceAim * 3.141592653589793 / 180) - _loc7_.clone.width / 2;
                  _loc7_.clone.loader.y = _launcherLayer.y + (_launcher.loader.y + _launcherLength * Math.cos(-_referenceAim * 3.141592653589793 / 180)) - _loc7_.clone.height / 2;
                  if(_loc7_.clone.loader.y < 2)
                  {
                     _loc7_.clone.loader.y = 2;
                  }
                  _loc12_ *= Math.sin(-_referenceAim * 3.141592653589793 / 180);
                  _loc11_ *= Math.cos(-_referenceAim * 3.141592653589793 / 180);
               }
            }
            else
            {
               _loc7_.clone.loader.x = param2;
               _loc7_.clone.loader.y = param3;
               _loc12_ = param4;
               _loc11_ = param5;
            }
            _loc13_ = new b2Vec2(_loc7_.clone.loader.x + _loc7_.clone.width / 2,_loc7_.clone.loader.y + _loc7_.clone.height / 2);
            _loc13_.x = _loc13_.x * _phyScale;
            _loc13_.y *= _phyScale;
            _loc6_ = new b2BodyDef();
            _loc6_.position.x = _loc13_.x;
            _loc6_.position.y = _loc13_.y;
            _loc14_.radius = _loc7_.clone.height * 0.5 * _phyScale;
            _loc14_.density = 1;
            _loc14_.friction = 0.01;
            _loc14_.restitution = 0;
            _loc6_.userData = _loc7_.clone;
            _loc9_ = _world.CreateBody(_loc6_);
            if(_loc9_)
            {
               _loc9_.CreateShape(_loc14_);
               _loc9_.SetMassFromShapes();
               if(param1)
               {
                  _aimReferenceBall = _loc7_;
               }
               else
               {
                  _theBalls.push(_loc7_);
                  _playfield.addChild(_loc6_.userData.loader);
               }
               _loc9_.m_force = new b2Vec2(_loc12_,_loc11_);
               _loc7_.body = _loc9_;
            }
            return true;
         }
         return false;
      }
      
      private function Heartbeat(param1:Event) : void
      {
         var _loc7_:int = 0;
         var _loc12_:Object = null;
         var _loc4_:Object = null;
         var _loc3_:b2Body = null;
         var _loc2_:b2Body = null;
         var _loc9_:Loader = null;
         var _loc10_:Number = NaN;
         var _loc11_:Matrix = null;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Number = (getTimer() - _lastTime) / 1000;
         _totalGameTime += _loc5_;
         _lastTime = getTimer();
         if(pillbugsLevelConverter && pillbugsLevelConverter._outputReadyState == 1)
         {
            startLevel(-1);
         }
         if(_pauseGame)
         {
            return;
         }
         if(_bugsToHide)
         {
            _loc7_ = _bugsToHide.length - 1;
            while(_loc7_ >= 0)
            {
               _loc4_ = _bugsToHide[_loc7_];
               _loc4_.removeTime = _loc4_.removeTime - _loc5_;
               if(_loc4_.removeTime <= 0)
               {
                  _loc4_.s.content.visible = false;
                  _bugsToHide.splice(_loc7_,1);
               }
               _loc7_--;
            }
         }
         if(_bugsToRemove)
         {
            _loc7_ = _bugsToRemove.length - 1;
            while(_loc7_ >= 0)
            {
               _loc3_ = _bugsToRemove[_loc7_].body;
               _loc4_ = _bugsToRemove[_loc7_].bug;
               _loc4_.removeTime = _loc4_.removeTime - _loc5_;
               if(_loc4_.removeTime <= 0)
               {
                  _world.DestroyBody(_loc3_);
                  _loc4_.s.content.remove();
                  _bugsToRemove.splice(_loc7_,1);
                  _loc4_.removeTime = 5;
                  _bugsToHide.push(_loc4_);
               }
               _loc7_--;
            }
         }
         if(_theBalls)
         {
            _loc7_ = _theBalls.length - 1;
            while(_loc7_ >= 0)
            {
               if(_theBalls[_loc7_].clone.loader.content)
               {
                  _theBalls[_loc7_].clone.loader.content.velX = _theBalls[_loc7_].body.GetLinearVelocity().x;
                  _theBalls[_loc7_].clone.loader.content.pX = _theBalls[_loc7_].clone.loader.x;
                  _theBalls[_loc7_].clone.loader.content.pY = _theBalls[_loc7_].clone.loader.y;
               }
               _loc7_--;
            }
         }
         if(_levelPopup)
         {
            if(_levelPopup.finished)
            {
               _levelPopup.parent.removeChild(_levelPopup);
               _levelPopup = null;
            }
         }
         if(_comboPopups.length > 0)
         {
            _loc7_ = _comboPopups.length - 1;
            while(_loc7_ >= 0)
            {
               if(_comboPopups[_loc7_].finished)
               {
                  _comboPopups[_loc7_].parent.removeChild(_comboPopups[_loc7_]);
                  _comboPopups.splice(_loc7_,1);
               }
               _loc7_--;
            }
         }
         if(stage.mouseX != _prevMouseX || stage.mouseY != _prevMouseY)
         {
            _prevMouseX = stage.mouseX;
            _prevMouseY = stage.mouseY;
            _rotation = Math.atan2(-stage.mouseX + _launcherLayer.x,stage.mouseY - _launcherLayer.y);
            _rotation *= 180 / 3.141592653589793;
         }
         else if(_leftArrowDown)
         {
            _rotation += 100 * _loc5_;
         }
         else if(_rightArrowDown)
         {
            _rotation -= 100 * _loc5_;
         }
         if(_rotation > 73)
         {
            _rotation = 73;
         }
         else if(_rotation < -73)
         {
            _rotation = -73;
         }
         if(_launcherAim != _rotation)
         {
            _launcher.loader.content.launcher.rotation = _rotation;
            _launcherAim = _rotation;
            if(_initLauncherAim)
            {
               _launcherAim = _rotation;
               _initLauncherAim = false;
            }
            updateAimReference();
            _launcherAim = _rotation;
         }
         if(_turnOffAimReferenceTimer > 0)
         {
            _turnOffAimReferenceTimer -= _loc5_;
            if(_turnOffAimReferenceTimer <= 0)
            {
               updateAimReference();
            }
         }
         if(_world)
         {
            _world.Step(_timeStep,_iterations);
            _loc2_ = _world.m_bodyList;
            while(_loc2_)
            {
               if(_loc2_.m_userData is Object)
               {
                  _loc12_ = _loc2_.m_userData;
                  if(!(!_loc12_.hasOwnProperty("name") || _loc12_.name != "aimBall" && _loc12_.name != "ball"))
                  {
                     _loc9_ = _loc12_.loader;
                     _loc10_ = _loc2_.GetAngle();
                     _loc11_ = _loc9_.transform.matrix;
                     _loc6_ = _loc2_.GetPosition().x / _phyScale;
                     _loc8_ = _loc2_.GetPosition().y / _phyScale;
                     _loc9_.x = _loc6_ - _loc12_.width * 0.5;
                     _loc9_.y = _loc8_ - _loc12_.height * 0.5;
                  }
               }
               _loc2_ = _loc2_.m_next;
            }
            while(_contactListener.contactStack.length)
            {
               processCollision(_contactListener.contactStack.pop());
            }
         }
         if(_displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _loc5_;
            if(_displayAchievementTimer <= 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
      }
      
      private function updateAimReference() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc3_:Point = null;
         var _loc5_:Loader = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Matrix = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc2_:Point = null;
         var _loc9_:Object = null;
         if(_aimReferenceBallsDisplayed)
         {
            _turnOffAimReferenceTimer = 0;
            _loc4_ = 0;
            while(_loc4_ < _aimReferenceBallsDisplayed.length)
            {
               Loader(_aimReferenceBallsDisplayed[_loc4_].loader).visible = false;
               _loc4_++;
            }
         }
         else
         {
            _aimReferenceBallsDisplayed = [];
         }
         if(_theBalls.length == 0)
         {
            _referenceAim = _launcherAim;
            if(_difficulty != 3)
            {
               createBall(true);
               if(_aimReferenceBall)
               {
                  _loc4_ = 0;
                  _loc1_ = 0;
                  _loc10_ = 0;
                  _loc11_ = 0;
                  _loc3_ = new Point(_aimReferenceBall.clone.loader.x,_aimReferenceBall.clone.loader.y);
                  _loc5_ = _aimReferenceBall.clone.loader;
                  _loc6_ = 125;
                  if(_difficulty == 1)
                  {
                     _loc6_ *= 2;
                  }
                  while(_loc11_ < _loc6_)
                  {
                     _world.Step(_timeStep,_iterations);
                     while(_contactListener.contactStack.length)
                     {
                        _loc1_++;
                        _contactListener.contactStack.pop();
                     }
                     if(_loc1_ > 1)
                     {
                        break;
                     }
                     _loc7_ = Number(_aimReferenceBall.body.GetAngle());
                     _loc8_ = _loc5_.transform.matrix;
                     _loc12_ = _aimReferenceBall.body.GetPosition().x / _phyScale;
                     _loc13_ = _aimReferenceBall.body.GetPosition().y / _phyScale;
                     _loc5_.x = _loc12_ - _aimReferenceBall.clone.width * 0.5;
                     _loc5_.y = _loc13_ - _aimReferenceBall.clone.height * 0.5;
                     _loc10_ += Math.sqrt((_loc3_.x - _loc5_.x) * (_loc3_.x - _loc5_.x) + (_loc3_.y - _loc5_.y) * (_loc3_.y - _loc5_.y));
                     if(_loc10_ >= 25)
                     {
                        _loc2_ = new Point(_loc5_.x - _loc3_.x,_loc5_.y - _loc3_.y);
                        _loc2_.normalize(1);
                        while(_loc10_ >= 25)
                        {
                           _loc3_.x += _loc2_.x * 25;
                           _loc3_.y += _loc2_.y * 25;
                           if(_loc4_ >= _aimReferenceBallsDisplayed.length)
                           {
                              _loc9_ = _scene.cloneAsset("ball_aim");
                              _loc9_.loader.alpha = 0.25;
                              _aimReferenceBallsDisplayed.push(_loc9_);
                           }
                           if(Loader(_aimReferenceBallsDisplayed[_loc4_].loader).parent == null)
                           {
                              _playfield.addChild(_aimReferenceBallsDisplayed[_loc4_].loader);
                           }
                           Loader(_aimReferenceBallsDisplayed[_loc4_].loader).x = _loc3_.x;
                           Loader(_aimReferenceBallsDisplayed[_loc4_].loader).y = _loc3_.y;
                           Loader(_aimReferenceBallsDisplayed[_loc4_].loader).visible = true;
                           _loc4_++;
                           _loc10_ -= 25;
                           _loc11_ += 25;
                           if(_loc11_ >= _loc6_)
                           {
                              break;
                           }
                        }
                     }
                  }
                  _world.DestroyBody(_aimReferenceBall.body);
                  _scene.releaseCloneAsset(_aimReferenceBall.clone.loader);
                  _aimReferenceBall = null;
               }
            }
         }
      }
      
      private function DebugHeartbeat() : void
      {
         var _loc3_:Object = null;
         var _loc1_:b2Vec2 = null;
         var _loc2_:b2Body = null;
         if(_debugSliderBallSpeed && _debugSliderBallSpeed.loader.content && _debugSliderBallSpeed.loader.content.valueChanged)
         {
            _ballSpeed = _debugSliderBallSpeed.loader.content.sliderValue;
            _debugSliderBallSpeed.loader.content.valueChanged = false;
         }
         if(_debugSliderGravity && _debugSliderGravity.loader.content && _debugSliderGravity.loader.content.valueChanged)
         {
            _gravity = _debugSliderGravity.loader.content.sliderValue;
            _loc1_ = new b2Vec2(0,_gravity);
            _world.SetGravity(_loc1_);
            _debugSliderGravity.loader.content.valueChanged = false;
         }
         if(_debugSliderRestitution1 && _debugSliderRestitution1.loader.content && _debugSliderRestitution1.loader.content.valueChanged)
         {
            _restitutionBugType1 = _debugSliderRestitution1.loader.content.sliderValue;
            _debugSliderRestitution1.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "peg1":
                     case "peg1a":
                     case "col_1":
                        _loc2_.GetShapeList().m_restitution = _restitutionBugType1 / 100;
                        break;
                  }
                  _world.Refilter(_loc2_.GetShapeList());
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderRestitution2 && _debugSliderRestitution2.loader.content && _debugSliderRestitution2.loader.content.valueChanged)
         {
            _restitutionBugType2 = _debugSliderRestitution2.loader.content.sliderValue;
            _debugSliderRestitution2.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "peg2":
                     case "peg2a":
                     case "col_2":
                        _loc2_.GetShapeList().m_restitution = _restitutionBugType2 / 100;
                        break;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderRestitution3 && _debugSliderRestitution3.loader.content && _debugSliderRestitution3.loader.content.valueChanged)
         {
            _restitutionBugType3 = _debugSliderRestitution3.loader.content.sliderValue;
            _debugSliderRestitution3.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "peg3":
                     case "peg3a":
                     case "col_3":
                        _loc2_.GetShapeList().m_restitution = _restitutionBugType3 / 100;
                        break;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderRestitution4 && _debugSliderRestitution4.loader.content && _debugSliderRestitution4.loader.content.valueChanged)
         {
            _restitutionBugType4 = _debugSliderRestitution4.loader.content.sliderValue;
            _debugSliderRestitution4.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "peg4":
                     case "peg4a":
                     case "col_4":
                        _loc2_.GetShapeList().m_restitution = _restitutionBugType4 / 100;
                        break;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderRestitution5 && _debugSliderRestitution5.loader.content && _debugSliderRestitution5.loader.content.valueChanged)
         {
            _restitutionBugType5 = _debugSliderRestitution5.loader.content.sliderValue;
            _debugSliderRestitution5.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "peg5":
                     case "peg5a":
                     case "col_5":
                        _loc2_.GetShapeList().m_restitution = _restitutionBugType5 / 100;
                        break;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderBonusItem && _debugSliderBonusItem.loader.content && _debugSliderBonusItem.loader.content.valueChanged)
         {
            _restitutionBonusItem = _debugSliderBonusItem.loader.content.sliderValue;
            _debugSliderBonusItem.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  switch(_loc3_.name)
                  {
                     case "rapidshot":
                     case "spawn":
                     case "gembonus":
                     case "scorebonus":
                     case "freeball":
                     case "col":
                     case "col_rapidshot":
                     case "col_spawn":
                     case "col_gembonus":
                     case "col_scorebonus":
                     case "col_freeball":
                        _loc2_.GetShapeList().m_restitution = _restitutionBonusItem / 100;
                        break;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
         if(_debugSliderWall && _debugSliderWall.loader.content && _debugSliderWall.loader.content.valueChanged)
         {
            _restitutionWall = _debugSliderWall.loader.content.sliderValue;
            _debugSliderWall.loader.content.valueChanged = false;
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_.GetUserData();
               if(_loc3_)
               {
                  var _loc4_:* = _loc3_.name;
                  if("wall" === _loc4_)
                  {
                     _loc2_.GetShapeList().m_restitution = _restitutionWall / 100;
                  }
               }
               _loc2_ = _loc2_.GetNext();
            }
         }
      }
      
      public function getPillBugHitSound(param1:String) : String
      {
         switch(param1)
         {
            case "peg2":
            case "peg2a":
            case "peg3":
            case "peg3a":
               break;
            case "peg4":
            case "peg4a":
            case "peg5":
            case "peg5a":
               if(_soundsBigBugHitIndex >= _soundsBigBugHit.length)
               {
                  _soundsBigBugHit = randomizeArray(_soundsBigBugHit);
                  _soundsBigBugHitIndex = 0;
               }
               return _soundsBigBugHit[_soundsBigBugHitIndex++];
            default:
               return _soundNameSmall1;
         }
         if(_soundsSmallBugHitIndex >= _soundsSmallBugHit.length)
         {
            _soundsSmallBugHit = randomizeArray(_soundsSmallBugHit);
            _soundsSmallBugHitIndex = 0;
         }
         return _soundsSmallBugHit[_soundsSmallBugHitIndex++];
      }
      
      private function processCollision(param1:PillBugCustomContactPoint) : void
      {
         var _loc10_:Object = null;
         var _loc20_:Object = null;
         var _loc8_:b2Body = null;
         var _loc18_:b2Body = null;
         var _loc19_:int = 0;
         var _loc3_:String = null;
         var _loc21_:b2Body = null;
         var _loc22_:Object = null;
         var _loc14_:b2Body = null;
         var _loc6_:Object = null;
         var _loc7_:Boolean = false;
         var _loc23_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc13_:MovieClip = null;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc24_:* = null;
         var _loc27_:Object = null;
         var _loc16_:* = param1.shape1.GetBody().GetUserData();
         var _loc17_:* = param1.shape2.GetBody().GetUserData();
         if(_loc16_ != null && _loc16_.hasOwnProperty("name") && _loc16_.name == "ball")
         {
            _loc10_ = _loc16_;
            _loc20_ = _loc17_;
            _loc18_ = param1.shape1.GetBody();
            _loc8_ = param1.shape2.GetBody();
         }
         else
         {
            if(!(_loc17_ != null && _loc17_.hasOwnProperty("name") && _loc17_.name == "ball"))
            {
               return;
            }
            _loc10_ = _loc17_;
            _loc20_ = _loc16_;
            _loc18_ = param1.shape2.GetBody();
            _loc8_ = param1.shape1.GetBody();
         }
         if(_loc20_ == null || !_loc20_.hasOwnProperty("name"))
         {
            return;
         }
         var _loc4_:Boolean = false;
         var _loc2_:String = null;
         var _loc15_:int = 0;
         switch(_loc20_.name)
         {
            case "wall":
            case "col":
               _loc3_ = _soundNameImpWall;
               break;
            case "peg2a":
            case "peg3a":
            case "peg4a":
            case "peg5a":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 1;
                  _loc2_ = new String();
                  _loc2_ += _scoreAccumulator;
                  _loc3_ = getPillBugHitSound(_loc20_.name);
               }
               break;
            case "peg2":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 2;
                  _loc2_ = new String();
                  _loc2_ += 100;
                  _loc3_ = getPillBugHitSound(_loc20_.name);
               }
               break;
            case "peg3":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 3;
                  _loc2_ = new String();
                  _loc2_ += 150;
                  _loc3_ = getPillBugHitSound(_loc20_.name);
               }
               break;
            case "peg4":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 4;
                  _loc2_ = new String();
                  _loc2_ += 300;
                  _loc3_ = getPillBugHitSound(_loc20_.name);
               }
               break;
            case "peg5":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 5;
                  _loc3_ = getPillBugHitSound(_loc20_.name);
               }
               break;
            case "spawn":
            case "col_spawn":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 11;
                  _loc2_ = LocalizationManager.translateIdOnly(28430);
                  _loc3_ = _soundNameGreenBug;
               }
               break;
            case "freeball":
            case "col_freeball":
               if(_loc20_.s.content != null)
               {
                  _loc4_ = true;
                  _loc15_ = 10;
                  _loc2_ = LocalizationManager.translateIdOnly(28431);
                  _loc3_ = _soundNameGoldBug;
               }
               break;
            case "col_flower":
               if(_loc20_.s.content != null)
               {
                  _loc2_ = LocalizationManager.translateIdOnly(28433);
               }
               break;
            default:
               if(_loc20_.name.indexOf("exit",0) >= 0)
               {
                  _loc3_ = _soundNameBallOut;
                  _loc19_ = _theBalls.length - 1;
                  while(_loc19_ >= 0)
                  {
                     if(_theBalls[_loc19_].clone == _loc10_)
                     {
                        _world.DestroyBody(_theBalls[_loc19_].body);
                        _loc10_.loader.parent.removeChild(_loc10_.loader);
                        _scene.releaseCloneAsset(_loc10_.loader);
                        _theBalls.splice(_loc19_,1);
                        updateAimReference();
                        break;
                     }
                     _loc19_--;
                  }
                  if(_theBalls.length == 0)
                  {
                     if(_bugsToRemove)
                     {
                        _loc19_ = _bugsToRemove.length - 1;
                        while(_loc19_ >= 0)
                        {
                           _loc21_ = _bugsToRemove[_loc19_].body;
                           _loc22_ = _bugsToRemove[_loc19_].bug;
                           _world.DestroyBody(_loc21_);
                           _loc22_.s.content.remove();
                           _bugsToRemove.splice(_loc19_,1);
                           _loc22_.removeTime = 5;
                           _bugsToHide.push(_loc22_);
                           _loc19_--;
                        }
                     }
                     _loc14_ = _world.GetBodyList();
                     _loc7_ = true;
                     while(_loc14_ && _loc7_)
                     {
                        _loc6_ = _loc14_.GetUserData();
                        if(_loc6_)
                        {
                           switch(_loc6_.name)
                           {
                              case "peg2a":
                              case "peg3a":
                              case "peg4a":
                              case "peg5a":
                                 if(_loc6_.s.content && _loc6_.s.content.pegState == 1)
                                 {
                                    _loc7_ = false;
                                 }
                                 break;
                           }
                        }
                        _loc14_ = _loc14_.GetNext();
                     }
                     if(_loc7_ || _balls == 0)
                     {
                        _levelScore += _remainingPillBugBonus * _balls;
                        _levelGemsEarned = _levelScore / 1000;
                        if(_loc7_)
                        {
                           _totalBugsHit = _totalBugsToHit;
                           _uiRight.meterFill(_totalBugsHit,_totalBugsToHit);
                           _loc14_ = _world.GetBodyList();
                           while(_loc14_ && _loc7_)
                           {
                              _loc6_ = _loc14_.GetUserData();
                              if(_loc6_)
                              {
                                 switch(_loc6_.name)
                                 {
                                    case "peg2":
                                    case "peg3":
                                    case "peg4":
                                    case "peg5":
                                    case "peg2a":
                                    case "peg3a":
                                    case "peg4a":
                                    case "peg5a":
                                    case "rapidshot":
                                    case "spawn":
                                    case "gembonus":
                                    case "scorebonus":
                                    case "freeball":
                                       if(_loc6_.s.content && _loc6_.s.content.pegState == 1)
                                       {
                                          _loc7_ = false;
                                       }
                                       break;
                                 }
                              }
                              _loc14_ = _loc14_.GetNext();
                           }
                           if(_stars[_level + 1] < 1)
                           {
                              _stars[_level + 1] = 1;
                           }
                           if(_loc7_)
                           {
                              _allBugsCleared = true;
                              switch(_difficulty - 1)
                              {
                                 case 0:
                                    if(_stars[_level + 1] < 2)
                                    {
                                       _stars[_level + 1] = 2;
                                    }
                                    break;
                                 case 1:
                                    if(_stars[_level + 1] < 3)
                                    {
                                       _stars[_level + 1] = 3;
                                    }
                                    break;
                                 case 2:
                                    if(_stars[_level + 1] < 4)
                                    {
                                       _stars[_level + 1] = 4;
                                       break;
                                    }
                              }
                              if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                              {
                                 AchievementXtCommManager.requestSetUserVar(278,1);
                                 _displayAchievementTimer = 1;
                                 _loc23_ = true;
                                 _loc19_ = 1;
                                 while(_loc19_ <= 30)
                                 {
                                    if(_stars[_loc19_] < 4)
                                    {
                                       _loc23_ = false;
                                       break;
                                    }
                                    _loc19_++;
                                 }
                                 if(_loc23_)
                                 {
                                    AchievementXtCommManager.requestSetUserVar(280,1);
                                    _displayAchievementTimer = 1;
                                 }
                              }
                              _levelGemsEarned += 15;
                           }
                           if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                           {
                              _loc5_ = true;
                              _loc19_ = 1;
                              while(_loc19_ <= 30)
                              {
                                 if(_stars[_loc19_] < 1)
                                 {
                                    _loc5_ = false;
                                    break;
                                 }
                                 _loc19_++;
                              }
                              if(_loc5_)
                              {
                                 AchievementXtCommManager.requestSetUserVar(279,1);
                                 _displayAchievementTimer = 1;
                              }
                           }
                           _gemsEarned += _levelGemsEarned;
                        }
                        AchievementXtCommManager.requestSetUserVar(247 + _level,_stars[_level + 1]);
                        AchievementXtCommManager.requestSetUserVar(217 + _level,_levelScore);
                        if(_scores[_level + 1] < _levelScore)
                        {
                           _scores[_level + 1] = _levelScore;
                        }
                        if(_totalBugsHit >= _totalBugsToHit)
                        {
                           _soundMan.playByName(_soundNameStingerSuccess);
                        }
                        else
                        {
                           _soundMan.playByName(_soundNameStingerFail);
                        }
                        showResultsDlg();
                     }
                  }
                  break;
               }
               if(Math.random() * 2 < 1)
               {
                  _loc3_ = _soundNameImpPlants1;
                  break;
               }
               _loc3_ = _soundNameImpPlants2;
               break;
         }
         if(_loc2_ != null)
         {
            if(_loc20_.s.content && _loc20_.s.content.pegState == 1)
            {
               _loc13_ = showDlg("PB_comboPopup",null,0,0,false);
               _loc13_.x = _loc20_.s.x + _loc20_.width / 2;
               _loc13_.y = _loc20_.s.y + _loc20_.height / 2;
               _loc13_.turnOn(_loc2_);
               _comboPopups.push(_loc13_);
            }
         }
         if(_loc4_)
         {
            if(_loc20_.s.content && _loc20_.s.content.pegState == 1 && _loc15_ != 0)
            {
               switch(_loc15_ - 1)
               {
                  case 0:
                     _totalScore += _scoreAccumulator;
                     _levelScore += _scoreAccumulator;
                     if(_scoreAccumulator < 5000)
                     {
                        _scoreAccumulator += 500;
                        if(_scoreAccumulator > 5000)
                        {
                           _scoreAccumulator = 5000;
                        }
                     }
                     pegType1Hit();
                     break;
                  case 1:
                     _totalScore += 100;
                     _levelScore += 100;
                     break;
                  case 2:
                     _totalScore += 150;
                     _levelScore += 150;
                     break;
                  case 3:
                     _totalScore += 300;
                     _levelScore += 300;
                     break;
                  case 4:
                     _totalScore += 500;
                     _levelScore += 500;
                     break;
                  case 9:
                     _balls++;
                     _uiLeft.counter.text = _balls;
                     break;
                  case 10:
                     _loc25_ = int(_loc20_.s.x);
                     _loc26_ = int(_loc20_.s.y);
                     _loc12_ = _loc25_ - _loc10_.loader.x;
                     _loc11_ = _loc26_ - _loc10_.loader.y;
                     _loc9_ = Math.sqrt(_loc12_ * _loc12_ + _loc11_ * _loc11_);
                     _loc12_ = _loc12_ / _loc9_ * _ballSpeed;
                     _loc11_ = _loc11_ / _loc9_ * _ballSpeed;
                     _world.DestroyBody(_loc8_);
                     _loc20_.s.content.remove();
                     _loc24_ = _loc18_;
                     createBall(false,_loc25_,_loc26_,_loc12_,_loc11_);
               }
               _uiRight.score.text = _levelScore;
               _loc19_ = _theBalls.length - 1;
               while(_loc19_ >= 0)
               {
                  if(_theBalls[_loc19_].clone == _loc10_)
                  {
                     _loc27_ = {};
                     _loc27_.body = _loc8_;
                     _loc27_.bug = _loc20_;
                     _bugsToRemove.push(_loc27_);
                     _loc20_.s.content.ballHit();
                     _loc20_.removeTime = 0.5;
                  }
                  _loc19_--;
               }
            }
         }
         if(_loc3_)
         {
            _soundMan.playByName(_loc3_);
         }
      }
      
      private function pegType1Hit() : void
      {
         var _loc3_:int = 0;
         var _loc4_:b2Body = null;
         var _loc9_:Object = null;
         var _loc1_:int = 0;
         var _loc7_:Object = null;
         var _loc2_:Object = null;
         var _loc8_:int = 0;
         var _loc5_:Number = _totalBugsHit / _totalBugsAvailableToHit;
         _totalBugsHit++;
         if(_totalBugsHit <= _totalBugsToHit)
         {
            _uiRight.meterFill(_totalBugsHit,_totalBugsToHit);
            _soundMan.playByName(_soundNameMeter);
         }
         var _loc10_:Number = _totalBugsHit / _totalBugsAvailableToHit;
         var _loc6_:Boolean = _loc5_ < 0.25 && _loc10_ >= 0.25 || _loc5_ < 0.5 && _loc10_ >= 0.5 || _loc5_ < 0.75 && _loc10_ >= 0.75;
         if(_loc6_)
         {
            _loc3_ = 0;
            _loc4_ = _world.GetBodyList();
            while(_loc4_)
            {
               _loc9_ = _loc4_.GetUserData();
               if(_loc9_)
               {
                  var _loc11_:* = _loc9_.name;
                  if("peg2" === _loc11_)
                  {
                     if(_loc9_.s.content.pegState == 1)
                     {
                        _loc3_++;
                     }
                  }
               }
               _loc4_ = _loc4_.GetNext();
            }
            if(_loc3_ > 0)
            {
               _loc1_ = Math.random() * _loc3_;
               if(_loc3_ > 0)
               {
                  _loc4_ = _world.GetBodyList();
                  loop1:
                  for(; _loc4_; _loc4_ = _loc4_.GetNext())
                  {
                     _loc9_ = _loc4_.GetUserData();
                     if(!_loc9_)
                     {
                        continue;
                     }
                     _loc7_ = null;
                     if(!(_loc9_.name == "peg2" && _loc9_.s.content.pegState == 1))
                     {
                        continue;
                     }
                     _loc1_--;
                     if(_loc1_ != 0)
                     {
                        continue;
                     }
                     _loc2_ = _scene.getLayer("freeball");
                     _loc2_.loader.content.reset();
                     _loc7_ = _scene.cloneAsset("freeball");
                     _loc7_.name = "freeball";
                     _loc7_.s = _loc7_.loader;
                     _loc7_.loader.x = _loc9_.s.x;
                     _loc7_.loader.y = _loc9_.s.y;
                     _clonesToRelease.push(_loc7_);
                     _background.addChild(_loc7_.loader);
                     _loc4_.SetUserData(_loc7_);
                     _loc8_ = 0;
                     while(true)
                     {
                        if(_loc8_ >= _clonesToRelease.length)
                        {
                           break loop1;
                        }
                        if(_clonesToRelease[_loc8_] == _loc9_)
                        {
                           if(_loc9_.loader.parent)
                           {
                              _loc9_.loader.parent.removeChild(_loc9_.loader);
                           }
                           _scene.releaseCloneAsset(_clonesToRelease[_loc8_].loader);
                           _clonesToRelease.splice(_loc8_,1);
                           break loop1;
                        }
                        _loc8_++;
                     }
                  }
               }
            }
         }
      }
      
      private function onMouseClick(param1:Event) : void
      {
         if(!_pauseGame && _levelPopup == null)
         {
            if(_theBalls.length == 0)
            {
               if(createBall(false))
               {
                  _scoreAccumulator = 500;
                  _balls--;
                  _uiLeft.counter.text = _balls;
                  _soundMan.playByName(_soundNameLaunch);
                  _launcher.loader.content.up();
                  _turnOffAimReferenceTimer = 0.35;
               }
            }
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               if(activeDlgMC == null)
               {
                  onMouseClick(param1);
               }
               break;
            case 5:
               _leftArrowDown = true;
               break;
            case 7:
               _rightArrowDown = true;
         }
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 37)
         {
            _leftArrowDown = false;
         }
         else if(param1.keyCode == 39)
         {
            _rightArrowDown = false;
         }
      }
      
      private function setNextLevel(param1:Boolean) : void
      {
         if(!param1)
         {
            _level += 1;
         }
         if(_level >= _levelData._data.length)
         {
            _level = 0;
            showLevelSelectPopup();
         }
         else
         {
            startLevel(_level);
         }
      }
      
      private function startLevel(param1:int) : void
      {
         var _loc7_:b2Body = null;
         var _loc4_:b2Body = null;
         var _loc5_:Object = null;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         if(_soundMan != null && _musicLoop == null)
         {
            _musicLoop = _soundMan.playStream(_SFX_PillBugs_Music,0,999999);
         }
         if(_world)
         {
            _loc7_ = _world.GetBodyList();
            while(_loc7_)
            {
               _world.DestroyBody(_loc7_);
               _loc7_ = _world.GetBodyList();
            }
         }
         _bugsToHide = null;
         if(_bugsToRemove)
         {
            _loc8_ = _bugsToRemove.length - 1;
            while(_loc8_ >= 0)
            {
               _loc4_ = _bugsToRemove[_loc8_].body;
               _loc5_ = _bugsToRemove[_loc8_].bug;
               _world.DestroyBody(_loc4_);
               _loc5_.s.content.remove();
               _bugsToRemove.splice(_loc8_,1);
               _loc8_--;
            }
         }
         _loc8_ = _theBalls.length - 1;
         while(_loc8_ >= 0)
         {
            _world.DestroyBody(_theBalls[_loc8_].body);
            _theBalls[_loc8_].clone.loader.parent.removeChild(_theBalls[_loc8_].clone.loader);
            _scene.releaseCloneAsset(_theBalls[_loc8_].clone.loader);
            _theBalls.splice(_loc8_,1);
            _loc8_--;
         }
         while(_background.numChildren > 0)
         {
            _background.removeChildAt(0);
         }
         while(_playfield.numChildren > 0)
         {
            _playfield.removeChildAt(0);
         }
         while(_foreground.numChildren > 0)
         {
            _foreground.removeChildAt(0);
         }
         while(_clonesToRelease.length > 0)
         {
            _scene.releaseCloneAsset(_clonesToRelease[0].loader);
            _clonesToRelease.splice(0,1);
         }
         if(_world)
         {
            _loc7_ = _world.GetBodyList();
            while(_loc7_)
            {
               _loc9_ = _loc7_.GetUserData();
               if(_loc9_)
               {
                  switch(_loc9_.name)
                  {
                     case "peg2a":
                     case "peg3a":
                     case "peg4a":
                     case "peg5a":
                        break;
                  }
               }
               _loc7_ = _loc7_.GetNext();
            }
         }
         _bugsToHide = [];
         _bugsToRemove = [];
         _level = param1;
         _totalBugsHit = 0;
         _allBugsCleared = false;
         var _loc2_:b2AABB = new b2AABB();
         _loc2_.lowerBound.Set(-1000,-1000);
         _loc2_.upperBound.Set(1000,1000);
         var _loc6_:b2Vec2 = new b2Vec2(0,_gravity);
         _world = new b2World(_loc2_,_loc6_,true);
         _contactListener = new PillBugContactListener();
         _world.SetContactListener(_contactListener);
         setupLevel(param1);
         _levelScore = 0;
         if(_tutorialHasBeenShown)
         {
            showReadyGoDlg();
         }
         else
         {
            showTutorialDlg();
         }
         _uiRight.meterFill(0,_totalBugsToHit);
         if(_scores[_level + 1] < _levelScore)
         {
            _scores[_level + 1] = _levelScore;
         }
         _uiRight.highscore.text = _scores[_level + 1];
         _uiRight.score.text = 0;
         _uiLeft.counter.text = _balls;
         var _loc11_:int = _level / 6 + 1;
         var _loc10_:int = _level % 6 + 1;
         _uiLeft.level_text.text = _loc11_ + "-" + _loc10_;
         _initLauncherAim = true;
         _launcherAim = 0;
         updateAimReference();
         if(_factImageMediaObject && _greatJobPopup != null)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
            _factImageMediaObject = null;
         }
         if(!_loadingImage)
         {
            loadNextFactImage();
         }
         _greatJobPopup = null;
      }
      
      private function endLevel() : void
      {
      }
      
      private function showLevelDifficultyPopup() : void
      {
         if(_soundMan != null && _musicLoop == null)
         {
            _musicLoop = _soundMan.playStream(_SFX_PillBugs_Music,0,999999);
         }
         var _loc1_:Array = [{
            "name":"btnEasy",
            "f":onDifficultySelect_Easy
         },{
            "name":"btnMedium",
            "f":onDifficultySelect_Medium
         },{
            "name":"btnHard",
            "f":onDifficultySelect_Hard
         },{
            "name":"x_btn",
            "f":onExit_Yes
         }];
         var _loc2_:MovieClip = showDlg("PB_Difficulty",_loc1_);
         _loc2_.btnEasy.mouseChildren = false;
         _loc2_.btnMedium.mouseChildren = false;
         _loc2_.btnHard.mouseChildren = false;
         _loc2_.x = 450;
         _loc2_.y = 275;
      }
      
      private function onDifficultySelect_Easy() : void
      {
         _remainingPillBugBonus = 1000;
         _difficulty = 1;
         LocalizationManager.translateId(_uiLeft.difficulty,11815);
         hideDlg();
         showLevelSelectPopup();
      }
      
      private function onDifficultySelect_Medium() : void
      {
         _remainingPillBugBonus = 3000;
         _difficulty = 2;
         LocalizationManager.translateId(_uiLeft.difficulty,11816);
         hideDlg();
         showLevelSelectPopup();
      }
      
      private function onDifficultySelect_Hard() : void
      {
         _remainingPillBugBonus = 5000;
         _difficulty = 3;
         LocalizationManager.translateId(_uiLeft.difficulty,11817);
         hideDlg();
         showLevelSelectPopup();
      }
      
      private function showLevelSelectPopup() : void
      {
         var _loc2_:int = 0;
         _levelSelectSet = _level / 6 + 1;
         var _loc1_:Array = [{
            "name":"lastSetButton",
            "f":onLevelSelect_LastSet
         },{
            "name":"nextSetButton",
            "f":onLevelSelect_NextSet
         },{
            "name":"levelButtons.node1",
            "f":onLevelSelect_Node1
         },{
            "name":"levelButtons.node2",
            "f":onLevelSelect_Node2
         },{
            "name":"levelButtons.node3",
            "f":onLevelSelect_Node3
         },{
            "name":"levelButtons.node4",
            "f":onLevelSelect_Node4
         },{
            "name":"levelButtons.node5",
            "f":onLevelSelect_Node5
         },{
            "name":"levelButtons.node6",
            "f":onLevelSelect_Node6
         },{
            "name":"x_btn",
            "f":onExit_Yes
         }];
         _levelSelectPopup = showDlg("PB_LevelSelect",_loc1_);
         _levelSelectPopup.x = 450;
         _levelSelectPopup.y = 275;
         _loc2_ = 1;
         while(_loc2_ <= 30)
         {
            _levelSelectPopup.scores[_loc2_] = _scores[_loc2_];
            if(_stars[_loc2_] > 0)
            {
               _levelSelectPopup.stars[_loc2_] = _stars[_loc2_] - 1;
            }
            else
            {
               _levelSelectPopup.stars[_loc2_] = 0;
            }
            _levelSelectPopup.unlocked[_loc2_] = _loc2_ == 1 || _stars[_loc2_ - 1] > 0;
            _loc2_++;
         }
         _levelSelectPopup.setLevels(_levelSelectSet);
      }
      
      private function onLevelSelect_LastSet() : void
      {
         _levelSelectSet--;
         if(_levelSelectSet < 1)
         {
            _levelSelectSet = 5;
         }
         _levelSelectPopup.goLast(_levelSelectSet);
         _soundMan.playByName(_soundNameLevelSelectSlide);
      }
      
      private function onLevelSelect_NextSet() : void
      {
         _levelSelectSet++;
         if(_levelSelectSet > 5)
         {
            _levelSelectSet = 1;
         }
         _levelSelectPopup.goNext(_levelSelectSet);
         _soundMan.playByName(_soundNameLevelSelectSlide);
      }
      
      private function onLevelSelect_Node1() : void
      {
         if(_levelSelectSet == 1 || _stars[(_levelSelectSet - 1) * 6] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6);
         }
      }
      
      private function onLevelSelect_Node2() : void
      {
         if(_stars[(_levelSelectSet - 1) * 6 + 1] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6 + 1);
         }
      }
      
      private function onLevelSelect_Node3() : void
      {
         if(_stars[(_levelSelectSet - 1) * 6 + 2] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6 + 2);
         }
      }
      
      private function onLevelSelect_Node4() : void
      {
         if(_stars[(_levelSelectSet - 1) * 6 + 3] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6 + 3);
         }
      }
      
      private function onLevelSelect_Node5() : void
      {
         if(_stars[(_levelSelectSet - 1) * 6 + 4] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6 + 4);
         }
      }
      
      private function onLevelSelect_Node6() : void
      {
         if(_stars[(_levelSelectSet - 1) * 6 + 5] > 0)
         {
            hideDlg();
            startLevel((_levelSelectSet - 1) * 6 + 5);
         }
      }
      
      private function gameOverKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onGameOverYes();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function greatJobKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               if(_level < 29)
               {
                  onGreatJobContinue();
                  break;
               }
               onGreatJobMenu();
               break;
            case 8:
            case 46:
            case 27:
               onGreatJobMenu();
         }
      }
      
      private function resultsKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               resultsContinue();
         }
      }
      
      private function hideTutKeyDown(param1:KeyboardEvent) : void
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
      
      private function showTutorialDlg() : void
      {
         stage.addEventListener("keyDown",hideTutKeyDown);
         var _loc1_:MovieClip = showDlg("PB_HowToPlay",[{
            "name":"x_btn",
            "f":hideTut
         },{
            "name":"doneButton",
            "f":hideTut
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function hideTut() : void
      {
         stage.removeEventListener("keyDown",hideTutKeyDown);
         hideDlg();
         _tutorialHasBeenShown = true;
         showReadyGoDlg();
      }
      
      private function showReadyGoDlg() : void
      {
         if(_levelPopup)
         {
            _levelPopup.parent.removeChild(_levelPopup);
            _levelPopup = null;
         }
         _levelPopup = showDlg("PB_readyGo",null,0,0,false);
         _levelPopup.x = 450;
         _levelPopup.y = 275;
         _levelPopup.turnOn(_level + 1);
         _soundMan.playByName(_soundNameTextPopup);
      }
      
      private function showResultsDlg() : void
      {
         stage.addEventListener("keyDown",resultsKeyDown);
         var _loc1_:MovieClip = showDlg("PB_Result",[{
            "name":"continue_btn",
            "f":resultsContinue
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _greatJobPopup = _loc1_;
         if(_factImageMediaObject)
         {
            _greatJobPopup.result_pic.addChild(_factImageMediaObject);
         }
         LocalizationManager.translateId(_loc1_.result_fact,_levelData._facts[_factsOrder[_factsIndex]].text);
      }
      
      private function resultsContinue() : void
      {
         stage.removeEventListener("keyDown",resultsKeyDown);
         hideDlg();
         if(_totalBugsHit >= _totalBugsToHit)
         {
            showGreatJobDlg();
         }
         else if(_balls == 0)
         {
            showGameOverDlg();
         }
      }
      
      private function showGreatJobDlg() : void
      {
         var _loc1_:MovieClip = null;
         stage.addEventListener("keyDown",greatJobKeyDown);
         if(_level >= 29)
         {
            _loc1_ = showDlg("PB_You_Win",[{
               "name":"button_levelSelect",
               "f":onGreatJobMenu
            }]);
         }
         else
         {
            _loc1_ = showDlg("PB_Great_Job",[{
               "name":"button_levelSelect",
               "f":onGreatJobMenu
            },{
               "name":"button_nextlevel",
               "f":onGreatJobContinue
            }]);
         }
         _loc1_.x = 450;
         _loc1_.y = 275;
         _loc1_.points.text = _levelScore;
         _loc1_.pointMultiplierLabel.text = _remainingPillBugBonus + " x " + _balls;
         if(_allBugsCleared && _stars[_level + 1] > 1)
         {
            switch(_difficulty - 1)
            {
               case 0:
                  _loc1_.bugTrophy(1);
                  break;
               case 1:
                  _loc1_.bugTrophy(2);
                  break;
               case 2:
                  _loc1_.bugTrophy(3);
            }
            _soundMan.playByName(_soundNameGoldenBugAward);
         }
         _loc1_.pointBonus.text = "= " + _remainingPillBugBonus * _balls;
         _loc1_.pointsAdded.text = _levelScore - _remainingPillBugBonus * _balls;
         addGemsToBalance(_levelGemsEarned);
         if(_levelGemsEarned == 1)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.gemsText,11619,_levelGemsEarned);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_loc1_.gemsText,11554,_levelGemsEarned);
         }
         if(_gemsEarned == 1)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.totalGemsText,11819,_gemsEarned);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_loc1_.totalGemsText,11549,_gemsEarned);
         }
      }
      
      private function onGreatJobMenu() : void
      {
         stage.removeEventListener("keyDown",greatJobKeyDown);
         hideDlg();
         showLevelSelectPopup();
      }
      
      private function onGreatJobContinue() : void
      {
         stage.removeEventListener("keyDown",greatJobKeyDown);
         hideDlg();
         setNextLevel(false);
      }
      
      private function showGameOverDlg() : void
      {
         stage.addEventListener("keyDown",gameOverKeyDown);
         var _loc1_:MovieClip = showDlg("PB_Game_Over",[{
            "name":"button_yes",
            "f":onGameOverYes
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         if(_levelScore == 1)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.pointsText,11821,_levelScore);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_loc1_.pointsText,11550,_levelScore);
         }
         addGemsToBalance(_levelGemsEarned);
         if(_levelGemsEarned == 1)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.gemsText,11433,_levelGemsEarned);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_loc1_.gemsText,11432,_levelGemsEarned);
         }
      }
      
      private function onGameOverYes() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(277,1);
            _displayAchievementTimer = 1;
         }
         hideDlg();
         setNextLevel(true);
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("PB_Options",[{
            "name":"btn_close",
            "f":onExit_No
         },{
            "name":"btn_exitGame",
            "f":onExit_Yes
         },{
            "name":"btn_restartLevel",
            "f":onExit_RestartLevel
         },{
            "name":"btn_levelSelect",
            "f":onExit_LevelSelect
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onExit_RestartLevel() : void
      {
         hideDlg();
         setNextLevel(true);
      }
      
      private function onExit_LevelSelect() : void
      {
         hideDlg();
         showLevelSelectPopup();
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            exit();
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         exit();
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function loadLevel() : void
      {
         pillbugsLevelConverter = new PillBugsLevelConverter();
         pillbugsLevelConverter.convertFile();
      }
      
      private function saveLevel() : void
      {
         if(pillbugsLevelConverter)
         {
            pillbugsLevelConverter.saveFile();
         }
      }
   }
}

