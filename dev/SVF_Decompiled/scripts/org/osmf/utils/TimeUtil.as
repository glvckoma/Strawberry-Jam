package org.osmf.utils
{
   public class TimeUtil
   {
      public function TimeUtil()
      {
         super();
      }
      
      public static function parseTime(param1:String) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:Number = 0;
         var _loc2_:Array = param1.split(":");
         if(_loc2_.length > 1)
         {
            _loc4_ = _loc2_[0] * 3600;
            _loc4_ = _loc4_ + _loc2_[1] * 60;
            _loc4_ = _loc4_ + Number(_loc2_[2]);
         }
         else
         {
            _loc3_ = 0;
            switch(param1.charAt(param1.length - 1))
            {
               case "h":
                  _loc3_ = 3600;
                  break;
               case "m":
                  _loc3_ = 60;
                  break;
               case "s":
                  _loc3_ = 1;
            }
            if(_loc3_)
            {
               _loc4_ = Number(param1.substr(0,param1.length - 1)) * _loc3_;
            }
            else
            {
               _loc4_ = Number(param1);
            }
         }
         return _loc4_;
      }
      
      public static function formatAsTimeCode(param1:Number) : String
      {
         var _loc3_:Number = Math.floor(param1 / 3600);
         _loc3_ = isNaN(_loc3_) ? 0 : _loc3_;
         var _loc4_:Number = Math.floor(param1 % 3600 / 60);
         _loc4_ = isNaN(_loc4_) ? 0 : _loc4_;
         var _loc2_:Number = Math.floor(param1 % 3600 % 60);
         _loc2_ = isNaN(_loc2_) ? 0 : _loc2_;
         return (_loc3_ == 0 ? "" : (_loc3_ < 10 ? "0" + _loc3_.toString() + ":" : _loc3_.toString() + ":")) + (_loc4_ < 10 ? "0" + _loc4_.toString() : _loc4_.toString()) + ":" + (_loc2_ < 10 ? "0" + _loc2_.toString() : _loc2_.toString());
      }
   }
}

