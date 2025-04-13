package buddy
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.UserInfo;
   import collection.IitemCollection;
   import com.sbi.bit.BitUtility;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import localization.LocalizationManager;
   import playerWall.PlayerWallManager;
   
   public class BuddyManager
   {
      private static const MAX_BUDDY_COUNT_IMMORTAL:int = 1000;
      
      private static const MAX_BUDDY_COUNT_MORTAL:int = 200;
      
      private static const WARNING_BUDDY_COUNT_REMAINING:int = 5;
      
      private static const PERMISSION_TIMEOUT:int = 20000;
      
      private static const BUDDY_REQUEST_TIMEOUT:int = 30000;
      
      private static var _numOnlineBuddies:int;
      
      private static var _buddyList:Dictionary;
      
      private static var _blockedList:Dictionary;
      
      private static var _buddyRequestList:Dictionary;
      
      private static var _buddyRequestCleanupTimer:Timer;
      
      private static var _buddyRequestPopups:Dictionary;
      
      private static var _confirmBuddyRequestPopups:Dictionary;
      
      private static var _eventDispatcher:EventDispatcher;
      
      private static var _mainHud:MovieClip;
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _timeSinceLastHostingUpdate:Number;
      
      private static var _buddyCard:BuddyCard;
      
      private static var _buddyCardCloseCallback:Function;
      
      public function BuddyManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip) : void
      {
         _buddyList = new Dictionary(false);
         _blockedList = new Dictionary(false);
         _buddyRequestList = new Dictionary(false);
         _buddyRequestPopups = new Dictionary(false);
         _confirmBuddyRequestPopups = new Dictionary(false);
         _timeSinceLastHostingUpdate = 0;
         _popupLayer = param1;
         _eventDispatcher = new EventDispatcher();
         BuddyList.init(_popupLayer,param2);
         _buddyRequestCleanupTimer = new Timer(30000);
         _buddyRequestCleanupTimer.addEventListener("timer",buddyRequestCleanupTimerHandler,false,0,true);
         _buddyRequestCleanupTimer.start();
      }
      
      public static function destroy() : void
      {
         _buddyList = null;
         _blockedList = null;
         _buddyRequestList = null;
         _buddyRequestPopups = null;
         _confirmBuddyRequestPopups = null;
         _eventDispatcher = null;
         _buddyList = null;
         _blockedList = null;
         if(_buddyCard)
         {
            _buddyCard.destroy();
         }
         BuddyList.destroy();
      }
      
      public static function heartbeat(param1:int) : void
      {
         _timeSinceLastHostingUpdate += param1 / 1000;
         if(_timeSinceLastHostingUpdate >= 10)
         {
            for each(var _loc2_ in _buddyList)
            {
               _loc2_.timeLeftHostingCustomParty -= 10;
            }
            BuddyList.updateBuddyTimeLeftHosting();
            _timeSinceLastHostingUpdate = 0;
         }
      }
      
      public static function get eventDispatcher() : EventDispatcher
      {
         return _eventDispatcher;
      }
      
      public static function isBuddy(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return _buddyList[param1.toLowerCase()] != null;
      }
      
      public static function isBlocked(param1:String) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         return _blockedList[param1.toLowerCase()] != null;
      }
      
      public static function getBuddyByUserName(param1:String) : Buddy
      {
         return _buddyList[param1.toLowerCase()];
      }
      
      public static function get buddyCount() : int
      {
         var _loc1_:int = 0;
         for(var _loc2_ in _buddyList)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public static function showBuddyCard(param1:Object, param2:Boolean = false, param3:Function = null) : void
      {
         if("userName" in param1)
         {
            if(_buddyCard)
            {
               if(_buddyCard.currBuddyCardUserName == param1.userName)
               {
                  DarkenManager.showLoadingSpiral(false);
                  return;
               }
               _buddyCard.destroy();
            }
            _buddyCardCloseCallback = param3;
            _buddyCard = new BuddyCard();
            _buddyCard.init(param1,param2,destroyBuddyCard);
         }
      }
      
      public static function destroyBuddyCard() : void
      {
         if(_buddyCard)
         {
            if(_buddyCardCloseCallback != null)
            {
               _buddyCardCloseCallback();
               _buddyCardCloseCallback = null;
            }
            _buddyCard.destroy();
            _buddyCard = null;
         }
      }
      
      public static function avatarLeftRoom(param1:String) : void
      {
         if(_buddyCard)
         {
            _buddyCard.avatarLeftRoom(param1);
         }
      }
      
      public static function updateCurrBuddyCardAvatar(param1:Avatar = null) : void
      {
         if(_buddyCard)
         {
            _buddyCard.updateCurrBuddyCardAvatar(param1);
         }
      }
      
      public static function grayOutGoToDenBtn(param1:Boolean, param2:String = "") : void
      {
         if(_buddyCard)
         {
            _buddyCard.grayOutGoToDenBtn(param1,param2);
         }
      }
      
      public static function resetBuddyCardForArchiveMode(param1:String) : void
      {
         if(_buddyCard)
         {
            _buddyCard.resetBuddyCardForArchiveMode(param1);
         }
      }
      
      public static function onTradeListReceived(param1:String, param2:IitemCollection) : void
      {
         if(_buddyCard)
         {
            _buddyCard.onTradeListReceived(param1,param2);
         }
      }
      
      public static function getTradeListFromBuddyCard() : IitemCollection
      {
         if(_buddyCard)
         {
            return _buddyCard.getTradeList();
         }
         return null;
      }
      
      public static function buddyBlockInfoResponseHandler(param1:String, param2:Boolean) : void
      {
         if(_buddyCard)
         {
            _buddyCard.buddyBlockInfoResponseHandler(param1,param2);
         }
      }
      
      public static function buddyRoomResponseHandler(param1:String, param2:String, param3:int, param4:Boolean) : void
      {
         if(_buddyCard)
         {
            _buddyCard.buddyRoomResponseHandler(param1,param2,param3,param4);
         }
      }
      
      public static function setPlayerWallLoading(param1:Boolean) : void
      {
         if(_buddyCard)
         {
            _buddyCard.setPlayerWallLoading(param1);
         }
      }
      
      public static function onDenPrivacyResponse(param1:String, param2:int) : void
      {
         if(_buddyCard)
         {
            _buddyCard.onDenPrivacyResponse(param1,param2);
         }
      }
      
      public static function joinBuddyInQuest() : Boolean
      {
         if(_buddyCard)
         {
            return _buddyCard.joinBuddyInQuest();
         }
         return false;
      }
      
      public static function addRemoveBuddy(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc6_:String = null;
         var _loc5_:Object = null;
         if(gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         if(param3)
         {
            _loc6_ = param1.toLowerCase();
            if(!isBuddyListFull())
            {
               _loc5_ = _buddyRequestList[_loc6_];
               if(_loc5_ == null || _loc5_.expires < new Date().getTime())
               {
                  if(isBlocked(_loc6_))
                  {
                     new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(33251,param2),true,onConfirmRemoveBlockAndAddBuddy,param1);
                     return;
                  }
                  BuddyXtCommManager.sendBuddyAddRequest(param1);
                  _buddyRequestList[_loc6_] = {
                     "userName":param1,
                     "expires":new Date().getTime() + 30000,
                     "isAccepting":true
                  };
               }
               else
               {
                  if(_buddyRequestList[_loc6_] != null)
                  {
                     if(!_buddyRequestList[_loc6_].isAccepting)
                     {
                        _buddyRequestPopups[_loc6_] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,param2));
                        return;
                     }
                  }
                  _buddyRequestPopups[_loc6_] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,param2));
               }
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
            }
         }
         else
         {
            BuddyXtCommManager.sendBuddyDeleteRequest(param1);
            delete PlayerWallManager.tokenMap[param1.toLowerCase()];
         }
      }
      
      private static function onConfirmRemoveBlockAndAddBuddy(param1:Object) : void
      {
         if(param1.status)
         {
            if(_buddyCard != null)
            {
               _buddyCard.buddyCardRemoveIgnoreConfirmCallback(param1,true);
            }
            else
            {
               BuddyXtCommManager.sendBuddyUnblockRequest(param1.passback,true);
            }
         }
      }
      
      private static function buddyAddRequestCallback(param1:Object) : void
      {
         var _loc2_:Timer = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].timer;
         if(_loc2_)
         {
            _loc2_.reset();
            _loc2_ = null;
         }
         var _loc3_:BuddyRequest = _confirmBuddyRequestPopups[param1.passback.toLowerCase()].popup;
         if(_loc3_)
         {
            _loc3_.destroy();
            _loc3_ = null;
         }
         delete _confirmBuddyRequestPopups[param1.passback.toLowerCase()];
         if(gMainFrame.clientInfo.extCallsActive)
         {
            BuddyXtCommManager.sendBuddyConfirmRequest(param1.passback,false);
         }
         else if(!isBuddyListFull())
         {
            BuddyXtCommManager.sendBuddyConfirmRequest(param1.passback,param1.status);
         }
         else
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
         }
      }
      
      public static function buddyListResponseHandler(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc11_:Buddy = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc4_:int = 0;
         var _loc12_:int = 0;
         var _loc14_:int = 0;
         var _loc13_:Buddy = null;
         var _loc2_:String = null;
         var _loc17_:String = null;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         _buddyList = new Dictionary(true);
         var _loc3_:int = 3;
         var _loc15_:int = int(param1[_loc3_++]);
         _loc6_ = 0;
         while(_loc6_ < _loc15_)
         {
            _loc11_ = new Buddy();
            _loc9_ = param1[_loc3_++];
            _loc10_ = param1[_loc3_++];
            _loc4_ = int(param1[_loc3_++]);
            _loc12_ = int(param1[_loc3_++]);
            _loc14_ = int(param1[_loc3_++]);
            _loc11_.init(_loc9_,_loc10_,_loc4_,1,_loc12_,_loc14_);
            _buddyList[_loc9_.toLowerCase()] = _loc11_;
            _loc6_++;
         }
         var _loc7_:int = int(param1[_loc3_++]);
         _loc6_ = 0;
         while(_loc6_ < _loc7_)
         {
            _loc13_ = new Buddy();
            _loc2_ = param1[_loc3_++];
            _loc17_ = param1[_loc3_++];
            _loc8_ = int(param1[_loc3_++]);
            _loc5_ = int(param1[_loc3_++]);
            _loc13_.init(_loc2_,_loc17_,_loc8_,0,_loc5_);
            _buddyList[_loc2_.toLowerCase()] = _loc13_;
            _loc6_++;
         }
         BuddyList.listRequested = true;
         var _loc16_:BuddyEvent = new BuddyEvent("OnBuddyList");
         _eventDispatcher.dispatchEvent(_loc16_);
      }
      
      public static function blockedListResponseHandler(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 3;
         var _loc2_:int = int(param1[_loc3_++]);
         _blockedList = new Dictionary(true);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _blockedList[param1[_loc3_++].toLowerCase()] = "1";
            _loc4_++;
         }
      }
      
      public static function buddyAddRequestResponseHandler(param1:int, param2:String, param3:int) : void
      {
         var _loc4_:AvatarInfo = null;
         var _loc5_:BuddyTimer = null;
         var _loc6_:String = param3 > 0 ? param2 : LocalizationManager.translateIdOnly(11098);
         if(param1 == 0)
         {
            if(!_buddyList[param2.toLowerCase()])
            {
               _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(param2);
               _loc5_ = new BuddyTimer(30000);
               _loc5_.userName = param2.toLowerCase();
               _loc5_.addEventListener("timer",confirmPopupTimerHandler,false,0,true);
               _confirmBuddyRequestPopups[param2.toLowerCase()] = {
                  "popup":new BuddyRequest(param2,buddyAddRequestCallback,1),
                  "timer":_loc5_
               };
               _loc5_.start();
            }
         }
         else if(param1 == 1)
         {
            _buddyRequestPopups[param2.toLowerCase()] = new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14707,_loc6_));
         }
         else if(param1 == 2)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14710,_loc6_));
         }
         else if(param1 == 3)
         {
            if(_buddyRequestList[param2.toLowerCase()] != null)
            {
               _buddyRequestList[param2.toLowerCase()].isAccepting = false;
            }
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14706,_loc6_));
         }
         else if(param1 == 4)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(14708));
         }
         else if(param1 == 5)
         {
            new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(33252,_loc6_));
         }
      }
      
      public static function buddyStatusResponseHandler(param1:String, param2:String, param3:int, param4:Boolean, param5:int, param6:int, param7:String = null, param8:String = null, param9:int = -1, param10:int = -1) : void
      {
         var _loc12_:AvatarInfo = null;
         var _loc14_:String = null;
         DebugUtility.debugTrace("buddyStatusResponseHandler - userName:" + param1 + ",uuid:" + param2 + ",userNameModerationFlag:" + param3 + ",isOnline:" + param4 + ",accountTypeId:" + param5 + ",buddyFlag:" + param6 + ",newUserName:" + param7 + ",avName:" + param8 + ",perUserAvId:" + param9 + ",timeLeftHostingCustomParty:" + param10);
         var _loc13_:String = param1.toLowerCase();
         var _loc15_:Buddy = _buddyList[_loc13_];
         var _loc11_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1);
         if(!_loc11_)
         {
            _loc11_ = new UserInfo();
            _loc11_.init(param1,param2);
            _loc11_.userNameModeratedFlag = param3;
            _loc11_.timeLeftHostingCustomParty = param10;
            gMainFrame.userInfo.setUserInfoByUserName(param1,_loc11_);
         }
         _loc11_.accountType = param5;
         if(param8)
         {
            _loc12_ = _loc11_.getAvatarInfoByPerUserAvId(param9);
            if(param9 > 0)
            {
               if(!_loc12_)
               {
                  _loc12_ = new AvatarInfo();
                  _loc12_.init(param9,-1,param8,param1,param2);
                  _loc11_.addAvatarToList(_loc12_);
               }
               _loc11_.currPerUserAvId = param9;
            }
         }
         if(param6 != 3 && param6 != 4)
         {
            if(_loc15_)
            {
               _loc15_.userName = param1;
               _loc15_.userNameModeratedFlag = param3;
               _loc15_.timeLeftHostingCustomParty = param10;
               if(_loc15_.isOnline && !param4)
               {
                  _numOnlineBuddies--;
               }
               else if(!_loc15_.isOnline && param4)
               {
                  if(Utility.canBuddy())
                  {
                     BuddyList.startBuddyListBtnGlow();
                  }
                  _numOnlineBuddies++;
               }
               _loc15_.onlineStatus = param4 ? 1 : 0;
            }
            else
            {
               _loc15_ = new Buddy();
               _loc15_.init(param1,param2,param3,param4 ? 1 : 0,param5,param10);
               _buddyList[_loc13_] = _loc15_;
               if(param6 == 1)
               {
                  if(_buddyRequestPopups[_loc13_] != null)
                  {
                     _buddyRequestPopups[_loc13_].destroy();
                     delete _buddyRequestPopups[_loc13_];
                  }
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,2));
               }
               else if(param6 == 2)
               {
                  SBPopupManager.nonSBPopups.push(new BuddyRequest(param1,null,2));
               }
            }
         }
         else
         {
            if(_loc15_)
            {
               _loc15_.userName = param7;
               _loc15_.userNameModeratedFlag = param3;
               _loc15_.timeLeftHostingCustomParty = param10;
               if(_loc15_.isOnline && !param4)
               {
                  _numOnlineBuddies--;
               }
               else if(!_loc15_.isOnline && param4)
               {
                  BuddyList.startBuddyListBtnGlow();
                  _numOnlineBuddies++;
               }
               _loc15_.onlineStatus = param4 ? 1 : 0;
               delete _buddyList[_loc13_];
               _buddyList[param7.toLowerCase()] = _loc15_;
               if(_buddyCard)
               {
                  _buddyCard.userNameChange(param1,param7,_loc15_.userNameModerated);
               }
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
            }
            if(isBlocked(_loc13_))
            {
               _loc14_ = param3 > 0 ? param7 : LocalizationManager.translateIdOnly(11098);
               if(_buddyCard)
               {
                  _buddyCard.userNameChange(param1,param7,_loc14_);
               }
               gMainFrame.userInfo.changeUserName(param1,param7,param3);
               param1 = param7;
               delete _blockedList[_loc13_];
               _blockedList[param7.toLowerCase()] = "1";
            }
         }
         var _loc16_:BuddyEvent = new BuddyEvent("OnBuddyChanged");
         _loc16_.userName = param1;
         _eventDispatcher.dispatchEvent(_loc16_);
      }
      
      public static function buddyDeleteResponseHandler(param1:String) : void
      {
         var _loc3_:BuddyEvent = null;
         var _loc2_:String = param1.toLowerCase();
         if(_buddyList[_loc2_])
         {
            delete _buddyList[_loc2_];
            delete _buddyRequestList[_loc2_];
            _loc3_ = new BuddyEvent("OnBuddyChanged");
            _loc3_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc3_);
         }
      }
      
      public static function buddyBlockResponseHandler(param1:String, param2:Boolean) : void
      {
         var _loc3_:BuddyEvent = null;
         if(param2)
         {
            _blockedList[param1.toLowerCase()] = "1";
            _loc3_ = new BuddyEvent("OnBuddyChanged");
            _loc3_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc3_);
         }
      }
      
      public static function buddyUnblockResponseHandler(param1:String, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc5_:BuddyEvent = null;
         var _loc4_:UserInfo = null;
         if(param2)
         {
            delete _blockedList[param1.toLowerCase()];
            _loc5_ = new BuddyEvent("OnBuddyChanged");
            _loc5_.userName = param1;
            _eventDispatcher.dispatchEvent(_loc5_);
            if(param3)
            {
               _loc4_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
               if(_loc4_)
               {
                  addRemoveBuddy(param1,_loc4_.getModeratedUserName(),true);
               }
            }
         }
      }
      
      public static function get buddyList() : Dictionary
      {
         return _buddyList;
      }
      
      public static function get blockedList() : Dictionary
      {
         return _blockedList;
      }
      
      public static function avatarListResponse() : void
      {
         var _loc1_:BuddyEvent = new BuddyEvent("OnBuddyList");
         BuddyManager.eventDispatcher.dispatchEvent(_loc1_);
      }
      
      public static function getMaxBuddyCount() : int
      {
         return gMainFrame.userInfo.isMember || BitUtility.isBitSetForNumber(1,gMainFrame.userInfo.pendingFlags) ? 1000 : 200;
      }
      
      public static function isBuddyListFull() : Boolean
      {
         return buddyCount >= getMaxBuddyCount();
      }
      
      public static function hasOnlineBuddies() : Boolean
      {
         for each(var _loc1_ in buddyList)
         {
            if(_loc1_.isOnline)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function getRemainingBuddyCount() : int
      {
         return getMaxBuddyCount() - buddyCount;
      }
      
      public static function warnAboutBuddyCount() : Boolean
      {
         return getRemainingBuddyCount() <= 5;
      }
      
      private static function buddyRequestCleanupTimerHandler(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         for each(var _loc2_ in _buddyRequestList)
         {
            _loc3_ = _loc2_.userName.toLowerCase();
            if(_loc2_ == null || _loc2_.expires < new Date().getTime())
            {
               delete _buddyRequestList[_loc3_];
               if(_buddyRequestPopups[_loc3_] != null)
               {
                  delete _buddyRequestPopups[_loc3_];
               }
            }
         }
      }
      
      private static function confirmPopupTimerHandler(param1:TimerEvent) : void
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc2_:BuddyTimer = BuddyTimer(param1.currentTarget);
         if(_loc2_)
         {
            _loc3_ = _loc2_.userName;
            _loc2_.stop();
            _loc2_ = null;
            _loc4_ = _confirmBuddyRequestPopups[_loc3_];
            if(_loc4_ != null)
            {
               if(_loc4_.popup)
               {
                  _loc4_.popup.destroy();
                  _loc4_.popup = null;
               }
               delete _confirmBuddyRequestPopups[_loc3_];
            }
         }
      }
   }
}

