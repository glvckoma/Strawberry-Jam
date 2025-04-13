package gui
{
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.TradeItemCollection;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.prediction.SetDictionary;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowOriginal;
   import inventory.Iitem;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import playerWall.PlayerWallManager;
   import shop.MyShopData;
   import shop.MyShopItem;
   import shop.ShopManager;
   import shop.ShopToSellXtCommManager;
   
   public class RecycleItems
   {
      public static const RECYCLE_ACCESSORIES:int = 0;
      
      public static const RECYCLE_DEN_ITEMS:int = 1;
      
      public static const RECYCLE_DEN_AUDIO:int = 2;
      
      public static const RECYCLE_DEN_ITEMS_OCEAN_ONLY:int = 3;
      
      public static const RECYCLE_DEN_ITEMS_LAND_ONLY:int = 4;
      
      public static const RECYCLE_ACCESSORIES_OCEAN_ONLY:int = 5;
      
      public static const RECYCLE_ACCESSORIES_LAND_ONLY:int = 6;
      
      private static var _accessoriesScrollValue:Number = 0;
      
      private static var _accessoriesOceanOnlyScrollValue:Number = 0;
      
      private static var _accessoriesLandOnlyScrollValue:Number = 0;
      
      private static var _denScrollValue:Number = 0;
      
      private static var _denOceanOnlyScrollValue:Number = 0;
      
      private static var _denLandOnlyScrollValue:Number = 0;
      
      private static var _denAudioScrollValue:Number = 0;
      
      private static var _scrollValue:Number = 0;
      
      private const POPUP_MEDIA_ID:int = 4618;
      
      private const RECYCLE_TUT_LIST_ID:int = 52;
      
      private var _popupLayer:DisplayObjectContainer;
      
      private var _recyclePopup:MovieClip;
      
      private var _confirmPopup:MovieClip;
      
      private var _recycleInventory:IitemCollection;
      
      private var _itemsToRecycle:SetDictionary;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _confirmWindows:WindowAndScrollbarGenerator;
      
      private var _mediaHelper:MediaHelper;
      
      private var _invIdxIntCollection:IntItemCollection;
      
      private var _itemRecycleId:int;
      
      private var _savedTradeIndexes:Vector.<Object>;
      
      private var _recycleOneItem:Boolean;
      
      private var _hasRecycled:Boolean;
      
      private var _isInCurrEnviro:Boolean;
      
      private var _recycleTotal:int;
      
      private var _closeCallback:Function;
      
      private var _onRecycleSuccessCallback:Function;
      
      public function RecycleItems()
      {
         super();
      }
      
      private static function onInfoBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function init(param1:int, param2:DisplayObjectContainer, param3:Boolean = false, param4:Function = null, param5:int = 450, param6:int = 250, param7:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _itemRecycleId = param1;
         _popupLayer = param2;
         _recycleOneItem = param3;
         _isInCurrEnviro = param7;
         _closeCallback = param4;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4618,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         removeListeners();
         confirmRemoveEventListeners();
         if(_itemWindows)
         {
            _scrollValue = _itemWindows.scrollYValue;
            switch(_itemRecycleId)
            {
               case 0:
                  _accessoriesScrollValue = _scrollValue;
                  break;
               case 1:
                  _denScrollValue = _scrollValue;
                  break;
               case 2:
                  _denAudioScrollValue = _scrollValue;
                  break;
               case 3:
                  _denOceanOnlyScrollValue = _scrollValue;
                  break;
               case 4:
                  _denLandOnlyScrollValue = _scrollValue;
                  break;
               case 5:
                  _accessoriesOceanOnlyScrollValue = _scrollValue;
                  break;
               case 6:
                  _accessoriesLandOnlyScrollValue = _scrollValue;
            }
            _itemWindows.destroy();
            _itemWindows = null;
         }
         DarkenManager.unDarken(_confirmPopup);
         DarkenManager.unDarken(_recyclePopup);
         _popupLayer.removeChild(_recyclePopup);
         _hasRecycled = false;
         _closeCallback = null;
      }
      
      public function hasBeenInited() : Boolean
      {
         return _recyclePopup != null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _recyclePopup = param1.getChildAt(0) as MovieClip;
         _confirmPopup = _recyclePopup.confirmPopup;
         _confirmPopup.visible = false;
         _mediaHelper.destroy();
         _mediaHelper = null;
         _recyclePopup.recycleBtn.activateGrayState(true);
         _recyclePopup.currencyToolTip.text = 0;
         addListeners();
         _recyclePopup.x = 900 * 0.5;
         _recyclePopup.y = 550 * 0.5;
         _popupLayer.addChild(_recyclePopup);
         DarkenManager.darken(_recyclePopup);
         _itemsToRecycle = new SetDictionary();
         _savedTradeIndexes = new Vector.<Object>();
         AJAudio.playItemRecycledSound();
         if(_itemRecycleId == 1 || _itemRecycleId == 3 || _itemRecycleId == 4)
         {
            if(gMainFrame.userInfo.playerUserInfo.denItemsFull.length <= 0)
            {
               DenXtCommManager.requestDenItems(fillInventory);
            }
            else
            {
               fillInventory();
            }
         }
         else
         {
            fillInventory();
         }
      }
      
      private function fillInventory(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc5_:AccItemCollection = null;
         var _loc2_:DenItemCollection = null;
         var _loc4_:int = 0;
         if(!param1)
         {
            _recycleInventory = new IitemCollection();
            if(_itemRecycleId == 0)
            {
               _recycleInventory = new IitemCollection((gMainFrame.userInfo.playerAvatarInfo.getFullItems() as IitemCollection).concatCollection(null));
               _scrollValue = _accessoriesScrollValue;
            }
            else if(_itemRecycleId == 6 || _itemRecycleId == 5)
            {
               _loc5_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(_itemRecycleId == 6)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc5_.length)
                  {
                     if(_loc5_.getAccItem(_loc3_).enviroType == 0 || _loc5_.getAccItem(_loc3_).isLandAndOcean)
                     {
                        _recycleInventory.pushIitem(_loc5_.getAccItem(_loc3_).clone());
                     }
                     _loc3_++;
                  }
                  _scrollValue = _accessoriesLandOnlyScrollValue;
               }
               else
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc5_.length)
                  {
                     if(_loc5_.getAccItem(_loc3_).enviroType == 1 || _loc5_.getAccItem(_loc3_).isLandAndOcean)
                     {
                        _recycleInventory.pushIitem(_loc5_.getAccItem(_loc3_).clone());
                     }
                     _loc3_++;
                  }
                  _scrollValue = _accessoriesOceanOnlyScrollValue;
               }
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.playerUserInfo.denItemsFull;
               if(_itemRecycleId == 4 || _itemRecycleId == 3)
               {
                  if(_isInCurrEnviro)
                  {
                     _loc2_ = Utility.denItemListByEnviroType(_loc2_,_itemRecycleId == 4 ? 0 : 1);
                  }
               }
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  if(_itemRecycleId == 2)
                  {
                     if(_loc2_.getDenItem(_loc3_).sortId == 4 && _loc2_.getDenItem(_loc3_).defId != 617)
                     {
                        _recycleInventory.setIitem(_loc4_,_loc2_.getDenItem(_loc3_).clone());
                        _loc4_++;
                     }
                  }
                  else if(_loc2_.getDenItem(_loc3_).sortId != 4)
                  {
                     if(_itemRecycleId == 1 || _isInCurrEnviro)
                     {
                        _recycleInventory.setIitem(_loc4_,_loc2_.getDenItem(_loc3_).clone());
                        _loc4_++;
                     }
                     else if(_itemRecycleId == 4 && (_loc2_.getDenItem(_loc3_).enviroType == 0 || _loc2_.getDenItem(_loc3_).isLandAndOcean))
                     {
                        _recycleInventory.setIitem(_loc4_,_loc2_.getDenItem(_loc3_).clone());
                        _loc4_++;
                     }
                     else if(_loc2_.getDenItem(_loc3_).enviroType == 1 || _loc2_.getDenItem(_loc3_).isLandAndOcean)
                     {
                        _recycleInventory.setIitem(_loc4_,_loc2_.getDenItem(_loc3_).clone());
                        _loc4_++;
                     }
                  }
                  _loc3_++;
               }
               if(_itemRecycleId == 2)
               {
                  _scrollValue = _denAudioScrollValue;
               }
               else if(_itemRecycleId == 1)
               {
                  _scrollValue = _denScrollValue;
               }
               else if(_itemRecycleId == 4)
               {
                  _scrollValue = _denLandOnlyScrollValue;
               }
               else if(_itemRecycleId == 3)
               {
                  _scrollValue = _denOceanOnlyScrollValue;
               }
            }
         }
         createWindows();
      }
      
      private function createWindows() : void
      {
         if(_itemWindows)
         {
            _scrollValue = _itemWindows.scrollYValue;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         while(_recyclePopup.itemBlock.numChildren > 1)
         {
            _recyclePopup.itemBlock.removeChildAt(_recyclePopup.itemBlock.numChildren - 1);
         }
         _itemWindows = new WindowAndScrollbarGenerator();
         _itemWindows.init(_recyclePopup.itemBlock.width,_recyclePopup.itemBlock.height,4,_scrollValue,3,4,12,2,2,0,1,ItemWindowOriginal,_recycleInventory.getCoreArray(),"icon",0,{
            "mouseDown":onItemWindowDown,
            "mouseOver":onItemRollOver,
            "mouseOut":onItemRollOut
         },{"isRecycling":true},null,true,false,false);
         _recyclePopup.itemBlock.addChild(_itemWindows);
      }
      
      private function sendRecycleRequest(param1:Boolean) : void
      {
         var _loc6_:Array = null;
         var _loc11_:TradeItemCollection = null;
         var _loc2_:int = 0;
         var _loc7_:Iitem = null;
         var _loc3_:* = undefined;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:Boolean = false;
         var _loc9_:int = 0;
         var _loc12_:* = undefined;
         var _loc10_:int = 0;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(true);
            _invIdxIntCollection = new IntItemCollection();
            _loc6_ = _itemsToRecycle.getValues();
            _loc11_ = gMainFrame.userInfo.getMyTradeList();
            _loc2_ = -1;
            _loc3_ = new Vector.<MyShopItem>();
            _loc5_ = 0;
            while(true)
            {
               if(_loc5_ < _loc6_.length)
               {
                  if(_loc6_[_loc5_])
                  {
                     _loc7_ = _loc6_[_loc5_] as Iitem;
                     _loc2_ = _loc7_.invIdx;
                     _invIdxIntCollection.pushIntItem(_loc2_);
                     _loc8_ = 0;
                     while(_loc8_ < _loc11_.length)
                     {
                        if(_loc11_.getTradeItem(_loc8_).itemType == _itemRecycleId && _loc11_.getTradeItem(_loc8_).invIdx == _loc2_)
                        {
                           _savedTradeIndexes.push({
                              "tradeIndex":_loc8_,
                              "invIdx":_loc2_
                           });
                           break;
                        }
                        _loc8_++;
                     }
                     if(_loc7_.denStoreInvId > 0 || _loc7_.itemType == 0 && (_loc7_ as DenItem).specialType == 5)
                     {
                        _loc4_ = _loc7_.itemType == 0 && (_loc7_ as DenItem).specialType == 5;
                        _loc9_ = _loc4_ ? _loc2_ : _loc7_.denStoreInvId;
                        if(!ShopManager.myShopItems[_loc9_])
                        {
                           break;
                        }
                        _loc12_ = ShopManager.myShopItems[_loc9_].shopItems;
                        _loc10_ = 0;
                        while(_loc10_ < _loc12_.length)
                        {
                           if(_loc4_)
                           {
                              _loc3_.push(_loc12_[_loc10_]);
                           }
                           else if(_loc12_[_loc10_].currItem.itemType == _loc7_.itemType && _loc12_[_loc10_].currItem.invIdx == _loc7_.invIdx)
                           {
                              _loc3_.push(_loc12_[_loc10_]);
                              break;
                           }
                           _loc10_++;
                        }
                     }
                     if(_loc7_.isInDenShop)
                     {
                        _loc3_.push(new MyShopItem(_loc7_,0,0,_loc9_));
                     }
                  }
                  continue;
               }
               if(_loc3_.length > 0)
               {
                  ShopManager.findAndRemoveDenShopItems(_loc3_,performRecycleRequest,null);
               }
               else
               {
                  performRecycleRequest(true,null);
               }
               _loc5_++;
            }
            ShopToSellXtCommManager.requestStoreInfo(gMainFrame.userInfo.myUserName,_loc9_,onRecycleDenStoreInfoRequest,null);
            return;
         }
      }
      
      private function onRecycleDenStoreInfoRequest(param1:MyShopData, param2:Object) : void
      {
         if(param1 != null)
         {
            sendRecycleRequest(true);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(24788));
         }
      }
      
      private function performRecycleRequest(param1:Boolean, param2:Object) : void
      {
         if(param1)
         {
            if(_itemRecycleId == 0 || _itemRecycleId == 6 || _itemRecycleId == 5)
            {
               ItemXtCommManager.requestItemRecycle(_invIdxIntCollection,confirmRecycle,onRecycleListCallback);
            }
            else
            {
               DenXtCommManager.requestRecycle(true,_invIdxIntCollection,confirmRecycle,onRecycleListCallback);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(24788));
         }
      }
      
      private function confirmRecycle(param1:Vector.<int>) : void
      {
         var _loc2_:int = 0;
         if(param1.length > 0)
         {
            if(_savedTradeIndexes.length > 0)
            {
               _loc2_ = 0;
               while(_loc2_ < _savedTradeIndexes.length)
               {
                  if(param1.indexOf(_savedTradeIndexes[_loc2_].invIdx) > -1)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(_savedTradeIndexes[_loc2_].tradeIndex);
                     if(_itemRecycleId == 0 || _itemRecycleId == 6 || _itemRecycleId == 5)
                     {
                        TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                     }
                     else if(_itemRecycleId == 1 || _itemRecycleId == 2 || _itemRecycleId == 4 || _itemRecycleId == 3)
                     {
                        TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                     }
                  }
                  _loc2_++;
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
         if(_itemsToRecycle.getSize() != param1.length)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(24788));
         }
         _savedTradeIndexes = new Vector.<Object>();
      }
      
      private function onRecycleListCallback() : void
      {
         var _loc3_:int = 0;
         var _loc1_:IntItemCollection = null;
         var _loc4_:Array = null;
         var _loc5_:Iitem = null;
         var _loc2_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         _hasRecycled = true;
         if(_onRecycleSuccessCallback != null)
         {
            _onRecycleSuccessCallback();
         }
         if(_recycleOneItem)
         {
            applyAndClose(true);
         }
         else
         {
            _loc1_ = new IntItemCollection();
            _loc4_ = _itemsToRecycle.getKeys(true,16);
            _loc2_ = 0;
            while(_loc2_ < _loc4_.length)
            {
               _loc5_ = Iitem(_itemsToRecycle.getValue(_loc4_[_loc2_]));
               if(_loc5_.isCustom)
               {
                  _loc1_.pushIntItem(_loc5_.invIdx);
               }
               _itemWindows.deleteItem(_loc4_[_loc2_] - _loc3_,_recycleInventory.getCoreArray(),true,false);
               _loc3_++;
               _loc2_++;
            }
            if(_loc1_.length > 0)
            {
               PlayerWallManager.checkAndRemoveMasterpieceItems(_loc1_);
            }
            _itemsToRecycle = new SetDictionary();
            _recycleTotal = 0;
            _recyclePopup.currencyToolTip.text = Utility.convertNumberToString(_recycleTotal);
            _recyclePopup.recycleBtn.activateGrayState(true);
         }
      }
      
      public function setOnRecycleSuccessCallback(param1:Function) : void
      {
         _onRecycleSuccessCallback = param1;
      }
      
      private function applyAndClose(param1:Boolean = false) : void
      {
         ItemXtCommManager.recycleIlCallback = null;
         DenXtCommManager.recycleDiCallback = null;
         if(_closeCallback != null)
         {
            _closeCallback(param1);
         }
         else
         {
            destroy();
         }
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         applyAndClose(_hasRecycled);
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc2_:ItemWindowOriginal = null;
         var _loc3_:Iitem = null;
         param1.stopPropagation();
         if(param1.currentTarget.name == "previewBtn")
         {
            _loc2_ = param1.currentTarget.parent.parent as ItemWindowOriginal;
            _loc3_ = _loc2_.currItem as Iitem;
            if(_loc3_ is DenItem)
            {
               GuiManager.openMasterpiecePreview((_loc3_ as DenItem).uniqueImageId,(_loc3_ as DenItem).uniqueImageCreator,(_loc3_ as DenItem).uniqueImageCreatorDbId,(_loc3_ as DenItem).uniqueImageCreatorUUID,(_loc3_ as DenItem).version,gMainFrame.userInfo.myUserName,_loc3_ as DenItem);
            }
         }
         else if(param1.currentTarget.name == "certBtn")
         {
            _loc3_ = param1.currentTarget.parent.parent.currItem;
            if(_loc3_ is PetItem)
            {
               GuiManager.openPetCertificatePopup((_loc3_ as PetItem).largeIcon as GuiPet,null);
            }
         }
         else
         {
            _loc2_ = param1.currentTarget as ItemWindowOriginal;
            if((_loc2_.currItem as Iitem).isApproved)
            {
               if(_loc2_.cir.currentFrameLabel != "green" && _loc2_.cir.currentFrameLabel != "greenMouse")
               {
                  _loc2_.cir.gotoAndStop("greenMouse");
                  _recycleTotal += (_loc2_.currItem as Iitem).recycleValue as int;
                  _itemsToRecycle.insertKey(_loc2_.index,(_loc2_.currItem as Iitem).clone());
                  _recyclePopup.recycleBtn.activateGrayState(false);
               }
               else
               {
                  if(_loc2_.isInUse)
                  {
                     _loc2_.cir.gotoAndStop("down");
                  }
                  else
                  {
                     _loc2_.cir.gotoAndStop("up");
                  }
                  _recycleTotal -= (_loc2_.currItem as Iitem).recycleValue as int;
                  _itemsToRecycle.removeKey(_loc2_.index);
                  if(_recycleTotal <= 0)
                  {
                     _recyclePopup.recycleBtn.activateGrayState(true);
                  }
               }
               _recyclePopup.currencyToolTip.text = Utility.convertNumberToString(_recycleTotal);
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(25196));
            }
         }
      }
      
      private function onItemRollOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.cir.currentFrameLabel == "down")
         {
            param1.currentTarget.cir.gotoAndStop("downMouse");
         }
         else if(param1.currentTarget.cir.currentFrameLabel == "green")
         {
            param1.currentTarget.cir.gotoAndStop("greenMouse");
         }
         else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("over");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemRollOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("down");
         }
         else if(param1.currentTarget.cir.currentFrameLabel == "greenMouse")
         {
            param1.currentTarget.cir.gotoAndStop("green");
         }
         else if(param1.currentTarget.cir.currentFrameLabel != "down")
         {
            param1.currentTarget.cir.gotoAndStop("up");
         }
      }
      
      private function onRecycleBtn(param1:MouseEvent) : void
      {
         var _loc4_:IitemCollection = null;
         var _loc5_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(gMainFrame.clientInfo.extCallsActive)
            {
               return;
            }
            DarkenManager.unDarken(_recyclePopup);
            DarkenManager.darken(_confirmPopup,true);
            _confirmPopup.visible = true;
            confirmAddEventListeners();
            _loc4_ = new IitemCollection();
            _loc5_ = _itemsToRecycle.getValues();
            _loc2_ = int(_loc5_.length);
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc5_[_loc3_])
               {
                  _loc4_.pushIitem(_loc5_[_loc3_]);
               }
               _loc3_++;
            }
            _confirmWindows = new WindowAndScrollbarGenerator();
            _confirmWindows.init(_confirmPopup.itemBlock.width,_confirmPopup.itemBlock.height,3,0,2,2,0,2,2,0,1,ItemWindowOriginal,_loc4_.getCoreArray(),"icon",0,{
               "mouseDown":null,
               "mouseOver":onItemRollOver,
               "mouseOut":onItemRollOut
            },{"isRecycling":true},null,true,false,false);
            _confirmPopup.itemBlock.addChild(_confirmWindows);
            LocalizationManager.translateIdAndInsert(_confirmPopup.bodyTxtCont.bodyTxt,_loc4_.length == 1 ? 11371 : 24764,Utility.convertNumberToString(_recycleTotal));
            LocalizationManager.translateIdAndInsert(_confirmPopup.txtCounter_ba.counterTxt,_loc4_.length == 1 ? 23696 : 23695,_loc4_.length);
            _loc4_ = null;
         }
      }
      
      private function onConfirmOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onConfirmNoOrExit(param1);
         sendRecycleRequest(true);
      }
      
      private function onConfirmNoOrExit(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_confirmPopup);
         DarkenManager.darken(_recyclePopup);
         _confirmPopup.visible = false;
         while(_confirmPopup.itemBlock.numChildren > 2)
         {
            _confirmPopup.itemBlock.removeChildAt(_confirmPopup.itemBlock.numChildren - 1);
         }
         if(_confirmWindows)
         {
            _confirmWindows.destroy();
            _confirmWindows = null;
         }
         confirmRemoveEventListeners();
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(52);
      }
      
      private function onInfoBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14678),param1.currentTarget.x + _recyclePopup.x,param1.currentTarget.y + _recyclePopup.y + param1.currentTarget.height);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function addListeners() : void
      {
         _recyclePopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _recyclePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _recyclePopup.infoBtn.addEventListener("mouseDown",onInfoBtnDown,false,0,true);
         _recyclePopup.infoBtn.addEventListener("mouseOver",onInfoBtnOver,false,0,true);
         _recyclePopup.infoBtn.addEventListener("mouseOut",onInfoBtnOut,false,0,true);
         _recyclePopup.recycleBtn.addEventListener("mouseDown",onRecycleBtn,false,0,true);
      }
      
      private function confirmAddEventListeners() : void
      {
         if(_confirmPopup)
         {
            _confirmPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
            _confirmPopup.bx.addEventListener("mouseDown",onConfirmNoOrExit,false,0,true);
            _confirmPopup.okBtn.addEventListener("mouseDown",onConfirmOkBtn,false,0,true);
            _confirmPopup.noBtn.addEventListener("mouseDown",onConfirmNoOrExit,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         _recyclePopup.removeEventListener("mouseDown",onPopupDown);
         _recyclePopup.bx.removeEventListener("mouseDown",onClose);
         _recyclePopup.infoBtn.removeEventListener("mouseDown",onInfoBtnDown);
         _recyclePopup.infoBtn.removeEventListener("mouseOver",onInfoBtnOver);
         _recyclePopup.infoBtn.removeEventListener("mouseOut",onInfoBtnOut);
         _recyclePopup.recycleBtn.removeEventListener("mouseDown",onRecycleBtn);
      }
      
      private function confirmRemoveEventListeners() : void
      {
         if(_confirmPopup)
         {
            _confirmPopup.removeEventListener("mouseDown",onPopupDown);
            _confirmPopup.bx.removeEventListener("mouseDown",onConfirmNoOrExit);
            _confirmPopup.okBtn.removeEventListener("mouseDown",onConfirmOkBtn);
            _confirmPopup.noBtn.removeEventListener("mouseDown",onConfirmNoOrExit);
         }
      }
   }
}

