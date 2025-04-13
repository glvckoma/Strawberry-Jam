package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CBCMode extends IVMode implements IMode
   {
      public function CBCMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,param2);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc4_:* = 0;
         padding.pad(param1);
         var _loc3_:ByteArray = getIV4e();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc4_ = 0;
            while(_loc4_ < blockSize)
            {
               var _loc5_:* = _loc2_ + _loc4_;
               var _loc6_:* = param1[_loc5_] ^ _loc3_[_loc4_];
               param1[_loc5_] = _loc6_;
               _loc4_++;
            }
            key.encrypt(param1,_loc2_);
            _loc3_.position = 0;
            _loc3_.writeBytes(param1,_loc2_,blockSize);
            _loc2_ += blockSize;
         }
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         var _loc4_:ByteArray = getIV4d();
         var _loc2_:ByteArray = new ByteArray();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_.position = 0;
            _loc2_.writeBytes(param1,_loc3_,blockSize);
            key.decrypt(param1,_loc3_);
            _loc5_ = 0;
            while(_loc5_ < blockSize)
            {
               var _loc6_:* = _loc3_ + _loc5_;
               var _loc7_:* = param1[_loc6_] ^ _loc4_[_loc5_];
               param1[_loc6_] = _loc7_;
               _loc5_++;
            }
            _loc4_.position = 0;
            _loc4_.writeBytes(_loc2_,0,blockSize);
            _loc3_ += blockSize;
         }
         padding.unpad(param1);
      }
      
      public function toString() : String
      {
         return key.toString() + "-cbc";
      }
   }
}

