package com.sbi.corelib.math
{
   import flash.geom.Point;
   
   public class Collision
   {
      public function Collision()
      {
         super();
      }
      
      public static function segIntersection(param1:Point, param2:Point, param3:Point, param4:Point) : Point
      {
         var _loc11_:Number = param2.x - param1.x;
         var _loc13_:Number = param2.y - param1.y;
         var _loc6_:Number = param4.x - param3.x;
         var _loc8_:Number = param4.y - param3.y;
         var _loc5_:Number = _loc11_ * _loc8_ - _loc13_ * _loc6_;
         if(_loc5_ == 0)
         {
            return null;
         }
         var _loc9_:Number = param3.x - param1.x;
         var _loc12_:Number = param3.y - param1.y;
         var _loc7_:Number = (_loc9_ * _loc8_ - _loc12_ * _loc6_) / _loc5_;
         if(_loc7_ < 0 || _loc7_ > 1)
         {
            return null;
         }
         var _loc10_:Number = (_loc9_ * _loc13_ - _loc12_ * _loc11_) / _loc5_;
         if(_loc10_ < 0 || _loc10_ > 1)
         {
            return null;
         }
         return new Point(param1.x + _loc7_ * _loc11_,param1.y + _loc7_ * _loc13_);
      }
      
      public static function circleHitCircle(param1:Point, param2:Number, param3:Point, param4:Number) : Boolean
      {
         var _loc5_:Point = param3.subtract(param1);
         var _loc6_:Number = _loc5_.x * _loc5_.x + _loc5_.y * _loc5_.y;
         return _loc6_ < (param2 + param4) * (param2 + param4);
      }
      
      public static function pointHitCircle(param1:Point, param2:Point, param3:Number) : Boolean
      {
         var _loc4_:Point = param1.subtract(param2);
         var _loc5_:Number = _loc4_.x * _loc4_.x + _loc4_.y * _loc4_.y;
         return _loc5_ < param3 * param3;
      }
      
      public static function movingCircleVsRay(param1:Point, param2:Number, param3:Point, param4:Number, param5:Point, param6:Point) : Number
      {
         var _loc8_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc21_:Point = null;
         var _loc11_:Point = null;
         var _loc10_:Point = null;
         var _loc12_:Point = param6.subtract(param5);
         var _loc20_:Point = param1.subtract(param5);
         var _loc9_:Point = new Point();
         var _loc14_:Point = new Point(param3.x * param4,param3.y * param4);
         var _loc16_:Number = param3.x * param3.y;
         var _loc18_:Number;
         var _loc7_:* = _loc18_ = _loc14_.x * _loc12_.y - _loc14_.y * _loc12_.x;
         if(_loc7_ == 0)
         {
            _loc8_ = _loc20_.x * _loc12_.x + _loc20_.y * _loc12_.y;
            _loc9_.x = _loc20_.x - _loc12_.x * _loc8_;
            _loc9_.y = _loc20_.y - _loc12_.y * _loc8_;
            param4 = 0;
            return _loc9_.x * _loc9_.y <= param2 ? -1 : 1;
         }
         _loc18_ /= _loc7_;
         _loc8_ = 0;
         if(_loc8_ <= param2)
         {
            _loc17_ = _loc20_.x * _loc12_.y - _loc20_.y * _loc12_.x;
            _loc23_ = -(_loc17_ * _loc18_) / _loc7_;
            _loc13_ = -(_loc18_ * _loc12_.y);
            _loc15_ = _loc18_ * _loc12_.x;
            _loc19_ = _loc13_ * _loc13_ + _loc15_ * _loc15_;
            if(_loc19_)
            {
               _loc19_ = Math.sqrt(_loc19_);
               _loc13_ /= _loc19_;
               _loc15_ /= _loc19_;
            }
            _loc22_ = Math.abs(param2 / (_loc14_.x * _loc13_ + _loc14_.y * _loc15_));
            if(_loc23_ < -_loc22_)
            {
               return -1;
            }
            if(_loc23_ - _loc22_ > 1)
            {
               return -1;
            }
            _loc24_ = _loc23_ - _loc22_ < 0 ? 0 : _loc23_ - _loc22_;
            _loc21_ = new Point(param1.x + param3.x * _loc24_,param1.y + param3.y * _loc24_);
            _loc11_ = _loc21_.subtract(param5);
            _loc10_ = _loc21_.subtract(param6);
            if(_loc11_.x * _loc12_.x + _loc11_.y * _loc12_.y < 0)
            {
               return Ray_Vs_Sphere(param1,param3,param4,param5,param2);
            }
            if(_loc10_.x * _loc12_.x + _loc10_.y * _loc12_.y > 0)
            {
               return Ray_Vs_Sphere(param1,param3,param4,param6,param2);
            }
            return _loc24_;
         }
         return -1;
      }
      
      public static function rayHitCircle(param1:Point, param2:Number, param3:Point, param4:Point) : Boolean
      {
         var _loc5_:Point = param1.subtract(param3);
         var _loc9_:Point = param4.subtract(param3);
         var _loc6_:Number = (_loc5_.x * _loc9_.x + _loc5_.y * _loc9_.y) / (_loc9_.x * _loc9_.x + _loc9_.y * _loc9_.y);
         if(_loc6_ < 0)
         {
            _loc6_ = 0;
         }
         if(_loc6_ > 1)
         {
            _loc6_ = 1;
         }
         var _loc10_:Point = new Point(param3.x + _loc6_ * _loc9_.x,param3.y + _loc6_ * _loc9_.y);
         var _loc7_:Point = param1.subtract(_loc10_);
         var _loc8_:Number = _loc7_.x * _loc7_.x + _loc7_.y * _loc7_.y;
         return _loc8_ <= param2 * param2;
      }
      
      public static function Ray_Vs_Sphere(param1:Point, param2:Point, param3:Number, param4:Point, param5:Number) : Number
      {
         var _loc22_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc10_:Point = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc8_:Number = param5 * param5;
         var _loc7_:Point = param4.subtract(param1);
         var _loc23_:Number = _loc7_.x * _loc7_.x + _loc7_.y * _loc7_.y;
         var _loc9_:Point = new Point(param2.x * param3,param2.y * param3);
         var _loc6_:Point = _loc9_.add(param1);
         var _loc12_:Number = _loc9_.x * _loc7_.x + _loc9_.y * _loc7_.y;
         var _loc15_:Point = param4.subtract(_loc6_);
         var _loc11_:Number = _loc9_.x * _loc15_.x + _loc9_.y * _loc15_.y;
         var _loc13_:Number = (_loc15_.x + _loc15_.y) * (_loc15_.x + _loc15_.y);
         var _loc14_:Number = _loc9_.x * _loc7_.y - _loc9_.y * _loc7_.x;
         var _loc18_:Number = _loc14_ * _loc14_;
         var _loc16_:Number = _loc9_.x * _loc9_.x + _loc9_.y * _loc9_.y;
         if(_loc12_ > 0 && (_loc11_ < 0 || _loc13_ < _loc8_) && _loc18_ < _loc8_ * _loc16_ && _loc16_ > 0.00001)
         {
            _loc22_ = Math.sqrt(_loc8_ - _loc18_ / _loc16_);
            _loc19_ = Math.sqrt(_loc16_);
            _loc17_ = 1 / _loc19_;
            _loc10_ = new Point(_loc9_.x * _loc17_,_loc9_.y * _loc17_);
            _loc20_ = _loc10_.x * _loc7_.x + _loc10_.y * _loc7_.y;
            _loc21_ = param3 * (_loc20_ - _loc22_) * _loc17_;
            return _loc21_ < 0 ? 0 : _loc21_;
         }
         if(_loc23_ < _loc8_)
         {
            return 0;
         }
         return -1;
      }
   }
}

