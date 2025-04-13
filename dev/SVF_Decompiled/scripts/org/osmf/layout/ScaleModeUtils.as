package org.osmf.layout
{
   import flash.geom.Point;
   
   internal class ScaleModeUtils
   {
      public function ScaleModeUtils()
      {
         super();
      }
      
      public static function getScaledSize(param1:String, param2:Number, param3:Number, param4:Number, param5:Number) : Point
      {
         var _loc6_:Point = null;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         switch(param1)
         {
            case "zoom":
            case "letterbox":
               _loc8_ = param2 / param3;
               _loc7_ = (param4 || param2) / (param5 || param3);
               if(param1 == "zoom" && _loc7_ < _loc8_ || param1 == "letterbox" && _loc7_ > _loc8_)
               {
                  _loc6_ = new Point(param2,param2 / _loc7_);
                  break;
               }
               _loc6_ = new Point(param3 * _loc7_,param3);
               break;
            case "stretch":
               _loc6_ = new Point(param2,param3);
               break;
            case "none":
               _loc6_ = new Point(param4 || param2,param5 || param3);
         }
         return _loc6_;
      }
   }
}

