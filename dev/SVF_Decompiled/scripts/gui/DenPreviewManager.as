package gui
{
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import shop.Shop;
   
   public class DenPreviewManager
   {
      private var _currentShop:Shop;
      
      private var _buyAndBackBtns:MovieClip;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _currDenSwitcherCallback:Function;
      
      public function DenPreviewManager()
      {
         super();
      }
      
      public function setCurrentShop(param1:Shop) : void
      {
         _currentShop = param1;
      }
      
      public function destroy() : void
      {
         if(_buyAndBackBtns)
         {
            _buyAndBackBtns.backBtn.removeEventListener("mouseDown",onBackBtn);
            _buyAndBackBtns.buyBtn.removeEventListener("mouseDown",onBuyBtn);
            GuiManager.guiLayer.removeChild(_buyAndBackBtns);
         }
      }
      
      public function handleAllRequiredVisibilities(param1:Boolean) : void
      {
         GuiManager.toggleHud();
         handleDenSwitcherandShopVisibility(param1);
         GuiManager.showDenHudItems(param1);
         if(_buyAndBackBtns)
         {
            _buyAndBackBtns.visible = !param1;
         }
         else if(!param1)
         {
            showBuyAndBackBtns(true);
         }
      }
      
      public function handleDenPurchase() : void
      {
         if(_buyAndBackBtns && _buyAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _buyAndBackBtns.visible = false;
         }
      }
      
      public function showBuyAndBackBtns(param1:Boolean) : void
      {
         if(param1)
         {
            if(_buyAndBackBtns)
            {
               _buyAndBackBtns.visible = true;
            }
            else
            {
               _loadingMediaHelper = new MediaHelper();
               _loadingMediaHelper.init(2969,onBuyAndBackBtnsLoaded);
            }
         }
         else if(_buyAndBackBtns)
         {
            _buyAndBackBtns.visible = false;
         }
      }
      
      public function exitPreview() : void
      {
         onBackBtn(null);
      }
      
      private function handleDenSwitcherandShopVisibility(param1:Boolean, param2:Boolean = false) : void
      {
         if(param1)
         {
            GuiManager.showDenSwitcher(true);
            if(GuiManager.currDenSwitcher)
            {
               GuiManager.currDenSwitcher.rebuildWindows(param2,_currDenSwitcherCallback);
            }
            if(_currentShop)
            {
               _currentShop.showShop(true);
            }
         }
         else
         {
            if(_currentShop)
            {
               _currentShop.showShop(false);
            }
            GuiManager.showDenSwitcher(false);
            if(GuiManager.currDenSwitcher)
            {
               _currDenSwitcherCallback = GuiManager.currDenSwitcher.currCloseCallback;
            }
         }
      }
      
      private function onBuyAndBackBtnsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _buyAndBackBtns = param1;
            _buyAndBackBtns.backBtn.addEventListener("mouseDown",onBackBtn,false,0,true);
            _buyAndBackBtns.buyBtn.addEventListener("mouseDown",onBuyBtn,false,0,true);
            GuiManager.guiLayer.addChild(_buyAndBackBtns);
         }
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_buyAndBackBtns && _buyAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _buyAndBackBtns.visible = false;
         }
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_currentShop)
         {
            if(_currentShop.isCurrentItemDiamond)
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.denRoomDefs[_currentShop.getCurrentItemDefId()];
               if(_loc2_)
               {
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(10305,Utility.convertNumberToString(_loc2_.value)),true,onPreviewBuy);
               }
            }
         }
      }
      
      private function onPreviewBuy(param1:Object) : void
      {
         if(param1.status)
         {
            if(_currentShop)
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
         }
      }
   }
}

