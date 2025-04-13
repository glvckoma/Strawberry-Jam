package com.greensock.easing
{
   public final class ExpoOut extends Ease
   {
      public static var ease:ExpoOut = new ExpoOut();
      
      public function ExpoOut()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         return 1 - Math.pow(2,-10 * param1);
      }
   }
}

