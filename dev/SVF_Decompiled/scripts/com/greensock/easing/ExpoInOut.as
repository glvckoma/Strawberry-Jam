package com.greensock.easing
{
   public final class ExpoInOut extends Ease
   {
      public static var ease:ExpoInOut = new ExpoInOut();
      
      public function ExpoInOut()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         param1 *= 2;
         return param1 < 1 ? 0.5 * Math.pow(2,10 * (param1 - 1)) : 0.5 * (2 - Math.pow(2,-10 * (param1 - 1)));
      }
   }
}

