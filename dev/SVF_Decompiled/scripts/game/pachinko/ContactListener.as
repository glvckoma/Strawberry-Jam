package game.pachinko
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2ContactPoint;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2ContactListener;
   
   public class ContactListener extends b2ContactListener
   {
      public var contactStack:Array = [];
      
      public function ContactListener()
      {
         super();
      }
      
      override public function Add(param1:b2ContactPoint) : void
      {
         var _loc2_:b2Shape = param1.shape1;
         var _loc3_:b2Shape = param1.shape2;
         var _loc4_:Number = param1.separation;
         var _loc5_:b2Vec2 = param1.position.Copy();
         contactStack.push(new CustomContactPoint(_loc2_,_loc3_,_loc4_,_loc5_));
      }
   }
}

