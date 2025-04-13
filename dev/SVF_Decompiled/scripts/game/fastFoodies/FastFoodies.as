package game.fastFoodies
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarView;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.graphics.PaletteHelper;
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
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   
   public class FastFoodies extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const ACCESSORY_LIST_LAND:int = 49;
      
      private static const GAMESTATE_LEVELSELECT:int = 0;
      
      private static const GAMESTATE_STAGESELECT:int = 1;
      
      private static const GAMESTATE_PLAYING:int = 2;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _gameTimer:Number;
      
      public var _score:int;
      
      public var _aiGameRandomizer:RandomSeed;
      
      private var _stageSelected:int = -1;
      
      private var _checkForLevelDone:Boolean = false;
      
      public var _soundMan:SoundManager;
      
      private var _SFX_Music_Splash:SBMusic;
      
      private var _SFX_Music_Theater:SBMusic;
      
      private var _SFX_Music_JuiceHut:SBMusic;
      
      private var _musicSC:SoundChannel;
      
      private var _currentMusic:SBMusic;
      
      private var _achPlayCount:int;
      
      private var _achAnimalsServed:int;
      
      private var _ach3PawCount:int;
      
      private var _soundTable:Array;
      
      private var _levelStats:Array;
      
      private var _levelResultsPopup:MovieClip;
      
      private const _audio:Array = ["ajm_FFTbutterSquirt.mp3","ajm_FFTcustomerAngry.mp3","ajm_FFTcustomerImpatient.mp3","ajm_FFTdrinkReady.mp3","ajm_FFTfryerEnter.mp3","ajm_FFTitemCheck1.mp3","ajm_FFTitemCheck2.mp3","ajm_FFTitemCheck3.mp3","ajm_FFTitemCheck4.mp3","ajm_FFTitemSelect.mp3","ajm_FFTplayTimeTickRed.mp3","ajm_FFTpopcornReady.mp3","ajm_FFTpourSoda.mp3","ajm_FFTresultsStinger.mp3","ajm_FFUIpawStingerIG.mp3","ajm_FFUIpawStingerRS1.mp3","ajm_FFUIpawStingerRS2.mp3","ajm_FFUIpawStingerRS3.mp3","ajm_FFbellTrill.mp3","ajm_FFblenderStart1.mp3","ajm_FFblenderStart2.mp3","ajm_FFblueSafe.mp3","ajm_FFcoconutBowlPickUp.mp3","ajm_FFcoconutBowlPlaced.mp3","ajm_FFcustOrderClose.mp3","ajm_FFcustomerEnter.mp3","ajm_FFcustomerExit.mp3","ajm_FFcustomerOrder.mp3","ajm_FFcustomerPayLarge.mp3","ajm_FFcustomerPaySmall.mp3","ajm_FFemoticonAngry.mp3","ajm_FFemoticonHappy.mp3","ajm_FFfillBlenderFruit1.mp3","ajm_FFfillBlenderFruit2.mp3","ajm_FFfillBlenderIce.mp3","ajm_FFfillBowlFruit.mp3","ajm_FFfillGlass.mp3"
      ,"ajm_FFgarbage.mp3","ajm_FFgemSpawn.mp3","ajm_FFgrabBlender.mp3","ajm_FFparasolPickUp.mp3","ajm_FFparasolPlaced.mp3","ajm_FFpineappleBowlPickUp.mp3","ajm_FFpineappleBowlPlaced.mp3","ajm_FFpop.mp3","ajm_FFresultsStinger.mp3","ajm_FFscoopedIce.mp3","ajm_FFselectFruit.mp3","ajm_FFstrawPickUp.mp3","ajm_FFstrawPlaced.mp3"];
      
      private var _index:int = 0;
      
      private var _soundNameFFTbutterSquirt:String = _audio[_index++];
      
      private var _soundNameFFTcustomerAngry:String = _audio[_index++];
      
      private var _soundNameFFTcustomerImpatient:String = _audio[_index++];
      
      private var _soundNameFFTdrinkReady:String = _audio[_index++];
      
      private var _soundNameFFTfryerEnter:String = _audio[_index++];
      
      private var _soundNameFFTitemCheck1:String = _audio[_index++];
      
      private var _soundNameFFTitemCheck2:String = _audio[_index++];
      
      private var _soundNameFFTitemCheck3:String = _audio[_index++];
      
      private var _soundNameFFTitemCheck4:String = _audio[_index++];
      
      private var _soundNameFFTitemSelect:String = _audio[_index++];
      
      private var _soundNameFFTplayTimeTickRed:String = _audio[_index++];
      
      private var _soundNameFFTpopcornReady:String = _audio[_index++];
      
      private var _soundNameFFTpourSoda:String = _audio[_index++];
      
      private var _soundNameFFTresultsStinger:String = _audio[_index++];
      
      private var _soundNameFFUIpawStingerIG:String = _audio[_index++];
      
      private var _soundNameFFUIpawStingerRS1:String = _audio[_index++];
      
      private var _soundNameFFUIpawStingerRS2:String = _audio[_index++];
      
      private var _soundNameFFUIpawStingerRS3:String = _audio[_index++];
      
      private var _soundNameFFbellTrill:String = _audio[_index++];
      
      private var _soundNameFFblenderStart1:String = _audio[_index++];
      
      private var _soundNameFFblenderStart2:String = _audio[_index++];
      
      private var _soundNameFFblueSafe:String = _audio[_index++];
      
      private var _soundNameFFcoconutBowlPickUp:String = _audio[_index++];
      
      private var _soundNameFFcoconutBowlPlaced:String = _audio[_index++];
      
      private var _soundNameFFcustOrderClose:String = _audio[_index++];
      
      private var _soundNameFFcustomerEnter:String = _audio[_index++];
      
      private var _soundNameFFcustomerExit:String = _audio[_index++];
      
      private var _soundNameFFcustomerOrder:String = _audio[_index++];
      
      private var _soundNameFFcustomerPayLarge:String = _audio[_index++];
      
      private var _soundNameFFcustomerPaySmall:String = _audio[_index++];
      
      private var _soundNameFFemoticonAngry:String = _audio[_index++];
      
      private var _soundNameFFemoticonHappy:String = _audio[_index++];
      
      private var _soundNameFFfillBlenderFruit1:String = _audio[_index++];
      
      private var _soundNameFFfillBlenderFruit2:String = _audio[_index++];
      
      private var _soundNameFFfillBlenderIce:String = _audio[_index++];
      
      private var _soundNameFFfillBowlFruit:String = _audio[_index++];
      
      private var _soundNameFFfillGlass:String = _audio[_index++];
      
      private var _soundNameFFgarbage:String = _audio[_index++];
      
      private var _soundNameFFgemSpawn:String = _audio[_index++];
      
      private var _soundNameFFgrabBlender:String = _audio[_index++];
      
      private var _soundNameFFparasolPickUp:String = _audio[_index++];
      
      private var _soundNameFFparasolPlaced:String = _audio[_index++];
      
      private var _soundNameFFpineappleBowlPickUp:String = _audio[_index++];
      
      private var _soundNameFFpineappleBowlPlaced:String = _audio[_index++];
      
      private var _soundNameFFpop:String = _audio[_index++];
      
      private var _soundNameFFresultsStinger:String = _audio[_index++];
      
      private var _soundNameFFscoopedIce:String = _audio[_index++];
      
      private var _soundNameFFselectFruit:String = _audio[_index++];
      
      private var _soundNameFFstrawPickUp:String = _audio[_index++];
      
      private var _soundNameFFstrawPlaced:String = _audio[_index++];
      
      public var ajm_musFFSplash:Class;
      
      public var ajm_FFTPopcornLP:Class;
      
      public var ajm_FFTfryerLP:Class;
      
      public var ajm_FFTfryerBurnLP:Class;
      
      public var ajm_FFgemCounterLP:Class;
      
      public var sc_musFFSplash:SoundChannel;
      
      public var sc_FFTPopcornLP:SoundChannel;
      
      public var sc_FFTfryerLP:SoundChannel;
      
      public var sc_FFTfryerBurnLP:SoundChannel;
      
      public var sc_FFgemCounterLP:SoundChannel;
      
      private var _avatarArray:Array = [1,4,5,6,7,8,13,15,16,17,18,23,24,26,27,28,29,30,31,32,33,34,36,37,38,40,41];
      
      private var _availableItems:Array;
      
      private var _availableItemColors:Array;
      
      private var _avatarFinalizeList:Array;
      
      private var _levelSelected:int;
      
      private var _displayAchievementTimer:Number = 0;
      
      private var _bEverythingUnlocked:Boolean;
      
      private var _levelSelectPopup:MovieClip;
      
      private var _gameState:int;
      
      private var _stageSelectPopup:MovieClip;
      
      public function FastFoodies()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music_Splash = _soundMan.addStream("ajm_musFFSplash",0.28);
         _SFX_Music_JuiceHut = _soundMan.addStream("ajm_musFFFruitShack",0.3);
         _SFX_Music_Theater = _soundMan.addStream("ajm_musFFTheater",0.26);
         _soundMan.addSound(ajm_musFFSplash,0.28,"ajm_musFFSplashLP");
         _soundMan.addSound(ajm_FFTPopcornLP,0.45,"ajm_FFTPopcornLP");
         _soundMan.addSoundByName(_audioByName[_soundNameFFTbutterSquirt],_soundNameFFTbutterSquirt,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTcustomerAngry],_soundNameFFTcustomerAngry,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTcustomerImpatient],_soundNameFFTcustomerImpatient,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTdrinkReady],_soundNameFFTdrinkReady,0.33);
         _soundMan.addSound(ajm_FFTfryerBurnLP,0.35,"ajm_FFTfryerBurnLP");
         _soundMan.addSoundByName(_audioByName[_soundNameFFTfryerEnter],_soundNameFFTfryerEnter,0.35);
         _soundMan.addSound(ajm_FFTfryerLP,0.3,"ajm_FFTfryerLP");
         _soundMan.addSoundByName(_audioByName[_soundNameFFTitemCheck1],_soundNameFFTitemCheck1,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTitemCheck2],_soundNameFFTitemCheck2,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTitemCheck3],_soundNameFFTitemCheck3,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTitemCheck4],_soundNameFFTitemCheck4,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTitemSelect],_soundNameFFTitemSelect,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTplayTimeTickRed],_soundNameFFTplayTimeTickRed,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTpopcornReady],_soundNameFFTpopcornReady,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTpourSoda],_soundNameFFTpourSoda,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameFFTresultsStinger],_soundNameFFTresultsStinger,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameFFUIpawStingerIG],_soundNameFFUIpawStingerIG,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameFFUIpawStingerRS1],_soundNameFFUIpawStingerRS1,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameFFUIpawStingerRS2],_soundNameFFUIpawStingerRS2,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameFFUIpawStingerRS3],_soundNameFFUIpawStingerRS3,0.46);
         _soundMan.addSoundByName(_audioByName[_soundNameFFbellTrill],_soundNameFFbellTrill,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFFblenderStart1],_soundNameFFblenderStart1,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameFFblenderStart2],_soundNameFFblenderStart2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFblueSafe],_soundNameFFblueSafe,0.18);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcoconutBowlPickUp],_soundNameFFcoconutBowlPickUp,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcoconutBowlPlaced],_soundNameFFcoconutBowlPlaced,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustOrderClose],_soundNameFFcustOrderClose,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustomerEnter],_soundNameFFcustomerEnter,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustomerExit],_soundNameFFcustomerExit,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustomerOrder],_soundNameFFcustomerOrder,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustomerPayLarge],_soundNameFFcustomerPayLarge,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFFcustomerPaySmall],_soundNameFFcustomerPaySmall,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFFemoticonAngry],_soundNameFFemoticonAngry,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFemoticonHappy],_soundNameFFemoticonHappy,0.53);
         _soundMan.addSoundByName(_audioByName[_soundNameFFfillBlenderFruit1],_soundNameFFfillBlenderFruit1,0.62);
         _soundMan.addSoundByName(_audioByName[_soundNameFFfillBlenderFruit2],_soundNameFFfillBlenderFruit2,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameFFfillBlenderIce],_soundNameFFfillBlenderIce,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFfillBowlFruit],_soundNameFFfillBowlFruit,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameFFfillGlass],_soundNameFFfillGlass,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameFFgarbage],_soundNameFFgarbage,0.52);
         _soundMan.addSound(ajm_FFgemCounterLP,0.3,"ajm_FFgemCounterLP");
         _soundMan.addSoundByName(_audioByName[_soundNameFFgemSpawn],_soundNameFFgemSpawn,0.39);
         _soundMan.addSoundByName(_audioByName[_soundNameFFgrabBlender],_soundNameFFgrabBlender,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFparasolPickUp],_soundNameFFparasolPickUp,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFFparasolPlaced],_soundNameFFparasolPlaced,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFFpineappleBowlPickUp],_soundNameFFpineappleBowlPickUp,0.28);
         _soundMan.addSoundByName(_audioByName[_soundNameFFpineappleBowlPlaced],_soundNameFFpineappleBowlPlaced,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameFFpop],_soundNameFFpop,0.68);
         _soundMan.addSoundByName(_audioByName[_soundNameFFresultsStinger],_soundNameFFresultsStinger,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFFscoopedIce],_soundNameFFscoopedIce,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFFselectFruit],_soundNameFFselectFruit,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameFFstrawPickUp],_soundNameFFstrawPickUp,0.43);
         _soundMan.addSoundByName(_audioByName[_soundNameFFstrawPlaced],_soundNameFFstrawPlaced,0.5);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         releaseBase();
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         if(sc_musFFSplash)
         {
            sc_musFFSplash.stop();
            sc_musFFSplash = null;
         }
         if(sc_FFTPopcornLP)
         {
            sc_FFTPopcornLP.stop();
            sc_FFTPopcornLP = null;
         }
         if(sc_FFTfryerLP)
         {
            sc_FFTfryerLP.stop();
            sc_FFTfryerLP = null;
         }
         if(sc_FFTfryerBurnLP)
         {
            sc_FFTfryerBurnLP.stop();
            sc_FFTfryerBurnLP = null;
         }
         if(sc_FFgemCounterLP)
         {
            sc_FFgemCounterLP.stop();
            sc_FFgemCounterLP = null;
         }
         for each(var _loc2_ in _avatarFinalizeList)
         {
            _loc2_.avt.destroy();
            delete _loc2_.avt;
         }
         _avatarFinalizeList = null;
         _levelResultsPopup = null;
         _layerMain = null;
         _guiLayer = null;
         if(_musicSC)
         {
            _musicSC.stop();
            _musicSC = null;
         }
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _aiGameRandomizer = new RandomSeed(Math.random() * 10000);
         _avatarFinalizeList = [];
         if(!_bInit)
         {
            ItemXtCommManager.requestShopList(gotItemListCallback,49);
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("FastFoodies/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = null;
         if(_gameState == 2)
         {
            _loc1_ = showDlg("foodiesExitDlg",[{
               "name":"button_yes",
               "f":onExit_Yes
            },{
               "name":"button_no",
               "f":onExit_No
            },{
               "name":"replayBtn",
               "f":stageSelectedHelper
            },{
               "name":"menuBtn",
               "f":showStageSelect
            }]);
            _theGame.loader.content.gameIsPaused = true;
            _loc1_.x = 450;
            _loc1_.y = 275;
         }
         else if(_gameState == 0)
         {
            _levelSelectPopup.exitPopupOn();
         }
         else
         {
            _stageSelectPopup.exitPopupOn();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         ajm_musFFSplash = getDefinitionByName("ajm_musFFSplash") as Class;
         ajm_FFTPopcornLP = getDefinitionByName("ajm_FFTPopcornLP") as Class;
         ajm_FFTfryerLP = getDefinitionByName("ajm_FFTfryerLP") as Class;
         ajm_FFTfryerBurnLP = getDefinitionByName("ajm_FFTfryerBurnLP") as Class;
         ajm_FFgemCounterLP = getDefinitionByName("ajm_FFgemCounterLP") as Class;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc5_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",_loc5_.x,_loc5_.y,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _theGame.loader.content.loopsOn = true;
         _theGame.loader.content.ajExit = onExit_Yes;
         _theGame.loader.content.awardGems = addGemsToBalance;
         _theGame.loader.content.getRandomAvatar = getRandomAvatar;
         _theGame.loader.content.playAnimation = playAnimation;
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         _soundTable = [];
         _loc4_ = 0;
         while(_loc4_ < _audio.length)
         {
            _soundTable.push([_audio[_loc4_],_audio[_loc4_].substring(0,_audio[_loc4_].length - 4)]);
            _loc4_++;
         }
         _levelStats = [];
         _levelStats.push([]);
         _levelStats.push([]);
         _ach3PawCount = gMainFrame.userInfo.userVarCache.getUserVarValueById(446);
         _achPlayCount = gMainFrame.userInfo.userVarCache.getUserVarValueById(444);
         _achAnimalsServed = gMainFrame.userInfo.userVarCache.getUserVarValueById(445);
         _levelStats[0][0] = gMainFrame.userInfo.userVarCache.getUserVarValueById(447);
         _levelStats[0][1] = gMainFrame.userInfo.userVarCache.getUserVarValueById(448);
         _levelStats[1][0] = gMainFrame.userInfo.userVarCache.getUserVarValueById(449);
         _levelStats[1][1] = gMainFrame.userInfo.userVarCache.getUserVarValueById(450);
         if(_levelStats[0][0] == -1)
         {
            _levelStats[0][0] = 0;
         }
         if(_levelStats[0][1] == -1)
         {
            _levelStats[0][1] = 0;
         }
         if(_levelStats[1][0] == -1)
         {
            _levelStats[1][0] = 0;
         }
         if(_levelStats[1][1] == -1)
         {
            _levelStats[1][1] = 0;
         }
         if(_ach3PawCount == -1)
         {
            _ach3PawCount = 0;
         }
         if(_achPlayCount == -1)
         {
            _achPlayCount = 0;
         }
         if(_achAnimalsServed == -1)
         {
            _achAnimalsServed = 0;
         }
         set3PawCount();
         showLevelSelect();
      }
      
      private function set3PawCount() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            switch(_loc3_)
            {
               case 0:
                  _loc1_ = int(_levelStats[0][0]);
                  break;
               case 1:
                  _loc1_ = int(_levelStats[0][1]);
                  break;
               case 2:
                  _loc1_ = int(_levelStats[1][0]);
                  break;
               default:
                  _loc1_ = int(_levelStats[1][1]);
            }
            _loc2_ = 0;
            while(_loc2_ < 10)
            {
               if((_loc1_ >> _loc2_ & 3) == 3)
               {
                  _loc4_++;
               }
               _loc2_++;
            }
            _loc3_++;
         }
         if(_ach3PawCount != _loc4_)
         {
            AchievementXtCommManager.requestSetUserVar(446,_loc4_);
            _ach3PawCount = _loc4_;
            _displayAchievementTimer = 1;
         }
      }
      
      private function unlockEverything(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.keyCode == 85)
         {
            _bEverythingUnlocked = true;
            _levelSelectPopup.unlock();
         }
         if(param1.keyCode == 65)
         {
            _loc2_ = 444;
            while(_loc2_ <= 446)
            {
               AchievementXtCommManager.requestSetUserVar(_loc2_,0);
               _loc2_++;
            }
         }
         if(param1.keyCode == 82)
         {
            _loc2_ = 447;
            while(_loc2_ <= 450)
            {
               AchievementXtCommManager.requestSetUserVar(_loc2_,0);
               _loc2_++;
            }
            _levelStats[0][0] = 0;
            _levelStats[0][1] = 0;
            _levelStats[1][0] = 0;
            _levelStats[1][1] = 0;
         }
         if(param1.keyCode == 81)
         {
            _ach3PawCount = 39;
            AchievementXtCommManager.requestSetUserVar(446,39);
            AchievementXtCommManager.requestSetUserVar(447,_levelStats[0][0] = 1048572);
            AchievementXtCommManager.requestSetUserVar(448,_levelStats[0][1] = 1048575);
            AchievementXtCommManager.requestSetUserVar(449,_levelStats[1][0] = 1048575);
            AchievementXtCommManager.requestSetUserVar(450,_levelStats[1][1] = 1048575);
         }
      }
      
      private function gotoJuiceHut() : void
      {
         _theGame.loader.content.resetLocation(0);
         _levelSelected = 0;
         showStageSelect();
      }
      
      private function gotoTheater() : void
      {
         _theGame.loader.content.resetLocation(1);
         _levelSelected = 1;
         showStageSelect();
      }
      
      private function showHowToPlay() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = showDlg("foodiesHowToPlay_popup",[{
            "name":"xBtn",
            "f":onCloseTutorial
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onCloseTutorial() : void
      {
         showLevelStartHelper();
      }
      
      private function showLevelResults() : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         _loc3_ = showDlg("foodiesResults_popup",[{
            "name":"replayBtn",
            "f":onReplay
         },{
            "name":"menuBtn",
            "f":showStageSelect
         },{
            "name":"nextBtn",
            "f":onNext
         }]);
         _loc3_.x = 450;
         _loc3_.y = 275;
         _levelResultsPopup = _loc3_;
         _loc3_.gemsText.text = _theGame.loader.content.gemsEarned;
         LocalizationManager.translateIdAndInsert(_loc3_.titleText,29023,_stageSelected);
         _loc3_.setRank(_theGame.loader.content.rankEarned,_levelSelected == 1 && _stageSelected == 20);
         if(_musicSC)
         {
            _musicSC.stop();
         }
         _currentMusic = null;
         if(_levelSelected == 0)
         {
            if(_stageSelected <= 10)
            {
               _loc2_ = 447;
            }
            else
            {
               _loc2_ = 448;
            }
         }
         else if(_stageSelected <= 10)
         {
            _loc2_ = 449;
         }
         else
         {
            _loc2_ = 450;
         }
         var _loc4_:* = int(_levelStats[_levelSelected][_stageSelected <= 10 ? 0 : 1]);
         var _loc1_:* = _theGame.loader.content.rankEarned << (_stageSelected <= 10 ? (_stageSelected - 1) * 2 : (_stageSelected - 11) * 2);
         _loc4_ |= _loc1_;
         _levelStats[_levelSelected][_stageSelected <= 10 ? 0 : 1] = _loc4_;
         AchievementXtCommManager.requestSetUserVar(_loc2_,_loc4_);
         _achPlayCount++;
         _achAnimalsServed += _theGame.loader.content.customersServed;
         AchievementXtCommManager.requestSetUserVar(444,_achPlayCount);
         AchievementXtCommManager.requestSetUserVar(445,_achAnimalsServed);
         set3PawCount();
         _displayAchievementTimer = 1;
         _checkForLevelDone = false;
      }
      
      private function onReplay() : void
      {
         stageSelectedHelper();
      }
      
      private function onNext() : void
      {
         _stageSelected++;
         if(_stageSelected <= 20)
         {
            if(_theGame.loader.content.rankEarned > 0)
            {
               stageSelectedHelper();
            }
            else
            {
               _stageSelected--;
            }
         }
         else if(_levelSelected == 0)
         {
            if(_theGame.loader.content.rankEarned > 0)
            {
               _levelSelected = 1;
               _stageSelected = 1;
               _theGame.loader.content.resetLocation(1);
               stageSelectedHelper();
            }
            else
            {
               _stageSelected--;
            }
         }
      }
      
      private function showStageSelect() : void
      {
         var _loc4_:int = 0;
         var _loc1_:Array = [];
         _loc4_ = 1;
         while(_loc4_ <= 20)
         {
            _loc1_.push({
               "name":"stageList.stage" + _loc4_ + ".stageInfo.playButton",
               "f":onstageSelected
            });
            _loc4_++;
         }
         _loc1_.push({
            "name":"backButton",
            "f":showLevelSelect
         },{
            "name":"exitPopup.button_yes",
            "f":onExit_Yes
         },{
            "name":"exitPopup.button_no",
            "f":onExit_No
         });
         if(_currentMusic != _SFX_Music_Splash)
         {
            if(_musicSC != null)
            {
               _musicSC.stop();
            }
            _musicSC = _soundMan.play(ajm_musFFSplash,0,999999);
            _currentMusic = _SFX_Music_Splash;
         }
         var _loc2_:MovieClip = showDlg("foodiesSelectAStage_popup",_loc1_);
         _loc2_.x = 450;
         _loc2_.y = 275;
         _stageSelectPopup = _loc2_;
         _closeBtn.visible = true;
         _guiLayer.addChild(_closeBtn);
         var _loc3_:Array = _levelStats[_levelSelected];
         _loc4_ = 0;
         while(_loc4_ < 10)
         {
            _loc2_.showStageProgress(_loc4_ + 1,_loc3_[0] >> _loc4_ * 2 & 3);
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 10)
         {
            _loc2_.showStageProgress(_loc4_ + 11,_loc3_[1] >> _loc4_ * 2 & 3);
            _loc4_++;
         }
         _gameState = 1;
      }
      
      private function showLevelSelect() : void
      {
         var _loc1_:MovieClip = showDlg("foodiesLevelSelect_popup",[{
            "name":"juiceHutBtn",
            "f":gotoJuiceHut
         },{
            "name":"theaterBtn",
            "f":gotoTheater
         },{
            "name":"exitPopup.button_yes",
            "f":onExit_Yes
         },{
            "name":"exitPopup.button_no",
            "f":onExit_No
         }],450,275);
         _closeBtn.visible = true;
         _guiLayer.addChild(_closeBtn);
         _gameState = 0;
         _levelSelectPopup = _loc1_;
         if(_currentMusic != _SFX_Music_Splash)
         {
            if(_musicSC != null)
            {
               _musicSC.stop();
            }
            _musicSC = _soundMan.play(ajm_musFFSplash,0,999999);
            _currentMusic = _SFX_Music_Splash;
         }
         if((_levelStats[0][1] & 0x0C0000) != 0)
         {
            _loc1_.unlock();
         }
      }
      
      private function onstageSelected(param1:MouseEvent) : void
      {
         _stageSelected = param1.currentTarget.parent.parent.name.substr(5);
         stageSelectedHelper();
      }
      
      private function stageSelectedHelper() : void
      {
         if(_levelSelected == 0 && _stageSelected == 1)
         {
            showHowToPlay();
         }
         else
         {
            showLevelStartHelper();
         }
         _theGame.loader.content.clearScene();
         _gameState = 2;
      }
      
      private function showLevelStartHelper() : void
      {
         var _loc1_:MovieClip = null;
         _loc1_ = showDlg("foodiesLevelStart_popup",[{
            "name":"button_exit",
            "f":startLevel
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _loc1_.stageNumTxt.text = _stageSelected;
         _loc1_.gemGoalTxt.text = _theGame.loader.content.juiceHutGoals[_stageSelected];
         if(_musicSC)
         {
            _musicSC.stop();
         }
         _musicSC = _soundMan.playStream(_levelSelected == 0 ? _SFX_Music_JuiceHut : _SFX_Music_Theater,0,999999);
         _currentMusic = _SFX_Music_JuiceHut;
      }
      
      private function playAnimation(param1:AvatarView, param2:int) : void
      {
         param1.playAnim(param2,false,0);
      }
      
      private function startLevel() : void
      {
         hideDlg();
         var _loc2_:int = int(_levelStats[_levelSelected][_stageSelected <= 10 ? 0 : 1]);
         var _loc1_:* = _loc2_ >> (_stageSelected <= 10 ? (_stageSelected - 1) * 2 : (_stageSelected - 11) * 2) & 3;
         _theGame.loader.content.gameIsPaused = false;
         _theGame.loader.content.startLevel(_stageSelected,_loc1_);
         _checkForLevelDone = true;
      }
      
      public function getRandomAvatar() : AvatarView
      {
         var _loc3_:Avatar = new Avatar();
         var _loc2_:AvatarView = new AvatarView();
         _loc2_.init(_loc3_);
         var _loc1_:int = int(_avatarArray[_aiGameRandomizer.integer(0,_avatarArray.length - 1)]);
         _loc3_.init(-1,-1,"FastFoodiesAvatar",_loc1_,[0,0,0]);
         _loc3_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(_loc1_,0,0,false));
         if(_availableItems != null)
         {
            _avatarFinalizeList.push({
               "avt":_loc2_,
               "bInitted":true
            });
            initFinalize(_loc2_);
         }
         else
         {
            _avatarFinalizeList.push({
               "avt":_loc2_,
               "bInitted":false
            });
         }
         return _loc2_;
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Item = null;
         _availableItems = new Array(param1.length);
         var _loc4_:int = 100;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc7_ = param1.getIitem(_loc5_) as Item;
            _availableItems[_loc5_] = new Item();
            _availableItems[_loc5_].init(_loc7_.defId,_loc4_++,_loc7_.color);
            _availableItems[_loc5_].makeSmallIcon();
            _loc5_++;
         }
         _availableItemColors = param3;
         _loc6_ = 0;
         while(_loc6_ < _avatarFinalizeList.length)
         {
            if(!_avatarFinalizeList[_loc6_].bInitted)
            {
               initFinalize(_avatarFinalizeList[_loc6_].avt);
               _avatarFinalizeList[_loc6_].bInitted = true;
            }
            _loc6_++;
         }
      }
      
      public function initFinalize(param1:AvatarView, param2:String = null) : void
      {
         initAIAccessories(param1);
         var _loc3_:Array = new Array(2);
         _loc3_[0] = 14;
         _loc3_[1] = 9;
         _loc3_[2] = 10;
         _loc3_[3] = 23;
         _loc3_[4] = 6;
         _loc3_[5] = 35;
         param1.preloadAnims(_loc3_);
         playAnimation(param1,9);
      }
      
      public function initAIAccessories(param1:AvatarView) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Item = null;
         var _loc4_:AccItemCollection = new AccItemCollection();
         _loc2_ = 0;
         while(_loc2_ < param1.avatarData.inventoryBodyMod.numItems)
         {
            _loc4_.pushAccItem(param1.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc2_));
            _loc2_++;
         }
         if(_aiGameRandomizer.integer(100) > 20)
         {
            _loc3_ = pickRandomClothingItemByLayer(5);
            if(_loc3_ != null)
            {
               _loc4_.pushAccItem(_loc3_);
            }
         }
         if(_aiGameRandomizer.integer(100) > 20)
         {
            _loc3_ = pickRandomClothingItemByLayer(6);
            if(_loc3_ != null)
            {
               _loc4_.pushAccItem(_loc3_);
            }
         }
         if(_aiGameRandomizer.integer(100) > 20)
         {
            _loc3_ = pickRandomClothingItemByLayer(8);
            if(_loc3_ == null)
            {
               _loc3_ = pickRandomClothingItemByLayer(9);
               if(_loc3_ == null)
               {
                  _loc3_ = pickRandomClothingItemByLayer(10);
               }
            }
            if(_loc3_ != null)
            {
               _loc4_.pushAccItem(_loc3_);
            }
         }
         if(_loc4_.length > param1.avatarData.inventoryBodyMod.numItems)
         {
            param1.avatarData.itemResponseIntegrate(_loc4_);
         }
         pickRandomColors(param1);
         pickEyeAndPattern(param1);
      }
      
      public function pickRandomClothingItemByLayer(param1:int) : Item
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Item = null;
         var _loc4_:Item = null;
         var _loc5_:int = 0;
         _loc3_ = _aiGameRandomizer.integer(_availableItems.length);
         _loc2_ = 0;
         while(_loc2_ < _availableItems.length)
         {
            _loc4_ = _availableItems[_loc3_];
            _loc5_ = _aiGameRandomizer.integer(_availableItemColors[_loc4_.defId].length);
            _loc4_.color = _availableItemColors[_loc4_.defId][_loc5_];
            if(_loc4_.type == 1 && _loc4_.layerId == param1)
            {
               _loc6_ = new Item();
               _loc6_.init(_loc4_.defId,_loc4_.invIdx,_loc4_.color,EquippedAvatars.forced());
               return _loc6_;
            }
            _loc3_++;
            if(_loc3_ >= _availableItems.length)
            {
               _loc3_ = 0;
            }
            _loc2_++;
         }
         return null;
      }
      
      private function pickRandomColors(param1:AvatarView) : void
      {
         var _loc2_:uint = uint(PaletteHelper.avatarPalette1[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc5_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette2.length)]);
         var _loc6_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc9_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc3_:Array = param1.avatarData.colors;
         var _loc4_:uint = uint(_loc3_[0]);
         var _loc7_:uint = uint(_loc3_[1]);
         var _loc8_:uint = uint(_loc3_[2]);
         _loc4_ = uint(_loc2_ << 24 | _loc5_ << 16 | (_loc4_ >> 8 & 0xFF) << 8 | _loc4_ & 0xFF);
         _loc7_ = uint(_loc6_ << 24 | (_loc7_ >> 16 & 0xFF) << 16 | (_loc7_ >> 8 & 0xFF) << 8 | _loc7_ & 0xFF);
         _loc8_ = uint(_loc9_ << 24 | (_loc8_ >> 16 & 0xFF) << 16 | (_loc8_ >> 8 & 0xFF) << 8 | _loc8_ & 0xFF);
         param1.avatarData.colors = [_loc4_,_loc7_,_loc8_];
      }
      
      private function pickEyeAndPattern(param1:AvatarView) : void
      {
         var _loc2_:Item = null;
         var _loc4_:int = 0;
         var _loc5_:Vector.<Item> = new Vector.<Item>();
         var _loc3_:Vector.<Item> = new Vector.<Item>();
         if(param1.avatarData.inventoryBodyMod != null)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.avatarData.inventoryBodyMod.numItems)
            {
               _loc2_ = param1.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc4_);
               if(_loc2_.layerId == 2)
               {
                  _loc3_.push(_loc2_);
               }
               else if(_loc2_.layerId == 3)
               {
                  _loc5_.push(_loc2_);
               }
               _loc4_++;
            }
            if(_loc3_.length > 0)
            {
               _loc2_ = _loc3_[_aiGameRandomizer.integer(_loc3_.length)];
               if(!_loc2_.getInUse(param1.avInvId))
               {
                  _loc2_.forceInUse(true);
                  param1.avatarData.accStateShowAccessory(_loc2_);
               }
            }
            if(_loc5_.length > 0)
            {
               _loc2_ = _loc5_[_aiGameRandomizer.integer(_loc5_.length)];
               if(!_loc2_.getInUse(param1.avInvId))
               {
                  _loc2_.forceInUse(true);
                  param1.avatarData.accStateShowAccessory(_loc2_);
               }
            }
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] == "ms")
         {
            _dbIDs = [];
            _loc2_ = 0;
            while(_loc2_ < _pIDs.length)
            {
               _dbIDs[_loc2_] = param1[_loc2_ + 1];
               _loc2_++;
            }
         }
         else if(param1[0] == "mm")
         {
         }
      }
      
      public function startGame() : void
      {
         hideDlg();
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc3_:* = null;
         var _loc4_:Boolean = false;
         _frameTime = (getTimer() - _lastTime) / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         _lastTime = getTimer();
         _gameTime += _frameTime;
         if(_sceneLoaded)
         {
            for each(_loc3_ in _soundTable)
            {
               if(_theGame.loader.content[_loc3_[1]] == true)
               {
                  _theGame.loader.content[_loc3_[1]] = false;
                  _soundMan.playByName(_loc3_[0]);
               }
            }
            sc_FFgemCounterLP = checkLoopingSfx(sc_FFgemCounterLP,ajm_FFgemCounterLP,"ajm_FFgemCounterLP");
            sc_FFTfryerBurnLP = checkLoopingSfx(sc_FFTfryerBurnLP,ajm_FFTfryerBurnLP,"ajm_FFTfryerBurnLP");
            sc_FFTfryerLP = checkLoopingSfx(sc_FFTfryerLP,ajm_FFTfryerLP,"ajm_FFTfryerLP");
            sc_FFTPopcornLP = checkLoopingSfx(sc_FFTPopcornLP,ajm_FFTPopcornLP,"ajm_FFTPopcornLP");
            if(_checkForLevelDone && _theGame.loader.content.levelDone)
            {
               showLevelResults();
            }
         }
         if(_levelResultsPopup)
         {
            _loc5_ = 1;
            while(_loc5_ <= 3)
            {
               _loc4_ = Boolean(_levelResultsPopup["ajm_FFUIpawStingerRS" + _loc5_]);
               if(_loc4_)
               {
                  _levelResultsPopup["ajm_FFUIpawStingerRS" + _loc5_] = false;
                  _soundMan.playByName("ajm_FFUIpawStingerRS" + _loc5_ + ".mp3");
               }
               _loc5_++;
            }
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
      }
      
      private function checkLoopingSfx(param1:SoundChannel, param2:Class, param3:String) : SoundChannel
      {
         if(param1 == null)
         {
            if(_theGame.loader.content[param3] == true)
            {
               return _soundMan.play(param2,0,99999);
            }
         }
         else if(_theGame.loader.content[param3] == false)
         {
            param1.stop();
            param1 = null;
         }
         return param1;
      }
      
      private function onStart_No() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_Yes() : void
      {
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
         if(_gameState == 2)
         {
            hideDlg();
            _theGame.loader.content.gameIsPaused = false;
         }
         else if(_gameState == 0)
         {
            _levelSelectPopup.exitPopupOff();
         }
         else
         {
            _stageSelectPopup.exitPopupOff();
         }
      }
   }
}

