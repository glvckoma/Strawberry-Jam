package gui
{
   import avatar.Avatar;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenRoomItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowAnimal;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import shop.Shop;
   import shop.ShopManager;
   
   public class DenSwitcher
   {
      private const MIN_NUM_DENS:int = 1;
      
      private const DENSWITCH_MEDIA_ID:int = 1168;
      
      private var _numTotalSlots:int;
      
      private var _playerAvatar:Avatar;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _shop:Shop;
      
      private var _views:Array;
      
      private var _activeIdx:int;
      
      private var _idx:int;
      
      private var _recycling:Boolean;
      
      private var _recyclingOnly:Boolean;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _contentItems:Array;
      
      private var _switchContent:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _choosingContent:MovieClip;
      
      private var _scrollButtons:SBScrollbar;
      
      private var _itemWindows:WindowGenerator;
      
      private var _openStoreOnly:Boolean;
      
      private var _firstOpenIdx:int;
      
      private var _glId:int;
      
      private var _storeItemIndex:int;
      
      public function DenSwitcher()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:Boolean = false, param4:Boolean = false, param5:Function = null, param6:int = -1, param7:int = -1, param8:int = -1, param9:int = 450, param10:int = 250) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _playerAvatar = param1;
         _guiLayer = param2;
         _closeCallback = param5;
         _recyclingOnly = param3;
         _openStoreOnly = param4;
         _firstOpenIdx = param6;
         _storeItemIndex = param8;
         _numTotalSlots = 200;
         _mediaHelpers = [];
         if(param7 == -1)
         {
            _glId = 13;
         }
         else
         {
            _glId = param7;
         }
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1168,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         removeListeners();
         KeepAlive.stopKATimer(_switchContent);
         _loc1_ = 0;
         while(_loc1_ < _views.length)
         {
            if(_views[_loc1_])
            {
               _views[_loc1_].destroy();
               _views[_loc1_] = null;
            }
            _loc1_++;
         }
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(_switchContent)
         {
            if(_switchContent.root.parent == _guiLayer)
            {
               _guiLayer.removeChild(_switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(_switchContent.root));
            _switchContent.root.removeEventListener("mouseDown",onPopup);
            _switchContent = null;
            if(_closeBtn)
            {
               _closeBtn = null;
            }
            if(_contentItems)
            {
               _contentItems = null;
            }
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         _recyclingOnly = false;
         _recycling = false;
         _closeCallback = null;
      }
      
      public function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      public function get idx() : int
      {
         return _idx;
      }
      
      public function showDenSwitcher(param1:Boolean, param2:int = -1) : void
      {
         if(_switchContent && _switchContent.root.visible != param1)
         {
            _switchContent.root.visible = param1;
            if(param1)
            {
               DarkenManager.darken(MovieClip(_switchContent.root));
            }
            else if(param2 == -1)
            {
               DarkenManager.unDarken(MovieClip(_switchContent.root));
            }
            if(param2 != -1)
            {
               _switchContent.root.parent.setChildIndex(_switchContent.root,param2);
               _switchContent.root.visible = param1;
            }
         }
         else if(param1)
         {
            _switchContent.root.parent.setChildIndex(_switchContent.root,_switchContent.root.parent.numChildren - 1);
         }
      }
      
      public function rebuildWindows(param1:Boolean, param2:Function) : void
      {
         _closeCallback = param2;
         _recyclingOnly = param1;
         buildWindows();
      }
      
      public function get currCloseCallback() : Function
      {
         return _closeCallback;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:* = false;
         if(param1)
         {
            _closeBtn = MovieClip(param1.getChildAt(0)).bx;
            _switchContent = MovieClip(param1.getChildAt(0)).c;
            KeepAlive.startKATimer(_switchContent);
            _guiLayer.addChild(param1);
            param1.addEventListener("mouseDown",onPopup,false,0,true);
            param1.x = 900 * 0.5;
            param1.y = 550 * 0.5;
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(param1);
            addListeners();
            _loc2_ = _firstOpenIdx != -1;
            initVisibilityAndStates();
            buildWindows();
            if(_openStoreOnly)
            {
               param1.visible = false;
               onItemWindowDown(null);
            }
            else if(_loc2_)
            {
               onItemWindowDown(null);
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function initVisibilityAndStates() : void
      {
         _activeIdx = DenSwitch.activeDenIdx;
         _switchContent.buyPopup.tag.visible = false;
         _switchContent.oopsPopup.body_txt.text = "";
         LocalizationManager.translateId(_switchContent.switchTitleTxt,11271);
         _switchContent.buyPopup.tag.txt.text = "";
         _switchContent.buyPopup.paw.gray.visible = false;
         _switchContent.buyPopup.banner.visible = false;
         _switchContent.buyPopup.lock.visible = false;
         _switchContent.buyPopup.lockOpen.visible = false;
         _switchContent.buyPopup.colorChange_btn.visible = false;
         _switchContent.buyPopup.paw.visible = true;
         _switchContent.buyPopup.visible = false;
         _switchContent.oopsPopup.visible = false;
         _switchContent.oopsCostPopup.visible = false;
         _switchContent.denShopTag.visible = false;
         _switchContent.saveAmlTag.visible = false;
         _switchContent.newAmlTag.visible = false;
      }
      
      private function buildWindows() : void
      {
         var _loc5_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc1_:MediaHelper = null;
         if(_scrollButtons)
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         var _loc6_:int = _numTotalSlots;
         var _loc7_:int = Math.min(_loc6_,4);
         var _loc3_:int = Math.ceil(_loc7_ / 2);
         _itemWindows = new WindowGenerator();
         _itemWindows.init(_loc7_,_loc3_,_loc6_,1,2,0,ItemWindowAnimal,DenSwitch.denList.getCoreArray(),"icon",{
            "mouseDown":onItemWindowDown,
            "mouseOver":onItemWindowOver,
            "mouseOut":onItemWindowOut
         },{"recylingOnly":_recyclingOnly},null,false,false);
         _switchContent.itemBlock.addChild(_itemWindows);
         _views = new Array(_numTotalSlots);
         _contentItems = new Array(_numTotalSlots);
         _activeIdx = DenSwitch.activeDenIdx;
         _loc5_ = 0;
         while(_loc5_ < _numTotalSlots)
         {
            _loc2_ = MovieClip(_itemWindows.bg.getChildAt(_loc5_));
            _contentItems[_loc5_] = _loc2_;
            if(DenSwitch.denList.getDenRoomItem(_loc5_) != null)
            {
               _loc1_ = new MediaHelper();
               _loc1_.init(DenSwitch.denList.getDenRoomItem(_loc5_).mediaId,mediaHelperCallback,DenSwitch.denList.getDenRoomItem(_loc5_).isMemberOnly);
               _views[_loc5_] = _loc1_;
            }
            else if(_firstOpenIdx == -1)
            {
               _firstOpenIdx = _loc5_;
            }
            _loc5_++;
         }
         if(_firstOpenIdx == -1)
         {
            _firstOpenIdx = 0;
         }
         var _loc4_:int = DenSwitch.numDens;
         if(_loc4_ > 1)
         {
            _switchContent.recycleBtn.gray.visible = false;
            _switchContent.recycleBtn.mouse.visible = true;
            _switchContent.recycleBtn.down.visible = false;
         }
         else
         {
            _switchContent.recycleBtn.gray.visible = true;
            _switchContent.recycleBtn.mouse.visible = false;
            _switchContent.recycleBtn.down.visible = false;
         }
         if(_recyclingOnly)
         {
            _recycling = true;
         }
         if(_loc4_ >= _numTotalSlots && !_recyclingOnly)
         {
            _switchContent.denShopTag.visible = true;
         }
         else
         {
            _switchContent.denShopTag.visible = false;
         }
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_itemWindows,840,440,-6,"scrollbar2",221.95);
         _switchContent.itemCounter.counterTxt.text = DenSwitch.numDens + "/" + 200;
      }
      
      public function switchDenCallback(param1:Boolean) : void
      {
         if(param1)
         {
            close();
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11272);
            _switchContent.oopsPopup.visible = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function recycleDenCallback(param1:Boolean, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param1)
         {
            if(_recyclingOnly)
            {
               DarkenManager.showLoadingSpiral(false);
               if(_closeCallback != null)
               {
                  _closeCallback(true);
               }
               else
               {
                  destroy();
               }
            }
            else
            {
               _loc3_ = _contentItems[param2];
               if(_views[param2])
               {
                  _views[param2].destroy();
                  _views[param2] = null;
               }
               _recycling = false;
               _loc5_ = 0;
               while(_loc5_ < _numTotalSlots)
               {
                  _contentItems[_loc5_].recycle.visible = false;
                  _loc5_++;
               }
               _loc3_.resetWindow(param2);
               _loc4_ = DenSwitch.numDens;
               if(_loc4_ <= 1)
               {
                  _switchContent.recycleBtn.gray.visible = true;
                  _switchContent.recycleBtn.mouse.visible = false;
                  _switchContent.recycleBtn.down.visible = false;
               }
               if(_loc4_ >= _numTotalSlots)
               {
                  _switchContent.denShopTag.visible = true;
               }
               else
               {
                  _switchContent.denShopTag.visible = false;
               }
               _switchContent.itemCounter.counterTxt.text = _loc4_ + "/" + 200;
            }
         }
         else
         {
            DarkenManager.darken(_switchContent.oopsPopup);
            LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11273);
            _switchContent.oopsPopup.visible = true;
            _recycling = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function purchasedDenRoomCallback() : void
      {
         if(_shop)
         {
            _shop.onDenPurchase();
         }
         if(!_openStoreOnly)
         {
            closeDenShop(true);
         }
         var _loc2_:DenRoomItem = DenSwitch.denList.getDenRoomItem(_idx);
         ItemWindowAnimal(MovieClip(_itemWindows).bg.getChildAt(_idx)).currItem = _loc2_;
         var _loc3_:MovieClip = _contentItems[_idx];
         _loc3_.buyDen.visible = false;
         _loc3_.denWindow.visible = true;
         LocalizationManager.updateToFit(_loc3_.denWindow.txt,_loc2_.name,false,false,false);
         _loc3_.denWindow.sel.visible = false;
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(_loc2_.mediaId,mediaHelperCallback,_loc2_.isMemberOnly);
         _views[_idx] = _loc1_;
         var _loc4_:int = DenSwitch.numDens;
         if(_loc4_ >= _numTotalSlots)
         {
            _switchContent.denShopTag.visible = true;
         }
         else
         {
            _switchContent.denShopTag.visible = false;
         }
         if(_loc4_ > 1)
         {
            _switchContent.recycleBtn.gray.visible = false;
            _switchContent.recycleBtn.mouse.visible = true;
            _switchContent.recycleBtn.down.visible = false;
         }
         if(_shop)
         {
            _shop.denItemIdx = _firstOpenIdx = Math.max(0,DenSwitch.nextFreeSlotIdx);
         }
         _switchContent.itemCounter.counterTxt.text = _loc4_ + "/" + 200;
      }
      
      public function closeDenShop(param1:Boolean = false) : void
      {
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(_openStoreOnly)
         {
            close();
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _views.length)
         {
            if(_views[_loc2_] == param1.mediaHelper)
            {
               if(param1.passback && !gMainFrame.userInfo.isMember)
               {
                  _contentItems[_loc2_].gray.amlMask.amlBox.addChild(param1);
                  break;
               }
               (_contentItems[_loc2_].denWindow as MovieClip).itemBlock.addChild(param1);
               break;
            }
            _loc2_++;
         }
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         if(param1.status)
         {
            DenSwitch.removeDen(_idx,recycleDenCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            _idx = param1.currentTarget.index;
         }
         else
         {
            _idx = _firstOpenIdx;
         }
         if(_contentItems[_idx].buyDen.visible || _openStoreOnly)
         {
            if(!ShopManager.isWorldShopOpen())
            {
               _shop = new Shop();
               _shop.init(_glId,1060,_playerAvatar,_guiLayer,closeDenShop,_idx,purchasedDenRoomCallback,_openStoreOnly,_storeItemIndex);
            }
         }
         else if(_contentItems[_idx].gray.visible == true && !_recycling)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("dens","useLockedDen/" + DenSwitch.denList.getDenRoomItem(_idx).name);
            }
         }
         else if(_recycling)
         {
            if(_idx == _activeIdx)
            {
               DarkenManager.darken(_switchContent.oopsPopup);
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11274);
               _switchContent.oopsPopup.visible = true;
            }
            else if(_idx == 0)
            {
               DarkenManager.darken(_switchContent.oopsPopup);
               LocalizationManager.translateId(_switchContent.oopsPopup.body_txt,11275);
               _switchContent.oopsPopup.visible = true;
            }
            else
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14715,Utility.convertNumberToString(DenSwitch.denList.getDenRoomItem(idx).recycleValue)),true,confirmRecycleHandler);
            }
         }
         else if((_contentItems[_idx].denWindow as MovieClip).visible == true)
         {
            if(_idx != _activeIdx)
            {
               DarkenManager.showLoadingSpiral(true);
               DenSwitch.switchDens(_idx,switchDenCallback);
            }
         }
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         if((_contentItems[_idx].denWindow as MovieClip).currentFrameLabel != "mouse")
         {
            (_contentItems[_idx].denWindow as MovieClip).gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         if((_contentItems[_idx].denWindow as MovieClip).currentFrameLabel != "out")
         {
            (_contentItems[_idx].denWindow as MovieClip).gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_switchContent.oopsPopup);
         _switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(!_recyclingOnly)
         {
            if(_recycling)
            {
               _loc2_ = 0;
               while(_loc2_ < _numTotalSlots)
               {
                  _contentItems[_loc2_].recycle.visible = false;
                  _loc2_++;
               }
               _recycling = false;
            }
            else if(!_switchContent.recycleBtn.gray.visible)
            {
               _recycling = true;
               _loc3_ = 0;
               while(_loc3_ < _numTotalSlots)
               {
                  if(_views[_loc3_])
                  {
                     if(!_contentItems[_loc3_].buyDen.visible)
                     {
                        _contentItems[_loc3_].recycle.visible = true;
                     }
                  }
                  _loc3_++;
               }
            }
            else
            {
               _switchContent.recycleBtn.mouse.visible = false;
            }
         }
      }
      
      private function onRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14626),25,490);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMoreDenDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_recyclingOnly)
         {
            _shop = new Shop();
            _shop.init(_glId,1040,_playerAvatar,_guiLayer,closeDenShop,-1,purchasedDenRoomCallback);
         }
      }
      
      private function addListeners() : void
      {
         if(_closeBtn)
         {
            _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         }
         if(_switchContent)
         {
            _switchContent.recycleBtn.addEventListener("mouseDown",onRecycleDown,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOver",onRecycleOver,false,0,true);
            _switchContent.recycleBtn.addEventListener("mouseOut",onRecycleOut,false,0,true);
            _switchContent.oopsPopup.closeBtn.addEventListener("mouseDown",onOopsClose,false,0,true);
            _switchContent.denShopTag.denShopBtn.addEventListener("mouseDown",onMoreDenDown,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numTotalSlots)
         {
            if(_contentItems[_loc1_])
            {
               _contentItems[_loc1_].removeEventListener("mouseDown",onItemWindowDown);
               _contentItems[_loc1_].removeEventListener("rollOver",onItemWindowOver);
               _contentItems[_loc1_].removeEventListener("rollOut",onItemWindowOut);
            }
            _loc1_++;
         }
         if(_closeBtn)
         {
            _closeBtn.removeEventListener("mouseDown",onClose);
         }
         if(_switchContent)
         {
            _switchContent.recycleBtn.removeEventListener("mouseDown",onRecycleDown);
            _switchContent.recycleBtn.removeEventListener("mouseOver",onRecycleOver);
            _switchContent.recycleBtn.removeEventListener("mouseOut",onRecycleOut);
            _switchContent.oopsPopup.closeBtn.removeEventListener("mouseDown",onOopsClose);
            _switchContent.denShopTag.denShopBtn.removeEventListener("mouseDown",onMoreDenDown);
         }
      }
   }
}

