package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFB8Mode extends IVMode implements IMode
   {
      public function CFB8Mode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,null);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         var _loc4_:ByteArray = getIV4e();
         var _loc2_:ByteArray = new ByteArray();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_.position = 0;
            _loc2_.writeBytes(_loc4_);
            key.encrypt(_loc4_);
            param1[_loc3_] ^= _loc4_[0];
            _loc5_ = 0;
            while(_loc5_ < blockSize - 1)
            {
               _loc4_[_loc5_] = _loc2_[_loc5_ + 1];
               _loc5_++;
            }
            _loc4_[blockSize - 1] = param1[_loc3_];
            _loc3_++;
         }
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc4_:* = 0;
         var _loc2_:* = 0;
         var _loc6_:* = 0;
         var _loc5_:ByteArray = getIV4d();
         var _loc3_:ByteArray = new ByteArray();
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = uint(param1[_loc4_]);
            _loc3_.position = 0;
            _loc3_.writeBytes(_loc5_);
            key.encrypt(_loc5_);
            param1[_loc4_] ^= _loc5_[0];
            _loc6_ = 0;
            while(_loc6_ < blockSize - 1)
            {
               _loc5_[_loc6_] = _loc3_[_loc6_ + 1];
               _loc6_++;
            }
            _loc5_[blockSize - 1] = _loc2_;
            _loc4_++;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb8";
      }
   }
}

