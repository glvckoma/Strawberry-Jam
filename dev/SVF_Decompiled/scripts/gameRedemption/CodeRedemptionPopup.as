package gameRedemption
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class CodeRedemptionPopup
   {
      private const POPUP_MEDIA_ID:int = 4625;
      
      private const HELP_POPUP_MEDIA_ID:int = 4628;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _guiLayer:DisplayLayer;
      
      private var _redemptionPopup:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _continueBtn:MovieClip;
      
      private var _codeInput:TextField;
      
      private var _helpBtn:MovieClip;
      
      private var _helpPopup:MovieClip;
      
      private var _captchaPopup:CaptchaPopup;
      
      private var _chosenCaptchaAnswer:String;
      
      private var _captchaQuestion:String;
      
      public function CodeRedemptionPopup()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4625,onRedemptionPopupLoaded);
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
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_redemptionPopup)
         {
            removeEventListeners();
            DarkenManager.unDarken(_redemptionPopup);
            _guiLayer.removeChild(_redemptionPopup);
         }
         if(_helpPopup)
         {
            removeHelpPopupEventListeners();
            DarkenManager.unDarken(_helpPopup);
            _guiLayer.removeChild(_helpPopup);
            _helpPopup = null;
         }
         _guiLayer = null;
         _redemptionPopup = null;
      }
      
      private function loadHelpPopup() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4628,onHelpPopupLoaded);
      }
      
      private function onRedemptionPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _redemptionPopup = param1.getChildAt(0) as MovieClip;
         _redemptionPopup.x = 900 * 0.5;
         _redemptionPopup.y = 550 * 0.5;
         _guiLayer.addChild(_redemptionPopup);
         DarkenManager.darken(_redemptionPopup);
         _closeBtn = _redemptionPopup.bx;
         _continueBtn = _redemptionPopup.continueBtn;
         _codeInput = _redemptionPopup.codeTxt;
         _codeInput.restrict = "A-Za-z0-9\\-";
         _helpBtn = _redemptionPopup.helpBtn;
         if(gMainFrame.clientInfo.redemptionCode != undefined && gMainFrame.clientInfo.redemptionCode.length > 0)
         {
            _codeInput.text = gMainFrame.clientInfo.redemptionCode;
         }
         else
         {
            _continueBtn.activateGrayState(true);
         }
         gMainFrame.stage.focus = _codeInput;
         _codeInput.setSelection(_codeInput.text.length,_codeInput.text.length);
         addEventListeners();
      }
      
      private function onHelpPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _helpPopup = param1.getChildAt(0) as MovieClip;
         _helpPopup.x = 900 * 0.5;
         _helpPopup.y = 550 * 0.5;
         _guiLayer.addChild(_helpPopup);
         DarkenManager.unDarken(_redemptionPopup);
         DarkenManager.darken(_helpPopup);
         addHelpPopupEventListeners();
      }
      
      private function addEventListeners() : void
      {
         gMainFrame.stage.addEventListener("keyDown",onKeyDown,false,0,true);
         _redemptionPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _continueBtn.addEventListener("mouseDown",onContinueBtn,false,0,true);
         _codeInput.addEventListener("change",onCodeInputChange,false,0,true);
         _helpBtn.addEventListener("mouseDown",onHelpBtn,false,0,true);
      }
      
      private function addHelpPopupEventListeners() : void
      {
         _helpPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _helpPopup.bx.addEventListener("mouseDown",onHelpClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         gMainFrame.stage.removeEventListener("keyDown",onKeyDown);
         _redemptionPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
         _continueBtn.removeEventListener("mouseDown",onContinueBtn);
         _codeInput.removeEventListener("change",onCodeInputChange);
         _helpBtn.removeEventListener("mouseDown",onHelpBtn);
      }
      
      private function removeHelpPopupEventListeners() : void
      {
         _helpPopup.removeEventListener("mouseDown",onPopup);
         _helpPopup.bx.removeEventListener("mouseDown",onHelpClose);
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
      
      private function onContinueBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_continueBtn.isGray && _codeInput.length > 0)
         {
            if(GameRedemptionXtCommManager.captchaToShowData != null)
            {
               _captchaPopup = new CaptchaPopup();
               _captchaPopup.init(GameRedemptionXtCommManager.captchaToShowData.question,GameRedemptionXtCommManager.captchaToShowData.options,onCaptchaClose);
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               GameRedemptionXtCommManager.requestRedeemCode(_codeInput.text,_captchaQuestion,_chosenCaptchaAnswer,onCodeRedeemResponse);
            }
         }
      }
      
      private function onCodeInputChange(param1:Event) : void
      {
         if(_codeInput.length <= 0)
         {
            _continueBtn.activateGrayState(true);
         }
         else
         {
            _continueBtn.activateGrayState(false);
         }
      }
      
      private function onHelpBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_helpPopup)
         {
            _helpPopup.visible = true;
            DarkenManager.unDarken(_redemptionPopup);
            DarkenManager.darken(_helpPopup);
         }
         else
         {
            loadHelpPopup();
         }
      }
      
      private function onHelpClose(param1:MouseEvent) : void
      {
         _helpPopup.visible = false;
         DarkenManager.unDarken(_helpPopup);
         DarkenManager.darken(_redemptionPopup);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         param1.stopPropagation();
         if(param1.keyCode == 13)
         {
            onContinueBtn(null);
         }
      }
      
      private function onCodeRedeemResponse(param1:String, param2:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _captchaQuestion = "";
         _chosenCaptchaAnswer = "";
         switch(param1)
         {
            case "1":
               gMainFrame.clientInfo.redemptionCode = undefined;
               destroy();
               break;
            case "-3":
               GuiManager.initEmailConfirmation(null,null,true);
               break;
            case "-4":
            case "-5":
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(25352));
               break;
            case "-6":
               GameRedemptionXtCommManager.captchaToShowData = param2;
               onContinueBtn(null);
               break;
            case "-7":
               GameRedemptionXtCommManager.captchaToShowData = param2;
            default:
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(24878));
         }
      }
      
      private function onCaptchaClose(param1:Boolean, param2:String, param3:String) : void
      {
         _captchaPopup.destroy();
         _captchaPopup = null;
         if(param3 != null && param3 != "")
         {
            _captchaQuestion = param2;
            _chosenCaptchaAnswer = param3;
         }
         GameRedemptionXtCommManager.captchaToShowData = null;
      }
   }
}

