package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class OFBMode extends IVMode implements IMode
   {
      public function OFBMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,null);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = getIV4e();
         core(param1,_loc2_);
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc2_:ByteArray = getIV4d();
         core(param1,_loc2_);
      }
      
      private function core(param1:ByteArray, param2:ByteArray) : void
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:uint = param1.length;
         var _loc3_:ByteArray = new ByteArray();
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            key.encrypt(param2);
            _loc3_.position = 0;
            _loc3_.writeBytes(param2);
            _loc5_ = uint(_loc4_ + blockSize < _loc7_ ? blockSize : _loc7_ - _loc4_);
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               var _loc8_:* = _loc4_ + _loc6_;
               var _loc9_:* = param1[_loc8_] ^ param2[_loc6_];
               param1[_loc8_] = _loc9_;
               _loc6_++;
            }
            param2.position = 0;
            param2.writeBytes(_loc3_);
            _loc4_ += blockSize;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-ofb";
      }
   }
}

