package game.microMiraSays
{
   import achievement.AchievementManager;
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
   
   public class MicroMiraSays extends GameBase implements IMinigame
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
      
      public var _displayAchievementTimer:Number;
      
      public var _theGame:Object;
      
      public var _players:Array;
      
      public var _soundMan:SoundManager;
      
      public var _failed:Boolean;
      
      public var _score:int;
      
      public var _gemsEarnedInRound:int;
      
      public var _roundEnded:Boolean;
      
      public var _awards:Array;
      
      private var _audio:Array = ["mira_says_note1.mp3","mira_says_note2.mp3","mira_says_note3.mp3","mira_says_note4.mp3","mira_says_rollover.mp3","MG_pop_up.mp3","mira_says_flash_1_2.mp3","mira_says_flash_1_4.mp3","mira_says_flash_2_2.mp3","mira_says_flash_2_4.mp3","mira_says_flash_3_2.mp3","mira_says_flash_3_4.mp3","mira_says_flash_4_2.mp3","mira_says_flash_4_4.mp3","mira_says_Go_Whoosh.mp3","mira_says_star1.mp3","mira_says_star2.mp3","mira_says_star3.mp3","mira_says_star4.mp3","mira_says_wrong_button.mp3"];
      
      private var _soundNameButton1:String = _audio[0];
      
      private var _soundNameButton2:String = _audio[1];
      
      private var _soundNameButton3:String = _audio[2];
      
      private var _soundNameButton4:String = _audio[3];
      
      private var _soundNameRollover:String = _audio[4];
      
      private var _soundNamePopup:String = _audio[5];
      
      private var _soundNameFlash_1_2:String = _audio[6];
      
      private var _soundNameFlash_1_4:String = _audio[7];
      
      private var _soundNameFlash_2_2:String = _audio[8];
      
      private var _soundNameFlash_2_4:String = _audio[9];
      
      private var _soundNameFlash_3_2:String = _audio[10];
      
      private var _soundNameFlash_3_4:String = _audio[11];
      
      private var _soundNameFlash_4_2:String = _audio[12];
      
      private var _soundNameFlash_4_4:String = _audio[13];
      
      private var _soundNameGoWhoosh:String = _audio[14];
      
      private var _soundNameStar1:String = _audio[15];
      
      private var _soundNameStar2:String = _audio[16];
      
      private var _soundNameStar3:String = _audio[17];
      
      private var _soundNameStar4:String = _audio[18];
      
      private var _soundNameWrongButton:String = _audio[19];
      
      public function MicroMiraSays()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameButton1],_soundNameButton1,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameButton2],_soundNameButton2,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameButton3],_soundNameButton3,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameButton4],_soundNameButton4,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameRollover],_soundNameRollover,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNamePopup],_soundNamePopup,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_1_2],_soundNameFlash_1_2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_1_4],_soundNameFlash_1_4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_2_2],_soundNameFlash_2_2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_2_4],_soundNameFlash_2_4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_3_2],_soundNameFlash_3_2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_3_4],_soundNameFlash_3_4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_4_2],_soundNameFlash_4_2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFlash_4_4],_soundNameFlash_4_4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGoWhoosh],_soundNameGoWhoosh,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStar1],_soundNameStar1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStar2],_soundNameStar2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStar3],_soundNameStar3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameStar4],_soundNameStar4,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameWrongButton],_soundNameWrongButton,0.15);
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
         }
         releaseBase();
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         resetGame();
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         _score = 0;
         _gemsEarnedInRound = 0;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroMiraSays/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc4_ = _scene.getLayer("closeButton");
         _theGame = _scene.getLayer("theGame");
         _closeBtn = addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _layerMain.addChild(_theGame.loader);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         startGame();
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
         var _loc1_:int = 0;
         resetGame();
         _roundEnded = false;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _failed = false;
         _score = 0;
         _awards = [false,false,false,false,false];
         _gemsEarnedInRound = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _theGame.loader.content.goSound = false;
            _theGame.loader.content.button1Sound = false;
            _theGame.loader.content.button2Sound = false;
            _theGame.loader.content.button3Sound = false;
            _theGame.loader.content.button4Sound = false;
            _theGame.loader.content.rollover1Sound = false;
            _theGame.loader.content.rollover2Sound = false;
            _theGame.loader.content.rollover3Sound = false;
            _theGame.loader.content.rollover4Sound = false;
            _theGame.loader.content.instructionSound = false;
            _theGame.loader.content.failSound = false;
            _loc1_ = 1;
            while(_loc1_ < 5)
            {
               _theGame.loader.content.starSound[_loc1_] = false;
               _theGame.loader.content.successSound[_loc1_] = false;
               _theGame.loader.content.prizeSound[_loc1_] = false;
               _loc1_++;
            }
            _theGame.loader.content.setGemsEarned(_gemsEarnedInRound);
         }
      }
      
      public function resetGame() : void
      {
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:Array = null;
         var _loc5_:Array = null;
         var _loc8_:Array = null;
         var _loc4_:MovieClip = null;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
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
            if(_theGame.loader.content.failSound)
            {
               _theGame.loader.content.failSound = false;
               _soundMan.playByName(_soundNameWrongButton);
            }
            if(_failed == false)
            {
               if(!_roundEnded)
               {
                  if(_theGame.loader.content.gameState == "success")
                  {
                     _roundEnded = true;
                     _loc3_ = 0;
                     if(!_awards[0] && _theGame.loader.content.award1)
                     {
                        _awards[0] = true;
                        switch(_theGame.loader.content.prize1)
                        {
                           case 1:
                              _loc3_ += 5;
                              break;
                           case 2:
                              _loc3_ += 10;
                        }
                     }
                     if(!_awards[1] && _theGame.loader.content.award2)
                     {
                        _awards[1] = true;
                        switch(_theGame.loader.content.prize2)
                        {
                           case 1:
                              _loc3_ += 5;
                              break;
                           case 2:
                              _loc3_ += 10;
                        }
                     }
                     if(!_awards[2] && _theGame.loader.content.award3)
                     {
                        _awards[2] = true;
                        switch(_theGame.loader.content.prize3)
                        {
                           case 1:
                              _loc3_ += 5;
                              break;
                           case 2:
                              _loc3_ += 10;
                        }
                     }
                     if(!_awards[3] && _theGame.loader.content.award4)
                     {
                        _awards[3] = true;
                        switch(_theGame.loader.content.prize4)
                        {
                           case 1:
                              _loc3_ += 5;
                              break;
                           case 2:
                              _loc3_ += 10;
                        }
                     }
                     _score = (_theGame.loader.content.score - _score) / 2000;
                     _loc3_ += _score;
                     _score *= 2000;
                     if(_loc3_ > 0)
                     {
                        addGemsToBalance(_loc3_);
                        _gemsEarnedInRound += _loc3_;
                        _theGame.loader.content.setGemsEarned(_gemsEarnedInRound);
                     }
                  }
               }
               else if(_theGame.loader.content.gameState != "success")
               {
                  _roundEnded = false;
               }
               if(!_failed && _theGame.loader.content.gameState != "fail")
               {
                  if(_theGame.loader.content.button1Sound)
                  {
                     _theGame.loader.content.button1Sound = false;
                     _soundMan.playByName(_soundNameButton1);
                  }
                  if(_theGame.loader.content.button2Sound)
                  {
                     _theGame.loader.content.button2Sound = false;
                     _soundMan.playByName(_soundNameButton2);
                  }
                  if(_theGame.loader.content.button3Sound)
                  {
                     _theGame.loader.content.button3Sound = false;
                     _soundMan.playByName(_soundNameButton3);
                  }
                  if(_theGame.loader.content.button4Sound)
                  {
                     _theGame.loader.content.button4Sound = false;
                     _soundMan.playByName(_soundNameButton4);
                  }
                  if(_theGame.loader.content.rollover1Sound || _theGame.loader.content.rollover2Sound || _theGame.loader.content.rollover3Sound || _theGame.loader.content.rollover4Sound)
                  {
                     _soundMan.playByName(_soundNameRollover);
                     _theGame.loader.content.rollover1Sound = false;
                     _theGame.loader.content.rollover2Sound = false;
                     _theGame.loader.content.rollover3Sound = false;
                     _theGame.loader.content.rollover4Sound = false;
                  }
                  if(_theGame.loader.content.instructionSound)
                  {
                     _theGame.loader.content.instructionSound = false;
                     _soundMan.playByName(_soundNamePopup);
                  }
                  if(_theGame.loader.content.goSound)
                  {
                     _theGame.loader.content.goSound = false;
                     _soundMan.playByName(_soundNameGoWhoosh);
                  }
                  _loc7_ = [0,_soundNameFlash_1_2,_soundNameFlash_2_2,_soundNameFlash_3_2,_soundNameFlash_4_2];
                  _loc5_ = [0,_soundNameFlash_1_4,_soundNameFlash_2_4,_soundNameFlash_3_4,_soundNameFlash_4_4];
                  _loc8_ = [0,_soundNameStar1,_soundNameStar2,_soundNameStar3,_soundNameStar4];
                  _loc6_ = 1;
                  while(_loc6_ < 5)
                  {
                     if(_theGame.loader.content.successSound[_loc6_])
                     {
                        _theGame.loader.content.successSound[_loc6_] = false;
                        _soundMan.playByName(_loc7_[_loc6_]);
                     }
                     if(_theGame.loader.content.prizeSound[_loc6_])
                     {
                        _theGame.loader.content.prizeSound[_loc6_] = false;
                        _soundMan.playByName(_loc5_[_loc6_]);
                     }
                     if(_theGame.loader.content.starSound[_loc6_])
                     {
                        _theGame.loader.content.starSound[_loc6_] = false;
                        _soundMan.playByName(_loc8_[_loc6_]);
                     }
                     _loc6_++;
                  }
               }
               else if(!_pauseGame)
               {
                  _score = (_theGame.loader.content.score - _score) / 2000;
                  _loc3_ += _score;
                  _score *= 2000;
                  if(_loc3_ > 0)
                  {
                     addGemsToBalance(_loc3_);
                     _gemsEarnedInRound += _loc3_;
                     _theGame.loader.content.setGemsEarned(_gemsEarnedInRound);
                  }
                  _closeBtn.visible = false;
                  _failed = true;
                  stage.addEventListener("keyDown",replayKeyDown);
                  _loc4_ = showDlg("MS_Game_Over",[{
                     "name":"button_yes",
                     "f":onFail_Yes
                  },{
                     "name":"button_no",
                     "f":onFail_No
                  }]);
                  _loc4_.x = 450;
                  _loc4_.y = 275;
                  LocalizationManager.translateIdAndInsert(_loc4_.points,11550,_theGame.loader.content.score);
                  LocalizationManager.translateIdAndInsert(_loc4_.Gems_Earned,11432,_gemsEarnedInRound);
               }
               if(!_pauseGame && !_awards[4] && _theGame.loader.content.award5)
               {
                  _awards[4] = true;
                  if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
                     _theGame._displayAchievementTimer = 1;
                  }
                  _closeBtn.visible = false;
                  _failed = true;
                  stage.addEventListener("keyDown",replayKeyDown);
                  _loc4_ = showDlg("MS_Game_Over",[{
                     "name":"button_yes",
                     "f":onFail_Yes
                  },{
                     "name":"button_no",
                     "f":onFail_No
                  }]);
                  _loc4_.x = 450;
                  _loc4_.y = 275;
                  LocalizationManager.translateIdAndInsert(_loc4_.points,11550,_theGame.loader.content.score);
                  LocalizationManager.translateIdAndInsert(_loc4_.Gems_Earned,11432,_gemsEarnedInRound);
                  _roundEnded = false;
               }
            }
            _lastTime = getTimer();
            _gameTime += _frameTime;
         }
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onFail_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onFail_No();
         }
      }
      
      public function onCloseButton() : void
      {
         _theGame.loader.content.pauseGame();
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
      
      private function onExit_No() : void
      {
         _theGame.loader.content.unpauseGame();
         hideDlg();
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onFail_Yes() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         if(_theGame)
         {
            _theGame.loader.content.newRound();
            startGame();
         }
         hideDlg();
      }
      
      private function onFail_No() : void
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
   }
}

