package Box2D.Collision.Shapes
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2MassData
   {
      public var mass:Number = 0;
      
      public var center:b2Vec2 = new b2Vec2(0,0);
      
      public var I:Number = 0;
      
      public function b2MassData()
      {
         super();
      }
   }
}

