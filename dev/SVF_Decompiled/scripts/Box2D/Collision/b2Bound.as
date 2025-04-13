package Box2D.Collision
{
   public class b2Bound
   {
      public var value:uint;
      
      public var proxyId:uint;
      
      public var stabbingCount:uint;
      
      public function b2Bound()
      {
         super();
      }
      
      public function IsLower() : Boolean
      {
         return (value & 1) == 0;
      }
      
      public function IsUpper() : Boolean
      {
         return (value & 1) == 1;
      }
      
      public function Swap(param1:b2Bound) : void
      {
         var _loc4_:uint = value;
         var _loc3_:uint = proxyId;
         var _loc2_:uint = stabbingCount;
         value = param1.value;
         proxyId = param1.proxyId;
         stabbingCount = param1.stabbingCount;
         param1.value = _loc4_;
         param1.proxyId = _loc3_;
         param1.stabbingCount = _loc2_;
      }
   }
}

