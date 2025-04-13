package buddy
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class HowDidYouHear
   {
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _hasClearedNameTxt:Boolean;
      
      private var _originalNameTxt:String;
      
      public function HowDidYouHear(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5303,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_popup);
         GuiManager.guiLayer.removeChild(_popup);
         _closeCallback = null;
         _popup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         _popup = MovieClip(param1.getChildAt(0));
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _mediaHelper.destroy();
         _mediaHelper = null;
         _popup.nameTxt.restrict = Utility.getUsernameRestrictions();
         _popup.nameTxt.maxChars = 20;
         _popup.nameTxt.alpha = 0.5;
         _originalNameTxt = _popup.nameTxt.text;
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         GuiManager.guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.submitBtn.addEventListener("mouseDown",onSubmitBtn,false,0,true);
         _popup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _popup.nameTxt.addEventListener("mouseDown",onNameTxt,false,0,true);
         _popup.nameTxt.addEventListener("change",onNameTxtChange,false,0,true);
         _popup.nameTxt.addEventListener("keyDown",keyDownListener,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.submitBtn.removeEventListener("mouseDown",onSubmitBtn);
         _popup.bx.removeEventListener("mouseDown",onCloseBtn);
         _popup.nameTxt.removeEventListener("mouseDown",onNameTxt);
         _popup.nameTxt.removeEventListener("change",onNameTxtChange);
         _popup.nameTxt.removeEventListener("keyDown",keyDownListener);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onSubmitBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_popup.nameTxt.text.toLowerCase() != _originalNameTxt.toLowerCase() && _popup.nameTxt.text.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase() && _popup.nameTxt.text.length >= 2 && Boolean(SbiConstants.USERNAME_REGEX.test(_popup.nameTxt.text)))
         {
            DarkenManager.showLoadingSpiral(true);
            ReferAFriendXtCommManager.sendReferralAssociation(onReferralAssociationComplete,_popup.nameTxt.text);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(32539));
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback(false);
            _closeCallback = null;
         }
      }
      
      private function onNameTxt(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _popup.nameTxt.alpha = 1;
         if(!_hasClearedNameTxt)
         {
            _popup.nameTxt.text = "";
            _hasClearedNameTxt = true;
         }
      }
      
      private function onNameTxtChange(param1:Event) : void
      {
         if(_popup.nameTxt.text.length == 0 && _hasClearedNameTxt)
         {
            _hasClearedNameTxt = false;
            _popup.nameTxt.text = _originalNameTxt;
            _popup.nameTxt.alpha = 0.5;
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(!_hasClearedNameTxt && param1.keyCode != 8 && param1.keyCode != 46)
         {
            _popup.nameTxt.text = "";
            _hasClearedNameTxt = true;
            _popup.nameTxt.alpha = 1;
         }
      }
      
      private function onReferralAssociationComplete(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1 == 1)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(32508),true,onReferralAssociationCompleteOk);
         }
         else if(param1 == -1)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(32507));
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(22626));
         }
      }
      
      private function onReferralAssociationCompleteOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         if(_closeCallback != null)
         {
            _closeCallback(true);
            _closeCallback = null;
         }
      }
   }
}

