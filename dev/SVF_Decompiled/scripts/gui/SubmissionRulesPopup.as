package gui
{
   import currency.UserCurrency;
   import diamond.DiamondXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import loader.MediaHelper;
   
   public class SubmissionRulesPopup
   {
      private const POPUP_MEDIA_ID:uint = 4812;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _submissionRulesPopup:MovieClip;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _cancelBtn:MovieClip;
      
      private var _buyBtn:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _diamondCostText:TextField;
      
      private var _itemCost:int;
      
      private var _numMasterpieceTokens:int;
      
      private var _tokenPopup:MovieClip;
      
      private var _tokenPopupDiamondBtn:MovieClip;
      
      private var _tokenPopupTokenBtn:MovieClip;
      
      public function SubmissionRulesPopup(param1:int, param2:int, param3:DisplayObjectContainer, param4:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _itemCost = param1;
         _closeCallback = param4;
         _guiLayer = param3;
         _numMasterpieceTokens = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4812,onPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false, param2:Boolean = false) : void
      {
         var _loc3_:Function = null;
         if(_closeCallback != null)
         {
            _loc3_ = _closeCallback;
            _closeCallback = null;
            _loc3_(param1,param2);
            return;
         }
         DarkenManager.unDarken(_submissionRulesPopup);
         _guiLayer.removeChild(_submissionRulesPopup);
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         _submissionRulesPopup = _closeBtn = _cancelBtn = _buyBtn = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _submissionRulesPopup = param1.getChildAt(0) as MovieClip;
         _diamondCostText = _submissionRulesPopup.diamondTxt;
         _closeBtn = _submissionRulesPopup.bx;
         _cancelBtn = _submissionRulesPopup.cancelBtn;
         _buyBtn = _submissionRulesPopup.buyBtn;
         _tokenPopup = _submissionRulesPopup.tokenCont;
         _tokenPopupDiamondBtn = _tokenPopup.diamondBtn;
         _tokenPopupTokenBtn = _tokenPopup.tokenBtn;
         _tokenPopup.visible = false;
         var _loc2_:Object = DiamondXtCommManager.getDiamondDef(221);
         _tokenPopupDiamondBtn.activateGrayState(!UserCurrency.hasEnoughCurrency(3,_loc2_.value));
         _diamondCostText.text = "x " + _itemCost;
         _submissionRulesPopup.x = 900 * 0.5;
         _submissionRulesPopup.y = 550 * 0.5;
         _guiLayer.addChild(_submissionRulesPopup);
         DarkenManager.darken(_submissionRulesPopup);
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _submissionRulesPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _cancelBtn.addEventListener("mouseDown",onBuyCancel,false,0,true);
         _buyBtn.addEventListener("mouseDown",onBuyCancel,false,0,true);
         _tokenPopupDiamondBtn.addEventListener("mouseDown",onTokenDiamondBtn,false,0,true);
         _tokenPopupTokenBtn.addEventListener("mouseDown",onTokenBuyBtn,false,0,true);
         _tokenPopup.bx.addEventListener("mouseDown",onClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _submissionRulesPopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onClose);
         _cancelBtn.removeEventListener("mouseDown",onBuyCancel);
         _buyBtn.removeEventListener("mouseDown",onBuyCancel);
         _tokenPopupDiamondBtn.removeEventListener("mouseDown",onTokenDiamondBtn);
         _tokenPopupTokenBtn.removeEventListener("mouseDown",onTokenBuyBtn);
         _tokenPopup.bx.removeEventListener("mouseDown",onClose);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy(false);
      }
      
      private function onBuyCancel(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _cancelBtn)
         {
            destroy(false);
         }
         else if(param1.currentTarget == _buyBtn)
         {
            if(_numMasterpieceTokens > 0)
            {
               _tokenPopup.visible = true;
            }
            else
            {
               destroy(true,false);
            }
         }
      }
      
      private function onTokenDiamondBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup("denArt","den_art");
            }
            else
            {
               destroy(true,false);
            }
         }
      }
      
      private function onTokenBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy(true,true);
      }
   }
}

