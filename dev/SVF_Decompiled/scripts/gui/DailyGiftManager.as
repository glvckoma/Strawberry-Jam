package gui
{
   import Enums.DenItemDef;
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import giftPopup.GiftPopup;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DailyGiftManager
   {
      public static const GIFTS_RECEIVED_UV:int = 458;
      
      private var _giftingPopupMediaHelper:MediaHelper;
      
      private var _giftingPopupContent:MovieClip;
      
      private var _giftPopup:GiftPopup;
      
      private var _giftIndex:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _randColorIndex:int;
      
      private var _gemAmount:int;
      
      private var _diamondAmount:int;
      
      private var _closeCallback:Function;
      
      private var _giftDataToStillBeDisplayed:Object;
      
      private var _additionalDiamond:Array;
      
      public function DailyGiftManager()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param2;
         _giftIndex = param1;
         var _loc3_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(458));
         var _loc5_:String = _loc3_.toString(2);
         var _loc6_:String = _loc5_.substr(0,_loc5_.length - 32);
         var _loc4_:int = parseInt(_loc6_,2);
         if(_loc4_ != new Date().fullYear)
         {
            AchievementXtCommManager.requestSetUserVar(458,666,onGiftsReceivedUpdated);
         }
         else
         {
            _giftingPopupMediaHelper = new MediaHelper();
            _giftingPopupMediaHelper.init(2539,giftingPopupCallback);
         }
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _giftDataToStillBeDisplayed = null;
         if(_giftingPopupContent)
         {
            DarkenManager.unDarken(_giftingPopupContent);
            _guiLayer.removeChild(_giftingPopupContent);
            _giftingPopupContent.visible = false;
            _giftingPopupContent = null;
            _giftingPopupMediaHelper = null;
         }
      }
      
      private function onGiftsReceivedUpdated(param1:int, param2:int) : void
      {
         _giftingPopupMediaHelper = new MediaHelper();
         _giftingPopupMediaHelper.init(2539,giftingPopupCallback);
      }
      
      private function giftingPopupCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _giftingPopupContent = MovieClip(param1.getChildAt(0));
            _giftingPopupContent.x = 900 * 0.5;
            _giftingPopupContent.y = 550 * 0.5;
            _additionalDiamond = [true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,false,false,true,true,true];
            setupPopup();
            addEventListeners();
            _guiLayer.addChild(_giftingPopupContent);
            DarkenManager.darken(_giftingPopupContent);
         }
      }
      
      private function setupPopup() : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc1_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(458));
         _loc2_ = 1;
         for(; _loc2_ <= 31; _loc2_++)
         {
            _loc3_ = _giftingPopupContent["gift" + _loc2_];
            if(_loc2_ < _giftIndex + 1)
            {
               if(_loc1_ != -1 && (_loc1_ & 1 << _loc2_ - 1) > 0)
               {
                  _loc3_.gotoAndStop("opened");
               }
               else
               {
                  _loc3_.gotoAndStop("missed");
                  _loc3_.missedGift.diamond.visible = _additionalDiamond[_loc2_ - 1];
               }
            }
            else
            {
               if(_loc2_ > _giftIndex + 1)
               {
                  _loc3_.gotoAndStop("unopened");
                  _loc3_.unopenedGift.highlight.visible = false;
                  _loc3_.unopenedGift.openTag.visible = false;
                  _loc3_.unopenedGift.currIndex = _loc2_;
                  _loc3_.unopenedGift.shine.visible = false;
                  _loc3_.unopenedGift.gift.addEventListener("mouseDown",onFutureGiftDown,false,0,true);
                  _loc3_.unopenedGift.diamond.addEventListener("mouseDown",onFutureGiftDown,false,0,true);
               }
               else if(_loc2_ == _giftIndex + 1)
               {
                  if(_loc1_ != -1 && (_loc1_ & 1 << _loc2_ - 1) > 0)
                  {
                     _loc3_.gotoAndStop("opened");
                     continue;
                  }
                  _loc3_.gotoAndStop("unopened");
                  _loc3_.unopenedGift.openTag.visible = true;
                  _loc3_.unopenedGift.highlight.visible = false;
                  _loc3_.unopenedGift.highlight.mouseChildren = false;
                  _loc3_.unopenedGift.highlight.mouseEnabled = false;
                  _loc3_.unopenedGift.shine.mouseChildren = false;
                  _loc3_.unopenedGift.shine.mouseEnabled = false;
                  _loc3_.unopenedGift.gift.addEventListener("mouseDown",onGiftDown,false,0,true);
                  _loc3_.unopenedGift.gift.addEventListener("rollOver",onGiftOver,false,0,true);
                  _loc3_.unopenedGift.gift.addEventListener("rollOut",onGiftOut,false,0,true);
                  _loc3_.unopenedGift.diamond.addEventListener("mouseDown",onGiftDown,false,0,true);
               }
               if(!gMainFrame.userInfo.isMember)
               {
                  _loc3_.unopenedGift.diamond.gotoAndStop("nonMember");
               }
               _loc3_.unopenedGift.diamond.visible = _additionalDiamond[_loc2_ - 1];
            }
         }
      }
      
      public function setupGiftPopup() : void
      {
         var _loc7_:Object = null;
         var _loc2_:Object = null;
         var _loc8_:int = 0;
         var _loc6_:Array = [0,1,0,1,1,0,1,0,0,1,0,1,1,0,1,1,1,0,0,1,1,0,0,1,0,1,1,0,1,0,1];
         var _loc4_:Array = [1057,2439,691,1806,2453,525,2452,853,854,2456,1311,2436,1825,1313,3955,1165,2913,2291,2292,2947,1808,2163,1955,2915,249,2869,1832,852,1833,526,2458];
         var _loc5_:int = int(gMainFrame.clientInfo.dailyGiftIndex);
         if(_loc5_ <= _loc6_.length)
         {
            if(_loc6_[_giftIndex] == 0)
            {
               _loc2_ = ItemXtCommManager.getItemDef(_loc4_[_loc5_]);
               _randColorIndex = _loc2_.colors.length * Math.random();
               _loc7_ = new Item();
               _loc7_.init(_loc2_.defId,0,_loc2_.colors[_randColorIndex],null,true);
               _loc8_ = 1;
            }
            else if(_loc6_[_giftIndex] == 1)
            {
               _loc2_ = DenXtCommManager.getDenItemDef(_loc4_[_loc5_]);
               _loc7_ = new DenItem();
               _loc7_.initShopItem(DenItemDef(_loc2_).id,0);
               _loc8_ = 2;
            }
            else if(_loc6_[_giftIndex] == 2)
            {
               _loc8_ = 0;
            }
            else if(_loc6_[_giftIndex] == 3)
            {
               _loc8_ = 8;
            }
            if(_additionalDiamond[_giftIndex])
            {
               _diamondAmount = 1;
               _giftingPopupMediaHelper = new MediaHelper();
               _giftingPopupMediaHelper.init(2221,onDiamondIconLoaded);
               _giftDataToStillBeDisplayed = {
                  "currItem":_loc7_,
                  "defIdOrAmount":_loc4_[_loc5_],
                  "giftType":_loc8_
               };
            }
            else
            {
               checkAndInitializeGiftPopup(_loc8_,_loc7_,_loc4_[_loc5_]);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function checkAndInitializeGiftPopup(param1:int, param2:Object, param3:int) : void
      {
         if(param1 == 0)
         {
            _gemAmount = param3;
            _giftingPopupMediaHelper = new MediaHelper();
            _giftingPopupMediaHelper.init(1086,onGemIconLoaded);
         }
         else if(param1 == 8)
         {
            _diamondAmount = param3;
            _giftingPopupMediaHelper = new MediaHelper();
            _giftingPopupMediaHelper.init(2221,onDiamondIconLoaded);
         }
         else
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param2.largeIcon,param2.name,param3,4,param1,keepGiftCallback,rejectGiftCallback);
         }
      }
      
      private function onGemIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(_gemAmount == 1 ? 11114 : 11097,_gemAmount),_gemAmount,4,0,null,keepGiftCallback,null,false,1);
         }
      }
      
      private function onDiamondIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(_diamondAmount == 1 ? 11116 : 11103,_diamondAmount),_diamondAmount,4,8,null,keepDiamondGiftCallback,null,false,1);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/close");
         close();
      }
      
      private function keepDiamondGiftCallback() : void
      {
         if(_giftDataToStillBeDisplayed != null)
         {
            _giftPopup.destroy();
            checkAndInitializeGiftPopup(_giftDataToStillBeDisplayed.giftType,_giftDataToStillBeDisplayed.currItem,_giftDataToStillBeDisplayed.defIdOrAmount);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(214,_randColorIndex,setVarCallback);
         }
      }
      
      private function keepGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _giftingPopupContent.visible = false;
         AchievementXtCommManager.requestSetUserVar(214,_randColorIndex,setVarCallback);
      }
      
      private function rejectGiftCallback() : void
      {
         if(_giftDataToStillBeDisplayed)
         {
            DarkenManager.showLoadingSpiral(true);
            _giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(214,666,setVarCallback);
         }
         else
         {
            close();
         }
      }
      
      private function setVarCallback(param1:int, param2:int) : void
      {
         if(_gemAmount > 0)
         {
            UserCurrency.setCurrency(UserCurrency.getCurrency(0) + _gemAmount,0);
         }
         if(_diamondAmount > 0)
         {
            UserCurrency.setCurrency(UserCurrency.getCurrency(3) + _diamondAmount,3);
         }
         DarkenManager.showLoadingSpiral(false);
         close();
      }
      
      private function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/" + param1.currentTarget.name);
         setupGiftPopup();
      }
      
      private function onFutureGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget.parent.currIndex - (_giftIndex + 1);
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc2_ == 1 ? 11383 : 11384,_loc2_));
      }
      
      private function onGiftOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.highlight.visible = true;
      }
      
      private function onGiftOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.highlight.visible = false;
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         _giftingPopupContent.bx.addEventListener("mouseDown",onClose,false,0,true);
         _giftingPopupContent.addEventListener("mouseDown",onPopupDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         _giftingPopupContent.bx.removeEventListener("mouseDown",onClose);
         _giftingPopupContent.removeEventListener("mouseDown",onPopupDown);
         _loc1_ = _giftIndex + 1;
         while(_loc1_ <= 25)
         {
            _loc2_ = _giftingPopupContent["gift" + _loc1_];
            if(_loc2_.unopenedGift)
            {
               _loc2_.unopenedGift.gift.removeEventListener("mouseDown",onGiftDown);
               _loc2_.unopenedGift.gift.removeEventListener("rollOver",onGiftOver);
               _loc2_.unopenedGift.gift.removeEventListener("rollOut",onGiftOut);
               _loc2_.unopenedGift.gift.removeEventListener("mouseDown",onFutureGiftDown);
               _loc2_.unopenedGift.diamond.removeEventListener("mouseDown",onFutureGiftDown);
            }
            _loc1_++;
         }
      }
   }
}

