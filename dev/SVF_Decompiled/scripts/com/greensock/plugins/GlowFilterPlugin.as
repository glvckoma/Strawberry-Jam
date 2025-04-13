package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.filters.GlowFilter;
   
   public class GlowFilterPlugin extends FilterPlugin
   {
      public static const API:Number = 2;
      
      private static var _propNames:Array = ["color","alpha","blurX","blurY","strength","quality","inner","knockout"];
      
      public function GlowFilterPlugin()
      {
         super("glowFilter");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         return _initFilter(param1,param2,param3,GlowFilter,new GlowFilter(16777215,0,0,0,param2.strength || 1,param2.quality || 2,param2.inner,param2.knockout),_propNames);
      }
   }
}

