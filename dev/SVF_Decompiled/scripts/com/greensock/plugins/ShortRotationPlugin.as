package com.greensock.plugins
{
   import com.greensock.TweenLite;
   
   public class ShortRotationPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      public function ShortRotationPlugin()
      {
         super("shortRotation");
         _overwriteProps.pop();
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         var _loc6_:Number = NaN;
         if(typeof param2 == "number")
         {
            return false;
         }
         var _loc5_:* = param2.useRadians == true;
         for(var _loc4_ in param2)
         {
            if(_loc4_ != "useRadians")
            {
               _loc6_ = Number(param1[_loc4_] is Function ? param1[_loc4_.indexOf("set") || !("get" + _loc4_.substr(3) in param1) ? _loc4_ : "get" + _loc4_.substr(3)]() : param1[_loc4_]);
               _initRotation(param1,_loc4_,_loc6_,typeof param2[_loc4_] == "number" ? Number(param2[_loc4_]) : _loc6_ + Number(param2[_loc4_].split("=").join("")),_loc5_);
            }
         }
         return true;
      }
      
      public function _initRotation(param1:Object, param2:String, param3:Number, param4:Number, param5:Boolean = false) : void
      {
         var _loc7_:Number = NaN;
         _loc7_ = param5 ? 3.141592653589793 * 2 : 360;
         var _loc6_:Number = (param4 - param3) % _loc7_;
         if(_loc6_ != _loc6_ % (_loc7_ / 2))
         {
            _loc6_ = _loc6_ < 0 ? _loc6_ + _loc7_ : _loc6_ - _loc7_;
         }
         _addTween(param1,param2,param3,param3 + _loc6_,param2);
         _overwriteProps[_overwriteProps.length] = param2;
      }
   }
}

