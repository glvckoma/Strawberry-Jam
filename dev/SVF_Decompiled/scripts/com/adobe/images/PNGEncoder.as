package com.adobe.images
{
   import flash.display.BitmapData;
   import flash.geom.*;
   import flash.utils.ByteArray;
   
   public class PNGEncoder
   {
      private static var crcTable:Array;
      
      private static var crcTableComputed:Boolean = false;
      
      public function PNGEncoder()
      {
         super();
      }
      
      public static function encode(param1:BitmapData) : ByteArray
      {
         var _loc4_:int = 0;
         var _loc2_:* = 0;
         var _loc5_:int = 0;
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUnsignedInt(2303741511);
         _loc3_.writeUnsignedInt(218765834);
         var _loc7_:ByteArray = new ByteArray();
         _loc7_.writeInt(param1.width);
         _loc7_.writeInt(param1.height);
         _loc7_.writeUnsignedInt(134610944);
         _loc7_.writeByte(0);
         writeChunk(_loc3_,1229472850,_loc7_);
         var _loc6_:ByteArray = new ByteArray();
         _loc4_ = 0;
         while(_loc4_ < param1.height)
         {
            _loc6_.writeByte(0);
            if(!param1.transparent)
            {
               _loc5_ = 0;
               while(_loc5_ < param1.width)
               {
                  _loc2_ = param1.getPixel(_loc5_,_loc4_);
                  _loc6_.writeUnsignedInt(uint((_loc2_ & 0xFFFFFF) << 8 | 0xFF));
                  _loc5_++;
               }
            }
            else
            {
               _loc5_ = 0;
               while(_loc5_ < param1.width)
               {
                  _loc2_ = param1.getPixel32(_loc5_,_loc4_);
                  _loc6_.writeUnsignedInt(uint((_loc2_ & 0xFFFFFF) << 8 | _loc2_ >>> 24));
                  _loc5_++;
               }
            }
            _loc4_++;
         }
         _loc6_.compress();
         writeChunk(_loc3_,1229209940,_loc6_);
         writeChunk(_loc3_,1229278788,null);
         return _loc3_;
      }
      
      private static function writeChunk(param1:ByteArray, param2:uint, param3:ByteArray) : void
      {
         var _loc5_:* = 0;
         var _loc10_:* = 0;
         var _loc9_:* = 0;
         var _loc8_:int = 0;
         if(!crcTableComputed)
         {
            crcTableComputed = true;
            crcTable = [];
            _loc10_ = 0;
            while(_loc10_ < 256)
            {
               _loc5_ = _loc10_;
               _loc9_ = 0;
               while(_loc9_ < 8)
               {
                  if(_loc5_ & 1)
                  {
                     _loc5_ = uint(3988292384 ^ uint(_loc5_ >>> 1));
                  }
                  else
                  {
                     _loc5_ >>>= 1;
                  }
                  _loc9_++;
               }
               crcTable[_loc10_] = _loc5_;
               _loc10_++;
            }
         }
         var _loc6_:uint = 0;
         if(param3 != null)
         {
            _loc6_ = param3.length;
         }
         param1.writeUnsignedInt(_loc6_);
         var _loc4_:uint = param1.position;
         param1.writeUnsignedInt(param2);
         if(param3 != null)
         {
            param1.writeBytes(param3);
         }
         var _loc7_:uint = param1.position;
         param1.position = _loc4_;
         _loc5_ = 4294967295;
         _loc8_ = 0;
         while(_loc8_ < _loc7_ - _loc4_)
         {
            _loc5_ = uint(crcTable[(_loc5_ ^ param1.readUnsignedByte()) & 0xFF] ^ uint(_loc5_ >>> 8));
            _loc8_++;
         }
         _loc5_ ^= 4294967295;
         param1.position = _loc7_;
         param1.writeUnsignedInt(_loc5_);
      }
   }
}

