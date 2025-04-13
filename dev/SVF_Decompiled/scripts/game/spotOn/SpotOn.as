package game.spotOn
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class SpotOn extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
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
      
      public var _gameOver:Boolean;
      
      private var uv_array_CategoriesLocked:int;
      
      private var uv_categoriesCompleted:int;
      
      private var array_CategoriesLocked:Array = [1,1,1,1,1,0];
      
      private var array_CategoryStarsEarned:Array = [0,0,0,0,0,0];
      
      private var correctAnswersPerCategory_Array:Array = [0,0,0,0,0,0];
      
      private var bool_categoriesCompleted:Boolean;
      
      private var answerRightInARow:int;
      
      public var _score:int;
      
      public var _soundMan:SoundManager;
      
      private var _SFX_Music:SBMusic;
      
      private var _musicSC:SoundChannel;
      
      private var _soundTable:Array;
      
      private const _audio:Array = ["aj_soBonusCoins.mp3","aj_soButtonRollover.mp3","aj_soButtonSelect.mp3","aj_soCoinBlue.mp3","aj_soCoinGreen.mp3","aj_soCoinPink.mp3","aj_soCoinPurple.mp3","aj_soCoinYellow.mp3","aj_soGemCountDown.mp3","aj_soGemVanish.mp3","aj_soGoodJob.mp3","aj_soRedTick.mp3","aj_soStarPopUp.mp3","aj_soStat1.mp3","aj_soStat2.mp3","aj_soStat3.mp3","aj_soTimeUp.mp3","aj_soWompWomp.mp3"];
      
      private var _soundNameBonusCoins:String = _audio[0];
      
      private var _soundNameButtonRollover:String = _audio[1];
      
      private var _soundNameButtonSelect:String = _audio[2];
      
      private var _soundNameCoinBlue:String = _audio[3];
      
      private var _soundNameCoinGreen:String = _audio[4];
      
      private var _soundNameCoinPink:String = _audio[5];
      
      private var _soundNameCoinPurple:String = _audio[6];
      
      private var _soundNameCoinYellow:String = _audio[7];
      
      private var _soundNameGemCountDown:String = _audio[8];
      
      private var _soundNameGemVanish:String = _audio[9];
      
      private var _soundNameGoodJob:String = _audio[10];
      
      private var _soundNameRedTick:String = _audio[11];
      
      private var _soundNameStarPopUp:String = _audio[12];
      
      private var _soundNameStat1:String = _audio[13];
      
      private var _soundNameStat2:String = _audio[14];
      
      private var _soundNameStat3:String = _audio[15];
      
      private var _soundNameTimeUp:String = _audio[16];
      
      private var _soundNameWompWomp:String = _audio[17];
      
      public var SFX_soTimerLP:Class;
      
      public var _SFX_soTimerLP_Instance:SoundChannel;
      
      public function SpotOn()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_musSpotOn",0.13);
         _soundMan.addSoundByName(_audioByName[_soundNameBonusCoins],_soundNameBonusCoins,0.59);
         _soundMan.addSoundByName(_audioByName[_soundNameButtonRollover],_soundNameButtonRollover,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameButtonSelect],_soundNameButtonSelect,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameCoinBlue],_soundNameCoinBlue,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCoinGreen],_soundNameCoinGreen,0.27);
         _soundMan.addSoundByName(_audioByName[_soundNameCoinPink],_soundNameCoinPink,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCoinPurple],_soundNameCoinPurple,0.37);
         _soundMan.addSoundByName(_audioByName[_soundNameCoinYellow],_soundNameCoinYellow,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGemCountDown],_soundNameGemCountDown,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameGemVanish],_soundNameGemVanish,0.27);
         _soundMan.addSoundByName(_audioByName[_soundNameGoodJob],_soundNameGoodJob,0.92);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTick],_soundNameRedTick,0.54);
         _soundMan.addSoundByName(_audioByName[_soundNameStarPopUp],_soundNameStarPopUp,1.74);
         _soundMan.addSoundByName(_audioByName[_soundNameStat1],_soundNameStat1,0.59);
         _soundMan.addSoundByName(_audioByName[_soundNameStat2],_soundNameStat2,0.83);
         _soundMan.addSoundByName(_audioByName[_soundNameStat3],_soundNameStat3,1.1);
         _soundMan.addSoundByName(_audioByName[_soundNameTimeUp],_soundNameTimeUp,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameWompWomp],_soundNameWompWomp,0.38);
         _soundMan.addSound(SFX_soTimerLP,0.3,"SFX_soTimerLP");
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
         _layerMain = null;
         _guiLayer = null;
         if(_musicSC)
         {
            _musicSC.stop();
            _musicSC = null;
         }
         if(_SFX_soTimerLP_Instance)
         {
            _SFX_soTimerLP_Instance.stop();
            _SFX_soTimerLP_Instance = null;
         }
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _gameOver = false;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("SpotOn/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function onCloseButton() : void
      {
         var _loc1_:MovieClip = showDlg("SpotOn_ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _theGame.loader.content.gameIsPaused = true;
         _theGame.loader.content.pausingWithTheTimer(true);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11577,_theGame.loader.content.gemsWonThisSession);
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc6_:Object = null;
         SFX_soTimerLP = getDefinitionByName("aj_soTimerLP") as Class;
         if(SFX_soTimerLP == null)
         {
            throw new Error("Sound not found! name:aj_soTimerLP");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicSC = _soundMan.playStream(_SFX_Music,0,999999);
         _loc6_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",_loc6_.x,_loc6_.y,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _theGame.loader.content.ajExit = onExit_Yes;
         _theGame.loader.content.awardGems = addGemsToBalance;
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         _gameOver = false;
         uv_array_CategoriesLocked = gMainFrame.userInfo.userVarCache.getUserVarValueById(382);
         uv_categoriesCompleted = gMainFrame.userInfo.userVarCache.getUserVarValueById(384);
         var _loc5_:int = 389;
         _loc4_ = 0;
         while(_loc4_ < array_CategoryStarsEarned.length)
         {
            array_CategoryStarsEarned[_loc4_] = Math.max(0,gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc5_++));
            _loc4_++;
         }
         cloneArray(array_CategoryStarsEarned,_theGame.loader.content.array_CategoryStarsEarned);
         _loc5_ = 395;
         _loc4_ = 0;
         while(_loc4_ < correctAnswersPerCategory_Array.length)
         {
            correctAnswersPerCategory_Array[_loc4_] = Math.max(0,gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc5_++));
            _loc4_++;
         }
         cloneArray(correctAnswersPerCategory_Array,_theGame.loader.content.correctAnswersPerCategory_Array);
         if(uv_array_CategoriesLocked != -1)
         {
            setArrayFromBits(uv_array_CategoriesLocked,array_CategoriesLocked);
            setArrayFromBits(uv_array_CategoriesLocked,_theGame.loader.content.array_CategoriesLocked);
         }
         if(uv_categoriesCompleted == 1)
         {
            _theGame.loader.content.bool_categoriesCompleted = true;
            bool_categoriesCompleted = true;
         }
         _soundTable = [];
         _soundTable.push([_soundNameBonusCoins,"bonusCoinsSound"]);
         _soundTable.push([_soundNameButtonRollover,"buttonRollOverSound"]);
         _soundTable.push([_soundNameButtonSelect,"buttonSelectSound"]);
         _soundTable.push([_soundNameCoinBlue,"blueCoinSound"]);
         _soundTable.push([_soundNameCoinGreen,"greenCoinSound"]);
         _soundTable.push([_soundNameCoinPink,"pinkCoinSound"]);
         _soundTable.push([_soundNameCoinPurple,"purpleCoinSound"]);
         _soundTable.push([_soundNameCoinYellow,"yellowCoinSound"]);
         _soundTable.push([_soundNameGemCountDown,"gemCountDownSound"]);
         _soundTable.push([_soundNameGemVanish,"gemVanishSound"]);
         _soundTable.push([_soundNameGoodJob,"goodJobSound"]);
         _soundTable.push([_soundNameRedTick,"redTimerSound"]);
         _soundTable.push([_soundNameStarPopUp,"starPopUpSound"]);
         _soundTable.push([_soundNameStat1,"star1Sound"]);
         _soundTable.push([_soundNameStat2,"star2Sound"]);
         _soundTable.push([_soundNameStat3,"star3Sound"]);
         _soundTable.push([_soundNameTimeUp,"timeUpSound"]);
         _soundTable.push([_soundNameWompWomp,"wompWompSound"]);
      }
      
      private function setArrayFromBits(param1:int, param2:Array) : void
      {
         param2[0] = param1 >> 5;
         param2[1] = param1 >> 4 & 1;
         param2[2] = param1 >> 3 & 1;
         param2[3] = param1 >> 2 & 1;
         param2[4] = param1 >> 1 & 1;
         param2[5] = param1 & 1;
      }
      
      private function setBitfieldFromArray(param1:Array) : int
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         _loc2_ |= param1[0];
         _loc3_ = 1;
         while(_loc3_ < param1.length)
         {
            _loc2_ <<= 1;
            _loc2_ |= param1[_loc3_];
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function cloneArray(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            param2[_loc3_] = param1[_loc3_];
            _loc3_++;
         }
      }
      
      private function arraysDiffer(param1:Array, param2:Array) : int
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_] != param2[_loc3_])
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
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
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null;
         _frameTime = (getTimer() - _lastTime) / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         _lastTime = getTimer();
         _gameTime += _frameTime;
         if(_sceneLoaded && _pauseGame == false)
         {
            if(_gameOver == false)
            {
               if(arraysDiffer(array_CategoriesLocked,_theGame.loader.content.array_CategoriesLocked) >= 0)
               {
                  cloneArray(_theGame.loader.content.array_CategoriesLocked,array_CategoriesLocked);
                  uv_array_CategoriesLocked = setBitfieldFromArray(array_CategoriesLocked);
                  AchievementXtCommManager.requestSetUserVar(382,uv_array_CategoriesLocked);
               }
               _loc3_ = arraysDiffer(array_CategoryStarsEarned,_theGame.loader.content.array_CategoryStarsEarned);
               if(_loc3_ >= 0)
               {
                  cloneArray(_theGame.loader.content.array_CategoryStarsEarned,array_CategoryStarsEarned);
                  AchievementXtCommManager.requestSetUserVar(389 + _loc3_,array_CategoryStarsEarned[_loc3_]);
               }
               _loc3_ = arraysDiffer(correctAnswersPerCategory_Array,_theGame.loader.content.correctAnswersPerCategory_Array);
               if(_loc3_ >= 0)
               {
                  cloneArray(_theGame.loader.content.correctAnswersPerCategory_Array,correctAnswersPerCategory_Array);
                  AchievementXtCommManager.requestSetUserVar(395 + _loc3_,correctAnswersPerCategory_Array[_loc3_]);
               }
               if(_theGame.loader.content.answerCorrect)
               {
                  AchievementXtCommManager.requestSetUserVar(387,1);
                  _theGame.loader.content.answerCorrect = false;
               }
               if(answerRightInARow != _theGame.loader.content.answerRightInARow)
               {
                  answerRightInARow = _theGame.loader.content.answerRightInARow;
                  AchievementXtCommManager.requestSetUserVar(388,answerRightInARow);
               }
               if(!bool_categoriesCompleted && _theGame.loader.content.bool_categoriesCompleted)
               {
                  bool_categoriesCompleted = true;
                  AchievementXtCommManager.requestSetUserVar(384,1);
               }
               if(_theGame.loader.content.completeFirstRound)
               {
                  _theGame.loader.content.completeFirstRound = false;
                  AchievementXtCommManager.requestSetUserVar(386,1);
               }
               for each(_loc4_ in _soundTable)
               {
                  if(_theGame.loader.content[_loc4_[1]] == true)
                  {
                     _theGame.loader.content[_loc4_[1]] = false;
                     _soundMan.playByName(_loc4_[0]);
                  }
               }
               if(_theGame.loader.content.gradualRevealLoopSound == true && _SFX_soTimerLP_Instance == null)
               {
                  _SFX_soTimerLP_Instance = _soundMan.play(SFX_soTimerLP,0,999999);
               }
               if(_theGame.loader.content.gradualRevealLoopSound == false && _SFX_soTimerLP_Instance != null)
               {
                  _SFX_soTimerLP_Instance.stop();
                  _SFX_soTimerLP_Instance = null;
               }
            }
         }
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
         hideDlg();
         _theGame.loader.content.gameIsPaused = false;
         _theGame.loader.content.pausingWithTheTimer(false);
      }
   }
}

