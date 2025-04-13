package game.microCrane
{
   import currency.UserCurrency;
   import den.DenItem;
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
   import giftPopup.GiftPopup;
   import item.Item;
   
   public class MicroCrane extends GameBase implements IMinigame
   {
      private static const MAX_CRANE_POSITION:int = 200;
      
      public static var SFX_CRANE_SERVO:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBack:Sprite;
      
      public var _layerCrane:Sprite;
      
      public var _layerFront:Sprite;
      
      public var _layerControls:Sprite;
      
      public var _goCountdown:Number;
      
      public var _goMC:Object;
      
      public var _soundMan:SoundManager;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _crane:Object;
      
      private var _drop:Object;
      
      private var _left:Object;
      
      private var _right:Object;
      
      private var _success:Boolean;
      
      private var _dropped:Boolean;
      
      private var _moveDirection:int;
      
      private var _cranePosition:Number;
      
      private var _craneOriginalPosition:Number;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      private var _velocity:Number;
      
      private var _gameStarted:Boolean;
      
      private var _endText:Object;
      
      private var _tryAgainTimer:Number;
      
      private var _needGemsTimer:Number;
      
      private var _prizePopup:GiftPopup;
      
      private var _cranePlaySuccess:Boolean;
      
      private var _prizeDenItem:DenItem;
      
      private var _prizeAccessory:Item;
      
      private var _audio:Array = ["claw_drop_button.mp3","claw_arrow_buttons.mp3","claw_close.mp3","claw_item_pick_up.mp3","claw_lower.mp3","claw_open.mp3","claw_retract.mp3","claw_prize.mp3","claw_almost.mp3","MG_popup_youWon.mp3","claw_insert_coin.mp3"];
      
      private var _soundNameCraneDrop:String = _audio[0];
      
      private var _soundNameCraneArrow:String = _audio[1];
      
      private var _soundNameCraneClose:String = _audio[2];
      
      private var _soundNameCraneItemPickup:String = _audio[3];
      
      private var _soundNameCraneLower:String = _audio[4];
      
      private var _soundNameCraneOpen:String = _audio[5];
      
      private var _soundNameCraneRetract:String = _audio[6];
      
      private var _soundNameCranePrize:String = _audio[7];
      
      private var _soundNameCraneAlmost:String = _audio[8];
      
      private var _soundNameCraneSuccess:String = _audio[9];
      
      private var _soundNameCraneInsertCoin:String = _audio[10];
      
      private var _SFX_Crane_Servo_Instance:SoundChannel;
      
      public function MicroCrane()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameCraneDrop],_soundNameCraneDrop,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneArrow],_soundNameCraneArrow,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneClose],_soundNameCraneClose,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneItemPickup],_soundNameCraneItemPickup,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneLower],_soundNameCraneLower,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneOpen],_soundNameCraneOpen,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneRetract],_soundNameCraneRetract,0.5);
         _soundMan.addSound(SFX_CRANE_SERVO,0.15,"SFX_CRANE_SERVO");
         _soundMan.addSoundByName(_audioByName[_soundNameCranePrize],_soundNameCranePrize,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneAlmost],_soundNameCraneAlmost,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneSuccess],_soundNameCraneSuccess,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameCraneInsertCoin],_soundNameCraneInsertCoin,0.6);
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = false;
               releaseMoveButtons();
               break;
            case 1:
               _upArrowDown = false;
               break;
            case 2:
               _rightArrowDown = false;
               releaseMoveButtons();
               break;
            case 3:
               _downArrowDown = false;
         }
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
            case 8:
               pressDropButton();
               _downArrowDown = true;
               break;
            case 5:
               _leftArrowDown = true;
               pressMoveButtons(-1);
               break;
            case 6:
               _upArrowDown = true;
               break;
            case 7:
               _rightArrowDown = true;
               pressMoveButtons(1);
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
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         hideDlg();
         releaseBase();
         if(_SFX_Crane_Servo_Instance)
         {
            _soundMan.stop(_SFX_Crane_Servo_Instance);
            _SFX_Crane_Servo_Instance = null;
         }
         stage.removeEventListener("keyDown",playKeyDown);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("mouseUp",mouseUpHandler);
         if(_drop)
         {
            _drop.loader.removeEventListener("click",mouseClickHandlerDrop);
         }
         if(_left)
         {
            _left.loader.removeEventListener("mouseDown",mouseDownHandlerLeft);
         }
         if(_right)
         {
            _right.loader.removeEventListener("mouseDown",mouseDownHandlerRight);
         }
         if(_crane)
         {
            _crane.loader.removeEventListener("craneDropComplete",craneDropCompleteHandler);
         }
         resetGame();
         _bInit = false;
         removeLayer(_layerBack);
         removeLayer(_layerCrane);
         removeLayer(_layerFront);
         removeLayer(_layerControls);
         removeLayer(_guiLayer);
         _layerBack = null;
         _layerCrane = null;
         _layerFront = null;
         _layerControls = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerBack = new Sprite();
            _layerCrane = new Sprite();
            _layerFront = new Sprite();
            _layerControls = new Sprite();
            _layerBack.mouseEnabled = false;
            _layerCrane.mouseEnabled = false;
            _layerFront.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBack);
            addChild(_layerCrane);
            addChild(_layerFront);
            addChild(_layerControls);
            addChild(_guiLayer);
            loadScene("CraneAssets/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc5_:Object = null;
         SFX_CRANE_SERVO = getDefinitionByName("claw_servo") as Class;
         if(SFX_CRANE_SERVO == null)
         {
            throw new Error("Sound not found! name:claw_servo");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _endText = null;
         _loc5_ = _scene.getLayer("closeButton");
         addBtn("CloseButton",_loc5_.x,_loc5_.y,onCloseButton);
         _crane = _scene.getLayer("crane_main");
         var _loc4_:String = MinigameManager.roomName;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId)
            {
               case 16:
                  _crane.loader.content.setType(1);
                  break;
               case 57:
                  _crane.loader.content.setType(2);
                  break;
               case 58:
                  _crane.loader.content.setType(3);
                  break;
               case 61:
                  _crane.loader.content.setType(4);
                  break;
               case 67:
                  _crane.loader.content.setType(6);
                  break;
               case 71:
                  _crane.loader.content.setType(7);
                  break;
               case 75:
                  _crane.loader.content.setType(5);
                  break;
               case 85:
                  _crane.loader.content.setType(12);
                  break;
               case 99:
                  _crane.loader.content.setType(10);
                  break;
               case 100:
                  _crane.loader.content.setType(8);
                  break;
               case 103:
                  _crane.loader.content.setType(11);
                  break;
               case 104:
                  _crane.loader.content.setType(15);
                  break;
               case 105:
                  _crane.loader.content.setType(14);
                  break;
               case 106:
                  _crane.loader.content.setType(13);
                  break;
               case 107:
                  _crane.loader.content.setType(16);
                  break;
               case 109:
                  _crane.loader.content.setType(18);
                  break;
               case 110:
                  _crane.loader.content.setType(19);
                  break;
               case 116:
                  _crane.loader.content.setType(9);
                  break;
               case 117:
                  _crane.loader.content.setType(20);
                  break;
               case 118:
                  _crane.loader.content.setType(17);
                  break;
               case 119:
                  _crane.loader.content.setType(23);
                  break;
               case 120:
                  _crane.loader.content.setType(3);
                  break;
               case 121:
                  _crane.loader.content.setType(24);
                  break;
               case 123:
                  _crane.loader.content.setType(22);
                  break;
               case 125:
                  _crane.loader.content.setType(26);
                  break;
               case 126:
                  _crane.loader.content.setType(25);
                  break;
               case 127:
                  _crane.loader.content.setType(31);
                  break;
               case 128:
                  _crane.loader.content.setType(27);
                  break;
               case 129:
                  _crane.loader.content.setType(28);
                  break;
               case 130:
                  _crane.loader.content.setType(29);
                  break;
               case 131:
                  _crane.loader.content.setType(30);
                  break;
               case 132:
                  _crane.loader.content.setType(33);
                  break;
               case 133:
                  _crane.loader.content.setType(34);
                  break;
               case 134:
                  _crane.loader.content.setType(35);
                  break;
               case 140:
                  _crane.loader.content.setType(32);
                  break;
               case 141:
                  _crane.loader.content.setType(36);
                  break;
               case 142:
                  _crane.loader.content.setType(37);
                  break;
               case 143:
                  _crane.loader.content.setType(38);
                  break;
               case 144:
                  _crane.loader.content.setType(39);
                  break;
               case 145:
                  _crane.loader.content.setType(40);
                  break;
               case 146:
                  _crane.loader.content.setType(41);
                  break;
               case 147:
                  _crane.loader.content.setType(42);
                  break;
               case 148:
                  _crane.loader.content.setType(43);
                  break;
               case 149:
                  _crane.loader.content.setType(44);
                  break;
               case 150:
                  _crane.loader.content.setType(45);
                  break;
               case 153:
                  _crane.loader.content.setType(46);
                  break;
               case 154:
                  _crane.loader.content.setType(47);
                  break;
               case 155:
                  _crane.loader.content.setType(48);
                  break;
               case 156:
                  _crane.loader.content.setType(49);
                  break;
               case 157:
                  _crane.loader.content.setType(50);
                  break;
               default:
                  _crane.loader.content.setType(0);
            }
         }
         else
         {
            _crane.loader.content.setType(0);
         }
         _craneOriginalPosition = _crane.loader.content.CraneClaw.x;
         _drop = _scene.getLayer("crane_drop");
         _left = _scene.getLayer("crane_left");
         _right = _scene.getLayer("crane_right");
         _crane.loader.content.CraneStop();
         _layerCrane.addChild(_crane.loader);
         _layerControls.addChild(_drop.loader);
         _layerControls.addChild(_left.loader);
         _layerControls.addChild(_right.loader);
         _sceneLoaded = true;
         _leftArrowDown = false;
         _rightArrowDown = false;
         _downArrowDown = false;
         _upArrowDown = false;
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseUp",mouseUpHandler);
         _drop.loader.addEventListener("click",mouseClickHandlerDrop);
         _left.loader.addEventListener("mouseDown",mouseDownHandlerLeft);
         _right.loader.addEventListener("mouseDown",mouseDownHandlerRight);
         _crane.loader.addEventListener("craneDropComplete",craneDropCompleteHandler);
         _crane.loader.addEventListener("craneOpen",craneOpenHandler);
         _crane.loader.addEventListener("craneClose",craneCloseHandler);
         _crane.loader.addEventListener("craneLower",craneLowerHandler);
         _crane.loader.addEventListener("craneRetract",craneRetractHandler);
         startGame();
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         if(param1[0] != "ml")
         {
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
               if(param1[2] == "cp")
               {
                  if(param1[3] != "1" && param1[3] != "0")
                  {
                     _loc2_ = showDlg("popup_needgems",[]);
                     _loc2_.x = 450;
                     _loc2_.y = 275;
                     _needGemsTimer = 3;
                  }
                  else
                  {
                     _success = false;
                     _dropped = false;
                     releaseMoveButtons();
                     _drop.loader.content.gotoAndStop("off");
                     _gameStarted = true;
                     if(param1[3] == "1")
                     {
                        _cranePlaySuccess = true;
                        if(param1[4] == "1")
                        {
                           _prizeAccessory = null;
                           _prizeDenItem = new DenItem();
                           _prizeDenItem.initShopItem(param1[5],param1[7]);
                        }
                        else
                        {
                           _prizeDenItem = null;
                           _prizeAccessory = new Item();
                           _prizeAccessory.init(param1[5],0,param1[7],null,true);
                        }
                     }
                     else
                     {
                        _cranePlaySuccess = false;
                     }
                  }
               }
            }
         }
      }
      
      private function keptItem() : void
      {
         MinigameManager.msg(["cd","1"]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         MinigameManager.msg(["cd","0"]);
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         popupTryAgain();
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
            if(_gameStarted)
            {
               if(_goCountdown > 0)
               {
                  _goCountdown -= _frameTime;
                  if(_goCountdown <= 0)
                  {
                     if(_goMC && _goMC.loader.parent)
                     {
                        _goMC.loader.parent.removeChild(_goMC.loader);
                        _scene.releaseCloneAsset(_goMC.loader);
                        _goMC = null;
                     }
                  }
               }
               else
               {
                  _gameTime += _frameTime;
                  if(_moveDirection != 0)
                  {
                     _velocity += 200 * _frameTime * _moveDirection;
                     if(_velocity > 125)
                     {
                        _velocity = 125;
                     }
                     else if(_velocity < -125)
                     {
                        _velocity = -125;
                     }
                  }
                  else if(_velocity > 0)
                  {
                     _velocity -= 200 * _frameTime;
                     if(_velocity < 0)
                     {
                        _velocity = 0;
                     }
                  }
                  else if(_velocity < 0)
                  {
                     _velocity += 200 * _frameTime;
                     if(_velocity > 0)
                     {
                        _velocity = 0;
                     }
                  }
                  if(_velocity != 0)
                  {
                     _cranePosition += _velocity * _frameTime;
                     if(_cranePosition < 0)
                     {
                        _velocity = 0;
                        _cranePosition = 0;
                        releaseMoveButtons();
                     }
                     else if(_cranePosition > 200)
                     {
                        _velocity = 0;
                        _cranePosition = 200;
                        releaseMoveButtons();
                     }
                     _crane.loader.content.CraneClaw.x = _craneOriginalPosition + _cranePosition;
                  }
               }
            }
            else if(_tryAgainTimer > 0)
            {
               _tryAgainTimer -= _frameTime;
               if(_tryAgainTimer <= 0)
               {
                  if(_endText && _endText.loader.parent)
                  {
                     _endText.loader.parent.removeChild(_endText.loader);
                     _scene.releaseCloneAsset(_endText.loader);
                     _endText = null;
                  }
                  if(_success)
                  {
                     _prizePopup = new GiftPopup();
                     if(_prizeDenItem != null)
                     {
                        _prizePopup.init(this.parent,_prizeDenItem.icon,_prizeDenItem.name,_prizeDenItem.defId,2,2,keptItem,rejectedItem,destroyPrizePopup);
                     }
                     else
                     {
                        _prizePopup.init(this.parent,_prizeAccessory.largeIcon,_prizeAccessory.name,_prizeAccessory.defId,2,1,keptItem,rejectedItem,destroyPrizePopup);
                     }
                     _soundMan.playByName(_soundNameCranePrize);
                  }
                  else
                  {
                     popupTryAgain();
                  }
               }
            }
            else if(_needGemsTimer > 0)
            {
               _needGemsTimer -= _frameTime;
               if(_needGemsTimer <= 0)
               {
                  hideDlg();
                  end(null);
               }
            }
         }
      }
      
      private function playKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onYes();
               break;
            case 8:
            case 46:
            case 27:
               onNo();
         }
      }
      
      public function startGame() : void
      {
         var _loc1_:String = null;
         var _loc2_:MovieClip = null;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _success = false;
         _dropped = false;
         _moveDirection = 0;
         _cranePosition = 0;
         _velocity = 0;
         _tryAgainTimer = 0;
         _gameStarted = false;
         if(_sceneLoaded)
         {
            stage.addEventListener("keyDown",playKeyDown);
            _loc1_ = "popup_play";
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               switch(MinigameManager.minigameInfoCache.currMinigameId - 57)
               {
                  case 0:
                     _loc1_ = "popup_play_25";
               }
            }
            _loc2_ = showDlg(_loc1_,[{
               "name":"button_yes",
               "f":onYes
            },{
               "name":"button_no",
               "f":onNo
            }]);
            _loc2_.x = 450;
            _loc2_.y = 275;
         }
      }
      
      public function resetGame() : void
      {
         if(_goMC)
         {
            if(_goMC.loader.parent)
            {
               _goMC.loader.parent.removeChild(_goMC.loader);
            }
            _scene.releaseCloneAsset(_goMC.loader);
            _goMC = null;
         }
      }
      
      private function mouseClickHandlerDrop(param1:MouseEvent) : void
      {
         if(_sceneLoaded)
         {
            pressDropButton();
         }
      }
      
      private function mouseDownHandlerRight(param1:MouseEvent) : void
      {
         if(_sceneLoaded)
         {
            if(!_dropped)
            {
               if(_moveDirection == 0)
               {
                  pressMoveButtons(1);
               }
            }
         }
      }
      
      private function mouseDownHandlerLeft(param1:MouseEvent) : void
      {
         if(_sceneLoaded)
         {
            if(!_dropped)
            {
               if(_moveDirection == 0)
               {
                  pressMoveButtons(-1);
               }
            }
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(_sceneLoaded)
         {
            releaseMoveButtons();
         }
      }
      
      private function craneOpenHandler(param1:CraneEvent) : void
      {
         _soundMan.playByName(_soundNameCraneOpen);
      }
      
      private function craneLowerHandler(param1:CraneEvent) : void
      {
         _soundMan.playByName(_soundNameCraneLower);
      }
      
      private function craneCloseHandler(param1:CraneEvent) : void
      {
         _soundMan.playByName(_soundNameCraneClose);
         if(_success)
         {
            _soundMan.playByName(_soundNameCraneItemPickup);
         }
      }
      
      private function craneRetractHandler(param1:CraneEvent) : void
      {
         _soundMan.playByName(_soundNameCraneRetract);
      }
      
      private function craneDropCompleteHandler(param1:CraneEvent) : void
      {
         if(_gameStarted)
         {
            _gameStarted = false;
            if(_success)
            {
               _endText = _scene.cloneAsset("crane_success");
               _soundMan.playByName(_soundNameCraneSuccess);
            }
            else
            {
               _endText = _scene.cloneAsset("crane_fail");
               _soundMan.playByName(_soundNameCraneAlmost);
            }
            _guiLayer.addChild(_endText.loader);
            _tryAgainTimer = 1.5;
         }
      }
      
      private function pressDropButton() : void
      {
         if(!_dropped && _goCountdown <= 0)
         {
            releaseMoveButtons();
            if(_gameStarted)
            {
               if(_cranePlaySuccess)
               {
                  _crane.loader.content.CraneDropSuccess();
                  _success = true;
               }
               else
               {
                  _crane.loader.content.CraneDropFail();
               }
               _dropped = true;
               _drop.loader.content.gotoAndStop("on");
               _soundMan.playByName(_soundNameCraneDrop);
            }
         }
      }
      
      private function pressMoveButtons(param1:int) : void
      {
         var _loc2_:* = false;
         if(!_dropped && _gameStarted)
         {
            if(param1 < 0 && _cranePosition > 0 || param1 > 0 && _cranePosition < 200)
            {
               _loc2_ = _moveDirection != param1;
               _moveDirection = param1;
               _crane.loader.content.CraneMove();
               if(param1 < 0)
               {
                  _right.loader.content.gotoAndStop("off");
                  _left.loader.content.gotoAndStop("on");
                  if(_loc2_)
                  {
                     _soundMan.playByName(_soundNameCraneArrow);
                     if(_SFX_Crane_Servo_Instance == null)
                     {
                        _SFX_Crane_Servo_Instance = _soundMan.play(SFX_CRANE_SERVO,0,99999);
                     }
                  }
               }
               else if(param1 > 0)
               {
                  _left.loader.content.gotoAndStop("off");
                  _right.loader.content.gotoAndStop("on");
                  if(_loc2_)
                  {
                     _soundMan.playByName(_soundNameCraneArrow);
                     if(_SFX_Crane_Servo_Instance == null)
                     {
                        _SFX_Crane_Servo_Instance = _soundMan.play(SFX_CRANE_SERVO,0,99999);
                     }
                  }
               }
            }
         }
      }
      
      public function onCloseButton() : void
      {
         end(null);
      }
      
      private function releaseMoveButtons() : void
      {
         _moveDirection = 0;
         _crane.loader.content.CraneStop();
         _left.loader.content.gotoAndStop("off");
         _right.loader.content.gotoAndStop("off");
         if(_SFX_Crane_Servo_Instance)
         {
            _soundMan.stop(_SFX_Crane_Servo_Instance);
            _SFX_Crane_Servo_Instance = null;
         }
      }
      
      public function onYes() : void
      {
         stage.removeEventListener("keyDown",playKeyDown);
         var _loc1_:int = UserCurrency.getCurrency(0);
         hideDlg();
         _crane.loader.content.CraneClearSuccess();
         _soundMan.playByName(_soundNameCraneInsertCoin);
         MinigameManager.msg(["cp"]);
         if(_goMC)
         {
            if(_goMC.loader.parent)
            {
               _goMC.loader.parent.removeChild(_goMC.loader);
            }
            _scene.releaseCloneAsset(_goMC.loader);
            _goMC = null;
         }
         _goMC = _scene.cloneAsset("goPopup");
         if(_goMC)
         {
            _goMC.loader.x = 251;
            _goMC.loader.y = 76;
            _guiLayer.addChild(_goMC.loader);
            _goCountdown = 1.5;
         }
         else
         {
            _goCountdown = 0;
         }
      }
      
      public function onNo() : void
      {
         stage.removeEventListener("keyDown",playKeyDown);
         hideDlg();
         end(null);
      }
      
      public function popupTryAgain() : void
      {
         stage.addEventListener("keyDown",playKeyDown);
         var _loc1_:String = "popup_try";
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            switch(MinigameManager.minigameInfoCache.currMinigameId - 57)
            {
               case 0:
                  _loc1_ = "popup_try_25";
            }
         }
         var _loc2_:MovieClip = showDlg(_loc1_,[{
            "name":"button_yes",
            "f":onYes
         },{
            "name":"button_no",
            "f":onNo
         }]);
         _loc2_.x = 450;
         _loc2_.y = 275;
      }
   }
}

