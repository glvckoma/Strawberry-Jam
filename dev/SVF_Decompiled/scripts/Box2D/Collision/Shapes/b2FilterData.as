package Box2D.Collision.Shapes
{
   public class b2FilterData
   {
      public var categoryBits:uint = 1;
      
      public var maskBits:uint = 65535;
      
      public var groupIndex:int = 0;
      
      public function b2FilterData()
      {
         super();
      }
      
      public function Copy() : b2FilterData
      {
         var _loc1_:b2FilterData = new b2FilterData();
         _loc1_.categoryBits = categoryBits;
         _loc1_.maskBits = maskBits;
         _loc1_.groupIndex = groupIndex;
         return _loc1_;
      }
   }
}

