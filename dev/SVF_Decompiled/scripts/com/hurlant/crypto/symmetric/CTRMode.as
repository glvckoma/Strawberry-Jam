package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CTRMode extends IVMode implements IMode
   {
      public function CTRMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,param2);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         padding.pad(param1);
         var _loc2_:ByteArray = getIV4e();
         core(param1,_loc2_);
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = getIV4d();
         core(param1,_loc2_);
         padding.unpad(param1);
      }
      
      private function core(param1:ByteArray, param2:ByteArray) : void
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc3_:ByteArray = new ByteArray();
         var _loc6_:ByteArray = new ByteArray();
         _loc3_.writeBytes(param2);
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc6_.position = 0;
            _loc6_.writeBytes(_loc3_);
            key.encrypt(_loc6_);
            _loc5_ = 0;
            while(_loc5_ < blockSize)
            {
               var _loc7_:* = _loc4_ + _loc5_;
               var _loc8_:* = param1[_loc7_] ^ _loc6_[_loc5_];
               param1[_loc7_] = _loc8_;
               _loc5_++;
            }
            _loc5_ = uint(blockSize - 1);
            while(_loc5_ >= 0)
            {
               _loc3_[_loc5_]++;
               if(_loc3_[_loc5_] != 0)
               {
                  break;
               }
               _loc5_--;
            }
            _loc4_ += blockSize;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-ctr";
      }
   }
}

