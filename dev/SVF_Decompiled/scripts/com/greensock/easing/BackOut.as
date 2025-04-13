package com.greensock.easing
{
   public final class BackOut extends Ease
   {
      public static var ease:BackOut = new BackOut();
      
      public function BackOut(param1:Number = 1.70158)
      {
         super();
         _p1 = param1;
      }
      
      override public function getRatio(param1:Number) : Number
      {
         param1 -= 1;
         return param1 * param1 * ((_p1 + 1) * param1 + _p1) + 1;
      }
      
      public function config(param1:Number = 1.70158) : BackOut
      {
         return new BackOut(param1);
      }
   }
}

