package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   public class b2Island
   {
      private static var s_reportCR:b2ContactResult = new b2ContactResult();
      
      public var m_allocator:*;
      
      public var m_listener:b2ContactListener;
      
      public var m_bodies:Array;
      
      public var m_contacts:Array;
      
      public var m_joints:Array;
      
      public var m_bodyCount:int;
      
      public var m_jointCount:int;
      
      public var m_contactCount:int;
      
      public var m_bodyCapacity:int;
      
      public var m_contactCapacity:int;
      
      public var m_jointCapacity:int;
      
      public var m_positionIterationCount:int;
      
      public function b2Island(param1:int, param2:int, param3:int, param4:*, param5:b2ContactListener)
      {
         var _loc6_:int = 0;
         super();
         m_bodyCapacity = param1;
         m_contactCapacity = param2;
         m_jointCapacity = param3;
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
         m_allocator = param4;
         m_listener = param5;
         m_bodies = new Array(param1);
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            m_bodies[_loc6_] = null;
            _loc6_++;
         }
         m_contacts = new Array(param2);
         _loc6_ = 0;
         while(_loc6_ < param2)
         {
            m_contacts[_loc6_] = null;
            _loc6_++;
         }
         m_joints = new Array(param3);
         _loc6_ = 0;
         while(_loc6_ < param3)
         {
            m_joints[_loc6_] = null;
            _loc6_++;
         }
         m_positionIterationCount = 0;
      }
      
      public function Clear() : void
      {
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
      }
      
      public function Solve(param1:b2TimeStep, param2:b2Vec2, param3:Boolean, param4:Boolean) : void
      {
         var _loc7_:int = 0;
         var _loc5_:b2Body = null;
         var _loc6_:b2Joint = null;
         var _loc8_:int = 0;
         var _loc10_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:Number = NaN;
         _loc7_ = 0;
         while(_loc7_ < m_bodyCount)
         {
            _loc5_ = m_bodies[_loc7_];
            if(!_loc5_.IsStatic())
            {
               _loc5_.m_linearVelocity.x += param1.dt * (param2.x + _loc5_.m_invMass * _loc5_.m_force.x);
               _loc5_.m_linearVelocity.y += param1.dt * (param2.y + _loc5_.m_invMass * _loc5_.m_force.y);
               _loc5_.m_angularVelocity += param1.dt * _loc5_.m_invI * _loc5_.m_torque;
               _loc5_.m_force.SetZero();
               _loc5_.m_torque = 0;
               _loc5_.m_linearVelocity.Multiply(b2Math.b2Clamp(1 - param1.dt * _loc5_.m_linearDamping,0,1));
               _loc5_.m_angularVelocity *= b2Math.b2Clamp(1 - param1.dt * _loc5_.m_angularDamping,0,1);
               if(_loc5_.m_linearVelocity.LengthSquared() > 40000)
               {
                  _loc5_.m_linearVelocity.Normalize();
                  _loc5_.m_linearVelocity.x *= 200;
                  _loc5_.m_linearVelocity.y *= 200;
               }
               if(_loc5_.m_angularVelocity * _loc5_.m_angularVelocity > 62500)
               {
                  if(_loc5_.m_angularVelocity < 0)
                  {
                     _loc5_.m_angularVelocity = -250;
                  }
                  else
                  {
                     _loc5_.m_angularVelocity = 250;
                  }
               }
            }
            _loc7_++;
         }
         var _loc11_:b2ContactSolver = new b2ContactSolver(param1,m_contacts,m_contactCount,m_allocator);
         _loc11_.InitVelocityConstraints(param1);
         _loc7_ = 0;
         while(_loc7_ < m_jointCount)
         {
            _loc6_ = m_joints[_loc7_];
            _loc6_.InitVelocityConstraints(param1);
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < param1.maxIterations)
         {
            _loc11_.SolveVelocityConstraints();
            _loc8_ = 0;
            while(_loc8_ < m_jointCount)
            {
               _loc6_ = m_joints[_loc8_];
               _loc6_.SolveVelocityConstraints(param1);
               _loc8_++;
            }
            _loc7_++;
         }
         _loc11_.FinalizeVelocityConstraints();
         _loc7_ = 0;
         while(_loc7_ < m_bodyCount)
         {
            _loc5_ = m_bodies[_loc7_];
            if(!_loc5_.IsStatic())
            {
               _loc5_.m_sweep.c0.SetV(_loc5_.m_sweep.c);
               _loc5_.m_sweep.a0 = _loc5_.m_sweep.a;
               _loc5_.m_sweep.c.x += param1.dt * _loc5_.m_linearVelocity.x;
               _loc5_.m_sweep.c.y += param1.dt * _loc5_.m_linearVelocity.y;
               _loc5_.m_sweep.a += param1.dt * _loc5_.m_angularVelocity;
               _loc5_.SynchronizeTransform();
            }
            _loc7_++;
         }
         if(param3)
         {
            _loc7_ = 0;
            while(_loc7_ < m_jointCount)
            {
               _loc6_ = m_joints[_loc7_];
               _loc6_.InitPositionConstraints();
               _loc7_++;
            }
            m_positionIterationCount = 0;
            while(m_positionIterationCount < param1.maxIterations)
            {
               _loc10_ = _loc11_.SolvePositionConstraints(0.2);
               _loc12_ = true;
               _loc7_ = 0;
               while(_loc7_ < m_jointCount)
               {
                  _loc6_ = m_joints[_loc7_];
                  _loc14_ = _loc6_.SolvePositionConstraints();
                  _loc12_ &&= _loc14_;
                  _loc7_++;
               }
               if(_loc10_ && _loc12_)
               {
                  break;
               }
               ++m_positionIterationCount;
            }
         }
         Report(_loc11_.m_constraints);
         if(param4)
         {
            _loc15_ = 1.7976931348623157e+308;
            _loc13_ = 0.0001;
            _loc9_ = 0.0001234567901234568;
            _loc7_ = 0;
            while(_loc7_ < m_bodyCount)
            {
               _loc5_ = m_bodies[_loc7_];
               if(_loc5_.m_invMass != 0)
               {
                  if((_loc5_.m_flags & b2Body.e_allowSleepFlag) == 0)
                  {
                     _loc5_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  if((_loc5_.m_flags & b2Body.e_allowSleepFlag) == 0 || _loc5_.m_angularVelocity * _loc5_.m_angularVelocity > _loc9_ || b2Math.b2Dot(_loc5_.m_linearVelocity,_loc5_.m_linearVelocity) > _loc13_)
                  {
                     _loc5_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc5_.m_sleepTime += param1.dt;
                     _loc15_ = b2Math.b2Min(_loc15_,_loc5_.m_sleepTime);
                  }
               }
               _loc7_++;
            }
            if(_loc15_ >= 0.5)
            {
               _loc7_ = 0;
               while(_loc7_ < m_bodyCount)
               {
                  _loc5_ = m_bodies[_loc7_];
                  _loc5_.m_flags = _loc5_.m_flags | b2Body.e_sleepFlag;
                  _loc5_.m_linearVelocity.SetZero();
                  _loc5_.m_angularVelocity = 0;
                  _loc7_++;
               }
            }
         }
      }
      
      public function SolveTOI(param1:b2TimeStep) : void
      {
         var _loc5_:int = 0;
         var _loc2_:b2Body = null;
         var _loc3_:Boolean = false;
         var _loc4_:b2ContactSolver = new b2ContactSolver(param1,m_contacts,m_contactCount,m_allocator);
         _loc5_ = 0;
         while(_loc5_ < param1.maxIterations)
         {
            _loc4_.SolveVelocityConstraints();
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < m_bodyCount)
         {
            _loc2_ = m_bodies[_loc5_];
            if(!_loc2_.IsStatic())
            {
               _loc2_.m_sweep.c0.SetV(_loc2_.m_sweep.c);
               _loc2_.m_sweep.a0 = _loc2_.m_sweep.a;
               _loc2_.m_sweep.c.x += param1.dt * _loc2_.m_linearVelocity.x;
               _loc2_.m_sweep.c.y += param1.dt * _loc2_.m_linearVelocity.y;
               _loc2_.m_sweep.a += param1.dt * _loc2_.m_angularVelocity;
               _loc2_.SynchronizeTransform();
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < param1.maxIterations)
         {
            _loc3_ = _loc4_.SolvePositionConstraints(0.75);
            if(_loc3_)
            {
               break;
            }
            _loc5_++;
         }
         Report(_loc4_.m_constraints);
      }
      
      public function Report(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc4_:b2Contact = null;
         var _loc2_:b2ContactConstraint = null;
         var _loc9_:b2ContactResult = null;
         var _loc10_:b2Body = null;
         var _loc11_:int = 0;
         var _loc3_:Array = null;
         var _loc6_:int = 0;
         var _loc15_:b2Manifold = null;
         var _loc7_:int = 0;
         var _loc8_:b2ManifoldPoint = null;
         var _loc12_:b2ContactConstraintPoint = null;
         if(m_listener == null)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < m_contactCount)
         {
            _loc4_ = m_contacts[_loc5_];
            _loc2_ = param1[_loc5_];
            _loc9_ = s_reportCR;
            _loc9_.shape1 = _loc4_.m_shape1;
            _loc9_.shape2 = _loc4_.m_shape2;
            _loc10_ = _loc9_.shape1.m_body;
            _loc11_ = _loc4_.m_manifoldCount;
            _loc3_ = _loc4_.GetManifolds();
            _loc6_ = 0;
            while(_loc6_ < _loc11_)
            {
               _loc15_ = _loc3_[_loc6_];
               _loc9_.normal.SetV(_loc15_.normal);
               _loc7_ = 0;
               while(_loc7_ < _loc15_.pointCount)
               {
                  _loc8_ = _loc15_.points[_loc7_];
                  _loc12_ = _loc2_.points[_loc7_];
                  _loc9_.position = _loc10_.GetWorldPoint(_loc8_.localPoint1);
                  _loc9_.normalImpulse = _loc12_.normalImpulse;
                  _loc9_.tangentImpulse = _loc12_.tangentImpulse;
                  _loc9_.id.key = _loc8_.id.key;
                  m_listener.Result(_loc9_);
                  _loc7_++;
               }
               _loc6_++;
            }
            _loc5_++;
         }
      }
      
      public function AddBody(param1:b2Body) : void
      {
         m_bodies[m_bodyCount++] = param1;
      }
      
      public function AddContact(param1:b2Contact) : void
      {
         m_contacts[m_contactCount++] = param1;
      }
      
      public function AddJoint(param1:b2Joint) : void
      {
         m_joints[m_jointCount++] = param1;
      }
   }
}

