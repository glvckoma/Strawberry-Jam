package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowChapterSelect;
   import loader.MediaHelper;
   
   public class WelcomeToCarnival
   {
      public static const WELCOME_CARNIVAL_MEDIA_ID:int = 1594;
      
      private var _popup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      public function WelcomeToCarnival()
      {
         super();
         ItemWindowChapterSelect;
      }
      
      public function init() : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1594,mediaCallback,true);
      }
      
      public function destroy() : void
      {
         removeListeners();
         _mediaHelper.destroy();
         GuiManager.guiLayer.removeChild(_popup);
         DarkenManager.unDarken(_popup);
         _popup = null;
      }
      
      private function mediaCallback(param1:MovieClip) : void
      {
         _popup = MovieClip(param1.getChildAt(0));
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         GuiManager.guiLayer.addChild(_popup);
         addListeners();
         setInitialConditions();
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_popup);
      }
      
      private function setInitialConditions() : void
      {
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addListeners() : void
      {
         _popup["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _popup["bx"].removeEventListener("mouseDown",popupCloseHandler);
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
      }
   }
}

