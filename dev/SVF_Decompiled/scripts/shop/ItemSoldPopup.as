package shop
{
   import collection.IitemCollection;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import inventory.Iitem;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ItemSoldPopup
   {
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _soldPopup:MovieClip;
      
      private var _itemCollection:IitemCollection;
      
      private var _shopItem:Iitem;
      
      private var _soldAmount:int;
      
      private var _currencyType:int;
      
      private var _passback:Object;
      
      public function ItemSoldPopup(param1:Iitem, param2:int, param3:int, param4:Function, param5:Object)
      {
         super();
         _shopItem = param1;
         _soldAmount = param2;
         _currencyType = param3;
         _closeCallback = param4;
         _passback = param5;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(7718,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         _shopItem.destroy();
         DarkenManager.unDarken(_soldPopup);
         GuiManager.guiLayer.removeChild(_soldPopup);
         _soldPopup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         _soldPopup = MovieClip(param1.getChildAt(0));
         _soldPopup.x = 900 * 0.5;
         _soldPopup.y = 550 * 0.5;
         addEventListeners();
         _soldPopup.itemLayer.addChild(_shopItem.largeIcon);
         LocalizationManager.updateToFit(_soldPopup.item_name_txt,_shopItem.name);
         if(_currencyType == 3)
         {
            if(_soldAmount == 1)
            {
               _loc2_ = 33922;
            }
            else
            {
               _loc2_ = 33925;
            }
         }
         else if(_soldAmount == 1)
         {
            _loc2_ = 33919;
         }
         else
         {
            _loc2_ = 33923;
         }
         LocalizationManager.translateIdAndInsert(_soldPopup.soldTxt,_loc2_,_soldAmount);
         DarkenManager.showLoadingSpiral(false);
         GuiManager.guiLayer.addChild(_soldPopup);
         DarkenManager.darken(_soldPopup);
      }
      
      private function addEventListeners() : void
      {
         _soldPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _soldPopup.okBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _soldPopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _soldPopup.okBtn.removeEventListener("mouseDown",onOkBtn);
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onCloseBtn(param1);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback(_passback);
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
   }
}

