package Box2D.Common.Math
{
   public class b2Math
   {
      public static const b2Vec2_zero:b2Vec2 = new b2Vec2(0,0);
      
      public static const b2Mat22_identity:b2Mat22 = new b2Mat22(0,new b2Vec2(1,0),new b2Vec2(0,1));
      
      public static const b2XForm_identity:b2XForm = new b2XForm(b2Vec2_zero,b2Mat22_identity);
      
      public function b2Math()
      {
         super();
      }
      
      public static function b2IsValid(param1:Number) : Boolean
      {
         return isFinite(param1);
      }
      
      public static function b2Dot(param1:b2Vec2, param2:b2Vec2) : Number
      {
         return param1.x * param2.x + param1.y * param2.y;
      }
      
      public static function b2CrossVV(param1:b2Vec2, param2:b2Vec2) : Number
      {
         return param1.x * param2.y - param1.y * param2.x;
      }
      
      public static function b2CrossVF(param1:b2Vec2, param2:Number) : b2Vec2
      {
         return new b2Vec2(param2 * param1.y,-param2 * param1.x);
      }
      
      public static function b2CrossFV(param1:Number, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(-param1 * param2.y,param1 * param2.x);
      }
      
      public static function b2MulMV(param1:b2Mat22, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(param1.col1.x * param2.x + param1.col2.x * param2.y,param1.col1.y * param2.x + param1.col2.y * param2.y);
      }
      
      public static function b2MulTMV(param1:b2Mat22, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Dot(param2,param1.col1),b2Dot(param2,param1.col2));
      }
      
      public static function b2MulX(param1:b2XForm, param2:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = b2MulMV(param1.R,param2);
         _loc3_.x += param1.position.x;
         _loc3_.y += param1.position.y;
         return _loc3_;
      }
      
      public static function b2MulXT(param1:b2XForm, param2:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = SubtractVV(param2,param1.position);
         var _loc4_:Number = _loc3_.x * param1.R.col1.x + _loc3_.y * param1.R.col1.y;
         _loc3_.y = _loc3_.x * param1.R.col2.x + _loc3_.y * param1.R.col2.y;
         _loc3_.x = _loc4_;
         return _loc3_;
      }
      
      public static function AddVV(param1:b2Vec2, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(param1.x + param2.x,param1.y + param2.y);
      }
      
      public static function SubtractVV(param1:b2Vec2, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(param1.x - param2.x,param1.y - param2.y);
      }
      
      public static function b2Distance(param1:b2Vec2, param2:b2Vec2) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public static function b2DistanceSquared(param1:b2Vec2, param2:b2Vec2) : Number
      {
         var _loc3_:Number = param1.x - param2.x;
         var _loc4_:Number = param1.y - param2.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      public static function MulFV(param1:Number, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(param1 * param2.x,param1 * param2.y);
      }
      
      public static function AddMM(param1:b2Mat22, param2:b2Mat22) : b2Mat22
      {
         return new b2Mat22(0,AddVV(param1.col1,param2.col1),AddVV(param1.col2,param2.col2));
      }
      
      public static function b2MulMM(param1:b2Mat22, param2:b2Mat22) : b2Mat22
      {
         return new b2Mat22(0,b2MulMV(param1,param2.col1),b2MulMV(param1,param2.col2));
      }
      
      public static function b2MulTMM(param1:b2Mat22, param2:b2Mat22) : b2Mat22
      {
         var _loc4_:b2Vec2 = new b2Vec2(b2Dot(param1.col1,param2.col1),b2Dot(param1.col2,param2.col1));
         var _loc5_:b2Vec2 = new b2Vec2(b2Dot(param1.col1,param2.col2),b2Dot(param1.col2,param2.col2));
         return new b2Mat22(0,_loc4_,_loc5_);
      }
      
      public static function b2Abs(param1:Number) : Number
      {
         return param1 > 0 ? param1 : -param1;
      }
      
      public static function b2AbsV(param1:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Abs(param1.x),b2Abs(param1.y));
      }
      
      public static function b2AbsM(param1:b2Mat22) : b2Mat22
      {
         return new b2Mat22(0,b2AbsV(param1.col1),b2AbsV(param1.col2));
      }
      
      public static function b2Min(param1:Number, param2:Number) : Number
      {
         return param1 < param2 ? param1 : param2;
      }
      
      public static function b2MinV(param1:b2Vec2, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Min(param1.x,param2.x),b2Min(param1.y,param2.y));
      }
      
      public static function b2Max(param1:Number, param2:Number) : Number
      {
         return param1 > param2 ? param1 : param2;
      }
      
      public static function b2MaxV(param1:b2Vec2, param2:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Max(param1.x,param2.x),b2Max(param1.y,param2.y));
      }
      
      public static function b2Clamp(param1:Number, param2:Number, param3:Number) : Number
      {
         return b2Max(param2,b2Min(param1,param3));
      }
      
      public static function b2ClampV(param1:b2Vec2, param2:b2Vec2, param3:b2Vec2) : b2Vec2
      {
         return b2MaxV(param2,b2MinV(param1,param3));
      }
      
      public static function b2Swap(param1:Array, param2:Array) : void
      {
         var _loc3_:* = param1[0];
         param1[0] = param2[0];
         param2[0] = _loc3_;
      }
      
      public static function b2Random() : Number
      {
         return Math.random() * 2 - 1;
      }
      
      public static function b2RandomRange(param1:Number, param2:Number) : Number
      {
         var _loc3_:Number = Math.random();
         return (param2 - param1) * _loc3_ + param1;
      }
      
      public static function b2NextPowerOfTwo(param1:uint) : uint
      {
         param1 |= param1 >> 1 & 0x7FFFFFFF;
         param1 |= param1 >> 2 & 0x3FFFFFFF;
         param1 |= param1 >> 4 & 0x0FFFFFFF;
         param1 |= param1 >> 8 & 0xFFFFFF;
         param1 |= param1 >> 16 & 0xFFFF;
         return param1 + 1;
      }
      
      public static function b2IsPowerOfTwo(param1:uint) : Boolean
      {
         return param1 > 0 && (param1 & param1 - 1) == 0;
      }
   }
}

