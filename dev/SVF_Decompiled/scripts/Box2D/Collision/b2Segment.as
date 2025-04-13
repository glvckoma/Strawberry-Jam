package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Segment
   {
      public var p1:b2Vec2 = new b2Vec2();
      
      public var p2:b2Vec2 = new b2Vec2();
      
      public function b2Segment()
      {
         super();
      }
      
      public function TestSegment(param1:Array, param2:b2Vec2, param3:b2Segment, param4:Number) : Boolean
      {
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc12_:b2Vec2 = param3.p1;
         var _loc6_:Number = param3.p2.x - _loc12_.x;
         var _loc7_:Number = param3.p2.y - _loc12_.y;
         var _loc13_:Number = p2.x - p1.x;
         var _loc15_:Number;
         var _loc9_:* = _loc15_ = p2.y - p1.y;
         var _loc10_:Number = -_loc13_;
         var _loc8_:Number = 100 * Number.MIN_VALUE;
         var _loc18_:Number = -(_loc6_ * _loc9_ + _loc7_ * _loc10_);
         if(_loc18_ > _loc8_)
         {
            _loc16_ = _loc12_.x - p1.x;
            _loc17_ = _loc12_.y - p1.y;
            _loc5_ = _loc16_ * _loc9_ + _loc17_ * _loc10_;
            if(0 <= _loc5_ && _loc5_ <= param4 * _loc18_)
            {
               _loc11_ = -_loc6_ * _loc17_ + _loc7_ * _loc16_;
               if(-_loc8_ * _loc18_ <= _loc11_ && _loc11_ <= _loc18_ * (1 + _loc8_))
               {
                  _loc5_ /= _loc18_;
                  _loc14_ = Math.sqrt(_loc9_ * _loc9_ + _loc10_ * _loc10_);
                  _loc9_ /= _loc14_;
                  _loc10_ /= _loc14_;
                  param1[0] = _loc5_;
                  param2.Set(_loc9_,_loc10_);
                  return true;
               }
            }
         }
         return false;
      }
   }
}

