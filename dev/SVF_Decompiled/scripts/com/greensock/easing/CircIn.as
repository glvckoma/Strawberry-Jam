package com.greensock.easing
{
   public final class CircIn extends Ease
   {
      public static var ease:CircIn = new CircIn();
      
      public function CircIn()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         return -(Math.sqrt(1 - param1 * param1) - 1);
      }
   }
}

