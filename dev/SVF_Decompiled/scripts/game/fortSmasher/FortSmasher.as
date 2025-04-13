package game.fortSmasher
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
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class FortSmasher extends GameBase implements IMinigame
   {
      private static const MATERIAL_METAL:int = 1;
      
      private static const MATERIAL_WOOD:int = 2;
      
      private static const MATERIAL_GLASS:int = 3;
      
      private static const MATERIAL_STONE:int = 4;
      
      private static const MATERIAL_PHANTOM:int = 5;
      
      private static const MATERIAL_FRUIT:int = 6;
      
      private static const SOUND_IMPACT:int = 0;
      
      private static const SOUND_CRACK:int = 1;
      
      private static const SOUND_DESTROY:int = 2;
      
      private static const ZOOM_TIME:Number = 1;
      
      private static const ENDTURN_TIME:Number = 1;
      
      private static const SHOW_DEBUG:Boolean = false;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const FRUIT_UI_SCALE:Number = 1.3;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_SCENELOADED:int = 1;
      
      public static const GAMESTATE_READY_DISPLAYED:int = 2;
      
      public static const GAMESTATE_LEVEL_DISPLAYED:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_CHOOSE:int = 5;
      
      public static const GAMESTATE_COINTOSS:int = 6;
      
      public static const GAMESTATE_SWITCHTURNS:int = 7;
      
      public static const GAMESTATE_WAITINGFORPLAYER:int = 8;
      
      public static const GAMESTATE_TITLESCREEN:int = 9;
      
      public static const GAMESTATE_ENDED:int = 10;
      
      public var DESIGN_MODE:Boolean = false;
      
      public var _materials:Array = [{
         "density":1,
         "friction":5,
         "bounce":0.01,
         "strength":1,
         "damage":0
      },{
         "density":0.8,
         "friction":3.75,
         "bounce":0.05,
         "strength":4,
         "damage":0.22
      },{
         "density":0.6,
         "friction":2.25,
         "bounce":0.15,
         "strength":1.5,
         "damage":0.18
      },{
         "density":0.28,
         "friction":1.5,
         "bounce":0.05,
         "strength":0.25,
         "damage":0.12
      },{
         "density":0.7,
         "friction":3.25,
         "bounce":0.01,
         "strength":3.5,
         "damage":0.2
      },{
         "density":0.65,
         "friction":2,
         "bounce":0.2,
         "strength":2.25,
         "damage":0.2
      }];
      
      public var _projectiles:Array = [{
         "density":0.7,
         "friction":1.35,
         "bounce":0.25,
         "strength":1.65,
         "damage":2.25
      },{
         "density":0.55,
         "friction":1,
         "bounce":0.35,
         "strength":1,
         "damage":2
      },{
         "density":0.85,
         "friction":3,
         "bounce":0.05,
         "strength":1.65,
         "damage":3.75
      },{
         "density":0.75,
         "friction":1.5,
         "bounce":0.25,
         "strength":0.5,
         "damage":0
      },{
         "density":2.5,
         "friction":0.15,
         "bounce":0.3,
         "strength":0.65,
         "damage":3
      },{
         "density":1.55,
         "friction":0.75,
         "bounce":0.25,
         "strength":1.5,
         "damage":2.75
      }];
      
      private var _facts:Array = [{
         "image":"dragon",
         "text":11557
      },{
         "image":"dragon_2",
         "text":11558
      },{
         "image":"dragon_3",
         "text":11559
      },{
         "image":"acai",
         "text":11560
      },{
         "image":"acai_2",
         "text":11561
      },{
         "image":"acai_3",
         "text":11562
      },{
         "image":"horned",
         "text":11563
      },{
         "image":"horned_2",
         "text":11564
      },{
         "image":"horned_3",
         "text":11565
      },{
         "image":"starfruit",
         "text":11566
      },{
         "image":"starfruit_2",
         "text":11567
      },{
         "image":"starfruit_3",
         "text":11568
      },{
         "image":"lychee",
         "text":11569
      },{
         "image":"lychee_2",
         "text":11570
      },{
         "image":"lychee_3",
         "text":11571
      }];
      
      public var _clusterParams:Array = [1,12];
      
      private var _levelAmmo:Array = [[9,0,0,0,0],[9,0,0,0,0],[9,0,0,0,0],[9,0,0,0,0],[9,0,0,0,0],[8,0,0,0,0],[8,0,0,0,0],[8,0,0,0,0],[8,0,0,0,0],[7,0,0,0,0],[4,5,0,0,0],[3,6,0,0,0],[5,4,0,0,0],[3,5,0,0,0],[4,5,0,0,0],[4,4,0,0,0],[4,5,0,0,0],[4,4,0,0,0],[3,4,0,0,0],[4,5,0,0,0],[2,2,5,0,0],[2,2,4,0,0],[1,1,4,0,0],[2,1,4,0,0],[2,2,3,0,0],[1,2,3,0,0],[2,2,3,0,0],[1,2,4,0,0],[2,1,4,0,0],[0,0,6,0,0],[0,0,0,6,0],[0,0,0,7,0],[1,1,1,4,0],[2,1,1,4,0],[0,1,2,4,0],[0,2,2,4,0],[1,2,1,3,0],[1,1,2,4,0],[2,1,0,4,0],[3,3,2,3,0],[1,1,1,1,4],[1,1,2,0,4],[1,2,0,1,4],[0,2,1,1,4],[2,2,2,2,3],[0,1,0,1,4],[0,0,0,1,5],[2,1,1,1,4],[1,1,1,1,2],[1,1,1,1,1]];
      
      private var _levelTrophieThreshold:Array = [26000,34000,23000,34000,28000,16000,32000,20000,18000,21000,23000,39000,27000,21000,18000,22000,33000,22000,18000,13000,37000,48000,30000,37000,54000,23000,34000,34000,27000,27000,35000,25000,35000,52000,34000,35000,44000,36000,46000,36000,54000,45000,16000,36000,38000,23000,17000,32000,46000,49000];
      
      private var _ammo:Array = [1,0,0,0,0];
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _perUserAvIDs:Array;
      
      public var _userNames:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _displayAchievementTimer:Number = 0;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerPlayers:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _layerBackground:Sprite;
      
      public var _layerFort1:Sprite;
      
      public var _layerFort2:Sprite;
      
      public var _readyLevelDisplayTimer:Number;
      
      public var _readyLevelDisplay:Object;
      
      public var _totalPlayers:int;
      
      public var _gameState:int;
      
      public var _players:Array;
      
      public var _levelIndex:int;
      
      public var _queueGameOver:Boolean;
      
      public var _queueCluster:Boolean;
      
      public var _queueNextTurn:Boolean;
      
      public var _activePlayerIndex:int;
      
      public var _fort:int;
      
      public var _terrain:int;
      
      public var _backgrounds:Array;
      
      public var _gravity:Number;
      
      public var _launchForce:Number;
      
      public var _damageThreshold:Number;
      
      public var _zoomed:Boolean;
      
      public var _zoomTransitionTime:Number;
      
      public var _materialSounds:Array;
      
      public var _fortPopup:MovieClip;
      
      public var _terrainPopup:MovieClip;
      
      public var _zoomRight:Boolean;
      
      public var _scorePopupPool:Array;
      
      public var _trailDotPool:Array;
      
      public var _currentPowerupLocIndex:int;
      
      public var _randomizer:RandomSeed;
      
      public var _timeOut:Number;
      
      public var _allowClusterClick:Boolean;
      
      public var _clusterSteps:int;
      
      public var _playerDropped:Boolean;
      
      public var _levelsUnlocked:int;
      
      public var _deleteList:Array;
      
      public var _hideList:Array;
      
      public var _endTurnTimer:Number;
      
      public var _forcePreviousTerrain:int;
      
      public var _projectilePool:Array;
      
      public var _forcePanLeft:Boolean;
      
      public var _outOfAmmo:Boolean;
      
      public var _zoomPivotX:Number;
      
      public var _zoomPivotY:Number;
      
      public var _tie:Boolean;
      
      public var _inputEnabled:Boolean;
      
      public var _buildMode:Boolean;
      
      public var _doDestruction:Boolean;
      
      public var _currentDragger:Object;
      
      private var _currentDebugMaterial:int;
      
      private var _currentDebugProjectileType:int;
      
      private var _debugSliderDensity:Object;
      
      private var _debugSliderFriction:Object;
      
      private var _debugSliderBounce:Object;
      
      private var _debugSliderStrength:Object;
      
      private var _debugSliderDamage:Object;
      
      private var _debugSliderGravity:Object;
      
      private var _debugSliderLaunchForce:Object;
      
      private var _debugSliderDamageThreshold:Object;
      
      private var _queueFortReset:Boolean;
      
      private var _materialOverride:int;
      
      private var _clusterSliders:Array = [];
      
      private var _clustersLoaded:int;
      
      public var _world:b2World;
      
      private var _contactListener:FortSmasherContactListener;
      
      private var _iterations:int = 13;
      
      public var _timeStep:Number = 0.020833333333333332;
      
      public var _phyScale:Number = 0.03333333333333333;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["fs_phantom_death_spiral.mp3","fs_projectile_launch.mp3","fs_fruit_imp1.mp3","fs_fruit_imp2.mp3","fs_fruit_imp3.mp3","fs_glass_crack1.mp3","fs_glass_crack2.mp3","fs_glass_shatter1.mp3","fs_glass_shatter2.mp3","fs_glass_shatter3.mp3","fs_metal_creak1.mp3","fs_metal_creak2.mp3","fs_metal_shatter.mp3","fs_mus_intro.mp3","fs_phantom_grunt1.mp3","fs_phantom_grunt2.mp3","fs_phantom_grunt3.mp3","fs_phantom_grunt4.mp3","fs_powerup.mp3","fs_projectile_df_fire.mp3","fs_rock_crack1.mp3","fs_rock_crack2.mp3","fs_rock_shatter1.mp3","fs_rock_shatter2.mp3","fs_rock_shatter3.mp3","fs_slingshot_stretch_1.mp3","fs_slingshot_stretch_2.mp3","fs_stinger_fail.mp3","fs_stinger_win.mp3","fs_stinger_your_turn.mp3","fs_timer_tick1.mp3","fs_wood_crack1.mp3","fs_wood_crack2.mp3","fs_wood_crack3.mp3","fs_wood_shatter1.mp3","fs_wood_shatter2.mp3","fs_projectile_split.mp3","fs_level_select.mp3","fs_projectile_compact.mp3","fs_projectile_large.mp3","fs_projectile_spin.mp3","fs_popup.mp3","fs_fruit_reload.mp3"
      ,"fs_fruit_splat.mp3"];
      
      internal var _soundNamePhantomDeathSpiral:String = _audio[0];
      
      internal var _soundNameProjectileLaunch:String = _audio[1];
      
      internal var _soundNameFruitImp1:String = _audio[2];
      
      internal var _soundNameFruitImp2:String = _audio[3];
      
      internal var _soundNameFruitImp3:String = _audio[4];
      
      internal var _soundNameGlassCrack1:String = _audio[5];
      
      internal var _soundNameGlassCrack2:String = _audio[6];
      
      internal var _soundNameGlassShatter1:String = _audio[7];
      
      internal var _soundNameGlassShatter2:String = _audio[8];
      
      internal var _soundNameGlassShatter3:String = _audio[9];
      
      internal var _soundNameMetalCreak1:String = _audio[10];
      
      internal var _soundNameMetalCreak2:String = _audio[11];
      
      internal var _soundNameMetalShatter:String = _audio[12];
      
      internal var _soundNameMusIntro:String = _audio[13];
      
      internal var _soundNamePhantomGrunt1:String = _audio[14];
      
      internal var _soundNamePhantomGrunt2:String = _audio[15];
      
      internal var _soundNamePhantomGrunt3:String = _audio[16];
      
      internal var _soundNamePhantomGrunt4:String = _audio[17];
      
      internal var _soundNamePowerup:String = _audio[18];
      
      internal var _soundNameProjectileFlying:String = _audio[19];
      
      internal var _soundNameRockCrack1:String = _audio[20];
      
      internal var _soundNameRockCrack2:String = _audio[21];
      
      internal var _soundNameRockShatter1:String = _audio[22];
      
      internal var _soundNameRockShatter2:String = _audio[23];
      
      internal var _soundNameRockShatter3:String = _audio[24];
      
      internal var _soundNameSlingshotStretch1:String = _audio[25];
      
      internal var _soundNameSlingshotStretch2:String = _audio[26];
      
      internal var _soundNameStingerFail:String = _audio[27];
      
      internal var _soundNameStingerWin:String = _audio[28];
      
      internal var _soundNameStingerYourTurn:String = _audio[29];
      
      internal var _soundNameTimerTick1:String = _audio[30];
      
      internal var _soundNameWoodCrack1:String = _audio[31];
      
      internal var _soundNameWoodCrack2:String = _audio[32];
      
      internal var _soundNameWoodCrack3:String = _audio[33];
      
      internal var _soundNameWoodShatter1:String = _audio[34];
      
      internal var _soundNameWoodShatter2:String = _audio[35];
      
      internal var _soundNameProjectileSplit:String = _audio[36];
      
      internal var _soundNameLevelSelect:String = _audio[37];
      
      internal var _soundNameProjectileCompact:String = _audio[38];
      
      internal var _soundNameProjectileLarge:String = _audio[39];
      
      internal var _soundNameProjectileSpin:String = _audio[40];
      
      internal var _soundNamePopup:String = _audio[41];
      
      internal var _soundNameFruitReload:String = _audio[42];
      
      internal var _soundNameFruitSplat:String = _audio[43];
      
      public var _SFX_Music:SBMusic;
      
      private var _SFX_Music_Instance:SoundChannel;
      
      private var _SFX_Intro_Instance:SoundChannel;
      
      public function FortSmasher()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("fs_ambience",0.25);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDeathSpiral],_soundNamePhantomDeathSpiral,0.47);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileLaunch],_soundNameProjectileLaunch,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitImp1],_soundNameFruitImp1,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitImp2],_soundNameFruitImp2,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitImp3],_soundNameFruitImp3,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameGlassCrack1],_soundNameGlassCrack1,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameGlassCrack2],_soundNameGlassCrack2,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameGlassShatter1],_soundNameGlassShatter1,1);
         _soundMan.addSoundByName(_audioByName[_soundNameGlassShatter2],_soundNameGlassShatter2,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameGlassShatter3],_soundNameGlassShatter3,0.74);
         _soundMan.addSoundByName(_audioByName[_soundNameMetalCreak1],_soundNameMetalCreak1,0.34);
         _soundMan.addSoundByName(_audioByName[_soundNameMetalCreak2],_soundNameMetalCreak2,0.34);
         _soundMan.addSoundByName(_audioByName[_soundNameMetalShatter],_soundNameMetalShatter,0.41);
         _soundMan.addSoundByName(_audioByName[_soundNameMusIntro],_soundNameMusIntro,0.64);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomGrunt1],_soundNamePhantomGrunt1,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomGrunt2],_soundNamePhantomGrunt2,0.48);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomGrunt3],_soundNamePhantomGrunt3,0.54);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomGrunt4],_soundNamePhantomGrunt4,0.54);
         _soundMan.addSoundByName(_audioByName[_soundNamePowerup],_soundNamePowerup,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileFlying],_soundNameProjectileFlying,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameRockCrack1],_soundNameRockCrack1,0.53);
         _soundMan.addSoundByName(_audioByName[_soundNameRockCrack2],_soundNameRockCrack2,0.56);
         _soundMan.addSoundByName(_audioByName[_soundNameRockShatter1],_soundNameRockShatter1,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameRockShatter2],_soundNameRockShatter2,0.57);
         _soundMan.addSoundByName(_audioByName[_soundNameRockShatter3],_soundNameRockShatter3,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameSlingshotStretch1],_soundNameSlingshotStretch1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameSlingshotStretch2],_soundNameSlingshotStretch2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.64);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerWin],_soundNameStingerWin,0.62);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerYourTurn],_soundNameStingerYourTurn,0.57);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerTick1],_soundNameTimerTick1,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodCrack1],_soundNameWoodCrack1,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodCrack2],_soundNameWoodCrack2,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodCrack3],_soundNameWoodCrack3,0.46);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodShatter1],_soundNameWoodShatter1,0.71);
         _soundMan.addSoundByName(_audioByName[_soundNameWoodShatter2],_soundNameWoodShatter2,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileSplit],_soundNameProjectileSplit,0.48);
         _soundMan.addSoundByName(_audioByName[_soundNameLevelSelect],_soundNameLevelSelect,0.56);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileCompact],_soundNameProjectileCompact,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileLarge],_soundNameProjectileLarge,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameProjectileSpin],_soundNameProjectileSpin,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNamePopup],_soundNamePopup,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitReload],_soundNameFruitReload,0.32);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitSplat],_soundNameFruitSplat,0.43);
         _materialSounds = [];
         _materialSounds[3] = [];
         _materialSounds[3][1] = [];
         _materialSounds[3][1][0] = _soundNameGlassCrack1;
         _materialSounds[3][1][1] = _soundNameGlassCrack2;
         _materialSounds[3][2] = [];
         _materialSounds[3][2][0] = _soundNameGlassShatter1;
         _materialSounds[3][2][1] = _soundNameGlassShatter2;
         _materialSounds[3][2][2] = _soundNameGlassShatter3;
         _materialSounds[2] = [];
         _materialSounds[2][1] = [];
         _materialSounds[2][1][0] = _soundNameWoodCrack1;
         _materialSounds[2][1][1] = _soundNameWoodCrack2;
         _materialSounds[2][1][2] = _soundNameWoodCrack3;
         _materialSounds[2][2] = [];
         _materialSounds[2][2][0] = _soundNameWoodShatter1;
         _materialSounds[2][2][1] = _soundNameWoodShatter2;
         _materialSounds[1] = [];
         _materialSounds[1][1] = [];
         _materialSounds[1][1][0] = _soundNameMetalCreak1;
         _materialSounds[1][1][1] = _soundNameMetalCreak2;
         _materialSounds[1][2] = [];
         _materialSounds[1][2][0] = _soundNameMetalShatter;
         _materialSounds[4] = [];
         _materialSounds[4][1] = [];
         _materialSounds[4][1][0] = _soundNameRockCrack1;
         _materialSounds[4][1][1] = _soundNameRockCrack2;
         _materialSounds[4][2] = [];
         _materialSounds[4][2][0] = _soundNameRockShatter1;
         _materialSounds[4][2][1] = _soundNameRockShatter2;
         _materialSounds[4][2][2] = _soundNameRockShatter3;
         _materialSounds[5] = [];
         _materialSounds[5][1] = [];
         _materialSounds[5][1][0] = _soundNamePhantomGrunt1;
         _materialSounds[5][1][1] = _soundNamePhantomGrunt2;
         _materialSounds[5][1][2] = _soundNamePhantomGrunt3;
         _materialSounds[5][1][3] = _soundNamePhantomGrunt4;
         _materialSounds[6] = [];
         _materialSounds[6][0] = [];
         _materialSounds[6][0][0] = _soundNameFruitImp1;
         _materialSounds[6][0][1] = _soundNameFruitImp2;
         _materialSounds[6][0][2] = _soundNameFruitImp3;
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
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         if(_SFX_Intro_Instance)
         {
            _SFX_Intro_Instance.stop();
            _SFX_Intro_Instance = null;
         }
         releaseBase();
         stage.removeEventListener("keyDown",winGameOverDlgKeyDown);
         stage.removeEventListener("keyDown",ngFactTieKeyDown);
         stage.removeEventListener("keyDown",ngFactLoseKeyDown);
         stage.removeEventListener("keyDown",ngFactWinKeyDown);
         stage.removeEventListener("keyDown",ngFactContinueKeyDown);
         stage.removeEventListener("keyDown",ngFactYouWinPlayerKeyDown);
         stage.removeEventListener("keyDown",exitMultiPlayerKeyDown);
         stage.removeEventListener("keyDown",greatJobDlgKeyDown);
         stage.removeEventListener("keyDown",youWinDlgKeyDown);
         stage.removeEventListener("keyDown",optionsDlgKeyDown);
         stage.removeEventListener("keyDown",titleKeyDown);
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         _world = null;
         removeLayer(_layerBackground);
         removeLayer(_layerPlayers);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _layerFort2 = null;
         _layerFort1 = null;
         _layerBackground = null;
         _layerPlayers = null;
         _layerPopups = null;
         _guiLayer = null;
         unloadSounds();
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            setGameState(0);
            _layerBackground = new Sprite();
            _layerFort1 = new Sprite();
            _layerFort2 = new Sprite();
            _layerPlayers = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerPlayers);
            addChild(_layerPopups);
            addChild(_guiLayer);
            _backgrounds = [];
            _terrain = 0;
            _playerDropped = false;
            loadScene("FortSmasherAssets/room_bg1.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function setCameraView(param1:Number, param2:Boolean = true) : void
      {
         _layerBackground.y = _layerPlayers.y = _layerPopups.y = 550 * (1 - param1);
         _layerPlayers.scaleX = _layerPlayers.scaleY = _layerBackground.scaleX = _layerBackground.scaleY = _layerPopups.scaleX = _layerPopups.scaleY = param1;
         if(_zoomRight && param2)
         {
            _layerBackground.x = _layerPlayers.x = _layerPopups.x = 1800 * (0.5 - param1);
         }
      }
      
      private function setZoomView(param1:Number) : void
      {
         _layerBackground.y = _layerPlayers.y = _layerPopups.y = 550 - _zoomPivotY - param1 * (550 - _zoomPivotY * 2);
         _layerPlayers.scaleX = _layerPlayers.scaleY = _layerBackground.scaleX = _layerBackground.scaleY = _layerPopups.scaleX = _layerPopups.scaleY = param1;
         _layerBackground.x = _layerPlayers.x = _layerPopups.x = _zoomPivotX * (0.5 - param1);
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Object = null;
         var _loc2_:Array = null;
         if(_scene.getLayer("bg"))
         {
            _loc4_ = {};
            _loc4_.lines = _scene.getActorList("ActorCollisionPoint");
            _loc4_.ground = _scene.getLayer("ground");
            _loc4_.ground2 = null;
            _loc4_.bg = _scene.getLayer("bg");
            _loc4_.spawn1 = _scene.getActorList("ActorSpawn")[0];
            _loc4_.spawn2 = _scene.getActorList("ActorSpawn")[1];
            _loc4_.powerupLocs = _scene.getActorList("ActorSpawn").slice(2);
            if(_loc4_.ground == null)
            {
               _loc4_.ground = _scene.getLayer("ground1");
               _loc4_.ground2 = _scene.getLayer("ground2");
            }
            _backgrounds[_terrain++] = _loc4_;
            if(_terrain < 5)
            {
               loadScene("FortSmasherAssets/room_bg" + (_terrain + 1) + ".xroom");
            }
            else
            {
               loadScene("FortSmasherAssets/room_main.xroom");
            }
         }
         else
         {
            _soundMan = new SoundManager(this);
            loadSounds();
            _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,999999);
            _fort = -1;
            _terrain = -1;
            _currentPowerupLocIndex = 0;
            _currentDebugMaterial = -1;
            _currentDebugProjectileType = -1;
            _loc3_ = _scene.getLayer("fort_ui").loader;
            if(_totalPlayers == 2)
            {
               _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
            }
            else
            {
               _closeBtn = addBtn("CloseButton",847,1,showOptionsDlg);
               _guiLayer.addChild(_loc3_ as DisplayObject);
               _guiLayer.addChild(_scene.getLayer("magnify").loader);
            }
            _sceneLoaded = true;
            stage.addEventListener("enterFrame",heartbeat,false,0,true);
            _inputEnabled = false;
            _layerBackground.addChild(_scene.getLayer("waitingbg").loader);
            _scene.getLayer("magnify").loader.content.magnifyBtn.addEventListener("mouseDown",zoomToggle);
            _scene.getLayer("magnify").loader.content.magnifyBtn.addEventListener("mouseOver",magnifyOver);
            _scene.getLayer("magnify").loader.content.magnifyBtn.addEventListener("mouseOut",magnifyOut);
            _scene.getLayer("magnify").loader.content.magnifyBtn.addEventListener("mouseUp",magnifyOver);
            _loc3_.content.fruit1.addEventListener("mouseOver",fruit1Over);
            _loc3_.content.fruit2.addEventListener("mouseOver",fruit2Over);
            _loc3_.content.fruit3.addEventListener("mouseOver",fruit3Over);
            _loc3_.content.fruit4.addEventListener("mouseOver",fruit4Over);
            _loc3_.content.fruit5.addEventListener("mouseOver",fruit5Over);
            _loc3_.content.fruit1.addEventListener("mouseOut",fruitOut);
            _loc3_.content.fruit2.addEventListener("mouseOut",fruitOut);
            _loc3_.content.fruit3.addEventListener("mouseOut",fruitOut);
            _loc3_.content.fruit4.addEventListener("mouseOut",fruitOut);
            _loc3_.content.fruit5.addEventListener("mouseOut",fruitOut);
            _loc3_.content.fruit1.addEventListener("click",fruitClick);
            _loc3_.content.fruit2.addEventListener("click",fruitClick);
            _loc3_.content.fruit3.addEventListener("click",fruitClick);
            _loc3_.content.fruit4.addEventListener("click",fruitClick);
            _loc3_.content.fruit5.addEventListener("click",fruitClick);
            _gravity = 18;
            _launchForce = 23;
            _damageThreshold = 250;
            _zoomed = false;
            _zoomTransitionTime = 0;
            _materialOverride = -1;
            _scorePopupPool = [];
            _trailDotPool = [];
            _deleteList = [];
            _hideList = [];
            _forcePreviousTerrain = -1;
            _projectilePool = [];
            _tie = false;
            LocalizationManager.updateToFit(_loc3_.content.nameLTextCont.nameLText,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_perUserAvIDs[0]).avName);
            if(_totalPlayers == 2)
            {
               LocalizationManager.updateToFit(_loc3_.content.nameRTextCont.nameRText,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_perUserAvIDs[1]).avName);
            }
            else
            {
               LocalizationManager.updateToFit(_loc3_.content.nameRTextCont.nameRText,"");
            }
            _SFX_Intro_Instance = _soundMan.playByName(_soundNameMusIntro);
            if(_SFX_Music_Instance == null)
            {
               _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,99999);
            }
            if(_totalPlayers == 2)
            {
               showWaitingPopup();
               setGameState(1);
            }
            else
            {
               _loc2_ = new Array(3);
               _loc2_[0] = "1";
               _loc2_[1] = "1";
               _loc2_[2] = myId.toString();
               setupPlayers(_loc2_);
            }
            super.sceneLoaded(param1);
         }
      }
      
      public function getProjectileAsset(param1:int) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _projectilePool.length)
         {
            _loc3_ = _projectilePool[_loc2_];
            if(_loc3_.loader.content.finished)
            {
               _loc3_.loader.content.setType(param1 + 1);
               _projectilePool.splice(_loc2_,1);
               if(param1 == 3)
               {
                  if(_activePlayerIndex == 0)
                  {
                     _loc3_.loader.content.starSpin(-1);
                  }
                  else
                  {
                     _loc3_.loader.content.starSpin(1);
                  }
               }
               return _loc3_;
            }
            _loc2_++;
         }
         _loc3_ = _scene.cloneAsset("phantom1");
         _loc3_.loader.contentLoaderInfo.addEventListener("complete",this["onProjectileLoadComplete" + (param1 + 1)]);
         _layerPlayers.addChild(_loc3_.loader);
         return _loc3_;
      }
      
      private function onProjectileLoadComplete1(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete1);
         param1.target.content.setType(1);
      }
      
      private function onProjectileLoadComplete2(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete2);
         param1.target.content.setType(2);
      }
      
      private function onProjectileLoadComplete3(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete3);
         param1.target.content.setType(3);
      }
      
      private function onProjectileLoadComplete4(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete4);
         param1.target.content.setType(4);
         if(_activePlayerIndex == 0)
         {
            param1.target.content.starSpin(-1);
         }
         else
         {
            param1.target.content.starSpin(1);
         }
      }
      
      private function onProjectileLoadComplete5(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete5);
         param1.target.content.setType(5);
      }
      
      private function onProjectileLoadComplete6(param1:Event) : void
      {
         param1.target.removeEventListener("complete",onProjectileLoadComplete6);
         param1.target.content.setType(6);
      }
      
      private function getUIFruitIndex(param1:int) : int
      {
         switch(param1)
         {
            case 0:
               return 1;
            case 1:
               return 3;
            case 2:
               return 2;
            case 3:
               return 4;
            case 4:
               return 5;
            default:
               return 0;
         }
      }
      
      public function setFruitHighlight(param1:int) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Object = _scene.getLayer("fort_ui").loader.content;
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         _loc4_ = 1;
         while(_loc4_ <= 5)
         {
            if(_loc4_ == param1)
            {
               _loc2_["fruit" + _loc4_].scaleX = _loc2_["fruit" + _loc4_].scaleY = 1.3;
               _loc2_["fruit" + _loc4_].gotoAndStop("highlight");
            }
            else if(_players[_loc3_]._projectileType + 1 != _loc4_)
            {
               _loc2_["fruit" + _loc4_].scaleX = _loc2_["fruit" + _loc4_].scaleY = 1;
               if(_ammo[_loc4_ - 1] > 0)
               {
                  _loc2_["fruit" + _loc4_].gotoAndStop("off");
               }
               else
               {
                  _loc2_["fruit" + _loc4_].gotoAndStop("gray");
               }
            }
            _loc4_++;
         }
      }
      
      private function fruit1Over(param1:MouseEvent) : void
      {
         if(_ammo[0] > 0)
         {
            _scene.getLayer("fort_ui").loader.content.popup(1);
            _soundMan.playByName(_soundNamePopup);
            setFruitHighlight(1);
         }
      }
      
      private function fruit2Over(param1:MouseEvent) : void
      {
         if(_ammo[1] > 0)
         {
            _scene.getLayer("fort_ui").loader.content.popup(3);
            _soundMan.playByName(_soundNamePopup);
            setFruitHighlight(2);
         }
      }
      
      private function fruit3Over(param1:MouseEvent) : void
      {
         if(_ammo[2] > 0)
         {
            _scene.getLayer("fort_ui").loader.content.popup(2);
            _soundMan.playByName(_soundNamePopup);
            setFruitHighlight(3);
         }
      }
      
      private function fruit4Over(param1:MouseEvent) : void
      {
         if(_ammo[3] > 0)
         {
            _scene.getLayer("fort_ui").loader.content.popup(5);
            _soundMan.playByName(_soundNamePopup);
            setFruitHighlight(4);
         }
      }
      
      private function fruit5Over(param1:MouseEvent) : void
      {
         if(_ammo[4] > 0)
         {
            _scene.getLayer("fort_ui").loader.content.popup(4);
            _soundMan.playByName(_soundNamePopup);
            setFruitHighlight(5);
         }
      }
      
      private function fruitOut(param1:MouseEvent) : void
      {
         fruitOutTarget(param1.currentTarget);
      }
      
      private function fruitOutTarget(param1:Object) : void
      {
         _scene.getLayer("fort_ui").loader.content.popup(0);
         var _loc2_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc3_:int = _players[_loc2_]._projectileType + 1;
         if(param1.hasOwnProperty("fruit1") && _ammo[0] > 0 || param1.hasOwnProperty("fruit2") && _ammo[1] > 0 || param1.hasOwnProperty("fruit3") && _ammo[2] > 0 || param1.hasOwnProperty("fruit4") && _ammo[3] > 0 || param1.hasOwnProperty("fruit5") && _ammo[4] > 0)
         {
            if(param1.hasOwnProperty("fruit" + _loc3_))
            {
               param1.gotoAndStop("highlight");
               setFruitHighlight(_loc3_);
               param1.scaleX = param1.scaleY = 1.3;
            }
            else
            {
               param1.gotoAndStop("off");
               param1.scaleX = param1.scaleY = 1;
            }
         }
         else
         {
            param1.gotoAndStop("gray");
            param1.scaleX = param1.scaleY = 1;
         }
      }
      
      private function fruitClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(_players[_activePlayerIndex]._localPlayer && _players[_activePlayerIndex]._hasTurn && _players[_activePlayerIndex]._doHeartbeat)
         {
            _loc2_ = _scene.getLayer("fort_ui").loader.content;
            _loc2_.popup(0);
            if(param1.currentTarget.hasOwnProperty("fruit1") && _ammo[0] > 0)
            {
               _players[_activePlayerIndex].setProjectileType(0);
            }
            else if(param1.currentTarget.hasOwnProperty("fruit2") && _ammo[1] > 0)
            {
               _players[_activePlayerIndex].setProjectileType(1);
            }
            else if(param1.currentTarget.hasOwnProperty("fruit3") && _ammo[2] > 0)
            {
               _players[_activePlayerIndex].setProjectileType(2);
            }
            else if(param1.currentTarget.hasOwnProperty("fruit4") && _ammo[3] > 0)
            {
               _players[_activePlayerIndex].setProjectileType(3);
            }
            else if(param1.currentTarget.hasOwnProperty("fruit5") && _ammo[4] > 0)
            {
               _players[_activePlayerIndex].setProjectileType(4);
            }
            setFruitHighlight(_players[_activePlayerIndex]._projectileType + 1);
         }
      }
      
      private function magnifyToggle(param1:MouseEvent) : void
      {
         if(_zoomTransitionTime <= 0)
         {
            if(_zoomed)
            {
               if(param1)
               {
                  _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("in_press");
               }
               else
               {
                  _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("out");
               }
            }
            else if(param1)
            {
               _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("out_press");
            }
            else
            {
               _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("in");
            }
            _zoomed = !_zoomed;
            _zoomTransitionTime = 1;
         }
      }
      
      private function getLevelYPivot() : Number
      {
         if(_totalPlayers == 1 && (_fort + 25 == 53 || _fort + 25 == 68))
         {
            return 200;
         }
         return 0;
      }
      
      private function zoomToggle(param1:MouseEvent) : void
      {
         if(_zoomTransitionTime <= 0)
         {
            if(_zoomed)
            {
               _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("in_press");
            }
            else
            {
               _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("out_press");
            }
            if(_activePlayerIndex == 0)
            {
               if(_players[0]._doHeartbeat || _zoomed)
               {
                  _zoomPivotX = -_layerBackground.x * 2;
                  _zoomPivotY = getLevelYPivot() * _zoomPivotX / 1800;
               }
               else
               {
                  _zoomPivotX = 1800;
                  _zoomPivotY = getLevelYPivot();
               }
            }
            else
            {
               _zoomPivotY = 0;
               if(_players[1]._doHeartbeat)
               {
                  _zoomPivotX = 1800;
               }
               else if(_zoomed)
               {
                  _zoomPivotX = -_layerBackground.x * 2;
               }
               else
               {
                  _zoomPivotX = 0;
               }
            }
            _zoomed = !_zoomed;
            _zoomTransitionTime = 1;
         }
      }
      
      private function magnifyOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.currentFrameLabel != "out_hi" && param1.currentTarget.currentFrameLabel != "in_hi")
         {
         }
         if(_zoomed)
         {
            param1.currentTarget.gotoAndStop("in_hi");
         }
         else
         {
            param1.currentTarget.gotoAndStop("out_hi");
         }
      }
      
      private function magnifyOut(param1:MouseEvent) : void
      {
         if(_zoomed)
         {
            param1.currentTarget.gotoAndStop("in");
         }
         else
         {
            param1.currentTarget.gotoAndStop("out");
         }
      }
      
      private function getCurrentMaterialName() : String
      {
         switch(_currentDebugMaterial)
         {
            case 0:
               return "Rubber";
            case 1:
               return "Metal";
            case 2:
               return "Wood";
            case 3:
               return "Glass";
            case 4:
               return "Stone";
            case 5:
               return "Relic";
            default:
               return "";
         }
      }
      
      private function getCurrentProjectileName() : String
      {
         switch(_currentDebugProjectileType)
         {
            case 0:
               return "Regular Projectile";
            case 1:
               return "Cluster Projectile";
            case 2:
               return "Heavy Projectile";
            case 3:
               return "Spin Projectile";
            case 4:
               return "Compact Projectile";
            case 5:
               return "Cluster Fragment Projectile";
            default:
               return "";
         }
      }
      
      private function onDebugSliderGravityLoaded(param1:Event) : void
      {
         _debugSliderGravity.loader.content.sliderRange(1,500,_gravity,"Gravity");
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderGravityLoaded);
         }
      }
      
      private function onDebugSliderLaunchForceLoaded(param1:Event) : void
      {
         _debugSliderLaunchForce.loader.content.sliderRange(1,500,_launchForce,"Launch Force");
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderLaunchForceLoaded);
         }
      }
      
      private function onDebugSliderDamageThresholdLoaded(param1:Event) : void
      {
         _debugSliderDamageThreshold.loader.content.sliderRange(0,499,_damageThreshold,"Damage Threshold");
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderDamageThresholdLoaded);
         }
      }
      
      private function onDebugSliderDensityLoaded(param1:Event) : void
      {
         if(_currentDebugMaterial >= 0)
         {
            _debugSliderDensity.loader.content.sliderRange(1,500,_materials[_currentDebugMaterial].density * 100,getCurrentMaterialName() + " Density");
         }
         else
         {
            _debugSliderDensity.loader.content.sliderRange(1,500,_projectiles[_currentDebugProjectileType].density * 100,getCurrentProjectileName() + " Density");
         }
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderDensityLoaded);
         }
      }
      
      private function onDebugSliderFrictionLoaded(param1:Event) : void
      {
         if(_currentDebugMaterial >= 0)
         {
            _debugSliderFriction.loader.content.sliderRange(1,500,_materials[_currentDebugMaterial].friction * 100,getCurrentMaterialName() + " Friction");
         }
         else
         {
            _debugSliderFriction.loader.content.sliderRange(1,500,_projectiles[_currentDebugProjectileType].friction * 100,getCurrentProjectileName() + " Friction");
         }
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderFrictionLoaded);
         }
      }
      
      private function onDebugSliderBounceLoaded(param1:Event) : void
      {
         if(_currentDebugMaterial >= 0)
         {
            _debugSliderBounce.loader.content.sliderRange(1,500,_materials[_currentDebugMaterial].bounce * 100,getCurrentMaterialName() + " Bounce");
         }
         else
         {
            _debugSliderBounce.loader.content.sliderRange(1,500,_projectiles[_currentDebugProjectileType].bounce * 100,getCurrentProjectileName() + " Bounce");
         }
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderBounceLoaded);
         }
      }
      
      private function onDebugSliderStrengthLoaded(param1:Event) : void
      {
         if(_currentDebugMaterial >= 0)
         {
            _debugSliderStrength.loader.content.sliderRange(1,500,_materials[_currentDebugMaterial].strength * 100,getCurrentMaterialName() + " Strength");
         }
         else
         {
            _debugSliderStrength.loader.content.sliderRange(1,500,_projectiles[_currentDebugProjectileType].strength * 100,getCurrentProjectileName() + " Strength");
         }
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderStrengthLoaded);
         }
      }
      
      private function onDebugSliderDamageLoaded(param1:Event) : void
      {
         if(_currentDebugMaterial >= 0)
         {
            _debugSliderDamage.loader.content.sliderRange(1,500,_materials[_currentDebugMaterial].damage * 100,getCurrentMaterialName() + " Damage");
         }
         else
         {
            _debugSliderDamage.loader.content.sliderRange(1,500,_projectiles[_currentDebugProjectileType].damage * 100,getCurrentProjectileName() + " Damage");
         }
         if(param1)
         {
            param1.target.removeEventListener("complete",onDebugSliderDamageLoaded);
         }
      }
      
      private function onDebugSliderClusterLoaded(param1:Event) : void
      {
         _clustersLoaded++;
         if(_clustersLoaded >= _clusterParams.length)
         {
            setupClusterSliders();
         }
         param1.target.removeEventListener("complete",onDebugSliderClusterLoaded);
      }
      
      private function setupClusterSliders() : void
      {
         _clusterSliders[0].loader.content.sliderRange(0,700,_clusterParams[0] * 100,"Velocity Multiplier");
         _clusterSliders[1].loader.content.sliderRange(0,700,_clusterParams[1],"Spread");
      }
      
      public function createPhysicsWorld() : void
      {
         var _loc12_:* = null;
         var _loc4_:b2Body = null;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc1_:b2AABB = new b2AABB();
         _loc1_.lowerBound.Set(-1000,-1000);
         _loc1_.upperBound.Set(1000,1000);
         var _loc5_:b2Vec2 = new b2Vec2(0,_gravity);
         _world = new b2World(_loc1_,_loc5_,true);
         var _loc3_:b2PolygonDef = new b2PolygonDef();
         var _loc6_:b2BodyDef = new b2BodyDef();
         var _loc7_:b2Vec2 = new b2Vec2();
         var _loc8_:b2MassData = new b2MassData();
         for each(_loc12_ in _backgrounds[_terrain].lines)
         {
            _loc11_ = Math.sqrt((_loc12_.x - _loc12_.x1) * (_loc12_.x - _loc12_.x1) + (_loc12_.y - _loc12_.y1) * (_loc12_.y - _loc12_.y1)) / 2;
            _loc7_.x = (_loc12_.x + _loc12_.x1) / 2;
            _loc7_.y = (_loc12_.y + _loc12_.y1) / 2;
            _loc9_ = Math.atan2(_loc12_.y - _loc12_.y1,_loc12_.x - _loc12_.x1);
            _loc6_.position.Set(_loc7_.x * _phyScale,_loc7_.y * _phyScale);
            _loc3_.SetAsOrientedBox(_loc11_ * _phyScale,1 * _phyScale,new b2Vec2(0,0),_loc9_);
            _loc4_ = _world.CreateBody(_loc6_);
            _loc4_.CreateShape(_loc3_);
            _loc4_.SetMassFromShapes();
         }
         _contactListener = new FortSmasherContactListener();
         _world.SetContactListener(_contactListener);
      }
      
      public function spawnPowerup() : void
      {
         var _loc6_:b2Body = null;
         var _loc3_:b2BodyDef = null;
         var _loc5_:Array = _backgrounds[_terrain].powerupLocs;
         var _loc2_:b2PolygonDef = new b2PolygonDef();
         var _loc1_:int = Math.floor(_randomizer.random() * (_loc5_.length - 1));
         _currentPowerupLocIndex += _loc1_;
         if(_currentPowerupLocIndex >= _loc5_.length)
         {
            _currentPowerupLocIndex -= _loc5_.length;
         }
         var _loc7_:Object = _scene.getLayer("powerups").loader;
         var _loc4_:MovieClip = _loc7_.content.fruit;
         if(_loc7_.parent == null)
         {
            _layerPlayers.addChild(_loc7_ as DisplayObject);
         }
         _loc4_.gotoAndStop(Math.floor(_randomizer.random() * 4) + 3);
         _loc7_.x = _loc5_[_currentPowerupLocIndex].x;
         _loc7_.y = _loc5_[_currentPowerupLocIndex].y;
         _loc2_.SetAsOrientedBox(_loc7_.content.collision.width * 0.5 * _phyScale,_loc7_.content.collision.height * 0.5 * _phyScale);
         _loc2_.isSensor = true;
         _loc3_ = new b2BodyDef();
         _loc3_.position.x = _loc7_.x * _phyScale;
         _loc3_.position.y = _loc7_.y * _phyScale;
         _loc6_ = _world.CreateBody(_loc3_);
         _loc6_.CreateShape(_loc2_);
         _loc6_.SetMassFromShapes();
      }
      
      public function buildForts(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _layerBackground.addChild(_backgrounds[_terrain].bg.loader);
            _layerBackground.addChild(_backgrounds[_terrain].ground.loader);
            if(_backgrounds[_terrain].ground2)
            {
               _layerBackground.addChild(_backgrounds[_terrain].ground2.loader);
            }
            setCameraView(0.5);
            _layerBackground.addChild(_layerFort1);
            if(_totalPlayers == 2)
            {
               _layerBackground.addChild(_layerFort2);
            }
         }
         if(_totalPlayers == 2)
         {
            _loc3_ = 0;
            while(_loc3_ < 2)
            {
               _loc2_ = _players[_loc3_]._fort;
               _loc2_.loader.x = _backgrounds[_terrain]["spawn" + (_loc3_ + 1)].x;
               _loc2_.loader.y = _backgrounds[_terrain]["spawn" + (_loc3_ + 1)].y;
               _players[_loc3_]._slingshot.loader.x = _loc3_ == 0 ? _loc2_.loader.x + 300 : _loc2_.loader.x - 300;
               _players[_loc3_]._slingshot.loader.y = _loc2_.loader.y;
               _loc2_.loader.content.setFort(_fort + 1);
               _loc3_++;
            }
         }
         else
         {
            _loc2_ = _players[0]._fort;
            _loc2_.loader.x = _backgrounds[_terrain]["spawn2"].x;
            _loc2_.loader.y = _backgrounds[_terrain]["spawn2"].y;
            _players[0]._slingshot.loader.x = _backgrounds[_terrain]["spawn1"].x;
            _players[0]._slingshot.loader.y = _backgrounds[_terrain]["spawn1"].y;
         }
      }
      
      public function startNextLevel(param1:Boolean = false, param2:Boolean = true) : void
      {
         var _loc12_:Object = null;
         var _loc9_:int = 0;
         var _loc13_:int = 0;
         var _loc15_:int = 0;
         var _loc5_:* = null;
         var _loc6_:b2Body = null;
         var _loc10_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc14_:Object = null;
         stage.removeEventListener("keyDown",greatJobDlgKeyDown);
         hideDlg();
         var _loc11_:Boolean = false;
         _players[0].removeTrail();
         setCameraView(0.5);
         _layerBackground.x = _layerPlayers.x = _layerPopups.x = 0;
         _players[0]._doHeartbeat = true;
         _players[0]._hasTurn = true;
         _scene.getLayer("magnify").loader.content.magnifyBtn.gotoAndStop("out");
         _zoomed = false;
         _players[0]._slingshot.loader.content.previewOn();
         if(!param1 && _forcePreviousTerrain < 0 && param2)
         {
            _fort++;
         }
         _players[0]._score = 0;
         _scene.getLayer("fort_ui").loader.content.scoreTxtCont.scoreText.text = "0";
         _outOfAmmo = false;
         var _loc16_:Object = _scene.getLayer("fort_ui").loader;
         _loc9_ = 0;
         while(_loc9_ < 5)
         {
            _loc16_.content["counter" + getUIFruitIndex(_loc9_) + "Cont"]["counter" + getUIFruitIndex(_loc9_)].text = _ammo[_loc9_] = _levelAmmo[_fort - 1][_loc9_];
            fruitOutTarget(_loc16_.content["fruit" + (_loc9_ + 1)]);
            _loc9_++;
         }
         if(!param1)
         {
            updateUI();
            if(_fort % 10 == 1 || _forcePreviousTerrain >= 0)
            {
               _loc11_ = true;
               if(param2)
               {
                  if(_forcePreviousTerrain < 0)
                  {
                     _terrain++;
                  }
                  _layerBackground.addChildAt(_backgrounds[_terrain].bg.loader,1);
                  _layerBackground.addChildAt(_backgrounds[_terrain].ground.loader,2);
                  if(_backgrounds[_terrain].ground2)
                  {
                     _layerBackground.addChildAt(_backgrounds[_terrain].ground2.loader,3);
                  }
               }
               _loc13_ = _terrain;
               if(_forcePreviousTerrain >= 0)
               {
                  _loc13_ = _forcePreviousTerrain;
               }
               else if(param2)
               {
                  _loc13_ = _terrain - 1;
               }
               if(_loc13_ != _terrain)
               {
                  _layerBackground.removeChild(_backgrounds[_loc13_].bg.loader);
                  _layerBackground.removeChild(_backgrounds[_loc13_].ground.loader);
                  if(_backgrounds[_loc13_].ground2)
                  {
                     _layerBackground.removeChild(_backgrounds[_loc13_].ground2.loader);
                  }
               }
            }
            _loc15_ = _fort % 10;
            if(_loc15_ == 0)
            {
               _loc15_ = 10;
            }
            _scene.getLayer("magnify").loader.content.levelText.text = _terrain + 1 + " - " + _loc15_;
         }
         _players[0].setProjectileType(_terrain,true);
         setFruitHighlight(_terrain + 1);
         if(_levelsUnlocked == _fort && _fort % 10 == 1)
         {
            this["fruit" + (_terrain + 1) + "Over"](null);
         }
         var _loc3_:b2Body = _world.m_bodyList;
         while(_loc3_)
         {
            _loc5_ = _loc3_;
            _loc3_ = _loc3_.GetNext();
            if(_totalPlayers == 1 && _players[0].isPlayerBody(_loc5_))
            {
               _players[0].destroyBody(_loc5_);
            }
            else
            {
               _world.DestroyBody(_loc5_);
            }
         }
         var _loc4_:b2PolygonDef = new b2PolygonDef();
         var _loc17_:b2BodyDef = new b2BodyDef();
         var _loc7_:b2Vec2 = new b2Vec2();
         var _loc8_:b2MassData = new b2MassData();
         for each(_loc12_ in _backgrounds[_terrain].lines)
         {
            _loc10_ = Math.sqrt((_loc12_.x - _loc12_.x1) * (_loc12_.x - _loc12_.x1) + (_loc12_.y - _loc12_.y1) * (_loc12_.y - _loc12_.y1)) / 2;
            _loc7_.x = (_loc12_.x + _loc12_.x1) / 2;
            _loc7_.y = (_loc12_.y + _loc12_.y1) / 2;
            _loc18_ = Math.atan2(_loc12_.y - _loc12_.y1,_loc12_.x - _loc12_.x1);
            _loc17_.position.Set(_loc7_.x * _phyScale,_loc7_.y * _phyScale);
            _loc4_.SetAsOrientedBox(_loc10_ * _phyScale,1 * _phyScale,new b2Vec2(0,0),_loc18_);
            _loc6_ = _world.CreateBody(_loc17_);
            _loc6_.CreateShape(_loc4_);
            _loc6_.SetMassFromShapes();
         }
         _loc14_ = _players[0]._fort;
         _loc14_.loader.x = _backgrounds[_terrain]["spawn2"].x;
         _loc14_.loader.y = _backgrounds[_terrain]["spawn2"].y;
         _players[0]._slingshot.loader.x = _backgrounds[_terrain]["spawn1"].x;
         _players[0]._slingshot.loader.y = _backgrounds[_terrain]["spawn1"].y;
         _loc14_.loader.content.addEventListener("mouseDown",fortPieceDrag);
         _loc14_.loader.content.addEventListener("mouseUp",fortPieceRelease);
         _loc9_ = 0;
         while(_loc9_ < _loc14_.loader.content.numChildren)
         {
            _loc12_ = _loc14_.loader.content.getChildAt(_loc9_);
            _loc12_.visible = true;
            if(_loc12_ is Class(getDefinitionByName("Relic")))
            {
               _loc12_.doDamage(0);
            }
            else
            {
               _loc12_.gotoAndStop(1);
               if(_materialOverride > 0)
               {
                  _loc12_.shape.gotoAndStop(_materialOverride + 1);
               }
               else
               {
                  _loc12_.shape.gotoAndStop(_loc12_.materialType + 1);
               }
            }
            _loc12_.damage.gotoAndStop(1);
            _loc12_.hitpoints = 100;
            _loc9_++;
         }
         if(!param1)
         {
            _players[0]._fort.loader.content.gotoAndStop("blank");
            _scene.getLayer("forts2").loader.content.gotoAndStop("blank");
            _players[0]._fort.loader.content.gotoAndStop(_fort + 25);
            _scene.getLayer("forts2").loader.content.gotoAndStop(_fort + 25);
         }
         applyMaterials(0);
         _forcePreviousTerrain = -1;
         setGameState(4);
      }
      
      private function fortPieceDrag(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(_buildMode)
         {
            _loc2_ = param1.target;
            while(_loc2_.parent != _loc2_.root)
            {
               _loc2_ = _loc2_.parent;
            }
            _currentDragger = _loc2_;
            _loc2_.startDrag();
         }
      }
      
      private function fortPieceRelease(param1:MouseEvent) : void
      {
         var _loc3_:* = null;
         var _loc2_:b2Body = null;
         if(_buildMode)
         {
            _loc2_ = _world.GetBodyList();
            while(_loc2_)
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.GetNext();
               if(_loc3_.m_userData == _currentDragger)
               {
                  _loc3_.WakeUp();
               }
            }
            _currentDragger.stopDrag();
            _currentDragger = null;
         }
      }
      
      private function resetForts() : void
      {
         var _loc3_:* = null;
         var _loc11_:int = 0;
         var _loc2_:Object = null;
         var _loc10_:Object = null;
         var _loc4_:b2PolygonDef = null;
         var _loc8_:b2CircleDef = null;
         var _loc9_:b2Body = null;
         var _loc5_:b2BodyDef = null;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:b2Body = _world.m_bodyList;
         while(_loc1_)
         {
            _loc3_ = _loc1_;
            _loc1_ = _loc1_.GetNext();
            if(_loc3_.m_userData is Object)
            {
               _loc10_ = _loc3_.m_userData;
               if(_loc10_.hasOwnProperty("shape"))
               {
                  _world.DestroyBody(_loc3_);
               }
            }
         }
         _loc11_ = 0;
         while(_loc11_ < _totalPlayers)
         {
            _loc2_ = _players[_loc11_]._fort;
            _loc4_ = new b2PolygonDef();
            _loc8_ = new b2CircleDef();
            _players[_loc11_]._numPhantoms = 0;
            _loc7_ = 0;
            for(; _loc7_ < _loc2_.loader.content.numChildren; _loc7_++)
            {
               _loc10_ = _loc2_.loader.content.getChildAt(_loc7_);
               _loc10_.visible = true;
               if(_loc10_ is Class(getDefinitionByName("Relic")))
               {
                  _loc10_.doDamage(0);
               }
               else
               {
                  _loc10_.gotoAndStop(1);
                  if(_materialOverride > 0)
                  {
                     _loc10_.shape.gotoAndStop(_materialOverride + 1);
                  }
                  else
                  {
                     _loc10_.shape.gotoAndStop(_loc10_.materialType + 1);
                  }
               }
               _loc10_.damage.gotoAndStop(1);
               _loc10_.hitpoints = 100;
               _loc10_.x = _loc10_.x0;
               _loc10_.y = _loc10_.y0;
               _loc10_.rotation = 0;
               switch(_loc10_.shapeType)
               {
                  case 0:
                     _loc8_.radius = _loc10_.width * 0.5 * _phyScale;
                     break;
                  case 1:
                     if(_loc10_ is Class(getDefinitionByName("Relic")))
                     {
                        _players[_loc11_]._numPhantoms++;
                        _loc4_.SetAsOrientedBox(_loc10_.shape.relic.collision.width * 0.5 * _phyScale * Math.abs(_loc10_.scaleX),_loc10_.shape.relic.collision.height * 0.5 * _phyScale * _loc10_.scaleY);
                        break;
                     }
                     _loc4_.SetAsOrientedBox(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     break;
                  case 2:
                     _loc4_.vertexCount = 3;
                     _loc4_.vertices[0].Set(0,-_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[2].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     break;
                  case 3:
                     _loc4_.vertexCount = 3;
                     _loc4_.vertices[0].Set(-_loc10_.width * 0.5 * _phyScale,-_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[2].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     break;
                  case 4:
                     _loc4_.vertexCount = 3;
                     _loc4_.vertices[0].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,-_loc10_.height * 0.5 * _phyScale);
                     _loc4_.vertices[2].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                     break;
                  default:
                     continue;
               }
               _loc10_.rotation = _loc10_.rotation0;
               _loc6_ = int(_loc10_.materialType);
               if(_materialOverride > 0)
               {
                  if(_loc6_ != 5 && _loc6_ >= 0)
                  {
                     _loc6_ = _materialOverride;
                  }
               }
               if(_loc10_.materialType >= 0)
               {
                  _loc4_.density = _loc8_.density = _materials[_loc6_].density;
                  _loc4_.friction = _loc8_.friction = _materials[_loc6_].friction;
                  _loc4_.restitution = _loc8_.restitution = _materials[_loc6_].bounce;
               }
               else
               {
                  _loc4_.density = _loc8_.density = 0;
                  _loc4_.friction = _loc8_.friction = 0.2;
                  _loc4_.restitution = _loc8_.restitution = 0;
               }
               _loc5_ = new b2BodyDef();
               _loc5_.position.x = (_loc10_.x + _loc2_.loader.x) * _phyScale;
               _loc5_.position.y = (_loc10_.y + _loc2_.loader.y) * _phyScale;
               _loc5_.angle = _loc10_.rotation * 3.141592653589793 / 180;
               _loc5_.isSleeping = true;
               if(_loc10_.materialType >= 0)
               {
                  _loc5_.userData = _loc10_;
               }
               if(_totalPlayers == 2)
               {
                  _loc4_.filter.maskBits = _loc8_.filter.maskBits = _loc11_ == 0 ? 65533 : 65531;
                  _loc4_.filter.categoryBits = _loc8_.filter.categoryBits = _loc11_ == 0 ? 4 : 2;
               }
               _loc9_ = _world.CreateBody(_loc5_);
               if(_loc10_.shapeType == 0)
               {
                  _loc9_.CreateShape(_loc8_);
                  _loc9_.m_angularDamping = 0.5;
                  if(_totalPlayers == 2)
                  {
                     _loc9_.m_angularDamping = 4;
                  }
               }
               else
               {
                  _loc9_.CreateShape(_loc4_);
               }
               _loc9_.SetMassFromShapes();
            }
            _loc11_++;
         }
      }
      
      private function onStart() : void
      {
         stage.removeEventListener("keyDown",titleKeyDown);
         hideDlg();
         AchievementXtCommManager.requestSetUserVar(143,1);
         _displayAchievementTimer = 1;
         setGameState(5);
      }
      
      private function titleKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onStart();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         if(_gameState != param1)
         {
            if(_readyLevelDisplay && _readyLevelDisplay.loader.parent)
            {
               _readyLevelDisplay.loader.parent.removeChild(_readyLevelDisplay.loader);
               _readyLevelDisplay = null;
            }
            _loc4_ = _gameState;
            _gameState = param1;
            switch(param1 - 1)
            {
               case 0:
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
                  break;
               case 4:
                  if(_totalPlayers == 1)
                  {
                     showLevelSelectPopup();
                     break;
                  }
                  if(_players[0]._localPlayer)
                  {
                     showFortPopup();
                     break;
                  }
                  showTerrainPopup();
                  break;
               case 5:
                  hideDlg();
                  createPhysicsWorld();
                  buildForts(true);
                  _loc5_ = _scene.getLayer("fort_ui").loader;
                  LocalizationManager.updateToFit(_loc5_.content.nameLTextCont.nameLText,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_perUserAvIDs[0]).avName);
                  if(_totalPlayers == 2)
                  {
                     LocalizationManager.updateToFit(_loc5_.content.nameRTextCont.nameRText,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_perUserAvIDs[1]).avName);
                     spawnPowerup();
                     setFruitHighlight(1);
                     applyMaterials(0);
                     applyMaterials(1);
                     _players[_activePlayerIndex]._hadFirstTurn = true;
                     _readyLevelDisplay = _scene.getLayer("cointoss");
                     _layerPopups.addChild(_readyLevelDisplay.loader);
                     if(_players[0]._localPlayer && _players[0]._hasTurn || _players[1]._localPlayer && _players[1]._hasTurn || _totalPlayers == 1)
                     {
                        _readyLevelDisplay.loader.content.setWin();
                     }
                     else
                     {
                        _loc3_ = !!_players[0]._localPlayer ? 1 : 0;
                        _readyLevelDisplay.loader.content.setLose(gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[_loc3_],_perUserAvIDs[_loc3_]).avName);
                     }
                     _players[_activePlayerIndex]._slingshot.loader.content.launcher.loadLauncher(1);
                     if(_players[_activePlayerIndex]._localPlayer)
                     {
                        _players[_activePlayerIndex]._slingshot.loader.content.tutorial(1);
                        _players[_activePlayerIndex]._firstShot = false;
                        if(_activePlayerIndex == 1)
                        {
                           _players[1]._slingshot.loader.content.howToPlay.scaleX *= -1;
                        }
                     }
                     break;
                  }
                  _activePlayerIndex = 0;
                  _players[_activePlayerIndex]._slingshot.loader.content.tutorial(1);
                  _players[_activePlayerIndex]._firstShot = false;
                  startNextLevel(false,false);
                  break;
               case 6:
                  _readyLevelDisplay = _scene.getLayer("cointoss");
                  _guiLayer.addChild(_readyLevelDisplay.loader);
                  _readyLevelDisplay.loader.x = 0;
                  _readyLevelDisplay.loader.y = 0;
                  if(_queueGameOver)
                  {
                     _readyLevelDisplay.loader.content.setWin();
                     LocalizationManager.translateId(_readyLevelDisplay.loader.content.whoseTurn.turn,11572);
                     break;
                  }
                  if(_players[0]._localPlayer && _players[0]._hasTurn || _players[1]._localPlayer && _players[1]._hasTurn || _totalPlayers == 1)
                  {
                     _readyLevelDisplay.loader.content.setWin();
                     break;
                  }
                  _loc3_ = !!_players[0]._localPlayer ? 1 : 0;
                  _readyLevelDisplay.loader.content.setLose(gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[_loc3_],_perUserAvIDs[_loc3_]).avName);
                  break;
               case 8:
                  _loc6_ = showDlg("FS_title",[{
                     "name":"startBtn",
                     "f":onStart
                  },{
                     "name":"exit_btn",
                     "f":onExit_Yes
                  }]);
                  _loc6_.x = 450;
                  _loc6_.y = 275;
                  stage.addEventListener("keyDown",titleKeyDown);
                  break;
               case 9:
                  if(_totalPlayers == 1)
                  {
                     if(_players)
                     {
                        _queueGameOver = false;
                        if(_players[0]._numPhantoms <= 0)
                        {
                           if(_fort % 10 == 0)
                           {
                              showNGFact();
                              break;
                           }
                           showGreatJobDlg();
                           break;
                        }
                        showGameOverDlg();
                        break;
                     }
                     _queueGameOver = false;
                     setGameState(_loc4_);
                     break;
                  }
                  _queueGameOver = false;
                  if(_tie)
                  {
                     showNGFactTie();
                     break;
                  }
                  if(_players && !_playerDropped && (_players[0]._localPlayer && _players[1]._numPhantoms <= 0 || _players[1]._localPlayer && _players[0]._numPhantoms <= 0))
                  {
                     showNGFactLose();
                     break;
                  }
                  if(!_sceneLoaded)
                  {
                     _totalPlayers = 1;
                     _queueGameOver = false;
                     _gameState = _loc4_;
                     break;
                  }
                  showNGFactWin();
                  break;
            }
         }
      }
      
      private function updateUI() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Object = _scene.getLayer("fort_ui").loader;
         _loc1_.content.fruit1.visible = true;
         _loc1_.content.counter1Cont.counter1.visible = true;
         _loc2_ = 2;
         while(_loc2_ <= 5)
         {
            _loc1_.content["fruit" + _loc2_].visible = false;
            _loc1_.content["counter" + _loc2_ + "Cont"]["counter" + _loc2_].visible = false;
            _loc2_++;
         }
         if(_levelsUnlocked > 10)
         {
            _loc1_.content.fruit2.visible = true;
            _loc1_.content.counter3Cont.counter3.visible = true;
         }
         if(_levelsUnlocked > 20)
         {
            _loc1_.content.fruit3.visible = true;
            _loc1_.content.counter2Cont.counter2.visible = true;
         }
         if(_levelsUnlocked > 30)
         {
            _loc1_.content.fruit4.visible = true;
            _loc1_.content.counter4Cont.counter4.visible = true;
         }
         if(_levelsUnlocked > 40)
         {
            _loc1_.content.fruit5.visible = true;
            _loc1_.content.counter5Cont.counter5.visible = true;
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc7_:* = null;
         var _loc6_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Object = null;
         if(param1[0] == "ml")
         {
            if(_gameState != 10)
            {
               _playerDropped = true;
            }
            if(_players == null)
            {
               _totalPlayers = 2;
            }
            setGameState(10);
         }
         else if(param1[0] == "ms")
         {
            _perUserAvIDs = [];
            _userNames = [];
            _loc4_ = 1;
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _perUserAvIDs[_loc3_] = param1[_loc4_++];
               _userNames[_loc3_] = param1[_loc4_++];
               _loc3_++;
            }
            _totalPlayers = _pIDs.length;
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "start")
            {
               if(_totalPlayers == 2)
               {
                  _loc2_ = _scene.getLayer("fort_ui").loader;
                  _guiLayer.addChild(_loc2_ as DisplayObject);
                  _guiLayer.addChild(_scene.getLayer("magnify").loader);
                  _scene.getLayer("magnify").loader.content.levelText.text = "";
               }
               hideDlg();
               setupPlayers(param1);
               _timeOut = 10;
            }
            else if(param1[2] == "setType")
            {
               !!_players[0]._localPlayer ? _players[1].setProjectileType(param1[3]) : _players[0].setProjectileType(param1[3]);
            }
            else if(param1[2] == "chooseFort")
            {
               _fort = int(param1[3]);
               _players[int(param1[4])]._hasTurn = true;
               _activePlayerIndex = int(param1[4]);
               if(_terrain >= 0)
               {
                  setGameState(6);
               }
            }
            else if(param1[2] == "chooseTer")
            {
               _terrain = int(param1[3]);
               _players[int(param1[4])]._hasTurn = true;
               _activePlayerIndex = int(param1[4]);
               if(_fort >= 0)
               {
                  setGameState(6);
               }
            }
            else if(param1[2] == "pos")
            {
               _loc6_ = uint(int(param1[3]));
               _loc5_ = 4;
               for each(_loc7_ in _players)
               {
                  if(_loc7_._netID == _loc6_)
                  {
                     _loc5_ = _loc7_.receivePositionData(param1,_loc5_);
                     break;
                  }
               }
            }
            else if(param1[2] == "shoot")
            {
               _loc5_ = 3;
               _loc5_ = int(!!_players[0]._localPlayer ? _players[1].receiveShootData(param1,_loc5_) : _players[0].receiveShootData(param1,_loc5_));
            }
            else if(param1[2] == "endTurn")
            {
               _queueNextTurn = true;
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:b2Body = null;
         var _loc4_:Boolean = false;
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
            if(_gameState == 5)
            {
               if(_totalPlayers == 2)
               {
                  _timeOut -= _frameTime;
                  if(_timeOut <= 0)
                  {
                     _timeOut = 0;
                  }
                  if(_fortPopup)
                  {
                     _fortPopup.showTime(Math.floor(_timeOut));
                  }
                  else
                  {
                     _terrainPopup.showTime(Math.floor(_timeOut));
                  }
               }
            }
            if(!_pauseGame || _players && _players.length > 1)
            {
               if(_gameState == 2)
               {
                  _readyLevelDisplayTimer -= _frameTime;
                  if(_readyLevelDisplayTimer <= 0)
                  {
                     setGameState(4);
                  }
               }
               else if(_gameState == 3)
               {
                  _readyLevelDisplayTimer -= _frameTime;
                  if(_readyLevelDisplayTimer <= 0)
                  {
                     setGameState(4);
                  }
               }
               else if(_gameState == 6)
               {
                  if(_totalPlayers == 1 || _readyLevelDisplay && _readyLevelDisplay.loader.content.finished)
                  {
                     setGameState(4);
                     _loc2_ = _world.m_bodyList;
                     while(_loc2_)
                     {
                        _loc2_.PutToSleep();
                        _loc2_ = _loc2_.m_next;
                     }
                  }
               }
               else if(_gameState == 7)
               {
                  if(_totalPlayers == 1 || _readyLevelDisplay && _readyLevelDisplay.loader.content.finished)
                  {
                     setGameState(4);
                  }
               }
               else if(_gameState == 8)
               {
                  if(_queueNextTurn)
                  {
                     _queueNextTurn = false;
                     endTurnPart2();
                  }
               }
               else if(_gameState == 10)
               {
                  if(_readyLevelDisplayTimer > 0 && _totalPlayers == 1)
                  {
                     _readyLevelDisplayTimer -= _frameTime;
                     if(_readyLevelDisplayTimer <= 0)
                     {
                        _players[0]._fort.loader.content.setFort(_fort + 25);
                        _scene.getLayer("forts2").loader.content.setFort(_fort + 25);
                        applyMaterials(0);
                        setGameState(4);
                     }
                  }
               }
               else if(_gameState == 4)
               {
                  _gameTime += _frameTime;
                  if(!_inputEnabled)
                  {
                     enableInput();
                  }
                  if(!_players[_activePlayerIndex]._doHeartbeat || _totalPlayers == 1)
                  {
                     stepPhysics();
                     checkEndTurn();
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _scorePopupPool.length)
                  {
                     if(_scorePopupPool[_loc3_].parent && _scorePopupPool[_loc3_].finished)
                     {
                        _scorePopupPool[_loc3_].parent.removeChild(_scorePopupPool[_loc3_]);
                     }
                     _loc3_++;
                  }
                  if(DESIGN_MODE)
                  {
                     checkSliderValues();
                  }
               }
               heartbeatPlayers();
               if(_zoomTransitionTime > 0)
               {
                  _zoomTransitionTime -= _frameTime;
                  if(_zoomTransitionTime < 0)
                  {
                     _zoomTransitionTime = 0;
                  }
                  if(_zoomed)
                  {
                     _layerPlayers.scaleX = _layerPlayers.scaleY = _layerBackground.scaleX = _layerBackground.scaleY = _layerPopups.scaleX = _layerPopups.scaleY = (Math.cos(3.141592653589793 * _zoomTransitionTime / 1) + 3) / 4;
                  }
                  else
                  {
                     _layerPlayers.scaleX = _layerPlayers.scaleY = _layerBackground.scaleX = _layerBackground.scaleY = _layerPopups.scaleX = _layerPopups.scaleY = (Math.cos(3.141592653589793 * (_zoomTransitionTime - 1) / 1) + 3) / 4;
                  }
                  setZoomView(_layerPlayers.scaleX);
               }
               else if(_zoomed && (!_players[_activePlayerIndex]._doHeartbeat || _forcePanLeft))
               {
                  if(_activePlayerIndex == 0 && !_forcePanLeft)
                  {
                     _layerBackground.x = _layerPlayers.x = _layerPopups.x = 450 * (Math.cos(Math.min(_players[_activePlayerIndex]._steps * _timeStep * 3,3.141592653589793)) - 1);
                  }
                  else
                  {
                     _layerBackground.x = _layerPlayers.x = _layerPopups.x = -450 * (Math.cos(Math.min(_players[_activePlayerIndex]._steps * _timeStep * 3,3.141592653589793)) + 1);
                  }
                  _layerBackground.y = _layerPlayers.y = _layerPopups.y = -getLevelYPivot() * _layerBackground.x / 900;
               }
               _loc3_ = 0;
               while(_loc3_ < _hideList.length)
               {
                  if(_hideList[_loc3_] is (getDefinitionByName("Relic") as Class))
                  {
                     _loc4_ = Boolean(_hideList[_loc3_].shape.relic.finished);
                  }
                  else
                  {
                     _loc4_ = Boolean(_hideList[_loc3_].finished);
                  }
                  if(_loc4_)
                  {
                     _hideList[_loc3_].visible = false;
                     _hideList.splice(_loc3_,1);
                     _loc3_--;
                  }
                  _loc3_++;
               }
               if(_queueFortReset)
               {
                  resetForts();
                  _queueFortReset = false;
               }
               if(_queueCluster)
               {
                  if(_players[_activePlayerIndex]._localPlayer || _players[_activePlayerIndex]._steps == _clusterSteps)
                  {
                     _queueCluster = false;
                     createCluster(_players[_activePlayerIndex]);
                  }
               }
            }
         }
      }
      
      private function stepPhysics() : void
      {
         var _loc1_:b2Body = null;
         var _loc7_:int = 0;
         var _loc2_:FortSmasherCustomContactPoint = null;
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc5_:int = 0;
         var _loc12_:Object = null;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc11_:DisplayObject = null;
         _loc7_ = 0;
         while(_loc7_ < 2)
         {
            _players[_activePlayerIndex]._steps++;
            _world.Step(_timeStep,_iterations);
            while(_contactListener.contactStack.length)
            {
               _loc2_ = _contactListener.contactStack.pop();
               if(_loc2_.shape1.GetBody() != null && _loc2_.shape2.GetBody() != null)
               {
                  _loc3_ = _loc2_.shape1.GetBody().GetUserData();
                  _loc4_ = _loc2_.shape2.GetBody().GetUserData();
                  if(_loc3_ == null && _loc2_.shape1.m_isSensor || _loc4_ == null && _loc2_.shape2.m_isSensor)
                  {
                     if(_scene.getLayer("powerups").loader.parent)
                     {
                        _loc5_ = _scene.getLayer("powerups").loader.content.fruit.currentFrame - 2;
                        _soundMan.playByName(_soundNamePowerup);
                        _world.DestroyBody(_loc3_ == null ? _loc2_.shape1.GetBody() : _loc2_.shape2.GetBody());
                        _scene.getLayer("powerups").loader.parent.removeChild(_scene.getLayer("powerups").loader);
                        if(_players[_activePlayerIndex]._localPlayer && _ammo[_loc5_] == 0)
                        {
                           _ammo[_loc5_] = 1;
                           _scene.getLayer("fort_ui").loader.content["fruit" + (_loc5_ + 1)].gotoAndStop("off");
                        }
                     }
                  }
                  else if(!_buildMode || _doDestruction)
                  {
                     doDamage(_loc3_,_loc4_,_loc2_.normalImpulse,_loc2_.shape1.GetBody(),_loc2_.position,_loc2_.shape2.GetBody());
                     doDamage(_loc4_,_loc3_,_loc2_.normalImpulse,_loc2_.shape2.GetBody(),_loc2_.position,_loc2_.shape1.GetBody());
                  }
               }
            }
            for each(_loc1_ in _deleteList)
            {
               _world.DestroyBody(_loc1_);
               _hideList.push(_loc1_.m_userData);
            }
            _deleteList.splice(0,_deleteList.length);
            _contactListener.reset();
            _loc7_++;
         }
         _loc1_ = _world.m_bodyList;
         while(_loc1_)
         {
            if(_loc1_.m_userData is Object)
            {
               _loc12_ = _loc1_.m_userData;
               if(_loc12_ == _currentDragger)
               {
                  _loc1_.SetXForm(new b2Vec2((_loc12_.x + _loc12_.parent.parent.x) * _phyScale,(_loc12_.y + _loc12_.parent.parent.y) * _phyScale),_loc1_.GetAngle());
               }
               else
               {
                  if(_loc12_.hasOwnProperty("loader"))
                  {
                     _loc12_ = _loc12_.loader;
                  }
                  _loc6_ = _loc1_.GetPosition().x / _phyScale;
                  _loc8_ = _loc1_.GetPosition().y / _phyScale;
                  if(!_loc1_.m_userData.hasOwnProperty("loader"))
                  {
                     _loc12_.x = _loc6_ - _loc12_.parent.parent.x;
                     _loc12_.y = _loc8_ - _loc12_.parent.parent.y;
                     _loc12_.rotation = _loc1_.GetAngle() * 180 / 3.141592653589793;
                  }
                  else if(_loc1_.m_userData.hasOwnProperty("type"))
                  {
                     _loc12_.x = _loc6_;
                     _loc12_.y = _loc8_;
                     if(_loc12_.content)
                     {
                        _loc12_.content.pX = _loc6_;
                        _loc12_.content.pY = _loc8_;
                        if(_players[_activePlayerIndex]._projectileType != 3)
                        {
                           _loc12_.content.pRotation = _loc1_.GetAngle() * 180 / 3.141592653589793;
                        }
                     }
                     if(_players[_activePlayerIndex]._localPlayer && _players[_activePlayerIndex]._makeTrail && _players[_activePlayerIndex].isCurrentBody(_loc1_))
                     {
                        _players[_activePlayerIndex]._trailFrames--;
                        if(_players[_activePlayerIndex]._trailFrames <= 0)
                        {
                           _loc11_ = getTrailDot() as DisplayObject;
                           _players[_activePlayerIndex]._trailFrames = 1;
                           _players[_activePlayerIndex]._trail.push(_loc11_);
                           _layerBackground.addChild(_loc11_);
                           _loc11_.x = _loc6_;
                           _loc11_.y = _loc8_;
                        }
                     }
                  }
               }
            }
            _loc1_ = _loc1_.m_next;
         }
      }
      
      private function checkEndTurn() : void
      {
         var _loc9_:b2Body = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc3_:b2Vec2 = null;
         var _loc2_:Boolean = false;
         var _loc1_:* = null;
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         _loc1_ = _world.m_bodyList;
         while(_loc1_)
         {
            _loc9_ = _loc1_.m_next;
            if(!_loc1_.IsSleeping() && _loc1_.m_userData)
            {
               _loc3_ = _loc1_.GetPosition();
               _loc7_ = _loc1_.GetPosition().x / _phyScale;
               _loc8_ = _loc1_.GetPosition().y / _phyScale;
               _loc2_ = Boolean(_players[_activePlayerIndex].isPlayerBody(_loc1_));
               if(outOfBounds(_loc7_,_loc8_,_loc2_))
               {
                  if(_loc2_)
                  {
                     if(_loc1_.m_userData.type == 1 && _allowClusterClick)
                     {
                        _allowClusterClick = false;
                        if(_players[_activePlayerIndex]._localPlayer)
                        {
                           sendClusterMessage(-1);
                        }
                     }
                     _players[_activePlayerIndex].destroyBody(_loc1_);
                     _players[_activePlayerIndex]._makeTrail = false;
                  }
                  else
                  {
                     if(_loc1_.GetUserData() && _loc1_.GetUserData() is Class(getDefinitionByName("Relic")))
                     {
                        _players[_activePlayerIndex]._numPhantoms--;
                        if(_players[_activePlayerIndex]._localPlayer)
                        {
                           AchievementXtCommManager.requestSetUserVar(160,1);
                           _displayAchievementTimer = 1;
                        }
                        if(_players[_activePlayerIndex]._numPhantoms <= 0)
                        {
                           if(_queueGameOver && _totalPlayers == 2)
                           {
                              _tie = true;
                           }
                           _queueGameOver = true;
                        }
                        _loc1_.GetUserData().doDamage(3);
                        _soundMan.playByName(_soundNamePhantomDeathSpiral);
                     }
                     else
                     {
                        _loc1_.GetUserData().gotoAndPlay("destroy");
                        _loc6_ = int(_loc1_.GetUserData().materialType);
                        if(_loc6_ > 0)
                        {
                           _soundMan.playByName(_materialSounds[_loc6_][2][Math.floor(_randomizer.random() * _materialSounds[_loc6_][2].length)]);
                        }
                     }
                     _world.DestroyBody(_loc1_);
                     _hideList.push(_loc1_.m_userData);
                     if(_players[_activePlayerIndex]._localPlayer)
                     {
                        showScorePopup(Math.floor(_loc1_.GetMass() * 500),_loc7_,_loc8_);
                        _players[_activePlayerIndex]._score += Math.floor(_loc1_.GetMass() * 500);
                        _scene.getLayer("fort_ui").loader.content.scoreTxtCont.scoreText.text = _players[_activePlayerIndex]._score.toString();
                     }
                  }
                  _loc4_ = true;
               }
               else if(!_loc4_ && (_loc1_.m_linearVelocity.LengthSquared() > 1 || Math.abs(_loc1_.m_angularVelocity) > 0.1))
               {
                  if(_totalPlayers == 2)
                  {
                     _endTurnTimer = 1;
                     if(_players[_activePlayerIndex]._steps < 1200)
                     {
                        _loc4_ = true;
                     }
                  }
                  else
                  {
                     _loc4_ = true;
                  }
               }
            }
            _loc1_ = _loc9_;
         }
         if(_totalPlayers == 2)
         {
            if(_players[_activePlayerIndex]._steps < 1200)
            {
               if(_loc4_)
               {
                  _endTurnTimer = 1;
                  return;
               }
               if(_players[_activePlayerIndex]._bodies.length)
               {
                  if(_endTurnTimer <= 0)
                  {
                     _endTurnTimer = 1;
                     return;
                  }
                  _endTurnTimer -= _timeStep * 2;
                  if(_endTurnTimer <= 0)
                  {
                     _players[_activePlayerIndex].destroyBody();
                     _endTurnTimer = 1;
                     return;
                  }
               }
               else
               {
                  _endTurnTimer -= _timeStep * 2;
                  if(_endTurnTimer <= 0)
                  {
                     endTurn();
                  }
               }
            }
            else
            {
               _players[_activePlayerIndex].destroyBody();
               endTurn();
            }
         }
         else
         {
            _players[0].destroySleepingBodies();
            if(_endTurnTimer > 0)
            {
               _endTurnTimer -= _timeStep * 2;
               if(_endTurnTimer <= 0)
               {
                  if(!_players[0]._doHeartbeat)
                  {
                     if(!_players[0]._makeTrail)
                     {
                        endTurnPart2();
                     }
                     else
                     {
                        _endTurnTimer = 0.001;
                     }
                  }
                  else if(_players[0]._numPhantoms <= 0)
                  {
                     endTurnPart2();
                  }
                  else if(!_loc4_)
                  {
                     _loc1_ = _world.m_bodyList;
                     while(_loc1_)
                     {
                        _loc1_.PutToSleep();
                        _loc1_ = _loc1_.m_next;
                     }
                     if(_zoomed && _players[0]._steps > 0)
                     {
                        if(!_forcePanLeft && _layerBackground.x < -890)
                        {
                           _forcePanLeft = true;
                           _players[0]._steps = 0;
                        }
                     }
                     if(_outOfAmmo)
                     {
                        endTurnPart2();
                     }
                  }
               }
            }
            else if(!_loc4_ && _players[0]._bodies.length == 0)
            {
               _endTurnTimer = 1;
            }
         }
      }
      
      private function outOfBounds(param1:Number, param2:Number, param3:Boolean) : Boolean
      {
         if(param1 < -150 || param1 > 1950 || param2 > 700)
         {
            return true;
         }
         if(!param3)
         {
            return _activePlayerIndex == 0 && param1 < 600 || _activePlayerIndex == 1 && param1 > 1200;
         }
         return false;
      }
      
      private function endTurn() : void
      {
         var _loc1_:b2Body = null;
         var _loc2_:Array = null;
         _loc1_ = _world.m_bodyList;
         while(_loc1_)
         {
            _loc1_.PutToSleep();
            _loc1_ = _loc1_.m_next;
         }
         if(_totalPlayers == 2)
         {
            _loc2_ = [];
            _loc2_[0] = "endTurn";
            MinigameManager.msg(_loc2_);
            setGameState(8);
         }
         else
         {
            endTurnPart2();
         }
      }
      
      private function endTurnPart2() : void
      {
         var _loc1_:int = 0;
         if(_totalPlayers == 2)
         {
            _players[_activePlayerIndex]._doHeartbeat = false;
            _players[_activePlayerIndex]._hasTurn = false;
            _players[_activePlayerIndex]._slingshot.loader.content.launcher.loadLauncher(0);
            _players[int(!_activePlayerIndex)]._doHeartbeat = true;
            _players[int(!_activePlayerIndex)]._hasTurn = true;
            _activePlayerIndex = int(!_activePlayerIndex);
            _soundMan.playByName(_soundNameStingerYourTurn);
            if(_scene.getLayer("powerups").loader.parent == null)
            {
               spawnPowerup();
            }
            _players[_activePlayerIndex].setProjectileType(0);
            setFruitHighlight(1);
         }
         else
         {
            if(_outOfAmmo)
            {
               _queueGameOver = true;
            }
            if(_ammo[_players[0]._projectileType] > 0)
            {
               _players[0].setProjectileType(_players[0]._projectileType,true);
               setFruitHighlight(_players[0]._projectileType + 1);
            }
            else
            {
               _loc1_ = 0;
               while(_loc1_ < 5)
               {
                  if(_ammo[_loc1_] > 0)
                  {
                     _players[0].setProjectileType(_loc1_,true);
                     setFruitHighlight(_loc1_ + 1);
                     break;
                  }
                  _loc1_++;
               }
            }
            if(_loc1_ == 5)
            {
               _outOfAmmo = true;
            }
         }
         if(_players[_activePlayerIndex]._localPlayer && _players[_activePlayerIndex]._firstShot)
         {
            _players[_activePlayerIndex]._slingshot.loader.content.tutorial(1);
            _players[_activePlayerIndex]._firstShot = false;
            if(_activePlayerIndex == 1)
            {
               _players[1]._slingshot.loader.content.howToPlay.scaleX *= -1;
            }
         }
         if(_queueGameOver)
         {
            if(_totalPlayers == 1)
            {
               setGameState(10);
            }
            else if(_players[_activePlayerIndex]._hadFirstTurn)
            {
               setGameState(10);
            }
            else
            {
               setGameState(7);
            }
         }
         else if(_totalPlayers == 2)
         {
            setGameState(7);
         }
         else
         {
            if(!_outOfAmmo)
            {
               _players[0]._doHeartbeat = true;
               _players[0]._hasTurn = true;
               _players[0]._slingshot.loader.content.previewOn();
            }
            setGameState(4);
         }
      }
      
      private function checkSliderValues() : void
      {
         if(_clusterSliders[0] && _clusterSliders[0].loader.content && _clusterSliders[0].loader.content.valueChanged)
         {
            _clusterParams[0] = _clusterSliders[0].loader.content.sliderValue / 100;
            _clusterSliders[0].loader.content.valueChanged = false;
         }
         if(_clusterSliders[1] && _clusterSliders[1].loader.content && _clusterSliders[1].loader.content.valueChanged)
         {
            _clusterParams[1] = _clusterSliders[1].loader.content.sliderValue;
            _clusterSliders[1].loader.content.valueChanged = false;
         }
         if(_debugSliderGravity && _debugSliderGravity.loader.content && _debugSliderGravity.loader.content.valueChanged)
         {
            _gravity = _debugSliderGravity.loader.content.sliderValue;
            _world.SetGravity(new b2Vec2(0,_gravity));
            _debugSliderGravity.loader.content.valueChanged = false;
         }
         if(_debugSliderLaunchForce && _debugSliderLaunchForce.loader.content && _debugSliderLaunchForce.loader.content.valueChanged)
         {
            _launchForce = _debugSliderLaunchForce.loader.content.sliderValue;
            _debugSliderLaunchForce.loader.content.valueChanged = false;
         }
         if(_debugSliderDamageThreshold && _debugSliderDamageThreshold.loader.content && _debugSliderDamageThreshold.loader.content.valueChanged)
         {
            _damageThreshold = _debugSliderDamageThreshold.loader.content.sliderValue;
            _debugSliderDamageThreshold.loader.content.valueChanged = false;
         }
         if(_debugSliderDensity && _debugSliderDensity.loader.content && _debugSliderDensity.loader.content.valueChanged)
         {
            if(_currentDebugMaterial >= 0)
            {
               _materials[_currentDebugMaterial].density = _debugSliderDensity.loader.content.sliderValue / 100;
            }
            else
            {
               _projectiles[_currentDebugProjectileType].density = _debugSliderDensity.loader.content.sliderValue / 100;
            }
            _debugSliderDensity.loader.content.valueChanged = false;
         }
         if(_debugSliderFriction && _debugSliderFriction.loader.content && _debugSliderFriction.loader.content.valueChanged)
         {
            if(_currentDebugMaterial >= 0)
            {
               _materials[_currentDebugMaterial].friction = _debugSliderFriction.loader.content.sliderValue / 100;
            }
            else
            {
               _projectiles[_currentDebugProjectileType].friction = _debugSliderFriction.loader.content.sliderValue / 100;
            }
            _debugSliderFriction.loader.content.valueChanged = false;
         }
         if(_debugSliderBounce && _debugSliderBounce.loader.content && _debugSliderBounce.loader.content.valueChanged)
         {
            if(_currentDebugMaterial >= 0)
            {
               _materials[_currentDebugMaterial].bounce = _debugSliderBounce.loader.content.sliderValue / 100;
            }
            else
            {
               _projectiles[_currentDebugProjectileType].bounce = _debugSliderBounce.loader.content.sliderValue / 100;
            }
            _debugSliderBounce.loader.content.valueChanged = false;
         }
         if(_debugSliderStrength && _debugSliderStrength.loader.content && _debugSliderStrength.loader.content.valueChanged)
         {
            if(_currentDebugMaterial >= 0)
            {
               _materials[_currentDebugMaterial].strength = _debugSliderStrength.loader.content.sliderValue / 100;
            }
            else
            {
               _projectiles[_currentDebugProjectileType].strength = _debugSliderStrength.loader.content.sliderValue / 100;
            }
            _debugSliderStrength.loader.content.valueChanged = false;
         }
         if(_debugSliderDamage && _debugSliderDamage.loader.content && _debugSliderDamage.loader.content.valueChanged)
         {
            if(_currentDebugMaterial >= 0)
            {
               _materials[_currentDebugMaterial].damage = _debugSliderDamage.loader.content.sliderValue / 100;
            }
            else
            {
               _projectiles[_currentDebugProjectileType].damage = _debugSliderDamage.loader.content.sliderValue / 100;
            }
            _debugSliderDamage.loader.content.valueChanged = false;
         }
      }
      
      private function getScorePopup() : MovieClip
      {
         var _loc2_:int = 0;
         var _loc1_:MovieClip = null;
         _loc2_ = 0;
         while(_loc2_ < _scorePopupPool.length)
         {
            if(_scorePopupPool[_loc2_].finished)
            {
               return _scorePopupPool[_loc2_];
            }
            _loc2_++;
         }
         if(_scorePopupPool.length <= 5)
         {
            _loc1_ = GETDEFINITIONBYNAME("FS_comboPopup");
            _loc1_.cacheAsBitmap = true;
            _scorePopupPool.push(_loc1_);
            return _scorePopupPool[_scorePopupPool.length - 1];
         }
         return null;
      }
      
      private function getTrailDot() : Object
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _trailDotPool.length)
         {
            if(_trailDotPool[_loc1_].parent == null)
            {
               return _trailDotPool[_loc1_];
            }
            _loc1_++;
         }
         return _scene.cloneAsset("trail").loader;
      }
      
      private function doDamage(param1:*, param2:*, param3:Number, param4:b2Body, param5:b2Vec2, param6:b2Body) : void
      {
         var _loc8_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:int = 0;
         var _loc11_:Boolean = false;
         var _loc10_:int = 0;
         var _loc7_:Number = NaN;
         var _loc14_:b2Vec2 = null;
         if(param1 != null)
         {
            if(param1.hasOwnProperty("hitpoints"))
            {
               _loc8_ = 1;
               _loc12_ = 1;
               _loc13_ = Number(param1.hitpoints);
               _loc11_ = false;
               if(param1.hasOwnProperty("materialType"))
               {
                  if(_materialOverride > 0 && param1.materialType != 5)
                  {
                     _loc9_ = _materialOverride;
                  }
                  else
                  {
                     _loc9_ = int(param1.materialType);
                  }
                  _loc8_ = Number(_materials[_loc9_].strength);
               }
               else
               {
                  if(_allowClusterClick)
                  {
                     _allowClusterClick = false;
                     if(_players[_activePlayerIndex]._localPlayer)
                     {
                        sendClusterMessage(-1);
                     }
                  }
                  if(param1.hasOwnProperty("sound"))
                  {
                     param1.sound.stop();
                  }
                  _players[_activePlayerIndex]._makeTrail = false;
                  _loc8_ = _projectiles[param1.type].strength * 1000;
                  if(param3 > 10)
                  {
                     if(param1.type != 3)
                     {
                        param1.loader.content.pBounce(true);
                     }
                  }
                  _soundMan.playByName(_materialSounds[6][0][Math.floor(_randomizer.random() * _materialSounds[6][0].length)]);
               }
               if(param2)
               {
                  if(param2.hasOwnProperty("materialType"))
                  {
                     if(_materialOverride > 0 && param2.materialType != 5)
                     {
                        _loc10_ = _materialOverride;
                     }
                     else
                     {
                        _loc10_ = int(param2.materialType);
                     }
                     _loc12_ = _materials[_loc10_].damage * 20;
                  }
                  else
                  {
                     if(param2.type == 4)
                     {
                        if(param3 < 10)
                        {
                           _loc12_ = 0;
                        }
                        else
                        {
                           _loc12_ = _projectiles[param2.type].damage * 20000;
                           param6.m_linearVelocity.x = param2.linVelX;
                           param6.m_linearVelocity.y = param2.linVelY;
                           param6.m_angularVelocity = param2.angVel;
                        }
                     }
                     else
                     {
                        _loc12_ = _projectiles[param2.type].damage * 20;
                     }
                     if(param2.type == 3)
                     {
                        _loc14_ = new b2Vec2();
                        _loc14_.x = param6.GetPosition().x - param4.GetPosition().x;
                        _loc14_.y = param6.GetPosition().y - param4.GetPosition().y;
                        _loc14_.Normalize();
                        if(_activePlayerIndex == 0)
                        {
                           _loc7_ = -_loc14_.y;
                           _loc14_.y = _loc14_.x;
                           _loc14_.x = _loc7_;
                        }
                        else
                        {
                           _loc7_ = _loc14_.y;
                           _loc14_.y = -_loc14_.x;
                           _loc14_.x = _loc7_;
                        }
                        _loc14_.Multiply(1000);
                        param4.ApplyForce(_loc14_,param5);
                     }
                  }
               }
               else
               {
                  _loc12_ *= 2;
               }
               param1.hitpoints -= param3 / _loc8_ * _loc12_;
               if(_loc13_ - param1.hitpoints < _damageThreshold * 0.02)
               {
                  param1.hitpoints = _loc13_;
               }
               else
               {
                  if(param1.hitpoints <= 0 && _players[_activePlayerIndex]._localPlayer && param1.hasOwnProperty("materialType") && _deleteList.indexOf(param4))
                  {
                     showScorePopup(Math.floor(param4.GetMass() * 500),param1.x + param1.parent.parent.x,param1.y + param1.parent.parent.y);
                     _players[_activePlayerIndex]._score += Math.floor(param4.GetMass() * 500);
                     _scene.getLayer("fort_ui").loader.content.scoreTxtCont.scoreText.text = _players[_activePlayerIndex]._score.toString();
                  }
                  if(param1 is Class(getDefinitionByName("Relic")))
                  {
                     if(param1.hitpoints <= 0)
                     {
                        if(_deleteList.indexOf(param4) == -1)
                        {
                           _players[_activePlayerIndex]._numPhantoms--;
                           param1.doDamage(3);
                           _soundMan.playByName(_soundNamePhantomDeathSpiral);
                           _deleteList.push(param4);
                           if(_players[_activePlayerIndex]._numPhantoms <= 0)
                           {
                              if(_queueGameOver && _totalPlayers == 2)
                              {
                                 _tie = true;
                              }
                              _queueGameOver = true;
                           }
                           if(_players[_activePlayerIndex]._localPlayer)
                           {
                              AchievementXtCommManager.requestSetUserVar(160,1);
                              _displayAchievementTimer = 1;
                           }
                        }
                     }
                     else if(param1.hitpoints <= 33 && _loc13_ > 33)
                     {
                        param1.doDamage(2);
                        _loc11_ = true;
                     }
                     else if(param1.hitpoints <= 66 && _loc13_ > 66)
                     {
                        param1.doDamage(1);
                        _loc11_ = true;
                     }
                     if(_loc11_)
                     {
                        _soundMan.playByName(_materialSounds[5][1][Math.floor(_randomizer.random() * _materialSounds[5][1].length)]);
                     }
                  }
                  else if(param1.hitpoints <= 0)
                  {
                     if(!param1.hasOwnProperty("loader"))
                     {
                        param1.gotoAndPlay("destroy");
                        if(_loc9_ > 0)
                        {
                           _soundMan.playByName(_materialSounds[_loc9_][2][Math.floor(_randomizer.random() * _materialSounds[_loc9_][2].length)]);
                        }
                        if(_deleteList.indexOf(param4) == -1)
                        {
                           _deleteList.push(param4);
                        }
                     }
                  }
                  else if(param1.hasOwnProperty("damage"))
                  {
                     if(param1.hitpoints <= 33 && _loc13_ > 33)
                     {
                        param1.damage.gotoAndStop(3);
                        _loc11_ = true;
                     }
                     else if(param1.hitpoints <= 66 && _loc13_ > 66)
                     {
                        param1.damage.gotoAndStop(2);
                        _loc11_ = true;
                     }
                     if(_loc11_ && _loc9_ > 0)
                     {
                        _soundMan.playByName(_materialSounds[_loc9_][1][Math.floor(_randomizer.random() * _materialSounds[_loc9_][1].length)]);
                     }
                  }
               }
            }
         }
      }
      
      private function showScorePopup(param1:int, param2:Number, param3:Number) : void
      {
         var _loc4_:MovieClip = null;
         if(!outOfBounds(param2,param3,true))
         {
            _loc4_ = getScorePopup();
            if(_loc4_)
            {
               if(_loc4_.parent == null)
               {
                  _layerBackground.addChild(_loc4_);
               }
               _loc4_.x = param2;
               _loc4_.y = param3;
               _loc4_.scaleY = 3;
               _loc4_.scaleX = 3;
               _loc4_.turnOn(String(param1));
            }
         }
      }
      
      private function updateSliders() : void
      {
         onDebugSliderDensityLoaded(null);
         onDebugSliderFrictionLoaded(null);
         onDebugSliderBounceLoaded(null);
         onDebugSliderStrengthLoaded(null);
         onDebugSliderDamageLoaded(null);
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.keyCode == 32)
         {
            if(_debugSliderDensity && _debugSliderDensity.loader.parent)
            {
               _debugSliderDensity.loader.parent.removeChild(_debugSliderDensity.loader);
               _debugSliderFriction.loader.parent.removeChild(_debugSliderFriction.loader);
               _debugSliderBounce.loader.parent.removeChild(_debugSliderBounce.loader);
               _debugSliderStrength.loader.parent.removeChild(_debugSliderStrength.loader);
               _debugSliderDamage.loader.parent.removeChild(_debugSliderDamage.loader);
               _debugSliderGravity.loader.parent.removeChild(_debugSliderGravity.loader);
               _debugSliderLaunchForce.loader.parent.removeChild(_debugSliderLaunchForce.loader);
               _debugSliderDamageThreshold.loader.parent.removeChild(_debugSliderDamageThreshold.loader);
               _currentDebugMaterial = -1;
               _currentDebugProjectileType = -1;
               DESIGN_MODE = false;
            }
            else
            {
               _currentDebugMaterial = 0;
               if(!_debugSliderDensity)
               {
                  _debugSliderDensity = _scene.cloneAsset("debugSlider");
                  _debugSliderDensity.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderDensityLoaded);
                  _debugSliderFriction = _scene.cloneAsset("debugSlider");
                  _debugSliderFriction.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderFrictionLoaded);
                  _debugSliderBounce = _scene.cloneAsset("debugSlider");
                  _debugSliderBounce.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderBounceLoaded);
                  _debugSliderStrength = _scene.cloneAsset("debugSlider");
                  _debugSliderStrength.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderStrengthLoaded);
                  _debugSliderDamage = _scene.cloneAsset("debugSlider");
                  _debugSliderDamage.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderDamageLoaded);
                  _debugSliderGravity = _scene.cloneAsset("debugSlider");
                  _debugSliderGravity.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderGravityLoaded);
                  _debugSliderLaunchForce = _scene.cloneAsset("debugSlider");
                  _debugSliderLaunchForce.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderLaunchForceLoaded);
                  _debugSliderDamageThreshold = _scene.cloneAsset("debugSlider");
                  _debugSliderDamageThreshold.loader.contentLoaderInfo.addEventListener("complete",onDebugSliderDamageThresholdLoaded);
               }
               else
               {
                  updateSliders();
               }
               _guiLayer.addChild(_debugSliderDensity.loader);
               _guiLayer.addChild(_debugSliderFriction.loader);
               _guiLayer.addChild(_debugSliderBounce.loader);
               _guiLayer.addChild(_debugSliderStrength.loader);
               _guiLayer.addChild(_debugSliderDamage.loader);
               _guiLayer.addChild(_debugSliderGravity.loader);
               _guiLayer.addChild(_debugSliderLaunchForce.loader);
               _guiLayer.addChild(_debugSliderDamageThreshold.loader);
               _debugSliderDensity.loader.x = 110;
               _debugSliderDensity.loader.y = 10;
               _debugSliderFriction.loader.x = 110;
               _debugSliderFriction.loader.y = 50;
               _debugSliderBounce.loader.x = 110;
               _debugSliderBounce.loader.y = 90;
               _debugSliderStrength.loader.x = 110;
               _debugSliderStrength.loader.y = 130;
               _debugSliderDamage.loader.x = 110;
               _debugSliderDamage.loader.y = 170;
               _debugSliderGravity.loader.x = 110;
               _debugSliderGravity.loader.y = 250;
               _debugSliderLaunchForce.loader.x = 110;
               _debugSliderLaunchForce.loader.y = 290;
               _debugSliderDamageThreshold.loader.x = 110;
               _debugSliderDamageThreshold.loader.y = 330;
               DESIGN_MODE = true;
            }
         }
         else if(param1.keyCode == 67)
         {
            if(_clusterSliders[0] && _clusterSliders[0].loader.parent)
            {
               _loc2_ = 0;
               while(_loc2_ < _clusterSliders.length)
               {
                  _clusterSliders[_loc2_].loader.parent.removeChild(_clusterSliders[_loc2_].loader);
                  _loc2_++;
               }
               DESIGN_MODE = false;
            }
            else
            {
               if(!_clusterSliders[0])
               {
                  _clustersLoaded = 0;
                  _loc2_ = 0;
                  while(_loc2_ < _clusterParams.length)
                  {
                     _clusterSliders[_loc2_] = _scene.cloneAsset("debugSlider");
                     _clusterSliders[_loc2_].loader.contentLoaderInfo.addEventListener("complete",onDebugSliderClusterLoaded);
                     _guiLayer.addChild(_clusterSliders[_loc2_].loader);
                     _clusterSliders[_loc2_].loader.x = 110;
                     _clusterSliders[_loc2_].loader.y = 10 + 40 * _loc2_;
                     _loc2_++;
                  }
               }
               else
               {
                  _loc2_ = 0;
                  while(_loc2_ < _clusterParams.length)
                  {
                     _guiLayer.addChild(_clusterSliders[_loc2_].loader);
                     _loc2_++;
                  }
               }
               DESIGN_MODE = true;
            }
         }
         else if(param1.keyCode == 37)
         {
            if(DESIGN_MODE)
            {
               if(_currentDebugMaterial >= 0)
               {
                  _currentDebugMaterial--;
                  if(_currentDebugMaterial < 0)
                  {
                     _currentDebugMaterial = _materials.length - 1;
                  }
               }
               else
               {
                  _currentDebugProjectileType--;
                  if(_currentDebugProjectileType < 0)
                  {
                     _currentDebugProjectileType = _projectiles.length - 1;
                  }
               }
               updateSliders();
            }
         }
         else if(param1.keyCode == 39)
         {
            if(DESIGN_MODE)
            {
               if(_currentDebugMaterial >= 0)
               {
                  _currentDebugMaterial++;
                  if(_currentDebugMaterial >= _materials.length)
                  {
                     _currentDebugMaterial = 0;
                  }
               }
               else
               {
                  _currentDebugProjectileType++;
                  if(_currentDebugProjectileType >= _projectiles.length)
                  {
                     _currentDebugProjectileType = 0;
                  }
               }
               updateSliders();
            }
         }
         else if(param1.keyCode == 38 || param1.keyCode == 40)
         {
            if(DESIGN_MODE)
            {
               if(_currentDebugMaterial >= 0)
               {
                  _currentDebugMaterial = -1;
                  _currentDebugProjectileType = 0;
               }
               else
               {
                  _currentDebugMaterial = 0;
                  _currentDebugProjectileType = -1;
               }
               updateSliders();
            }
         }
         else if(param1.keyCode == 66)
         {
            _buildMode = !_buildMode;
         }
         else if(param1.keyCode == 68)
         {
            _doDestruction = !_doDestruction;
         }
         else if(param1.keyCode == 77)
         {
            _materialOverride = 1;
            _queueFortReset = true;
         }
         else if(param1.keyCode == 87)
         {
            _materialOverride = 2;
            _queueFortReset = true;
         }
         else if(param1.keyCode == 71)
         {
            _materialOverride = 3;
            _queueFortReset = true;
         }
         else if(param1.keyCode == 83)
         {
            _materialOverride = 4;
            _queueFortReset = true;
         }
         else if(param1.keyCode == 13)
         {
            _materialOverride = -1;
            _queueFortReset = true;
         }
         else if(param1.keyCode == 97)
         {
            _players[0].setProjectileType(0);
            if(_players[1])
            {
               _players[1].setProjectileType(0);
            }
         }
         else if(param1.keyCode == 98)
         {
            _players[0].setProjectileType(1);
            if(_players[1])
            {
               _players[1].setProjectileType(1);
            }
         }
         else if(param1.keyCode == 99)
         {
            _players[0].setProjectileType(2);
            if(_players[1])
            {
               _players[1].setProjectileType(2);
            }
         }
         else if(param1.keyCode == 100)
         {
            _players[0].setProjectileType(3);
            if(_players[1])
            {
               _players[1].setProjectileType(3);
            }
         }
         else if(param1.keyCode == 101)
         {
            _players[0].setProjectileType(4);
            if(_players[1])
            {
               _players[1].setProjectileType(4);
            }
         }
         else if(param1.keyCode == 102)
         {
            _players[0].setProjectileType(5);
            if(_players[1])
            {
               _players[1].setProjectileType(5);
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
      
      public function setupPlayers(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc7_:FortSmasherPlayer = null;
         _players = [];
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _readyLevelDisplayTimer = 0;
         _queueGameOver = false;
         _queueCluster = false;
         _queueNextTurn = false;
         var _loc4_:int = 3;
         if(_totalPlayers == 1)
         {
            _loc4_ = 0;
         }
         var _loc2_:uint = parseInt(param1[_loc4_++]);
         _randomizer = new RandomSeed(_loc2_);
         _levelIndex = -1;
         _players = [];
         _totalPlayers = parseInt(param1[_loc4_++]);
         _loc3_ = 0;
         while(_loc3_ < _totalPlayers)
         {
            _loc7_ = new FortSmasherPlayer(this);
            _loc4_ = _loc7_.init(_loc3_,param1,_loc4_,_loc2_);
            _players.push(_loc7_);
            _loc3_++;
         }
         if(_totalPlayers == 2)
         {
            AchievementXtCommManager.requestSetUserVar(143,1);
            _displayAchievementTimer = 1;
            setGameState(5);
         }
         else
         {
            setGameState(9);
         }
      }
      
      private function disableInput() : void
      {
         if(_inputEnabled)
         {
            stage.removeEventListener("mouseUp",mouseUpHandler);
            stage.removeEventListener("mouseDown",mouseDownHandler);
            _inputEnabled = false;
         }
      }
      
      private function enableInput() : void
      {
         if(!_inputEnabled)
         {
            stage.addEventListener("mouseUp",mouseUpHandler);
            stage.addEventListener("mouseDown",mouseDownHandler);
            _inputEnabled = true;
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(!_pauseGame && _gameState == 4 && _zoomTransitionTime <= 0 && !_buildMode)
         {
            if(_players[_activePlayerIndex]._localPlayer)
            {
               if(_players[_activePlayerIndex]._doHeartbeat)
               {
                  if(_players[_activePlayerIndex]._launcherLoaded && _players[_activePlayerIndex]._pullDistance > 0)
                  {
                     _players[_activePlayerIndex].shoot(_totalPlayers == 2);
                  }
               }
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:FortSmasherPlayer = null;
         if(!_pauseGame && _gameState == 4 && _zoomTransitionTime <= 0 && !_buildMode)
         {
            _loc2_ = _players[_activePlayerIndex];
            if(_loc2_._localPlayer)
            {
               if(_loc2_._doHeartbeat && _layerPlayers.mouseY < 448)
               {
                  if(!_loc2_._launcherLoaded)
                  {
                     _soundMan.playByName(_soundNameSlingshotStretch1);
                     _loc2_._launcherLoaded = true;
                     _loc2_._slingshot.loader.content.tutorial(0);
                     _loc2_._slingshot.loader.content.previewOn();
                  }
               }
               else if(_loc2_._hasTurn && _loc2_._projectileType == 1 && _allowClusterClick)
               {
                  _queueCluster = true;
                  _allowClusterClick = false;
               }
            }
         }
      }
      
      private function mouseWheelHandler(param1:MouseEvent) : void
      {
         _layerBackground.scaleX = _layerBackground.scaleY = _layerBackground.scaleX + 0.01 * param1.delta;
         if(_layerBackground.scaleX < 0.55)
         {
            _layerBackground.scaleX = _layerBackground.scaleY = 0.55;
         }
         else if(_layerBackground.scaleX > 1)
         {
            _layerBackground.scaleX = _layerBackground.scaleY = 1;
         }
         _layerPlayers.scaleX = _layerPlayers.scaleY = _layerBackground.scaleX;
         _layerBackground.y = _layerPlayers.y = 275 * (1 - _layerBackground.scaleX);
      }
      
      public function createCluster(param1:FortSmasherPlayer) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:int = 0;
         var _loc10_:Object = null;
         var _loc7_:Loader = null;
         var _loc8_:b2Body = null;
         var _loc4_:b2BodyDef = null;
         var _loc9_:b2CircleDef = null;
         var _loc2_:b2Vec2 = new b2Vec2();
         var _loc3_:b2Body = param1._bodies[param1._bodies.length - 1].body;
         _scene.getLayer("phantom1").loader.content.setType(6);
         _loc6_ = _scene.getLayer("phantom1").loader.content.projectile.projectile.collision.height * 0.5;
         _loc5_ = 0;
         while(_loc5_ < 3)
         {
            _loc10_ = getProjectileAsset(5);
            _loc10_.loader.visible = true;
            _loc10_.name = "ball";
            _loc10_.hitpoints = 100;
            _loc10_.type = 5;
            _loc7_ = _loc10_.loader;
            _loc9_ = new b2CircleDef();
            _loc4_ = new b2BodyDef();
            if(_loc5_ == 0)
            {
               _loc2_.x = -_loc3_.m_linearVelocity.y;
               _loc2_.y = _loc3_.m_linearVelocity.x;
               _loc2_.Normalize();
               _loc2_.Multiply(_loc10_.height / 2);
            }
            else if(_loc5_ == 1)
            {
               _loc2_.y = 0;
               _loc2_.x = 0;
            }
            else
            {
               _loc2_.x = _loc3_.m_linearVelocity.y;
               _loc2_.y = -_loc3_.m_linearVelocity.x;
               _loc2_.Normalize();
               _loc2_.Multiply(_loc10_.height / 2);
            }
            _loc4_.position.x = (_loc3_.m_userData.loader.x + _loc2_.x) * _phyScale;
            _loc4_.position.y = (_loc3_.m_userData.loader.y + _loc2_.y) * _phyScale;
            _loc4_.angularDamping = 0.5;
            if(_totalPlayers == 2)
            {
               _loc4_.angularDamping = 4;
            }
            _loc9_.radius = _loc6_ * _phyScale;
            _loc9_.density = _projectiles[5].density;
            _loc9_.friction = _projectiles[5].friction;
            _loc9_.restitution = _projectiles[5].bounce;
            _loc4_.userData = _loc10_;
            if(_totalPlayers == 2)
            {
               _loc9_.filter.categoryBits = _players[0] == param1 ? 2 : 4;
            }
            _loc8_ = _world.CreateBody(_loc4_);
            if(_loc8_)
            {
               _loc8_.CreateShape(_loc9_);
               _loc8_.SetMassFromShapes();
               _loc8_.m_linearVelocity.x = _loc3_.m_linearVelocity.x * _clusterParams[0];
               _loc8_.m_linearVelocity.y = _loc3_.m_linearVelocity.y * _clusterParams[0];
               if(_loc5_ != 1)
               {
                  _loc2_.Normalize();
                  _loc2_.Multiply(_clusterParams[1]);
                  _loc8_.m_force.x = _loc2_.x;
                  _loc8_.m_force.y = _loc2_.y;
               }
            }
            _loc8_.m_force.Multiply(2.5 * _loc9_.density);
            param1.createBody(_loc8_);
            _loc5_++;
         }
         if(param1._localPlayer)
         {
            sendClusterMessage(param1._steps);
         }
         _loc3_.m_userData.sound.stop();
         param1.destroyBody(_loc3_);
         _soundMan.playByName(_soundNameProjectileSplit);
      }
      
      public function createBall(param1:FortSmasherPlayer, param2:int) : void
      {
         var _loc6_:b2Body = null;
         var _loc4_:b2BodyDef = null;
         var _loc8_:Object = getProjectileAsset(param2);
         _loc8_.name = "ball";
         _loc8_.hitpoints = 100;
         _loc8_.type = param2;
         _scene.getLayer("phantom1").loader.content.setType(param2 + 1);
         _loc8_.loader.visible = false;
         var _loc5_:Loader = _loc8_.loader;
         var _loc7_:b2CircleDef = new b2CircleDef();
         if(param2 == 1)
         {
            _allowClusterClick = true;
            _clusterSteps = -1;
         }
         else
         {
            _allowClusterClick = false;
         }
         _loc5_.x = param1._slingshot.loader.x;
         _loc5_.y = param1._slingshot.loader.y - 60;
         _loc4_ = new b2BodyDef();
         _loc4_.position.x = _loc5_.x * _phyScale;
         _loc4_.position.y = _loc5_.y * _phyScale;
         _loc4_.angularDamping = 0.5;
         if(_totalPlayers == 2)
         {
            _loc4_.angularDamping = 4;
         }
         var _loc3_:MovieClip = _scene.getLayer("phantom1").loader.content.projectile.projectile.collision;
         _loc7_.radius = _loc3_.height * 0.5 * _phyScale;
         _loc7_.density = _projectiles[param2].density;
         _loc7_.friction = _projectiles[param2].friction;
         _loc7_.restitution = _projectiles[param2].bounce;
         _loc4_.userData = _loc8_;
         if(_totalPlayers == 2)
         {
            _loc7_.filter.categoryBits = _players[0] == param1 ? 2 : 4;
         }
         _loc6_ = _world.CreateBody(_loc4_);
         if(_loc6_)
         {
            _loc6_.CreateShape(_loc7_);
            _loc6_.SetMassFromShapes();
         }
         param1.createBody(_loc6_);
      }
      
      public function launchBall(param1:FortSmasherPlayer, param2:Number, param3:Number, param4:Boolean) : void
      {
         var _loc5_:Array = null;
         var _loc6_:Number = (param2 - 20) / 60 * 30 + 50;
         var _loc7_:b2Body = param1._bodies[param1._bodies.length - 1].body;
         var _loc8_:Number = -(int(_loc6_) * _launchForce * _loc7_.m_mass);
         _loc7_.m_force = new b2Vec2(_loc8_ * Math.cos(param3),_loc8_ * Math.sin(param3));
         _loc7_.m_userData.loader.visible = true;
         if(param1._localPlayer)
         {
            if(_totalPlayers == 1)
            {
               _scene.getLayer("fort_ui").loader.content.popup(0);
               _ammo[param1._projectileType]--;
               _scene.getLayer("fort_ui").loader.content["counter" + getUIFruitIndex(param1._projectileType) + "Cont"]["counter" + getUIFruitIndex(param1._projectileType)].text = _ammo[param1._projectileType];
               if(_ammo[param1._projectileType] <= 0)
               {
                  fruitOutTarget(_scene.getLayer("fort_ui").loader.content["fruit" + (param1._projectileType + 1)]);
               }
               _endTurnTimer = 2.5;
               _forcePanLeft = false;
            }
            else if(param1._localPlayer && param1._projectileType != 0)
            {
               _ammo[param1._projectileType] = 0;
               fruitOutTarget(_scene.getLayer("fort_ui").loader.content["fruit" + (param1._projectileType + 1)]);
            }
         }
         switch(param1._projectileType)
         {
            case 0:
            case 1:
               _loc7_.m_userData.sound = _soundMan.playByName(_soundNameProjectileFlying);
               break;
            case 2:
               _soundMan.playByName(_soundNameProjectileLarge);
               break;
            case 3:
               _soundMan.playByName(_soundNameProjectileSpin);
               break;
            case 4:
               _soundMan.playByName(_soundNameProjectileCompact);
         }
         _soundMan.playByName(_soundNameProjectileLaunch);
         param1._slingshot.loader.content.launcher.fire();
         param1._launcherLoaded = false;
         if(param4 && param1._projectileType != 1)
         {
            _loc5_ = [];
            _loc5_[0] = "shoot";
            _loc5_[1] = String(param2);
            _loc5_[2] = String(param3);
            _loc5_[3] = String(param1._projectileType);
            _loc5_[4] = "0";
            MinigameManager.msg(_loc5_);
         }
      }
      
      private function sendClusterMessage(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc3_:FortSmasherPlayer = null;
         if(_totalPlayers == 2)
         {
            _loc3_ = _players[_activePlayerIndex];
            _loc2_ = [];
            _loc2_[0] = "shoot";
            _loc2_[1] = String(_loc3_._pullDistance);
            _loc2_[2] = String(_loc3_._angle);
            _loc2_[3] = String(_loc3_._projectileType);
            _loc2_[4] = String(param1);
            MinigameManager.msg(_loc2_);
         }
      }
      
      private function optionsDlgKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onExit_No();
         }
      }
      
      private function showOptionsDlg() : void
      {
         var _loc1_:MovieClip = showDlg("FS_Options",[{
            "name":"btn_restartLevel",
            "f":onBtnRestartLevel
         },{
            "name":"btn_levelSelect",
            "f":onBtnLevelSelect
         },{
            "name":"btn_exitGame",
            "f":onExit_Yes
         },{
            "name":"btn_close",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",optionsDlgKeyDown);
      }
      
      private function gameOverKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onBtnRestartLevel();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function showGameOverDlg() : void
      {
         var _loc2_:MovieClip = showDlg("FS_Game_Over",[{
            "name":"button_yes",
            "f":onBtnRestartLevel
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         LocalizationManager.translateIdAndInsert(_loc2_.points,11550,_players[0]._score);
         var _loc1_:int = Math.floor(_players[0]._score / 1000);
         LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,11432,_loc1_);
         _loc2_.x = 450;
         _loc2_.y = 275;
         stage.addEventListener("keyDown",gameOverKeyDown);
         _soundMan.playByName(_soundNameStingerFail);
         addGemsToBalance(_loc1_);
      }
      
      private function endLevel(param1:MovieClip) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < 5)
         {
            _loc5_ += _ammo[_loc6_];
            _loc6_++;
         }
         var _loc3_:int = _loc5_ * 5000;
         _players[0]._score += _loc3_;
         _scene.getLayer("fort_ui").loader.content.scoreTxtCont.scoreText.text = _players[_activePlayerIndex]._score.toString();
         var _loc4_:int = Math.floor(_players[0]._score / 1000);
         LocalizationManager.translateIdAndInsert(param1.points,11550,_players[0]._score);
         _players[0]._gemCount += _loc4_;
         if(param1.hasOwnProperty("Gems_Total"))
         {
            LocalizationManager.translateIdAndInsert(param1.Gems_Earned,11432,_loc4_);
            LocalizationManager.translateIdAndInsert(param1.Gems_Total,11549,_players[0]._gemCount);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(param1.Gems_Earned,11432,_players[0]._gemCount);
         }
         param1.x = 450;
         param1.y = 275;
         AchievementXtCommManager.requestSetUserVar(159,_fort + 1);
         _displayAchievementTimer = 1;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < 5)
         {
            _loc7_ += _levelAmmo[_fort - 1][_loc6_];
            _loc8_ += _ammo[_loc6_];
            _loc6_++;
         }
         if(_loc7_ - _loc8_ == 1)
         {
            AchievementXtCommManager.requestSetUserVar(145,1);
            _displayAchievementTimer = 1;
         }
         if(_fort + 1 > _levelsUnlocked)
         {
            _levelsUnlocked = _fort + 1;
         }
         var _loc2_:MovieClip = getScorePopup();
         if(_loc2_)
         {
            if(_loc2_.parent == null)
            {
               _layerBackground.addChild(_loc2_);
            }
            _loc2_.x = 450;
            _loc2_.y = 500;
            _loc2_.scaleY = 3;
            _loc2_.scaleX = 3;
            _loc2_.turnOn(String(_loc3_));
         }
         param1.addEventListener("exitFrame",showStar);
         AchievementXtCommManager.requestSetUserVar(160 + _fort,_players[0]._score);
         _soundMan.playByName(_soundNameStingerWin);
         addGemsToBalance(_loc4_);
      }
      
      private function youWinDlgKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onBtnLevelSelect();
               break;
            case 8:
            case 46:
            case 27:
               onBtnLevelSelect();
         }
      }
      
      private function greatJobDlgKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               startNextLevel();
               break;
            case 8:
            case 46:
            case 27:
               onBtnLevelSelect();
         }
      }
      
      private function showYouWinDlg() : void
      {
         stage.removeEventListener("keyDown",ngFactYouWinPlayerKeyDown);
         hideDlg();
         var _loc1_:MovieClip = showDlg("FS_YouWin",[{
            "name":"btn_continue",
            "f":onBtnLevelSelect
         }]);
         stage.addEventListener("keyDown",youWinDlgKeyDown);
         endLevel(_loc1_);
      }
      
      private function showGreatJobDlg() : void
      {
         stage.removeEventListener("keyDown",ngFactContinueKeyDown);
         hideDlg();
         var _loc1_:MovieClip = showDlg("FS_Great_Job",[{
            "name":"button_levelSelect",
            "f":onBtnLevelSelect
         },{
            "name":"button_nextlevel",
            "f":startNextLevel
         }]);
         stage.addEventListener("keyDown",greatJobDlgKeyDown);
         endLevel(_loc1_);
      }
      
      private function showStar(param1:Event) : void
      {
         if(_players[0]._score >= _levelTrophieThreshold[_fort - 1])
         {
            param1.currentTarget.trophy.visible = true;
         }
         else
         {
            param1.currentTarget.trophy.visible = false;
         }
         param1.currentTarget.removeEventListener("exitFrame",showStar);
      }
      
      private function exitMultiPlayerKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onExit_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function showLoseGameOverDlg() : void
      {
         stage.removeEventListener("keyDown",ngFactLoseKeyDown);
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc1_:int = !!_players[0]._localPlayer ? 1 : 0;
         var _loc4_:FortSmasherPlayer = _players[_loc3_];
         var _loc2_:MovieClip = showDlg("FS_Game_Over_Multiplayer",[{
            "name":"button_exit",
            "f":onExit_Yes
         }]);
         stage.addEventListener("keyDown",exitMultiPlayerKeyDown);
         LocalizationManager.translateIdAndInsert(_loc2_.winnerName,11574,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[_loc1_],_perUserAvIDs[_loc1_]).avName);
         LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,11432,Math.floor(_loc4_._score / 1000).toString());
         _loc2_.x = 450;
         _loc2_.y = 275;
         addGemsToBalance(Math.floor(_loc4_._score / 1000));
         _soundMan.playByName(_soundNameStingerFail);
      }
      
      private function ngFactYouWinPlayerKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showYouWinDlg();
         }
      }
      
      private function ngFactContinueKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGreatJobDlg();
         }
      }
      
      private function showNGFact() : void
      {
         var _loc1_:MovieClip = null;
         if(_fort == 50)
         {
            _loc1_ = showDlg("FS_Result",[{
               "name":"continue_btn",
               "f":showYouWinDlg
            }]);
            stage.addEventListener("keyDown",ngFactYouWinPlayerKeyDown);
         }
         else
         {
            _loc1_ = showDlg("FS_Result",[{
               "name":"continue_btn",
               "f":showGreatJobDlg
            }]);
            stage.addEventListener("keyDown",ngFactContinueKeyDown);
         }
         var _loc2_:int = _terrain * 3 + Math.floor(Math.random() * 3);
         _scene.getLayer(_facts[_loc2_].image).loader.x = 0;
         _scene.getLayer(_facts[_loc2_].image).loader.y = 0;
         _loc1_.result_pic.addChild(_scene.getLayer(_facts[_loc2_].image).loader);
         LocalizationManager.translateId(_loc1_.result_fact,_facts[_loc2_].text);
         LocalizationManager.translateId(_loc1_.result_great,11575);
         _loc1_.score.text = "";
         _loc1_.result_score.text = "";
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function ngFactWinKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showWinGameOverDlg();
         }
      }
      
      private function showNGFactWin() : void
      {
         var _loc2_:MovieClip = showDlg("FS_Result",[{
            "name":"continue_btn",
            "f":showWinGameOverDlg
         }]);
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc1_:int = !!_players[0]._localPlayer ? 1 : 0;
         var _loc5_:FortSmasherPlayer = _players[_loc3_];
         var _loc4_:int = Math.floor(Math.random() * _facts.length);
         _scene.getLayer(_facts[_loc4_].image).loader.x = 0;
         _scene.getLayer(_facts[_loc4_].image).loader.y = 0;
         _loc2_.result_pic.addChild(_scene.getLayer(_facts[_loc4_].image).loader);
         LocalizationManager.translateId(_loc2_.result_fact,_facts[_loc4_].text);
         LocalizationManager.translateId(_loc2_.result_great,11575);
         _loc2_.score.text = Math.floor(_loc5_._score).toString();
         _loc2_.x = 450;
         _loc2_.y = 275;
         stage.addEventListener("keyDown",ngFactWinKeyDown);
      }
      
      private function ngFactLoseKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showLoseGameOverDlg();
         }
      }
      
      private function showNGFactLose() : void
      {
         var _loc2_:MovieClip = showDlg("FS_Result",[{
            "name":"continue_btn",
            "f":showLoseGameOverDlg
         }]);
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc1_:int = !!_players[0]._localPlayer ? 1 : 0;
         var _loc5_:FortSmasherPlayer = _players[_loc3_];
         var _loc4_:int = Math.floor(Math.random() * _facts.length);
         _scene.getLayer(_facts[_loc4_].image).loader.x = 0;
         _scene.getLayer(_facts[_loc4_].image).loader.y = 0;
         _loc2_.result_pic.addChild(_scene.getLayer(_facts[_loc4_].image).loader);
         LocalizationManager.translateId(_loc2_.result_fact,_facts[_loc4_].text);
         LocalizationManager.translateId(_loc2_.result_great,11576);
         _loc2_.score.text = Math.floor(_loc5_._score).toString();
         _loc2_.x = 450;
         _loc2_.y = 275;
         stage.addEventListener("keyDown",ngFactLoseKeyDown);
      }
      
      private function ngFactTieKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showTieGameOverDlg();
         }
      }
      
      private function showNGFactTie() : void
      {
         var _loc2_:MovieClip = showDlg("FS_Result",[{
            "name":"continue_btn",
            "f":showTieGameOverDlg
         }]);
         var _loc3_:int = !!_players[0]._localPlayer ? 0 : 1;
         var _loc1_:int = !!_players[0]._localPlayer ? 1 : 0;
         var _loc5_:FortSmasherPlayer = _players[_loc3_];
         var _loc4_:int = Math.floor(Math.random() * _facts.length);
         _scene.getLayer(_facts[_loc4_].image).loader.x = 0;
         _scene.getLayer(_facts[_loc4_].image).loader.y = 0;
         _loc2_.result_pic.addChild(_scene.getLayer(_facts[_loc4_].image).loader);
         LocalizationManager.translateId(_loc2_.result_fact,_facts[_loc4_].text);
         LocalizationManager.translateId(_loc2_.result_great,11575);
         _loc2_.score.text = Math.floor(_loc5_._score).toString();
         _loc2_.x = 450;
         _loc2_.y = 275;
         stage.addEventListener("keyDown",ngFactTieKeyDown);
      }
      
      private function winGameOverDlgKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function showWinGameOverDlg() : void
      {
         stage.removeEventListener("keyDown",ngFactWinKeyDown);
         var _loc1_:int = _playerDropped ? 0 : 25;
         var _loc2_:MovieClip = showDlg("FS_You_Won_Multiplayer",[{
            "name":"button_exit",
            "f":onExit_Yes
         }]);
         var _loc3_:int = Math.floor((!!_players[0]._localPlayer ? _players[0]._score : _players[1]._score) / 1000) + _loc1_;
         LocalizationManager.translateIdAndInsert(_loc2_.gemBonus,11097,_loc1_);
         LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,11432,_loc3_.toString());
         _loc2_.x = 450;
         _loc2_.y = 275;
         addGemsToBalance(_loc3_);
         AchievementXtCommManager.requestSetUserVar(144,1);
         _displayAchievementTimer = 1;
         _soundMan.playByName(_soundNameStingerWin);
         stage.addEventListener("keyDown",winGameOverDlgKeyDown);
      }
      
      private function showTieGameOverDlg() : void
      {
         stage.removeEventListener("keyDown",ngFactTieKeyDown);
         var _loc1_:MovieClip = showDlg("FS_Tie_Multiplayer",[{
            "name":"button_exit",
            "f":onExit_Yes
         }]);
         var _loc2_:int = Math.floor((!!_players[0]._localPlayer ? _players[0]._score : _players[1]._score) / 1000);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11577,_loc2_.toString());
         _loc1_.x = 450;
         _loc1_.y = 275;
         addGemsToBalance(_loc2_);
         _soundMan.playByName(_soundNameStingerWin);
         stage.addEventListener("keyDown",winGameOverDlgKeyDown);
      }
      
      private function chooseFort(param1:int) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         if(_totalPlayers == 2)
         {
            _loc2_ = [];
            _loc2_[0] = "choose";
            _loc2_[1] = "f" + param1;
            MinigameManager.msg(_loc2_);
            _fort = param1;
         }
         else
         {
            _terrain = _fortPopup.terrainNumber - 1;
            _fort = 10 * _terrain + param1;
            _loc3_ = 0;
            while(_loc3_ < 10)
            {
               _fortPopup["l" + (_loc3_ + 1)].removeEventListener("mouseOver",levelButtonMouseEvent);
               _fortPopup["l" + (_loc3_ + 1)].removeEventListener("mouseOut",levelButtonMouseEvent);
               _loc3_++;
            }
         }
         if(_terrain >= 0 && (_levelsUnlocked >= _fort || _totalPlayers == 2))
         {
            if(_forcePreviousTerrain >= 0)
            {
               startNextLevel();
            }
            else
            {
               setGameState(6);
            }
         }
         else if(_totalPlayers == 2)
         {
            hideDlg();
            showWaitingPopup();
         }
      }
      
      private function chooseFort0() : void
      {
         chooseFort(_fortPopup.fortNumber - 1);
      }
      
      private function chooseFort1() : void
      {
         chooseFort(1);
      }
      
      private function chooseFort2() : void
      {
         chooseFort(2);
      }
      
      private function chooseFort3() : void
      {
         chooseFort(3);
      }
      
      private function chooseFort4() : void
      {
         chooseFort(4);
      }
      
      private function chooseFort5() : void
      {
         chooseFort(5);
      }
      
      private function chooseFort6() : void
      {
         chooseFort(6);
      }
      
      private function chooseFort7() : void
      {
         chooseFort(7);
      }
      
      private function chooseFort8() : void
      {
         chooseFort(8);
      }
      
      private function chooseFort9() : void
      {
         chooseFort(9);
      }
      
      private function chooseFort10() : void
      {
         chooseFort(10);
      }
      
      private function chooseTerrain(param1:int) : void
      {
         var _loc2_:Array = null;
         hideDlg();
         if(_totalPlayers == 2)
         {
            _loc2_ = [];
            _loc2_[0] = "choose";
            _loc2_[1] = "t" + param1;
            MinigameManager.msg(_loc2_);
         }
         _terrain = param1;
         if(_fort >= 0)
         {
            setGameState(6);
         }
         else
         {
            showWaitingPopup();
         }
      }
      
      private function chooseTerrain0() : void
      {
         chooseTerrain(0);
      }
      
      private function chooseTerrain1() : void
      {
         chooseTerrain(1);
      }
      
      private function chooseTerrain2() : void
      {
         chooseTerrain(2);
      }
      
      private function chooseTerrain3() : void
      {
         chooseTerrain(3);
      }
      
      private function chooseTerrain4() : void
      {
         chooseTerrain(4);
      }
      
      private function showFortPopup() : void
      {
         var _loc1_:Array = [{
            "name":"fort1",
            "f":chooseFort0
         },{
            "name":"arrowL",
            "f":doNothing
         },{
            "name":"arrowR",
            "f":doNothing
         },{
            "name":"exit_btn",
            "f":onExit_Yes
         }];
         _fortPopup = showDlg("chooseFortPopup",_loc1_);
         _fortPopup.x = 450;
         _fortPopup.y = 275;
      }
      
      private function doNothing() : void
      {
         _soundMan.playByName(_soundNameLevelSelect);
      }
      
      private function showTerrainPopup() : void
      {
         var _loc1_:Array = [{
            "name":"terrain1",
            "f":chooseTerrain0
         },{
            "name":"terrain2",
            "f":chooseTerrain1
         },{
            "name":"terrain3",
            "f":chooseTerrain2
         },{
            "name":"terrain4",
            "f":chooseTerrain3
         },{
            "name":"terrain5",
            "f":chooseTerrain4
         },{
            "name":"arrowL",
            "f":doNothing
         },{
            "name":"arrowR",
            "f":doNothing
         },{
            "name":"exit_btn",
            "f":onExit_Yes
         }];
         _terrainPopup = showDlg("chooseTerrainPopup",_loc1_);
         _terrainPopup.x = 450;
         _terrainPopup.y = 275;
      }
      
      private function showLevelSelectPopup() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Array = [{
            "name":"l1",
            "f":chooseFort1
         },{
            "name":"l2",
            "f":chooseFort2
         },{
            "name":"l3",
            "f":chooseFort3
         },{
            "name":"l4",
            "f":chooseFort4
         },{
            "name":"l5",
            "f":chooseFort5
         },{
            "name":"l6",
            "f":chooseFort6
         },{
            "name":"l7",
            "f":chooseFort7
         },{
            "name":"l8",
            "f":chooseFort8
         },{
            "name":"l9",
            "f":chooseFort9
         },{
            "name":"l10",
            "f":chooseFort10
         },{
            "name":"arrowL",
            "f":doNothing
         },{
            "name":"arrowR",
            "f":doNothing
         },{
            "name":"exit_btn",
            "f":onExit_Yes
         }];
         _levelsUnlocked = gMainFrame.userInfo.userVarCache.getUserVarValueById(159);
         _fortPopup = showDlg("FS_LevelSelect",_loc1_);
         _fortPopup.x = 450;
         _fortPopup.y = 275;
         _loc2_ = 1;
         while(_loc2_ <= 10)
         {
            _fortPopup["l" + _loc2_].mouseChildren = false;
            _loc2_++;
         }
         _fortPopup.addEventListener("exitFrame",setUnlockedLevels);
      }
      
      private function setUnlockedLevels(param1:Event) : void
      {
         var _loc2_:int = 0;
         _fortPopup.removeEventListener("exitFrame",setUnlockedLevels);
         if(_levelsUnlocked > 0)
         {
            _fortPopup.setNumLevelsUnlocked(_levelsUnlocked);
         }
         else
         {
            _levelsUnlocked = 1;
         }
         if(_terrain >= 0)
         {
            _fortPopup.setTerrain(_terrain + 1);
         }
         _loc2_ = 0;
         while(_loc2_ < 10)
         {
            _fortPopup["l" + (_loc2_ + 1)].addEventListener("mouseOver",levelButtonMouseEvent);
            _fortPopup["l" + (_loc2_ + 1)].addEventListener("mouseOut",levelButtonMouseEvent);
            _loc2_++;
         }
         _loc2_ = 1;
         while(_loc2_ <= 50)
         {
            _fortPopup.trophies[_loc2_] = gMainFrame.userInfo.userVarCache.getUserVarValueById(160 + _loc2_) >= _levelTrophieThreshold[_loc2_ - 1];
            _loc2_++;
         }
         _fortPopup.updateGrayLevels();
         _soundMan.playByName(_soundNameLevelSelect);
      }
      
      private function levelButtonMouseEvent(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         var _loc2_:int = 0;
         if(param1.type == "mouseOver")
         {
            _loc5_ = param1.currentTarget.name;
            _loc3_ = parseInt(_loc5_.charAt(_loc5_.length - 1));
            if(_loc3_ == 0)
            {
               _loc3_ = 10;
            }
            _loc4_ = _loc3_;
            _loc3_ += (_fortPopup.terrainNumber - 1) * 10;
            _loc2_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(160 + _loc3_));
            if(_loc2_ >= 0)
            {
               LocalizationManager.translateIdAndInsert(_fortPopup.levelInfo,11548,_fortPopup.terrainNumber + " - " + _loc4_ + "\n" + LocalizationManager.translateIdAndInsertOnly(11546,_loc2_));
            }
         }
      }
      
      private function showWaitingPopup() : void
      {
         var _loc1_:Array = [];
         var _loc2_:MovieClip = showDlg("FS_Waiting",_loc1_);
         _loc2_.x = 450;
         _loc2_.y = 275;
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
      
      private function onResults_Next() : void
      {
         hideDlg();
      }
      
      private function onGameOver_Yes() : void
      {
         hideDlg();
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",winGameOverDlgKeyDown);
         stage.removeEventListener("keyDown",exitMultiPlayerKeyDown);
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("keyDown",titleKeyDown);
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
         stage.removeEventListener("keyDown",optionsDlgKeyDown);
         hideDlg();
      }
      
      private function onBtnRestartLevel() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         _players[0]._doHeartbeat = true;
         _players[0]._hasTurn = true;
         _players[0]._slingshot.loader.content.previewOn();
         _players[0]._numPhantoms = 0;
         _zoomed = false;
         _zoomRight = false;
         _queueGameOver = false;
         setCameraView(0.5);
         _layerBackground.x = _layerPlayers.x = _layerPopups.x = 0;
         _players[0].setProjectileType(0);
         startNextLevel(true);
      }
      
      private function onBtnLevelSelect() : void
      {
         stage.removeEventListener("keyDown",greatJobDlgKeyDown);
         stage.removeEventListener("keyDown",youWinDlgKeyDown);
         hideDlg();
         _players[0]._doHeartbeat = true;
         _players[0]._hasTurn = true;
         _players[0]._slingshot.loader.content.previewOn();
         _players[0]._numPhantoms = 0;
         _zoomed = false;
         _zoomRight = false;
         setCameraView(0.5);
         _layerBackground.x = _layerPlayers.x = _layerPopups.x = 0;
         _players[0].setProjectileType(0);
         _forcePreviousTerrain = _terrain;
         showLevelSelectPopup();
      }
      
      override protected function showDlg(param1:String, param2:Array, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Boolean = false) : MovieClip
      {
         disableInput();
         return super.showDlg(param1,param2,0,0,param5);
      }
      
      override protected function hideDlg() : void
      {
         super.hideDlg();
      }
      
      private function applyMaterials(param1:int) : void
      {
         var _loc10_:Object = null;
         var _loc9_:b2Body = null;
         var _loc6_:b2BodyDef = null;
         var _loc7_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Object = _players[param1]._fort;
         var _loc5_:Object = _scene.getLayer("forts2");
         var _loc4_:b2PolygonDef = new b2PolygonDef();
         var _loc8_:b2CircleDef = new b2CircleDef();
         _loc2_.loader.content.applyMaterials(null);
         _loc7_ = 0;
         for(; _loc7_ < _loc2_.loader.content.numChildren; _loc7_++)
         {
            _loc10_ = _loc2_.loader.content.getChildAt(_loc7_);
            if(_totalPlayers == 1)
            {
               _loc3_ = _loc5_.loader.content.getChildAt(_loc7_);
               _loc10_.x = _loc3_.x;
               _loc10_.y = _loc3_.y;
               _loc10_.scaleX = _loc3_.scaleX;
               _loc10_.scaleY = _loc3_.scaleY;
               _loc10_.rotation = _loc3_.rotation;
               if(_loc10_.materialType != _loc3_.materialType)
               {
                  _loc10_.materialType = _loc3_.materialType;
               }
            }
            _loc10_.rotation0 = _loc10_.rotation;
            if(param1 == 1)
            {
               _loc10_.x *= -1;
               _loc10_.scaleX *= -1;
               _loc10_.rotation *= -1;
               _loc10_.rotation0 = _loc10_.rotation;
            }
            _loc10_.x0 = _loc10_.x;
            _loc10_.y0 = _loc10_.y;
            _loc10_.rotation = 0;
            if(param1 == 1)
            {
               if(_loc10_.shapeType == 3)
               {
                  _loc10_.shapeType = 4;
               }
               else if(_loc10_.shapeType == 4)
               {
                  _loc10_.shapeType = 3;
               }
            }
            switch(_loc10_.shapeType)
            {
               case 0:
                  _loc8_.radius = _loc10_.width * 0.5 * _phyScale;
                  break;
               case 1:
                  if(_loc10_ is Class(getDefinitionByName("Relic")))
                  {
                     _players[param1]._numPhantoms++;
                     _loc4_.SetAsOrientedBox(_loc10_.shape.relic.collision.width * 0.5 * _phyScale * Math.abs(_loc10_.scaleX),_loc10_.shape.relic.collision.height * 0.5 * _phyScale * _loc10_.scaleY);
                     break;
                  }
                  _loc4_.SetAsOrientedBox(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  break;
               case 2:
                  _loc4_.vertexCount = 3;
                  _loc4_.vertices[0].Set(0,-_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[2].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  break;
               case 3:
                  _loc4_.vertexCount = 3;
                  _loc4_.vertices[0].Set(-_loc10_.width * 0.5 * _phyScale,-_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[2].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  break;
               case 4:
                  _loc4_.vertexCount = 3;
                  _loc4_.vertices[0].Set(-_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[1].Set(_loc10_.width * 0.5 * _phyScale,-_loc10_.height * 0.5 * _phyScale);
                  _loc4_.vertices[2].Set(_loc10_.width * 0.5 * _phyScale,_loc10_.height * 0.5 * _phyScale);
                  break;
               default:
                  continue;
            }
            _loc10_.rotation = _loc10_.rotation0;
            if(_loc10_.materialType >= 0)
            {
               _loc4_.density = _loc8_.density = _materials[_loc10_.materialType].density;
               _loc4_.friction = _loc8_.friction = _materials[_loc10_.materialType].friction;
               _loc4_.restitution = _loc8_.restitution = _materials[_loc10_.materialType].bounce;
            }
            else
            {
               _loc4_.density = _loc8_.density = 0;
               _loc4_.friction = _loc8_.friction = 0.2;
               _loc4_.restitution = _loc8_.restitution = 0;
            }
            _loc6_ = new b2BodyDef();
            _loc6_.position.x = (_loc10_.x + _loc2_.loader.x) * _phyScale;
            _loc6_.position.y = (_loc10_.y + _loc2_.loader.y) * _phyScale;
            _loc6_.angle = _loc10_.rotation * 3.141592653589793 / 180;
            _loc6_.isSleeping = true;
            if(_loc10_.materialType >= 0)
            {
               _loc6_.userData = _loc10_;
            }
            if(_totalPlayers == 2)
            {
               _loc4_.filter.maskBits = _loc8_.filter.maskBits = param1 == 0 ? 65533 : 65531;
               _loc4_.filter.categoryBits = _loc8_.filter.categoryBits = param1 == 0 ? 4 : 2;
            }
            _loc9_ = _world.CreateBody(_loc6_);
            if(_loc10_.shapeType == 0)
            {
               _loc9_.CreateShape(_loc8_);
               _loc9_.m_angularDamping = 0.5;
               if(_totalPlayers == 2)
               {
                  _loc9_.m_angularDamping = 4;
               }
            }
            else
            {
               _loc9_.CreateShape(_loc4_);
            }
            _loc9_.SetMassFromShapes();
         }
      }
   }
}

