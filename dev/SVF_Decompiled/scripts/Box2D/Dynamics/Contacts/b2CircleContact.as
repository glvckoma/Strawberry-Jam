package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2CircleContact extends b2Contact
   {
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      private var m_manifolds:Array = [new b2Manifold()];
      
      public var m_manifold:b2Manifold;
      
      private var m0:b2Manifold = new b2Manifold();
      
      public function b2CircleContact(param1:b2Shape, param2:b2Shape)
      {
         super(param1,param2);
         m_manifold = m_manifolds[0];
         m_manifold.pointCount = 0;
         var _loc3_:b2ManifoldPoint = m_manifold.points[0];
         _loc3_.normalImpulse = 0;
         _loc3_.tangentImpulse = 0;
      }
      
      public static function Create(param1:b2Shape, param2:b2Shape, param3:*) : b2Contact
      {
         return new b2CircleContact(param1,param2);
      }
      
      public static function Destroy(param1:b2Contact, param2:*) : void
      {
      }
      
      override public function Evaluate(param1:b2ContactListener) : void
      {
         var _loc4_:b2Vec2 = null;
         var _loc5_:b2Vec2 = null;
         var _loc6_:b2ManifoldPoint = null;
         var _loc3_:b2ManifoldPoint = null;
         var _loc8_:b2Body = m_shape1.m_body;
         var _loc2_:b2Body = m_shape2.m_body;
         m0.Set(m_manifold);
         b2Collision.b2CollideCircles(m_manifold,m_shape1 as b2CircleShape,_loc8_.m_xf,m_shape2 as b2CircleShape,_loc2_.m_xf);
         var _loc7_:b2ContactPoint = s_evalCP;
         _loc7_.shape1 = m_shape1;
         _loc7_.shape2 = m_shape2;
         _loc7_.friction = m_friction;
         _loc7_.restitution = m_restitution;
         if(m_manifold.pointCount > 0)
         {
            m_manifoldCount = 1;
            _loc3_ = m_manifold.points[0];
            if(m0.pointCount == 0)
            {
               _loc3_.normalImpulse = 0;
               _loc3_.tangentImpulse = 0;
               if(param1)
               {
                  _loc7_.position = _loc8_.GetWorldPoint(_loc3_.localPoint1);
                  _loc4_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc5_ = _loc2_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc7_.velocity.Set(_loc5_.x - _loc4_.x,_loc5_.y - _loc4_.y);
                  _loc7_.normal.SetV(m_manifold.normal);
                  _loc7_.separation = _loc3_.separation;
                  _loc7_.id.key = _loc3_.id._key;
                  param1.Add(_loc7_);
               }
            }
            else
            {
               _loc6_ = m0.points[0];
               _loc3_.normalImpulse = _loc6_.normalImpulse;
               _loc3_.tangentImpulse = _loc6_.tangentImpulse;
               if(param1)
               {
                  _loc7_.position = _loc8_.GetWorldPoint(_loc3_.localPoint1);
                  _loc4_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc5_ = _loc2_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc7_.velocity.Set(_loc5_.x - _loc4_.x,_loc5_.y - _loc4_.y);
                  _loc7_.normal.SetV(m_manifold.normal);
                  _loc7_.separation = _loc3_.separation;
                  _loc7_.id.key = _loc3_.id._key;
                  param1.Persist(_loc7_);
               }
            }
         }
         else
         {
            m_manifoldCount = 0;
            if(m0.pointCount > 0 && param1)
            {
               _loc6_ = m0.points[0];
               _loc7_.position = _loc8_.GetWorldPoint(_loc6_.localPoint1);
               _loc4_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc6_.localPoint1);
               _loc5_ = _loc2_.GetLinearVelocityFromLocalPoint(_loc6_.localPoint2);
               _loc7_.velocity.Set(_loc5_.x - _loc4_.x,_loc5_.y - _loc4_.y);
               _loc7_.normal.SetV(m0.normal);
               _loc7_.separation = _loc6_.separation;
               _loc7_.id.key = _loc6_.id._key;
               param1.Remove(_loc7_);
            }
         }
      }
      
      override public function GetManifolds() : Array
      {
         return m_manifolds;
      }
   }
}

