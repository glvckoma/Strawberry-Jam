package game.pVP_Marbles
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2ContactResult;
   import Box2D.Dynamics.b2ContactListener;
   
   public class PVP_Marbles_ContactListener extends b2ContactListener
   {
      public var contactStack:Array = [];
      
      public function PVP_Marbles_ContactListener()
      {
         super();
      }
      
      override public function Result(param1:b2ContactResult) : void
      {
         var _loc2_:b2Shape = param1.shape1;
         var _loc3_:b2Shape = param1.shape2;
         var _loc4_:Number = param1.normalImpulse;
         var _loc5_:b2Vec2 = param1.position;
         if(_loc4_ > 1)
         {
            contactStack.push(new PVP_Marbles_CustomContactPoint(_loc2_,_loc3_,_loc4_,_loc5_));
         }
      }
   }
}

