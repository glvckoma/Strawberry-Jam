package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import inventory.Iitem;
   import loader.MediaHelper;
   
   public class ItemReceivedPopup
   {
      private const POPUP_MEDIA_ID:uint = 4820;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currItem:Iitem;
      
      private var _closeCallback:Function;
      
      private var _itemReceivedPopup:MovieClip;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _itemLayer:MovieClip;
      
      private var _okBtn:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _loadingSpiral:LoadingSpiral;
      
      public function ItemReceivedPopup(param1:Iitem, param2:DisplayObjectContainer, param3:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _currItem = param1;
         _closeCallback = param3;
         _guiLayer = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4820,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:Function = null;
         if(_closeCallback != null)
         {
            _loc1_ = _closeCallback;
            _closeCallback = null;
            _loc1_();
            return;
         }
         DarkenManager.unDarken(_itemReceivedPopup);
         _guiLayer.removeChild(_itemReceivedPopup);
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         _itemReceivedPopup = _itemLayer = _closeBtn = _okBtn = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _itemReceivedPopup = param1.getChildAt(0) as MovieClip;
         _itemLayer = _itemReceivedPopup.itemLayer;
         _closeBtn = _itemReceivedPopup.bx;
         _okBtn = _itemReceivedPopup.okBtn;
         _itemReceivedPopup.x = 900 * 0.5;
         _itemReceivedPopup.y = 550 * 0.5;
         _guiLayer.addChild(_itemReceivedPopup);
         DarkenManager.darken(_itemReceivedPopup);
         addEventListeners();
         setupItem();
      }
      
      private function setupItem() : void
      {
         if(!_currItem.isIconLoaded)
         {
            _currItem.imageLoadedCallback = onImageLoaded;
            _loadingSpiral = new LoadingSpiral(_itemLayer);
         }
         _itemLayer.addChild(_currItem.icon);
      }
      
      private function onImageLoaded() : void
      {
         _loadingSpiral.destroy();
         _loadingSpiral = null;
      }
      
      private function addEventListeners() : void
      {
         _itemReceivedPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _okBtn.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _itemReceivedPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onClose);
         _okBtn.removeEventListener("mouseDown",onClose);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
   }
}

