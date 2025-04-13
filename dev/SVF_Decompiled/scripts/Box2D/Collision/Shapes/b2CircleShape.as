package Box2D.Collision.Shapes
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2CircleShape extends b2Shape
   {
      public var m_localPosition:b2Vec2 = new b2Vec2();
      
      public var m_radius:Number;
      
      public function b2CircleShape(param1:b2ShapeDef)
      {
         super(param1);
         var _loc2_:b2CircleDef = param1 as b2CircleDef;
         m_type = 0;
         m_localPosition.SetV(_loc2_.localPosition);
         m_radius = _loc2_.radius;
      }
      
      override public function TestPoint(param1:b2XForm, param2:b2Vec2) : Boolean
      {
         var _loc5_:b2Mat22 = param1.R;
         var _loc3_:Number = param1.position.x + (_loc5_.col1.x * m_localPosition.x + _loc5_.col2.x * m_localPosition.y);
         var _loc4_:Number = param1.position.y + (_loc5_.col1.y * m_localPosition.x + _loc5_.col2.y * m_localPosition.y);
         _loc3_ = param2.x - _loc3_;
         _loc4_ = param2.y - _loc4_;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_ <= m_radius * m_radius;
      }
      
      override public function TestSegment(param1:b2XForm, param2:Array, param3:b2Vec2, param4:b2Segment, param5:Number) : Boolean
      {
         var _loc17_:b2Mat22 = param1.R;
         var _loc15_:Number = param1.position.x + (_loc17_.col1.x * m_localPosition.x + _loc17_.col2.x * m_localPosition.y);
         var _loc16_:Number = param1.position.y + (_loc17_.col1.y * m_localPosition.x + _loc17_.col2.y * m_localPosition.y);
         var _loc11_:Number = param4.p1.x - _loc15_;
         var _loc12_:Number = param4.p1.y - _loc16_;
         var _loc9_:Number = _loc11_ * _loc11_ + _loc12_ * _loc12_ - m_radius * m_radius;
         if(_loc9_ < 0)
         {
            return false;
         }
         var _loc13_:Number = param4.p2.x - param4.p1.x;
         var _loc14_:Number = param4.p2.y - param4.p1.y;
         var _loc10_:Number = _loc11_ * _loc13_ + _loc12_ * _loc14_;
         var _loc6_:Number = _loc13_ * _loc13_ + _loc14_ * _loc14_;
         var _loc7_:Number = _loc10_ * _loc10_ - _loc6_ * _loc9_;
         if(_loc7_ < 0 || _loc6_ < Number.MIN_VALUE)
         {
            return false;
         }
         var _loc8_:Number = -(_loc10_ + Math.sqrt(_loc7_));
         if(0 <= _loc8_ && _loc8_ <= param5 * _loc6_)
         {
            _loc8_ /= _loc6_;
            param2[0] = _loc8_;
            param3.x = _loc11_ + _loc8_ * _loc13_;
            param3.y = _loc12_ + _loc8_ * _loc14_;
            param3.Normalize();
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(param1:b2AABB, param2:b2XForm) : void
      {
         var _loc4_:b2Mat22 = param2.R;
         var _loc3_:Number = param2.position.x + (_loc4_.col1.x * m_localPosition.x + _loc4_.col2.x * m_localPosition.y);
         var _loc5_:Number = param2.position.y + (_loc4_.col1.y * m_localPosition.x + _loc4_.col2.y * m_localPosition.y);
         param1.lowerBound.Set(_loc3_ - m_radius,_loc5_ - m_radius);
         param1.upperBound.Set(_loc3_ + m_radius,_loc5_ + m_radius);
      }
      
      override public function ComputeSweptAABB(param1:b2AABB, param2:b2XForm, param3:b2XForm) : void
      {
         var _loc7_:b2Mat22 = null;
         _loc7_ = param2.R;
         var _loc4_:Number = param2.position.x + (_loc7_.col1.x * m_localPosition.x + _loc7_.col2.x * m_localPosition.y);
         var _loc8_:Number = param2.position.y + (_loc7_.col1.y * m_localPosition.x + _loc7_.col2.y * m_localPosition.y);
         _loc7_ = param3.R;
         var _loc6_:Number = param3.position.x + (_loc7_.col1.x * m_localPosition.x + _loc7_.col2.x * m_localPosition.y);
         var _loc5_:Number = param3.position.y + (_loc7_.col1.y * m_localPosition.x + _loc7_.col2.y * m_localPosition.y);
         param1.lowerBound.Set((_loc4_ < _loc6_ ? _loc4_ : _loc6_) - m_radius,(_loc8_ < _loc5_ ? _loc8_ : _loc5_) - m_radius);
         param1.upperBound.Set((_loc4_ > _loc6_ ? _loc4_ : _loc6_) + m_radius,(_loc8_ > _loc5_ ? _loc8_ : _loc5_) + m_radius);
      }
      
      override public function ComputeMass(param1:b2MassData) : void
      {
         param1.mass = m_density * 3.141592653589793 * m_radius * m_radius;
         param1.center.SetV(m_localPosition);
         param1.I = param1.mass * (0.5 * m_radius * m_radius + (m_localPosition.x * m_localPosition.x + m_localPosition.y * m_localPosition.y));
      }
      
      public function GetLocalPosition() : b2Vec2
      {
         return m_localPosition;
      }
      
      public function GetRadius() : Number
      {
         return m_radius;
      }
      
      override public function UpdateSweepRadius(param1:b2Vec2) : void
      {
         var _loc2_:Number = m_localPosition.x - param1.x;
         var _loc3_:Number = m_localPosition.y - param1.y;
         _loc2_ = Math.sqrt(_loc2_ * _loc2_ + _loc3_ * _loc3_);
         m_sweepRadius = _loc2_ + m_radius - 0.04;
      }
   }
}

