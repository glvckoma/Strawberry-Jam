package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import com.greensock.core.PropTween;
   
   public class RoundPropsPlugin extends TweenPlugin
   {
      public static const API:Number = 2;
      
      protected var _tween:TweenLite;
      
      public function RoundPropsPlugin()
      {
         super("roundProps",-1);
         _overwriteProps.length = 0;
      }
      
      override public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         _tween = param3;
         return true;
      }
      
      public function _onInitAllProps() : Boolean
      {
         var _loc5_:String = null;
         var _loc3_:* = null;
         var _loc1_:PropTween = null;
         var _loc7_:Array = null;
         _loc7_ = _tween.vars.roundProps is Array ? _tween.vars.roundProps : _tween.vars.roundProps.split(",");
         var _loc6_:int = int(_loc7_.length);
         var _loc2_:Object = {};
         var _loc4_:PropTween = _tween._propLookup.roundProps;
         while(true)
         {
            _loc6_--;
            if(_loc6_ <= -1)
            {
               break;
            }
            _loc2_[_loc7_[_loc6_]] = 1;
         }
         _loc6_ = int(_loc7_.length);
         while(true)
         {
            _loc6_--;
            if(_loc6_ <= -1)
            {
               break;
            }
            _loc5_ = _loc7_[_loc6_];
            _loc3_ = _tween._firstPT;
            while(_loc3_)
            {
               _loc1_ = _loc3_._next;
               if(_loc3_.pg)
               {
                  _loc3_.t._roundProps(_loc2_,true);
               }
               else if(_loc3_.n == _loc5_)
               {
                  _add(_loc3_.t,_loc5_,_loc3_.s,_loc3_.c);
                  if(_loc1_)
                  {
                     _loc1_._prev = _loc3_._prev;
                  }
                  if(_loc3_._prev)
                  {
                     _loc3_._prev._next = _loc1_;
                  }
                  else if(_tween._firstPT == _loc3_)
                  {
                     _tween._firstPT = _loc1_;
                  }
                  _loc3_._prev = null;
                  _loc3_._next = null;
                  _tween._propLookup[_loc5_] = _loc4_;
               }
               _loc3_ = _loc1_;
            }
         }
         return false;
      }
      
      public function _add(param1:Object, param2:String, param3:Number, param4:Number) : void
      {
         _addTween(param1,param2,param3,param3 + param4,param2,true);
         _overwriteProps[_overwriteProps.length] = param2;
      }
   }
}

