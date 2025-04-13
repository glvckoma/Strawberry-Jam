package game.microSmoothie
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gskinner.motion.GTween;
   
   public class MicroSmoothie extends GameBase implements IMinigame
   {
      private static const MAX_VELOCITY_X:Number = 900;
      
      private static const MAX_VELOCITY_Y:Number = 250;
      
      private static const ACCELERATION_X:Number = 2500;
      
      private static const ACCELERATION_Y:Number = 450;
      
      private static const BRAKE_X:Number = 4000;
      
      private static const BRAKE_Y:Number = 800;
      
      private static const REQUIRED_FRUITS:int = 10;
      
      public var _fruitTypesColor:Array;
      
      public var _fruitTypes:Array;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBack:Sprite;
      
      public var _layerFront:Sprite;
      
      public var _layerFruits:Sprite;
      
      public var _layerCupFront:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _cupFront:Object;
      
      private var _cupBack:Object;
      
      private var _cupFrontMax:Object;
      
      private var _cupBackMax:Object;
      
      private var _fruitMachine:Object;
      
      private var _ready:Object;
      
      private var _congrats:Object;
      
      private var _fruitStart:Object;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      public var _nextFruitTimer:Number;
      
      public var _congratsTimer:Number;
      
      public var _velocityX:Number;
      
      public var _fruitCaught:int;
      
      public var _smoothieType:int;
      
      private var _dismissDialogTimer:Number;
      
      public var _soundMan:SoundManager;
      
      public var _fruitStartSounds:Array;
      
      private var _audio:Array = ["slushy_fruit_passby.mp3","slushy_fruit_passby2.mp3","slushy_correct_fruit.mp3","slushy_wrong_fruit.mp3","MG_popup_youWon.mp3"];
      
      private var _soundNameFruitStart1:String = _audio[0];
      
      private var _soundNameFruitStart2:String = _audio[1];
      
      private var _soundNameCorrect:String = _audio[2];
      
      private var _soundNameWrong:String = _audio[3];
      
      private var _soundNamePlayerWins:String = _audio[4];
      
      public function MicroSmoothie()
      {
         super();
         _fruitTypesColor = new Array("purple","orange","red","yellow");
         _fruitTypes = new Array("grapes","orange","strawberry","banana");
         init();
      }
      
      private function loadSounds() : void
      {
         _fruitStartSounds = [];
         _soundMan.addSoundByName(_audioByName[_soundNameFruitStart1],_soundNameFruitStart1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameFruitStart2],_soundNameFruitStart2,0.5);
         _fruitStartSounds = new Array(_soundNameFruitStart1,_soundNameFruitStart2);
         _soundMan.addSoundByName(_audioByName[_soundNameCorrect],_soundNameCorrect,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameWrong],_soundNameWrong,0.8);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerWins],_soundNamePlayerWins,0.35);
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = false;
               break;
            case 1:
               _upArrowDown = false;
               break;
            case 2:
               _rightArrowDown = false;
               break;
            case 3:
               _downArrowDown = false;
         }
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = true;
               break;
            case 1:
               _upArrowDown = true;
               break;
            case 2:
               _rightArrowDown = true;
               break;
            case 3:
               _downArrowDown = true;
         }
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
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("click",mouseClickHandler);
         resetGame();
         _bInit = false;
         removeLayer(_layerBack);
         removeLayer(_layerFront);
         removeLayer(_layerFruits);
         removeLayer(_layerCupFront);
         removeLayer(_guiLayer);
         _layerBack = null;
         _layerFront = null;
         _layerFruits = null;
         _layerCupFront = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerBack = new Sprite();
            _layerFront = new Sprite();
            _layerFruits = new Sprite();
            _layerCupFront = new Sprite();
            _layerBack.mouseEnabled = false;
            _layerFront.mouseEnabled = false;
            _layerFruits.mouseEnabled = false;
            _layerCupFront.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBack);
            addChild(_layerFruits);
            addChild(_layerFront);
            addChild(_layerCupFront);
            addChild(_guiLayer);
            loadScene("SmoothieAssets/room_main.xroom",_audio);
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
         addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _cupFront = _scene.getLayer("cupFront");
         _cupBack = _scene.getLayer("cupBack");
         _cupFrontMax = _scene.getLayer("cupFrontMax");
         _cupBackMax = _scene.getLayer("cupBackMax");
         _fruitMachine = _scene.getLayer("smoothieGame");
         _layerBack.addChild(_scene.getLayer("smoothieBackground").loader);
         _layerBack.addChild(_cupBack.loader);
         _layerFruits.addChild(_fruitMachine.loader);
         _layerCupFront.addChild(_cupFront.loader);
         _congrats = _scene.getLayer("smoothieSuccess");
         _leftArrowDown = false;
         _rightArrowDown = false;
         _downArrowDown = false;
         _upArrowDown = false;
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("click",mouseClickHandler);
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
         var _loc6_:Point = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_sceneLoaded)
            {
               _gameTime += _frameTime;
               if(_fruitCaught < 10)
               {
                  if(_dismissDialogTimer > 0)
                  {
                     _dismissDialogTimer -= _frameTime;
                     if(_dismissDialogTimer <= 0)
                     {
                        hideDlg();
                        _nextFruitTimer = 1.5;
                     }
                  }
                  else if(_nextFruitTimer >= 0)
                  {
                     _loc6_ = localToGlobal(new Point(_cupBack.loader.x,_cupBack.loader.y));
                     _loc5_ = int(_fruitMachine.loader.content.detectCollision(_loc6_.x,_loc6_.y,_cupBack.width,_cupBack.height + 75));
                     if(_loc5_ >= 0)
                     {
                        if(_loc5_ == _smoothieType)
                        {
                           _soundMan.playByName(_soundNameCorrect);
                           _fruitCaught += 2;
                           updateFruitMeter();
                           if(_fruitCaught >= 10)
                           {
                              new GTween(_fruitMachine.loader,0.5,{"alpha":0});
                              _guiLayer.addChild(_congrats.loader);
                              _congrats.loader.content.Ready_Text.gotoAndPlay("on");
                              if(_closeBtn)
                              {
                                 _closeBtn.visible = false;
                              }
                              if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                              {
                                 switch(MinigameManager.minigameInfoCache.currMinigameId - 91)
                                 {
                                    case 0:
                                       MinigameManager.handleQuestMiniGameComplete(1);
                                       break;
                                    default:
                                       MinigameManager.msg(["_a",2,_fruitTypesColor[_smoothieType]]);
                                 }
                              }
                              _congratsTimer = 3;
                              _soundMan.playByName(_soundNamePlayerWins);
                           }
                        }
                        else
                        {
                           _soundMan.playByName(_soundNameWrong);
                           _cupFront.loader.content.loseSlush();
                           _fruitCaught -= 2;
                           if(_fruitCaught < 0)
                           {
                              _fruitCaught = 0;
                           }
                           updateFruitMeter();
                        }
                     }
                     _nextFruitTimer -= _frameTime;
                     if(_nextFruitTimer <= 0)
                     {
                        _loc2_ = Math.random() * 6;
                        if(_loc2_ >= 3)
                        {
                           _loc2_ = _smoothieType;
                        }
                        else if(_smoothieType == _loc2_)
                        {
                           _loc2_ = 3;
                        }
                        _nextFruitTimer = 0.5 + Math.random() * 0.5;
                        _fruitMachine.loader.content.createFruit(_loc2_);
                        _loc4_ = Math.random() * _fruitStartSounds.length;
                        _soundMan.playByName(_fruitStartSounds[_loc4_]);
                     }
                     _cupBack.loader.x = stage.mouseX - _cupFront.width / 2;
                     _cupFront.loader.x = stage.mouseX - _cupFront.width / 2;
                     if(_cupFront.loader.x < _cupFront.x)
                     {
                        _cupBack.loader.x = _cupBack.x;
                        _cupFront.loader.x = _cupFront.x;
                     }
                     else if(_cupFront.loader.x > _cupFrontMax.x)
                     {
                        _cupBack.loader.x = _cupBackMax.x;
                        _cupFront.loader.x = _cupFrontMax.x;
                     }
                  }
               }
               else
               {
                  _congratsTimer -= _frameTime;
                  if(_congratsTimer <= 0)
                  {
                     end(null);
                  }
               }
            }
         }
      }
      
      public function updateFruitMeter() : void
      {
         var _loc1_:int = 2;
         if(_fruitCaught > 0)
         {
            _loc1_ = Math.max(3,_fruitCaught / 10 * 15 + 1);
            if(_loc1_ > 16)
            {
               _loc1_ = 16;
            }
         }
         _cupFront.loader.content.gotoAndStop(_loc1_);
      }
      
      public function updateControls() : void
      {
         if(stage.mouseX < _cupFront.loader.x + _cupFront.width / 5)
         {
            _velocityX -= 2500 * _frameTime;
            if(_velocityX < -900)
            {
               _velocityX = -900;
            }
         }
         else if(stage.mouseX > _cupFront.loader.x + 4 * _cupFront.width / 5)
         {
            _velocityX += 2500 * _frameTime;
            if(_velocityX > 900)
            {
               _velocityX = 900;
            }
         }
         else if(_velocityX > 0)
         {
            _velocityX -= 4000 * _frameTime;
            if(_velocityX < 0)
            {
               _velocityX = 0;
            }
         }
         else if(_velocityX < 0)
         {
            _velocityX += 4000 * _frameTime;
            if(_velocityX > 0)
            {
               _velocityX = 0;
            }
         }
      }
      
      public function startGame() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:MovieClip = null;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _nextFruitTimer = -1;
         _dismissDialogTimer = 0;
         _fruitCaught = 0;
         _velocityX = 0;
         if(_sceneLoaded)
         {
            _loc3_ = (_cupFrontMax.x - _cupFront.x) / 2;
            _cupFront.loader.x = _cupFront.x + _loc3_;
            _cupBack.loader.x = _cupBack.x + _loc3_;
            _cupFront.loader.content.gotoAndStop(2);
            _loc1_ = showDlg("popup_flavor",[{
               "name":"button_strawberry",
               "f":onFlavorStrawberry
            },{
               "name":"button_orange",
               "f":onFlavorOrange
            },{
               "name":"button_banana",
               "f":onFlavorBanana
            },{
               "name":"button_grape",
               "f":onFlavorGrape
            }]);
            _loc1_.x = 455;
            _loc1_.y = 225;
         }
      }
      
      public function resetGame() : void
      {
      }
      
      private function mouseClickHandler(param1:MouseEvent) : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      public function onCloseButton() : void
      {
         end(null);
      }
      
      public function onStart() : void
      {
         hideDlg();
         if(_ready && _ready.loader.parent)
         {
            _ready.loader.parent.removeChild(_ready.loader);
         }
         _nextFruitTimer = 3;
      }
      
      public function selectFlavor(param1:int) : void
      {
         _smoothieType = param1;
         _cupFront.loader.content.slush.gotoAndStop(_fruitTypesColor[_smoothieType]);
         hideDlg();
         var _loc2_:MovieClip = showDlg("popup_fillcup",[]);
         _loc2_.x = 455;
         _loc2_.y = 300;
         _loc2_.gotoAndStop(_fruitTypes[_smoothieType]);
         _dismissDialogTimer = 3;
         addChild(_scene.getLayer("pickedFruit").loader);
      }
      
      public function onFlavorStrawberry() : void
      {
         _scene.getLayer("pickedFruit").loader.content.gotoAndStop("icon_strawberry");
         selectFlavor(2);
      }
      
      public function onFlavorBanana() : void
      {
         _scene.getLayer("pickedFruit").loader.content.gotoAndStop("icon_banana");
         selectFlavor(3);
      }
      
      public function onFlavorOrange() : void
      {
         _scene.getLayer("pickedFruit").loader.content.gotoAndStop("icon_orange");
         selectFlavor(1);
      }
      
      public function onFlavorGrape() : void
      {
         _scene.getLayer("pickedFruit").loader.content.gotoAndStop("icon_grape");
         selectFlavor(0);
      }
   }
}

