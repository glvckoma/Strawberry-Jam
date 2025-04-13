package Box2D.Dynamics
{
   import Box2D.Collision.Shapes.b2FilterData;
   import Box2D.Collision.Shapes.b2Shape;
   
   public class b2ContactFilter
   {
      public static var b2_defaultFilter:b2ContactFilter = new b2ContactFilter();
      
      public function b2ContactFilter()
      {
         super();
      }
      
      public function ShouldCollide(param1:b2Shape, param2:b2Shape) : Boolean
      {
         var _loc3_:b2FilterData = param1.GetFilterData();
         var _loc5_:b2FilterData = param2.GetFilterData();
         if(_loc3_.groupIndex == _loc5_.groupIndex && _loc3_.groupIndex != 0)
         {
            return _loc3_.groupIndex > 0;
         }
         return (_loc3_.maskBits & _loc5_.categoryBits) != 0 && (_loc3_.categoryBits & _loc5_.maskBits) != 0;
      }
   }
}

