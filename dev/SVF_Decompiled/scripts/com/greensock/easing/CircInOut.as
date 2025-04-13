package com.greensock.easing
{
   public final class CircInOut extends Ease
   {
      public static var ease:CircInOut = new CircInOut();
      
      public function CircInOut()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         param1 *= 2;
         return param1 < 1 ? -0.5 * (Math.sqrt(1 - param1 * param1) - 1) : 0.5 * (Math.sqrt(1 - (param1 -= 2) * param1) + 1);
      }
   }
}

