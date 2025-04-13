package gui
{
   import Enums.DenItemDef;
   import achievement.Achievement;
   import achievement.AchievementXtCommManager;
   import adoptAPet.AdoptAPetManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import buddy.BuddyList;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gameRedemption.GameRedemptionXtCommManager;
   import giftPopup.GiftPopup;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Circular;
   import gskinner.motion.easing.Quadratic;
   import inventory.Iitem;
   import item.SimpleIcon;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   
   public class StartupPopups
   {
      public static const EXPIRING_MESSAGE:int = 1953;
      
      public static const PROMOTION_CODE:int = 1068;
      
      public static const WELCOME_POPUP:int = 85;
      
      public static const NEW_MEMBER:int = 117;
      
      public static const DEMOTION_MESSAGE:int = 156;
      
      public static const PLAYER_ENGAGEMENT:int = 1567;
      
      public static const GEMS_MEDIA_ID:int = 1086;
      
      public static const DIAMOND_MEDIA_ID:int = 2221;
      
      public static const DIAMOND_ANIMAL_REDEEM_ID:int = 2254;
      
      public static const JOEY_MEDIA_ID:int = 2541;
      
      public static var HAS_LOADED_STARTUP_POPUPS:Boolean;
      
      private var _loadTheseMediaItems:Array;
      
      private var _mediaViews:Array;
      
      private var _popupImages:Array;
      
      private var _popupLayer:DisplayLayer;
      
      private var _imageBeingLoaded:Boolean;
      
      private var _numMediaItemsLoaded:int;
      
      private var _expiringPopup:ExpiringDaysPopup;
      
      private var _welcomePopup:MovieClip;
      
      private var _newMemberPopup:MovieClip;
      
      private var _welcomeRoomURI:String;
      
      private var _redemptionList:Array;
      
      private var _currRedemECard:ECard;
      
      private var _clothingIconHelper:SimpleIcon;
      
      private var _denIconHelper:DenItemHelper;
      
      private var _avtView:AvatarView;
      
      private var _redeemItem:Iitem;
      
      private var _bulkItemData:Object;
      
      private var _bulkGiftAccept:BulkItemAcceptPopup;
      
      private var _extendingMembershipJAGMsgId:int;
      
      private var _numDiamondsReceiving:int;
      
      private var _numDiamondRefundsReceiving:int;
      
      private var _diamondECards:Array;
      
      private var _diamondRedeemPopup:MovieClip;
      
      private var _numGemsReceiving:int;
      
      private var _gemECards:Array;
      
      private var _adoptAPetCardsReceiving:Array;
      
      private var _newMemberECardTypes:Array;
      
      private var _numJumpGemsReceiving:int;
      
      private var _jumpGemsECards:Array;
      
      private var _checkRedemptionsOnly:Boolean;
      
      private var _closeCallback:Function;
      
      private var _showFirstAdoptAPetPopup:Boolean;
      
      private var _hasRedeemedAvatar:Boolean;
      
      private var _numBulkItems:int;
      
      private var _reRequestRedemptionCards:Boolean;
      
      public function StartupPopups()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function, param3:Boolean = false) : void
      {
         _popupLayer = param1;
         _loadTheseMediaItems = [];
         _mediaViews = [];
         _popupImages = [];
         _redemptionList = [];
         _diamondECards = [];
         _jumpGemsECards = [];
         _gemECards = [];
         _newMemberECardTypes = [];
         _imageBeingLoaded = false;
         _closeCallback = param2;
         _checkRedemptionsOnly = param3;
         RoomManagerWorld.instance.callback_InitialDataRequest = requestInitialData;
         if((gMainFrame.clientInfo.numRedemptionCards > 0 || gMainFrame.clientInfo.numAJHQBulkGiftCards > 0 || !gMainFrame.userInfo.isMember && gMainFrame.clientInfo.numAJHQGiftCards > 0 || _checkRedemptionsOnly) && !gMainFrame.clientInfo.invisiMode)
         {
            DarkenManager.showLoadingSpiral(true);
            ECardManager.isFirstTime = false;
            _loadTheseMediaItems.push(1068);
            ECardXtCommManager.sendECardListRequest(redemptionCardsRequest);
         }
         else
         {
            setupAndLoadAllPopups();
         }
      }
      
      public function setupInGameRedemption() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _loadTheseMediaItems = [];
         _mediaViews = [];
         _popupImages = [];
         _redemptionList = [];
         _diamondECards = [];
         _jumpGemsECards = [];
         _gemECards = [];
         _newMemberECardTypes = [];
         _adoptAPetCardsReceiving = null;
         _imageBeingLoaded = false;
         _checkRedemptionsOnly = true;
         ECardManager.isFirstTime = false;
         _numMediaItemsLoaded = 0;
         _loadTheseMediaItems.push(1068);
         ECardXtCommManager.sendECardListRequest(redemptionCardsRequest);
      }
      
      public function setNeedsToLoadAdditional() : void
      {
         _reRequestRedemptionCards = true;
      }
      
      private function setupAndLoadAllPopups() : void
      {
         var _loc2_:MediaHelper = null;
         var _loc1_:int = 0;
         if(!_checkRedemptionsOnly)
         {
            if(gMainFrame.clientInfo.accountType != 4 && Boolean(gMainFrame.userInfo.isMember) && gMainFrame.clientInfo.numDaysLeftOnSubscription > -1 && gMainFrame.clientInfo.numDaysLeftOnSubscription < 7 && GuiManager.sharedObj && (GuiManager.sharedObj.data.expiration == null || GuiManager.sharedObj.data.expiration + 86400000 <= new Date().millisecondsUTC))
            {
               _loadTheseMediaItems.push(1953);
            }
            if(gMainFrame.clientInfo.accountTypeChanged && gMainFrame.userInfo.isMember || _extendingMembershipJAGMsgId > 0)
            {
               gMainFrame.clientInfo.accountTypeChanged = false;
               _newMemberECardTypes.push(null);
               _loadTheseMediaItems.push(117);
            }
            if(!gMainFrame.userInfo.isMember && AvatarSwitch.availSlotFlags == 0)
            {
               _loadTheseMediaItems.push(156);
            }
         }
         else if(gMainFrame.clientInfo.accountTypeChanged && gMainFrame.userInfo.isMember || _extendingMembershipJAGMsgId > 0)
         {
            gMainFrame.clientInfo.accountTypeChanged = false;
            _newMemberECardTypes.push(null);
            _loadTheseMediaItems.push(117);
         }
         _loc1_ = 0;
         while(_loc1_ < _loadTheseMediaItems.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(_loadTheseMediaItems[_loc1_],popupsMediaCallback,_loc1_);
            _mediaViews[_loc1_] = _loc2_;
            _loc1_++;
         }
         if(_loadTheseMediaItems.length == 0)
         {
            DarkenManager.showLoadingSpiral(false);
            HAS_LOADED_STARTUP_POPUPS = true;
            requestInitialData();
            destroy();
         }
      }
      
      private function popupsMediaCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            _numMediaItemsLoaded++;
            _popupImages[param1.passback] = param1;
            if(_numMediaItemsLoaded >= _loadTheseMediaItems.length)
            {
               loadNextPopup();
            }
         }
      }
      
      public function requestInitialData() : void
      {
         if(gMainFrame.clientInfo.hasOnlineBuddies && Utility.canBuddy())
         {
            BuddyList.startBuddyListBtnGlow();
         }
         if(_loadTheseMediaItems.length == 0)
         {
            if(gMainFrame.userInfo.isMember && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
            {
               AchievementXtCommManager.requestSetUserVar(Achievement.MEMBER_NEW,1);
            }
            GameRedemptionXtCommManager.checkIfHasGiftInOtherDomain(GuiManager.guiStartupChecks,_checkRedemptionsOnly);
         }
         if(gMainFrame.clientInfo.numUnreadECards > 0)
         {
            ECardManager.unreadCount = gMainFrame.clientInfo.numUnreadECards;
         }
      }
      
      public function setWelcomeRoomName(param1:String) : void
      {
         _welcomeRoomURI = param1;
      }
      
      private function destroy() : void
      {
         var _loc1_:int = 0;
         SBTracker.flush();
         if(_welcomeRoomURI)
         {
            SBTracker.trackPageview(_welcomeRoomURI);
         }
         if(_mediaViews)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaViews.length)
            {
               _mediaViews[_loc1_].destroy();
               _mediaViews[_loc1_] = null;
               _loc1_++;
            }
         }
         RoomManagerWorld.instance.callback_InitialDataRequest = null;
         _welcomePopup = null;
         _newMemberPopup = null;
         if(_expiringPopup)
         {
            _expiringPopup.destroy();
            _expiringPopup = null;
         }
         _imageBeingLoaded = false;
         _loadTheseMediaItems = null;
         _mediaViews = null;
         _popupImages = null;
         _newMemberECardTypes = null;
         _adoptAPetCardsReceiving = null;
         _hasRedeemedAvatar = false;
         _numMediaItemsLoaded = 0;
         if(_clothingIconHelper != null)
         {
            _clothingIconHelper.destroy();
            _clothingIconHelper = null;
         }
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
         HAS_LOADED_STARTUP_POPUPS = true;
      }
      
      private function loadNextPopup(param1:Boolean = true) : void
      {
         if(!_loadTheseMediaItems)
         {
            return;
         }
         if(_loadTheseMediaItems.length > 0 && _popupImages.length > 0 && !_imageBeingLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            if(_popupImages[0])
            {
               switch(_loadTheseMediaItems[0])
               {
                  case 1068:
                     _imageBeingLoaded = true;
                     _currRedemECard = _redemptionList[0];
                     if(_currRedemECard)
                     {
                        if(!_currRedemECard.isBulkItem)
                        {
                           SBTracker.push();
                           SBTracker.trackPageview("/game/play/popup/promotionCode/#" + _currRedemECard.msg,-1,1);
                        }
                        loadRedemptionImage(_currRedemECard);
                     }
                     break;
                  case 1953:
                     _imageBeingLoaded = true;
                     SBTracker.push();
                     SBTracker.trackPageview("/game/play/popup/expiration/" + gMainFrame.clientInfo.numDaysLeftOnSubscription);
                     _expiringPopup = new ExpiringDaysPopup(_popupLayer,popupCloseHandler,_popupImages[0]);
                     break;
                  case 85:
                     _imageBeingLoaded = true;
                     createWelcomePopup(_popupImages[0]);
                     break;
                  case 117:
                     _imageBeingLoaded = true;
                     SBTracker.push();
                     SBTracker.trackPageview("/game/play/popup/newMember",-1,1);
                     createNewMemberPopup(_popupImages[0]);
                     break;
                  case 156:
                     _imageBeingLoaded = true;
                     SBTracker.push();
                     SBTracker.trackPageview("/game/play/popup/demotion/page1");
                     createDemotionPopup(_popupImages[0]);
                     break;
                  case 1567:
                     _imageBeingLoaded = true;
                     SBTracker.trackPageview("/game/play/popup/playerEngagement",-1,1);
                     createPlayerEngagement(_popupImages[0]);
               }
               if(_imageBeingLoaded)
               {
                  _loadTheseMediaItems.splice(0,1);
                  _popupImages.splice(0,1);
               }
            }
         }
         else if(_loadTheseMediaItems.length == 0)
         {
            if(_reRequestRedemptionCards)
            {
               _reRequestRedemptionCards = false;
               setupInGameRedemption();
               return;
            }
            if(_hasRedeemedAvatar)
            {
               AvatarXtCommManager.requestAvatarList([gMainFrame.userInfo.myUserName],AvatarSwitch.updateAfterRedeemingAvatar);
            }
            if(gMainFrame.userInfo.isMember && gMainFrame.userInfo.userVarCache.getUserVarValueById(Achievement.MEMBER_NEW) == -1)
            {
               AchievementXtCommManager.requestSetUserVar(Achievement.MEMBER_NEW,1);
            }
            destroy();
            if(param1)
            {
               GameRedemptionXtCommManager.checkIfHasGiftInOtherDomain(GuiManager.guiStartupChecks,_checkRedemptionsOnly);
            }
         }
      }
      
      private function redemptionCardsRequest(param1:Array) : void
      {
         var _loc3_:ECard = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_.isRedemptionJAG)
            {
               if(_loc3_.isBulkItem)
               {
                  _numBulkItems++;
               }
               if(_loc3_.type == 7)
               {
                  _extendingMembershipJAGMsgId = _loc3_.msgId;
                  _redemptionList.push(_loc3_);
                  _newMemberECardTypes.push(_loc3_);
               }
               else if(_loc3_.type == 13)
               {
                  _redemptionList.push(_loc3_);
                  _loadTheseMediaItems.push(117);
                  _newMemberECardTypes.push(_loc3_);
               }
               else if(_loc3_.type == 9)
               {
                  if(_loc3_.giftColor != 0)
                  {
                     _redemptionList.push(_loc3_);
                  }
                  else
                  {
                     if(_numDiamondRefundsReceiving != 0 || _numDiamondsReceiving != 0)
                     {
                        _diamondECards.push(_loc3_);
                     }
                     else
                     {
                        _redemptionList.push(_loc3_);
                     }
                     if(_loc3_.stampMediaId == 2)
                     {
                        _numDiamondRefundsReceiving += _loc3_.giftId;
                     }
                     else
                     {
                        _numDiamondsReceiving += _loc3_.giftId;
                     }
                  }
               }
               else if(_loc3_.type == 4)
               {
                  if(_loc3_.stampMediaId == 1)
                  {
                     if(_numJumpGemsReceiving == 0)
                     {
                        _redemptionList.push(_loc3_);
                     }
                     else
                     {
                        _jumpGemsECards.push(_loc3_);
                     }
                     _numJumpGemsReceiving += _loc3_.giftId;
                  }
                  else
                  {
                     if(_numGemsReceiving != 0)
                     {
                        _gemECards.push(_loc3_);
                     }
                     else
                     {
                        _redemptionList.push(_loc3_);
                     }
                     _numGemsReceiving += _loc3_.giftId;
                  }
               }
               else if(_loc3_.type == 12)
               {
                  if(_adoptAPetCardsReceiving == null)
                  {
                     _adoptAPetCardsReceiving = [];
                     _redemptionList.push(_loc3_);
                  }
                  else
                  {
                     _adoptAPetCardsReceiving.push(_loc3_);
                  }
               }
               else
               {
                  _redemptionList.push(_loc3_);
               }
            }
            _loc2_++;
         }
         if(_redemptionList.length <= 0)
         {
            _loc2_ = 0;
            while(_loc2_ < _loadTheseMediaItems.length)
            {
               if(_loadTheseMediaItems[_loc2_] == 1068)
               {
                  _loadTheseMediaItems.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
         setupAndLoadAllPopups();
      }
      
      private function createWelcomePopup(param1:MovieClip) : void
      {
         if(param1)
         {
            _welcomePopup = param1;
            _welcomePopup.getChildAt(0)["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
            _welcomePopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _welcomePopup.x = 900 * 0.5;
            _welcomePopup.y = 550 * 0.5;
            _popupLayer.addChild(_welcomePopup);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_welcomePopup);
         }
      }
      
      private function createNewMemberPopup(param1:MovieClip) : void
      {
         var _loc3_:ECard = null;
         var _loc2_:Boolean = false;
         var _loc4_:int = 0;
         if(param1)
         {
            _loc3_ = _newMemberECardTypes.shift();
            _loc4_ = -1;
            if(_loc3_ != null)
            {
               if(_loc3_.type == 13)
               {
                  _loc2_ = true;
                  if(_loc3_.giftColor == 30)
                  {
                     _loc4_ = 33758;
                  }
               }
            }
            else
            {
               _loc2_ = false;
            }
            _newMemberPopup = MovieClip(param1.getChildAt(0)).newMemberPopup;
            _newMemberPopup.gotoAndStop("page1");
            _newMemberPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _newMemberPopup.bx.addEventListener("mouseDown",popupCloseHandler,false,0,true);
            _newMemberPopup.parent.parent.x = 900 * 0.5;
            _newMemberPopup.parent.parent.y = 550 * 0.5;
            _popupLayer.addChild(_newMemberPopup.parent.parent);
            _newMemberPopup.scaleY = 0.1;
            _newMemberPopup.scaleX = 0.1;
            new GTween(_newMemberPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":onNewMemberTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_newMemberPopup.parent.parent);
            if(_loc2_)
            {
               _newMemberPopup.gotoAndStop("page4");
               if(_loc4_ != -1)
               {
                  LocalizationManager.translateId(_newMemberPopup.description,_loc4_);
               }
            }
            LocalizationManager.findAllTextfields(_newMemberPopup);
            if(_newMemberPopup.featuresBtn)
            {
               _newMemberPopup.featuresBtn.addEventListener("mouseDown",newMemberFeaturesBtn,false,0,true);
            }
            if(_newMemberPopup.playNowBtn)
            {
               _newMemberPopup.playNowBtn.addEventListener("mouseDown",popupCloseHandler,false,0,true);
            }
         }
      }
      
      private function onDiamondRedeemPopupLoaded(param1:MovieClip) : void
      {
         var _loc4_:Avatar = null;
         var _loc2_:AvatarView = null;
         var _loc3_:Point = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _diamondRedeemPopup = MovieClip(param1.getChildAt(0));
            _diamondRedeemPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _diamondRedeemPopup.saveBtn.addEventListener("mouseDown",onSaveDiamonds,false,0,true);
            _diamondRedeemPopup.redeemBtn.addEventListener("mouseDown",onRedeemDiamonds,false,0,true);
            _diamondRedeemPopup.diamondItem = DiamondXtCommManager.getDiamondItem(param1.passback.diamondDef);
            _diamondRedeemPopup.numDiamondsReceived = param1.passback.numDiamondsReceived;
            _loc4_ = AvatarUtility.findCreationAvatarByType(_diamondRedeemPopup.diamondItem.refDefId,-1);
            _loc2_ = new AvatarView();
            _loc2_.init(_loc4_);
            _loc2_.playAnim(13,false,1,null);
            if(_diamondRedeemPopup)
            {
               _diamondRedeemPopup.avatarName = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_diamondRedeemPopup.diamondItem.refDefId,false).titleStrRef);
               LocalizationManager.translateIdAndInsert(_diamondRedeemPopup.txt,11385,_diamondRedeemPopup.avatarName);
            }
            _loc3_ = AvatarUtility.getAnimalItemWindowOffset(_diamondRedeemPopup.diamondItem.refDefId);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            _diamondRedeemPopup.itemLayer.addChild(_loc2_);
            _diamondRedeemPopup.x = 900 * 0.5;
            _diamondRedeemPopup.y = 550 * 0.5;
            _popupLayer.addChild(_diamondRedeemPopup);
            DarkenManager.darken(_diamondRedeemPopup);
         }
      }
      
      private function destroyDiamondRedeemPopup(param1:MouseEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
            SBOkPopup.destroyInParentChain(param1.target.parent);
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currRedemECard.msgId,false,onGiftAcceptRejectResponse,-1,_currRedemECard);
         _diamondRedeemPopup.removeEventListener("mouseDown",popupMouseDownHandler);
         _diamondRedeemPopup.saveBtn.removeEventListener("mouseDown",onSaveDiamonds);
         _diamondRedeemPopup.redeemBtn.removeEventListener("mouseDown",onRedeemDiamonds);
         _loc2_ = 0;
         while(_loc2_ < _diamondRedeemPopup.itemLayer.numChildren)
         {
            _loc3_ = _diamondRedeemPopup.itemLayer.getChildAt(0);
            if(_loc3_ is AvatarView)
            {
               _loc3_.destroy(true);
               _loc3_ = null;
               break;
            }
            _loc2_++;
         }
         DarkenManager.unDarken(_diamondRedeemPopup);
         _popupLayer.removeChild(_diamondRedeemPopup);
         _diamondRedeemPopup = null;
         _imageBeingLoaded = false;
      }
      
      private function onAcceptCloseDiamondRefundPopup() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _diamondECards.length)
         {
            if(_diamondECards[_loc1_].stampMediaId == 2)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_diamondECards[_loc1_].msgId,true,onGiftAcceptRejectResponse,-1,_diamondECards[_loc1_]);
               _diamondECards.splice(0,1);
            }
            _loc1_++;
         }
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currRedemECard.msgId,false,onGiftAcceptRejectResponse,-1,null);
         _imageBeingLoaded = false;
      }
      
      private function onNewMemberTweenComplete(param1:GTween) : void
      {
         new GTween(_newMemberPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
      
      private function createPlayerEngagement(param1:MovieClip) : void
      {
         GuiManager.initPlayerEngagement(loadNextPopup);
      }
      
      private function createDemotionPopup(param1:MovieClip) : void
      {
         GuiManager.initDemotionMessage(loadNextPopup);
      }
      
      private function checkRedemptionStatus() : void
      {
         GuiManager.destroyPromotionalPopup();
         _redemptionList.splice(0,1);
         if(_redemptionList.length > 0)
         {
            DarkenManager.showLoadingSpiral(true);
            _currRedemECard = _redemptionList[0];
            if(!_currRedemECard.isBulkItem)
            {
               SBTracker.push();
               SBTracker.trackPageview("/game/play/popup/promotionCode/#" + _currRedemECard.msg,-1,1);
            }
            loadRedemptionImage(_currRedemECard);
         }
         else
         {
            _imageBeingLoaded = false;
            loadNextPopup();
         }
      }
      
      private function setupGiftPopup(param1:Sprite) : void
      {
         var _loc4_:String = null;
         var _loc7_:Array = null;
         var _loc3_:String = "";
         var _loc6_:String = _currRedemECard.msg;
         var _loc5_:DenItemDef = null;
         if(!isNaN(parseInt(_loc6_)))
         {
            _loc6_ = LocalizationManager.translateIdOnly(int(_loc6_));
            if(_currRedemECard.isFromVoice)
            {
               if(_loc6_.indexOf("%s") != -1)
               {
                  _loc6_ = LocalizationManager.translateIdAndInsertOnly(parseInt(_currRedemECard.msg),_currRedemECard.additionalGiftData);
               }
            }
         }
         if(_currRedemECard.type == 5 || _currRedemECard.type == 6 || _currRedemECard.type == 10)
         {
            _loc7_ = _loc6_.split("|");
            if(_loc7_.length == 5)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(int(_loc7_[1]),LocalizationManager.translateIdOnly(int(_loc7_[2])),Utility.convertNumberToString(int(_loc7_[3])),LocalizationManager.translateIdOnly(int(_loc7_[4])));
            }
            else if(_loc7_.length == 4)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(int(_loc7_[1]),LocalizationManager.translateIdOnly(int(_loc7_[2])),LocalizationManager.translateIdOnly(int(_loc7_[3])));
            }
            else if(_loc7_.length == 3)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(int(_loc7_[1]),LocalizationManager.translateIdOnly(int(_loc7_[2])));
            }
            _loc4_ = _currRedemECard.giftName;
         }
         else if(_currRedemECard.type == 3)
         {
            _loc5_ = DenXtCommManager.getDenItemDef(_currRedemECard.giftId);
            _loc4_ = _currRedemECard.giftName;
         }
         else if(_currRedemECard.type == 9)
         {
            _loc4_ = LocalizationManager.translateIdAndInsertOnly(_numDiamondsReceiving > 1 ? 11103 : 11116,_numDiamondsReceiving);
         }
         else if(_currRedemECard.type == 7)
         {
            if(_currRedemECard.stampMediaId == 3)
            {
               _loc4_ = LocalizationManager.translateIdOnly(32469);
            }
            else
            {
               _loc4_ = LocalizationManager.translateIdOnly(32528);
            }
         }
         else if(_currRedemECard.type == 13)
         {
            _loc4_ = LocalizationManager.translateIdOnly(32528);
         }
         else if(_currRedemECard.type == 4)
         {
            _loc4_ = LocalizationManager.translateIdAndInsertOnly(_numGemsReceiving > 1 ? 11097 : 11114,_numGemsReceiving);
         }
         else
         {
            _loc4_ = _currRedemECard.giftName;
         }
         var _loc2_:int = _currRedemECard.isAJHQGift ? 6 : (_loc5_ != null && _loc5_.promoType == DenItemDef.PROMO_TYPE_MCD ? 20 : 1);
         if(_currRedemECard.isBulkItem)
         {
            if(_bulkItemData == null)
            {
               _bulkItemData = {
                  "images":[param1],
                  "giftNames":[_loc4_],
                  "eCards":[_currRedemECard]
               };
            }
            else
            {
               _bulkItemData.images.push(param1);
               _bulkItemData.giftNames.push(_loc4_);
               _bulkItemData.eCards.push(_currRedemECard);
            }
            if(_bulkGiftAccept)
            {
               _bulkGiftAccept.updateAndInsertLatest(_bulkItemData);
            }
            if(_bulkItemData.images.length == Math.min(100,_numBulkItems))
            {
               _numBulkItems -= 100;
               if(_bulkGiftAccept)
               {
                  _bulkGiftAccept.showGrayStateOnKeepBtn(false);
                  DarkenManager.showLoadingSpiral(false);
               }
            }
            else
            {
               checkRedemptionStatus();
            }
         }
         else if(_currRedemECard.stampMediaId == 3)
         {
            if(_extendingMembershipJAGMsgId > 0)
            {
               _loc6_ = LocalizationManager.translateIdOnly(32397);
            }
            else
            {
               _loc6_ = LocalizationManager.translateIdOnly(32509);
            }
            GuiManager.openReferGiftPopup(param1,_loc4_,_currRedemECard.giftId,_currRedemECard.type,keepGiftCallback,rejectGiftCallback,onGiftPopupClose,GiftPopup.buttonsTypeForECardType(_currRedemECard.type),_loc3_,_loc2_,_loc6_,true,_redeemItem);
         }
         else
         {
            GuiManager.openGiftPopup(param1,_loc4_,_currRedemECard.giftId,_currRedemECard.type,keepGiftCallback,rejectGiftCallback,onGiftPopupClose,GiftPopup.buttonsTypeForECardType(_currRedemECard.type,_loc5_ != null ? _loc5_.promoType : 0,_redeemItem != null ? _redeemItem.enviroType : 0),_loc3_,_loc2_,_loc6_,true,_redeemItem);
         }
      }
      
      private function setupBulkGiftPopup() : void
      {
         if(_bulkGiftAccept == null)
         {
            _bulkGiftAccept = new BulkItemAcceptPopup();
            _bulkGiftAccept.init(_bulkItemData,Math.min(100,_numBulkItems),onBulkGiftAccept);
         }
      }
      
      private function onBulkGiftAccept() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _bulkGiftAccept.destroy();
         _bulkGiftAccept = null;
         ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_bulkItemData.eCards[0].msgId,true,onBulkGiftAcceptResponse);
         (_bulkItemData.eCards as Array).splice(0,1);
      }
      
      private function onBulkGiftAcceptResponse(param1:int, param2:Boolean, param3:ECard) : void
      {
         ECardManager.onDeleteResponse([param1],true);
         if(_bulkItemData && _bulkItemData.eCards.length > 0)
         {
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_bulkItemData.eCards[0].msgId,true,onBulkGiftAcceptResponse);
            (_bulkItemData.eCards as Array).splice(0,1);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            _bulkItemData = null;
            if(!GuiManager.closePromoPopup())
            {
               checkRedemptionStatus();
            }
         }
      }
      
      private function onGiftPopupClose() : void
      {
         _redeemItem = null;
         checkRedemptionStatus();
      }
      
      private function keepGiftCallback(param1:int = -1) : void
      {
         keepRejectResponse(true,param1);
      }
      
      private function rejectGiftCallback() : void
      {
         keepRejectResponse(false);
      }
      
      private function keepRejectResponse(param1:Boolean, param2:int = -1, param3:ECard = null) : void
      {
         var _loc5_:int = 0;
         DarkenManager.showLoadingSpiral(true);
         var _loc4_:Boolean = true;
         if(_currRedemECard.type == 9)
         {
            _loc5_ = 0;
            while(_loc5_ < _diamondECards.length)
            {
               if(_diamondECards[_loc5_].stampMediaId != 2)
               {
                  if(_diamondECards[_loc5_].msgId == _currRedemECard.msgId)
                  {
                     _loc4_ = false;
                  }
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_diamondECards[_loc5_].msgId,param1,onGiftAcceptRejectResponse,-1,_diamondECards[_loc5_]);
               }
               _loc5_++;
            }
            _diamondECards = null;
            _numDiamondsReceiving = 0;
         }
         else if(_currRedemECard.type == 4)
         {
            if(_currRedemECard.stampMediaId == 1)
            {
               _loc5_ = 0;
               while(_loc5_ < _jumpGemsECards.length)
               {
                  if(_jumpGemsECards[_loc5_].msgId == _currRedemECard.msgId)
                  {
                     _loc4_ = false;
                  }
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_jumpGemsECards[_loc5_].msgId,param1,onGiftAcceptRejectResponse,-1,_jumpGemsECards[_loc5_]);
                  _loc5_++;
               }
               _jumpGemsECards = null;
               _numJumpGemsReceiving = 0;
            }
            else
            {
               _loc5_ = 0;
               while(_loc5_ < _gemECards.length)
               {
                  if(_gemECards[_loc5_].msgId == _currRedemECard.msgId)
                  {
                     _loc4_ = false;
                  }
                  ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_gemECards[_loc5_].msgId,param1,onGiftAcceptRejectResponse,-1,_gemECards[_loc5_]);
                  _loc5_++;
               }
               _gemECards = null;
               _numGemsReceiving = 0;
            }
         }
         else if(_currRedemECard.type == 12)
         {
            _loc5_ = 0;
            while(_loc5_ < _adoptAPetCardsReceiving.length)
            {
               if(_adoptAPetCardsReceiving[_loc5_].msgId == _currRedemECard.msgId)
               {
                  _loc4_ = false;
               }
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_adoptAPetCardsReceiving[_loc5_].msgId,param1,onGiftAcceptRejectResponse,-1,_adoptAPetCardsReceiving[_loc5_]);
               _loc5_++;
            }
            _adoptAPetCardsReceiving = null;
         }
         if(_loc4_)
         {
            ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_currRedemECard.msgId,param1,onGiftAcceptRejectResponse,param2,param3);
         }
      }
      
      private function onGiftAcceptRejectResponse(param1:int, param2:Boolean, param3:ECard) : void
      {
         var _loc4_:int = 0;
         DarkenManager.showLoadingSpiral(false);
         ECardManager.onDeleteResponse([param1],true);
         if(param3)
         {
            if(_currRedemECard.type == 4)
            {
               return;
            }
            if(_currRedemECard.type == 12)
            {
               return;
            }
            if(param3.type == 9)
            {
               if(param3.stampMediaId == 2 || param3.stampMediaId == 0 || param3.stampMediaId == 3)
               {
                  return;
               }
            }
            else if(param3.type == 13)
            {
               if(!param2)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _loadTheseMediaItems.length)
                  {
                     if(_loadTheseMediaItems[_loc4_] == 117)
                     {
                        _loadTheseMediaItems.splice(_loc4_,1);
                        break;
                     }
                     _loc4_++;
                  }
               }
            }
         }
         if(!GuiManager.closePromoPopup())
         {
            checkRedemptionStatus();
         }
      }
      
      private function onExtendingMembershipResponse(param1:int, param2:Boolean, param3:ECard) : void
      {
         ECardManager.onDeleteResponse([param1],true);
      }
      
      private function loadRedemptionImage(param1:ECard) : void
      {
         var _loc4_:Array = null;
         var _loc10_:String = null;
         var _loc2_:int = 0;
         var _loc8_:String = null;
         var _loc9_:MediaHelper = null;
         var _loc3_:Object = null;
         var _loc5_:MediaHelper = null;
         var _loc11_:Avatar = null;
         var _loc7_:int = 0;
         var _loc6_:MediaHelper = null;
         if(param1.isBulkItem)
         {
            setupBulkGiftPopup();
         }
         if(param1.type == 1)
         {
            _clothingIconHelper = new SimpleIcon();
            _clothingIconHelper.init(param1.giftColor,param1.giftId,1,true,false,clothingIconReceived);
         }
         else if(param1.type == 3 || param1.type == 99)
         {
            _loc4_ = param1.additionalGiftData.split("|");
            _loc10_ = "";
            _loc8_ = "";
            if(_loc4_.length == 3)
            {
               _loc10_ = _loc4_[0];
               _loc2_ = int(_loc4_[1]);
               _loc8_ = _loc4_[2];
            }
            _redeemItem = new DenItem();
            (_redeemItem as DenItem).initShopItem(param1.giftId,param1.giftColor);
            (_redeemItem as DenItem).imageLoadedCallback = onDenItemLoaded;
            (_redeemItem as DenItem).icon;
         }
         else if(param1.type == 4 || param1.type == 9)
         {
            _loc9_ = new MediaHelper();
            if(param1.giftColor != 0)
            {
               _loc9_.init(2254,onDiamondRedeemPopupLoaded,{
                  "diamondDef":param1.giftColor,
                  "numDiamondsReceived":param1.giftId
               });
               _mediaViews.push(_loc9_);
            }
            else if(param1.stampMediaId == 2)
            {
               Utility.setupDiamondRefundPopup(_popupLayer,_numDiamondRefundsReceiving,onAcceptCloseDiamondRefundPopup);
            }
            else
            {
               _loc9_.init(param1.type == 4 ? 1086 : 2221,onMediaHelperIconReceived,param1.stampMediaId);
               _mediaViews.push(_loc9_);
            }
         }
         else if(param1.type == 5)
         {
            _loc3_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1.giftId);
            if(!_loc3_)
            {
               trace("Error loading image for denRoomDefId=" + param1.giftId);
               return;
            }
            _loc5_ = new MediaHelper();
            _loc5_.init(_loc3_.mediaId,onMediaHelperIconReceived);
            _mediaViews.push(_loc5_);
         }
         else if(param1.type == 6 || param1.type == 10)
         {
            _loc11_ = null;
            if(param1.type == 10)
            {
               _loc11_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId,true);
            }
            else
            {
               _loc11_ = AvatarManager.getDefaultAvatarByDefId(param1.giftId);
            }
            if(_loc11_ == null)
            {
               trace("Error loading avatar using avDefId=" + param1.giftId);
               return;
            }
            _avtView = new AvatarView();
            _avtView.init(_loc11_);
            _avtView.playAnim(13,false,1,avatarViewReceived);
            _hasRedeemedAvatar = true;
         }
         else if(param1.type == 8)
         {
            if(param1.stampMediaId == 1)
            {
               GuiManager.openJumpPopup(true,onJumpPopupClose,null,param1.giftId);
            }
            else
            {
               PetManager.openPetFinder(PetManager.petNameForDefId(param1.giftId),onPetCreateClose,true);
            }
         }
         else if(param1.type == 12)
         {
            if(!AdoptAPetManager.hasAtLeastOneUsableAdoptAPet)
            {
               AdoptAPetManager.shouldShowFirstAdoptAPetPopup = true;
            }
            AdoptAPetManager.setUsableAdoptAPetDef(param1.giftId);
            _loc7_ = 0;
            while(_loc7_ < _adoptAPetCardsReceiving.length)
            {
               AdoptAPetManager.setUsableAdoptAPetDef(_adoptAPetCardsReceiving[_loc7_].giftId);
               _loc7_++;
            }
            keepGiftCallback();
         }
         else if(param1.type == 7)
         {
            _loc6_ = new MediaHelper();
            _loc6_.init(7163,onSubscriptionMediaHelper);
            _mediaViews.push(_loc6_);
         }
         else if(param1.type == 13)
         {
            keepRejectResponse(true,-1,param1);
         }
         else
         {
            keepRejectResponse(true);
         }
      }
      
      private function onSubscriptionMediaHelper(param1:MovieClip) : void
      {
         if(_currRedemECard.stampMediaId != 3)
         {
            param1.scaleY = 2;
            param1.scaleX = 2;
         }
         setupGiftPopup(param1);
      }
      
      private function avatarViewReceived(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Sprite = new Sprite();
         _loc3_.addChild(_avtView);
         var _loc4_:Point = AvatarUtility.getAvOffsetByDefId(_avtView.avTypeId);
         _avtView.x = _loc4_.x;
         _avtView.y = _loc4_.y;
         setupGiftPopup(_loc3_);
      }
      
      private function clothingIconReceived() : void
      {
         var _loc2_:LayerBitmap = _clothingIconHelper.iconBitmap;
         var _loc1_:Sprite = new Sprite();
         var _loc3_:Number = 168 / Math.max(_loc2_.width,_loc2_.height);
         _loc2_.width *= _loc3_;
         _loc2_.height *= _loc3_;
         _loc1_.addChild(_loc2_);
         _loc1_.x = -_loc1_.width * 0.5;
         _loc1_.y = -_loc1_.height * 0.5;
         setupGiftPopup(_loc1_);
      }
      
      private function onDenItemLoaded() : void
      {
         (_redeemItem as DenItem).imageLoadedCallback = null;
         setupGiftPopup(_redeemItem.icon);
      }
      
      private function onMediaHelperIconReceived(param1:MovieClip) : void
      {
         if(param1.passback == 1)
         {
            GuiManager.openJumpPopup(false,onJumpPopupClose,param1,_numJumpGemsReceiving);
         }
         else
         {
            setupGiftPopup(param1);
         }
      }
      
      private function onJumpPopupClose(param1:Boolean, param2:int, param3:MovieClip = null) : void
      {
         if(param1)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(param2),onPetCreateClose,true);
         }
         else
         {
            keepGiftCallback();
         }
      }
      
      private function onPetCreateClose(param1:Boolean) : void
      {
         if(!GuiManager.closePromoPopup())
         {
            checkRedemptionStatus();
         }
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.parent)
         {
            _loc2_ = param1.currentTarget.root;
            if(_extendingMembershipJAGMsgId > 0)
            {
               ECardXtCommManager.sendECardAcceptDiscardGiftRequest(_extendingMembershipJAGMsgId,false,onExtendingMembershipResponse);
               _extendingMembershipJAGMsgId = 0;
            }
            DarkenManager.unDarken(_loc2_);
            _popupLayer.removeChild(_loc2_);
            _loc2_.visible = false;
            _loc2_ = null;
            _imageBeingLoaded = false;
            loadNextPopup();
         }
      }
      
      private function popupMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function newMemberFeaturesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/newMemberFeatures",-1,1);
         _newMemberPopup.gotoAndStop("page2");
         LocalizationManager.findAllTextfields(_newMemberPopup);
         if(_newMemberPopup.featuresBtn)
         {
            _newMemberPopup.featuresBtn.addEventListener("mouseDown",newMemberFeaturesBtn,false,0,true);
         }
         if(_newMemberPopup.playNowBtn)
         {
            _newMemberPopup.playNowBtn.addEventListener("mouseDown",popupCloseHandler,false,0,true);
         }
      }
      
      private function onRenew(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
         var _loc3_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc2_:URLRequest = new URLRequest(_loc3_);
         try
         {
            navigateToURL(_loc2_,"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function onSaveDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14802,_diamondRedeemPopup.numDiamondsReceived),true,destroyDiamondRedeemPopup);
      }
      
      private function onRedeemDiamonds(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AvatarSwitch.addAvatar(AvatarSwitch.avatars.length,false,onAvatarAdded,false,false,false,_diamondRedeemPopup.diamondItem.refDefId,true,172,_diamondRedeemPopup.diamondItem.defId);
      }
      
      private function onAvatarAdded(param1:int) : void
      {
         if(param1 == 1)
         {
            destroyDiamondRedeemPopup();
         }
         else if(param1 == -1)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(11382,_diamondRedeemPopup.avatarName),true,destroyDiamondRedeemPopup);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(11225),true,destroyDiamondRedeemPopup);
         }
      }
   }
}

