package org.osmf.elements.f4mClasses
{
   internal class DateUtil
   {
      public function DateUtil()
      {
         super();
      }
      
      public static function parseW3CDTF(param1:String) : Date
      {
         var _loc3_:Date = null;
         var _loc7_:String = null;
         var _loc13_:String = null;
         var _loc18_:Array = null;
         var _loc9_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc21_:String = null;
         var _loc20_:Array = null;
         var _loc17_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc15_:Array = null;
         var _loc14_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc6_:String = null;
         try
         {
            _loc7_ = param1.substring(0,param1.indexOf("T"));
            _loc13_ = param1.substring(param1.indexOf("T") + 1,param1.length);
            _loc18_ = _loc7_.split("-");
            _loc9_ = Number(_loc18_.shift());
            _loc16_ = Number(_loc18_.shift());
            _loc2_ = Number(_loc18_.shift());
            if(_loc13_.indexOf("Z") != -1)
            {
               _loc11_ = 1;
               _loc19_ = 0;
               _loc5_ = 0;
               _loc13_ = _loc13_.replace("Z","");
            }
            else if(_loc13_.indexOf("+") != -1)
            {
               _loc11_ = 1;
               _loc21_ = _loc13_.substring(_loc13_.indexOf("+") + 1,_loc13_.length);
               _loc19_ = Number(_loc21_.substring(0,_loc21_.indexOf(":")));
               _loc5_ = Number(_loc21_.substring(_loc21_.indexOf(":") + 1,_loc21_.length));
               _loc13_ = _loc13_.substring(0,_loc13_.indexOf("+"));
            }
            else
            {
               _loc11_ = -1;
               _loc21_ = _loc13_.substring(_loc13_.indexOf("-") + 1,_loc13_.length);
               _loc19_ = Number(_loc21_.substring(0,_loc21_.indexOf(":")));
               _loc5_ = Number(_loc21_.substring(_loc21_.indexOf(":") + 1,_loc21_.length));
               _loc13_ = _loc13_.substring(0,_loc13_.indexOf("-"));
            }
            _loc20_ = _loc13_.split(":");
            _loc17_ = Number(_loc20_.shift());
            _loc12_ = Number(_loc20_.shift());
            _loc15_ = _loc20_.length > 0 ? String(_loc20_.shift()).split(".") : null;
            _loc14_ = _loc15_ != null && _loc15_.length > 0 ? Number(_loc15_.shift()) : 0;
            _loc4_ = _loc15_ != null && _loc15_.length > 0 ? Number(_loc15_.shift()) : 0;
            _loc10_ = Date.UTC(_loc9_,_loc16_ - 1,_loc2_,_loc17_,_loc12_,_loc14_,_loc4_);
            _loc8_ = (_loc19_ * 3600000 + _loc5_ * 60000) * _loc11_;
            _loc3_ = new Date(_loc10_ - _loc8_);
            if(_loc3_.toString() == "Invalid Date")
            {
               throw new Error("This date does not conform to W3CDTF.");
            }
         }
         catch(e:Error)
         {
            _loc6_ = "Unable to parse the string [" + param1 + "] into a date. ";
            _loc6_ = _loc6_ + ("The internal error was: " + e.toString());
            throw new Error(_loc6_);
         }
         return _loc3_;
      }
   }
}

