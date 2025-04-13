package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Distance
   {
      public static var g_GJK_Iterations:int = 0;
      
      private static var s_p1s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_p2s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_points:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var gPoint:b2Point = new b2Point();
      
      public function b2Distance()
      {
         super();
      }
      
      public static function ProcessTwo(param1:b2Vec2, param2:b2Vec2, param3:Array, param4:Array, param5:Array) : int
      {
         var _loc16_:b2Vec2 = param5[0];
         var _loc17_:b2Vec2 = param5[1];
         var _loc7_:b2Vec2 = param3[0];
         var _loc9_:b2Vec2 = param3[1];
         var _loc6_:b2Vec2 = param4[0];
         var _loc8_:b2Vec2 = param4[1];
         var _loc10_:Number = -_loc17_.x;
         var _loc11_:Number = -_loc17_.y;
         var _loc14_:Number = _loc16_.x - _loc17_.x;
         var _loc15_:Number = _loc16_.y - _loc17_.y;
         var _loc12_:Number = Math.sqrt(_loc14_ * _loc14_ + _loc15_ * _loc15_);
         _loc14_ /= _loc12_;
         _loc15_ /= _loc12_;
         var _loc13_:Number = _loc10_ * _loc14_ + _loc11_ * _loc15_;
         if(_loc13_ <= 0 || _loc12_ < Number.MIN_VALUE)
         {
            param1.SetV(_loc9_);
            param2.SetV(_loc8_);
            _loc7_.SetV(_loc9_);
            _loc6_.SetV(_loc8_);
            _loc16_.SetV(_loc17_);
            return 1;
         }
         _loc13_ /= _loc12_;
         param1.x = _loc9_.x + _loc13_ * (_loc7_.x - _loc9_.x);
         param1.y = _loc9_.y + _loc13_ * (_loc7_.y - _loc9_.y);
         param2.x = _loc8_.x + _loc13_ * (_loc6_.x - _loc8_.x);
         param2.y = _loc8_.y + _loc13_ * (_loc6_.y - _loc8_.y);
         return 2;
      }
      
      public static function ProcessThree(param1:b2Vec2, param2:b2Vec2, param3:Array, param4:Array, param5:Array) : int
      {
         var _loc11_:Number = NaN;
         var _loc21_:b2Vec2 = param5[0];
         var _loc22_:b2Vec2 = param5[1];
         var _loc23_:b2Vec2 = param5[2];
         var _loc6_:b2Vec2 = param3[0];
         var _loc7_:b2Vec2 = param3[1];
         var _loc8_:b2Vec2 = param3[2];
         var _loc24_:b2Vec2 = param4[0];
         var _loc25_:b2Vec2 = param4[1];
         var _loc26_:b2Vec2 = param4[2];
         var _loc15_:Number = _loc21_.x;
         var _loc16_:Number = _loc21_.y;
         var _loc33_:Number = _loc22_.x;
         var _loc37_:Number = _loc22_.y;
         var _loc12_:Number = _loc23_.x;
         var _loc13_:Number = _loc23_.y;
         var _loc14_:Number = _loc33_ - _loc15_;
         var _loc17_:Number = _loc37_ - _loc16_;
         var _loc38_:Number = _loc12_ - _loc15_;
         var _loc34_:Number = _loc13_ - _loc16_;
         var _loc35_:Number = _loc12_ - _loc33_;
         var _loc40_:Number = _loc13_ - _loc37_;
         var _loc19_:Number = -(_loc15_ * _loc14_ + _loc16_ * _loc17_);
         var _loc10_:Number = _loc33_ * _loc14_ + _loc37_ * _loc17_;
         var _loc41_:Number = -(_loc15_ * _loc38_ + _loc16_ * _loc34_);
         var _loc31_:Number = _loc12_ * _loc38_ + _loc13_ * _loc34_;
         var _loc18_:Number = -(_loc33_ * _loc35_ + _loc37_ * _loc40_);
         var _loc9_:Number = _loc12_ * _loc35_ + _loc13_ * _loc40_;
         if(_loc31_ <= 0 && _loc9_ <= 0)
         {
            param1.SetV(_loc8_);
            param2.SetV(_loc26_);
            _loc6_.SetV(_loc8_);
            _loc24_.SetV(_loc26_);
            _loc21_.SetV(_loc23_);
            return 1;
         }
         var _loc30_:Number = _loc14_ * _loc34_ - _loc17_ * _loc38_;
         var _loc29_:Number = _loc30_ * (_loc15_ * _loc37_ - _loc16_ * _loc33_);
         var _loc27_:Number = _loc30_ * (_loc33_ * _loc13_ - _loc37_ * _loc12_);
         if(_loc27_ <= 0 && _loc18_ >= 0 && _loc9_ >= 0 && _loc18_ + _loc9_ > 0)
         {
            _loc11_ = _loc18_ / (_loc18_ + _loc9_);
            param1.x = _loc7_.x + _loc11_ * (_loc8_.x - _loc7_.x);
            param1.y = _loc7_.y + _loc11_ * (_loc8_.y - _loc7_.y);
            param2.x = _loc25_.x + _loc11_ * (_loc26_.x - _loc25_.x);
            param2.y = _loc25_.y + _loc11_ * (_loc26_.y - _loc25_.y);
            _loc6_.SetV(_loc8_);
            _loc24_.SetV(_loc26_);
            _loc21_.SetV(_loc23_);
            return 2;
         }
         var _loc28_:Number = _loc30_ * (_loc12_ * _loc16_ - _loc13_ * _loc15_);
         if(_loc28_ <= 0 && _loc41_ >= 0 && _loc31_ >= 0 && _loc41_ + _loc31_ > 0)
         {
            _loc11_ = _loc41_ / (_loc41_ + _loc31_);
            param1.x = _loc6_.x + _loc11_ * (_loc8_.x - _loc6_.x);
            param1.y = _loc6_.y + _loc11_ * (_loc8_.y - _loc6_.y);
            param2.x = _loc24_.x + _loc11_ * (_loc26_.x - _loc24_.x);
            param2.y = _loc24_.y + _loc11_ * (_loc26_.y - _loc24_.y);
            _loc7_.SetV(_loc8_);
            _loc25_.SetV(_loc26_);
            _loc22_.SetV(_loc23_);
            return 2;
         }
         var _loc20_:Number = _loc27_ + _loc28_ + _loc29_;
         _loc20_ = 1 / _loc20_;
         var _loc32_:Number = _loc27_ * _loc20_;
         var _loc36_:Number = _loc28_ * _loc20_;
         var _loc39_:Number = 1 - _loc32_ - _loc36_;
         param1.x = _loc32_ * _loc6_.x + _loc36_ * _loc7_.x + _loc39_ * _loc8_.x;
         param1.y = _loc32_ * _loc6_.y + _loc36_ * _loc7_.y + _loc39_ * _loc8_.y;
         param2.x = _loc32_ * _loc24_.x + _loc36_ * _loc25_.x + _loc39_ * _loc26_.x;
         param2.y = _loc32_ * _loc24_.y + _loc36_ * _loc25_.y + _loc39_ * _loc26_.y;
         return 3;
      }
      
      public static function InPoints(param1:b2Vec2, param2:Array, param3:int) : Boolean
      {
         var _loc8_:int = 0;
         var _loc6_:b2Vec2 = null;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc4_:Number = 100 * Number.MIN_VALUE;
         _loc8_ = 0;
         while(_loc8_ < param3)
         {
            _loc6_ = param2[_loc8_];
            _loc5_ = Math.abs(param1.x - _loc6_.x);
            _loc7_ = Math.abs(param1.y - _loc6_.y);
            _loc9_ = Math.max(Math.abs(param1.x),Math.abs(_loc6_.x));
            _loc10_ = Math.max(Math.abs(param1.y),Math.abs(_loc6_.y));
            if(_loc5_ < _loc4_ * (_loc9_ + 1) && _loc7_ < _loc4_ * (_loc10_ + 1))
            {
               return true;
            }
            _loc8_++;
         }
         return false;
      }
      
      public static function DistanceGeneric(param1:b2Vec2, param2:b2Vec2, param3:*, param4:b2XForm, param5:*, param6:b2XForm) : Number
      {
         var _loc20_:b2Vec2 = null;
         var _loc9_:int = 0;
         _loc9_ = 20;
         var _loc14_:int = 0;
         var _loc10_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc21_:b2Vec2 = null;
         var _loc22_:b2Vec2 = null;
         var _loc7_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc15_:int = 0;
         var _loc19_:Array = s_p1s;
         var _loc17_:Array = s_p2s;
         var _loc16_:Array = s_points;
         var _loc18_:int = 0;
         param1.SetV(param3.GetFirstVertex(param4));
         param2.SetV(param5.GetFirstVertex(param6));
         var _loc13_:Number = 0;
         _loc14_ = 0;
         while(_loc14_ < 20)
         {
            _loc10_ = param2.x - param1.x;
            _loc12_ = param2.y - param1.y;
            _loc21_ = param3.Support(param4,_loc10_,_loc12_);
            _loc22_ = param5.Support(param6,-_loc10_,-_loc12_);
            _loc13_ = _loc10_ * _loc10_ + _loc12_ * _loc12_;
            _loc7_ = _loc22_.x - _loc21_.x;
            _loc11_ = _loc22_.y - _loc21_.y;
            _loc8_ = _loc10_ * _loc7_ + _loc12_ * _loc11_;
            if(_loc13_ - _loc8_ <= 0.01 * _loc13_)
            {
               if(_loc18_ == 0)
               {
                  param1.SetV(_loc21_);
                  param2.SetV(_loc22_);
               }
               g_GJK_Iterations = _loc14_;
               return Math.sqrt(_loc13_);
            }
            switch(_loc18_)
            {
               case 0:
                  _loc20_ = _loc19_[0];
                  _loc20_.SetV(_loc21_);
                  _loc20_ = _loc17_[0];
                  _loc20_.SetV(_loc22_);
                  _loc20_ = _loc16_[0];
                  _loc20_.x = _loc7_;
                  _loc20_.y = _loc11_;
                  param1.SetV(_loc19_[0]);
                  param2.SetV(_loc17_[0]);
                  _loc18_++;
                  break;
               case 1:
                  _loc20_ = _loc19_[1];
                  _loc20_.SetV(_loc21_);
                  _loc20_ = _loc17_[1];
                  _loc20_.SetV(_loc22_);
                  _loc20_ = _loc16_[1];
                  _loc20_.x = _loc7_;
                  _loc20_.y = _loc11_;
                  _loc18_ = ProcessTwo(param1,param2,_loc19_,_loc17_,_loc16_);
                  break;
               case 2:
                  _loc20_ = _loc19_[2];
                  _loc20_.SetV(_loc21_);
                  _loc20_ = _loc17_[2];
                  _loc20_.SetV(_loc22_);
                  _loc20_ = _loc16_[2];
                  _loc20_.x = _loc7_;
                  _loc20_.y = _loc11_;
                  _loc18_ = ProcessThree(param1,param2,_loc19_,_loc17_,_loc16_);
            }
            if(_loc18_ == 3)
            {
               g_GJK_Iterations = _loc14_;
               return 0;
            }
            _loc23_ = -1.7976931348623157e+308;
            _loc15_ = 0;
            while(_loc15_ < _loc18_)
            {
               _loc20_ = _loc16_[_loc15_];
               _loc23_ = b2Math.b2Max(_loc23_,_loc20_.x * _loc20_.x + _loc20_.y * _loc20_.y);
               _loc15_++;
            }
            if(_loc18_ == 3 || _loc13_ <= 100 * Number.MIN_VALUE * _loc23_)
            {
               g_GJK_Iterations = _loc14_;
               _loc10_ = param2.x - param1.x;
               _loc12_ = param2.y - param1.y;
               _loc13_ = _loc10_ * _loc10_ + _loc12_ * _loc12_;
               return Math.sqrt(_loc13_);
            }
            _loc14_++;
         }
         g_GJK_Iterations = 20;
         return Math.sqrt(_loc13_);
      }
      
      public static function DistanceCC(param1:b2Vec2, param2:b2Vec2, param3:b2CircleShape, param4:b2XForm, param5:b2CircleShape, param6:b2XForm) : Number
      {
         var _loc16_:b2Mat22 = null;
         var _loc12_:b2Vec2 = null;
         var _loc20_:Number = NaN;
         var _loc8_:Number = NaN;
         _loc16_ = param4.R;
         _loc12_ = param3.m_localPosition;
         var _loc13_:Number = param4.position.x + (_loc16_.col1.x * _loc12_.x + _loc16_.col2.x * _loc12_.y);
         var _loc17_:Number = param4.position.y + (_loc16_.col1.y * _loc12_.x + _loc16_.col2.y * _loc12_.y);
         _loc16_ = param6.R;
         _loc12_ = param5.m_localPosition;
         var _loc15_:Number = param6.position.x + (_loc16_.col1.x * _loc12_.x + _loc16_.col2.x * _loc12_.y);
         var _loc14_:Number = param6.position.y + (_loc16_.col1.y * _loc12_.x + _loc16_.col2.y * _loc12_.y);
         var _loc10_:Number = _loc15_ - _loc13_;
         var _loc11_:Number = _loc14_ - _loc17_;
         var _loc18_:Number = _loc10_ * _loc10_ + _loc11_ * _loc11_;
         var _loc19_:Number = param3.m_radius - 0.04;
         var _loc7_:Number = param5.m_radius - 0.04;
         var _loc9_:Number = _loc19_ + _loc7_;
         if(_loc18_ > _loc9_ * _loc9_)
         {
            _loc20_ = Math.sqrt(_loc18_);
            _loc10_ /= _loc20_;
            _loc11_ /= _loc20_;
            _loc8_ = _loc20_ - _loc9_;
            param1.x = _loc13_ + _loc19_ * _loc10_;
            param1.y = _loc17_ + _loc19_ * _loc11_;
            param2.x = _loc15_ - _loc7_ * _loc10_;
            param2.y = _loc14_ - _loc7_ * _loc11_;
            return _loc8_;
         }
         if(_loc18_ > Number.MIN_VALUE * Number.MIN_VALUE)
         {
            _loc20_ = Math.sqrt(_loc18_);
            _loc10_ /= _loc20_;
            _loc11_ /= _loc20_;
            param1.x = _loc13_ + _loc19_ * _loc10_;
            param1.y = _loc17_ + _loc19_ * _loc11_;
            param2.x = param1.x;
            param2.y = param1.y;
            return 0;
         }
         param1.x = _loc13_;
         param1.y = _loc17_;
         param2.x = param1.x;
         param2.y = param1.y;
         return 0;
      }
      
      public static function DistancePC(param1:b2Vec2, param2:b2Vec2, param3:b2PolygonShape, param4:b2XForm, param5:b2CircleShape, param6:b2XForm) : Number
      {
         var _loc13_:b2Mat22 = null;
         var _loc12_:b2Vec2 = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc8_:b2Point = gPoint;
         _loc12_ = param5.m_localPosition;
         _loc13_ = param6.R;
         _loc8_.p.x = param6.position.x + (_loc13_.col1.x * _loc12_.x + _loc13_.col2.x * _loc12_.y);
         _loc8_.p.y = param6.position.y + (_loc13_.col1.y * _loc12_.x + _loc13_.col2.y * _loc12_.y);
         var _loc7_:Number = DistanceGeneric(param1,param2,param3,param4,_loc8_,b2Math.b2XForm_identity);
         var _loc9_:Number = param5.m_radius - 0.04;
         if(_loc7_ > _loc9_)
         {
            _loc7_ -= _loc9_;
            _loc10_ = param2.x - param1.x;
            _loc11_ = param2.y - param1.y;
            _loc14_ = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
            _loc10_ /= _loc14_;
            _loc11_ /= _loc14_;
            param2.x -= _loc9_ * _loc10_;
            param2.y -= _loc9_ * _loc11_;
         }
         else
         {
            _loc7_ = 0;
            param2.x = param1.x;
            param2.y = param1.y;
         }
         return _loc7_;
      }
      
      public static function Distance(param1:b2Vec2, param2:b2Vec2, param3:b2Shape, param4:b2XForm, param5:b2Shape, param6:b2XForm) : Number
      {
         var _loc8_:int = param3.m_type;
         var _loc7_:int = param5.m_type;
         if(_loc8_ == 0 && _loc7_ == 0)
         {
            return DistanceCC(param1,param2,param3 as b2CircleShape,param4,param5 as b2CircleShape,param6);
         }
         if(_loc8_ == 1 && _loc7_ == 0)
         {
            return DistancePC(param1,param2,param3 as b2PolygonShape,param4,param5 as b2CircleShape,param6);
         }
         if(_loc8_ == 0 && _loc7_ == 1)
         {
            return DistancePC(param2,param1,param5 as b2PolygonShape,param6,param3 as b2CircleShape,param4);
         }
         if(_loc8_ == 1 && _loc7_ == 1)
         {
            return DistanceGeneric(param1,param2,param3 as b2PolygonShape,param4,param5 as b2PolygonShape,param6);
         }
         return 0;
      }
   }
}

