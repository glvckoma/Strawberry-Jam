package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   
   public class SHABase implements IHash
   {
      public function SHABase()
      {
         super();
      }
      
      public function getInputSize() : uint
      {
         return 64;
      }
      
      public function getHashSize() : uint
      {
         return 0;
      }
      
      public function hash(param1:ByteArray) : ByteArray
      {
         var _loc7_:* = 0;
         var _loc6_:uint = param1.length;
         var _loc8_:String = param1.endian;
         param1.endian = "bigEndian";
         var _loc3_:uint = _loc6_ * 8;
         while(param1.length % 4 != 0)
         {
            param1[param1.length] = 0;
         }
         param1.position = 0;
         var _loc2_:Array = [];
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            _loc2_.push(param1.readUnsignedInt());
            _loc7_ += 4;
         }
         var _loc4_:Array = core(_loc2_,_loc3_);
         var _loc9_:ByteArray = new ByteArray();
         var _loc5_:uint = getHashSize() / 4;
         _loc7_ = 0;
         while(_loc7_ < _loc5_)
         {
            _loc9_.writeUnsignedInt(_loc4_[_loc7_]);
            _loc7_++;
         }
         param1.length = _loc6_;
         param1.endian = _loc8_;
         return _loc9_;
      }
      
      protected function core(param1:Array, param2:uint) : Array
      {
         return null;
      }
      
      public function toString() : String
      {
         return "sha";
      }
   }
}

