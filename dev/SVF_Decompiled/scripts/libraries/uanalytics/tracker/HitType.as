package libraries.uanalytics.tracker
{
   import flash.system.System;
   import flash.utils.describeType;
   
   public class HitType
   {
      public static const PAGEVIEW:String = "pageview";
      
      public static const SCREENVIEW:String = "screenview";
      
      public static const EVENT:String = "event";
      
      public static const TRANSACTION:String = "transaction";
      
      public static const ITEM:String = "item";
      
      public static const SOCIAL:String = "social";
      
      public static const EXCEPTION:String = "exception";
      
      public static const TIMING:String = "timing";
      
      public function HitType()
      {
         super();
      }
      
      public static function isValid(param1:String) : Boolean
      {
         var _loc3_:String = null;
         var _loc5_:XML = describeType(HitType);
         var _loc2_:Boolean = false;
         for each(var _loc4_ in _loc5_.constant)
         {
            _loc3_ = String(_loc4_.@name);
            if(HitType[_loc3_] == param1)
            {
               _loc2_ = true;
               break;
            }
         }
         System.disposeXML(_loc5_);
         if(_loc2_)
         {
            return true;
         }
         return false;
      }
   }
}

