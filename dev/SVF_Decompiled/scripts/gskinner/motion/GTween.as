package gskinner.motion
{
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class GTween extends EventDispatcher
   {
      public static var version:Number = 2.01;
      
      public static var defaultDispatchEvents:Boolean = false;
      
      public static var pauseAll:Boolean = false;
      
      public static var timeScaleAll:Number = 1;
      
      protected static var hasStarPlugins:Boolean = false;
      
      protected static var shape:Shape;
      
      protected static var time:Number;
      
      protected static var numItemsInTickList:int;
      
      public static var defaultEase:Function = linearEase;
      
      protected static var plugins:Object = {};
      
      protected static var tickList:Dictionary = new Dictionary(true);
      
      protected static var gcLockList:Dictionary = new Dictionary(false);
      
      staticInit();
      
      protected var _delay:Number = 0;
      
      protected var _values:Object;
      
      protected var _paused:Boolean = true;
      
      protected var _position:Number;
      
      protected var _inited:Boolean;
      
      protected var _initValues:Object;
      
      protected var _rangeValues:Object;
      
      protected var _proxy:TargetProxy;
      
      public var autoPlay:Boolean = true;
      
      public var data:*;
      
      public var duration:Number;
      
      public var ease:Function;
      
      public var nextTween:GTween;
      
      public var pluginData:Object;
      
      public var reflect:Boolean;
      
      public var repeatCount:int = 1;
      
      public var target:Object;
      
      public var useFrames:Boolean;
      
      public var timeScale:Number = 1;
      
      public var positionOld:Number;
      
      public var ratio:Number;
      
      public var ratioOld:Number;
      
      public var calculatedPosition:Number;
      
      public var calculatedPositionOld:Number;
      
      public var suppressEvents:Boolean;
      
      public var dispatchEvents:Boolean;
      
      public var onComplete:Function;
      
      public var onChange:Function;
      
      public var onInit:Function;
      
      public function GTween(param1:Object = null, param2:Number = 1, param3:Object = null, param4:Object = null, param5:Object = null)
      {
         var _loc6_:Boolean = false;
         super();
         ease = defaultEase;
         dispatchEvents = defaultDispatchEvents;
         this.target = param1;
         this.duration = param2;
         this.pluginData = copy(param5,{});
         if(param4)
         {
            _loc6_ = Boolean(param4.swapValues);
            delete param4.swapValues;
         }
         copy(param4,this);
         resetValues(param3);
         if(_loc6_)
         {
            swapValues();
         }
         if(this.duration == 0 && delay == 0 && autoPlay)
         {
            position = 0;
         }
      }
      
      public static function installPlugin(param1:Object, param2:Array, param3:Boolean = false) : void
      {
         var _loc5_:* = 0;
         var _loc4_:String = null;
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = param2[_loc5_];
            if(_loc4_ == "*")
            {
               hasStarPlugins = true;
            }
            if(plugins[_loc4_] == null)
            {
               plugins[_loc4_] = [param1];
            }
            else if(param3)
            {
               plugins[_loc4_].unshift(param1);
            }
            else
            {
               plugins[_loc4_].push(param1);
            }
            _loc5_++;
         }
      }
      
      public static function linearEase(param1:Number, param2:Number, param3:Number, param4:Number) : Number
      {
         return param1;
      }
      
      protected static function staticInit() : void
      {
         (shape = new Shape()).addEventListener("enterFrame",staticTick);
         time = getTimer() / 1000;
      }
      
      protected static function staticTick(param1:Event) : void
      {
         var _loc3_:GTween = null;
         var _loc4_:Number = time;
         if(pauseAll || numItemsInTickList <= 0)
         {
            return;
         }
         time = getTimer() / 1000;
         var _loc2_:Number = (time - _loc4_) * timeScaleAll;
         for(var _loc5_ in tickList)
         {
            _loc3_ = _loc5_ as GTween;
            _loc3_.position = _loc3_._position + (_loc3_.useFrames ? timeScaleAll : _loc2_) * _loc3_.timeScale;
         }
      }
      
      public function get paused() : Boolean
      {
         return _paused;
      }
      
      public function set paused(param1:Boolean) : void
      {
         if(param1 == _paused)
         {
            return;
         }
         _paused = param1;
         if(_paused)
         {
            numItemsInTickList--;
            delete tickList[this];
            if(target is IEventDispatcher)
            {
               target.removeEventListener("_",invalidate);
            }
            delete gcLockList[this];
         }
         else
         {
            time = getTimer() / 1000;
            if(isNaN(_position) || repeatCount != 0 && _position >= repeatCount * duration)
            {
               _inited = false;
               calculatedPosition = calculatedPositionOld = ratio = ratioOld = positionOld = 0;
               _position = -delay;
            }
            numItemsInTickList++;
            tickList[this] = true;
            if(target is IEventDispatcher)
            {
               target.addEventListener("_",invalidate);
            }
            else
            {
               gcLockList[this] = true;
            }
         }
      }
      
      public function get position() : Number
      {
         return _position;
      }
      
      public function set position(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:Array = null;
         var _loc9_:* = 0;
         var _loc7_:* = 0;
         positionOld = _position;
         ratioOld = ratio;
         calculatedPositionOld = calculatedPosition;
         var _loc6_:Number = repeatCount * duration;
         var _loc8_:Boolean = param1 >= _loc6_ && repeatCount > 0;
         if(_loc8_)
         {
            if(calculatedPositionOld == _loc6_)
            {
               return;
            }
            _position = _loc6_;
            calculatedPosition = reflect && !(repeatCount & 1) ? 0 : duration;
         }
         else
         {
            _position = param1;
            calculatedPosition = _position < 0 ? 0 : _position % duration;
            if(reflect && _position / duration & 1)
            {
               calculatedPosition = duration - calculatedPosition;
            }
         }
         ratio = duration == 0 && _position >= 0 ? 1 : ease(calculatedPosition / duration,0,1,1);
         if(target && (_position >= 0 || positionOld >= 0) && calculatedPosition != calculatedPositionOld)
         {
            if(!_inited)
            {
               init();
            }
            for(var _loc10_ in _values)
            {
               _loc2_ = Number(_initValues[_loc10_]);
               _loc4_ = Number(_rangeValues[_loc10_]);
               _loc3_ = _loc2_ + _loc4_ * ratio;
               _loc5_ = plugins[_loc10_];
               if(_loc5_)
               {
                  _loc9_ = _loc5_.length;
                  _loc7_ = 0;
                  while(_loc7_ < _loc9_)
                  {
                     _loc3_ = Number(_loc5_[_loc7_].tween(this,_loc10_,_loc3_,_loc2_,_loc4_,ratio,_loc8_));
                     _loc7_++;
                  }
                  if(!isNaN(_loc3_))
                  {
                     target[_loc10_] = _loc3_;
                  }
               }
               else
               {
                  target[_loc10_] = _loc3_;
               }
            }
         }
         if(hasStarPlugins)
         {
            _loc5_ = plugins["*"];
            _loc9_ = _loc5_.length;
            _loc7_ = 0;
            while(_loc7_ < _loc9_)
            {
               _loc5_[_loc7_].tween(this,"*",NaN,NaN,NaN,ratio,_loc8_);
               _loc7_++;
            }
         }
         if(!suppressEvents)
         {
            if(dispatchEvents)
            {
               dispatchEvt("change");
            }
            if(onChange != null)
            {
               onChange(this);
            }
         }
         if(_loc8_)
         {
            paused = true;
            if(nextTween)
            {
               nextTween.paused = false;
            }
            if(!suppressEvents)
            {
               if(dispatchEvents)
               {
                  dispatchEvt("complete");
               }
               if(onComplete != null)
               {
                  onComplete(this);
               }
            }
         }
      }
      
      public function get delay() : Number
      {
         return _delay;
      }
      
      public function set delay(param1:Number) : void
      {
         if(_position <= 0)
         {
            _position = -param1;
         }
         _delay = param1;
      }
      
      public function get proxy() : TargetProxy
      {
         if(_proxy == null)
         {
            _proxy = new TargetProxy(this);
         }
         return _proxy;
      }
      
      public function setValue(param1:String, param2:Number) : void
      {
         _values[param1] = param2;
         invalidate();
      }
      
      public function getValue(param1:String) : Number
      {
         return _values[param1];
      }
      
      public function deleteValue(param1:String) : Boolean
      {
         delete _rangeValues[param1];
         delete _initValues[param1];
         return delete _values[param1];
      }
      
      public function setValues(param1:Object) : void
      {
         copy(param1,_values,true);
         invalidate();
      }
      
      public function resetValues(param1:Object = null) : void
      {
         _values = {};
         setValues(param1);
      }
      
      public function getValues() : Object
      {
         return copy(_values,{});
      }
      
      public function getInitValue(param1:String) : Number
      {
         return _initValues[param1];
      }
      
      public function swapValues() : void
      {
         var _loc1_:Number = NaN;
         if(!_inited)
         {
            init();
         }
         var _loc3_:Object = _values;
         _values = _initValues;
         _initValues = _loc3_;
         for(var _loc2_ in _rangeValues)
         {
            _rangeValues[_loc2_] *= -1;
         }
         if(_position < 0)
         {
            _loc1_ = positionOld;
            position = 0;
            _position = positionOld;
            positionOld = _loc1_;
         }
         else
         {
            position = _position;
         }
      }
      
      public function init() : void
      {
         var _loc1_:Array = null;
         var _loc3_:* = 0;
         var _loc4_:Number = NaN;
         var _loc2_:* = 0;
         _inited = true;
         _initValues = {};
         _rangeValues = {};
         for(var _loc5_ in _values)
         {
            if(plugins[_loc5_])
            {
               _loc1_ = plugins[_loc5_];
               _loc3_ = _loc1_.length;
               _loc4_ = Number(_loc5_ in target ? target[_loc5_] : NaN);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  _loc4_ = Number(_loc1_[_loc2_].init(this,_loc5_,_loc4_));
                  _loc2_++;
               }
               if(!isNaN(_loc4_))
               {
                  _rangeValues[_loc5_] = _values[_loc5_] - (_initValues[_loc5_] = _loc4_);
               }
            }
            else
            {
               _rangeValues[_loc5_] = _values[_loc5_] - (_initValues[_loc5_] = target[_loc5_]);
            }
         }
         if(hasStarPlugins)
         {
            _loc1_ = plugins["*"];
            _loc3_ = _loc1_.length;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc1_[_loc2_].init(this,"*",NaN);
               _loc2_++;
            }
         }
         if(!suppressEvents)
         {
            if(dispatchEvents)
            {
               dispatchEvt("init");
            }
            if(onInit != null)
            {
               onInit(this);
            }
         }
      }
      
      public function beginning() : void
      {
         position = 0;
         paused = true;
      }
      
      public function end() : void
      {
         position = repeatCount > 0 ? repeatCount * duration : duration;
      }
      
      protected function invalidate() : void
      {
         _inited = false;
         if(_position > 0)
         {
            _position = 0;
         }
         if(autoPlay)
         {
            paused = false;
         }
      }
      
      protected function copy(param1:Object, param2:Object, param3:Boolean = false) : Object
      {
         for(var _loc4_ in param1)
         {
            if(param3 && param1[_loc4_] == null)
            {
               delete param2[_loc4_];
            }
            else
            {
               param2[_loc4_] = param1[_loc4_];
            }
         }
         return param2;
      }
      
      protected function dispatchEvt(param1:String) : void
      {
         if(hasEventListener(param1))
         {
            dispatchEvent(new Event(param1));
         }
      }
   }
}

import flash.utils.Proxy;
import flash.utils.flash_proxy;

use namespace flash_proxy;

dynamic class TargetProxy extends Proxy
{
   private var tween:GTween;
   
   public function TargetProxy(param1:GTween)
   {
      super();
      this.tween = param1;
   }
   
   override flash_proxy function callProperty(param1:*, ... rest) : *
   {
      return tween.target[param1].apply(null,rest);
   }
   
   override flash_proxy function getProperty(param1:*) : *
   {
      var _loc2_:Number = Number(tween.getValue(param1));
      return isNaN(_loc2_) ? tween.target[param1] : _loc2_;
   }
   
   override flash_proxy function setProperty(param1:*, param2:*) : void
   {
      if(param2 is Boolean || param2 is String || isNaN(param2))
      {
         tween.target[param1] = param2;
      }
      else
      {
         tween.setValue(param1,param2);
      }
   }
   
   override flash_proxy function deleteProperty(param1:*) : Boolean
   {
      tween.deleteValue(param1);
      return true;
   }
}
