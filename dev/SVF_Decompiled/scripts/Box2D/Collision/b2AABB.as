package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2AABB
   {
      public var lowerBound:b2Vec2 = new b2Vec2();
      
      public var upperBound:b2Vec2 = new b2Vec2();
      
      public function b2AABB()
      {
         super();
      }
      
      public function IsValid() : Boolean
      {
         var _loc2_:Number = upperBound.x - lowerBound.x;
         var _loc3_:Number = upperBound.y - lowerBound.y;
         var _loc1_:Boolean = _loc2_ >= 0 && _loc3_ >= 0;
         return _loc1_ && lowerBound.IsValid() && upperBound.IsValid();
      }
   }
}

