package gui
{
   import flash.display.MovieClip;
   import gui.itemWindows.ItemWindowBase;
   
   public class WindowAndScrollbarGenerator extends MovieClip
   {
      public var bg:MovieClip;
      
      public var numWindowsCreated:int;
      
      public var toolTip:ToolTipPopup;
      
      private var _xWinVis:int;
      
      private var _yWinVis:int;
      
      private var _numRows:int;
      
      private var _numCols:int;
      
      private var _totalNumWin:int;
      
      private var _winWidth:int;
      
      private var _winHeight:int;
      
      private var _boxWidth:int;
      
      private var _boxHeight:int;
      
      private var _xOffset:Number;
      
      private var _yOffset:Number;
      
      private var _xStart:Number;
      
      private var _numToCreated:int;
      
      private var _fillCompletely:Boolean;
      
      private var _mediaWindows:Array;
      
      private var _singleLoadWindow:MovieClip;
      
      private var _numLoaded:int;
      
      private var _numSpecificNameWindowsLoaded:int;
      
      private var _callback:Function;
      
      private var _mouseDown:Function;
      
      private var _mouseOver:Function;
      
      private var _mouseOut:Function;
      
      private var _mouseMemberOnlyDown:Function;
      
      private var _dynamicScrollbar:SBDynamicScrollbar;
      
      private var _isSideways:Boolean;
      
      private var _windowClass:Class;
      
      private var _itemList:Array;
      
      private var _iconLayerName:String;
      
      private var _customParams:Object;
      
      private var _loading:Boolean;
      
      private var _loadingQueue:Array;
      
      private var _manyLoadedWindows:Array;
      
      private var _moreLoadedWindows:Array;
      
      private var _specificLoadedWindows:Array;
      
      private var _specificLoadedIndexes:Object;
      
      private var _updateScrollPosition:Boolean;
      
      private var _manyLoadingWindowIndexOffset:int;
      
      private var _maxNumWindows:int;
      
      private var _onInsertManyCallback:Function;
      
      private var _onPaginationLoadCallback:Function;
      
      private var _onPaginationLoadArgs:Array;
      
      private var _onLoadSpecificNameCallback:Function;
      
      private var _onReloadCallback:Function;
      
      private var _onReloadPassbackArgs:Array;
      
      private var _reloadMediaWindows:Array;
      
      private var _insertAtTop:Boolean;
      
      private var _numWindowsToLoad:int;
      
      private var _numSpecificNameWindowsToLoad:int;
      
      private var _numWindowsPerScreen:int;
      
      private var _windowsToAddToEnd:Array;
      
      private var _adjustListOnInsert:Boolean;
      
      private var _contentPositionUpdateCallback:Function;
      
      public function WindowAndScrollbarGenerator()
      {
         super();
      }
      
      public function init(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:int, param8:Number, param9:Number, param10:Number, param11:Number, param12:Class, param13:Array, param14:String, param15:int = 0, param16:Object = null, param17:Object = null, param18:Function = null, param19:Boolean = true, param20:Boolean = false, param21:Boolean = true, param22:Boolean = false, param23:Boolean = false, param24:Boolean = true, param25:Boolean = false) : void
      {
         _xWinVis = param5;
         _yWinVis = param6;
         _totalNumWin = !!param13 ? param13.length : 0;
         _maxNumWindows = param15;
         _xOffset = param8;
         _yOffset = param9;
         _xStart = param10;
         _fillCompletely = param21;
         _callback = param18;
         _isSideways = param20;
         _windowClass = param12;
         _itemList = param13;
         _iconLayerName = param14;
         _customParams = param17;
         _adjustListOnInsert = param24;
         if(_fillCompletely)
         {
            param7 = _xWinVis * _yWinVis;
         }
         if(_totalNumWin < param7)
         {
            _totalNumWin = param7;
         }
         if(param20)
         {
            _numRows = param6;
            _numCols = Math.ceil(_totalNumWin / _yWinVis);
            _numWindowsPerScreen = Math.max(1,_xWinVis * _yWinVis);
         }
         else
         {
            _numRows = Math.ceil(_totalNumWin / _xWinVis);
            _numCols = param5;
            _numWindowsPerScreen = Math.max(1,_xWinVis * _yWinVis);
         }
         if(param16 != null)
         {
            _mouseDown = param16.mouseDown;
            _mouseOut = param16.mouseOut;
            _mouseOver = param16.mouseOver;
            _mouseMemberOnlyDown = param16.memberOnlyDown;
         }
         bg = new MovieClip();
         bg.graphics.beginFill(0);
         bg.graphics.drawRect(0,0,0,0);
         addChild(bg);
         _dynamicScrollbar = new SBDynamicScrollbar(bg,param1,param2,param7,param5,param6,param8,param9,param10,param11,param3,_maxNumWindows,param19,param4,-1,param22,param23,param20,param25);
         _mediaWindows = [];
         _loadingQueue = [];
         _manyLoadedWindows = [];
         _moreLoadedWindows = [];
         _specificLoadedWindows = [];
         _reloadMediaWindows = [];
         _specificLoadedIndexes = {};
         _windowsToAddToEnd = [];
         _numLoaded = 0;
         _numSpecificNameWindowsLoaded = 0;
         toolTip = ToolTipPopup(GETDEFINITIONBYNAME("Tooltip"));
         var _loc26_:int = 100 / _numWindowsPerScreen * _numWindowsPerScreen;
         if(_loc26_ > _totalNumWin)
         {
            _loc26_ = _totalNumWin;
         }
         loadWindows(_loc26_,onInitialWindowsLoaded,true,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_dynamicScrollbar)
         {
            _dynamicScrollbar.destroy();
            _dynamicScrollbar = null;
         }
         if(bg)
         {
            while(bg.numChildren > 0)
            {
               bg.removeChildAt(0);
            }
            if(bg.parent == this)
            {
               removeChild(bg);
            }
         }
         if(_mediaWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaWindows.length)
            {
               if(_mediaWindows[_loc1_] != null && _mediaWindows[_loc1_].hasOwnProperty("destroy"))
               {
                  _mediaWindows[_loc1_].destroy();
               }
               _loc1_++;
            }
            _mediaWindows = null;
         }
         if(toolTip)
         {
            toolTip.resetTimerAndSetVisibility();
            toolTip = null;
         }
         bg = null;
         _contentPositionUpdateCallback = null;
      }
      
      public function get boxHeight() : int
      {
         return _boxHeight;
      }
      
      public function get boxWidth() : int
      {
         return _boxWidth;
      }
      
      public function get mediaWindows() : Array
      {
         return _mediaWindows;
      }
      
      public function get scrollYValue() : Number
      {
         return _dynamicScrollbar.scrollYValue;
      }
      
      public function set customStartScrollYValue(param1:Number) : void
      {
         _dynamicScrollbar.startScrollYValue = param1;
      }
      
      public function get totalNumWindows() : int
      {
         return _totalNumWin;
      }
      
      public function get numWindowsPerScreen() : int
      {
         return _numWindowsPerScreen;
      }
      
      public function set contentPositionUpdateCallback(param1:Function) : void
      {
         _contentPositionUpdateCallback = param1;
      }
      
      public function set preventGrayStateButtons(param1:Boolean) : void
      {
         _dynamicScrollbar.preventGrayStateButtons = param1;
      }
      
      public function deleteItem(param1:int, param2:*, param3:Boolean = true, param4:Boolean = true) : void
      {
         var _loc6_:Array = null;
         var _loc5_:int = 0;
         if(_dynamicScrollbar.deleteTweenItem(param1))
         {
            _totalNumWin--;
            _numLoaded--;
            _numWindowsToLoad--;
            _loc6_ = _mediaWindows.splice(param1,1);
            _loc5_ = 100 / _numWindowsPerScreen * _numWindowsPerScreen;
            if(_numLoaded + _loc5_ > _totalNumWin)
            {
               _loc5_ = _totalNumWin - _numLoaded;
            }
            if(param4 && _loc5_ > 0 && _loc6_.length > 0)
            {
               _windowsToAddToEnd.push(_loc6_[0]);
            }
            if(param3)
            {
               if(param2 && param2 != _itemList)
               {
                  param2.splice(param1,1);
               }
               _itemList.splice(param1,1);
            }
         }
         else
         {
            _loc6_ = _mediaWindows.splice(param1,1);
            if(param4 && _loc6_.length > 0)
            {
               _mediaWindows.push(_loc6_[0]);
            }
            if(param3)
            {
               if(param2 && param2 != _itemList)
               {
                  _loc6_ = param2.splice(param1,1);
                  if(param4 && _loc6_.length > 0)
                  {
                     param2.push(_loc6_[0]);
                  }
               }
               _loc6_ = _itemList.splice(param1,1);
               if(param4 && _loc6_.length > 0)
               {
                  _itemList.push(_loc6_[0]);
               }
            }
         }
      }
      
      public function isIndexInView(param1:int) : Boolean
      {
         return _dynamicScrollbar.getIsIndexInView(param1);
      }
      
      public function get scrollContentHeight() : Number
      {
         if(_dynamicScrollbar)
         {
            return _dynamicScrollbar.scrollContentHeight;
         }
         return 0;
      }
      
      public function insertItem(param1:*, param2:Boolean, param3:Boolean = false) : void
      {
         _insertAtTop = param3;
         if(param1 != null)
         {
            if(_itemList)
            {
               if(param3)
               {
                  _itemList.unshift(param1);
               }
               else
               {
                  _itemList.push(param1);
               }
            }
         }
         loadWindows(1,onSingleWindowLoaded,param2);
      }
      
      public function insertItemAtSpecificPosition(param1:*, param2:Boolean, param3:int) : void
      {
         _insertAtTop = false;
         if(param1 != null)
         {
            if(_itemList)
            {
               _itemList.splice(param3,0,param1);
            }
            _mediaWindows.splice(param3,0,null);
            loadWindows(1,onSingleSpecificWindowLoaded,param2,false,[param3]);
         }
      }
      
      public function insertManyItems(param1:Array, param2:Boolean, param3:Boolean = false, param4:Function = null, param5:Boolean = true) : void
      {
         var _loc6_:int = 0;
         _insertAtTop = param3;
         if(_itemList && param5)
         {
            _loc6_ = 0;
            while(_loc6_ < param1.length)
            {
               if(param1[_loc6_] != null)
               {
                  _itemList.push(param1[_loc6_]);
               }
               _loc6_++;
            }
         }
         _onInsertManyCallback = param4;
         _manyLoadingWindowIndexOffset = _insertAtTop ? 0 : _dynamicScrollbar.getNumOfAssets();
         loadWindows(param1.length,onManyWindowsLoaded,param2);
      }
      
      public function updateItem(param1:int, param2:*) : void
      {
         _dynamicScrollbar.updateItem(param1,param2);
      }
      
      public function findItemAndUpdate(param1:*) : void
      {
         _dynamicScrollbar.findItemAndUpdate(param1);
      }
      
      public function findItemWithTypeAndUpdate(param1:*, param2:String) : void
      {
         _dynamicScrollbar.findItemWithTypeAndUpdate(param1,param2);
      }
      
      public function findOpenWindowAndUpdate(param1:*) : void
      {
         _dynamicScrollbar.findOpenAndUpdate(param1);
      }
      
      public function callUpdateInWindow() : void
      {
         var _loc1_:int = 0;
         if(_mediaWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaWindows.length)
            {
               if(_mediaWindows[_loc1_] && _mediaWindows[_loc1_].hasOwnProperty("update"))
               {
                  _mediaWindows[_loc1_].update();
               }
               _loc1_++;
            }
         }
      }
      
      public function callUpdateInWindowWithInput(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(_mediaWindows)
         {
            _loc2_ = 0;
            while(_loc2_ < _mediaWindows.length)
            {
               if(_mediaWindows[_loc2_] && _mediaWindows[_loc2_].hasOwnProperty("update"))
               {
                  _mediaWindows[_loc2_].update(param1);
               }
               _loc2_++;
            }
         }
      }
      
      public function callUpdateOnWindowWithInput(param1:int, param2:Object) : void
      {
         if(_mediaWindows[param1] && _mediaWindows[param1].hasOwnProperty("update"))
         {
            _mediaWindows[param1].update(param2);
         }
      }
      
      public function callUpdateOnWindow(param1:int) : Boolean
      {
         if(_mediaWindows[param1] && _mediaWindows[param1].hasOwnProperty("update"))
         {
            _mediaWindows[param1].update();
            return true;
         }
         return false;
      }
      
      public function handleSearchInput(param1:String) : void
      {
         _dynamicScrollbar.handleSearchInput(param1);
      }
      
      public function loadMoreWithSpecificName(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         _loc3_ = _numLoaded;
         while(_loc3_ < _totalNumWin)
         {
            if(_itemList[_loc3_].name.toLowerCase().indexOf(param1) != -1)
            {
               if(!_specificLoadedIndexes[_loc3_])
               {
                  _loc2_.push(_loc3_);
                  _specificLoadedIndexes[_loc3_] = true;
               }
            }
            if(_loc2_.length == 100)
            {
               break;
            }
            _loc3_++;
         }
         if(_loc2_.length > 0)
         {
            loadWindows(_loc2_.length,onLoadSpecificNameWindows,true,false,_loc2_);
         }
      }
      
      public function reloadInitialSet(param1:Function, ... rest) : void
      {
         var _loc3_:int = 100 / _numWindowsPerScreen * _numWindowsPerScreen;
         if(_loc3_ > _totalNumWin)
         {
            _loc3_ = _totalNumWin;
         }
         _loadingQueue = [];
         _manyLoadedWindows = [];
         _moreLoadedWindows = [];
         _specificLoadedWindows = [];
         _specificLoadedIndexes = {};
         _reloadMediaWindows = [];
         _numLoaded = 0;
         _numWindowsToLoad = 0;
         _numSpecificNameWindowsLoaded = 0;
         _manyLoadingWindowIndexOffset = 0;
         numWindowsCreated = 0;
         _onReloadCallback = param1;
         _onReloadPassbackArgs = rest;
         loadWindows(_loc3_,onReloadInitialWindows,true,true);
      }
      
      public function handleScrollBtnClick(param1:Boolean) : void
      {
         _dynamicScrollbar.handleExternalScrollClick(param1);
      }
      
      public function scrollToIndex(param1:int, param2:Boolean) : void
      {
         _dynamicScrollbar.scrollToElement(param1,param2);
      }
      
      public function findAndScrollTo(param1:String, param2:Object, param3:Boolean) : void
      {
         _dynamicScrollbar.findItemAndScrollTo(param1,param2,param3);
      }
      
      public function onScrollContentPositionUpdate(param1:Number) : void
      {
         if(_contentPositionUpdateCallback != null)
         {
            _contentPositionUpdateCallback(param1);
         }
      }
      
      private function loadWindows(param1:int, param2:Function, param3:Boolean, param4:Boolean = false, param5:Array = null) : void
      {
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         if(!_loading)
         {
            if(param1 > 0)
            {
               _loading = true;
               _updateScrollPosition = param3;
               if(param5)
               {
                  _numSpecificNameWindowsToLoad += param1;
                  _loc8_ = 0;
                  while(_loc8_ < param5.length)
                  {
                     _loc9_ = int(param5[_loc8_]);
                     if(_mediaWindows[_loc9_])
                     {
                        if(_mediaWindows[_loc9_].hasOwnProperty("resetWindowToOriginalState"))
                        {
                           _mediaWindows[_loc9_].resetWindowToOriginalState();
                        }
                        _mediaWindows[_loc9_].visibilityIndex = _loc9_;
                        param2(_mediaWindows[_loc9_],_loc9_);
                     }
                     else if(_windowClass == ItemWindowBase)
                     {
                        new _windowClass(_customParams.itemClassName,param2,_itemList != null && _itemList.length > _loc9_ ? _itemList[_loc9_] : null,_iconLayerName,_loc9_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown);
                     }
                     else
                     {
                        new _windowClass(param2,_itemList != null && _itemList.length > _loc9_ ? _itemList[_loc9_] : null,_iconLayerName,_loc9_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown,_customParams);
                     }
                     _loc8_++;
                  }
               }
               else
               {
                  if(!param4)
                  {
                     _totalNumWin += param1;
                  }
                  _numWindowsToLoad += param1;
                  _loc7_ = 0;
                  _loc8_ = _numLoaded;
                  while(_loc8_ < _numWindowsToLoad)
                  {
                     if(_mediaWindows[_loc8_])
                     {
                        if(_mediaWindows[_loc8_].hasOwnProperty("resetWindowToOriginalState"))
                        {
                           _mediaWindows[_loc8_].resetWindowToOriginalState();
                        }
                        _mediaWindows[_loc8_].visibilityIndex = _loc8_;
                        param2(_mediaWindows[_loc8_],_loc8_);
                     }
                     else
                     {
                        if(_insertAtTop)
                        {
                           _loc6_ = _loc7_++;
                        }
                        else
                        {
                           _loc6_ = _loc8_;
                        }
                        if(_windowClass == ItemWindowBase)
                        {
                           new _windowClass(_customParams.itemClassName,param2,_itemList != null && _itemList.length > _loc6_ ? _itemList[_loc6_] : null,_iconLayerName,_loc6_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown);
                        }
                        else
                        {
                           new _windowClass(param2,_itemList != null && _itemList.length > _loc6_ ? _itemList[_loc6_] : null,_iconLayerName,_loc6_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown,_customParams);
                        }
                     }
                     _loc8_++;
                  }
               }
            }
            else if(_callback != null)
            {
               _callback();
               _callback = null;
            }
         }
         else
         {
            _loadingQueue.push({
               "numWindows":param1,
               "callback":param2,
               "updateScrollPosition":param3,
               "indexList":param5
            });
         }
      }
      
      private function onInitialWindowsLoaded(param1:MovieClip, param2:int = -1) : void
      {
         if(_mediaWindows && _dynamicScrollbar)
         {
            _mediaWindows[param2 == -1 ? param1.index : param2] = param1;
            _numLoaded++;
            if(_numLoaded == _numWindowsToLoad)
            {
               _boxWidth = param1.width;
               _boxHeight = param1.height;
               numWindowsCreated = _numLoaded;
               _dynamicScrollbar.insertMany(_mediaWindows,_updateScrollPosition,false,true);
               checkForMoreToLoad();
               if(_callback != null)
               {
                  _callback();
                  _callback = null;
               }
            }
         }
      }
      
      private function onSingleWindowLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _loc3_ = int(param2 == -1 ? param1.index : param2);
            _mediaWindows[_loc3_] = param1;
            if(_insertAtTop)
            {
               _loc4_ = 1;
               while(_loc4_ < _mediaWindows.length)
               {
                  _mediaWindows[_loc4_].index++;
                  _loc4_++;
               }
            }
            _numLoaded++;
            _dynamicScrollbar.insert(param1,_updateScrollPosition,_insertAtTop);
            numWindowsCreated = _numLoaded;
            checkForMoreToLoad();
         }
      }
      
      private function onSingleSpecificWindowLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _loc3_ = int(param2 == -1 ? param1.index : param2);
            _mediaWindows[_loc3_] = param1;
            _loc4_ = _loc3_;
            while(_loc4_ < _mediaWindows.length)
            {
               if(_mediaWindows[_loc4_] != null)
               {
                  _mediaWindows[_loc4_].index++;
               }
               _loc4_++;
            }
            _numLoaded++;
            _dynamicScrollbar.insertAtIndex(param1,_updateScrollPosition,_loc3_);
            numWindowsCreated = _numLoaded;
            checkForMoreToLoad();
         }
      }
      
      private function onManyWindowsLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _loc4_ = int(param2 == -1 ? param1.index : param2);
            _mediaWindows[_loc4_] = param1;
            _manyLoadedWindows[_loc4_ - _manyLoadingWindowIndexOffset] = param1;
            _numLoaded++;
            if(_numLoaded == _numWindowsToLoad)
            {
               numWindowsCreated = _numLoaded;
               if(_insertAtTop)
               {
                  _loc3_ = _mediaWindows[_mediaWindows.length - 1].index + 1;
                  _loc5_ = _numLoaded;
                  while(_loc5_ < _mediaWindows.length)
                  {
                     _mediaWindows[_loc5_].index = _loc3_++;
                     _loc5_++;
                  }
               }
               _dynamicScrollbar.insertMany(_manyLoadedWindows,_updateScrollPosition,false,_insertAtTop);
               _manyLoadedWindows = [];
               if(!checkForMoreToLoad())
               {
                  if(_onInsertManyCallback != null)
                  {
                     _onInsertManyCallback();
                     _onInsertManyCallback = null;
                  }
               }
            }
         }
      }
      
      private function checkForMoreToLoad() : Boolean
      {
         var _loc1_:Object = null;
         _loading = false;
         _updateScrollPosition = false;
         if(_loadingQueue.length > 0)
         {
            _loc1_ = _loadingQueue.shift();
            _manyLoadingWindowIndexOffset = _dynamicScrollbar.getNumOfAssets();
            loadWindows(_loc1_.numWindows,_loc1_.callback,_loc1_.updateScrollPosition,false,_loc1_.indexList);
            return true;
         }
         return false;
      }
      
      public function loadNextSet(param1:Function, ... rest) : Boolean
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(!_loading)
         {
            _loc3_ = 100 / _numWindowsPerScreen * _numWindowsPerScreen;
            if(_numLoaded + _loc3_ > _totalNumWin)
            {
               _loc3_ = _totalNumWin - _numLoaded;
            }
            if(_loc3_ > 0)
            {
               _onPaginationLoadCallback = param1;
               _onPaginationLoadArgs = rest;
               loadWindows(_loc3_,onLoadMoreWindows,true,true);
               return true;
            }
            if(_windowsToAddToEnd.length > 0)
            {
               _loc5_ = int(_mediaWindows[_mediaWindows.length - 1].index);
               _loc4_ = 0;
               while(_loc4_ < _windowsToAddToEnd.length)
               {
                  _loc5_++;
                  _windowsToAddToEnd[_loc4_].index = _loc5_;
                  if(_windowsToAddToEnd[_loc4_].hasOwnProperty("removeLoadedItem"))
                  {
                     _windowsToAddToEnd[_loc4_].removeLoadedItem();
                  }
                  _loc4_++;
               }
               insertManyItems(_windowsToAddToEnd,false,_insertAtTop,null,_adjustListOnInsert);
               _windowsToAddToEnd = [];
            }
            return false;
         }
         _onPaginationLoadCallback = param1;
         _onPaginationLoadArgs = rest;
         return true;
      }
      
      private function onLoadMoreWindows(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _mediaWindows[param2 == -1 ? param1.index : param2] = param1;
            _moreLoadedWindows[(param2 == -1 ? param1.index : param2) - _dynamicScrollbar.getNumOfAssets()] = param1;
            _numLoaded++;
            if(_numLoaded == _numWindowsToLoad)
            {
               numWindowsCreated = _numLoaded;
               if(_insertAtTop)
               {
                  _loc3_ = _mediaWindows[_mediaWindows.length - 1].index + 1;
                  _loc4_ = _numLoaded;
                  while(_loc4_ < _mediaWindows.length)
                  {
                     _mediaWindows[_loc4_].index = _loc3_++;
                     _loc4_++;
                  }
               }
               _dynamicScrollbar.insertMany(_moreLoadedWindows,_updateScrollPosition,false,_insertAtTop);
               _moreLoadedWindows = [];
               if(!checkForMoreToLoad())
               {
                  if(_onPaginationLoadCallback != null)
                  {
                     if(_onPaginationLoadArgs != null)
                     {
                        _onPaginationLoadCallback.apply(null,_onPaginationLoadArgs);
                     }
                     else
                     {
                        _onPaginationLoadCallback();
                     }
                     _onPaginationLoadArgs = null;
                     _onPaginationLoadCallback = null;
                  }
               }
            }
         }
      }
      
      private function onLoadSpecificNameWindows(param1:MovieClip, param2:int = -1) : void
      {
         if(_mediaWindows && _dynamicScrollbar)
         {
            _mediaWindows[param2 == -1 ? param1.index : param2] = param1;
            _specificLoadedWindows[param2 == -1 ? param1.index : param2] = param1;
            _numSpecificNameWindowsLoaded++;
            param1.visibilityIndex = _dynamicScrollbar.getNumOfAssets() + _numSpecificNameWindowsLoaded;
            if(_numSpecificNameWindowsLoaded == _numSpecificNameWindowsToLoad)
            {
               _numSpecificNameWindowsLoaded = 0;
               if(_insertAtTop)
               {
                  throw new Error("Insert At Top not supported");
               }
               _dynamicScrollbar.insertMany(_specificLoadedWindows,_updateScrollPosition,false,false);
               _specificLoadedWindows = [];
               _numSpecificNameWindowsLoaded = 0;
               _numSpecificNameWindowsToLoad = 0;
               if(!checkForMoreToLoad())
               {
                  if(_onLoadSpecificNameCallback != null)
                  {
                     _onLoadSpecificNameCallback();
                     _onLoadSpecificNameCallback = null;
                  }
               }
            }
         }
      }
      
      private function onReloadInitialWindows(param1:MovieClip, param2:int = -1) : void
      {
         if(_mediaWindows && _dynamicScrollbar)
         {
            _mediaWindows[param2 == -1 ? param1.index : param2] = param1;
            _reloadMediaWindows[param2 == -1 ? param1.index : param2] = param1;
            param1.visibilityIndex = param2 == -1 ? param1.index : param2;
            _numLoaded++;
            if(_numLoaded == _numWindowsToLoad)
            {
               _boxWidth = param1.width;
               _boxHeight = param1.height;
               numWindowsCreated = _numLoaded;
               _dynamicScrollbar.insertMany(_reloadMediaWindows,_updateScrollPosition,false,true);
               _reloadMediaWindows = [];
               checkForMoreToLoad();
               if(_onReloadCallback != null)
               {
                  if(_onReloadPassbackArgs != null)
                  {
                     _onReloadCallback.apply(null,_onReloadPassbackArgs);
                  }
                  else
                  {
                     _onReloadCallback();
                  }
                  _onReloadCallback = null;
                  _onReloadPassbackArgs = null;
               }
            }
         }
      }
   }
}

