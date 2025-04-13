package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2DistanceJoint extends b2Joint
   {
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_u:b2Vec2;
      
      public var m_frequencyHz:Number;
      
      public var m_dampingRatio:Number;
      
      public var m_gamma:Number;
      
      public var m_bias:Number;
      
      public var m_impulse:Number;
      
      public var m_mass:Number;
      
      public var m_length:Number;
      
      public function b2DistanceJoint(param1:b2DistanceJointDef)
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         m_localAnchor1 = new b2Vec2();
         m_localAnchor2 = new b2Vec2();
         m_u = new b2Vec2();
         super(param1);
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_length = param1.length;
         m_frequencyHz = param1.frequencyHz;
         m_dampingRatio = param1.dampingRatio;
         m_impulse = 0;
         m_gamma = 0;
         m_bias = 0;
         m_inv_dt = 0;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc15_:b2Mat22 = null;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         m_inv_dt = param1.inv_dt;
         var _loc11_:b2Body = m_body1;
         var _loc12_:b2Body = m_body2;
         _loc15_ = _loc11_.m_xf.R;
         var _loc13_:* = m_localAnchor1.x - _loc11_.m_sweep.localCenter.x;
         var _loc17_:Number = m_localAnchor1.y - _loc11_.m_sweep.localCenter.y;
         _loc4_ = _loc15_.col1.x * _loc13_ + _loc15_.col2.x * _loc17_;
         _loc17_ = _loc15_.col1.y * _loc13_ + _loc15_.col2.y * _loc17_;
         _loc13_ = _loc4_;
         _loc15_ = _loc12_.m_xf.R;
         var _loc16_:* = m_localAnchor2.x - _loc12_.m_sweep.localCenter.x;
         var _loc14_:Number = m_localAnchor2.y - _loc12_.m_sweep.localCenter.y;
         _loc4_ = _loc15_.col1.x * _loc16_ + _loc15_.col2.x * _loc14_;
         _loc14_ = _loc15_.col1.y * _loc16_ + _loc15_.col2.y * _loc14_;
         _loc16_ = _loc4_;
         m_u.x = _loc12_.m_sweep.c.x + _loc16_ - _loc11_.m_sweep.c.x - _loc13_;
         m_u.y = _loc12_.m_sweep.c.y + _loc14_ - _loc11_.m_sweep.c.y - _loc17_;
         var _loc6_:Number = Math.sqrt(m_u.x * m_u.x + m_u.y * m_u.y);
         if(_loc6_ > 0.005)
         {
            m_u.Multiply(1 / _loc6_);
         }
         else
         {
            m_u.SetZero();
         }
         var _loc19_:Number = _loc13_ * m_u.y - _loc17_ * m_u.x;
         var _loc18_:Number = _loc16_ * m_u.y - _loc14_ * m_u.x;
         var _loc2_:Number = _loc11_.m_invMass + _loc11_.m_invI * _loc19_ * _loc19_ + _loc12_.m_invMass + _loc12_.m_invI * _loc18_ * _loc18_;
         m_mass = 1 / _loc2_;
         if(m_frequencyHz > 0)
         {
            _loc3_ = _loc6_ - m_length;
            _loc10_ = 2 * 3.141592653589793 * m_frequencyHz;
            _loc5_ = 2 * m_mass * m_dampingRatio * _loc10_;
            _loc9_ = m_mass * _loc10_ * _loc10_;
            m_gamma = 1 / (param1.dt * (_loc5_ + param1.dt * _loc9_));
            m_bias = _loc3_ * param1.dt * _loc9_ * m_gamma;
            m_mass = 1 / (_loc2_ + m_gamma);
         }
         if(param1.warmStarting)
         {
            m_impulse *= param1.dtRatio;
            _loc7_ = m_impulse * m_u.x;
            _loc8_ = m_impulse * m_u.y;
            _loc11_.m_linearVelocity.x -= _loc11_.m_invMass * _loc7_;
            _loc11_.m_linearVelocity.y -= _loc11_.m_invMass * _loc8_;
            _loc11_.m_angularVelocity -= _loc11_.m_invI * (_loc13_ * _loc8_ - _loc17_ * _loc7_);
            _loc12_.m_linearVelocity.x += _loc12_.m_invMass * _loc7_;
            _loc12_.m_linearVelocity.y += _loc12_.m_invMass * _loc8_;
            _loc12_.m_angularVelocity += _loc12_.m_invI * (_loc16_ * _loc8_ - _loc14_ * _loc7_);
         }
         else
         {
            m_impulse = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc9_:b2Mat22 = null;
         var _loc5_:b2Body = m_body1;
         var _loc6_:b2Body = m_body2;
         _loc9_ = _loc5_.m_xf.R;
         var _loc7_:* = m_localAnchor1.x - _loc5_.m_sweep.localCenter.x;
         var _loc13_:Number = m_localAnchor1.y - _loc5_.m_sweep.localCenter.y;
         var _loc2_:Number = _loc9_.col1.x * _loc7_ + _loc9_.col2.x * _loc13_;
         _loc13_ = _loc9_.col1.y * _loc7_ + _loc9_.col2.y * _loc13_;
         _loc7_ = _loc2_;
         _loc9_ = _loc6_.m_xf.R;
         var _loc10_:* = m_localAnchor2.x - _loc6_.m_sweep.localCenter.x;
         var _loc8_:Number = m_localAnchor2.y - _loc6_.m_sweep.localCenter.y;
         _loc2_ = _loc9_.col1.x * _loc10_ + _loc9_.col2.x * _loc8_;
         _loc8_ = _loc9_.col1.y * _loc10_ + _loc9_.col2.y * _loc8_;
         _loc10_ = _loc2_;
         var _loc14_:Number = _loc5_.m_linearVelocity.x + -_loc5_.m_angularVelocity * _loc13_;
         var _loc17_:Number = _loc5_.m_linearVelocity.y + _loc5_.m_angularVelocity * _loc7_;
         var _loc16_:Number = _loc6_.m_linearVelocity.x + -_loc6_.m_angularVelocity * _loc8_;
         var _loc15_:Number = _loc6_.m_linearVelocity.y + _loc6_.m_angularVelocity * _loc10_;
         var _loc11_:Number = m_u.x * (_loc16_ - _loc14_) + m_u.y * (_loc15_ - _loc17_);
         var _loc12_:Number = -m_mass * (_loc11_ + m_bias + m_gamma * m_impulse);
         m_impulse += _loc12_;
         var _loc3_:Number = _loc12_ * m_u.x;
         var _loc4_:Number = _loc12_ * m_u.y;
         _loc5_.m_linearVelocity.x -= _loc5_.m_invMass * _loc3_;
         _loc5_.m_linearVelocity.y -= _loc5_.m_invMass * _loc4_;
         _loc5_.m_angularVelocity -= _loc5_.m_invI * (_loc7_ * _loc4_ - _loc13_ * _loc3_);
         _loc6_.m_linearVelocity.x += _loc6_.m_invMass * _loc3_;
         _loc6_.m_linearVelocity.y += _loc6_.m_invMass * _loc4_;
         _loc6_.m_angularVelocity += _loc6_.m_invI * (_loc10_ * _loc4_ - _loc8_ * _loc3_);
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc12_:b2Mat22 = null;
         if(m_frequencyHz > 0)
         {
            return true;
         }
         var _loc6_:b2Body = m_body1;
         var _loc7_:b2Body = m_body2;
         _loc12_ = _loc6_.m_xf.R;
         var _loc10_:* = m_localAnchor1.x - _loc6_.m_sweep.localCenter.x;
         var _loc15_:Number = m_localAnchor1.y - _loc6_.m_sweep.localCenter.y;
         var _loc2_:Number = _loc12_.col1.x * _loc10_ + _loc12_.col2.x * _loc15_;
         _loc15_ = _loc12_.col1.y * _loc10_ + _loc12_.col2.y * _loc15_;
         _loc10_ = _loc2_;
         _loc12_ = _loc7_.m_xf.R;
         var _loc13_:* = m_localAnchor2.x - _loc7_.m_sweep.localCenter.x;
         var _loc11_:Number = m_localAnchor2.y - _loc7_.m_sweep.localCenter.y;
         _loc2_ = _loc12_.col1.x * _loc13_ + _loc12_.col2.x * _loc11_;
         _loc11_ = _loc12_.col1.y * _loc13_ + _loc12_.col2.y * _loc11_;
         _loc13_ = _loc2_;
         var _loc8_:Number = _loc7_.m_sweep.c.x + _loc13_ - _loc6_.m_sweep.c.x - _loc10_;
         var _loc9_:Number = _loc7_.m_sweep.c.y + _loc11_ - _loc6_.m_sweep.c.y - _loc15_;
         var _loc3_:Number = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
         _loc8_ /= _loc3_;
         _loc9_ /= _loc3_;
         var _loc1_:Number = _loc3_ - m_length;
         _loc1_ = b2Math.b2Clamp(_loc1_,-0.2,0.2);
         var _loc14_:Number = -m_mass * _loc1_;
         m_u.Set(_loc8_,_loc9_);
         var _loc4_:Number = _loc14_ * m_u.x;
         var _loc5_:Number = _loc14_ * m_u.y;
         _loc6_.m_sweep.c.x -= _loc6_.m_invMass * _loc4_;
         _loc6_.m_sweep.c.y -= _loc6_.m_invMass * _loc5_;
         _loc6_.m_sweep.a -= _loc6_.m_invI * (_loc10_ * _loc5_ - _loc15_ * _loc4_);
         _loc7_.m_sweep.c.x += _loc7_.m_invMass * _loc4_;
         _loc7_.m_sweep.c.y += _loc7_.m_invMass * _loc5_;
         _loc7_.m_sweep.a += _loc7_.m_invI * (_loc13_ * _loc5_ - _loc11_ * _loc4_);
         _loc6_.SynchronizeTransform();
         _loc7_.SynchronizeTransform();
         return b2Math.b2Abs(_loc1_) < 0.005;
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_body1.GetWorldPoint(m_localAnchor1);
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(m_localAnchor2);
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         var _loc1_:b2Vec2 = new b2Vec2();
         _loc1_.SetV(m_u);
         _loc1_.Multiply(m_inv_dt * m_impulse);
         return _loc1_;
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
   }
}

