package currency
{
   public class UserCurrency
   {
      private static var _gems:int;
      
      private static var _tickets:int;
      
      private static var _diamonds:int;
      
      private static var _crystals:int;
      
      private static var _craftValues:String;
      
      private static var _craftValuesParsed:Vector.<int>;
      
      private static var _currency:Vector.<int>;
      
      public function UserCurrency()
      {
         super();
      }
      
      public static function initCurrency() : void
      {
         _currency = new Vector.<int>(12);
      }
      
      public static function setCurrency(param1:*, param2:int) : Boolean
      {
         var _loc6_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = null;
         var _loc7_:int = 0;
         if(param2 != 100 && (param2 < 0 || param2 >= 12))
         {
            return false;
         }
         if(param2 == 100)
         {
            _loc6_ = param1.split(",");
            _loc7_ = 0;
            while(_loc7_ < _loc6_.length)
            {
               _loc3_ = _loc6_[_loc7_].split("x");
               if(_loc3_.length <= 1)
               {
                  throw new Error("Failed to parse craft values where value=" + _craftValues);
               }
               _loc5_ = int(_loc3_[0]);
               _loc4_ = int(_loc3_[1]);
               _currency[_loc5_] = _loc4_;
               _loc7_++;
            }
         }
         else
         {
            _currency[param2] = param1;
         }
         return true;
      }
      
      public static function getCurrency(param1:int) : int
      {
         if(param1 < 0 || param1 >= _currency.length)
         {
            return -1;
         }
         return _currency[param1];
      }
      
      public static function hasEnoughCurrency(param1:int, param2:*, param3:int = -1) : Boolean
      {
         var _loc7_:Object = null;
         var _loc5_:* = false;
         var _loc6_:int = 0;
         if(param1 == 100)
         {
            if(param3 != -1)
            {
               if(param2 is CombinedCurrencyItem)
               {
                  _loc7_ = param2.getCountDataObjectByType(param3);
                  if(_loc7_ == null)
                  {
                     return false;
                  }
                  return _currency[param3] >= _loc7_.count;
               }
               return _currency[param3] >= param2;
            }
            _loc5_ = param2 is CombinedCurrencyItem;
            _loc6_ = 0;
            while(_loc6_ < _currency.length)
            {
               if(_loc5_)
               {
                  _loc7_ = param2.getCountDataObjectByType(_loc6_);
                  if(_loc7_ != null)
                  {
                     if(_currency[_loc6_] < _loc7_.count)
                     {
                        return false;
                     }
                  }
               }
               else if(_currency[_loc6_] < param2)
               {
                  return false;
               }
               _loc6_++;
            }
            return true;
         }
         return getCurrency(param1) >= param2;
      }
      
      public static function get usableCraftTypes() : Array
      {
         return [4,5,6,7,8,9,10];
      }
   }
}

