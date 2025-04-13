package game.dunkAPhantom
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
   
   public class DunkAPhantom extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
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
      
      private var _scorePopups:Array;
      
      private var _scorePopupIndex:int;
      
      public var _gameTimer:Number;
      
      public var _gameOver:Boolean;
      
      public var _score:int;
      
      public var _scoreCounter:int;
      
      public var _scoreMultiplier:int;
      
      public var _highScore:int;
      
      public var _soundMan:SoundManager;
      
      public var _resultsDlg:MovieClip;
      
      public var _instructionsPopup:MovieClip;
      
      public var _showInstructions:Boolean;
      
      private var _audio:Array = ["aj_phntmDunk.mp3","aj_phntmFallPlatform.mp3","aj_phntmGrunt.mp3","aj_slingshotStretch.mp3","aj_slingshotLaunch.mp3","aj_targetBreak.mp3","aj_targetImpact.mp3","aj_targetSpawn.mp3","ajj_timerCountDown.mp3","aj_phntmGoldFall.mp3","aj_phntmGoldDunk.mp3","aj_phantomLaugh.mp3","aj_dunkTick.mp3","aj_dunkRedTick.mp3","aj_dunkPhantomHit.mp3"];
      
      internal var _soundNamePhntmDunk:String = _audio[0];
      
      internal var _soundNamePhntmFallPlatform:String = _audio[1];
      
      internal var _soundNamePhntmGrunt:String = _audio[2];
      
      internal var _soundNameSlingshotStretch:String = _audio[3];
      
      internal var _soundNameSlingshotLaunch:String = _audio[4];
      
      internal var _soundNameTargetBreak:String = _audio[5];
      
      internal var _soundNameTargetImpact:String = _audio[6];
      
      internal var _soundNameTargetSpawn:String = _audio[7];
      
      internal var _soundNameTimerCountDown:String = _audio[8];
      
      internal var _soundNamePhntmGoldFall:String = _audio[9];
      
      internal var _soundNamePhntmGoldDunk:String = _audio[10];
      
      internal var _soundNamePhantomLaugh:String = _audio[11];
      
      internal var _soundNameDunkTick:String = _audio[12];
      
      internal var _soundNameDunkRedTick:String = _audio[13];
      
      internal var _soundNameDunkPhantomHit:String = _audio[14];
      
      private var _SFX_aj_tickets_Instance:SoundChannel;
      
      public function DunkAPhantom()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmDunk],_soundNamePhntmDunk,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmFallPlatform],_soundNamePhntmFallPlatform,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmGrunt],_soundNamePhntmGrunt,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameSlingshotStretch],_soundNameSlingshotStretch,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameSlingshotLaunch],_soundNameSlingshotLaunch,0.47);
         _soundMan.addSoundByName(_audioByName[_soundNameTargetBreak],_soundNameTargetBreak,0.57);
         _soundMan.addSoundByName(_audioByName[_soundNameTargetImpact],_soundNameTargetImpact,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameTargetSpawn],_soundNameTargetSpawn,0.78);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerCountDown],_soundNameTimerCountDown,0.3);
         _soundMan.addSound(SFX_aj_tickets,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmGoldFall],_soundNamePhntmGoldFall,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNamePhntmGoldDunk],_soundNamePhntmGoldDunk,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomLaugh],_soundNamePhantomLaugh,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameDunkTick],_soundNameDunkTick,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameDunkRedTick],_soundNameDunkRedTick,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameDunkPhantomHit],_soundNameDunkPhantomHit,0.48);
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
         resetGame();
         releaseBase();
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
            loadScene("DunkAPhantom/room_main.xroom",_audio);
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
         var _loc5_:Object = null;
         var _loc3_:MovieClip = null;
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
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         _gameOver = true;
         _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(380),0);
         _theGame.loader.content.highScoreText.text = _highScore.toString();
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
         hideDlg();
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
            _gameOver = false;
            _theGame.loader.content.playAgain();
            _scoreMultiplier = 1;
            _score = 0;
            _theGame.loader.content.scoreText.text = _score;
         }
      }
      
      public function resetGame() : void
      {
         _theGame.loader.content.gamePaused = false;
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
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
               if(_theGame.loader.content.timerCountDown)
               {
                  _theGame.loader.content.timerCountDown = false;
                  _soundMan.playByName(_soundNameTimerCountDown);
               }
               if(_theGame.loader.content.targetSpawn)
               {
                  _theGame.loader.content.targetSpawn = false;
                  _soundMan.playByName(_soundNameTargetSpawn);
               }
               if(_theGame.loader.content.phntmFallPlatform)
               {
                  _theGame.loader.content.phntmFallPlatform = false;
                  _soundMan.playByName(_soundNamePhntmFallPlatform);
               }
               if(_theGame.loader.content.phntmGrunt)
               {
                  _theGame.loader.content.phntmGrunt = false;
                  _soundMan.playByName(_soundNamePhntmGrunt);
               }
               if(_theGame.loader.content.phntmDunk)
               {
                  _theGame.loader.content.phntmDunk = false;
                  _soundMan.playByName(_soundNamePhntmDunk);
               }
               if(_theGame.loader.content.targetImpact)
               {
                  _theGame.loader.content.targetImpact = false;
                  _soundMan.playByName(_soundNameTargetImpact);
               }
               if(_theGame.loader.content.targetBreak)
               {
                  _theGame.loader.content.targetBreak = false;
                  _soundMan.playByName(_soundNameTargetBreak);
               }
               if(_theGame.loader.content.slingshotStretch)
               {
                  _theGame.loader.content.slingshotStretch = false;
                  _soundMan.playByName(_soundNameSlingshotStretch);
               }
               if(_theGame.loader.content.slingshotLaunch)
               {
                  _theGame.loader.content.slingshotLaunch = false;
                  _soundMan.playByName(_soundNameSlingshotLaunch);
               }
               if(_theGame.loader.content.phntmGoldFall)
               {
                  _theGame.loader.content.phntmGoldFall = false;
                  _soundMan.playByName(_soundNamePhntmGoldFall);
               }
               if(_theGame.loader.content.phntmGoldDunk)
               {
                  _theGame.loader.content.phntmGoldDunk = false;
                  _soundMan.playByName(_soundNamePhntmGoldDunk);
               }
               if(_theGame.loader.content.phantomLaugh)
               {
                  _theGame.loader.content.phantomLaugh = false;
                  _soundMan.playByName(_soundNamePhantomLaugh);
               }
               if(_theGame.loader.content.dunkTick)
               {
                  _theGame.loader.content.dunkTick = false;
                  _soundMan.playByName(_soundNameDunkTick);
               }
               if(_theGame.loader.content.dunkRedTick)
               {
                  _theGame.loader.content.dunkRedTick = false;
                  _soundMan.playByName(_soundNameDunkRedTick);
               }
               if(_theGame.loader.content.dunkPhantomHit)
               {
                  _theGame.loader.content.dunkPhantomHit = false;
                  _soundMan.playByName(_soundNameDunkPhantomHit);
               }
               if(_theGame.loader.content.roundOver)
               {
                  _score = _theGame.loader.content.score;
                  if(_score > _highScore)
                  {
                     _highScore = _score;
                     AchievementXtCommManager.requestSetUserVar(380,_highScore);
                     _theGame.loader.content.highScoreText.text = _highScore.toString();
                  }
                  _loc2_ = [];
                  _loc6_ = (_score + 29) * 7 + (_serialNumber1 + 49) * 5;
                  _loc7_ = (_score + 49) * 3 + (_serialNumber2 + 83) * 5;
                  _loc3_ = (_serialNumber1 + _score) * 3 + _score * 3;
                  _loc2_[0] = "gr";
                  _loc2_[1] = _loc6_;
                  _loc2_[2] = _loc7_;
                  _loc2_[3] = _loc3_;
                  MinigameManager.msg(_loc2_);
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
         _theGame.loader.content.gamePaused = true;
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
         _theGame.loader.content.gamePaused = false;
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

