package Box2D.Common.Math
{
   public class b2Vec2
   {
      public var x:Number;
      
      public var y:Number;
      
      public function b2Vec2(param1:Number = 0, param2:Number = 0)
      {
         super();
         x = param1;
         y = param2;
      }
      
      public static function Make(param1:Number, param2:Number) : b2Vec2
      {
         return new b2Vec2(param1,param2);
      }
      
      public function SetZero() : void
      {
         x = 0;
         y = 0;
      }
      
      public function Set(param1:Number = 0, param2:Number = 0) : void
      {
         x = param1;
         y = param2;
      }
      
      public function SetV(param1:b2Vec2) : void
      {
         x = param1.x;
         y = param1.y;
      }
      
      public function Negative() : b2Vec2
      {
         return new b2Vec2(-x,-y);
      }
      
      public function Copy() : b2Vec2
      {
         return new b2Vec2(x,y);
      }
      
      public function Add(param1:b2Vec2) : void
      {
         x += param1.x;
         y += param1.y;
      }
      
      public function Subtract(param1:b2Vec2) : void
      {
         x -= param1.x;
         y -= param1.y;
      }
      
      public function Multiply(param1:Number) : void
      {
         x *= param1;
         y *= param1;
      }
      
      public function MulM(param1:b2Mat22) : void
      {
         var _loc2_:Number = x;
         x = param1.col1.x * _loc2_ + param1.col2.x * y;
         y = param1.col1.y * _loc2_ + param1.col2.y * y;
      }
      
      public function MulTM(param1:b2Mat22) : void
      {
         var _loc2_:Number = b2Math.b2Dot(this,param1.col1);
         y = b2Math.b2Dot(this,param1.col2);
         x = _loc2_;
      }
      
      public function CrossVF(param1:Number) : void
      {
         var _loc2_:Number = x;
         x = param1 * y;
         y = -param1 * _loc2_;
      }
      
      public function CrossFV(param1:Number) : void
      {
         var _loc2_:Number = x;
         x = -param1 * y;
         y = param1 * _loc2_;
      }
      
      public function MinV(param1:b2Vec2) : void
      {
         x = x < param1.x ? x : param1.x;
         y = y < param1.y ? y : param1.y;
      }
      
      public function MaxV(param1:b2Vec2) : void
      {
         x = x > param1.x ? x : param1.x;
         y = y > param1.y ? y : param1.y;
      }
      
      public function Abs() : void
      {
         if(x < 0)
         {
            x = -x;
         }
         if(y < 0)
         {
            y = -y;
         }
      }
      
      public function Length() : Number
      {
         return Math.sqrt(x * x + y * y);
      }
      
      public function LengthSquared() : Number
      {
         return x * x + y * y;
      }
      
      public function Normalize() : Number
      {
         var _loc2_:Number = Math.sqrt(x * x + y * y);
         if(_loc2_ < Number.MIN_VALUE)
         {
            return 0;
         }
         var _loc1_:Number = 1 / _loc2_;
         x *= _loc1_;
         y *= _loc1_;
         return _loc2_;
      }
      
      public function IsValid() : Boolean
      {
         return b2Math.b2IsValid(x) && b2Math.b2IsValid(y);
      }
   }
}

