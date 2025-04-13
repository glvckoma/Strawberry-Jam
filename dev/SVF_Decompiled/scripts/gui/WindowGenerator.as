package gui
{
   import flash.display.MovieClip;
   import gui.itemWindows.ItemWindowBase;
   
   public class WindowGenerator extends MovieClip
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
      
      private var _xOffset:int;
      
      private var _yOffset:int;
      
      private var _xStart:int;
      
      private var _yStart:int;
      
      private var _numToCreated:int;
      
      private var _fillCompletely:Boolean;
      
      private var _mediaWindows:Array;
      
      private var _numLoaded:int;
      
      private var _callback:Function;
      
      private var _mouseDown:Function;
      
      private var _mouseOver:Function;
      
      private var _mouseOut:Function;
      
      private var _mouseMemberOnlyDown:Function;
      
      public function WindowGenerator()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:Number, param5:Number, param6:int, param7:Class, param8:Array, param9:String, param10:Object = null, param11:Object = null, param12:Function = null, param13:Boolean = false, param14:Boolean = true) : void
      {
         var _loc15_:int = 0;
         _xWinVis = param1;
         _yWinVis = param2;
         _totalNumWin = param3;
         _xOffset = param4;
         _yOffset = param5;
         _xStart = param6;
         _yStart = _yOffset * 0.5;
         _fillCompletely = param14;
         _callback = param12;
         var _loc16_:int = _totalNumWin;
         if(_fillCompletely)
         {
            _loc16_ = _xWinVis * _yWinVis;
         }
         if(_totalNumWin < _loc16_)
         {
            _totalNumWin = _loc16_;
         }
         if(param13)
         {
            _numRows = param2;
            _numCols = Math.ceil(_totalNumWin / _yWinVis);
         }
         else
         {
            _numRows = Math.ceil(_totalNumWin / _xWinVis);
            _numCols = param1;
         }
         bg = new MovieClip();
         if(param10 != null)
         {
            _mouseDown = param10.mouseDown;
            _mouseOut = param10.mouseOut;
            _mouseOver = param10.mouseOver;
            _mouseMemberOnlyDown = param10.memberOnlyDown;
         }
         _mediaWindows = [_totalNumWin];
         _numLoaded = 0;
         _loc15_ = 0;
         while(_loc15_ < _totalNumWin)
         {
            if(param7 == ItemWindowBase)
            {
               new param7(param11.itemClassName,windowLoaded,param8 != null && param8.length > _loc15_ ? param8[_loc15_] : null,param9,_loc15_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown);
            }
            else
            {
               new param7(windowLoaded,param8 != null && param8.length > _loc15_ ? param8[_loc15_] : null,param9,_loc15_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown,param11);
            }
            _loc15_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
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
      
      public function isIndexInView(param1:int) : Boolean
      {
         return true;
      }
      
      private function windowLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var hasSizeCont:Boolean;
         var window:MovieClip = param1;
         var index:int = param2;
         if(_mediaWindows)
         {
            _mediaWindows[index == -1 ? window.index : index] = window;
            _numLoaded++;
            if(_numLoaded == _totalNumWin)
            {
               toolTip = ToolTipPopup(GETDEFINITIONBYNAME("Tooltip"));
               hasSizeCont = "sizeCont" in window;
               _boxWidth = hasSizeCont ? window.sizeCont.width : window.width;
               _boxHeight = hasSizeCont ? window.sizeCont.height : window.height;
               generateWindows();
               with(bg.graphics)
               {
                  
                  drawRect(0,0,_xWinVis * _boxWidth + (_xWinVis - 1) * _xOffset + 2 * _xStart,_numRows * _boxHeight + (_numRows - 1) * _yOffset + 2 * _yStart);
               }
               addChild(bg);
               if(_callback != null)
               {
                  _callback();
                  _callback = null;
               }
            }
         }
      }
      
      private function generateWindows() : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _numRows)
         {
            _loc3_ = 0;
            while(_loc3_ < _numCols)
            {
               if(_loc1_ >= _totalNumWin && !_fillCompletely)
               {
                  numWindowsCreated = _loc1_;
                  return;
               }
               if(_mediaWindows[_loc1_] is ItemWindowBase)
               {
                  _loc2_ = _mediaWindows[_loc1_];
                  _loc2_.x = _xStart + _xOffset * _loc3_ + _boxWidth * _loc3_;
                  _loc2_.y = _yStart + _yOffset * _loc4_ + _boxHeight * _loc4_;
                  bg.addChild(_loc2_);
                  _loc1_++;
               }
               _loc3_++;
            }
            _loc4_++;
         }
         numWindowsCreated = _loc1_;
      }
   }
}

