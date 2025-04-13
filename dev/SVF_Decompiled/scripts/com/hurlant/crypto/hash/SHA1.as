package com.hurlant.crypto.hash
{
   public class SHA1 extends SHABase implements IHash
   {
      public static const HASH_SIZE:int = 20;
      
      public function SHA1()
      {
         super();
      }
      
      override public function getHashSize() : uint
      {
         return 20;
      }
      
      override protected function core(param1:Array, param2:uint) : Array
      {
         var _loc9_:* = 0;
         var _loc13_:* = 0;
         var _loc14_:* = 0;
         var _loc8_:* = 0;
         var _loc10_:* = 0;
         var _loc11_:* = 0;
         var _loc12_:* = 0;
         var _loc15_:* = 0;
         param1[param2 >> 5] |= 128 << 24 - param2 % 32;
         param1[(param2 + 64 >> 9 << 4) + 15] = param2;
         var _loc16_:Array = [];
         var _loc3_:* = 1732584193;
         var _loc4_:* = 4023233417;
         var _loc5_:* = 2562383102;
         var _loc6_:* = 271733878;
         var _loc7_:* = 3285377520;
         _loc9_ = 0;
         while(_loc9_ < param1.length)
         {
            _loc13_ = _loc3_;
            _loc14_ = _loc4_;
            _loc8_ = _loc5_;
            _loc10_ = _loc6_;
            _loc11_ = _loc7_;
            _loc12_ = 0;
            while(_loc12_ < 80)
            {
               if(_loc12_ < 16)
               {
                  _loc16_[_loc12_] = param1[_loc9_ + _loc12_] || 0;
               }
               else
               {
                  _loc16_[_loc12_] = rol(_loc16_[_loc12_ - 3] ^ _loc16_[_loc12_ - 8] ^ _loc16_[_loc12_ - 14] ^ _loc16_[_loc12_ - 16],1);
               }
               _loc15_ = rol(_loc3_,5) + ft(_loc12_,_loc4_,_loc5_,_loc6_) + _loc7_ + _loc16_[_loc12_] + kt(_loc12_);
               _loc7_ = _loc6_;
               _loc6_ = _loc5_;
               _loc5_ = rol(_loc4_,30);
               _loc4_ = _loc3_;
               _loc3_ = _loc15_;
               _loc12_++;
            }
            _loc3_ += _loc13_;
            _loc4_ += _loc14_;
            _loc5_ += _loc8_;
            _loc6_ += _loc10_;
            _loc7_ += _loc11_;
            _loc9_ += 16;
         }
         return [_loc3_,_loc4_,_loc5_,_loc6_,_loc7_];
      }
      
      private function rol(param1:uint, param2:uint) : uint
      {
         return param1 << param2 | param1 >>> 32 - param2;
      }
      
      private function ft(param1:uint, param2:uint, param3:uint, param4:uint) : uint
      {
         if(param1 < 20)
         {
            return param2 & param3 | ~param2 & param4;
         }
         if(param1 < 40)
         {
            return param2 ^ param3 ^ param4;
         }
         if(param1 < 60)
         {
            return param2 & param3 | param2 & param4 | param3 & param4;
         }
         return param2 ^ param3 ^ param4;
      }
      
      private function kt(param1:uint) : uint
      {
         return param1 < 20 ? 1518500249 : (param1 < 40 ? 1859775393 : (param1 < 60 ? 2400959708 : 3395469782));
      }
      
      override public function toString() : String
      {
         return "sha1";
      }
   }
}

