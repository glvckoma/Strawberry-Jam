package com.greensock.easing
{
   public class Ease
   {
      protected static var _baseParams:Array = [0,0,1,1];
      
      protected var _func:Function;
      
      protected var _params:Array;
      
      protected var _p1:Number;
      
      protected var _p2:Number;
      
      protected var _p3:Number;
      
      public var _type:int;
      
      public var _power:int;
      
      public var _calcEnd:Boolean;
      
      public function Ease(param1:Function = null, param2:Array = null, param3:Number = 0, param4:Number = 0)
      {
         super();
         _func = param1;
         _params = !!param2 ? _baseParams.concat(param2) : _baseParams;
         _type = param3;
         _power = param4;
      }
      
      public function getRatio(param1:Number) : Number
      {
         var _loc2_:Number = NaN;
         if(_func != null)
         {
            _params[0] = param1;
            return _func.apply(null,_params);
         }
         _loc2_ = _type == 1 ? 1 - param1 : (_type == 2 ? param1 : (param1 < 0.5 ? param1 * 2 : (1 - param1) * 2));
         if(_power == 1)
         {
            _loc2_ *= _loc2_;
         }
         else if(_power == 2)
         {
            _loc2_ *= _loc2_ * _loc2_;
         }
         else if(_power == 3)
         {
            _loc2_ *= _loc2_ * _loc2_ * _loc2_;
         }
         else if(_power == 4)
         {
            _loc2_ *= _loc2_ * _loc2_ * _loc2_ * _loc2_;
         }
         return _type == 1 ? 1 - _loc2_ : (_type == 2 ? _loc2_ : (param1 < 0.5 ? _loc2_ / 2 : 1 - _loc2_ / 2));
      }
   }
}

