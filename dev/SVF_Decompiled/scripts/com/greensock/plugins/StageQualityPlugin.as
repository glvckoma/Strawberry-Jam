package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.display.Stage;
   
   public class StageQualityPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _stage:Stage;
      
      protected var _during:String;
      
      protected var _after:String;
      
      protected var _tween:TweenLite;
      
      public function StageQualityPlugin()
      {
         super("stageQuality");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!(param2.stage is Stage))
         {
            trace("You must define a \'stage\' property for the stageQuality object in your tween.");
            return false;
         }
         _stage = param2.stage as Stage;
         _tween = param3;
         _during = "during" in param2 ? param2.during : "medium";
         _after = "after" in param2 ? param2.after : _stage.quality;
         return true;
      }
      
      override public function setRatio(param1:Number) : void
      {
         if(param1 == 1 && _tween._duration == _tween._time && _tween.data != "isFromStart" || param1 == 0 && _tween._time == 0)
         {
            _stage.quality = _after;
         }
         else if(_stage.quality != _during)
         {
            _stage.quality = _during;
         }
      }
   }
}

