package libraries.uanalytics.utils
{
   import flash.utils.ByteArray;
   
   public final class crc32
   {
      private static var _poly:uint = 3988292384;
      
      private static var _init:uint = 4294967295;
      
      private static var lookup:Vector.<uint> = make_crc_table();
      
      private var _crc:uint;
      
      private var _length:uint;
      
      private var _endian:String;
      
      public function crc32()
      {
         super();
         _length = 4294967295;
         _endian = "littleEndian";
         reset();
      }
      
      private static function make_crc_table() : Vector.<uint>
      {
         var _loc1_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:Vector.<uint> = new Vector.<uint>();
         _loc2_ = 0;
         while(_loc2_ < 256)
         {
            _loc1_ = _loc2_;
            _loc3_ = 0;
            while(_loc3_ < 8)
            {
               if((_loc1_ & 1) != 0)
               {
                  _loc1_ = uint(_loc1_ >>> 1 ^ _poly);
               }
               else
               {
                  _loc1_ >>>= 1;
               }
               _loc3_++;
            }
            _loc4_[_loc2_] = _loc1_;
            _loc2_++;
         }
         return _loc4_;
      }
      
      public function get endian() : String
      {
         return _endian;
      }
      
      public function get length() : uint
      {
         return _length;
      }
      
      public function update(param1:ByteArray, param2:uint = 0, param3:uint = 0) : void
      {
         var _loc6_:* = 0;
         var _loc4_:* = 0;
         if(param3 == 0)
         {
            param3 = param1.length;
         }
         param1.position = param2;
         var _loc5_:uint = uint(_length & _crc);
         _loc6_ = param2;
         while(_loc6_ < param3)
         {
            _loc4_ = uint(param1[_loc6_]);
            _loc5_ = uint(_loc5_ >>> 8 ^ lookup[(_loc5_ ^ _loc4_) & 0xFF]);
            _loc6_++;
         }
         _crc = ~_loc5_;
      }
      
      public function reset() : void
      {
         _crc = _init;
      }
      
      public function valueOf() : uint
      {
         return _crc;
      }
      
      public function toString(param1:Number = 16) : String
      {
         return _crc.toString(param1);
      }
   }
}

