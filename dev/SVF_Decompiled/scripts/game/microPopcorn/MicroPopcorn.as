package game.microPopcorn
{
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gskinner.motion.GTween;
   
   public class MicroPopcorn extends GameBase implements IMinigame
   {
      private static const MAX_VELOCITY_X:Number = 450;
      
      private static const MAX_VELOCITY_Y:Number = 250;
      
      private static const ACCELERATION_X:Number = 2500;
      
      private static const ACCELERATION_Y:Number = 450;
      
      private static const BRAKE_X:Number = 4000;
      
      private static const BRAKE_Y:Number = 800;
      
      private static const REQUIRED_KERNELS:int = 15;
      
      public var _soundMan:SoundManager;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBack:Sprite;
      
      public var _layerFront:Sprite;
      
      public var _layerKernels:Sprite;
      
      public var _layerCupFront:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _readySetGo:Number;
      
      private var _cupFront:Object;
      
      private var _cupBack:Object;
      
      private var _cupFrontMax:Object;
      
      private var _cupBackMax:Object;
      
      private var _popper:Object;
      
      private var _popcornMachine:Object;
      
      private var _ready:Object;
      
      private var _congrats:Object;
      
      private var _popStart:Object;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      public var _popKernelTimer:Number;
      
      public var _congratsTimer:Number;
      
      public var _velocityX:Number;
      
      public var _popcornCaught:int;
      
      public var _kernelPoppedSounds:Array;
      
      private var _audio:Array = ["kernel_popped1.mp3","kernel_popped2.mp3","burnt_kernel.mp3","bad kernel.mp3","good kernel.mp3","MG_popup_youWon.mp3","GS_Ready_Blink.mp3"];
      
      private var _soundNameKernelPopped1:String = _audio[0];
      
      private var _soundNameKernelPopped2:String = _audio[1];
      
      private var _soundNameKernelBurnt:String = _audio[2];
      
      private var _soundNameKernelBad:String = _audio[3];
      
      private var _soundNameKernelGood:String = _audio[4];
      
      private var _soundNamePlayerWins:String = _audio[5];
      
      private var _soundNameReady:String = _audio[6];
      
      public var _SFX_POP_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function MicroPopcorn()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_POP_Music = _soundMan.addStream("popcorn_lp",1);
         _soundMan.addSoundByName(_audioByName[_soundNameKernelPopped1],_soundNameKernelPopped1,1);
         _soundMan.addSoundByName(_audioByName[_soundNameKernelPopped2],_soundNameKernelPopped2,1);
         _kernelPoppedSounds = new Array(_soundNameKernelPopped1,_soundNameKernelPopped2);
         _soundMan.addSoundByName(_audioByName[_soundNameKernelBurnt],_soundNameKernelBurnt,1);
         _soundMan.addSoundByName(_audioByName[_soundNameKernelBad],_soundNameKernelBad,1);
         _soundMan.addSoundByName(_audioByName[_soundNameKernelGood],_soundNameKernelGood,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerWins],_soundNamePlayerWins,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameReady],_soundNameReady,0.65);
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
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",startKeyDown);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("click",mouseClickHandler);
         resetGame();
         _bInit = false;
         removeLayer(_layerBack);
         removeLayer(_layerFront);
         removeLayer(_layerKernels);
         removeLayer(_layerCupFront);
         removeLayer(_guiLayer);
         _layerBack = null;
         _layerFront = null;
         _layerKernels = null;
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
            _layerKernels = new Sprite();
            _layerCupFront = new Sprite();
            _layerBack.mouseEnabled = false;
            _layerFront.mouseEnabled = false;
            _layerKernels.mouseEnabled = false;
            _layerCupFront.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBack);
            addChild(_layerKernels);
            addChild(_layerFront);
            addChild(_layerCupFront);
            addChild(_guiLayer);
            loadScene("PopcornAssets/room_main.xroom",_audio);
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
         _musicLoop = _soundMan.playStream(_SFX_POP_Music,0,999999);
         _loc4_ = _scene.getLayer("closeButton");
         addBtn("CloseButton",_loc4_.x,_loc4_.y,onCloseButton);
         _cupFront = _scene.getLayer("pop_bucket_front");
         _cupBack = _scene.getLayer("pop_bucket_rear");
         _cupFrontMax = _scene.getLayer("pop_bucket_front_max");
         _cupBackMax = _scene.getLayer("pop_bucket_rear_max");
         _popper = _scene.getLayer("pop_popper");
         _popcornMachine = _scene.getLayer("popcornMachine");
         _layerBack.addChild(_scene.getLayer("pop_background").loader);
         _layerBack.addChild(_popper.loader);
         _layerBack.addChild(_cupBack.loader);
         _layerKernels.addChild(_popcornMachine.loader);
         _layerFront.addChild(_scene.getLayer("pop_foreground").loader);
         _layerFront.addChild(_scene.getLayer("pop_foreground_top").loader);
         _layerCupFront.addChild(_cupFront.loader);
         _congrats = _scene.getLayer("pop_congrats");
         _popStart = _scene.getLayer("pop_exit");
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
         var _loc5_:Point = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
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
               if(_readySetGo > 0)
               {
                  _readySetGo -= _frameTime;
                  if(_readySetGo <= 0)
                  {
                     if(_ready && _ready.loader.parent)
                     {
                        _ready.loader.parent.removeChild(_ready.loader);
                        _scene.releaseCloneAsset(_ready.loader);
                        _ready = null;
                     }
                  }
               }
               if(_popcornCaught < 15)
               {
                  if(_popKernelTimer >= 0)
                  {
                     _loc5_ = localToGlobal(new Point(_cupBack.loader.x,_cupBack.loader.y));
                     switch(_popcornMachine.loader.content.detectCollision(_loc5_.x,_loc5_.y,_cupBack.width,_cupBack.height + 75))
                     {
                        case 0:
                           _soundMan.playByName(_soundNameKernelBad);
                           _popcornCaught -= 2;
                           if(_popcornCaught < 0)
                           {
                              _popcornCaught = 0;
                           }
                           updatePopcornMeter();
                           _cupFront.loader.content.losePopcorn();
                           break;
                        case 1:
                           _soundMan.playByName(_soundNameKernelGood);
                           _popcornCaught += 2;
                           updatePopcornMeter();
                           if(_popcornCaught >= 15)
                           {
                              new GTween(_popcornMachine.loader,0.5,{"alpha":0});
                              _soundMan.playByName(_soundNamePlayerWins);
                              _guiLayer.addChild(_congrats.loader);
                              _congrats.loader.content.Ready_Text.gotoAndPlay("on");
                              if(_closeBtn)
                              {
                                 _closeBtn.visible = false;
                              }
                              MinigameManager.msg(["_a",1]);
                              _congratsTimer = 2;
                              break;
                           }
                     }
                     _popKernelTimer -= _frameTime;
                     if(_popKernelTimer <= 0)
                     {
                        _loc4_ = Math.min(2,Math.random() * 6);
                        _popKernelTimer = 0.5 + Math.random() * 0.5;
                        _popcornMachine.loader.content.popKernel(_loc4_);
                        _loc2_ = Math.random() * _kernelPoppedSounds.length;
                        _soundMan.playByName(_kernelPoppedSounds[_loc2_]);
                        if(_loc4_ == 0)
                        {
                           _soundMan.playByName(_soundNameKernelBurnt);
                        }
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
      
      public function updatePopcornMeter() : void
      {
         var _loc1_:int = 2;
         if(_popcornCaught > 0)
         {
            _loc1_ = Math.max(3,_popcornCaught / 15 * 15 + 1);
         }
         _cupFront.loader.content.gotoAndStop(_loc1_);
      }
      
      public function updateControls() : void
      {
         if(stage.mouseX < _cupFront.loader.x + _cupFront.width / 3)
         {
            _velocityX -= 2500 * _frameTime;
            if(_velocityX < -450)
            {
               _velocityX = -450;
            }
         }
         else if(stage.mouseX > _cupFront.loader.x + 2 * _cupFront.width / 3)
         {
            _velocityX += 2500 * _frameTime;
            if(_velocityX > 450)
            {
               _velocityX = 450;
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
      
      private function startKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onStart();
               break;
            case 8:
            case 46:
            case 27:
               onCloseButton();
         }
      }
      
      public function startGame() : void
      {
         var _loc3_:Number = NaN;
         var _loc1_:MovieClip = null;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _popKernelTimer = -1;
         _popcornCaught = 0;
         _velocityX = 0;
         if(_sceneLoaded)
         {
            _loc3_ = (_cupFrontMax.x - _cupFront.x) / 2;
            _cupFront.loader.x = _cupFront.x + _loc3_;
            _cupBack.loader.x = _cupBack.x + _loc3_;
            _cupFront.loader.content.gotoAndStop(2);
            _loc1_ = showDlg("popup_fill",[{
               "name":"button_play",
               "f":onStart
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
            stage.addEventListener("keyDown",startKeyDown);
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
         stage.removeEventListener("keyDown",startKeyDown);
         hideDlg();
         if(_ready && _ready.loader.parent)
         {
            _ready.loader.parent.removeChild(_ready.loader);
         }
         _readySetGo = 3;
         _ready = _scene.cloneAsset("pop_ready");
         _guiLayer.addChild(_ready.loader);
         _soundMan.playByName(_soundNameReady);
         _popKernelTimer = 3;
      }
   }
}

