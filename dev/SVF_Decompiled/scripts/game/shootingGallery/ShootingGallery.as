package game.shootingGallery
{
   import achievement.AchievementXtCommManager;
   import flash.display.DisplayObject;
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
   import localization.LocalizationManager;
   
   public class ShootingGallery extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const TYPE_DEFAULT:int = 0;
      
      public static const TYPE_PICKUP:int = 1;
      
      public static const TYPE_LETTER:int = 2;
      
      public static const TYPE_PHANTOM:int = 3;
      
      public static const TYPE_SPACE:int = 4;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_TUTORIAL:int = 2;
      
      public static const GAMESTATE_PRESTART:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_NEXTLEVEL:int = 5;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      public static var SFX_aj_tickets:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _timeOutTimer:Number;
      
      private var _currentPopup:MovieClip;
      
      private var _score:int;
      
      private var _scorePopups:Array = [];
      
      private var _scorePopupIndex:int;
      
      private var _countdownPopup:MovieClip;
      
      private var _tutorialPopup:MovieClip;
      
      private var _scoreMultiplier:int = 1;
      
      private var _numDarts:int;
      
      private var _ticketsWon:int;
      
      private var _gameOver:Boolean;
      
      public var _serialNumber1:int;
      
      public var _serialNumber2:int;
      
      private var _highScore:int;
      
      private var _bgContent:Object;
      
      private var _cannon:Object;
      
      private var _objectSpawnTimer:Number;
      
      private var _shootTimer:Number;
      
      private var _objects:Array = [];
      
      private var _objectPool:Array = [];
      
      private var _bullets:Array = [];
      
      private var _bulletPool:Array = [];
      
      private var _moveSpeed:Number = 300;
      
      private var _bulletInterval:Number = 0.35;
      
      private var _bulletSpeed:Number = 300;
      
      private var _objectSpeed:Number = 26;
      
      private var _objectInterval:Number = 1.4;
      
      private var _wheelPhantoms:int = 0;
      
      private var _currentLevel:int = 0;
      
      private var _currentSpawnIndex:int = 0;
      
      private var _currentLetterIndex:int = 0;
      
      private var _letters:Array = [1,2,3,4,5,6,7];
      
      private var _numLettersHit:int = 0;
      
      private var _gameOverTimer:Number;
      
      private var _nextLevelTimer:Number;
      
      private var _useSpaces:Boolean;
      
      private var _phantomsOnly:Boolean;
      
      private var _nextLetterTimer:Number;
      
      private var _nextAmmoTimer:Number;
      
      private var _hasShownTutorial:Boolean = false;
      
      public var _numAttackers:int = 0;
      
      private var _frameStepTime:Number;
      
      private var _levelData:Array = [{
         "darts":30,
         "objects":50,
         "pickups":5,
         "phantoms":15,
         "phantomwordbonus":10000,
         "wheelphantomincrement":1000,
         "spaces":35
      },{
         "darts":0,
         "objects":5,
         "pickups":0,
         "phantoms":4,
         "phantomwordbonus":1000,
         "wheelphantomincrement":100,
         "spaces":2
      }];
      
      private var _rightArrow:Boolean;
      
      private var _leftArrow:Boolean;
      
      private var _upArrow:Boolean;
      
      private var _space:Boolean;
      
      public var _soundMan:SoundManager;
      
      public var _resultsDlg:MovieClip;
      
      private const _audio:Array = ["stingerGold.mp3","sg_bowFire.mp3","sg_phantomDescends1.mp3","sg_phantomDescends2.mp3","sg_popEmpty.mp3","sg_popItem.mp3","sg_popLetter.mp3","sg_popPhantom.mp3","sg_stingerLetters.mp3","sg_stingerNextLevel.mp3","sg_boardImpact.mp3","sg_phantomEat.mp3","aj_PopUp_Go.mp3","aj_PopUp_ReadySet.mp3"];
      
      private var _soundNameStingerGold:String = _audio[0];
      
      private var _soundNameBowFire:String = _audio[1];
      
      internal var _soundNamePhantomDescends1:String = _audio[2];
      
      internal var _soundNamePhantomDescends2:String = _audio[3];
      
      private var _soundNamePopEmpty:String = _audio[4];
      
      private var _soundNamePopItem:String = _audio[5];
      
      private var _soundNamePopLetter:String = _audio[6];
      
      private var _soundNamePopPhantom:String = _audio[7];
      
      private var _soundNameStingerLetters:String = _audio[8];
      
      private var _soundNameStingerNextLevel:String = _audio[9];
      
      private var _soundNameBoardImpact:String = _audio[10];
      
      private var _soundNamePhantomEat:String = _audio[11];
      
      private var _soundNamePopUpGo:String = _audio[12];
      
      private var _soundNamePopUpReadySet:String = _audio[13];
      
      private var _SFX_aj_tickets_Instance:SoundChannel;
      
      private var _rollSound:SoundChannel;
      
      public function ShootingGallery()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameStingerGold],_soundNameStingerGold,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameBowFire],_soundNameBowFire,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDescends1],_soundNamePhantomDescends1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomDescends2],_soundNamePhantomDescends2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopEmpty],_soundNamePopEmpty,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopItem],_soundNamePopItem,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopLetter],_soundNamePopLetter,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopPhantom],_soundNamePopPhantom,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerLetters],_soundNameStingerLetters,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerNextLevel],_soundNameStingerNextLevel,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameBoardImpact],_soundNameBoardImpact,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomEat],_soundNamePhantomEat,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpGo],_soundNamePopUpGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpReadySet],_soundNamePopUpReadySet,0.27);
         _soundMan.addSound(SFX_aj_tickets,0.15,"SFX_aj_tickets");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         if(param1[0] == "ms")
         {
            _serverStarted = true;
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
                  resetScore();
                  if(_hasShownTutorial)
                  {
                     setGameState(3);
                  }
                  else
                  {
                     setGameState(2);
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
               showGameOver();
            }
         }
      }
      
      private function doGameOver() : void
      {
         setGameState(6);
         var _loc1_:Array = [];
         var _loc3_:int = (_score + 29) * 7 + (_serialNumber1 + 49) * 5;
         var _loc4_:int = (_score + 49) * 3 + (_serialNumber2 + 83) * 5;
         var _loc2_:int = (_serialNumber1 + _score) * 3 + _score * 3;
         _loc1_[0] = "gr";
         _loc1_[1] = _loc3_;
         _loc1_[2] = _loc4_;
         _loc1_[3] = _loc2_;
         MinigameManager.msg(_loc1_);
      }
      
      private function doNextLevel() : void
      {
         _currentLevel++;
         setGameState(5);
      }
      
      public function end(param1:Array) : void
      {
         if(_SFX_aj_tickets_Instance)
         {
            _soundMan.stop(_SFX_aj_tickets_Instance);
            _SFX_aj_tickets_Instance = null;
         }
         hideDlg();
         releaseBase();
         stage.removeEventListener("keyDown",onCarnPlayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",onKeyDown);
         stage.removeEventListener("keyUp",onKeyUp);
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _layerMain = null;
         _layerPopups = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         var _loc1_:MovieClip = null;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_layerPopups);
            addChild(_guiLayer);
            loadScene("ShootingGalleryAssets/room_main.xroom",_audio);
            _bInit = true;
         }
         else if(gMainFrame)
         {
            if(_sceneLoaded)
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
         else
         {
            setGameState(3);
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
         var _loc3_:MovieClip = null;
         SFX_aj_tickets = getDefinitionByName("aj_tickets") as Class;
         if(SFX_aj_tickets == null)
         {
            throw new Error("Sound not found! name:aj_tickets");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _bgContent = _scene.getLayer("bg").loader.content;
         _layerMain.addChild(_bgContent as DisplayObject);
         _cannon = _bgContent.cannon;
         _gameOverTimer = 0;
         _nextLevelTimer = 0;
         _scorePopupIndex = 0;
         _loc4_ = 0;
         while(_loc4_ < 1)
         {
            _scorePopups[_loc4_] = GETDEFINITIONBYNAME("shootingGallery_scorePopup");
            _layerPopups.addChild(_scorePopups[_loc4_]);
            _loc4_++;
         }
         _countdownPopup = GETDEFINITIONBYNAME("shootingGallery_countdown");
         _countdownPopup.x = 450;
         _countdownPopup.y = 275;
         _layerPopups.addChild(_countdownPopup);
         _tutorialPopup = GETDEFINITIONBYNAME("shootingGallery_controls");
         _tutorialPopup.x = 450;
         _tutorialPopup.y = 275;
         _layerPopups.addChild(_tutorialPopup);
         _tutorialPopup.visible = false;
         if(gMainFrame)
         {
            _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(348),0);
         }
         stage.addEventListener("enterFrame",heartbeat);
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("keyDown",onKeyDown);
         _sceneLoaded = true;
         super.sceneLoaded(param1);
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _shootTimer = 0;
         _bgContent.scoreText.text = "0";
         _bgContent.highScoreText.text = _highScore.toString();
         _gameOver = true;
         if(gMainFrame)
         {
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
         else
         {
            setGameState(3);
            _serverStarted = true;
         }
      }
      
      private function doChange(param1:Event) : void
      {
         param1.currentTarget.parent.s.value = parseInt(param1.currentTarget.parent.ALERTER.text);
         param1.currentTarget.parent.sliderValue = param1.currentTarget.parent.s.value;
         param1.currentTarget.parent.valueChanged = true;
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               _space = true;
               break;
            case 5:
               _leftArrow = true;
               break;
            case 6:
               _upArrow = true;
               break;
            case 7:
               _rightArrow = true;
         }
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               _space = false;
               break;
            case 5:
               _leftArrow = false;
               break;
            case 6:
               _upArrow = false;
               break;
            case 7:
               _rightArrow = false;
         }
      }
      
      private function showGameOver() : void
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
      
      private function showNextLevel() : void
      {
         _resultsDlg = showDlg("shootingGallery_nextLevel",[]);
         _resultsDlg.x = 450;
         _resultsDlg.y = 275;
         _resultsDlg.nextLevel();
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("carnival_leaveGame",[{
            "name":"button_yes",
            "f":onStart_No
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onExit_No() : void
      {
         hideDlg();
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
      
      private function getNextLetterTime() : void
      {
         if(_numLettersHit < 6)
         {
            _nextLetterTimer = 5 + Math.random() * 10;
         }
         else
         {
            _nextLetterTimer = 10 + Math.random() * 10;
         }
      }
      
      private function getNextAmmoTimer() : void
      {
         _nextAmmoTimer = 10 + Math.random() * 3;
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc3_:int = 0;
         if(_gameState != param1)
         {
            switch(param1 - 2)
            {
               case 0:
                  hideDlg();
                  _tutorialPopup.visible = true;
                  _objectSpawnTimer = 3;
                  _hasShownTutorial = true;
                  break;
               case 1:
                  hideDlg();
                  _cannon.gotoAndPlay("loaded");
                  _cannon.x = 450;
                  _gameOver = false;
                  clearLevel();
                  _levelData[0].pickups = 5;
                  _letters = [1,2,3,4,5,6,7];
                  randomizeArray(_letters);
                  _bgContent.ammoBelt.ammo(_numDarts - 1);
                  _bgContent.highScoreText.text = _highScore.toString();
                  LocalizationManager.translateIdAndInsert(_bgContent.levelLabelText,11548,_currentLevel + 1);
                  _scoreMultiplier = 1;
                  getNextLetterTime();
                  getNextAmmoTimer();
                  _frameStepTime = 0;
                  _countdownPopup.gotoAndPlay("on");
                  _objectSpawnTimer = _objectInterval;
                  _loc3_ = 0;
                  while(_loc3_ < 150)
                  {
                     forceHeartbeat();
                     _loc3_++;
                  }
                  break;
               case 3:
                  _soundMan.playByName(_soundNameStingerNextLevel);
                  showNextLevel();
                  break;
               case 4:
                  _gameOver = true;
                  if(_score > _highScore)
                  {
                     _highScore = _score;
                     AchievementXtCommManager.requestSetUserVar(348,_highScore);
                     break;
                  }
            }
            _gameState = param1;
         }
      }
      
      public function stealBullets() : void
      {
         _bgContent.ammoBelt.steal(Math.max(_numDarts - 1 - 5,0));
         _numDarts = Math.max(1,_numDarts - 5);
         _soundMan.playByName(_soundNamePhantomEat);
         _numAttackers--;
      }
      
      private function spawnObject(param1:int) : ShootingGalleryObject
      {
         var _loc2_:ShootingGalleryObject = getObject(param1);
         _loc2_._clone.y = -200;
         _loc2_._clone.x = -200;
         _bgContent.targetContainer.addChild(_loc2_._clone as DisplayObject);
         _objects.push(_loc2_);
         return _loc2_;
      }
      
      private function doScorePopup(param1:Number, param2:Number, param3:int) : void
      {
         var _loc4_:MovieClip = _scorePopups[_scorePopupIndex];
         _loc4_.x = param1;
         _loc4_.y = param2;
         _loc4_.turnOn(param3.toString());
         _scorePopupIndex = (_scorePopupIndex + 1) % _scorePopups.length;
      }
      
      private function shoot() : void
      {
         var _loc1_:Object = getBullet();
         _loc1_.x = _cannon.x;
         _loc1_.y = _cannon.y - 20;
         _bgContent.targetContainer.addChild(_loc1_ as DisplayObject);
         _bullets.push(_loc1_);
         _shootTimer = _bulletInterval;
         _numDarts--;
         _bgContent.ammoBelt.ammo(_numDarts - 1);
         _cannon.gotoAndPlay("fire");
         _soundMan.playByName(_soundNameBowFire);
      }
      
      private function getBullet() : Object
      {
         var _loc1_:Object = null;
         if(_bulletPool.length > 5)
         {
            _loc1_ = _bulletPool[0];
            _bulletPool.splice(0,1);
         }
         else
         {
            _loc1_ = GETDEFINITIONBYNAME("shootingGallery_bullet");
         }
         return _loc1_;
      }
      
      private function getObject(param1:int) : ShootingGalleryObject
      {
         var _loc2_:ShootingGalleryObject = null;
         if(_objectPool.length > 5)
         {
            _loc2_ = _objectPool[0];
            _objectPool.splice(0,1);
            _loc2_.reset();
         }
         else
         {
            _loc2_ = new ShootingGalleryObject(this);
            _loc2_.init(GETDEFINITIONBYNAME("shootingGallery_enemy"));
         }
         _loc2_._type = param1;
         if(_loc2_._type == 0)
         {
            _loc2_._clone.target.colorBalloon();
         }
         else if(_loc2_._type == 4)
         {
            _loc2_._clone.visible = false;
         }
         else if(_loc2_._type == 2)
         {
            if(_currentLetterIndex >= _letters.length)
            {
               _currentLetterIndex = 0;
            }
            _loc2_._letter = _letters[_currentLetterIndex++];
            _loc2_._clone.target.phantomBalloon(_loc2_._letter);
            if(_currentLetterIndex >= _letters.length)
            {
               _currentLetterIndex = 0;
            }
         }
         else if(_loc2_._type == 3)
         {
            _loc2_._clone.target.phantom();
         }
         else if(_loc2_._type == 1)
         {
            _loc2_._clone.target.dartBalloon(5);
         }
         return _loc2_;
      }
      
      private function resetScore() : void
      {
         _score = 0;
         _bgContent.scoreText.text = "0";
         _numDarts = _levelData[0].darts;
         _currentLevel = 0;
      }
      
      private function clearLevel() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         while(_objects.length > 0)
         {
            _loc2_ = _objects[0];
            _objectPool.push(_loc2_);
            _objects.splice(0,1);
         }
         _loc1_ = 0;
         while(_loc1_ < _objectPool.length)
         {
            _loc2_ = _objectPool[_loc1_];
            if(_loc2_._clone.parent)
            {
               _loc2_._clone.parent.removeChild(_loc2_._clone);
            }
            _loc1_++;
         }
         while(_bullets.length)
         {
            _loc2_ = _bullets[0];
            _bulletPool.push(_loc2_);
            _bullets.splice(0,1);
            if(_loc2_.parent)
            {
               _loc2_.parent.removeChild(_loc2_);
            }
         }
         _loc1_ = 1;
         while(_loc1_ <= 8)
         {
            _bgContent.phantomWheel["p" + _loc1_].respawn();
            _loc1_++;
         }
         _gameOverTimer = 0;
         _nextLevelTimer = 0;
         _numAttackers = 0;
         _bgContent.phantomBonus.reset();
         _currentSpawnIndex = _currentLetterIndex = _wheelPhantoms = _numLettersHit = 0;
      }
      
      private function randomizeArray(param1:Array) : Array
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
      
      private function anyActiveEnemiesRemaining() : Boolean
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _objects.length)
         {
            if(!(_phantomsOnly && _objects[_loc1_]._type != 3))
            {
               if(_objects[_loc1_]._clone.visible && _objects[_loc1_]._clone.target.active)
               {
                  return true;
               }
            }
            _loc1_++;
         }
         return false;
      }
      
      private function forceHeartbeat() : void
      {
         var _loc2_:int = 0;
         if(_objectSpawnTimer > 0)
         {
            _objectSpawnTimer -= 0.08333333333333333;
            if(_objectSpawnTimer <= 0)
            {
               spawnRowObjects();
            }
         }
         _loc2_ = 0;
         while(_loc2_ < _objects.length)
         {
            _objects[_loc2_].heartbeat(0.08333333333333333);
            _objects[_loc2_]._decisionTime = 100;
            _loc2_++;
         }
      }
      
      private function spawnRowObjects() : void
      {
         var _loc1_:Object = null;
         _nextLetterTimer += _objectSpawnTimer - _objectInterval;
         _nextAmmoTimer += _objectSpawnTimer - _objectInterval;
         _loc1_ = spawnObject(3);
         _loc1_._row = 0;
         _loc1_._clone.x = -25;
         _loc1_._clone.y = 131;
         _loc1_._speed = _objectSpeed * 4 * 0.8;
         _loc1_._clone.x -= _loc1_._speed * _objectSpawnTimer;
         _loc1_._clone.scaleX = _loc1_._clone.scaleY = 0.85;
         if(_nextLetterTimer <= 0 && _letters.length > 0)
         {
            _loc1_ = spawnObject(2);
            getNextLetterTime();
         }
         else if(_nextAmmoTimer <= 0 && _levelData[0].pickups > 0)
         {
            _levelData[0].pickups--;
            _loc1_ = spawnObject(1);
            getNextAmmoTimer();
         }
         else
         {
            _loc1_ = spawnObject(0);
         }
         _loc1_._row = 1;
         _loc1_._clone.x = 925;
         _loc1_._clone.y = 189;
         _loc1_._speed = -_objectSpeed * 4;
         _loc1_._clone.x += _loc1_._speed * _objectSpawnTimer;
         _loc1_._clone.scaleX = _loc1_._clone.scaleY = 0.95;
         _loc1_ = spawnObject(0);
         _loc1_._row = 2;
         _loc1_._clone.x = -25;
         _loc1_._clone.y = 263;
         _loc1_._speed = _objectSpeed * 4 * 1.2;
         _loc1_._clone.x -= _loc1_._speed * _objectSpawnTimer;
         _loc1_._clone.scaleX = _loc1_._clone.scaleY = 1;
         _objectSpawnTimer += _objectInterval;
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         var _loc3_:Boolean = false;
         var _loc7_:int = 0;
         if(_sceneLoaded)
         {
            if(_serverStarted)
            {
               _frameTime = (getTimer() - _lastTime) / 1000;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
               _gameTime += _frameTime;
               if(_resultsDlg != null && _gameState != 5)
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
               if(_gameState == 4 && !_gameOver)
               {
                  if(_numDarts <= 0 && _gameOverTimer <= 0)
                  {
                     _gameOverTimer = 3;
                  }
                  if(_nextLevelTimer > 0)
                  {
                     _nextLevelTimer -= _frameTime;
                     if(_nextLevelTimer <= 0)
                     {
                        doNextLevel();
                     }
                  }
                  if(_gameOverTimer > 0)
                  {
                     _gameOverTimer -= _frameTime;
                     if(_gameOverTimer <= 0)
                     {
                        doGameOver();
                     }
                  }
                  if(_leftArrow)
                  {
                     _cannon.x -= _frameTime * _moveSpeed;
                     if(_cannon.x < 60)
                     {
                        _cannon.x = 60;
                     }
                  }
                  if(_rightArrow)
                  {
                     _cannon.x += _frameTime * _moveSpeed;
                     if(_cannon.x > 840)
                     {
                        _cannon.x = 840;
                     }
                  }
                  if(_objectSpawnTimer > 0)
                  {
                     _objectSpawnTimer -= _frameTime;
                     if(_objectSpawnTimer <= 0)
                     {
                        spawnRowObjects();
                     }
                  }
                  _loc5_ = 0;
                  while(_loc5_ < _objects.length)
                  {
                     _objects[_loc5_].heartbeat(_frameTime);
                     if(_objects[_loc5_]._row == 1 && _objects[_loc5_]._clone.x < -50 || _objects[_loc5_]._row != 1 && _objects[_loc5_]._clone.x > 950)
                     {
                        if(_objects[_loc5_]._type == 1)
                        {
                           _levelData[0].pickups++;
                        }
                        _objectPool.push(_objects[_loc5_]);
                        _objects[_loc5_]._clone.parent.removeChild(_objects[_loc5_]._clone);
                        _objects.splice(_loc5_--,1);
                     }
                     _loc5_++;
                  }
                  if(_shootTimer <= 0 && _numDarts > 0 && _gameOverTimer == 0 && _nextLevelTimer == 0)
                  {
                     _cannon.gotoAndPlay("loaded");
                     if(_upArrow || _space)
                     {
                        shoot();
                     }
                  }
                  else
                  {
                     _shootTimer -= _frameTime;
                  }
                  _loc5_ = 0;
                  while(_loc5_ < _bullets.length)
                  {
                     _bullets[_loc5_].y -= _bulletSpeed * _frameTime;
                     if(_bullets[_loc5_].y < -20)
                     {
                        _bullets[_loc5_].parent.removeChild(_bullets[_loc5_]);
                        _bulletPool.push(_bullets[_loc5_]);
                        _bullets.splice(_loc5_--,1);
                        _scoreMultiplier = 1;
                     }
                     else
                     {
                        _loc3_ = false;
                        _loc6_ = 0;
                        while(_loc6_ < _objects.length)
                        {
                           if(_objects[_loc6_]._clone.target.active && _objects[_loc6_]._clone.visible)
                           {
                              if(_objects[_loc6_]._clone.target.hitTestPoint(_bullets[_loc5_].x,_bullets[_loc5_].y - 13,true))
                              {
                                 _bullets[_loc5_].parent.removeChild(_bullets[_loc5_]);
                                 _bulletPool.push(_bullets[_loc5_]);
                                 _objectPool.push(_objects[_loc6_]);
                                 _objects[_loc6_]._clone.target.popBalloon();
                                 if(_objects[_loc6_]._row == 0)
                                 {
                                    doScorePopup(_objects[_loc6_]._clone.x,_bullets[_loc5_].y - 13,500);
                                    _score += 500;
                                    if(_objects[_loc6_]._isAttacking)
                                    {
                                       _numAttackers--;
                                    }
                                 }
                                 else if(_objects[_loc6_]._row == 1)
                                 {
                                    if(_objects[_loc6_]._type == 2)
                                    {
                                       _loc7_ = 1000 * (_numLettersHit + 1);
                                       doScorePopup(_objects[_loc6_]._clone.x,_objects[_loc6_]._clone.y,_loc7_);
                                       _score += _loc7_;
                                    }
                                    else
                                    {
                                       doScorePopup(_objects[_loc6_]._clone.x,_objects[_loc6_]._clone.y,200);
                                       _score += 200;
                                    }
                                 }
                                 else
                                 {
                                    doScorePopup(_objects[_loc6_]._clone.x,_objects[_loc6_]._clone.y,100);
                                    _score += 100;
                                 }
                                 if(_objects[_loc6_]._type == 3)
                                 {
                                    _soundMan.playByName(_soundNamePopPhantom);
                                 }
                                 else if(_objects[_loc6_]._type == 2)
                                 {
                                    _numLettersHit++;
                                    _bgContent.phantomBonus.getLetter(_objects[_loc6_]._letter);
                                    _letters.splice(_letters.indexOf(_objects[_loc6_]._letter),1);
                                    if(_numLettersHit == 7)
                                    {
                                       _bgContent.phantomBonus.allLetters();
                                       _loc7_ = _levelData[0].phantomwordbonus + _levelData[1].phantomwordbonus * _currentLevel;
                                       doScorePopup(_bgContent.phantomBonus.x,_bgContent.phantomBonus.y,_loc7_);
                                       _score += _loc7_;
                                       _soundMan.playByName(_soundNameStingerLetters);
                                    }
                                    _soundMan.playByName(_soundNamePopLetter);
                                 }
                                 else if(_objects[_loc6_]._type == 1)
                                 {
                                    _numDarts += 5;
                                    _bgContent.ammoBelt.ammo(_numDarts - 1);
                                    _gameOverTimer = 0;
                                    _soundMan.playByName(_soundNamePopItem);
                                 }
                                 else
                                 {
                                    _soundMan.playByName(_soundNamePopEmpty);
                                 }
                                 _bgContent.scoreText.text = _score.toString();
                                 _scoreMultiplier++;
                                 _bullets.splice(_loc5_--,1);
                                 _objects.splice(_loc6_--,1);
                                 _loc3_ = true;
                                 break;
                              }
                           }
                           _loc6_++;
                        }
                        if(!_loc3_)
                        {
                           if(_bullets[_loc5_].hitTestObject(_bgContent.phantomShield))
                           {
                              _bullets[_loc5_].parent.removeChild(_bullets[_loc5_]);
                              _bulletPool.push(_bullets[_loc5_]);
                              _bullets.splice(_loc5_--,1);
                              _loc3_ = true;
                              _scoreMultiplier = 1;
                              _soundMan.playByName(_soundNameBoardImpact);
                           }
                        }
                        if(!_loc3_)
                        {
                           _loc7_ = 0;
                           _loc6_ = 1;
                           while(_loc6_ <= 8)
                           {
                              if(_bgContent.phantomWheel["p" + _loc6_].active && _bullets[_loc5_].hitTestObject(_bgContent.phantomWheel["p" + _loc6_]))
                              {
                                 _bullets[_loc5_].parent.removeChild(_bullets[_loc5_]);
                                 _bulletPool.push(_bullets[_loc5_]);
                                 _bullets.splice(_loc5_--,1);
                                 _bgContent.phantomWheel["p" + _loc6_].die();
                                 _bgContent.phantomWheel["p" + _loc6_].active = false;
                                 _wheelPhantoms++;
                                 _loc7_ = 1000;
                                 doScorePopup(_bgContent.phantomWheel["p" + _loc6_].x + _bgContent.phantomWheel.x,_bgContent.phantomWheel["p" + _loc6_].y + _bgContent.phantomWheel.y,_loc7_);
                                 _score += _loc7_;
                                 _bgContent.scoreText.text = _score.toString();
                                 _loc3_ = true;
                                 _soundMan.playByName(_soundNamePopPhantom);
                                 break;
                              }
                              _loc6_++;
                           }
                        }
                     }
                     _loc5_++;
                  }
               }
               else if(_gameState == 5)
               {
                  if(_resultsDlg.active == false)
                  {
                     _resultsDlg = null;
                     setGameState(3);
                  }
               }
               else if(_gameState == 3)
               {
                  if(_countdownPopup.playSound)
                  {
                     _countdownPopup.playSound = false;
                     _soundMan.playByName(_soundNamePopUpReadySet);
                  }
                  if(_countdownPopup.playGo)
                  {
                     _countdownPopup.playGo = false;
                     _soundMan.playByName(_soundNamePopUpGo);
                  }
                  if(!_countdownPopup.active)
                  {
                     setGameState(4);
                  }
               }
               else if(_gameState == 2)
               {
                  _objectSpawnTimer -= _frameTime;
                  if(_objectSpawnTimer <= 0)
                  {
                     _tutorialPopup.parent.removeChild(_tutorialPopup);
                     setGameState(3);
                  }
               }
               else if(_gameState == 6)
               {
               }
            }
         }
      }
   }
}

