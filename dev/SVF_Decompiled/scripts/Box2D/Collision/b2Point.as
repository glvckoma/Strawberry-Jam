package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   
   public class b2Point
   {
      public var p:b2Vec2 = new b2Vec2();
      
      public function b2Point()
      {
         super();
      }
      
      public function Support(param1:b2XForm, param2:Number, param3:Number) : b2Vec2
      {
         return p;
      }
      
      public function GetFirstVertex(param1:b2XForm) : b2Vec2
      {
         return p;
      }
   }
}

