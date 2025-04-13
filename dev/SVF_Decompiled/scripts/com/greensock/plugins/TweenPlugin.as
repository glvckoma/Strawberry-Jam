package com.greensock.plugins
{
   import com.greensock.TweenLite;
   import com.greensock.core.PropTween;
   
   public class TweenPlugin
   {
      public static const version:String = "12.1.5";
      
      public static const API:Number = 2;
      
      public var _propName:String;
      
      public var _overwriteProps:Array;
      
      public var _priority:int = 0;
      
      protected var _firstPT:PropTween;
      
      public function TweenPlugin(param1:String = "", param2:int = 0)
      {
         super();
         _overwriteProps = param1.split(",");
         _propName = _overwriteProps[0];
         _priority = param2 || 0;
      }
      
      private static function _onTweenEvent(param1:String, param2:TweenLite) : Boolean
      {
         var _loc7_:Boolean = false;
         var _loc6_:* = null;
         var _loc5_:* = null;
         var _loc3_:PropTween = null;
         var _loc8_:* = null;
         var _loc4_:* = param2._firstPT;
         if(param1 == "_onInitAllProps")
         {
            while(_loc4_)
            {
               _loc3_ = _loc4_._next;
               _loc8_ = _loc6_;
               while(_loc8_ && _loc8_.pr > _loc4_.pr)
               {
                  _loc8_ = _loc8_._next;
               }
               if(_loc4_._prev == _loc8_ ? _loc8_._prev : _loc5_)
               {
                  _loc4_._prev._next = _loc4_;
               }
               else
               {
                  _loc6_ = _loc4_;
               }
               if(_loc4_._next == _loc8_)
               {
                  _loc8_._prev = _loc4_;
               }
               else
               {
                  _loc5_ = _loc4_;
               }
               _loc4_ = _loc3_;
            }
            _loc4_ = param2._firstPT = _loc6_;
         }
         while(_loc4_)
         {
            if(_loc4_.pg)
            {
               if(param1 in _loc4_.t)
               {
                  if(_loc4_.t[param1]())
                  {
                     _loc7_ = true;
                  }
               }
            }
            _loc4_ = _loc4_._next;
         }
         return _loc7_;
      }
      
      public static function activate(param1:Array) : Boolean
      {
         TweenLite._onPluginEvent = TweenPlugin._onTweenEvent;
         var _loc2_:int = int(param1.length);
         while(true)
         {
            _loc2_--;
            if(_loc2_ <= -1)
            {
               break;
            }
            if(param1[_loc2_].API == 2)
            {
               TweenLite._plugins[new (param1[_loc2_] as Class)()._propName] = param1[_loc2_];
            }
         }
         return true;
      }
      
      public function _onInitTween(param1:Object, param2:*, param3:TweenLite) : Boolean
      {
         return false;
      }
      
      protected function _addTween(param1:Object, param2:String, param3:Number, param4:*, param5:String = null, param6:Boolean = false) : PropTween
      {
         if((param4 == null ? 0 : (typeof param4 === "number" || param4.charAt(1) !== "=" ? param4 - param3 : (int(param4.charAt(0) + "1")) * Number(param4.substr(2)))) !== 0)
         {
            _firstPT = new PropTween(param1,param2,param3,0,param5 || param2,false,_firstPT);
            _firstPT.r = param6;
            return _firstPT;
         }
         return null;
      }
      
      public function setRatio(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:PropTween = _firstPT;
         while(_loc3_)
         {
            _loc2_ = _loc3_.c * param1 + _loc3_.s;
            if(_loc3_.r)
            {
               _loc2_ = _loc2_ + (_loc2_ > 0 ? 0.5 : -0.5) | 0;
            }
            if(_loc3_.f)
            {
               _loc3_.t[_loc3_.p](_loc2_);
            }
            else
            {
               _loc3_.t[_loc3_.p] = _loc2_;
            }
            _loc3_ = _loc3_._next;
         }
      }
      
      public function _roundProps(param1:Object, param2:Boolean = true) : void
      {
         var _loc3_:PropTween = _firstPT;
         while(_loc3_)
         {
            if(_propName in param1 || _loc3_.n != null && _loc3_.n.split(_propName + "_").join("") in param1)
            {
               _loc3_.r = param2;
            }
            _loc3_ = _loc3_._next;
         }
      }
      
      public function _kill(param1:Object) : Boolean
      {
         var _loc3_:int = 0;
         if(_propName in param1)
         {
            _overwriteProps = [];
         }
         else
         {
            _loc3_ = int(_overwriteProps.length);
            while(true)
            {
               _loc3_--;
               if(_loc3_ <= -1)
               {
                  break;
               }
               if(_overwriteProps[_loc3_] in param1)
               {
                  _overwriteProps.splice(_loc3_,1);
               }
            }
         }
         var _loc2_:PropTween = _firstPT;
         while(_loc2_)
         {
            if(_loc2_.n in param1)
            {
               if(_loc2_._next)
               {
                  _loc2_._next._prev = _loc2_._prev;
               }
               if(_loc2_._prev)
               {
                  _loc2_._prev._next = _loc2_._next;
                  _loc2_._prev = null;
               }
               else if(_firstPT == _loc2_)
               {
                  _firstPT = _loc2_._next;
               }
            }
            _loc2_ = _loc2_._next;
         }
         return false;
      }
   }
}

