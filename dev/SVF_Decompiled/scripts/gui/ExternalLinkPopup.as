package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ExternalLinkPopup
   {
      private const POPUP_MEDIA_ID:int = 6911;
      
      private var _guiLayer:DisplayLayer;
      
      private var _urlString:String;
      
      private var _callback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _urlToolTip:ToolTipPopup;
      
      public function ExternalLinkPopup(param1:String, param2:Function)
      {
         super();
         _guiLayer = GuiManager.guiLayer;
         _urlString = param1;
         _callback = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(6911,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         _callback = null;
         removeEventListeners();
         DarkenManager.unDarken(_popup);
         _guiLayer.removeChild(_popup);
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         _popup = MovieClip(param1.getChildAt(0));
         _mediaHelper.destroy();
         _mediaHelper = null;
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _urlToolTip = ToolTipPopup(GETDEFINITIONBYNAME("Tooltip"));
         var _loc2_:String = _urlString;
         if(_urlString.length > 100)
         {
            _loc2_ = _loc2_.substr(0,100) + "...";
         }
         _urlToolTip.init(_popup,_loc2_,0,-13);
         LocalizationManager.updateToFit(_popup.urlTxtCont.urlTxt,_urlString,false,false,true,true);
         addEventListeners();
         _guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.yesBtn.addEventListener("mouseDown",onYesNoBtn,false,0,true);
         _popup.noBtn.addEventListener("mouseDown",onYesNoBtn,false,0,true);
         _popup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _popup.urlTxtCont.addEventListener("mouseOver",onUrlOverOut,false,0,true);
         _popup.urlTxtCont.addEventListener("mouseOut",onUrlOverOut,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.yesBtn.removeEventListener("mouseDown",onYesNoBtn);
         _popup.noBtn.removeEventListener("mouseDown",onYesNoBtn);
         _popup.bx.removeEventListener("mouseDown",onCloseBtn);
         _popup.urlTxtCont.removeEventListener("mouseOver",onUrlOverOut);
         _popup.urlTxtCont.removeEventListener("mouseOut",onUrlOverOut);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onYesNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _popup.yesBtn)
         {
            _callback(true,_urlString);
         }
         else
         {
            _callback(false,_urlString);
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _callback(false,_urlString);
      }
      
      private function onUrlOverOut(param1:MouseEvent) : void
      {
         if(param1.type == "mouseOver")
         {
            _urlToolTip.startTimer(param1);
         }
         else
         {
            _urlToolTip.resetTimerAndSetVisibility();
         }
      }
   }
}

