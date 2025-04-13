package com.hurlant.crypto.symmetric
{
   import flash.utils.ByteArray;
   
   public class CFBMode extends IVMode implements IMode
   {
      public function CFBMode(param1:ISymmetricKey, param2:IPad = null)
      {
         super(param1,null);
      }
      
      public function encrypt(param1:ByteArray) : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:uint = param1.length;
         var _loc4_:ByteArray = getIV4e();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            key.encrypt(_loc4_);
            _loc3_ = uint(_loc2_ + blockSize < _loc6_ ? blockSize : _loc6_ - _loc2_);
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               var _loc7_:* = _loc2_ + _loc5_;
               var _loc8_:* = param1[_loc7_] ^ _loc4_[_loc5_];
               param1[_loc7_] = _loc8_;
               _loc5_++;
            }
            _loc4_.position = 0;
            _loc4_.writeBytes(param1,_loc2_,_loc3_);
            _loc2_ += blockSize;
         }
      }
      
      public function decrypt(param1:ByteArray) : void
      {
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:uint = param1.length;
         var _loc5_:ByteArray = getIV4d();
         var _loc2_:ByteArray = new ByteArray();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            key.encrypt(_loc5_);
            _loc4_ = uint(_loc3_ + blockSize < _loc7_ ? blockSize : _loc7_ - _loc3_);
            _loc2_.position = 0;
            _loc2_.writeBytes(param1,_loc3_,_loc4_);
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               var _loc8_:* = _loc3_ + _loc6_;
               var _loc9_:* = param1[_loc8_] ^ _loc5_[_loc6_];
               param1[_loc8_] = _loc9_;
               _loc6_++;
            }
            _loc5_.position = 0;
            _loc5_.writeBytes(_loc2_);
            _loc3_ += blockSize;
         }
      }
      
      public function toString() : String
      {
         return key.toString() + "-cfb";
      }
   }
}

