package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.itemWindows.ItemWindowOriginalImages;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class BulkItemAcceptPopup
   {
      private const POPUP_MEDIA_ID:int = 4936;
      
      private var _bulkAcceptPopup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _itemBlockLoadingSpiral:LoadingSpiral;
      
      private var _itemWindow:WindowAndScrollbarGenerator;
      
      private var _displayData:Object;
      
      private var _itemBlock:MovieClip;
      
      private var _countText:TextField;
      
      private var _keepBtn:MovieClip;
      
      private var _numItemsToLoad:int;
      
      public function BulkItemAcceptPopup()
      {
         super();
      }
      
      public function init(param1:Object, param2:int, param3:Function) : void
      {
         _displayData = param1;
         _numItemsToLoad = param2;
         _closeCallback = param3;
         _guiLayer = GuiManager.guiLayer;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4936,onPopupLoaded);
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
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_itemBlockLoadingSpiral)
         {
            _itemBlockLoadingSpiral.destroy();
            _itemBlockLoadingSpiral = null;
         }
         _keepBtn.removeEventListener("mouseDown",onKeepBtn);
         DarkenManager.unDarken(_bulkAcceptPopup);
         _guiLayer.removeChild(_bulkAcceptPopup);
      }
      
      public function updateAndInsertLatest(param1:Object) : void
      {
         _displayData = param1;
         if(_bulkAcceptPopup)
         {
            if(_itemWindow)
            {
               _itemWindow.findOpenWindowAndUpdate(param1);
               LocalizationManager.translateIdAndInsert(_countText,23695,_displayData.images.length);
            }
            else
            {
               setupItemWindows();
            }
         }
      }
      
      public function showGrayStateOnKeepBtn(param1:Boolean) : void
      {
         if(_keepBtn)
         {
            _keepBtn.activateGrayState(param1);
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _bulkAcceptPopup = param1.getChildAt(0) as MovieClip;
         _itemBlock = _bulkAcceptPopup.itemBlock;
         _countText = _bulkAcceptPopup.txtCounter_ba.counterTxt;
         _keepBtn = _bulkAcceptPopup.keepBtn;
         _keepBtn.addEventListener("mouseDown",onKeepBtn,false,0,true);
         _bulkAcceptPopup.x = 900 * 0.5;
         _bulkAcceptPopup.y = 550 * 0.5;
         _itemBlockLoadingSpiral = new LoadingSpiral(_itemBlock,_itemBlock.width * 0.5,_itemBlock.height * 0.5);
         if(_displayData)
         {
            showGrayStateOnKeepBtn(_displayData.images.length != _numItemsToLoad);
            LocalizationManager.translateIdAndInsert(_countText,23695,_displayData.images.length);
            setupItemWindows();
         }
         else
         {
            showGrayStateOnKeepBtn(false);
         }
         _guiLayer.addChild(_bulkAcceptPopup);
         DarkenManager.darken(_bulkAcceptPopup);
      }
      
      private function setupItemWindows() : void
      {
         _itemWindow = new WindowAndScrollbarGenerator();
         _itemWindow.init(_itemBlock.width,_itemBlock.height,0,0,2,2,_numItemsToLoad,2,2,2,2,ItemWindowOriginalImages,_displayData.images,"",0,null,_displayData,onWindowsLoaded,true,false,false);
         _itemBlock.addChild(_itemWindow);
      }
      
      private function onWindowsLoaded() : void
      {
         if(_itemBlockLoadingSpiral)
         {
            _itemBlockLoadingSpiral.destroy();
            _itemBlockLoadingSpiral = null;
         }
      }
      
      private function onKeepBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            destroy();
         }
      }
   }
}

