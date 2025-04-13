package org.osmf.media.pluginClasses
{
   public class VersionUtils
   {
      public function VersionUtils()
      {
         super();
      }
      
      public static function parseVersionString(param1:String) : Object
      {
         var _loc4_:Array = param1.split(".");
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(_loc4_.length >= 1)
         {
            _loc2_ = parseInt(_loc4_[0]);
         }
         if(_loc4_.length >= 2)
         {
            _loc3_ = parseInt(_loc4_[1]);
            if(_loc3_ < 10)
            {
               _loc3_ *= 10;
            }
         }
         return {
            "major":_loc2_,
            "minor":_loc3_
         };
      }
   }
}

