package com.greensock
{
   import com.greensock.core.Animation;
   import com.greensock.core.SimpleTimeline;
   
   public class TimelineLite extends SimpleTimeline
   {
      public static const version:String = "12.1.5";
      
      protected var _labels:Object;
      
      public function TimelineLite(param1:Object = null)
      {
         var _loc2_:String = null;
         var _loc3_:Object = null;
         super(param1);
         _labels = {};
         autoRemoveChildren = this.vars.autoRemoveChildren == true;
         smoothChildTiming = this.vars.smoothChildTiming == true;
         _sortChildren = true;
         _onUpdate = this.vars.onUpdate;
         for(_loc2_ in this.vars)
         {
            _loc3_ = this.vars[_loc2_];
            if(_loc3_ is Array)
            {
               if(_loc3_.join("").indexOf("{self}") !== -1)
               {
                  this.vars[_loc2_] = _swapSelfInParams(_loc3_ as Array);
               }
            }
         }
         if(this.vars.tweens is Array)
         {
            this.add(this.vars.tweens,0,this.vars.align || "normal",this.vars.stagger || 0);
         }
      }
      
      protected static function _prepVars(param1:Object) : Object
      {
         return !!param1._isGSVars ? param1.vars : param1;
      }
      
      protected static function _copy(param1:Object) : Object
      {
         var _loc2_:String = null;
         var _loc3_:Object = {};
         for(_loc2_ in param1)
         {
            _loc3_[_loc2_] = param1[_loc2_];
         }
         return _loc3_;
      }
      
      public static function exportRoot(param1:Object = null, param2:Boolean = true) : TimelineLite
      {
         var _loc6_:TimelineLite = null;
         var _loc3_:Animation = null;
         param1 ||= {};
         if(!("smoothChildTiming" in param1))
         {
            param1.smoothChildTiming = true;
         }
         _loc6_ = new TimelineLite(param1);
         var _loc5_:SimpleTimeline = _loc6_._timeline;
         _loc5_._remove(_loc6_,true);
         _loc6_._startTime = 0;
         _loc6_._rawPrevTime = _loc6_._time = _loc6_._totalTime = _loc5_._time;
         var _loc4_:* = _loc5_._first;
         while(_loc4_)
         {
            _loc3_ = _loc4_._next;
            if(!param2 || !(_loc4_ is TweenLite && TweenLite(_loc4_).target == _loc4_.vars.onComplete))
            {
               _loc6_.add(_loc4_,_loc4_._startTime - _loc4_._delay);
            }
            _loc4_ = _loc3_;
         }
         _loc5_.add(_loc6_,0);
         return _loc6_;
      }
      
      public function to(param1:Object, param2:Number, param3:Object, param4:* = "+=0") : *
      {
         return !!param2 ? add(new TweenLite(param1,param2,param3),param4) : this.set(param1,param3,param4);
      }
      
      public function from(param1:Object, param2:Number, param3:Object, param4:* = "+=0") : *
      {
         return add(TweenLite.from(param1,param2,param3),param4);
      }
      
      public function fromTo(param1:Object, param2:Number, param3:Object, param4:Object, param5:* = "+=0") : *
      {
         return !!param2 ? add(TweenLite.fromTo(param1,param2,param3,param4),param5) : this.set(param1,param4,param5);
      }
      
      public function staggerTo(param1:Array, param2:Number, param3:Object, param4:Number, param5:* = "+=0", param6:Function = null, param7:Array = null) : *
      {
         var _loc9_:int = 0;
         var _loc8_:TimelineLite = new TimelineLite({
            "onComplete":param6,
            "onCompleteParams":param7,
            "smoothChildTiming":this.smoothChildTiming
         });
         _loc9_ = 0;
         while(_loc9_ < param1.length)
         {
            if(param3.startAt != null)
            {
               param3.startAt = _copy(param3.startAt);
            }
            _loc8_.to(param1[_loc9_],param2,_copy(param3),_loc9_ * param4);
            _loc9_++;
         }
         return add(_loc8_,param5);
      }
      
      public function staggerFrom(param1:Array, param2:Number, param3:Object, param4:Number = 0, param5:* = "+=0", param6:Function = null, param7:Array = null) : *
      {
         param3 = _prepVars(param3);
         if(!("immediateRender" in param3))
         {
            param3.immediateRender = true;
         }
         param3.runBackwards = true;
         return staggerTo(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function staggerFromTo(param1:Array, param2:Number, param3:Object, param4:Object, param5:Number = 0, param6:* = "+=0", param7:Function = null, param8:Array = null) : *
      {
         param4 = _prepVars(param4);
         param3 = _prepVars(param3);
         param4.startAt = param3;
         param4.immediateRender = param4.immediateRender != false && param3.immediateRender != false;
         return staggerTo(param1,param2,param4,param5,param6,param7,param8);
      }
      
      public function call(param1:Function, param2:Array = null, param3:* = "+=0") : *
      {
         return add(TweenLite.delayedCall(0,param1,param2),param3);
      }
      
      public function set(param1:Object, param2:Object, param3:* = "+=0") : *
      {
         param3 = _parseTimeOrLabel(param3,0,true);
         param2 = _prepVars(param2);
         if(param2.immediateRender == null)
         {
            param2.immediateRender = param3 === _time && !_paused;
         }
         return add(new TweenLite(param1,0,param2),param3);
      }
      
      public function addPause(param1:* = "+=0", param2:Function = null, param3:Array = null) : *
      {
         return call(_pauseCallback,["{self}",param2,param3],param1);
      }
      
      protected function _pauseCallback(param1:TweenLite, param2:Function = null, param3:Array = null) : void
      {
         pause(param1._startTime);
         if(param2 != null)
         {
            param2.apply(null,param3);
         }
      }
      
      override public function insert(param1:*, param2:* = 0) : *
      {
         return add(param1,param2 || 0);
      }
      
      override public function add(param1:*, param2:* = "+=0", param3:String = "normal", param4:Number = 0) : *
      {
         var _loc10_:* = undefined;
         var _loc7_:int = 0;
         var _loc6_:SimpleTimeline = null;
         if(typeof param2 !== "number")
         {
            param2 = _parseTimeOrLabel(param2,0,true,param1);
         }
         if(!(param1 is Animation))
         {
            if(param1 is Array)
            {
               var _loc5_:Number = param2;
               var _loc9_:Number = Number(param1.length);
               _loc7_ = 0;
               while(_loc7_ < _loc9_)
               {
                  _loc10_ = param1[_loc7_];
                  if(_loc10_ is Array)
                  {
                     _loc10_ = new TimelineLite({"tweens":_loc10_});
                  }
                  add(_loc10_,_loc5_);
                  if(!(typeof _loc10_ === "string" || typeof _loc10_ === "function"))
                  {
                     if(param3 === "sequence")
                     {
                        _loc5_ = _loc10_._startTime + _loc10_.totalDuration() / _loc10_._timeScale;
                     }
                     else if(param3 === "start")
                     {
                        _loc10_._startTime -= _loc10_.delay();
                     }
                  }
                  _loc5_ += param4;
                  _loc7_++;
               }
               return _uncache(true);
            }
            if(typeof param1 === "string")
            {
               return addLabel(param1,param2);
            }
            if(typeof param1 !== "function")
            {
               trace("Cannot add " + param1 + " into the TimelineLite/Max: it is not a tween, timeline, function, or string.");
               return this;
            }
            param1 = TweenLite.delayedCall(0,param1);
         }
         super.add(param1,param2);
         if(_gc || _time === _duration)
         {
            if(!_paused)
            {
               if(_duration < duration())
               {
                  _loc6_ = this;
                  var _loc8_:* = _loc6_.rawTime() > param1._startTime;
                  while(_loc6_._timeline)
                  {
                     if(_loc8_ && _loc6_._timeline.smoothChildTiming)
                     {
                        _loc6_.totalTime(_loc6_._totalTime,true);
                     }
                     else if(_loc6_._gc)
                     {
                        _loc6_._enabled(true,false);
                     }
                     _loc6_ = _loc6_._timeline;
                  }
               }
            }
         }
         return this;
      }
      
      public function remove(param1:*) : *
      {
         var _loc2_:Number = NaN;
         if(param1 is Animation)
         {
            return _remove(param1,false);
         }
         if(param1 is Array)
         {
            _loc2_ = Number(param1.length);
            while(true)
            {
               _loc2_--;
               if(_loc2_ <= -1)
               {
                  break;
               }
               remove(param1[_loc2_]);
            }
            return this;
         }
         if(typeof param1 == "string")
         {
            return removeLabel(param1);
         }
         return kill(null,param1);
      }
      
      override public function _remove(param1:Animation, param2:Boolean = false) : *
      {
         super._remove(param1,param2);
         if(_last == null)
         {
            _time = _totalTime = _duration = _totalDuration = 0;
         }
         else if(_time > _last._startTime + _last._totalDuration / _last._timeScale)
         {
            _time = duration();
            _totalTime = _totalDuration;
         }
         return this;
      }
      
      public function append(param1:*, param2:* = 0) : *
      {
         return add(param1,_parseTimeOrLabel(null,param2,true,param1));
      }
      
      public function insertMultiple(param1:Array, param2:* = 0, param3:String = "normal", param4:Number = 0) : *
      {
         return add(param1,param2 || 0,param3,param4);
      }
      
      public function appendMultiple(param1:Array, param2:* = 0, param3:String = "normal", param4:Number = 0) : *
      {
         return add(param1,_parseTimeOrLabel(null,param2,true,param1),param3,param4);
      }
      
      public function addLabel(param1:String, param2:* = "+=0") : *
      {
         _labels[param1] = _parseTimeOrLabel(param2);
         return this;
      }
      
      public function removeLabel(param1:String) : *
      {
         delete _labels[param1];
         return this;
      }
      
      public function getLabelTime(param1:String) : Number
      {
         return param1 in _labels ? Number(_labels[param1]) : -1;
      }
      
      protected function _parseTimeOrLabel(param1:*, param2:* = 0, param3:Boolean = false, param4:Object = null) : Number
      {
         var _loc5_:int = 0;
         if(param4 is Animation && param4.timeline === this)
         {
            remove(param4);
         }
         else if(param4 is Array)
         {
            _loc5_ = int(param4.length);
            while(true)
            {
               _loc5_--;
               if(_loc5_ <= -1)
               {
                  break;
               }
               if(param4[_loc5_] is Animation && param4[_loc5_].timeline === this)
               {
                  remove(param4[_loc5_]);
               }
            }
         }
         if(typeof param2 === "string")
         {
            return _parseTimeOrLabel(param2,param3 && typeof param1 === "number" && !(param2 in _labels) ? param1 - duration() : 0,param3);
         }
         param2 ||= 0;
         if(typeof param1 === "string" && (isNaN(param1) || param1 in _labels))
         {
            _loc5_ = int(param1.indexOf("="));
            if(_loc5_ === -1)
            {
               if(!(param1 in _labels))
               {
                  return param3 ? (_labels[param1] = duration() + param2) : param2;
               }
               return _labels[param1] + param2;
            }
            param2 = parseInt(param1.charAt(_loc5_ - 1) + "1",10) * Number(param1.substr(_loc5_ + 1));
            param1 = _loc5_ > 1 ? _parseTimeOrLabel(param1.substr(0,_loc5_ - 1),0,param3) : duration();
         }
         else if(param1 == null)
         {
            param1 = duration();
         }
         return param1 + param2;
      }
      
      override public function seek(param1:*, param2:Boolean = true) : *
      {
         return totalTime(typeof param1 === "number" ? param1 : _parseTimeOrLabel(param1),param2);
      }
      
      public function stop() : *
      {
         return paused(true);
      }
      
      public function gotoAndPlay(param1:*, param2:Boolean = true) : *
      {
         return play(param1,param2);
      }
      
      public function gotoAndStop(param1:*, param2:Boolean = true) : *
      {
         return pause(param1,param2);
      }
      
      override public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var _loc10_:* = null;
         var _loc13_:Boolean = false;
         var _loc5_:Animation = null;
         var _loc12_:String = null;
         var _loc9_:Boolean = false;
         if(_gc)
         {
            _enabled(true,false);
         }
         var _loc8_:Number = Number(!_dirty ? _totalDuration : totalDuration());
         var _loc7_:Number = _time;
         var _loc4_:Number = _startTime;
         var _loc11_:Number = _timeScale;
         var _loc6_:Boolean = _paused;
         if(param1 >= _loc8_)
         {
            _totalTime = _time = _loc8_;
            if(!_reversed)
            {
               if(!_hasPausedChild())
               {
                  _loc13_ = true;
                  _loc12_ = "onComplete";
                  if(_duration === 0)
                  {
                     if(param1 === 0 || _rawPrevTime < 0 || _rawPrevTime === _tinyNum)
                     {
                        if(_rawPrevTime !== param1 && _first != null)
                        {
                           _loc9_ = true;
                           if(_rawPrevTime > _tinyNum)
                           {
                              _loc12_ = "onReverseComplete";
                           }
                        }
                     }
                  }
               }
            }
            _rawPrevTime = _duration !== 0 || !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
            param1 = _loc8_ + 0.0001;
         }
         else if(param1 < 1e-7)
         {
            _totalTime = _time = 0;
            if(_loc7_ !== 0 || _duration === 0 && _rawPrevTime !== _tinyNum && (_rawPrevTime > 0 || param1 < 0 && _rawPrevTime >= 0))
            {
               _loc12_ = "onReverseComplete";
               _loc13_ = _reversed;
            }
            if(param1 < 0)
            {
               _active = false;
               if(_rawPrevTime >= 0 && _first != null)
               {
                  _loc9_ = true;
               }
               _rawPrevTime = param1;
            }
            else
            {
               _rawPrevTime = _duration || !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
               param1 = 0;
               if(!_initted)
               {
                  _loc9_ = true;
               }
            }
         }
         else
         {
            _totalTime = _time = _rawPrevTime = param1;
         }
         if((_time == _loc7_ || !_first) && !param3 && !_loc9_)
         {
            return false;
         }
         if(!_initted)
         {
            _initted = true;
         }
         if(!_active)
         {
            if(!_paused && _time !== _loc7_ && param1 > 0)
            {
               _active = true;
            }
         }
         if(_loc7_ == 0)
         {
            if(vars.onStart)
            {
               if(_time != 0)
               {
                  if(!param2)
                  {
                     vars.onStart.apply(null,vars.onStartParams);
                  }
               }
            }
         }
         if(_time >= _loc7_)
         {
            _loc10_ = _first;
            while(true)
            {
               if(_loc10_)
               {
                  _loc5_ = _loc10_._next;
                  if(!(_paused && !_loc6_))
                  {
                     if(_loc10_._active || _loc10_._startTime <= _time && !_loc10_._paused && !_loc10_._gc)
                     {
                        if(!_loc10_._reversed)
                        {
                           _loc10_.render((param1 - _loc10_._startTime) * _loc10_._timeScale,param2,param3);
                        }
                        else
                        {
                           _loc10_.render((!_loc10_._dirty ? _loc10_._totalDuration : _loc10_.totalDuration()) - (param1 - _loc10_._startTime) * _loc10_._timeScale,param2,param3);
                        }
                     }
                     _loc10_ = _loc5_;
                     continue;
                  }
               }
            }
         }
         else
         {
            _loc10_ = _last;
            while(_loc10_)
            {
               _loc5_ = _loc10_._prev;
               if(_paused && !_loc6_)
               {
                  break;
               }
               if(_loc10_._active || _loc10_._startTime <= _loc7_ && !_loc10_._paused && !_loc10_._gc)
               {
                  if(!_loc10_._reversed)
                  {
                     _loc10_.render((param1 - _loc10_._startTime) * _loc10_._timeScale,param2,param3);
                  }
                  else
                  {
                     _loc10_.render((!_loc10_._dirty ? _loc10_._totalDuration : _loc10_.totalDuration()) - (param1 - _loc10_._startTime) * _loc10_._timeScale,param2,param3);
                  }
               }
               _loc10_ = _loc5_;
            }
         }
         if(_onUpdate != null)
         {
            if(!param2)
            {
               _onUpdate.apply(null,vars.onUpdateParams);
            }
         }
         if(_loc12_)
         {
            if(!_gc)
            {
               if(_loc4_ == _startTime || _loc11_ != _timeScale)
               {
                  if(_time == 0 || _loc8_ >= totalDuration())
                  {
                     if(_loc13_)
                     {
                        if(_timeline.autoRemoveChildren)
                        {
                           _enabled(false,false);
                        }
                        _active = false;
                     }
                     if(!param2)
                     {
                        if(vars[_loc12_])
                        {
                           vars[_loc12_].apply(null,vars[_loc12_ + "Params"]);
                        }
                     }
                  }
               }
            }
         }
         return true;
      }
      
      public function _hasPausedChild() : Boolean
      {
         var _loc1_:Animation = _first;
         while(_loc1_)
         {
            if(_loc1_._paused || _loc1_ is TimelineLite && Boolean(TimelineLite(_loc1_)._hasPausedChild()))
            {
               return true;
            }
            _loc1_ = _loc1_._next;
         }
         return false;
      }
      
      public function getChildren(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true, param4:Number = -9999999999) : Array
      {
         var _loc6_:Array = [];
         var _loc5_:Animation = _first;
         var _loc7_:int = 0;
         while(_loc5_)
         {
            if(_loc5_._startTime >= param4)
            {
               if(_loc5_ is TweenLite)
               {
                  if(param2)
                  {
                     _loc6_[_loc7_++] = _loc5_;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _loc6_[_loc7_++] = _loc5_;
                  }
                  if(param1)
                  {
                     _loc6_ = _loc6_.concat(TimelineLite(_loc5_).getChildren(true,param2,param3));
                     _loc7_ = int(_loc6_.length);
                  }
               }
            }
            _loc5_ = _loc5_._next;
         }
         return _loc6_;
      }
      
      public function getTweensOf(param1:Object, param2:Boolean = true) : Array
      {
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = this._gc;
         var _loc3_:Array = [];
         var _loc5_:int = 0;
         if(_loc7_)
         {
            _enabled(true,true);
         }
         _loc4_ = TweenLite.getTweensOf(param1);
         _loc6_ = int(_loc4_.length);
         while(true)
         {
            _loc6_--;
            if(_loc6_ <= -1)
            {
               break;
            }
            if(_loc4_[_loc6_].timeline === this || param2 && _contains(_loc4_[_loc6_]))
            {
               _loc3_[_loc5_++] = _loc4_[_loc6_];
            }
         }
         if(_loc7_)
         {
            _enabled(false,true);
         }
         return _loc3_;
      }
      
      private function _contains(param1:Animation) : Boolean
      {
         var _loc2_:SimpleTimeline = param1.timeline;
         while(_loc2_)
         {
            if(_loc2_ == this)
            {
               return true;
            }
            _loc2_ = _loc2_.timeline;
         }
         return false;
      }
      
      public function shiftChildren(param1:Number, param2:Boolean = false, param3:Number = 0) : *
      {
         var _loc5_:Animation = _first;
         while(_loc5_)
         {
            if(_loc5_._startTime >= param3)
            {
               _loc5_._startTime += param1;
            }
            _loc5_ = _loc5_._next;
         }
         if(param2)
         {
            for(var _loc4_ in _labels)
            {
               if(_labels[_loc4_] >= param3)
               {
                  var _loc6_:* = _loc4_;
                  var _loc7_:* = _labels[_loc6_] + param1;
                  _labels[_loc6_] = _loc7_;
               }
            }
         }
         _uncache(true);
         return this;
      }
      
      override public function _kill(param1:Object = null, param2:Object = null) : Boolean
      {
         var _loc3_:Array = null;
         if(param1 == null)
         {
            if(param2 == null)
            {
               return _enabled(false,false);
            }
         }
         _loc3_ = param2 == null ? getChildren(true,true,false) : getTweensOf(param2);
         var _loc4_:int = int(_loc3_.length);
         var _loc5_:Boolean = false;
         while(true)
         {
            _loc4_--;
            if(_loc4_ <= -1)
            {
               break;
            }
            if(_loc3_[_loc4_]._kill(param1,param2))
            {
               _loc5_ = true;
            }
         }
         return _loc5_;
      }
      
      public function clear(param1:Boolean = true) : *
      {
         var _loc2_:Array = null;
         _loc2_ = getChildren(false,true,true);
         var _loc3_:int = int(_loc2_.length);
         _time = _totalTime = 0;
         while(true)
         {
            _loc3_--;
            if(_loc3_ <= -1)
            {
               break;
            }
            _loc2_[_loc3_]._enabled(false,false);
         }
         if(param1)
         {
            _labels = {};
         }
         return _uncache(true);
      }
      
      override public function invalidate() : *
      {
         var _loc1_:Animation = _first;
         while(_loc1_)
         {
            _loc1_.invalidate();
            _loc1_ = _loc1_._next;
         }
         return this;
      }
      
      override public function _enabled(param1:Boolean, param2:Boolean = false) : Boolean
      {
         var _loc3_:Animation = null;
         if(param1 == _gc)
         {
            _loc3_ = _first;
            while(_loc3_)
            {
               _loc3_._enabled(param1,true);
               _loc3_ = _loc3_._next;
            }
         }
         return super._enabled(param1,param2);
      }
      
      override public function duration(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            if(_dirty)
            {
               totalDuration();
            }
            return _duration;
         }
         switch(param1)
         {
            default:
               timeScale(_duration / param1);
               break;
            case 0:
            case 0:
         }
         return this;
      }
      
      override public function totalDuration(param1:Number = NaN) : *
      {
         var _loc6_:Animation = null;
         var _loc7_:Number = NaN;
         var _loc5_:* = NaN;
         if(!arguments.length)
         {
            if(_dirty)
            {
               _loc5_ = 0;
               var _loc4_:* = _last;
               var _loc3_:Number = Infinity;
               while(_loc4_)
               {
                  _loc6_ = _loc4_._prev;
                  if(_loc4_._dirty)
                  {
                     _loc4_.totalDuration();
                  }
                  if(_loc4_._startTime > _loc3_ && _sortChildren && !_loc4_._paused)
                  {
                     add(_loc4_,_loc4_._startTime - _loc4_._delay);
                  }
                  else
                  {
                     _loc3_ = _loc4_._startTime;
                  }
                  if(_loc4_._startTime < 0 && !_loc4_._paused)
                  {
                     _loc5_ -= _loc4_._startTime;
                     if(_timeline.smoothChildTiming)
                     {
                        _startTime += _loc4_._startTime / _timeScale;
                     }
                     shiftChildren(-_loc4_._startTime,false,-9999999999);
                     _loc3_ = 0;
                  }
                  _loc7_ = _loc4_._startTime + _loc4_._totalDuration / _loc4_._timeScale;
                  if(_loc7_ > _loc5_)
                  {
                     _loc5_ = _loc7_;
                  }
                  _loc4_ = _loc6_;
               }
               _duration = _totalDuration = _loc5_;
               _dirty = false;
            }
            return _totalDuration;
         }
         if(totalDuration() != 0)
         {
            if(param1 != 0)
            {
               timeScale(_totalDuration / param1);
            }
         }
         return this;
      }
      
      public function usesFrames() : Boolean
      {
         var _loc1_:SimpleTimeline = _timeline;
         while(_loc1_._timeline)
         {
            _loc1_ = _loc1_._timeline;
         }
         return _loc1_ == _rootFramesTimeline;
      }
      
      override public function rawTime() : Number
      {
         return _paused ? _totalTime : (_timeline.rawTime() - _startTime) * _timeScale;
      }
   }
}

