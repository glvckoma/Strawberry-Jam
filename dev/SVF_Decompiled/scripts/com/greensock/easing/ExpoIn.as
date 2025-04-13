package com.greensock.easing
{
   public final class ExpoIn extends Ease
   {
      public static var ease:ExpoIn = new ExpoIn();
      
      public function ExpoIn()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         return Math.pow(2,10 * (param1 - 1)) - 0.001;
      }
   }
}

