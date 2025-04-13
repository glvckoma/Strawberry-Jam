package com.sbi.graphics
{
   import com.sbi.corelib.Set;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class LayerAnim
   {
      public static const PLAY_LOOP:int = 0;
      
      public static const PLAY_ONE_SHOT:int = 1;
      
      public static const PLAY_LOOP__KEEP_CURRENT_FRAME:int = 2;
      
      public static const PLAY_FRAME:int = 3;
      
      public static const AN_SIT_NNE:int = 1;
      
      public static const AN_SIT_NE:int = 2;
      
      public static const AN_SIT_E:int = 3;
      
      public static const AN_SIT_SE:int = 4;
      
      public static const AN_SIT_SSE:int = 5;
      
      public static const AN_MOVE_NNE:int = 7;
      
      public static const AN_MOVE_NE:int = 8;
      
      public static const AN_MOVE_E:int = 9;
      
      public static const AN_MOVE_SE:int = 10;
      
      public static const AN_MOVE_SSE:int = 11;
      
      public static const AN_BBCARD:int = 13;
      
      public static const AN_IDLE_SE:int = 14;
      
      public static const AN_HUD_AVT:int = 15;
      
      public static const AN_IDLE_NE:int = 16;
      
      public static const AN_HOP:int = 17;
      
      public static const AN_SLEEP:int = 22;
      
      public static const AN_DANCE:int = 23;
      
      public static const AN_PLAY:int = 6;
      
      public static const AN_LEAP:int = 35;
      
      public static const AN_JUMP_EAST:int = 34;
      
      public static const AN_SWIM_N:int = 36;
      
      public static const AN_SWIM_NE:int = 34;
      
      public static const AN_SWIM_E:int = 29;
      
      public static const AN_SWIM_SE:int = 35;
      
      public static const AN_SWIM_S:int = 37;
      
      public static const AN_FLOAT:int = 32;
      
      public static const AN_WATER_DIVE:int = 41;
      
      public static const AN_WATER_PLAY:int = 39;
      
      public static const AN_WATER_SPIN:int = 33;
      
      public static const AN_WATER_JIG:int = 38;
      
      public static const AN_WATER_POSE:int = 40;
      
      public static const AN_PHOTO:int = 42;
      
      public static const AN_PARACHUTE_IDLE:int = 19;
      
      public static const AN_PARACHUTE_JUMP:int = 24;
      
      public static const AN_PARACHUTE_DISTRESS:int = 20;
      
      public static const AN_PARACHUTE_LAND:int = 21;
      
      public static const AN_WINDRIDER_JUMP:int = 28;
      
      public static const AN_WINDRIDER_IDLE:int = 29;
      
      public static const AN_WINDRIDER_FALL:int = 30;
      
      public static const AN_WINDRIDER_START:int = 31;
      
      public static const AN_WINDRIDER_DISTRESS:int = 20;
      
      public static const AVATAR_BITMAP_OFFSET_X:int = 375;
      
      public static const AVATAR_BITMAP_OFFSET_Y:int = 365;
      
      private static var _activePool:Vector.<LayerAnim>;
      
      private static var _avOffsets:Array;
      
      private static var _throttle:int = 8;
      
      private static var _lastEntry:int;
      
      private static var _useMaxThrottle:Function;
      
      private static function _isOnscreen(param1:LayerAnim):Boolean
      {
         return true;
      }
      private static function _hasSequence(param1:int):Boolean
      {
         return true;
      }
      private var _bitmap:LayerBitmap;
      
      private var _avDefId:int;
      
      private var _animId:int;
      
      private var _frame:int;
      
      private var _hFlip:Boolean;
      
      private var _totalFrames:int;
      
      private var _lastAnchorPoint:Point;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _rotation:int;
      
      private var _xOff:int;
      
      private var _yOff:int;
      
      private var _bReposition:Boolean;
      
      private var _bPause:Boolean;
      
      private var _layers:Array;
      
      private var _colors:Array;
      
      private var _callback:Function;
      
      private var _mode:int;
      
      private var _tStep:int;
      
      private var _bReload:Boolean;
      
      private var _avatarEnabled:Boolean = true;
      
      private var _requestAnimId:int;
      
      private var _receivedData:Array;
      
      private var _requestedIds:Set;
      
      private var _requestedCacheKey:String;
      
      private var _requestCallback:Function;
      
      private var _requestMode:int;
      
      private var _preloadRequestedIds:Set;
      
      private var _preloadCallback:Function;
      
      private var _bounceEnabled:Boolean;
      
      private var _bounceOverride:Boolean;
      
      private var _bounceOffSet:int;
      
      private var _local:Boolean;
      
      private var _skipWorldCheck:Boolean;
      
      public function LayerAnim(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid access.  Use LayerAnim.getNew");
         }
      }
      
      public static function set avOffsets(param1:Array) : void
      {
         _avOffsets = param1;
      }
      
      public static function getAvOffset(param1:int) : Point
      {
         if(_avOffsets[param1])
         {
            return _avOffsets[param1];
         }
         return new Point(-100,-100);
      }
      
      public static function set throttle(param1:int) : void
      {
         _throttle = param1;
      }
      
      public static function getNew(param1:Boolean = false) : LayerAnim
      {
         if(!_activePool)
         {
            _activePool = new Vector.<LayerAnim>();
         }
         var _loc2_:LayerAnim = new LayerAnim(SingletonLock);
         _activePool.push(_loc2_);
         _loc2_.init(param1);
         return _loc2_;
      }
      
      public static function destroy(param1:LayerAnim) : void
      {
         var _loc2_:int = int(_activePool.indexOf(param1));
         if(_loc2_ >= 0)
         {
            _activePool.splice(_loc2_,1);
            if(_loc2_ > 0 && _lastEntry >= _loc2_)
            {
               _lastEntry--;
            }
            param1.destroy();
         }
      }
      
      public static function heartbeat() : void
      {
         var _loc2_:int = 0;
         var _loc4_:* = 0;
         var _loc1_:int = 0;
         var _loc5_:int = 0;
         if(_activePool && _activePool.length)
         {
            _loc2_ = int(_activePool.length);
            _loc4_ = _loc2_;
            _loc1_ = _loc2_ * 0.5;
            if(_loc1_ < 1 || _useMaxThrottle && _useMaxThrottle())
            {
               _loc1_ = 1;
            }
            if(_loc1_ > _throttle)
            {
               _loc1_ = _throttle;
            }
            _loc5_ = _lastEntry;
            for each(var _loc3_ in _activePool)
            {
               _loc3_._tStep++;
            }
            while(_loc1_ > 0 && _loc4_ > 0)
            {
               if(_loc5_ >= _loc2_)
               {
                  _loc5_ = 0;
               }
               _loc3_ = _activePool[_loc5_++];
               if(_loc3_._tStep >= 2)
               {
                  _loc3_._tStep = 0;
                  if((_loc3_._requestMode == 1 || _isOnscreen(_loc3_) || _loc3_._skipWorldCheck) && _loc3_.heartbeat())
                  {
                     _loc1_--;
                  }
               }
               _loc4_--;
            }
            _lastEntry = _loc5_;
         }
      }
      
      public static function set useMaxThrottle(param1:Function) : void
      {
         _useMaxThrottle = param1;
      }
      
      public static function set isOnscreen(param1:Function) : void
      {
         if(param1 != null)
         {
            _isOnscreen = param1;
         }
      }
      
      public static function set hasSequence(param1:Function) : void
      {
         if(param1 != null)
         {
            _hasSequence = param1;
         }
      }
      
      public static function trimAnims() : Set
      {
         var _loc2_:Set = new Set();
         if(_activePool && _activePool.length)
         {
            for each(var _loc1_ in _activePool)
            {
               _loc2_.addAll(_loc1_.bitmap.trimLayerGroups());
            }
         }
         return _loc2_;
      }
      
      public function get bounceOffSet() : int
      {
         return _bounceOffSet;
      }
      
      public function get bounceEnabled() : Boolean
      {
         return _bounceEnabled;
      }
      
      public function set bounceEnabled(param1:Boolean) : void
      {
         _bounceEnabled = param1;
      }
      
      public function set local(param1:Boolean) : void
      {
         _local = param1;
      }
      
      private function init(param1:Boolean = false) : void
      {
         _bitmap = new LayerBitmap();
         _bitmap.pixelSnapping = "always";
         _layers = null;
         _requestAnimId = -1;
         _avDefId = -1;
         _animId = -1;
         _totalFrames = 0;
         _lastAnchorPoint = new Point(0,0);
         _bReposition = true;
         _bReload = true;
         _tStep = 1;
         _bounceEnabled = false;
         _avatarEnabled = true;
         _skipWorldCheck = param1;
         _preloadRequestedIds = new Set();
         _requestedIds = new Set();
      }
      
      private function destroy() : void
      {
         if(_bitmap)
         {
            _bitmap.destroy();
            _bitmap = null;
         }
         ImageServerURL.instance.removeEventListener("OnNewData",onReceiveData);
         _layers = null;
         _callback = null;
         _preloadRequestedIds.clear();
         _requestedIds.clear();
      }
      
      public function set avDefId(param1:int) : void
      {
         if(param1 != _avDefId)
         {
            _avDefId = param1;
            _xOff = -getAvOffset(_avDefId).x - 375;
            _yOff = -getAvOffset(_avDefId).y - 365;
            _bReposition = true;
            _bReload = true;
         }
      }
      
      public function get layers() : Array
      {
         return _layers;
      }
      
      public function get avDefId() : int
      {
         return _avDefId;
      }
      
      public function get animId() : int
      {
         return _animId;
      }
      
      public function get hFlip() : Boolean
      {
         return _hFlip;
      }
      
      public function get frame() : int
      {
         return _frame;
      }
      
      public function set frame(param1:int) : void
      {
         _frame = param1;
      }
      
      public function set avatarEnabled(param1:Boolean) : void
      {
         _avatarEnabled = param1;
      }
      
      public function set layers(param1:Array) : void
      {
         var _loc2_:Boolean = true;
         var _loc3_:Boolean = false;
         if(_layers && _layers.length == param1.length)
         {
            _loc2_ = false;
            for(var _loc4_ in param1)
            {
               if(!_layers[_loc4_] || _layers[_loc4_].l != param1[_loc4_].l)
               {
                  _loc2_ = true;
                  break;
               }
               if(_layers[_loc4_].c != param1[_loc4_].c)
               {
                  _loc3_ = true;
               }
            }
            if(!_loc2_ && !_loc3_)
            {
               return;
            }
         }
         if(param1.length > 0)
         {
            _layers = param1;
            if(_loc2_)
            {
               _bReload = true;
            }
            else if(_loc3_)
            {
               for each(var _loc5_ in param1)
               {
                  _bitmap.setLayerColor(ImageServerURL.instance.getLayerIndex(_loc5_.l),_loc5_.c);
               }
            }
         }
      }
      
      public function get x() : int
      {
         return _x;
      }
      
      public function get y() : int
      {
         return _y;
      }
      
      public function set x(param1:int) : void
      {
         if(_x != param1)
         {
            _x = param1;
            _bReposition = true;
         }
      }
      
      public function set y(param1:int) : void
      {
         if(_y != param1)
         {
            _y = param1;
            _bReposition = true;
         }
      }
      
      public function set alpha(param1:Number) : void
      {
         _bitmap.alpha = param1;
      }
      
      public function set rotation(param1:Number) : void
      {
         if(_rotation != param1)
         {
            _rotation = param1;
            _bReposition = true;
         }
      }
      
      public function set hFlip(param1:Boolean) : void
      {
         if(param1 != _hFlip)
         {
            _hFlip = param1;
         }
      }
      
      public function set visible(param1:Boolean) : void
      {
         _bitmap.visible = param1;
      }
      
      public function get visible() : Boolean
      {
         return _bitmap.visible;
      }
      
      public function set pause(param1:Boolean) : void
      {
         _bPause = param1;
      }
      
      public function get bitmap() : LayerBitmap
      {
         return _bitmap;
      }
      
      public function playAnim(param1:int, param2:int = 0, param3:Function = null, param4:int = 0) : void
      {
         if(_requestAnimId == -1 && param1 != _animId || _requestAnimId != param1 || param2 == 3)
         {
            _requestCallback = param3;
            _requestMode = param2;
            _requestAnimId = param1;
            _bReload = true;
            _bounceOverride = param1 != 17;
         }
      }
      
      public function preload(param1:Array, param2:Function) : void
      {
         var _loc4_:int = 0;
         _preloadCallback = param2;
         var _loc3_:Array = [];
         while(_loc4_ < param1.length)
         {
            buildRequestArray(param1[_loc4_],_loc3_,null);
            _loc4_++;
         }
         _preloadRequestedIds.addAll(_loc3_);
         requestImages(_loc3_);
      }
      
      private function heartbeat() : Boolean
      {
         var _loc1_:Boolean = false;
         if(_bReload)
         {
            loadAnim();
         }
         if(_totalFrames == 0)
         {
            return false;
         }
         if(_mode == 3 && _callback != null)
         {
            _callback(_totalFrames);
            _callback = null;
         }
         if(_frame >= _totalFrames)
         {
            if(_mode == 1)
            {
               _frame = _totalFrames > 0 ? _totalFrames - 1 : 0;
            }
            else
            {
               _frame = 0;
            }
            if(_callback != null)
            {
               _callback(this,_animId);
               _callback = null;
            }
         }
         if(_avatarEnabled)
         {
            _lastAnchorPoint.copyFrom(_bitmap.anchorPoint);
            _loc1_ = _bitmap.paint(_frame,_hFlip);
            if(!_lastAnchorPoint.equals(_bitmap.anchorPoint))
            {
               _bReposition = true;
            }
         }
         calcBounceOffset();
         if(_bReposition)
         {
            updateBitmapPos();
         }
         if(!_bPause && _mode != 3)
         {
            _frame++;
         }
         return _loc1_;
      }
      
      private function calcBounceOffset() : void
      {
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         if(_bounceEnabled && !_bounceOverride)
         {
            _loc3_ = _bounceOffSet;
            _loc1_ = 75;
            _loc2_ = (_frame + 1) / _totalFrames;
            _bounceOffSet = (1 - (2 * _loc2_ - 1) * (2 * _loc2_ - 1)) * _loc1_;
            if(_bounceOffSet != _loc3_)
            {
               if(_local && _frame == 0)
               {
                  SBAudio.playCachedSound("BOUNCE");
               }
               _bReposition = true;
            }
         }
         else if(_bounceOffSet != 0)
         {
            _bounceOffSet = 0;
            _bReposition = true;
         }
      }
      
      private function updateBitmapPos() : void
      {
         var _loc3_:Matrix = null;
         var _loc4_:Point = _bitmap.anchorPoint;
         var _loc1_:int = _x + _loc4_.x + _xOff;
         var _loc2_:int = _y + _loc4_.y + _yOff - _bounceOffSet;
         if(_rotation)
         {
            _loc3_ = _bitmap.transform.matrix;
            _loc3_.identity();
            _loc3_.translate(_loc4_.x + _xOff,_loc4_.y + _yOff);
            _loc3_.rotate(_rotation * (3.141592653589793 / 180));
            _loc3_.translate(_loc1_,_loc2_);
            _bitmap.transform.matrix = _loc3_;
         }
         else
         {
            if(_bitmap.rotation != _rotation)
            {
               _bitmap.rotation = _rotation;
            }
            _bitmap.x = _loc1_;
            _bitmap.y = _loc2_;
         }
         _bReposition = false;
      }
      
      private function loadAnim() : void
      {
         var _loc1_:int = 0;
         if(_layers != null && _layers.length > 0)
         {
            _loc1_ = _requestAnimId != -1 ? _requestAnimId : _animId;
            if(_loc1_ >= 0)
            {
               _requestAnimId = _loc1_;
               requestAnim(_loc1_);
            }
         }
      }
      
      private function requestAnim(param1:int) : void
      {
         _bReload = false;
         var _loc4_:Array = [];
         var _loc2_:Array = [];
         buildRequestArray(param1,_loc2_,_loc4_);
         _loc2_.sort();
         var _loc3_:String = _loc2_.join();
         _colors = _loc4_;
         _requestedCacheKey = _loc3_;
         _receivedData = [];
         _requestedIds = new Set();
         _requestedIds.addAll(_loc2_);
         requestImages(_loc2_);
      }
      
      private function buildRequestArray(param1:int, param2:Array, param3:Array) : void
      {
         var _loc4_:uint = ImageArrayHelper.packId(_avDefId,param1,0);
         if(_hasSequence(_loc4_))
         {
            param2.push(_loc4_);
         }
         for each(var _loc5_ in _layers)
         {
            _loc4_ = ImageArrayHelper.packId(_avDefId,param1,_loc5_.l);
            param2.push(_loc4_);
            if(param3)
            {
               param3[_loc4_] = _loc5_.c;
            }
         }
      }
      
      private function requestImages(param1:Array) : void
      {
         ImageServerURL.instance.addEventListener("OnNewData",onReceiveData,false,0,true);
         for each(var _loc2_ in param1)
         {
            ImageServerURL.instance.requestImage(_loc2_);
         }
      }
      
      private function onReceiveData(param1:ImageServerEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         if(_preloadRequestedIds.remove(param1.id))
         {
            if(_preloadRequestedIds.isEmpty())
            {
               if(_requestedIds.isEmpty())
               {
                  ImageServerURL.instance.removeEventListener("OnNewData",onReceiveData);
               }
               if(_preloadCallback != null)
               {
                  _preloadCallback(this);
               }
            }
         }
         if(_requestedIds.remove(param1.id))
         {
            _loc3_ = param1.layer;
            if(_loc3_ > 0)
            {
               _loc2_ = uint(_colors[param1.id]);
            }
            if(param1.success)
            {
               _receivedData.push({
                  "l":_loc3_,
                  "d":param1.imageData,
                  "c":_loc2_
               });
            }
            if(_requestedIds.isEmpty())
            {
               if(_preloadRequestedIds.isEmpty())
               {
                  ImageServerURL.instance.removeEventListener("OnNewData",onReceiveData);
               }
               for each(var _loc4_ in _receivedData)
               {
                  _bitmap.setLayer(_loc4_.l,_loc4_.d,_loc4_.c,_requestedCacheKey);
               }
               finishAnimRequest();
               _receivedData = null;
               _requestedCacheKey = null;
               _colors = null;
            }
         }
      }
      
      private function finishAnimRequest() : void
      {
         if(_mode != 2 && _mode != 3)
         {
            _frame = 0;
         }
         _mode = _requestMode;
         if(_requestAnimId >= 0)
         {
            _animId = _requestAnimId;
         }
         _requestAnimId = -1;
         _callback = _requestCallback;
         _totalFrames = _bitmap.length;
      }
   }
}

class SingletonLock
{
   public function SingletonLock()
   {
      super();
   }
}
