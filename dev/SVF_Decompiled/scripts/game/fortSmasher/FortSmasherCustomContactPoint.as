package game.fortSmasher
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   
   public class FortSmasherCustomContactPoint
   {
      public var shape1:b2Shape;
      
      public var shape2:b2Shape;
      
      public var separation:Number;
      
      public var position:b2Vec2;
      
      public var velocity:b2Vec2;
      
      public var normal:b2Vec2;
      
      public var force:Number;
      
      public var normalImpulse:Number;
      
      public var tangentImpulse:Number;
      
      public function FortSmasherCustomContactPoint(param1:b2Shape, param2:b2Shape, param3:Number, param4:Number, param5:b2Vec2)
      {
         super();
         shape1 = param1;
         shape2 = param2;
         position = param5;
         normalImpulse = param3;
         tangentImpulse = param4;
      }
   }
}

