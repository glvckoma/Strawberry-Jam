package com.hurlant.util
{
   import flash.utils.ByteArray;
   
   public class Base64
   {
      private static const _encodeChars:Vector.<int> = _initEncoreChar();
      
      private static const _decodeChars:Vector.<int> = _initDecodeChar();
      
      public function Base64()
      {
         super();
      }
      
      public static function encode(param1:String) : String
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         return encodeByteArray(_loc2_);
      }
      
      public static function decode(param1:String) : String
      {
         var _loc2_:ByteArray = decodeToByteArray(param1);
         return _loc2_.readUTFBytes(_loc2_.length);
      }
      
      public static function encodeByteArray(param1:ByteArray) : String
      {
         var _loc3_:* = 0;
         var _loc7_:ByteArray = new ByteArray();
         _loc7_.length = (2 + param1.length - (param1.length + 2) % 3) * 4 / 3;
         var _loc6_:int = 0;
         var _loc2_:int = param1.length % 3;
         var _loc4_:int = param1.length - _loc2_;
         var _loc5_:int = 0;
         while(_loc6_ < _loc4_)
         {
            _loc3_ = uint(param1[_loc6_++] << 16 | param1[_loc6_++] << 8 | param1[_loc6_++]);
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 18];
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 12 & 0x3F];
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 6 & 0x3F];
            _loc7_[_loc5_++] = _encodeChars[_loc3_ & 0x3F];
         }
         if(_loc2_ == 1)
         {
            _loc3_ = uint(param1[_loc6_]);
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 2];
            _loc7_[_loc5_++] = _encodeChars[(_loc3_ & 3) << 4];
            _loc7_[_loc5_++] = 61;
            _loc7_[_loc5_++] = 61;
         }
         else if(_loc2_ == 2)
         {
            _loc3_ = uint(param1[_loc6_++] << 8 | param1[_loc6_]);
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 10];
            _loc7_[_loc5_++] = _encodeChars[_loc3_ >>> 4 & 0x3F];
            _loc7_[_loc5_++] = _encodeChars[(_loc3_ & 0x0F) << 2];
            _loc7_[_loc5_++] = 61;
         }
         return _loc7_.readUTFBytes(_loc7_.length);
      }
      
      public static function decodeToByteArray(param1:String) : ByteArray
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = param1.length;
         var _loc5_:ByteArray = new ByteArray();
         _loc5_.writeUTFBytes(param1);
         var _loc6_:int = 0;
         while(_loc7_ < _loc4_)
         {
            _loc8_ = _decodeChars[int(_loc5_[_loc7_++])];
            if(_loc8_ == -1)
            {
               break;
            }
            _loc9_ = _decodeChars[int(_loc5_[_loc7_++])];
            if(_loc9_ == -1)
            {
               break;
            }
            _loc5_[_loc6_++] = _loc8_ << 2 | (_loc9_ & 0x30) >> 4;
            _loc2_ = int(_loc5_[_loc7_++]);
            if(_loc2_ == 61)
            {
               break;
            }
            _loc2_ = _decodeChars[_loc2_];
            if(_loc2_ == -1)
            {
               break;
            }
            _loc5_[_loc6_++] = (_loc9_ & 0x0F) << 4 | (_loc2_ & 0x3C) >> 2;
            _loc3_ = int(_loc5_[_loc7_++]);
            if(_loc3_ == 61)
            {
               break;
            }
            _loc3_ = _decodeChars[_loc3_];
            if(_loc3_ == -1)
            {
               break;
            }
            _loc5_[_loc6_++] = (_loc2_ & 3) << 6 | _loc3_;
         }
         _loc5_.length = _loc6_;
         _loc5_.position = 0;
         return _loc5_;
      }
      
      public static function decodeToByteArrayB(param1:String) : ByteArray
      {
         return decodeToByteArray(param1);
      }
      
      private static function _initEncoreChar() : Vector.<int>
      {
         var _loc1_:int = 0;
         var _loc2_:Vector.<int> = new Vector.<int>(64,true);
         _loc1_ = 0;
         while(_loc1_ < 64)
         {
            _loc2_[_loc1_] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/".charCodeAt(_loc1_);
            _loc1_++;
         }
         return _loc2_;
      }
      
      private static function _initDecodeChar() : Vector.<int>
      {
         return new <int>[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,62,-1,-1,-1,63,52,53,54,55,56,57,58,59,60,61,-1,-1,-1,-1,-1,-1,-1,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,-1,-1,-1,-1,-1,-1,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1];
      }
   }
}

