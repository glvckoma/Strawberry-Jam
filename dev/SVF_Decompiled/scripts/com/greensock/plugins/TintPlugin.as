package com.greensock.plugins
{
   import com.greensock.*;
   import com.greensock.core.*;
   import flash.display.*;
   import flash.geom.ColorTransform;
   import flash.geom.Transform;
   
   public class TintPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected static var _props:Array = ["redMultiplier","greenMultiplier","blueMultiplier","alphaMultiplier","redOffset","greenOffset","blueOffset","alphaOffset"];
      
      protected var _transform:Transform;
      
      public function TintPlugin()
      {
         super("tint,colorTransform,removeTint");
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         if(!(param1 is DisplayObject))
         {
            return false;
         }
         var _loc5_:ColorTransform = new ColorTransform();
         if(param2 != null && param3.vars.removeTint != true)
         {
            _loc5_.color = param2;
         }
         _transform = DisplayObject(param1).transform;
         var _loc4_:ColorTransform = _transform.colorTransform;
         _loc5_.alphaMultiplier = _loc4_.alphaMultiplier;
         _loc5_.alphaOffset = _loc4_.alphaOffset;
         _init(_loc4_,_loc5_);
         return true;
      }
      
      public function _init(param1:ColorTransform, param2:ColorTransform) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = int(_props.length);
         while(true)
         {
            _loc4_--;
            if(_loc4_ <= -1)
            {
               break;
            }
            _loc3_ = _props[_loc4_];
            if(param1[_loc3_] != param2[_loc3_])
            {
               _addTween(param1,_loc3_,param1[_loc3_],param2[_loc3_],"tint");
            }
         }
      }
      
      override public function setRatio(param1:Number) : void
      {
         var _loc2_:ColorTransform = _transform.colorTransform;
         var _loc3_:PropTween = _firstPT;
         while(_loc3_)
         {
            _loc2_[_loc3_.p] = _loc3_.c * param1 + _loc3_.s;
            _loc3_ = _loc3_._next;
         }
         _transform.colorTransform = _loc2_;
      }
   }
}

