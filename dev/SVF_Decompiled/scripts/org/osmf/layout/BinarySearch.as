package org.osmf.layout
{
   import org.osmf.utils.OSMFStrings;
   
   internal class BinarySearch
   {
      public function BinarySearch()
      {
         super();
      }
      
      public static function search(param1:Object, param2:Function, param3:*, param4:int = 0, param5:int = -2147483648) : int
      {
         var _loc8_:int = 0;
         var _loc7_:* = undefined;
         if(param1 == null || param2 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         var _loc6_:* = int(-param4);
         param5 = int(param5 == -2147483648 ? param1.length - 1 : param5);
         if(param1.length > 0 && param4 <= param5)
         {
            _loc8_ = (param4 + param5) / 2;
            _loc7_ = param1[_loc8_];
            switch(param2(param3,_loc7_))
            {
               case -1:
                  _loc6_ = search(param1,param2,param3,param4,_loc8_ - 1);
                  break;
               case 0:
                  _loc6_ = _loc8_;
                  break;
               case 1:
                  _loc6_ = search(param1,param2,param3,_loc8_ + 1,param5);
            }
         }
         return _loc6_;
      }
   }
}

