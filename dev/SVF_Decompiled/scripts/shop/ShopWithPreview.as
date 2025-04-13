package shop
{
   import avatar.Avatar;
   import avatar.AvatarEditorView;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import collection.AccItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.LayerAnim;
   import currency.UserCurrency;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiSoundToggleButton;
   import gui.LoadingSpiral;
   import inventory.Iitem;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ShopWithPreview extends Shop
   {
      private static const SHOP_WITH_PREVIEW_MEDIA_ID:int = 4753;
      
      private static const NUM_COLOR_ICONS:int = 8;
      
      private var _avtEditorView:AvatarEditorView;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _accShownItems:AccItemCollection;
      
      private var _isShowingAnItem:Boolean;
      
      private var _lastItemAdded:Item;
      
      private var _currColorIdx:int;
      
      private var _lastWindowIx:int;
      
      private var _lastItemOffset:int;
      
      public function ShopWithPreview()
      {
         super();
      }
      
      override public function init(param1:int, param2:int, param3:Avatar, param4:DisplayLayer, param5:Function = null, param6:int = 0, param7:Function = null, param8:Boolean = false, param9:int = -1) : void
      {
         DarkenManager.showLoadingSpiral(true);
         SBTracker.push();
         _shopId = param1;
         _glDefType = param2;
         _playerAvatar = param3;
         _popupLayer = param4;
         _appendString = "";
         _isMember = gMainFrame.userInfo.isMember;
         _denRoomShopCallback = param7;
         _isShopOnlyDen = param8;
         _isInFFM = GuiManager.isInFFM;
         _useStartupShopIndex = param9;
         _denItemIdx = param6;
         _closeCallback = param5;
         _shopWithPreview = this;
         _lastItemAdded = null;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4753,onShopLoaded);
      }
      
      public function checkAndRemovePrevItem(param1:Iitem, param2:int, param3:Boolean = false) : void
      {
         if(_lastItemAdded && param1 is Item && param1.defId != _lastItemAdded.defId || _lastWindowIx != param2 || _lastItemOffset != _itemOffset || param3)
         {
            _shop["iw" + _lastWindowIx].yellowBG.visible = false;
            (_shop["iconItemWindow_" + (_currColorIdx + 1)] as GuiSoundToggleButton).downToUpState();
            _currColorIdx = _itemColorIdx = 0;
         }
      }
      
      public function handleItemEquip(param1:Iitem, param2:int, param3:Boolean = false) : void
      {
         checkAndRemovePrevItem(param1,param2,param3);
         _lastWindowIx = param2;
         _lastItemOffset = _itemOffset;
         _shop["iw" + param2].yellowBG.visible = !_shop["iw" + param2].yellowBG.visible;
         if(param1 is Item)
         {
            if((param1 as Item).getInUse(_playerAvatar.avInvId))
            {
               hideItem(Item(param1));
               _lastItemOffset = 0;
               _lastWindowIx = 0;
               _itemIdx = -1;
            }
            else if(!(param1 as Item).getInUse(_playerAvatar.avInvId))
            {
               showItem(Item(param1));
            }
            if(_shop.buyPopup.visible)
            {
               if(_itemIdx == -1)
               {
                  onBuyPopupCloseBtnDown(null);
               }
               else
               {
                  setupBuyPopup();
               }
            }
            return;
         }
         throw new Error("Trying to equip item that is not an Item");
      }
      
      public function purchaseComplete() : void
      {
         var _loc2_:int = 0;
         _lastItemAdded.setInUse(_playerAvatar.avInvId,false);
         _lastItemAdded.setIconColor(_lastItemAdded.layerId,_itemColorsArray[_itemToBuy.defId][0]);
         _lastItemAdded = null;
         setBtnsAndName(false,null);
         if(_avtEditorView)
         {
            _shop.charBox.removeChild(_avtEditorView);
         }
         _loc2_ = 1;
         while(_loc2_ <= 8)
         {
            (_shop["iconItemWindow_" + _loc2_] as GuiSoundToggleButton).downToUpState();
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _shop["iw" + _loc2_].yellowBG.visible = false;
            _loc2_++;
         }
         _avtEditorView = new AvatarEditorView();
         _avtEditorView.init(_playerAvatar,null,onAvatarChanged);
         var _loc1_:Point = AvatarUtility.getAvatarViewPosition(_avtEditorView.avTypeId);
         _avtEditorView.x = _loc1_.x;
         _avtEditorView.y = _loc1_.y;
         if(Utility.isOcean(_playerAvatar.enviroTypeFlag))
         {
            if(Utility.isLand(_playerAvatar.enviroTypeFlag))
            {
               _shop.charBox.gotoAndStop(3);
            }
            else
            {
               _shop.charBox.gotoAndStop(2);
            }
         }
         _shop.charBox.addChild(_avtEditorView);
         _avtEditorView.playAnim(13,false,1,onAvatarLoaded);
         _accShownItems = new AccItemCollection(_avtEditorView.accShownItems.concatCollection(null));
      }
      
      public function adjustColor() : void
      {
         if(_itemToBuy)
         {
            setColorsOnIcons(_itemColorIdx);
         }
      }
      
      public function checkIfThisItemEquipped(param1:int, param2:int) : void
      {
         var _loc3_:Iitem = _currShopItemArray.getIitem(param1 + param2);
         if(_lastItemAdded && _loc3_ is Item && _lastItemAdded.defId == _loc3_.defId)
         {
            _shop["iw" + param1].yellowBG.visible = true;
         }
         else
         {
            _shop["iw" + param1].yellowBG.visible = false;
         }
      }
      
      override protected function toggleInitialVisibility() : void
      {
         super.toggleInitialVisibility();
         setBtnsAndName(false,null);
         _loadingSpiralAvatar = new LoadingSpiral(_shop.charBox);
         _avtEditorView = new AvatarEditorView();
         _avtEditorView.init(_playerAvatar,null,onAvatarChanged);
         var _loc1_:Point = AvatarUtility.getAvatarViewPosition(_avtEditorView.avTypeId);
         _avtEditorView.x = _loc1_.x;
         _avtEditorView.y = _loc1_.y;
         if(Utility.isOcean(_playerAvatar.enviroTypeFlag))
         {
            if(Utility.isLand(_playerAvatar.enviroTypeFlag))
            {
               _shop.charBox.gotoAndStop(3);
            }
            else
            {
               _shop.charBox.gotoAndStop(2);
            }
         }
         _shop.charBox.addChild(_avtEditorView);
         _avtEditorView.playAnim(13,false,1,onAvatarLoaded);
         _accShownItems = new AccItemCollection(_avtEditorView.accShownItems.concatCollection(null));
      }
      
      override protected function addListeners() : void
      {
         var _loc1_:int = 0;
         super.addListeners();
         _shop.buyBtnGreenPreview.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _shop.buyBtnRedPreview.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _shop.zoomBtn.addEventListener("mouseDown",onZoomBtn,false,0,true);
         _loc1_ = 1;
         while(_loc1_ <= 8)
         {
            _shop["iconItemWindow_" + _loc1_].addEventListener("mouseDown",onIconItemDown,false,0,true);
            _loc1_++;
         }
      }
      
      override protected function removeListeners() : void
      {
         var _loc1_:int = 0;
         super.removeListeners();
         _shop.buyBtnGreenPreview.removeEventListener("mouseDown",onBuyBtn);
         _shop.buyBtnRedPreview.removeEventListener("mouseDown",onBuyBtn);
         _shop.zoomBtn.removeEventListener("mouseDown",onZoomBtn);
         _loc1_ = 1;
         while(_loc1_ <= 8)
         {
            _shop["iconItemWindow_" + _loc1_].removeEventListener("mouseDown",onIconItemDown);
            _loc1_++;
         }
      }
      
      private function onAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.destroy();
            _loadingSpiralAvatar = null;
         }
      }
      
      private function onAvatarChanged(param1:AvatarView) : void
      {
         _avtEditorView.playAnim(13,false,1,onAvatarLoaded);
      }
      
      private function showItem(param1:Item, param2:Function = null) : void
      {
         if(param1)
         {
            if(_lastItemAdded != null)
            {
               hideItem(_lastItemAdded);
            }
            _lastItemAdded = param1;
            _avtEditorView.showAccessory(param1,param2);
            _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
            setBtnsAndName(true,param1);
            setupColorIcons();
         }
      }
      
      private function hideItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _avtEditorView.hideAccessory(param1);
            _lastItemAdded = null;
            _itemToBuy = null;
            _loc2_ = 0;
            while(_loc2_ < _accShownItems.length)
            {
               _avtEditorView.showAccessory(_accShownItems.getAccItem(_loc2_));
               _loc2_++;
            }
            setBtnsAndName(false,null);
         }
      }
      
      private function setBtnsAndName(param1:Boolean, param2:Item) : void
      {
         var _loc3_:int = 0;
         if(param1)
         {
            if(UserCurrency.hasEnoughCurrency(param2.currencyType,param2.value))
            {
               _shop.buyBtnGreenPreview.visible = true;
               _shop.buyBtnRedPreview.visible = false;
            }
            else
            {
               _shop.buyBtnGreenPreview.visible = false;
               _shop.buyBtnRedPreview.visible = true;
            }
            LocalizationManager.updateToFit(_shop.itemNameTxt,param2.name);
         }
         else
         {
            _shop.buyBtnGreenPreview.visible = false;
            _shop.buyBtnRedPreview.visible = false;
         }
         _shop.itemNameBa.visible = param1;
         _shop.itemNameTxt.visible = param1;
         _shop.previewBtnBa.visible = param1;
         _shop.zoomBtn.activateGrayState(!param1);
         _loc3_ = 1;
         while(_loc3_ <= 8)
         {
            _shop["iconItemWindow_" + _loc3_].visible = param1;
            _loc3_++;
         }
      }
      
      private function setupColorIcons() : void
      {
         var _loc3_:Array = null;
         var _loc2_:Item = null;
         var _loc1_:int = 0;
         if(_itemToBuy is Item && _itemColorsArray)
         {
            _loc3_ = _itemColorsArray[_itemToBuy.defId];
            _loc2_ = _itemToBuy.clone() as Item;
            _loc2_.specialScale = 0.5;
            _loc1_ = 0;
            while(_loc1_ < 8)
            {
               if(_loc3_[_loc1_] != null)
               {
                  _loc2_.color = _loc3_[_loc1_];
                  (_shop["iconItemWindow_" + (_loc1_ + 1)] as GuiSoundToggleButton).insertIitem(_loc2_,"itemLayer");
                  _shop["iconItemWindow_" + (_loc1_ + 1)].mouseEnabled = true;
                  _shop["iconItemWindow_" + (_loc1_ + 1)].mouseChildren = true;
                  _shop["iconItemWindow_" + (_loc1_ + 1)].visible = true;
               }
               else
               {
                  _shop["iconItemWindow_" + (_loc1_ + 1)].mouseEnabled = false;
                  _shop["iconItemWindow_" + (_loc1_ + 1)].mouseChildren = false;
                  _shop["iconItemWindow_" + (_loc1_ + 1)].visible = false;
               }
               _loc1_++;
            }
            (_itemToBuy as Item).color = _loc3_[_itemColorIdx];
            (_shop["iconItemWindow_" + (_itemColorIdx + 1)] as GuiSoundToggleButton).upToDownState();
         }
      }
      
      private function onZoomBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            setupBuyPopup();
         }
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         buyBtnDownHandler(null);
      }
      
      private function onIconItemDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         setColorsOnIcons(param1.currentTarget.name.split("_")[1] - 1);
      }
      
      private function setColorsOnIcons(param1:int) : void
      {
         (_shop["iconItemWindow_" + (_currColorIdx + 1)] as GuiSoundToggleButton).downToUpState();
         _currColorIdx = _itemColorIdx = param1;
         (_shop["iconItemWindow_" + (_currColorIdx + 1)] as GuiSoundToggleButton).upToDownState();
         (_itemToBuy as Item).color = _itemColorsArray[_itemToBuy.defId][_itemColorIdx];
         _avtEditorView.replaceAccItem(_itemToBuy as Item,_itemToBuy as Item);
         if(_shop.buyPopup.visible)
         {
            _itemToBuy.largeIcon;
         }
      }
   }
}

