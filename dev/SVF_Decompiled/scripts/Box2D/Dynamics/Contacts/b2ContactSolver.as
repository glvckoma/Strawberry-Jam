package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2ContactSolver
   {
      public var m_step:b2TimeStep;
      
      public var m_allocator:*;
      
      public var m_constraints:Array;
      
      public var m_constraintCount:int;
      
      public function b2ContactSolver(param1:b2TimeStep, param2:Array, param3:int, param4:*)
      {
         var _loc14_:b2Contact = null;
         var _loc28_:int = 0;
         var _loc44_:b2Mat22 = null;
         var _loc9_:b2Body = null;
         var _loc10_:b2Body = null;
         var _loc11_:int = 0;
         var _loc6_:Array = null;
         var _loc33_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc29_:int = 0;
         var _loc16_:b2Manifold = null;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc23_:b2ContactConstraint = null;
         var _loc31_:* = 0;
         var _loc32_:b2ManifoldPoint = null;
         var _loc12_:b2ContactConstraintPoint = null;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc43_:* = NaN;
         var _loc45_:Number = NaN;
         var _loc17_:* = NaN;
         var _loc15_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc26_:* = NaN;
         var _loc22_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc39_:Number = NaN;
         m_step = new b2TimeStep();
         m_constraints = [];
         super();
         m_step.dt = param1.dt;
         m_step.inv_dt = param1.inv_dt;
         m_step.maxIterations = param1.maxIterations;
         m_allocator = param4;
         m_constraintCount = 0;
         _loc28_ = 0;
         while(_loc28_ < param3)
         {
            _loc14_ = param2[_loc28_];
            m_constraintCount += _loc14_.m_manifoldCount;
            _loc28_++;
         }
         _loc28_ = 0;
         while(_loc28_ < m_constraintCount)
         {
            m_constraints[_loc28_] = new b2ContactConstraint();
            _loc28_++;
         }
         var _loc27_:int = 0;
         _loc28_ = 0;
         while(_loc28_ < param3)
         {
            _loc14_ = param2[_loc28_];
            _loc9_ = _loc14_.m_shape1.m_body;
            _loc10_ = _loc14_.m_shape2.m_body;
            _loc11_ = _loc14_.m_manifoldCount;
            _loc6_ = _loc14_.GetManifolds();
            _loc33_ = _loc14_.m_friction;
            _loc37_ = _loc14_.m_restitution;
            _loc46_ = _loc9_.m_linearVelocity.x;
            _loc47_ = _loc9_.m_linearVelocity.y;
            _loc21_ = _loc10_.m_linearVelocity.x;
            _loc20_ = _loc10_.m_linearVelocity.y;
            _loc18_ = _loc9_.m_angularVelocity;
            _loc19_ = _loc10_.m_angularVelocity;
            _loc29_ = 0;
            while(_loc29_ < _loc11_)
            {
               _loc16_ = _loc6_[_loc29_];
               _loc5_ = _loc16_.normal.x;
               _loc7_ = _loc16_.normal.y;
               _loc23_ = m_constraints[_loc27_];
               _loc23_.body1 = _loc9_;
               _loc23_.body2 = _loc10_;
               _loc23_.manifold = _loc16_;
               _loc23_.normal.x = _loc5_;
               _loc23_.normal.y = _loc7_;
               _loc23_.pointCount = _loc16_.pointCount;
               _loc23_.friction = _loc33_;
               _loc23_.restitution = _loc37_;
               _loc31_ = 0;
               while(_loc31_ < _loc23_.pointCount)
               {
                  _loc32_ = _loc16_.points[_loc31_];
                  _loc12_ = _loc23_.points[_loc31_];
                  _loc12_.normalImpulse = _loc32_.normalImpulse;
                  _loc12_.tangentImpulse = _loc32_.tangentImpulse;
                  _loc12_.separation = _loc32_.separation;
                  _loc12_.positionImpulse = 0;
                  _loc12_.localAnchor1.SetV(_loc32_.localPoint1);
                  _loc12_.localAnchor2.SetV(_loc32_.localPoint2);
                  _loc44_ = _loc9_.m_xf.R;
                  _loc43_ = _loc32_.localPoint1.x - _loc9_.m_sweep.localCenter.x;
                  _loc45_ = _loc32_.localPoint1.y - _loc9_.m_sweep.localCenter.y;
                  _loc24_ = _loc44_.col1.x * _loc43_ + _loc44_.col2.x * _loc45_;
                  _loc45_ = _loc44_.col1.y * _loc43_ + _loc44_.col2.y * _loc45_;
                  _loc43_ = _loc24_;
                  _loc12_.r1.Set(_loc43_,_loc45_);
                  _loc44_ = _loc10_.m_xf.R;
                  _loc17_ = _loc32_.localPoint2.x - _loc10_.m_sweep.localCenter.x;
                  _loc15_ = _loc32_.localPoint2.y - _loc10_.m_sweep.localCenter.y;
                  _loc24_ = _loc44_.col1.x * _loc17_ + _loc44_.col2.x * _loc15_;
                  _loc15_ = _loc44_.col1.y * _loc17_ + _loc44_.col2.y * _loc15_;
                  _loc17_ = _loc24_;
                  _loc12_.r2.Set(_loc17_,_loc15_);
                  _loc8_ = _loc43_ * _loc43_ + _loc45_ * _loc45_;
                  _loc30_ = _loc17_ * _loc17_ + _loc15_ * _loc15_;
                  _loc38_ = _loc43_ * _loc5_ + _loc45_ * _loc7_;
                  _loc41_ = _loc17_ * _loc5_ + _loc15_ * _loc7_;
                  _loc13_ = _loc9_.m_invMass + _loc10_.m_invMass;
                  _loc13_ = _loc13_ + (_loc9_.m_invI * (_loc8_ - _loc38_ * _loc38_) + _loc10_.m_invI * (_loc30_ - _loc41_ * _loc41_));
                  _loc12_.normalMass = 1 / _loc13_;
                  _loc36_ = _loc9_.m_mass * _loc9_.m_invMass + _loc10_.m_mass * _loc10_.m_invMass;
                  _loc36_ = _loc36_ + (_loc9_.m_mass * _loc9_.m_invI * (_loc8_ - _loc38_ * _loc38_) + _loc10_.m_mass * _loc10_.m_invI * (_loc30_ - _loc41_ * _loc41_));
                  _loc12_.equalizedMass = 1 / _loc36_;
                  _loc26_ = _loc7_;
                  _loc22_ = -_loc5_;
                  _loc34_ = _loc43_ * _loc26_ + _loc45_ * _loc22_;
                  _loc35_ = _loc17_ * _loc26_ + _loc15_ * _loc22_;
                  _loc42_ = _loc9_.m_invMass + _loc10_.m_invMass;
                  _loc42_ = _loc42_ + (_loc9_.m_invI * (_loc8_ - _loc34_ * _loc34_) + _loc10_.m_invI * (_loc30_ - _loc35_ * _loc35_));
                  _loc12_.tangentMass = 1 / _loc42_;
                  _loc12_.velocityBias = 0;
                  if(_loc12_.separation > 0)
                  {
                     _loc12_.velocityBias = -60 * _loc12_.separation;
                  }
                  _loc24_ = _loc21_ + -_loc19_ * _loc15_ - _loc46_ - -_loc18_ * _loc45_;
                  _loc25_ = _loc20_ + _loc19_ * _loc17_ - _loc47_ - _loc18_ * _loc43_;
                  _loc39_ = _loc23_.normal.x * _loc24_ + _loc23_.normal.y * _loc25_;
                  if(_loc39_ < -1)
                  {
                     _loc12_.velocityBias += -_loc23_.restitution * _loc39_;
                  }
                  _loc31_++;
               }
               _loc27_++;
               _loc29_++;
            }
            _loc28_++;
         }
      }
      
      public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc13_:int = 0;
         var _loc8_:b2ContactConstraint = null;
         var _loc18_:b2Body = null;
         var _loc19_:b2Body = null;
         var _loc9_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc11_:* = NaN;
         var _loc2_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc15_:int = 0;
         var _loc17_:int = 0;
         var _loc20_:b2ContactConstraintPoint = null;
         var _loc12_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc16_:b2ContactConstraintPoint = null;
         _loc13_ = 0;
         while(_loc13_ < m_constraintCount)
         {
            _loc8_ = m_constraints[_loc13_];
            _loc18_ = _loc8_.body1;
            _loc19_ = _loc8_.body2;
            _loc9_ = _loc18_.m_invMass;
            _loc5_ = _loc18_.m_invI;
            _loc6_ = _loc19_.m_invMass;
            _loc3_ = _loc19_.m_invI;
            _loc4_ = _loc8_.normal.x;
            _loc11_ = _loc7_ = _loc8_.normal.y;
            _loc2_ = -_loc4_;
            if(param1.warmStarting)
            {
               _loc17_ = _loc8_.pointCount;
               _loc15_ = 0;
               while(_loc15_ < _loc17_)
               {
                  _loc20_ = _loc8_.points[_loc15_];
                  _loc20_.normalImpulse = _loc20_.normalImpulse * param1.dtRatio;
                  _loc20_.tangentImpulse *= param1.dtRatio;
                  _loc12_ = _loc20_.normalImpulse * _loc4_ + _loc20_.tangentImpulse * _loc11_;
                  _loc14_ = _loc20_.normalImpulse * _loc7_ + _loc20_.tangentImpulse * _loc2_;
                  _loc18_.m_angularVelocity -= _loc5_ * (_loc20_.r1.x * _loc14_ - _loc20_.r1.y * _loc12_);
                  _loc18_.m_linearVelocity.x -= _loc9_ * _loc12_;
                  _loc18_.m_linearVelocity.y -= _loc9_ * _loc14_;
                  _loc19_.m_angularVelocity += _loc3_ * (_loc20_.r2.x * _loc14_ - _loc20_.r2.y * _loc12_);
                  _loc19_.m_linearVelocity.x += _loc6_ * _loc12_;
                  _loc19_.m_linearVelocity.y += _loc6_ * _loc14_;
                  _loc15_++;
               }
            }
            else
            {
               _loc17_ = _loc8_.pointCount;
               _loc15_ = 0;
               while(_loc15_ < _loc17_)
               {
                  _loc16_ = _loc8_.points[_loc15_];
                  _loc16_.normalImpulse = 0;
                  _loc16_.tangentImpulse = 0;
                  _loc15_++;
               }
            }
            _loc13_++;
         }
      }
      
      public function SolveVelocityConstraints() : void
      {
         var _loc24_:int = 0;
         var _loc14_:b2ContactConstraintPoint = null;
         var _loc30_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc23_:int = 0;
         var _loc20_:b2ContactConstraint = null;
         var _loc12_:b2Body = null;
         var _loc13_:b2Body = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc36_:b2Vec2 = null;
         var _loc37_:b2Vec2 = null;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc22_:* = NaN;
         var _loc19_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc25_:int = 0;
         var _loc10_:Number = NaN;
         _loc23_ = 0;
         while(_loc23_ < m_constraintCount)
         {
            _loc20_ = m_constraints[_loc23_];
            _loc12_ = _loc20_.body1;
            _loc13_ = _loc20_.body2;
            _loc17_ = _loc12_.m_angularVelocity;
            _loc18_ = _loc13_.m_angularVelocity;
            _loc36_ = _loc12_.m_linearVelocity;
            _loc37_ = _loc13_.m_linearVelocity;
            _loc6_ = _loc12_.m_invMass;
            _loc3_ = _loc12_.m_invI;
            _loc4_ = _loc13_.m_invMass;
            _loc1_ = _loc13_.m_invI;
            _loc2_ = _loc20_.normal.x;
            _loc22_ = _loc5_ = _loc20_.normal.y;
            _loc19_ = -_loc2_;
            _loc26_ = _loc20_.friction;
            _loc25_ = _loc20_.pointCount;
            _loc24_ = 0;
            while(_loc24_ < _loc25_)
            {
               _loc14_ = _loc20_.points[_loc24_];
               _loc8_ = _loc37_.x + -_loc18_ * _loc14_.r2.y - _loc36_.x - -_loc17_ * _loc14_.r1.y;
               _loc7_ = _loc37_.y + _loc18_ * _loc14_.r2.x - _loc36_.y - _loc17_ * _loc14_.r1.x;
               _loc31_ = _loc8_ * _loc2_ + _loc7_ * _loc5_;
               _loc32_ = -_loc14_.normalMass * (_loc31_ - _loc14_.velocityBias);
               _loc38_ = _loc8_ * _loc22_ + _loc7_ * _loc19_;
               _loc27_ = _loc14_.tangentMass * -_loc38_;
               _loc35_ = b2Math.b2Max(_loc14_.normalImpulse + _loc32_,0);
               _loc32_ = _loc35_ - _loc14_.normalImpulse;
               _loc10_ = _loc26_ * _loc14_.normalImpulse;
               _loc28_ = b2Math.b2Clamp(_loc14_.tangentImpulse + _loc27_,-_loc10_,_loc10_);
               _loc27_ = _loc28_ - _loc14_.tangentImpulse;
               _loc9_ = _loc32_ * _loc2_ + _loc27_ * _loc22_;
               _loc11_ = _loc32_ * _loc5_ + _loc27_ * _loc19_;
               _loc36_.x -= _loc6_ * _loc9_;
               _loc36_.y -= _loc6_ * _loc11_;
               _loc17_ -= _loc3_ * (_loc14_.r1.x * _loc11_ - _loc14_.r1.y * _loc9_);
               _loc37_.x += _loc4_ * _loc9_;
               _loc37_.y += _loc4_ * _loc11_;
               _loc18_ += _loc1_ * (_loc14_.r2.x * _loc11_ - _loc14_.r2.y * _loc9_);
               _loc14_.normalImpulse = _loc35_;
               _loc14_.tangentImpulse = _loc28_;
               _loc24_++;
            }
            _loc12_.m_angularVelocity = _loc17_;
            _loc13_.m_angularVelocity = _loc18_;
            _loc23_++;
         }
      }
      
      public function FinalizeVelocityConstraints() : void
      {
         var _loc2_:int = 0;
         var _loc1_:b2ContactConstraint = null;
         var _loc4_:b2Manifold = null;
         var _loc3_:int = 0;
         var _loc5_:b2ManifoldPoint = null;
         var _loc6_:b2ContactConstraintPoint = null;
         _loc2_ = 0;
         while(_loc2_ < m_constraintCount)
         {
            _loc1_ = m_constraints[_loc2_];
            _loc4_ = _loc1_.manifold;
            _loc3_ = 0;
            while(_loc3_ < _loc1_.pointCount)
            {
               _loc5_ = _loc4_.points[_loc3_];
               _loc6_ = _loc1_.points[_loc3_];
               _loc5_.normalImpulse = _loc6_.normalImpulse;
               _loc5_.tangentImpulse = _loc6_.tangentImpulse;
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      public function SolvePositionConstraints(param1:Number) : Boolean
      {
         var _loc35_:b2Mat22 = null;
         var _loc32_:b2Vec2 = null;
         var _loc29_:int = 0;
         var _loc24_:b2ContactConstraint = null;
         var _loc12_:b2Body = null;
         var _loc13_:b2Body = null;
         var _loc23_:b2Vec2 = null;
         var _loc21_:Number = NaN;
         var _loc26_:b2Vec2 = null;
         var _loc19_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc31_:int = 0;
         var _loc30_:int = 0;
         var _loc14_:b2ContactConstraintPoint = null;
         var _loc34_:* = NaN;
         var _loc37_:Number = NaN;
         var _loc20_:* = NaN;
         var _loc18_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc28_:Number = 0;
         _loc29_ = 0;
         while(_loc29_ < m_constraintCount)
         {
            _loc24_ = m_constraints[_loc29_];
            _loc12_ = _loc24_.body1;
            _loc13_ = _loc24_.body2;
            _loc23_ = _loc12_.m_sweep.c;
            _loc21_ = _loc12_.m_sweep.a;
            _loc26_ = _loc13_.m_sweep.c;
            _loc19_ = _loc13_.m_sweep.a;
            _loc7_ = _loc12_.m_mass * _loc12_.m_invMass;
            _loc4_ = _loc12_.m_mass * _loc12_.m_invI;
            _loc5_ = _loc13_.m_mass * _loc13_.m_invMass;
            _loc2_ = _loc13_.m_mass * _loc13_.m_invI;
            _loc3_ = _loc24_.normal.x;
            _loc6_ = _loc24_.normal.y;
            _loc31_ = _loc24_.pointCount;
            _loc30_ = 0;
            while(_loc30_ < _loc31_)
            {
               _loc14_ = _loc24_.points[_loc30_];
               _loc35_ = _loc12_.m_xf.R;
               _loc32_ = _loc12_.m_sweep.localCenter;
               _loc34_ = _loc14_.localAnchor1.x - _loc32_.x;
               _loc37_ = _loc14_.localAnchor1.y - _loc32_.y;
               _loc25_ = _loc35_.col1.x * _loc34_ + _loc35_.col2.x * _loc37_;
               _loc37_ = _loc35_.col1.y * _loc34_ + _loc35_.col2.y * _loc37_;
               _loc34_ = _loc25_;
               _loc35_ = _loc13_.m_xf.R;
               _loc32_ = _loc13_.m_sweep.localCenter;
               _loc20_ = _loc14_.localAnchor2.x - _loc32_.x;
               _loc18_ = _loc14_.localAnchor2.y - _loc32_.y;
               _loc25_ = _loc35_.col1.x * _loc20_ + _loc35_.col2.x * _loc18_;
               _loc18_ = _loc35_.col1.y * _loc20_ + _loc35_.col2.y * _loc18_;
               _loc20_ = _loc25_;
               _loc33_ = _loc23_.x + _loc34_;
               _loc36_ = _loc23_.y + _loc37_;
               _loc17_ = _loc26_.x + _loc20_;
               _loc16_ = _loc26_.y + _loc18_;
               _loc11_ = _loc17_ - _loc33_;
               _loc9_ = _loc16_ - _loc36_;
               _loc15_ = _loc11_ * _loc3_ + _loc9_ * _loc6_ + _loc14_.separation;
               _loc28_ = b2Math.b2Min(_loc28_,_loc15_);
               _loc8_ = param1 * b2Math.b2Clamp(_loc15_ + 0.005,-0.2,0);
               _loc10_ = -_loc14_.equalizedMass * _loc8_;
               _loc38_ = _loc14_.positionImpulse;
               _loc14_.positionImpulse = b2Math.b2Max(_loc38_ + _loc10_,0);
               _loc10_ = _loc14_.positionImpulse - _loc38_;
               _loc27_ = _loc10_ * _loc3_;
               _loc22_ = _loc10_ * _loc6_;
               _loc23_.x -= _loc7_ * _loc27_;
               _loc23_.y -= _loc7_ * _loc22_;
               _loc21_ -= _loc4_ * (_loc34_ * _loc22_ - _loc37_ * _loc27_);
               _loc12_.m_sweep.a = _loc21_;
               _loc12_.SynchronizeTransform();
               _loc26_.x += _loc5_ * _loc27_;
               _loc26_.y += _loc5_ * _loc22_;
               _loc19_ += _loc2_ * (_loc20_ * _loc22_ - _loc18_ * _loc27_);
               _loc13_.m_sweep.a = _loc19_;
               _loc13_.SynchronizeTransform();
               _loc30_++;
            }
            _loc29_++;
         }
         return _loc28_ >= -1.5 * 0.005;
      }
   }
}

