package com.greensock
{
   import com.greensock.core.Animation;
   import com.greensock.core.PropTween;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.events.TweenEvent;
   import com.greensock.plugins.AutoAlphaPlugin;
   import com.greensock.plugins.BevelFilterPlugin;
   import com.greensock.plugins.BezierPlugin;
   import com.greensock.plugins.BezierThroughPlugin;
   import com.greensock.plugins.BlurFilterPlugin;
   import com.greensock.plugins.ColorMatrixFilterPlugin;
   import com.greensock.plugins.ColorTransformPlugin;
   import com.greensock.plugins.DropShadowFilterPlugin;
   import com.greensock.plugins.EndArrayPlugin;
   import com.greensock.plugins.FrameLabelPlugin;
   import com.greensock.plugins.FramePlugin;
   import com.greensock.plugins.GlowFilterPlugin;
   import com.greensock.plugins.HexColorsPlugin;
   import com.greensock.plugins.RemoveTintPlugin;
   import com.greensock.plugins.RoundPropsPlugin;
   import com.greensock.plugins.ShortRotationPlugin;
   import com.greensock.plugins.TintPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.greensock.plugins.VisiblePlugin;
   import com.greensock.plugins.VolumePlugin;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.getTimer;
   
   public class TweenMax extends TweenLite implements IEventDispatcher
   {
      public static const version:String = "12.1.5";
      
      protected static var _listenerLookup:Object = {
         "onCompleteListener":"complete",
         "onUpdateListener":"change",
         "onStartListener":"start",
         "onRepeatListener":"repeat",
         "onReverseCompleteListener":"reverseComplete"
      };
      
      public static var ticker:Shape = Animation.ticker;
      
      public static var allTo:Function = staggerTo;
      
      public static var allFrom:Function = staggerFrom;
      
      public static var allFromTo:Function = staggerFromTo;
      
      TweenPlugin.activate([AutoAlphaPlugin,EndArrayPlugin,FramePlugin,RemoveTintPlugin,TintPlugin,VisiblePlugin,VolumePlugin,BevelFilterPlugin,BezierPlugin,BezierThroughPlugin,BlurFilterPlugin,ColorMatrixFilterPlugin,ColorTransformPlugin,DropShadowFilterPlugin,FrameLabelPlugin,GlowFilterPlugin,HexColorsPlugin,RoundPropsPlugin,ShortRotationPlugin]);
      
      protected var _dispatcher:EventDispatcher;
      
      protected var _hasUpdateListener:Boolean;
      
      protected var _repeat:int = 0;
      
      protected var _repeatDelay:Number = 0;
      
      protected var _cycle:int = 0;
      
      public var _yoyo:Boolean;
      
      public function TweenMax(param1:Object, param2:Number, param3:Object)
      {
         super(param1,param2,param3);
         _yoyo = this.vars.yoyo == true;
         _repeat = int(this.vars.repeat);
         _repeatDelay = this.vars.repeatDelay || 0;
         _dirty = true;
         if(this.vars.onCompleteListener || this.vars.onUpdateListener || this.vars.onStartListener || this.vars.onRepeatListener || this.vars.onReverseCompleteListener)
         {
            _initDispatcher();
            if(_duration == 0)
            {
               if(_delay == 0)
               {
                  if(this.vars.immediateRender)
                  {
                     _dispatcher.dispatchEvent(new TweenEvent("change"));
                     _dispatcher.dispatchEvent(new TweenEvent("complete"));
                  }
               }
            }
         }
      }
      
      public static function killTweensOf(param1:*, param2:* = false, param3:Object = null) : void
      {
         TweenLite.killTweensOf(param1,param2,param3);
      }
      
      public static function killDelayedCallsTo(param1:Function) : void
      {
         TweenLite.killTweensOf(param1);
      }
      
      public static function getTweensOf(param1:*, param2:Boolean = false) : Array
      {
         return TweenLite.getTweensOf(param1,param2);
      }
      
      public static function to(param1:Object, param2:Number, param3:Object) : TweenMax
      {
         return new TweenMax(param1,param2,param3);
      }
      
      public static function from(param1:Object, param2:Number, param3:Object) : TweenMax
      {
         param3 = _prepVars(param3,true);
         param3.runBackwards = true;
         return new TweenMax(param1,param2,param3);
      }
      
      public static function fromTo(param1:Object, param2:Number, param3:Object, param4:Object) : TweenMax
      {
         param4 = _prepVars(param4,false);
         param3 = _prepVars(param3,false);
         param4.startAt = param3;
         param4.immediateRender = param4.immediateRender != false && param3.immediateRender != false;
         return new TweenMax(param1,param2,param4);
      }
      
      public static function staggerTo(param1:Array, param2:Number, param3:Object, param4:Number = 0, param5:Function = null, param6:Array = null) : Array
      {
         var copy:Object;
         var p:String;
         var targets:Array = param1;
         var duration:Number = param2;
         var vars:Object = param3;
         var stagger:Number = param4;
         var onCompleteAll:Function = param5;
         var onCompleteAllParams:Array = param6;
         vars = _prepVars(vars,false);
         var a:Array = [];
         var l:int = int(targets.length);
         var delay:Number = Number(vars.delay || 0);
         var i:int = 0;
         while(i < l)
         {
            copy = {};
            for(p in vars)
            {
               copy[p] = vars[p];
            }
            copy.delay = delay;
            if(i == l - 1)
            {
               if(onCompleteAll != null)
               {
                  copy.onComplete = function():void
                  {
                     if(vars.onComplete)
                     {
                        vars.onComplete.apply(null,arguments);
                     }
                     onCompleteAll.apply(null,onCompleteAllParams);
                  };
               }
            }
            a[i] = new TweenMax(targets[i],duration,copy);
            delay += stagger;
            i++;
         }
         return a;
      }
      
      public static function staggerFrom(param1:Array, param2:Number, param3:Object, param4:Number = 0, param5:Function = null, param6:Array = null) : Array
      {
         param3 = _prepVars(param3,true);
         param3.runBackwards = true;
         if(param3.immediateRender != false)
         {
            param3.immediateRender = true;
         }
         return staggerTo(param1,param2,param3,param4,param5,param6);
      }
      
      public static function staggerFromTo(param1:Array, param2:Number, param3:Object, param4:Object, param5:Number = 0, param6:Function = null, param7:Array = null) : Array
      {
         param4 = _prepVars(param4,false);
         param3 = _prepVars(param3,false);
         param4.startAt = param3;
         param4.immediateRender = param4.immediateRender != false && param3.immediateRender != false;
         return staggerTo(param1,param2,param4,param5,param6,param7);
      }
      
      public static function delayedCall(param1:Number, param2:Function, param3:Array = null, param4:Boolean = false) : TweenMax
      {
         return new TweenMax(param2,0,{
            "delay":param1,
            "onComplete":param2,
            "onCompleteParams":param3,
            "onReverseComplete":param2,
            "onReverseCompleteParams":param3,
            "immediateRender":false,
            "useFrames":param4,
            "overwrite":0
         });
      }
      
      public static function set(param1:Object, param2:Object) : TweenMax
      {
         return new TweenMax(param1,0,param2);
      }
      
      public static function isTweening(param1:Object) : Boolean
      {
         return TweenLite.getTweensOf(param1,true).length > 0;
      }
      
      public static function getAllTweens(param1:Boolean = false) : Array
      {
         var _loc2_:Array = _getChildrenOf(_rootTimeline,param1);
         return _loc2_.concat(_getChildrenOf(_rootFramesTimeline,param1));
      }
      
      protected static function _getChildrenOf(param1:SimpleTimeline, param2:Boolean) : Array
      {
         if(param1 == null)
         {
            return [];
         }
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         var _loc3_:Animation = param1._first;
         while(_loc3_)
         {
            if(_loc3_ is TweenLite)
            {
               _loc4_[_loc5_++] = _loc3_;
            }
            else
            {
               if(param2)
               {
                  _loc4_[_loc5_++] = _loc3_;
               }
               _loc4_ = _loc4_.concat(_getChildrenOf(SimpleTimeline(_loc3_),param2));
               _loc5_ = int(_loc4_.length);
            }
            _loc3_ = _loc3_._next;
         }
         return _loc4_;
      }
      
      public static function killAll(param1:Boolean = false, param2:Boolean = true, param3:Boolean = true, param4:Boolean = true) : void
      {
         var _loc6_:Animation = null;
         var _loc8_:int = 0;
         var _loc5_:Array = null;
         _loc5_ = getAllTweens(param4);
         var _loc9_:int = int(_loc5_.length);
         var _loc10_:Boolean = param2 && param3 && param4;
         _loc8_ = 0;
         while(_loc8_ < _loc9_)
         {
            _loc6_ = _loc5_[_loc8_];
            if(_loc10_ || _loc6_ is SimpleTimeline || false == (TweenLite(_loc6_).target == TweenLite(_loc6_).vars.onComplete) && param3 || param2)
            {
               if(param1)
               {
                  _loc6_.totalTime(_loc6_._reversed ? 0 : _loc6_.totalDuration());
               }
               else
               {
                  _loc6_._enabled(false,false);
               }
            }
            _loc8_++;
         }
      }
      
      public static function killChildTweensOf(param1:DisplayObjectContainer, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Array = null;
         _loc3_ = getAllTweens(false);
         var _loc5_:int = int(_loc3_.length);
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            if(_containsChildOf(param1,_loc3_[_loc4_].target))
            {
               if(param2)
               {
                  _loc3_[_loc4_].totalTime(_loc3_[_loc4_].totalDuration());
               }
               else
               {
                  _loc3_[_loc4_]._enabled(false,false);
               }
            }
            _loc4_++;
         }
      }
      
      private static function _containsChildOf(param1:DisplayObjectContainer, param2:Object) : Boolean
      {
         var _loc4_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         if(param2 is Array)
         {
            _loc3_ = int(param2.length);
            while(true)
            {
               _loc3_--;
               if(_loc3_ <= -1)
               {
                  break;
               }
               if(_containsChildOf(param1,param2[_loc3_]))
               {
                  return true;
               }
            }
         }
         else if(param2 is DisplayObject)
         {
            _loc4_ = param2.parent;
            while(_loc4_)
            {
               if(_loc4_ == param1)
               {
                  return true;
               }
               _loc4_ = _loc4_.parent;
            }
         }
         return false;
      }
      
      public static function pauseAll(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true) : void
      {
         _changePause(true,param1,param2,param3);
      }
      
      public static function resumeAll(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true) : void
      {
         _changePause(false,param1,param2,param3);
      }
      
      private static function _changePause(param1:Boolean, param2:Boolean = true, param3:Boolean = false, param4:Boolean = true) : void
      {
         var _loc7_:Boolean = false;
         var _loc5_:Animation = null;
         var _loc6_:Array = null;
         _loc6_ = getAllTweens(param4);
         var _loc9_:Boolean = param2 && param3 && param4;
         var _loc8_:int = int(_loc6_.length);
         while(true)
         {
            _loc8_--;
            if(_loc8_ <= -1)
            {
               break;
            }
            _loc5_ = _loc6_[_loc8_];
            _loc7_ = _loc5_ is TweenLite && TweenLite(_loc5_).target == _loc5_.vars.onComplete;
            if(_loc9_ || _loc5_ is SimpleTimeline || _loc7_ && param3 || param2 && !_loc7_)
            {
               _loc5_.paused(param1);
            }
         }
      }
      
      public static function globalTimeScale(param1:Number = NaN) : Number
      {
         if(!arguments.length)
         {
            return _rootTimeline == null ? 1 : _rootTimeline._timeScale;
         }
         param1 ||= 0.0001;
         if(_rootTimeline == null)
         {
            TweenLite.to({},0,{});
         }
         var _loc4_:SimpleTimeline = _rootTimeline;
         var _loc3_:Number = getTimer() / 1000;
         _loc4_._startTime = _loc3_ - (_loc3_ - _loc4_._startTime) * _loc4_._timeScale / param1;
         _loc4_ = _rootFramesTimeline;
         _loc3_ = _rootFrame;
         _loc4_._startTime = _loc3_ - (_loc3_ - _loc4_._startTime) * _loc4_._timeScale / param1;
         _rootFramesTimeline._timeScale = _rootTimeline._timeScale = param1;
         return param1;
      }
      
      override public function invalidate() : *
      {
         _yoyo = this.vars.yoyo == true;
         _repeat = this.vars.repeat || 0;
         _repeatDelay = this.vars.repeatDelay || 0;
         _hasUpdateListener = false;
         _initDispatcher();
         _uncache(true);
         return super.invalidate();
      }
      
      public function updateTo(param1:Object, param2:Boolean = false) : *
      {
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc8_:Number = ratio;
         if(param2)
         {
            if(_startTime < _timeline._time)
            {
               _startTime = _timeline._time;
               _uncache(false);
               if(_gc)
               {
                  _enabled(true,false);
               }
               else
               {
                  _timeline.insert(this,_startTime - _delay);
               }
            }
         }
         for(var _loc3_ in param1)
         {
            this.vars[_loc3_] = param1[_loc3_];
         }
         if(_initted)
         {
            if(param2)
            {
               _initted = false;
            }
            else
            {
               if(_gc)
               {
                  _enabled(true,false);
               }
               if(_notifyPluginsOfEnabled)
               {
                  if(_firstPT != null)
                  {
                     _onPluginEvent("_onDisable",this);
                  }
               }
               if(_time / _duration > 0.998)
               {
                  _loc7_ = _time;
                  render(0,true,false);
                  _initted = false;
                  render(_loc7_,true,false);
               }
               else if(_time > 0)
               {
                  _initted = false;
                  _init();
                  _loc4_ = 1 / (1 - _loc8_);
                  var _loc5_:PropTween = _firstPT;
                  while(_loc5_)
                  {
                     _loc6_ = _loc5_.s + _loc5_.c;
                     _loc5_.c *= _loc4_;
                     _loc5_.s = _loc6_ - _loc5_.c;
                     _loc5_ = _loc5_._next;
                  }
               }
            }
         }
         return this;
      }
      
      override public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var _loc15_:Boolean = false;
         var _loc13_:String = null;
         var _loc5_:PropTween = null;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         if(!_initted)
         {
            if(_duration === 0 && vars.repeat)
            {
               invalidate();
            }
         }
         var _loc7_:Number = Number(!_dirty ? _totalDuration : totalDuration());
         var _loc6_:Number = _time;
         var _loc9_:Number = _totalTime;
         var _loc4_:Number = _cycle;
         if(param1 >= _loc7_)
         {
            _totalTime = _loc7_;
            _cycle = _repeat;
            if(_yoyo && (_cycle & 1) != 0)
            {
               _time = 0;
               ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
            }
            else
            {
               _time = _duration;
               ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
            }
            if(!_reversed)
            {
               _loc15_ = true;
               _loc13_ = "onComplete";
            }
            if(_duration == 0)
            {
               _loc12_ = _rawPrevTime;
               if(_startTime === _timeline._duration)
               {
                  param1 = 0;
               }
               if(param1 === 0 || _loc12_ < 0 || _loc12_ === _tinyNum)
               {
                  if(_loc12_ !== param1)
                  {
                     param3 = true;
                     if(_loc12_ > _tinyNum)
                     {
                        _loc13_ = "onReverseComplete";
                     }
                  }
               }
               _rawPrevTime = _loc12_ = !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
            }
         }
         else if(param1 < 1e-7)
         {
            _totalTime = _time = _cycle = 0;
            ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
            if(_loc9_ !== 0 || _duration === 0 && _rawPrevTime > 0 && _rawPrevTime !== _tinyNum)
            {
               _loc13_ = "onReverseComplete";
               _loc15_ = _reversed;
            }
            if(param1 < 0)
            {
               _active = false;
               if(_duration == 0)
               {
                  if(_rawPrevTime >= 0)
                  {
                     param3 = true;
                  }
                  _rawPrevTime = _loc12_ = !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
               }
            }
            else if(!_initted)
            {
               param3 = true;
            }
         }
         else
         {
            _totalTime = _time = param1;
            if(_repeat != 0)
            {
               _loc11_ = _duration + _repeatDelay;
               _cycle = _totalTime / _loc11_ >> 0;
               if(_cycle !== 0)
               {
                  if(_cycle === _totalTime / _loc11_)
                  {
                     _cycle--;
                  }
               }
               _time = _totalTime - _cycle * _loc11_;
               if(_yoyo)
               {
                  if((_cycle & 1) != 0)
                  {
                     _time = _duration - _time;
                  }
               }
               if(_time > _duration)
               {
                  _time = _duration;
               }
               else if(_time < 0)
               {
                  _time = 0;
               }
            }
            if(_easeType)
            {
               _loc10_ = _time / _duration;
               var _loc8_:int = _easeType;
               var _loc14_:int = _easePower;
               if(_loc8_ == 1 || _loc8_ == 3 && _loc10_ >= 0.5)
               {
                  _loc10_ = 1 - _loc10_;
               }
               if(_loc8_ == 3)
               {
                  _loc10_ *= 2;
               }
               if(_loc14_ == 1)
               {
                  _loc10_ *= _loc10_;
               }
               else if(_loc14_ == 2)
               {
                  _loc10_ *= _loc10_ * _loc10_;
               }
               else if(_loc14_ == 3)
               {
                  _loc10_ *= _loc10_ * _loc10_ * _loc10_;
               }
               else if(_loc14_ == 4)
               {
                  _loc10_ *= _loc10_ * _loc10_ * _loc10_ * _loc10_;
               }
               if(_loc8_ == 1)
               {
                  ratio = 1 - _loc10_;
               }
               else if(_loc8_ == 2)
               {
                  ratio = _loc10_;
               }
               else if(_time / _duration < 0.5)
               {
                  ratio = _loc10_ / 2;
               }
               else
               {
                  ratio = 1 - _loc10_ / 2;
               }
            }
            else
            {
               ratio = _ease.getRatio(_time / _duration);
            }
         }
         if(_loc6_ == _time && !param3 && _cycle === _loc4_)
         {
            if(_loc9_ !== _totalTime)
            {
               if(_onUpdate != null)
               {
                  if(!param2)
                  {
                     _onUpdate.apply(vars.onUpdateScope || this,vars.onUpdateParams);
                  }
               }
            }
            return false;
         }
         if(!_initted)
         {
            _init();
            if(!_initted || _gc)
            {
               return false;
            }
            if(_time && !_loc15_)
            {
               ratio = _ease.getRatio(_time / _duration);
            }
            else if(_loc15_ && _ease._calcEnd)
            {
               ratio = _ease.getRatio(_time === 0 ? 0 : 1);
            }
         }
         if(!_active)
         {
            if(!_paused && _time !== _loc6_ && param1 >= 0)
            {
               _active = true;
            }
         }
         if(_loc9_ == 0)
         {
            if(_startAt != null)
            {
               if(param1 >= 0)
               {
                  _startAt.render(param1,param2,param3);
               }
               else if(!_loc13_)
               {
                  _loc13_ = "_dummyGS";
               }
            }
            if(_totalTime != 0 || _duration == 0)
            {
               if(!param2)
               {
                  if(vars.onStart)
                  {
                     vars.onStart.apply(null,vars.onStartParams);
                  }
                  if(_dispatcher)
                  {
                     _dispatcher.dispatchEvent(new TweenEvent("start"));
                  }
               }
            }
         }
         _loc5_ = _firstPT;
         while(_loc5_)
         {
            if(_loc5_.f)
            {
               _loc5_.t[_loc5_.p](_loc5_.c * ratio + _loc5_.s);
            }
            else
            {
               _loc5_.t[_loc5_.p] = _loc5_.c * ratio + _loc5_.s;
            }
            _loc5_ = _loc5_._next;
         }
         if(_onUpdate != null)
         {
            if(param1 < 0 && _startAt != null && _startTime != 0)
            {
               _startAt.render(param1,param2,param3);
            }
            if(!param2)
            {
               if(_totalTime !== _loc9_ || _loc15_)
               {
                  _onUpdate.apply(null,vars.onUpdateParams);
               }
            }
         }
         if(_hasUpdateListener)
         {
            if(param1 < 0 && _startAt != null && _onUpdate == null && _startTime != 0)
            {
               _startAt.render(param1,param2,param3);
            }
            if(!param2)
            {
               _dispatcher.dispatchEvent(new TweenEvent("change"));
            }
         }
         if(_cycle != _loc4_)
         {
            if(!param2)
            {
               if(!_gc)
               {
                  if(vars.onRepeat)
                  {
                     vars.onRepeat.apply(null,vars.onRepeatParams);
                  }
                  if(_dispatcher)
                  {
                     _dispatcher.dispatchEvent(new TweenEvent("repeat"));
                  }
               }
            }
         }
         if(_loc13_)
         {
            if(!_gc)
            {
               if(param1 < 0 && _startAt != null && _onUpdate == null && !_hasUpdateListener && _startTime != 0)
               {
                  _startAt.render(param1,param2,true);
               }
               if(_loc15_)
               {
                  if(_timeline.autoRemoveChildren)
                  {
                     _enabled(false,false);
                  }
                  _active = false;
               }
               if(!param2)
               {
                  if(vars[_loc13_])
                  {
                     vars[_loc13_].apply(null,vars[_loc13_ + "Params"]);
                  }
                  if(_dispatcher)
                  {
                     _dispatcher.dispatchEvent(new TweenEvent(_loc13_ == "onComplete" ? "complete" : "reverseComplete"));
                  }
               }
               if(_duration === 0 && _rawPrevTime === _tinyNum && _loc12_ !== _tinyNum)
               {
                  _rawPrevTime = 0;
               }
            }
         }
         return true;
      }
      
      protected function _initDispatcher() : Boolean
      {
         var _loc1_:String = null;
         var _loc2_:Boolean = false;
         for(_loc1_ in _listenerLookup)
         {
            if(_loc1_ in vars)
            {
               if(vars[_loc1_] is Function)
               {
                  if(_dispatcher == null)
                  {
                     _dispatcher = new EventDispatcher(this);
                  }
                  _dispatcher.addEventListener(_listenerLookup[_loc1_],vars[_loc1_],false,0,true);
                  _loc2_ = true;
               }
            }
         }
         return _loc2_;
      }
      
      public function addEventListener(param1:String, param2:Function, param3:Boolean = false, param4:int = 0, param5:Boolean = false) : void
      {
         if(_dispatcher == null)
         {
            _dispatcher = new EventDispatcher(this);
         }
         if(param1 == "change")
         {
            _hasUpdateListener = true;
         }
         _dispatcher.addEventListener(param1,param2,param3,param4,param5);
      }
      
      public function removeEventListener(param1:String, param2:Function, param3:Boolean = false) : void
      {
         if(_dispatcher)
         {
            _dispatcher.removeEventListener(param1,param2,param3);
         }
      }
      
      public function hasEventListener(param1:String) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.hasEventListener(param1);
      }
      
      public function willTrigger(param1:String) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.willTrigger(param1);
      }
      
      public function dispatchEvent(param1:Event) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.dispatchEvent(param1);
      }
      
      override public function progress(param1:Number = NaN, param2:Boolean = false) : *
      {
         return !arguments.length ? _time / duration() : totalTime(duration() * (_yoyo && (_cycle & 1) !== 0 ? 1 - param1 : param1) + _cycle * (_duration + _repeatDelay),param2);
      }
      
      override public function totalProgress(param1:Number = NaN, param2:Boolean = false) : *
      {
         return !arguments.length ? _totalTime / totalDuration() : totalTime(totalDuration() * param1,param2);
      }
      
      override public function time(param1:Number = NaN, param2:Boolean = false) : *
      {
         if(!arguments.length)
         {
            return _time;
         }
         if(_dirty)
         {
            totalDuration();
         }
         if(param1 > _duration)
         {
            param1 = _duration;
         }
         if(_yoyo && (_cycle & 1) !== 0)
         {
            param1 = _duration - param1 + _cycle * (_duration + _repeatDelay);
         }
         else if(_repeat != 0)
         {
            param1 += _cycle * (_duration + _repeatDelay);
         }
         return totalTime(param1,param2);
      }
      
      override public function duration(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            return this._duration;
         }
         return super.duration(param1);
      }
      
      override public function totalDuration(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            if(_dirty)
            {
               _totalDuration = _repeat == -1 ? 999999999999 : _duration * (_repeat + 1) + _repeatDelay * _repeat;
               _dirty = false;
            }
            return _totalDuration;
         }
         return _repeat == -1 ? this : duration((param1 - _repeat * _repeatDelay) / (_repeat + 1));
      }
      
      public function repeat(param1:int = 0) : *
      {
         if(!arguments.length)
         {
            return _repeat;
         }
         _repeat = param1;
         return _uncache(true);
      }
      
      public function repeatDelay(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            return _repeatDelay;
         }
         _repeatDelay = param1;
         return _uncache(true);
      }
      
      public function yoyo(param1:Boolean = false) : *
      {
         if(!arguments.length)
         {
            return _yoyo;
         }
         _yoyo = param1;
         return this;
      }
   }
}

