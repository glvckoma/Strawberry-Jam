package com.sbi.graphics
{
   import com.sbi.corelib.Set;
   import com.sbi.loader.ImageServerURL;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   
   public class LayerBitmap extends Bitmap
   {
      public static const BACKGROUND_COLOR:uint = 0;
      
      private var _anchorPoint:Point;
      
      private var _activeLayerGroup:LayerGroup;
      
      private var _bmin:Point;
      
      private var _bmax:Point;
      
      private var _lastFrame:int;
      
      private var _lastHFlip:Boolean;
      
      private var _blendColor:uint;
      
      private var _cachedLayerGroups:Dictionary;
      
      private var _currCacheKey:String;
      
      public function LayerBitmap()
      {
         super();
         _activeLayerGroup = new LayerGroup();
         _anchorPoint = new Point();
         _bmin = new Point();
         _bmax = new Point();
         _cachedLayerGroups = new Dictionary();
      }
      
      public function destroy() : void
      {
         if(_currCacheKey == null)
         {
            _activeLayerGroup.destroy();
         }
         for each(var _loc1_ in _cachedLayerGroups)
         {
            _loc1_.destroy();
         }
         _cachedLayerGroups = null;
         if(this.bitmapData)
         {
            this.bitmapData.dispose();
            this.bitmapData = null;
         }
      }
      
      public function get length() : int
      {
         return _activeLayerGroup.length;
      }
      
      public function release() : void
      {
         for each(var _loc1_ in _cachedLayerGroups)
         {
            _loc1_.destroy();
         }
         _cachedLayerGroups = new Dictionary();
         if(_currCacheKey == null)
         {
            _activeLayerGroup.destroy();
         }
         else
         {
            _currCacheKey = null;
         }
         _activeLayerGroup = new LayerGroup();
         invalidate();
         _lastHFlip = false;
      }
      
      public function invalidate() : void
      {
         _lastFrame = -1;
      }
      
      public function trimLayerGroups() : Set
      {
         var _loc3_:LayerGroup = null;
         var _loc2_:Set = new Set();
         for(var _loc4_ in _cachedLayerGroups)
         {
            if(_loc4_ != _currCacheKey)
            {
               _loc3_ = _cachedLayerGroups[_loc4_];
               if(_loc3_.decrementTtl() < 1)
               {
                  delete _cachedLayerGroups[_loc4_];
                  _loc3_.destroy();
                  continue;
               }
            }
            for each(var _loc1_ in String(_loc4_).split(","))
            {
               _loc2_.add(_loc1_);
            }
         }
         return _loc2_;
      }
      
      public function setLayer(param1:int, param2:Object, param3:uint, param4:String = null) : void
      {
         if(param1 < 0 || param1 > 10)
         {
            return;
         }
         if(param4 != null)
         {
            if(param4 != _currCacheKey)
            {
               if(_currCacheKey == null)
               {
                  _cachedLayerGroups[param4] = _activeLayerGroup;
               }
               else
               {
                  if(!_cachedLayerGroups[param4])
                  {
                     _cachedLayerGroups[param4] = new LayerGroup();
                  }
                  _activeLayerGroup = _cachedLayerGroups[param4];
               }
               _currCacheKey = param4;
            }
         }
         if(param2)
         {
            if(_activeLayerGroup.layers[param1] == null)
            {
               _activeLayerGroup.layers[param1] = {
                  "c":param3,
                  "lastColor":-1,
                  "blendColor":-1
               };
               _activeLayerGroup.checkColors = true;
            }
            else
            {
               setLayerColor(param1,param3);
            }
            _activeLayerGroup.layers[param1].o = param2;
         }
         else
         {
            delete _activeLayerGroup.layers[param1];
            _activeLayerGroup.checkColors = true;
         }
         invalidate();
      }
      
      public function setLayerColor(param1:int, param2:uint) : void
      {
         var _loc3_:Object = _activeLayerGroup.layers[param1];
         if(_loc3_ && param2 != _loc3_.c)
         {
            _loc3_.c = param2;
            _activeLayerGroup.checkColors = true;
         }
      }
      
      public function setBlendColor(param1:uint) : void
      {
         if(_blendColor != param1)
         {
            _blendColor = param1;
            for each(var _loc2_ in _cachedLayerGroups)
            {
               _loc2_.checkColors = true;
            }
         }
      }
      
      public function switchLayerGroup(param1:Array, param2:String = null) : Boolean
      {
         var _loc6_:int = 0;
         var _loc4_:LayerGroup = param2 == null ? _activeLayerGroup : _cachedLayerGroups[param2];
         if(_loc4_ == null || param1 == null)
         {
            return false;
         }
         var _loc3_:ImageServerURL = ImageServerURL.instance;
         for each(var _loc5_ in param1)
         {
            _loc6_ = _loc3_.getLayerIndex(_loc5_.l);
            if(!_loc4_.layers[_loc6_])
            {
               return false;
            }
            if(_loc4_.layers[_loc6_].c != _loc5_.c)
            {
               _loc4_.layers[_loc6_].c = _loc5_.c;
               _loc4_.checkColors = true;
            }
         }
         if(param2 != null && param2 != _currCacheKey)
         {
            _activeLayerGroup = _cachedLayerGroups[param2];
            _currCacheKey = param2;
         }
         invalidate();
         return true;
      }
      
      public function get anchorPoint() : Point
      {
         return _anchorPoint;
      }
      
      private function refreshLayerPalette(param1:int) : Boolean
      {
         var _loc7_:* = false;
         var _loc5_:* = 0;
         var _loc6_:Array = null;
         var _loc8_:* = 0;
         var _loc10_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc9_:Object = _activeLayerGroup.layers[param1];
         if(_loc9_)
         {
            _loc7_ = param1 == 3;
            if(_loc9_.lastColor != _loc9_.c || !_loc7_ && _loc9_.blendColor != _blendColor)
            {
               _loc5_ = uint(_loc9_.c);
               _loc6_ = PaletteHelper.gamePalette;
               _loc8_ = _loc5_ >> 24 & 0xFF;
               _loc10_ = _loc5_ >> 16 & 0xFF;
               _loc2_ = _loc5_ >> 8 & 0xFF;
               _loc3_ = _loc5_ & 0xFF;
               if(!_loc9_.pal)
               {
                  _loc9_.pal = [];
               }
               PaletteHelper.BuildAnimalPalette(_loc9_.pal,_loc6_[_loc8_],_loc6_[_loc10_],_loc6_[_loc2_],_loc6_[_loc3_]);
               if(!_loc7_)
               {
                  _loc4_ = _blendColor >> 24 & 0xFF;
                  if(_loc4_ > 0)
                  {
                     PaletteHelper.adjustPaletteColor(_loc9_.pal,_blendColor);
                  }
                  _loc9_.blendColor = _blendColor;
               }
               _loc9_.lastColor = _loc5_;
               return true;
            }
         }
         return false;
      }
      
      private function refreshAllPalettes() : Boolean
      {
         var _loc2_:Boolean = false;
         for(var _loc1_ in _activeLayerGroup.layers)
         {
            if(_loc1_ > 0)
            {
               if(refreshLayerPalette(_loc1_))
               {
                  _loc2_ = true;
               }
            }
         }
         if(_loc2_)
         {
            _activeLayerGroup.invalidate();
         }
         return _loc2_;
      }
      
      private function calcBounds(param1:int) : void
      {
         var _loc4_:Object = null;
         var _loc10_:Object = null;
         var _loc3_:int = 0;
         var _loc8_:Object = null;
         var _loc2_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         _bmin.setTo(1000,1000);
         _bmax.setTo(0,0);
         for(var _loc7_ in _activeLayerGroup.layers)
         {
            if(_loc7_ != 0)
            {
               _loc4_ = _activeLayerGroup.layers[_loc7_];
               _loc10_ = _loc4_.o;
               if(_loc10_.v != 117967104)
               {
                  return;
               }
               _loc3_ = int(_loc10_.f.length);
               if(param1 < _loc3_)
               {
                  _loc8_ = _loc10_.f[param1];
                  if(_loc8_)
                  {
                     _loc2_ = int(_loc8_.x);
                     _loc9_ = int(_loc8_.y);
                     _loc5_ = int(_loc8_.w);
                     _loc6_ = int(_loc8_.h);
                     if(_loc2_ < _bmin.x)
                     {
                        _bmin.x = _loc2_;
                     }
                     if(_loc9_ < _bmin.y)
                     {
                        _bmin.y = _loc9_;
                     }
                     if(_loc2_ + _loc5_ > _bmax.x)
                     {
                        _bmax.x = _loc2_ + _loc5_;
                     }
                     if(_loc9_ + _loc6_ > _bmax.y)
                     {
                        _bmax.y = _loc9_ + _loc6_;
                     }
                  }
               }
            }
         }
         if(_bmin.x == 1000 || _bmin.y == 1000)
         {
            trace("WARNING: detected frame with unexpected bounds - currCacheKey:" + _currCacheKey + " index:" + param1 + " bmin.x:" + _bmin.x + " bmin.y:" + _bmin.y + " bmax.x:" + _bmax.x + " bmax.y:" + _bmax.y);
            _bmin.copyFrom(_bmax);
         }
      }
      
      private function switchFrame() : Boolean
      {
         var _loc1_:Boolean = false;
         var _loc2_:Array = _activeLayerGroup.paintedFrames;
         if(!_loc2_[_lastFrame])
         {
            _loc2_[_lastFrame] = [];
            createFrame(_loc2_[_lastFrame]);
         }
         else if(_loc2_[_lastFrame][_lastHFlip] != null && _loc2_[_lastFrame][_lastHFlip].isValid)
         {
            _loc2_[_lastFrame][_lastHFlip].copyBoundsTo(_bmin,_bmax);
            _loc1_ = true;
         }
         else if(_loc2_[_lastFrame][!_lastHFlip] != null && _loc2_[_lastFrame][!_lastHFlip].isValid)
         {
            _loc2_[_lastFrame][_lastHFlip] = _loc2_[_lastFrame][!_lastHFlip].flip();
            _loc2_[_lastFrame][_lastHFlip].copyBoundsTo(_bmin,_bmax);
            _loc1_ = true;
         }
         else
         {
            createFrame(_loc2_[_lastFrame]);
         }
         this.bitmapData = _loc2_[_lastFrame][_lastHFlip].frameData;
         _loc2_[_lastFrame][_lastHFlip].updateAnchorPoint(_anchorPoint,_lastHFlip);
         return _loc1_;
      }
      
      private function createFrame(param1:Array) : void
      {
         calcBounds(_lastFrame);
         if(param1[_lastHFlip] == null)
         {
            param1[_lastHFlip] = new PaintedFrame(_bmin,_bmax);
         }
         else if(!param1[_lastHFlip].validateBounds(_bmin,_bmax))
         {
            param1[_lastHFlip].destroy();
            param1[_lastHFlip] = new PaintedFrame(_bmin,_bmax);
         }
         else
         {
            param1[_lastHFlip].isValid = true;
         }
      }
      
      public function paint(param1:int, param2:Boolean = false, param3:Boolean = true) : Boolean
      {
         var _loc6_:Object = null;
         var _loc4_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc5_:int = 0;
         _activeLayerGroup.resetTtl();
         if(param3 && _activeLayerGroup.layers[0] != null)
         {
            _loc6_ = _activeLayerGroup.layers[0];
            param1 = int(_loc6_.o.f[param1]);
         }
         if(_activeLayerGroup.checkColors)
         {
            _loc7_ = refreshAllPalettes();
            _activeLayerGroup.checkColors = false;
         }
         if(param1 != _lastFrame || param2 != _lastHFlip || _loc7_)
         {
            _lastFrame = param1;
            _lastHFlip = param2;
            if(!switchFrame())
            {
               _loc5_ = 1;
               while(_loc5_ < _activeLayerGroup.layers.length)
               {
                  _loc6_ = _activeLayerGroup.layers[_loc5_];
                  if(_loc6_ != null && _loc6_.o != null && _loc6_.pal != null)
                  {
                     if(paintFrame(_loc6_.o,param1,_loc6_.pal,param2))
                     {
                        _loc4_ = true;
                     }
                  }
                  _loc5_++;
               }
            }
         }
         return _loc4_;
      }
      
      private function paintFrame(param1:Object, param2:int, param3:Array, param4:Boolean) : Boolean
      {
         var _loc25_:* = 0;
         var _loc18_:int = 0;
         var _loc13_:* = 0;
         var _loc15_:* = 0;
         var _loc31_:* = 0;
         var _loc20_:* = 0;
         var _loc8_:* = 0;
         var _loc26_:* = 0;
         var _loc5_:* = 0;
         var _loc21_:* = 0;
         var _loc10_:* = 0;
         var _loc27_:* = 0;
         var _loc9_:int = 0;
         var _loc14_:Number = NaN;
         var _loc23_:* = 0;
         var _loc12_:int = 0;
         if(param1 == null || !param1.hasOwnProperty("f"))
         {
            return false;
         }
         if(param2 >= param1.f.length)
         {
            return false;
         }
         var _loc24_:Object = param1.f[param2];
         if(!_loc24_)
         {
            return false;
         }
         var _loc6_:BitmapData = this.bitmapData;
         if(_loc6_ == null)
         {
            return false;
         }
         _loc6_.lock();
         var _loc22_:ByteArray = _loc24_.b;
         var _loc11_:int = int(_loc24_.x);
         var _loc7_:int = int(_loc24_.y);
         var _loc28_:int = int(_loc24_.w);
         var _loc17_:int = int(_loc24_.h);
         _loc11_ -= _bmin.x;
         _loc7_ -= _bmin.y;
         _loc28_ += _loc11_;
         _loc22_.position = 0;
         var _loc16_:int = int(_loc22_.length);
         var _loc29_:* = _loc11_;
         var _loc30_:* = _loc7_;
         var _loc19_:int = _loc28_ - _loc11_;
         if(!param4)
         {
            while(_loc22_.position < _loc16_)
            {
               _loc25_ = int(_loc22_.readUnsignedByte());
               _loc18_ = 1;
               if((_loc25_ & 0x80) == 128)
               {
                  _loc25_ &= 127;
                  _loc18_ = _loc22_.readUnsignedByte() + 1;
               }
               if(_loc25_ == 0)
               {
                  _loc29_ += _loc18_;
                  if(_loc29_ >= _loc28_)
                  {
                     _loc18_ = _loc29_ - _loc28_;
                     _loc29_ = _loc11_ + _loc18_ % _loc19_;
                     _loc30_ += _loc18_ / _loc19_ + 1;
                  }
               }
               else
               {
                  _loc13_ = uint(param3[_loc25_]);
                  if(_loc13_ >= 4278190080)
                  {
                     if(_loc29_ + _loc18_ < _loc28_)
                     {
                        while(true)
                        {
                           _loc18_--;
                           if(_loc18_ <= -1)
                           {
                              break;
                           }
                           _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                        }
                     }
                     else
                     {
                        while(true)
                        {
                           _loc18_--;
                           if(_loc18_ <= -1)
                           {
                              break;
                           }
                           _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                           if(_loc29_ == _loc28_)
                           {
                              _loc29_ = _loc11_;
                              _loc30_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(true)
                     {
                        _loc18_--;
                        if(_loc18_ <= -1)
                        {
                           break;
                        }
                        _loc15_ = _loc6_.getPixel32(_loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc13_ >> 24 & 0xFF;
                           _loc31_ = _loc13_ >> 16 & 0xFF;
                           _loc20_ = _loc13_ >> 8 & 0xFF;
                           _loc8_ = _loc13_ & 0xFF;
                           _loc27_ = _loc15_ >> 24 & 0xFF;
                           _loc5_ = _loc15_ >> 16 & 0xFF;
                           _loc21_ = _loc15_ >> 8 & 0xFF;
                           _loc10_ = _loc15_ & 0xFF;
                           if(_loc26_ == 192)
                           {
                              _loc31_ = (_loc31_ + _loc31_ + _loc31_ + _loc5_) * 0.25;
                              _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc21_) * 0.25;
                              _loc8_ = (_loc8_ + _loc8_ + _loc8_ + _loc10_) * 0.25;
                           }
                           else if(_loc26_ == 128)
                           {
                              _loc31_ = (_loc31_ + _loc5_) * 0.5;
                              _loc20_ = (_loc20_ + _loc21_) * 0.5;
                              _loc8_ = (_loc8_ + _loc10_) * 0.5;
                           }
                           else
                           {
                              _loc31_ = (_loc31_ + _loc5_ + _loc5_ + _loc5_) * 0.25;
                              _loc20_ = (_loc20_ + _loc21_ + _loc21_ + _loc21_) * 0.25;
                              _loc8_ = (_loc8_ + _loc10_ + _loc10_ + _loc10_) * 0.25;
                           }
                           if(_loc27_ > _loc26_)
                           {
                              _loc26_ = _loc27_;
                           }
                           _loc13_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                        }
                        _loc6_.setPixel32(_loc29_++,_loc30_,_loc13_);
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            _loc9_ = _bmax.x - _bmin.x;
            while(_loc22_.position < _loc16_)
            {
               _loc25_ = int(_loc22_.readUnsignedByte());
               _loc18_ = 1;
               if((_loc25_ & 0x80) == 128)
               {
                  _loc25_ &= 127;
                  _loc18_ = _loc22_.readUnsignedByte() + 1;
               }
               if(_loc25_ == 0)
               {
                  _loc29_ += _loc18_;
                  if(_loc29_ >= _loc28_)
                  {
                     _loc18_ = _loc29_ - _loc28_;
                     _loc29_ = _loc11_ + _loc18_ % _loc19_;
                     _loc30_ += _loc18_ / _loc19_ + 1;
                  }
               }
               else
               {
                  _loc13_ = uint(param3[_loc25_]);
                  if(_loc13_ >= 4278190080)
                  {
                     if(_loc29_ + _loc18_ < _loc28_)
                     {
                        while(true)
                        {
                           _loc18_--;
                           if(_loc18_ <= -1)
                           {
                              break;
                           }
                           _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                        }
                     }
                     else
                     {
                        while(true)
                        {
                           _loc18_--;
                           if(_loc18_ <= -1)
                           {
                              break;
                           }
                           _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                           if(_loc29_ == _loc28_)
                           {
                              _loc29_ = _loc11_;
                              _loc30_++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(true)
                     {
                        _loc18_--;
                        if(_loc18_ <= -1)
                        {
                           break;
                        }
                        _loc15_ = _loc6_.getPixel32(_loc9_ - _loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc13_ >> 24 & 0xFF;
                           _loc31_ = _loc13_ >> 16 & 0xFF;
                           _loc20_ = _loc13_ >> 8 & 0xFF;
                           _loc8_ = _loc13_ & 0xFF;
                           _loc27_ = _loc15_ >> 24 & 0xFF;
                           _loc5_ = _loc15_ >> 16 & 0xFF;
                           _loc21_ = _loc15_ >> 8 & 0xFF;
                           _loc10_ = _loc15_ & 0xFF;
                           switch(_loc26_)
                           {
                              case 192:
                                 _loc31_ = (_loc31_ + _loc31_ + _loc31_ + _loc5_) * 0.25;
                                 _loc20_ = (_loc20_ + _loc20_ + _loc20_ + _loc21_) * 0.25;
                                 _loc8_ = (_loc8_ + _loc8_ + _loc8_ + _loc10_) * 0.25;
                                 break;
                              case 128:
                                 _loc31_ = (_loc31_ + _loc5_) * 0.5;
                                 _loc20_ = (_loc20_ + _loc21_) * 0.5;
                                 _loc8_ = (_loc8_ + _loc10_) * 0.5;
                                 break;
                              case 64:
                                 _loc31_ = (_loc31_ + _loc5_ + _loc5_ + _loc5_) * 0.25;
                                 _loc20_ = (_loc20_ + _loc21_ + _loc21_ + _loc21_) * 0.25;
                                 _loc8_ = (_loc8_ + _loc10_ + _loc10_ + _loc10_) * 0.25;
                           }
                           if(_loc27_ > _loc26_)
                           {
                              _loc26_ = _loc27_;
                           }
                           _loc13_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                        }
                        _loc6_.setPixel32(_loc9_ - _loc29_++,_loc30_,_loc13_);
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
         }
         if(_loc24_.hasOwnProperty("s"))
         {
            _loc12_ = int(_loc24_.sm);
            _loc22_ = _loc24_.s;
            _loc16_ = int(_loc22_.length);
            _loc22_.position = 0;
            _loc29_ = _loc11_;
            _loc30_ = _loc7_;
            if(!param4)
            {
               while(_loc22_.position < _loc16_)
               {
                  _loc25_ = int(_loc22_.readUnsignedByte());
                  _loc18_ = 1;
                  if((_loc25_ & 0x80) == 128)
                  {
                     _loc25_ &= 127;
                     _loc18_ = _loc22_.readUnsignedByte() + 1;
                  }
                  if(_loc25_ == 0)
                  {
                     _loc29_ += _loc18_;
                     if(_loc29_ >= _loc28_)
                     {
                        _loc18_ = _loc29_ - _loc28_;
                        _loc29_ = _loc11_ + _loc18_ % _loc19_;
                        _loc30_ += _loc18_ / _loc19_ + 1;
                     }
                  }
                  else
                  {
                     _loc13_ = uint(_loc25_ << _loc12_);
                     _loc13_ = uint(_loc13_ + 24);
                     if(_loc13_ > 255)
                     {
                        _loc14_ = 1;
                     }
                     else
                     {
                        _loc14_ = _loc13_ / 255;
                     }
                     while(true)
                     {
                        _loc18_--;
                        if(_loc18_ <= -1)
                        {
                           break;
                        }
                        _loc15_ = _loc6_.getPixel32(_loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc15_ >> 24 & 0xFF;
                           _loc31_ = (_loc15_ >> 16 & 0xFF) * _loc14_;
                           _loc20_ = (_loc15_ >> 8 & 0xFF) * _loc14_;
                           _loc8_ = (_loc15_ & 0xFF) * _loc14_;
                           _loc23_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                           _loc6_.setPixel32(_loc29_,_loc30_,_loc23_);
                        }
                        _loc29_++;
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
            else
            {
               _loc9_ = _bmax.x - _bmin.x;
               while(_loc22_.position < _loc16_)
               {
                  _loc25_ = int(_loc22_.readUnsignedByte());
                  _loc18_ = 1;
                  if((_loc25_ & 0x80) == 128)
                  {
                     _loc25_ &= 127;
                     _loc18_ = _loc22_.readUnsignedByte() + 1;
                  }
                  if(_loc25_ == 0)
                  {
                     _loc29_ += _loc18_;
                     if(_loc29_ >= _loc28_)
                     {
                        _loc18_ = _loc29_ - _loc28_;
                        _loc29_ = _loc11_ + _loc18_ % _loc19_;
                        _loc30_ += _loc18_ / _loc19_ + 1;
                     }
                  }
                  else
                  {
                     _loc13_ = uint(_loc25_ << _loc12_);
                     _loc13_ = uint(_loc13_ + 24);
                     if(_loc13_ > 255)
                     {
                        _loc14_ = 1;
                     }
                     else
                     {
                        _loc14_ = _loc13_ / 255;
                     }
                     while(true)
                     {
                        _loc18_--;
                        if(_loc18_ <= -1)
                        {
                           break;
                        }
                        _loc15_ = _loc6_.getPixel32(_loc9_ - _loc29_,_loc30_);
                        if(_loc15_ != 0)
                        {
                           _loc26_ = _loc15_ >> 24 & 0xFF;
                           _loc31_ = (_loc15_ >> 16 & 0xFF) * _loc14_;
                           _loc20_ = (_loc15_ >> 8 & 0xFF) * _loc14_;
                           _loc8_ = (_loc15_ & 0xFF) * _loc14_;
                           _loc23_ = uint(_loc26_ << 24 | _loc31_ << 16 | _loc20_ << 8 | _loc8_);
                           _loc6_.setPixel32(_loc9_ - _loc29_,_loc30_,_loc23_);
                        }
                        _loc29_++;
                        if(_loc29_ == _loc28_)
                        {
                           _loc29_ = _loc11_;
                           _loc30_++;
                        }
                     }
                  }
               }
            }
         }
         _loc6_.unlock();
         return true;
      }
   }
}

