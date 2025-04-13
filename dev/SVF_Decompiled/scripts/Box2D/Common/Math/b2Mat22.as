package Box2D.Common.Math
{
   public class b2Mat22
   {
      public var col1:b2Vec2;
      
      public var col2:b2Vec2;
      
      public function b2Mat22(param1:Number = 0, param2:b2Vec2 = null, param3:b2Vec2 = null)
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         col1 = new b2Vec2();
         col2 = new b2Vec2();
         super();
         if(param2 != null && param3 != null)
         {
            col1.SetV(param2);
            col2.SetV(param3);
         }
         else
         {
            _loc4_ = Math.cos(param1);
            _loc5_ = Math.sin(param1);
            col1.x = _loc4_;
            col2.x = -_loc5_;
            col1.y = _loc5_;
            col2.y = _loc4_;
         }
      }
      
      public function Set(param1:Number) : void
      {
         var _loc2_:Number = Math.cos(param1);
         var _loc3_:Number = Math.sin(param1);
         col1.x = _loc2_;
         col2.x = -_loc3_;
         col1.y = _loc3_;
         col2.y = _loc2_;
      }
      
      public function SetVV(param1:b2Vec2, param2:b2Vec2) : void
      {
         col1.SetV(param1);
         col2.SetV(param2);
      }
      
      public function Copy() : b2Mat22
      {
         return new b2Mat22(0,col1,col2);
      }
      
      public function SetM(param1:b2Mat22) : void
      {
         col1.SetV(param1.col1);
         col2.SetV(param1.col2);
      }
      
      public function AddM(param1:b2Mat22) : void
      {
         col1.x += param1.col1.x;
         col1.y += param1.col1.y;
         col2.x += param1.col2.x;
         col2.y += param1.col2.y;
      }
      
      public function SetIdentity() : void
      {
         col1.x = 1;
         col2.x = 0;
         col1.y = 0;
         col2.y = 1;
      }
      
      public function SetZero() : void
      {
         col1.x = 0;
         col2.x = 0;
         col1.y = 0;
         col2.y = 0;
      }
      
      public function GetAngle() : Number
      {
         return Math.atan2(col1.y,col1.x);
      }
      
      public function Invert(param1:b2Mat22) : b2Mat22
      {
         var _loc2_:Number = col1.x;
         var _loc3_:Number = col2.x;
         var _loc5_:Number = col1.y;
         var _loc6_:Number = col2.y;
         var _loc4_:Number = _loc2_ * _loc6_ - _loc3_ * _loc5_;
         _loc4_ = 1 / _loc4_;
         param1.col1.x = _loc4_ * _loc6_;
         param1.col2.x = -_loc4_ * _loc3_;
         param1.col1.y = -_loc4_ * _loc5_;
         param1.col2.y = _loc4_ * _loc2_;
         return param1;
      }
      
      public function Solve(param1:b2Vec2, param2:Number, param3:Number) : b2Vec2
      {
         var _loc4_:Number = col1.x;
         var _loc8_:Number = col2.x;
         var _loc6_:Number = col1.y;
         var _loc5_:Number = col2.y;
         var _loc7_:Number = _loc4_ * _loc5_ - _loc8_ * _loc6_;
         _loc7_ = 1 / _loc7_;
         param1.x = _loc7_ * (_loc5_ * param2 - _loc8_ * param3);
         param1.y = _loc7_ * (_loc4_ * param3 - _loc6_ * param2);
         return param1;
      }
      
      public function Abs() : void
      {
         col1.Abs();
         col2.Abs();
      }
   }
}

