package it.gotoandplay.smartfoxserver.util
{
   public class Entities
   {
      private static var ascTab:Array = [];
      
      ascTab[">"] = "&gt;";
      ascTab["<"] = "&lt;";
      ascTab["&"] = "&amp;";
      ascTab["\'"] = "&apos;";
      ascTab["\""] = "&quot;";
      
      private static var ascTabRev:Array = [];
      
      ascTabRev["&gt;"] = ">";
      ascTabRev["&lt;"] = "<";
      ascTabRev["&amp;"] = "&";
      ascTabRev["&apos;"] = "\'";
      ascTabRev["&quot;"] = "\"";
      
      private static var hexTable:Array = [];
      
      hexTable["0"] = 0;
      hexTable["1"] = 1;
      hexTable["2"] = 2;
      hexTable["3"] = 3;
      hexTable["4"] = 4;
      hexTable["5"] = 5;
      hexTable["6"] = 6;
      hexTable["7"] = 7;
      hexTable["8"] = 8;
      hexTable["9"] = 9;
      hexTable["A"] = 10;
      hexTable["B"] = 11;
      hexTable["C"] = 12;
      hexTable["D"] = 13;
      hexTable["E"] = 14;
      hexTable["F"] = 15;
      
      public function Entities()
      {
         super();
      }
      
      public static function encodeEntities(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc2_:String = null;
         var _loc5_:int = 0;
         var _loc3_:String = "";
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc2_ = param1.charAt(_loc4_);
            _loc5_ = int(param1.charCodeAt(_loc4_));
            if(_loc5_ == 9 || _loc5_ == 10 || _loc5_ == 13)
            {
               _loc3_ += _loc2_;
            }
            else if(_loc5_ >= 32 && _loc5_ <= 126)
            {
               if(ascTab[_loc2_] != null)
               {
                  _loc3_ += ascTab[_loc2_];
               }
               else
               {
                  _loc3_ += _loc2_;
               }
            }
            else
            {
               _loc3_ += _loc2_;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function decodeEntities(param1:String) : String
      {
         var _loc5_:String = null;
         var _loc3_:String = null;
         var _loc7_:* = null;
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc6_:int = 0;
         _loc5_ = "";
         while(_loc6_ < param1.length)
         {
            _loc3_ = param1.charAt(_loc6_);
            if(_loc3_ == "&")
            {
               _loc7_ = _loc3_;
               do
               {
                  _loc6_++;
                  _loc4_ = param1.charAt(_loc6_);
                  _loc7_ += _loc4_;
               }
               while(_loc4_ != ";" && _loc6_ < param1.length);
               
               _loc2_ = ascTabRev[_loc7_];
               if(_loc2_ != null)
               {
                  _loc5_ += _loc2_;
               }
               else
               {
                  _loc5_ += String.fromCharCode(getCharCode(_loc7_));
               }
            }
            else
            {
               _loc5_ += _loc3_;
            }
            _loc6_++;
         }
         return _loc5_;
      }
      
      public static function getCharCode(param1:String) : Number
      {
         var _loc2_:String = param1.substr(3,param1.length);
         _loc2_ = _loc2_.substr(0,_loc2_.length - 1);
         return Number("0x" + _loc2_);
      }
   }
}

