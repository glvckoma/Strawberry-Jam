package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2ManifoldPoint
   {
      public var localPoint1:b2Vec2 = new b2Vec2();
      
      public var localPoint2:b2Vec2 = new b2Vec2();
      
      public var separation:Number;
      
      public var normalImpulse:Number;
      
      public var tangentImpulse:Number;
      
      public var id:b2ContactID = new b2ContactID();
      
      public function b2ManifoldPoint()
      {
         super();
      }
      
      public function Reset() : void
      {
         localPoint1.SetZero();
         localPoint2.SetZero();
         separation = 0;
         normalImpulse = 0;
         tangentImpulse = 0;
         id.key = 0;
      }
      
      public function Set(param1:b2ManifoldPoint) : void
      {
         localPoint1.SetV(param1.localPoint1);
         localPoint2.SetV(param1.localPoint2);
         separation = param1.separation;
         normalImpulse = param1.normalImpulse;
         tangentImpulse = param1.tangentImpulse;
         id.key = param1.id.key;
      }
   }
}

