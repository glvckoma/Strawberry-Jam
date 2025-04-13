package com.greensock
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Transform;
   
   public class BlitMask extends Sprite
   {
      public static var version:Number = 0.62;
      
      protected static var _tempContainer:Sprite = new Sprite();
      
      protected static var _sliceRect:Rectangle = new Rectangle();
      
      protected static var _drawRect:Rectangle = new Rectangle();
      
      protected static var _destPoint:Point = new Point();
      
      protected static var _tempMatrix:Matrix = new Matrix();
      
      protected static var _emptyArray:Array = [];
      
      protected static var _colorTransform:ColorTransform = new ColorTransform();
      
      protected static var _mouseEvents:Array = ["click","doubleClick","mouseDown","mouseMove","mouseOut","mouseOver","mouseUp","mouseWheel","rollOut","rollOver","gesturePressAndTap","gesturePan","gestureRotate","gestureSwipe","gestureZoom","gestureTwoFingerTap","touchBegin","touchEnd","touchMove","touchOut","touchOver","touchRollOut","touchRollOver","touchTap"];
      
      protected var _target:DisplayObject;
      
      protected var _fillColor:uint;
      
      protected var _smoothing:Boolean;
      
      protected var _width:Number;
      
      protected var _height:Number;
      
      protected var _bd:BitmapData;
      
      protected var _gridSize:int = 2879;
      
      protected var _grid:Array;
      
      protected var _bounds:Rectangle;
      
      protected var _clipRect:Rectangle;
      
      protected var _bitmapMode:Boolean;
      
      protected var _rows:int;
      
      protected var _columns:int;
      
      protected var _scaleX:Number;
      
      protected var _scaleY:Number;
      
      protected var _prevMatrix:Matrix;
      
      protected var _transform:Transform;
      
      protected var _prevRotation:Number;
      
      protected var _autoUpdate:Boolean;
      
      protected var _wrap:Boolean;
      
      protected var _wrapOffsetX:Number = 0;
      
      protected var _wrapOffsetY:Number = 0;
      
      public function BlitMask(param1:DisplayObject, param2:Number = 0, param3:Number = 0, param4:Number = 100, param5:Number = 100, param6:Boolean = false, param7:Boolean = false, param8:uint = 0, param9:Boolean = false)
      {
         super();
         if(param4 < 0 || param5 < 0)
         {
            throw new Error("A FlexBlitMask cannot have a negative width or height.");
         }
         _width = param4;
         _height = param5;
         _scaleX = _scaleY = 1;
         _smoothing = param6;
         _fillColor = param8;
         _autoUpdate = param7;
         _wrap = param9;
         _grid = [];
         _bounds = new Rectangle();
         if(_smoothing)
         {
            super.x = param2;
            super.y = param3;
         }
         else
         {
            super.x = param2 < 0 ? param2 - 0.5 >> 0 : param2 + 0.5 >> 0;
            super.y = param3 < 0 ? param3 - 0.5 >> 0 : param3 + 0.5 >> 0;
         }
         _clipRect = new Rectangle(0,0,_gridSize + 1,_gridSize + 1);
         _bd = new BitmapData(param4 + 1,param5 + 1,true,_fillColor);
         _bitmapMode = true;
         this.target = param1;
      }
      
      protected function _captureTargetBitmap() : void
      {
         var _loc1_:Number = NaN;
         var _loc4_:BitmapData = null;
         var _loc12_:int = 0;
         var _loc7_:int = 0;
         if(_bd == null || _target == null)
         {
            return;
         }
         _disposeGrid();
         var _loc11_:DisplayObject = _target.mask;
         if(_loc11_ != null)
         {
            _target.mask = null;
         }
         var _loc2_:Rectangle = _target.scrollRect;
         if(_loc2_ != null)
         {
            _target.scrollRect = null;
         }
         var _loc13_:Array = _target.filters;
         if(_loc13_.length != 0)
         {
            _target.filters = _emptyArray;
         }
         _grid = [];
         if(_target.parent == null)
         {
            _tempContainer.addChild(_target);
         }
         _bounds = _target.getBounds(_target.parent);
         var _loc10_:Number = 0;
         var _loc6_:Number = 0;
         _columns = Math.ceil(_bounds.width / _gridSize);
         _rows = Math.ceil(_bounds.height / _gridSize);
         var _loc8_:Number = 0;
         var _loc9_:Matrix = _transform.matrix;
         var _loc5_:Number = _loc9_.tx - _bounds.x;
         var _loc3_:Number = _loc9_.ty - _bounds.y;
         if(!_smoothing)
         {
            _loc5_ = _loc5_ + 0.5 >> 0;
            _loc3_ = _loc3_ + 0.5 >> 0;
         }
         _loc12_ = 0;
         while(_loc12_ < _rows)
         {
            _loc6_ = Number(_bounds.height - _loc8_ > _gridSize ? _gridSize : _bounds.height - _loc8_);
            _loc9_.ty = -_loc8_ + _loc3_;
            _loc1_ = 0;
            _grid[_loc12_] = [];
            _loc7_ = 0;
            while(_loc7_ < _columns)
            {
               _loc10_ = Number(_bounds.width - _loc1_ > _gridSize ? _gridSize : _bounds.width - _loc1_);
               _grid[_loc12_][_loc7_] = _loc4_ = new BitmapData(_loc10_ + 1,_loc6_ + 1,true,_fillColor);
               _loc9_.tx = -_loc1_ + _loc5_;
               _loc4_.draw(_target,_loc9_,null,null,_clipRect,_smoothing);
               _loc1_ += _loc10_;
               _loc7_++;
            }
            _loc8_ += _loc6_;
            _loc12_++;
         }
         if(_target.parent == _tempContainer)
         {
            _tempContainer.removeChild(_target);
         }
         if(_loc11_ != null)
         {
            _target.mask = _loc11_;
         }
         if(_loc2_ != null)
         {
            _target.scrollRect = _loc2_;
         }
         if(_loc13_.length != 0)
         {
            _target.filters = _loc13_;
         }
      }
      
      protected function _disposeGrid() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Array = null;
         var _loc2_:int = int(_grid.length);
         while(true)
         {
            _loc2_--;
            if(_loc2_ <= -1)
            {
               break;
            }
            _loc1_ = _grid[_loc2_];
            _loc3_ = int(_loc1_.length);
            while(true)
            {
               _loc3_--;
               if(_loc3_ <= -1)
               {
                  break;
               }
               BitmapData(_loc1_[_loc3_]).dispose();
            }
         }
      }
      
      public function update(param1:Event = null, param2:Boolean = false) : void
      {
         var _loc3_:Matrix = null;
         if(_bd == null)
         {
            return;
         }
         if(_target == null)
         {
            _render();
         }
         else if(_target.parent)
         {
            _bounds = _target.getBounds(_target.parent);
            if(this.parent != _target.parent)
            {
               _target.parent.addChildAt(this,_target.parent.getChildIndex(_target));
            }
         }
         if(_bitmapMode || param2)
         {
            _loc3_ = _transform.matrix;
            if(param2 || _prevMatrix == null || _loc3_.a != _prevMatrix.a || _loc3_.b != _prevMatrix.b || _loc3_.c != _prevMatrix.c || _loc3_.d != _prevMatrix.d)
            {
               _captureTargetBitmap();
               _render();
            }
            else if(_loc3_.tx != _prevMatrix.tx || _loc3_.ty != _prevMatrix.ty)
            {
               _render();
            }
            else if(_bitmapMode && _target != null)
            {
               this.filters = _target.filters;
               this.transform.colorTransform = _transform.colorTransform;
            }
            _prevMatrix = _loc3_;
         }
      }
      
      protected function _render(param1:Number = 0, param2:Number = 0, param3:Boolean = true, param4:Boolean = false) : void
      {
         var _loc11_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc16_:* = 0;
         var _loc5_:BitmapData = null;
         if(param3)
         {
            _sliceRect.y = 0;
            _sliceRect.x = 0;
            _sliceRect.width = _width + 1;
            _sliceRect.height = _height + 1;
            _bd.fillRect(_sliceRect,_fillColor);
            if(_bitmapMode && _target != null)
            {
               this.filters = _target.filters;
               this.transform.colorTransform = _transform.colorTransform;
            }
            else
            {
               this.filters = _emptyArray;
               this.transform.colorTransform = _colorTransform;
            }
         }
         if(_bd == null)
         {
            return;
         }
         if(_rows == 0)
         {
            _captureTargetBitmap();
         }
         var _loc13_:Number = super.x + param1;
         var _loc15_:Number = super.y + param2;
         var _loc10_:* = _bounds.width + _wrapOffsetX + 0.5 >> 0;
         var _loc12_:* = _bounds.height + _wrapOffsetY + 0.5 >> 0;
         var _loc8_:Graphics = this.graphics;
         if(_bounds.width == 0 || _bounds.height == 0 || _wrap && (_loc10_ == 0 || _loc12_ == 0) || !_wrap && (_loc13_ + _width < _bounds.x || _loc15_ + _height < _bounds.y || _loc13_ > _bounds.right || _loc15_ > _bounds.bottom))
         {
            _loc8_.clear();
            _loc8_.beginBitmapFill(_bd);
            _loc8_.drawRect(0,0,_width,_height);
            _loc8_.endFill();
            return;
         }
         var _loc9_:* = int((_loc13_ - _bounds.x) / _gridSize);
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         var _loc17_:int = (_loc15_ - _bounds.y) / _gridSize;
         if(_loc17_ < 0)
         {
            _loc17_ = 0;
         }
         var _loc18_:int = (_loc13_ + _width - _bounds.x) / _gridSize;
         if(_loc18_ >= _columns)
         {
            _loc18_ = _columns - 1;
         }
         var _loc14_:uint = uint(int((_loc15_ + _height - _bounds.y) / _gridSize));
         if(_loc14_ >= _rows)
         {
            _loc14_ = uint(_rows - 1);
         }
         var _loc6_:Number = (_bounds.x - _loc13_) % 1;
         var _loc19_:Number = (_bounds.y - _loc15_) % 1;
         if(_loc15_ <= _bounds.y)
         {
            _destPoint.y = _bounds.y - _loc15_ >> 0;
            _sliceRect.y = -1;
         }
         else
         {
            _destPoint.y = 0;
            _sliceRect.y = Math.ceil(_loc15_ - _bounds.y) - _loc17_ * _gridSize - 1;
            if(param3 && _loc19_ != 0)
            {
               _loc19_ += 1;
            }
         }
         if(_loc13_ <= _bounds.x)
         {
            _destPoint.x = _bounds.x - _loc13_ >> 0;
            _sliceRect.x = -1;
         }
         else
         {
            _destPoint.x = 0;
            _sliceRect.x = Math.ceil(_loc13_ - _bounds.x) - _loc9_ * _gridSize - 1;
            if(param3 && _loc6_ != 0)
            {
               _loc6_ += 1;
            }
         }
         if(_wrap && param3)
         {
            _render(Math.ceil((_bounds.x - _loc13_) / _loc10_) * _loc10_,Math.ceil((_bounds.y - _loc15_) / _loc12_) * _loc12_,false,false);
         }
         else if(_rows != 0)
         {
            _loc11_ = _destPoint.x;
            _loc7_ = _sliceRect.x;
            _loc16_ = _loc9_;
            while(_loc17_ <= _loc14_)
            {
               _loc5_ = _grid[_loc17_][0];
               _sliceRect.height = _loc5_.height - _sliceRect.y;
               _destPoint.x = _loc11_;
               _sliceRect.x = _loc7_;
               _loc9_ = _loc16_;
               while(_loc9_ <= _loc18_)
               {
                  _loc5_ = _grid[_loc17_][_loc9_];
                  _sliceRect.width = _loc5_.width - _sliceRect.x;
                  _bd.copyPixels(_loc5_,_sliceRect,_destPoint);
                  _destPoint.x += _sliceRect.width - 1;
                  _sliceRect.x = 0;
                  _loc9_++;
               }
               _destPoint.y += _sliceRect.height - 1;
               _sliceRect.y = 0;
               _loc17_++;
            }
         }
         if(param3)
         {
            _tempMatrix.tx = _loc6_ - 1;
            _tempMatrix.ty = _loc19_ - 1;
            _loc8_.clear();
            _loc8_.beginBitmapFill(_bd,_tempMatrix,false,_smoothing);
            _loc8_.drawRect(0,0,_width,_height);
            _loc8_.endFill();
         }
         else if(_wrap)
         {
            if(_loc13_ + _width > _bounds.right)
            {
               _render(param1 - _loc10_,param2,false,true);
            }
            if(!param4 && _loc15_ + _height > _bounds.bottom)
            {
               _render(param1,param2 - _loc12_,false,false);
            }
         }
      }
      
      public function setSize(param1:Number, param2:Number) : void
      {
         if(_width == param1 && _height == param2)
         {
            return;
         }
         if(param1 < 0 || param2 < 0)
         {
            throw new Error("A BlitMask cannot have a negative width or height.");
         }
         if(_bd != null)
         {
            _bd.dispose();
         }
         _width = param1;
         _height = param2;
         _bd = new BitmapData(param1 + 1,param2 + 1,true,_fillColor);
         _render();
      }
      
      protected function _mouseEventPassthrough(param1:Event) : void
      {
         if(this.mouseEnabled && (!_bitmapMode || param1 is MouseEvent && this.hitTestPoint(MouseEvent(param1).stageX,MouseEvent(param1).stageY,false)))
         {
            dispatchEvent(param1);
         }
      }
      
      public function enableBitmapMode(param1:Event = null) : void
      {
         this.bitmapMode = true;
      }
      
      public function disableBitmapMode(param1:Event = null) : void
      {
         this.bitmapMode = false;
      }
      
      public function normalizePosition() : void
      {
         var _loc1_:* = 0;
         var _loc4_:* = 0;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_target && _bounds)
         {
            _loc1_ = _bounds.width + _wrapOffsetX + 0.5 >> 0;
            _loc4_ = _bounds.height + _wrapOffsetY + 0.5 >> 0;
            _loc2_ = (_bounds.x - this.x) % _loc1_;
            _loc3_ = (_bounds.y - this.y) % _loc4_;
            if(_loc2_ > (_width + _wrapOffsetX) / 2)
            {
               _loc2_ -= _loc1_;
            }
            else if(_loc2_ < (_width + _wrapOffsetX) / -2)
            {
               _loc2_ += _loc1_;
            }
            if(_loc3_ > (_height + _wrapOffsetY) / 2)
            {
               _loc3_ -= _loc4_;
            }
            else if(_loc3_ < (_height + _wrapOffsetY) / -2)
            {
               _loc3_ += _loc4_;
            }
            _target.x += this.x + _loc2_ - _bounds.x;
            _target.y += this.y + _loc3_ - _bounds.y;
         }
      }
      
      public function dispose() : void
      {
         if(_bd == null)
         {
            return;
         }
         _disposeGrid();
         _bd.dispose();
         _bd = null;
         this.bitmapMode = false;
         this.autoUpdate = false;
         if(_target != null)
         {
            _target.mask = null;
         }
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         this.target = null;
      }
      
      public function get bitmapMode() : Boolean
      {
         return _bitmapMode;
      }
      
      public function set bitmapMode(param1:Boolean) : void
      {
         if(_bitmapMode != param1)
         {
            _bitmapMode = param1;
            if(_target != null)
            {
               _target.visible = !_bitmapMode;
               update(null);
               if(_bitmapMode)
               {
                  this.filters = _target.filters;
                  this.transform.colorTransform = _transform.colorTransform;
                  this.blendMode = _target.blendMode;
                  _target.mask = null;
               }
               else
               {
                  this.filters = _emptyArray;
                  this.transform.colorTransform = _colorTransform;
                  this.blendMode = "normal";
                  this.cacheAsBitmap = false;
                  _target.mask = this;
                  if(_wrap)
                  {
                     normalizePosition();
                  }
               }
               if(_bitmapMode && _autoUpdate)
               {
                  this.addEventListener("enterFrame",update,false,-10,true);
               }
               else
               {
                  this.removeEventListener("enterFrame",update);
               }
            }
         }
      }
      
      public function get autoUpdate() : Boolean
      {
         return _autoUpdate;
      }
      
      public function set autoUpdate(param1:Boolean) : void
      {
         if(_autoUpdate != param1)
         {
            _autoUpdate = param1;
            if(_bitmapMode && _autoUpdate)
            {
               this.addEventListener("enterFrame",update,false,-10,true);
            }
            else
            {
               this.removeEventListener("enterFrame",update);
            }
         }
      }
      
      public function get target() : DisplayObject
      {
         return _target;
      }
      
      public function set target(param1:DisplayObject) : void
      {
         if(_target != param1)
         {
            _target = param1;
            if(_target != null)
            {
               _prevMatrix = null;
               _transform = _target.transform;
               _bitmapMode = !_bitmapMode;
               this.bitmapMode = !_bitmapMode;
            }
            else
            {
               _bounds = new Rectangle();
            }
         }
      }
      
      override public function get x() : Number
      {
         return super.x;
      }
      
      override public function set x(param1:Number) : void
      {
         if(_smoothing)
         {
            super.x = param1;
         }
         else if(param1 >= 0)
         {
            super.x = param1 + 0.5 >> 0;
         }
         else
         {
            super.x = param1 - 0.5 >> 0;
         }
         if(_bitmapMode)
         {
            _render();
         }
      }
      
      override public function get y() : Number
      {
         return super.y;
      }
      
      override public function set y(param1:Number) : void
      {
         if(_smoothing)
         {
            super.y = param1;
         }
         else if(param1 >= 0)
         {
            super.y = param1 + 0.5 >> 0;
         }
         else
         {
            super.y = param1 - 0.5 >> 0;
         }
         if(_bitmapMode)
         {
            _render();
         }
      }
      
      override public function get width() : Number
      {
         return _width;
      }
      
      override public function set width(param1:Number) : void
      {
         setSize(param1,_height);
      }
      
      override public function get height() : Number
      {
         return _height;
      }
      
      override public function set height(param1:Number) : void
      {
         setSize(_width,param1);
      }
      
      override public function get scaleX() : Number
      {
         return 1;
      }
      
      override public function set scaleX(param1:Number) : void
      {
         var _loc2_:Number = _scaleX;
         _scaleX = param1;
         setSize(_width * (_scaleX / _loc2_),_height);
      }
      
      override public function get scaleY() : Number
      {
         return 1;
      }
      
      override public function set scaleY(param1:Number) : void
      {
         var _loc2_:Number = _scaleY;
         _scaleY = param1;
         setSize(_width,_height * (_scaleY / _loc2_));
      }
      
      override public function set rotation(param1:Number) : void
      {
         if(param1 != 0)
         {
            throw new Error("Cannot set the rotation of a BlitMask to a non-zero number. BlitMasks should remain unrotated.");
         }
      }
      
      public function get scrollX() : Number
      {
         return (super.x - _bounds.x) / (_bounds.width - _width);
      }
      
      public function set scrollX(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_target != null && _target.parent)
         {
            _bounds = _target.getBounds(_target.parent);
            _loc2_ = super.x - (_bounds.width - _width) * param1 - _bounds.x;
            _target.x += _loc2_;
            _bounds.x += _loc2_;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get scrollY() : Number
      {
         return (super.y - _bounds.y) / (_bounds.height - _height);
      }
      
      public function set scrollY(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_target != null && _target.parent)
         {
            _bounds = _target.getBounds(_target.parent);
            _loc2_ = super.y - (_bounds.height - _height) * param1 - _bounds.y;
            _target.y += _loc2_;
            _bounds.y += _loc2_;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get smoothing() : Boolean
      {
         return _smoothing;
      }
      
      public function set smoothing(param1:Boolean) : void
      {
         if(_smoothing != param1)
         {
            _smoothing = param1;
            _captureTargetBitmap();
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get fillColor() : uint
      {
         return _fillColor;
      }
      
      public function set fillColor(param1:uint) : void
      {
         if(_fillColor != param1)
         {
            _fillColor = param1;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get wrap() : Boolean
      {
         return _wrap;
      }
      
      public function set wrap(param1:Boolean) : void
      {
         if(_wrap != param1)
         {
            _wrap = param1;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get wrapOffsetX() : Number
      {
         return _wrapOffsetX;
      }
      
      public function set wrapOffsetX(param1:Number) : void
      {
         if(_wrapOffsetX != param1)
         {
            _wrapOffsetX = param1;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
      
      public function get wrapOffsetY() : Number
      {
         return _wrapOffsetY;
      }
      
      public function set wrapOffsetY(param1:Number) : void
      {
         if(_wrapOffsetY != param1)
         {
            _wrapOffsetY = param1;
            if(_bitmapMode)
            {
               _render();
            }
         }
      }
   }
}

