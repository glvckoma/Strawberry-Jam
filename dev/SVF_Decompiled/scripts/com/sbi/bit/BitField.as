package com.sbi.bit
{
   public class BitField
   {
      private var _bitField:uint;
      
      public function BitField(param1:uint = 0)
      {
         super();
         _bitField = param1;
      }
      
      public function updateBitField(param1:uint, param2:BitWiseOperator) : void
      {
         switch(param2)
         {
            case BitWiseOperator.AND:
               and(param1);
               break;
            case BitWiseOperator.OR:
               or(param1);
               break;
            case BitWiseOperator.XOR:
               xor(param1);
               break;
            case BitWiseOperator.NOT:
               not();
         }
      }
      
      public function and(param1:int) : BitField
      {
         _bitField &= param1;
         return this;
      }
      
      public function or(param1:int) : BitField
      {
         _bitField |= param1;
         return this;
      }
      
      public function xor(param1:int) : BitField
      {
         _bitField ^= param1;
         return this;
      }
      
      public function not() : BitField
      {
         _bitField = ~_bitField;
         return this;
      }
      
      public function toggleBit(param1:int) : BitField
      {
         if(param1 < 0 || param1 > 31)
         {
            throw new Error("Attempted to toggle bit outside of normal range. bit=" + param1);
         }
         return xor(1 << param1);
      }
      
      public function setBit(param1:uint, param2:Boolean) : Boolean
      {
         if(param1 < 0 || param1 > 31)
         {
            throw new Error("Attempted to set bit outside of normal range. bit=" + param1);
         }
         var _loc3_:uint = _bitField;
         if(param2)
         {
            _bitField |= 1 << param1;
         }
         else
         {
            _bitField &= ~(1 << param1);
         }
         return _loc3_ != _bitField;
      }
      
      public function isBitSet(param1:uint) : Boolean
      {
         if(param1 < 0 || param1 > 31)
         {
            throw new Error("Attempted to read bit outside of normal range. bit=" + param1);
         }
         return (_bitField & 1 << param1) != 0;
      }
      
      public function getInt() : uint
      {
         return _bitField;
      }
      
      public function getNumBitsSet() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 32)
         {
            if(isBitSet(_loc2_))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getSetBits() : Array
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = getNumBitsSet();
         var _loc1_:Array = [];
         if(_loc2_ > 0)
         {
            _loc4_ = 0;
            _loc3_ = 0;
            while(_loc3_ < 32)
            {
               if(isBitSet(_loc3_))
               {
                  _loc1_[_loc4_++] = _loc3_;
               }
               _loc3_++;
            }
         }
         return _loc1_;
      }
      
      public function toString() : String
      {
         return String(_bitField);
      }
   }
}

