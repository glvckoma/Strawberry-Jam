package currency
{
   public class CombinedCurrencyItem
   {
      private var _countData:Vector.<Object>;
      
      private var _numCurrenciesInUse:int;
      
      public function CombinedCurrencyItem(param1:String)
      {
         var _loc5_:Array = null;
         var _loc6_:Number = NaN;
         var _loc4_:int = 0;
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         super();
         _numCurrenciesInUse = 0;
         if(param1 && param1 != "")
         {
            _countData = new Vector.<Object>(12);
            _loc5_ = param1.split(",");
            _loc3_ = 0;
            while(_loc3_ < _loc5_.length)
            {
               _loc2_ = _loc5_[_loc3_].split("x");
               if(_loc2_.length < 2)
               {
                  throw new Error("Unable to parse currency. String=" + _loc5_[_loc3_]);
               }
               _loc6_ = int(_loc2_[1]);
               _loc4_ = int(_loc2_[0]);
               _numCurrenciesInUse++;
               _countData[_loc4_] = {
                  "count":_loc6_,
                  "type":_loc4_,
                  "name":typeToName(_loc4_)
               };
               _loc3_++;
            }
         }
      }
      
      public function get countData() : Vector.<Object>
      {
         return _countData;
      }
      
      public function get numCurrenciesInUse() : int
      {
         return _numCurrenciesInUse;
      }
      
      public function getCountDataObjectByType(param1:int) : Object
      {
         if(param1 < 0 || param1 >= _countData.length)
         {
            return null;
         }
         return _countData[param1];
      }
      
      private function typeToName(param1:int) : String
      {
         switch(param1 - 4)
         {
            case 0:
               return "straw";
            case 1:
               return "bamboo";
            case 2:
               return "wood";
            case 3:
               return "stone";
            case 4:
               return "silver";
            case 5:
               return "gold";
            case 6:
               return "gemstone";
            default:
               return "";
         }
      }
   }
}

