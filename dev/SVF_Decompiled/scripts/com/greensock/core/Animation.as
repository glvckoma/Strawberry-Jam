package com.greensock.core
{
   import flash.display.Shape;
   import flash.events.Event;
   import flash.utils.getTimer;
   
   public class Animation
   {
      public static const version:String = "12.1.1";
      
      public static var _rootTimeline:SimpleTimeline;
      
      public static var _rootFramesTimeline:SimpleTimeline;
      
      protected static var _rootFrame:Number = -1;
      
      protected static var _tinyNum:Number = 1e-10;
      
      public static var ticker:Shape = new Shape();
      
      protected static var _tickEvent:Event = new Event("tick");
      
      protected var _onUpdate:Function;
      
      public var _delay:Number;
      
      public var _rawPrevTime:Number;
      
      public var _active:Boolean;
      
      public var _gc:Boolean;
      
      public var _initted:Boolean;
      
      public var _startTime:Number;
      
      public var _time:Number;
      
      public var _totalTime:Number;
      
      public var _duration:Number;
      
      public var _totalDuration:Number;
      
      public var _pauseTime:Number;
      
      public var _timeScale:Number;
      
      public var _reversed:Boolean;
      
      public var _timeline:SimpleTimeline;
      
      public var _dirty:Boolean;
      
      public var _paused:Boolean;
      
      public var _next:Animation;
      
      public var _prev:Animation;
      
      public var vars:Object;
      
      public var timeline:SimpleTimeline;
      
      public var data:*;
      
      public function Animation(param1:Number = 0, param2:Object = null)
      {
         super();
         this.vars = param2 || {};
         if(this.vars._isGSVars)
         {
            this.vars = this.vars.vars;
         }
         _duration = _totalDuration = param1 || 0;
         _delay = Number(this.vars.delay) || 0;
         _timeScale = 1;
         _totalTime = _time = 0;
         data = this.vars.data;
         _rawPrevTime = -1;
         if(_rootTimeline == null)
         {
            if(_rootFrame != -1)
            {
               return;
            }
            _rootFrame = 0;
            _rootFramesTimeline = new SimpleTimeline();
            _rootTimeline = new SimpleTimeline();
            _rootTimeline._startTime = getTimer() / 1000;
            _rootFramesTimeline._startTime = 0;
            _rootFramesTimeline._active = true;
            _rootTimeline._active = true;
            ticker.addEventListener("enterFrame",_updateRoot,false,0,true);
         }
         var _loc3_:SimpleTimeline = !!this.vars.useFrames ? _rootFramesTimeline : _rootTimeline;
         _loc3_.add(this,_loc3_._time);
         _reversed = this.vars.reversed == true;
         if(this.vars.paused)
         {
            paused(true);
         }
      }
      
      public static function _updateRoot(param1:Event = null) : void
      {
         _rootFrame++;
         if(_rootTimeline.renderCreateTime(_rootTimeline._startTime,_rootTimeline._timeScale,false,false) && _rootFramesTimeline.render((_rootFrame - _rootFramesTimeline._startTime) * _rootFramesTimeline._timeScale,false,false))
         {
            ticker.dispatchEvent(_tickEvent);
         }
      }
      
      public function play(param1:* = null, param2:Boolean = true) : *
      {
         if(param1 != null)
         {
            seek(param1,param2);
         }
         reversed(false);
         return paused(false);
      }
      
      public function pause(param1:* = null, param2:Boolean = true) : *
      {
         if(param1 != null)
         {
            seek(param1,param2);
         }
         return paused(true);
      }
      
      public function resume(param1:* = null, param2:Boolean = true) : *
      {
         if(param1 != null)
         {
            seek(param1,param2);
         }
         return paused(false);
      }
      
      public function seek(param1:*, param2:Boolean = true) : *
      {
         return totalTime(param1,param2);
      }
      
      public function restart(param1:Boolean = false, param2:Boolean = true) : *
      {
         reversed(false);
         paused(false);
         return totalTime(param1 ? -_delay : 0,param2,true);
      }
      
      public function reverse(param1:* = null, param2:Boolean = true) : *
      {
         if(param1 != null)
         {
            seek(param1 || totalDuration(),param2);
         }
         reversed(true);
         return paused(false);
      }
      
      public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         return false;
      }
      
      public function renderCreateTime(param1:Number, param2:Number, param3:Boolean = false, param4:Boolean = false) : Boolean
      {
         return false;
      }
      
      public function invalidate() : *
      {
         return this;
      }
      
      public function isActive() : Boolean
      {
         var _loc1_:Number = NaN;
         var _loc2_:SimpleTimeline = _timeline;
         return _loc2_ == null || !_gc && !_paused && _loc2_.isActive() && (_loc1_ = _loc2_.rawTime()) >= _startTime && _loc1_ < _startTime + totalDuration() / _timeScale;
      }
      
      public function _enabled(param1:Boolean, param2:Boolean = false) : Boolean
      {
         _gc = !param1;
         _active = param1 && !_paused && _totalTime > 0 && _totalTime < _totalDuration;
         if(!param2)
         {
            if(param1 && timeline == null)
            {
               _timeline.add(this,_startTime - _delay);
            }
            else if(!param1 && timeline != null)
            {
               _timeline._remove(this,true);
            }
         }
         return false;
      }
      
      public function _kill(param1:Object = null, param2:Object = null) : Boolean
      {
         return _enabled(false,false);
      }
      
      public function kill(param1:Object = null, param2:Object = null) : *
      {
         _kill(param1,param2);
         return this;
      }
      
      protected function _uncache(param1:Boolean) : *
      {
         var _loc2_:Animation = param1 ? this : timeline;
         while(_loc2_)
         {
            _loc2_._dirty = true;
            _loc2_ = _loc2_.timeline;
         }
         return this;
      }
      
      protected function _swapSelfInParams(param1:Array) : Array
      {
         var _loc2_:int = int(param1.length);
         var _loc3_:Array = param1.concat();
         while(true)
         {
            _loc2_--;
            if(_loc2_ <= -1)
            {
               break;
            }
            if(param1[_loc2_] === "{self}")
            {
               _loc3_[_loc2_] = this;
            }
         }
         return _loc3_;
      }
      
      public function eventCallback(param1:String, param2:Function = null, param3:Array = null) : *
      {
         if(param1 == null)
         {
            return null;
         }
         if(param1.substr(0,2) == "on")
         {
            if(arguments.length == 1)
            {
               return vars[param1];
            }
            if(param2 == null)
            {
               delete vars[param1];
            }
            else
            {
               vars[param1] = param2;
               vars[param1 + "Params"] = param3 is Array && param3.join("").indexOf("{self}") !== -1 ? _swapSelfInParams(param3) : param3;
            }
            if(param1 == "onUpdate")
            {
               _onUpdate = param2;
            }
         }
         return this;
      }
      
      public function delay(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            return _delay;
         }
         if(_timeline.smoothChildTiming)
         {
            startTime(_startTime + param1 - _delay);
         }
         _delay = param1;
         return this;
      }
      
      public function duration(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            _dirty = false;
            return _duration;
         }
         _duration = _totalDuration = param1;
         _uncache(true);
         if(_timeline.smoothChildTiming)
         {
            if(_time > 0)
            {
               if(_time < _duration)
               {
                  if(param1 != 0)
                  {
                     totalTime(_totalTime * (param1 / _duration),true);
                  }
               }
            }
         }
         return this;
      }
      
      public function totalDuration(param1:Number = NaN) : *
      {
         _dirty = false;
         return !arguments.length ? _totalDuration : duration(param1);
      }
      
      public function time(param1:Number = NaN, param2:Boolean = false) : *
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
         return totalTime(param1,param2);
      }
      
      public function totalTime(param1:Number = NaN, param2:Boolean = false, param3:Boolean = false) : *
      {
         var _loc5_:SimpleTimeline = null;
         if(!arguments.length)
         {
            return _totalTime;
         }
         if(_timeline)
         {
            if(param1 < 0 && !param3)
            {
               param1 += totalDuration();
            }
            if(_timeline.smoothChildTiming)
            {
               if(_dirty)
               {
                  totalDuration();
               }
               if(param1 > _totalDuration && !param3)
               {
                  param1 = _totalDuration;
               }
               _loc5_ = _timeline;
               _startTime = (_paused ? _pauseTime : _loc5_._time) - (!_reversed ? param1 : _totalDuration - param1) / _timeScale;
               if(!_timeline._dirty)
               {
                  _uncache(false);
               }
               if(_loc5_._timeline != null)
               {
                  while(_loc5_._timeline)
                  {
                     if(_loc5_._timeline._time !== (_loc5_._startTime + _loc5_._totalTime) / _loc5_._timeScale)
                     {
                        _loc5_.totalTime(_loc5_._totalTime,true);
                     }
                     _loc5_ = _loc5_._timeline;
                  }
               }
            }
            if(_gc)
            {
               _enabled(true,false);
            }
            if(_totalTime != param1 || _duration === 0)
            {
               render(param1,param2,false);
            }
         }
         return this;
      }
      
      public function progress(param1:Number = NaN, param2:Boolean = false) : *
      {
         return !arguments.length ? _time / duration() : totalTime(duration() * param1,param2);
      }
      
      public function totalProgress(param1:Number = NaN, param2:Boolean = false) : *
      {
         return !arguments.length ? _time / duration() : totalTime(duration() * param1,param2);
      }
      
      public function startTime(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            return _startTime;
         }
         if(param1 != _startTime)
         {
            _startTime = param1;
            if(timeline)
            {
               if(timeline._sortChildren)
               {
                  timeline.add(this,param1 - _delay);
               }
            }
         }
         return this;
      }
      
      public function timeScale(param1:Number = NaN) : *
      {
         var _loc3_:Number = NaN;
         if(!arguments.length)
         {
            return _timeScale;
         }
         param1 ||= 0.000001;
         if(_timeline && _timeline.smoothChildTiming)
         {
            _loc3_ = _pauseTime || _pauseTime == 0 ? _pauseTime : _timeline._totalTime;
            _startTime = _loc3_ - (_loc3_ - _startTime) * _timeScale / param1;
         }
         _timeScale = param1;
         return _uncache(false);
      }
      
      public function reversed(param1:Boolean = false) : *
      {
         if(!arguments.length)
         {
            return _reversed;
         }
         if(param1 != _reversed)
         {
            _reversed = param1;
            totalTime(_timeline && !_timeline.smoothChildTiming ? totalDuration() - _totalTime : _totalTime,true);
         }
         return this;
      }
      
      public function paused(param1:Boolean = false) : *
      {
         var _loc4_:Number = NaN;
         if(!arguments.length)
         {
            return _paused;
         }
         if(param1 != _paused)
         {
            if(_timeline)
            {
               _loc4_ = _timeline.rawTime();
               var _loc3_:Number = _loc4_ - _pauseTime;
               if(!param1 && _timeline.smoothChildTiming)
               {
                  _startTime += _loc3_;
                  _uncache(false);
               }
               _pauseTime = param1 ? _loc4_ : NaN;
               _paused = param1;
               _active = !param1 && _totalTime > 0 && _totalTime < _totalDuration;
               if(!param1 && _loc3_ != 0 && _initted && duration() !== 0)
               {
                  render(_timeline.smoothChildTiming ? _totalTime : (_loc4_ - _startTime) / _timeScale,true,true);
               }
            }
         }
         if(_gc && !param1)
         {
            _enabled(true,false);
         }
         return this;
      }
   }
}

