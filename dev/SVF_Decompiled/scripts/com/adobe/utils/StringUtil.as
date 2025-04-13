package com.adobe.utils
{
   public class StringUtil
   {
      public function StringUtil()
      {
         super();
      }
      
      public static function stringsAreEqual(param1:String, param2:String, param3:Boolean) : Boolean
      {
         if(param3)
         {
            return param1 == param2;
         }
         return param1.toUpperCase() == param2.toUpperCase();
      }
      
      public static function trim(param1:String) : String
      {
         return StringUtil.ltrim(StringUtil.rtrim(param1));
      }
      
      public static function ltrim(param1:String) : String
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = param1.length;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(param1.charCodeAt(_loc3_) > 32)
            {
               return param1.substring(_loc3_);
            }
            _loc3_++;
         }
         return "";
      }
      
      public static function rtrim(param1:String) : String
      {
         var _loc3_:* = NaN;
         var _loc2_:Number = param1.length;
         _loc3_ = _loc2_;
         while(_loc3_ > 0)
         {
            if(param1.charCodeAt(_loc3_ - 1) > 32)
            {
               return param1.substring(0,_loc3_);
            }
            _loc3_--;
         }
         return "";
      }
      
      public static function beginsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(0,param2.length);
      }
      
      public static function endsWith(param1:String, param2:String) : Boolean
      {
         return param2 == param1.substring(param1.length - param2.length);
      }
      
      public static function remove(param1:String, param2:String) : String
      {
         return StringUtil.replace(param1,param2,"");
      }
      
      public static function replace(param1:String, param2:String, param3:String) : String
      {
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:String = new String();
         var _loc4_:Boolean = false;
         var _loc5_:Number = param1.length;
         var _loc6_:Number = param2.length;
         _loc7_ = 0;
         for(; _loc7_ < _loc5_; _loc7_++)
         {
            if(param1.charAt(_loc7_) == param2.charAt(0))
            {
               _loc4_ = true;
               _loc8_ = 0;
               while(_loc8_ < _loc6_)
               {
                  if(param1.charAt(_loc7_ + _loc8_) != param2.charAt(_loc8_))
                  {
                     _loc4_ = false;
                     break;
                  }
                  _loc8_++;
               }
               if(_loc4_)
               {
                  _loc9_ += param3;
                  _loc7_ += _loc6_ - 1;
                  continue;
               }
            }
            _loc9_ += param1.charAt(_loc7_);
         }
         return _loc9_;
      }
   }
}

