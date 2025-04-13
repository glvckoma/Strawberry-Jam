package com.sbi.bit
{
   public class ScalableBitField
   {
      private static const NUM_BITS_PER_BITFIELD:uint = 32;
      
      protected var _maxArraySize:uint = 8;
      
      private var _bitFields:Vector.<BitField>;
      
      public function ScalableBitField(param1:String = "", param2:int = 8)
      {
         var _loc4_:* = 0;
         super();
         _maxArraySize = param2;
         _bitFields = new Vector.<BitField>();
         var _loc3_:Array = param1.split(",");
         enforceMaxArraySize(_loc3_.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _bitFields[_loc4_] = new BitField(_loc3_[_loc4_]);
            _loc4_++;
         }
         trim();
      }
      
      public function updateBitField(param1:ScalableBitField, param2:BitWiseOperator) : void
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(param2 == BitWiseOperator.NOT)
         {
            _loc4_ = 0;
            while(_loc4_ < _bitFields.length)
            {
               _bitFields[_loc4_].not();
               _loc4_++;
            }
            trim();
            return;
         }
         if(param1 == null)
         {
            throw new Error("Attempted to update bit field with null changes: op:" + param2);
         }
         var _loc5_:uint = param1._bitFields.length;
         if(_loc5_ > _bitFields.length)
         {
            resizeBitFields(_loc5_,false);
         }
         _loc4_ = 0;
         while(_loc4_ < _bitFields.length)
         {
            _loc3_ = uint(_loc4_ < _loc5_ ? param1._bitFields[_loc4_].getInt() : 0);
            _bitFields[_loc4_].updateBitField(_loc3_,param2);
            _loc4_++;
         }
         trim();
      }
      
      public function and(param1:ScalableBitField) : ScalableBitField
      {
         updateBitField(param1,BitWiseOperator.AND);
         return this;
      }
      
      public function or(param1:ScalableBitField) : ScalableBitField
      {
         updateBitField(param1,BitWiseOperator.OR);
         return this;
      }
      
      public function xor(param1:ScalableBitField) : ScalableBitField
      {
         updateBitField(param1,BitWiseOperator.XOR);
         return this;
      }
      
      public function not() : ScalableBitField
      {
         updateBitField(null,BitWiseOperator.NOT);
         return this;
      }
      
      public function unset(param1:ScalableBitField) : ScalableBitField
      {
         return and(param1.clone().not().fill(_bitFields.length));
      }
      
      public function unsetAll() : void
      {
         _bitFields = new Vector.<BitField>();
         _bitFields[0] = new BitField(0);
      }
      
      public function toggleBit(param1:int) : ScalableBitField
      {
         if(param1 < 0)
         {
            throw new Error("ERROR: Attempted to toggle a negative bit index. bit=" + param1);
         }
         var _loc3_:int = int(getArrayIndexForBit(param1));
         var _loc2_:Boolean = false;
         if(_loc3_ >= _bitFields.length)
         {
            resizeBitFields(_loc3_ + 1,false);
            _loc2_ = true;
         }
         _bitFields[_loc3_].toggleBit(getTranslatedBit(param1));
         if(!_loc2_)
         {
            trim();
         }
         return this;
      }
      
      public function setBit(param1:uint, param2:Boolean) : Boolean
      {
         if(param1 < 0)
         {
            throw new Error("ERROR: Attempted to set a negative bit index. bit=" + param1);
         }
         var _loc4_:uint = getArrayIndexForBit(param1);
         if(_loc4_ >= _bitFields.length)
         {
            if(!param2)
            {
               return false;
            }
            resizeBitFields(_loc4_ + 1,false);
         }
         var _loc3_:Boolean = _bitFields[_loc4_].setBit(getTranslatedBit(param1),param2);
         if(!param2 && _loc3_)
         {
            trim();
         }
         return _loc3_;
      }
      
      public function isBitSet(param1:uint) : Boolean
      {
         if(param1 < 0)
         {
            throw new Error("Attempted to check a negative bit index. bit=" + param1);
         }
         var _loc2_:uint = getArrayIndexForBit(param1);
         return _loc2_ >= _bitFields.length ? false : _bitFields[_loc2_].isBitSet(getTranslatedBit(param1));
      }
      
      public function areAnyBitsSet() : Boolean
      {
         return _bitFields.length > 1 || _bitFields[0].getInt() != 0;
      }
      
      public function getNumBitsSet() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _bitFields.length)
         {
            _loc1_ += _bitFields[_loc2_].getNumBitsSet();
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function getSetBits() : Array
      {
         var _loc2_:int = 0;
         var _loc1_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < _bitFields.length)
         {
            for each(var _loc3_ in _bitFields[_loc2_].getSetBits())
            {
               _loc1_.push(_loc3_ + _loc2_ * 32);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function toString() : String
      {
         var _loc3_:String = "";
         var _loc1_:Boolean = true;
         for each(var _loc2_ in _bitFields)
         {
            if(_loc1_)
            {
               _loc1_ = false;
            }
            else
            {
               _loc3_ += ",";
            }
            _loc3_ += _loc2_.toString();
         }
         return _loc3_;
      }
      
      public function clone() : ScalableBitField
      {
         return new ScalableBitField(toString(),_maxArraySize);
      }
      
      public function equals(param1:ScalableBitField) : Boolean
      {
         return param1 != null && toString() == param1.toString();
      }
      
      private function enforceMaxArraySize(param1:int) : void
      {
         if(param1 > _maxArraySize)
         {
            throw new Error("Blocking operation that requires more than " + _maxArraySize + " elements: " + param1);
         }
      }
      
      private function getArrayIndexForBit(param1:uint) : uint
      {
         return param1 / 32;
      }
      
      private function getTranslatedBit(param1:uint) : uint
      {
         return param1 % 32;
      }
      
      private function trim() : void
      {
         var _loc2_:uint = uint(_bitFields.length - 1);
         while(_loc2_ > 0 && _bitFields[_loc2_].getInt() == 0)
         {
            _loc2_--;
         }
         var _loc1_:uint = uint(_loc2_ + 1);
         if(_loc1_ != _bitFields.length)
         {
            resizeBitFields(_loc1_,false);
         }
      }
      
      private function fill(param1:int) : ScalableBitField
      {
         if(_bitFields.length < param1)
         {
            resizeBitFields(param1,true);
         }
         return this;
      }
      
      private function resizeBitFields(param1:uint, param2:Boolean) : void
      {
         var _loc3_:* = 0;
         enforceMaxArraySize(param1);
         var _loc4_:int = param2 ? -1 : 0;
         if(param1 < _bitFields.length)
         {
            _bitFields.splice(param1,_bitFields.length);
         }
         else if(param1 > _bitFields.length)
         {
            _loc3_ = _bitFields.length;
            while(_loc3_ < param1)
            {
               _bitFields[_loc3_] = new BitField(_loc4_);
               _loc3_++;
            }
         }
      }
   }
}

