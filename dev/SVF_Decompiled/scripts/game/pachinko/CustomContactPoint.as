package game.pachinko
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   
   public class CustomContactPoint
   {
      public var shape1:b2Shape;
      
      public var shape2:b2Shape;
      
      public var separation:Number;
      
      public var position:b2Vec2;
      
      public function CustomContactPoint(param1:b2Shape, param2:b2Shape, param3:Number, param4:b2Vec2)
      {
         super();
         shape1 = param1;
         shape2 = param2;
         separation = param3;
         position = param4;
      }
   }
}

