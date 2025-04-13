package game.whackPhantom
{
   import achievement.AchievementXtCommManager;
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
   
   public class WhackPhantom extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MAX_TIMER_FRAME:int = 275;
      
      private static const MIN_TIMER_FRAME:int = 1;
      
      private static const GAME_TIME:Number = 45;
      
      private static const SCORE_BASE:int = 10;
      
      private static const SCORE_INCREMENT:int = 10;
      
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
      
      public var _resultsDlg:MovieClip;
      
      public var _instructionsPopup:MovieClip;
      
      public var _showInstructions:Boolean;
      
      public var _serialNumber1:int;
      
      public var _serialNumber2:int;
      
      public var _holes:Array;
      
      public var _whackData:WhackPhantomData;
      
      public var _gameProgression:Array;
      
      public var _progressionIndex:int;
      
      public var _progressionTimer:Number;
      
      public var _gameTimer:Number;
      
      public var _totalHit:int;
      
      public var _totalMissed:int;
      
      public var _score:int;
      
      public var _scoreCounter:int;
      
      public var _scoreMultiplier:int;
      
      public var _gameOver:Boolean;
      
      public var _ticketsWon:int;
      
      public var _highScore:int;
      
      private var _scorePopups:Array;
      
      private var _scorePopupIndex:int;
      
      public var _soundMan:SoundManager;
      
      public var _squishSounds:Array;
      
      public var _squishGoldSounds:Array;
      
      public var _enterGoldSounds:Array;
      
      public var _enterSounds:Array;
      
      public var _enterElecSounds:Array;
      
      private var _soundNameMalletHit:String = WhackPhantomData._audio[0];
      
      private var _soundNamePhantomEnterElec1:String = WhackPhantomData._audio[1];
      
      private var _soundNamePhantomEnterElec2:String = WhackPhantomData._audio[2];
      
      private var _soundNamePhantomEnterElec3:String = WhackPhantomData._audio[3];
      
      private var _soundNamePhantomEnter1:String = WhackPhantomData._audio[4];
      
      private var _soundNamePhantomEnter2:String = WhackPhantomData._audio[5];
      
      private var _soundNamePhantomEnter3:String = WhackPhantomData._audio[6];
      
      private var _soundNamePhantomSquish1:String = WhackPhantomData._audio[7];
      
      private var _soundNamePhantomSquish2:String = WhackPhantomData._audio[8];
      
      private var _soundNamePhantomSquish3:String = WhackPhantomData._audio[9];
      
      private var _soundNamePhantomSquish4:String = WhackPhantomData._audio[10];
      
      private var _soundNameTickFast:String = WhackPhantomData._audio[11];
      
      private var _soundNameTickSlow:String = WhackPhantomData._audio[12];
      
      private var _soundNameTickTimeUp:String = WhackPhantomData._audio[13];
      
      private var _soundNamePhantomEnterGold1:String = WhackPhantomData._audio[14];
      
      private var _soundNamePhantomEnterGold2:String = WhackPhantomData._audio[15];
      
      private var _soundNamePhantomSquishGold1:String = WhackPhantomData._audio[16];
      
      private var _soundNamePhantomSquishGold2:String = WhackPhantomData._audio[17];
      
      private var _soundNameMalletFlash:String = WhackPhantomData._audio[18];
      
      private var _soundNameRedFlash:String = WhackPhantomData._audio[19];
      
      private var _SFX_aj_tickets_Instance:SoundChannel;
      
      public function WhackPhantom()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _squishSounds = new Array(_soundNamePhantomSquish1,_soundNamePhantomSquish2,_soundNamePhantomSquish3,_soundNamePhantomSquish4);
         _enterGoldSounds = new Array(_soundNamePhantomEnterGold1,_soundNamePhantomEnterGold2);
         _squishGoldSounds = new Array(_soundNamePhantomSquishGold1,_soundNamePhantomSquishGold2);
         _enterSounds = new Array(_soundNamePhantomEnter1,_soundNamePhantomEnter2,_soundNamePhantomEnter3);
         _enterElecSounds = new Array(_soundNamePhantomEnterElec1,_soundNamePhantomEnterElec2,_soundNamePhantomEnterElec3);
         _soundMan.addSoundByName(_audioByName[_soundNameMalletHit],_soundNameMalletHit,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnterElec1],_soundNamePhantomEnterElec1,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnterElec2],_soundNamePhantomEnterElec2,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnterElec3],_soundNamePhantomEnterElec3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnter1],_soundNamePhantomEnter1,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnter2],_soundNamePhantomEnter2,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnter3],_soundNamePhantomEnter3,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquish1],_soundNamePhantomSquish1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquish2],_soundNamePhantomSquish2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquish3],_soundNamePhantomSquish3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquish4],_soundNamePhantomSquish4,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTickFast],_soundNameTickFast,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTickSlow],_soundNameTickSlow,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTickTimeUp],_soundNameTickTimeUp,1.65);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnterGold1],_soundNamePhantomEnterGold1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEnterGold2],_soundNamePhantomEnterGold2,0.73);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquishGold1],_soundNamePhantomSquishGold1,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomSquishGold2],_soundNamePhantomSquishGold2,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameMalletFlash],_soundNameMalletFlash,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRedFlash],_soundNameRedFlash,0.67);
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
         _theGame.loader.content.removeEventListener("mouseDown",mouseHandleDown);
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
            _whackData = new WhackPhantomData();
            _layerMain = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("WhackPhantom/room_main.xroom",WhackPhantomData._audio);
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
         while(_loc4_ < 3)
         {
            _loc3_ = GETDEFINITIONBYNAME("whack_scorePopup");
            _scorePopups.push(_loc3_);
            _loc3_.mouseEnabled = false;
            _loc3_.mouseChildren = false;
            _theGame.loader.content.scorePopupContainer.addChild(_loc3_);
            _loc4_++;
         }
         _scorePopupIndex = 0;
         _holes = new Array(new WhackPhantomObject(_theGame.loader.content.hole0),new WhackPhantomObject(_theGame.loader.content.hole1),new WhackPhantomObject(_theGame.loader.content.hole2),new WhackPhantomObject(_theGame.loader.content.hole3),new WhackPhantomObject(_theGame.loader.content.hole4),new WhackPhantomObject(_theGame.loader.content.hole5),new WhackPhantomObject(_theGame.loader.content.hole6),new WhackPhantomObject(_theGame.loader.content.hole7),new WhackPhantomObject(_theGame.loader.content.hole8),new WhackPhantomObject(_theGame.loader.content.hole9),new WhackPhantomObject(_theGame.loader.content.hole10),new WhackPhantomObject(_theGame.loader.content.hole11),new WhackPhantomObject(_theGame.loader.content.hole12),new WhackPhantomObject(_theGame.loader.content.hole13));
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         _theGame.loader.content.addEventListener("mouseDown",mouseHandleDown);
         _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(335),0);
         _theGame.loader.content.scoreText.text = "";
         _theGame.loader.content.highScoreText.text = _highScore.toString();
         _gameOver = true;
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
                     _instructionsPopup = showDlg("carnival_whackInstructions",[{
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
         var _loc1_:int = 0;
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
            _gameTimer = 45;
            _gameOver = false;
            _totalMissed = 0;
            _scoreCounter = 10;
            _scoreMultiplier = 1;
            _score = 0;
            _totalHit = 0;
            _theGame.loader.content.scoreText.text = _score;
            _loc1_ = 0;
            _loc1_ = Math.random() * _whackData._data.games.length;
            _gameProgression = _whackData._data.games[_loc1_];
            _progressionIndex = 0;
            _progressionTimer = _gameProgression[_progressionIndex++];
         }
      }
      
      public function resetGame() : void
      {
         var _loc1_:int = 0;
         if(_holes != null)
         {
            _loc1_ = 0;
            while(_loc1_ < _holes.length)
            {
               _holes[_loc1_].reset();
               _loc1_++;
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:Array = null;
         var _loc6_:int = 0;
         var _loc3_:Number = NaN;
         var _loc5_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
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
            _loc6_ = 0;
            while(_loc6_ < _holes.length)
            {
               if(_holes[_loc6_].heartbeat(_frameTime))
               {
                  _totalMissed++;
               }
               _loc6_++;
            }
            if(_gameOver == false)
            {
               _loc3_ = _gameTimer;
               _gameTimer -= _frameTime;
               if(_gameTimer <= 10)
               {
                  if(_loc3_ > 10)
                  {
                     _theGame.loader.content.timer.flashingOn();
                  }
                  if(_theGame.loader.content.timer.flashRed == true)
                  {
                     _theGame.loader.content.timer.flashRed = false;
                     _soundMan.playByName(_soundNameRedFlash);
                  }
               }
               if(_gameTimer <= 10)
               {
                  if(int(_loc3_ * 2) > int(_gameTimer * 2))
                  {
                     _soundMan.playByName(_soundNameTickFast);
                  }
               }
               else if(int(_loc3_) > int(_gameTimer))
               {
                  _soundMan.playByName(_soundNameTickSlow);
               }
               if(_gameTimer <= 0)
               {
                  _loc5_ = false;
                  _loc6_ = 0;
                  while(_loc6_ < _holes.length)
                  {
                     if(_holes[_loc6_].isActive())
                     {
                        _loc5_ = true;
                        break;
                     }
                     _loc6_++;
                  }
                  if(!_loc5_)
                  {
                     _theGame.loader.content.timer.flashingOff();
                     _theGame.loader.content.timer.timerMask.gotoAndStop(1);
                     _gameOver = true;
                     _soundMan.playByName(_soundNameTickTimeUp);
                     if(_score > _highScore)
                     {
                        _highScore = _score;
                        AchievementXtCommManager.requestSetUserVar(335,_highScore);
                        _theGame.loader.content.highScoreText.text = _highScore.toString();
                     }
                     _loc2_ = [];
                     _loc9_ = (_score + 29) * 7 + (_serialNumber1 + 49) * 5;
                     _loc10_ = (_score + 49) * 3 + (_serialNumber2 + 83) * 5;
                     _loc4_ = (_serialNumber1 + _score) * 3 + _score * 3;
                     _loc2_[0] = "gr";
                     _loc2_[1] = _loc9_;
                     _loc2_[2] = _loc10_;
                     _loc2_[3] = _loc4_;
                     MinigameManager.msg(_loc2_);
                     _loc6_ = 0;
                     while(_loc6_ < _holes.length)
                     {
                        _holes[_loc6_].reset();
                        _loc6_++;
                     }
                  }
               }
               else
               {
                  _loc7_ = (275 - 1) * ((45 - _gameTimer) / 45);
                  _theGame.loader.content.timer.timerMask.gotoAndStop(_loc7_);
                  _progressionTimer -= _frameTime;
                  if(_progressionTimer <= 0)
                  {
                     if(_progressionIndex < _gameProgression.length)
                     {
                        popTile(_whackData._data.tiles[_gameProgression[_progressionIndex++]]);
                        if(_progressionIndex < _gameProgression.length)
                        {
                           _progressionTimer = _gameProgression[_progressionIndex++];
                        }
                        else
                        {
                           _progressionTimer = 0;
                        }
                     }
                  }
               }
            }
            _theGame.loader.content.mallet.x = stage.mouseX;
            _theGame.loader.content.mallet.y = stage.mouseY;
         }
      }
      
      public function popTile(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = -1;
         while(_loc2_ < param1.length)
         {
            _loc3_ = int(param1[_loc2_++]);
            _loc6_ = int(param1[_loc2_++]);
            _holes[_loc3_].activate(_loc6_);
            if(_holes[_loc3_]._type > _loc4_)
            {
               _loc4_ = int(_holes[_loc3_]._type);
            }
         }
         switch(_loc4_)
         {
            case 0:
               _loc5_ = Math.random() * _enterSounds.length;
               _soundMan.playByName(_enterSounds[_loc5_]);
               break;
            case 1:
               _loc5_ = Math.random() * _enterElecSounds.length;
               _soundMan.playByName(_enterElecSounds[_loc5_]);
               break;
            case 2:
               _loc5_ = Math.random() * _enterGoldSounds.length;
               _soundMan.playByName(_enterGoldSounds[_loc5_]);
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
      
      private function mouseHandleDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:Boolean = false;
         if(_theGame != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _holes.length)
            {
               if(_holes[_loc3_].hit(param1))
               {
                  _loc2_ = false;
                  switch(_holes[_loc3_]._type)
                  {
                     case 2:
                        _loc4_ = Math.random() * _squishGoldSounds.length;
                        _soundMan.playByName(_squishGoldSounds[_loc4_]);
                        _scoreMultiplier++;
                        break;
                     case 1:
                        _loc2_ = true;
                        _theGame.loader.content.mallet.blinkRed();
                        _soundMan.playByName(_soundNameMalletFlash);
                        _scoreCounter = 10;
                        _scoreMultiplier = 1;
                        break;
                     default:
                        _loc4_ = Math.random() * _squishSounds.length;
                        _soundMan.playByName(_squishSounds[_loc4_]);
                  }
                  if(!_loc2_)
                  {
                     _totalHit++;
                     doScorePopup(_holes[_loc3_]._hole.x,_holes[_loc3_]._hole.y,_scoreCounter);
                     _score += _scoreCounter * _scoreMultiplier;
                     _scoreCounter += 10;
                     _theGame.loader.content.scoreText.text = _score;
                  }
               }
               _loc3_++;
            }
            _theGame.loader.content.mallet.mallet.gotoAndPlay("on");
            _soundMan.playByName(_soundNameMalletHit);
         }
      }
      
      private function doScorePopup(param1:Number, param2:Number, param3:int) : void
      {
         if(_scoreMultiplier > 1)
         {
            _scorePopups[_scorePopupIndex].combo.gotoAndStop("multi");
            _scorePopups[_scorePopupIndex].combo.comboNum.text = param3.toString() + " x " + _scoreMultiplier.toString();
         }
         else
         {
            _scorePopups[_scorePopupIndex].combo.gotoAndStop("single");
            _scorePopups[_scorePopupIndex].combo.comboNum.text = param3.toString();
         }
         _scorePopups[_scorePopupIndex].x = param1;
         _scorePopups[_scorePopupIndex].y = param2;
         _scorePopups[_scorePopupIndex].gotoAndPlay("on");
         _scorePopupIndex++;
         if(_scorePopupIndex >= _scorePopups.length)
         {
            _scorePopupIndex = 0;
         }
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

