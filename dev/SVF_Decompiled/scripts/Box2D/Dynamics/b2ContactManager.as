package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   
   public class b2ContactManager extends b2PairCallback
   {
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      public var m_world:b2World;
      
      public var m_nullContact:b2NullContact = new b2NullContact();
      
      public var m_destroyImmediate:Boolean;
      
      public function b2ContactManager()
      {
         super();
         m_world = null;
         m_destroyImmediate = false;
      }
      
      override public function PairAdded(param1:*, param2:*) : *
      {
         var _loc4_:b2Shape = param1 as b2Shape;
         var _loc5_:b2Shape = param2 as b2Shape;
         var _loc6_:b2Body = _loc4_.m_body;
         var _loc7_:b2Body = _loc5_.m_body;
         if(_loc6_.IsStatic() && _loc7_.IsStatic())
         {
            return m_nullContact;
         }
         if(_loc4_.m_body == _loc5_.m_body)
         {
            return m_nullContact;
         }
         if(_loc7_.IsConnected(_loc6_))
         {
            return m_nullContact;
         }
         if(m_world.m_contactFilter != null && m_world.m_contactFilter.ShouldCollide(_loc4_,_loc5_) == false)
         {
            return m_nullContact;
         }
         var _loc3_:b2Contact = b2Contact.Create(_loc4_,_loc5_,m_world.m_blockAllocator);
         if(_loc3_ == null)
         {
            return m_nullContact;
         }
         _loc4_ = _loc3_.m_shape1;
         _loc5_ = _loc3_.m_shape2;
         _loc6_ = _loc4_.m_body;
         _loc7_ = _loc5_.m_body;
         _loc3_.m_prev = null;
         _loc3_.m_next = m_world.m_contactList;
         if(m_world.m_contactList != null)
         {
            m_world.m_contactList.m_prev = _loc3_;
         }
         m_world.m_contactList = _loc3_;
         _loc3_.m_node1.contact = _loc3_;
         _loc3_.m_node1.other = _loc7_;
         _loc3_.m_node1.prev = null;
         _loc3_.m_node1.next = _loc6_.m_contactList;
         if(_loc6_.m_contactList != null)
         {
            _loc6_.m_contactList.prev = _loc3_.m_node1;
         }
         _loc6_.m_contactList = _loc3_.m_node1;
         _loc3_.m_node2.contact = _loc3_;
         _loc3_.m_node2.other = _loc6_;
         _loc3_.m_node2.prev = null;
         _loc3_.m_node2.next = _loc7_.m_contactList;
         if(_loc7_.m_contactList != null)
         {
            _loc7_.m_contactList.prev = _loc3_.m_node2;
         }
         _loc7_.m_contactList = _loc3_.m_node2;
         ++m_world.m_contactCount;
         return _loc3_;
      }
      
      override public function PairRemoved(param1:*, param2:*, param3:*) : void
      {
         if(param3 == null)
         {
            return;
         }
         var _loc4_:b2Contact = param3 as b2Contact;
         if(_loc4_ == m_nullContact)
         {
            return;
         }
         Destroy(_loc4_);
      }
      
      public function Destroy(param1:b2Contact) : void
      {
         var _loc8_:b2Body = null;
         var _loc9_:b2Body = null;
         var _loc2_:Array = null;
         var _loc7_:b2ContactPoint = null;
         var _loc5_:int = 0;
         var _loc14_:b2Manifold = null;
         var _loc6_:int = 0;
         var _loc3_:b2ManifoldPoint = null;
         var _loc15_:b2Vec2 = null;
         var _loc16_:b2Vec2 = null;
         var _loc11_:b2Shape = param1.m_shape1;
         var _loc12_:b2Shape = param1.m_shape2;
         var _loc10_:int = param1.m_manifoldCount;
         if(_loc10_ > 0 && m_world.m_contactListener)
         {
            _loc8_ = _loc11_.m_body;
            _loc9_ = _loc12_.m_body;
            _loc2_ = param1.GetManifolds();
            _loc7_ = s_evalCP;
            _loc7_.shape1 = param1.m_shape1;
            _loc7_.shape2 = param1.m_shape2;
            _loc7_.friction = param1.m_friction;
            _loc7_.restitution = param1.m_restitution;
            _loc5_ = 0;
            while(_loc5_ < _loc10_)
            {
               _loc14_ = _loc2_[_loc5_];
               _loc7_.normal.SetV(_loc14_.normal);
               _loc6_ = 0;
               while(_loc6_ < _loc14_.pointCount)
               {
                  _loc3_ = _loc14_.points[_loc6_];
                  _loc7_.position = _loc8_.GetWorldPoint(_loc3_.localPoint1);
                  _loc15_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc16_ = _loc9_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc7_.velocity.Set(_loc16_.x - _loc15_.x,_loc16_.y - _loc15_.y);
                  _loc7_.separation = _loc3_.separation;
                  _loc7_.id.key = _loc3_.id._key;
                  m_world.m_contactListener.Remove(_loc7_);
                  _loc6_++;
               }
               _loc5_++;
            }
         }
         if(param1.m_prev)
         {
            param1.m_prev.m_next = param1.m_next;
         }
         if(param1.m_next)
         {
            param1.m_next.m_prev = param1.m_prev;
         }
         if(param1 == m_world.m_contactList)
         {
            m_world.m_contactList = param1.m_next;
         }
         var _loc13_:b2Body = _loc11_.m_body;
         var _loc4_:b2Body = _loc12_.m_body;
         if(param1.m_node1.prev)
         {
            param1.m_node1.prev.next = param1.m_node1.next;
         }
         if(param1.m_node1.next)
         {
            param1.m_node1.next.prev = param1.m_node1.prev;
         }
         if(param1.m_node1 == _loc13_.m_contactList)
         {
            _loc13_.m_contactList = param1.m_node1.next;
         }
         if(param1.m_node2.prev)
         {
            param1.m_node2.prev.next = param1.m_node2.next;
         }
         if(param1.m_node2.next)
         {
            param1.m_node2.next.prev = param1.m_node2.prev;
         }
         if(param1.m_node2 == _loc4_.m_contactList)
         {
            _loc4_.m_contactList = param1.m_node2.next;
         }
         b2Contact.Destroy(param1,m_world.m_blockAllocator);
         --m_world.m_contactCount;
      }
      
      public function Collide() : void
      {
         var _loc1_:b2Contact = null;
         var _loc2_:b2Body = null;
         var _loc3_:b2Body = null;
         _loc1_ = m_world.m_contactList;
         while(_loc1_)
         {
            _loc2_ = _loc1_.m_shape1.m_body;
            _loc3_ = _loc1_.m_shape2.m_body;
            if(!(_loc2_.IsSleeping() && _loc3_.IsSleeping()))
            {
               _loc1_.Update(m_world.m_contactListener);
            }
            _loc1_ = _loc1_.m_next;
         }
      }
   }
}

