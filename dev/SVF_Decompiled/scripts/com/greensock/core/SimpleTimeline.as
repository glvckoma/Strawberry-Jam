package com.greensock.core
{
   import flash.utils.getTimer;
   
   public class SimpleTimeline extends Animation
   {
      public var autoRemoveChildren:Boolean;
      
      public var smoothChildTiming:Boolean;
      
      public var _sortChildren:Boolean;
      
      public var _first:Animation;
      
      public var _last:Animation;
      
      public function SimpleTimeline(param1:Object = null)
      {
         super(0,param1);
         this.smoothChildTiming = true;
         this.autoRemoveChildren = true;
      }
      
      public function insert(param1:*, param2:* = 0) : *
      {
         return add(param1,param2 || 0);
      }
      
      public function add(param1:*, param2:* = "+=0", param3:String = "normal", param4:Number = 0) : *
      {
         var _loc5_:Number = NaN;
         param1._startTime = (Number(param2 || 0)) + param1._delay;
         if(param1._paused)
         {
            if(this != param1._timeline)
            {
               param1._pauseTime = param1._startTime + (rawTime() - param1._startTime) / param1._timeScale;
            }
         }
         if(param1.timeline)
         {
            param1.timeline._remove(param1,true);
         }
         param1.timeline = param1._timeline = this;
         if(param1._gc)
         {
            param1._enabled(true,true);
         }
         var _loc6_:Animation = _last;
         if(_sortChildren)
         {
            _loc5_ = Number(param1._startTime);
            while(_loc6_ && _loc6_._startTime > _loc5_)
            {
               _loc6_ = _loc6_._prev;
            }
         }
         if(_loc6_)
         {
            param1._next = _loc6_._next;
            _loc6_._next = Animation(param1);
         }
         else
         {
            param1._next = _first;
            _first = Animation(param1);
         }
         if(param1._next)
         {
            param1._next._prev = param1;
         }
         else
         {
            _last = Animation(param1);
         }
         param1._prev = _loc6_;
         if(_timeline)
         {
            _uncache(true);
         }
         return this;
      }
      
      public function _remove(param1:Animation, param2:Boolean = false) : *
      {
         if(param1.timeline == this)
         {
            if(!param2)
            {
               param1._enabled(false,true);
            }
            if(param1._prev)
            {
               param1._prev._next = param1._next;
            }
            else if(_first === param1)
            {
               _first = param1._next;
            }
            if(param1._next)
            {
               param1._next._prev = param1._prev;
            }
            else if(_last === param1)
            {
               _last = param1._prev;
            }
            param1._next = param1._prev = param1.timeline = null;
            if(_timeline)
            {
               _uncache(true);
            }
         }
         return this;
      }
      
      override public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var _loc4_:Animation = null;
         var _loc5_:* = _first;
         if(_loc5_)
         {
            _totalTime = _time = _rawPrevTime = param1;
            while(_loc5_)
            {
               _loc4_ = _loc5_._next;
               if(_loc5_._active || param1 >= _loc5_._startTime && !_loc5_._paused)
               {
                  if(!_loc5_._reversed)
                  {
                     _loc5_.render((param1 - _loc5_._startTime) * _loc5_._timeScale,param2,param3);
                  }
                  else
                  {
                     _loc5_.render((!_loc5_._dirty ? _loc5_._totalDuration : _loc5_.totalDuration()) - (param1 - _loc5_._startTime) * _loc5_._timeScale,param2,param3);
                  }
               }
               _loc5_ = _loc4_;
            }
            return true;
         }
         return false;
      }
      
      override public function renderCreateTime(param1:Number, param2:Number, param3:Boolean = false, param4:Boolean = false) : Boolean
      {
         var _loc5_:Animation = null;
         var _loc7_:Number = NaN;
         var _loc6_:* = _first;
         if(_loc6_)
         {
            _totalTime = _time = _rawPrevTime = _loc7_ = (getTimer() / 1000 - param1) * param2;
            while(_loc6_)
            {
               _loc5_ = _loc6_._next;
               if(_loc6_._active || _loc7_ >= _loc6_._startTime && !_loc6_._paused)
               {
                  if(!_loc6_._reversed)
                  {
                     _loc6_.render((_loc7_ - _loc6_._startTime) * _loc6_._timeScale,param3,param4);
                  }
                  else
                  {
                     _loc6_.render((!_loc6_._dirty ? _loc6_._totalDuration : _loc6_.totalDuration()) - (_loc7_ - _loc6_._startTime) * _loc6_._timeScale,param3,param4);
                  }
               }
               _loc6_ = _loc5_;
            }
            return true;
         }
         return false;
      }
      
      public function rawTime() : Number
      {
         return _totalTime;
      }
   }
}

