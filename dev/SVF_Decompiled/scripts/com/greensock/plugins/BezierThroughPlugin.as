package com.greensock.plugins
{
   import com.greensock.TweenLite;
   
   public class BezierThroughPlugin extends BezierPlugin
   {
      public static const API:Number = 2;
      
      public function BezierThroughPlugin()
      {
         super();
         _propName = "bezierThrough";
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(param2 is Array)
         {
            param2 = {"values":param2};
         }
         param2.type = "thru";
         return super._onInitTween(param1,param2,param3);
      }
   }
}

