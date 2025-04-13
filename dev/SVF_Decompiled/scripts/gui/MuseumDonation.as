package gui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MuseumDonation
   {
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _myGemCount:int;
      
      private var _donationAmounts:Array;
      
      private var _donationIndex:int;
      
      private var _radioBtn1:MovieClip;
      
      private var _radioBtn2:MovieClip;
      
      private var _radioBtn3:MovieClip;
      
      private var _lastChosenString:String;
      
      public function MuseumDonation()
      {
         super();
      }
      
      public function init(param1:Function) : void
      {
         _guiLayer = GuiManager.guiLayer;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1546,onMediaLoaded);
         _closeCallback = param1;
         _donationAmounts = [10,25,50,100,250,500,1000,2500,5000];
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         _closeCallback = null;
         DarkenManager.unDarken(_popup);
         _guiLayer.removeChild(_popup);
         _popup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _popup = MovieClip(param1.getChildAt(0));
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            _myGemCount = UserCurrency.getCurrency(0);
            _popup.donateRedBtn.visible = false;
            _radioBtn1 = _popup.radioBtn1;
            _radioBtn2 = _popup.radioBtn2;
            _radioBtn3 = _popup.radioBtn3;
            _popup.donateBtn.activateGrayState(true);
            _radioBtn1._circle.visible = false;
            _radioBtn2._circle.visible = false;
            _radioBtn3._circle.visible = false;
            addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            _guiLayer.addChild(_popup);
            DarkenManager.darken(_popup);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onUpBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(_popup.donationAmountTxt.text);
         if(_donationIndex < _donationAmounts.length - 1)
         {
            _donationIndex++;
            _loc2_ = int(_donationAmounts[_donationIndex]);
         }
         if(_loc2_ > _myGemCount)
         {
            _popup.donateRedBtn.visible = true;
         }
         else
         {
            _popup.donateRedBtn.visible = false;
         }
         _popup.donationAmountTxt.text = _loc2_;
      }
      
      private function onDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(_popup.donationAmountTxt.text);
         if(_donationIndex > 0)
         {
            _donationIndex--;
            _loc2_ = int(_donationAmounts[_donationIndex]);
         }
         if(_loc2_ > _myGemCount)
         {
            _popup.donateRedBtn.visible = true;
         }
         else
         {
            _popup.donateRedBtn.visible = false;
         }
         _popup.donationAmountTxt.text = _loc2_;
      }
      
      private function onDonateBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_myGemCount < _popup.donationAmountTxt.text)
            {
               SBTracker.trackPageview("/game/play/popup/donate/donation/notEnoughGems/#" + _myGemCount,-1,1);
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14770));
            }
            else
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14771,Utility.convertNumberToString(_popup.donationAmountTxt.text)),true,onConfirm);
            }
         }
      }
      
      private function onConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            ItemXtCommManager.requestDonateGems(_popup.donationAmountTxt.text,onDonateDone);
            FeedbackManager.setupRequest(new UserImageUpload(),_lastChosenString + "|" + _popup.donationAmountTxt.text,12,0,onSuccess,onError);
         }
      }
      
      private function onError(param1:Event) : void
      {
      }
      
      private function onSuccess(param1:Event) : void
      {
      }
      
      private function onDonateDone(param1:Boolean) : void
      {
         if(param1)
         {
            _popup.visible = false;
            SBTracker.trackPageview("/game/play/popup/donate/donation/#" + _popup.donationAmountTxt.text);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14772),true,onDonationThanks);
         }
         else
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14773));
         }
      }
      
      private function onDonationThanks(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onClose(null);
      }
      
      private function onRadioBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _radioBtn1._circle.visible = false;
         _radioBtn2._circle.visible = false;
         _radioBtn3._circle.visible = false;
         var _loc2_:Object = param1.currentTarget;
         _loc2_._circle.visible = !_loc2_._circle.visible;
         if(_loc2_._circle.visible)
         {
            _lastChosenString = _popup["selectionLabelTxt" + _loc2_.name.substr(8)].text;
         }
         if(_popup.donateBtn.isGray)
         {
            _popup.donateBtn.activateGrayState(false);
         }
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _popup.upBtn.addEventListener("mouseDown",onUpBtn,false,0,true);
         _popup.downBtn.addEventListener("mouseDown",onDownBtn,false,0,true);
         _popup.donateBtn.addEventListener("mouseDown",onDonateBtn,false,0,true);
         _popup.donateRedBtn.addEventListener("mouseDown",onDonateBtn,false,0,true);
         _popup.radioBtn1.addEventListener("mouseDown",onRadioBtn,false,0,true);
         _popup.radioBtn2.addEventListener("mouseDown",onRadioBtn,false,0,true);
         _popup.radioBtn3.addEventListener("mouseDown",onRadioBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.bx.removeEventListener("mouseDown",onClose);
         _popup.upBtn.removeEventListener("mouseDown",onUpBtn);
         _popup.downBtn.removeEventListener("mouseDown",onDownBtn);
         _popup.donateBtn.removeEventListener("mouseDown",onDonateBtn);
         _popup.donateRedBtn.removeEventListener("mouseDown",onDonateBtn);
         _popup.radioBtn1.removeEventListener("mouseDown",onRadioBtn);
         _popup.radioBtn2.removeEventListener("mouseDown",onRadioBtn);
         _popup.radioBtn3.removeEventListener("mouseDown",onRadioBtn);
      }
   }
}

