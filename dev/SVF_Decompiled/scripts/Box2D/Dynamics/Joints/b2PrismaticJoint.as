package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2PrismaticJoint extends b2Joint
   {
      public var m_localAnchor1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_localXAxis1:b2Vec2;
      
      public var m_localYAxis1:b2Vec2;
      
      public var m_refAngle:Number;
      
      public var m_linearJacobian:b2Jacobian;
      
      public var m_linearMass:Number;
      
      public var m_force:Number;
      
      public var m_angularMass:Number;
      
      public var m_torque:Number;
      
      public var m_motorJacobian:b2Jacobian;
      
      public var m_motorMass:Number;
      
      public var m_motorForce:Number;
      
      public var m_limitForce:Number;
      
      public var m_limitPositionImpulse:Number;
      
      public var m_lowerTranslation:Number;
      
      public var m_upperTranslation:Number;
      
      public var m_maxMotorForce:Number;
      
      public var m_motorSpeed:Number;
      
      public var m_enableLimit:Boolean;
      
      public var m_enableMotor:Boolean;
      
      public var m_limitState:int;
      
      public function b2PrismaticJoint(param1:b2PrismaticJointDef)
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         m_localAnchor1 = new b2Vec2();
         m_localAnchor2 = new b2Vec2();
         m_localXAxis1 = new b2Vec2();
         m_localYAxis1 = new b2Vec2();
         m_linearJacobian = new b2Jacobian();
         m_motorJacobian = new b2Jacobian();
         super(param1);
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_localXAxis1.SetV(param1.localAxis1);
         m_localYAxis1.x = -m_localXAxis1.y;
         m_localYAxis1.y = m_localXAxis1.x;
         m_refAngle = param1.referenceAngle;
         m_linearJacobian.SetZero();
         m_linearMass = 0;
         m_force = 0;
         m_angularMass = 0;
         m_torque = 0;
         m_motorJacobian.SetZero();
         m_motorMass = 0;
         m_motorForce = 0;
         m_limitForce = 0;
         m_limitPositionImpulse = 0;
         m_lowerTranslation = param1.lowerTranslation;
         m_upperTranslation = param1.upperTranslation;
         m_maxMotorForce = param1.maxMotorForce;
         m_motorSpeed = param1.motorSpeed;
         m_enableLimit = param1.enableLimit;
         m_enableMotor = param1.enableMotor;
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
         var _loc4_:b2Mat22 = m_body1.m_xf.R;
         var _loc3_:Number = m_limitForce * (_loc4_.col1.x * m_localXAxis1.x + _loc4_.col2.x * m_localXAxis1.y);
         var _loc1_:Number = m_limitForce * (_loc4_.col1.y * m_localXAxis1.x + _loc4_.col2.y * m_localXAxis1.y);
         var _loc2_:Number = m_force * (_loc4_.col1.x * m_localYAxis1.x + _loc4_.col2.x * m_localYAxis1.y);
         var _loc5_:Number = m_force * (_loc4_.col1.y * m_localYAxis1.x + _loc4_.col2.y * m_localYAxis1.y);
         return new b2Vec2(m_limitForce * _loc3_ + m_force * _loc2_,m_limitForce * _loc1_ + m_force * _loc5_);
      }
      
      override public function GetReactionTorque() : Number
      {
         return m_torque;
      }
      
      public function GetJointTranslation() : Number
      {
         var _loc9_:b2Body = m_body1;
         var _loc1_:b2Body = m_body2;
         var _loc2_:b2Vec2 = _loc9_.GetWorldPoint(m_localAnchor1);
         var _loc3_:b2Vec2 = _loc1_.GetWorldPoint(m_localAnchor2);
         var _loc4_:Number = _loc3_.x - _loc2_.x;
         var _loc5_:Number = _loc3_.y - _loc2_.y;
         var _loc8_:b2Vec2 = _loc9_.GetWorldVector(m_localXAxis1);
         return _loc8_.x * _loc4_ + _loc8_.y * _loc5_;
      }
      
      public function GetJointSpeed() : Number
      {
         var _loc13_:b2Mat22 = null;
         var _loc4_:b2Body = m_body1;
         var _loc5_:b2Body = m_body2;
         _loc13_ = _loc4_.m_xf.R;
         var _loc11_:* = m_localAnchor1.x - _loc4_.m_sweep.localCenter.x;
         var _loc17_:Number = m_localAnchor1.y - _loc4_.m_sweep.localCenter.y;
         var _loc1_:Number = _loc13_.col1.x * _loc11_ + _loc13_.col2.x * _loc17_;
         _loc17_ = _loc13_.col1.y * _loc11_ + _loc13_.col2.y * _loc17_;
         _loc11_ = _loc1_;
         _loc13_ = _loc5_.m_xf.R;
         var _loc14_:* = m_localAnchor2.x - _loc5_.m_sweep.localCenter.x;
         var _loc12_:Number = m_localAnchor2.y - _loc5_.m_sweep.localCenter.y;
         _loc1_ = _loc13_.col1.x * _loc14_ + _loc13_.col2.x * _loc12_;
         _loc12_ = _loc13_.col1.y * _loc14_ + _loc13_.col2.y * _loc12_;
         _loc14_ = _loc1_;
         var _loc8_:Number = _loc4_.m_sweep.c.x + _loc11_;
         var _loc15_:Number = _loc4_.m_sweep.c.y + _loc17_;
         var _loc10_:Number = _loc5_.m_sweep.c.x + _loc14_;
         var _loc9_:Number = _loc5_.m_sweep.c.y + _loc12_;
         var _loc6_:Number = _loc10_ - _loc8_;
         var _loc7_:Number = _loc9_ - _loc15_;
         var _loc2_:b2Vec2 = _loc4_.GetWorldVector(m_localXAxis1);
         var _loc18_:b2Vec2 = _loc4_.m_linearVelocity;
         var _loc20_:b2Vec2 = _loc5_.m_linearVelocity;
         var _loc16_:Number = _loc4_.m_angularVelocity;
         var _loc19_:Number = _loc5_.m_angularVelocity;
         return _loc6_ * (-_loc16_ * _loc2_.y) + _loc7_ * (_loc16_ * _loc2_.x) + (_loc2_.x * (_loc20_.x + -_loc19_ * _loc12_ - _loc18_.x - -_loc16_ * _loc17_) + _loc2_.y * (_loc20_.y + _loc19_ * _loc14_ - _loc18_.y - _loc16_ * _loc11_));
      }
      
      public function IsLimitEnabled() : Boolean
      {
         return m_enableLimit;
      }
      
      public function EnableLimit(param1:Boolean) : void
      {
         m_enableLimit = param1;
      }
      
      public function GetLowerLimit() : Number
      {
         return m_lowerTranslation;
      }
      
      public function GetUpperLimit() : Number
      {
         return m_upperTranslation;
      }
      
      public function SetLimits(param1:Number, param2:Number) : void
      {
         m_lowerTranslation = param1;
         m_upperTranslation = param2;
      }
      
      public function IsMotorEnabled() : Boolean
      {
         return m_enableMotor;
      }
      
      public function EnableMotor(param1:Boolean) : void
      {
         m_enableMotor = param1;
      }
      
      public function SetMotorSpeed(param1:Number) : void
      {
         m_motorSpeed = param1;
      }
      
      public function GetMotorSpeed() : Number
      {
         return m_motorSpeed;
      }
      
      public function SetMaxMotorForce(param1:Number) : void
      {
         m_maxMotorForce = param1;
      }
      
      public function GetMotorForce() : Number
      {
         return m_motorForce;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc27_:b2Mat22 = null;
         var _loc17_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc6_:b2Body = m_body1;
         var _loc7_:b2Body = m_body2;
         _loc27_ = _loc6_.m_xf.R;
         var _loc25_:* = m_localAnchor1.x - _loc6_.m_sweep.localCenter.x;
         var _loc28_:Number = m_localAnchor1.y - _loc6_.m_sweep.localCenter.y;
         _loc17_ = _loc27_.col1.x * _loc25_ + _loc27_.col2.x * _loc28_;
         _loc28_ = _loc27_.col1.y * _loc25_ + _loc27_.col2.y * _loc28_;
         _loc25_ = _loc17_;
         _loc27_ = _loc7_.m_xf.R;
         var _loc15_:* = m_localAnchor2.x - _loc7_.m_sweep.localCenter.x;
         var _loc14_:Number = m_localAnchor2.y - _loc7_.m_sweep.localCenter.y;
         _loc17_ = _loc27_.col1.x * _loc15_ + _loc27_.col2.x * _loc14_;
         _loc14_ = _loc27_.col1.y * _loc15_ + _loc27_.col2.y * _loc14_;
         _loc15_ = _loc17_;
         var _loc5_:Number = _loc6_.m_invMass;
         var _loc3_:Number = _loc7_.m_invMass;
         var _loc4_:Number = _loc6_.m_invI;
         var _loc2_:Number = _loc7_.m_invI;
         _loc27_ = _loc6_.m_xf.R;
         var _loc8_:Number = _loc27_.col1.x * m_localYAxis1.x + _loc27_.col2.x * m_localYAxis1.y;
         var _loc20_:Number = _loc27_.col1.y * m_localYAxis1.x + _loc27_.col2.y * m_localYAxis1.y;
         var _loc10_:Number = _loc7_.m_sweep.c.x + _loc15_ - _loc6_.m_sweep.c.x;
         var _loc12_:Number = _loc7_.m_sweep.c.y + _loc14_ - _loc6_.m_sweep.c.y;
         m_linearJacobian.linear1.x = -_loc8_;
         m_linearJacobian.linear1.y = -_loc20_;
         m_linearJacobian.linear2.x = _loc8_;
         m_linearJacobian.linear2.y = _loc20_;
         m_linearJacobian.angular1 = -(_loc10_ * _loc20_ - _loc12_ * _loc8_);
         m_linearJacobian.angular2 = _loc15_ * _loc20_ - _loc14_ * _loc8_;
         m_linearMass = _loc5_ + _loc4_ * m_linearJacobian.angular1 * m_linearJacobian.angular1 + _loc3_ + _loc2_ * m_linearJacobian.angular2 * m_linearJacobian.angular2;
         m_linearMass = 1 / m_linearMass;
         m_angularMass = _loc4_ + _loc2_;
         if(m_angularMass > Number.MIN_VALUE)
         {
            m_angularMass = 1 / m_angularMass;
         }
         if(m_enableLimit || m_enableMotor)
         {
            _loc27_ = _loc6_.m_xf.R;
            _loc11_ = _loc27_.col1.x * m_localXAxis1.x + _loc27_.col2.x * m_localXAxis1.y;
            _loc9_ = _loc27_.col1.y * m_localXAxis1.x + _loc27_.col2.y * m_localXAxis1.y;
            m_motorJacobian.linear1.x = -_loc11_;
            m_motorJacobian.linear1.y = -_loc9_;
            m_motorJacobian.linear2.x = _loc11_;
            m_motorJacobian.linear2.y = _loc9_;
            m_motorJacobian.angular1 = -(_loc10_ * _loc9_ - _loc12_ * _loc11_);
            m_motorJacobian.angular2 = _loc15_ * _loc9_ - _loc14_ * _loc11_;
            m_motorMass = _loc5_ + _loc4_ * m_motorJacobian.angular1 * m_motorJacobian.angular1 + _loc3_ + _loc2_ * m_motorJacobian.angular2 * m_motorJacobian.angular2;
            m_motorMass = 1 / m_motorMass;
            if(m_enableLimit)
            {
               _loc21_ = _loc10_ - _loc25_;
               _loc22_ = _loc12_ - _loc28_;
               _loc26_ = _loc11_ * _loc21_ + _loc9_ * _loc22_;
               if(b2Math.b2Abs(m_upperTranslation - m_lowerTranslation) < 2 * 0.005)
               {
                  m_limitState = 3;
               }
               else if(_loc26_ <= m_lowerTranslation)
               {
                  if(m_limitState != 1)
                  {
                     m_limitForce = 0;
                  }
                  m_limitState = 1;
               }
               else if(_loc26_ >= m_upperTranslation)
               {
                  if(m_limitState != 2)
                  {
                     m_limitForce = 0;
                  }
                  m_limitState = 2;
               }
               else
               {
                  m_limitState = 0;
                  m_limitForce = 0;
               }
            }
         }
         if(m_enableMotor == false)
         {
            m_motorForce = 0;
         }
         if(m_enableLimit == false)
         {
            m_limitForce = 0;
         }
         if(param1.warmStarting)
         {
            _loc13_ = param1.dt * (m_force * m_linearJacobian.linear1.x + (m_motorForce + m_limitForce) * m_motorJacobian.linear1.x);
            _loc16_ = param1.dt * (m_force * m_linearJacobian.linear1.y + (m_motorForce + m_limitForce) * m_motorJacobian.linear1.y);
            _loc24_ = param1.dt * (m_force * m_linearJacobian.linear2.x + (m_motorForce + m_limitForce) * m_motorJacobian.linear2.x);
            _loc23_ = param1.dt * (m_force * m_linearJacobian.linear2.y + (m_motorForce + m_limitForce) * m_motorJacobian.linear2.y);
            _loc18_ = param1.dt * (m_force * m_linearJacobian.angular1 - m_torque + (m_motorForce + m_limitForce) * m_motorJacobian.angular1);
            _loc19_ = param1.dt * (m_force * m_linearJacobian.angular2 + m_torque + (m_motorForce + m_limitForce) * m_motorJacobian.angular2);
            _loc6_.m_linearVelocity.x += _loc5_ * _loc13_;
            _loc6_.m_linearVelocity.y += _loc5_ * _loc16_;
            _loc6_.m_angularVelocity += _loc4_ * _loc18_;
            _loc7_.m_linearVelocity.x += _loc3_ * _loc24_;
            _loc7_.m_linearVelocity.y += _loc3_ * _loc23_;
            _loc7_.m_angularVelocity += _loc2_ * _loc19_;
         }
         else
         {
            m_force = 0;
            m_torque = 0;
            m_limitForce = 0;
            m_motorForce = 0;
         }
         m_limitPositionImpulse = 0;
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:b2Body = m_body1;
         var _loc10_:b2Body = m_body2;
         var _loc5_:Number = _loc9_.m_invMass;
         var _loc3_:Number = _loc10_.m_invMass;
         var _loc4_:Number = _loc9_.m_invI;
         var _loc2_:Number = _loc10_.m_invI;
         var _loc18_:Number = m_linearJacobian.Compute(_loc9_.m_linearVelocity,_loc9_.m_angularVelocity,_loc10_.m_linearVelocity,_loc10_.m_angularVelocity);
         var _loc17_:Number = -param1.inv_dt * m_linearMass * _loc18_;
         m_force += _loc17_;
         var _loc11_:Number = param1.dt * _loc17_;
         _loc9_.m_linearVelocity.x += _loc5_ * _loc11_ * m_linearJacobian.linear1.x;
         _loc9_.m_linearVelocity.y += _loc5_ * _loc11_ * m_linearJacobian.linear1.y;
         _loc9_.m_angularVelocity += _loc4_ * _loc11_ * m_linearJacobian.angular1;
         _loc10_.m_linearVelocity.x += _loc3_ * _loc11_ * m_linearJacobian.linear2.x;
         _loc10_.m_linearVelocity.y += _loc3_ * _loc11_ * m_linearJacobian.linear2.y;
         _loc10_.m_angularVelocity += _loc2_ * _loc11_ * m_linearJacobian.angular2;
         var _loc19_:Number = _loc10_.m_angularVelocity - _loc9_.m_angularVelocity;
         var _loc6_:Number = -param1.inv_dt * m_angularMass * _loc19_;
         m_torque += _loc6_;
         var _loc7_:Number = param1.dt * _loc6_;
         _loc9_.m_angularVelocity -= _loc4_ * _loc7_;
         _loc10_.m_angularVelocity += _loc2_ * _loc7_;
         if(m_enableMotor && m_limitState != 3)
         {
            _loc16_ = m_motorJacobian.Compute(_loc9_.m_linearVelocity,_loc9_.m_angularVelocity,_loc10_.m_linearVelocity,_loc10_.m_angularVelocity) - m_motorSpeed;
            _loc15_ = -param1.inv_dt * m_motorMass * _loc16_;
            _loc12_ = m_motorForce;
            m_motorForce = b2Math.b2Clamp(m_motorForce + _loc15_,-m_maxMotorForce,m_maxMotorForce);
            _loc15_ = m_motorForce - _loc12_;
            _loc11_ = param1.dt * _loc15_;
            _loc9_.m_linearVelocity.x += _loc5_ * _loc11_ * m_motorJacobian.linear1.x;
            _loc9_.m_linearVelocity.y += _loc5_ * _loc11_ * m_motorJacobian.linear1.y;
            _loc9_.m_angularVelocity += _loc4_ * _loc11_ * m_motorJacobian.angular1;
            _loc10_.m_linearVelocity.x += _loc3_ * _loc11_ * m_motorJacobian.linear2.x;
            _loc10_.m_linearVelocity.y += _loc3_ * _loc11_ * m_motorJacobian.linear2.y;
            _loc10_.m_angularVelocity += _loc2_ * _loc11_ * m_motorJacobian.angular2;
         }
         if(m_enableLimit && m_limitState != 0)
         {
            _loc13_ = m_motorJacobian.Compute(_loc9_.m_linearVelocity,_loc9_.m_angularVelocity,_loc10_.m_linearVelocity,_loc10_.m_angularVelocity);
            _loc8_ = -param1.inv_dt * m_motorMass * _loc13_;
            if(m_limitState == 3)
            {
               m_limitForce += _loc8_;
            }
            else if(m_limitState == 1)
            {
               _loc14_ = m_limitForce;
               m_limitForce = b2Math.b2Max(m_limitForce + _loc8_,0);
               _loc8_ = m_limitForce - _loc14_;
            }
            else if(m_limitState == 2)
            {
               _loc14_ = m_limitForce;
               m_limitForce = b2Math.b2Min(m_limitForce + _loc8_,0);
               _loc8_ = m_limitForce - _loc14_;
            }
            _loc11_ = param1.dt * _loc8_;
            _loc9_.m_linearVelocity.x += _loc5_ * _loc11_ * m_motorJacobian.linear1.x;
            _loc9_.m_linearVelocity.y += _loc5_ * _loc11_ * m_motorJacobian.linear1.y;
            _loc9_.m_angularVelocity += _loc4_ * _loc11_ * m_motorJacobian.angular1;
            _loc10_.m_linearVelocity.x += _loc3_ * _loc11_ * m_motorJacobian.linear2.x;
            _loc10_.m_linearVelocity.y += _loc3_ * _loc11_ * m_motorJacobian.linear2.y;
            _loc10_.m_angularVelocity += _loc2_ * _loc11_ * m_motorJacobian.angular2;
         }
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc22_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc29_:b2Mat22 = null;
         var _loc19_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc8_:b2Body = m_body1;
         var _loc9_:b2Body = m_body2;
         var _loc5_:Number = _loc8_.m_invMass;
         var _loc2_:Number = _loc9_.m_invMass;
         var _loc3_:Number = _loc8_.m_invI;
         var _loc1_:Number = _loc9_.m_invI;
         _loc29_ = _loc8_.m_xf.R;
         var _loc27_:* = m_localAnchor1.x - _loc8_.m_sweep.localCenter.x;
         var _loc31_:Number = m_localAnchor1.y - _loc8_.m_sweep.localCenter.y;
         _loc19_ = _loc29_.col1.x * _loc27_ + _loc29_.col2.x * _loc31_;
         _loc31_ = _loc29_.col1.y * _loc27_ + _loc29_.col2.y * _loc31_;
         _loc27_ = _loc19_;
         _loc29_ = _loc9_.m_xf.R;
         var _loc17_:* = m_localAnchor2.x - _loc9_.m_sweep.localCenter.x;
         var _loc16_:Number = m_localAnchor2.y - _loc9_.m_sweep.localCenter.y;
         _loc19_ = _loc29_.col1.x * _loc17_ + _loc29_.col2.x * _loc16_;
         _loc16_ = _loc29_.col1.y * _loc17_ + _loc29_.col2.y * _loc16_;
         _loc17_ = _loc19_;
         var _loc26_:Number = _loc8_.m_sweep.c.x + _loc27_;
         var _loc30_:Number = _loc8_.m_sweep.c.y + _loc31_;
         var _loc15_:Number = _loc9_.m_sweep.c.x + _loc17_;
         var _loc14_:Number = _loc9_.m_sweep.c.y + _loc16_;
         var _loc23_:Number = _loc15_ - _loc26_;
         var _loc24_:Number = _loc14_ - _loc30_;
         _loc29_ = _loc8_.m_xf.R;
         var _loc10_:Number = _loc29_.col1.x * m_localYAxis1.x + _loc29_.col2.x * m_localYAxis1.y;
         var _loc21_:Number = _loc29_.col1.y * m_localYAxis1.x + _loc29_.col2.y * m_localYAxis1.y;
         var _loc25_:Number = _loc10_ * _loc23_ + _loc21_ * _loc24_;
         _loc25_ = b2Math.b2Clamp(_loc25_,-0.2,0.2);
         var _loc7_:Number = -m_linearMass * _loc25_;
         _loc8_.m_sweep.c.x += _loc5_ * _loc7_ * m_linearJacobian.linear1.x;
         _loc8_.m_sweep.c.y += _loc5_ * _loc7_ * m_linearJacobian.linear1.y;
         _loc8_.m_sweep.a += _loc3_ * _loc7_ * m_linearJacobian.angular1;
         _loc9_.m_sweep.c.x += _loc2_ * _loc7_ * m_linearJacobian.linear2.x;
         _loc9_.m_sweep.c.y += _loc2_ * _loc7_ * m_linearJacobian.linear2.y;
         _loc9_.m_sweep.a += _loc1_ * _loc7_ * m_linearJacobian.angular2;
         var _loc4_:Number = b2Math.b2Abs(_loc25_);
         var _loc6_:Number = _loc9_.m_sweep.a - _loc8_.m_sweep.a - m_refAngle;
         _loc6_ = b2Math.b2Clamp(_loc6_,-0.13962634015954636,0.13962634015954636);
         var _loc32_:Number = -m_angularMass * _loc6_;
         _loc8_.m_sweep.a -= _loc8_.m_invI * _loc32_;
         _loc9_.m_sweep.a += _loc9_.m_invI * _loc32_;
         _loc8_.SynchronizeTransform();
         _loc9_.SynchronizeTransform();
         var _loc20_:Number = b2Math.b2Abs(_loc6_);
         if(m_enableLimit && m_limitState != 0)
         {
            _loc29_ = _loc8_.m_xf.R;
            _loc27_ = m_localAnchor1.x - _loc8_.m_sweep.localCenter.x;
            _loc31_ = m_localAnchor1.y - _loc8_.m_sweep.localCenter.y;
            _loc19_ = _loc29_.col1.x * _loc27_ + _loc29_.col2.x * _loc31_;
            _loc31_ = _loc29_.col1.y * _loc27_ + _loc29_.col2.y * _loc31_;
            _loc27_ = _loc19_;
            _loc29_ = _loc9_.m_xf.R;
            _loc17_ = m_localAnchor2.x - _loc9_.m_sweep.localCenter.x;
            _loc16_ = m_localAnchor2.y - _loc9_.m_sweep.localCenter.y;
            _loc19_ = _loc29_.col1.x * _loc17_ + _loc29_.col2.x * _loc16_;
            _loc16_ = _loc29_.col1.y * _loc17_ + _loc29_.col2.y * _loc16_;
            _loc17_ = _loc19_;
            _loc26_ = _loc8_.m_sweep.c.x + _loc27_;
            _loc30_ = _loc8_.m_sweep.c.y + _loc31_;
            _loc15_ = _loc9_.m_sweep.c.x + _loc17_;
            _loc14_ = _loc9_.m_sweep.c.y + _loc16_;
            _loc23_ = _loc15_ - _loc26_;
            _loc24_ = _loc14_ - _loc30_;
            _loc29_ = _loc8_.m_xf.R;
            _loc12_ = _loc29_.col1.x * m_localXAxis1.x + _loc29_.col2.x * m_localXAxis1.y;
            _loc11_ = _loc29_.col1.y * m_localXAxis1.x + _loc29_.col2.y * m_localXAxis1.y;
            _loc28_ = _loc12_ * _loc23_ + _loc11_ * _loc24_;
            _loc18_ = 0;
            if(m_limitState == 3)
            {
               _loc22_ = b2Math.b2Clamp(_loc28_,-0.2,0.2);
               _loc18_ = -m_motorMass * _loc22_;
               _loc4_ = b2Math.b2Max(_loc4_,b2Math.b2Abs(_loc6_));
            }
            else if(m_limitState == 1)
            {
               _loc22_ = _loc28_ - m_lowerTranslation;
               _loc4_ = b2Math.b2Max(_loc4_,-_loc22_);
               _loc22_ = b2Math.b2Clamp(_loc22_ + 0.005,-0.2,0);
               _loc18_ = -m_motorMass * _loc22_;
               _loc13_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Max(m_limitPositionImpulse + _loc18_,0);
               _loc18_ = m_limitPositionImpulse - _loc13_;
            }
            else if(m_limitState == 2)
            {
               _loc22_ = _loc28_ - m_upperTranslation;
               _loc4_ = b2Math.b2Max(_loc4_,_loc22_);
               _loc22_ = b2Math.b2Clamp(_loc22_ - 0.005,0,0.2);
               _loc18_ = -m_motorMass * _loc22_;
               _loc13_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Min(m_limitPositionImpulse + _loc18_,0);
               _loc18_ = m_limitPositionImpulse - _loc13_;
            }
            _loc8_.m_sweep.c.x += _loc5_ * _loc18_ * m_motorJacobian.linear1.x;
            _loc8_.m_sweep.c.y += _loc5_ * _loc18_ * m_motorJacobian.linear1.y;
            _loc8_.m_sweep.a += _loc3_ * _loc18_ * m_motorJacobian.angular1;
            _loc9_.m_sweep.c.x += _loc2_ * _loc18_ * m_motorJacobian.linear2.x;
            _loc9_.m_sweep.c.y += _loc2_ * _loc18_ * m_motorJacobian.linear2.y;
            _loc9_.m_sweep.a += _loc1_ * _loc18_ * m_motorJacobian.angular2;
            _loc8_.SynchronizeTransform();
            _loc9_.SynchronizeTransform();
         }
         return _loc4_ <= 0.005 && _loc20_ <= 0.03490658503988659;
      }
   }
}

