package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   
   public class ColorTransformPlugin extends TintPlugin
   {
      public static const API:Number = 2;
      
      public function ColorTransformPlugin()
      {
         super();
         _propName = "colorTransform";
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var _loc5_:ColorTransform = null;
         var _loc7_:Number = NaN;
         var _loc6_:ColorTransform = new ColorTransform();
         if(param1 is DisplayObject)
         {
            _transform = DisplayObject(param1).transform;
            _loc5_ = _transform.colorTransform;
         }
         else
         {
            if(!(param1 is ColorTransform))
            {
               return false;
            }
            _loc5_ = param1 as ColorTransform;
         }
         if(param2 is ColorTransform)
         {
            _loc6_.concat(param2);
         }
         else
         {
            _loc6_.concat(_loc5_);
         }
         for(var _loc4_ in param2)
         {
            if(_loc4_ == "tint" || _loc4_ == "color")
            {
               if(param2[_loc4_] != null)
               {
                  _loc6_.color = int(param2[_loc4_]);
               }
            }
            else if(!(_loc4_ == "tintAmount" || _loc4_ == "exposure" || _loc4_ == "brightness"))
            {
               _loc6_[_loc4_] = param2[_loc4_];
            }
         }
         if(!(param2 is ColorTransform))
         {
            if(!isNaN(param2.tintAmount))
            {
               _loc7_ = param2.tintAmount / (1 - (_loc6_.redMultiplier + _loc6_.greenMultiplier + _loc6_.blueMultiplier) / 3);
               _loc6_.redOffset *= _loc7_;
               _loc6_.greenOffset *= _loc7_;
               _loc6_.blueOffset *= _loc7_;
               _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc6_.blueMultiplier = 1 - param2.tintAmount;
            }
            else if(!isNaN(param2.exposure))
            {
               _loc6_.redOffset = _loc6_.greenOffset = _loc6_.blueOffset = 255 * (param2.exposure - 1);
               _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc6_.blueMultiplier = 1;
            }
            else if(!isNaN(param2.brightness))
            {
               _loc6_.redOffset = _loc6_.greenOffset = _loc6_.blueOffset = Math.max(0,(param2.brightness - 1) * 255);
               _loc6_.redMultiplier = _loc6_.greenMultiplier = _loc6_.blueMultiplier = 1 - Math.abs(param2.brightness - 1);
            }
         }
         _init(_loc5_,_loc6_);
         return true;
      }
   }
}

