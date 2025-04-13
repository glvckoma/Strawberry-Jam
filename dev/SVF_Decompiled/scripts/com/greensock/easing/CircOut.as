package com.greensock.easing
{
   public final class CircOut extends Ease
   {
      public static var ease:CircOut = new CircOut();
      
      public function CircOut()
      {
         super();
      }
      
      override public function getRatio(param1:Number) : Number
      {
         return Math.sqrt(1 - (param1 -= 1) * param1);
      }
   }
}

