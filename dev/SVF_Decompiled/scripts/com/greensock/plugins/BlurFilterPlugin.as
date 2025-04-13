package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.filters.BlurFilter;
   
   public class BlurFilterPlugin extends FilterPlugin
   {
      public static const API:Number = 2;
      
      private static var _propNames:Array = ["blurX","blurY","quality"];
      
      public function BlurFilterPlugin()
      {
         super("blurFilter");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         return _initFilter(param1,param2,param3,BlurFilter,new BlurFilter(0,0,param2.quality || 2),_propNames);
      }
   }
}

