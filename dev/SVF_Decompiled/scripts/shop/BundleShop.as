package shop
{
   import collection.IitemCollection;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.UpsellManager;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class BundleShop
   {
      private var _mediaHelper:MediaHelper;
      
      private var _bundleShop:MovieClip;
      
      private const SHOP_ID:int = 1;
      
      private const MEDIA_ID:int = 8266;
      
      private var _unfilteredItemArray:IitemCollection;
      
      private var _unfilteredColorsArray:Array;
      
      private var _shopItemArray:IitemCollection;
      
      private var _itemColorsArray:Array;
      
      private var _currShopItemArray:IitemCollection;
      
      private var _diamondCost:int;
      
      private var _closeCallback:Function;
      
      public function BundleShop(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(8266,onShopLoaded);
      }
      
      private function onShopLoaded(param1:MovieClip) : void
      {
         _bundleShop = param1.getChildAt(0) as MovieClip;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(8267,onImageLoaded);
         ItemXtCommManager.requestShopList(gotItemListCallback,1);
      }
      
      private function onImageLoaded(param1:MovieClip) : void
      {
         _bundleShop.itemLayer.addChild(param1.getChildAt(0));
      }
      
      private function gotItemListCallback(param1:IitemCollection, param2:String, param3:Boolean, param4:int, param5:Array = null) : void
      {
         if(param3)
         {
            _diamondCost = param4;
            _unfilteredItemArray = param1;
            _unfilteredColorsArray = param5;
            LocalizationManager.translateId(_bundleShop.bodyTxt,35572);
            if(param2 != "")
            {
               LocalizationManager.translateId(_bundleShop.titleTxt,int(param2));
            }
            setupTags();
            filterItemLists();
         }
      }
      
      private function filterItemLists() : void
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
         GenericListXtCommManager.filterIitems(_shopItemArray,true,_itemColorsArray);
         DarkenManager.showLoadingSpiral(false);
         if(_shopItemArray.length == 0)
         {
            destroy();
            return;
         }
         _bundleShop.visible = true;
         _bundleShop.x = 900 * 0.5;
         _bundleShop.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_bundleShop);
         DarkenManager.darken(_bundleShop);
         addListeners();
      }
      
      private function setupTags() : void
      {
         if(UserCurrency.hasEnoughCurrency(3,_diamondCost))
         {
            if(_bundleShop.tag.currentFrameLabel != "diamondgreen")
            {
               _bundleShop.tag.gotoAndPlay("diamondgreen");
            }
            _bundleShop.tag.txt.textColor = "0x386630";
         }
         else
         {
            if(_bundleShop.tag.currentFrameLabel != "diamondred")
            {
               _bundleShop.tag.gotoAndPlay("diamondred");
            }
            _bundleShop.tag.txt.textColor = "0x800000";
         }
         _bundleShop.tag.txt.text = Utility.convertNumberToString(_diamondCost);
         _bundleShop.tag.visible = true;
      }
      
      private function addListeners() : void
      {
         _bundleShop.addEventListener("mouseDown",onPopupDown,false,0,true);
         _bundleShop.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _bundleShop.buyBtn.addEventListener("mouseDown",onBuyBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _bundleShop.removeEventListener("mouseDown",onPopupDown);
         _bundleShop.bx.removeEventListener("mouseDown",onCloseBtn);
         _bundleShop.buyBtn.removeEventListener("mouseDown",onBuyBtn);
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("diamondShop","buyBundle/");
            return;
         }
         if(!UserCurrency.hasEnoughCurrency(3,_diamondCost))
         {
            UpsellManager.displayPopup("","extraDiamonds");
            return;
         }
         ItemXtCommManager.requestBuyDiamondBundle(1,onDiamondPurchaseComplete);
      }
      
      private function onDiamondPurchaseComplete(param1:Object) : void
      {
         destroy();
         if(param1[2] == "true")
         {
            UserCurrency.setCurrency(param1[3],3);
            GuiManager.setupInGameRedemptions();
         }
      }
      
      private function destroy() : void
      {
         removeListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         DarkenManager.unDarken(_bundleShop);
         GuiManager.guiLayer.removeChild(_bundleShop);
         _bundleShop = null;
         if(_closeCallback != null)
         {
            _closeCallback(false);
            _closeCallback = null;
         }
      }
   }
}

