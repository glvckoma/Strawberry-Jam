package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   
   public class b2TimeOfImpact
   {
      public static var s_p1:b2Vec2 = new b2Vec2();
      
      public static var s_p2:b2Vec2 = new b2Vec2();
      
      public static var s_xf1:b2XForm = new b2XForm();
      
      public static var s_xf2:b2XForm = new b2XForm();
      
      public function b2TimeOfImpact()
      {
         super();
      }
      
      public static function TimeOfImpact(param1:b2Shape, param2:b2Sweep, param3:b2Shape, param4:b2Sweep) : Number
      {
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc10_:b2XForm = null;
         var _loc13_:b2XForm = null;
         var _loc27_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc30_:Number = param1.m_sweepRadius;
         var _loc5_:Number = param3.m_sweepRadius;
         var _loc28_:Number = param2.t0;
         var _loc29_:Number = param2.c.x - param2.c0.x;
         var _loc31_:Number = param2.c.y - param2.c0.y;
         var _loc18_:Number = param4.c.x - param4.c0.x;
         var _loc17_:Number = param4.c.y - param4.c0.y;
         var _loc21_:Number = param2.a - param2.a0;
         var _loc20_:Number = param4.a - param4.a0;
         var _loc16_:* = 0;
         var _loc6_:b2Vec2 = s_p1;
         var _loc8_:b2Vec2 = s_p2;
         var _loc22_:int = 0;
         var _loc7_:Number = 0;
         var _loc9_:Number = 0;
         var _loc12_:Number = 0;
         var _loc23_:Number = 0;
         while(true)
         {
            _loc26_ = (1 - _loc16_) * _loc28_ + _loc16_;
            _loc10_ = s_xf1;
            _loc13_ = s_xf2;
            param2.GetXForm(_loc10_,_loc26_);
            param4.GetXForm(_loc13_,_loc26_);
            _loc12_ = b2Distance.Distance(_loc6_,_loc8_,param1,_loc10_,param3,_loc13_);
            if(_loc22_ == 0)
            {
               if(_loc12_ > 2 * 0.04)
               {
                  _loc23_ = 1.5 * 0.04;
               }
               else
               {
                  _loc11_ = 0.05 * 0.04;
                  _loc14_ = _loc12_ - 0.5 * 0.04;
                  _loc23_ = _loc11_ > _loc14_ ? _loc11_ : _loc14_;
               }
            }
            if(_loc12_ - _loc23_ < 0.05 * 0.04 || _loc22_ == 20)
            {
               break;
            }
            _loc7_ = _loc8_.x - _loc6_.x;
            _loc9_ = _loc8_.y - _loc6_.y;
            _loc27_ = Math.sqrt(_loc7_ * _loc7_ + _loc9_ * _loc9_);
            _loc7_ /= _loc27_;
            _loc9_ /= _loc27_;
            _loc15_ = _loc7_ * (_loc29_ - _loc18_) + _loc9_ * (_loc31_ - _loc17_) + (_loc21_ < 0 ? -_loc21_ : _loc21_) * _loc30_ + (_loc20_ < 0 ? -_loc20_ : _loc20_) * _loc5_;
            if(_loc15_ == 0)
            {
               _loc16_ = 1;
               break;
            }
            _loc25_ = (_loc12_ - _loc23_) / _loc15_;
            _loc24_ = _loc16_ + _loc25_;
            if(_loc24_ < 0 || 1 < _loc24_)
            {
               _loc16_ = 1;
               break;
            }
            if(_loc24_ < (1 + 100 * Number.MIN_VALUE) * _loc16_)
            {
               break;
            }
            _loc16_ = _loc24_;
            _loc22_++;
         }
         return _loc16_;
      }
   }
}

