package gui
{
   import Enums.DenItemDef;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserInfo;
   import buddy.Buddy;
   import buddy.BuddyList;
   import buddy.BuddyManager;
   import buddy.BuddyXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import giftPopup.GiftPopup;
   import gui.itemWindows.ItemWindowECard;
   import item.SimpleIcon;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class ECardInbox
   {
      public static const AJHQ_JAG_ID:int = 1194;
      
      public static const NEWS_CREW_JAG_ID:int = 1630;
      
      public static var eCardIsOpen:Boolean;
      
      public static var eCardWasOpen:Boolean;
      
      public static var ffmCallback:Function;
      
      public static var initialConditionsCallback:Function;
      
      public static var nextSetCallback:Function;
      
      private const AJHQ_JAG_ORIG_Y_POS:Number = 35.55;
      
      private const ECARD_INBOX_MEDIA_ID:int = 1353;
      
      private var _eCardInbox:MovieClip;
      
      private var _nameBars:MovieClip;
      
      private var _onCloseCallback:Function;
      
      private var _createCard:Function;
      
      private var _currCardIdx:int;
      
      private var _currMsgId:int = -1;
      
      private var _privacyId:int;
      
      private var _isTabOpen:Boolean;
      
      private var _inbox:Array;
      
      private var _toolTipPositions:Object;
      
      private var _hasDeletedAtLeastOneECard:Boolean;
      
      private var _guiLayer:DisplayLayer;
      
      private var _giftPopup:GiftPopup;
      
      private var _clothingIconHelper:SimpleIcon;
      
      private var _denIconHelper:DenItemHelper;
      
      private var _mediaHelper:MediaHelper;
      
      private var _guiPet:GuiPet;
      
      private var _petBits:Array;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _buddyRequestAvatar:Avatar;
      
      private var _buddyRequestAvatarView:AvatarView;
      
      private var _inboxItemWindows:WindowAndScrollbarGenerator;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _inboxSettingsRadioBtns:GuiRadioButtonGroup;
      
      private var _eCardLoadingSpiral:LoadingSpiral;
      
      private var _windowsLoadingSpiral:LoadingSpiral;
      
      private var _externalLinkPopup:ExternalLinkPopup;
      
      public function ECardInbox()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Array, param3:Function, param4:Function) : void
      {
         _guiLayer = param1;
         _createCard = param3;
         _onCloseCallback = param4;
         _inbox = param2;
         SBTracker.push();
         SBTracker.trackPageview("/game/play/JaG/#inbox/open");
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1353,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:ECard = null;
         var _loc2_:int = 0;
         SBTracker.pop();
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(_eCardInbox);
         }
         if(_inbox)
         {
            _loc2_ = 0;
            while(_loc2_ < _inbox.length)
            {
               _loc1_ = _inbox[_loc2_];
               if(_loc1_ && _loc1_.isBuddy)
               {
                  if(_loc1_.acceptBtn)
                  {
                     _loc1_.acceptBtn.removeEventListener("mouseDown",onAcceptBtn);
                  }
                  if(_loc1_.rejectBtn)
                  {
                     _loc1_.rejectBtn.removeEventListener("mouseDown",onRejectBtn);
                  }
               }
               if(_loc1_.linkToBtn)
               {
                  _loc1_.linkToBtn.removeEventListener("mouseDown",onLinkToBtn);
               }
               _loc2_++;
            }
         }
         if(_giftPopup)
         {
            _giftPopup.destroy();
         }
         if(_buddyRequestAvatarView)
         {
            _buddyRequestAvatarView.destroy();
            _buddyRequestAvatarView = null;
         }
         if(_hasDeletedAtLeastOneECard)
         {
            ECardXtCommManager.sendECardClearCache();
            _hasDeletedAtLeastOneECard = false;
         }
         AvatarManager.showAvtAndChatLayers(true);
         DarkenManager.unDarken(_eCardInbox);
         if(_eCardInbox && _eCardInbox.parent == _guiLayer)
         {
            _guiLayer.removeChild(_eCardInbox);
         }
         removeListeners();
         _eCardInbox = null;
      }
      
      public function updateUnreadCount() : void
      {
         var _loc1_:int = ECardManager.unreadCount;
         _eCardInbox.newEcardCount.visible = _loc1_ > 0;
         _eCardInbox.newEcardCount.eCardCountTxt.text = _loc1_;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _eCardInbox = param1.getChildAt(0) as MovieClip;
         _eCardInbox.x = 900 * 0.5;
         _eCardInbox.y = 550 * 0.5;
         KeepAlive.startKATimer(_eCardInbox);
         _eCardLoadingSpiral = new LoadingSpiral(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
         _windowsLoadingSpiral = new LoadingSpiral(_eCardInbox.inboxItemWindow,_eCardInbox.inboxItemWindow.width * 0.5,_eCardInbox.inboxItemWindow.height * 0.5);
         _nameBars = _eCardInbox.fromTab.nameBars;
         _nameBars.nonmember.visible = false;
         _nameBars.member.visible = false;
         _eCardInbox.nonMemIcon.visible = false;
         _eCardInbox.giftBig.visible = false;
         _eCardInbox.cardSlot.noMailPopup.visible = !ECardManager.isFirstTime;
         _currCardIdx = 0;
         drawCurrECard();
         setupInboxWindows();
         setupToolTipPositions();
         setupSettingsPopup();
         updateUnreadCount();
         addListeners();
         _guiLayer.addChild(_eCardInbox);
         DarkenManager.darken(_eCardInbox);
         if(ECardManager.isFirstTime)
         {
            ECardXtCommManager.sendECardListRequest();
            ECardManager.isFirstTime = false;
         }
         AvatarManager.showAvtAndChatLayers(false);
      }
      
      public function processECardList(param1:Array = null) : void
      {
         if(param1)
         {
            param1 = param1.concat();
            _inbox = param1;
            if(_currCardIdx == -1)
            {
               _currCardIdx = 0;
            }
            if(_inbox.length == 0)
            {
               _eCardLoadingSpiral.visible = false;
               _eCardInbox.cardSlot.noMailPopup.visible = true;
               _eCardInbox.countTxt.text = "0/0";
            }
            drawCurrECard();
            _inboxItemWindows.insertManyItems(_inbox,false,true,onInboxWindowsLoaded);
         }
         else
         {
            drawCurrECard();
         }
      }
      
      public function processECardPush(param1:ECard) : void
      {
         _inbox.unshift(param1);
         ++_currCardIdx;
         _inboxItemWindows.insertItem(param1,false,true);
      }
      
      public function updateECard(param1:ECard) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _inbox.length)
         {
            if(_inbox[_loc2_].msgId == param1.msgId)
            {
               _inboxItemWindows.updateItem(_loc2_,param1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function onDeleteResponse(param1:Array, param2:Boolean) : void
      {
         var _loc4_:ECard = null;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(param2)
         {
            _hasDeletedAtLeastOneECard = true;
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _loc5_ = 0;
               while(_loc5_ < _inbox.length)
               {
                  _loc4_ = _inbox[_loc5_];
                  if(_loc4_ != null && _loc4_.msgId == param1[_loc3_])
                  {
                     _inboxItemWindows.deleteItem(_loc5_,_inbox,true,false);
                     if(_loc4_.msgId == _currMsgId)
                     {
                        if(_loc4_.isBuddy)
                        {
                           _loc4_.acceptBtn.removeEventListener("mouseDown",onAcceptBtn);
                           _loc4_.rejectBtn.removeEventListener("mouseDown",onRejectBtn);
                        }
                        else if(_loc4_.isGift)
                        {
                           _eCardInbox.giftBig.visible = false;
                           destroyGiftPopup();
                        }
                        if(_loc4_.linkToBtn)
                        {
                           _loc4_.linkToBtn.removeEventListener("mouseDown",onLinkToBtn);
                        }
                     }
                     break;
                  }
                  _loc5_++;
               }
               _loc3_++;
            }
            if(_inbox.length == 0)
            {
               _eCardInbox.cardSlot.noMailPopup.visible = true;
               _eCardInbox.countTxt.text = "0/0";
               _currCardIdx = -1;
            }
            else if(_currCardIdx > _inbox.length - 1)
            {
               _currCardIdx = _inbox.length - 1;
            }
            if(_inbox[_currCardIdx])
            {
               _currMsgId = _inbox[_currCardIdx].msgId;
            }
            else
            {
               _currMsgId = -1;
            }
            _inboxItemWindows.callUpdateOnWindow(_currCardIdx);
            ECardManager.setInboxAfterDelete = _inbox;
            drawCurrECard();
         }
         else
         {
            DebugUtility.debugTrace("Error on deletion");
         }
      }
      
      public function onECardLoaded(param1:ECard) : void
      {
         if(param1)
         {
            if(param1.isFromVoice)
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = false;
            }
            else if(param1.msg != "" && !SafeChatManager.containsInTreeArray(param1.msg,1))
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = true;
            }
            else
            {
               _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.visible = false;
            }
            _eCardLoadingSpiral.visible = false;
            if(param1.isBuddy || param1.isEmailReset)
            {
               if(param1.isBuddy)
               {
                  if(param1.acceptBtn)
                  {
                     setupBuddyRequest(param1);
                  }
               }
               else if(param1.changeEmailBtn)
               {
                  setupChangeEmailRequest(param1);
               }
            }
            if(param1.linkToBtn)
            {
               setupLinkToBtnRequest(param1);
            }
            if(_inboxItemWindows)
            {
               _inboxItemWindows.findItemAndUpdate(param1);
            }
            if((_eCardInbox.eCardCont as MovieClip).hitTestPoint(gMainFrame.stage.mouseX,gMainFrame.stage.mouseY))
            {
               onECardItemWindowOverOut(null);
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _onCloseCallback();
      }
      
      private function setupToolTipPositions() : void
      {
         var _loc1_:Point = null;
         _toolTipPositions = {};
         _loc1_ = _eCardInbox.newBtn.localToGlobal(new Point(_eCardInbox.newBtn.width * 0.5,-10));
         _toolTipPositions[_eCardInbox.newBtn] = _loc1_;
         _loc1_ = _eCardInbox.replyBtn.localToGlobal(new Point(_eCardInbox.replyBtn.width * 0.5,-10));
         _toolTipPositions[_eCardInbox.replyBtn] = _loc1_;
         _loc1_ = _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.localToGlobal(new Point(0,-10));
         _loc1_.x += _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.width * 0.5;
         _toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn] = _loc1_;
         _loc1_ = _nameBars.localToGlobal(new Point(50,-35));
         _toolTipPositions[_nameBars] = _loc1_;
         _loc1_ = _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.localToGlobal(new Point(0,-10));
         _loc1_.x += _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.width * 0.5;
         _toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn] = _loc1_;
      }
      
      private function setupInboxWindows() : void
      {
         _inboxItemWindows = new WindowAndScrollbarGenerator();
         _inboxItemWindows.init(_eCardInbox.inboxItemWindow.width,_eCardInbox.inboxItemWindow.height,5,0,1,5,0,0,0,0,0,ItemWindowECard,_inbox.concat(),"",0,{
            "mouseOver":windowMouseOver,
            "mouseDown":windowMouseDown,
            "mouseOut":windowMouseOut
         },{
            "currSelectedIndex":getCurrCardIndex,
            "readFunction":readCurrECard
         },onInboxWindowsLoaded,true,false,false,false,false);
         while(_eCardInbox.inboxItemWindow.numChildren > 2)
         {
            _eCardInbox.inboxItemWindow.removeChildAt(_eCardInbox.inboxItemWindow.numChildren - 1);
         }
         _eCardInbox.inboxItemWindow.addChild(_inboxItemWindows);
      }
      
      private function onInboxWindowsLoaded() : void
      {
         _windowsLoadingSpiral.visible = false;
      }
      
      private function setupSettingsPopup(param1:Boolean = false) : void
      {
         if(param1)
         {
            _eCardInbox.settingsPopup.removeEventListener("mouseDown",onPopup);
            _eCardInbox.settingsPopup.bx.removeEventListener("mouseDown",onSettingsClose);
            if(_inboxSettingsRadioBtns)
            {
               _inboxSettingsRadioBtns.currRadioButton.removeEventListener("mouseDown",onSettingsChoose);
               _inboxSettingsRadioBtns.destroy();
               _inboxSettingsRadioBtns = null;
            }
         }
         else
         {
            _privacyId = gMainFrame.userInfo.eCardPrivacySettings;
            _eCardInbox.settingsPopup.visible = false;
            _eCardInbox.settingsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _eCardInbox.settingsPopup.bx.addEventListener("mouseDown",onSettingsClose,false,0,true);
            _inboxSettingsRadioBtns = new GuiRadioButtonGroup(_eCardInbox.settingsPopup.options);
            _inboxSettingsRadioBtns.currRadioButton.addEventListener("mouseDown",onSettingsChoose,false,0,true);
            _inboxSettingsRadioBtns.selected = _privacyId;
            onSettingsChoose(null);
         }
      }
      
      private function onSettingsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_inboxSettingsRadioBtns.selected != _privacyId)
         {
            KeepAlive.restartTimeLeftTimer();
            ECardXtCommManager.sendECardPrivacySettingUpdateRequest(_inboxSettingsRadioBtns.selected,onPrivacySetResponse);
         }
         onSettingsBtn(param1);
      }
      
      private function onSettingsChoose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _eCardInbox.settingsBtn.gotoAndStop(_inboxSettingsRadioBtns.selected + 1);
         if(_eCardInbox.settingsPopup.visible)
         {
            _eCardInbox.settingsBtn[_eCardInbox.settingsBtn.currentFrameLabel + "Btn"].upToDownState();
         }
      }
      
      private function onSettingsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _eCardInbox.settingsPopup.visible = !_eCardInbox.settingsPopup.visible;
         if(!_eCardInbox.settingsPopup.visible)
         {
            _eCardInbox.settingsBtn[_eCardInbox.settingsBtn.currentFrameLabel + "Btn"].downToUpState();
         }
      }
      
      private function onPrivacySetResponse(param1:Boolean, param2:int) : void
      {
         if(_eCardInbox)
         {
            if(param1)
            {
               _privacyId = param2;
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14774));
            }
         }
      }
      
      private function getCurrCardIndex() : int
      {
         return _currCardIdx;
      }
      
      private function drawCurrECard() : void
      {
         var _loc1_:ECard = null;
         BuddyManager.destroyBuddyCard();
         if(_buddyRequestAvatarView)
         {
            _buddyRequestAvatarView.destroy();
            _buddyRequestAvatarView = null;
         }
         if(_currCardIdx == 0)
         {
            _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.activateGrayState(true);
            if(_inbox.length < 2)
            {
               _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.activateGrayState(true);
            }
            else
            {
               _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.activateGrayState(false);
            }
         }
         else if(_currCardIdx == _inbox.length - 1)
         {
            if(_inbox.length == 1)
            {
               _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.activateGrayState(true);
            }
            else
            {
               _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.activateGrayState(false);
            }
            _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.activateGrayState(true);
         }
         else
         {
            _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.activateGrayState(false);
            _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.activateGrayState(false);
         }
         if(_inbox && _inbox[_currCardIdx])
         {
            _loc1_ = _inbox[_currCardIdx];
            _currMsgId = _loc1_.msgId;
            _eCardInbox.cardSlot.noMailPopup.visible = false;
            _eCardInbox.AJIcon.visible = false;
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
            while(_eCardInbox.eCardCont.eCardItemWindow.numChildren > 1)
            {
               _eCardInbox.eCardCont.eCardItemWindow.removeChildAt(_eCardInbox.eCardCont.eCardItemWindow.numChildren - 1);
            }
            _eCardLoadingSpiral.setNewParent(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
            _eCardLoadingSpiral.visible = true;
            _eCardInbox.eCardCont.eCardItemWindow.addChild(_loc1_.cardImg);
            if(_loc1_.isGift)
            {
               _eCardInbox.giftBig.visible = true;
            }
            else
            {
               _eCardInbox.giftBig.visible = false;
            }
            if(_loc1_.specialType == 1)
            {
               _nameBars.member.visible = true;
               _nameBars.nonmember.visible = false;
               _eCardInbox.nonMemIcon.visible = false;
               _nameBars.nonmember.iconIds = GuiManager.getNamebarBadgeList();
               _nameBars.member.setNubType(NameBar.BUDDY,false);
               _nameBars.member.setColorAndBadge(6);
               _nameBars.member.setAvName(_loc1_.senderModeratedUserName,false,null,false);
               _nameBars.member.isBlocked = false;
            }
            else if(_loc1_.isSenderMember)
            {
               _nameBars.member.visible = true;
               _nameBars.nonmember.visible = false;
               _eCardInbox.nonMemIcon.visible = false;
               if(_loc1_.isFromVoice)
               {
                  _nameBars.nonmember.iconIds = GuiManager.getNamebarBadgeList();
                  _nameBars.member.setNubType(NameBar.GUIDE,false);
                  _nameBars.member.setColorAndBadge(0);
                  _nameBars.member.setAvName(_loc1_.senderUserName,false,null,false);
               }
               else
               {
                  _nameBars.member.iconIds = GuiManager.getNamebarBadgeList();
                  _nameBars.member.setNubType(NameBar.BUDDY,false);
                  _nameBars.member.setColorAndBadge(_loc1_.nameBarData);
                  _nameBars.member.setAvName(_loc1_.senderModeratedUserName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
               }
               _nameBars.member.isBlocked = false;
            }
            else
            {
               _eCardInbox.nonMemIcon.visible = true;
               _nameBars.member.visible = false;
               _nameBars.nonmember.visible = true;
               _nameBars.nonmember.txt.text = _loc1_.senderModeratedUserName;
            }
            _nameBars.mouseEnabled = true;
            _nameBars.mouseChildren = true;
            _eCardInbox.countTxt.text = _currCardIdx + 1 + "/" + _inbox.length;
            _eCardInbox.fromTab.visible = true;
            _eCardInbox.replyBtn.visible = true;
            _eCardInbox.newBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            if(_eCardInbox.replyBtn.hasGrayState)
            {
               _eCardInbox.replyBtn.activateGrayState(!Utility.canBuddy() || !Utility.canJAG());
            }
            if(_loc1_.isFromVoice || _loc1_.specialType == 1)
            {
               if(_eCardInbox.stampSlot)
               {
                  _eCardInbox.stampSlot.visible = false;
               }
               if(_eCardInbox.replyBtn.hasGrayState)
               {
                  _eCardInbox.replyBtn.activateGrayState(true);
               }
               _nameBars.mouseEnabled = false;
               _nameBars.mouseChildren = false;
               if(_loc1_.specialType == 1)
               {
                  _eCardInbox.AJIcon.visible = false;
               }
               else if(_loc1_.isFromVoice)
               {
                  _eCardInbox.AJIcon.visible = true;
               }
            }
            else if(_loc1_.isSenderArchived)
            {
               if(_eCardInbox.replyBtn.hasGrayState)
               {
                  _eCardInbox.replyBtn.activateGrayState(true);
               }
            }
         }
         else if(_eCardInbox)
         {
            while(_eCardInbox.eCardCont.eCardItemWindow.numChildren > 1)
            {
               _eCardInbox.eCardCont.eCardItemWindow.removeChildAt(_eCardInbox.eCardCont.eCardItemWindow.numChildren - 1);
            }
            _eCardLoadingSpiral.setNewParent(_eCardInbox.eCardCont.eCardItemWindow,_eCardInbox.eCardCont.eCardItemWindow.width * 0.5,_eCardInbox.eCardCont.eCardItemWindow.height * 0.5);
            _eCardInbox.countTxt.text = "0/0";
            _eCardInbox.fromTab.visible = false;
            _eCardInbox.replyBtn.visible = false;
            _eCardInbox.AJIcon.visible = false;
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
            _eCardLoadingSpiral.visible = false;
         }
      }
      
      private function displayGiftPopup() : void
      {
         var _loc1_:DenItemDef = null;
         var _loc7_:String = null;
         var _loc2_:int = 0;
         var _loc5_:String = null;
         var _loc4_:Array = null;
         var _loc3_:Object = null;
         var _loc6_:ECard = _inbox[_currCardIdx];
         if(_loc6_)
         {
            DarkenManager.showLoadingSpiral(true);
            if(_loc6_.isGift)
            {
               switch(_loc6_.type)
               {
                  case 1:
                     _clothingIconHelper = new SimpleIcon();
                     _clothingIconHelper.init(_loc6_.giftColor,_loc6_.giftId,1,true,false,clothingIconReceived);
                     break;
                  case 3:
                  case 99:
                     _loc1_ = DenXtCommManager.getDenItemDef(_loc6_.giftId);
                     if(!_loc1_)
                     {
                        DarkenManager.showLoadingSpiral(false);
                        return;
                     }
                     _loc7_ = "";
                     _loc5_ = "";
                     if(_loc1_.isMasterpiece)
                     {
                        _loc4_ = _loc6_.additionalGiftData.split("|");
                        if(_loc4_.length == 4)
                        {
                           _loc7_ = _loc4_[0];
                           _loc2_ = int(_loc4_[1]);
                           _loc5_ = _loc4_[2];
                        }
                     }
                     _denIconHelper = new DenItemHelper();
                     _denIconHelper.initGeneric(_loc1_,denIconReceived,0,0,0,_loc7_,_loc2_,_loc5_);
                     break;
                  case 5:
                     _loc3_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc6_.giftId);
                     _mediaHelper = new MediaHelper();
                     _mediaHelper.init(_loc3_.mediaId,onMediaIconReceived);
                     break;
                  case 8:
                     _petBits = PetManager.packPetBits(PetManager.createRandomPet(_loc6_.giftId));
                     _guiPet = new GuiPet(0,0,_petBits[0],_petBits[1],_petBits[2],0,_loc6_.giftName,0,0,0,onPetLoaded);
               }
            }
         }
      }
      
      private function clothingIconReceived() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         var _loc2_:ECard = _inbox[_currCardIdx];
         var _loc1_:Sprite = new Sprite();
         _loc1_.addChild(_clothingIconHelper.iconBitmap);
         _loc1_.x = -_loc1_.width * 0.5;
         _loc1_.y = -_loc1_.height * 0.5;
         setupGiftPopup(_loc1_);
      }
      
      private function denIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Sprite = null;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc3_:Sprite = null;
         if(param1 && param1.displayObject)
         {
            _loc2_ = param1.displayObject;
            _loc4_ = MovieClip(Loader(_loc2_.getChildAt(0)).content);
            _loc5_ = 0;
            while(_loc5_ < _loc4_.currentLabels.length)
            {
               if(_loc4_.currentLabels[_loc5_].name == "icon")
               {
                  _loc4_.gotoAndStop("icon");
                  break;
               }
               _loc5_++;
            }
            _loc6_ = 168 / Math.max(_loc2_.width,_loc2_.height);
            _loc2_.width *= _loc6_;
            _loc2_.height *= _loc6_;
            _loc3_ = new Sprite();
            _loc3_.addChild(_loc2_);
            _loc3_.x = -_loc3_.width * 0.5;
            _loc3_.y = -_loc3_.height * 0.5;
            setupGiftPopup(_loc3_);
         }
      }
      
      private function onMediaIconReceived(param1:MovieClip) : void
      {
         _mediaHelper.destroy();
         _mediaHelper = null;
         if(param1)
         {
            setupGiftPopup(param1);
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _guiPet.scaleX = 3;
         _guiPet.scaleY = 3;
         _guiPet.y += _guiPet.height * 0.5;
         setupGiftPopup(_guiPet);
      }
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:ECard = _inbox[_currCardIdx];
         var _loc3_:Boolean = _loc2_.isFromVoice && _loc2_.additionalGiftData.length > 0 && _loc2_.additionalGiftData.indexOf("|") == -1;
         _giftPopup = new GiftPopup();
         _giftPopup.init(_guiLayer,param1,_loc2_.giftName,_loc2_.giftId,_loc2_.isFromVoice ? 6 : 0,GiftPopup.giftTypeForECardType(_loc2_.type),keepGiftCallback,rejectGiftCallback,destroyGiftPopup,!_loc2_.isFromVoice,GiftPopup.buttonsTypeForECardType(_loc2_.type),_loc2_.secondaryType,null,_loc3_ ? _loc2_.modifiedMsg : null,_petBits);
      }
      
      private function keepGiftCallback() : void
      {
         if((gMainFrame.userInfo.isMember || _inbox[_currCardIdx].isFromVoice) && !gMainFrame.clientInfo.extCallsActive)
         {
            DarkenManager.showLoadingSpiral(true);
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currMsgId,true,onGiftAcceptDismissResponse);
         }
      }
      
      private function rejectGiftCallback() : void
      {
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currMsgId,false,onGiftAcceptDismissResponse);
      }
      
      private function destroyGiftPopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(_guiPet != null)
         {
            _guiPet.destroy();
            _guiPet = null;
         }
         if(_clothingIconHelper != null)
         {
            _clothingIconHelper.destroy();
            _clothingIconHelper = null;
         }
         if(_denIconHelper != null)
         {
            _denIconHelper.destroy();
            _denIconHelper = null;
         }
      }
      
      private function onAcceptBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         if(!BuddyManager.isBuddyListFull())
         {
            ECardXtCommManager.sendECardBuddyRequest(_currMsgId,true);
            if(_currMsgId >= 0)
            {
               onDeleteResponse([_inbox[_currCardIdx].msgId],true);
            }
         }
         else
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      private function onRejectBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         ECardXtCommManager.sendECardBuddyRequest(_currMsgId,false);
         if(_currMsgId >= 0)
         {
            onDeleteResponse([_inbox[_currCardIdx].msgId],true);
         }
      }
      
      private function onChangeEmailBtn(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = null;
         param1.stopPropagation();
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         var _loc3_:String = (_inbox[_currCardIdx] as ECard).msg;
         if(_loc3_ != "" && _loc3_.indexOf("animaljam.com") != -1)
         {
            _loc2_ = new URLRequest((_inbox[_currCardIdx] as ECard).msg);
            navigateToURL(_loc2_,"_self");
         }
         onCancelEmailBtn(param1);
      }
      
      private function onCancelEmailBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
      }
      
      private function onLinkToBtn(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = null;
         param1.stopPropagation();
         var _loc3_:String = "";
         var _loc4_:Boolean = false;
         if(param1.currentTarget.hasOwnProperty("urlCont"))
         {
            _loc3_ = param1.currentTarget.urlCont.txt.text;
            _loc4_ = true;
         }
         if(_loc3_ != "")
         {
            if(_loc4_)
            {
               _externalLinkPopup = new ExternalLinkPopup(_loc3_,onChooseExternalLink);
               return;
            }
            _loc2_ = new URLRequest(_loc3_);
            try
            {
               navigateToURL(_loc2_,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
      }
      
      private function onChooseExternalLink(param1:Boolean, param2:String) : void
      {
         var _loc3_:URLRequest = null;
         if(param1)
         {
            _loc3_ = new URLRequest(param2);
            try
            {
               navigateToURL(_loc3_,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
         _externalLinkPopup.destroy();
         _externalLinkPopup = null;
      }
      
      private function deleteBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         if(_inbox.length > 0)
         {
            if(_inbox[_currCardIdx].isGift)
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14718),true,deleteMessageConfirmCallback);
            }
            else
            {
               deleteMessageConfirmCallback({"status":true});
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            if(_currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function readCurrECard() : void
      {
         var _loc1_:ECard = null;
         if(_currMsgId >= 0)
         {
            _loc1_ = _inbox[_currCardIdx];
            if(_loc1_ && !_loc1_.isRead)
            {
               if(_loc1_.isFromVoice)
               {
                  SBTracker.trackPageview("game/play/ecard/read#" + _loc1_.cardMediaId,-1,1);
               }
               ECardXtCommManager.sendECardReadRequest(_currMsgId,onReadResponse);
            }
         }
      }
      
      private function onReadResponse(param1:int, param2:Boolean) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _inbox.length)
         {
            if(_inbox[_loc3_])
            {
               if(_inbox[_loc3_].msgId == param1)
               {
                  _inbox[_loc3_].isReadInProcess = false;
                  if(param2)
                  {
                     _inbox[_loc3_].isRead = true;
                     ECardManager.unreadCount--;
                     break;
                  }
                  DebugUtility.debugTrace("Error on reading");
                  break;
               }
            }
            _loc3_++;
         }
      }
      
      private function onGiftAcceptDismissResponse(param1:int, param2:Boolean, param3:ECard) : void
      {
         var _loc4_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(param2)
         {
            _loc4_ = 0;
            while(_loc4_ < _inbox.length)
            {
               if(_inbox[_loc4_])
               {
                  if(_inbox[_loc4_].msgId == param1)
                  {
                     _inbox[_loc4_].type = 0;
                     if(_loc4_ == _currCardIdx)
                     {
                        if(_eCardInbox)
                        {
                           _eCardInbox.giftBig.visible = false;
                        }
                        _inboxItemWindows.callUpdateOnWindow(_loc4_);
                     }
                     break;
                  }
               }
               _loc4_++;
            }
         }
         else
         {
            DebugUtility.debugTrace("Error with accepting/dismissing gift");
         }
      }
      
      private function newBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_eCardInbox.newBtn.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14652),_toolTipPositions[_eCardInbox.newBtn].x,_toolTipPositions[_eCardInbox.newBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function replyBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_eCardInbox.replyBtn.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14653),_toolTipPositions[_eCardInbox.replyBtn].x,_toolTipPositions[_eCardInbox.replyBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function deleteBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onECardItemWindowOverOut(param1);
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14654),_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn].x,_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn].y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function newBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_eCardInbox.newBtn.isGray)
         {
            _createCard("","",0);
            if(nextSetCallback != null)
            {
               nextSetCallback(1);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function replyBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_eCardInbox.replyBtn.isGray)
         {
            if(_inbox[_currCardIdx])
            {
               _createCard(_inbox[_currCardIdx].senderUserName,_inbox[_currCardIdx].senderModeratedUserName,_inbox[_currCardIdx].senderSGAccountType,true);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function fromTabHandler(param1:MouseEvent = null) : void
      {
         var _loc4_:String = null;
         var _loc2_:Buddy = null;
         var _loc3_:UserInfo = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_inbox[_currCardIdx].isFromVoice)
         {
            _loc4_ = _inbox[_currCardIdx].senderUserName;
            if(BuddyList.listRequested)
            {
               _loc2_ = BuddyManager.getBuddyByUserName(_loc4_);
               if(_loc2_)
               {
                  BuddyManager.showBuddyCard({
                     "userName":_loc2_.userName,
                     "onlineStatus":_loc2_.onlineStatus
                  });
               }
               else
               {
                  _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_loc4_);
                  if(!_loc3_)
                  {
                     AvatarXtCommManager.requestAvatarGet(_loc4_,onUserLookUpReceived,true);
                  }
                  else
                  {
                     onUserLookUpReceived(_loc4_,true,0);
                  }
               }
            }
            else
            {
               BuddyXtCommManager.sendBuddyListRequest(handleBuddyListFromTabHelper);
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function handleBuddyListFromTabHelper() : void
      {
         fromTabHandler(null);
      }
      
      private function fromTabOverHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_inbox[_currCardIdx].isFromVoice)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14655),_toolTipPositions[_nameBars].x,_toolTipPositions[_nameBars].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function fromTabOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onGiftBigBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         displayGiftPopup();
      }
      
      private function onReportBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_inbox.length > 0)
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
            }
            else
            {
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(2,_guiLayer,onReportAPlayerClose,true,_inbox[_currCardIdx].senderUserName,_inbox[_currCardIdx].senderModeratedUserName,true,null,-1,900 * 0.5,550 * 0.5);
            }
         }
      }
      
      private function onReportOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onECardItemWindowOverOut(param1);
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14633),_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn].x,_toolTipPositions[_eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn].y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onReportOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         if(param1)
         {
            if(_currMsgId >= 0)
            {
               DarkenManager.showLoadingSpiral(true);
               ECardXtCommManager.sendECardDeleteRequest(_currMsgId,ECardManager.onDeleteResponse);
            }
         }
      }
      
      private function windowMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function windowMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function windowMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = _currCardIdx;
         if(param1.currentTarget.index != _loc2_)
         {
            _currCardIdx = param1.currentTarget.index;
            drawCurrECard();
            _inboxItemWindows.callUpdateOnWindow(_loc2_);
            param1.currentTarget.update();
         }
      }
      
      private function onLeftRight(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc2_:* = false;
         var _loc3_:int = 0;
         if(_inbox.length > 0 && !ECardManager.isECardCreationOpen())
         {
            _loc4_ = _currCardIdx;
            if(param1 is KeyboardEvent)
            {
               _loc3_ = int((param1 as KeyboardEvent).keyCode);
               if(!(_loc3_ == 39 || _loc3_ == 37 || _loc3_ == 38 || _loc3_ == 40))
               {
                  return;
               }
               _loc2_ = _loc3_ == 37 || _loc3_ == 38;
            }
            else
            {
               _loc2_ = param1.currentTarget == _eCardInbox.eCardCont.eCard_MouseOver.leftBtn;
            }
            if(_loc2_)
            {
               if(_eCardInbox.eCardCont.eCard_MouseOver.leftBtn.isGray)
               {
                  return;
               }
               if(_currCardIdx - 1 >= 0)
               {
                  _currCardIdx--;
               }
            }
            else
            {
               if(_eCardInbox.eCardCont.eCard_MouseOver.rightBtn.isGray)
               {
                  return;
               }
               if(_currCardIdx + 1 <= _inbox.length - 1)
               {
                  _currCardIdx++;
               }
            }
            if(_currCardIdx != _loc4_)
            {
               _inboxItemWindows.callUpdateOnWindow(_loc4_);
               _inboxItemWindows.callUpdateOnWindow(_currCardIdx);
               _inboxItemWindows.scrollToIndex(_currCardIdx,false);
               drawCurrECard();
            }
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         param1.preventDefault();
         param1.stopPropagation();
         onLeftRight(param1);
      }
      
      private function onChangeEmailButtonsLoaded() : void
      {
         var _loc1_:ECard = null;
         if(_eCardInbox)
         {
            if(_inbox && _inbox[_currCardIdx])
            {
               _loc1_ = _inbox[_currCardIdx];
               if(_loc1_.isEmailReset && _loc1_.changeEmailBtn)
               {
                  setupChangeEmailRequest(_loc1_);
               }
            }
         }
      }
      
      private function setupChangeEmailRequest(param1:ECard) : void
      {
         param1.changeEmailBtn.addEventListener("mouseDown",onChangeEmailBtn,false,0,true);
         param1.cancelEmailBtn.addEventListener("mouseDown",onCancelEmailBtn,false,0,true);
      }
      
      private function onBuddyButtonsLoaded() : void
      {
         var _loc1_:ECard = null;
         if(_eCardInbox)
         {
            if(_inbox && _inbox[_currCardIdx])
            {
               _loc1_ = _inbox[_currCardIdx];
               if(_loc1_.isBuddy && _loc1_.acceptBtn)
               {
                  setupBuddyRequest(_loc1_);
               }
            }
         }
      }
      
      private function onECardItemWindowOverOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_eCardInbox.cardSlot.noMailPopup.visible && (param1 == null || param1.type == "mouseOver"))
         {
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 1;
         }
         else
         {
            _eCardInbox.eCardCont.eCard_MouseOver.alpha = 0;
         }
      }
      
      private function setupBuddyRequest(param1:ECard) : void
      {
         param1.acceptBtn.addEventListener("mouseDown",onAcceptBtn,false,0,true);
         param1.rejectBtn.addEventListener("mouseDown",onRejectBtn,false,0,true);
         param1.nonMemberNameBar.mouseChildren = false;
         param1.nonMemberNameBar.mouseEnabled = false;
         param1.memberNameBar.mouseChildren = false;
         param1.memberNameBar.mouseEnabled = false;
         if(param1.isSenderMember)
         {
            param1.nonMemberNameBar.visible = false;
            param1.memberNameBar.visible = true;
            param1.nonMemberUserName.visible = false;
            param1.nonMemberNameBar.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            param1.memberNameBar.setNubType(NameBar.BUDDY,false);
            param1.memberNameBar.setColorAndBadge(param1.nameBarData);
            param1.memberNameBar.setAvName(param1.senderModeratedUserName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
            param1.memberNameBar.isBlocked = false;
         }
         else
         {
            param1.memberNameBar.visible = false;
            param1.nonMemberNameBar.visible = true;
            param1.nonMemberUserName.text = param1.senderModeratedUserName;
         }
         if(_loadingSpiralAvatar == null)
         {
            _loadingSpiralAvatar = new LoadingSpiral(param1.charBox);
         }
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.senderUserName);
         if(!_loc2_)
         {
            AvatarXtCommManager.requestAvatarGet(param1.senderUserName,onAvatarGetReceived);
         }
         else
         {
            onAvatarGetReceived(param1.senderUserName,true,0);
         }
      }
      
      private function setupLinkToBtnRequest(param1:ECard) : void
      {
         param1.linkToBtn.addEventListener("mouseDown",onLinkToBtn,false,0,true);
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc4_:UserInfo = null;
         var _loc5_:ECard = _inbox[_currCardIdx];
         if(param2 && param1.toLowerCase() == _loc5_.senderUserName.toLowerCase() && _loc5_.isBuddy)
         {
            _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(_loc5_.senderUserName);
            if(_loc4_)
            {
               _buddyRequestAvatar = AvatarManager.getAvatarByUserName(_loc5_.senderUserName);
               if(_buddyRequestAvatar == null)
               {
                  _buddyRequestAvatar = AvatarUtility.generateNew(_loc4_.currPerUserAvId,null,_loc5_.senderUserName,-1,0,onAvatarItemData);
               }
               drawMainAvatar(_buddyRequestAvatar);
            }
         }
      }
      
      private function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _buddyRequestAvatar != null)
         {
            drawMainAvatar(_buddyRequestAvatar);
         }
      }
      
      private function drawMainAvatar(param1:Avatar) : void
      {
         if(_inbox[_currCardIdx].isBuddy)
         {
            _buddyRequestAvatarView = new AvatarView();
            _buddyRequestAvatarView.init(param1);
            if(param1.uuid != "")
            {
               _buddyRequestAvatarView.playAnim(13,false,1,positionAndAddBuddyRequestAvatarView);
            }
         }
      }
      
      private function positionAndAddBuddyRequestAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = null;
         var _loc4_:ECard = null;
         if(_buddyRequestAvatarView)
         {
            _loc3_ = AvatarUtility.getAvOffsetByDefId(_buddyRequestAvatarView.avTypeId);
            _buddyRequestAvatarView.x = _loc3_.x;
            _buddyRequestAvatarView.y = _loc3_.y;
            _loc4_ = _inbox[_currCardIdx];
            if(_loc4_ && _loc4_.isBuddy && _loc4_.charBox)
            {
               _loc4_.charBox.addChild(_buddyRequestAvatarView);
            }
         }
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.visible = false;
         }
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         var _loc5_:ECard = null;
         var _loc4_:UserInfo = null;
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(param2)
         {
            if(param3 != -1)
            {
               _loc5_ = _inbox[_currCardIdx];
               if(!(_loc5_ && !_loc5_.isFromVoice))
               {
                  return;
               }
               _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
               if(_loc4_ != null && _loc4_.nameBarData != _loc5_.nameBarData)
               {
                  _loc5_.nameBarData = _loc4_.nameBarData;
                  _loc5_.memberNameBar.setColorAndBadge(_loc5_.nameBarData);
               }
            }
            BuddyManager.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
      
      private function addListeners() : void
      {
         gMainFrame.stage.addEventListener("keyDown",onKeyDown,false,0,true);
         _eCardInbox.addEventListener("mouseDown",onPopup,false,0,true);
         _eCardInbox.bx.addEventListener("mouseDown",onClose,false,0,true);
         _eCardInbox.eCardCont.addEventListener("mouseOver",onECardItemWindowOverOut,false,0,true);
         _eCardInbox.eCardCont.addEventListener("mouseOut",onECardItemWindowOverOut,false,0,true);
         if(Utility.canBuddy())
         {
            _eCardInbox.newBtn.addEventListener("mouseDown",newBtnHandler,false,0,true);
            _eCardInbox.newBtn.addEventListener("mouseOver",newBtnOverHandler,false,0,true);
            _eCardInbox.newBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseDown",replyBtnHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            _eCardInbox.replyBtn.addEventListener("mouseOver",replyBtnOverHandler,false,0,true);
         }
         else
         {
            _eCardInbox.newBtn.activateGrayState(true);
            _eCardInbox.replyBtn.activateGrayState(true);
         }
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseDown",deleteBtnHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseOver",deleteBtnOverHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseDown",onReportBtn,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseOver",onReportOver,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.addEventListener("mouseOut",onReportOut,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.addEventListener("mouseDown",onLeftRight,false,0,true);
         _nameBars.addEventListener("mouseDown",fromTabHandler,false,0,true);
         _nameBars.addEventListener("mouseOver",fromTabOverHandler,false,0,true);
         _nameBars.addEventListener("mouseOut",fromTabOutHandler,false,0,true);
         _eCardInbox.giftBig.addEventListener("mouseDown",onGiftBigBtn,false,0,true);
         _eCardInbox.settingsBtn.addEventListener("mouseDown",onSettingsBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         gMainFrame.stage.removeEventListener("keyDown",onKeyDown);
         _eCardInbox.removeEventListener("mouseDown",onPopup);
         _eCardInbox.bx.removeEventListener("mouseDown",onClose);
         _eCardInbox.eCardCont.addEventListener("mouseOver",onECardItemWindowOverOut);
         _eCardInbox.eCardCont.addEventListener("mouseOut",onECardItemWindowOverOut);
         if(Utility.canBuddy())
         {
            _eCardInbox.newBtn.removeEventListener("mouseDown",newBtnHandler);
            _eCardInbox.newBtn.removeEventListener("mouseOver",newBtnOverHandler);
            _eCardInbox.newBtn.removeEventListener("mouseOut",btnOutHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseDown",replyBtnHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseOut",btnOutHandler);
            _eCardInbox.replyBtn.removeEventListener("mouseOver",replyBtnOverHandler);
         }
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseDown",deleteBtnHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseOver",deleteBtnOverHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.deleteMessageBtn.removeEventListener("mouseOut",btnOutHandler);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseDown",onReportBtn);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseOver",onReportOver);
         _eCardInbox.eCardCont.eCard_MouseOver.reportMessageBtn.removeEventListener("mouseOut",onReportOut);
         _eCardInbox.eCardCont.eCard_MouseOver.leftBtn.addEventListener("mouseDown",onLeftRight);
         _eCardInbox.eCardCont.eCard_MouseOver.rightBtn.addEventListener("mouseDown",onLeftRight);
         _nameBars.removeEventListener("mouseOver",fromTabOverHandler);
         _nameBars.removeEventListener("mouseOut",fromTabOutHandler);
         _eCardInbox.giftBig.removeEventListener("mouseDown",onGiftBigBtn);
         _eCardInbox.settingsBtn.removeEventListener("mouseDown",onSettingsBtn);
      }
   }
}

