package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import flash.display.MovieClip;
   
   public class FrameLabelPlugin extends FramePlugin
   {
      public static const API:Number = 2;
      
      public function FrameLabelPlugin()
      {
         super();
         _propName = "frameLabel";
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!param3.target is MovieClip)
         {
            return false;
         }
         _target = param1 as MovieClip;
         this.frame = _target.currentFrame;
         var _loc7_:Array = _target.currentLabels;
         var _loc6_:String = param2;
         var _loc5_:int = _target.currentFrame;
         var _loc4_:int = int(_loc7_.length);
         while(true)
         {
            _loc4_--;
            if(_loc4_ <= -1)
            {
               break;
            }
            if(_loc7_[_loc4_].name == _loc6_)
            {
               _loc5_ = int(_loc7_[_loc4_].frame);
               break;
            }
         }
         if(this.frame != _loc5_)
         {
            _addTween(this,"frame",this.frame,_loc5_,"frame",true);
         }
         return true;
      }
   }
}

