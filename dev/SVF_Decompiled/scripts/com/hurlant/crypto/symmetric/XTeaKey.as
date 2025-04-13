package com.hurlant.crypto.symmetric
{
   import com.hurlant.crypto.prng.Random;
   import com.hurlant.util.Memory;
   import flash.utils.ByteArray;
   
   public class XTeaKey implements ISymmetricKey
   {
      public const NUM_ROUNDS:uint = 64;
      
      private var k:Array;
      
      public function XTeaKey(param1:ByteArray)
      {
         super();
         param1.position = 0;
         k = [param1.readUnsignedInt(),param1.readUnsignedInt(),param1.readUnsignedInt(),param1.readUnsignedInt()];
      }
      
      public static function parseKey(param1:String) : XTeaKey
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(parseInt(param1.substr(0,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(8,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(16,8),16));
         _loc2_.writeUnsignedInt(parseInt(param1.substr(24,8),16));
         _loc2_.position = 0;
         return new XTeaKey(_loc2_);
      }
      
      public function getBlockSize() : uint
      {
         return 8;
      }
      
      public function encrypt(param1:ByteArray, param2:uint = 0) : void
      {
         var _loc4_:* = 0;
         param1.position = param2;
         var _loc5_:uint = param1.readUnsignedInt();
         var _loc7_:uint = param1.readUnsignedInt();
         var _loc6_:uint = 0;
         var _loc3_:Number = 2654435769;
         _loc4_ = 0;
         while(_loc4_ < 64)
         {
            _loc5_ += (_loc7_ << 4 ^ _loc7_ >> 5) + _loc7_ ^ _loc6_ + k[_loc6_ & 3];
            _loc6_ += _loc3_;
            _loc7_ += (_loc5_ << 4 ^ _loc5_ >> 5) + _loc5_ ^ _loc6_ + k[_loc6_ >> 11 & 3];
            _loc4_++;
         }
         param1.position -= 8;
         param1.writeUnsignedInt(_loc5_);
         param1.writeUnsignedInt(_loc7_);
      }
      
      public function decrypt(param1:ByteArray, param2:uint = 0) : void
      {
         var _loc4_:* = 0;
         param1.position = param2;
         var _loc5_:uint = param1.readUnsignedInt();
         var _loc7_:uint = param1.readUnsignedInt();
         var _loc3_:Number = 2654435769;
         var _loc6_:uint = _loc3_ * 64;
         _loc4_ = 0;
         while(_loc4_ < 64)
         {
            _loc7_ -= (_loc5_ << 4 ^ _loc5_ >> 5) + _loc5_ ^ _loc6_ + k[_loc6_ >> 11 & 3];
            _loc6_ -= _loc3_;
            _loc5_ -= (_loc7_ << 4 ^ _loc7_ >> 5) + _loc7_ ^ _loc6_ + k[_loc6_ & 3];
            _loc4_++;
         }
         param1.position -= 8;
         param1.writeUnsignedInt(_loc5_);
         param1.writeUnsignedInt(_loc7_);
      }
      
      public function dispose() : void
      {
         var _loc2_:* = 0;
         var _loc1_:Random = new Random();
         _loc2_ = 0;
         while(_loc2_ < k.length)
         {
            k[_loc2_] = _loc1_.nextByte();
            delete k[_loc2_];
            _loc2_++;
         }
         k = null;
         Memory.gc();
      }
      
      public function toString() : String
      {
         return "xtea";
      }
   }
}

