package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2PolygonContact extends b2Contact
   {
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      private var m0:b2Manifold = new b2Manifold();
      
      private var m_manifolds:Array = [new b2Manifold()];
      
      public var m_manifold:b2Manifold;
      
      public function b2PolygonContact(param1:b2Shape, param2:b2Shape)
      {
         super(param1,param2);
         m_manifold = m_manifolds[0];
         m_manifold.pointCount = 0;
      }
      
      public static function Create(param1:b2Shape, param2:b2Shape, param3:*) : b2Contact
      {
         return new b2PolygonContact(param1,param2);
      }
      
      public static function Destroy(param1:b2Contact, param2:*) : void
      {
      }
      
      override public function Evaluate(param1:b2ContactListener) : void
      {
         var _loc11_:b2Vec2 = null;
         var _loc13_:b2Vec2 = null;
         var _loc5_:b2ManifoldPoint = null;
         var _loc6_:b2ContactPoint = null;
         var _loc3_:int = 0;
         var _loc2_:b2ManifoldPoint = null;
         var _loc10_:Boolean = false;
         var _loc9_:* = 0;
         var _loc4_:int = 0;
         var _loc7_:b2Body = m_shape1.m_body;
         var _loc8_:b2Body = m_shape2.m_body;
         m0.Set(m_manifold);
         b2Collision.b2CollidePolygons(m_manifold,m_shape1 as b2PolygonShape,_loc7_.m_xf,m_shape2 as b2PolygonShape,_loc8_.m_xf);
         var _loc12_:Array = [false,false];
         _loc6_ = s_evalCP;
         _loc6_.shape1 = m_shape1;
         _loc6_.shape2 = m_shape2;
         _loc6_.friction = m_friction;
         _loc6_.restitution = m_restitution;
         if(m_manifold.pointCount > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < m_manifold.pointCount)
            {
               _loc2_ = m_manifold.points[_loc3_];
               _loc2_.normalImpulse = 0;
               _loc2_.tangentImpulse = 0;
               _loc10_ = false;
               _loc9_ = _loc2_.id._key;
               _loc4_ = 0;
               while(_loc4_ < m0.pointCount)
               {
                  if(_loc12_[_loc4_] != true)
                  {
                     _loc5_ = m0.points[_loc4_];
                     if(_loc5_.id._key == _loc9_)
                     {
                        _loc12_[_loc4_] = true;
                        _loc2_.normalImpulse = _loc5_.normalImpulse;
                        _loc2_.tangentImpulse = _loc5_.tangentImpulse;
                        _loc10_ = true;
                        if(param1 != null)
                        {
                           _loc6_.position = _loc7_.GetWorldPoint(_loc2_.localPoint1);
                           _loc11_ = _loc7_.GetLinearVelocityFromLocalPoint(_loc2_.localPoint1);
                           _loc13_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc2_.localPoint2);
                           _loc6_.velocity.Set(_loc13_.x - _loc11_.x,_loc13_.y - _loc11_.y);
                           _loc6_.normal.SetV(m_manifold.normal);
                           _loc6_.separation = _loc2_.separation;
                           _loc6_.id.key = _loc9_;
                           param1.Persist(_loc6_);
                        }
                        break;
                     }
                  }
                  _loc4_++;
               }
               if(_loc10_ == false && param1 != null)
               {
                  _loc6_.position = _loc7_.GetWorldPoint(_loc2_.localPoint1);
                  _loc11_ = _loc7_.GetLinearVelocityFromLocalPoint(_loc2_.localPoint1);
                  _loc13_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc2_.localPoint2);
                  _loc6_.velocity.Set(_loc13_.x - _loc11_.x,_loc13_.y - _loc11_.y);
                  _loc6_.normal.SetV(m_manifold.normal);
                  _loc6_.separation = _loc2_.separation;
                  _loc6_.id.key = _loc9_;
                  param1.Add(_loc6_);
               }
               _loc3_++;
            }
            m_manifoldCount = 1;
         }
         else
         {
            m_manifoldCount = 0;
         }
         if(param1 == null)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < m0.pointCount)
         {
            if(!_loc12_[_loc3_])
            {
               _loc5_ = m0.points[_loc3_];
               _loc6_.position = _loc7_.GetWorldPoint(_loc5_.localPoint1);
               _loc11_ = _loc7_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint1);
               _loc13_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint2);
               _loc6_.velocity.Set(_loc13_.x - _loc11_.x,_loc13_.y - _loc11_.y);
               _loc6_.normal.SetV(m0.normal);
               _loc6_.separation = _loc5_.separation;
               _loc6_.id.key = _loc5_.id._key;
               param1.Remove(_loc6_);
            }
            _loc3_++;
         }
      }
      
      override public function GetManifolds() : Array
      {
         return m_manifolds;
      }
   }
}

