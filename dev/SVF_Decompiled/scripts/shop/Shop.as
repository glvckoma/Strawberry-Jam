package shop
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarView;
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyXtCommManager;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.CombinedCurrencyItem;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenRoomItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.system.ApplicationDomain;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   import gui.DarkenManager;
   import gui.DenPreviewManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import gui.GuiSoundButton;
   import gui.LoadingSpiral;
   import gui.RecycleItems;
   import gui.UpsellManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowBuddyList;
   import gui.itemWindows.ItemWindowSatchel;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TutorialPopups;
   
   public class Shop
   {
      protected const ITEMS_PER_SCREEN:int = 6;
      
      protected const GLOW_FILTER_COLOR:uint = 5586479;
      
      protected const GLOW_FILTER_ALPHA:Number = 1;
      
      protected var _closeCallback:Function;
      
      protected var _denRoomShopCallback:Function;
      
      protected var _onPurchaseSuccessCallback:Function;
      
      protected var _shopId:int;
      
      protected var _glDefType:int;
      
      protected var _playerAvatar:Avatar;
      
      protected var _shop:MovieClip;
      
      protected var _popupLayer:DisplayLayer;
      
      protected var _charmBuyPopup:MovieClip;
      
      protected var _charmBuddyListItemWindow:WindowAndScrollbarGenerator;
      
      protected var _unfilteredItemArray:IitemCollection;
      
      protected var _unfilteredColorsArray:Array;
      
      protected var _currShopItemArray:IitemCollection;
      
      protected var _shopItemArray:IitemCollection;
      
      protected var _shopItemArrayReversed:IitemCollection;
      
      protected var _shopItemArrayGemHigh:IitemCollection;
      
      protected var _shopItemArrayGemLow:IitemCollection;
      
      protected var _shopItemArrayNameHigh:IitemCollection;
      
      protected var _shopItemArrayNameLow:IitemCollection;
      
      protected var _itemColorsArray:Array;
      
      protected var _denItemColorsArray:Array;
      
      protected var _numItems:int;
      
      protected var _shopNameId:int;
      
      protected var _currentSelectedCharmUsername:String;
      
      protected var _currentSelectedCharmIndex:int;
      
      protected var _itemToBuy:Iitem;
      
      protected var _bItemsPurchased:Boolean;
      
      protected var _isMember:Boolean;
      
      protected var _itemIdx:int = -1;
      
      protected var _itemColorIdx:int;
      
      protected var _itemOffset:int;
      
      protected var _denItemIdx:int;
      
      protected var _useStartupShopIndex:int;
      
      protected var _spirals:Array;
      
      protected var _pageURI:String;
      
      protected var _lastPage:int;
      
      protected var _isDenAudioList:Boolean;
      
      protected var _isShopOnlyDen:Boolean;
      
      protected var _itemNotAvailPopup:SBOkPopup;
      
      protected var _infoTweenFinished:Boolean;
      
      protected var _isInfoOpen:Boolean;
      
      protected var _appendString:String;
      
      protected var _isInFFM:Boolean;
      
      protected var _isDenSaleShopOwner:Boolean;
      
      protected var _recyclePopup:RecycleItems;
      
      protected var _showTutorial:Boolean;
      
      protected var _mediaHelper:MediaHelper;
      
      protected var _currLoaderAppDomain:ApplicationDomain;
      
      protected var _satchelWindow:WindowAndScrollbarGenerator;
      
      protected var _denPreviewManager:DenPreviewManager;
      
      protected var _isCombinedCurrencyStore:Boolean;
      
      protected var _shopWithPreview:ShopWithPreview;
      
      protected var _shopToSell:ShopToSell;
      
      public function Shop()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:Avatar, param4:DisplayLayer, param5:Function = null, param6:int = 0, param7:Function = null, param8:Boolean = false, param9:int = -1) : void
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
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(3934,onShopLoaded);
      }
      
      public function get showTutorial() : Boolean
      {
         return _showTutorial;
      }
      
      public function set denItemIdx(param1:int) : void
      {
         _denItemIdx = param1;
      }
      
      public function showShop(param1:Boolean) : void
      {
         if(_shop.visible != param1)
         {
            _shop.visible = param1;
            if(param1)
            {
               DarkenManager.darken(_shop);
            }
            else
            {
               DarkenManager.unDarken(_shop);
            }
            if(param1)
            {
               setupBigBuyPopup();
            }
         }
         if(param1)
         {
            _denPreviewManager.destroy();
            _denPreviewManager = null;
         }
      }
      
      public function attemptToBuyCurrrentItem() : void
      {
         buyBtnDownHandler(null);
      }
      
      protected function onShopLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _currLoaderAppDomain = param1.loaderInfo.applicationDomain;
            _shop = param1.getChildAt(0) as MovieClip;
            KeepAlive.startKATimer(_shop);
            _showTutorial = matchesShopId(234);
            if(!_shopToSell && _showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,6))
            {
               TutorialPopups.openTutorialTextPopup(18659,10,115);
            }
            _spirals = [];
            _loc2_ = 0;
            while(_loc2_ < 6)
            {
               _shop["iw" + _loc2_].lock.visible = false;
               _shop["iw" + _loc2_].lockOpen.visible = false;
               _shop["iw" + _loc2_].blueBG.visible = false;
               _shop["iw" + _loc2_].addItemBtn.visible = false;
               if(_spirals[_loc2_])
               {
                  _spirals[_loc2_].destroy();
               }
               _loc2_++;
            }
            _shop.x = 900 * 0.5;
            _shop.y = 550 * 0.5;
            toggleInitialVisibility();
            _bItemsPurchased = false;
            requestShopList(gotItemListCallback,_shopId);
         }
      }
      
      protected function requestShopList(param1:Function, param2:int) : void
      {
         ItemXtCommManager.requestShopList(param1,param2);
      }
      
      protected function toggleInitialVisibility() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _loc1_ = _shop["iw" + _loc2_];
            _loc1_.tag.visible = !_loc1_.tag.visible;
            _loc1_.tagTall.visible = false;
            _loc1_.banner.visible = false;
            _loc1_.newTag.visible = false;
            _loc1_.saleTag.visible = false;
            _loc1_.clearanceTag.visible = false;
            _loc1_.daysLeftTag.visible = false;
            _loc1_.itemNameTxt.visible = !_loc1_.itemNameTxt.visible;
            _loc1_.itemNameTxtMultiline.visible = !_loc1_.itemNameTxtMultiline.visible;
            _loc1_.ocean.visible = false;
            if(_loc1_.consumerItemBtn)
            {
               _loc1_.consumerItemBtn.visible = false;
            }
            if(_loc1_.rareDiamondTag)
            {
               _loc1_.rareDiamondTag.visible = false;
            }
            if(_loc1_.customDiamond)
            {
               _loc1_.customDiamond.visible = false;
            }
            if(_loc1_.rareTag)
            {
               _loc1_.rareTag.visible = false;
            }
            if(_loc1_.diamond)
            {
               _loc1_.diamond.visible = false;
            }
            if(_loc1_.yellowBG)
            {
               _loc1_.yellowBG.visible = false;
            }
            if(_loc1_.editBtn)
            {
               _loc1_.editBtn.visible = false;
            }
            if(_loc1_.deleteItemBtn)
            {
               _loc1_.deleteItemBtn.visible = false;
            }
            _loc2_++;
         }
         _shop.buyPopup.paw.visible = false;
         _shop.buyPopup.newTag.visible = false;
         _shop.buyPopup.saleTag.visible = false;
         _shop.buyPopup.clearanceTag.visible = false;
         _shop.buyPopup.daysLeftTag.visible = false;
         _shop.buyPopup.tag.visible = false;
         _shop.buyPopup.tagTall.visible = false;
         _shop.buyPopup.ocean.visible = false;
         if(_shop.buyPopup.consumerItemBtn)
         {
            _shop.buyPopup.consumerItemBtn.visible = false;
         }
         if(_shop.buyPopup.rareDiamondTag)
         {
            _shop.buyPopup.rareDiamondTag.visible = false;
         }
         if(_shop.buyPopup.customDiamond)
         {
            _shop.buyPopup.customDiamond.visible = false;
         }
         if(_shop.buyPopup.rareTag)
         {
            _shop.buyPopup.rareTag.visible = false;
         }
         if(_shop.buyPopup.diamond)
         {
            _shop.buyPopup.diamond.visible = false;
         }
         if(_shop.buyBigPopup)
         {
            _shop.buyBigPopup.visible = false;
            _shop.buyBigPopup.newTag.visible = false;
            _shop.buyBigPopup.saleTag.visible = false;
            _shop.buyBigPopup.clearanceTag.visible = false;
            _shop.buyBigPopup.daysLeftTag.visible = false;
            _shop.buyBigPopup.ocean.visible = false;
            _shop.buyBigPopup.tag.visible = false;
            _shop.buyBigPopup.tagTall.visible = false;
            _shop.colorCycleBigBtn.visible = false;
            _shop.colorCycleBigFlash.visible = false;
         }
         _shop.sortBtn.visible = false;
         if(_shop.sortBtnDiamond)
         {
            _shop.sortBtnDiamond.visible = false;
         }
         _shop.sortingPopup.visible = false;
         if(_shop.sortingPopupDiamond)
         {
            _shop.sortingPopupDiamond.visible = false;
         }
         _shop.titleTxt.text = "";
         if(_shop.titleTxtDiamond)
         {
            _shop.titleTxtDiamond.text = "";
         }
         _shop.buyPopup.visible = false;
         if(_shop.oopsPopup)
         {
            _shop.oopsPopup.visible = false;
         }
         _shop.gemAnim.visible = false;
         if(_shop.charmTokenCont)
         {
            _shop.charmTokenCont.visible = matchesShopId(669);
         }
         _shop.setItemCostCont.visible = false;
      }
      
      protected function setupDiamondItems(param1:Boolean) : void
      {
         if(param1)
         {
            _appendString = "Diamond";
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.buyGreenBGDiamond.visible = true;
               _shop.buyBigPopup.buyGreenBG.visible = false;
               _shop.buyBigPopup.buyBlueBGDiamond.visible = true;
               _shop.buyBigPopup.buyBlueBG.visible = false;
               _shop.buyBigPopup.bgDiamond.visible = true;
               _shop.buyBigPopup.bg.visible = false;
            }
            _shop.buyPopup.buyGreenBGDiamond.visible = true;
            _shop.buyPopup.buyGreenBG.visible = false;
            _shop.buyPopup.buyBlueBGDiamond.visible = true;
            _shop.buyPopup.buyBlueBG.visible = false;
            _shop.buyPopup.bgDiamond.visible = true;
            _shop.buyPopup.bg.visible = false;
            if(_shop.buyPopup.questAbilities)
            {
               _shop.buyPopup.questAbilitiesDiamond.visible = false;
               _shop.buyPopup.questAbilities.visible = false;
            }
            _shop.titleTxtDiamond.visible = true;
            if(_shop.currentFrameLabel == "twoCurrency")
            {
               _shop.gemBanner.visible = true;
               _shop.myGemCountTxt.visible = true;
            }
            else
            {
               _shop.gemBanner.visible = false;
               _shop.myGemCountTxt.visible = false;
            }
            _shop.titleTxt = _shop.titleTxtDiamond;
            _shop.sparkleCont.visible = true;
            _shop.infoBtn.visible = true;
         }
         else
         {
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.buyGreenBGDiamond.visible = false;
               _shop.buyBigPopup.buyBlueBGDiamond.visible = false;
               _shop.buyBigPopup.bgDiamond.visible = false;
               _shop.buyBigPopup.sparkleCont.visible = false;
            }
            _shop.buyPopup.buyGreenBGDiamond.visible = false;
            _shop.buyPopup.buyBlueBGDiamond.visible = false;
            _shop.buyPopup.bgDiamond.visible = false;
            if(_shop.buyPopup.questAbilitiesDiamond)
            {
               _shop.buyPopup.questAbilitiesDiamond.visible = false;
            }
            if(_shop.titleBannerDiamond)
            {
               _shop.titleBannerDiamond.visible = false;
            }
            if(_shop.titleTxtDiamond)
            {
               _shop.titleTxtDiamond.visible = false;
            }
            if(_shop.oopsCostPopupDiamond)
            {
               _shop.oopsCostPopupDiamond.visible = false;
            }
            if(_shop.myGemCountTxtDiamond && _glDefType != 1060)
            {
               _shop.myGemCountTxtDiamond.visible = false;
               _shop.gemBannerDiamond.visible = false;
               _shop.myGemCountTxt.visible = true;
               if(_shop.infoBtn)
               {
                  _shop.infoBtn.visible = false;
               }
            }
            if(_shop.sparkleCont)
            {
               _shop.sparkleCont.visible = false;
            }
            _shop.buyPopup.sparkleCont.visible = false;
            if(_shop.sortBtnDiamond)
            {
               _shop["sortBtnDiamond"].visible = false;
               _shop["sortingPopupDiamond"].visible = false;
            }
            if(_shop.infoBtn)
            {
               _shop.infoBtn.visible = false;
            }
         }
         if(!_isCombinedCurrencyStore && (_shop["sortingPopup"] || _shop["sortingPopup" + _appendString]))
         {
            if(_shopWithPreview)
            {
               _shop["sortBtn"].visible = true;
               _shop["sortingPopup"].visible = false;
            }
            else
            {
               _shop["sortBtn" + _appendString].visible = true;
               _shop["sortingPopup" + _appendString].visible = false;
            }
         }
         if(_shop.oopsCostPopup)
         {
            _shop.oopsCostPopup.visible = false;
            _shop["oopsCostPopup" + _appendString].visible = false;
         }
         if(_shop.buyPopup["questAbilities" + _appendString])
         {
            _shop.buyPopup["questAbilities" + _appendString].visible = false;
         }
      }
      
      protected function setupCombinedCurrencyItems(param1:Boolean) : void
      {
         if(param1)
         {
            _shop.gotoAndStop("combinedCurrency");
            _shop.buyPopup.tag.visible = false;
            _shop.buyBigPopup.tag.visible = false;
            _shop.buyPopup.tagTall.visible = true;
            _shop.buyBigPopup.tagTall.visible = true;
            if(_shopNameId != 0)
            {
               LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
            }
            else
            {
               _shop.titleTxt.text = "";
            }
            _satchelWindow = new WindowAndScrollbarGenerator();
            _satchelWindow.init(_shop.satchelCont.itemWindow.width,_shop.satchelCont.itemWindow.height,0,0,1,7,0,0,3,0,1.5,ItemWindowSatchel,[4143,4138,4144,4142,4141,4140,4139],"",0,null,null,null,true,false,true,true);
            _shop.satchelCont.itemWindow.addChild(_satchelWindow);
         }
         else
         {
            if(_shopToSell && _isDenSaleShopOwner)
            {
               _shop.gotoAndStop("simple");
            }
            else if(_glDefType == 1060)
            {
               _shop.gotoAndStop("twoCurrency");
               _shop.gemAnim.visible = false;
               _shop.diamondAnim.visible = false;
            }
            else if(_shop.currentLabels.length > 0)
            {
               _shop.gotoAndStop("singleCurrency");
            }
            if(_shopNameId != 0)
            {
               LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
               if(_shop.titleTxtDiamond)
               {
                  LocalizationManager.translateId(_shop.titleTxtDiamond,_shopNameId);
               }
            }
            else
            {
               _shop.titleTxt.text = "";
               if(_shop.titleTxtDiamond)
               {
                  _shop.titleTxtDiamond.text = "";
               }
            }
            _shop.buyPopup.tagTall.visible = false;
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.tagTall.visible = false;
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         SBTracker.pop();
         KeepAlive.stopKATimer(_shop);
         if(_denPreviewManager)
         {
            _denPreviewManager.destroy();
            _denPreviewManager = null;
         }
         removeListeners();
         if(_shopItemArray && _shopItemArray.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _shopItemArray.length)
            {
               _shopItemArray.getIitem(_loc1_).destroy();
               if(_shopItemArrayReversed)
               {
                  _shopItemArrayReversed.getIitem(_loc1_).destroy();
                  _shopItemArrayGemHigh.getIitem(_loc1_).destroy();
                  _shopItemArrayGemLow.getIitem(_loc1_).destroy();
                  _shopItemArrayNameHigh.getIitem(_loc1_).destroy();
                  _shopItemArrayNameLow.getIitem(_loc1_).destroy();
               }
               _loc1_++;
            }
            _shopItemArray = null;
            _shopItemArrayReversed = null;
            _shopItemArrayGemHigh = null;
            _shopItemArrayGemLow = null;
            _shopItemArrayNameHigh = null;
            _shopItemArrayNameLow = null;
         }
         _shopItemArray = null;
         if(_spirals && _spirals.length > 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _spirals.length)
            {
               _spirals[_loc2_].destroy();
               _loc2_++;
            }
            _spirals = null;
         }
         TutorialPopups.closeTutorialTextPopup();
         _spirals = null;
         _closeCallback = null;
         if(_shop.buyPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyPopup);
         }
         if(_shop.buyBigPopup && _shop.buyBigPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
         }
         if(_charmBuyPopup)
         {
            DarkenManager.unDarken(_charmBuyPopup);
            if(_charmBuddyListItemWindow)
            {
               _charmBuddyListItemWindow.destroy();
               _charmBuddyListItemWindow = null;
            }
            _charmBuyPopup = null;
         }
         DarkenManager.unDarken(_shop);
         if(_shop.parent && _shop.parent == _popupLayer)
         {
            _popupLayer.removeChild(_shop);
         }
         _shop = null;
         _shopToSell = null;
         _shopWithPreview = null;
      }
      
      public function setOnPurchaseSuccessCallback(param1:Function) : void
      {
         _onPurchaseSuccessCallback = param1;
      }
      
      public function get isAudioShop() : Boolean
      {
         return _isDenAudioList;
      }
      
      public function applyAndClose() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback(_bItemsPurchased);
         }
         else
         {
            destroy();
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         if(param2 != "")
         {
            _shopNameId = int(param2);
            LocalizationManager.translateId(_shop.titleTxt,_shopNameId);
            if(_shop.titleTxtDiamond)
            {
               LocalizationManager.translateId(_shop.titleTxtDiamond,_shopNameId);
            }
         }
         _pageURI = "/game/play/popup/store/";
         switch(_glDefType)
         {
            case 1000:
               _pageURI += "accessory/#";
               break;
            case 1030:
               if(_isDenAudioList)
               {
                  _pageURI += "denAudio/#";
                  break;
               }
               _pageURI += "denItem/#";
               break;
            case 1040:
               _pageURI += "denRoom/#";
               break;
            case 1051:
               _pageURI += "currency/#";
               break;
            case 1054:
               _pageURI += "diamond/#";
         }
         _pageURI += param2 + "/page";
         _unfilteredItemArray = param1;
         _unfilteredColorsArray = param3;
         filterItemLists();
      }
      
      public function filterItemLists() : void
      {
         _shopItemArray = new IitemCollection(_unfilteredItemArray.concatCollection(null));
         if(_unfilteredColorsArray)
         {
            _itemColorsArray = _unfilteredColorsArray.concat();
         }
         else
         {
            _itemColorsArray = null;
         }
         if(_shop.titleTxt.text != "")
         {
            GenericListXtCommManager.filterIitems(_shopItemArray,true,_itemColorsArray);
         }
         _currShopItemArray = _shopItemArray;
         initialShopSetup();
      }
      
      public function getCurrentItemDefId() : int
      {
         var _loc1_:Object = null;
         var _loc2_:Object = _currShopItemArray.getIitem(_itemIdx);
         var _loc3_:int = int(_loc2_.defId);
         if(_loc2_.currencyType == 3)
         {
            _loc1_ = DiamondXtCommManager.getDiamondDef(_loc2_.diamondItem.defId);
            if(_loc1_)
            {
               _loc3_ = int(_loc1_.refDefId);
            }
         }
         return _loc3_;
      }
      
      public function get isCurrentItemDiamond() : Boolean
      {
         return _currShopItemArray.getIitem(_itemIdx).currencyType == 3;
      }
      
      protected function initialShopSetup() : void
      {
         if(_currShopItemArray)
         {
            _numItems = _shopItemArray.length;
         }
         else
         {
            _numItems = 0;
         }
         if(_numItems > 0)
         {
            if(_shopItemArray.getIitem(0) is DenItem && (_shopItemArray.getIitem(0) as DenItem).sortId == 4)
            {
               _isDenAudioList = true;
            }
            if(_shopItemArray.getIitem(0).currencyType == 1)
            {
               _shop.currency.gotoAndStop("tickets");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 0 || _glDefType == 1060)
            {
               _shop.currency.gotoAndStop("gems");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 2)
            {
               _shop.currency.gotoAndStop("earth");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 3)
            {
               _shop.currency.gotoAndStop("diamonds");
               _shop.frame.gotoAndStop("diamond");
            }
            else if(_shopItemArray.getIitem(0).currencyType == 11)
            {
               _shop.currency.gotoAndStop("eco");
            }
         }
         _isCombinedCurrencyStore = _shopItemArray.length > 0 ? _shopItemArray.getIitem(0).currencyType == 100 : false;
         setupCombinedCurrencyItems(_isCombinedCurrencyStore);
         setupDiamondItems(_shopItemArray.length > 0 ? _shopItemArray.getIitem(0).currencyType == 3 && _glDefType != 1060 : false);
         setupCurrencyAmounts();
         shopSetupCommon();
      }
      
      protected function setupCurrencyAmounts() : void
      {
         if(!_isCombinedCurrencyStore)
         {
            if(_shop.sortBtn || _shop["sortBtn" + _appendString])
            {
               if(_shopWithPreview)
               {
                  _shop["sortBtn"].gotoAndStop("timeBtnDn");
               }
               else
               {
                  _shop["sortBtn" + _appendString].gotoAndStop("timeBtnDn");
               }
               _shopItemArrayReversed = new IitemCollection(_shopItemArray.getCoreArray().concat().reverse());
               if(!_shopToSell)
               {
                  if(_shop.currentFrameLabel == "twoCurrency")
                  {
                     _shopItemArrayGemLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sort(function(param1:Iitem, param2:Iitem):int
                     {
                        if(param1.isDiamond && param2.isDiamond || !param1.isDiamond && !param2.isDiamond)
                        {
                           if(param1.value < param2.value)
                           {
                              return -1;
                           }
                           if(param1.value > param2.value)
                           {
                              return 1;
                           }
                           return 0;
                        }
                        if(param1.isDiamond)
                        {
                           return 1;
                        }
                        if(param2.isDiamond)
                        {
                           return -1;
                        }
                        return 0;
                     }));
                  }
                  else
                  {
                     _shopItemArrayGemLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sortOn("value",16));
                  }
                  _shopItemArrayGemHigh = new IitemCollection(_shopItemArrayGemLow.getCoreArray().concat().reverse());
               }
               _shopItemArrayNameLow = new IitemCollection(_shopItemArray.getCoreArray().concat().sortOn("name",2));
               _shopItemArrayNameHigh = new IitemCollection(_shopItemArrayNameLow.getCoreArray().concat().reverse());
            }
         }
         if(_numItems > 0 || _shop.currentFrameLabel == "twoCurrency")
         {
            if(_shop.currentFrameLabel == "singleCurrency" || _shop.currentLabels.length == 0)
            {
               _shop["myGemCountTxt" + _appendString].text = Utility.convertNumberToString(UserCurrency.getCurrency(_shopItemArray.getIitem(0).currencyType));
            }
            else if(_shop.currentFrameLabel == "twoCurrency")
            {
               _shop.currencyDiamond.gotoAndStop("diamonds");
               _shop.myGemCountTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
               _shop.myGemCountTxtDiamond.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
               _shop.myGemCountTxtDiamond.visible = true;
            }
         }
      }
      
      protected function shopSetupCommon() : void
      {
         DarkenManager.showLoadingSpiral(false);
         _shop.visible = true;
         _popupLayer.addChild(_shop);
         DarkenManager.darken(_shop);
         addListeners();
         setupShopWindows();
         if(_useStartupShopIndex != -1)
         {
            onItemWindowDown(null);
         }
      }
      
      protected function setupShopWindows() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Iitem = null;
         var _loc1_:MovieClip = null;
         var _loc5_:* = null;
         var _loc6_:Matrix = null;
         _numItems = _shopItemArray.length;
         if(_numItems > 0 && _shopToSell && !_isDenSaleShopOwner && _itemOffset == _numItems)
         {
            _itemOffset = Math.max(0,_itemOffset - 6);
         }
         var _loc4_:int = int(_itemOffset / 6) + 1;
         if(_lastPage != _loc4_)
         {
            SBTracker.trackPageview(_pageURI + _loc4_);
            _lastPage = _loc4_;
         }
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _loc3_ = _currShopItemArray.length > _loc2_ + _itemOffset ? _currShopItemArray.getIitem(_loc2_ + _itemOffset) : null;
            _loc1_ = _shop["iw" + _loc2_];
            while(_loc1_.itemLayer.numChildren > 1)
            {
               _loc1_.itemLayer.removeChildAt(1);
            }
            _loc1_.removeEventListener("mouseDown",onItemWindowDown);
            _loc1_.removeEventListener("rollOver",onItemWindowRollOver);
            _loc1_.removeEventListener("rollOut",onItemWindowRollOut);
            if(_shopToSell && _isDenSaleShopOwner)
            {
               _loc1_.editBtn.removeEventListener("mouseDown",_shopToSell.onEditBtn);
               _loc1_.deleteItemBtn.removeEventListener("mouseDown",_shopToSell.onDeleteBtn);
            }
            if(_loc3_)
            {
               _loc5_ = _loc3_;
               if(_shopWithPreview && _loc5_ is Item)
               {
                  (_loc5_ as Item).specialScale = 0.4;
               }
               if(_shopToSell)
               {
                  _loc5_.asShopItemSized = true;
                  if(_loc5_ is Item)
                  {
                     (_loc5_ as Item).specialScale = 1;
                  }
               }
               if(_loc5_.icon)
               {
                  if(!(_loc5_ is DenItem) && !(_loc5_ is AvatarItem) && !(_loc5_ is PetItem))
                  {
                     _loc5_.icon.filters = [new GlowFilter(5586479,1,2,2,4)];
                  }
                  if(_loc5_ is AvatarItem)
                  {
                     _loc6_ = _loc5_.icon.transform.matrix;
                     if(_loc6_.a != -1)
                     {
                        _loc6_.scale(-1,1);
                        _loc5_.icon.transform.matrix = _loc6_;
                     }
                  }
                  _loc1_.itemLayer.addChild(_loc5_.icon);
               }
               else
               {
                  _loc1_.itemLayer.addChild(_loc5_);
               }
               _spirals[_loc2_] = new LoadingSpiral(_loc1_.itemLayer);
               if(!_loc5_.isIconLoaded)
               {
                  _loc5_.imageLoadedCallback = _spirals[_loc2_].destroy;
               }
               else
               {
                  _spirals[_loc2_].destroy();
               }
               if(_shopToSell)
               {
                  _shopToSell.setupShopItemPrizeTags(_loc1_,_loc2_ + _itemOffset);
               }
               else
               {
                  setupPriceTags(_loc1_,_loc5_);
               }
               LocalizationManager.updateToFit(_loc1_.itemNameTxt,_loc5_.name);
               if(_loc5_.isMemberOnly)
               {
                  _loc1_.banner.visible = true;
                  LocalizationManager.translateId(_loc1_.banner.txtCont.txt,11376);
                  if(_isMember)
                  {
                     _loc1_.lockOpen.visible = true;
                  }
                  else
                  {
                     _loc1_.lock.visible = true;
                  }
               }
               else
               {
                  _loc1_.banner.visible = false;
                  _loc1_.lock.visible = false;
                  _loc1_.lockOpen.visible = false;
               }
               if(_loc5_.isOcean)
               {
                  _loc1_.blueBG.visible = true;
                  _loc1_.greenBG.visible = false;
                  _loc1_.ocean.visible = true;
               }
               else
               {
                  _loc1_.greenBG.visible = true;
                  _loc1_.ocean.visible = false;
               }
               if(_loc1_.rareDiamondTag)
               {
                  _loc1_.rareDiamondTag.visible = false;
               }
               if(_loc1_.diamond)
               {
                  _loc1_.diamond.visible = false;
               }
               _loc1_.rareTag.visible = false;
               if(_loc1_.customDiamond)
               {
                  _loc1_.customDiamond.visible = false;
               }
               if(_shopToSell)
               {
                  if(_loc5_.isRareDiamond)
                  {
                     _loc1_.rareDiamondTag.visible = true;
                  }
                  else if(_loc5_.isCustom)
                  {
                     _loc1_.customDiamond.visible = true;
                  }
                  else
                  {
                     if(_loc5_.isRare)
                     {
                        _loc1_.rareTag.visible = true;
                     }
                     _loc1_.diamond.visible = _loc5_.isDiamond;
                  }
               }
               else if(_loc5_.isRare)
               {
                  _loc1_.rareTag.visible = true;
               }
               _loc1_.avtSpecific.visible = false;
               _loc1_.addItemBtn.visible = false;
               if(!_shopToSell)
               {
                  _loc1_.newTag.visible = _loc5_.isNew;
                  _loc1_.clearanceTag.visible = _loc5_.isOnClearance;
                  _loc1_.saleTag.visible = _loc5_.isOnSale;
               }
               else
               {
                  _loc1_.newTag.visible = false;
                  _loc1_.clearanceTag.visible = false;
                  _loc1_.saleTag.visible = false;
               }
               setupNumDaysLeft(_loc1_,_loc5_);
               if(_shopWithPreview)
               {
                  _shopWithPreview.checkIfThisItemEquipped(_loc2_,_itemOffset);
               }
               _loc1_.addEventListener("mouseDown",onItemWindowDown,false,0,true);
               _loc1_.addEventListener("rollOver",onItemWindowRollOver,false,0,true);
               _loc1_.addEventListener("rollOut",onItemWindowRollOut,false,0,true);
               if(_shopToSell && _isDenSaleShopOwner)
               {
                  _loc1_.editBtn.addEventListener("mouseDown",_shopToSell.onEditBtn,false,0,true);
                  _loc1_.deleteItemBtn.addEventListener("mouseDown",_shopToSell.onDeleteBtn,false,0,true);
               }
               if(_loc5_ is DenItem)
               {
                  if((_loc5_ as DenItem).specialType == 7 || (_loc5_ as DenItem).specialType == 6)
                  {
                     _loc1_.consumerItemBtn.visible = true;
                     _loc1_.consumerItemBtn.activateGrayState((_loc5_ as DenItem).specialType == 6);
                  }
               }
            }
            else
            {
               _loc1_.tag.visible = false;
               _loc1_.tagTall.visible = false;
               _loc1_.tag.txt.text = "";
               _loc1_.itemNameTxt.text = "";
               _loc1_.itemNameTxtMultiline.text = "";
               _loc1_.banner.visible = false;
               _loc1_.lock.visible = false;
               _loc1_.lockOpen.visible = false;
               _loc1_.blueBG.visible = _shop.frame.currentFrameLabel == "diamond";
               _loc1_.newTag.visible = false;
               _loc1_.clearanceTag.visible = false;
               _loc1_.saleTag.visible = false;
               _loc1_.ocean.visible = false;
               _loc1_.greenBG.visible = false;
               _loc1_.rareTag.visible = false;
               _loc1_.avtSpecific.visible = false;
               _loc1_.daysLeftTag.visible = false;
               if(_loc1_.consumerItemBtn)
               {
                  _loc1_.consumerItemBtn.visible = false;
               }
               if(_loc1_.rareDiamondTag)
               {
                  _loc1_.rareDiamondTag.visible = false;
               }
               if(_loc1_.diamond)
               {
                  _loc1_.diamond.visible = false;
               }
               if(_loc1_.diamond)
               {
                  _loc1_.customDiamond.visible = false;
               }
               if(_loc1_.yellowBG)
               {
                  _loc1_.yellowBG.visible = false;
               }
               if(_shopToSell && _isDenSaleShopOwner && _loc2_ + _itemOffset < 24)
               {
                  _loc1_.addEventListener("mouseDown",onItemWindowDown,false,0,true);
                  _loc1_.addEventListener("rollOver",onItemWindowRollOver,false,0,true);
                  _loc1_.addEventListener("rollOut",onItemWindowRollOut,false,0,true);
                  _loc1_.addItemBtn.visible = true;
               }
            }
            _loc1_.itemNameTxt.visible = false;
            _loc1_.itemNameTxtMultiline.visible = false;
            _loc2_++;
         }
         if(_numItems <= 6 && (_shopToSell == null || _isDenSaleShopOwner && _numItems < 6))
         {
            _shop.nextBtn.activateGrayState(true);
            _shop.prevBtn.activateGrayState(true);
         }
         else
         {
            _shop.nextBtn.activateGrayState(false);
            _shop.prevBtn.activateGrayState(false);
         }
      }
      
      private function setupCombinedTag(param1:MovieClip, param2:Object, param3:MovieClip) : void
      {
         var _loc5_:* = undefined;
         var _loc8_:int = 0;
         var _loc6_:MovieClip = null;
         var _loc10_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc9_:int = 0;
         while(param1.tagTall.tag_mid.numChildren > 1)
         {
            param1.tagTall.tag_mid.removeChildAt(param1.tagTall.tag_mid.numChildren - 1);
         }
         var _loc7_:CombinedCurrencyItem = param2.combinedCurrencyItem;
         if(_loc7_)
         {
            _loc5_ = _loc7_.countData;
            _loc9_ = 0;
            while(_loc9_ < _loc5_.length)
            {
               if(_loc5_[_loc9_] != null)
               {
                  _loc6_ = new (_currLoaderAppDomain.getDefinition("mid_tallTag") as Class)();
                  _loc6_.iconCont.gotoAndStop(_loc5_[_loc9_].name);
                  _loc6_.gemCountTxt.text = Utility.convertNumberToString(_loc5_[_loc9_].count);
                  if(UserCurrency.hasEnoughCurrency(param2.currencyType,param2.value,_loc9_))
                  {
                     param1.tagTall.gotoAndStop("green");
                     param1.tagTall.tag_mid.tagWindow.height = _loc6_.height * (_loc8_ + 1);
                     _loc6_.gotoAndStop("green");
                     _loc4_ = true;
                  }
                  else
                  {
                     if(!_loc4_)
                     {
                        param1.tagTall.gotoAndStop("red");
                     }
                     param1.tagTall.tag_mid.tagWindow.height = _loc6_.height * (_loc8_ + 1);
                     _loc6_.gotoAndStop("red");
                     _loc10_ = true;
                  }
                  _loc6_.y = _loc6_.height * _loc8_;
                  param1.tagTall.tag_mid.addChild(_loc6_);
                  _loc8_++;
               }
               _loc9_++;
            }
            param1.tagTall.tag_btm.y = param1.tagTall.tag_mid.y + param1.tagTall.tag_mid.height;
            if(param3 != null)
            {
               param3.visible = !_loc10_;
            }
         }
      }
      
      private function setupNumDaysLeft(param1:MovieClip, param2:Object) : void
      {
         var _loc4_:int = 0;
         var _loc3_:MovieClip = param1.daysLeftTag;
         if(!param2.isRare && !_shopToSell)
         {
            _loc4_ = Math.ceil((param2.endTime - Utility.getCurrEpochTime()) / 60 / 60 / 24);
            if(_loc4_ > 0 && _loc4_ <= 10)
            {
               if(_loc4_ == 1)
               {
                  LocalizationManager.translateId(_loc3_.txt,18061);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(_loc3_.txt,6260,_loc4_);
               }
               _loc3_.visible = true;
               param1.clearanceTag.visible = false;
               param1.rareTag.visible = false;
               param1.saleTag.visible = false;
               param1.newTag.visible = false;
            }
            else
            {
               _loc3_.visible = false;
            }
         }
         else
         {
            _loc3_.visible = false;
         }
      }
      
      protected function setupPriceTags(param1:MovieClip, param2:Object, param3:MovieClip = null) : void
      {
         var _loc4_:String = null;
         if(matchesShopId(669))
         {
            param1.tag.visible = false;
         }
         else
         {
            _loc4_ = "";
            if(param2.currencyType == 1)
            {
               _loc4_ = "ticket";
            }
            else if(param2.currencyType == 2)
            {
               _loc4_ = "earth";
            }
            else if(param2.currencyType == 3)
            {
               _loc4_ = "diamond";
            }
            else if(param2.currencyType == 11)
            {
               _loc4_ = "eco";
            }
            if(param2.currencyType == 100)
            {
               setupCombinedTag(param1,param2,param3);
               param1.tagTall.visible = true;
            }
            else
            {
               if(UserCurrency.hasEnoughCurrency(param2.currencyType,param2.value))
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
               param1.tag.txt.text = Utility.convertNumberToString(param2.value);
               param1.tag.visible = true;
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_shop.buyPopup.visible)
         {
            if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
            {
               RoomManagerWorld.instance.playPreviousMusic();
            }
            DarkenManager.unDarken(_shop.buyPopup);
         }
         if(_shop.buyBigPopup && _shop.buyBigPopup.visible)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
         }
         applyAndClose();
         QuestManager.onShopClose();
         TutorialPopups.closeTutorialTextPopup();
      }
      
      protected function buyBtnDownHandler(param1:MouseEvent = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:MyShopItem = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_itemToBuy)
         {
            _loc4_ = _itemToBuy.isMemberOnly ? _isMember : true;
            _loc2_ = _itemToBuy.currencyType;
            _loc3_ = _itemToBuy.value;
            if(_shopToSell)
            {
               _loc5_ = _shopToSell.currShopItem;
               _loc2_ = _loc5_.currencyType;
               _loc3_ = _loc5_.cost;
            }
            if(_loc2_ == 3 && _loc4_)
            {
               GuiManager.showDiamondConfirmation(_loc3_,attemptToPurchaseItem);
            }
            else
            {
               attemptToPurchaseItem();
            }
         }
      }
      
      protected function attemptToPurchaseItem() : void
      {
         var _loc13_:MyShopItem = null;
         var _loc7_:CombinedCurrencyItem = null;
         var _loc6_:* = undefined;
         var _loc9_:String = null;
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:Boolean = false;
         var _loc12_:Object = null;
         var _loc11_:Iitem = _currShopItemArray.getIitem(_itemIdx).clone();
         var _loc1_:int = _loc11_.currencyType;
         var _loc3_:* = _loc11_.value;
         if(_shopToSell)
         {
            if(!_isMember)
            {
               UpsellManager.displayPopup("accessories","buyAccessory/" + _loc11_.name);
               return;
            }
            _loc13_ = _shopToSell.currShopItem;
            _loc1_ = _loc13_.currencyType;
            _loc3_ = _loc13_.cost;
         }
         if(!_isMember)
         {
            if(_loc11_.isMemberOnly)
            {
               if(_loc11_ is Item)
               {
                  UpsellManager.displayPopup("accessories","buyAccessory/" + _loc11_.name);
                  return;
               }
               if(_loc11_ is DenItem)
               {
                  if(_isDenAudioList)
                  {
                     UpsellManager.displayPopup("denAudio","buyDenAudio/" + _loc11_.name);
                  }
                  else
                  {
                     UpsellManager.displayPopup("denItems","buyDenItem/" + _loc11_.name);
                  }
                  return;
               }
               if(_loc11_ is DenRoomItem)
               {
                  UpsellManager.displayPopup("dens","buyDenRoom/" + _loc11_.name);
                  return;
               }
               trace("ERROR: _shopId=" + _shopId + " is not expected.");
            }
         }
         if(!UserCurrency.hasEnoughCurrency(_loc1_,_loc3_))
         {
            if(_loc1_ == 3)
            {
               UpsellManager.displayPopup("","extraDiamonds");
            }
            else
            {
               DarkenManager.darken(_shop["oopsCostPopup" + _appendString]);
               if(_loc1_ == 100)
               {
                  _loc7_ = _loc3_;
                  _shop["oopsCostPopup" + _appendString].gotoAndStop(_loc7_.numCurrenciesInUse);
                  _loc6_ = _loc7_.countData;
                  _loc9_ = "";
                  _loc8_ = 0;
                  while(_loc8_ < _loc6_.length)
                  {
                     _loc4_ = _loc6_[_loc8_];
                     if(_loc4_ != null)
                     {
                        _loc5_ = UserCurrency.getCurrency(_loc4_.type);
                        _shop["oopsCostPopup" + _appendString]["currencyType" + _loc9_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["currencyCost" + _loc9_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["currencyNeed" + _loc9_].gotoAndStop(_loc4_.name);
                        _shop["oopsCostPopup" + _appendString]["gemsTxt" + _loc9_].text = Utility.convertNumberToString(_loc5_);
                        _shop["oopsCostPopup" + _appendString]["costTxt" + _loc9_].text = Utility.convertNumberToString(_loc4_.count);
                        _shop["oopsCostPopup" + _appendString]["needTxt" + _loc9_].text = Utility.convertNumberToString(Math.max(0,_loc4_.count - _loc5_));
                        _shop["oopsCostPopup" + _appendString]["needCircle" + _loc9_].visible = _loc4_.count - _loc5_ > 0;
                        if(_loc9_ == "")
                        {
                           _loc9_ = "Two";
                        }
                        else if(_loc9_ == "Two")
                        {
                           _loc9_ = "Three";
                        }
                     }
                     _loc8_++;
                  }
                  _shop["oopsCostPopup" + _appendString].visible = true;
                  _shop["oopsCostPopup" + _appendString].earnGemsBtn.visible = false;
               }
               else
               {
                  _shop["oopsCostPopup" + _appendString].currencyCost.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc1_]);
                  _shop["oopsCostPopup" + _appendString].currencyNeed.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc1_]);
                  _shop["oopsCostPopup" + _appendString].currencyType.gotoAndStop(SbiConstants.CURRENCY_NAMES[_loc1_]);
                  _shop["oopsCostPopup" + _appendString].gemsTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(_loc1_));
                  _shop["oopsCostPopup" + _appendString].costTxt.text = Utility.convertNumberToString(_loc3_);
                  _shop["oopsCostPopup" + _appendString].needTxt.text = Utility.convertNumberToString(_loc3_ - int(_shop["oopsCostPopup" + _appendString].gemsTxt.text));
                  _shop["oopsCostPopup" + _appendString].visible = true;
                  if(_loc1_ == 0)
                  {
                     if(_appendString == "")
                     {
                        _shop.oopsCostPopup.earnGemsBtn.addEventListener("mouseDown",onEarnGemsBtn,false,0,true);
                     }
                  }
                  else
                  {
                     _shop.oopsCostPopup.earnGemsBtn.visible = false;
                  }
               }
            }
         }
         else if(_loc11_ is Item)
         {
            if(_playerAvatar.inventoryClothing.numItems < ShopManager.maxItems)
            {
               if(_loc11_.defId > 0)
               {
                  sendBuyRequest(_loc11_);
               }
            }
            else
            {
               if(AvatarManager.roomEnviroType == 0)
               {
                  _loc10_ = 6;
               }
               else
               {
                  _loc10_ = 5;
               }
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc10_);
            }
         }
         else if(_loc11_ is DenItem)
         {
            if((_loc11_ as DenItem).sortId == 4)
            {
               _loc12_ = Utility.validateDenInventorySpace(ShopManager.maxAudioItems,_playerAvatar.inventoryDenFull.denItemCollection,_loc11_.enviroType,true);
               if(_loc12_.allow)
               {
                  sendBuyRequest(_loc11_);
               }
               else
               {
                  _loc10_ = 2;
                  _loc2_ = true;
               }
            }
            else
            {
               _loc12_ = Utility.validateDenInventorySpace(ShopManager.maxDenItems,_playerAvatar.inventoryDenFull.denItemCollection,_loc11_.enviroType);
               if(_loc12_.allow)
               {
                  sendBuyRequest(_loc11_);
               }
               else
               {
                  if(_loc12_.enviroTypeOverflow == 0)
                  {
                     _loc10_ = 4;
                  }
                  else
                  {
                     _loc10_ = 3;
                  }
                  _loc2_ = true;
               }
            }
            if(_loc2_)
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc10_);
            }
         }
         else if(_loc11_ is DenRoomItem)
         {
            if(_denItemIdx < 1)
            {
               _denItemIdx = DenSwitch.nextFreeSlotIdx;
            }
            if(!DenSwitch.denList.getDenRoomItem(_denItemIdx) && _denItemIdx < 200 && _denItemIdx > 0)
            {
               sendBuyRequest(_loc11_);
            }
            else
            {
               _loc10_ = 99;
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc10_);
            }
         }
         else if(_glDefType == 1051)
         {
            sendBuyRequest(_loc11_);
         }
         else if(_loc11_ is PetItem && _shopToSell)
         {
            sendBuyRequest(_loc11_);
         }
      }
      
      protected function sendBuyRequest(param1:Iitem) : void
      {
         var _loc3_:int = 0;
         DarkenManager.showLoadingSpiral(true);
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,7))
         {
            AchievementXtCommManager.requestSetUserVar(379,7);
            _shop.buyBtnGreen.setButtonState(0);
         }
         var _loc2_:* = param1.currencyType == 3;
         if(param1 is Item)
         {
            ItemXtCommManager.requestItemBuy(confirmPurchase,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,_itemColorIdx,_loc2_ ? 1 : 0,-1,"");
            ItemXtCommManager.setItemBuyIlCallback(putOnPurchasedItem);
         }
         else if(param1 is DenItem)
         {
            _loc3_ = (_itemToBuy as DenItem).version;
            if(_loc3_ >= (_itemToBuy as DenItem).getVersions().length)
            {
               _loc3_ = 0;
            }
            DenXtCommManager.requestBuy(true,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,confirmPurchase,onDenItemPurchaseInventoryResponse,0,null,_loc3_,_loc2_ ? 1 : 0);
         }
         else if(param1 is DenRoomItem)
         {
            DenXtCommManager.requestBuy(false,_shopId,_loc2_ ? param1.diamondItem.defId : param1.defId,confirmPurchase,null,_denItemIdx,_denRoomShopCallback != null ? _denRoomShopCallback : onDenPurchase,0,_loc2_ ? 1 : 0);
         }
         else if(_glDefType == 1051)
         {
            ItemXtCommManager.requestCurrencyExchange(_shopId,param1.defId,confirmPurchase);
         }
      }
      
      private function pageCatalogHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == _shop.nextBtn.name && (_shopToSell && _isDenSaleShopOwner ? _numItems >= 6 : _numItems > 6))
            {
               if(_shopToSell && _isDenSaleShopOwner)
               {
                  if(_itemOffset + 6 >= 24)
                  {
                     _itemOffset = 0;
                  }
                  else if(_itemOffset + 6 <= _numItems)
                  {
                     _itemOffset += 6;
                  }
               }
               else if(_itemOffset + 6 < _numItems)
               {
                  _itemOffset += 6;
               }
               else
               {
                  _itemOffset = 0;
               }
            }
            else if(param1.currentTarget.name == _shop.prevBtn.name && (_shopToSell && _isDenSaleShopOwner ? _numItems >= 6 : _numItems > 6))
            {
               if(_itemOffset == 0)
               {
                  _loc2_ = _numItems % 6;
                  if(_loc2_ != 0)
                  {
                     _itemOffset = _numItems - _loc2_;
                  }
                  else
                  {
                     _itemOffset = _numItems - 6;
                  }
               }
               else
               {
                  _itemOffset -= 6;
               }
            }
            setupShopWindows();
         }
      }
      
      private function okBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function confirmFullInventoryHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onClose(null);
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = int(param1.passback);
         if(param1.status)
         {
            if(_loc2_ == 99)
            {
               if(_denPreviewManager)
               {
                  _denPreviewManager.showBuyAndBackBtns(false);
               }
               GuiManager.showDenSwitcher(true);
               if(GuiManager.currDenSwitcher)
               {
                  GuiManager.currDenSwitcher.rebuildWindows(true,onDenRoomRecycleClose);
               }
               else
               {
                  GuiManager.openDenRoomSwitcher(true,onDenRoomRecycleClose);
               }
            }
            else
            {
               _recyclePopup = new RecycleItems();
               _recyclePopup.init(_loc2_,_popupLayer,true,onRecycleClose,900 * 0.5,550 * 0.5,true);
            }
         }
         else if(_loc2_ != 99)
         {
            onClose(null);
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.destroy();
            _recyclePopup = null;
         }
      }
      
      private function onDenRoomRecycleClose(param1:Boolean = false) : void
      {
         GuiManager.showDenSwitcher(false,!!_shop ? _popupLayer.getChildIndex(_shop) - 1 : -1);
         if(_denPreviewManager)
         {
            _denPreviewManager.showBuyAndBackBtns(true);
            if(param1)
            {
               _denPreviewManager.exitPreview();
            }
         }
      }
      
      private function onItemNoLongerAvailable(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_itemNotAvailPopup)
         {
            _itemNotAvailPopup.destroy();
            _itemNotAvailPopup = null;
         }
         if(matchesShopId(13))
         {
            onBuyBigPopupCloseBtnDown(null);
         }
         else
         {
            onBuyPopupCloseBtnDown(null);
         }
         filterItemLists();
      }
      
      public function onDenPurchase() : void
      {
         if(_denPreviewManager)
         {
            _denPreviewManager.handleDenPurchase();
         }
      }
      
      protected function confirmPurchase(param1:int, param2:Object, param3:int, param4:int = 0) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(param1 == 1)
         {
            _bItemsPurchased = true;
            playCurrencyAnimation();
            if(matchesShopId(13))
            {
               onBuyBigPopupCloseBtnDown(null);
               if(!_isShopOnlyDen)
               {
                  return;
               }
            }
            else
            {
               onBuyPopupCloseBtnDown(null);
               onBuyBigPopupCloseBtnDown(null);
            }
            _loc5_ = !!_shopToSell ? param4 : _itemToBuy.currencyType;
            UserCurrency.setCurrency(param2,_loc5_);
            if(_loc5_ == 100)
            {
               _satchelWindow.callUpdateInWindow();
            }
            else if(_shop.myGemCountTxtDiamond && _loc5_ == 3)
            {
               _shop.myGemCountTxtDiamond.text = Utility.convertNumberToString(UserCurrency.getCurrency(_loc5_));
            }
            else if(_shop.myGemCountTxt)
            {
               _shop.myGemCountTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(_loc5_));
            }
            if(_itemToBuy is Item && _playerAvatar.inventoryClothing.numItems >= ShopManager.warningItemCount)
            {
               new SBOkPopup(_popupLayer,getWarningText(_playerAvatar.inventoryClothing.numItems,ShopManager.maxItems));
            }
            else
            {
               if(_itemToBuy is DenItem)
               {
                  if(_shopToSell)
                  {
                     onDenItemPurchaseInventoryResponse();
                     DenXtCommManager.denEditorDIResponseCallback = null;
                  }
                  return;
               }
               if(_itemToBuy is DenRoomItem)
               {
                  _loc6_ = DenSwitch.numDens;
                  if(_loc6_ + 1 >= ShopManager.warningDenRoomCount)
                  {
                     new SBOkPopup(_popupLayer,getWarningText(_loc6_ + 1,200));
                  }
               }
            }
            if(!(_itemToBuy is Item))
            {
               DarkenManager.showLoadingSpiral(false);
            }
            else if(_shopToSell)
            {
               putOnPurchasedItem();
            }
            if(_shopToSell)
            {
               removeItemFromAllLists();
               _shopToSell.setupNewShopLists();
            }
            else
            {
               setupShopWindows();
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(param1 == -2)
            {
               _itemNotAvailPopup = new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14797),true,onItemNoLongerAvailable);
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14798),true,onCouldntPurchaseOk);
            }
            ItemXtCommManager.setItemBuyIlCallback(null);
            if(_shopToSell)
            {
               applyAndClose();
            }
         }
      }
      
      private function removeItemFromAllLists() : void
      {
         var _loc1_:Iitem = null;
         var _loc2_:int = 0;
         if(_itemToBuy)
         {
            _loc1_ = _currShopItemArray.getCoreArray().removeAt(_itemIdx);
            _loc2_ = 0;
            while(_loc2_ < _shopItemArray.length)
            {
               if(_shopItemArray.getIitem(_loc2_).invIdx == _loc1_.invIdx && _shopItemArray.getIitem(_loc2_).defId == _loc1_.defId)
               {
                  _shopItemArray.getCoreArray().removeAt(_loc2_);
                  break;
               }
               _loc2_++;
            }
            setupCurrencyAmounts();
         }
      }
      
      private function onCouldntPurchaseOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ShopManager.clearShopItems(_shopId);
         SBOkPopup.destroyInParentChain(param1.target.parent);
         if(_shopToSell)
         {
            applyAndClose();
         }
      }
      
      protected function onDenItemPurchaseInventoryResponse() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_shop)
         {
            if((_itemToBuy as DenItem).sortId == 4)
            {
               _loc1_ = Utility.numDenItemsInList(_playerAvatar.inventoryDenFull.denItemCollection,-1,true);
               if(_loc1_ >= ShopManager.warningAudioItemCount)
               {
                  new SBOkPopup(_popupLayer,getWarningText(_loc1_,ShopManager.maxAudioItems));
               }
            }
            else
            {
               _loc2_ = Utility.numDenItemsInList(_playerAvatar.inventoryDenFull.denItemCollection,_itemToBuy.enviroType);
               if(_loc2_ >= ShopManager.warningDenItemCount)
               {
                  new SBOkPopup(_popupLayer,getWarningText(_loc2_,ShopManager.maxDenItems));
               }
               if((_itemToBuy as DenItem).sortId == 2 || (_itemToBuy as DenItem).sortId == 3)
               {
                  if(gMainFrame.userInfo.userVarCache.getUserVarValueById(420) <= 0)
                  {
                     AchievementXtCommManager.requestSetUserVar(420,1);
                     GuiManager.resetPetWindowListAndUpdateBtns();
                  }
               }
               GuiManager.updateSwitchRecycleBtnVisibility();
            }
            if(matchesShopId(13))
            {
               if(!_isShopOnlyDen)
               {
                  return;
               }
            }
            if(_shopToSell)
            {
               removeItemFromAllLists();
               _shopToSell.setupNewShopLists();
            }
            else
            {
               setupShopWindows();
            }
         }
      }
      
      private function getWarningText(param1:int, param2:int) : String
      {
         var _loc4_:int = param2 - param1;
         var _loc3_:String = "";
         if(_loc4_ > 1)
         {
            _loc3_ = LocalizationManager.translateIdAndInsertOnly(11378,_loc4_);
         }
         else if(_loc4_ == 1)
         {
            _loc3_ = LocalizationManager.translateIdAndInsertOnly(11379,_loc4_);
         }
         else
         {
            _loc3_ = LocalizationManager.translateIdOnly(11381);
         }
         return _loc3_;
      }
      
      private function matchesShopId(param1:int) : Boolean
      {
         if(_shopToSell == null && _shopId == param1)
         {
            return true;
         }
         return false;
      }
      
      protected function putOnPurchasedItem() : void
      {
         var _loc2_:IntItemCollection = null;
         var _loc7_:IntItemCollection = null;
         var _loc1_:int = _currShopItemArray.getIitem(_itemIdx).layerId;
         var _loc3_:AccItemCollection = _playerAvatar.inventoryClothing.itemCollection;
         var _loc4_:int = _loc3_.getAccItem(0).invIdx;
         var _loc5_:int = -1;
         for each(var _loc6_ in _loc3_.getCoreArray())
         {
            if(_loc6_.getInUse(_playerAvatar.avInvId) && _loc6_.layerId == _loc1_ && _loc6_.invIdx != _loc4_)
            {
               _loc5_ = _loc6_.invIdx;
               break;
            }
         }
         if(_currShopItemArray.getIitem(_itemIdx).enviroType == AvatarManager.roomEnviroType)
         {
            _loc2_ = new IntItemCollection();
            _loc2_.pushIntItem(_loc4_);
            _loc7_ = new IntItemCollection();
            if(_loc5_ != -1)
            {
               _loc7_.pushIntItem(_loc5_);
            }
            ItemXtCommManager.requestItemUse(onItemUseResponse,_loc2_,_loc7_);
            ItemXtCommManager.setItemBuyIlCallback(null);
         }
         if(_onPurchaseSuccessCallback != null)
         {
            _onPurchaseSuccessCallback();
         }
      }
      
      private function onItemUseResponse(param1:IntItemCollection, param2:IntItemCollection, param3:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_shopWithPreview)
         {
            _shopWithPreview.purchaseComplete();
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.name == _shop.iw0.name)
            {
               _loc2_ = 0;
            }
            else if(param1.currentTarget.name == _shop.iw1.name)
            {
               _loc2_ = 1;
            }
            else if(param1.currentTarget.name == _shop.iw2.name)
            {
               _loc2_ = 2;
            }
            else if(param1.currentTarget.name == _shop.iw3.name)
            {
               _loc2_ = 3;
            }
            else if(param1.currentTarget.name == _shop.iw4.name)
            {
               _loc2_ = 4;
            }
            else if(param1.currentTarget.name == _shop.iw5.name)
            {
               _loc2_ = 5;
            }
            _itemIdx = _loc2_ + _itemOffset;
         }
         else
         {
            _itemIdx = _useStartupShopIndex;
         }
         setupClickedWindow(_loc2_);
      }
      
      protected function setupClickedWindow(param1:int) : void
      {
         var _loc2_:Iitem = _currShopItemArray.getIitem(_itemIdx);
         if(!_loc2_)
         {
            return;
         }
         if(_shopId != 13 && !(_loc2_ is DenRoomItem) && _shopWithPreview)
         {
            _shopWithPreview.checkAndRemovePrevItem(_loc2_,param1);
         }
         if(_loc2_ is Item && _itemColorsArray && _itemColorsArray[_loc2_.defId] && _itemColorsArray[_loc2_.defId].length > 1)
         {
            if(_shopToSell == null)
            {
               (_loc2_ as Item).color = _itemColorsArray[_loc2_.defId][_itemColorIdx];
               _shop.colorCycleBtn.visible = !_isInFFM;
               _shop.colorCycleFlash.visible = !_isInFFM;
            }
         }
         else if(_loc2_ is DenItem)
         {
            if((_loc2_ as DenItem).getVersions() && (_loc2_ as DenItem).getVersions().length > 0)
            {
               if(_shopToSell == null)
               {
                  _denItemColorsArray = (_loc2_ as DenItem).getVersions();
                  (_loc2_ as DenItem).setVersion(_denItemColorsArray[_itemColorIdx]);
                  _shop.colorCycleBtn.visible = !_isInFFM;
                  _shop.colorCycleFlash.visible = !_isInFFM;
               }
            }
            else
            {
               _denItemColorsArray = null;
               _shop.colorCycleFlash.visible = false;
               _shop.colorCycleBtn.visible = false;
            }
         }
         else
         {
            _shop.colorCycleFlash.visible = false;
            _shop.colorCycleBtn.visible = false;
         }
         if(_shopToSell == null && (_shopId == 13 || _loc2_ is DenRoomItem))
         {
            _shop.buyPopup.visible = false;
            setupBigBuyPopup();
         }
         else
         {
            if(_shop.buyBigPopup)
            {
               _shop.buyBigPopup.visible = false;
            }
            if(_shopWithPreview)
            {
               _shopWithPreview.handleItemEquip(_loc2_,param1);
            }
            else
            {
               setupBuyPopup();
            }
         }
      }
      
      private function onItemWindowRollOver(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _shop.iw0.name)
         {
            _loc3_ = 0;
         }
         else if(param1.currentTarget.name == _shop.iw1.name)
         {
            _loc3_ = 1;
         }
         else if(param1.currentTarget.name == _shop.iw2.name)
         {
            _loc3_ = 2;
         }
         else if(param1.currentTarget.name == _shop.iw3.name)
         {
            _loc3_ = 3;
         }
         else if(param1.currentTarget.name == _shop.iw4.name)
         {
            _loc3_ = 4;
         }
         else if(param1.currentTarget.name == _shop.iw5.name)
         {
            _loc3_ = 5;
         }
         var _loc2_:MovieClip = _shop["iw" + _loc3_];
         if(_shopToSell && _isDenSaleShopOwner)
         {
            if(_currShopItemArray.getIitem(_loc3_ + _itemOffset))
            {
               _loc2_.editBtn.visible = true;
               _loc2_.deleteItemBtn.visible = true;
            }
         }
         if(_loc2_.currentFrameLabel != "mouse")
         {
            _loc2_.gotoAndPlay("mouse");
         }
         if(_loc2_.itemNameTxt.text.length == 0)
         {
            _loc2_.mouse0.gotoAndStop("outline");
         }
         else if(_loc2_.itemNameTxt.text == _loc2_.itemNameTxtMultiline.text)
         {
            _loc2_.mouse0.gotoAndStop("multi");
            _loc2_.itemNameTxtMultiline.visible = true;
         }
         else
         {
            _loc2_.mouse0.gotoAndStop("single");
            _loc2_.itemNameTxt.visible = true;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowRollOut(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _shop.iw0.name)
         {
            _loc3_ = 0;
         }
         else if(param1.currentTarget.name == _shop.iw1.name)
         {
            _loc3_ = 1;
         }
         else if(param1.currentTarget.name == _shop.iw2.name)
         {
            _loc3_ = 2;
         }
         else if(param1.currentTarget.name == _shop.iw3.name)
         {
            _loc3_ = 3;
         }
         else if(param1.currentTarget.name == _shop.iw4.name)
         {
            _loc3_ = 4;
         }
         else if(param1.currentTarget.name == _shop.iw5.name)
         {
            _loc3_ = 5;
         }
         var _loc2_:MovieClip = _shop["iw" + _loc3_];
         if(_shopToSell && _isDenSaleShopOwner)
         {
            _loc2_.editBtn.visible = false;
            _loc2_.deleteItemBtn.visible = false;
         }
         if(_loc2_.currentFrameLabel != "out")
         {
            _loc2_.gotoAndPlay("out");
         }
         if(_loc2_.itemNameTxt.text == _loc2_.itemNameTxtMultiline.text)
         {
            _loc2_.itemNameTxtMultiline.visible = false;
         }
         else
         {
            _loc2_.itemNameTxt.visible = false;
         }
      }
      
      protected function setupBuyPopup() : void
      {
         _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
         if(matchesShopId(669))
         {
            if(_charmBuyPopup != null)
            {
               setupCharmBuyPopup();
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(6620,onBuyCharmLoaded);
            }
            return;
         }
         if(_itemToBuy is PetItem)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId((_itemToBuy.icon as GuiPet).idx),OnPetFinderClose,false,null,_itemToBuy,(_itemToBuy as PetItem).currencyType,_shopId);
            return;
         }
         if(_itemToBuy is AvatarItem)
         {
            AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,onAvatarAdded,false,_itemToBuy.isOcean,false,(_itemToBuy.icon as AvatarView).avTypeId,true,_shopId,_itemToBuy.defId,_itemToBuy);
            return;
         }
         if(_shopWithPreview == null)
         {
            _itemColorIdx = 0;
         }
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
         }
         else
         {
            _shop.buyPopup.buyGreenBG.visible = true;
         }
         _shop.buyPopup.avtSpecificIcon.visible = false;
         _shop.buyPopup.newTag.visible = _itemToBuy.isNew;
         _shop.buyPopup.clearanceTag.visible = _itemToBuy.isOnClearance;
         setupNumDaysLeft(_shop.buyPopup,_itemToBuy);
         _shop.buyPopup.saleTag.visible = _itemToBuy.isOnSale;
         _shop.buyPopup.rareTag.visible = _itemToBuy.isRare;
         _shop.buyPopup.rareTag.gotoAndStop(!!_shop.colorCycleBtn.visible ? "color" : "noColor");
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
         onColorBtnDown(null);
         if(!(_itemToBuy is DenItem))
         {
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         }
         _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         setupPriceTags(_shop.buyPopup,_itemToBuy,_shop.buyBtnGreen);
         LocalizationManager.updateToFit(_shop.buyPopupItemNameTxt,_itemToBuy.name);
         if(_shop.buyPopupItemNameTxt.text == _shop.buyPopupItemNameTxtMultiline.text)
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("multi");
         }
         else
         {
            _shop.buyPopup["bg" + _appendString].gotoAndStop("single");
         }
         if(_shopWithPreview == null)
         {
            DarkenManager.darken(_shop.buyPopup);
         }
         _shop.buyPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
         if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
         {
            RoomManagerWorld.instance.playMusic((_itemToBuy as DenItem).strmName + ".mp3",(_itemToBuy as DenItem).version2 / 100);
         }
         else if(_itemToBuy.isOcean && _itemToBuy is DenItem && !DenSwitch.haveOceanDen())
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14799));
         }
         if(_itemToBuy is DenItem)
         {
            if((_itemToBuy as DenItem).specialType == 7 || (_itemToBuy as DenItem).specialType == 6)
            {
               _shop.buyPopup.consumerItemBtn.visible = true;
               _shop.buyPopup.consumerItemBtn.activateGrayState((_itemToBuy as DenItem).specialType == 6);
            }
            else
            {
               _shop.buyPopup.consumerItemBtn.visible = false;
            }
         }
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,6))
         {
            AchievementXtCommManager.requestSetUserVar(379,6);
         }
         if(_showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,7))
         {
            TutorialPopups.openTutorialTextPopup(18660,10,115);
            _shop.buyBtnGreen.gotoAndStop("new");
            _shop.buyBtnGreen.setButtonState(2);
         }
         else
         {
            _shop.buyBtnGreen.setButtonState(1);
         }
      }
      
      private function setupBigBuyPopup() : void
      {
         _itemToBuy = _currShopItemArray.getIitem(_itemIdx).clone();
         _itemColorIdx = 0;
         if(_itemToBuy.isMemberOnly)
         {
            _shop.buyBigPopup.banner.visible = true;
            LocalizationManager.translateId(_shop.buyBigPopup.banner.txtCont.txt,11376);
            if(_isMember)
            {
               _shop.buyBigPopup.lockOpen.visible = true;
               _shop.buyBigPopup.lock.visible = false;
            }
            else
            {
               _shop.buyBigPopup.lock.visible = true;
               _shop.buyBigPopup.lockOpen.visible = false;
            }
         }
         else
         {
            _shop.buyBigPopup.lockOpen.visible = false;
            _shop.buyBigPopup.lock.visible = false;
            _shop.buyBigPopup.banner.visible = false;
         }
         if(_itemToBuy.isOcean)
         {
            _shop.buyBigPopup.buyGreenBG.visible = false;
         }
         else
         {
            _shop.buyBigPopup.buyGreenBG.visible = true;
         }
         _shop.buyBigPopup.avtSpecificIcon.visible = false;
         _shop.buyBigPopup.newTag.visible = _itemToBuy.isNew;
         _shop.buyBigPopup.clearanceTag.visible = _itemToBuy.isOnClearance;
         setupNumDaysLeft(_shop.buyBigPopup,_itemToBuy);
         _shop.buyBigPopup.saleTag.visible = _itemToBuy.isOnSale;
         _shop.buyBigPopup.rareTag.visible = _itemToBuy.isRare;
         if(_shop.buyBigPopup.itemLayer.numChildren > 1)
         {
            _shop.buyBigPopup.itemLayer.removeChildAt(1);
         }
         if(!(_itemToBuy is DenItem))
         {
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         }
         _shop.buyBigPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         _shop.buyBigPopup.tag.txt.text = Utility.convertNumberToString(_itemToBuy.value);
         setupPriceTags(_shop.buyBigPopup,_itemToBuy,_shop.buyBigBtnGreen);
         LocalizationManager.updateToFit(_shop.buyBigPopupItemNameTxt,_itemToBuy.name);
         if(_shop.buyBigPopupItemNameTxt.text == _shop.buyBigPopupItemNameTxtMultiline.text)
         {
            _shop.buyBigPopup["bg" + _appendString].gotoAndStop("multi");
         }
         else
         {
            _shop.buyBigPopup["bg" + _appendString].gotoAndStop("single");
         }
         DarkenManager.darken(_shop.buyBigPopup);
         _shop.buyBigPopup.visible = true;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onBuyCharmLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _charmBuyPopup = MovieClip(param1.getChildAt(0));
         _charmBuyPopup.x = 900 * 0.5;
         _charmBuyPopup.y = 550 * 0.5;
         setupCharmBuyPopup();
      }
      
      private function setupCharmBuyPopup() : void
      {
         _charmBuyPopup.redeem.visible = false;
         _charmBuyPopup.preview.visible = true;
         _charmBuyPopup.preview.itemLayer.addChild(_itemToBuy.largeIcon);
         if(_charmBuddyListItemWindow != null)
         {
            _charmBuddyListItemWindow.destroy();
         }
         if(BuddyList.listRequested)
         {
            _charmBuddyListItemWindow = new WindowAndScrollbarGenerator();
            _charmBuddyListItemWindow.init(_charmBuyPopup.preview.itemBlock.width,_charmBuyPopup.preview.itemBlock.height,0,0,1,5,0,0,1,0,0.5,ItemWindowBuddyList,BuddyList.buildBuddyList(),"",0,{"mouseDown":clickOnCharmBuddyHandler},{
               "isSelection":true,
               "currSelectedUsername":""
            },null,true,false,false,false,false);
            _charmBuyPopup.preview.itemBlock.addChild(_charmBuddyListItemWindow);
         }
         else
         {
            BuddyXtCommManager.sendBuddyListRequest(onBuddyListLoaded);
            BuddyList.listRequested = true;
         }
         LocalizationManager.translateId(_charmBuyPopup.redeem.bodyTxt,31200);
         _currentSelectedCharmUsername = "";
         _currentSelectedCharmIndex = -1;
         _charmBuyPopup.preview.colorChange_btn.visible = _itemColorsArray[_itemToBuy.defId].length > 1;
         _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         _charmBuyPopup.preview.redeemBtn.activateGrayState(true);
         addCharmEventListeners();
         _popupLayer.addChild(_charmBuyPopup);
         DarkenManager.darken(_charmBuyPopup);
      }
      
      private function onBuddyListLoaded() : void
      {
         _charmBuddyListItemWindow = new WindowAndScrollbarGenerator();
         _charmBuddyListItemWindow.init(_charmBuyPopup.preview.itemBlock.width,_charmBuyPopup.preview.itemBlock.height,0,0,1,5,0,0,1,0,0.5,ItemWindowBuddyList,BuddyList.buildBuddyList(),"",0,{"mouseDown":clickOnCharmBuddyHandler},{
            "isSelection":true,
            "currSelectedUsername":""
         },null,true,false,false,false,false);
         _charmBuyPopup.preview.itemBlock.addChild(_charmBuddyListItemWindow);
      }
      
      private function clickOnCharmBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Buddy = param1.currentTarget.getBuddy();
         if(_currentSelectedCharmUsername != "" && _currentSelectedCharmUsername.toLowerCase() == param1.currentTarget.buddyPortalUsername())
         {
            param1.currentTarget.turnOffBuddySelection();
            _currentSelectedCharmIndex = -1;
            _currentSelectedCharmUsername = "";
            _charmBuyPopup.preview.redeemBtn.activateGrayState(true);
         }
         else
         {
            if(_currentSelectedCharmIndex != -1)
            {
               MovieClip(_charmBuddyListItemWindow.bg.getChildAt(_currentSelectedCharmIndex)).turnOffBuddySelection();
            }
            param1.currentTarget.setBuddySelection();
            _currentSelectedCharmIndex = param1.currentTarget.index;
            _currentSelectedCharmUsername = param1.currentTarget.getBuddy().userName;
            _charmBuyPopup.preview.redeemBtn.activateGrayState(false);
         }
      }
      
      protected function OnPetFinderClose(param1:Boolean) : void
      {
         if(param1)
         {
            playCurrencyAnimation();
         }
         if(_shop)
         {
            _shop["myGemCountTxt" + _appendString].text = Utility.convertNumberToString(UserCurrency.getCurrency(_itemToBuy.currencyType));
            setupShopWindows();
         }
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            OnPetFinderClose(true);
            return;
         }
         if(param1 == -1)
         {
            LocalizationManager.translateIdAndInsert(_shop.oopsPopup.body_txt,11382,_itemToBuy.name.toLowerCase());
         }
         else
         {
            LocalizationManager.translateId(_shop.oopsPopup.body_txt,11225);
         }
         _shop.oopsPopup.visible = true;
      }
      
      private function onColorBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_itemToBuy is Item && _itemColorsArray && _itemColorsArray[_itemToBuy.defId])
         {
            if(param1)
            {
               if(_itemColorsArray[_itemToBuy.defId][_itemColorIdx + 1] != null)
               {
                  _itemColorIdx++;
               }
               else
               {
                  if(_itemColorIdx == 0)
                  {
                     _shop.colorCycleBtn.removeEventListener("mouseDown",onColorBtnDown);
                     _shop.colorCycleBtn.visible = false;
                     return;
                  }
                  _itemColorIdx = 0;
               }
            }
            if(_shop.buyPopup.itemLayer.numChildren > 1)
            {
               _shop.buyPopup.itemLayer.removeChildAt(1);
            }
            (_itemToBuy as Item).color = _itemColorsArray[_itemToBuy.defId][_itemColorIdx];
            _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
            _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         }
         else if(_itemToBuy is DenItem && _denItemColorsArray)
         {
            if(param1)
            {
               if(_denItemColorsArray[_itemColorIdx + 1] != null)
               {
                  _itemColorIdx++;
               }
               else if(_itemColorIdx != 0)
               {
                  _itemColorIdx = 0;
               }
            }
            if(_shop.buyPopup.itemLayer.numChildren > 1)
            {
               _shop.buyPopup.itemLayer.removeChildAt(1);
            }
            (_itemToBuy as DenItem).setVersion(_denItemColorsArray[_itemColorIdx]);
            _shop.buyPopup.itemLayer.addChild(_itemToBuy.largeIcon);
         }
         if(_shopWithPreview)
         {
            _shopWithPreview.adjustColor();
         }
      }
      
      protected function onBuyPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.unDarken(_shop.buyPopup);
         _shop.buyPopup.visible = false;
         if(_shop.buyPopup.itemLayer.numChildren > 1)
         {
            _shop.buyPopup.itemLayer.removeChildAt(1);
         }
         if(_itemToBuy is DenItem && (_itemToBuy as DenItem).sortId == 4)
         {
            RoomManagerWorld.instance.playPreviousMusic();
         }
         TutorialPopups.closeTutorialTextPopup();
         if(_shopWithPreview)
         {
            _shopWithPreview.adjustColor();
         }
         else
         {
            _itemColorIdx = 0;
         }
      }
      
      private function onDiamondShopInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openDiamondShopInfo();
      }
      
      private function onInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_isInfoOpen)
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x - 185},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            _isInfoOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else
         {
            new GTween(param1.currentTarget.parent,0.5,{"x":param1.currentTarget.parent.x + 185},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            _isInfoOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         _infoTweenFinished = false;
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         _infoTweenFinished = true;
      }
      
      private function onBuyBigPopupCloseBtnDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_shop.buyBigPopup)
         {
            DarkenManager.unDarken(_shop.buyBigPopup);
            _shop.buyBigPopup.visible = false;
            if(_shop.buyBigPopup.itemLayer.numChildren > 1)
            {
               _shop.buyBigPopup.itemLayer.removeChildAt(1);
            }
         }
         _itemColorIdx = 0;
         _denItemIdx = 0;
      }
      
      private function onBuyBigPopupPreviewBtnDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         var _loc5_:Iitem = _currShopItemArray.getIitem(_itemIdx);
         var _loc6_:int = _loc5_.defId;
         if(_loc5_.currencyType == 3)
         {
            _loc2_ = DiamondXtCommManager.getDiamondDef(_loc5_.diamondItem.defId);
            if(_loc2_)
            {
               _loc6_ = int(_loc2_.refDefId);
            }
         }
         var _loc3_:Object = gMainFrame.userInfo.denRoomDefs[_loc6_];
         if(_loc3_ != null ? RoomXtCommManager.getRoomDef(_loc3_.roomDefId) : null)
         {
            if(Utility.isSameEnviroType(AvatarManager.playerAvatar.enviroTypeFlag,_loc5_.enviroType))
            {
               DarkenManager.unDarken(_shop.buyBigPopup);
               _denPreviewManager = new DenPreviewManager();
               _denPreviewManager.setCurrentShop(this);
               RoomManagerWorld.instance.loadPreviewRoom(null.pathName,_loc5_.enviroType,_denPreviewManager);
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(Utility.isOcean(AvatarManager.playerAvatar.enviroTypeFlag) ? 18905 : 18903));
            }
         }
      }
      
      private function onOopsPopupCloseBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_shop.oopsPopup);
         _shop.oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_shop["oopsCostPopup" + _appendString]);
         _shop["oopsCostPopup" + _appendString].visible = false;
         if(_appendString == "")
         {
            _shop.oopsCostPopup.earnGemsBtn.removeEventListener("mouseDown",onEarnGemsBtn);
         }
      }
      
      private function onEarnGemsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onCostPopupClose(param1);
         onClose(param1);
         GuiManager.openJoinGamesPopup();
      }
      
      private function playCurrencyAnimation() : void
      {
         var _loc1_:Boolean = Boolean(!!_shopToSell ? _shopToSell.currShopItem.currencyType : _itemToBuy.currencyType == 3);
         if(_shop)
         {
            if(_glDefType == 1060 && _loc1_)
            {
               if(_shop.diamondAnim)
               {
                  _shop.diamondAnim.gotoAndStop("diamonds");
                  _shop.diamondAnim.visible = true;
                  _shop.diamondAnim.diamonds.gotoAndPlay(1);
               }
            }
            else if(_shop.gemAnim)
            {
               _shop.gemAnim.gotoAndStop(_loc1_ ? "diamonds" : "gems");
               _shop.gemAnim.visible = true;
               _shop.gemAnim[_loc1_ ? "diamonds" : "gems"].gotoAndPlay(1);
            }
         }
         AJAudio.playShopCachingSound();
      }
      
      private function onSortBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = !!_shopWithPreview ? "" : _appendString;
         _shop["sortingPopup" + _loc2_].visible = !_shop["sortingPopup" + _loc2_].visible;
         if(_shop["sortingPopup" + _loc2_].visible)
         {
            onSortBtnOut(param1);
         }
      }
      
      private function onSortBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_shop["sortingPopup" + (!!_shopWithPreview ? "" : _appendString)].visible)
         {
            return;
         }
         GuiManager.toolTip.init(param1.currentTarget as MovieClip,LocalizationManager.translateIdOnly(24502),0,30,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onSortBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onSortingBtns(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         var _loc3_:Iitem = null;
         param1.stopPropagation();
         if(_shopWithPreview)
         {
            _loc3_ = _currShopItemArray.getIitem(_itemIdx);
            if(_loc3_)
            {
               _shopWithPreview.handleItemEquip(_loc3_,0,true);
            }
         }
         onBuyPopupCloseBtnDown(null);
         if(param1.currentTarget.name == "timeBtn")
         {
            if(_currShopItemArray == _shopItemArray)
            {
               _currShopItemArray = _shopItemArrayReversed;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Dn");
            }
            else
            {
               _currShopItemArray = _shopItemArray;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Up");
            }
         }
         else if(param1.currentTarget.name == "gemBtn")
         {
            if(_currShopItemArray == _shopItemArrayGemHigh)
            {
               _currShopItemArray = _shopItemArrayGemLow;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Up");
            }
            else
            {
               _currShopItemArray = _shopItemArrayGemHigh;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Dn");
            }
         }
         else if(param1.currentTarget.name == "abcBtn")
         {
            if(_currShopItemArray == _shopItemArrayNameHigh)
            {
               _currShopItemArray = _shopItemArrayNameLow;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Dn");
            }
            else
            {
               _currShopItemArray = _shopItemArrayNameHigh;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Up");
            }
         }
         if(_shopToSell)
         {
            _shopToSell.onSortButton(param1.currentTarget.name,_loc4_ == "Up");
         }
         var _loc2_:String = !!_shopWithPreview ? "" : _appendString;
         _shop["sortBtn" + _loc2_].gotoAndStop(param1.currentTarget.name + _loc4_);
         _shop["sortingPopup" + _loc2_].visible = false;
         _itemOffset = 0;
         setupShopWindows();
      }
      
      private function onCharmBuyPopupClose(param1:MouseEvent) : void
      {
         DarkenManager.unDarken(_charmBuyPopup);
         _popupLayer.removeChild(_charmBuyPopup);
         removeCharmEventListeners();
         if(param1 != null)
         {
            param1.stopPropagation();
         }
         else
         {
            applyAndClose();
         }
      }
      
      private function onCharmBuyPopupColorChange(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            if(_itemColorsArray[_itemToBuy.defId][_itemColorIdx + 1] != null)
            {
               _itemColorIdx++;
            }
            else if(_itemColorIdx != 0)
            {
               _itemColorIdx = 0;
            }
         }
         if(_charmBuyPopup.preview.itemLayer.numChildren > 1)
         {
            _charmBuyPopup.preview.itemLayer.removeChildAt(1);
         }
         (_itemToBuy as Item).color = _itemColorsArray[_itemToBuy.defId][_itemColorIdx];
         _itemToBuy.largeIcon.filters = [new GlowFilter(5586479,1,2,2,8)];
         _charmBuyPopup.preview.itemLayer.addChild(_itemToBuy.largeIcon);
      }
      
      private function onCharmBuyPopupReedeem(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _charmBuyPopup.preview.visible = false;
         _charmBuyPopup.redeem.visible = true;
      }
      
      private function onCharmBuyPopupRedeemClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _charmBuyPopup.preview.visible = true;
         _charmBuyPopup.redeem.visible = false;
      }
      
      private function onCharmBuyPopupRedeemOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:Iitem = _currShopItemArray.getIitem(_itemIdx).clone();
         ItemXtCommManager.requestItemBuy(onCharmBuyResponse,_shopId,_loc2_.defId,_itemColorIdx,0,RoomManagerWorld.instance.denItemHolder.lastSelectedItem.invIdx,_currentSelectedCharmUsername);
         ItemXtCommManager.setItemBuyIlCallback(putOnPurchasedItem);
      }
      
      private function onCharmBuyPopupRedeemNo(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _charmBuyPopup.preview.visible = true;
         _charmBuyPopup.redeem.visible = false;
      }
      
      private function onCharmBuyResponse(param1:int, param2:Object, param3:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(31204,_currentSelectedCharmUsername),true,onCharmBuyResponseOk);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(28159),true,onCharmBuyResponseOk);
         }
      }
      
      private function onCharmBuyResponseOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onCharmBuyPopupClose(null);
      }
      
      protected function addListeners() : void
      {
         _shop.frame.bx.addEventListener("mouseDown",onClose,false,0,true);
         _shop.nextBtn.addEventListener("mouseDown",pageCatalogHandler,false,0,true);
         _shop.prevBtn.addEventListener("mouseDown",pageCatalogHandler,false,0,true);
         _shop.buyBtnGreen.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
         _shop.buyBtnRed.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
         _shop.buyPopup.closeBtn.addEventListener("mouseDown",onBuyPopupCloseBtnDown,false,0,true);
         _shop.colorCycleBtn.addEventListener("mouseDown",onColorBtnDown,false,0,true);
         if(_shop.buyBigPopup)
         {
            _shop.buyBigBtnGreen.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
            _shop.buyBigBtnRed.addEventListener("mouseDown",buyBtnDownHandler,false,0,true);
            _shop.buyBigPopup.closeBtn.addEventListener("mouseDown",onBuyBigPopupCloseBtnDown,false,0,true);
            _shop.buyBigPopupPreviewBtn.addEventListener("mouseDown",onBuyBigPopupPreviewBtnDown,false,0,true);
         }
         _shop.oopsPopup.closeBtn.addEventListener("mouseDown",onOopsPopupCloseBtnDown,false,0,true);
         _shop["oopsCostPopup" + _appendString].bx.addEventListener("mouseDown",onCostPopupClose,false,0,true);
         var _loc1_:String = _shopWithPreview == null ? _appendString : "";
         if(!_isCombinedCurrencyStore && _shop["sortBtn" + _loc1_])
         {
            _shop["sortBtn" + _loc1_].addEventListener("mouseDown",onSortBtn,false,0,true);
            _shop["sortBtn" + _loc1_].addEventListener("mouseOver",onSortBtnOver,false,0,true);
            _shop["sortBtn" + _loc1_].addEventListener("mouseOut",onSortBtnOut,false,0,true);
            _shop["sortingPopup" + _loc1_].timeBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
            _shop["sortingPopup" + _loc1_].gemBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
            _shop["sortingPopup" + _loc1_].abcBtn.addEventListener("mouseDown",onSortingBtns,false,0,true);
         }
         if(_shop.infoBtn)
         {
            _shop.infoBtn.addEventListener("mouseDown",onDiamondShopInfoBtn,false,0,true);
         }
      }
      
      private function addCharmEventListeners() : void
      {
         if(_charmBuyPopup)
         {
            _charmBuyPopup.preview.bx.addEventListener("mouseDown",onCharmBuyPopupClose,false,0,true);
            _charmBuyPopup.preview.colorChange_btn.addEventListener("mouseDown",onCharmBuyPopupColorChange,false,0,true);
            _charmBuyPopup.preview.redeemBtn.addEventListener("mouseDown",onCharmBuyPopupReedeem,false,0,true);
            _charmBuyPopup.redeem.bx.addEventListener("mouseDown",onCharmBuyPopupRedeemClose,false,0,true);
            _charmBuyPopup.redeem.okBtn.addEventListener("mouseDown",onCharmBuyPopupRedeemOk,false,0,true);
            _charmBuyPopup.redeem.noBtn.addEventListener("mouseDown",onCharmBuyPopupRedeemNo,false,0,true);
         }
      }
      
      private function removeCharmEventListeners() : void
      {
         if(_charmBuyPopup)
         {
            _charmBuyPopup.preview.bx.removeEventListener("mouseDown",onCharmBuyPopupClose);
            _charmBuyPopup.preview.colorChange_btn.removeEventListener("mouseDown",onCharmBuyPopupColorChange);
            _charmBuyPopup.preview.redeemBtn.removeEventListener("mouseDown",onCharmBuyPopupReedeem);
            _charmBuyPopup.redeem.bx.removeEventListener("mouseDown",onCharmBuyPopupRedeemClose);
            _charmBuyPopup.redeem.okBtn.removeEventListener("mouseDown",onCharmBuyPopupRedeemOk);
            _charmBuyPopup.redeem.noBtn.removeEventListener("mouseDown",onCharmBuyPopupRedeemNo);
         }
      }
      
      protected function removeListeners() : void
      {
         var _loc2_:int = 0;
         _shop.frame.bx.removeEventListener("mouseDown",onClose);
         _shop.nextBtn.removeEventListener("mouseDown",pageCatalogHandler);
         _shop.prevBtn.removeEventListener("mouseDown",pageCatalogHandler);
         _loc2_ = 0;
         while(_loc2_ < 6)
         {
            _shop["iw" + _loc2_].removeEventListener("mouseDown",onItemWindowDown);
            _shop["iw" + _loc2_].removeEventListener("rollOver",onItemWindowRollOver);
            _shop["iw" + _loc2_].removeEventListener("rollOut",onItemWindowRollOut);
            if(_shopToSell && _isDenSaleShopOwner)
            {
               _shop["iw" + _loc2_].editBtn.addEventListener("mouseDown",_shopToSell.onEditBtn);
               _shop["iw" + _loc2_].deleteItemBtn.addEventListener("mouseDown",_shopToSell.onDeleteBtn);
            }
            _loc2_++;
         }
         _shop.buyBtnGreen.removeEventListener("mouseDown",buyBtnDownHandler);
         _shop.buyBtnRed.removeEventListener("mouseDown",buyBtnDownHandler);
         if(_shop.buyBtnGreenPreview)
         {
            _shop.buyBtnGreenPreview.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBtnRedPreview.removeEventListener("mouseDown",buyBtnDownHandler);
         }
         _shop.buyPopup.closeBtn.removeEventListener("mouseDown",onBuyPopupCloseBtnDown);
         _shop.colorCycleBtn.removeEventListener("mouseDown",onColorBtnDown);
         if(_shop.buyBigPopup)
         {
            _shop.buyBigBtnGreen.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBigBtnRed.removeEventListener("mouseDown",buyBtnDownHandler);
            _shop.buyBigPopup.closeBtn.removeEventListener("mouseDown",onBuyBigPopupCloseBtnDown);
            _shop.buyBigPopupPreviewBtn.removeEventListener("mouseDown",onBuyBigPopupPreviewBtnDown);
         }
         _shop.oopsPopup.closeBtn.removeEventListener("mouseDown",onOopsPopupCloseBtnDown);
         var _loc1_:String = _shopWithPreview == null ? _appendString : "";
         _shop["oopsCostPopup" + _loc1_].bx.removeEventListener("mouseDown",onCostPopupClose);
         if(!_isCombinedCurrencyStore && _shop["sortBtn" + _loc1_])
         {
            _shop["sortBtn" + _loc1_].removeEventListener("mouseDown",onSortBtn);
            _shop["sortBtn" + _loc1_].removeEventListener("mouseOver",onSortBtnOver);
            _shop["sortBtn" + _loc1_].removeEventListener("mouseOut",onSortBtnOut);
            _shop["sortingPopup" + _loc1_].timeBtn.removeEventListener("mouseDown",onSortingBtns);
            _shop["sortingPopup" + _loc1_].gemBtn.removeEventListener("mouseDown",onSortingBtns);
            _shop["sortingPopup" + _loc1_].abcBtn.removeEventListener("mouseDown",onSortingBtns);
         }
         if(_shop.infoBtn)
         {
            _shop.infoBtn.removeEventListener("mouseDown",onDiamondShopInfoBtn);
         }
      }
   }
}

