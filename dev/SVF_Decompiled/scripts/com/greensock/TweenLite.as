package com.greensock
{
   import com.greensock.core.Animation;
   import com.greensock.core.PropTween;
   import com.greensock.core.SimpleTimeline;
   import com.greensock.easing.Ease;
   import flash.display.Shape;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class TweenLite extends Animation
   {
      public static const version:String = "12.1.5";
      
      public static var defaultOverwrite:String = "auto";
      
      public static var _onPluginEvent:Function;
      
      protected static var _overwriteLookup:Object;
      
      public static var defaultEase:Ease = new Ease(null,null,1,1);
      
      public static var ticker:Shape = Animation.ticker;
      
      public static var _plugins:Object = {};
      
      protected static var _tweenLookup:Dictionary = new Dictionary(false);
      
      protected static var _reservedProps:Object = {
         "ease":1,
         "delay":1,
         "overwrite":1,
         "onComplete":1,
         "onCompleteParams":1,
         "onCompleteScope":1,
         "useFrames":1,
         "runBackwards":1,
         "startAt":1,
         "onUpdate":1,
         "onUpdateParams":1,
         "onUpdateScope":1,
         "onStart":1,
         "onStartParams":1,
         "onStartScope":1,
         "onReverseComplete":1,
         "onReverseCompleteParams":1,
         "onReverseCompleteScope":1,
         "onRepeat":1,
         "onRepeatParams":1,
         "onRepeatScope":1,
         "easeParams":1,
         "yoyo":1,
         "onCompleteListener":1,
         "onUpdateListener":1,
         "onStartListener":1,
         "onReverseCompleteListener":1,
         "onRepeatListener":1,
         "orientToBezier":1,
         "immediateRender":1,
         "repeat":1,
         "repeatDelay":1,
         "data":1,
         "paused":1,
         "reversed":1
      };
      
      public var target:Object;
      
      public var ratio:Number;
      
      public var _propLookup:Object;
      
      public var _firstPT:PropTween;
      
      protected var _targets:Array;
      
      public var _ease:Ease;
      
      protected var _easeType:int;
      
      protected var _easePower:int;
      
      protected var _siblings:Array;
      
      protected var _overwrite:int;
      
      protected var _overwrittenProps:Object;
      
      protected var _notifyPluginsOfEnabled:Boolean;
      
      protected var _startAt:TweenLite;
      
      public function TweenLite(param1:Object, param2:Number, param3:Object)
      {
         var _loc4_:int = 0;
         super(param2,param3);
         if(param1 == null)
         {
            throw new Error("Cannot tween a null object. Duration: " + param2 + ", data: " + this.data);
         }
         if(!_overwriteLookup)
         {
            _overwriteLookup = {
               "none":0,
               "all":1,
               "auto":2,
               "concurrent":3,
               "allOnStart":4,
               "preexisting":5,
               "true":1,
               "false":0
            };
            ticker.addEventListener("enterFrame",_dumpGarbage,false,-1,true);
         }
         ratio = 0;
         this.target = param1;
         _ease = defaultEase;
         _overwrite = !("overwrite" in this.vars) ? _overwriteLookup[defaultOverwrite] : (typeof this.vars.overwrite === "number" ? this.vars.overwrite >> 0 : _overwriteLookup[this.vars.overwrite]);
         if(this.target is Array && typeof this.target[0] === "object")
         {
            _targets = this.target.concat();
            _propLookup = [];
            _siblings = [];
            _loc4_ = int(_targets.length);
            while(true)
            {
               _loc4_--;
               if(_loc4_ <= -1)
               {
                  break;
               }
               _siblings[_loc4_] = _register(_targets[_loc4_],this,false);
               if(_overwrite == 1)
               {
                  if(_siblings[_loc4_].length > 1)
                  {
                     _applyOverwrite(_targets[_loc4_],this,null,1,_siblings[_loc4_]);
                  }
               }
            }
         }
         else
         {
            _propLookup = {};
            _siblings = _tweenLookup[param1];
            if(_siblings == null)
            {
               _siblings = _tweenLookup[param1] = [this];
            }
            else
            {
               _siblings[_siblings.length] = this;
               if(_overwrite == 1)
               {
                  _applyOverwrite(param1,this,null,1,_siblings);
               }
            }
         }
         if(this.vars.immediateRender || param2 == 0 && _delay == 0 && this.vars.immediateRender != false)
         {
            render(-_delay,false,true);
         }
      }
      
      public static function to(param1:Object, param2:Number, param3:Object) : TweenLite
      {
         return new TweenLite(param1,param2,param3);
      }
      
      public static function from(param1:Object, param2:Number, param3:Object) : TweenLite
      {
         param3 = _prepVars(param3,true);
         param3.runBackwards = true;
         return new TweenLite(param1,param2,param3);
      }
      
      public static function fromTo(param1:Object, param2:Number, param3:Object, param4:Object) : TweenLite
      {
         param4 = _prepVars(param4,true);
         param3 = _prepVars(param3);
         param4.startAt = param3;
         param4.immediateRender = param4.immediateRender != false && param3.immediateRender != false;
         return new TweenLite(param1,param2,param4);
      }
      
      protected static function _prepVars(param1:Object, param2:Boolean = false) : Object
      {
         if(param1._isGSVars)
         {
            param1 = param1.vars;
         }
         if(param2 && !("immediateRender" in param1))
         {
            param1.immediateRender = true;
         }
         return param1;
      }
      
      public static function delayedCall(param1:Number, param2:Function, param3:Array = null, param4:Boolean = false) : TweenLite
      {
         return new TweenLite(param2,0,{
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
      
      public static function set(param1:Object, param2:Object) : TweenLite
      {
         return new TweenLite(param1,0,param2);
      }
      
      private static function _dumpGarbage(param1:Event) : void
      {
         var _loc3_:Array = null;
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         if(_rootFrame / 60 >> 0 === _rootFrame / 60)
         {
            for(_loc2_ in _tweenLookup)
            {
               _loc3_ = _tweenLookup[_loc2_];
               _loc4_ = int(_loc3_.length);
               while(true)
               {
                  _loc4_--;
                  if(_loc4_ <= -1)
                  {
                     break;
                  }
                  if(_loc3_[_loc4_]._gc)
                  {
                     _loc3_.splice(_loc4_,1);
                  }
               }
               if(_loc3_.length === 0)
               {
                  delete _tweenLookup[_loc2_];
               }
            }
         }
      }
      
      public static function killTweensOf(param1:*, param2:* = false, param3:Object = null) : void
      {
         var _loc4_:Array = null;
         if(typeof param2 === "object")
         {
            param3 = param2;
            param2 = false;
         }
         _loc4_ = TweenLite.getTweensOf(param1,param2);
         var _loc5_:int = int(_loc4_.length);
         while(true)
         {
            _loc5_--;
            if(_loc5_ <= -1)
            {
               break;
            }
            _loc4_[_loc5_]._kill(param3,param1);
         }
      }
      
      public static function killDelayedCallsTo(param1:Function) : void
      {
         killTweensOf(param1);
      }
      
      public static function getTweensOf(param1:*, param2:Boolean = false) : Array
      {
         var _loc3_:Array = null;
         var _loc6_:* = 0;
         var _loc4_:TweenLite = null;
         var _loc5_:int = 0;
         if(param1 is Array && typeof param1[0] != "string" && typeof param1[0] != "number")
         {
            _loc5_ = int(param1.length);
            _loc3_ = [];
            while(true)
            {
               _loc5_--;
               if(_loc5_ <= -1)
               {
                  break;
               }
               _loc3_ = _loc3_.concat(getTweensOf(param1[_loc5_],param2));
            }
            _loc5_ = int(_loc3_.length);
            while(true)
            {
               _loc5_--;
               if(_loc5_ <= -1)
               {
                  break;
               }
               _loc4_ = _loc3_[_loc5_];
               _loc6_ = _loc5_;
               while(true)
               {
                  _loc6_--;
                  if(_loc6_ <= -1)
                  {
                     break;
                  }
                  if(_loc4_ === _loc3_[_loc6_])
                  {
                     _loc3_.splice(_loc5_,1);
                  }
               }
            }
         }
         else
         {
            _loc3_ = _register(param1).concat();
            _loc5_ = int(_loc3_.length);
            while(true)
            {
               _loc5_--;
               if(_loc5_ <= -1)
               {
                  break;
               }
               if(_loc3_[_loc5_]._gc || param2 && !_loc3_[_loc5_].isActive())
               {
                  _loc3_.splice(_loc5_,1);
               }
            }
         }
         return _loc3_;
      }
      
      protected static function _register(param1:Object, param2:TweenLite = null, param3:Boolean = false) : Array
      {
         var _loc5_:int = 0;
         var _loc4_:Array = _tweenLookup[param1];
         if(_loc4_ == null)
         {
            _loc4_ = _tweenLookup[param1] = [];
         }
         if(param2)
         {
            _loc5_ = int(_loc4_.length);
            _loc4_[_loc5_] = param2;
            if(param3)
            {
               while(true)
               {
                  _loc5_--;
                  if(_loc5_ <= -1)
                  {
                     break;
                  }
                  if(_loc4_[_loc5_] === param2)
                  {
                     _loc4_.splice(_loc5_,1);
                  }
               }
            }
         }
         return _loc4_;
      }
      
      protected static function _applyOverwrite(param1:Object, param2:TweenLite, param3:Object, param4:int, param5:Array) : Boolean
      {
         var _loc14_:Boolean = false;
         var _loc6_:TweenLite = null;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         var _loc10_:Number = NaN;
         if(param4 == 1 || param4 >= 4)
         {
            _loc8_ = int(param5.length);
            _loc7_ = 0;
            while(_loc7_ < _loc8_)
            {
               _loc6_ = param5[_loc7_];
               if(_loc6_ != param2)
               {
                  if(!_loc6_._gc)
                  {
                     if(_loc6_._enabled(false,false))
                     {
                        _loc14_ = true;
                     }
                  }
               }
               else if(param4 == 5)
               {
                  break;
               }
               _loc7_++;
            }
            return _loc14_;
         }
         var _loc13_:Number = param2._startTime + 1e-10;
         var _loc12_:Array = [];
         var _loc9_:int = 0;
         var _loc11_:* = param2._duration == 0;
         _loc7_ = int(param5.length);
         while(true)
         {
            _loc7_--;
            if(_loc7_ <= -1)
            {
               break;
            }
            _loc6_ = param5[_loc7_];
            if(!(_loc6_ === param2 || _loc6_._gc || _loc6_._paused))
            {
               if(_loc6_._timeline != param2._timeline)
               {
                  _loc10_ ||= _checkOverlap(param2,0,_loc11_);
                  if(_checkOverlap(_loc6_,_loc10_,_loc11_) === 0)
                  {
                     _loc12_[_loc9_++] = _loc6_;
                  }
               }
               else if(_loc6_._startTime <= _loc13_)
               {
                  if(_loc6_._startTime + _loc6_.totalDuration() / _loc6_._timeScale > _loc13_)
                  {
                     if(!((_loc11_ || !_loc6_._initted) && _loc13_ - _loc6_._startTime <= 2e-10))
                     {
                        _loc12_[_loc9_++] = _loc6_;
                     }
                  }
               }
            }
         }
         _loc7_ = _loc9_;
         while(true)
         {
            _loc7_--;
            if(_loc7_ <= -1)
            {
               break;
            }
            _loc6_ = _loc12_[_loc7_];
            if(param4 == 2)
            {
               if(_loc6_._kill(param3,param1))
               {
                  _loc14_ = true;
               }
            }
            if(param4 !== 2 || !_loc6_._firstPT && _loc6_._initted)
            {
               if(_loc6_._enabled(false,false))
               {
                  _loc14_ = true;
               }
            }
         }
         return _loc14_;
      }
      
      private static function _checkOverlap(param1:Animation, param2:Number, param3:Boolean) : Number
      {
         var _loc6_:SimpleTimeline = null;
         _loc6_ = param1._timeline;
         var _loc7_:Number = _loc6_._timeScale;
         var _loc5_:Number = param1._startTime;
         while(_loc6_._timeline)
         {
            _loc5_ += _loc6_._startTime;
            _loc7_ *= _loc6_._timeScale;
            if(_loc6_._paused)
            {
               return -100;
            }
            _loc6_ = _loc6_._timeline;
         }
         _loc5_ += param1.totalDuration() / param1._timeScale / _loc7_;
         _loc5_ /= _loc7_;
         return _loc5_ > param2 ? _loc5_ - param2 : (param3 && _loc5_ == param2 || !param1._initted && _loc5_ - param2 < 2 * 1e-10 ? 1e-10 : (_loc5_ > param2 + 1e-10 ? 0 : _loc5_ - param2 - 1e-10));
      }
      
      protected function _init() : void
      {
         var _loc5_:int = 0;
         var _loc2_:Boolean = false;
         var _loc3_:PropTween = null;
         var _loc1_:String = null;
         var _loc6_:Object = null;
         var _loc4_:Boolean = Boolean(vars.immediateRender);
         if(vars.startAt)
         {
            if(_startAt != null)
            {
               _startAt.render(-1,true);
            }
            vars.startAt.overwrite = 0;
            vars.startAt.immediateRender = true;
            _startAt = new TweenLite(target,0,vars.startAt);
            if(_loc4_)
            {
               if(_time > 0)
               {
                  _startAt = null;
               }
               else if(_duration !== 0)
               {
                  return;
               }
            }
         }
         else if(vars.runBackwards && _duration !== 0)
         {
            if(_startAt != null)
            {
               _startAt.render(-1,true);
               _startAt = null;
            }
            else
            {
               _loc6_ = {};
               for(_loc1_ in vars)
               {
                  if(!(_loc1_ in _reservedProps))
                  {
                     _loc6_[_loc1_] = vars[_loc1_];
                  }
               }
               _loc6_.overwrite = 0;
               _loc6_.data = "isFromStart";
               _startAt = TweenLite.to(target,0,_loc6_);
               if(!_loc4_)
               {
                  _startAt.render(-1,true);
               }
               else if(_time === 0)
               {
                  return;
               }
            }
         }
         if(vars.ease is Ease)
         {
            _ease = vars.easeParams is Array ? vars.ease.config.apply(vars.ease,vars.easeParams) : vars.ease;
         }
         else if(typeof vars.ease === "function")
         {
            _ease = new Ease(vars.ease,vars.easeParams);
         }
         else
         {
            _ease = defaultEase;
         }
         _easeType = _ease._type;
         _easePower = _ease._power;
         _firstPT = null;
         if(_targets)
         {
            _loc5_ = int(_targets.length);
            while(true)
            {
               _loc5_--;
               if(_loc5_ <= -1)
               {
                  break;
               }
               if(_initProps(_targets[_loc5_],_propLookup[_loc5_] = {},_siblings[_loc5_],!!_overwrittenProps ? _overwrittenProps[_loc5_] : null))
               {
                  _loc2_ = true;
               }
            }
         }
         else
         {
            _loc2_ = _initProps(target,_propLookup,_siblings,_overwrittenProps);
         }
         if(_loc2_)
         {
            _onPluginEvent("_onInitAllProps",this);
         }
         if(_overwrittenProps)
         {
            if(_firstPT == null)
            {
               if(typeof target !== "function")
               {
                  _enabled(false,false);
               }
            }
         }
         if(vars.runBackwards)
         {
            _loc3_ = _firstPT;
            while(_loc3_)
            {
               _loc3_.s += _loc3_.c;
               _loc3_.c = -_loc3_.c;
               _loc3_ = _loc3_._next;
            }
         }
         _onUpdate = vars.onUpdate;
         _initted = true;
      }
      
      protected function _initProps(param1:Object, param2:Object, param3:Array, param4:Object) : Boolean
      {
         var _loc5_:String = null;
         var _loc9_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:Object = null;
         var _loc6_:Object = null;
         var _loc10_:Object = this.vars;
         if(param1 == null)
         {
            return false;
         }
         for(_loc5_ in _loc10_)
         {
            _loc6_ = _loc10_[_loc5_];
            if(_loc5_ in _reservedProps)
            {
               if(_loc6_ is Array)
               {
                  if(_loc6_.join("").indexOf("{self}") !== -1)
                  {
                     _loc10_[_loc5_] = _swapSelfInParams(_loc6_ as Array);
                  }
               }
            }
            else if(_loc5_ in _plugins && (_loc8_ = new _plugins[_loc5_]())._onInitTween(param1,_loc6_,this))
            {
               _firstPT = new PropTween(_loc8_,"setRatio",0,1,_loc5_,true,_firstPT,_loc8_._priority);
               _loc9_ = int(_loc8_._overwriteProps.length);
               while(true)
               {
                  _loc9_--;
                  if(_loc9_ <= -1)
                  {
                     break;
                  }
                  param2[_loc8_._overwriteProps[_loc9_]] = _firstPT;
               }
               if(_loc8_._priority || "_onInitAllProps" in _loc8_)
               {
                  _loc7_ = true;
               }
               if("_onDisable" in _loc8_ || "_onEnable" in _loc8_)
               {
                  _notifyPluginsOfEnabled = true;
               }
            }
            else
            {
               _firstPT = param2[_loc5_] = new PropTween(param1,_loc5_,0,1,_loc5_,false,_firstPT);
               _firstPT.s = !_firstPT.f ? Number(param1[_loc5_]) : param1[_loc5_.indexOf("set") || !("get" + _loc5_.substr(3) in param1) ? _loc5_ : "get" + _loc5_.substr(3)]();
               _firstPT.c = typeof _loc6_ === "number" ? Number(_loc6_) - _firstPT.s : (typeof _loc6_ === "string" && _loc6_.charAt(1) === "=" ? (int(_loc6_.charAt(0) + "1")) * Number(_loc6_.substr(2)) : Number(Number(_loc6_) || 0));
            }
         }
         if(param4)
         {
            if(_kill(param4,param1))
            {
               return _initProps(param1,param2,param3,param4);
            }
         }
         if(_overwrite > 1)
         {
            if(_firstPT != null)
            {
               if(param3.length > 1)
               {
                  if(_applyOverwrite(param1,this,param2,_overwrite,param3))
                  {
                     _kill(param2,param1);
                     return _initProps(param1,param2,param3,param4);
                  }
               }
            }
         }
         return _loc7_;
      }
      
      override public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var _loc7_:String = null;
         var _loc5_:PropTween = null;
         var _loc6_:Number = NaN;
         var _loc9_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc8_:Number = _time;
         if(param1 >= _duration)
         {
            _totalTime = _time = _duration;
            ratio = _ease._calcEnd ? _ease.getRatio(1) : 1;
            if(!_reversed)
            {
               _loc9_ = true;
               _loc7_ = "onComplete";
            }
            if(_duration == 0)
            {
               _loc6_ = _rawPrevTime;
               if(_startTime === _timeline._duration)
               {
                  param1 = 0;
               }
               if(param1 === 0 || _loc6_ < 0 || _loc6_ === _tinyNum)
               {
                  if(_loc6_ !== param1)
                  {
                     param3 = true;
                     if(_loc6_ > 0 && _loc6_ !== _tinyNum)
                     {
                        _loc7_ = "onReverseComplete";
                     }
                  }
               }
               _rawPrevTime = _loc6_ = !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
            }
         }
         else if(param1 < 1e-7)
         {
            _totalTime = _time = 0;
            ratio = _ease._calcEnd ? _ease.getRatio(0) : 0;
            if(_loc8_ !== 0 || _duration === 0 && _rawPrevTime > 0 && _rawPrevTime !== _tinyNum)
            {
               _loc7_ = "onReverseComplete";
               _loc9_ = _reversed;
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
                  _rawPrevTime = _loc6_ = !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
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
            if(_easeType)
            {
               _loc4_ = param1 / _duration;
               if(_easeType == 1 || _easeType == 3 && _loc4_ >= 0.5)
               {
                  _loc4_ = 1 - _loc4_;
               }
               if(_easeType == 3)
               {
                  _loc4_ *= 2;
               }
               if(_easePower == 1)
               {
                  _loc4_ *= _loc4_;
               }
               else if(_easePower == 2)
               {
                  _loc4_ *= _loc4_ * _loc4_;
               }
               else if(_easePower == 3)
               {
                  _loc4_ *= _loc4_ * _loc4_ * _loc4_;
               }
               else if(_easePower == 4)
               {
                  _loc4_ *= _loc4_ * _loc4_ * _loc4_ * _loc4_;
               }
               if(_easeType == 1)
               {
                  ratio = 1 - _loc4_;
               }
               else if(_easeType == 2)
               {
                  ratio = _loc4_;
               }
               else if(param1 / _duration < 0.5)
               {
                  ratio = _loc4_ / 2;
               }
               else
               {
                  ratio = 1 - _loc4_ / 2;
               }
            }
            else
            {
               ratio = _ease.getRatio(param1 / _duration);
            }
         }
         if(_time == _loc8_ && !param3)
         {
            return false;
         }
         if(!_initted)
         {
            _init();
            if(!_initted || _gc)
            {
               return false;
            }
            if(_time && !_loc9_)
            {
               ratio = _ease.getRatio(_time / _duration);
            }
            else if(_loc9_ && _ease._calcEnd)
            {
               ratio = _ease.getRatio(_time === 0 ? 0 : 1);
            }
         }
         if(!_active)
         {
            if(!_paused && _time !== _loc8_ && param1 >= 0)
            {
               _active = true;
            }
         }
         if(_loc8_ == 0)
         {
            if(_startAt != null)
            {
               if(param1 >= 0)
               {
                  _startAt.render(param1,param2,param3);
               }
               else if(!_loc7_)
               {
                  _loc7_ = "_dummyGS";
               }
            }
            if(vars.onStart)
            {
               if(_time != 0 || _duration == 0)
               {
                  if(!param2)
                  {
                     vars.onStart.apply(null,vars.onStartParams);
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
               if(_time !== _loc8_ || _loc9_)
               {
                  _onUpdate.apply(null,vars.onUpdateParams);
               }
            }
         }
         if(_loc7_)
         {
            if(!_gc)
            {
               if(param1 < 0 && _startAt != null && _onUpdate == null && _startTime != 0)
               {
                  _startAt.render(param1,param2,param3);
               }
               if(_loc9_)
               {
                  if(_timeline.autoRemoveChildren)
                  {
                     _enabled(false,false);
                  }
                  _active = false;
               }
               if(!param2)
               {
                  if(vars[_loc7_])
                  {
                     vars[_loc7_].apply(null,vars[_loc7_ + "Params"]);
                  }
               }
               if(_duration === 0 && _rawPrevTime === _tinyNum && _loc6_ !== _tinyNum)
               {
                  _rawPrevTime = 0;
               }
            }
         }
         return true;
      }
      
      override public function _kill(param1:Object = null, param2:Object = null) : Boolean
      {
         var _loc5_:Object = null;
         var _loc3_:String = null;
         var _loc4_:PropTween = null;
         var _loc8_:Object = null;
         var _loc10_:Boolean = false;
         var _loc9_:Object = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         if(param1 === "all")
         {
            param1 = null;
         }
         if(param1 == null)
         {
            if(param2 == null || param2 == this.target)
            {
               return _enabled(false,false);
            }
         }
         param2 = param2 || _targets || this.target;
         if(param2 is Array && typeof param2[0] === "object")
         {
            _loc7_ = int(param2.length);
            while(true)
            {
               _loc7_--;
               if(_loc7_ <= -1)
               {
                  break;
               }
               if(_kill(param1,param2[_loc7_]))
               {
                  _loc10_ = true;
               }
            }
         }
         else
         {
            if(_targets)
            {
               _loc7_ = int(_targets.length);
               while(true)
               {
                  _loc7_--;
                  if(_loc7_ <= -1)
                  {
                     break;
                  }
                  if(param2 === _targets[_loc7_])
                  {
                     _loc8_ = _propLookup[_loc7_] || {};
                     _overwrittenProps ||= [];
                     _loc5_ = _overwrittenProps[_loc7_] = !!param1 ? _overwrittenProps[_loc7_] || {} : "all";
                     break;
                  }
               }
            }
            else
            {
               if(param2 !== this.target)
               {
                  return false;
               }
               _loc8_ = _propLookup;
               _loc5_ = _overwrittenProps = !!param1 ? _overwrittenProps || {} : "all";
            }
            if(_loc8_)
            {
               _loc9_ = param1 || _loc8_;
               _loc6_ = param1 != _loc5_ && _loc5_ != "all" && param1 != _loc8_ && (typeof param1 != "object" || param1._tempKill != true);
               for(_loc3_ in _loc9_)
               {
                  _loc4_ = _loc8_[_loc3_];
                  if(_loc4_ != null)
                  {
                     if(_loc4_.pg && _loc4_.t._kill(_loc9_))
                     {
                        _loc10_ = true;
                     }
                     if(!_loc4_.pg || _loc4_.t._overwriteProps.length === 0)
                     {
                        if(_loc4_._prev)
                        {
                           _loc4_._prev._next = _loc4_._next;
                        }
                        else if(_loc4_ == _firstPT)
                        {
                           _firstPT = _loc4_._next;
                        }
                        if(_loc4_._next)
                        {
                           _loc4_._next._prev = _loc4_._prev;
                        }
                        _loc4_._next = _loc4_._prev = null;
                     }
                     delete _loc8_[_loc3_];
                  }
                  if(_loc6_)
                  {
                     _loc5_[_loc3_] = 1;
                  }
               }
               if(_firstPT == null && _initted)
               {
                  _enabled(false,false);
               }
            }
         }
         return _loc10_;
      }
      
      override public function invalidate() : *
      {
         if(_notifyPluginsOfEnabled)
         {
            _onPluginEvent("_onDisable",this);
         }
         _firstPT = null;
         _overwrittenProps = null;
         _onUpdate = null;
         _startAt = null;
         _initted = _active = _notifyPluginsOfEnabled = false;
         _propLookup = !!_targets ? {} : [];
         return this;
      }
      
      override public function _enabled(param1:Boolean, param2:Boolean = false) : Boolean
      {
         var _loc3_:int = 0;
         if(param1 && _gc)
         {
            if(_targets)
            {
               _loc3_ = int(_targets.length);
               while(true)
               {
                  _loc3_--;
                  if(_loc3_ <= -1)
                  {
                     break;
                  }
                  _siblings[_loc3_] = _register(_targets[_loc3_],this,true);
               }
            }
            else
            {
               _siblings = _register(target,this,true);
            }
         }
         super._enabled(param1,param2);
         if(_notifyPluginsOfEnabled)
         {
            if(_firstPT != null)
            {
               return _onPluginEvent(param1 ? "_onEnable" : "_onDisable",this);
            }
         }
         return false;
      }
   }
}

