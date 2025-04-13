package com.sbi.bit
{
   public class BitUtility
   {
      public function BitUtility()
      {
         super();
      }
      
      public static function isBitSetForNumber(param1:int, param2:Number) : Boolean
      {
         if(param2 == -1)
         {
            return false;
         }
         if((param2 >> param1 & 1) == 1)
         {
            return true;
         }
         return false;
      }
      
      public static function leftShiftNumbers(param1:int) : Number
      {
         var _loc3_:Boolean = false;
         if(param1 == 31)
         {
            param1--;
            _loc3_ = true;
         }
         var _loc2_:Number = 1 << param1;
         if(_loc3_)
         {
            _loc2_ *= 2;
         }
         if(param1 > 31)
         {
            _loc2_ = Number("0x" + _loc2_.toString(16) + "00000000");
         }
         return _loc2_;
      }
      
      public static function rightShiftNumber(param1:Number) : Number
      {
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(param1 > 4294967295)
         {
            _loc4_ = param1 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param1.toString(2);
            _loc2_ = _loc4_.substr(0,_loc4_.length - 32);
            _loc3_ = _loc4_.substr(_loc4_.length - 32);
            _loc3_ = _loc2_.charAt(_loc2_.length - 1) + _loc3_.substr(0,_loc3_.length - 1);
            _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
            if(_loc2_ == "")
            {
               _loc2_ = "0";
            }
            return Number("0x" + _loc2_ + "00000000") + parseInt(_loc3_,2);
         }
         return param1 >>> 1;
      }
      
      public static function bitwiseAnd(param1:Number, param2:Number) : Number
      {
         var _loc6_:String = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:Number = NaN;
         if(param1 < 1073741824 && param2 < 1073741824)
         {
            return param1 & param2;
         }
         _loc6_ = param1 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param1.toString(2);
         _loc4_ = _loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0;
         _loc5_ = parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2);
         _loc6_ = param2 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param2.toString(2);
         _loc3_ = _loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0;
         _loc8_ = parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2);
         _loc7_ = uint(_loc5_ & _loc8_);
         _loc9_ = Number("0x" + (_loc4_ & _loc3_).toString(16) + "00000000");
         return _loc7_ + _loc9_;
      }
      
      public static function bitwiseOr(param1:Number, param2:Number) : Number
      {
         var _loc6_:String = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:* = 0;
         var _loc8_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:Number = NaN;
         if(param1 < 1073741824 && param2 < 1073741824)
         {
            return param1 | param2;
         }
         _loc6_ = param1 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param1.toString(2);
         _loc4_ = _loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0;
         _loc5_ = parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2);
         _loc6_ = param2 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param2.toString(2);
         _loc3_ = _loc6_.length > 32 ? parseInt(_loc6_.substr(0,_loc6_.length - 32),2) : 0;
         _loc8_ = parseInt(_loc6_.substr(_loc6_.length > 32 ? _loc6_.length - 32 : 0),2);
         _loc7_ = uint(_loc5_ | _loc8_);
         _loc9_ = Number("0x" + (_loc4_ | _loc3_).toString(16) + "00000000");
         return _loc7_ + _loc9_;
      }
      
      public static function bitwiseNot(param1:Number) : Number
      {
         var _loc2_:uint = (param1 == -1 ? "1111111111111111111111111111111111111111111111111111111111111111" : param1.toString(2)).length > 32 ? parseInt("1111111111111111111111111111111111111111111111111111111111111111".substr(0,"1111111111111111111111111111111111111111111111111111111111111111".length - 32),2) : 0;
         var _loc4_:uint = parseInt("1111111111111111111111111111111111111111111111111111111111111111".substr("1111111111111111111111111111111111111111111111111111111111111111".length > 32 ? "1111111111111111111111111111111111111111111111111111111111111111".length - 32 : 0),2);
         _loc2_ = uint(~_loc2_);
         _loc4_ = uint(~_loc4_);
         var _loc6_:String = _loc2_.toString(2).substr(11);
         var _loc3_:String = _loc4_.toString(2);
         return parseInt(_loc6_ + _loc3_,2);
      }
      
      public static function numberOfBitsSet(param1:Number) : int
      {
         var _loc3_:int = 0;
         if(param1 == 0 || param1 <= 0)
         {
            return 0;
         }
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < 64)
         {
            if(bitwiseAnd(param1,leftShiftNumbers(_loc3_)) != 0)
            {
               _loc2_++;
            }
            _loc3_++;
         }
         return _loc2_;
      }
   }
}

