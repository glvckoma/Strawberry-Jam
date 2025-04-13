package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2RevoluteJoint extends b2Joint
   {
      public static var tImpulse:b2Vec2 = new b2Vec2();
      
      private var K:b2Mat22 = new b2Mat22();
      
      private var K1:b2Mat22 = new b2Mat22();
      
      private var K2:b2Mat22 = new b2Mat22();
      
      private var K3:b2Mat22 = new b2Mat22();
      
      public var m_localAnchor1:b2Vec2 = new b2Vec2();
      
      public var m_localAnchor2:b2Vec2 = new b2Vec2();
      
      public var m_pivotForce:b2Vec2 = new b2Vec2();
      
      public var m_motorForce:Number;
      
      public var m_limitForce:Number;
      
      public var m_limitPositionImpulse:Number;
      
      public var m_pivotMass:b2Mat22 = new b2Mat22();
      
      public var m_motorMass:Number;
      
      public var m_enableMotor:Boolean;
      
      public var m_maxMotorTorque:Number;
      
      public var m_motorSpeed:Number;
      
      public var m_enableLimit:Boolean;
      
      public var m_referenceAngle:Number;
      
      public var m_lowerAngle:Number;
      
      public var m_upperAngle:Number;
      
      public var m_limitState:int;
      
      public function b2RevoluteJoint(param1:b2RevoluteJointDef)
      {
         super(param1);
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_referenceAngle = param1.referenceAngle;
         m_pivotForce.Set(0,0);
         m_motorForce = 0;
         m_limitForce = 0;
         m_limitPositionImpulse = 0;
         m_lowerAngle = param1.lowerAngle;
         m_upperAngle = param1.upperAngle;
         m_maxMotorTorque = param1.maxMotorTorque;
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
         return m_pivotForce;
      }
      
      override public function GetReactionTorque() : Number
      {
         return m_limitForce;
      }
      
      public function GetJointAngle() : Number
      {
         return m_body2.m_sweep.a - m_body1.m_sweep.a - m_referenceAngle;
      }
      
      public function GetJointSpeed() : Number
      {
         return m_body2.m_angularVelocity - m_body1.m_angularVelocity;
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
         return m_lowerAngle;
      }
      
      public function GetUpperLimit() : Number
      {
         return m_upperAngle;
      }
      
      public function SetLimits(param1:Number, param2:Number) : void
      {
         m_lowerAngle = param1;
         m_upperAngle = param2;
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
      
      public function SetMaxMotorTorque(param1:Number) : void
      {
         m_maxMotorTorque = param1;
      }
      
      public function GetMotorTorque() : Number
      {
         return m_motorForce;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc11_:b2Mat22 = null;
         var _loc6_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc7_:b2Body = m_body1;
         var _loc8_:b2Body = m_body2;
         _loc11_ = _loc7_.m_xf.R;
         var _loc9_:* = m_localAnchor1.x - _loc7_.m_sweep.localCenter.x;
         var _loc13_:Number = m_localAnchor1.y - _loc7_.m_sweep.localCenter.y;
         _loc6_ = _loc11_.col1.x * _loc9_ + _loc11_.col2.x * _loc13_;
         _loc13_ = _loc11_.col1.y * _loc9_ + _loc11_.col2.y * _loc13_;
         _loc9_ = _loc6_;
         _loc11_ = _loc8_.m_xf.R;
         var _loc12_:* = m_localAnchor2.x - _loc8_.m_sweep.localCenter.x;
         var _loc10_:Number = m_localAnchor2.y - _loc8_.m_sweep.localCenter.y;
         _loc6_ = _loc11_.col1.x * _loc12_ + _loc11_.col2.x * _loc10_;
         _loc10_ = _loc11_.col1.y * _loc12_ + _loc11_.col2.y * _loc10_;
         _loc12_ = _loc6_;
         var _loc5_:Number = _loc7_.m_invMass;
         var _loc3_:Number = _loc8_.m_invMass;
         var _loc4_:Number = _loc7_.m_invI;
         var _loc2_:Number = _loc8_.m_invI;
         K1.col1.x = _loc5_ + _loc3_;
         K1.col2.x = 0;
         K1.col1.y = 0;
         K1.col2.y = _loc5_ + _loc3_;
         K2.col1.x = _loc4_ * _loc13_ * _loc13_;
         K2.col2.x = -_loc4_ * _loc9_ * _loc13_;
         K2.col1.y = -_loc4_ * _loc9_ * _loc13_;
         K2.col2.y = _loc4_ * _loc9_ * _loc9_;
         K3.col1.x = _loc2_ * _loc10_ * _loc10_;
         K3.col2.x = -_loc2_ * _loc12_ * _loc10_;
         K3.col1.y = -_loc2_ * _loc12_ * _loc10_;
         K3.col2.y = _loc2_ * _loc12_ * _loc12_;
         K.SetM(K1);
         K.AddM(K2);
         K.AddM(K3);
         K.Invert(m_pivotMass);
         m_motorMass = 1 / (_loc4_ + _loc2_);
         if(m_enableMotor == false)
         {
            m_motorForce = 0;
         }
         if(m_enableLimit)
         {
            _loc14_ = _loc8_.m_sweep.a - _loc7_.m_sweep.a - m_referenceAngle;
            if(b2Math.b2Abs(m_upperAngle - m_lowerAngle) < 2 * 0.03490658503988659)
            {
               m_limitState = 3;
            }
            else if(_loc14_ <= m_lowerAngle)
            {
               if(m_limitState != 1)
               {
                  m_limitForce = 0;
               }
               m_limitState = 1;
            }
            else if(_loc14_ >= m_upperAngle)
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
         else
         {
            m_limitForce = 0;
         }
         if(param1.warmStarting)
         {
            _loc7_.m_linearVelocity.x -= param1.dt * _loc5_ * m_pivotForce.x;
            _loc7_.m_linearVelocity.y -= param1.dt * _loc5_ * m_pivotForce.y;
            _loc7_.m_angularVelocity -= param1.dt * _loc4_ * (_loc9_ * m_pivotForce.y - _loc13_ * m_pivotForce.x + m_motorForce + m_limitForce);
            _loc8_.m_linearVelocity.x += param1.dt * _loc3_ * m_pivotForce.x;
            _loc8_.m_linearVelocity.y += param1.dt * _loc3_ * m_pivotForce.y;
            _loc8_.m_angularVelocity += param1.dt * _loc2_ * (_loc12_ * m_pivotForce.y - _loc10_ * m_pivotForce.x + m_motorForce + m_limitForce);
         }
         else
         {
            m_pivotForce.SetZero();
            m_motorForce = 0;
            m_limitForce = 0;
         }
         m_limitPositionImpulse = 0;
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc18_:b2Mat22 = null;
         var _loc3_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:b2Body = m_body1;
         var _loc8_:b2Body = m_body2;
         _loc18_ = _loc7_.m_xf.R;
         var _loc16_:* = m_localAnchor1.x - _loc7_.m_sweep.localCenter.x;
         var _loc20_:Number = m_localAnchor1.y - _loc7_.m_sweep.localCenter.y;
         _loc3_ = _loc18_.col1.x * _loc16_ + _loc18_.col2.x * _loc20_;
         _loc20_ = _loc18_.col1.y * _loc16_ + _loc18_.col2.y * _loc20_;
         _loc16_ = _loc3_;
         _loc18_ = _loc8_.m_xf.R;
         var _loc19_:* = m_localAnchor2.x - _loc8_.m_sweep.localCenter.x;
         var _loc17_:Number = m_localAnchor2.y - _loc8_.m_sweep.localCenter.y;
         _loc3_ = _loc18_.col1.x * _loc19_ + _loc18_.col2.x * _loc17_;
         _loc17_ = _loc18_.col1.y * _loc19_ + _loc18_.col2.y * _loc17_;
         _loc19_ = _loc3_;
         var _loc12_:Number = _loc8_.m_linearVelocity.x + -_loc8_.m_angularVelocity * _loc17_ - _loc7_.m_linearVelocity.x - -_loc7_.m_angularVelocity * _loc20_;
         var _loc14_:Number = _loc8_.m_linearVelocity.y + _loc8_.m_angularVelocity * _loc19_ - _loc7_.m_linearVelocity.y - _loc7_.m_angularVelocity * _loc16_;
         var _loc21_:Number = -param1.inv_dt * (m_pivotMass.col1.x * _loc12_ + m_pivotMass.col2.x * _loc14_);
         var _loc2_:Number = -param1.inv_dt * (m_pivotMass.col1.y * _loc12_ + m_pivotMass.col2.y * _loc14_);
         m_pivotForce.x += _loc21_;
         m_pivotForce.y += _loc2_;
         var _loc4_:Number = param1.dt * _loc21_;
         var _loc5_:Number = param1.dt * _loc2_;
         _loc7_.m_linearVelocity.x -= _loc7_.m_invMass * _loc4_;
         _loc7_.m_linearVelocity.y -= _loc7_.m_invMass * _loc5_;
         _loc7_.m_angularVelocity -= _loc7_.m_invI * (_loc16_ * _loc5_ - _loc20_ * _loc4_);
         _loc8_.m_linearVelocity.x += _loc8_.m_invMass * _loc4_;
         _loc8_.m_linearVelocity.y += _loc8_.m_invMass * _loc5_;
         _loc8_.m_angularVelocity += _loc8_.m_invI * (_loc19_ * _loc5_ - _loc17_ * _loc4_);
         if(m_enableMotor && m_limitState != 3)
         {
            _loc15_ = _loc8_.m_angularVelocity - _loc7_.m_angularVelocity - m_motorSpeed;
            _loc13_ = -param1.inv_dt * m_motorMass * _loc15_;
            _loc9_ = m_motorForce;
            m_motorForce = b2Math.b2Clamp(m_motorForce + _loc13_,-m_maxMotorTorque,m_maxMotorTorque);
            _loc13_ = m_motorForce - _loc9_;
            _loc7_.m_angularVelocity -= _loc7_.m_invI * param1.dt * _loc13_;
            _loc8_.m_angularVelocity += _loc8_.m_invI * param1.dt * _loc13_;
         }
         if(m_enableLimit && m_limitState != 0)
         {
            _loc10_ = _loc8_.m_angularVelocity - _loc7_.m_angularVelocity;
            _loc6_ = -param1.inv_dt * m_motorMass * _loc10_;
            if(m_limitState == 3)
            {
               m_limitForce += _loc6_;
            }
            else if(m_limitState == 1)
            {
               _loc11_ = m_limitForce;
               m_limitForce = b2Math.b2Max(m_limitForce + _loc6_,0);
               _loc6_ = m_limitForce - _loc11_;
            }
            else if(m_limitState == 2)
            {
               _loc11_ = m_limitForce;
               m_limitForce = b2Math.b2Min(m_limitForce + _loc6_,0);
               _loc6_ = m_limitForce - _loc11_;
            }
            _loc7_.m_angularVelocity -= _loc7_.m_invI * param1.dt * _loc6_;
            _loc8_.m_angularVelocity += _loc8_.m_invI * param1.dt * _loc6_;
         }
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc10_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc24_:b2Mat22 = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc8_:b2Body = m_body1;
         var _loc9_:b2Body = m_body2;
         var _loc3_:Number = 0;
         _loc24_ = _loc8_.m_xf.R;
         var _loc23_:* = m_localAnchor1.x - _loc8_.m_sweep.localCenter.x;
         var _loc26_:Number = m_localAnchor1.y - _loc8_.m_sweep.localCenter.y;
         var _loc18_:Number = _loc24_.col1.x * _loc23_ + _loc24_.col2.x * _loc26_;
         _loc26_ = _loc24_.col1.y * _loc23_ + _loc24_.col2.y * _loc26_;
         _loc23_ = _loc18_;
         _loc24_ = _loc9_.m_xf.R;
         var _loc14_:* = m_localAnchor2.x - _loc9_.m_sweep.localCenter.x;
         var _loc13_:Number = m_localAnchor2.y - _loc9_.m_sweep.localCenter.y;
         _loc18_ = _loc24_.col1.x * _loc14_ + _loc24_.col2.x * _loc13_;
         _loc13_ = _loc24_.col1.y * _loc14_ + _loc24_.col2.y * _loc13_;
         _loc14_ = _loc18_;
         var _loc22_:Number = _loc8_.m_sweep.c.x + _loc23_;
         var _loc25_:Number = _loc8_.m_sweep.c.y + _loc26_;
         var _loc12_:Number = _loc9_.m_sweep.c.x + _loc14_;
         var _loc11_:Number = _loc9_.m_sweep.c.y + _loc13_;
         var _loc1_:Number = _loc12_ - _loc22_;
         var _loc4_:Number = _loc11_ - _loc25_;
         _loc3_ = Math.sqrt(_loc1_ * _loc1_ + _loc4_ * _loc4_);
         var _loc7_:Number = _loc8_.m_invMass;
         var _loc5_:Number = _loc9_.m_invMass;
         var _loc6_:Number = _loc8_.m_invI;
         var _loc2_:Number = _loc9_.m_invI;
         K1.col1.x = _loc7_ + _loc5_;
         K1.col2.x = 0;
         K1.col1.y = 0;
         K1.col2.y = _loc7_ + _loc5_;
         K2.col1.x = _loc6_ * _loc26_ * _loc26_;
         K2.col2.x = -_loc6_ * _loc23_ * _loc26_;
         K2.col1.y = -_loc6_ * _loc23_ * _loc26_;
         K2.col2.y = _loc6_ * _loc23_ * _loc23_;
         K3.col1.x = _loc2_ * _loc13_ * _loc13_;
         K3.col2.x = -_loc2_ * _loc14_ * _loc13_;
         K3.col1.y = -_loc2_ * _loc14_ * _loc13_;
         K3.col2.y = _loc2_ * _loc14_ * _loc14_;
         K.SetM(K1);
         K.AddM(K2);
         K.AddM(K3);
         K.Solve(tImpulse,-_loc1_,-_loc4_);
         var _loc19_:Number = tImpulse.x;
         var _loc17_:Number = tImpulse.y;
         _loc8_.m_sweep.c.x -= _loc8_.m_invMass * _loc19_;
         _loc8_.m_sweep.c.y -= _loc8_.m_invMass * _loc17_;
         _loc8_.m_sweep.a -= _loc8_.m_invI * (_loc23_ * _loc17_ - _loc26_ * _loc19_);
         _loc9_.m_sweep.c.x += _loc9_.m_invMass * _loc19_;
         _loc9_.m_sweep.c.y += _loc9_.m_invMass * _loc17_;
         _loc9_.m_sweep.a += _loc9_.m_invI * (_loc14_ * _loc17_ - _loc13_ * _loc19_);
         _loc8_.SynchronizeTransform();
         _loc9_.SynchronizeTransform();
         var _loc20_:Number = 0;
         if(m_enableLimit && m_limitState != 0)
         {
            _loc15_ = _loc9_.m_sweep.a - _loc8_.m_sweep.a - m_referenceAngle;
            _loc16_ = 0;
            if(m_limitState == 3)
            {
               _loc21_ = b2Math.b2Clamp(_loc15_,-0.13962634015954636,0.13962634015954636);
               _loc16_ = -m_motorMass * _loc21_;
               _loc20_ = b2Math.b2Abs(_loc21_);
            }
            else if(m_limitState == 1)
            {
               _loc21_ = _loc15_ - m_lowerAngle;
               _loc20_ = b2Math.b2Max(0,-_loc21_);
               _loc21_ = b2Math.b2Clamp(_loc21_ + 0.03490658503988659,-0.13962634015954636,0);
               _loc16_ = -m_motorMass * _loc21_;
               _loc10_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Max(m_limitPositionImpulse + _loc16_,0);
               _loc16_ = m_limitPositionImpulse - _loc10_;
            }
            else if(m_limitState == 2)
            {
               _loc21_ = _loc15_ - m_upperAngle;
               _loc20_ = b2Math.b2Max(0,_loc21_);
               _loc21_ = b2Math.b2Clamp(_loc21_ - 0.03490658503988659,0,0.13962634015954636);
               _loc16_ = -m_motorMass * _loc21_;
               _loc10_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Min(m_limitPositionImpulse + _loc16_,0);
               _loc16_ = m_limitPositionImpulse - _loc10_;
            }
            _loc8_.m_sweep.a -= _loc8_.m_invI * _loc16_;
            _loc9_.m_sweep.a += _loc9_.m_invI * _loc16_;
            _loc8_.SynchronizeTransform();
            _loc9_.SynchronizeTransform();
         }
         return _loc3_ <= 0.005 && _loc20_ <= 0.03490658503988659;
      }
   }
}

