package avatar
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import loader.MediaHelper;
   
   public class NameBar extends MovieClip
   {
      public static var NON_BUDDY:String = "nonBuddy";
      
      public static var BUDDY:String = "buddy";
      
      public static var GUIDE:String = "guide";
      
      public static const MAX_COLORS:int = 10;
      
      private static var BADGE_ID_VIP_CAMERA:int = 31;
      
      private static var _getNamebarIconsFunc:Function;
      
      public static const LEVEL_SHAPES:Array = new Array(1851,1858,1853,1857);
      
      private var _iconIdsArray:Array;
      
      private var _isBlocked:Boolean;
      
      private var _nubType:String;
      
      private var _left:MovieClip;
      
      private var _mid:MovieClip;
      
      private var _right:MovieClip;
      
      private var _avName:MovieClip;
      
      private var _meter:MovieClip;
      
      private var _shape:MovieClip;
      
      private var _host:MovieClip;
      
      private var _iconsMediaHelperArray:Array;
      
      private var _iconImages:Array;
      
      private var _nameBarDataToBeLoaded:int;
      
      private var _currColorId:int;
      
      private var _packedNameBarData:int;
      
      private var _badgeId:int;
      
      private var _levelShapeHelper:MediaHelper;
      
      private var _shapesMediaHelperArray:Array;
      
      private var _currShapeMouse:MovieClip;
      
      private var _currShapeUp:MovieClip;
      
      private var _isMember:Boolean;
      
      private var _isMemberNamebar:Boolean;
      
      private var _avNameTxt:TextField;
      
      public function NameBar(param1:String = "nonBuddy", param2:Boolean = false)
      {
         super();
         _left = this["e"];
         _mid = this["m"];
         if(this["meter"] != null)
         {
            _meter = this["meter"];
         }
         if(this["shape"] != null)
         {
            _shape = this["shape"];
         }
         if(this["hostTag"] != null)
         {
            _host = this["hostTag"];
         }
         _right = this["selnub"];
         _avName = this["c"];
         if(!(_left && _mid && _right && _avName))
         {
            throw new Error("NameBar is missing parts or parts are named improperly!");
         }
         _isMemberNamebar = "dark" in _avName;
         _avNameTxt = _isMemberNamebar ? _avName.dark.txt : _avName.txt;
         _currColorId = 4;
         isBlocked = param2;
         nubType = param1;
         isHostingCustomParty = false;
         _iconsMediaHelperArray = [];
         _shapesMediaHelperArray = [];
         _iconImages = [];
         if(_getNamebarIconsFunc != null)
         {
            _iconIdsArray = _getNamebarIconsFunc();
         }
         if(!_iconIdsArray)
         {
            _iconIdsArray = [];
         }
         _nameBarDataToBeLoaded = -1;
         this.cacheAsBitmap = true;
         addEventListener("rollOver",onOverHandler,false,0,true);
         addEventListener("rollOut",onOutHandler,false,0,true);
      }
      
      public static function set getNamebarIconsFunc(param1:Function) : void
      {
         _getNamebarIconsFunc = param1;
      }
      
      public static function isVIPBadge(param1:int) : Boolean
      {
         var _loc2_:* = param1 >> 8 & 0xFF;
         return _loc2_ + 1 == BADGE_ID_VIP_CAMERA;
      }
      
      public function destroy() : void
      {
         removeListeners();
      }
      
      public function set isBlocked(param1:Boolean) : void
      {
         _isBlocked = param1;
         if(_nubType != GUIDE)
         {
            _right.blocked.visible = _isBlocked;
         }
      }
      
      public function set isHostingCustomParty(param1:Boolean) : void
      {
         if(_host)
         {
            this["hostTag"].visible = param1;
         }
      }
      
      public function get hostTagMC() : MovieClip
      {
         return this["hostTag"];
      }
      
      public function setColorAndBadge(param1:int) : void
      {
         _packedNameBarData = param1;
         var _loc2_:* = param1 & 0xFF;
         var _loc3_:* = param1 >> 8 & 0xFF;
         _badgeId = _loc3_ + 1;
         if(_left)
         {
            setColor(_loc2_);
            if(_isMemberNamebar)
            {
               setBadgeIcon(_loc3_);
            }
         }
      }
      
      public function setColorBadgeAndXp(param1:int, param2:int, param3:Boolean, param4:Boolean = false) : void
      {
         setColorAndBadge(param1);
         var _loc5_:Boolean = (param1 >> 16 & 0x0F) == 0 && param3;
         _isMember = param3;
         if(param2 > 0 && (param4 || _loc5_))
         {
            if(_currShapeMouse && _currShapeMouse.level != null && _currShapeMouse.level == param2)
            {
               setCurrShape();
            }
            else if(param2 > 0)
            {
               setShape(param2);
            }
         }
         else
         {
            while(_shape.mouse.up.icon.numChildren > 0)
            {
               _shape.mouse.up.icon.removeChildAt(0);
            }
            while(_shape.mouse.mouse.icon.numChildren > 0)
            {
               _shape.mouse.mouse.icon.removeChildAt(0);
            }
         }
      }
      
      public function setNubType(param1:String, param2:Boolean = true) : void
      {
         nubType = param1;
         resize(param2,-1);
      }
      
      public function setAvName(param1:Object, param2:Boolean = false, param3:Object = null, param4:Boolean = true, param5:Number = -1) : void
      {
         if(param2)
         {
            if(param3 != null)
            {
               _avNameTxt.text = param3.getModeratedUserName();
            }
            else if(param1 is String)
            {
               _avNameTxt.text = String(param1);
            }
            else
            {
               _avNameTxt.text = param1.avName;
            }
         }
         else if(param1 is String)
         {
            _avNameTxt.text = String(param1);
         }
         else
         {
            _avNameTxt.text = param1.avName;
         }
         resize(param4,param5);
      }
      
      public function removeShape() : void
      {
         while(_shape.mouse.up.icon.numChildren > 0)
         {
            _shape.mouse.up.icon.removeChildAt(0);
         }
         while(_shape.mouse.mouse.icon.numChildren > 0)
         {
            _shape.mouse.mouse.icon.removeChildAt(0);
         }
      }
      
      public function updateMeter(param1:int) : void
      {
         setMeter(param1);
      }
      
      public function getMeterValue() : int
      {
         if(this["meter"])
         {
            return this["meter"].hpBar.width;
         }
         return 0;
      }
      
      public function removeListeners() : void
      {
         removeEventListener("rollOver",onOverHandler);
         removeEventListener("rollOut",onOutHandler);
      }
      
      public function get iconIds() : Array
      {
         return _iconIdsArray;
      }
      
      public function set iconIds(param1:Array) : void
      {
         _iconIdsArray = param1;
      }
      
      public function get packedNameBarData() : int
      {
         return _packedNameBarData;
      }
      
      public function get xpShapeIcons() : Object
      {
         return {
            "mouseIcon":_currShapeMouse,
            "upIcon":_currShapeUp
         };
      }
      
      public function set xpShapeIcons(param1:Object) : void
      {
         _currShapeMouse = param1.mouseIcon;
         _currShapeUp = param1.upIcon;
         if(_currShapeMouse && _currShapeMouse.level != null)
         {
            setShape(_currShapeMouse.level);
         }
      }
      
      public function get currentLevel() : int
      {
         if(_currShapeMouse && _currShapeMouse.level != null)
         {
            return _currShapeMouse.level;
         }
         return 0;
      }
      
      private function setColor(param1:int) : void
      {
         if(param1 == 0)
         {
            _currColorId = 4;
         }
         else if(param1 > 3 && param1 < 10)
         {
            _currColorId = param1 + 1;
         }
         else
         {
            _currColorId = Math.min(4,param1);
         }
         if(_isMemberNamebar)
         {
            this["updateColor"](_currColorId);
         }
      }
      
      private function setBadgeIcon(param1:int) : void
      {
         var _loc2_:int = 0;
         if(_iconIdsArray.length > 0)
         {
            if(this["selnub"].currentFrameLabel == "buddy")
            {
               while(_right.nub.mouse.mouse.light.numChildren > 0)
               {
                  _right.nub.mouse.mouse.light.removeChildAt(0);
               }
               while(_right.nub.mouse.up.light.numChildren > 0)
               {
                  _right.nub.mouse.up.light.removeChildAt(0);
               }
               _loc2_ = int(_iconIdsArray[param1]);
               param1 *= 2;
               if(param1 % 2 != 0)
               {
                  param1++;
               }
               if(_iconImages[param1] && _iconImages[param1 + 1])
               {
                  _right.nub.mouse.mouse.light.addChild(_iconImages[param1]);
                  _right.nub.mouse.up.light.addChild(_iconImages[param1 + 1]);
                  if(_isMemberNamebar)
                  {
                     this["updateColor"](_currColorId);
                  }
               }
               else
               {
                  loadIcon(_loc2_,param1);
               }
            }
         }
         else
         {
            _nameBarDataToBeLoaded = _packedNameBarData;
         }
      }
      
      private function set nubType(param1:String) : void
      {
         if(param1 == "")
         {
            _right.visible = false;
         }
         else
         {
            _right.visible = true;
            _nubType = param1;
            _right.gotoAndStop(_nubType);
            if(_isMemberNamebar)
            {
               this["updateColor"](_currColorId);
            }
            if(_isBlocked && _nubType != GUIDE)
            {
               _right.blocked.gotoAndStop(1);
            }
         }
      }
      
      private function resize(param1:Boolean, param2:Number) : void
      {
         var _loc3_:int = 0;
         var _loc7_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc4_:MovieClip = null;
         var _loc6_:MovieClip = null;
         if(param1)
         {
            _loc7_ = _mid.parent != this ? MovieClip(_mid.parent) : _mid;
            _loc5_ = _left.parent != this ? MovieClip(_left.parent) : _left;
            _loc4_ = _shape && _shape.parent != this ? MovieClip(_shape.parent) : _shape;
            _loc6_ = _meter && _meter.parent != this ? MovieClip(_meter.parent) : _meter;
            if(_nubType == NON_BUDDY && !_isBlocked)
            {
               _loc3_ = 10;
            }
            else
            {
               _loc3_ = 20;
            }
            _avNameTxt.width = 300;
            if(param2 > 0)
            {
               _loc7_.width = param2;
            }
            else if(_avNameTxt.textWidth + _loc3_ < 60)
            {
               _loc7_.width = 60 + 0.5 * _right.width;
            }
            else
            {
               _loc7_.width = Math.ceil(_avNameTxt.textWidth + _loc3_);
            }
            _loc7_.x = _loc7_.width * 0.5 * -1;
            _avNameTxt.width = _loc7_.width - _loc3_ + 5;
            _loc5_.x = _loc7_.x - _loc5_.width;
            _avName.x = _loc7_.x + (_isMember ? 2 : -2);
            _right.x = _loc7_.x + _loc7_.width - 1;
            if(_loc4_)
            {
               _loc4_.x = _loc5_.x;
            }
            if(_loc6_)
            {
               _loc6_.width = _avNameTxt.width + 18;
               _loc6_.x = _avName.x - 7;
            }
         }
         _left.mouse.gotoAndStop(1);
         _mid.mouse.gotoAndStop(1);
         _right.nub.mouse.gotoAndStop(1);
         if(_shape)
         {
            _shape.mouse.gotoAndStop(1);
         }
      }
      
      private function loadIcon(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2);
         _iconsMediaHelperArray[param2] = _loc3_;
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2 + 1);
         _iconsMediaHelperArray[param2 + 1] = _loc3_;
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         if(param1)
         {
            param1.cacheAsBitmap = true;
            _loc2_ = int(param1.passback);
            _iconImages[_loc2_] = param1;
            if(_loc2_ % 2 == 0)
            {
               _loc3_ = _right.nub.mouse.mouse.light;
               while(_loc3_.numChildren > 0)
               {
                  _loc3_.removeChildAt(0);
               }
               _loc3_.addChild(param1);
            }
            else
            {
               _loc3_ = _right.nub.mouse.up.light;
               while(_loc3_.numChildren > 0)
               {
                  _loc3_.removeChildAt(0);
               }
               _loc3_.addChild(param1);
            }
            if(_iconsMediaHelperArray[_loc2_])
            {
               _iconsMediaHelperArray[_loc2_].destroy();
               _iconsMediaHelperArray[_loc2_] = null;
               delete _iconsMediaHelperArray[_loc2_];
            }
            if(_isMemberNamebar)
            {
               this["updateColor"](_currColorId);
            }
         }
      }
      
      private function setCurrShape() : void
      {
         while(_shape.mouse.up.icon.numChildren > 0)
         {
            _shape.mouse.up.icon.removeChildAt(0);
         }
         _shape.mouse.up.icon.addChild(_currShapeUp);
         while(_shape.mouse.mouse.icon.numChildren > 0)
         {
            _shape.mouse.mouse.icon.removeChildAt(0);
         }
         _shape.mouse.mouse.icon.addChild(_currShapeMouse);
      }
      
      private function setShape(param1:int) : void
      {
         var _loc2_:int = 0;
         if(param1 > 0)
         {
            if(_currShapeMouse == null || _currShapeMouse.level != param1 && Math.floor(_currShapeMouse.level / 5) != Math.floor(param1 / 5))
            {
               _loc2_ = int(Math.floor(param1 / 5) > LEVEL_SHAPES.length - 1 ? LEVEL_SHAPES[LEVEL_SHAPES.length - 1] : LEVEL_SHAPES[Math.floor(param1 / 5)]);
               _levelShapeHelper = new MediaHelper();
               _shapesMediaHelperArray.push(_levelShapeHelper);
               _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,-1);
               _levelShapeHelper = new MediaHelper();
               _shapesMediaHelperArray.push(_levelShapeHelper);
               _levelShapeHelper.init(_loc2_,onLevelShapeLoaded,param1);
            }
            else
            {
               while(_shape.mouse.up.icon.numChildren > 0)
               {
                  _shape.mouse.up.icon.removeChildAt(0);
               }
               _shape.mouse.up.icon.addChild(_currShapeUp);
               while(_shape.mouse.mouse.icon.numChildren > 0)
               {
                  _shape.mouse.mouse.icon.removeChildAt(0);
               }
               _shape.mouse.mouse.icon.addChild(_currShapeMouse);
               _currShapeMouse.dark.text.text = param1;
               _currShapeUp.dark.text.text = param1;
               if(_isMemberNamebar)
               {
                  this["updateColor"](_currColorId);
               }
            }
         }
         else
         {
            while(_shape.mouse.up.icon.numChildren > 0)
            {
               _shape.mouse.up.icon.removeChildAt(0);
            }
            while(_shape.mouse.mouse.icon.numChildren > 0)
            {
               _shape.mouse.mouse.icon.removeChildAt(0);
            }
         }
      }
      
      private function onLevelShapeLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            _loc2_ = MovieClip(param1.getChildAt(0));
            if(param1.passback == -1)
            {
               _currShapeUp = _loc2_;
               if(_isMember)
               {
                  _currShapeUp.gotoAndStop("member");
               }
               if(_currShapeMouse)
               {
                  _currShapeUp.dark.text.text = _currShapeMouse.level;
               }
               _shapesMediaHelperArray[0].destroy();
               _shapesMediaHelperArray.splice(0,1);
               while(_shape.mouse.up.icon.numChildren > 0)
               {
                  _shape.mouse.up.icon.removeChildAt(0);
               }
               _shape.mouse.up.icon.addChild(_currShapeUp);
            }
            else
            {
               _currShapeMouse = _loc2_;
               if(_isMember)
               {
                  _currShapeMouse.gotoAndStop("member");
               }
               _currShapeMouse.level = _currShapeMouse.dark.text.text = param1.passback;
               if(_currShapeUp)
               {
                  _currShapeUp.dark.text.text = _currShapeMouse.level;
               }
               _shapesMediaHelperArray[_shapesMediaHelperArray.length - 1].destroy();
               _shapesMediaHelperArray.pop();
               while(_shape.mouse.mouse.icon.numChildren > 0)
               {
                  _shape.mouse.mouse.icon.removeChildAt(0);
               }
               _shape.mouse.mouse.icon.addChild(_currShapeMouse);
            }
            _shape.mouse.gotoAndStop(1);
            if(_isMemberNamebar)
            {
               this["updateColor"](_currColorId);
            }
         }
      }
      
      private function setMeter(param1:int) : void
      {
         if(this["meter"])
         {
            this["meter"].hpBar.width = this["meter"].hpBarContainer.width * (param1 / 100);
         }
      }
      
      private function onOverHandler(param1:MouseEvent) : void
      {
         _left.mouse.gotoAndPlay(1);
         _mid.mouse.gotoAndPlay(1);
         if(_shape)
         {
            _shape.mouse.gotoAndPlay(1);
         }
         if(_host)
         {
            _host.mouse.gotoAndPlay(1);
         }
         _right.nub.mouse.gotoAndPlay(1);
         if(_isBlocked && _nubType != GUIDE)
         {
            _right.blocked.mouse.gotoAndPlay(1);
         }
      }
      
      private function onOutHandler(param1:MouseEvent) : void
      {
         if(_left.mouse.currentFrame > 1)
         {
            playBackwards(_left.mouse);
         }
         else
         {
            _left.mouse.stop();
         }
         if(_mid.mouse.currentFrame > 1)
         {
            playBackwards(_mid.mouse);
         }
         else
         {
            _mid.mouse.stop();
         }
         if(_shape)
         {
            if(_shape.mouse.currentFrame > 1)
            {
               playBackwards(_shape.mouse);
            }
            else
            {
               _shape.mouse.stop();
            }
         }
         if(_host)
         {
            if(_host.mouse.currentFrame > 1)
            {
               playBackwards(_host.mouse);
            }
            else
            {
               _host.mouse.stop();
            }
         }
         if(_right.nub.mouse.currentFrame > 1)
         {
            playBackwards(_right.nub.mouse);
         }
         else
         {
            _right.nub.mouse.stop();
         }
         if(_isBlocked && _nubType != GUIDE)
         {
            if(_right.blocked.mouse.currentFrame > 1)
            {
               playBackwards(_right.blocked.mouse);
            }
            else
            {
               _right.blocked.mouse.stop();
            }
         }
      }
      
      private function playBackwards(param1:MovieClip) : void
      {
         param1.addEventListener("enterFrame",pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == 1)
            {
               _loc2_.removeEventListener("enterFrame",pbFrameHandler);
               return;
            }
            _loc2_.prevFrame();
         }
      }
   }
}

