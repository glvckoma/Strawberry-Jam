package org.osmf.utils
{
   public class Version
   {
      private static const _major:String = "1";
      
      private static const _minor:String = "5";
      
      private static const FIELD_SEPARATOR:String = ".";
      
      public function Version()
      {
         super();
      }
      
      public static function get version() : String
      {
         return "1" + "." + "5";
      }
      
      public static function get lastAPICompatibleVersion() : String
      {
         return "1.0";
      }
      
      public static function get FLASH_10_1() : Boolean
      {
         return true;
      }
      
      public static function get LOGGING() : Boolean
      {
         return false;
      }
   }
}

