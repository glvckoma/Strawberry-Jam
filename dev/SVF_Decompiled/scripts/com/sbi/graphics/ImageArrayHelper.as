package com.sbi.graphics
{
   public class ImageArrayHelper
   {
      public function ImageArrayHelper()
      {
         super();
      }
      
      public static function packId(param1:int, param2:int, param3:int) : uint
      {
         return param1 << 24 | param2 << 16 | param3;
      }
      
      public static function avatarId(param1:uint) : int
      {
         return param1 >> 24 & 0xFF;
      }
      
      public static function categoryId(param1:uint) : int
      {
         return param1 >> 16 & 0xFF;
      }
      
      public static function layerId(param1:uint) : int
      {
         return param1 & 0xFFFF;
      }
   }
}

