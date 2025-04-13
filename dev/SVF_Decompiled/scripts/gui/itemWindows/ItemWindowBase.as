package gui.itemWindows
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.LoadingSpiral;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   import inventory.Iitem;
   import loader.MediaHelper;
   
   public class ItemWindowBase extends MovieClip
   {
      protected var _window:MovieClip;
      
      protected var _currItem:Object;
      
      protected var _mouseDown:Function;
      
      protected var _mouseOver:Function;
      
      protected var _mouseOut:Function;
      
      protected var _memberOnlyDown:Function;
      
      protected var _index:int;
      
      protected var _visibilityIndex:int;
      
      protected var _spiral:LoadingSpiral;
      
      protected var _windowLoadedCallback:Function;
      
      protected var _iconLayerName:String;
      
      protected var _isCurrItemLoaded:Boolean;
      
      protected var _itemYLocation:int;
      
      protected var _itemXLocation:int;
      
      protected var _useToolTip:Boolean;
      
      protected var _windowGenerator:Object;
      
      protected var _runningMovieClips:Array;
      
      protected var _callbackToCallWhenImageLoads:Function;
      
      private var _windowMediaHelper:MediaHelper;
      
      private var _memberOnlyTrackingName:String;
      
      public function ItemWindowBase(param1:*, param2:Function, param3:Object, param4:String, param5:int, param6:Function, param7:Function, param8:Function, param9:Function, param10:Boolean = false)
      {
         var _loc11_:Array = null;
         super();
         _currItem = param3;
         _iconLayerName = param4;
         _mouseDown = param6;
         _mouseOver = param7;
         _mouseOut = param8;
         _memberOnlyDown = param9;
         _index = param5;
         _visibilityIndex = param5;
         _windowLoadedCallback = param2;
         _useToolTip = param10;
         if(param1 is String)
         {
            _loc11_ = param1.split("|");
            _window = GETDEFINITIONBYNAME(_loc11_[0],_loc11_.length > 1 ? false : true);
            addChild(_window);
            onWindowLoadCallback();
         }
         else if(param1 is int)
         {
            _windowMediaHelper = new MediaHelper();
            _windowMediaHelper.init(param1,onWindowLoaded);
         }
         else
         {
            if(!(param1 is MovieClip))
            {
               throw new Error("windowClassOrId is not of type string or int. windowClassOrIdOrMovieClip = " + param1);
            }
            _window = param1;
            addChild(_window);
            onWindowLoadCallback();
         }
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         if(_spiral)
         {
            _spiral.destroy();
         }
         if(_windowMediaHelper)
         {
            _windowMediaHelper.destroy();
         }
         if(_window && _window.parent == this)
         {
            removeChild(_window);
         }
         if(_currItem && _currItem.hasOwnProperty("destroy"))
         {
            _currItem.destroy();
         }
         _windowGenerator = null;
         _window = null;
         _windowLoadedCallback = null;
         _currItem = null;
         _mouseDown = null;
         _mouseOver = null;
         _mouseOut = null;
      }
      
      public function get index() : int
      {
         return _index;
      }
      
      public function set index(param1:int) : void
      {
         _index = param1;
      }
      
      public function get visibilityIndex() : int
      {
         return _visibilityIndex;
      }
      
      public function set visibilityIndex(param1:int) : void
      {
         _visibilityIndex = param1;
      }
      
      override public function get width() : Number
      {
         if("sizeCont" in _window && _window.sizeCont)
         {
            return _window.sizeCont.width;
         }
         return super.width;
      }
      
      override public function get height() : Number
      {
         if("sizeCont" in _window && _window.sizeCont)
         {
            return _window.sizeCont.height;
         }
         return super.height;
      }
      
      public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
         var _loc3_:int = 0;
         if(param1)
         {
            if(this.visible == false)
            {
               if(_runningMovieClips != null)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _runningMovieClips.length)
                  {
                     MovieClip(_runningMovieClips[_loc3_]).play();
                     _loc3_++;
                  }
               }
               this.visible = true;
            }
         }
         else if(this.visible == true)
         {
            if(_runningMovieClips == null)
            {
               if(param2 == null)
               {
                  param2 = _currItem;
               }
               if(param2 is Iitem)
               {
                  if(!Iitem(param2).isIconLoaded)
                  {
                     if(Iitem(param2).imageLoadedCallback != null && Iitem(param2).imageLoadedCallback != onImageIconLoaded)
                     {
                        _callbackToCallWhenImageLoads = Iitem(param2).imageLoadedCallback;
                     }
                     Iitem(param2).imageLoadedCallback = onImageIconLoaded;
                     return;
                  }
                  _runningMovieClips = [];
                  findAndSetAllRunningMovieClips(Iitem(param2).icon);
               }
               else
               {
                  _runningMovieClips = [];
                  findAndSetAllRunningMovieClips(param2);
               }
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < _runningMovieClips.length)
               {
                  MovieClip(_runningMovieClips[_loc3_]).stop();
                  _loc3_++;
               }
            }
            this.visible = false;
         }
      }
      
      public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(_currItem && !(_currItem is int) && !_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
            if(_iconLayerName != "" && Boolean(_currItem.hasOwnProperty(_iconLayerName)))
            {
               _window.addChild(_currItem[_iconLayerName]);
            }
            else if(_window != _currItem)
            {
               _window.addChild(DisplayObject(_currItem));
            }
         }
      }
      
      protected function findAndSetAllRunningMovieClips(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            if(param1 is MovieClip && MovieClip(param1).totalFrames > 1 && MovieClip(param1).currentFrame != 1)
            {
               MovieClip(param1).stop();
               _runningMovieClips.push(param1);
            }
            if(param1.hasOwnProperty("numChildren"))
            {
               _loc2_ = 0;
               while(_loc2_ < param1.numChildren)
               {
                  findAndSetAllRunningMovieClips(param1.getChildAt(_loc2_));
                  _loc2_++;
               }
            }
         }
      }
      
      protected function onWindowLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _window = MovieClip(param1.getChildAt(0));
            addChild(_window);
            onWindowLoadCallback();
            _windowMediaHelper.destroy();
            _windowMediaHelper = null;
         }
      }
      
      protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         if(_windowLoadedCallback != null)
         {
            _windowLoadedCallback(this);
         }
      }
      
      protected function onImageIconLoaded(param1:Object = null, ... rest) : void
      {
         var _loc3_:Function = null;
         setStatesForVisibility(false);
         if(_callbackToCallWhenImageLoads != null)
         {
            rest.insertAt(0,param1);
            _loc3_ = _callbackToCallWhenImageLoads;
            _callbackToCallWhenImageLoads = null;
            _loc3_.apply(null,rest);
         }
      }
      
      protected function setChildrenAndInitialConditions() : void
      {
      }
      
      protected function onWindowRollOver(param1:MouseEvent) : void
      {
         if(_useToolTip && this.parent != null)
         {
            if(_windowGenerator == null)
            {
               if(this.parent.parent is WindowGenerator)
               {
                  _windowGenerator = WindowGenerator(this.parent.parent);
               }
               else
               {
                  _windowGenerator = WindowAndScrollbarGenerator(this.parent.parent);
               }
            }
            if(_currItem && _windowGenerator.isIndexInView(_visibilityIndex))
            {
               _windowGenerator.toolTip.init(_windowGenerator.parent.parent,_currItem.name,this.x + _windowGenerator.boxWidth * 0.5 - _itemXLocation + _windowGenerator.parent.x,this.y + _windowGenerator.boxHeight - _itemYLocation + _windowGenerator.parent.y - 5);
               _windowGenerator.toolTip.startTimer(param1);
            }
         }
      }
      
      protected function onWindowRollOut(param1:MouseEvent) : void
      {
         if(_windowGenerator && _useToolTip && this.parent != null)
         {
            _windowGenerator.toolTip.resetTimerAndSetVisibility();
         }
      }
      
      protected function addEventListeners() : void
      {
         if(_window && _currItem)
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               if(_useToolTip)
               {
                  addEventListener("rollOver",onWindowRollOver,false,0,true);
               }
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               if(_useToolTip)
               {
                  addEventListener("rollOut",onWindowRollOut,false,0,true);
               }
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
      
      protected function removeEventListeners() : void
      {
         if(_mouseDown != null)
         {
            removeEventListener("mouseDown",_mouseDown);
         }
         if(_mouseOver != null)
         {
            if(_useToolTip)
            {
               removeEventListener("rollOver",onWindowRollOver);
            }
            removeEventListener("rollOver",_mouseOver);
         }
         if(_mouseOut != null)
         {
            if(_useToolTip)
            {
               removeEventListener("rollOut",onWindowRollOut);
            }
            removeEventListener("rollOut",_mouseOut);
         }
         if(_memberOnlyDown != null)
         {
            removeEventListener("mouseDown",_memberOnlyDown);
         }
      }
   }
}

