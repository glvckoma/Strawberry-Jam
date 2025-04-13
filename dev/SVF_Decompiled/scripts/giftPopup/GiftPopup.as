package giftPopup
{
   import Enums.DenItemDef;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.DenRoomItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import gui.GuiSoundToggleButton;
   import gui.RecycleItems;
   import gui.UpsellManager;
   import inventory.Iitem;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import shop.ShopManager;
   
   public class GiftPopup
   {
      public static const POPUP_TYPE_JAG:int = 0;
      
      public static const POPUP_TYPE_PROMO:int = 1;
      
      public static const POPUP_TYPE_PRIZE:int = 2;
      
      public static const POPUP_TYPE_JB:int = 3;
      
      public static const POPUP_TYPE_JAMAALIDAY_GIFT:int = 4;
      
      public static const POPUP_TYPE_TOUCH_POOL:int = 5;
      
      public static const POPUP_TYPE_HQ:int = 6;
      
      public static const POPUP_TYPE_TREASURE:int = 7;
      
      public static const POPUP_TYPE_ADVENTURES:int = 8;
      
      public static const POPUP_TYPE_TREASURE_RED:int = 9;
      
      public static const POPUP_TYPE_TREASURE_BLUE:int = 10;
      
      public static const POPUP_TYPE_TREASURE_ORANGE:int = 11;
      
      public static const POPUP_TYPE_TREASURE_GREEN:int = 12;
      
      public static const POPUP_TYPE_TREASURE_BAG:int = 13;
      
      public static const POPUP_TYPE_ADVENTURES_ALT:int = 14;
      
      public static const POPUP_TYPE_ADVENTURES_LUCKY:int = 15;
      
      public static const POPUP_TYPE_ADVENTURES_EASTER:int = 16;
      
      public static const POPUP_TYPE_ADVENTURES_BITTERSWEETS:int = 17;
      
      public static const POPUP_TYPE_ADVENTURES_LUCKY2:int = 18;
      
      public static const POPUP_TYPE_ADVENTURES_HOTCOLD1:int = 19;
      
      public static const POPUP_TYPE_PROMO_WITH_COLOR:int = 20;
      
      public static const GIFT_TYPE_GEMS:int = 0;
      
      public static const GIFT_TYPE_CLOTHING:int = 1;
      
      public static const GIFT_TYPE_DEN_ACC:int = 2;
      
      public static const GIFT_TYPE_DEN_ROOM:int = 3;
      
      public static const GIFT_TYPE_AVT:int = 4;
      
      public static const GIFT_TYPE_DEN_AUDIO:int = 5;
      
      public static const GIFT_TYPE_PET:int = 6;
      
      public static const GIFT_TYPE_CRYSTALS:int = 7;
      
      public static const GIFT_TYPE_DIAMOND:int = 8;
      
      public static const GIFT_TYPE_CUSTOM_AVT:int = 9;
      
      public static const BUTTONS_TYPE_KEEP_DISCARD:int = 0;
      
      public static const BUTTONS_TYPE_OK:int = 1;
      
      public static const BUTTONS_TYPE_CREATE:int = 2;
      
      public static const BUTTONS_TYPE_TAKE_LEAVE:int = 3;
      
      public static const BUTTON_TYPE_REDEEM:int = 4;
      
      public static const GIFT_POPUP_TYPE_NORMAL:int = 0;
      
      public static const GIFT_POPUP_TYPE_REFER:int = 1;
      
      private const GIFT_POPUP_ID:int = 1084;
      
      protected var _guiLayer:DisplayObjectContainer;
      
      protected var _item:Iitem;
      
      protected var _icon:Sprite;
      
      protected var _name:String;
      
      protected var _popupType:int;
      
      protected var _giftType:int;
      
      protected var _enviroType:int;
      
      protected var _denyForNonMem:Boolean;
      
      protected var _buttonsType:int;
      
      protected var _onCloseMsg:String;
      
      protected var _msgText:String;
      
      protected var _keepCallback:Function;
      
      protected var _rejectCallback:Function;
      
      protected var _closeCallback:Function;
      
      protected var _loadingMediaHelper:MediaHelper;
      
      protected var _popupContent:MovieClip;
      
      protected var _closeMsgOkPopup:SBOkPopup;
      
      protected var _recyclePopup:RecycleItems;
      
      protected var _giftDataArray:Array;
      
      protected var _isFromStartup:Boolean;
      
      protected var _popupActive:Boolean;
      
      protected var _giftDefIdOrAmount:String;
      
      protected var _itemColorIndex:int;
      
      public function GiftPopup()
      {
         super();
      }
      
      public static function giftTypeForECardType(param1:int) : int
      {
         if(param1 == 4)
         {
            return 0;
         }
         if(param1 == 1)
         {
            return 1;
         }
         if(param1 == 3)
         {
            return 2;
         }
         if(param1 == 5)
         {
            return 3;
         }
         if(param1 == 6)
         {
            return 4;
         }
         if(param1 == 99)
         {
            return 5;
         }
         if(param1 == 8)
         {
            return 6;
         }
         if(param1 == 9)
         {
            return 8;
         }
         if(param1 == 10)
         {
            return 9;
         }
         return -1;
      }
      
      public static function buttonsTypeForECardType(param1:int, param2:int = 0, param3:int = 0) : int
      {
         if(param1 == 8)
         {
            return 2;
         }
         if(param1 == 4 || param1 == 6 || param1 == 9 || param1 == 10 || param1 == 7 || param1 == 13)
         {
            return 1;
         }
         if(param1 == 3 && param2 == DenItemDef.PROMO_TYPE_MCD && Utility.validateDenInventorySpace(ShopManager.maxDenItems,gMainFrame.userInfo.playerUserInfo.denItemsFull,param3).allow)
         {
            return 4;
         }
         return 0;
      }
      
      public function init(param1:DisplayObjectContainer, param2:Sprite, param3:String, param4:int, param5:int, param6:int, param7:Function = null, param8:Function = null, param9:Function = null, param10:Boolean = false, param11:int = 0, param12:int = 0, param13:String = null, param14:String = null, param15:Array = null, param16:Boolean = false, param17:Iitem = null) : void
      {
         _guiLayer = param1;
         _item = param17;
         _icon = param2;
         _name = param3;
         _enviroType = param12;
         _denyForNonMem = param10;
         _buttonsType = param11;
         _onCloseMsg = param13;
         _giftDefIdOrAmount = param4 == 0 ? param3 : String(param4);
         translateNonItemNameForTracking();
         _popupType = param5;
         _giftType = param6;
         _keepCallback = param7;
         _rejectCallback = param8;
         _closeCallback = param9;
         _msgText = param14;
         _giftDataArray = param15;
         _isFromStartup = param16;
         _itemColorIndex = -1;
         DarkenManager.showLoadingSpiral(true);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1084,onMediaItemLoaded);
      }
      
      public function destroy() : void
      {
         if(_popupContent)
         {
            _popupContent.removeEventListener("mouseDown",onGiftPopup);
            if(_popupContent.buttons.keepBtn.visible)
            {
               _guiLayer.stage.removeEventListener("keyDown",keepKeyDown);
               _popupContent.buttons.keepBtn.removeEventListener("mouseDown",keepBtnDownHandler);
               _guiLayer.stage.removeEventListener("keyDown",rejectKeyDown);
               _popupContent.buttons.discardBtn.removeEventListener("mouseDown",rejectBtnDownHandler);
            }
            if(_popupContent.buttons.okBtn && _popupContent.buttons.okBtn.visible)
            {
               _guiLayer.stage.removeEventListener("keyDown",rejectFromOkKeyDown);
               _popupContent.buttons.okBtn.removeEventListener("mouseDown",rejectFromOkButtonDownHandler);
            }
            if(_popupContent.buttons.redeemBtn && _popupContent.buttons.redeemBtn.visible)
            {
               _guiLayer.stage.removeEventListener("keyDown",rejectFromOkKeyDown);
               _popupContent.buttons.redeemBtn.removeEventListener("mouseDown",keepBtnDownHandler);
            }
            if(_popupContent.bx.visible)
            {
               _popupContent.bx.removeEventListener("mouseDown",onXBtnDown);
            }
            if(_popupType == 20)
            {
               destroyColorsView();
            }
            _guiLayer.removeChild(_popupContent);
            DarkenManager.unDarken(_popupContent);
         }
         if(_loadingMediaHelper)
         {
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
         _popupContent = null;
         _guiLayer = null;
         _icon = null;
         _keepCallback = null;
         _rejectCallback = null;
         _closeCallback = null;
      }
      
      public function close() : void
      {
         if(_onCloseMsg)
         {
            _closeMsgOkPopup = new SBOkPopup(_guiLayer,_onCloseMsg,true,onCloseMsgOkBtnDown);
            _onCloseMsg = null;
            return;
         }
         SBTracker.pop();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
      }
      
      protected function onMediaItemLoaded(param1:MovieClip, param2:int = 0) : void
      {
         var _loc3_:String = null;
         if(param1)
         {
            _loc3_ = _enviroType == 1 ? "_Ocean" : "";
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/gift/" + popupTypeToString(_popupType) + "/#" + _giftDefIdOrAmount,-1,1);
            _popupContent = MovieClip(param1.getChildAt(0));
            if(_item)
            {
               _popupContent.itemLayer.addChild(_item.icon);
            }
            else
            {
               _popupContent.itemLayer.addChild(_icon);
            }
            LocalizationManager.updateToFit(_popupContent.buttons.giftNameTxt,_name);
            if(_popupContent.bx)
            {
               _popupContent.bx.visible = false;
            }
            if(!AJAudio.hasLoadedGiftUnwrapSfx && param2 == 0)
            {
               AJAudio.loadSfx("GiftUnwrap",param1.loaderInfo.applicationDomain.getDefinition("GiftUnwrap") as Class,0.6);
               AJAudio.loadSfx("TreasureUnwrap",param1.loaderInfo.applicationDomain.getDefinition("TreasureUnwrap") as Class,0.33);
               AJAudio.loadSfx("TreasureBagUnwrap",param1.loaderInfo.applicationDomain.getDefinition("TreasureBagUnwrap") as Class,0.6);
               AJAudio.loadSfx("EpicLuckyTreasureUnwrap",param1.loaderInfo.applicationDomain.getDefinition("EpicLuckyTreasureUnwrap") as Class,0.6);
               AJAudio.loadSfx("potOgoldPopUp",param1.loaderInfo.applicationDomain.getDefinition("potOgoldPopUp") as Class,0.6);
               AJAudio.loadSfx("TreasureGoldenEgg",param1.loaderInfo.applicationDomain.getDefinition("TreasureGoldenEgg") as Class,0.68);
               AJAudio.hasLoadedGiftUnwrapSfx = true;
            }
            _guiLayer.addChild(_popupContent);
            if(_popupType == 1 || _popupType == 20)
            {
               if(_popupType == 20)
               {
                  _popupContent.gotoAndPlay("onColorSelect");
                  LocalizationManager.updateToFit(_popupContent.buttons.giftNameTxt,_name);
                  setupColorsView();
               }
               else
               {
                  _popupContent.buttons.visible = false;
               }
               if(_popupContent.buttons.treasureNameTxt)
               {
                  _popupContent.buttons.treasureNameTxt.visible = false;
                  _popupContent.buttons.treasureTxtBox.visible = false;
               }
               if(param2 == 1)
               {
                  LocalizationManager.translateId(_popupContent.titleTxt,32510);
                  LocalizationManager.updateToFit(_popupContent.messageTxt,_msgText);
               }
               else if(_name.indexOf("Diamond") != -1)
               {
                  LocalizationManager.translateId(_popupContent.titleTxt,23913);
               }
               else
               {
                  LocalizationManager.translateId(_popupContent.titleTxt,11281);
               }
               if(param2 == 0)
               {
                  _popupContent.present.addEventListener("mouseDown",onPresentDownHandler,false,0,true);
               }
            }
            else if(_popupType == 6)
            {
               _popupContent.buttons.treasureNameTxt.visible = false;
               _popupContent.buttons.treasureTxtBox.visible = false;
               if(!_isFromStartup)
               {
                  _popupContent.bx.visible = true;
                  _popupContent.bx.addEventListener("mouseDown",onXBtnDown,false,0,true);
               }
               if(param2 == 0)
               {
                  _popupContent.present.addEventListener("mouseDown",onPresentDownHandler,false,0,true);
                  _popupContent.gotoAndPlay("offMessage");
               }
               if(_msgText)
               {
                  LocalizationManager.updateToFit(_popupContent.messageTxt,_msgText);
               }
               _popupContent.buttons.visible = false;
            }
            else if(isPopUpTypeTreasure())
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndStop("offTreasureMessage" + _loc3_ + popUpColor());
                  _popupContent.present.addEventListener("mouseDown",onPresentDownHandler,false,0,true);
                  _popupContent.bx.addEventListener("mouseDown",onXBtnDown,false,0,true);
               }
               _popupContent.buttons.visible = false;
            }
            else if(_popupType == 8)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onChooseTreasure" + _loc3_);
                  AJAudio.playTreasureUnwrap();
               }
            }
            else if(_popupType == 14)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onChooseTreasure" + _loc3_);
                  AJAudio.playTreasureUnwrap();
               }
            }
            else if(_popupType == 15)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onTreasureLucky" + _loc3_);
                  AJAudio.playTreasureLuckyUnwrap();
               }
            }
            else if(_popupType == 18)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onTreasurePotOfGold" + _loc3_);
                  AJAudio.playTreasureLucky2Unwrap();
               }
            }
            else if(_popupType == 19)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onTreasureChinese" + _loc3_);
                  AJAudio.playTreasureLucky2Unwrap();
               }
            }
            else if(_popupType == 16)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onTreasureGoldEgg" + _loc3_);
                  AJAudio.playTreasureEggUnwrap();
               }
            }
            else if(_popupType == 17)
            {
               _popupContent.buttons.giftNameTxt.visible = false;
               _popupContent.buttons.giftTxtBox.visible = false;
               _popupContent.buttons.treasureNameTxt.text = _name;
               if(param2 == 0)
               {
                  _popupContent.gotoAndPlay("onTreasurePhantom" + _loc3_);
                  AJAudio.playTreasureUnwrap();
               }
            }
            else
            {
               _popupContent.buttons.treasureNameTxt.visible = false;
               _popupContent.buttons.treasureTxtBox.visible = false;
               if(_popupType == 0 || _popupType == 3 || _popupType == 5)
               {
                  if(_popupType == 5)
                  {
                     LocalizationManager.translateId(_popupContent.titleTxt,11282);
                  }
                  else
                  {
                     LocalizationManager.translateId(_popupContent.titleTxt,11283);
                  }
                  if(param2 == 0)
                  {
                     _popupContent.bx.visible = true;
                     _popupContent.bx.addEventListener("mouseDown",onXBtnDown,false,0,true);
                  }
               }
               else if(_popupType == 4)
               {
                  LocalizationManager.translateId(_popupContent.titleTxt,11283);
               }
               else if(_popupType == 2)
               {
                  LocalizationManager.translateId(_popupContent.titleTxt,11282);
               }
               if(param2 == 0)
               {
                  _popupContent.gotoAndStop("lastFrame");
                  AJAudio.playGiftUnwrap();
               }
            }
            _popupContent.addEventListener("mouseDown",onGiftPopup,false,0,true);
            if(_buttonsType == 0)
            {
               _guiLayer.stage.addEventListener("keyDown",keepKeyDown,false,0,true);
               _popupContent.buttons.keepBtn.addEventListener("mouseDown",keepBtnDownHandler,false,0,true);
               _guiLayer.stage.addEventListener("keyDown",rejectKeyDown,false,0,true);
               _popupContent.buttons.discardBtn.addEventListener("mouseDown",rejectBtnDownHandler,false,0,true);
               if(_popupContent.buttons.okBtn)
               {
                  _popupContent.buttons.okBtn.visible = false;
               }
               if(_popupContent.buttons.createBtn)
               {
                  _popupContent.buttons.createBtn.visible = false;
               }
               if(_popupContent.buttons.takeBtn)
               {
                  _popupContent.buttons.takeBtn.visible = false;
               }
               if(_popupContent.buttons.leaveBtn)
               {
                  _popupContent.buttons.leaveBtn.visible = false;
               }
               if(_popupContent.buttons.redeemBtn)
               {
                  _popupContent.buttons.redeemBtn.visible = false;
               }
            }
            else if(_buttonsType == 1)
            {
               _guiLayer.stage.addEventListener("keyDown",rejectFromOkKeyDown,false,0,true);
               _popupContent.buttons.okBtn.addEventListener("mouseDown",rejectFromOkButtonDownHandler,false,0,true);
               _popupContent.buttons.keepBtn.visible = false;
               _popupContent.buttons.discardBtn.visible = false;
               _popupContent.buttons.createBtn.visible = false;
               if(_popupContent.buttons.takeBtn)
               {
                  _popupContent.buttons.takeBtn.visible = false;
               }
               if(_popupContent.buttons.leaveBtn)
               {
                  _popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(_buttonsType == 2)
            {
               _popupContent.buttons.createBtn.addEventListener("mouseDown",onCreateButton,false,0,true);
               _popupContent.buttons.createBtn.visible = true;
               _popupContent.buttons.keepBtn.visible = false;
               _popupContent.buttons.discardBtn.visible = false;
               _popupContent.buttons.okBtn.visible = false;
               if(_popupContent.buttons.takeBtn)
               {
                  _popupContent.buttons.takeBtn.visible = false;
               }
               if(_popupContent.buttons.leaveBtn)
               {
                  _popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(_buttonsType == 3)
            {
               _guiLayer.stage.addEventListener("keyDown",keepKeyDown,false,0,true);
               _popupContent.buttons.takeBtn.addEventListener("mouseDown",keepBtnDownHandler,false,0,true);
               _guiLayer.stage.addEventListener("keyDown",rejectKeyDown,false,0,true);
               _popupContent.buttons.leaveBtn.addEventListener("mouseDown",rejectBtnDownHandler,false,0,true);
               _popupContent.buttons.okBtn.visible = false;
               _popupContent.buttons.createBtn.visible = false;
               _popupContent.buttons.keepBtn.visible = false;
               _popupContent.buttons.discardBtn.visible = false;
            }
            else if(_buttonsType == 4)
            {
               _guiLayer.stage.addEventListener("keyDown",keepKeyDown,false,0,true);
               _popupContent.buttons.redeemBtn.addEventListener("mouseDown",keepBtnDownHandler,false,0,true);
               _popupContent.buttons.keepBtn.visible = false;
               _popupContent.buttons.discardBtn.visible = false;
               if(_popupContent.buttons.takeBtn)
               {
                  _popupContent.buttons.takeBtn.visible = false;
               }
               if(_popupContent.buttons.leaveBtn)
               {
                  _popupContent.buttons.leaveBtn.visible = false;
               }
            }
            _popupContent.x = 900 * 0.5;
            _popupContent.y = 550 * 0.5;
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_popupContent);
         }
      }
      
      private function setupColorsView() : void
      {
         var _loc3_:DenItem = null;
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(_item is DenItem)
         {
            _loc3_ = _item.clone() as DenItem;
            _loc3_.globalScale = 0.5;
            _loc1_ = (_item as DenItem).getVersions();
            _itemColorIndex = 0;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_] != null)
               {
                  _loc3_.setVersion(_loc1_[_loc2_]);
                  (_popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)] as GuiSoundToggleButton).insertIitem(_loc3_,"itemLayer");
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].mouseEnabled = true;
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].mouseChildren = true;
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].visible = true;
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].addEventListener("mouseDown",onIconItemDown,false,0,true);
               }
               else
               {
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].mouseEnabled = false;
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].mouseChildren = false;
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].visible = false;
               }
               _loc2_++;
            }
            (_popupContent.buttons["iconItemWindow_1"] as GuiSoundToggleButton).upToDownState();
         }
      }
      
      private function onIconItemDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         (_popupContent.buttons["iconItemWindow_" + (_itemColorIndex + 1)] as GuiSoundToggleButton).downToUpState();
         _itemColorIndex = param1.currentTarget.name.split("_")[1] - 1;
         (_popupContent.buttons["iconItemWindow_" + (_itemColorIndex + 1)] as GuiSoundToggleButton).upToDownState();
         (_item as DenItem).setVersion(_itemColorIndex);
      }
      
      private function destroyColorsView() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(_item is DenItem)
         {
            _loc1_ = (_item as DenItem).getVersions();
            _itemColorIndex = -1;
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_] != null)
               {
                  _popupContent.buttons["iconItemWindow_" + (_loc2_ + 1)].removeEventListener("mouseDown",onIconItemDown);
               }
               _loc2_++;
            }
         }
      }
      
      private function keepKeyDown(param1:KeyboardEvent) : void
      {
         if(_popupActive == false)
         {
            switch(param1.keyCode)
            {
               case 13:
               case 32:
                  if(_popupContent && _popupContent.buttons && !_popupContent.buttons.visible)
                  {
                     handlePresentDown();
                     break;
                  }
                  keepBtnDownHandler(param1);
                  break;
            }
         }
      }
      
      private function rejectKeyDown(param1:KeyboardEvent) : void
      {
         if(_popupActive == false)
         {
            switch(param1.keyCode)
            {
               case 8:
               case 46:
               case 27:
                  rejectBtnDownHandler(param1);
            }
         }
      }
      
      private function rejectFromOkKeyDown(param1:KeyboardEvent) : void
      {
         if(_popupActive == false)
         {
            switch(param1.keyCode)
            {
               case 32:
               case 8:
               case 46:
               case 27:
                  if(_popupContent && _popupContent.buttons && !_popupContent.buttons.visible)
                  {
                     handlePresentDown();
                     break;
                  }
                  rejectFromOkButtonDownHandler(param1);
                  break;
            }
         }
      }
      
      private function onGiftPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onXBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function isPopUpTypeTreasure() : Boolean
      {
         return _popupType == 7 || _popupType == 10 || _popupType == 9 || _popupType == 11 || _popupType == 12 || _popupType == 13;
      }
      
      private function popUpColor() : String
      {
         switch(_popupType - 9)
         {
            case 0:
               return "Red";
            case 1:
               return "Blue";
            case 2:
               return "Orange";
            case 3:
               return "Green";
            case 4:
               return "Bag";
            default:
               return "";
         }
      }
      
      private function handlePresentDown() : void
      {
         var _loc1_:String = _enviroType == 1 ? "_Ocean" : "";
         _popupContent.buttons.visible = true;
         _popupContent.present.removeEventListener("mouseDown",onPresentDownHandler);
         _popupContent.gotoAndPlay(_popupType == 6 ? "onMessage" : (isPopUpTypeTreasure() ? "onTreasureMessage" + _loc1_ + popUpColor() : "on"));
         if(isPopUpTypeTreasure())
         {
            if(_popupType == 13)
            {
               AJAudio.playTreasureBagUnwrap();
            }
            else
            {
               AJAudio.playTreasureUnwrap();
            }
         }
         else
         {
            AJAudio.playGiftUnwrap();
         }
      }
      
      private function onPresentDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         handlePresentDown();
      }
      
      private function keepBtnDownHandler(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:AccItemCollection = null;
         var _loc9_:AccItemCollection = null;
         var _loc6_:DenItemCollection = null;
         var _loc3_:UserInfo = null;
         var _loc4_:DenItemCollection = null;
         var _loc11_:DenRoomItemCollection = null;
         var _loc7_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_denyForNonMem && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("jamagram","Receiving_Gift");
         }
         else
         {
            if(_giftType == 1)
            {
               if(gMainFrame.userInfo.playerAvatarInfo)
               {
                  _loc2_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               }
               if(_enviroType == 0)
               {
                  if(_loc2_.length > 0)
                  {
                     _loc9_ = Utility.clothingItemListByEnviroType(_loc2_,0);
                  }
                  _loc5_ = 6;
               }
               else
               {
                  if(_loc2_.length > 0)
                  {
                     _loc9_ = Utility.clothingItemListByEnviroType(_loc2_,1);
                  }
                  _loc5_ = 5;
               }
               if(_loc9_)
               {
                  _loc8_ = int(_loc9_.length);
               }
               _loc10_ = ShopManager.maxItems;
            }
            else if(_giftType == 2)
            {
               if(_enviroType == 0)
               {
                  if(gMainFrame.userInfo.playerUserInfo)
                  {
                     _loc3_ = gMainFrame.userInfo.playerUserInfo;
                     if(_loc3_.denItemsFull.length > 0)
                     {
                        _loc6_ = Utility.denItemListByEnviroType(_loc3_.denItemsFull,0);
                     }
                  }
                  _loc5_ = 4;
               }
               else
               {
                  if(gMainFrame.userInfo.playerUserInfo && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
                  {
                     _loc6_ = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,1);
                  }
                  _loc5_ = 3;
               }
               if(_loc6_)
               {
                  _loc8_ = int(_loc6_.length);
               }
               _loc10_ = ShopManager.maxDenItems;
            }
            else if(_giftType == 5)
            {
               if(gMainFrame.userInfo.playerUserInfo && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
               {
                  _loc4_ = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,-1,true);
               }
               _loc5_ = 2;
               if(_loc4_)
               {
                  _loc8_ = int(_loc4_.length);
               }
               _loc10_ = ShopManager.maxAudioItems;
            }
            else if(_giftType == 3)
            {
               _loc11_ = DenSwitch.denList;
               _loc5_ = 99;
               if(_loc11_)
               {
                  _loc7_ = 0;
                  while(_loc7_ < _loc11_.length)
                  {
                     if(_loc11_.getDenRoomItem(_loc7_))
                     {
                        _loc8_++;
                     }
                     _loc7_++;
                  }
               }
               _loc10_ = 200;
            }
            else
            {
               if(_popupType == 8 || _popupType == 14 || _popupType == 15 || _popupType == 18 || _popupType == 19 || _popupType == 16 || _popupType == 17)
               {
                  if(_giftType == 0 || _giftType == 7)
                  {
                     keepItem();
                     return;
                  }
               }
               trace("Invalid type for GiftPopup keep button. type=" + _giftType);
            }
            if(Utility.canGift() || _popupType != 0)
            {
               if(_loc8_ >= _loc10_)
               {
                  _popupActive = true;
                  new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14746),true,confirmRecycleHandler,_loc5_);
               }
               else
               {
                  keepItem();
               }
            }
            else
            {
               _popupActive = true;
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14747),true,okPopupComplete);
            }
         }
      }
      
      private function okPopupComplete(param1:MouseEvent) : void
      {
         _popupActive = false;
         SBOkPopup.destroyInParentChain(param1.target.parent);
      }
      
      private function rejectFromOkButtonDownHandler(param1:Event) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/gift/" + popupTypeToString(_popupType) + "/#" + _giftDefIdOrAmount + "/ok",-1,1);
         if(_rejectCallback != null)
         {
            _rejectCallback();
         }
         else
         {
            close();
         }
      }
      
      private function rejectBtnDownHandler(param1:Event) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!isPopUpTypeTreasure())
         {
            if(_popupType == 1)
            {
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(14748,_popupContent.titleTxt.text.toLowerCase());
            }
            else if(_popupType == 6)
            {
               _loc2_ = LocalizationManager.translateIdOnly(14749);
            }
            else
            {
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(14750,_popupContent.titleTxt.text.toLowerCase());
            }
            _popupActive = true;
            new SBYesNoPopup(_guiLayer,_loc2_,true,onConfirmReject);
         }
         else
         {
            _popupActive = true;
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14919),true,onConfirmReject);
         }
      }
      
      private function onCreateButton(param1:MouseEvent) : void
      {
         PetManager.openPetFinder(_name.toLowerCase().replace(/[\s\r\n]*/gim,""),onPetCreated,true,_giftDataArray);
      }
      
      private function onPetCreated() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
         }
      }
      
      private function onConfirmReject(param1:Object) : void
      {
         if(param1.status)
         {
            SBTracker.trackPageview("game/play/popup/gift/" + popupTypeToString(_popupType) + "/#" + _giftDefIdOrAmount + "/reject",-1,1);
            _onCloseMsg = null;
            if(_rejectCallback != null)
            {
               _rejectCallback();
            }
            else
            {
               close();
            }
         }
         _popupActive = false;
      }
      
      private function keepItem() : void
      {
         SBTracker.trackPageview("game/play/popup/gift/" + popupTypeToString(_popupType) + "/#" + _giftDefIdOrAmount + "/keep",-1,1);
         if(_keepCallback != null)
         {
            if(_keepCallback.length > 0)
            {
               _keepCallback(_itemColorIndex);
            }
            else
            {
               _keepCallback();
            }
         }
         else
         {
            close();
         }
      }
      
      private function onCloseMsgOkBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _closeMsgOkPopup.destroy();
         _closeMsgOkPopup = null;
         close();
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc2_ = int(param1.passback);
            _popupActive = true;
            if(_loc2_ == 99)
            {
               GuiManager.openDenRoomSwitcher(true,onDenRoomRecycleClose);
            }
            else
            {
               if(_recyclePopup)
               {
                  _recyclePopup.destroy();
               }
               _recyclePopup = new RecycleItems();
               _recyclePopup.init(_loc2_,_guiLayer,true,onRecycleClose,900 * 0.5,550 * 0.5,_enviroType == AvatarManager.roomEnviroType);
            }
         }
         else
         {
            _popupActive = false;
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.destroy();
            _recyclePopup = null;
         }
         if(param1)
         {
            keepItem();
         }
         _popupActive = false;
      }
      
      private function onDenRoomRecycleClose(param1:Boolean = false) : void
      {
         GuiManager.onDenSwitchClose(true);
         if(param1)
         {
            keepItem();
         }
         _popupActive = false;
      }
      
      private function onColorChangeBtn(param1:MouseEvent) : void
      {
         if(_giftType == 2)
         {
            if((_item as DenItem).getVersions() && (_item as DenItem).getVersions().length > 0)
            {
               if(_itemColorIndex == -1)
               {
                  _itemColorIndex = 0;
               }
               _itemColorIndex++;
               if(_itemColorIndex >= (_item as DenItem).getVersions().length)
               {
                  _itemColorIndex = 0;
               }
               (_item as DenItem).setVersion((_item as DenItem).getVersions()[_itemColorIndex]);
            }
         }
      }
      
      private function popupTypeToString(param1:int) : String
      {
         switch(param1)
         {
            case 0:
               return "JAG";
            case 1:
               return "Promo";
            case 2:
               return "Prize";
            case 3:
               return "JB";
            case 5:
               return "TouchPool";
            default:
               return "";
         }
      }
      
      protected function translateNonItemNameForTracking() : void
      {
         if(_giftType == 0)
         {
            _giftDefIdOrAmount += " gems";
         }
         else if(_giftType == 7)
         {
            _giftDefIdOrAmount += " crystals";
         }
         else if(_giftType == 8)
         {
            _giftDefIdOrAmount += " diamonds";
         }
      }
   }
}

