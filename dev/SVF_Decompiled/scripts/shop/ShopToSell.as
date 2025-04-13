package shop
{
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarManager;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.IitemCollection;
   import collection.PetItemCollection;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.DenAndClothesItemSelect;
   import gui.DenSwitch;
   import gui.GuiRadioButtonGroup;
   import gui.PetInventory;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   import pet.PetItem;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import room.RoomManagerWorld;
   
   public class ShopToSell extends Shop
   {
      private var _itemSelect:DenAndClothesItemSelect;
      
      private var _costTypeRadioBtns:GuiRadioButtonGroup;
      
      private var _selectedItem:Iitem;
      
      private var _addedItems:Vector.<MyShopItem>;
      
      private var _removedItems:Vector.<MyShopItem>;
      
      private var _modifiedItems:Vector.<MyShopItem>;
      
      private var _myShopItems:Vector.<MyShopItem>;
      
      private var _currMyShopItemsArray:Vector.<MyShopItem>;
      
      private var _itemCurrentlyBeingUpdated:MyShopItem;
      
      private var _clonedItems:AccItemCollection;
      
      private var _clonedDenItems:DenItemCollection;
      
      private var _clonedPetItems:PetItemCollection;
      
      private var _myShopData:MyShopData;
      
      private var _petInventory:PetInventory;
      
      private var _selectedGemAmount:int;
      
      private var _selectedDiamondAmount:int;
      
      private var _counterMouseDown:Boolean;
      
      private var _isIncrementing:Boolean;
      
      private var _downTimer:Timer;
      
      private var _myShopItemsReversed:Vector.<MyShopItem>;
      
      private var _myShopItemsGemLow:Vector.<MyShopItem>;
      
      private var _myShopItemsGemHigh:Vector.<MyShopItem>;
      
      private var _myShopItemsNameLow:Vector.<MyShopItem>;
      
      private var _myShopItemsNameHigh:Vector.<MyShopItem>;
      
      public function ShopToSell()
      {
         super();
      }
      
      override public function init(param1:int, param2:int, param3:Avatar, param4:DisplayLayer, param5:Function = null, param6:int = 0, param7:Function = null, param8:Boolean = false, param9:int = -1) : void
      {
         _isDenSaleShopOwner = param3.userName == RoomManagerWorld.instance.denOwnerName;
         _shopToSell = this;
         super.init(param1,1060,param3,param4,param5,param6,param7,param8,param9);
      }
      
      public function get isDenSaleShopOwner() : Boolean
      {
         return _isDenSaleShopOwner;
      }
      
      public function get shopInvId() : int
      {
         return _shopId;
      }
      
      override public function applyAndClose() : void
      {
         if((_addedItems == null || _addedItems.length == 0) && (_removedItems == null || _removedItems.length == 0) && (_modifiedItems == null || _modifiedItems.length == 0))
         {
            _bItemsPurchased = false;
            super.applyAndClose();
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            ShopToSellXtCommManager.requestStoreUpdateItems(_shopId,_myShopData.state,_addedItems,_removedItems,_modifiedItems,onUpdateStoreComplete);
         }
      }
      
      public function removeItemFromStore(param1:Iitem, param2:int) : void
      {
         var _loc4_:* = undefined;
         var _loc3_:int = 0;
         if(_myShopData)
         {
            _loc4_ = _myShopData.shopItems;
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               if(_loc4_[_loc3_].currItem.itemType == param1.itemType && _loc4_[_loc3_].currItem.defId == param1.defId && _loc4_[_loc3_].currItem.invIdx == param2)
               {
                  _loc4_.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      public function updateMyShopDataState(param1:String, param2:int) : void
      {
         if(_myShopData && _myShopData.storeInvId == param2)
         {
            _myShopData.state = param1;
         }
      }
      
      public function setupNewShopLists() : void
      {
         DarkenManager.showLoadingSpiral(false);
         removeItemFromStore(currShopItem.currItem,currShopItem.currItem.invIdx);
         onShopInfoResponse(_myShopData,null,false);
         setupShopWindows();
      }
      
      private function onUpdateStoreComplete(param1:Boolean, param2:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            super.applyAndClose();
         }
         else
         {
            super.applyAndClose();
            ShopManager.clearShopItems(_shopId);
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(33933));
         }
      }
      
      override protected function requestShopList(param1:Function, param2:int) : void
      {
         if(_isDenSaleShopOwner && ShopManager.myShopItems[param2] != null)
         {
            onShopInfoResponse(ShopManager.myShopItems[param2],null);
         }
         else
         {
            ShopToSellXtCommManager.requestStoreInfo(RoomManagerWorld.instance.denOwnerName,_shopId,onShopInfoResponse,null);
         }
      }
      
      private function onShopInfoResponse(param1:MyShopData, param2:Object, param3:Boolean = true) : void
      {
         var i:int;
         var shopData:MyShopData = param1;
         var passback:Object = param2;
         var initialize:Boolean = param3;
         if(_shop)
         {
            _myShopData = shopData;
            _myShopItems = shopData.shopItems.concat();
            _currMyShopItemsArray = _myShopItems;
            _shopItemArray = new IitemCollection();
            i = 0;
            while(i < _myShopItems.length)
            {
               _shopItemArray.pushIitem(_myShopItems[i].currItem);
               i++;
            }
            _myShopItemsReversed = _myShopItems.concat().reverse();
            _myShopItemsGemLow = _myShopItems.concat().sort(function(param1:MyShopItem, param2:MyShopItem):int
            {
               if(param1.currencyType > param2.currencyType)
               {
                  return 1;
               }
               if(param1.currencyType == param2.currencyType)
               {
                  if(param1.cost < param2.cost)
                  {
                     return -1;
                  }
                  if(param1.cost > param2.cost)
                  {
                     return 1;
                  }
                  return 0;
               }
               if(param1.currencyType < param2.currencyType)
               {
                  return -1;
               }
            });
            _myShopItemsGemHigh = _myShopItemsGemLow.concat().reverse();
            _shopItemArrayGemLow = new IitemCollection();
            i = 0;
            while(i < _myShopItemsGemLow.length)
            {
               _shopItemArrayGemLow.setIitem(i,_myShopItemsGemLow[i].currItem);
               i++;
            }
            _shopItemArrayGemHigh = new IitemCollection(_shopItemArrayGemLow.getCoreArray().concat().reverse());
            _myShopItemsNameLow = _myShopItems.concat().sort(function(param1:MyShopItem, param2:MyShopItem):int
            {
               if(param1.currItem.name > param2.currItem.name)
               {
                  return -1;
               }
               if(param1.currItem.name < param2.currItem.name)
               {
                  return 1;
               }
               return 0;
            });
            _myShopItemsNameHigh = _myShopItemsNameLow.concat().reverse();
            _currShopItemArray = _shopItemArray;
            if(initialize)
            {
               initialShopSetup();
            }
         }
      }
      
      public function onSortButton(param1:String, param2:Boolean) : void
      {
         if(param1 == "timeBtn")
         {
            if(param2)
            {
               _currMyShopItemsArray = _myShopItemsReversed;
            }
            else
            {
               _currMyShopItemsArray = _myShopItems;
            }
         }
         else if(param1 == "gemBtn")
         {
            if(param2)
            {
               _currMyShopItemsArray = _myShopItemsGemHigh;
            }
            else
            {
               _currMyShopItemsArray = _myShopItemsGemLow;
            }
         }
         else if(param1 == "abcBtn")
         {
            if(param2)
            {
               _currMyShopItemsArray = _myShopItemsNameLow;
            }
            else
            {
               _currMyShopItemsArray = _myShopItemsNameHigh;
            }
         }
      }
      
      override protected function initialShopSetup() : void
      {
         _isCombinedCurrencyStore = false;
         setupCombinedCurrencyItems(_isCombinedCurrencyStore);
         setupDiamondItems(_shopItemArray.length > 0 ? _shopItemArray.getIitem(0).currencyType == 3 && _glDefType != 1060 : false);
         if(_isDenSaleShopOwner)
         {
            LocalizationManager.translateId(_shop.titleTxt,33912);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_shop.titleTxt,33975,RoomManagerWorld.instance.denOwnerName);
         }
         super.setupCurrencyAmounts();
         super.shopSetupCommon();
         DarkenManager.showLoadingSpiral(false);
      }
      
      override protected function setupClickedWindow(param1:int) : void
      {
         var _loc2_:Iitem = _currShopItemArray.getIitem(_itemIdx);
         if(!_loc2_)
         {
            if(_isDenSaleShopOwner && _numItems < 24)
            {
               if(_clonedItems == null)
               {
                  _clonedItems = new AccItemCollection(gMainFrame.userInfo.playerAvatarInfo.getFullItems().concatCollection(null));
                  _clonedDenItems = new DenItemCollection(AvatarManager.playerAvatar.inventoryDenFull.denItemCollection.concatCollection(null));
                  _clonedPetItems = new PetItemCollection(PetManager.myPetListAsIitem.concatCollection(null));
               }
               _itemCurrentlyBeingUpdated = null;
               _itemSelect = new DenAndClothesItemSelect();
               _itemSelect.init(_clonedItems,_clonedDenItems,_clonedPetItems,_popupLayer,null,onChooseItemsClose,2,null,_currShopItemArray);
            }
            else
            {
               _shop.colorCycleFlash.visible = false;
               _shop.colorCycleBtn.visible = false;
               if(_shop.buyBigPopup)
               {
                  _shop.buyBigPopup.visible = false;
               }
            }
         }
         else if(_isDenSaleShopOwner)
         {
            _itemCurrentlyBeingUpdated = _currMyShopItemsArray[_itemIdx];
            onChooseItemsClose(_shopItemArray.getIitem(_itemIdx));
         }
         else
         {
            super.setupClickedWindow(param1);
         }
      }
      
      override protected function setupBuyPopup() : void
      {
         _itemColorIdx = 0;
         _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
         _itemToBuy.asShopItemSized = true;
         if(_itemToBuy.isMemberOnly)
         {
            _shop.buyPopup.banner.visible = true;
            LocalizationManager.translateId(_shop.buyPopup.banner.txtCont.txt,11376);
            if(_isMember)
            {
               _shop.buyPopup.lockOpen.visible = true;
               _shop.buyPopup.lock.visible = false;
            }
            else
            {
               _shop.buyPopup.lock.visible = true;
               _shop.buyPopup.lockOpen.visible = false;
            }
         }
         else
         {
            _shop.buyPopup.banner.visible = false;
            _shop.buyPopup.lockOpen.visible = false;
            _shop.buyPopup.lock.visible = false;
         }
         if(_itemToBuy.isOcean)
         {
            _shop.buyPopup.buyGreenBG.visible = false;
            _shop.buyPopup.ocean.visible = true;
         }
         else
         {
            _shop.buyPopup.buyGreenBG.visible = true;
            _shop.buyPopup.ocean.visible = false;
         }
         _shop.buyPopup.avtSpecificIcon.visible = false;
         _shop.buyPopup.newTag.visible = false;
         _shop.buyPopup.clearanceTag.visible = false;
         _shop.buyPopup.daysLeftTag.visible = false;
         _shop.buyPopup.saleTag.visible = false;
         _shop.buyPopup.rareDiamondTag.visible = false;
         _shop.buyPopup.customDiamond.visible = false;
         _shop.buyPopup.rareTag.visible = false;
         _shop.buyPopup.diamond.visible = false;
         if(_itemToBuy.isRareDiamond)
         {
            _shop.buyPopup.rareDiamondTag.visible = true;
         }
         else if(_itemToBuy.isCustom)
         {
            _shop.buyPopup.customDiamond.visible = true;
         }
         else
         {
            if(_itemToBuy.isRare)
            {
               _shop.buyPopup.rareTag.visible = true;
               _shop.buyPopup.rareTag.gotoAndStop("noColor");
            }
            _shop.buyPopup.diamond.visible = _itemToBuy.isDiamond;
         }
         if(_itemToBuy.isDiamond)
         {
            _shop.buyPopup.buyGreenBGDiamond.visible = true;
            _shop.buyPopup.buyGreenBG.visible = false;
            _shop.buyPopup.buyBlueBGDiamond.visible = true;
            _shop.buyPopup.buyBlueBG.visible = false;
            _shop.buyPopup.bgDiamond.visible = true;
            _shop.buyPopup.bg.visible = false;
         }
         else
         {
            _shop.buyPopup.buyGreenBGDiamond.visible = false;
            _shop.buyPopup.buyGreenBG.visible = true;
            _shop.buyPopup.buyBlueBGDiamond.visible = false;
            _shop.buyPopup.buyBlueBG.visible = true;
            _shop.buyPopup.bgDiamond.visible = false;
            _shop.buyPopup.bg.visible = true;
         }
         if(_shop.buyPopup.itemLayer.numChildren > 1)
         {
            _shop.buyPopup.itemLayer.removeChildAt(1);
         }
         _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         setupShopItemPrizeTags(_shop.buyPopup,_itemIdx,_shop.buyBtnGreen);
         LocalizationManager.updateToFit(_shop.buyPopupItemNameTxt,_itemToBuy.name);
         if(_shop.buyPopupItemNameTxt.text == _shop.buyPopupItemNameTxtMultiline.text)
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("multi");
         }
         else
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("single");
         }
         _shop.colorCycleFlash.visible = false;
         _shop.colorCycleBtn.visible = false;
         if(_shopWithPreview == null)
         {
            DarkenManager.darken(_shop.buyPopup);
         }
         _shop.buyPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
         if(_itemToBuy.isOcean && _itemToBuy is DenItem && !DenSwitch.haveOceanDen())
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14799));
         }
         _shop.buyBtnGreen.setButtonState(1);
      }
      
      override protected function sendBuyRequest(param1:Iitem) : void
      {
         if(param1.itemType == 2)
         {
            ItemXtCommManager.setItemBuyIlCallback(putOnPurchasedItem);
         }
         else if(param1.itemType == 0)
         {
            DenXtCommManager.denEditorDIResponseCallback = onDenItemPurchaseInventoryResponse;
         }
         else if(param1.itemType == 1)
         {
            if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14783),true,confirmPetRecycle);
               return;
            }
            PetXtCommManager.petCreateCallback = OnPetFinderClose;
         }
         DarkenManager.showLoadingSpiral(true);
         ShopToSellXtCommManager.requestStoreBuy(RoomManagerWorld.instance.denOwnerName,currShopItem,_myShopData.state,confirmPurchase);
      }
      
      private function confirmPetRecycle(param1:Object) : void
      {
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            _petInventory = new PetInventory();
            _petInventory.init(onPetInventoryClose,true);
         }
      }
      
      private function onPetInventoryClose(param1:Boolean) : void
      {
         _petInventory = null;
         if(param1)
         {
            attemptToPurchaseItem();
         }
      }
      
      public function setupShopItemPrizeTags(param1:MovieClip, param2:int, param3:MovieClip = null) : void
      {
         var _loc4_:String = null;
         if(_currMyShopItemsArray.length > param2 ? _currMyShopItemsArray[param2] : null)
         {
            _loc4_ = "";
            if(null.currencyType == 1)
            {
               _loc4_ = "ticket";
            }
            else if(null.currencyType == 2)
            {
               _loc4_ = "earth";
            }
            else if(null.currencyType == 3)
            {
               _loc4_ = "diamond";
            }
            if(UserCurrency.hasEnoughCurrency(null.currencyType,null.cost))
            {
               if(param1.tag.currentFrameLabel != _loc4_ + "green")
               {
                  param1.tag.gotoAndPlay(_loc4_ + "green");
               }
               param1.tag.txt.textColor = "0x386630";
               if(param3 != null)
               {
                  param3.visible = true;
               }
            }
            else
            {
               if(param1.tag.currentFrameLabel != _loc4_ + "red")
               {
                  param1.tag.gotoAndPlay(_loc4_ + "red");
               }
               param1.tag.txt.textColor = "0x800000";
               if(param3 != null)
               {
                  param3.visible = false;
               }
            }
            param1.tag.txt.text = Utility.convertNumberToString(null.cost);
            param1.tag.visible = true;
         }
         else
         {
            param1.tag.visible = false;
         }
      }
      
      public function onEditBtn(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.parent.name == _shop.iw0.name)
         {
            _loc3_ = 0;
         }
         else if(param1.currentTarget.parent.name == _shop.iw1.name)
         {
            _loc3_ = 1;
         }
         else if(param1.currentTarget.parent.name == _shop.iw2.name)
         {
            _loc3_ = 2;
         }
         else if(param1.currentTarget.parent.name == _shop.iw3.name)
         {
            _loc3_ = 3;
         }
         else if(param1.currentTarget.parent.name == _shop.iw4.name)
         {
            _loc3_ = 4;
         }
         else if(param1.currentTarget.parent.name == _shop.iw5.name)
         {
            _loc3_ = 5;
         }
         var _loc2_:int = _loc3_ + _itemOffset;
         _itemCurrentlyBeingUpdated = _currMyShopItemsArray[_loc2_];
         onChooseItemsClose(_shopItemArray.getIitem(_loc2_));
      }
      
      public function onDeleteBtn(param1:MouseEvent) : void
      {
         var _loc7_:int = 0;
         var _loc3_:Boolean = false;
         var _loc5_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.parent.name == _shop.iw0.name)
         {
            _loc7_ = 0;
         }
         else if(param1.currentTarget.parent.name == _shop.iw1.name)
         {
            _loc7_ = 1;
         }
         else if(param1.currentTarget.parent.name == _shop.iw2.name)
         {
            _loc7_ = 2;
         }
         else if(param1.currentTarget.parent.name == _shop.iw3.name)
         {
            _loc7_ = 3;
         }
         else if(param1.currentTarget.parent.name == _shop.iw4.name)
         {
            _loc7_ = 4;
         }
         else if(param1.currentTarget.parent.name == _shop.iw5.name)
         {
            _loc7_ = 5;
         }
         var _loc4_:int = _loc7_ + _itemOffset;
         var _loc6_:Iitem = _shopItemArray.getIitem(_loc4_);
         if(_addedItems)
         {
            _loc5_ = 0;
            while(_loc5_ < _addedItems.length)
            {
               if(_addedItems[_loc5_].currItem.itemType == _loc6_.itemType && _addedItems[_loc5_].currItem.defId == _loc6_.defId)
               {
                  _addedItems.splice(_loc5_,1);
                  _loc3_ = true;
                  break;
               }
               _loc5_++;
            }
         }
         if(_modifiedItems)
         {
            _loc5_ = 0;
            while(_loc5_ < _modifiedItems.length)
            {
               if(_modifiedItems[_loc5_].currItem.itemType == _loc6_.itemType && _modifiedItems[_loc5_].currItem.defId == _loc6_.defId)
               {
                  _modifiedItems.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
         }
         var _loc2_:MyShopItem = _currMyShopItemsArray.splice(_loc4_,1)[0];
         if(!_loc3_)
         {
            if(_removedItems == null)
            {
               _removedItems = new Vector.<MyShopItem>();
            }
            _removedItems.push(_loc2_);
         }
         _shopItemArray.getCoreArray().splice(_loc4_,1);
         _currShopItemArray = _shopItemArray;
         setupShopWindows();
      }
      
      public function get currShopItem() : MyShopItem
      {
         return _currMyShopItemsArray[_itemIdx];
      }
      
      private function onChooseItemsClose(param1:Iitem) : void
      {
         if(param1)
         {
            displaySetCostPopup(param1);
         }
         if(_itemSelect)
         {
            _itemSelect.destroy();
            _itemSelect = null;
         }
      }
      
      private function displaySetCostPopup(param1:Iitem) : void
      {
         var _loc2_:MovieClip = null;
         _selectedItem = param1.clone();
         _shop.setItemCostCont.item_name_txt.text = _selectedItem.name;
         _costTypeRadioBtns = new GuiRadioButtonGroup(_shop.setItemCostCont.options);
         _costTypeRadioBtns.selected = !!_itemCurrentlyBeingUpdated ? (_itemCurrentlyBeingUpdated.currencyType == 3 ? 1 : 0) : 1;
         _costTypeRadioBtns.currRadioButton.addEventListener("mouseDown",onCostDown,false,0,true);
         _shop.setItemCostCont.numTxt.text = !!_itemCurrentlyBeingUpdated ? _itemCurrentlyBeingUpdated.cost : (_costTypeRadioBtns.selected == 1 ? 1 : 50);
         _selectedDiamondAmount = 1;
         _selectedGemAmount = 50;
         setPriceTag();
         if(_selectedItem.isOcean)
         {
            _shop.setItemCostCont.buyBlueBG.visible = true;
            _shop.setItemCostCont.buyGreenBG.visible = false;
            _loc2_ = _shop.setItemCostCont.buyBlueBG;
         }
         else
         {
            _shop.setItemCostCont.buyGreenBG.visible = true;
            _shop.setItemCostCont.buyBlueBG.visible = false;
            _loc2_ = _shop.setItemCostCont.buyGreenBG;
         }
         while(_loc2_.numChildren > 1)
         {
            _loc2_.removeChildAt(_loc2_.numChildren - 1);
         }
         _selectedItem.asShopItemSized = true;
         if(_selectedItem is Item)
         {
            (_selectedItem as Item).specialScale = 1.25;
         }
         _loc2_.addChild(_selectedItem.icon);
         if(!(_selectedItem is DenItem) && !(_selectedItem is AvatarItem) && !(_selectedItem is PetItem))
         {
            _selectedItem.icon.filters = [new GlowFilter(5586479,1,2,2,4)];
         }
         _downTimer = new Timer(500);
         _downTimer.addEventListener("timer",onTimer,false,0,true);
         _shop.setItemCostCont.setCostBtn.addEventListener("mouseDown",onSetCostDown,false,0,true);
         _shop.setItemCostCont.closeBtn.addEventListener("mouseDown",onCloseCostPopup,false,0,true);
         _shop.setItemCostCont.upBtn.addEventListener("mouseDown",onUpDownBtn,false,0,true);
         _shop.setItemCostCont.downBtn.addEventListener("mouseDown",onUpDownBtn,false,0,true);
         _shop.setItemCostCont.upBtn.addEventListener("mouseUp",onUpDownBtnUp,false,0,true);
         _shop.setItemCostCont.downBtn.addEventListener("mouseUp",onUpDownBtnUp,false,0,true);
         _shop.setItemCostCont.upBtn.addEventListener("rollOut",onUpDownBtnUp,false,0,true);
         _shop.setItemCostCont.downBtn.addEventListener("rollOut",onUpDownBtnUp,false,0,true);
         _shop.setItemCostCont.addEventListener("enterFrame",onEnterFrame,false,0,true);
         _shop.setItemCostCont.visible = true;
      }
      
      private function onCostDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_costTypeRadioBtns.selected == 1)
         {
            _shop.setItemCostCont.numTxt.text = _selectedDiamondAmount;
         }
         else
         {
            _shop.setItemCostCont.numTxt.text = _selectedGemAmount;
         }
         setPriceTag();
      }
      
      private function onSetCostDown(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:int = 0;
         var _loc3_:MyShopItem = null;
         param1.stopPropagation();
         if(_itemCurrentlyBeingUpdated)
         {
            if(_modifiedItems == null)
            {
               _modifiedItems = new Vector.<MyShopItem>();
            }
            _itemCurrentlyBeingUpdated.cost = int(_shop.setItemCostCont.numTxt.text);
            _itemCurrentlyBeingUpdated.currencyType = _costTypeRadioBtns.selected == 1 ? 3 : 0;
            if(_addedItems)
            {
               _loc4_ = 0;
               while(_loc4_ < _addedItems.length)
               {
                  if(_addedItems[_loc4_].currItem.itemType == _itemCurrentlyBeingUpdated.currItem.itemType && _addedItems[_loc4_].currItem.defId == _itemCurrentlyBeingUpdated.currItem.defId)
                  {
                     _loc2_ = true;
                     break;
                  }
                  _loc4_++;
               }
            }
            if(!_loc2_)
            {
               _loc4_ = 0;
               while(_loc4_ < _modifiedItems.length)
               {
                  if(_modifiedItems[_loc4_].currItem.itemType == _itemCurrentlyBeingUpdated.currItem.itemType && _modifiedItems[_loc4_].currItem.defId == _itemCurrentlyBeingUpdated.currItem.defId)
                  {
                     _loc2_ = true;
                     break;
                  }
                  _loc4_++;
               }
               if(!_loc2_)
               {
                  _modifiedItems.push(_itemCurrentlyBeingUpdated);
               }
            }
         }
         else
         {
            if(_removedItems)
            {
               _loc4_ = 0;
               while(_loc4_ < _removedItems.length)
               {
                  if(_removedItems[_loc4_].currItem.itemType == _selectedItem.itemType && _removedItems[_loc4_].currItem.defId == _selectedItem.defId)
                  {
                     if((_costTypeRadioBtns.selected == 1 ? 3 : 0) == _removedItems[_loc4_].currencyType && int(_shop.setItemCostCont.numTxt.text) == _removedItems[_loc4_].cost)
                     {
                        _loc2_ = true;
                     }
                     _removedItems.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
            }
            _shopItemArray.pushIitem(_selectedItem.clone());
            _loc3_ = new MyShopItem(_selectedItem.clone(),_costTypeRadioBtns.selected == 1 ? 3 : 0,int(_shop.setItemCostCont.numTxt.text),_shopId);
            if(!_loc2_)
            {
               if(_addedItems == null)
               {
                  _addedItems = new Vector.<MyShopItem>();
               }
               _addedItems.push(_loc3_);
            }
            _currMyShopItemsArray.push(_loc3_);
         }
         _currShopItemArray = _shopItemArray;
         setupShopWindows();
         onCloseCostPopup(param1);
      }
      
      private function onCloseCostPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _shop.setItemCostCont.setCostBtn.removeEventListener("mouseDown",onSetCostDown);
         _shop.setItemCostCont.closeBtn.removeEventListener("mouseDown",onCloseCostPopup);
         _shop.setItemCostCont.upBtn.removeEventListener("mouseDown",onUpDownBtn);
         _shop.setItemCostCont.downBtn.removeEventListener("mouseDown",onUpDownBtn);
         _shop.setItemCostCont.upBtn.removeEventListener("mouseUp",onUpDownBtnUp);
         _shop.setItemCostCont.downBtn.removeEventListener("mouseUp",onUpDownBtnUp);
         _shop.setItemCostCont.upBtn.removeEventListener("rollOut",onUpDownBtnUp);
         _shop.setItemCostCont.downBtn.removeEventListener("rollOut",onUpDownBtnUp);
         _shop.setItemCostCont.removeEventListener("enterFrame",onEnterFrame);
         _downTimer.removeEventListener("timer",onTimer);
         _downTimer.reset();
         _downTimer = null;
         _costTypeRadioBtns.destroy();
         _costTypeRadioBtns = null;
         _selectedItem = null;
         _shop.setItemCostCont.visible = false;
      }
      
      private function setPriceTag() : void
      {
         var _loc1_:String = "";
         if(_costTypeRadioBtns.selected == 1)
         {
            _loc1_ = "diamond";
            _shop.setItemCostCont.gemHighlight.visible = false;
            _shop.setItemCostCont.diamondHighlight.visible = true;
            _selectedDiamondAmount = _shop.setItemCostCont.numTxt.text;
         }
         else
         {
            _shop.setItemCostCont.gemHighlight.visible = true;
            _shop.setItemCostCont.diamondHighlight.visible = false;
            _selectedGemAmount = _shop.setItemCostCont.numTxt.text;
         }
         if(_shop.setItemCostCont.tag.currentFrameLabel != _loc1_ + "green")
         {
            _shop.setItemCostCont.tag.gotoAndPlay(_loc1_ + "green");
         }
         _shop.setItemCostCont.tag.txt.textColor = "0x386630";
         _shop.setItemCostCont.tag.txt.text = Utility.convertNumberToString(_shop.setItemCostCont.numTxt.text);
         _shop.setItemCostCont.tag.visible = true;
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         if(_counterMouseDown)
         {
            if(_downTimer.currentCount == 0)
            {
               _downTimer.start();
            }
            else if(_downTimer.currentCount == 1)
            {
               updateCost(_isIncrementing);
            }
         }
      }
      
      private function onTimer(param1:TimerEvent) : void
      {
         _downTimer.stop();
      }
      
      private function onUpDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _counterMouseDown = true;
         if(param1.currentTarget == _shop.setItemCostCont.upBtn)
         {
            _isIncrementing = true;
         }
         else
         {
            _isIncrementing = false;
         }
         updateCost(_isIncrementing);
      }
      
      private function onUpDownBtnUp(param1:Event) : void
      {
         _counterMouseDown = false;
         _downTimer.reset();
      }
      
      private function updateCost(param1:Boolean) : void
      {
         var _loc2_:int = _costTypeRadioBtns.selected == 1 ? 1 : 50;
         var _loc3_:int = _costTypeRadioBtns.selected == 1 ? 500 : 15000;
         var _loc4_:int = int(_shop.setItemCostCont.numTxt.text);
         if(param1)
         {
            _shop.setItemCostCont.numTxt.text = Math.min(int(_shop.setItemCostCont.numTxt.text) + _loc2_,_loc3_);
         }
         else
         {
            _shop.setItemCostCont.numTxt.text = Math.max(_loc2_,int(_shop.setItemCostCont.numTxt.text) - _loc2_);
         }
         var _loc5_:int = int(_shop.setItemCostCont.numTxt.text);
         if(_loc4_ != _loc5_)
         {
            setPriceTag();
         }
      }
   }
}

