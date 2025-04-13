package game.microSnake
{
   import achievement.AchievementXtCommManager;
   import flash.display.DisplayObject;
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
   
   public class MicroSnake extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _layerGame:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _pet:Object;
      
      public var _petContainer:Object;
      
      public var _gems:int;
      
      public var _goldCollection:int;
      
      public var _points:int;
      
      public var _lives:int;
      
      public var _difficultyRampFactor:Number = 150;
      
      public var _readyGo:Boolean;
      
      public var _snakeSpeed:int = 5;
      
      public var _mice:Array;
      
      public var _micePool:Array;
      
      public var _useKeyboard:Boolean;
      
      public var _rightArrow:Boolean;
      
      public var _leftArrow:Boolean;
      
      public var _upArrow:Boolean;
      
      public var _downArrow:Boolean;
      
      public var _currentVelX:Number;
      
      public var _currentVelY:Number;
      
      public var _constantMotion:Boolean;
      
      public var _gameOverTimer:Number;
      
      public var _snakeParts:Array;
      
      public var _snakeBody:Sprite;
      
      public var _numMiceCreated:int;
      
      private var _audio:Array = ["popup_Go.mp3","popup_Ready.mp3","aj_snakeTel.mp3","aj_snakeTurn1.mp3","aj_snakeTurn2.mp3","aj_hamsterEat.mp3","aj_hamsterGoldEat.mp3","aj_snakeDeath.mp3"];
      
      private var _soundNamePopupGo:String = _audio[0];
      
      private var _soundNamePopupReady:String = _audio[1];
      
      private var _soundNameSnakeTel:String = _audio[2];
      
      private var _soundNameSnakeTurn1:String = _audio[3];
      
      private var _soundNameSnakeTurn2:String = _audio[4];
      
      private var _soundNameHamsterEat:String = _audio[5];
      
      private var _soundNameHamsterGoldEat:String = _audio[6];
      
      private var _soundNameSnakeDeath:String = _audio[7];
      
      public var _soundMan:SoundManager;
      
      public function MicroSnake()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNamePopupGo],_soundNamePopupGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupReady],_soundNamePopupReady,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeTel],_soundNameSnakeTel,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeTurn1],_soundNameSnakeTurn1,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeTurn2],_soundNameSnakeTurn2,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHamsterEat],_soundNameHamsterEat,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameHamsterGoldEat],_soundNameHamsterGoldEat,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameSnakeDeath],_soundNameSnakeDeath,0.3);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
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
         var _loc1_:MovieClip = showDlg("snakeGame_gameOver",[{
            "name":"button_yes",
            "f":onRetry
         },{
            "name":"button_no",
            "f":onExit
         }]);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,_gems == 1 ? 11619 : 11554,_gems);
         if(_goldCollection > 0)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.goldenDuckies,_goldCollection == 1 ? 11618 : 11617,_goldCollection);
         }
         else
         {
            _loc1_.goldenDuckies.text = "";
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
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",gameOverKeyDown);
         hideDlg();
         AchievementXtCommManager.requestSetUserVar(321,_points);
         AchievementXtCommManager.requestSetUserVar(322,_points);
         AchievementXtCommManager.requestSetUserVar(323,_goldCollection);
         _goldCollection = 0;
         addGemsToBalance(_gems);
         _gems = 0;
         _points = 0;
         _theGame.loader.content.gems.gemsText.text = "0";
         _theGame.loader.content.points.text = "0";
         _gameTime = 0;
         _readyGo = true;
         _theGame.loader.content.readyGo.gotoAndPlay("on");
         _theGame.loader.content.startMovement = false;
         _numMiceCreated = 0;
         _rightArrow = false;
         _leftArrow = false;
         _upArrow = false;
         _downArrow = false;
         _theGame.loader.content.controls.visible = true;
         _theGame.loader.content.readyGo.visible = true;
         while(_mice.length)
         {
            _mice[0].parent.removeChild(_mice[0]);
            _micePool.push(_mice[0]);
            _mice.splice(0,1);
         }
         addMouse();
         destroySnake();
         createSnake();
      }
      
      public function end(param1:Array) : void
      {
         AchievementXtCommManager.requestSetUserVar(321,_points);
         AchievementXtCommManager.requestSetUserVar(322,_points);
         AchievementXtCommManager.requestSetUserVar(323,_goldCollection);
         addGemsToBalance(_gems);
         releaseBase();
         stage.removeEventListener("keyDown",gameOverKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyboardHandler);
         stage.removeEventListener("keyUp",keyboardReleased);
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
            loadScene("MicroSnake/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      private function addMouse() : void
      {
         var _loc1_:Object = null;
         if(_micePool.length > 1)
         {
            _loc1_ = _micePool[0];
            _micePool.splice(0,1);
         }
         else
         {
            _loc1_ = GETDEFINITIONBYNAME("snakeGame_mouse");
         }
         _loc1_.scaleY = 0.38;
         _loc1_.scaleX = 0.38;
         _layerGame.addChild(_loc1_ as DisplayObject);
         do
         {
            _loc1_.x = Math.random() * 640 + 30;
            _loc1_.y = Math.random() * 365 + 30;
         }
         while(_loc1_.hitTestObject(_layerGame["deadZone1"]) || _loc1_.hitTestObject(_layerGame["deadZone2"]) || _loc1_.hitTestObject(_layerGame["deadZone3"]) || _loc1_.hitTestObject(_layerGame["deadZone4"]));
         
         _mice.push(_loc1_);
         _numMiceCreated++;
         _soundMan.playByName(_soundNameSnakeTel);
         if(_numMiceCreated % 20 == 1 && _numMiceCreated > 1)
         {
            _loc1_.gotoAndPlay("gold");
         }
         else
         {
            _loc1_.gotoAndPlay("white");
         }
         if(_numMiceCreated % 15 == 1 && _numMiceCreated / 15 < 5 && _numMiceCreated > 1)
         {
            addMouse();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",749,58,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _layerGame = _theGame.loader.content.snakeGameAll;
         _theGame.loader.content.gems.gemsText.text = "0";
         _theGame.loader.content.points.text = "0";
         _lives = 3;
         _gameOverTimer = 0;
         _snakeParts = [];
         _snakeBody = new Sprite();
         _mice = [];
         _micePool = [];
         addMouse();
         _useKeyboard = true;
         _constantMotion = true;
         _layerGame.addChild(_snakeBody);
         _pet = MinigameManager.getActivePet(petLoaded);
         _theGame.loader.content.petName.text = MinigameManager.getActivePetName();
         createSnake();
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",keyboardHandler);
         stage.addEventListener("keyUp",keyboardReleased);
         startGame();
         super.sceneLoaded(param1);
      }
      
      private function destroySnake() : void
      {
         while(_snakeParts.length)
         {
            _snakeParts[0].mc.parent.removeChild(_snakeParts[0].mc);
            _snakeParts.splice(0,1);
         }
      }
      
      private function createSnake() : void
      {
         var _loc1_:Object = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            if(_loc2_ == 0)
            {
               _loc1_ = GETDEFINITIONBYNAME("snake_head");
               _loc1_.init();
               _loc1_.setState(_pet.getLBits(),_pet.getUBits());
               _layerGame.addChild(_loc1_ as DisplayObject);
            }
            else if(_loc2_ < 5)
            {
               _loc1_ = GETDEFINITIONBYNAME("snake_part");
               _loc1_.init();
               _loc1_.setState(_pet.getLBits(),_pet.getUBits());
               _snakeBody.addChild(_loc1_ as DisplayObject);
            }
            else
            {
               _loc1_ = GETDEFINITIONBYNAME("snake_tail");
               _loc1_.init();
               _loc1_.setState(_pet.getLBits(),_pet.getUBits());
               _snakeBody.addChild(_loc1_ as DisplayObject);
            }
            _snakeParts.push({
               "x":-15 * _loc2_ + 250,
               "y":210,
               "mc":_loc1_
            });
            _loc2_++;
         }
         taperTail();
         updateSnakeBody(0);
      }
      
      private function extend(param1:int) : void
      {
         var _loc2_:Object = _snakeParts[param1];
         var _loc4_:Object = _snakeParts[param1 + 1];
         var _loc7_:Object = GETDEFINITIONBYNAME("snake_part");
         _snakeBody.addChildAt(_loc7_ as DisplayObject,_snakeBody.getChildIndex(_loc4_.mc) + 1);
         _loc7_.init();
         _loc7_.setState(_pet.getLBits(),_pet.getUBits());
         var _loc6_:Object = {
            "x":_loc2_.x,
            "y":_loc2_.y,
            "mc":_loc7_
         };
         _snakeParts.splice(param1 + 1,0,_loc6_);
         var _loc3_:Number = (_loc2_.x - _loc4_.x) * 0.5;
         var _loc5_:Number = (_loc2_.y - _loc4_.y) * 0.5;
         _loc2_.x += _loc3_;
         _loc2_.y += _loc5_;
         updateSnakeBody(param1);
         _loc2_.x -= _loc3_;
         _loc2_.y -= _loc5_;
         updateSnakeBody(param1);
      }
      
      private function taperTail() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _snakeParts.length - 4)
         {
            _snakeParts[_loc1_].mc.scaleY = 1;
            _loc1_++;
         }
         _snakeParts[_snakeParts.length - 4].mc.scaleY = 0.8;
         _snakeParts[_snakeParts.length - 3].mc.scaleY = 0.6;
         _snakeParts[_snakeParts.length - 2].mc.scaleY = 0.4;
         _snakeParts[_snakeParts.length - 1].mc.scaleY = 0.2;
      }
      
      private function updateSnakeBody(param1:int) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:* = 0;
         _loc8_ = param1;
         while(_loc8_ < _snakeParts.length - 1)
         {
            _loc2_ = _snakeParts[_loc8_];
            _loc3_ = _snakeParts[_loc8_ + 1];
            _loc5_ = _loc3_.x - _loc2_.x;
            _loc4_ = _loc3_.y - _loc2_.y;
            _loc7_ = Math.atan2(_loc4_,_loc5_) * 180 / 3.141592653589793;
            _loc6_ = Math.sqrt(_loc5_ * _loc5_ + _loc4_ * _loc4_);
            _loc3_.x += (15 - _loc6_) * _loc5_ / _loc6_;
            _loc3_.y += (15 - _loc6_) * _loc4_ / _loc6_;
            _loc2_.mc.x = _loc2_.x;
            _loc2_.mc.y = _loc2_.y;
            _loc2_.mc.rotation = _loc7_;
            _loc8_++;
         }
      }
      
      private function mouseMove() : void
      {
         var _loc1_:Number = mouseX - 100 - _snakeParts[0].x;
         var _loc3_:Number = mouseY - 60 - _snakeParts[0].y;
         var _loc2_:Number = Math.sqrt(_loc1_ * _loc1_ + _loc3_ * _loc3_);
         if(_loc2_ > _snakeSpeed)
         {
            _loc2_ = _snakeSpeed / _loc2_;
            _snakeParts[0].x += (mouseX - 100 - _snakeParts[0].x) * _loc2_;
            _snakeParts[0].y += (mouseY - 60 - _snakeParts[0].y) * _loc2_;
         }
         else
         {
            _snakeParts[0].x = mouseX - 100;
            _snakeParts[0].y = mouseY - 60;
         }
         updateSnakeBody(0);
      }
      
      private function keyboardMove() : void
      {
         var _loc1_:Number = Math.min(_snakeSpeed + _gameTime / 36,20);
         var _loc2_:* = _loc1_;
         if(_upArrow)
         {
            if(_leftArrow || _rightArrow)
            {
               _loc2_ = _snakeSpeed * 0.7071067811865476;
            }
            _snakeParts[0].y -= _loc2_;
         }
         else if(_downArrow)
         {
            if(_leftArrow || _rightArrow)
            {
               _loc2_ = _snakeSpeed * 0.7071067811865476;
            }
            _snakeParts[0].y += _loc2_;
         }
         _loc2_ = _loc1_;
         if(_leftArrow)
         {
            if(_upArrow || _downArrow)
            {
               _loc2_ = _snakeSpeed * 0.7071067811865476;
            }
            _snakeParts[0].x -= _loc2_;
         }
         else if(_rightArrow)
         {
            if(_upArrow || _downArrow)
            {
               _loc2_ = _snakeSpeed * 0.7071067811865476;
            }
            _snakeParts[0].x += _loc2_;
         }
         updateSnakeBody(0);
      }
      
      private function keyboardHandler(param1:KeyboardEvent) : void
      {
         if(_theGame.loader.content.startMovement)
         {
            if(_useKeyboard)
            {
               switch(int(param1.keyCode) - 37)
               {
                  case 0:
                     if(!_rightArrow && !_theGame.loader.content.controls.visible)
                     {
                        if(!_leftArrow)
                        {
                           _soundMan.playByName(Math.random() < 0.5 ? _soundNameSnakeTurn1 : _soundNameSnakeTurn2);
                        }
                        _leftArrow = true;
                        if(_constantMotion)
                        {
                           _rightArrow = false;
                           _upArrow = false;
                           _downArrow = false;
                        }
                     }
                     break;
                  case 1:
                     if(!_downArrow)
                     {
                        if(!_upArrow)
                        {
                           _soundMan.playByName(Math.random() < 0.5 ? _soundNameSnakeTurn1 : _soundNameSnakeTurn2);
                        }
                        _upArrow = true;
                        if(_constantMotion)
                        {
                           _downArrow = false;
                           _leftArrow = false;
                           _rightArrow = false;
                        }
                        if(_theGame.loader.content.controls.visible)
                        {
                           _theGame.loader.content.controls.visible = false;
                           _theGame.loader.content.readyGo.visible = false;
                        }
                     }
                     break;
                  case 2:
                     if(!_leftArrow)
                     {
                        if(!_rightArrow)
                        {
                           _soundMan.playByName(Math.random() < 0.5 ? _soundNameSnakeTurn1 : _soundNameSnakeTurn2);
                        }
                        _rightArrow = true;
                        if(_constantMotion)
                        {
                           _leftArrow = false;
                           _upArrow = false;
                           _downArrow = false;
                        }
                        if(_theGame.loader.content.controls.visible)
                        {
                           _theGame.loader.content.controls.visible = false;
                           _theGame.loader.content.readyGo.visible = false;
                        }
                     }
                     break;
                  case 3:
                     if(!_upArrow)
                     {
                        if(!_downArrow)
                        {
                           _soundMan.playByName(Math.random() < 0.5 ? _soundNameSnakeTurn1 : _soundNameSnakeTurn2);
                        }
                        _downArrow = true;
                        if(_constantMotion)
                        {
                           _upArrow = false;
                           _leftArrow = false;
                           _rightArrow = false;
                        }
                        if(_theGame.loader.content.controls.visible)
                        {
                           _theGame.loader.content.controls.visible = false;
                           _theGame.loader.content.readyGo.visible = false;
                        }
                        break;
                     }
               }
            }
         }
      }
      
      private function keyboardReleased(param1:KeyboardEvent) : void
      {
         var _loc2_:Array = [_rightArrow == true,_leftArrow == true,_upArrow == true,_downArrow == true];
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrow = false;
               break;
            case 1:
               _upArrow = false;
               break;
            case 2:
               _rightArrow = false;
               break;
            case 3:
               _downArrow = false;
         }
         if(_constantMotion)
         {
            if(!_rightArrow && !_leftArrow && !_upArrow && !_downArrow)
            {
               _rightArrow = _loc2_[0];
               _leftArrow = _loc2_[1];
               _upArrow = _loc2_[2];
               _downArrow = _loc2_[3];
            }
         }
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
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
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
            if(!(_readyGo && !_theGame.loader.content.startMovement))
            {
               if(_pauseGame == false && _gameOverTimer <= 0)
               {
                  _gameTime += _frameTime;
                  _readyGo = false;
                  if(_useKeyboard == 0)
                  {
                     mouseMove();
                  }
                  else
                  {
                     keyboardMove();
                  }
                  if(_snakeParts[0].x < 0 || _snakeParts[0].x > 700 || _snakeParts[0].y < 0 || _snakeParts[0].y > 425)
                  {
                     _snakeParts[0].mc.top.miss.gotoAndPlay("onWall");
                     _gameOverTimer = 1;
                     _soundMan.playByName(_soundNameSnakeDeath);
                  }
                  else if(_snakeBody.hitTestPoint(_snakeParts[0].x + 100,_snakeParts[0].y + 60,true))
                  {
                     _snakeParts[0].mc.top.miss.gotoAndPlay("on");
                     _gameOverTimer = 1;
                     _soundMan.playByName(_soundNameSnakeDeath);
                  }
                  _loc2_ = 0;
                  _loc3_ = 0;
                  while(_loc3_ < _mice.length)
                  {
                     if(_snakeParts[0].mc.hitTestObject(_mice[_loc3_]))
                     {
                        extend(_snakeParts.length - 2);
                        taperTail();
                        _mice[_loc3_].gotoAndPlay("off");
                        if(_mice[_loc3_].golden)
                        {
                           _gems += 15;
                           _goldCollection++;
                           addToPetMastery(1);
                           _soundMan.playByName(_soundNameHamsterGoldEat);
                        }
                        else
                        {
                           _gems++;
                           _soundMan.playByName(_soundNameHamsterEat);
                        }
                        _micePool.push(_mice[_loc3_]);
                        _mice.splice(_loc3_,1);
                        _loc3_--;
                        _loc2_++;
                        _points++;
                        _theGame.loader.content.gems.gemsText.text = _gems.toString();
                        _theGame.loader.content.points.text = _points.toString();
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_)
                  {
                     addMouse();
                     _loc3_++;
                  }
               }
            }
            if(_gameOverTimer > 0)
            {
               _gameOverTimer -= _frameTime;
               if(_gameOverTimer <= 0)
               {
                  showGameOver();
               }
            }
         }
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
            _readyGo = true;
            _theGame.loader.content.readyGo.gotoAndPlay("on");
         }
      }
      
      public function petLoaded(param1:MovieClip) : void
      {
      }
      
      public function onCloseButton() : void
      {
         showExitConfirmationDlg();
      }
   }
}

