package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class PKCS5 implements IPad
   {
      
      private var blockSize:uint;
      
      public function PKCS5(param1:uint = 0)
      {
         super();
         this.blockSize = param1;
      }
      
      public function pad(param1:ByteArray) : void
      {
         var _loc3_:* = 0;
         var _loc2_:uint = blockSize - param1.length % blockSize;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            param1[param1.length] = _loc2_;
            _loc3_++;
         }
      }
      
      public function unpad(param1:ByteArray) : void
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         var _loc2_:uint = param1.length % blockSize;
         if(_loc2_ != 0)
         {
            throw new Error("PKCS#5::unpad: ByteArray.length isn\'t a multiple of the blockSize");
         }
         _loc2_ = uint(param1[param1.length - 1]);
         _loc4_ = _loc2_;
         while(_loc4_ > 0)
         {
            _loc3_ = uint(param1[param1.length - 1]);
            param1.length--;
            if(_loc2_ != _loc3_)
            {
               throw new Error("PKCS#5:unpad: Invalid padding value. expected [" + _loc2_ + "], found [" + _loc3_ + "]");
            }
            _loc4_--;
         }
      }
      
      public function setBlockSize(param1:uint) : void
      {
         blockSize = param1;
      }
   }
}

