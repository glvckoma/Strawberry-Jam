package buddy
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.system.System;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowBuddyList;
   import gui.itemWindows.ItemWindowNameBar;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ReferAFriend
   {
      private static var _code:String = "";
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _hasClearedNameTxt:Boolean;
      
      private var _originalNameTxt:String;
      
      private var _gameLaunchObj:Object;
      
      private var _popup:MovieClip;
      
      private var _referAFriendPopup:MovieClip;
      
      private var _referralLevelsInfoPopup:MovieClip;
      
      private var _myReferrals:MovieClip;
      
      private var _linkPopup:MovieClip;
      
      private var _referralsList:Array;
      
      private var _referralsLoadingSpiral:LoadingSpiral;
      
      private var _itemWindowReferralList:WindowAndScrollbarGenerator;
      
      private var _pageRequested:int;
      
      private var _pageSizeRequested:int;
      
      private var _allowMoreReferralRequests:Boolean;
      
      private var _waitingForRequestAndInsertToComplete:Boolean;
      
      public function ReferAFriend(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _pageRequested = 1;
         _pageSizeRequested = 8;
         _allowMoreReferralRequests = true;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5305,onPopupLoaded);
      }
      
      public static function get code() : String
      {
         return _code;
      }
      
      private static function referralListClickOnReferralHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         BuddyManager.showBuddyCard({
            "userName":param1.currentTarget.userName,
            "onlineStatus":0
         });
         GuiManager.toolTip.resetTimerAndSetVisibility();
         AJAudio.playSubMenuBtnClick();
      }
      
      private static function referralListOverReferralHandler(param1:MouseEvent) : void
      {
         (param1.currentTarget as ItemWindowBuddyList).showRecycleBtn(true);
      }
      
      private static function referralListOutReferralHandler(param1:MouseEvent) : void
      {
         (param1.currentTarget as ItemWindowBuddyList).showRecycleBtn(false);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_popup);
         if(_popup.parent && _popup.parent == GuiManager.guiLayer)
         {
            GuiManager.guiLayer.removeChild(_popup);
         }
         if(_itemWindowReferralList)
         {
            _itemWindowReferralList.destroy();
            _itemWindowReferralList = null;
         }
         if(_referralsLoadingSpiral)
         {
            _referralsLoadingSpiral.destroy();
            _referralsLoadingSpiral = null;
         }
         _closeCallback = null;
         _referralLevelsInfoPopup = null;
         _referAFriendPopup = null;
         _myReferrals = null;
         _linkPopup = null;
         _popup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         _popup = MovieClip(param1.getChildAt(0));
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _mediaHelper.destroy();
         _mediaHelper = null;
         _referAFriendPopup = _popup.referAFriendCont;
         _referAFriendPopup.visible = false;
         _referralLevelsInfoPopup = _popup.referralLevels;
         _referralLevelsInfoPopup.visible = false;
         _myReferrals = _popup.myReferrals;
         _myReferrals.visible = false;
         setupTreasuresAndProgress();
         addEventListeners();
         if(_code == null || _code == "")
         {
            ReferAFriendXtCommManager.sendCodeRequest(onCodeRequestComplete);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            GuiManager.guiLayer.addChild(_popup);
            DarkenManager.darken(_popup);
         }
      }
      
      private function setupTreasuresAndProgress() : void
      {
         var _loc3_:int = 0;
         var _loc2_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(461));
         if(_loc2_ > 0)
         {
            _popup.treasure0.gotoAndStop("open");
         }
         var _loc1_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(462));
         if(_loc1_ != -1)
         {
            _loc3_ = 0;
            while(_loc3_ < 3)
            {
               if((_loc1_ >> _loc3_ & 1) == 1)
               {
                  _popup.progressMeter.normalBar.width -= 165 + (_loc3_ > 0 ? 47 : 0);
                  _popup["treasure" + (_loc3_ + 1)].gotoAndStop("open");
               }
               _loc3_++;
            }
         }
      }
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.referAFriendBtn.addEventListener("mouseDown",onReferAFriend,false,0,true);
         _popup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _popup.myReferralsBtn.addEventListener("mouseDown",onReferralsBtn,false,0,true);
         _popup.level1.addEventListener("mouseDown",onLevelBtn,false,0,true);
         _popup.level2.addEventListener("mouseDown",onLevelBtn,false,0,true);
         _popup.level3.addEventListener("mouseDown",onLevelBtn,false,0,true);
         _popup.level4.addEventListener("mouseDown",onLevelBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.referAFriendBtn.removeEventListener("mouseDown",onReferAFriend);
         _popup.bx.removeEventListener("mouseDown",onCloseBtn);
         _popup.myReferralsBtn.removeEventListener("mouseDown",onReferralsBtn);
         _popup.level1.removeEventListener("mouseDown",onLevelBtn);
         _popup.level2.removeEventListener("mouseDown",onLevelBtn);
         _popup.level3.removeEventListener("mouseDown",onLevelBtn);
         _popup.level4.removeEventListener("mouseDown",onLevelBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onReferAFriend(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _referAFriendPopup.visible = true;
         addReferAFriendEventListeners();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
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
      
      private function onLevelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         switch(param1.currentTarget)
         {
            case _popup.level1:
               _referralLevelsInfoPopup.gotoAndStop(1);
               break;
            case _popup.level2:
               _referralLevelsInfoPopup.gotoAndStop(2);
               break;
            case _popup.level3:
               _referralLevelsInfoPopup.gotoAndStop(3);
               break;
            case _popup.level4:
               _referralLevelsInfoPopup.gotoAndStop(4);
         }
         LocalizationManager.findAllTextfields(_referralLevelsInfoPopup);
         _referralLevelsInfoPopup.visible = true;
         addLevelEventListeners();
      }
      
      private function addLevelEventListeners() : void
      {
         _referralLevelsInfoPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _referralLevelsInfoPopup.bx.addEventListener("mouseDown",onCloseLevelInfoBtn,false,0,true);
      }
      
      private function removeLevelEventListeners() : void
      {
         _referralLevelsInfoPopup.removeEventListener("mouseDown",onPopup);
         _referralLevelsInfoPopup.bx.removeEventListener("mouseDown",onCloseLevelInfoBtn);
      }
      
      private function onCloseLevelInfoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _referralLevelsInfoPopup.visible = false;
         removeLevelEventListeners();
      }
      
      private function addReferralsPopupEventListeners() : void
      {
         _myReferrals.addEventListener("mouseDown",onPopup,false,0,true);
         _myReferrals.bx.addEventListener("mouseDown",onCloseReferralsPopup,false,0,true);
      }
      
      private function removeReferralsPopupEventListeners() : void
      {
         _myReferrals.removeEventListener("mouseDown",onPopup);
         _myReferrals.bx.removeEventListener("mouseDown",onCloseReferralsPopup);
      }
      
      private function onCloseReferralsPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onReferralsBtn(param1);
      }
      
      private function onReferralsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _myReferrals.visible = !_myReferrals.visible;
         if(_myReferrals.visible)
         {
            addReferralsPopupEventListeners();
            _referralsLoadingSpiral = new LoadingSpiral(_myReferrals.itemBlock,_myReferrals.itemBlock.width / 2,_myReferrals.itemBlock.height / 2);
            buildReferralsList();
         }
         else
         {
            removeReferralsPopupEventListeners();
         }
      }
      
      private function buildReferralsList() : void
      {
         if(_referralsList)
         {
            buildReferralsWindows();
         }
         else
         {
            _waitingForRequestAndInsertToComplete = true;
            ReferAFriendXtCommManager.sendReferralReferralsRequest(onReferralsListResponse,_pageRequested,_pageSizeRequested);
         }
      }
      
      private function onReferralsListResponse(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = [];
         var _loc8_:int = int(param1[2]);
         if(_loc8_ == 1)
         {
            _loc2_ = JSON.parse(param1[3]);
            if(_loc2_ != null)
            {
               _loc6_ = _loc2_.referrals;
               _allowMoreReferralRequests = _loc6_.length >= _pageRequested * _pageSizeRequested;
               _myReferrals.counterTxt.text = _loc6_.length + (_allowMoreReferralRequests ? "+" : "");
               _loc5_ = 0;
               while(_loc5_ < _loc6_.length)
               {
                  if(_loc6_[_loc5_].hasOwnProperty("moderatedUserName"))
                  {
                     _loc7_ = _loc6_[_loc5_].moderatedUserName;
                  }
                  else
                  {
                     _loc7_ = "#11098";
                  }
                  if(_loc6_[_loc5_].hasOwnProperty("namebarData"))
                  {
                     _loc4_ = int(_loc6_[_loc5_].namebarData);
                  }
                  else
                  {
                     _loc4_ = 0;
                  }
                  _loc3_.push({
                     "isMember":(_loc6_[_loc5_].account_type == "Non-Member" ? false : true),
                     "nameBarData":_loc4_,
                     "userName":_loc6_[_loc5_].name,
                     "moderatedUserName":LocalizationManager.translateLocalizedId(_loc7_).text,
                     "avName":LocalizationManager.translateLocalizedId(_loc6_[_loc5_].name).text,
                     "isBuddy":BuddyManager.isBuddy(_loc6_[_loc5_].name),
                     "isBlocked":BuddyManager.isBlocked(_loc6_[_loc5_].name)
                  });
                  _loc5_++;
               }
            }
         }
         else
         {
            _allowMoreReferralRequests = false;
         }
         _waitingForRequestAndInsertToComplete = false;
         _referralsList = _loc3_;
         buildReferralsWindows();
      }
      
      private function onReferralsListPaginationResponse(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = [];
         var _loc8_:int = int(param1[2]);
         if(_loc8_ == 1)
         {
            _loc2_ = JSON.parse(param1[3]);
            if(_loc2_ != null)
            {
               _loc6_ = _loc2_.referrals;
               _allowMoreReferralRequests = _loc6_.length >= _pageRequested * _pageSizeRequested;
               _myReferrals.counterTxt.text = _referralsList.length + _loc6_.length + (_allowMoreReferralRequests ? "+" : "");
               _loc5_ = 0;
               while(_loc5_ < _loc6_.length)
               {
                  if(_loc6_[_loc5_].hasOwnProperty("moderatedUserName"))
                  {
                     _loc7_ = _loc6_[_loc5_].moderatedUserName;
                  }
                  else
                  {
                     _loc7_ = "#11098";
                  }
                  if(_loc6_[_loc5_].hasOwnProperty("namebarData"))
                  {
                     _loc4_ = int(_loc6_[_loc5_].namebarData);
                  }
                  else
                  {
                     _loc4_ = 0;
                  }
                  _loc3_.push({
                     "isMember":(_loc6_[_loc5_].account_type == "Non-Member" ? false : true),
                     "nameBarData":_loc4_,
                     "userName":_loc6_[_loc5_].name,
                     "moderatedUserName":LocalizationManager.translateLocalizedId(_loc7_).text,
                     "avName":LocalizationManager.translateLocalizedId(_loc6_[_loc5_].name).text,
                     "isBuddy":BuddyManager.isBuddy(_loc6_[_loc5_].name),
                     "isBlocked":BuddyManager.isBlocked(_loc6_[_loc5_].name)
                  });
                  _loc5_++;
               }
            }
         }
         else
         {
            _allowMoreReferralRequests = false;
         }
         if(_itemWindowReferralList)
         {
            _itemWindowReferralList.insertManyItems(_loc3_,false,false,onInsertReferralsCallback);
         }
      }
      
      private function onInsertReferralsCallback() : void
      {
         _waitingForRequestAndInsertToComplete = false;
         if(!_allowMoreReferralRequests)
         {
            _itemWindowReferralList.preventGrayStateButtons = false;
         }
      }
      
      private function buildReferralsWindows() : void
      {
         _referralsLoadingSpiral.destroy();
         if(_itemWindowReferralList == null)
         {
            _itemWindowReferralList = new WindowAndScrollbarGenerator();
            _itemWindowReferralList.init(_myReferrals.itemBlock.width,_myReferrals.itemBlock.height,0,0,1,8,0,4,10,8,4,ItemWindowNameBar,_referralsList,"",0,{
               "mouseDown":referralListClickOnReferralHandler,
               "mouseOver":null,
               "mouseOut":null
            },{"specificWidth":140},null,true,false,false,false,false,true,_allowMoreReferralRequests);
            _itemWindowReferralList.contentPositionUpdateCallback = onContentPositionUpdate;
            _myReferrals.itemBlock.addChild(_itemWindowReferralList);
         }
      }
      
      private function onContentPositionUpdate(param1:Number) : void
      {
         if(param1 == 1)
         {
            if(_allowMoreReferralRequests && !_waitingForRequestAndInsertToComplete)
            {
               _waitingForRequestAndInsertToComplete = true;
               ReferAFriendXtCommManager.sendReferralReferralsRequest(onReferralsListPaginationResponse,++_pageRequested,_pageSizeRequested);
            }
         }
      }
      
      private function buildReferralsWindowsComplete() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _itemWindowReferralList.bg.numChildren)
         {
            ItemWindowNameBar(_itemWindowReferralList.bg.getChildAt(_loc1_)).updateToBeCentered(_myReferrals.itemBlock.width);
            _loc1_++;
         }
      }
      
      private function addReferAFriendEventListeners() : void
      {
         _referAFriendPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _referAFriendPopup.bx.addEventListener("mouseDown",onCloseReferAFriendBtn,false,0,true);
         _referAFriendPopup.copyLinkBtn.addEventListener("mouseDown",onCopyLinkBtn,false,0,true);
         _referAFriendPopup.printInviteBtn.addEventListener("mouseDown",printInviteBtn,false,0,true);
      }
      
      private function removeReferAFriendEventListeners() : void
      {
         _referAFriendPopup.removeEventListener("mouseDown",onPopup);
         _referAFriendPopup.bx.removeEventListener("mouseDown",onCloseReferAFriendBtn);
         _referAFriendPopup.copyLinkBtn.removeEventListener("mouseDown",onCopyLinkBtn);
         _referAFriendPopup.printInviteBtn.removeEventListener("mouseDown",printInviteBtn);
      }
      
      private function onCopyLinkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         System.setClipboard("https://buddy.animaljam.com/" + _code);
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(7604,onLinkPopupLoaded);
      }
      
      private function printInviteBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         launchPrint();
      }
      
      private function onCloseReferAFriendBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _referAFriendPopup.visible = false;
         removeReferAFriendEventListeners();
      }
      
      private function launchPrint() : void
      {
         _gameLaunchObj = {"typeDefId":152};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(_gameLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([_gameLaunchObj.typeDefId],false,onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(_gameLaunchObj,null,true);
         }
      }
      
      private function onCodeRequestComplete(param1:int, param2:String) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1 == 1)
         {
            _code = param2;
            GuiManager.guiLayer.addChild(_popup);
            DarkenManager.darken(_popup);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(22626),true,onCodeRequestCompleteFailureOk);
         }
      }
      
      private function onCodeRequestCompleteFailureOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onCloseBtn(null);
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_gameLaunchObj,null,true);
      }
      
      private function onLinkPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _linkPopup = param1.getChildAt(0) as MovieClip;
         _linkPopup.linkTxt.text = "https://buddy.animaljam.com/" + _code;
         _linkPopup.x = 900 / 2;
         _linkPopup.y = 550 / 2;
         GuiManager.guiLayer.addChild(_linkPopup);
         DarkenManager.darken(_linkPopup);
         addLinkEventListeners();
      }
      
      private function addLinkEventListeners() : void
      {
         _linkPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _linkPopup.bx.addEventListener("mouseDown",onCloseLinkPopup,false,0,true);
      }
      
      private function removeLinkEventListeners() : void
      {
         _linkPopup.removeEventListener("mouseDown",onPopup);
         _linkPopup.bx.removeEventListener("mouseDown",onCloseLinkPopup);
      }
      
      private function onCloseLinkPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         removeLinkEventListeners();
         DarkenManager.unDarken(_linkPopup);
         GuiManager.guiLayer.removeChild(_linkPopup);
         _linkPopup = null;
      }
   }
}

