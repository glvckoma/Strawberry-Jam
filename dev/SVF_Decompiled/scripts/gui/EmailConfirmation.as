package gui
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import verification.VerificationXtCommManager;
   
   public class EmailConfirmation
   {
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallBack:Function;
      
      private var _emailConfirmPopup:MovieClip;
      
      private var _parentEmailPopup:MovieClip;
      
      private var _emailStsTracking:Object;
      
      private var _emailSts:MovieClip;
      
      private var _emailTxt:TextField;
      
      private var _lastCheckedEmail:String;
      
      private var _delaySuggestionTimer:Timer;
      
      private var _suggestedDomain:String;
      
      private var _displayCodeRedemptionString:Boolean;
      
      private var _messagePopup:MovieClip;
      
      public function EmailConfirmation()
      {
         super();
      }
      
      public function init(param1:Function, param2:MovieClip, param3:Boolean = false) : void
      {
         _closeCallBack = param1;
         _displayCodeRedemptionString = param3;
         if(param2 == null)
         {
            DarkenManager.showLoadingSpiral(true);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(4573,onPopupLoaded);
         }
         else
         {
            onPopupLoaded(param2);
         }
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_emailConfirmPopup);
         GuiManager.guiLayer.removeChild(_emailConfirmPopup);
         _emailConfirmPopup = null;
         _messagePopup = null;
         _parentEmailPopup = null;
         if(_closeCallBack != null)
         {
            _closeCallBack();
            _closeCallBack = null;
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
         }
         _emailConfirmPopup = MovieClip(param1.getChildAt(0));
         _emailConfirmPopup.x = 900 * 0.5;
         _emailConfirmPopup.y = 550 * 0.5;
         _messagePopup = _emailConfirmPopup.messagePopup;
         _parentEmailPopup = _emailConfirmPopup.parentEmailPopup;
         _parentEmailPopup.visible = false;
         if(_displayCodeRedemptionString)
         {
            LocalizationManager.translateId(_messagePopup.bodyTxt,24884);
         }
         _emailTxt = _parentEmailPopup.email_txt;
         _emailSts = _parentEmailPopup.email_status;
         _emailStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
         _parentEmailPopup.emailCheckPopup.visible = false;
         _parentEmailPopup.resendBtn.activateGrayState(true);
         _delaySuggestionTimer = new Timer(1000,1);
         LocalizationManager.translateId(_messagePopup.countTitleTxt,25145);
         _emailTxt.text = gMainFrame.clientInfo.pendingEmail;
         emailKeyUpHandler(null);
         if(gMainFrame.clientInfo.pendingEmail == null || gMainFrame.clientInfo.pendingEmail == "")
         {
            _parentEmailPopup.visible = _displayCodeRedemptionString ? false : true;
            gMainFrame.stage.focus = _emailTxt;
            _emailTxt.setSelection(_emailTxt.length,_emailTxt.length);
            (_parentEmailPopup.resendBtn as GuiSoundButton).setTextInLayer(LocalizationManager.translateIdOnly(33034),"txt");
            LocalizationManager.translateId(_parentEmailPopup.descTxt,_displayCodeRedemptionString ? 33060 : 33033);
            _messagePopup.visible = _displayCodeRedemptionString ? true : false;
         }
         else
         {
            _parentEmailPopup.visible = false;
            gMainFrame.stage.focus = _emailTxt;
            _emailTxt.setSelection(_emailTxt.length,_emailTxt.length);
            (_parentEmailPopup.resendBtn as GuiSoundButton).setTextInLayer(LocalizationManager.translateIdOnly(24698),"txt");
            LocalizationManager.translateId(_parentEmailPopup.descTxt,_displayCodeRedemptionString ? 33060 : 25148);
            _messagePopup.visible = true;
         }
         GuiManager.guiLayer.addChild(_emailConfirmPopup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_emailConfirmPopup);
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _emailConfirmPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _messagePopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _messagePopup.okBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _messagePopup.resendBtn.addEventListener("mouseDown",onResendBtn,false,0,true);
         _parentEmailPopup.resendBtn.addEventListener("mouseDown",onResendBtn,false,0,true);
         _parentEmailPopup.bx.addEventListener("mouseDown",onParentEmailClose,false,0,true);
         _emailTxt.addEventListener("keyUp",emailKeyUpHandler,false,0,true);
         _delaySuggestionTimer.addEventListener("timer",onSuggestionTimer,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _emailConfirmPopup.removeEventListener("mouseDown",onPopup);
         _messagePopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _messagePopup.okBtn.removeEventListener("mouseDown",onCloseBtn);
         _messagePopup.resendBtn.removeEventListener("mouseDown",onResendBtn);
         _parentEmailPopup.resendBtn.removeEventListener("mouseDown",onResendBtn);
         _parentEmailPopup.bx.removeEventListener("mouseDown",onParentEmailClose);
         _emailTxt.removeEventListener("keyUp",emailKeyUpHandler);
         _delaySuggestionTimer.removeEventListener("timer",onSuggestionTimer);
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
      
      private function onResendBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget == _messagePopup.resendBtn)
            {
               _parentEmailPopup.visible = true;
               gMainFrame.stage.focus = _emailTxt;
               _emailTxt.setSelection(_emailTxt.length,_emailTxt.length);
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               VerificationXtCommManager.requestSendEmailActivation(_emailTxt.text,onResendComplete);
            }
         }
      }
      
      private function onParentEmailClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _parentEmailPopup.visible = false;
         if(!_messagePopup.visible)
         {
            destroy();
         }
      }
      
      private function onSuggestionTimer(param1:TimerEvent) : void
      {
         if(_suggestedDomain != "")
         {
            _parentEmailPopup.emailCheckPopup.visible = true;
            LocalizationManager.translateIdAndInsert(_parentEmailPopup.emailCheckPopup.suggestTxt,11165,_suggestedDomain);
         }
      }
      
      private function emailKeyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc3_:* = false;
         var _loc2_:Object = null;
         if(_emailTxt.text == "")
         {
            GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
            _parentEmailPopup.textBar.visible = true;
            _lastCheckedEmail = _emailTxt.text;
            _parentEmailPopup.resendBtn.activateGrayState(true);
            return;
         }
         if(_emailTxt.text != _lastCheckedEmail)
         {
            _emailSts.visible = true;
            _lastCheckedEmail = _emailTxt.text;
            _suggestedDomain = "";
            _loc3_ = !SbiConstants.EMAIL_REGEX.test(_emailTxt.text);
            if(_loc3_)
            {
               GuiStatusIcon.showX(_emailSts,_emailStsTracking);
               _parentEmailPopup.textBar.visible = false;
               _parentEmailPopup.emailCheckPopup.visible = false;
               _parentEmailPopup.resendBtn.activateGrayState(true);
            }
            else
            {
               GuiStatusIcon.showCheck(_emailSts,_emailStsTracking);
               _parentEmailPopup.textBar.visible = true;
               _loc2_ = Utility.checkEmailDomain(_emailTxt.text);
               if(_loc2_.suggestions.length > 0)
               {
                  _suggestedDomain = _loc2_.suggestions[0];
                  _delaySuggestionTimer.reset();
                  _delaySuggestionTimer.start();
               }
               else
               {
                  _parentEmailPopup.emailCheckPopup.visible = false;
               }
               _parentEmailPopup.resendBtn.activateGrayState(false);
            }
         }
      }
      
      private function onResendComplete(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            gMainFrame.clientInfo.pendingEmail = _emailTxt.text;
            GuiManager.rebuildMainHud();
            destroy();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(22626));
         }
      }
   }
}

