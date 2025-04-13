package org.osmf.elements.f4mClasses
{
   import flash.utils.ByteArray;
   
   internal class Base64Decoder
   {
      private static const ESCAPE_CHAR_CODE:Number = 61;
      
      private static const inverse:Array = [64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,62,64,64,64,63,52,53,54,55,56,57,58,59,60,61,64,64,64,64,64,64,64,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,64,64,64,64,64,64,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64,64];
      
      private var count:int = 0;
      
      private var data:ByteArray;
      
      private var filled:int = 0;
      
      private var work:Array = [0,0,0,0];
      
      public function Base64Decoder()
      {
         super();
         data = new ByteArray();
      }
      
      private static function copyByteArray(param1:ByteArray, param2:ByteArray, param3:uint = 0) : void
      {
         var _loc5_:int = int(param1.position);
         param1.position = 0;
         param2.position = 0;
         var _loc4_:uint = 0;
         while(param1.bytesAvailable > 0 && _loc4_ < param3)
         {
            param2.writeByte(param1.readByte());
            _loc4_++;
         }
         param1.position = _loc5_;
         param2.position = 0;
      }
      
      public function decode(param1:String) : void
      {
         var _loc3_:* = 0;
         var _loc2_:Number = NaN;
         _loc3_ = 0;
         for(; _loc3_ < param1.length; _loc3_++)
         {
            _loc2_ = Number(param1.charCodeAt(_loc3_));
            if(_loc2_ == 61)
            {
               work[count++] = -1;
            }
            else
            {
               if(inverse[_loc2_] == 64)
               {
                  continue;
               }
               work[count++] = inverse[_loc2_];
            }
            if(count == 4)
            {
               count = 0;
               data.writeByte(work[0] << 2 | (work[1] & 0xFF) >> 4);
               filled++;
               if(work[2] == -1)
               {
                  break;
               }
               data.writeByte(work[1] << 4 | (work[2] & 0xFF) >> 2);
               filled++;
               if(work[3] == -1)
               {
                  break;
               }
               data.writeByte(work[2] << 6 | work[3]);
               filled++;
            }
         }
      }
      
      public function drain() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         copyByteArray(data,_loc1_,filled);
         filled = 0;
         return _loc1_;
      }
   }
}

