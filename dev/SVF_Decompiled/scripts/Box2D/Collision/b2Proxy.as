package Box2D.Collision
{
   public class b2Proxy
   {
      public var lowerBounds:Array = [0,0];
      
      public var upperBounds:Array = [0,0];
      
      public var overlapCount:uint;
      
      public var timeStamp:uint;
      
      public var userData:* = null;
      
      public function b2Proxy()
      {
         super();
      }
      
      public function GetNext() : uint
      {
         return lowerBounds[0];
      }
      
      public function SetNext(param1:uint) : void
      {
         lowerBounds[0] = param1 & 0xFFFF;
      }
      
      public function IsValid() : Boolean
      {
         return overlapCount != 65535;
      }
   }
}

