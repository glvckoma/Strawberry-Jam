package com.greensock.plugins
{
   import com.greensock.TweenLite;
   
   public class VisiblePlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _target:Object;
      
      protected var _tween:TweenLite;
      
      protected var _visible:Boolean;
      
      protected var _initVal:Boolean;
      
      protected var _progress:int;
      
      public function VisiblePlugin()
      {
         super("visible");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         _target = param1;
         _tween = param3;
         _progress = !!_tween.vars.runBackwards ? 0 : 1;
         _initVal = _target.visible;
         _visible = param2;
         return true;
      }
      
      override public function setRatio(param1:Number) : void
      {
         _target.visible = param1 == 1 && (_tween._time / _tween._duration == _progress || _tween._duration == 0) ? _visible : _initVal;
      }
   }
}

