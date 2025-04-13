package game.candyCatcher
{
   import achievement.AchievementXtCommManager;
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
   
   public class CandyCatcher extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MAX_TIMER_FRAME:int = 275;
      
      private static const MIN_TIMER_FRAME:int = 1;
      
      private static const GAME_TIME:int = 45;
      
      private static const SCORE_BASE:int = 10;
      
      private static const SCORE_INCREMENT:int = 10;
      
      private static const TRASH_APPEARS_MIN:int = 2;
      
      private static const TRASH_APPEARS_MAX:int = 4;
      
      private static const GOLD_APPEARS_MIN:int = 20;
      
      private static const GOLD_APPEARS_MAX:int = 20;
      
      private static const SPAWN_DELAY:Number = 0.3;
      
      private static const SPAWN_DECREMENT:Number = 0.01;
      
      private static const MIN_SPAWN_DELAY:Number = 0.15;
      
      private static const EDGE_MIN_X:int = 173;
      
      private static const EDGE_MAX_X:int = 723;
      
      private static const CANDY_EDGE_MIN_X:int = 228;
      
      private static const CANDY_EDGE_MAX_X:int = 668;
      
      public static var SFX_cc_candyGoldLP:Class;
      
      public static var SFX_aj_tickets:Class;
      
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
      
      public var _ticketsWon:int;
      
      public var _serialNumber1:int;
      
      public var _serialNumber2:int;
      
      public var _candy:Array;
      
      private var _scorePopups:Array;
      
      private var _scorePopupIndex:int;
      
      public var _gameTimer:Number;
      
      public var _candySpawnTimer:Number;
      
      public var _candySpawnDelay:Number;
      
      public var _nextTrash:int;
      
      public var _nextGold:int;
      
      public var _gameOver:Boolean;
      
      public var _missed:int;
      
      public var _score:int;
      
      public var _scoreCounter:int;
      
      public var _scoreMultiplier:int;
      
      public var _highScore:int;
      
      public var _debugSliders:Array;
      
      public var _DebugMinSpeeds:Array;
      
      public var _DebugMaxSpeeds:Array;
      
      public var _soundMan:SoundManager;
      
      public var _enterSounds:Array;
      
      public var _resultsDlg:MovieClip;
      
      public var _instructionsPopup:MovieClip;
      
      public var _showInstructions:Boolean;
      
      private const _sounds:Array = ["cc_GameOver.mp3","cc_TrashCaught.mp3","cc_candyCaught.mp3","cc_candyCaughtGold.mp3","cc_candyEnter1.mp3","cc_candyEnter2.mp3","cc_redFlash.mp3"];
      
      private var _soundNameGameOver:String = _sounds[0];
      
      private var _soundNameTrashCaught:String = _sounds[1];
      
      private var _soundNameCandyCaught:String = _sounds[2];
      
      private var _soundNameCandyCaughtGold:String = _sounds[3];
      
      private var _soundNameCandyEnter1:String = _sounds[4];
      
      private var _soundNameCandyEnter2:String = _sounds[5];
      
      private var _soundNameRedFlash:String = _sounds[6];
      
      private var _SFX_cc_candyGoldLP_Instance:SoundChannel;
      
      private var _SFX_aj_tickets_Instance:SoundChannel;
      
      public function CandyCatcher()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _enterSounds = new Array(_soundNameCandyEnter1,_soundNameCandyEnter2);
         _soundMan.addSoundByName(_audioByName[_soundNameGameOver],_soundNameGameOver,0.59);
         _soundMan.addSoundByName(_audioByName[_soundNameTrashCaught],_soundNameTrashCaught,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameCandyCaught],_soundNameCandyCaught,0.44);
         _soundMan.addSoundByName(_audioByName[_soundNameCandyCaughtGold],_soundNameCandyCaughtGold,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameCandyEnter1],_soundNameCandyEnter1,0.12);
         _soundMan.addSoundByName(_audioByName[_soundNameCandyEnter2],_soundNameCandyEnter2,0.13);
         _soundMan.addSoundByName(_audioByName[_soundNameRedFlash],_soundNameRedFlash,0.67);
         _soundMan.addSound(SFX_cc_candyGoldLP,0.55,"SFX_cc_candyGoldLP");
         _soundMan.addSound(SFX_aj_tickets,0.15,"SFX_aj_tickets");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_SFX_aj_tickets_Instance)
         {
            _soundMan.stop(_SFX_aj_tickets_Instance);
            _SFX_aj_tickets_Instance = null;
         }
         if(_SFX_cc_candyGoldLP_Instance)
         {
            _soundMan.stop(_SFX_cc_candyGoldLP_Instance);
            _SFX_cc_candyGoldLP_Instance = null;
         }
         resetGame();
         releaseBase();
         stage.removeEventListener("keyDown",onInstructionsKeyDown);
         stage.removeEventListener("keyDown",onCarnPlayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         var _loc1_:MovieClip = null;
         _gameOver = true;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            _candy = [];
            loadScene("CandyCatcher/room_main.xroom",_sounds);
            _bInit = true;
         }
         else if(_sceneLoaded)
         {
            _loc1_ = showDlg("carnival_play",[{
               "name":"button_yes",
               "f":onStart_Yes
            },{
               "name":"button_no",
               "f":onStart_No
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
            stage.addEventListener("keyDown",onCarnPlayKeyDown);
         }
      }
      
      private function onCarnPlayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onStart_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onStart_No();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:MovieClip = null;
         SFX_cc_candyGoldLP = getDefinitionByName("cc_candyGoldLP") as Class;
         if(SFX_cc_candyGoldLP == null)
         {
            throw new Error("Sound not found! name:cc_candyGoldLP");
         }
         SFX_aj_tickets = getDefinitionByName("aj_tickets") as Class;
         if(SFX_aj_tickets == null)
         {
            throw new Error("Sound not found! name:aj_tickets");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc5_ = _scene.getLayer("closeButton");
         _theGame = _scene.getLayer("theGame");
         _closeBtn = addBtn("CloseButton",_loc5_.x,_loc5_.y,onCloseButton);
         _layerMain.addChild(_theGame.loader);
         _sceneLoaded = true;
         _scorePopups = [];
         _loc4_ = 0;
         while(_loc4_ < 1)
         {
            _loc3_ = GETDEFINITIONBYNAME("candyCatch_scorePopup");
            _scorePopups.push(_loc3_);
            _loc3_.mouseEnabled = false;
            _loc3_.mouseChildren = false;
            _guiLayer.addChild(_loc3_);
            _loc4_++;
         }
         _scorePopupIndex = 0;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         _gameOver = true;
         _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(336),0);
         _theGame.loader.content.scoreText.text = "";
         _theGame.loader.content.highScoreText.text = _highScore.toString();
         _showInstructions = true;
         _loc3_ = showDlg("carnival_play",[{
            "name":"button_yes",
            "f":onStart_Yes
         },{
            "name":"button_no",
            "f":onStart_No
         }]);
         _loc3_.x = 450;
         _loc3_.y = 275;
         stage.addEventListener("keyDown",onCarnPlayKeyDown);
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         if(param1[0] == "ms")
         {
            _dbIDs = [];
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _dbIDs[_loc3_] = param1[_loc3_ + 1];
               _loc3_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "pz")
            {
               _serialNumber1 = (parseInt(param1[3]) + 7) / 3 - 5;
            }
            else if(param1[2] == "pg")
            {
               if(parseInt(param1[3]) == 1)
               {
                  _serialNumber2 = (parseInt(param1[4]) + 7) / 3 - 5;
                  if(_showInstructions)
                  {
                     _instructionsPopup = showDlg("carnival_candyInstructions",[{
                        "name":"x_btn",
                        "f":onInstructions
                     }]);
                     _instructionsPopup.x = 450;
                     _instructionsPopup.y = 275;
                     stage.addEventListener("keyDown",onInstructionsKeyDown);
                  }
                  else
                  {
                     startGame();
                  }
               }
               else
               {
                  _loc2_ = showDlg("carnival_lowGems",[{
                     "name":"exitButton",
                     "f":onStart_No
                  }]);
                  _loc2_.x = 450;
                  _loc2_.y = 275;
               }
            }
            else if(param1[2] == "gr")
            {
               _ticketsWon = parseInt(param1[3]);
               showResults();
            }
         }
      }
      
      private function onInstructionsKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onInstructions();
         }
      }
      
      private function showResults() : void
      {
         _resultsDlg = showDlg("carnival_results",[{
            "name":"button_yes",
            "f":onStart_Yes
         },{
            "name":"button_no",
            "f":onStart_No
         }]);
         _resultsDlg.ticketCounter.earnTickets(_ticketsWon);
         _resultsDlg.messageText.text = _ticketsWon;
         _resultsDlg.x = 450;
         _resultsDlg.y = 275;
         stage.addEventListener("keyDown",onCarnPlayKeyDown);
      }
      
      public function startGame() : void
      {
         resetGame();
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _theGame.loader.content.timer.flashingOff();
            _gameOver = false;
            _missed = 0;
            _nextTrash = 4;
            _nextGold = 20 + Math.random() * (20 - 20);
            _candySpawnTimer = 0.3 / 2;
            _candySpawnDelay = 0.3;
            _gameTimer = 45;
            _scoreCounter = 10;
            _scoreMultiplier = 1;
            _score = 0;
            _theGame.loader.content.scoreText.text = _score;
         }
      }
      
      public function resetGame() : void
      {
         while(_candy.length > 0)
         {
            _candy[0].destroy();
            _candy.splice(0,1);
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc7_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc12_:* = false;
         var _loc5_:Number = NaN;
         var _loc11_:int = 0;
         var _loc14_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc13_:int = 0;
         _frameTime = (getTimer() - _lastTime) / 1000;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         _lastTime = getTimer();
         _gameTime += _frameTime;
         if(_resultsDlg != null)
         {
            if(_resultsDlg.ticketCounter.ticketState == 0)
            {
               if(_SFX_aj_tickets_Instance)
               {
                  _soundMan.stop(_SFX_aj_tickets_Instance);
                  _SFX_aj_tickets_Instance = null;
               }
            }
            else if(_SFX_aj_tickets_Instance == null)
            {
               _SFX_aj_tickets_Instance = _soundMan.play(SFX_aj_tickets,0,99999);
            }
         }
         if(_sceneLoaded && _pauseGame == false && _instructionsPopup == null)
         {
            if(_gameOver == false)
            {
               _loc3_ = _theGame.loader.content.bucket.x + _theGame.loader.content.bucket.bucketCollision.x;
               _loc4_ = _theGame.loader.content.bucket.y + _theGame.loader.content.bucket.bucketCollision.y;
               _loc7_ = _candy.length - 1;
               while(_loc7_ >= 0)
               {
                  if(_candy[_loc7_].heartbeat(_frameTime))
                  {
                     if(_candy[_loc7_]._type == 2)
                     {
                        if(_SFX_cc_candyGoldLP_Instance)
                        {
                           _soundMan.stop(_SFX_cc_candyGoldLP_Instance);
                           _SFX_cc_candyGoldLP_Instance = null;
                        }
                     }
                     _candy[_loc7_].destroy();
                     _candy.splice(_loc7_,1);
                  }
                  else if(_candy[_loc7_]._candy.y >= _loc4_)
                  {
                     if(_candy[_loc7_]._candy.x > _loc3_ && _candy[_loc7_]._candy.x < _loc3_ + _theGame.loader.content.bucket.bucketCollision.width)
                     {
                        _theGame.loader.content.catchType(_candy[_loc7_]._type,_candy[_loc7_]._candy.whichColor);
                        switch(_candy[_loc7_]._type)
                        {
                           case 0:
                              _soundMan.playByName(_soundNameCandyCaught);
                              doScorePopup(_theGame.loader.content.bucket.x,_loc4_,_scoreCounter);
                              _score += _scoreCounter * _scoreMultiplier;
                              _scoreCounter += 10;
                              break;
                           case 2:
                              if(_SFX_cc_candyGoldLP_Instance)
                              {
                                 _soundMan.stop(_SFX_cc_candyGoldLP_Instance);
                                 _SFX_cc_candyGoldLP_Instance = null;
                              }
                              _soundMan.playByName(_soundNameCandyCaughtGold);
                              _scoreMultiplier++;
                              doScorePopup(_theGame.loader.content.bucket.x,_loc4_,_scoreCounter);
                              _score += _scoreCounter * _scoreMultiplier;
                              _scoreCounter += 10;
                              break;
                           case 1:
                              _soundMan.playByName(_soundNameTrashCaught);
                              _scoreMultiplier = 1;
                              _scoreCounter = 10;
                              _missed++;
                        }
                        _theGame.loader.content.scoreText.text = _score;
                        _candy[_loc7_].destroy();
                        _candy.splice(_loc7_,1);
                     }
                  }
                  _loc7_--;
               }
               _loc12_ = stage.mouseX < _theGame.loader.content.bucket.x;
               _theGame.loader.content.bucket.x = stage.mouseX;
               if(_theGame.loader.content.bucket.x < 173)
               {
                  _theGame.loader.content.bucket.x = 173;
               }
               else if(_theGame.loader.content.bucket.x > 723)
               {
                  _theGame.loader.content.bucket.x = 723;
               }
               _loc3_ = _theGame.loader.content.bucket.x + _theGame.loader.content.bucket.bucketCollision.x;
               _loc4_ = _theGame.loader.content.bucket.y + _theGame.loader.content.bucket.bucketCollision.y;
               _loc7_ = _candy.length - 1;
               while(_loc7_ >= 0)
               {
                  if(_candy[_loc7_]._candy.y >= _loc4_)
                  {
                     if(_candy[_loc7_]._candy.x > _loc3_ && _candy[_loc7_]._candy.x < _loc3_ + _theGame.loader.content.bucket.bucketCollision.width)
                     {
                        if(_loc12_)
                        {
                           _candy[_loc7_]._candy.x = _loc3_ - 1;
                        }
                        else
                        {
                           _candy[_loc7_]._candy.x = _loc3_ + _theGame.loader.content.bucket.bucketCollision.width + 1;
                        }
                     }
                  }
                  _loc7_--;
               }
               _loc5_ = _gameTimer;
               _gameTimer -= _frameTime;
               if(_gameTimer <= 10)
               {
                  if(_loc5_ > 10)
                  {
                     _theGame.loader.content.timer.flashingOn();
                  }
                  if(_theGame.loader.content.timer.flashRed == true)
                  {
                     _theGame.loader.content.timer.flashRed = false;
                     _soundMan.playByName(_soundNameRedFlash);
                  }
               }
               if(_gameTimer <= 0)
               {
                  if(_candy.length <= 0)
                  {
                     if(_SFX_cc_candyGoldLP_Instance)
                     {
                        _soundMan.stop(_SFX_cc_candyGoldLP_Instance);
                        _SFX_cc_candyGoldLP_Instance = null;
                     }
                     _theGame.loader.content.timer.flashingOff();
                     _theGame.loader.content.timer.timerMask.gotoAndStop(1);
                     _soundMan.playByName(_soundNameGameOver);
                     _gameOver = true;
                     if(_score > _highScore)
                     {
                        _highScore = _score;
                        AchievementXtCommManager.requestSetUserVar(336,_highScore);
                        _theGame.loader.content.highScoreText.text = _highScore.toString();
                     }
                     _loc2_ = [];
                     _loc11_ = (_score + 29) * 7 + (_serialNumber1 + 49) * 5;
                     _loc14_ = (_score + 49) * 3 + (_serialNumber2 + 83) * 5;
                     _loc6_ = (_serialNumber1 + _score) * 3 + _score * 3;
                     _loc2_[0] = "gr";
                     _loc2_[1] = _loc11_;
                     _loc2_[2] = _loc14_;
                     _loc2_[3] = _loc6_;
                     MinigameManager.msg(_loc2_);
                  }
               }
               else
               {
                  _loc9_ = (275 - 1) * ((45 - _gameTimer) / 45);
                  _theGame.loader.content.timer.timerMask.gotoAndStop(_loc9_);
                  _candySpawnTimer -= _frameTime;
                  if(_candySpawnTimer <= 0)
                  {
                     _nextTrash--;
                     _nextGold--;
                     if(_nextTrash <= 0 && _gameTimer <= 45 - 5)
                     {
                        _nextTrash = 2 + Math.random() * (4 - 2);
                        _loc8_ = 1;
                     }
                     else if(_nextGold <= 0)
                     {
                        _nextGold = 20 + Math.random() * (20 - 20);
                        _loc8_ = 2;
                        if(_SFX_cc_candyGoldLP_Instance == null)
                        {
                           _SFX_cc_candyGoldLP_Instance = _soundMan.play(SFX_cc_candyGoldLP,0,99999);
                        }
                     }
                     else
                     {
                        _loc8_ = 0;
                     }
                     _loc13_ = Math.random() * _enterSounds.length;
                     _soundMan.playByName(_enterSounds[_loc13_]);
                     _candy.push(new CandyCatchObject(_loc8_,228,668,_theGame.loader.content.candyContainer));
                     _candySpawnTimer = _candySpawnDelay;
                     _candySpawnDelay -= 0.01;
                     if(_candySpawnDelay < 0.15)
                     {
                        _candySpawnDelay = 0.15;
                     }
                  }
               }
            }
         }
      }
      
      private function doScorePopup(param1:Number, param2:Number, param3:int) : void
      {
         if(_scoreMultiplier > 1)
         {
            _scorePopups[_scorePopupIndex].combo.gotoAndStop("multi");
            _scorePopups[_scorePopupIndex].combo.comboMult.text = "x " + _scoreMultiplier.toString();
         }
         else
         {
            _scorePopups[_scorePopupIndex].combo.gotoAndStop("single");
         }
         _scorePopups[_scorePopupIndex].combo.comboNum.text = param3.toString();
         _scorePopups[_scorePopupIndex].x = param1;
         _scorePopups[_scorePopupIndex].y = param2;
         _scorePopups[_scorePopupIndex].gotoAndPlay("on");
         _scorePopupIndex++;
         if(_scorePopupIndex >= _scorePopups.length)
         {
            _scorePopupIndex = 0;
         }
      }
      
      public function onCloseButton() : void
      {
         var _loc1_:MovieClip = showDlg("carnival_leaveGame",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onStart_Yes() : void
      {
         stage.removeEventListener("keyDown",onCarnPlayKeyDown);
         _resultsDlg = null;
         if(_SFX_aj_tickets_Instance)
         {
            _soundMan.stop(_SFX_aj_tickets_Instance);
            _SFX_aj_tickets_Instance = null;
         }
         hideDlg();
         var _loc1_:Array = [];
         _loc1_[0] = "pg";
         MinigameManager.msg(_loc1_);
      }
      
      private function onStart_No() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function onInstructions() : void
      {
         stage.removeEventListener("keyDown",onInstructionsKeyDown);
         hideDlg();
         _instructionsPopup = null;
         _showInstructions = false;
         startGame();
      }
   }
}

