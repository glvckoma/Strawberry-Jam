package game.towerDefense
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class TowerDefense extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_STARTED:int = 1;
      
      public static const GAMESTATE_GAMEOVER:int = 2;
      
      public static const GAMESTATE_SUCCESS:int = 3;
      
      public static const GAMESTATE_FAIL:int = 4;
      
      public static const GAMESTATE_SELECTMODE:int = 5;
      
      public static const GAMESTATE_QUIT:int = 6;
      
      public static const GAMEMODE_TUTORIAL:int = 0;
      
      public static const GAMEMODE_EASY:int = 1;
      
      public static const GAMEMODE_NORMAL:int = 2;
      
      public static const GAMEMODE_HARD:int = 3;
      
      public static const TOWERTYPE_PLANT:int = 0;
      
      public static const TOWERTYPE_FROG:int = 1;
      
      public static const TOWERTYPE_LIZARD:int = 2;
      
      public static const TOWERTYPE_SNAKE:int = 3;
      
      public static const ENEMYTYPE_ANT:int = 0;
      
      public static const ENEMYTYPE_FLY:int = 1;
      
      public static const ENEMYTYPE_GRASSHOPPER:int = 2;
      
      public static const ENEMYTYPE_DRAGONFLY:int = 3;
      
      public static const ENEMYTYPE_BEETLE:int = 4;
      
      public static const ENEMYTYPE_SCORPION:int = 5;
      
      public static const ENEMYTYPE_TARANTULA:int = 6;
      
      public static const ENEMYTYPE_MOUSE:int = 7;
      
      public var _attackPriority:Array = [[0,1],[2,3],[6,4],[7,5]];
      
      public var _enemyScoreAwards:Array = [100,200,400,500,750,1000,1500,1500];
      
      public var _enemyPopupDisplayed:Array = [0,0,0,0,0,0,0,0];
      
      public var _obstacles:Array = [[0,1,28,29,12,13,26,27,40,41],[98,99,126,127,124,125,138,139],[0,9,11,13,23,25,27,41,125,139],[0,1,2,14,15,16,42,43,70,71,50,123,124,125,137,138,139]];
      
      public var _attackDamage:Array = [[0,0,0],[0,0,0],[0,0,0],[0,0,0]];
      
      public var _attackRate:Array = [[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5],[0.5,0.5,0.5]];
      
      public var _attackRange:Array = [1,2,1,2];
      
      public var _baseHitPoints:Array = [63,94,156,219,313,406,844,750];
      
      public var _speeds:Array = [85,85,85,85,85,85,45,140];
      
      public var _towerCost:Array = [[5,25,50],[10,35,60],[15,45,90],[20,55,100]];
      
      public var _attackDamageModifier:Array = [[9,9,1,1,1,1,1,1],[1,1,14,15,1,1,1,1],[1,1,1,1,22,1,25,1],[1,1,1,1,1,22,1,25]];
      
      public var _attackDamageModifier2:Array = [[14,14,1,1,1,1,1,1],[1,1,18,20,1,1,1,1],[1,1,1,1,35,2,40,2],[1,1,1,1,2,35,2,45]];
      
      public var _attackDamageModifier3:Array = [[25,25,1,1,1,1,1,1],[1,1,35,40,1,1,1,1],[1,1,1,1,60,4,60,4],[1,1,1,1,4,60,4,60]];
      
      public var _startingTokens:Array = [25,25,20,20];
      
      public var _tokenEnemyAwards:Array = [1,2,2,2,3,4,8,6];
      
      public var _pathIndices:Array = [0,1,2,3];
      
      public var _paths:Array = [[14,15,16,30,44,58,59,60,61,62,48,34,20,21,22,23,37,51,65,79,93,107,106,105,104,103,102,88,87,86,85,99,113,127,128,129,130,131,132,133,134,135,136,137,123,109,95,81,82,83],[112,113,114,100,86,72,73,74,75,76,90,104,118,119,120,121,107,93,79,65,51,37,36,35,34,33,32,46,45,44,43,29,15,1,2,3,4,5,6,7,8,9,10,11,25,39,53,67,81,82,83],[10,24,38,52,51,50,49,35,21,7,6,5,4,3,17,31,45,44,43,42,56,70,84,98,112,126,127,128,129,115,101,87,88,89,90,91,105,119,133,134,135,136,122,108,94,80,81,82,83],[56,57,58,72,86,100,114,128,129,130,131,132,133,134,120,106,92,91,90,89,75,61,47,33,19,5,6,7,8,9,10,11,25,39,53,67,81,82,83]];
      
      public var _levels:Array = [[[1,0,1,10],[236,0,1.5,5],[477,0,1.5,5],[575,1,1.5,5],[607,0,1,1.5,5],[613,0,1,1.5,5],[246,2,2,5],[723,0,1,2,1.5,5],[756,1,1.5,5],[760,2,1.5,5],[898,3,2,5]],[[1,0,1,10],[473,0,1.5,5],[716,0,1.5,5],[575,1,1.5,5],[607,0,1,1.5,5],[734,1,1.5,5],[492,2,1.5,5],[623,1,2,1.5,5],[757,0,2,1.5,5],[888,1,2,1.5,5],[898,3,1.5,5],[1063,1,2,3,1.5,5],[1231,0,1,2,3,1.5,5],[1055,2,1.5,5],[1600,2,3,1.5,5],[1349,4,1.5,5],[1717,1,3,4,1.5,5],[1514,0,2,4,1.5,5],[1779,3,4,1.5,5],[2018,2,3,1.5,5],[2156,0,1,2,3,4,1.5,5],[2518,2,3,4,1.5,5],[2747,0,1,2,4,1.5,5],[2865,0,1,4,1.5,5],[3243,2,3,4,1.5,5],[4023,0,1,2,3,4,1.5,5]],[[1,0,1,10],[630,0,1.5,5],[954,0,1.5,5],[767,1,1.5,5],[809,0,1,1.5,5],[978,1,1.5,5],[656,2,1.5,5],[830,1,2,1.5,5],[1010,0,2,1.5,5],[1185,1,2,1.5,5],[1198,3,1.5,5],[1417,1,2,3,1.5,5],[1641,0,1,2,3,1.5,5],[1406,2,1.5,5],[2134,2,3,1.5,5],[1799,4,1.5,5],[2289,1,3,4,1.5,5],[2018,0,2,4,1.5,5],[2372,3,4,1.5,5],[2691,2,3,1.5,5],[2874,0,1,2,3,4,1.5,5],[3358,2,3,4,1.5,5],[2502,5,1.5
      ,5],[3936,0,1,4,5,1.5,5],[4675,2,3,4,5,1.5,5],[4764,2,4,1.5,5],[3212,1,3,1.5,5],[4460,0,2,4,1.5,5],[4703,1,3,5,1.5,5],[4424,0,1,2,3,4,5,1.5,5],[3379,6,2,5],[4428,3,1.5,5],[4471,2,4,1.5,5],[6063,1,4,5,1.5,5],[3687,0,2,1.5,5],[4781,3,4,6,1.5,5],[3768,0,1,2,3,1.5,5],[4968,3,4,5,1.5,5],[5426,1,3,1.5,5],[6167,3,4,1.5,5],[6725,5,6,1.5,5],[6990,4,1.5,5],[5639,2,3,1.5,5],[6403,2,4,5,1.5,5],[7202,4,1.5,5],[7799,0,1,2,3,4,5,6,1.5,5],[3662,2,1.5,5],[9092,2,3,4,5,1.5,5],[11477,4,5,1.5,5],[11189,2,3,4,5,1.5,5],[13743,6,2,5]],[[1,0,1,10],[945,0,1.5,5],[1432,0,1.5,5],[1151,1,1.5,5],[1213,0,1,1.5,5],[1467,1,1.5,5],[984,2,1.5,5],[1245,1,2,1.5,5],[1515,0,2,1.5,5],[1777,1,2,1.5,5],[1796,3,1.5,5],[2126,1,2,3,1.5,5],[2462,0,1,2,3,1.5,5],[2109,2,1.5,5],[3201,2,3,1.5,5],[2698,4,1.5,5],[3434,1,3,4,1.5,5],[3027,0,2,4,1.5,5],[3558,3,4,1.5,5],[4037,2,3,1.5,5],[4311,0,1,2,3,4,1.5,5],[5037,2,3,4,1.5,5],[3753,5,1.5,5],[5904,0,1,4,5,1.5,5],[7013,2,3,4,5,1.5,5],[7146,2,4,1.5,5],[4819,1,3,1.5,5],[6689,0,2,4,1.5,5],[7055
      ,1,3,5,1.5,5],[6636,0,1,2,3,4,5,1.5,5],[5068,6,2,5],[6642,3,1.5,5],[6706,2,4,1.5,5],[9095,1,4,5,1.5,5],[5530,0,2,1.5,5],[7172,3,4,6,1.5,5],[5652,0,1,2,3,1.5,5],[7451,3,4,5,1.5,5],[8139,1,3,1.5,5],[9250,3,4,1.5,5],[1700,7,1.5,5],[10485,4,1.5,5],[8459,2,3,1.5,5],[9605,2,4,5,1.5,5],[10803,4,1.5,5],[11699,0,1,2,3,4,5,6,1.5,5],[5492,2,1.5,5],[13639,2,3,4,5,1.5,5],[17216,4,5,1.5,5],[16783,2,3,4,5,1.5,5],[19240,4,5,6,7,1.5,5],[14654,1,2,3,4,5,1.5,5],[14663,0,1,2,3,4,5,1.5,5],[16196,2,3,5,1.5,5],[10101,4,6,1.5,5],[15246,4,5,6,7,1.5,5],[19848,4,5,1.5,5],[18423,2,3,4,5,1.5,5],[12418,1,3,1.5,5],[22519,2,5,1.5,5],[20325,4,5,6,7,1.5,5],[17876,1,5,1.5,5],[15839,0,2,4,7,1.5,5],[19036,1,3,4,5,6,1.5,5],[17562,0,1,2,3,4,5,1.5,5],[21977,5,6,7,1.5,5],[16125,0,1,2,3,1.5,5],[19786,5,7,1.5,5],[18462,2,4,6,1.5,5],[18083,0,1,2,3,4,5,1,5],[24230,0,1,4,5,7,1.5,5],[19759,4,5,1.5,5],[17101,2,3,1.5,5],[21141,3,4,1.5,5],[27649,0,1,2,3,4,5,1.5,5],[39944,6,7,2,5]]];
      
      private const _audio:Array = ["TD_enemy_kill.mp3","TD_enemy_kill2.mp3","TD_enemy_kill3.mp3","TD_enemy_kill4.mp3","TD_error_tower.mp3","TD_plant_attack1.mp3","TD_plant_attack2.mp3","TD_plant_attack3.mp3","TD_frog_attack1.mp3","TD_frog_attack2.mp3","TD_frog_attack3.mp3","TD_lizard_attack1.mp3","TD_lizard_attack2.mp3","TD_lizard_attack3.mp3","TD_snake_attack1.mp3","TD_snake_attack2.mp3","TD_snake_attack3.mp3","TD_stinger_fail.mp3","Td_stinger_win.mp3","TD_stinger_popup.mp3","TD_tower_deselect.mp3","TD_tower_placement.mp3","TD_tower_sell_2.mp3","TD_tower_upgrade.mp3","TD_tower_select.mp3","td_rollover.mp3","td_rollover_select.mp3","TD_CountDown_timer1.mp3","TD_CountDown_timer2.mp3","TD_health_lost.mp3","TD_upgrade_available.mp3","TD_mus_80bpm_nw.mp3","TD_mus_80bpm_we.mp3"];
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _displayAchievementTimer:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _loadComplete:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerBoard:Sprite;
      
      public var _layerTowers:Sprite;
      
      public var _layerEnemies:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _score:Number;
      
      public var _highScore:Number;
      
      public var _gameSuccesTimer:Number;
      
      public var _level:int;
      
      public var _wave:int;
      
      public var _waveUsedHitpoints:int;
      
      public var _pathIndex:int;
      
      public var _enemies:Array;
      
      public var _placedTowers:Array;
      
      public var _towerLocations:Array;
      
      public var _enemySpawnTimer:Number;
      
      public var _currentDragger:MovieClip;
      
      public var _tokens:int;
      
      public var _waitForNextLevel:Boolean;
      
      public var _lives:int;
      
      public var _frameTimeMultiplier:int;
      
      public var _activeDialogTower:TowerDefenseTower;
      
      public var _cacheEvent:Event;
      
      public var _path:Sprite;
      
      public var _mode:int;
      
      public var _gems:int;
      
      public var _totalGems:int;
      
      public var _tutorialIndex:int;
      
      public var _tutorialLivesLostShown:Boolean;
      
      public var _endless:Boolean;
      
      public var _towerAttackSoundChannels:Array;
      
      public var _enemyPool:Array;
      
      public var _muted:Boolean;
      
      public var _enemiesKilledThisRound:int;
      
      public var _tarantulasKilledThisRound:int;
      
      private var _enemyNames:Array = [11982,11983,11984,11985,11986,11987,11988,11989];
      
      private var _facts:Array = [{
         "image":"ant",
         "text":11942
      },{
         "image":"ant_2",
         "text":11943
      },{
         "image":"ant_3",
         "text":11944
      },{
         "image":"ant_4",
         "text":11945
      },{
         "image":"ant_5",
         "text":11946
      },{
         "image":"fly",
         "text":11947
      },{
         "image":"fly_2",
         "text":11948
      },{
         "image":"fly_3",
         "text":11949
      },{
         "image":"fly_4",
         "text":11950
      },{
         "image":"fly_5",
         "text":11951
      },{
         "image":"grasshpr",
         "text":11952
      },{
         "image":"grasshpr_2",
         "text":11953
      },{
         "image":"grasshpr_3",
         "text":11954
      },{
         "image":"grasshpr_4",
         "text":11955
      },{
         "image":"grasshpr_5",
         "text":11956
      },{
         "image":"drgfly",
         "text":11957
      },{
         "image":"drgfly_2",
         "text":11958
      },{
         "image":"drgfly_3",
         "text":11959
      },{
         "image":"drgfly_4",
         "text":11960
      },{
         "image":"drgfly_5",
         "text":11961
      },{
         "image":"beetle",
         "text":11962
      },{
         "image":"beetle_2",
         "text":11963
      },{
         "image":"beetle_3",
         "text":11964
      },{
         "image":"beetle_4",
         "text":11965
      },{
         "image":"beetle_5",
         "text":11966
      },{
         "image":"scorpion",
         "text":11967
      },{
         "image":"scorpion_2",
         "text":11968
      },{
         "image":"scorpion_3",
         "text":11969
      },{
         "image":"scorpion_4",
         "text":11970
      },{
         "image":"scorpion_5",
         "text":11971
      },{
         "image":"tarantula",
         "text":11972
      },{
         "image":"tarantula_2",
         "text":11973
      },{
         "image":"tarantula_3",
         "text":11974
      },{
         "image":"tarantula_4",
         "text":11975
      },{
         "image":"tarantula_5",
         "text":11976
      },{
         "image":"mouse",
         "text":11977
      },{
         "image":"mouse_2",
         "text":11978
      },{
         "image":"mouse_3",
         "text":11979
      },{
         "image":"mouse_4",
         "text":11980
      },{
         "image":"mouse_5",
         "text":11981
      }];
      
      private var _soundMan:SoundManager;
      
      public var _gameState:int;
      
      internal var _soundNameEnemyKill1:String = _audio[0];
      
      internal var _soundNameEnemyKill2:String = _audio[1];
      
      internal var _soundNameEnemyKill3:String = _audio[2];
      
      internal var _soundNameEnemyKill4:String = _audio[3];
      
      private var _soundNameErrorTower:String = _audio[4];
      
      private var _soundNamePlantAttack1:String = _audio[5];
      
      private var _soundNamePlantAttack2:String = _audio[6];
      
      private var _soundNamePlantAttack3:String = _audio[7];
      
      private var _soundNameFrogAttack1:String = _audio[8];
      
      private var _soundNameFrogAttack2:String = _audio[9];
      
      private var _soundNameFrogAttack3:String = _audio[10];
      
      private var _soundNameLizardAttack1:String = _audio[11];
      
      private var _soundNameLizardAttack2:String = _audio[12];
      
      private var _soundNameLizardAttack3:String = _audio[13];
      
      private var _soundNameSnakeAttack1:String = _audio[14];
      
      private var _soundNameSnakeAttack2:String = _audio[15];
      
      private var _soundNameSnakeAttack3:String = _audio[16];
      
      private var _soundNameStingerFail:String = _audio[17];
      
      private var _soundNameStingerWin:String = _audio[18];
      
      private var _soundNameStingerPopup:String = _audio[19];
      
      internal var _soundNameTowerDeselect:String = _audio[20];
      
      private var _soundNameTowerPlacement:String = _audio[21];
      
      internal var _soundNameTowerSell:String = _audio[22];
      
      internal var _soundNameTowerUpgrade:String = _audio[23];
      
      internal var _soundNameTowerSelect:String = _audio[24];
      
      private var _soundNameRollover:String = _audio[25];
      
      private var _soundNameRolloverSelect:String = _audio[26];
      
      private var _soundNameCountDownTimer1:String = _audio[27];
      
      private var _soundNameCountDownTimer2:String = _audio[28];
      
      private var _soundNameHealthLost:String = _audio[29];
      
      private var _soundNameUpgradeAvailable:String = _audio[30];
      
      private var _soundNameMus80bpmNw:String = _audio[31];
      
      private var _soundNameMus80bpmWe:String = _audio[32];
      
      public var _SFX_TowerDefense_Music:SBMusic;
      
      public var _SFX_TowerDefense_Music_Fast:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function TowerDefense()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_TowerDefense_Music = _soundMan.addStream("TD_mus_80bpm_lp",0.4);
         _SFX_TowerDefense_Music_Fast = _soundMan.addStream("TD_mus_120bpm_lp",0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameEnemyKill1],_soundNameEnemyKill1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameEnemyKill2],_soundNameEnemyKill2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameEnemyKill3],_soundNameEnemyKill3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameEnemyKill4],_soundNameEnemyKill4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameErrorTower],_soundNameErrorTower,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNamePlantAttack1],_soundNamePlantAttack1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePlantAttack2],_soundNamePlantAttack2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePlantAttack3],_soundNamePlantAttack3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogAttack1],_soundNameFrogAttack1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogAttack2],_soundNameFrogAttack2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogAttack3],_soundNameFrogAttack3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLizardAttack1],_soundNameLizardAttack1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLizardAttack2],_soundNameLizardAttack2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLizardAttack3],_soundNameLizardAttack3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeAttack1],_soundNameSnakeAttack1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeAttack2],_soundNameSnakeAttack2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeAttack3],_soundNameSnakeAttack3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerFail],_soundNameStingerFail,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerWin],_soundNameStingerWin,0.85);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerPopup],_soundNameStingerPopup,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameTowerDeselect],_soundNameTowerDeselect,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameTowerPlacement],_soundNameTowerPlacement,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameTowerSell],_soundNameTowerSell,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameTowerUpgrade],_soundNameTowerUpgrade,0.56);
         _soundMan.addSoundByName(_audioByName[_soundNameTowerSelect],_soundNameTowerSelect,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRolloverSelect],_soundNameRolloverSelect,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDownTimer1],_soundNameCountDownTimer1,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDownTimer2],_soundNameCountDownTimer2,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameHealthLost],_soundNameHealthLost,0.76);
         _soundMan.addSoundByName(_audioByName[_soundNameUpgradeAvailable],_soundNameUpgradeAvailable,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameMus80bpmNw],_soundNameMus80bpmNw,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameMus80bpmWe],_soundNameMus80bpmWe,0.55);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function stopBGSounds() : void
      {
         if(_musicLoop)
         {
            _musicLoop.removeEventListener("soundComplete",loopMusic);
            _musicLoop.stop();
            _musicLoop = null;
         }
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         releaseBase();
         stopBGSounds();
         stage.removeEventListener("keyDown",hintKeyDown);
         stage.removeEventListener("keyDown",completeKeyDown);
         stage.removeEventListener("keyDown",continueKeyDown);
         stage.removeEventListener("keyDown",replayKeyDown);
         removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerBoard);
         removeLayer(_guiLayer);
         removeLayer(_layerPopups);
         _layerBackground = null;
         _layerBoard = null;
         _layerTowers = null;
         _layerEnemies = null;
         _guiLayer = null;
         _layerPopups = null;
         _gameState = 6;
         MinigameManager.leave();
      }
      
      private function validateGameData() : void
      {
         if(_attackDamage.length != _attackDamageModifier.length || _attackDamageModifier.length != _attackPriority.length || _attackPriority.length != _attackRange.length || _attackRange.length != _attackRate.length || _attackRate.length != _towerCost.length || _baseHitPoints.length != _speeds.length || _speeds.length != _tokenEnemyAwards.length)
         {
            throw new Error("Invalid game data");
         }
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
            _loc9_ = getDataArray(_loc5_[_loc4_++]);
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
         if(!_sceneLoaded && _cacheEvent != null)
         {
            sceneLoaded(_cacheEvent);
         }
      }
      
      private function getDataArray(param1:String) : Array
      {
         switch(param1)
         {
            case "_attackDamage":
               return _attackDamage;
            case "_attackRate":
               return _attackRate;
            case "_attackRange":
               return _attackRange;
            case "_attackPriority":
               return _attackPriority;
            case "_baseHitPoints":
               return _baseHitPoints;
            case "_speeds":
               return _speeds;
            case "_towerCost":
               return _towerCost;
            case "_attackDamageModifier":
               return _attackDamageModifier;
            case "_attackDamageModifier2":
               return _attackDamageModifier2;
            case "_attackDamageModifier3":
               return _attackDamageModifier3;
            case "_startingGems":
               return _startingTokens;
            case "_gemEnemyAwards":
               return _tokenEnemyAwards;
            case "_paths":
               return _paths;
            case "_pathIndices":
               return _pathIndices;
            case "_levels":
            case "":
               break;
            default:
               return null;
         }
         return _levels;
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            _loadComplete = true;
            setGameState(0);
            validateGameData();
            _layerBackground = new Sprite();
            _layerBoard = new Sprite();
            _layerTowers = new Sprite();
            _layerEnemies = new Sprite();
            _guiLayer = new Sprite();
            _layerPopups = new Sprite();
            _highScore = 0;
            _gameSuccesTimer = 0;
            _level = 1;
            _wave = 0;
            _waveUsedHitpoints = 0;
            _lives = 5;
            _enemySpawnTimer = 0;
            _frameTimeMultiplier = 1;
            _waitForNextLevel = false;
            _enemies = [];
            _enemyPool = [];
            _placedTowers = [];
            _towerLocations = [];
            _towerAttackSoundChannels = [];
            _towerAttackSoundChannels[0] = 0;
            _towerAttackSoundChannels[1] = 0;
            _towerAttackSoundChannels[2] = 0;
            _towerAttackSoundChannels[3] = 0;
            _activeDialogTower = null;
            _mode = 2;
            _gems = 0;
            _totalGems = 0;
            _tutorialLivesLostShown = false;
            _muted = SBAudio.isMusicMuted;
            _enemiesKilledThisRound = 0;
            _tarantulasKilledThisRound = 0;
            _layerBoard.y = 4;
            _layerBoard.x = 4;
            addChild(_layerBackground);
            addChild(_layerBoard);
            addChild(_layerPopups);
            addChild(_guiLayer);
            _layerBackground.addEventListener("mouseDown",mouseUpHandler);
            loadScene("TowerDefense/game_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(!_loadComplete)
         {
            _cacheEvent = param1;
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_TowerDefense_Music,0);
         if(_musicLoop)
         {
            _musicLoop.addEventListener("soundComplete",loopMusic);
         }
         _pathIndex = _pathIndices[_level];
         _path = new Sprite();
         _tokens = _startingTokens[0];
         _endless = false;
         _layerBackground.addChild(_scene.getLayer("background").loader);
         _layerBoard.addChild(_scene.getLayer("board").loader);
         _layerBoard.addChild(_path);
         _layerBoard.addChild(_layerEnemies);
         _layerBoard.addChild(_layerTowers);
         _layerBackground.addChild(_scene.getLayer("tower0").loader);
         _layerBackground.addChild(_scene.getLayer("tower1").loader);
         _layerBackground.addChild(_scene.getLayer("tower2").loader);
         _layerBackground.addChild(_scene.getLayer("tower3").loader);
         _scene.getLayer("background").loader.content.levelText.text = "1";
         _scene.getLayer("background").loader.content.healthText.text = _lives.toString();
         _scene.getLayer("background").loader.content.scoreText.text = "0";
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
         _scene.getLayer("tower0").loader.addEventListener("mouseDown",mouseDownHandler);
         _scene.getLayer("tower0").loader.addEventListener("mouseOver",mouseOverHandler);
         _scene.getLayer("tower0").loader.addEventListener("mouseOut",mouseOutHandler);
         _scene.getLayer("tower1").loader.addEventListener("mouseDown",mouseDownHandler);
         _scene.getLayer("tower1").loader.addEventListener("mouseOver",mouseOverHandler);
         _scene.getLayer("tower1").loader.addEventListener("mouseOut",mouseOutHandler);
         _scene.getLayer("tower2").loader.addEventListener("mouseDown",mouseDownHandler);
         _scene.getLayer("tower2").loader.addEventListener("mouseOver",mouseOverHandler);
         _scene.getLayer("tower2").loader.addEventListener("mouseOut",mouseOutHandler);
         _scene.getLayer("tower3").loader.addEventListener("mouseDown",mouseDownHandler);
         _scene.getLayer("tower3").loader.addEventListener("mouseOver",mouseOverHandler);
         _scene.getLayer("tower3").loader.addEventListener("mouseOut",mouseOutHandler);
         _scene.getLayer("background").loader.content.ff_btn.addEventListener("mouseDown",fastForward);
         _scene.getLayer("background").loader.content.ff_btn.addEventListener("mouseOver",ffOver);
         _scene.getLayer("background").loader.content.ff_btn.addEventListener("mouseOut",ffOut);
         _scene.getLayer("background").loader.content.ff_btn.addEventListener("mouseUp",ffOver);
         _scene.getLayer("background").loader.content.ff_btn.gotoAndStop("fast");
         _scene.getLayer("background").loader.content.sound_btn.addEventListener("mouseDown",toggleMute);
         _scene.getLayer("background").loader.content.sound_btn.addEventListener("mouseOver",muteOver);
         _scene.getLayer("background").loader.content.sound_btn.addEventListener("mouseOut",muteOut);
         _scene.getLayer("background").loader.content.sound_btn.addEventListener("mouseUp",muteOver);
         _scene.getLayer("background").loader.content.sound_btn.gotoAndStop(_muted ? "off" : "on");
         _scene.getLayer("background").loader.content.hint_btn.addEventListener("mouseDown",showHintDlg);
         _scene.getLayer("background").loader.content.hint_btn.addEventListener("mouseOver",hintOver);
         _scene.getLayer("background").loader.content.hint_btn.addEventListener("mouseOut",hintOut);
         _scene.getLayer("background").loader.content.hint_btn.addEventListener("mouseUp",hintOver);
         _scene.getLayer("towerOptions").loader.content.upgradeButton.addEventListener("click",towerOptionsUpgrade);
         _scene.getLayer("towerOptions").loader.content.upgradeButton.addEventListener("mouseDown",towerOptionsUpgradeMouseDown);
         _scene.getLayer("towerOptions").loader.content.upgradeButton.addEventListener("mouseOver",towerOptionsUpgradeMouseOver);
         _scene.getLayer("towerOptions").loader.content.upgradeButton.addEventListener("mouseOut",towerOptionsUpgradeMouseOut);
         _scene.getLayer("towerOptions").loader.content.sellButton.addEventListener("click",towerOptionsSell);
         _scene.getLayer("towerOptions").loader.content.sellButton.addEventListener("mouseDown",towerOptionsSellMouseDown);
         _scene.getLayer("towerOptions").loader.content.sellButton.addEventListener("mouseOver",towerOptionsSellMouseOver);
         _scene.getLayer("towerOptions").loader.content.sellButton.addEventListener("mouseOut",towerOptionsSellMouseOut);
         _loc3_ = 0;
         while(_loc3_ < _scene.getLayer("towerOptions").loader.content.sellButton.numChildren)
         {
            _loc4_ = _scene.getLayer("towerOptions").loader.content.sellButton.getChildAt(_loc3_);
            if(_loc4_.hasOwnProperty("mouseEnabled"))
            {
               _loc4_.mouseEnabled = false;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _scene.getLayer("towerOptions").loader.content.upgradeButton.numChildren)
         {
            _loc4_ = _scene.getLayer("towerOptions").loader.content.upgradeButton.getChildAt(_loc3_);
            if(_loc4_.hasOwnProperty("mouseEnabled"))
            {
               _loc4_.mouseEnabled = false;
            }
            _loc3_++;
         }
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         startGame();
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         if(_gameState != param1)
         {
            _gameState = param1;
         }
         if(_gameState == 5)
         {
            _loc2_ = showDlg("TD_Difficulty",[{
               "name":"btnTutorial",
               "f":onBtnTutorial
            },{
               "name":"btnEasy",
               "f":onBtnEasy
            },{
               "name":"btnMedium",
               "f":onBtnNormal
            },{
               "name":"btnHard",
               "f":onBtnHard
            }]);
            _loc2_.btnTutorial.mouseChildren = false;
            _loc2_.btnEasy.mouseChildren = false;
            _loc2_.btnMedium.mouseChildren = false;
            _loc2_.btnHard.mouseChildren = false;
            _guiLayer.removeChild(_closeBtn);
            _guiLayer.addChild(_closeBtn);
            _closeBtn.visible = true;
            if(_loc2_)
            {
               _loc2_.x = 450;
               _loc2_.y = 275;
            }
         }
      }
      
      private function hintOver(param1:MouseEvent) : void
      {
         if(!_pauseGame)
         {
            param1.target.gotoAndStop("hint_hl");
            play(_soundNameRollover);
         }
      }
      
      private function hintOut(param1:MouseEvent) : void
      {
         param1.target.gotoAndStop("hint");
      }
      
      protected function hintClose() : void
      {
         stage.removeEventListener("keyDown",hintKeyDown);
         hideDlg();
      }
      
      private function hintKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               hintClose();
         }
      }
      
      private function showHintDlg(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(!_pauseGame)
         {
            if(param1)
            {
               param1.target.gotoAndStop("hint_press");
               play(_soundNameRolloverSelect);
            }
            stage.addEventListener("keyDown",hintKeyDown);
            _loc2_ = showDlg("TD_Hint",[{
               "name":"x_btn",
               "f":hintClose
            },{
               "name":"doneButton",
               "f":hintClose
            }]);
            if(_loc2_)
            {
               _loc2_.x = 450;
               _loc2_.y = 275;
            }
         }
      }
      
      private function toggleMute(param1:Event) : void
      {
         var _loc2_:SoundTransform = null;
         if(!_pauseGame)
         {
            if(!_muted)
            {
               _loc2_ = new SoundTransform(0);
            }
            else if(_frameTimeMultiplier == 1)
            {
               _loc2_ = new SoundTransform(_soundMan._musicVolume[_SFX_TowerDefense_Music]);
            }
            else
            {
               _loc2_ = new SoundTransform(_soundMan._musicVolume[_SFX_TowerDefense_Music_Fast]);
            }
            SBAudio.toggleMuteAll();
            if(_musicLoop)
            {
               _musicLoop.soundTransform = _loc2_;
            }
            _muted = !_muted;
            play(_soundNameRolloverSelect);
         }
      }
      
      private function mute() : void
      {
         var _loc1_:SoundTransform = null;
         if(!_muted && _musicLoop)
         {
            SBAudio.muteAll();
            _loc1_ = new SoundTransform(0);
            _musicLoop.soundTransform = _loc1_;
            _musicLoop.addEventListener("soundComplete",loopMusic);
         }
      }
      
      private function unmute() : void
      {
         var _loc1_:SoundTransform = null;
         if(!_muted)
         {
            SBAudio.unmuteAll();
            if(_frameTimeMultiplier == 1)
            {
               _loc1_ = new SoundTransform(_soundMan._musicVolume[_SFX_TowerDefense_Music]);
            }
            else
            {
               _loc1_ = new SoundTransform(_soundMan._musicVolume[_SFX_TowerDefense_Music_Fast]);
            }
            if(_musicLoop)
            {
               _musicLoop.soundTransform = _loc1_;
               _musicLoop.addEventListener("soundComplete",loopMusic);
            }
         }
      }
      
      public function play(param1:String) : SoundChannel
      {
         if(!_muted)
         {
            return _soundMan.playByName(param1);
         }
         return null;
      }
      
      private function onBtnTutorial() : void
      {
         hideDlg();
         _tutorialIndex = 0;
         _guiLayer.addChild(_scene.getLayer("tutorial").loader);
         _level = _mode = 0;
         _pathIndex = _pathIndices[_level % _pathIndices.length];
         _scene.getLayer("board").loader.content.gotoAndStop(_pathIndex + 1);
         setGameState(1);
         _scene.getLayer("tower1").loader.content.lock();
         _scene.getLayer("tower2").loader.content.lock();
         _scene.getLayer("tower3").loader.content.lock();
         _tokens = _startingTokens[_level];
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
      }
      
      private function onBtnEasy() : void
      {
         hideDlg();
         _level = _mode = 1;
         _pathIndex = _pathIndices[_level % _pathIndices.length];
         _scene.getLayer("board").loader.content.gotoAndStop(_pathIndex + 1);
         setGameState(1);
         _scene.getLayer("tower1").loader.content.unlock();
         _scene.getLayer("tower2").loader.content.unlock();
         _scene.getLayer("tower3").loader.content.unlock();
         _tokens = _startingTokens[_level];
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
      }
      
      private function onBtnNormal() : void
      {
         hideDlg();
         _level = _mode = 2;
         _pathIndex = _pathIndices[_level % _pathIndices.length];
         _scene.getLayer("board").loader.content.gotoAndStop(_pathIndex + 1);
         setGameState(1);
         _scene.getLayer("tower1").loader.content.unlock();
         _scene.getLayer("tower2").loader.content.unlock();
         _scene.getLayer("tower3").loader.content.unlock();
         _tokens = _startingTokens[_level];
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
         stage.addEventListener("keyDown",hintKeyDown);
         var _loc1_:MovieClip = showDlg("TD_upgrade1",[{
            "name":"x_btn",
            "f":hintClose
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onBtnHard() : void
      {
         hideDlg();
         _level = _mode = 3;
         _pathIndex = _pathIndices[_level % _pathIndices.length];
         _scene.getLayer("board").loader.content.gotoAndStop(_pathIndex + 1);
         setGameState(1);
         _scene.getLayer("tower1").loader.content.unlock();
         _scene.getLayer("tower2").loader.content.unlock();
         _scene.getLayer("tower3").loader.content.unlock();
         _tokens = _startingTokens[_level];
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "ml")
         {
            end(param1);
            return;
         }
      }
      
      public function towerOptionsUpgrade(param1:MouseEvent) : void
      {
         if(_activeDialogTower && _scene.getLayer("towerOptions").loader.content.upgradeButton.currentFrameLabel == "pressed")
         {
            _activeDialogTower.upgrade();
         }
      }
      
      public function towerOptionsUpgradeMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.upgradeButton;
         if(_loc2_.currentFrameLabel == "on")
         {
            _loc2_.gotoAndStop("pressed");
            play(_soundNameRolloverSelect);
         }
      }
      
      public function towerOptionsUpgradeMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.upgradeButton;
         if(_loc2_.currentFrameLabel == "off")
         {
            _loc2_.gotoAndStop("on");
            play(_soundNameRollover);
         }
      }
      
      public function towerOptionsUpgradeMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.upgradeButton;
         if(_loc2_.currentFrameLabel == "on" || _loc2_.currentFrameLabel == "pressed")
         {
            _loc2_.gotoAndStop("off");
         }
      }
      
      public function towerOptionsSellMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.sellButton;
         if(_loc2_.currentFrameLabel == "on")
         {
            _loc2_.gotoAndStop("pressed");
            play(_soundNameRolloverSelect);
         }
      }
      
      public function towerOptionsSellMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.sellButton;
         if(_loc2_.currentFrameLabel == "off")
         {
            _loc2_.gotoAndStop("on");
            play(_soundNameRollover);
         }
      }
      
      public function towerOptionsSellMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _scene.getLayer("towerOptions").loader.content.sellButton;
         if(_loc2_.currentFrameLabel == "on" || _loc2_.currentFrameLabel == "pressed")
         {
            _loc2_.gotoAndStop("off");
         }
      }
      
      public function towerOptionsSell(param1:MouseEvent) : void
      {
         if(_activeDialogTower)
         {
            _activeDialogTower.sell();
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = 0;
         if(_sceneLoaded && _loadComplete)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            _loc2_ = 0;
            while(_loc2_ < _frameTimeMultiplier)
            {
               update();
               _loc2_++;
            }
            _lastTime = getTimer();
         }
      }
      
      public function getStartingEnemyHitpoints(param1:int) : int
      {
         var _loc4_:Number = NaN;
         var _loc3_:int = 0;
         var _loc2_:Number = 0.01;
         if(_mode == 0 || _mode == 1)
         {
            _loc4_ = 0.75;
         }
         else if(_mode == 2)
         {
            _loc4_ = 1;
         }
         else
         {
            _loc4_ = 1.5;
            _loc3_ = parseInt(_scene.getLayer("background").loader.content.levelText.text);
            if(_loc3_ > 50)
            {
               _loc2_ = (Math.floor((_loc3_ - 50) / 25) + 2) * 0.01;
            }
         }
         return Math.round((_baseHitPoints[param1] + Math.round(_baseHitPoints[param1] * _loc2_ * _wave)) * _loc4_);
      }
      
      public function update() : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         var _loc7_:int = 0;
         var _loc1_:int = 0;
         var _loc6_:TowerDefenseEnemy = null;
         var _loc9_:* = null;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         if(_displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _frameTime;
            if(_displayAchievementTimer <= 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
         if(!_pauseGame && _gameState == 1)
         {
            if(_mode == 0)
            {
               if(_tutorialIndex == 0 || _scene.getLayer("tutorial").loader.content && _scene.getLayer("tutorial").loader.content.finished)
               {
                  if(_tutorialIndex < 5)
                  {
                     _scene.getLayer("tutorial").loader.content.nextTutorial(++_tutorialIndex);
                     if(_activeDialogTower)
                     {
                        _activeDialogTower.towerOptionsClose(null);
                     }
                  }
               }
            }
            if((_mode != 0 || _scene.getLayer("tutorial").loader.content && _scene.getLayer("tutorial").loader.content.finished) && _scene.getLayer("background").loader.content)
            {
               _gameTime += _frameTime;
               if(_waitForNextLevel == false && _levels.length > 0)
               {
                  _enemySpawnTimer -= _frameTime;
                  if(_waveUsedHitpoints == 0)
                  {
                     _scene.getLayer("background").loader.content.nextWave(Math.floor(_enemySpawnTimer));
                     if(Math.floor(_enemySpawnTimer) != Math.floor(_enemySpawnTimer + _frameTime))
                     {
                        if(_enemySpawnTimer <= 1)
                        {
                           if(_wave > 0 && _enemySpawnTimer > 0)
                           {
                              play(_soundNameCountDownTimer2);
                           }
                        }
                     }
                  }
                  else
                  {
                     _scene.getLayer("background").loader.content.nextWave(0);
                  }
                  if(_enemySpawnTimer <= 0)
                  {
                     if(_waveUsedHitpoints == 0)
                     {
                        if(_wave > 1)
                        {
                           _loc3_ = ((_wave - 2) % 5 + 1) * 2;
                           _gems += _loc3_;
                           _score += ((_wave - 2) % 5 + 1) * 500 * (_lives / 5);
                           _scene.getLayer("background").loader.content.scoreText.text = _score.toString();
                           if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                           {
                              if(_tarantulasKilledThisRound > 0)
                              {
                                 AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,_tarantulasKilledThisRound);
                              }
                              if(_enemiesKilledThisRound > 0)
                              {
                                 AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom2UserVarRef,_enemiesKilledThisRound);
                              }
                              _displayAchievementTimer = 1;
                           }
                           _enemiesKilledThisRound = 0;
                           _tarantulasKilledThisRound = 0;
                           if(_mode == 3)
                           {
                              _gems += Math.round(_loc3_ * 0.5);
                           }
                           if(_mode == 0 && _wave == 6)
                           {
                              if(_tokens < 10)
                              {
                                 _tokens = 10;
                                 _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
                              }
                              _tutorialIndex = 6;
                              _scene.getLayer("tower1").loader.content.unlock();
                              _scene.getLayer("tutorial").loader.content.nextTutorial(_tutorialIndex);
                              if(_activeDialogTower)
                              {
                                 _activeDialogTower.towerOptionsClose(null);
                              }
                           }
                        }
                        if(_mode != 0 && _wave > 0)
                        {
                           _loc4_ = 1;
                           while(_loc4_ < _levels[_level][_wave].length - 2)
                           {
                              if(_enemyPopupDisplayed[_levels[_level][_wave][_loc4_]] == 0)
                              {
                                 _enemyPopupDisplayed[_levels[_level][_wave][_loc4_]] = 1;
                                 showNGFact(_levels[_level][_wave][_loc4_]);
                                 break;
                              }
                              _loc4_++;
                           }
                        }
                     }
                     _loc2_ = [];
                     _loc4_ = 1;
                     while(_loc4_ < _levels[_level][_wave].length - 2)
                     {
                        if(_waveUsedHitpoints + getStartingEnemyHitpoints(_levels[_level][_wave][_loc4_]) <= _levels[_level][_wave][0])
                        {
                           _loc2_.push(_levels[_level][_wave][_loc4_]);
                        }
                        _loc4_++;
                     }
                     if(_loc2_.length > 0)
                     {
                        _loc7_ = int(_loc2_[Math.floor(Math.random() * _loc2_.length)]);
                        _loc1_ = getStartingEnemyHitpoints(_loc7_);
                        if(_enemyPool.length > 0)
                        {
                           _loc6_ = _enemyPool[0];
                           _enemyPool.splice(0,1);
                        }
                        else
                        {
                           _loc6_ = new TowerDefenseEnemy(this);
                        }
                        _loc6_.init(_loc7_,_loc1_,_speeds[_loc7_]);
                        _layerEnemies.addChild(_loc6_._clone.loader);
                        _enemies.push(_loc6_);
                        _waveUsedHitpoints += _loc1_;
                        _enemySpawnTimer += _levels[_level][_wave][_levels[_level][_wave].length - 2];
                     }
                     else
                     {
                        _enemySpawnTimer += _levels[_level][_wave][_levels[_level][_wave].length - 1];
                        _waveUsedHitpoints = 0;
                        _wave++;
                        if(_wave > 1)
                        {
                           _totalGems += _gems;
                           addGemsToBalance(_gems);
                           _gems = 0;
                           _scene.getLayer("background").loader.content.levelText.text = (parseInt(_scene.getLayer("background").loader.content.levelText.text) + 1).toString();
                        }
                        else
                        {
                           _scene.getLayer("background").loader.content.levelText.text = "1";
                        }
                     }
                     if(_endless)
                     {
                        if(_wave == _levels[_level].length)
                        {
                           _wave = 51;
                        }
                     }
                     if(_wave == _levels[_level].length || _mode == 3 && _wave == 51 && _endless == false)
                     {
                        _enemySpawnTimer = 0;
                        _waitForNextLevel = true;
                     }
                  }
               }
               else if(_enemies.length == 0)
               {
                  _gameState = 3;
                  _waitForNextLevel = false;
               }
               for each(_loc6_ in _enemies)
               {
                  _loc6_.heartbeat(_frameTime);
                  if(_loc6_._clone.loader.x < -50 || _loc6_._clone.loader.x > 700 || _loc6_._clone.loader.y < -50 || _loc6_._clone.loader.y > 500)
                  {
                     _layerEnemies.removeChild(_loc6_._clone.loader);
                     _loc6_.removeEnemy();
                     _lives--;
                     play(_soundNameHealthLost);
                     if(_mode == 0 && _tutorialLivesLostShown == false)
                     {
                        _scene.getLayer("tutorial").loader.content.nextTutorial(8);
                        _tutorialLivesLostShown = true;
                        if(_activeDialogTower)
                        {
                           _activeDialogTower.towerOptionsClose(null);
                        }
                     }
                     if(_lives == 0)
                     {
                        _gameState = 2;
                     }
                     _score -= _enemyScoreAwards[_loc6_._type];
                     if(_score < 0)
                     {
                        _score = 0;
                     }
                     _scene.getLayer("background").loader.content.scoreText.text = _score.toString();
                     _scene.getLayer("background").loader.content.healthText.text = _lives.toString();
                  }
               }
               for each(_loc9_ in _placedTowers)
               {
                  _loc9_.heartbeat(_frameTime);
               }
            }
         }
         else if(_gameState == 2)
         {
            if(!_pauseGame)
            {
               showGameOverDlg();
            }
         }
         else if(_gameState == 3)
         {
            if(_score > _highScore)
            {
               _highScore = _score;
            }
            if(!_pauseGame)
            {
               showGameCompleteDlg();
            }
         }
         else if(_gameState == 4)
         {
            if(_score > _highScore)
            {
               _highScore = _score;
            }
         }
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
      
      private function boxCollisionTest(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : Boolean
      {
         var _loc13_:* = NaN;
         var _loc11_:* = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc12_:* = NaN;
         var _loc14_:* = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Number = NaN;
         _loc13_ = param1;
         _loc11_ = param5;
         _loc15_ = param1 + param3;
         _loc16_ = param5 + param7;
         _loc12_ = param2;
         _loc14_ = param6;
         _loc10_ = param2 + param4;
         _loc9_ = param6 + param8;
         if(_loc10_ < _loc14_)
         {
            return false;
         }
         if(_loc12_ > _loc9_)
         {
            return false;
         }
         if(_loc15_ < _loc11_)
         {
            return false;
         }
         if(_loc13_ > _loc16_)
         {
            return false;
         }
         return true;
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         setGameState(5);
      }
      
      public function resetGame() : void
      {
         var _loc1_:int = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _gems = 0;
         _totalGems = 0;
         _gameSuccesTimer = 0;
         _tutorialLivesLostShown = false;
         _wave = 0;
         _waveUsedHitpoints = 0;
         _lives = 5;
         _enemySpawnTimer = 0;
         _waitForNextLevel = false;
         _activeDialogTower = null;
         _tokens = 0;
         _endless = false;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         if(_frameTimeMultiplier != 1)
         {
            fastForward(null);
         }
         _scene.getLayer("background").loader.content.ff_btn.gotoAndStop("fast");
         _scene.getLayer("background").loader.content.gemsText.text = "0";
         _scene.getLayer("background").loader.content.levelText.text = "1";
         _scene.getLayer("background").loader.content.scoreText.text = _score.toString();
         _scene.getLayer("background").loader.content.healthText.text = _lives.toString();
         _path.graphics.clear();
         while(_enemies.length)
         {
            _enemies[0]._clone.loader.parent.removeChild(_enemies[0]._clone.loader);
            _enemyPool.push(_enemies[0]);
            _enemies.splice(0,1);
         }
         while(_placedTowers.length)
         {
            _placedTowers[0]._clone.loader.parent.removeChild(_placedTowers[0]._clone.loader);
            _placedTowers.splice(0,1);
         }
         _towerLocations.splice(0,_towerLocations.length);
         _loc1_ = 0;
         while(_loc1_ < _enemyPopupDisplayed.length)
         {
            _enemyPopupDisplayed[_loc1_] = 0;
            _loc1_++;
         }
         setGameState(5);
      }
      
      private function ffOver(param1:MouseEvent) : void
      {
         if(!_pauseGame)
         {
            if(param1.target.currentFrameLabel != "fast_hl" && param1.target.currentFrameLabel != "slow_hl")
            {
               play(_soundNameRollover);
            }
            if(_frameTimeMultiplier == 1)
            {
               param1.target.gotoAndStop("fast_hl");
            }
            else
            {
               param1.target.gotoAndStop("slow_hl");
            }
         }
      }
      
      private function ffOut(param1:MouseEvent) : void
      {
         if(_frameTimeMultiplier == 1)
         {
            param1.target.gotoAndStop("fast");
         }
         else
         {
            param1.target.gotoAndStop("slow");
         }
      }
      
      private function muteOver(param1:MouseEvent) : void
      {
         if(!_pauseGame)
         {
            if(param1.target.currentFrameLabel != "off_hi" && param1.target.currentFrameLabel != "on_hi")
            {
               play(_soundNameRollover);
            }
            if(_muted)
            {
               param1.target.gotoAndStop("off_hi");
            }
            else
            {
               param1.target.gotoAndStop("on_hi");
            }
         }
      }
      
      private function muteOut(param1:MouseEvent) : void
      {
         if(_muted)
         {
            param1.target.gotoAndStop("off");
         }
         else
         {
            param1.target.gotoAndStop("on");
         }
      }
      
      private function fastForward(param1:MouseEvent) : void
      {
         var _loc2_:SoundTransform = null;
         if(!_pauseGame)
         {
            if(_frameTimeMultiplier == 1)
            {
               _frameTimeMultiplier = 4;
               _scene.getLayer("background").loader.content.ff_btn.gotoAndStop("fast_press");
               if(_soundMan && _musicLoop)
               {
                  _soundMan.togglePauseStream(_SFX_TowerDefense_Music);
                  _musicLoop = _soundMan.playStream(_SFX_TowerDefense_Music_Fast,_musicLoop.position * 0.6666666666666);
               }
            }
            else
            {
               _frameTimeMultiplier = 1;
               _scene.getLayer("background").loader.content.ff_btn.gotoAndStop("slow_press");
               if(_soundMan && _musicLoop)
               {
                  _soundMan.togglePauseStream(_SFX_TowerDefense_Music_Fast);
                  _musicLoop = _soundMan.playStream(_SFX_TowerDefense_Music,_musicLoop.position * 1.5);
               }
            }
            if(_muted)
            {
               _loc2_ = new SoundTransform(0);
               if(_musicLoop)
               {
                  _musicLoop.soundTransform = _loc2_;
               }
            }
            play(_soundNameRolloverSelect);
            if(_musicLoop)
            {
               _musicLoop.addEventListener("soundComplete",loopMusic);
            }
         }
      }
      
      private function loopMusic(param1:Event) : void
      {
         var _loc2_:SoundTransform = null;
         if(_frameTimeMultiplier == 4)
         {
            _musicLoop = _soundMan.playStream(_SFX_TowerDefense_Music_Fast,0);
         }
         else
         {
            _musicLoop = _soundMan.playStream(_SFX_TowerDefense_Music,0);
         }
         if(_muted)
         {
            _loc2_ = new SoundTransform(0);
            if(_musicLoop)
            {
               _musicLoop.soundTransform = _loc2_;
            }
         }
         if(_musicLoop)
         {
            _musicLoop.addEventListener("soundComplete",loopMusic);
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(!_pauseGame)
         {
            if(_mode == 0)
            {
               if(_scene.getLayer("tutorial").loader.content.finished || _tutorialIndex == 2 || _tutorialIndex == 6)
               {
                  if(param1.target.parent.hasOwnProperty("plant") && _tutorialIndex >= 2 && _tutorialIndex != 6)
                  {
                     _loc2_ = _scene.cloneAsset("tower0");
                  }
                  else if(param1.target.parent.hasOwnProperty("frog") && _tutorialIndex >= 6)
                  {
                     _loc2_ = _scene.cloneAsset("tower1");
                  }
               }
            }
            else if(param1.target.parent.hasOwnProperty("plant"))
            {
               _loc2_ = _scene.cloneAsset("tower0");
            }
            else if(param1.target.parent.hasOwnProperty("frog"))
            {
               _loc2_ = _scene.cloneAsset("tower1");
            }
            else if(param1.target.parent.hasOwnProperty("lizard"))
            {
               _loc2_ = _scene.cloneAsset("tower2");
            }
            else if(param1.target.parent.hasOwnProperty("snake"))
            {
               _loc2_ = _scene.cloneAsset("tower3");
            }
            if(_loc2_)
            {
               play(_soundNameRolloverSelect);
               _layerTowers.addChild(_scene.getLayer("range").loader);
               _layerTowers.addChild(_loc2_.loader);
               _scene.getLayer("range").loader.visible = false;
               _loc2_.loader.x -= _layerTowers.parent.x;
               _loc2_.loader.y -= _layerTowers.parent.y;
               _loc2_.loader.contentLoaderInfo.addEventListener("complete",towerLoadComplete);
            }
         }
      }
      
      private function mouseOutHandler(param1:MouseEvent) : void
      {
         if(param1.target.parent && param1.target.parent.hasOwnProperty("rollout"))
         {
            if(_mode == 0)
            {
               if(_scene.getLayer("tutorial").loader.content.finished || _tutorialIndex == 2 || _tutorialIndex == 6)
               {
                  if(param1.target.parent.hasOwnProperty("plant") && _tutorialIndex >= 2 && _tutorialIndex != 6 || param1.target.parent.hasOwnProperty("frog") && _tutorialIndex >= 6)
                  {
                     param1.target.parent.rollout();
                  }
               }
            }
            else
            {
               param1.target.parent.rollout();
            }
         }
      }
      
      private function mouseOverHandler(param1:MouseEvent) : void
      {
         if(_currentDragger == null && !_pauseGame && param1.target.parent && param1.target.parent.hasOwnProperty("rollover"))
         {
            if(_mode == 0)
            {
               if(_scene.getLayer("tutorial").loader.content.finished || _tutorialIndex == 2 || _tutorialIndex == 6)
               {
                  if(param1.target.parent.hasOwnProperty("plant") && _tutorialIndex >= 2 && _tutorialIndex != 6 || param1.target.parent.hasOwnProperty("frog") && _tutorialIndex >= 6)
                  {
                     param1.target.parent.rollover();
                     play(_soundNameRollover);
                  }
               }
            }
            else
            {
               param1.target.parent.rollover();
               play(_soundNameRollover);
            }
         }
      }
      
      private function towerLoadComplete(param1:Event) : void
      {
         var _loc2_:Loader = null;
         var _loc3_:MovieClip = param1.target.loader.content;
         if(_loc3_)
         {
            _loc2_ = _scene.getLayer("range").loader;
            _loc2_.y = 25;
            _loc2_.x = 25;
            if(_loc3_.hasOwnProperty("frog") || Boolean(_loc3_.hasOwnProperty("snake")))
            {
               _scene.getLayer("range").loader.content.gotoAndStop(2);
            }
            else
            {
               _scene.getLayer("range").loader.content.gotoAndStop(1);
            }
            param1.target.loader.x = mouseX - 25;
            param1.target.loader.y = mouseY - 25;
            _loc3_.startDrag(false);
            _currentDragger = _loc3_;
            _loc3_.addEventListener("mouseUp",mouseUpHandler);
            _loc3_.addEventListener("mouseMove",mouseMoveHandler);
         }
      }
      
      private function killCurrentDrag() : void
      {
         if(_currentDragger)
         {
            _scene.getLayer("range").loader.parent.removeChild(_scene.getLayer("range").loader);
            _currentDragger.stopDrag();
            _currentDragger.parent.parent.removeChild(_currentDragger.parent);
            _currentDragger.removeEventListener("mouseUp",mouseUpHandler);
            _currentDragger.removeEventListener("mouseMove",mouseMoveHandler);
            _currentDragger = null;
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(_currentDragger)
         {
            if(_scene.getLayer("range").loader.parent)
            {
               _scene.getLayer("range").loader.parent.removeChild(_scene.getLayer("range").loader);
            }
            _currentDragger.stopDrag();
            _currentDragger.removeEventListener("mouseUp",mouseUpHandler);
            _currentDragger.removeEventListener("mouseMove",mouseMoveHandler);
            placeTower();
            _currentDragger = null;
         }
      }
      
      private function mouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:int = 0;
         var _loc3_:Loader = null;
         if(_currentDragger)
         {
            _loc5_ = Math.round((_currentDragger.x + _currentDragger.parent.x) / 50) * 50;
            _loc2_ = Math.round((_currentDragger.y + _currentDragger.parent.y) / 50) * 50;
            _loc4_ = _loc2_ / 50 * 14 + _loc5_ / 50;
            _loc3_ = _scene.getLayer("range").loader;
            if(_loc5_ < 0 || _loc5_ > 650 || _loc2_ < 0 || _loc2_ > 450 || _paths[_pathIndex].indexOf(_loc4_) != -1 || _towerLocations.indexOf(_loc4_) != -1 || _obstacles[_pathIndex].indexOf(_loc4_) != -1)
            {
               _loc3_.visible = false;
            }
            else
            {
               _loc3_.visible = true;
               _loc3_.x = _loc5_ + 25;
               _loc3_.y = _loc2_ + 25;
            }
         }
      }
      
      private function placeTower() : void
      {
         var _loc2_:int = 0;
         var _loc4_:TowerDefenseTower = null;
         _currentDragger.parent.x = Math.round((_currentDragger.x + _currentDragger.parent.x) / 50) * 50;
         _currentDragger.parent.y = Math.round((_currentDragger.y + _currentDragger.parent.y) / 50) * 50;
         _currentDragger.x = 0;
         _currentDragger.y = 0;
         var _loc1_:int = _tokens;
         if(Loader(_currentDragger.parent).content.hasOwnProperty("plant"))
         {
            _loc2_ = 0;
         }
         else if(Loader(_currentDragger.parent).content.hasOwnProperty("frog"))
         {
            _loc2_ = 1;
         }
         else if(Loader(_currentDragger.parent).content.hasOwnProperty("lizard"))
         {
            _loc2_ = 2;
         }
         else if(Loader(_currentDragger.parent).content.hasOwnProperty("snake"))
         {
            _loc2_ = 3;
         }
         _tokens -= _towerCost[_loc2_][0];
         var _loc3_:int = _currentDragger.parent.y / 50 * 14 + _currentDragger.parent.x / 50;
         if(_tokens < 0 || _currentDragger.parent.x < 0 || _currentDragger.parent.x > 650 || _currentDragger.parent.y < 0 || _currentDragger.parent.y > 450 || _paths[_pathIndex].indexOf(_loc3_) != -1 || _towerLocations.indexOf(_loc3_) != -1 || _obstacles[_pathIndex].indexOf(_loc3_) != -1)
         {
            _currentDragger.parent.parent.removeChild(_currentDragger.parent);
            _tokens = _loc1_;
            play(_soundNameErrorTower);
         }
         else
         {
            _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
            _loc4_ = new TowerDefenseTower(this,_loc2_);
            _loc4_._clone.loader = _currentDragger.parent;
            _loc4_.enableMouse();
            _placedTowers.push(_loc4_);
            _towerLocations.push(_loc3_);
            play(_soundNameTowerPlacement);
            if(_mode == 0)
            {
               if(_tutorialIndex == 2)
               {
                  _scene.getLayer("tutorial").loader.content.tutorialOff();
               }
               else if(_tutorialIndex == 6)
               {
                  _scene.getLayer("tutorial").loader.content.nextTutorial(++_tutorialIndex);
                  _scene.getLayer("tutorial").loader.content.finished = true;
                  _currentDragger = null;
                  showHintDlg(null);
                  if(_activeDialogTower)
                  {
                     _activeDialogTower.towerOptionsClose(null);
                  }
               }
            }
         }
      }
      
      public function attack(param1:int) : void
      {
         var _loc4_:String = null;
         var _loc2_:int = 0;
         var _loc5_:SoundChannel = null;
         var _loc3_:Function = null;
         if(_towerAttackSoundChannels[param1] < 2)
         {
            switch(param1)
            {
               case 0:
                  _loc4_ = "Plant";
                  _loc2_ = 3;
                  _loc3_ = removePlantSound;
                  break;
               case 1:
                  _loc4_ = "Frog";
                  _loc2_ = 3;
                  _loc3_ = removeFrogSound;
                  break;
               case 2:
                  _loc4_ = "Lizard";
                  _loc2_ = 3;
                  _loc3_ = removeLizardSound;
                  break;
               case 3:
                  _loc4_ = "Snake";
                  _loc2_ = 3;
                  _loc3_ = removeSnakeSound;
            }
            _loc5_ = play(this["_soundName" + _loc4_ + "Attack" + (Math.floor(Math.random() * _loc2_) + 1)]);
            if(_loc5_ != null)
            {
               _loc5_.addEventListener("soundComplete",_loc3_);
               _towerAttackSoundChannels[param1]++;
            }
         }
      }
      
      private function removePlantSound(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removePlantSound);
         _towerAttackSoundChannels[0]--;
         if(_towerAttackSoundChannels[0] < 0)
         {
            throw new Error("removing more sound attack sounds than currently exist");
         }
      }
      
      private function removeFrogSound(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeFrogSound);
         _towerAttackSoundChannels[1]--;
         if(_towerAttackSoundChannels[1] < 0)
         {
            throw new Error("removing more sound attack sounds than currently exist");
         }
      }
      
      private function removeLizardSound(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeLizardSound);
         _towerAttackSoundChannels[2]--;
         if(_towerAttackSoundChannels[2] < 0)
         {
            throw new Error("removing more sound attack sounds than currently exist");
         }
      }
      
      private function removeSnakeSound(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeSnakeSound);
         _towerAttackSoundChannels[3]--;
         if(_towerAttackSoundChannels[3] < 0)
         {
            throw new Error("removing more sound attack sounds than currently exist");
         }
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
      
      private function completeKeyDown(param1:KeyboardEvent) : void
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
               if(_mode != 3)
               {
                  onExit_Yes();
                  break;
               }
         }
      }
      
      private function continueKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               hideNGFact();
         }
      }
      
      private function showNGFact(param1:int) : void
      {
         var _loc3_:int = 0;
         stage.addEventListener("keyDown",continueKeyDown);
         var _loc2_:MovieClip = showDlg("TD_result",[{
            "name":"continue_btn",
            "f":hideNGFact
         }]);
         if(_loc2_)
         {
            _loc3_ = Math.floor(Math.random() * 5) + 5 * param1;
            _loc2_.scoreCont.score.text = _score.toString();
            _scene.getLayer(_facts[_loc3_].image).loader.x = 0;
            _scene.getLayer(_facts[_loc3_].image).loader.y = 0;
            _loc2_.result_pic.addChild(_scene.getLayer(_facts[_loc3_].image).loader);
            LocalizationManager.translateId(_loc2_.result_factCont.result_fact,_facts[_loc3_].text);
            _loc2_.pestType(param1 + 1);
            LocalizationManager.translateId(_loc2_.pestNameCont.pestName,_enemyNames[param1]);
            mute();
            play(_soundNameStingerPopup);
            _loc2_.x = 450;
            _loc2_.y = 275;
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         if(_gameState == 5)
         {
            onExit_Yes();
            return;
         }
         var _loc1_:MovieClip = showDlg("TD_Exit",[{
            "name":"button_yes",
            "f":onExit_Yes_AwardGems
         },{
            "name":"button_no",
            "f":onExit_NoReset
         }]);
         if(_loc1_)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_score.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11432,(_totalGems + _gems).toString());
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
      }
      
      private function showGameOverDlg() : void
      {
         _gameState = -1;
         stage.addEventListener("keyDown",replayKeyDown);
         hideDlg();
         var _loc1_:MovieClip = showDlg("TD_Game_Over",[{
            "name":"button_yes",
            "f":onRetry
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         if(_loc1_)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.points,11550,_score.toString());
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11432,(_totalGems + _gems).toString());
            _loc1_.x = 450;
            _loc1_.y = 275;
            addGemsToBalance(_gems);
            mute();
            play(_soundNameStingerFail);
         }
      }
      
      private function showGameCompleteDlg() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         hideDlg();
         stage.addEventListener("keyDown",completeKeyDown);
         switch(_mode)
         {
            case 0:
               _loc2_ = showDlg("TD_Win_Tutorial",[{
                  "name":"button_yes",
                  "f":onExit_No
               },{
                  "name":"button_no",
                  "f":onExit_Yes
               }]);
               break;
            case 1:
               _loc2_ = showDlg("TD_Win_Easy",[{
                  "name":"button_yes",
                  "f":onExit_No
               },{
                  "name":"button_no",
                  "f":onExit_Yes
               }]);
               break;
            case 2:
               _loc2_ = showDlg("TD_Win_Medium",[{
                  "name":"button_yes",
                  "f":onExit_No
               },{
                  "name":"button_no",
                  "f":onExit_Yes
               }]);
               break;
            case 3:
               _loc2_ = showDlg("TD_Win_Hard",[{
                  "name":"continue_btn",
                  "f":onExit_No
               }]);
         }
         if(_loc2_)
         {
            _loc1_ = Math.floor(_tokens / 10);
            LocalizationManager.translateIdAndInsert(_loc2_.points,11550,_score.toString());
            LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,11549,(_totalGems + _gems + _loc1_).toString());
            LocalizationManager.translateIdAndInsert(_loc2_.Token_Num_Bonus.gem_bonus,18839,_loc1_.toString());
            _loc2_.x = 450;
            _loc2_.y = 275;
            addGemsToBalance(_gems + _loc1_);
            mute();
            play(_soundNameStingerWin);
         }
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
      
      private function onExit_Yes_AwardGems() : void
      {
         hideDlg();
         addGemsToBalance(_gems);
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onExit_No() : void
      {
         stage.removeEventListener("keyDown",completeKeyDown);
         hideDlg();
         if(_mode != 3)
         {
            resetGame();
         }
         else
         {
            _endless = true;
            setGameState(1);
         }
         unmute();
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         unmute();
         resetGame();
      }
      
      private function onExit_NoReset() : void
      {
         hideDlg();
      }
      
      private function hideNGFact() : void
      {
         stage.removeEventListener("keyDown",continueKeyDown);
         hideDlg();
         unmute();
      }
      
      public function enemyKilled(param1:int, param2:Number) : void
      {
         var _loc3_:Number = NaN;
         if(param1 == 6)
         {
            _tarantulasKilledThisRound++;
         }
         _enemiesKilledThisRound++;
         _tokens += _tokenEnemyAwards[param1];
         _scene.getLayer("background").loader.content.gemsText.text = _tokens.toString();
         if(_activeDialogTower)
         {
            if(_scene.getLayer("towerOptions").loader.content.upgradeButton.currentFrameLabel == "short" && _tokens >= getUpgradeCost(_activeDialogTower._type,_activeDialogTower._upgradeLevel))
            {
               if(_scene.getLayer("towerOptions").loader.hitTestPoint(stage.mouseX,stage.mouseY))
               {
                  _scene.getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("on");
               }
               else
               {
                  _scene.getLayer("towerOptions").loader.content.upgradeButton.gotoAndStop("off");
               }
               play(_soundNameUpgradeAvailable);
            }
         }
         switch(param1)
         {
            case 0:
            case 1:
               if(param2 < 0.1)
               {
                  _loc3_ = 1;
                  break;
               }
               _loc3_ = 1 - (param2 - 0.1) / 0.9;
               break;
            case 2:
            case 3:
               if(param2 < 0.15)
               {
                  _loc3_ = 1;
                  break;
               }
               _loc3_ = 1 - (param2 - 0.15) / 0.85;
               break;
            case 4:
            case 5:
               if(param2 < 0.2)
               {
                  _loc3_ = 1;
                  break;
               }
               _loc3_ = 1 - (param2 - 0.2) / 0.8;
               break;
            case 6:
            case 7:
               if(param2 < 0.25)
               {
                  _loc3_ = 1;
                  break;
               }
               _loc3_ = 1 - (param2 - 0.25) / 0.75;
               break;
         }
         _loc3_ *= 0.9;
         _loc3_ += 0.1;
         _score += Math.round(_enemyScoreAwards[param1] * _loc3_);
         _scene.getLayer("background").loader.content.scoreText.text = _score.toString();
      }
      
      public function getUpgradeCost(param1:int, param2:int) : int
      {
         return _towerCost[param1][param2 + 1];
      }
      
      public function getSellPrice(param1:int, param2:int) : int
      {
         return _towerCost[param1][param2] * 0.6;
      }
      
      override protected function showDlg(param1:String, param2:Array, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Boolean = false) : MovieClip
      {
         killCurrentDrag();
         if(_activeDialogTower)
         {
            _activeDialogTower.towerOptionsClose(null);
         }
         return super.showDlg(param1,param2,0,0,param5);
      }
   }
}

