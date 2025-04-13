package game.microPuppy
{
   import achievement.AchievementXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class MicroPuppy extends GameBase implements IMinigame
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
      
      public var _pet:Object;
      
      public var _goldFrisbees:int;
      
      public var _gemsAwarded:int;
      
      private var _audio:Array = ["pup_frisbee1.mp3","pup_frisbee2.mp3","pup_frisbee3.mp3","pup_frisbeeCollision1.mp3","pup_frisbeeCollision2.mp3","pup_frisbeeCollision3.mp3","pup_growlJump.mp3","pup_growlMiss.mp3","pup_pointCounter.mp3","pup_stingerCatch.mp3","pup_stingerGold.mp3","pup_stingerMiss.mp3","pup_paw1.mp3","pup_paw2.mp3","pup_paw3.mp3","pup_paw4.mp3","popup_Go.mp3","popup_Ready.mp3"];
      
      private var _soundNameFrisbee1:String = _audio[0];
      
      private var _soundNameFrisbee2:String = _audio[1];
      
      private var _soundNameFrisbee3:String = _audio[2];
      
      private var _soundNameFrisbeeCollision1:String = _audio[3];
      
      private var _soundNameFrisbeeCollision2:String = _audio[4];
      
      private var _soundNameFrisbeeCollision3:String = _audio[5];
      
      private var _soundNameGrowlJump:String = _audio[6];
      
      private var _soundNameGrowlMiss:String = _audio[7];
      
      private var _soundNamePointCounter:String = _audio[8];
      
      private var _soundNameStingerCatch:String = _audio[9];
      
      private var _soundNameStingerGold:String = _audio[10];
      
      private var _soundNameStingerMiss:String = _audio[11];
      
      private var _soundNamePaw1:String = _audio[12];
      
      private var _soundNamePaw2:String = _audio[13];
      
      private var _soundNamePaw3:String = _audio[14];
      
      private var _soundNamePaw4:String = _audio[15];
      
      private var _soundNamePopupGo:String = _audio[16];
      
      private var _soundNamePopupReady:String = _audio[17];
      
      public var _soundMan:SoundManager;
      
      public function MicroPuppy()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbee1],_soundNameFrisbee1,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbee2],_soundNameFrisbee2,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbee3],_soundNameFrisbee3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbeeCollision1],_soundNameFrisbeeCollision1,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbeeCollision2],_soundNameFrisbeeCollision2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrisbeeCollision3],_soundNameFrisbeeCollision3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowlJump],_soundNameGrowlJump,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameGrowlMiss],_soundNameGrowlMiss,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNamePointCounter],_soundNamePointCounter,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerCatch],_soundNameStingerCatch,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerGold],_soundNameStingerGold,0.72);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerMiss],_soundNameStingerMiss,0.72);
         _soundMan.addSoundByName(_audioByName[_soundNamePaw1],_soundNamePaw1,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePaw2],_soundNamePaw2,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePaw3],_soundNamePaw3,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePaw4],_soundNamePaw4,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupGo],_soundNamePopupGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupReady],_soundNamePopupReady,0.2);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         AchievementXtCommManager.requestSetUserVar(313,_theGame.loader.content.catches);
         AchievementXtCommManager.requestSetUserVar(314,_theGame.loader.content.catches);
         var _loc2_:* = _pet.getUBits() >> 16 & 0x0F;
         if(_loc2_ == 2)
         {
            AchievementXtCommManager.requestSetUserVar(315,1);
         }
         addGemsToBalance(_theGame.loader.content.gemsEarned - _gemsAwarded);
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",_theGame.loader.content.fl_KeyboardDownHandler);
         stage.removeEventListener("keyUp",_theGame.loader.content.fl_KeyboardUpHandler);
         releaseBase();
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
            loadScene("MicroPuppy/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",749,58,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _goldFrisbees = 0;
         _gemsAwarded = 0;
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",_theGame.loader.content.fl_KeyboardDownHandler);
         stage.addEventListener("keyUp",_theGame.loader.content.fl_KeyboardUpHandler);
         startGame();
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] != "ml")
         {
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
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
            if(_pauseGame == false)
            {
               if(_theGame && _theGame.loader && _theGame.loader.content)
               {
                  if(_theGame.loader.content.frisbee1Sound)
                  {
                     _theGame.loader.content.frisbee1Sound = false;
                     _soundMan.playByName(_soundNameFrisbee1);
                  }
                  if(_theGame.loader.content.frisbee2Sound)
                  {
                     _theGame.loader.content.frisbee2Sound = false;
                     _soundMan.playByName(_soundNameFrisbee2);
                  }
                  if(_theGame.loader.content.frisbee3Sound)
                  {
                     _theGame.loader.content.frisbee3Sound = false;
                     _soundMan.playByName(_soundNameFrisbee3);
                  }
                  if(_theGame.loader.content.frisbeeCollision1Sound)
                  {
                     _theGame.loader.content.frisbeeCollision1Sound = false;
                     _soundMan.playByName(_soundNameFrisbeeCollision1);
                  }
                  if(_theGame.loader.content.frisbeeCollision2Sound)
                  {
                     _theGame.loader.content.frisbeeCollision2Sound = false;
                     _soundMan.playByName(_soundNameFrisbeeCollision2);
                  }
                  if(_theGame.loader.content.frisbeeCollision3Sound)
                  {
                     _theGame.loader.content.frisbeeCollision3Sound = false;
                     _soundMan.playByName(_soundNameFrisbeeCollision3);
                  }
                  if(_theGame.loader.content.growlJumpSound)
                  {
                     _theGame.loader.content.growlJumpSound = false;
                     _soundMan.playByName(_soundNameGrowlJump);
                  }
                  if(_theGame.loader.content.growlMissSound)
                  {
                     _theGame.loader.content.growlMissSound = false;
                     _soundMan.playByName(_soundNameGrowlMiss);
                  }
                  if(_theGame.loader.content.pointCounterSound)
                  {
                     _theGame.loader.content.pointCounterSound = false;
                     _soundMan.playByName(_soundNamePointCounter);
                  }
                  if(_theGame.loader.content.stingerCatchSound)
                  {
                     _theGame.loader.content.stingerCatchSound = false;
                     _soundMan.playByName(_soundNameStingerCatch);
                     if(_theGame.loader.content.gemsEarned - _gemsAwarded >= 300)
                     {
                        addGemsToBalance(300);
                        _gemsAwarded += 300;
                     }
                  }
                  if(_theGame.loader.content.stingerGoldSound)
                  {
                     _theGame.loader.content.stingerGoldSound = false;
                     _soundMan.playByName(_soundNameStingerGold);
                     _goldFrisbees++;
                     addToPetMastery(1);
                  }
                  if(_theGame.loader.content.stingerMissSound)
                  {
                     _theGame.loader.content.stingerMissSound = false;
                     _soundMan.playByName(_soundNameStingerMiss);
                  }
                  if(_theGame.loader.content.paw1Sound)
                  {
                     _theGame.loader.content.paw1Sound = false;
                     _soundMan.playByName(_soundNamePaw1);
                  }
                  if(_theGame.loader.content.paw2Sound)
                  {
                     _theGame.loader.content.paw2Sound = false;
                     _soundMan.playByName(_soundNamePaw2);
                  }
                  if(_theGame.loader.content.paw3Sound)
                  {
                     _theGame.loader.content.paw3Sound = false;
                     _soundMan.playByName(_soundNamePaw3);
                  }
                  if(_theGame.loader.content.paw4Sound)
                  {
                     _theGame.loader.content.paw4Sound = false;
                     _soundMan.playByName(_soundNamePaw4);
                  }
                  if(_theGame.loader.content.goSound)
                  {
                     _theGame.loader.content.goSound = false;
                     _soundMan.playByName(_soundNamePopupGo);
                  }
                  if(_theGame.loader.content.readySound)
                  {
                     _theGame.loader.content.readySound = false;
                     _soundMan.playByName(_soundNamePopupReady);
                  }
                  if(_theGame.loader.content.endGame)
                  {
                     showGameOver();
                  }
               }
            }
         }
      }
      
      public function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         _theGame.loader.content.gamePaused = true;
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
               onExit();
         }
      }
      
      public function showGameOver() : void
      {
         var _loc1_:MovieClip = showDlg("puppyGame_gameOver",[{
            "name":"button_yes",
            "f":onRetry
         },{
            "name":"button_no",
            "f":onExit
         }]);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,_theGame.loader.content.gemsEarned == 1 ? 11619 : 11554,_theGame.loader.content.gemsEarned);
         if(_goldFrisbees > 0)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.goldenDiscs,_goldFrisbees == 1 ? 11623 : 11622,_goldFrisbees);
         }
         else
         {
            _loc1_.goldenDiscs.text = "";
         }
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",gameOverKeyDown);
      }
      
      private function onExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         _theGame.loader.content.gamePaused = false;
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         AchievementXtCommManager.requestSetUserVar(313,_theGame.loader.content.catches);
         AchievementXtCommManager.requestSetUserVar(314,_theGame.loader.content.catches);
         _goldFrisbees = 0;
         addGemsToBalance(_theGame.loader.content.gemsEarned - _gemsAwarded);
         _gemsAwarded = 0;
         _theGame.loader.content.newRound();
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _pet = MinigameManager.getActivePet(petLoaded);
            _theGame.loader.content.puppyName.text = MinigameManager.getActivePetName();
         }
      }
      
      public function petLoaded(param1:MovieClip) : void
      {
         _theGame.loader.content.setUpPet(_pet);
         _pet.getChildAt(0).pet.setAnim(0);
      }
      
      public function onCloseButton() : void
      {
         showExitConfirmationDlg();
      }
   }
}

