package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2Jacobian
   {
      public var linear1:b2Vec2 = new b2Vec2();
      
      public var angular1:Number;
      
      public var linear2:b2Vec2 = new b2Vec2();
      
      public var angular2:Number;
      
      public function b2Jacobian()
      {
         super();
      }
      
      public function SetZero() : void
      {
         linear1.SetZero();
         angular1 = 0;
         linear2.SetZero();
         angular2 = 0;
      }
      
      public function Set(param1:b2Vec2, param2:Number, param3:b2Vec2, param4:Number) : void
      {
         linear1.SetV(param1);
         angular1 = param2;
         linear2.SetV(param3);
         angular2 = param4;
      }
      
      public function Compute(param1:b2Vec2, param2:Number, param3:b2Vec2, param4:Number) : Number
      {
         return linear1.x * param1.x + linear1.y * param1.y + angular1 * param2 + (linear2.x * param3.x + linear2.y * param3.y) + angular2 * param4;
      }
   }
}

