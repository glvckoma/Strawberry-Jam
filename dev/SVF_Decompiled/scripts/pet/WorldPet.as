package pet
{
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import gui.GuiManager;
   
   public class WorldPet extends PetBase
   {
      public static const ANIM_IDLE:int = 0;
      
      public static const ANIM_MOVE:int = 1;
      
      public static const ANIM_IDLE_UP:int = 2;
      
      public static const ANIM_MOVE_UP:int = 3;
      
      public static const ANIM_CLICK:int = 4;
      
      public static const ANIM_IDLE_WATER:int = 10;
      
      public static const ANIM_IDLE_MUD:int = 20;
      
      public static const ANIM_DANCE:int = 31;
      
      public static const ANIM_SLEEP_OR_DIVE:int = 32;
      
      public static const ANIM_HOP_OR_SWIRL:int = 33;
      
      public static const ANIM_PLAY:int = 34;
      
      public static const ANIM_SIT_OR_POSE:int = 35;
      
      public static const ACTION_CLICK:int = 0;
      
      public static const ACTION_SPARKLE:int = 1;
      
      public static const PET_SPARKLE_TIME:int = 7200;
      
      public static var _actionLookup:Array = [{
         "name":":dance:",
         "animId":31
      },{
         "name":":sleep:",
         "animId":32
      },{
         "name":":dive:",
         "animId":32
      },{
         "name":":hop:",
         "animId":33
      },{
         "name":":swirl:",
         "animId":33
      },{
         "name":":play:",
         "animId":34
      },{
         "name":":sit:",
         "animId":35
      },{
         "name":":sitNW:",
         "animId":35
      },{
         "name":":sitSW:",
         "animId":35
      },{
         "name":":sitSE:",
         "animId":35
      },{
         "name":":sitNE:",
         "animId":35
      },{
         "name":":pose:",
         "animId":35
      },{
         "name":":poseLeft:",
         "animId":35
      },{
         "name":":poseRight:",
         "animId":35
      }];
      
      private var _parent:AvatarWorldView;
      
      private var _mode:int;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _targetX:int;
      
      private var _targetY:int;
      
      private var _bNewTarget:Boolean;
      
      private var _dirX:Number;
      
      private var _dirY:Number;
      
      private var _speed:Number;
      
      private var _lastAnim:int;
      
      private var _bFlip:Boolean;
      
      private var _bBack:Boolean;
      
      private var _bUpdateState:Boolean;
      
      private var _parentLastX:Number;
      
      private var _parentLastY:Number;
      
      private var _bSpecialMove:Boolean;
      
      private var _petLoaded:Boolean;
      
      private var _sparkle:int;
      
      private var _offsetX:int = 100;
      
      private var _offsetY:int = -50;
      
      private var _maxSpeed:Number = 1;
      
      private var _accel:Number = 0.03;
      
      private var _scale:Number = 1;
      
      private var _minX:Number = -70;
      
      private var _maxX:Number = 55;
      
      private var _airPetYOffest:Number = -80;
      
      private var _oceanPetXOffset:Number = 55;
      
      private var _petLandLowXOffset:Number = 30;
      
      public function WorldPet(param1:AvatarWorldView, param2:Number, param3:uint, param4:uint, param5:uint, param6:uint, param7:uint, param8:uint, param9:int = 0)
      {
         super(param2,param3,param4,param5,param6,param7,param8,onPetLoaded);
         _sparkle = param9;
         _parent = param1;
         _targetX = 0;
         _bNewTarget = true;
         _mode = 1;
         _lastAnim = -1;
         _bUpdateState = true;
         _bFlip = false;
         _bBack = false;
         _bSpecialMove = false;
         _parent.addChild(this);
         if(param1.userName.toLowerCase() == gMainFrame.server.userName.toLowerCase() && !GuiManager.isBeYourPetRoom())
         {
            this.addEventListener("mouseDown",onClick,false,0,true);
         }
         else
         {
            this.mouseChildren = false;
            this.mouseEnabled = false;
         }
         if(isEggAndHasNotHatched || (getType() == 0 || getType() == 2 || getType() == 4))
         {
            if(GuiManager.isBeYourPetRoom())
            {
               _y = -5;
               GuiManager.actionMgr.grayOutPetDanceBtn(false);
            }
            else
            {
               _y = 0;
            }
         }
         else
         {
            GuiManager.actionMgr.grayOutPetDanceBtn(true);
            if(GuiManager.isBeYourPetRoom())
            {
               _y = -5;
            }
            else
            {
               _y = _airPetYOffest;
            }
         }
         _parentLastX = _parent.x;
         _parentLastY = _parent.y;
         if(GuiManager.isBeYourPetRoom())
         {
            _minX = 25;
            _maxX = -30;
            _x = _maxX;
            _parentLastX = 0;
         }
         else
         {
            if(getType() == 2)
            {
               _minX -= _oceanPetXOffset;
               _maxX += _oceanPetXOffset;
            }
            else if(getType() == 0)
            {
               if(param1.avTypeId != 5)
               {
                  _minX -= _petLandLowXOffset;
               }
            }
            _x = 0;
         }
         _targetX = 0;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         this.removeEventListener("mouseDown",onClick);
      }
      
      public function heartbeat(param1:int, param2:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc3_:Matrix = null;
         var _loc4_:int = 0;
         if(_content && _parent && !_parent.isOffScreen)
         {
            if(GuiManager.isBeYourPetRoom())
            {
               if(_parentLastX != _parent.x)
               {
                  if(_parent.x > _parentLastX)
                  {
                     if(!_bFlip)
                     {
                        _parent.flipSplash(true);
                        _bFlip = true;
                        _x = _minX;
                     }
                  }
                  else if(_bFlip)
                  {
                     _parent.flipSplash(false);
                     _bFlip = false;
                     _x = _maxX;
                  }
                  _parentLastX = _parent.x;
               }
            }
            else
            {
               if(_targetX == 0)
               {
                  _targetX = _parent.hFlip ? _minX : _maxX;
               }
               if(_parentLastX != _parent.x)
               {
                  _bFlip = _parent.x > _parentLastX ? true : false;
                  if(Math.abs(_parentLastX - _parent.x) > 13)
                  {
                     _targetX = _bFlip ? _minX : _maxX;
                  }
                  _parentLastX = _parent.x;
               }
               if(_parentLastY != _parent.y)
               {
                  _bBack = _parent.y < _parentLastY - 10 ? true : false;
                  _parentLastY = _parent.y;
               }
               if(_x > _targetX)
               {
                  _x -= 10;
                  if(_x <= _targetX)
                  {
                     _x = _targetX;
                  }
                  _bFlip = _x == _targetX ? true : false;
               }
               if(_x < _targetX)
               {
                  _x += 10;
                  if(_x > _targetX)
                  {
                     _x = _targetX;
                  }
                  _bFlip = _x == _targetX ? false : true;
               }
            }
            if(_bUpdateState)
            {
               PetManager.setPetState(_content,_lBits,_uBits,_eBits);
               _bUpdateState = false;
            }
            _loc5_ = _parent.inSplashVolume() ? 10 : 0;
            if(_loc5_ && _parent.splashLiquid == "mud")
            {
               _loc5_ = 20;
            }
            if(_parent.splashLiquid != "mud" && _parent.splashLiquid != "water")
            {
               _loc5_ = 0;
            }
            _loc3_ = _content.transform.matrix;
            _loc3_.identity();
            _loc3_.scale(_bFlip ? -_scale : _scale,_scale);
            _loc3_.translate(_x,_y - param1);
            _content.transform.matrix = _loc3_;
            _loc4_ = _loc5_ + param2;
            if(_bBack)
            {
               _loc4_ += 2;
            }
            if((param2 || _lastAnim <= 4) && _lastAnim != _loc4_)
            {
               _lastAnim = _loc4_;
               _content.pet.setAnim(_loc4_);
            }
            if(_bSpecialMove)
            {
               _bSpecialMove = false;
               if(!param2)
               {
                  _content.pet.setAnim(4 + _loc5_);
               }
            }
         }
      }
      
      public function setState(param1:Array) : void
      {
         _lBits = param1[0];
         _uBits = param1[1];
         _eBits = param1[2];
         _bUpdateState = true;
      }
      
      public function setAction(param1:int, param2:int = 0) : void
      {
         switch(param1)
         {
            case 0:
               onClick();
               break;
            case 1:
               setSparkle(param2);
         }
      }
      
      public function setActionByName(param1:String) : void
      {
         var _loc2_:int = 0;
         for each(var _loc3_ in _actionLookup)
         {
            if(_loc3_.name == param1)
            {
               _loc2_ = int(_loc3_.animId);
               if(_loc2_ > 0)
               {
                  _lastAnim = _loc2_;
                  if(_content)
                  {
                     _content.pet.setAnim(_loc2_);
                  }
               }
               break;
            }
         }
      }
      
      public function onClick(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            UserCommXtCommManager.sendPetAction(0);
         }
         _bSpecialMove = true;
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         if(GuiManager.isBeYourPetRoom())
         {
            _content.pet.scaleY = 2;
            _content.pet.scaleX = 2;
         }
         _content.pet.setSparkle(_sparkle);
      }
      
      private function convertAvtAnimToPetAnim() : int
      {
         switch(_parent.animId)
         {
            case 23:
            case 38:
               return 31;
            case 22:
            case 41:
               return 32;
            case 17:
            case 33:
               return 33;
            case 6:
            case 39:
               return 34;
            case 2:
            case 4:
            case 40:
               break;
            default:
               return _parent.isPetMovingTest() ? 0 : 1;
         }
         return 35;
      }
   }
}

