package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2GearJoint extends b2Joint
   {
      public var m_ground1:b2Body;
      
      public var m_ground2:b2Body;
      
      public var m_revolute1:b2RevoluteJoint;
      
      public var m_prismatic1:b2PrismaticJoint;
      
      public var m_revolute2:b2RevoluteJoint;
      
      public var m_prismatic2:b2PrismaticJoint;
      
      public var m_groundAnchor1:b2Vec2;
      
      public var m_groundAnchor2:b2Vec2;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_J:b2Jacobian;
      
      public var m_constant:Number;
      
      public var m_ratio:Number;
      
      public var m_mass:Number;
      
      public var m_force:Number;
      
      public function b2GearJoint(param1:b2GearJointDef)
      {
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         m_groundAnchor1 = new b2Vec2();
         m_groundAnchor2 = new b2Vec2();
         m_localAnchor1 = new b2Vec2();
         m_localAnchor2 = new b2Vec2();
         m_J = new b2Jacobian();
         super(param1);
         var _loc5_:int = param1.joint1.m_type;
         var _loc2_:int = param1.joint2.m_type;
         m_revolute1 = null;
         m_prismatic1 = null;
         m_revolute2 = null;
         m_prismatic2 = null;
         m_ground1 = param1.joint1.m_body1;
         m_body1 = param1.joint1.m_body2;
         if(_loc5_ == 1)
         {
            m_revolute1 = param1.joint1 as b2RevoluteJoint;
            m_groundAnchor1.SetV(m_revolute1.m_localAnchor1);
            m_localAnchor1.SetV(m_revolute1.m_localAnchor2);
            _loc4_ = m_revolute1.GetJointAngle();
         }
         else
         {
            m_prismatic1 = param1.joint1 as b2PrismaticJoint;
            m_groundAnchor1.SetV(m_prismatic1.m_localAnchor1);
            m_localAnchor1.SetV(m_prismatic1.m_localAnchor2);
            _loc4_ = m_prismatic1.GetJointTranslation();
         }
         m_ground2 = param1.joint2.m_body1;
         m_body2 = param1.joint2.m_body2;
         if(_loc2_ == 1)
         {
            m_revolute2 = param1.joint2 as b2RevoluteJoint;
            m_groundAnchor2.SetV(m_revolute2.m_localAnchor1);
            m_localAnchor2.SetV(m_revolute2.m_localAnchor2);
            _loc3_ = m_revolute2.GetJointAngle();
         }
         else
         {
            m_prismatic2 = param1.joint2 as b2PrismaticJoint;
            m_groundAnchor2.SetV(m_prismatic2.m_localAnchor1);
            m_localAnchor2.SetV(m_prismatic2.m_localAnchor2);
            _loc3_ = m_prismatic2.GetJointTranslation();
         }
         m_ratio = param1.ratio;
         m_constant = _loc4_ + m_ratio * _loc3_;
         m_force = 0;
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
         return new b2Vec2(m_force * m_J.linear2.x,m_force * m_J.linear2.y);
      }
      
      override public function GetReactionTorque() : Number
      {
         var _loc4_:b2Mat22 = m_body2.m_xf.R;
         var _loc2_:* = m_localAnchor1.x - m_body2.m_sweep.localCenter.x;
         var _loc3_:Number = m_localAnchor1.y - m_body2.m_sweep.localCenter.y;
         var _loc1_:Number = _loc4_.col1.x * _loc2_ + _loc4_.col2.x * _loc3_;
         _loc3_ = _loc4_.col1.y * _loc2_ + _loc4_.col2.y * _loc3_;
         _loc2_ = _loc1_;
         return m_force * m_J.angular2 - (_loc2_ * (m_force * m_J.linear2.y) - _loc3_ * (m_force * m_J.linear2.x));
      }
      
      public function GetRatio() : Number
      {
         return m_ratio;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:* = NaN;
         var _loc6_:Number = NaN;
         var _loc15_:b2Mat22 = null;
         var _loc14_:b2Vec2 = null;
         var _loc11_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc7_:b2Body = m_ground1;
         var _loc8_:b2Body = m_ground2;
         var _loc10_:b2Body = m_body1;
         var _loc12_:b2Body = m_body2;
         var _loc9_:Number = 0;
         m_J.SetZero();
         if(m_revolute1)
         {
            m_J.angular1 = -1;
            _loc9_ += _loc10_.m_invI;
         }
         else
         {
            _loc15_ = _loc7_.m_xf.R;
            _loc14_ = m_prismatic1.m_localXAxis1;
            _loc5_ = _loc15_.col1.x * _loc14_.x + _loc15_.col2.x * _loc14_.y;
            _loc3_ = _loc15_.col1.y * _loc14_.x + _loc15_.col2.y * _loc14_.y;
            _loc15_ = _loc10_.m_xf.R;
            _loc4_ = m_localAnchor1.x - _loc10_.m_sweep.localCenter.x;
            _loc6_ = m_localAnchor1.y - _loc10_.m_sweep.localCenter.y;
            _loc2_ = _loc15_.col1.x * _loc4_ + _loc15_.col2.x * _loc6_;
            _loc6_ = _loc15_.col1.y * _loc4_ + _loc15_.col2.y * _loc6_;
            _loc4_ = _loc2_;
            _loc11_ = _loc4_ * _loc3_ - _loc6_ * _loc5_;
            m_J.linear1.Set(-_loc5_,-_loc3_);
            m_J.angular1 = -_loc11_;
            _loc9_ += _loc10_.m_invMass + _loc10_.m_invI * _loc11_ * _loc11_;
         }
         if(m_revolute2)
         {
            m_J.angular2 = -m_ratio;
            _loc9_ += m_ratio * m_ratio * _loc12_.m_invI;
         }
         else
         {
            _loc15_ = _loc8_.m_xf.R;
            _loc14_ = m_prismatic2.m_localXAxis1;
            _loc5_ = _loc15_.col1.x * _loc14_.x + _loc15_.col2.x * _loc14_.y;
            _loc3_ = _loc15_.col1.y * _loc14_.x + _loc15_.col2.y * _loc14_.y;
            _loc15_ = _loc12_.m_xf.R;
            _loc4_ = m_localAnchor2.x - _loc12_.m_sweep.localCenter.x;
            _loc6_ = m_localAnchor2.y - _loc12_.m_sweep.localCenter.y;
            _loc2_ = _loc15_.col1.x * _loc4_ + _loc15_.col2.x * _loc6_;
            _loc6_ = _loc15_.col1.y * _loc4_ + _loc15_.col2.y * _loc6_;
            _loc4_ = _loc2_;
            _loc11_ = _loc4_ * _loc3_ - _loc6_ * _loc5_;
            m_J.linear2.Set(-m_ratio * _loc5_,-m_ratio * _loc3_);
            m_J.angular2 = -m_ratio * _loc11_;
            _loc9_ += m_ratio * m_ratio * (_loc12_.m_invMass + _loc12_.m_invI * _loc11_ * _loc11_);
         }
         m_mass = 1 / _loc9_;
         if(param1.warmStarting)
         {
            _loc13_ = param1.dt * m_force;
            _loc10_.m_linearVelocity.x += _loc10_.m_invMass * _loc13_ * m_J.linear1.x;
            _loc10_.m_linearVelocity.y += _loc10_.m_invMass * _loc13_ * m_J.linear1.y;
            _loc10_.m_angularVelocity += _loc10_.m_invI * _loc13_ * m_J.angular1;
            _loc12_.m_linearVelocity.x += _loc12_.m_invMass * _loc13_ * m_J.linear2.x;
            _loc12_.m_linearVelocity.y += _loc12_.m_invMass * _loc13_ * m_J.linear2.y;
            _loc12_.m_angularVelocity += _loc12_.m_invI * _loc13_ * m_J.angular2;
         }
         else
         {
            m_force = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc6_:b2Body = m_body1;
         var _loc2_:b2Body = m_body2;
         var _loc4_:Number = m_J.Compute(_loc6_.m_linearVelocity,_loc6_.m_angularVelocity,_loc2_.m_linearVelocity,_loc2_.m_angularVelocity);
         var _loc5_:Number = -param1.inv_dt * m_mass * _loc4_;
         m_force += _loc5_;
         var _loc3_:Number = param1.dt * _loc5_;
         _loc6_.m_linearVelocity.x += _loc6_.m_invMass * _loc3_ * m_J.linear1.x;
         _loc6_.m_linearVelocity.y += _loc6_.m_invMass * _loc3_ * m_J.linear1.y;
         _loc6_.m_angularVelocity += _loc6_.m_invI * _loc3_ * m_J.angular1;
         _loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc3_ * m_J.linear2.x;
         _loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc3_ * m_J.linear2.y;
         _loc2_.m_angularVelocity += _loc2_.m_invI * _loc3_ * m_J.angular2;
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc7_:b2Body = m_body1;
         var _loc1_:b2Body = m_body2;
         if(m_revolute1)
         {
            _loc5_ = m_revolute1.GetJointAngle();
         }
         else
         {
            _loc5_ = m_prismatic1.GetJointTranslation();
         }
         if(m_revolute2)
         {
            _loc4_ = m_revolute2.GetJointAngle();
         }
         else
         {
            _loc4_ = m_prismatic2.GetJointTranslation();
         }
         var _loc3_:Number = m_constant - (_loc5_ + m_ratio * _loc4_);
         var _loc6_:Number = -m_mass * _loc3_;
         _loc7_.m_sweep.c.x += _loc7_.m_invMass * _loc6_ * m_J.linear1.x;
         _loc7_.m_sweep.c.y += _loc7_.m_invMass * _loc6_ * m_J.linear1.y;
         _loc7_.m_sweep.a += _loc7_.m_invI * _loc6_ * m_J.angular1;
         _loc1_.m_sweep.c.x += _loc1_.m_invMass * _loc6_ * m_J.linear2.x;
         _loc1_.m_sweep.c.y += _loc1_.m_invMass * _loc6_ * m_J.linear2.y;
         _loc1_.m_sweep.a += _loc1_.m_invI * _loc6_ * m_J.angular2;
         _loc7_.SynchronizeTransform();
         _loc1_.SynchronizeTransform();
         return 0 < 0.005;
      }
   }
}

