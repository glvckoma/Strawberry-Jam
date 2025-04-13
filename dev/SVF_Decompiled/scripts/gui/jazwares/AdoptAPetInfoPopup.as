package gui.jazwares
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   
   public class AdoptAPetInfoPopup
   {
      private const INFO_MEDIA_ID:int = 4621;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _guiLayer:DisplayLayer;
      
      private var _infoPopup:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      public function AdoptAPetInfoPopup()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4621,onInfoMediaLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:Function = null;
         if(_closeCallback != null)
         {
            _loc1_ = _closeCallback;
            _closeCallback = null;
            _loc1_();
            _loc1_ = null;
            return;
         }
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         DarkenManager.unDarken(_infoPopup);
         _guiLayer.removeChild(_infoPopup);
         _guiLayer = null;
         _infoPopup = null;
      }
      
      private function onInfoMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _infoPopup = param1.getChildAt(0) as MovieClip;
         _infoPopup.x = 900 * 0.5;
         _infoPopup.y = 550 * 0.5;
         _guiLayer.addChild(_infoPopup);
         DarkenManager.darken(_infoPopup);
         _closeBtn = _infoPopup.bx;
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _infoPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _infoPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
   }
}

