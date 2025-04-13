package gui
{
   import com.sbi.corelib.audio.SBAudio;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import localization.LocalizationManager;
   
   public class GuiCarousel
   {
      private static const SPIN_UPDATE_MS:int = 1;
      
      private static const BUTTON_HOLD_DELAY:int = 500;
      
      public var spinSpeed:Number = 3;
      
      public var upBtn:MovieClip;
      
      public var downBtn:MovieClip;
      
      public var itemsHolder:MovieClip;
      
      public var scrollerMask:Sprite;
      
      public var itemHolders:Vector.<TextField>;
      
      public var itemInfos:Vector.<ItemInfo>;
      
      public var contentItems:Array;
      
      public var doneSpinningCallback:Function;
      
      private var _soundsEnabled:Boolean;
      
      private var _callDone:Boolean;
      
      private var _itemCycleDown:Boolean;
      
      private var _autoCycleDown:Boolean;
      
      private var _autoScroll:Boolean;
      
      private var _contentItemIndex:int;
      
      private var _targetContentItemIndex:int;
      
      private var _centerItemHolderIndex:int;
      
      private var _centerItemHolderGlowFilter:GlowFilter;
      
      private var _hoverItemHolderGlowFilter:GlowFilter;
      
      private var _centerTextFormatShadow:TextFormat;
      
      private var _centerTextFormatLight:TextFormat;
      
      private var _itemCycleTimer:Timer;
      
      private var _btnHoldTimer:Timer;
      
      private var _lastTimer:int;
      
      private var _randomizing:Boolean;
      
      private var _continueCallback:Function;
      
      private var _isFromLogin:Boolean;
      
      private var _guiAsset:MovieClip;
      
      private var _hasLoaded:Boolean;
      
      private var _startingIndex:int;
      
      private var _forceSpinStop:Boolean;
      
      public function GuiCarousel(param1:MovieClip)
      {
         super();
         _guiAsset = param1;
      }
      
      public function init(param1:Array, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:int = -1) : void
      {
         var _loc7_:DisplayObject = null;
         var _loc6_:int = 0;
         _lastTimer = getTimer();
         _startingIndex = param5;
         _soundsEnabled = !SBAudio.areSoundsMuted;
         contentItems = param1;
         _isFromLogin = param4;
         if(contentItems.length < 1)
         {
            throw new Error("Attempted to init GuiCarousel with content array length less than one!");
         }
         doneSpinningCallback = param2;
         upBtn = _guiAsset._up;
         downBtn = _guiAsset._down;
         itemsHolder = _guiAsset._items;
         scrollerMask = _guiAsset.scrollerMask;
         if(!(upBtn && downBtn && itemsHolder && scrollerMask))
         {
            throw new Error("GuiCarousel is missing parts or they are named incorrectly!");
         }
         upBtn.stop();
         upBtn.addEventListener("mouseDown",upBtnMouseDownHandler,false,0,true);
         upBtn.addEventListener("mouseUp",upBtnMouseUpOutHandler,false,0,true);
         upBtn.addEventListener("mouseOut",upBtnMouseUpOutHandler,false,0,true);
         downBtn.stop();
         downBtn.addEventListener("mouseDown",downBtnMouseDownHandler,false,0,true);
         downBtn.addEventListener("mouseUp",downBtnMouseUpOutHandler,false,0,true);
         downBtn.addEventListener("mouseOut",downBtnMouseUpOutHandler,false,0,true);
         itemInfos = new Vector.<ItemInfo>(2);
         var _loc8_:int = 0;
         while(itemsHolder.hasOwnProperty("_item" + _loc8_))
         {
            _loc7_ = itemsHolder["_item" + _loc8_];
            itemInfos[_loc8_] = new ItemInfo();
            itemInfos[_loc8_].stopY = _loc7_.y;
            _loc8_++;
         }
         if(_loc8_ == 0)
         {
            throw new Error("GuiCarousel did not have any _item# instances inside it!");
         }
         itemInfos[_loc8_] = new ItemInfo();
         itemInfos[_loc8_].stopY = itemInfos.length > 2 ? itemInfos[_loc8_ - 1].stopY + (itemInfos[_loc8_ - 1].stopY - itemInfos[_loc8_ - 2].stopY) : itemInfos[_loc8_ - 1].stopY + itemsHolder["_item1"].height;
         itemHolders = new Vector.<TextField>(_loc8_);
         _loc6_ = 0;
         while(_loc6_ < _loc8_)
         {
            itemHolders[_loc6_] = itemsHolder["_item" + _loc6_];
            itemHolders[_loc6_].addEventListener("mouseDown",itemMouseDownHandler,false,0,true);
            itemHolders[_loc6_].addEventListener("mouseOver",itemMouseOverHandler,false,0,true);
            itemHolders[_loc6_].addEventListener("mouseOut",itemMouseOutHandler,false,0,true);
            _loc6_++;
         }
         _hoverItemHolderGlowFilter = new GlowFilter(16777215,1,16,16,3);
         _centerItemHolderIndex = _loc8_ / 2;
         _centerTextFormatShadow = TextField(itemsHolder["_item1"]).getTextFormat();
         _centerTextFormatLight = TextField(itemsHolder["_item" + _centerItemHolderIndex]).getTextFormat();
         _btnHoldTimer = new Timer(500,1);
         _btnHoldTimer.addEventListener("timer",btnHoldTimerHandler,false,0,true);
         _itemCycleTimer = new Timer(1);
         _autoScroll = false;
         spinSpeed = 4;
         _callDone = true;
         _continueCallback = param3;
         if(param5 == -1)
         {
            pickRandomItem(true);
         }
         else
         {
            spinToIndex(param5,true);
         }
         if(_continueCallback != null)
         {
            _continueCallback();
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         _btnHoldTimer.stop();
         _btnHoldTimer = null;
         _itemCycleTimer.stop();
         _itemCycleTimer = null;
         upBtn.removeEventListener("mouseDown",upBtnMouseDownHandler);
         upBtn.removeEventListener("mouseUp",upBtnMouseUpOutHandler);
         upBtn.removeEventListener("mouseOut",upBtnMouseUpOutHandler);
         downBtn.removeEventListener("mouseDown",downBtnMouseDownHandler);
         downBtn.removeEventListener("mouseUp",downBtnMouseUpOutHandler);
         downBtn.removeEventListener("mouseOut",downBtnMouseUpOutHandler);
         _loc1_ = 0;
         while(_loc1_ < itemHolders.length)
         {
            itemHolders[_loc1_].removeEventListener("mouseDown",itemMouseDownHandler);
            itemHolders[_loc1_].removeEventListener("mouseOver",itemMouseOverHandler);
            itemHolders[_loc1_].removeEventListener("mouseOut",itemMouseOutHandler);
            _loc1_++;
         }
         itemHolders = null;
      }
      
      public function set soundsEnabled(param1:Boolean) : void
      {
         _soundsEnabled = param1;
      }
      
      public function get soundsEnabled() : Boolean
      {
         return _soundsEnabled;
      }
      
      public function forceStop() : void
      {
         _forceSpinStop = true;
         if(_itemCycleTimer.running)
         {
            _itemCycleTimer.removeEventListener("timer",itemCycleUpdate);
            _itemCycleTimer.reset();
            _randomizing = false;
            setupHolders(false);
            doneSpinning();
         }
      }
      
      public function get contentItemIndex() : int
      {
         return _contentItemIndex;
      }
      
      public function set contentItemIndex(param1:int) : void
      {
         if(param1 == _contentItemIndex)
         {
            return;
         }
         spinToIndex(param1);
      }
      
      public function get selectedContentItem() : *
      {
         return !!contentItems ? contentItems[_contentItemIndex] : null;
      }
      
      public function set selectedContentItem(param1:*) : void
      {
         spinToIndex(contentItems.indexOf(param1));
      }
      
      public function get hasLoaded() : Boolean
      {
         return _hasLoaded;
      }
      
      public function pickRandomItem(param1:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = int(contentItems.length);
         var _loc3_:int = Math.random() * _loc2_;
         if(!param1)
         {
            _randomizing = true;
            _loc4_ = _loc3_ + (Math.random() < 0.5 ? 8 : -8);
            if(_loc4_ < 0)
            {
               _loc4_ += _loc2_;
            }
            if(_loc4_ >= _loc2_)
            {
               _loc4_ -= _loc2_;
            }
            _callDone = false;
            spinToIndex(_loc4_,true);
            _callDone = true;
         }
         spinToIndex(_loc3_,param1);
      }
      
      private function spin() : void
      {
         if(_soundsEnabled && hasLoaded)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         startSpin();
      }
      
      public function spinToIndex(param1:int, param2:Boolean = false) : void
      {
         if(_itemCycleTimer.hasEventListener("timer") || param1 < 0 || param1 >= contentItems.length)
         {
            return;
         }
         if(!param2 && _soundsEnabled && hasLoaded)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         if(Math.abs(_contentItemIndex - param1) < contentItems.length / 2)
         {
            _itemCycleDown = _contentItemIndex - param1 > 0;
         }
         else
         {
            _itemCycleDown = _contentItemIndex - param1 <= 0;
         }
         if(param2)
         {
            _contentItemIndex = _targetContentItemIndex = param1;
            displayItems(true,true);
            DarkenManager.showLoadingSpiral(false);
         }
         else
         {
            _targetContentItemIndex = param1;
            startSpin();
         }
      }
      
      private function startSpin() : void
      {
         _forceSpinStop = false;
         TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatShadow);
         TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatShadow;
         if(!_itemCycleDown)
         {
            setupHolders();
         }
         _itemCycleTimer.addEventListener("timer",itemCycleUpdate,false,0,true);
         _lastTimer = getTimer();
         _itemCycleTimer.start();
      }
      
      private function setupHolders(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(itemHolders.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            itemHolders[_loc2_].y = itemInfos[int(_itemCycleDown || !param1 ? _loc2_ : _loc2_ + 1)].stopY;
            _loc2_++;
         }
         if(param1)
         {
            cycleItems();
         }
      }
      
      private function cycleItems() : void
      {
         var _loc1_:int = int(contentItems.length);
         if(_itemCycleDown)
         {
            if(--_contentItemIndex == -1)
            {
               _contentItemIndex = _loc1_ - 1;
            }
         }
         else if(++_contentItemIndex == _loc1_)
         {
            _contentItemIndex = 0;
         }
         displayItems(!_autoScroll && _targetContentItemIndex == _contentItemIndex);
      }
      
      private function displayItems(param1:Boolean = true, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc5_:* = 0;
         DarkenManager.showLoadingSpiral(false);
         var _loc7_:int = Math.min(itemHolders.length,contentItems.length);
         var _loc6_:int = int(contentItems.length);
         var _loc4_:int = _contentItemIndex - int(_loc7_ / 2);
         if(_loc4_ < 0)
         {
            _loc4_ += _loc6_;
         }
         _loc3_ = 0;
         _loc5_ = _loc4_;
         while(_loc3_ < _loc7_)
         {
            LocalizationManager.updateToFit(TextField(itemHolders[_loc3_]),contentItems[_loc5_],false,false,false);
            _loc5_++;
            if(_loc5_ >= _loc6_)
            {
               _loc5_ = 0;
            }
            _loc3_++;
         }
         if(param2 || param1 && _callDone)
         {
            if(param2 || _itemCycleDown)
            {
               doneSpinning();
            }
         }
      }
      
      private function doneSpinning() : void
      {
         _autoScroll = false;
         TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatLight);
         TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatLight;
         LocalizationManager.updateToFit(TextField(itemHolders[_centerItemHolderIndex]),contentItems[_contentItemIndex],false,false,false);
         if(!_btnHoldTimer.running)
         {
            if(hasLoaded)
            {
               AJAudio.stopNameGenRotationSound();
               AJAudio.playNameGenStopSound();
            }
            else
            {
               _hasLoaded = true;
            }
         }
         if(!_randomizing || _itemCycleTimer.running)
         {
            _randomizing = false;
            if(doneSpinningCallback != null)
            {
               doneSpinningCallback();
            }
         }
      }
      
      private function itemCycleUpdate(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:int = int(itemHolders.length);
         var _loc3_:Boolean = false;
         var _loc5_:int = getTimer();
         var _loc6_:Number = (_loc5_ - _lastTimer) / 20;
         var _loc7_:Number = _loc6_ * spinSpeed;
         if(_itemCycleDown)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc9_)
            {
               if(itemHolders[_loc2_].y + _loc7_ < itemInfos[_loc2_ + 1].stopY)
               {
                  itemHolders[_loc2_].y += _loc7_;
               }
               else
               {
                  itemHolders[_loc2_].y = itemInfos[_loc2_ + 1].stopY;
                  _loc3_ = true;
               }
               _loc2_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < _loc9_)
            {
               if(itemHolders[_loc4_].y - _loc7_ > itemInfos[_loc4_].stopY)
               {
                  itemHolders[_loc4_].y -= _loc7_;
               }
               else
               {
                  itemHolders[_loc4_].y = itemInfos[_loc4_].stopY;
                  _loc3_ = true;
               }
               _loc4_++;
            }
         }
         _lastTimer = _loc5_;
         if(_loc3_)
         {
            if(_itemCycleDown)
            {
               setupHolders();
            }
            _loc8_ = !_autoScroll && _targetContentItemIndex == _contentItemIndex || _forceSpinStop;
            if(_loc8_)
            {
               _itemCycleTimer.removeEventListener("timer",itemCycleUpdate);
               _itemCycleTimer.reset();
               _randomizing = false;
            }
            if(!_itemCycleDown)
            {
               setupHolders(!_loc8_);
               if(_loc8_)
               {
                  doneSpinning();
               }
            }
         }
      }
      
      private function upBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!_itemCycleTimer.running)
         {
            _loc2_ = _contentItemIndex - 1;
            if(_loc2_ == -1)
            {
               _loc2_ = contentItems.length - 1;
            }
            _btnHoldTimer.start();
            spinToIndex(_loc2_,false);
            _autoCycleDown = true;
         }
      }
      
      private function downBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!_itemCycleTimer.running)
         {
            _loc2_ = _contentItemIndex + 1;
            if(_loc2_ == contentItems.length)
            {
               _loc2_ = 0;
            }
            _btnHoldTimer.start();
            spinToIndex(_loc2_,false);
            _autoCycleDown = false;
         }
      }
      
      private function btnHoldTimerHandler(param1:TimerEvent) : void
      {
         _autoScroll = true;
         _itemCycleDown = _autoCycleDown;
         _btnHoldTimer.reset();
         spin();
      }
      
      private function upBtnMouseUpOutHandler(param1:MouseEvent) : void
      {
         _btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(_autoScroll)
         {
            _autoScroll = false;
            _targetContentItemIndex = _contentItemIndex - 1;
            if(_targetContentItemIndex == -1)
            {
               _targetContentItemIndex = contentItems.length - 1;
            }
         }
      }
      
      private function downBtnMouseUpOutHandler(param1:MouseEvent) : void
      {
         _btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(_autoScroll)
         {
            _autoScroll = false;
            _targetContentItemIndex = _contentItemIndex;
         }
      }
      
      private function itemMouseDownHandler(param1:MouseEvent) : void
      {
         spinToIndex(contentItems.indexOf(param1.currentTarget.text),false);
      }
      
      private function itemMouseOverHandler(param1:MouseEvent) : void
      {
         if(!_itemCycleTimer.hasEventListener("timer") && param1.currentTarget != itemHolders[_centerItemHolderIndex])
         {
            param1.currentTarget.filters = [_hoverItemHolderGlowFilter];
         }
      }
      
      private function itemMouseOutHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.filters = [];
      }
   }
}

class ItemInfo
{
   public var stopY:Number;
   
   public function ItemInfo()
   {
      super();
   }
}
