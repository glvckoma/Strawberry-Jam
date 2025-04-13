package com.greensock.easing
{
   public final class BackInOut extends Ease
   {
      public static var ease:BackInOut = new BackInOut();
      
      public function BackInOut(param1:Number = 1.70158)
      {
         super();
         _p1 = param1;
         _p2 = _p1 * 1.525;
      }
      
      override public function getRatio(param1:Number) : Number
      {
         param1 *= 2;
         return param1 < 1 ? 0.5 * param1 * param1 * ((_p2 + 1) * param1 - _p2) : 0.5 * ((param1 -= 2) * param1 * ((_p2 + 1) * param1 + _p2) + 2);
      }
      
      public function config(param1:Number = 1.70158) : BackInOut
      {
         return new BackInOut(param1);
      }
   }
}

