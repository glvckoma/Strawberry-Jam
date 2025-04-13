package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   
   public class SBScrollbar extends MovieClip
   {
      private const MIN_HANDLE_HEIGHT:int = 30;
      
      private const EASE_TIME:Number = 0.001;
      
      private const EASE_BUTTON_TIME:Number = 0.5;
      
      private var _scrollContentMask:MovieClip;
      
      private var _wheelScrollPercent:Number;
      
      private var _wheelScrollChange:Number;
      
      private var _scrollHeight:Number;
      
      private var _bounds:Rectangle;
      
      private var _scrollTween:GTween;
      
      private var _scrollContent:MovieClip;
      
      private var _scrollContentHeight:Number;
      
      private var _track:MovieClip;
      
      private var _scrollHandle:MovieClip;
      
      private var _topBtn:MovieClip;
      
      private var _bottomBtn:MovieClip;
      
      private var _gap:Number;
      
      private var _snapHeight:Number;
      
      private var _viewableWidth:Number;
      
      private var _viewableHeight:Number;
      
      private var _adjTrackHeight:Number;
      
      private var _handleMovementPercentage:Number;
      
      private var _currContentY:Number;
      
      private var _numRowsInView:int;
      
      private var _fullScreenScrollChange:Number;
      
      private var _numPerRow:int;
      
      public function SBScrollbar()
      {
         super();
      }
      
      public function init(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:Number = 0, param8:Number = -1) : void
      {
         _scrollContent = param1;
         _scrollContent.y = 0;
         _scrollContent.x = 0;
         var _loc9_:MovieClip = GETDEFINITIONBYNAME(param5);
         if(_loc9_.track && _loc9_.handle)
         {
            _track = _loc9_.track;
            _scrollHandle = _loc9_.handle;
            _topBtn = _loc9_.topBtn;
            _bottomBtn = _loc9_.botBtn;
            _snapHeight = param6;
            _gap = param4;
            _viewableWidth = param2;
            _viewableHeight = param3;
            _numPerRow = Math.round(_viewableWidth / _scrollContent.boxWidth);
            if(param8 < _viewableHeight)
            {
               _scrollContentHeight = _scrollContent.height;
            }
            else
            {
               _scrollContentHeight = param8;
            }
            _scrollContentMask = createMask(_viewableWidth,_viewableHeight);
            _scrollContent.parent.addChild(_scrollContentMask);
            _scrollContentMask.x = _scrollContent.x;
            _scrollContentMask.y = _scrollContent.y;
            _scrollContent.mask = _scrollContentMask;
            _scrollHeight = _scrollContentHeight - _scrollContentMask.height;
            if(param7 <= 0)
            {
               _currContentY = 0;
            }
            else if(param7 > _scrollHeight)
            {
               _currContentY = _scrollHeight;
            }
            else
            {
               _currContentY = param7;
            }
            setupAllItems();
            _numRowsInView = Math.round(_viewableHeight / _snapHeight);
            _fullScreenScrollChange = _snapHeight * (_numRowsInView - 1);
            _handleMovementPercentage = 0;
            _bounds = new Rectangle(_track.x,_scrollContentMask.y,0,Math.round(_bottomBtn.y - _scrollHandle.height));
            _bounds.top = _topBtn.height;
            _adjTrackHeight = _track.height - _scrollHandle.height;
            _wheelScrollPercent = _snapHeight / (_scrollContentHeight - _scrollContentMask.height);
            _wheelScrollChange = _wheelScrollPercent * (_scrollContentMask.y + _scrollContentMask.height - _scrollHandle.height);
            setScrollHandleLocation(_currContentY);
            updateLoadItems();
            _scrollContent.y = _scrollContentMask.y - _currContentY;
            return;
         }
         throw new Error("Error: SBSCrollbar.init()- The 5th parameter must contain two symbols; \'track\' and \'handle\'.");
      }
      
      public function destroy() : void
      {
         if(_scrollHandle)
         {
            _scrollHandle.y = 0;
            _scrollContent.y = 0;
         }
         if(_scrollContent)
         {
            if(_scrollContent.stage)
            {
               _scrollContent.stage.removeEventListener("mouseUp",onMouseUpHandler);
               _scrollContent.stage.removeEventListener("mouseMove",onMouseMoveHandler);
            }
            if(_scrollContent.parent)
            {
               _scrollContent.parent.removeEventListener("mouseWheel",onMouseWheelHandler);
               if(_scrollContent.stage)
               {
                  _scrollContent.parent.stage.removeEventListener("mouseUp",onMouseUpHandler);
               }
               if(_scrollContent.parent.parent)
               {
                  _scrollContent.parent.parent.removeEventListener("rollOut",onStageOut);
               }
               if(_scrollContent.parent && _scrollContent.parent.parent && _scrollContent.parent.parent.parent)
               {
                  _scrollContent.parent.parent.parent.removeEventListener("mouseUp",onMouseUpHandler);
               }
               if(_scrollContentMask && _scrollContentMask.parent)
               {
                  _scrollContentMask.parent.removeChild(_scrollContentMask);
               }
               if(_track && _track.parent && _track.parent == _scrollContent.parent)
               {
                  _scrollContent.parent.removeChild(_track);
               }
               if(_scrollHandle && _scrollHandle.parent && _scrollHandle.parent == _scrollContent.parent)
               {
                  _scrollHandle.removeEventListener("mouseDown",onMouseDownHandler);
                  _scrollContent.parent.removeChild(_scrollHandle);
               }
               if(_topBtn && _topBtn.parent && _topBtn.parent == _scrollContent.parent)
               {
                  _topBtn.removeEventListener("mouseDown",onBtnClick);
                  _scrollContent.parent.removeChild(_topBtn);
               }
               if(_bottomBtn && _bottomBtn.parent && _bottomBtn.parent == _scrollContent.parent)
               {
                  _bottomBtn.removeEventListener("mouseDown",onBtnClick);
                  _scrollContent.parent.removeChild(_bottomBtn);
               }
            }
         }
         _track = null;
         _scrollHandle = null;
         _topBtn = null;
         _bottomBtn = null;
         _scrollContent = null;
         _scrollContentMask = null;
         _bounds = null;
         _gap = NaN;
         _snapHeight = NaN;
         _viewableWidth = NaN;
         _viewableHeight = NaN;
         _adjTrackHeight = NaN;
         _handleMovementPercentage = NaN;
         _currContentY = NaN;
         _numRowsInView = NaN;
         _fullScreenScrollChange = NaN;
      }
      
      public function get scrollHeight() : Number
      {
         return _scrollHeight;
      }
      
      public function get getMaskHeight() : Number
      {
         return _scrollContentMask.height;
      }
      
      public function get getMaskY() : Number
      {
         return _scrollContentMask.y;
      }
      
      public function get scrollYValue() : Number
      {
         if(_scrollContentHeight <= _scrollContentMask.height)
         {
            _currContentY = 0;
         }
         return _currContentY;
      }
      
      public function get scrollYPercentage() : Number
      {
         if(_scrollContentHeight <= _scrollContentMask.height)
         {
            return _currContentY = 0;
         }
         return _currContentY / _scrollHeight;
      }
      
      public function get getScrollContentParent() : MovieClip
      {
         return MovieClip(_scrollContent.parent);
      }
      
      public function scrollToElement(param1:int, param2:Boolean = false) : void
      {
         if(param1 < 0 || param1 > _scrollContentHeight / _snapHeight)
         {
            throw new Error("Invalid index.");
         }
         var _loc3_:Number = Math.min(_scrollHeight,param1 * _snapHeight - _currContentY);
         updateContentPosition(_loc3_ < 0 ? 0 : _loc3_,param2);
      }
      
      private function setupAllItems() : void
      {
         _scrollContent.parent.addChild(_track);
         _track.x = Math.round(_scrollContent.x + _viewableWidth + _gap + _track.width * 0.5);
         _track.y = _scrollContent.y + _topBtn.height;
         _track.height = _scrollContentMask.height - _topBtn.height - _bottomBtn.height;
         _scrollContent.parent.addChild(_topBtn);
         _topBtn.x = _track.x;
         _topBtn.y = _scrollContent.y;
         _scrollContent.parent.addChild(_bottomBtn);
         _bottomBtn.x = _track.x;
         _bottomBtn.y = _track.y + _track.height;
         _scrollContent.parent.addChild(_scrollHandle);
         _scrollHandle.x = _track.x;
         _scrollHandle.y = _track.y;
         resizeHandle();
      }
      
      private function snapToPlace() : void
      {
         var _loc3_:Number = Math.ceil(_scrollHeight * _handleMovementPercentage / _snapHeight);
         _loc3_ = _snapHeight * _loc3_;
         var _loc1_:Number = Math.min(1,_loc3_ / _scrollHeight);
         _currContentY = _scrollHeight * _loc1_;
         new GTween(_scrollContent,0.5,{"y":_scrollContentMask.y - _currContentY},{"ease":Quadratic.easeOut});
         setScrollHandleLocation(_currContentY);
         var _loc2_:Number = Math.max(_scrollHandle.y,_track.y);
         new GTween(_scrollHandle,0.5,{"y":_loc2_},{"ease":Quadratic.easeOut});
      }
      
      private function setScrollHandleLocation(param1:Number) : void
      {
         var _loc2_:Number = Math.min(1,param1 / _scrollHeight);
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         var _loc3_:Number = _loc2_ * _scrollHeight;
         _loc3_ /= _snapHeight;
         _handleMovementPercentage = _loc3_ * _snapHeight / _scrollHeight;
         _scrollHandle.y = Math.max(_handleMovementPercentage * _adjTrackHeight + _topBtn.height,_track.y);
      }
      
      private function loadCurrViewableObjects(param1:Number) : void
      {
         var _loc5_:* = 0;
         var _loc2_:int = Math.ceil(param1 / _snapHeight);
         var _loc6_:int = _loc2_ * _numPerRow;
         var _loc3_:int = _loc6_ + _numRowsInView * _numPerRow;
         var _loc4_:int = int(_scrollContent.bg.numChildren);
         _loc5_ = _loc6_;
         while(_loc5_ < _loc3_)
         {
            if(_loc5_ < _loc4_)
            {
               _scrollContent.bg.getChildAt(_loc5_).loadCurrItem(param1);
            }
            _loc5_++;
         }
      }
      
      private function updateLoadItems(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_scrollContent.hasOwnProperty("bg"))
         {
            if(!param1)
            {
               loadCurrViewableObjects(_currContentY);
            }
            else
            {
               _loc3_ = Math.ceil(_scrollHeight * _handleMovementPercentage / _snapHeight);
               _loc3_ = _snapHeight * _loc3_;
               _loc2_ = Math.min(1,_loc3_ / _scrollHeight);
               loadCurrViewableObjects(_scrollHeight * _loc2_);
            }
         }
      }
      
      private function updateContentPosition(param1:Number = NaN, param2:Boolean = false) : void
      {
         if(!isNaN(param1))
         {
            _currContentY += param1;
            setScrollHandleLocation(_currContentY);
            updateLoadItems();
            _scrollTween = new GTween(_scrollContent,param2 ? 0.001 : 0.5,{"y":_scrollContentMask.y - _currContentY},{"ease":Quadratic.easeOut});
         }
         else
         {
            _handleMovementPercentage = Math.min(1,(_scrollHandle.y - _topBtn.height) / _adjTrackHeight);
            if(_handleMovementPercentage < 0)
            {
               _handleMovementPercentage = 0;
            }
            updateLoadItems(true);
            _scrollTween = new GTween(_scrollContent,0.001,{"y":_scrollContentMask.y - _scrollHeight * _handleMovementPercentage},{"ease":Quadratic.easeOut});
         }
      }
      
      private function onBtnClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Number = 0;
         if(_scrollTween)
         {
            _scrollTween.end();
         }
         if(param1.currentTarget.name == _topBtn.name)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function scrollUp() : Number
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_currContentY > 0)
         {
            if(_currContentY >= _fullScreenScrollChange)
            {
               _loc2_ = -_fullScreenScrollChange;
            }
            else
            {
               _loc1_ = _numRowsInView - 2;
               while(_loc1_ > 0)
               {
                  if(_currContentY >= _snapHeight * _loc1_)
                  {
                     _loc2_ = -(_snapHeight * _loc1_);
                     break;
                  }
                  _loc1_--;
               }
               if(_loc2_ > -_currContentY)
               {
                  _loc2_ = -_currContentY;
               }
            }
         }
         return _loc2_;
      }
      
      private function scrollDown() : Number
      {
         var _loc2_:int = 0;
         var _loc3_:* = 0;
         var _loc1_:Number = _scrollContentHeight - _currContentY - _viewableHeight;
         if(_loc1_ > 0)
         {
            if(_loc1_ >= _fullScreenScrollChange)
            {
               _loc3_ = _fullScreenScrollChange;
            }
            else
            {
               _loc2_ = _numRowsInView - 2;
               while(_loc2_ > 0)
               {
                  if(_loc1_ >= _snapHeight * _loc2_)
                  {
                     _loc3_ = _snapHeight * _loc2_;
                     break;
                  }
                  _loc2_--;
               }
               if(_loc3_ < _loc1_)
               {
                  _loc3_ = _loc1_;
               }
            }
         }
         return _loc3_;
      }
      
      private function onMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_scrollHandle.height < _scrollContentHeight - 3)
         {
            _scrollHandle.startDrag(false,_bounds);
            _scrollContent.parent.parent.addEventListener("rollOut",onStageOut,false,0,true);
            _scrollContent.stage.addEventListener("mouseMove",onMouseMoveHandler,false,0,true);
            _scrollContent.parent.stage.addEventListener("mouseUp",onMouseUpHandler,false,0,true);
            _scrollContent.parent.parent.parent.addEventListener("mouseUp",onMouseUpHandler,false,0,true);
         }
      }
      
      private function onStageOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onMouseUpHandler(param1);
      }
      
      private function onMouseUpHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _scrollHandle.stopDrag();
         if(_scrollTween)
         {
            _scrollTween.end();
         }
         if(_snapHeight > 0)
         {
            snapToPlace();
         }
         if(_scrollContent.stage)
         {
            _scrollContent.stage.removeEventListener("mouseMove",onMouseMoveHandler);
         }
         if(_scrollContent.parent.stage)
         {
            _scrollContent.parent.stage.removeEventListener("mouseUp",onMouseUpHandler);
         }
         if(_scrollContent.parent.parent)
         {
            _scrollContent.parent.parent.removeEventListener("rollOut",onStageOut);
         }
         if(_scrollContent.parent.parent.parent)
         {
            _scrollContent.parent.parent.parent.removeEventListener("mouseUp",onMouseUpHandler);
         }
      }
      
      private function onTrackDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = Math.ceil(param1.localY * param1.currentTarget.scaleY);
         if(_scrollTween)
         {
            _scrollTween.end();
         }
         if(_loc3_ < _scrollHandle.y + _scrollHandle.height - _topBtn.height)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function onMouseMoveHandler(param1:MouseEvent) : void
      {
         updateContentPosition();
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         if(param1.delta > 0)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function createMask(param1:Number, param2:Number) : MovieClip
      {
         var _loc3_:MovieClip = new MovieClip();
         _loc3_.graphics.beginFill(16777215);
         _loc3_.graphics.drawRect(0,0,param1,param2);
         _loc3_.graphics.endFill();
         return _loc3_;
      }
      
      private function resizeHandle() : void
      {
         var _loc1_:Number = NaN;
         if(_scrollContentHeight <= _scrollContentMask.height || _currContentY != _scrollHeight && _scrollContentHeight - _currContentY - _viewableHeight < _snapHeight)
         {
            _scrollHandle.visible = false;
            if(_topBtn.hasGrayState && _bottomBtn.hasGrayState)
            {
               _topBtn.activateGrayState(true);
               _bottomBtn.activateGrayState(true);
            }
            if(_scrollContent.parent.hasEventListener("mouseWheel"))
            {
               _scrollContent.parent.removeEventListener("mouseWheel",onMouseWheelHandler);
            }
         }
         else
         {
            _loc1_ = _scrollContentMask.height / _scrollContentHeight * _scrollContentMask.height - _topBtn.height - _bottomBtn.height;
            _topBtn.addEventListener("mouseDown",onBtnClick,false,0,true);
            _bottomBtn.addEventListener("mouseDown",onBtnClick,false,0,true);
            _scrollHandle.addEventListener("mouseDown",onMouseDownHandler,false,0,true);
            _track.addEventListener("mouseDown",onTrackDown,false,0,true);
            _scrollContent.parent.addEventListener("mouseWheel",onMouseWheelHandler,false,0,true);
            if(_loc1_ < 30)
            {
               _loc1_ = 30;
            }
            _scrollHandle.mid.height = _loc1_ - _scrollHandle.top.height - _scrollHandle.bot.height;
            _scrollHandle.top.y = 0;
            _scrollHandle.mid.y = _scrollHandle.top.y + _scrollHandle.top.height - 0.1;
            _scrollHandle.bot.y = _scrollHandle.mid.y + _scrollHandle.mid.height - 0.1;
         }
      }
   }
}

