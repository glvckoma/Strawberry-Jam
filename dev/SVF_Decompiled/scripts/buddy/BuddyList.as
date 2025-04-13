package buddy
{
   import com.sbi.popup.SBPopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.PlayerSearch;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowBuddyList;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class BuddyList
   {
      private static const BUDDY_LIST_X_OFFSET:int = 5;
      
      private static const BUDDY_LIST_Y_OFFSET:int = 40;
      
      private static var _playerSearch:PlayerSearch;
      
      private static var _buddyListPopup:SBPopup;
      
      private static var _buddyListContent:MovieClip;
      
      private static var _buddyListBtn:MovieClip;
      
      private static var _buddyListWorldPopup:MovieClip;
      
      private static var _requestingForWorldBuddyList:Boolean;
      
      private static var _worldSelectCallback:Function;
      
      private static var _currentSelectedUsername:String;
      
      private static var _currentSelectedItem:Object;
      
      private static var _currentSelectedIndex:int;
      
      private static var _itemWindowBuddyList:WindowAndScrollbarGenerator;
      
      private static var _itemWindowBuddyListWorld:WindowAndScrollbarGenerator;
      
      private static var _buddyListReferFriendBg:MovieClip;
      
      private static var _buddyListReferAFriendBtn:MovieClip;
      
      private static var _buddyListHowDidYouHearBtn:MovieClip;
      
      private static var _glowTimer:Timer;
      
      private static var _howDidYouHearPopup:HowDidYouHear;
      
      private static var _referAFriendPopup:ReferAFriend;
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _worldPopupLoadingSpiral:LoadingSpiral;
      
      private static var _hasRequestedReferralAssociation:Boolean;
      
      public static var listRequested:Boolean;
      
      public function BuddyList()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip, param3:Boolean = false) : void
      {
         _popupLayer = param1;
         _buddyListBtn = param2;
         if(!Utility.canBuddy())
         {
            _buddyListBtn.activateGrayState(true);
         }
         _buddyListContent = GETDEFINITIONBYNAME("BuddyListContent");
         LocalizationManager.translateId(_buddyListContent.buddyListTitleTxt,11250);
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.getMaxBuddyCount());
         _buddyListPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("BuddyListPopup"),_buddyListContent,false,true,false,false);
         _buddyListPopup.closeCallback = buddyListClosedCallback;
         _buddyListPopup.x = _buddyListPopup.width * 0.5 + 5;
         _buddyListPopup.y = _buddyListPopup.skin.s.ba.height * 0.5 + 40;
         _buddyListReferFriendBg = _buddyListPopup.skin.s.ba.referFriendBg;
         _buddyListReferAFriendBtn = _buddyListPopup.skin.s.ba.referAFriend;
         _buddyListHowDidYouHearBtn = _buddyListPopup.skin.s.ba.howDidYouHear;
         _loadingSpiral = new LoadingSpiral(DisplayObjectContainer(_buddyListPopup.content),-15);
         _hasRequestedReferralAssociation = false;
         _glowTimer = new Timer(5000);
         addListeners();
         if(param3)
         {
            onBuddyListChange(null);
         }
      }
      
      public static function rebuildBtn(param1:MovieClip) : void
      {
         if(_buddyListBtn)
         {
            _buddyListBtn.removeEventListener("mouseDown",buddyListBtnHandler);
         }
         _buddyListBtn = param1;
         if(Utility.canBuddy())
         {
            _buddyListBtn.addEventListener("mouseDown",buddyListBtnHandler,false,0,true);
         }
         else
         {
            _buddyListBtn.activateGrayState(true);
         }
         _buddyListBtn.glow.visible = false;
         LocalizationManager.translateId(_buddyListContent.buddyListTitleTxt,11250);
      }
      
      public static function destroy() : void
      {
         removeListeners();
         _buddyListContent = null;
         if(_itemWindowBuddyList)
         {
            _itemWindowBuddyList.destroy();
            _itemWindowBuddyList = null;
         }
         if(_buddyListPopup)
         {
            _buddyListPopup.destroy();
            _buddyListPopup = null;
         }
      }
      
      public static function get visible() : Boolean
      {
         return _buddyListPopup.visible;
      }
      
      public static function closeBuddyList() : void
      {
         if(_buddyListPopup && _buddyListPopup.visible)
         {
            _buddyListPopup.close();
            removePopupListeners();
            GuiManager.toolTip.resetTimerAndSetVisibility();
            _buddyListBtn.downToUpState();
         }
         onPlayerSearchClose();
      }
      
      public static function updateBuddyTimeLeftHosting() : void
      {
         if(_itemWindowBuddyList)
         {
            _itemWindowBuddyList.callUpdateInWindow();
         }
      }
      
      private static function onHasReferralAssociationResponse(param1:int) : void
      {
         _hasRequestedReferralAssociation = true;
         _buddyListReferFriendBg.visible = true;
         if(param1 == 1)
         {
            _buddyListReferAFriendBtn.visible = true;
            _buddyListHowDidYouHearBtn.visible = false;
         }
         else
         {
            _buddyListReferAFriendBtn.visible = false;
            _buddyListHowDidYouHearBtn.visible = true;
         }
         if(_buddyListPopup.visible)
         {
            addReferAFriendListeners();
         }
      }
      
      private static function onBuddyListChange(param1:Event) : void
      {
         if(_buddyListWorldPopup)
         {
            buildInWorldBuddyList(null,_currentSelectedItem,null,_currentSelectedUsername);
         }
         _loadingSpiral.visible = false;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.getMaxBuddyCount());
         var _loc2_:Number = -1;
         if(_itemWindowBuddyList)
         {
            _loc2_ = _itemWindowBuddyList.scrollYValue;
            (_buddyListPopup.content as MovieClip).itemBlock.removeChild(_itemWindowBuddyList);
            _itemWindowBuddyList.destroy();
         }
         _itemWindowBuddyList = new WindowAndScrollbarGenerator();
         _itemWindowBuddyList.init((_buddyListPopup.content as MovieClip).itemBlock.width,(_buddyListPopup.content as MovieClip).itemBlock.height,-5,_loc2_,1,10,BuddyManager.buddyCount,0,2,0,9,ItemWindowBuddyList,buildBuddyList(),"",0,{
            "mouseDown":buddyListClickOnBuddyHandler,
            "mouseOver":buddyListOverBuddyHandler,
            "mouseOut":buddyListOutBuddyHandler
         },null,null,true,false,false,false,false);
         (_buddyListPopup.content as MovieClip).itemBlock.addChild(_itemWindowBuddyList);
      }
      
      public static function buildBuddyList() : Array
      {
         var _loc4_:Array = [];
         var _loc2_:Dictionary = BuddyManager.buddyList;
         var _loc3_:int = BuddyManager.buddyCount;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.getMaxBuddyCount());
         if(_loc2_ && _loc3_ > 0)
         {
            for each(var _loc1_ in _loc2_)
            {
               _loc4_.push({
                  "userName":_loc1_.userName,
                  "moderatedUserName":_loc1_.userNameModerated,
                  "moderatedUserNameFlag":_loc1_.userNameModeratedFlag,
                  "onlineStatus":_loc1_.onlineStatus,
                  "accountType":_loc1_.accountType,
                  "uuid":_loc1_.uuid,
                  "timeLeftHostingCustomParty":_loc1_.timeLeftHostingCustomParty
               });
            }
            _loc4_.sortOn(["onlineStatus","userName"],[2,1]);
         }
         return _loc4_;
      }
      
      public static function buildInWorldBuddyList(param1:MovieClip, param2:Object, param3:Function, param4:String) : void
      {
         var _loc8_:Array = null;
         var _loc6_:Dictionary = null;
         var _loc7_:int = 0;
         if(!param1 || param1 && !closeWorldBuddyList() || !listRequested)
         {
            if(param1)
            {
               _worldSelectCallback = param3;
               if(_buddyListWorldPopup == null)
               {
                  _buddyListWorldPopup = GETDEFINITIONBYNAME("portalLinkBuddyListPopup");
               }
               if(_worldPopupLoadingSpiral == null)
               {
                  _worldPopupLoadingSpiral = new LoadingSpiral(_buddyListWorldPopup,_buddyListWorldPopup.width * 0.5,_buddyListWorldPopup.height * 0.5);
               }
               RoomManagerWorld.instance.layerManager.room_chat.addChild(_buddyListWorldPopup);
               _buddyListWorldPopup.x = param1.x - _buddyListWorldPopup.width * 0.5;
               _buddyListWorldPopup.y = param1.y + 15;
            }
            if(!listRequested)
            {
               _worldPopupLoadingSpiral.visible = true;
               BuddyXtCommManager.sendBuddyListRequest();
               listRequested = true;
               _requestingForWorldBuddyList = true;
               _currentSelectedUsername = param4;
               _currentSelectedItem = param2;
            }
            else
            {
               if(!param1 || !_itemWindowBuddyListWorld || _currentSelectedItem != param2)
               {
                  _loc8_ = [];
                  _loc6_ = BuddyManager.buddyList;
                  _loc7_ = BuddyManager.buddyCount;
                  if(_loc6_ && _loc7_ > 0)
                  {
                     for each(var _loc5_ in _loc6_)
                     {
                        _loc8_.push({
                           "userName":_loc5_.userName,
                           "moderatedUserName":_loc5_.userNameModerated,
                           "moderatedUserNameFlag":_loc5_.userNameModeratedFlag,
                           "uuid":_loc5_.uuid
                        });
                     }
                     _loc8_.sortOn(["userName"],[2,1]);
                  }
                  _currentSelectedUsername = param4;
                  _currentSelectedItem = param2;
                  _currentSelectedIndex = -1;
                  if(_itemWindowBuddyListWorld)
                  {
                     _itemWindowBuddyListWorld.destroy();
                     _itemWindowBuddyListWorld = null;
                  }
                  while(_buddyListWorldPopup.numChildren > 2)
                  {
                     _buddyListWorldPopup.removeChildAt(_buddyListWorldPopup.numChildren - 1);
                  }
                  _itemWindowBuddyListWorld = new WindowAndScrollbarGenerator();
                  _itemWindowBuddyListWorld.init(_buddyListWorldPopup.itemBlock.width,_buddyListWorldPopup.itemBlock.height,0,0,1,5,0,0,2,0,1,ItemWindowBuddyList,_loc8_,"",0,{"mouseDown":worldBuddyListClickOnBuddyHandler},{
                     "isSelection":true,
                     "currSelectedUsername":param4
                  },null,true,false,false,false,false);
                  _buddyListWorldPopup.itemBlock.addChild(_itemWindowBuddyListWorld);
               }
               _worldPopupLoadingSpiral.visible = false;
            }
         }
      }
      
      public static function updateWorldBuddyListPosition(param1:MovieClip) : void
      {
         if(_buddyListWorldPopup && _buddyListWorldPopup.parent)
         {
            _buddyListWorldPopup.x = param1.x - _buddyListWorldPopup.width * 0.5;
            _buddyListWorldPopup.y = param1.y + 15;
         }
      }
      
      public static function closeWorldBuddyList() : Boolean
      {
         if(_buddyListWorldPopup && _buddyListWorldPopup.parent)
         {
            _buddyListWorldPopup.parent.removeChild(_buddyListWorldPopup);
            _worldSelectCallback = null;
            return true;
         }
         return false;
      }
      
      public static function isOverWorldBuddyList(param1:int, param2:int) : Boolean
      {
         var _loc3_:Point = null;
         if(_buddyListWorldPopup && _buddyListWorldPopup.parent)
         {
            _loc3_ = RoomManagerWorld.instance.convertWorldToScreen(param1,param2);
            return _buddyListWorldPopup.hitTestPoint(_loc3_.x,_loc3_.y,false);
         }
         return false;
      }
      
      public static function destroyInWorldBuddyList() : void
      {
         closeWorldBuddyList();
         _buddyListWorldPopup = null;
         if(_itemWindowBuddyListWorld)
         {
            _itemWindowBuddyListWorld.destroy();
            _itemWindowBuddyListWorld = null;
         }
         _worldSelectCallback = null;
         _currentSelectedUsername = "";
         _currentSelectedItem = null;
      }
      
      public static function requestBuddyListIfNeeded(param1:Function) : void
      {
         if(!listRequested)
         {
            BuddyXtCommManager.sendBuddyListRequest(param1);
            listRequested = true;
         }
         else if(param1 != null)
         {
            param1();
         }
      }
      
      public static function updateSelectedInWorldBuddyIndex(param1:int) : void
      {
         _currentSelectedIndex = param1;
      }
      
      private static function worldBuddyListClickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_worldSelectCallback != null)
         {
            if(_currentSelectedUsername != "" && _currentSelectedUsername.toLowerCase() == param1.currentTarget.buddyPortalUsername())
            {
               param1.currentTarget.turnOffBuddySelection();
               _currentSelectedIndex = -1;
               _currentSelectedUsername = "";
            }
            else
            {
               if(_currentSelectedIndex != -1)
               {
                  MovieClip(_itemWindowBuddyListWorld.bg.getChildAt(_currentSelectedIndex)).turnOffBuddySelection();
               }
               param1.currentTarget.setBuddySelection();
               _currentSelectedIndex = param1.currentTarget.index;
               _currentSelectedUsername = param1.currentTarget.getBuddy().userName;
            }
            _worldSelectCallback(_currentSelectedUsername);
         }
      }
      
      private static function buddyListClickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Buddy = param1.currentTarget.getBuddy();
         if(_loc2_.userName.indexOf("Liza") < 0)
         {
            BuddyManager.showBuddyCard({
               "userName":_loc2_.userName,
               "onlineStatus":_loc2_.onlineStatus
            });
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         AJAudio.playSubMenuBtnClick();
      }
      
      private static function buddyListOverBuddyHandler(param1:MouseEvent) : void
      {
         (param1.currentTarget as ItemWindowBuddyList).showRecycleBtn(true);
      }
      
      private static function buddyListOutBuddyHandler(param1:MouseEvent) : void
      {
         (param1.currentTarget as ItemWindowBuddyList).showRecycleBtn(false);
      }
      
      private static function buddyListBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(!listRequested)
            {
               BuddyXtCommManager.sendBuddyListRequest();
               listRequested = true;
            }
            GuiManager.onExitRoom(true);
            if(_buddyListPopup.visible)
            {
               _buddyListPopup.close();
               removePopupListeners();
            }
            else
            {
               if(Utility.daysSinceCreated() > 3)
               {
                  _buddyListReferAFriendBtn.visible = true;
                  _buddyListHowDidYouHearBtn.visible = false;
                  addReferAFriendListeners();
               }
               else if(!_hasRequestedReferralAssociation)
               {
                  _buddyListReferFriendBg.visible = false;
                  _buddyListReferAFriendBtn.visible = false;
                  _buddyListHowDidYouHearBtn.visible = false;
                  ReferAFriendXtCommManager.sendHasReferralAssociate(onHasReferralAssociationResponse);
               }
               else
               {
                  addReferAFriendListeners();
               }
               glowTimerHandler(null);
               _buddyListPopup.open();
               addPopupListeners();
            }
         }
      }
      
      private static function buddyListClosedCallback() : void
      {
         _buddyListBtn.downToUpState();
      }
      
      public static function startBuddyListBtnGlow() : void
      {
         if(_buddyListBtn)
         {
            _buddyListBtn.glow.visible = true;
         }
         AJAudio.playBuddyOnlineOfflineSound();
         if(_glowTimer.running)
         {
            _glowTimer.stop();
         }
         _glowTimer.start();
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         if(_buddyListBtn)
         {
            _buddyListBtn.glow.visible = false;
         }
      }
      
      private static function onSearchBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _playerSearch = new PlayerSearch();
         _playerSearch.init(onPlayerSearchClose);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function onSearchBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14638),180,305);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function onSearchBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function onPlayerSearchClose() : void
      {
         if(_playerSearch)
         {
            _playerSearch.destroy();
            _playerSearch = null;
         }
      }
      
      private static function onReferAFriendBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _referAFriendPopup = new ReferAFriend(onReferAFriendClose);
      }
      
      private static function onReferAFriendClose() : void
      {
         _referAFriendPopup.destroy();
         _referAFriendPopup = null;
      }
      
      private static function onHowDidYouHearBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _howDidYouHearPopup = new HowDidYouHear(onHowDidYouHearClose);
      }
      
      private static function onHowDidYouHearClose(param1:Boolean) : void
      {
         _howDidYouHearPopup.destroy();
         _howDidYouHearPopup = null;
         if(param1)
         {
            _buddyListHowDidYouHearBtn.visible = false;
            _buddyListHowDidYouHearBtn.removeEventListener("mouseDown",onHowDidYouHearBtn);
            _buddyListReferAFriendBtn.visible = true;
            _buddyListReferAFriendBtn.addEventListener("mouseDown",onReferAFriendBtn,false,0,true);
         }
      }
      
      private static function addPopupListeners() : void
      {
         _buddyListContent.searchBtn.addEventListener("mouseDown",onSearchBtn,false,0,true);
         _buddyListContent.searchBtn.addEventListener("mouseOver",onSearchBtnOver,false,0,true);
         _buddyListContent.searchBtn.addEventListener("mouseOut",onSearchBtnOut,false,0,true);
      }
      
      private static function addReferAFriendListeners() : void
      {
         if(_buddyListReferAFriendBtn.visible)
         {
            _buddyListReferAFriendBtn.addEventListener("mouseDown",onReferAFriendBtn,false,0,true);
         }
         else if(_buddyListHowDidYouHearBtn.visible)
         {
            _buddyListHowDidYouHearBtn.addEventListener("mouseDown",onHowDidYouHearBtn,false,0,true);
         }
      }
      
      private static function removePopupListeners() : void
      {
         if(_buddyListContent)
         {
            _buddyListContent.searchBtn.removeEventListener("mouseDown",onSearchBtn);
            _buddyListContent.searchBtn.removeEventListener("mouseOver",onSearchBtnOver);
            _buddyListContent.searchBtn.removeEventListener("mouseOut",onSearchBtnOut);
            if(_buddyListReferAFriendBtn.visible)
            {
               _buddyListReferAFriendBtn.removeEventListener("mouseDown",onReferAFriendBtn);
            }
            else if(_buddyListHowDidYouHearBtn.visible)
            {
               _buddyListHowDidYouHearBtn.removeEventListener("mouseDown",onHowDidYouHearBtn);
            }
         }
      }
      
      private static function addListeners() : void
      {
         _glowTimer.addEventListener("timer",glowTimerHandler,false,0,true);
         BuddyManager.eventDispatcher.addEventListener("OnBuddyList",onBuddyListChange,false,0,true);
         BuddyManager.eventDispatcher.addEventListener("OnBuddyChanged",onBuddyListChange,false,0,true);
         if(Utility.canBuddy())
         {
            _buddyListBtn.addEventListener("mouseDown",buddyListBtnHandler,false,0,true);
         }
      }
      
      private static function removeListeners() : void
      {
         if(Utility.canBuddy())
         {
            _buddyListBtn.removeEventListener("mouseDown",buddyListBtnHandler);
         }
         _glowTimer.removeEventListener("timer",glowTimerHandler);
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyList",onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyChanged",onBuddyListChange);
      }
   }
}

