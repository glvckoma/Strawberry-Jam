package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   
   public class HMAC
   {
      private var hash:IHash;
      
      private var bits:uint;
      
      public function HMAC(param1:IHash, param2:uint = 0)
      {
         super();
         this.hash = param1;
         this.bits = param2;
      }
      
      public function getHashSize() : uint
      {
         if(bits != 0)
         {
            return bits / 8;
         }
         return hash.getHashSize();
      }
      
      public function compute(param1:ByteArray, param2:ByteArray) : ByteArray
      {
         var _loc3_:ByteArray = null;
         var _loc7_:* = 0;
         if(param1.length > hash.getInputSize())
         {
            _loc3_ = hash.hash(param1);
         }
         else
         {
            _loc3_ = new ByteArray();
            _loc3_.writeBytes(param1);
         }
         while(_loc3_.length < hash.getInputSize())
         {
            _loc3_[_loc3_.length] = 0;
         }
         var _loc8_:ByteArray = new ByteArray();
         var _loc5_:ByteArray = new ByteArray();
         _loc7_ = 0;
         while(_loc7_ < _loc3_.length)
         {
            _loc8_[_loc7_] = _loc3_[_loc7_] ^ 0x36;
            _loc5_[_loc7_] = _loc3_[_loc7_] ^ 0x5C;
            _loc7_++;
         }
         _loc8_.position = _loc3_.length;
         _loc8_.writeBytes(param2);
         var _loc6_:ByteArray = hash.hash(_loc8_);
         _loc5_.position = _loc3_.length;
         _loc5_.writeBytes(_loc6_);
         var _loc4_:ByteArray = hash.hash(_loc5_);
         if(bits > 0 && bits < 8 * _loc4_.length)
         {
            _loc4_.length = bits / 8;
         }
         return _loc4_;
      }
      
      public function dispose() : void
      {
         hash = null;
         bits = 0;
      }
      
      public function toString() : String
      {
         return "hmac-" + (bits > 0 ? bits + "-" : "") + hash.toString();
      }
   }
}

