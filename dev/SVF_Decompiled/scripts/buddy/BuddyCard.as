package buddy
{
   import Enums.TradeItem;
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import achievement.AchievementXtCommManager;
   import adoptAPet.AdoptAPetXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import collection.IitemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBBlockCancelPopup;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.utils.Timer;
   import game.MinigameManager;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   import gui.DarkenManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.MySettings;
   import gui.ReportAPlayer;
   import gui.SBScrollbar;
   import gui.TradeManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   import gui.itemWindows.ItemWindowAvtPetSml;
   import gui.itemWindows.ItemWindowBase;
   import gui.itemWindows.ItemWindowGame;
   import gui.itemWindows.ItemWindowOriginal;
   import gui.jazwares.CheckListPopup;
   import inventory.Iitem;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetXtCommManager;
   import playerWall.PlayerWallManager;
   import playerWall.PlayerWallXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomJoinType;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeXtCommManager;
   
   public class BuddyCard
   {
      private const BUDDY_POPUP_X:int = 690;
      
      private const BUDDY_POPUP_Y:int = 165;
      
      private const REQUEST_INTERVAL:int = 10000;
      
      private const TRADE_TUT_LIST_ID:int = 22;
      
      private const LOADING_SPIRAL_SMALL:int = 397;
      
      private const BUDDY_POPUP_MEDIA_ID:int = 4620;
      
      private var _buddyCardMC:MovieClip;
      
      private var _popupLayer:DisplayLayer;
      
      private var _buddyRoomTimer:Timer;
      
      private var _buddyRoomNameWithNodeIp:String;
      
      private var _buddyRoomNameWithoutNodeIp:String;
      
      private var _buddyNode:String;
      
      private var _buddyRoomDisplayName:String;
      
      private var _isDropDownOpen:Boolean;
      
      private var _bDropDownTweenFinished:Boolean = true;
      
      private var _isGameTabOpen:Boolean;
      
      private var _isTradingTabOpen:Boolean;
      
      private var _sideMenuTweenFinished:Boolean = true;
      
      private var _achievementTimeStamp:Number;
      
      private var _petsTimeStamp:Number;
      
      private var _avatarTimeStamp:Number;
      
      private var _shouldDarkenBuddyCard:Boolean;
      
      private var _mainAvatarView:AvatarView;
      
      private var _currPerUserAvId:int;
      
      private var _currPetIdx:int;
      
      private var _currUserName:String;
      
      private var _currUserNameModerated:String;
      
      private var _currUserAccountType:int;
      
      private var _currUserIsBuddy:Boolean;
      
      private var _currUserIsArchived:Boolean;
      
      private var _currUserIsBlocked:Boolean;
      
      private var _currUserIsOnline:Boolean;
      
      private var _offlineBuddyAvatar:Avatar;
      
      private var _currUserBlocked:Boolean;
      
      private var _locationTxtBeforeOverCharBox:String;
      
      private var _playerAvatars:Array;
      
      private var _pvpGameList:Array;
      
      private var _tradeList:IitemCollection;
      
      private var _views:Array;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _pvpItemWindows:WindowGenerator;
      
      private var _pvpScrollBar:SBScrollbar;
      
      private var _tradeItemWindows:WindowGenerator;
      
      private var _tradeScrollBar:SBScrollbar;
      
      private var _userInfo:UserInfo;
      
      private var _checkListPopup:CheckListPopup;
      
      private var _achievements:Array;
      
      private var _pets:Array;
      
      private var _mainPetView:GuiPet;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _loadingSpiralDropDown:LoadingSpiral;
      
      private var _loadingSpiralAvatar:LoadingSpiral;
      
      private var _loadingSpiralPullOut:LoadingSpiral;
      
      private var _buddyListFullPopup:SBPopup;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _currNameBarData:int;
      
      private var _isFromUserClickRequest:Boolean;
      
      private var _isRequestingData:Boolean;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currPlayerObj:Object;
      
      private var _closeCallback:Function;
      
      private var charBox:MovieClip;
      
      private var goToBtn:MovieClip;
      
      private var allBtns:MovieClip;
      
      private var dropDown:MovieClip;
      
      private var awardsPopup:MovieClip;
      
      private var buddyAvNamePopup:MovieClip;
      
      private var locationPopup:MovieClip;
      
      private var tradeTab:MovieClip;
      
      private var gameTab:MovieClip;
      
      private var memberKey:MovieClip;
      
      private var nonmemberNameBar:MovieClip;
      
      private var memberNameBar:MovieClip;
      
      private var shamanBlock:MovieClip;
      
      private var shamanTag:MovieClip;
      
      private var avatarNameTxt:TextField;
      
      private var userNameTxt:TextField;
      
      private var tradeHelpPopup:MovieClip;
      
      private var petCodeBlock:MovieClip;
      
      private var xpShape:MovieClip;
      
      private var closeBtn:MovieClip;
      
      private var petCertBtn:MovieClip;
      
      private var shamanDescTxt:TextField;
      
      private var petsBtnDn:MovieClip;
      
      private var awardsBtnDn:MovieClip;
      
      private var charsBtnDn:MovieClip;
      
      private var petsBtnUp:MovieClip;
      
      private var awardsBtnUp:MovieClip;
      
      private var charsBtnUp:MovieClip;
      
      private var jammerPartyBtn:MovieClip;
      
      private var reportBtn:MovieClip;
      
      private var unblockBtn:MovieClip;
      
      private var blockBtn:MovieClip;
      
      private var mailBtn:MovieClip;
      
      private var bigDenBtn:MovieClip;
      
      private var denBtn:MovieClip;
      
      private var playerWallBtn:MovieClip;
      
      private var removeBuddyBtn:MovieClip;
      
      private var addBuddyBtn:MovieClip;
      
      private var dropDownTitleTxt:TextField;
      
      private var awardDescTxt:TextField;
      
      private var awardNameTxt:TextField;
      
      private var buddyAvNamePopupTxt:TextField;
      
      private var locationPopupTxt:TextField;
      
      private var tradeTabItemWindow:MovieClip;
      
      private var tradeTabBtn:MovieClip;
      
      private var gameTabItemWindow:MovieClip;
      
      private var gameTabBtn:MovieClip;
      
      private var checkListBtn:MovieClip;
      
      public function BuddyCard()
      {
         super();
      }
      
      public static function updateViewPosition(param1:AvatarView) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         switch(param1.avTypeId)
         {
            case 1:
               _loc3_ = 62;
               _loc2_ = 51;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 2:
               _loc3_ = 45;
               _loc2_ = 70;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 35:
               _loc3_ = 60;
               _loc2_ = 65;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 4:
               _loc3_ = 70;
               _loc2_ = 62;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 5:
               _loc3_ = 87;
               _loc2_ = 63;
               param1.scaleX = 0.5;
               param1.scaleY = 0.5;
               break;
            case 6:
               _loc3_ = 64;
               _loc2_ = 55;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 7:
               _loc3_ = 77;
               _loc2_ = 64;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 8:
               _loc3_ = 100;
               _loc2_ = 57;
               param1.scaleX = 0.6;
               param1.scaleY = 0.6;
               break;
            case 13:
               _loc3_ = 70;
               _loc2_ = 58;
               param1.scaleX = 0.35;
               param1.scaleY = 0.35;
               break;
            case 15:
               _loc3_ = 67;
               _loc2_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 16:
               _loc3_ = 70;
               _loc2_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 18:
               _loc3_ = 73;
               _loc2_ = 57;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 19:
               _loc3_ = 75;
               _loc2_ = 80;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 20:
               _loc3_ = 63;
               _loc2_ = 60;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 17:
               _loc3_ = 65;
               _loc2_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 23:
               _loc3_ = 69;
               _loc2_ = 60;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 22:
               _loc3_ = 65;
               _loc2_ = 70;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 24:
               _loc3_ = 79;
               _loc2_ = 70;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 21:
               _loc3_ = 75;
               _loc2_ = 60;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 26:
               _loc3_ = 64;
               _loc2_ = 63;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 25:
               _loc3_ = 60;
               _loc2_ = 67;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 28:
               _loc3_ = 60;
               _loc2_ = 65;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 29:
               _loc3_ = 60;
               _loc2_ = 75;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 30:
               _loc3_ = 62;
               _loc2_ = 63;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 31:
               _loc3_ = 59;
               _loc2_ = 63;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 27:
               _loc3_ = 70;
               _loc2_ = 73;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 3:
               _loc3_ = 75;
               _loc2_ = 73;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 9:
               _loc3_ = 65;
               _loc2_ = 48;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 10:
               _loc3_ = 55;
               _loc2_ = 48;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case 11:
               _loc3_ = 55;
               _loc2_ = 48;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case 12:
               _loc3_ = 63;
               _loc2_ = 47;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 14:
            case 34:
               _loc3_ = 55;
               _loc2_ = 48;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case 32:
            case 33:
               _loc3_ = 55;
               _loc2_ = 50;
               param1.scaleX = 0.25;
               param1.scaleY = 0.25;
               break;
            case 36:
               _loc3_ = 69;
               _loc2_ = 44;
               param1.scaleX = 0.35;
               param1.scaleY = 0.35;
               break;
            case 37:
            case 38:
               _loc3_ = 69;
               _loc2_ = 44;
               param1.scaleX = 0.35;
               param1.scaleY = 0.35;
               break;
            case 39:
               _loc3_ = 75;
               _loc2_ = 95;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 40:
               _loc3_ = 75;
               _loc2_ = 55;
               param1.scaleX = 0.4;
               param1.scaleY = 0.4;
               break;
            case 41:
               _loc3_ = 58;
               _loc2_ = 45;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 42:
               _loc3_ = 61;
               _loc2_ = 45;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 43:
               _loc3_ = 68;
               _loc2_ = 60;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 44:
               _loc3_ = 65;
               _loc2_ = 50;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 45:
               _loc3_ = 65;
               _loc2_ = 75;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 46:
               _loc3_ = 63;
               _loc2_ = 70;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 47:
               _loc3_ = 65;
               _loc2_ = 74;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 49:
               _loc3_ = 65;
               _loc2_ = 94;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 48:
               _loc3_ = 68;
               _loc2_ = 55;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 50:
               _loc3_ = 60;
               _loc2_ = 53;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 51:
               _loc3_ = 65;
               _loc2_ = 53;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 52:
               _loc3_ = 67;
               _loc2_ = 53;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            case 53:
               _loc3_ = 69;
               _loc2_ = 56;
               param1.scaleX = 0.3;
               param1.scaleY = 0.3;
               break;
            default:
               _loc3_ = 65;
               _loc2_ = 59;
               param1.scaleX = 0.5;
               param1.scaleY = 0.5;
         }
         param1.x = _loc3_;
         param1.y = _loc2_;
      }
      
      public function init(param1:Object, param2:Boolean = false, param3:Function = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _popupLayer = GuiManager.guiLayer;
         _currPlayerObj = param1;
         _shouldDarkenBuddyCard = param2;
         _closeCallback = param3;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4620,onBuddyCardLoaded);
      }
      
      public function destroy() : void
      {
         var _loc2_:Function = null;
         var _loc1_:int = 0;
         if(_closeCallback != null)
         {
            _loc2_ = _closeCallback;
            _closeCallback = null;
            _loc2_();
            _loc2_ = null;
            return;
         }
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         onCheckListClose();
         if(_buddyRoomTimer)
         {
            _buddyRoomTimer.reset();
            _buddyRoomTimer.removeEventListener("timer",buddyRoomTimerHandler);
            _buddyRoomTimer = null;
         }
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyChanged",buddyChangedHandler);
         GuiManager.toolTip.resetTimerAndSetVisibility();
         removeCardListeners();
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_mainAvatarView)
         {
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
         if(_mainPetView)
         {
            _mainPetView.destroy();
            _mainPetView = null;
         }
         if(_pvpItemWindows)
         {
            if(_pvpItemWindows.parent)
            {
               _pvpItemWindows.parent.removeChild(_pvpItemWindows);
            }
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         if(_pvpScrollBar)
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(_tradeItemWindows)
         {
            if(_tradeItemWindows.parent)
            {
               _tradeItemWindows.parent.removeChild(_tradeItemWindows);
            }
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(_tradeScrollBar)
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_shouldDarkenBuddyCard)
         {
            DarkenManager.unDarken(_buddyCardMC);
         }
         _popupLayer.removeChild(_buddyCardMC);
         _buddyCardMC = null;
         AvatarManager.buddyCardAvatarView = null;
         if(_playerAvatars)
         {
            _loc1_ = 0;
            while(_loc1_ < _playerAvatars.length)
            {
               _playerAvatars[_loc1_].destroy();
               _playerAvatars[_loc1_] = null;
               _loc1_++;
            }
            _playerAvatars = null;
         }
         _shouldDarkenBuddyCard = false;
         if(_loadingSpiralDropDown)
         {
            _loadingSpiralDropDown.destroy();
         }
         if(_loadingSpiralAvatar)
         {
            _loadingSpiralAvatar.destroy();
         }
         if(_loadingSpiralPullOut)
         {
            _loadingSpiralPullOut.destroy();
         }
         AvatarManager.buddyCardAvatarView = null;
         _buddyRoomDisplayName = "";
         _currUserName = "";
         _userInfo = null;
         _currUserBlocked = false;
         _currUserNameModerated = "";
         _currUserAccountType = 0;
         _currNameBarData = 0;
         _currPerUserAvId = -1;
         _currPetIdx = -1;
         _buddyRoomNameWithNodeIp = "";
         _buddyRoomNameWithoutNodeIp = "";
         _buddyNode = null;
         _currUserIsBuddy = false;
         _currUserIsArchived = false;
         _currUserIsBlocked = false;
         _currUserIsOnline = false;
      }
      
      private function onBuddyCardLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _buddyCardMC = param1.getChildAt(0) as MovieClip;
         _buddyRoomTimer = new Timer(gMainFrame.clientInfo.buddyRoomTimerInterval);
         _buddyRoomTimer.addEventListener("timer",buddyRoomTimerHandler,false,0,true);
         _playerAvatars = [];
         _achievements = [];
         _pets = [];
         _tradeList = new IitemCollection();
         BuddyManager.eventDispatcher.addEventListener("OnBuddyChanged",buddyChangedHandler,false,0,true);
         var _loc4_:String = _currPlayerObj.userName;
         var _loc3_:int = int(_currPlayerObj.onlineStatus);
         var _loc2_:* = _loc3_ == -1;
         _avatarTimeStamp = 0;
         _achievementTimeStamp = 0;
         _petsTimeStamp = 0;
         _currUserIsArchived = _loc2_;
         _currUserName = _loc4_;
         _currUserBlocked = false;
         _isDropDownOpen = false;
         _isGameTabOpen = false;
         _isTradingTabOpen = false;
         charBox = _buddyCardMC.charBox;
         userNameTxt = _buddyCardMC.userName_txt;
         avatarNameTxt = _buddyCardMC.avatarNameTxt;
         shamanTag = _buddyCardMC.shamanTag;
         shamanBlock = _buddyCardMC.shamanBlock;
         memberNameBar = _buddyCardMC.memberNameBar;
         nonmemberNameBar = _buddyCardMC.nonmemberNameBar;
         memberKey = _buddyCardMC.memberKey;
         gameTab = _buddyCardMC.gameTab;
         tradeTab = _buddyCardMC.tradeTab;
         locationPopup = _buddyCardMC.locationPopup;
         buddyAvNamePopup = _buddyCardMC.buddyAvNamePopup;
         awardsPopup = _buddyCardMC.awardsPopup;
         dropDown = _buddyCardMC.dropDown;
         allBtns = _buddyCardMC.allBtns;
         goToBtn = _buddyCardMC.goToBtn;
         tradeHelpPopup = _buddyCardMC.tradeHelpPopup;
         petCodeBlock = _buddyCardMC.petCodeBlock;
         xpShape = _buddyCardMC.xpShape;
         closeBtn = _buddyCardMC.bx;
         petCertBtn = _buddyCardMC.certBtn;
         shamanDescTxt = shamanBlock.descTxt;
         gameTabBtn = gameTab.gameTabBtn;
         gameTabItemWindow = gameTab.itemWindow;
         tradeTabBtn = tradeTab.tradeBtn;
         tradeTabItemWindow = tradeTab.itemWindow;
         locationPopupTxt = locationPopup.txt;
         buddyAvNamePopupTxt = buddyAvNamePopup.txt;
         awardNameTxt = awardsPopup.title_txt;
         awardDescTxt = awardsPopup.desc_txt;
         dropDownTitleTxt = dropDown.tab_title_txt;
         addBuddyBtn = allBtns.addFriend_btn;
         removeBuddyBtn = allBtns.removeFriend_btn;
         playerWallBtn = allBtns.playerWall_btn;
         denBtn = allBtns.home_btn;
         bigDenBtn = allBtns.home_btnBig;
         mailBtn = allBtns.mail_btn;
         blockBtn = allBtns.block_btn;
         unblockBtn = allBtns.unblock_btn;
         reportBtn = allBtns.report_btn;
         jammerPartyBtn = allBtns.jammerParty_btn;
         charsBtnUp = dropDown.char_tab;
         awardsBtnUp = dropDown.trophy_tab;
         petsBtnUp = dropDown.pets_tab;
         charsBtnDn = dropDown.downChar_tab;
         awardsBtnDn = dropDown.downTrophy_tab;
         petsBtnDn = dropDown.downPet_tab;
         checkListBtn = dropDown.checklistBtn;
         locationPopup.visible = false;
         buddyAvNamePopup.visible = false;
         awardsPopup.visible = false;
         awardsBtnUp.visible = false;
         tradeHelpPopup.visible = false;
         goToBtn.activateGrayState(true);
         petCodeBlock.visible = false;
         playerWallBtn.activateLoadingState(true);
         jammerPartyBtn.activateLoadingState(true);
         bigDenBtn.visible = true;
         jammerPartyBtn.visible = false;
         denBtn.visible = false;
         shamanTag.visible = false;
         shamanBlock.visible = false;
         petsBtnUp.visible = false;
         charsBtnUp.visible = false;
         awardsBtnUp.visible = true;
         petsBtnDn.visible = true;
         petCertBtn.visible = false;
         locationPopupTxt.autoSize = "center";
         locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
         _buddyRoomDisplayName = locationPopupTxt.text;
         avatarNameTxt.text = "";
         userNameTxt.text = "";
         locationPopup.tooltipCont.visible = false;
         addCardListeners();
         _popupLayer.addChild(_buddyCardMC);
         _buddyCardMC.x = 690;
         _buddyCardMC.y = 165;
         if(_shouldDarkenBuddyCard)
         {
            DarkenManager.darken(_buddyCardMC);
         }
         setupCardWithAvatar(_loc4_,_loc3_,_loc2_);
      }
      
      private function setupCardWithAvatar(param1:String, param2:int, param3:Boolean) : void
      {
         var _loc5_:UserInfo = null;
         var _loc6_:AvatarInfo = null;
         if(param3)
         {
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(param1);
            if(_loc5_)
            {
               _loc5_.setTimeOfLastAchievementRequest(0);
            }
         }
         var _loc7_:String = gMainFrame.server.getCurrentRoomName(false);
         _loadingSpiralAvatar = new LoadingSpiral(charBox);
         if(_loc7_ != "den" + param1 && !shouldGrayOut())
         {
            denBtn.activateGrayState(false);
            bigDenBtn.activateGrayState(false);
         }
         else
         {
            denBtn.activateGrayState(true);
            bigDenBtn.activateGrayState(true);
         }
         if(param2 < 1 || shouldGrayOut())
         {
            if(tradeTabBtn.hasGrayState)
            {
               tradeTabBtn.activateGrayState(true);
            }
            if(gameTabBtn.hasGrayState)
            {
               gameTabBtn.activateGrayState(true);
            }
         }
         var _loc4_:Buddy = BuddyManager.getBuddyByUserName(param1);
         _currUserIsBuddy = _loc4_ != null;
         if(_currUserIsBuddy)
         {
            _currUserIsOnline = _loc4_.isOnline;
            _currPlayerObj.onlineStatus = param2 = _currUserIsOnline ? 1 : 0;
            avatarNameTxt.text = "";
            userNameTxt.text = _loc4_.userNameModerated;
            if(_currUserIsOnline)
            {
               BuddyXtCommManager.sendBuddyRoomRequest(param1);
               _buddyRoomTimer.start();
               locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
            }
            else
            {
               LocalizationManager.translateId(locationPopupTxt,11235);
            }
            _locationTxtBeforeOverCharBox = locationPopupTxt.text;
            resizeLocationToolTip();
         }
         else
         {
            userNameTxt.text = _currUserName;
            BuddyXtCommManager.sendBuddyRoomRequest(param1);
         }
         addBuddyBtn.visible = !_currUserIsBuddy;
         removeBuddyBtn.visible = _currUserIsBuddy;
         _currUserIsBlocked = BuddyManager.isBlocked(_currUserName);
         blockBtn.visible = !_currUserIsBlocked;
         unblockBtn.visible = _currUserIsBlocked;
         if(gMainFrame.userInfo.isModerator)
         {
            if(_loc7_ != "den" + param1)
            {
               denBtn.activateGrayState(false);
               bigDenBtn.activateGrayState(false);
            }
         }
         if(!_loadingSpiralDropDown)
         {
            _loadingSpiralDropDown = new LoadingSpiral(dropDown.itemWindow,dropDown.itemWindow.width * 0.5,dropDown.itemWindow.height * 0.5);
         }
         else
         {
            _loadingSpiralDropDown.setNewParent(dropDown.itemWindow,dropDown.itemWindow.width * 0.5,dropDown.itemWindow.height * 0.5);
         }
         _loadingSpiralDropDown.visible = false;
         if(!_loadingSpiralPullOut)
         {
            _loadingSpiralPullOut = new LoadingSpiral(tradeTabItemWindow,tradeTabItemWindow.width * 0.5 + 15,tradeTabItemWindow.height * 0.5);
         }
         _loadingSpiralPullOut.visible = false;
         setupAllGrayStates(true);
         _isRequestingData = false;
         if(!param3)
         {
            charBox.gotoAndStop(1);
            _loc6_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc6_)
            {
               _isRequestingData = true;
               AvatarXtCommManager.requestAvatarGet(param1,onAvatarGetReceived);
               return;
            }
            onAvatarGetReceived(param1,true,param2,_loc6_);
         }
         else
         {
            SBTracker.trackPageview("game/play/popup/buddyCard/archived",-1,1);
         }
      }
      
      private function setupAllGrayStates(param1:Boolean) : void
      {
         if(param1)
         {
            charBox.gotoAndStop(4);
            if(_currUserIsArchived)
            {
               _loadingSpiralAvatar.visible = false;
            }
            clearPetAndAvatarViews();
            _currPerUserAvId = -1;
            _currPetIdx = -1;
            avatarNameTxt.text = "";
            if(tradeTabBtn.hasGrayState)
            {
               tradeTabBtn.activateGrayState(true);
            }
            if(gameTabBtn.hasGrayState)
            {
               gameTabBtn.activateGrayState(true);
            }
         }
         if(!_currUserIsBuddy)
         {
            addBuddyBtn.activateGrayState(param1);
         }
         if(param1 || gMainFrame.server.getCurrentRoomName(false) != "den" + _currUserName && !shouldGrayOut())
         {
            denBtn.activateGrayState(param1);
            bigDenBtn.activateGrayState(param1);
         }
         if(param1 || !MinigameManager.inMinigame())
         {
            mailBtn.activateGrayState(param1);
         }
         if(_currUserIsArchived)
         {
            blockBtn.visible = true;
            unblockBtn.visible = false;
            dropDown.visible = false;
            memberKey.visible = false;
            memberNameBar.visible = false;
            goToBtn.activateGrayState(true);
            playerWallBtn.activateLoadingState(false);
            playerWallBtn.activateGrayState(true);
         }
         blockBtn.activateGrayState(param1);
         reportBtn.activateGrayState(param1);
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:AvatarInfo = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Avatar = null;
         if(param2 && param1.toLowerCase() == _currUserName.toLowerCase())
         {
            _currUserName = param1;
            _currUserBlocked = false;
            if(param3 == -1)
            {
               resetBuddyCardForArchiveMode(_currUserName);
               return;
            }
            if(param3 == -3)
            {
               destroy();
               return;
            }
            if(!param4)
            {
               param4 = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
               if(!param4)
               {
                  throw new Error("onAvatarGetReceived and avInfo is null");
               }
            }
            if(param3 < 1 || shouldGrayOut())
            {
               if(tradeTabBtn.hasGrayState)
               {
                  tradeTabBtn.activateGrayState(true);
               }
               if(gameTabBtn.hasGrayState)
               {
                  gameTabBtn.activateGrayState(true);
               }
            }
            else
            {
               if(tradeTabBtn.hasGrayState)
               {
                  tradeTabBtn.activateGrayState(false);
               }
               if(gameTabBtn.hasGrayState)
               {
                  gameTabBtn.activateGrayState(false);
               }
            }
            setupAllGrayStates(false);
            if(!_currUserIsBuddy)
            {
               if(!denBtn.isGray && !_currUserIsArchived)
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
               }
            }
            getPlayerWallPrivacySettings();
            _loc5_ = param4.perUserAvId;
            _loc6_ = AvatarManager.getAvatarByUserName(_currUserName);
            if(_loc6_ == null)
            {
               if(_offlineBuddyAvatar == null)
               {
                  _offlineBuddyAvatar = AvatarUtility.generateNew(_loc5_,null,_currUserName,-1,0,onAvatarItemData);
               }
               else if(_offlineBuddyAvatar.userName != param4.userName)
               {
                  _offlineBuddyAvatar.destroy();
                  _offlineBuddyAvatar = AvatarUtility.generateNew(_loc5_,null,_currUserName,-1,0,onAvatarItemData);
               }
               _loc6_ = _offlineBuddyAvatar;
            }
            _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
            _currUserNameModerated = _userInfo.getModeratedUserName();
            _currUserAccountType = _userInfo.getAccountType();
            if(param4.isMember)
            {
               _currNameBarData = _userInfo.nameBarData;
               nonmemberNameBar.visible = false;
               memberNameBar.nubType = "";
               memberNameBar.setColorAndBadge(_userInfo.nameBarData);
               memberNameBar.isBlocked = false;
               memberNameBar.setAvName(_currUserNameModerated,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_userInfo,false);
               userNameTxt.visible = false;
               memberNameBar.mouseEnabled = false;
               memberNameBar.mouseChildren = false;
            }
            else
            {
               memberKey.visible = false;
               memberNameBar.visible = false;
            }
            getJammerPartyIsActive();
            userNameTxt.text = _currUserNameModerated;
            drawMainAvatar(_loc6_,true);
            _currPerUserAvId = _loc5_;
            if((_userInfo && _userInfo.isGuide || _loc6_.isShaman) && !(gMainFrame.userInfo.isModerator || Boolean(gMainFrame.userInfo.isGuide)))
            {
               if(_userInfo && _userInfo.isGuide)
               {
                  memberNameBar.setAvName(LocalizationManager.translateIdOnly(11236),false,null,false);
                  shamanDescTxt.text = getGuideText(_loc6_.userName);
                  shamanDescTxt.height = shamanDescTxt.textHeight + 5;
                  shamanDescTxt.y = 0 - shamanDescTxt.height / 2;
               }
               else
               {
                  memberNameBar.setAvName(LocalizationManager.translateIdOnly(11237),false,null,false);
                  avatarNameTxt.text = _loc6_.shamanName;
                  shamanDescTxt.text = _loc6_.shamanText;
                  shamanDescTxt.height = shamanDescTxt.textHeight + 5;
                  shamanDescTxt.y = 0 - shamanDescTxt.height / 2;
               }
               allBtns.visible = false;
               shamanBlock.visible = true;
               shamanTag.visible = true;
               goToBtn.visible = false;
               dropDown.visible = false;
               tradeTabBtn.activateGrayState(true);
               gameTabBtn.activateGrayState(true);
            }
            else
            {
               shamanBlock.visible = false;
               shamanTag.visible = false;
            }
            if(shouldGrayOut())
            {
               if(!goToBtn.isGray)
               {
                  goToBtn.activateGrayState(true);
               }
               if(!denBtn.isGray)
               {
                  denBtn.activateGrayState(true);
                  bigDenBtn.activateGrayState(true);
               }
            }
         }
         else
         {
            destroy();
         }
      }
      
      private function drawMainAvatar(param1:Avatar, param2:Boolean = false) : void
      {
         var _loc3_:AvatarInfo = null;
         if(_buddyCardMC && (_currPerUserAvId != param1.perUserAvId || param2))
         {
            if(Utility.isOcean(param1.enviroTypeFlag))
            {
               if(Utility.isLand(param1.enviroTypeFlag))
               {
                  charBox.gotoAndStop(3);
               }
               else
               {
                  charBox.gotoAndStop(2);
               }
            }
            else
            {
               charBox.gotoAndStop(1);
            }
            clearPetAndAvatarViews();
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param1.userName,param1.perUserAvId);
            if(_loc3_ && _loc3_.questLevel > 0)
            {
               loadXPShape(_loc3_.questLevel);
            }
            else
            {
               xpShape.visible = false;
            }
            _mainAvatarView = new AvatarView();
            _mainAvatarView.init(param1);
            if(param1.uuid != "")
            {
               _mainAvatarView.playAnim(13,false,1,positionAndAddMainAvatarView);
            }
            avatarNameTxt.text = param1.avName;
            _currPetIdx = -1;
            _currPerUserAvId = param1.perUserAvId;
            AvatarManager.buddyCardAvatarView = _mainAvatarView;
         }
      }
      
      private function getPlayerWallPrivacySettings() : void
      {
         if(PlayerWallManager.ownerNameOfCurrentOpenWall().toLowerCase() != _currUserName.toLowerCase())
         {
            PlayerWallXtCommManager.sendGetWallSettingsRequest(_currUserName,onPlayerWallPrivacyGet);
         }
         else
         {
            playerWallBtn.activateLoadingState(false);
            playerWallBtn.activateGrayState(true);
         }
      }
      
      private function getJammerPartyIsActive() : void
      {
         if(_userInfo)
         {
            if(_isRequestingData)
            {
               if(_userInfo.isStillHosting)
               {
                  BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
               }
               else
               {
                  setGrayStateForJammerPartyBtn(true);
               }
            }
            else
            {
               PartyXtCommManager.sendCustomPartyIsHosting(_currUserName,_userInfo.uuid,onJammerPartyIsHostingResponse);
            }
         }
      }
      
      private function setGrayStateForJammerPartyBtn(param1:Boolean) : void
      {
         if(param1 == false)
         {
            if(gMainFrame.server.getCurrentRoomName() != _buddyRoomNameWithNodeIp && _buddyRoomNameWithoutNodeIp != null && _buddyRoomNameWithoutNodeIp.indexOf(_currUserName) != -1)
            {
               param1 = true;
            }
         }
         if(_buddyCardMC)
         {
            bigDenBtn.visible = param1;
            jammerPartyBtn.visible = !param1;
            denBtn.visible = !param1;
            jammerPartyBtn.activateLoadingState(false);
            jammerPartyBtn.activateGrayState(param1);
         }
      }
      
      private function loadXPShape(param1:int) : void
      {
         var _loc2_:int = Utility.getColorId(_currNameBarData);
         if(xpShape.currentFrame != _loc2_)
         {
            xpShape.gotoAndStop(_loc2_);
         }
         Utility.createXpShape(param1,!nonmemberNameBar.visible,xpShape[xpShape.currentLabels[_loc2_ - 1].name].mouse.up.icon,null,2147483647);
      }
      
      public function onAvatarItemData(param1:Boolean) : void
      {
         if(param1 && _offlineBuddyAvatar != null)
         {
            drawMainAvatar(_offlineBuddyAvatar,true);
         }
         else
         {
            destroy();
         }
      }
      
      private function shouldGrayOut() : Boolean
      {
         if(gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom() || MinigameManager.inMinigame())
         {
            return true;
         }
         return false;
      }
      
      private function clearPetAndAvatarViews() : void
      {
         if(_mainPetView)
         {
            if(charBox.contains(_mainPetView))
            {
               charBox.removeChild(_mainPetView);
            }
            _mainPetView = null;
            petCertBtn.visible = false;
         }
         if(_mainAvatarView)
         {
            if(charBox.contains(_mainAvatarView))
            {
               charBox.removeChild(_mainAvatarView);
            }
            _mainAvatarView.destroy();
            _mainAvatarView = null;
         }
      }
      
      private function drawMainPet(param1:int) : void
      {
         var _loc2_:int = 0;
         if(_currPetIdx != param1)
         {
            charBox.gotoAndStop(1);
            _loadingSpiralAvatar = new LoadingSpiral(charBox);
            if(_mainPetView)
            {
               if(charBox.contains(_mainPetView))
               {
                  charBox.removeChild(_mainPetView);
               }
               _mainPetView = null;
            }
            if(_mainAvatarView)
            {
               if(charBox.contains(_mainAvatarView))
               {
                  charBox.removeChild(_mainAvatarView);
               }
               _mainAvatarView.destroy();
               _mainAvatarView = null;
               AvatarManager.buddyCardAvatarView = null;
            }
            _currPerUserAvId = -1;
            _currPetIdx = param1;
            _loc2_ = 0;
            while(_loc2_ < _pets.length)
            {
               if(_pets[_loc2_].idx == _currPetIdx)
               {
                  createMainPetView(_loc2_);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function createMainPetView(param1:int) : void
      {
         var _loc2_:Object = _pets[param1];
         _mainPetView = new GuiPet(_loc2_.createdTs,_loc2_.idx,_loc2_.lBits,_loc2_.uBits,_loc2_.eBits,_loc2_.type,_loc2_.name,_loc2_.personalityDefId,_loc2_.favoriteToyDefId,_loc2_.favoriteFoodDefId,onMainPetLoaded);
         if(!_mainPetView.isEggAndHasNotHatched())
         {
            petCertBtn.visible = true;
         }
         avatarNameTxt.text = _mainPetView.petName;
         if(_buddyCardMC)
         {
            if(_mainPetView.canGoOnLand() && !_mainPetView.canGoInOcean() || AvatarManager.roomEnviroType == 0 && _mainPetView.canGoOnLand())
            {
               charBox.gotoAndStop(1);
            }
            else
            {
               charBox.gotoAndStop(2);
            }
            charBox.addChild(_mainPetView);
         }
      }
      
      private function onMainPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _mainPetView.y += charBox.height * 0.4;
         _mainPetView.scaleY = 4.5;
         _mainPetView.scaleX = 4.5;
         _loadingSpiralAvatar.visible = false;
      }
      
      private function positionAndAddMainAvatarView(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Point = AvatarUtility.getAvOffsetByDefId(_mainAvatarView.avTypeId);
         _mainAvatarView.x = _loc3_.x;
         _mainAvatarView.y = _loc3_.y;
         if(_buddyCardMC)
         {
            charBox.addChild(_mainAvatarView);
         }
         _loadingSpiralAvatar.visible = false;
      }
      
      private function checkBuddyRoomAgainstMine(param1:Boolean) : void
      {
         var _loc2_:Buddy = null;
         if(gMainFrame.server.getCurrentRoomName() != _buddyRoomNameWithNodeIp)
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(!param1 && _loc2_ && _loc2_.isOnline)
            {
               if(goToBtn.isGray && !shouldGrayOut())
               {
                  goToBtn.activateGrayState(false);
               }
            }
            else if(!goToBtn.isGray)
            {
               goToBtn.activateGrayState(true);
            }
         }
         else
         {
            goToBtn.activateGrayState(_currUserIsBuddy ? false : true);
         }
      }
      
      public function userNameChange(param1:String, param2:String, param3:String) : void
      {
         if(param1 && param2)
         {
            if(_currUserName.toLowerCase() == param1.toLowerCase())
            {
               _currUserName = param2;
               _currUserNameModerated = param3;
            }
            if(_buddyCardMC)
            {
               memberNameBar.setAvName(_currUserNameModerated,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
               userNameTxt.text = _currUserNameModerated;
            }
         }
      }
      
      public function updateCurrBuddyCardAvatar(param1:Avatar = null) : void
      {
         if(param1 == null)
         {
            param1 = _offlineBuddyAvatar;
         }
         else if(_buddyCardMC && _buddyCardMC.visible)
         {
            drawMainAvatar(param1);
         }
         if(_mainAvatarView)
         {
            _mainAvatarView.resetAvatar(param1);
         }
         if(_buddyCardMC && avatarNameTxt)
         {
            avatarNameTxt.text = param1.avName;
         }
      }
      
      public function avatarLeftRoom(param1:String) : void
      {
         if(_currUserName == param1)
         {
            if(BuddyManager.isBuddy(_currUserName) || Boolean(gMainFrame.userInfo.isModerator))
            {
               locationPopupTxt.text = LocalizationManager.translateIdOnly(11234);
               _buddyRoomDisplayName = _locationTxtBeforeOverCharBox = locationPopupTxt.text;
               _buddyRoomTimer.start();
               resizeLocationToolTip();
            }
            else
            {
               goToBtn.activateGrayState(true);
               locationPopupTxt.text = _locationTxtBeforeOverCharBox = _buddyRoomDisplayName = "";
            }
         }
      }
      
      public function grayOutGoToDenBtn(param1:Boolean, param2:String = "") : void
      {
         if(_buddyCardMC)
         {
            if(param1 && shouldGrayOut())
            {
               return;
            }
            goToBtn.activateGrayState(param1);
            if(param2 == null || _currUserName.toLowerCase() == param2.toLowerCase())
            {
               denBtn.activateGrayState(param1);
               bigDenBtn.activateGrayState(param1);
            }
         }
      }
      
      public function resetBuddyCardForArchiveMode(param1:String) : void
      {
         var _loc2_:String = null;
         if(_currUserName.toLowerCase() == param1.toLowerCase())
         {
            _loc2_ = _currUserName;
            _currUserBlocked = false;
            _currUserNameModerated = "";
            _currUserAccountType = 0;
            _currUserIsArchived = true;
            _userInfo = null;
            setupCardWithAvatar(_loc2_,-1,true);
         }
      }
      
      public function setPlayerWallLoading(param1:Boolean) : void
      {
         if(_buddyCardMC)
         {
            playerWallBtn.activateLoadingState(param1);
         }
      }
      
      private function addRemoveBlockDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(BuddyManager.isBlocked(_currUserName))
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14699,_currUserNameModerated),true,buddyCardRemoveIgnoreConfirmCallback);
            }
            else
            {
               new SBBlockCancelPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14700,_currUserNameModerated),true,buddyCardAddIgnoreConfirmCallback);
            }
         }
      }
      
      private function addRemoveBlockDownOverHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(BuddyManager.isBlocked(_currUserName))
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14628),790,210);
               GuiManager.toolTip.startTimer(param1);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14629),790,210);
               GuiManager.toolTip.startTimer(param1);
            }
         }
      }
      
      private function requestAvatarList(param1:Boolean = false) : void
      {
         _loadingSpiralDropDown.visible = true;
         _isFromUserClickRequest = param1;
         AvatarXtCommManager.requestAvatarList([_currUserName],drawAvatarsInDropDown);
      }
      
      private function drawAvatarsInDropDown(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Avatar = null;
         if(param1)
         {
            resetBuddyCardForArchiveMode(_currUserName);
            return;
         }
         if(GuiManager.isVersionPopupOpen())
         {
            destroy();
            return;
         }
         _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_currUserName);
         if(_userInfo && _currUserName.toLowerCase() == _userInfo.userName.toLowerCase())
         {
            if(_playerAvatars)
            {
               _loc2_ = 0;
               while(_loc2_ < _playerAvatars.length)
               {
                  _playerAvatars[_loc2_].destroy();
                  _playerAvatars[_loc2_] = null;
                  _loc2_++;
               }
               _playerAvatars = null;
            }
            _playerAvatars = [];
            for each(var _loc4_ in _userInfo.avList)
            {
               _loc3_ = new Avatar();
               _loc3_.init(_loc4_.perUserAvId,_loc4_.avInvId,_loc4_.userName,_loc4_.type,_loc4_.colors,_loc4_.customAvId,null,_currUserName);
               _playerAvatars.push(_loc3_);
            }
            _loadingSpiralDropDown.visible = false;
            if(_isDropDownOpen && charsBtnUp.visible)
            {
               createAvatarWindows();
            }
         }
      }
      
      public function onDenPrivacyResponse(param1:String, param2:int) : void
      {
         if(param1.toLowerCase() == _currUserName.toLowerCase() && _buddyCardMC && _currUserName != "" && !shouldGrayOut())
         {
            if(gMainFrame.userInfo.isModerator)
            {
               denBtn.activateGrayState(false);
               bigDenBtn.activateGrayState(false);
            }
            else if(param2 == 2)
            {
               BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
            }
            else if(param2 == 1)
            {
               if(_currUserIsBuddy)
               {
                  BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
               }
               else
               {
                  denBtn.activateGrayState(true);
                  bigDenBtn.activateGrayState(true);
               }
            }
            else if(param2 == 0)
            {
               denBtn.activateGrayState(true);
               bigDenBtn.activateGrayState(true);
            }
         }
         else
         {
            denBtn.activateGrayState(true);
            bigDenBtn.activateGrayState(true);
         }
      }
      
      public function onPlayerWallPrivacyGet(param1:int) : void
      {
         if(_buddyCardMC && _currUserName != "" && !MinigameManager.inMinigame())
         {
            if(param1 == 2)
            {
               BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
            }
            else if(param1 == 1)
            {
               if(_currUserIsBuddy)
               {
                  BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
               }
               else
               {
                  playerWallBtn.activateLoadingState(false);
                  playerWallBtn.activateGrayState(true);
               }
            }
            else if(param1 == 0)
            {
               playerWallBtn.activateLoadingState(false);
               playerWallBtn.activateGrayState(true);
            }
         }
         else
         {
            playerWallBtn.activateLoadingState(false);
            playerWallBtn.activateGrayState(true);
         }
      }
      
      private function onJammerPartyIsHostingResponse(param1:int, param2:UserInfo) : void
      {
         if(param2)
         {
            _userInfo = param2;
         }
         if(param1 > 0)
         {
            BuddyXtCommManager.sendBuddyBlockInfoRequest(_currUserName);
         }
         else
         {
            setGrayStateForJammerPartyBtn(true);
         }
      }
      
      public function onTradeListReceived(param1:String, param2:IitemCollection) : void
      {
         if(param1.toLowerCase() == _currUserName.toLowerCase())
         {
            _tradeList = param2;
            createTradeWindows();
         }
      }
      
      public function getTradeList() : IitemCollection
      {
         return _tradeList;
      }
      
      private function createAvatarWindows() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         while(dropDown.itemWindow.numChildren > 2)
         {
            dropDown.itemWindow.removeChildAt(dropDown.itemWindow.numChildren - 1);
         }
         if(_itemWindows && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_playerAvatars)
         {
            _loc3_ = int(_playerAvatars.length);
            _loc2_ = Math.min(_loc3_,4);
            _loc1_ = Math.ceil(_loc2_ / 4);
            _itemWindows = new WindowAndScrollbarGenerator();
            _itemWindows.init(dropDown.itemWindow.width,dropDown.itemWindow.height,-12,0,_loc2_,_loc1_,0,2,2,2,2,ItemWindowAvtPetSml,_playerAvatars,"",0,{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{
               "isMember":!nonmemberNameBar.visible,
               "nameBarData":_currNameBarData,
               "currPerUserAvId":_userInfo.currPerUserAvId
            },null);
            dropDown.itemWindow.addChild(_itemWindows);
         }
      }
      
      private function requestAchievementsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         AchievementXtCommManager.requestAchievements(_currUserName,achievementListCallback);
      }
      
      private function achievementListCallback(param1:Array, param2:Array, param3:Boolean = false) : void
      {
         var _loc4_:int = 0;
         if(param3)
         {
            resetBuddyCardForArchiveMode(_currUserName);
            return;
         }
         _achievements = [];
         if(param1)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _achievements.push(param1[_loc4_]);
               _loc4_++;
            }
         }
         _loadingSpiralDropDown.visible = false;
         if(_isDropDownOpen && awardsBtnUp.visible)
         {
            createAchievementsWindows();
         }
      }
      
      private function createAchievementsWindows() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         while(dropDown.itemWindow.numChildren > 2)
         {
            dropDown.itemWindow.removeChildAt(dropDown.itemWindow.numChildren - 1);
         }
         if(_itemWindows && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_achievements)
         {
            _loc2_ = int(_achievements.length);
            _loc3_ = Math.min(_loc2_,4);
            _loc1_ = Math.ceil(_loc3_ / 4);
            _itemWindows = new WindowAndScrollbarGenerator();
            _itemWindows.init(dropDown.itemWindow.width,dropDown.itemWindow.height,-12,0,_loc3_,_loc1_,_loc2_,6,6,0,0,ItemWindowBase,_achievements,"image",0,{
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"itemClassName":"awardSmlCont"});
            dropDown.itemWindow.addChild(_itemWindows);
         }
      }
      
      private function requestPetsList() : void
      {
         _loadingSpiralDropDown.visible = true;
         PetXtCommManager.sendPetListRequest(_currUserName,petListCallback);
      }
      
      private function petListCallback(param1:Array, param2:int) : void
      {
         var _loc3_:int = 0;
         if(param2 == 0)
         {
            destroy();
            return;
         }
         if(param2 == -1)
         {
            resetBuddyCardForArchiveMode(_currUserName);
            return;
         }
         _pets = [];
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < param1.length)
            {
               _pets.push(param1[_loc3_]);
               _loc3_++;
            }
         }
         _loadingSpiralDropDown.visible = false;
         if(_isDropDownOpen && petsBtnUp.visible)
         {
            createPetsWindows();
         }
      }
      
      private function createPetsWindows() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         while(dropDown.itemWindow.numChildren > 2)
         {
            dropDown.itemWindow.removeChildAt(dropDown.itemWindow.numChildren - 1);
         }
         if(_itemWindows && _itemWindows.numChildren > 0)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_pets)
         {
            _loc2_ = int(_pets.length);
            _loc3_ = Math.min(_loc2_,4);
            _loc1_ = Math.ceil(_loc3_ / 4);
            _itemWindows = new WindowAndScrollbarGenerator();
            _itemWindows.init(dropDown.itemWindow.width,dropDown.itemWindow.height,-12,0,_loc3_,_loc1_,_loc2_,2,0,0,0,ItemWindowAvtPetSml,_pets,"",0,{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"isPet":true});
            dropDown.itemWindow.addChild(_itemWindows);
         }
      }
      
      private function getPVPIcons() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MediaHelper = null;
         _views = [];
         _loc1_ = 0;
         while(_loc1_ < _pvpGameList.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(_pvpGameList[_loc1_].gameLibraryIconMediaId,mediaHelperCallback,true);
            _views[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc4_:Number = NaN;
         _loc3_ = 0;
         while(_loc3_ < _views.length)
         {
            if(_views[_loc3_] == param1.mediaHelper)
            {
               _loc2_ = MovieClip(_pvpItemWindows.bg.getChildAt(_loc3_));
               param1 = param1.getChildAt(0) as MovieClip;
               _loc4_ = _loc2_.itemLayer.height / Math.max(param1.sizeCont.width,param1.sizeCont.height);
               param1.scaleX = param1.scaleY = _loc4_;
               param1.sizeCont.scaleX = param1.sizeCont.scaleY = _loc4_;
               param1.x += param1.sizeCont.width * 0.5;
               param1.y += param1.sizeCont.height * 0.5;
               _loc2_.itemLayer.addChild(param1);
            }
            _loc3_++;
         }
      }
      
      private function createPVPWindows() : void
      {
         if(_pvpScrollBar)
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(_pvpItemWindows && _pvpItemWindows.numChildren > 0)
         {
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         var _loc1_:int = int(_pvpGameList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         _pvpItemWindows = new WindowGenerator();
         _pvpItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },null,null,false,false);
         gameTabItemWindow.addChild(_pvpItemWindows);
         _pvpScrollBar = new SBScrollbar();
         _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",78,0,Math.ceil(_loc1_ / _loc2_) * 78);
      }
      
      private function createTradeWindows() : void
      {
         if(_tradeScrollBar)
         {
            _tradeScrollBar.destroy();
            _tradeScrollBar = null;
         }
         if(_tradeItemWindows)
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         if(_tradeItemWindows && _tradeItemWindows.numChildren > 0)
         {
            _tradeItemWindows.destroy();
            _tradeItemWindows = null;
         }
         var _loc1_:int = int(_tradeList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         _tradeItemWindows = new WindowGenerator();
         _tradeItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,1,ItemWindowOriginal,_tradeList.getCoreArray(),"icon",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseSideOut
         },{"isViewingATradeList":true},null,false,false);
         tradeTabItemWindow.addChild(_tradeItemWindows);
         _loadingSpiralPullOut.visible = false;
         _tradeScrollBar = new SBScrollbar();
         _tradeScrollBar.init(_tradeItemWindows,176,172,0,"scrollbar2",86);
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.hasOwnProperty("charLayer"))
         {
            GuiManager.toolTip.init(dropDown.itemWindow,_achievements[param1.currentTarget.index].name,param1.currentTarget.x + param1.currentTarget.width * 0.5,param1.currentTarget.y + _itemWindows.y + 60 - _itemWindows.scrollYValue);
            GuiManager.toolTip.startTimer(param1);
         }
         else
         {
            param1.currentTarget.gotoAndStop("over");
            GuiManager.toolTip.init(dropDown.itemWindow,param1.currentTarget.toolTipName,param1.currentTarget.x + param1.currentTarget.sel.width * 0.5,param1.currentTarget.y + _itemWindows.y + 60 - _itemWindows.scrollYValue);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function sideMenuMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         if(_isGameTabOpen)
         {
            if(param1.currentTarget.parent.numChildren > 0)
            {
               GuiManager.toolTip.init(gameTabItemWindow,LocalizationManager.translateIdOnly(_pvpGameList[param1.currentTarget.index].titleStrId),param1.currentTarget.x + param1.currentTarget.width * 0.5,param1.currentTarget.y + _pvpItemWindows.y + 80);
               GuiManager.toolTip.startTimer(param1);
            }
         }
         else if(_isTradingTabOpen)
         {
            if(param1.currentTarget.numChildren >= 2)
            {
               _loc2_ = param1.currentTarget.getChildAt(0);
               if(param1.currentTarget.cir.currentFrameLabel == "down")
               {
                  param1.currentTarget.cir.gotoAndStop("downMouse");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("over");
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseSideOut(param1:MouseEvent) : void
      {
         if(_isTradingTabOpen)
         {
            if(param1.currentTarget.numChildren >= 2 && param1.currentTarget.cir)
            {
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("down");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "down")
               {
                  param1.currentTarget.cir.gotoAndStop("up");
               }
            }
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         if(_isDropDownOpen && _buddyCardMC && (petsBtnUp.visible || charsBtnUp.visible))
         {
            param1.currentTarget.gotoAndStop("up");
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function winMouseClick(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         param1.currentTarget.gotoAndStop("down");
         _loc3_ = 0;
         while(_loc3_ < _itemWindows.bg.numChildren)
         {
            _loc2_ = MovieClip(_itemWindows.bg.getChildAt(_loc3_));
            _loc2_.sel.visible = false;
            _loc3_++;
         }
         param1.currentTarget.sel.visible = true;
         if(param1.currentTarget.isPet)
         {
            xpShape.visible = false;
            drawMainPet(_pets[param1.currentTarget.index].idx);
         }
         else
         {
            xpShape.visible = true;
            drawMainAvatar(_playerAvatars[param1.currentTarget.index]);
         }
      }
      
      private function sideMenuMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Buddy = null;
         var _loc4_:Iitem = null;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:Iitem = null;
         var _loc7_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == "previewBtn")
         {
            if(_isTradingTabOpen)
            {
               _loc4_ = _tradeList.getIitem(param1.currentTarget.parent.parent.index);
               if(_loc4_ is DenItem)
               {
                  GuiManager.openMasterpiecePreview((_loc4_ as DenItem).uniqueImageId,(_loc4_ as DenItem).uniqueImageCreator,(_loc4_ as DenItem).uniqueImageCreatorDbId,(_loc4_ as DenItem).uniqueImageCreatorUUID,(_loc4_ as DenItem).version,_currUserName,_loc4_ as DenItem);
               }
            }
         }
         else if(param1.currentTarget.name == "certBtn")
         {
            if(_isTradingTabOpen)
            {
               _loc4_ = param1.currentTarget.parent.parent.currItem;
               if(_loc4_ is PetItem)
               {
                  GuiManager.openPetCertificatePopup((_loc4_ as PetItem).largeIcon as GuiPet,null);
               }
            }
         }
         else if(_isGameTabOpen)
         {
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,param1);
               return;
            }
            if(_buddyNode != null && gMainFrame.server.serverIp != _buddyNode)
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14702),true,onConfirmServerSwitch);
               return;
            }
            if(_buddyRoomNameWithNodeIp != gMainFrame.server.getCurrentRoomName())
            {
               _loc3_ = int(!!_buddyRoomNameWithoutNodeIp ? _buddyRoomNameWithoutNodeIp.indexOf("_") : 0);
               if(_buddyRoomNameWithoutNodeIp == null || _loc3_ > 0 && !isNaN(Number(_buddyRoomNameWithoutNodeIp.charAt(_loc3_ - 1))) && !isNaN(Number(_buddyRoomNameWithoutNodeIp.charAt(_loc3_ + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14701,_currUserNameModerated));
                  return;
               }
            }
            MinigameManager.checkAndStartPvpGame(_pvpGameList[param1.currentTarget.index],_currUserName,_currUserNameModerated);
            destroy();
         }
         else if(_isTradingTabOpen)
         {
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(sideMenuMouseDown,param1);
               return;
            }
            if(_buddyNode != null && gMainFrame.server.serverIp != _buddyNode)
            {
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14704),true,onConfirmServerSwitch);
               return;
            }
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(_loc2_ && _buddyRoomNameWithNodeIp != gMainFrame.server.getCurrentRoomName())
            {
               _loc6_ = int(!!_buddyRoomNameWithoutNodeIp ? _buddyRoomNameWithoutNodeIp.indexOf("_") : 0);
               if(_buddyRoomNameWithoutNodeIp == null || _loc6_ > 0 && !isNaN(Number(_buddyRoomNameWithoutNodeIp.charAt(_loc6_ - 1))) && !isNaN(Number(_buddyRoomNameWithoutNodeIp.charAt(_loc6_ + 1))))
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(11388,_currUserNameModerated));
                  return;
               }
            }
            TradeXtCommManager.sendTradeBusyRequest(true);
            TradeManager.isCurrentlyTrading = true;
            _loc5_ = _tradeList.getIitem(param1.currentTarget.index);
            if(_loc5_.isApproved)
            {
               if(_loc5_ is Item)
               {
                  _loc7_ = 0;
               }
               else if(_loc5_ is DenItem)
               {
                  _loc7_ = 1;
               }
               else if(_loc5_ is PetItem)
               {
                  _loc7_ = 3;
               }
               TradeManager.displayRequestTrade({
                  "currUsernameToTradeTo":_currUserName,
                  "itemToTrade":new TradeItem(_loc5_.invIdx,_loc7_)
               });
            }
            else
            {
               new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(25197));
            }
         }
      }
      
      private function onConfirmServerSwitch(param1:Object) : void
      {
         if(param1.status)
         {
            gotoDownHandler(null);
         }
      }
      
      private function dropDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = Number(new Date().getTime());
         if(param1.currentTarget.name == charsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(dropDownTitleTxt,11238);
                  charsBtnUp.visible = true;
                  awardsBtnUp.visible = false;
                  petsBtnUp.visible = false;
                  checkListBtn.visible = false;
                  openDropDown(dropDown);
                  if(_loc2_ - _avatarTimeStamp > 10000)
                  {
                     requestAvatarList(true);
                     _avatarTimeStamp = _loc2_;
                  }
                  else
                  {
                     createAvatarWindows();
                  }
               }
            }
            else
            {
               closeDropDown(dropDown);
            }
         }
         else if(param1.currentTarget.name == charsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            LocalizationManager.translateId(dropDownTitleTxt,11238);
            charsBtnUp.visible = true;
            awardsBtnUp.visible = false;
            petsBtnUp.visible = false;
            checkListBtn.visible = false;
            if(!_isDropDownOpen)
            {
               openDropDown(dropDown);
            }
            if(_loc2_ - _avatarTimeStamp > 10000)
            {
               requestAvatarList(true);
               _avatarTimeStamp = _loc2_;
            }
            else
            {
               createAvatarWindows();
            }
         }
         else if(param1.currentTarget.name == awardsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(dropDownTitleTxt,11239);
                  awardsBtnUp.visible = true;
                  charsBtnUp.visible = false;
                  petsBtnUp.visible = false;
                  checkListBtn.visible = false;
                  openDropDown(dropDown);
                  if(_loc2_ - _achievementTimeStamp > 10000)
                  {
                     requestAchievementsList();
                     _achievementTimeStamp = _loc2_;
                  }
                  else
                  {
                     createAchievementsWindows();
                  }
               }
            }
            else
            {
               closeDropDown(dropDown);
            }
         }
         else if(param1.currentTarget.name == awardsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            LocalizationManager.translateId(dropDownTitleTxt,11239);
            awardsBtnUp.visible = true;
            charsBtnUp.visible = false;
            petsBtnUp.visible = false;
            checkListBtn.visible = false;
            if(!_isDropDownOpen)
            {
               openDropDown(dropDown);
            }
            if(_loc2_ - _achievementTimeStamp > 10000)
            {
               requestAchievementsList();
               _achievementTimeStamp = _loc2_;
            }
            else
            {
               createAchievementsWindows();
            }
         }
         else if(param1.currentTarget.name == petsBtnUp.name)
         {
            if(!_isDropDownOpen)
            {
               if(!_loadingSpiralDropDown.visible)
               {
                  LocalizationManager.translateId(dropDownTitleTxt,11240);
                  petsBtnUp.visible = true;
                  awardsBtnUp.visible = false;
                  charsBtnUp.visible = false;
                  checkListBtn.visible = false;
                  openDropDown(dropDown);
                  if(_loc2_ - _petsTimeStamp > 10000)
                  {
                     requestPetsList();
                     _petsTimeStamp = _loc2_;
                  }
                  else
                  {
                     createPetsWindows();
                  }
               }
            }
            else
            {
               closeDropDown(dropDown);
            }
         }
         else if(param1.currentTarget.name == petsBtnDn.name && !_loadingSpiralDropDown.visible)
         {
            LocalizationManager.translateId(dropDownTitleTxt,11240);
            petsBtnUp.visible = true;
            awardsBtnUp.visible = false;
            charsBtnUp.visible = false;
            checkListBtn.visible = false;
            requestAdoptAPetCount();
            if(!_isDropDownOpen)
            {
               openDropDown(dropDown);
            }
            if(_loc2_ - _petsTimeStamp > 10000)
            {
               requestPetsList();
               _petsTimeStamp = _loc2_;
            }
            else
            {
               createPetsWindows();
            }
         }
      }
      
      private function requestAdoptAPetCount() : void
      {
         checkListBtn.activateLoadingState(true,checkListBtn.icon);
         AdoptAPetXtCommManager.requestPetAdoptUsableCount(_currUserName,onAdoptAPetCount);
      }
      
      private function onAdoptAPetCount(param1:int) : void
      {
         if(param1 > 0)
         {
            checkListBtn.visible = true;
            checkListBtn.activateLoadingState(false,checkListBtn.icon);
         }
         else
         {
            checkListBtn.visible = false;
            checkListBtn.activateLoadingState(false,checkListBtn.icon);
            checkListBtn.activateGrayState(true);
         }
      }
      
      private function onCheckListBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_checkListPopup)
            {
               onCheckListClose();
            }
            _checkListPopup = new CheckListPopup();
            _checkListPopup.init(onCheckListClose,_currUserName);
         }
      }
      
      private function onCheckListClose() : void
      {
         if(_checkListPopup)
         {
            _checkListPopup.destroy();
            _checkListPopup = null;
         }
      }
      
      private function sideMenuHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!_isGameTabOpen && param1.currentTarget.name == gameTabBtn.name)
         {
            if(!gameTabBtn.isGray)
            {
               if(_isTradingTabOpen)
               {
                  closeSideMenu(tradeTab);
               }
               if(_pvpItemWindows == null)
               {
                  _pvpGameList = MinigameManager.minigameInfoCache.getAllReadyForPvpGameDefs();
                  createPVPWindows();
                  getPVPIcons();
               }
               else
               {
                  gameTabItemWindow.addChild(_pvpItemWindows);
                  if(_pvpScrollBar)
                  {
                     _pvpScrollBar.destroy();
                  }
                  _pvpScrollBar = new SBScrollbar();
                  _pvpScrollBar.init(_pvpItemWindows,155,156,0,"scrollbar2",77);
               }
               openSideMenu(gameTab);
            }
         }
         else if(param1.currentTarget.name == gameTabBtn.name && _isGameTabOpen)
         {
            closeSideMenu(gameTab);
         }
         else if(param1.currentTarget.name == tradeTabBtn.name && _isTradingTabOpen)
         {
            closeSideMenu(tradeTab);
         }
         else if(!tradeTabBtn.isGray)
         {
            if(_isGameTabOpen)
            {
               closeSideMenu(gameTab);
            }
            _loadingSpiralPullOut.visible = true;
            TradeXtCommManager.sendTradeListRequest(_currUserName);
            openSideMenu(tradeTab);
            if(!gMainFrame.userInfo.userVarCache.isBitSet(129,1))
            {
               tradeHelpPopup.visible = true;
               LocalizationManager.translateId(tradeHelpPopup.txt,11241);
               AchievementXtCommManager.requestSetUserVar(129,1);
            }
         }
      }
      
      private function sideMenuOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == gameTabBtn.name)
         {
            if(_isGameTabOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14630),308,45);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14630),516,45);
            }
         }
         else if(_isTradingTabOpen)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14631),300,175);
         }
         else
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14631),520,175);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function dropDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == charsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),787,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),787,270);
            }
         }
         else if(param1.currentTarget.name == awardsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,270);
            }
         }
         else if(param1.currentTarget.name == petsBtnUp.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),733,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),733,270);
            }
         }
         else if(param1.currentTarget.name == charsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),787,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11238),787,270);
            }
         }
         else if(param1.currentTarget.name == awardsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11239),843,270);
            }
         }
         else if(param1.currentTarget.name == petsBtnDn.name)
         {
            if(_isDropDownOpen)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),733,435);
            }
            else
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(11240),733,270);
            }
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function openDropDown(param1:MovieClip) : void
      {
         if(_bDropDownTweenFinished && !_isDropDownOpen)
         {
            new GTween(param1,0.5,{"y":param1.y + 178},{
               "ease":Quadratic.easeIn,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private function closeDropDown(param1:MovieClip) : void
      {
         if(_isDropDownOpen && _bDropDownTweenFinished)
         {
            new GTween(param1,0.5,{"y":param1.y - 178},{
               "ease":Quadratic.easeIn,
               "onComplete":dropDownComplete
            });
            _bDropDownTweenFinished = false;
            _isDropDownOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private function openSideMenu(param1:MovieClip) : void
      {
         var _loc2_:Buddy = BuddyManager.getBuddyByUserName(_currUserName);
         if(param1 == gameTab && _sideMenuTweenFinished && !_isGameTabOpen && !gameTabBtn.isGray)
         {
            new GTween(param1,0.5,{"x":param1.x - 208},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            if(_buddyCardMC.getChildIndex(gameTab) < _buddyCardMC.getChildIndex(tradeTab))
            {
               _buddyCardMC.swapChildren(gameTab,tradeTab);
            }
            _sideMenuTweenFinished = false;
            _isGameTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
         else if(param1 == tradeTab && _sideMenuTweenFinished && !_isTradingTabOpen && !tradeTabBtn.isGray)
         {
            new GTween(param1,0.5,{"x":param1.x - 231},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            if(_buddyCardMC.getChildIndex(gameTab) > _buddyCardMC.getChildIndex(tradeTab))
            {
               _buddyCardMC.swapChildren(gameTab,tradeTab);
            }
            _sideMenuTweenFinished = false;
            _isTradingTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private function closeSideMenu(param1:MovieClip) : void
      {
         if(param1 == gameTab && _isGameTabOpen && _sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x + 208},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isGameTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
         else if(param1 == tradeTab && _isTradingTabOpen && _sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x + 231},{
               "ease":Quadratic.easeIn,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isTradingTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private function dropDownComplete(param1:GTween) : void
      {
         _bDropDownTweenFinished = true;
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         _sideMenuTweenFinished = true;
      }
      
      private function buddyCardAddIgnoreConfirmCallback(param1:Object) : void
      {
         if(param1.status && _currUserName.length > 0)
         {
            blockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyBlockRequest(_currUserName);
            delete PlayerWallManager.tokenMap[_currUserName.toLowerCase()];
         }
      }
      
      public function buddyCardRemoveIgnoreConfirmCallback(param1:Object, param2:Boolean = false) : void
      {
         if(param1.status && _currUserName.length > 0)
         {
            unblockBtn.activateGrayState(true);
            BuddyXtCommManager.sendBuddyUnblockRequest(_currUserName,param2);
         }
      }
      
      private function gotoDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:AvatarWorldView = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!goToBtn.isGray)
         {
            if(gMainFrame.server.getCurrentRoomName() == _buddyRoomNameWithNodeIp)
            {
               _loc2_ = AvatarManager.avatarViewList;
               for(var _loc4_ in _loc2_)
               {
                  _loc3_ = _loc2_[_loc4_];
                  if(_loc3_ && _loc3_.userName == _currUserName)
                  {
                     RoomManagerWorld.instance.setMovePlayerPosition(_loc3_.avatarPos);
                     break;
                  }
               }
            }
            else if(!GuiManager.mainHud.swapBtn.isGray)
            {
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager._seekBuddyName = _currUserName;
               RoomXtCommManager.sendRoomJoinRequest(_buddyRoomNameWithNodeIp,-1,false,false,true,RoomJoinType.DIRECT_JOIN_AND_HALT_ON_FAILURE);
            }
            else if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(gotoDownHandler,param1);
            }
         }
      }
      
      private function goToRollOverHandler(param1:MouseEvent) : void
      {
         if(_currUserIsBuddy && !goToBtn.isGray)
         {
            if(locationPopupTxt.text != "")
            {
               locationPopup.visible = true;
            }
         }
      }
      
      private function goToRollOutHandler(param1:MouseEvent) : void
      {
         locationPopup.visible = false;
      }
      
      private function resizeLocationToolTip() : void
      {
         locationPopupTxt.width = int(locationPopupTxt.textWidth + 10);
         locationPopup.m.width = locationPopupTxt.width;
         locationPopup.l.x = 0;
         locationPopup.m.x = locationPopup.l.x + locationPopup.l.width;
         locationPopup.r.x = locationPopup.m.x + locationPopup.m.width;
         locationPopupTxt.x = locationPopup.m.x;
         locationPopup.x = goToBtn.x - (locationPopup.l.width + locationPopup.m.width + locationPopup.r.width) * 0.5;
      }
      
      private function petCertBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openPetCertificatePopup(_mainPetView,null);
      }
      
      private function petCertBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(27437),720,50);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function petCertBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function get currBuddyCardUserName() : String
      {
         if(_currUserName != "")
         {
            return _currUserName.toLowerCase();
         }
         return "";
      }
      
      private function denDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(denBtn.isGray || bigDenBtn.isGray)
         {
            return;
         }
         if(_currUserName != "")
         {
            if(QuestManager.isInPrivateAdventureState)
            {
               QuestManager.showLeaveQuestLobbyPopup(denDownHandler,param1);
               return;
            }
            if(!RoomXtCommManager.isSwitching)
            {
               DenXtCommManager.requestDenJoinFull("den" + _currUserName);
            }
         }
      }
      
      private function denDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(denBtn.isGray || bigDenBtn.isGray)
         {
            return;
         }
         var _loc2_:Point = param1.currentTarget == denBtn ? new Point(795,97) : new Point(822,100);
         GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14632),_loc2_.x,_loc2_.y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function jammerPartyDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(jammerPartyBtn.isGray)
         {
            return;
         }
         if(_currUserName != "" && _userInfo != null)
         {
            if(_userInfo.isStillHosting)
            {
               if(!RoomXtCommManager.isSwitching)
               {
                  PartyManager.sendCustomPartyJoin(_currUserName,_userInfo.uuid,null);
               }
            }
            else
            {
               setGrayStateForJammerPartyBtn(true);
            }
         }
      }
      
      private function jammerPartyOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(jammerPartyBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(24267),922,102);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function reportDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
            }
            else
            {
               _reportAPlayer = new ReportAPlayer();
               _reportAPlayer.init(1,GuiManager.guiLayer,onReportAPlayerClose,true,_currUserName,_currUserNameModerated,true,null,-1,900 * 0.5,550 * 0.5);
            }
         }
      }
      
      private function reportDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14633),845,210);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private function mailDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            ECardManager.openCreateCard(_currUserName,_currUserNameModerated,_currUserAccountType,false);
         }
      }
      
      private function mailDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14634),824,155);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function addRemoveBuddyDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == addBuddyBtn.name)
            {
               if(BuddyManager.isBuddy(_currUserName))
               {
                  throw new Error("ERROR: Trying to add a buddy that is already a buddy! userName=" + _currUserName);
               }
               addBuddyBtn.activateGrayState(true);
               BuddyManager.addRemoveBuddy(_currUserName,_currUserNameModerated,true);
            }
            else if(param1.currentTarget.name == removeBuddyBtn.name)
            {
               if(!BuddyManager.isBuddy(_currUserName))
               {
                  throw new Error("ERROR: Trying to remove a buddy that is already not a buddy! userName=" + _currUserName);
               }
               new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14705,_currUserNameModerated),true,removeBuddyConfirmCallback,{
                  "currUserName":_currUserName,
                  "currUserNameModerated":_currUserNameModerated
               });
            }
         }
      }
      
      private function addRemoveBuddyDownOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == addBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14635),822,47);
            }
            else if(param1.currentTarget.name == removeBuddyBtn.name)
            {
               GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14636),822,47);
            }
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onPlayerWallDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!playerWallBtn.isGray)
         {
            setPlayerWallLoading(true);
            PlayerWallManager.closeWalls();
            PlayerWallManager.openStrangersPlayerWall(_currUserName,_userInfo.getModeratedUserName(),_userInfo.uuid);
         }
      }
      
      private function onPlayerWallOver(param1:MouseEvent) : void
      {
         if(!playerWallBtn.isGray)
         {
            GuiManager.toolTip.init(_popupLayer,LocalizationManager.translateIdOnly(14637),792,155);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function removeBuddyConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            removeBuddyBtn.activateGrayState(true);
            BuddyManager.addRemoveBuddy(param1.passback.currUserName,param1.passback.currUserNameModerated,false);
         }
      }
      
      private function buddyRoomTimerHandler(param1:TimerEvent) : void
      {
         BuddyXtCommManager.sendBuddyRoomRequest(_currUserName);
      }
      
      private function closeTradeHelp(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         tradeHelpPopup.visible = false;
      }
      
      private function buddyChangedHandler(param1:BuddyEvent) : void
      {
         var _loc2_:Buddy = null;
         var _loc3_:Boolean = false;
         if(param1.userName.toLowerCase() == _currUserName.toLowerCase())
         {
            _loc2_ = BuddyManager.getBuddyByUserName(_currUserName);
            if(_currUserIsBuddy && !_loc2_)
            {
               _currUserIsBuddy = false;
               addBuddyBtn.visible = true;
               if(_currUserIsArchived)
               {
                  addBuddyBtn.activateGrayState(true);
               }
               removeBuddyBtn.visible = false;
               removeBuddyBtn.activateGrayState(false);
               goToBtn.activateGrayState(true);
               gameTabBtn.activateGrayState(true);
               if(!_currUserIsArchived && _currUserIsOnline && !shouldGrayOut())
               {
                  tradeTabBtn.activateGrayState(false);
                  gameTabBtn.activateGrayState(false);
               }
               else if(!_currUserIsOnline)
               {
                  tradeTabBtn.activateGrayState(true);
                  gameTabBtn.activateGrayState(true);
               }
               if(!_currUserIsArchived && !shouldGrayOut())
               {
                  DenXtCommManager.requestUserDenPrivacy(_currUserName);
                  getPlayerWallPrivacySettings();
                  getJammerPartyIsActive();
               }
               _buddyRoomTimer.reset();
            }
            else if(!_currUserIsBuddy && _loc2_)
            {
               _currUserIsOnline = _loc2_.isOnline;
               _currUserIsBuddy = true;
               addBuddyBtn.visible = false;
               addBuddyBtn.activateGrayState(false);
               removeBuddyBtn.visible = true;
               if(!shouldGrayOut())
               {
                  denBtn.activateGrayState(false);
                  bigDenBtn.activateGrayState(false);
                  gameTabBtn.activateGrayState(false);
                  tradeTabBtn.activateGrayState(false);
                  getPlayerWallPrivacySettings();
                  getJammerPartyIsActive();
               }
               if(shouldShowGoToBtn())
               {
                  goToBtn.activateGrayState(false);
               }
               _buddyRoomTimer.start();
            }
            else if(!_currUserIsOnline && _loc2_ && _loc2_.isOnline)
            {
               _currUserIsOnline = true;
               if(!shouldGrayOut())
               {
                  gameTabBtn.activateGrayState(false);
                  tradeTabBtn.activateGrayState(false);
               }
               _buddyRoomTimer.start();
               _isRequestingData = true;
               AvatarXtCommManager.requestAvatarGet(_currUserName,onAvatarGetReceived);
            }
            else if(_currUserIsOnline && _loc2_ && !_loc2_.isOnline)
            {
               _currUserIsOnline = false;
               _buddyRoomDisplayName = "";
               _buddyNode = null;
               _buddyRoomNameWithNodeIp = "";
               _buddyRoomNameWithoutNodeIp = "";
               _buddyRoomTimer.reset();
               goToBtn.activateGrayState(true);
               gameTabBtn.activateGrayState(true);
               tradeTabBtn.activateGrayState(true);
               LocalizationManager.translateId(locationPopupTxt,11235);
               _locationTxtBeforeOverCharBox = locationPopupTxt.text;
               resizeLocationToolTip();
            }
            else
            {
               _loc3_ = BuddyManager.isBlocked(_currUserName);
               if(_currUserIsBlocked && !_loc3_)
               {
                  _currUserIsBlocked = false;
                  blockBtn.visible = true;
                  unblockBtn.visible = false;
                  unblockBtn.activateGrayState(false);
               }
               else if(!_currUserIsBlocked && _loc3_)
               {
                  _currUserIsBlocked = true;
                  blockBtn.visible = false;
                  blockBtn.activateGrayState(false);
                  unblockBtn.visible = true;
               }
            }
         }
      }
      
      public function buddyRoomResponseHandler(param1:String, param2:String, param3:int, param4:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc5_:Array = null;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         if(_buddyCardMC)
         {
            if((param2 == null || param2 == "") && param3 > 0)
            {
               param2 = LocalizationManager.translateIdOnly(param3);
            }
            if(_buddyRoomNameWithNodeIp != param1 || param2 != _buddyRoomDisplayName)
            {
               _buddyRoomNameWithNodeIp = param1;
               _loc6_ = int(param1.indexOf("@"));
               if(_loc6_ >= 0)
               {
                  _buddyNode = param1.substr(_loc6_ + 1);
                  _buddyRoomNameWithoutNodeIp = param1.substring(0,_loc6_);
               }
               else
               {
                  _buddyNode = null;
                  _buddyRoomNameWithoutNodeIp = param1;
               }
               if(param2 == null || param2 == "")
               {
                  LocalizationManager.translateId(locationPopupTxt,11235);
                  _buddyRoomDisplayName = _locationTxtBeforeOverCharBox = locationPopupTxt.text;
                  resizeLocationToolTip();
                  goToBtn.activateGrayState(true);
                  _buddyRoomTimer.reset();
                  _currUserIsOnline = false;
                  return;
               }
               if(param2 == "Choosing Server")
               {
                  locationPopupTxt.text = _locationTxtBeforeOverCharBox = _buddyRoomDisplayName = param2;
                  resizeLocationToolTip();
                  goToBtn.activateGrayState(true);
                  _currUserIsOnline = false;
                  return;
               }
               if(param2 == LocalizationManager.translateIdOnly(11235))
               {
                  _buddyRoomTimer.reset();
                  locationPopupTxt.text = _locationTxtBeforeOverCharBox = _buddyRoomDisplayName = param2;
                  resizeLocationToolTip();
                  goToBtn.activateGrayState(true);
                  _currUserIsOnline = false;
                  return;
               }
               if(param1.indexOf("pparty") == 0)
               {
                  _loc5_ = param2.split("|");
                  param2 = LocalizationManager.translateIdOnly(_loc5_[0]) + " " + LocalizationManager.translateIdOnly(_loc5_[1]) + " " + LocalizationManager.translateIdOnly(_loc5_[2]);
               }
               _loc7_ = param2.split("\'");
               if(_loc7_ && _loc7_.length > 1)
               {
                  if(_currUserName.toLowerCase() == _loc7_[0].toLowerCase())
                  {
                     param2 = _currUserNameModerated + "\'" + _loc7_[1];
                  }
               }
               _loc8_ = _buddyRoomDisplayName = param2;
               if(_loc8_.indexOf("Den") != -1)
               {
                  if(param3 != 0)
                  {
                     locationPopupTxt.text = LocalizationManager.translateIdOnly(param3);
                  }
                  else
                  {
                     locationPopupTxt.text = normalizeName(_loc8_);
                  }
               }
               else
               {
                  locationPopupTxt.text = LocalizationManager.translateIdAndInsertOnly(18427,_currUserNameModerated);
               }
               _locationTxtBeforeOverCharBox = locationPopupTxt.text;
               resizeLocationToolTip();
               checkBuddyRoomAgainstMine(param4);
               _currUserIsOnline = true;
               if(!_currUserIsOnline || shouldGrayOut())
               {
                  if(tradeTabBtn.hasGrayState)
                  {
                     tradeTabBtn.activateGrayState(true);
                  }
                  if(gameTabBtn.hasGrayState)
                  {
                     gameTabBtn.activateGrayState(true);
                  }
               }
               else
               {
                  if(tradeTabBtn.hasGrayState)
                  {
                     tradeTabBtn.activateGrayState(false);
                  }
                  if(gameTabBtn.hasGrayState)
                  {
                     gameTabBtn.activateGrayState(false);
                  }
               }
            }
         }
      }
      
      private function shouldShowGoToBtn() : Boolean
      {
         return !(_buddyRoomDisplayName == LocalizationManager.translateIdOnly(11235) || _buddyRoomDisplayName == "Choosing Server");
      }
      
      public function buddyBlockInfoResponseHandler(param1:String, param2:Boolean) : void
      {
         if(_currUserName.toLowerCase() == param1.toLowerCase())
         {
            _currUserBlocked = param2;
            if(playerWallBtn.loadingCont.visible)
            {
               playerWallBtn.activateLoadingState(false);
               playerWallBtn.activateGrayState(param2);
            }
            denBtn.activateGrayState(param2);
            bigDenBtn.activateGrayState(param2);
            if(_userInfo && _userInfo.isStillHosting)
            {
               setGrayStateForJammerPartyBtn(param2);
            }
         }
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(22);
      }
      
      private function normalizeName(param1:String) : String
      {
         var _loc4_:int = 0;
         var _loc3_:Array = param1.split(" ");
         var _loc2_:int = int(_loc3_.length);
         while(_loc4_ < _loc2_)
         {
            _loc3_[_loc4_] = capitalizeFirstLetter(_loc3_[_loc4_]);
            _loc4_++;
         }
         return _loc3_.join(" ");
      }
      
      public function joinBuddyInQuest() : Boolean
      {
         if(_currUserName.length > 0)
         {
            QuestXtCommManager.sendQuestJoinBuddy(_currUserName);
            return true;
         }
         return false;
      }
      
      private function capitalizeFirstLetter(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc2_:String = null;
         switch(param1)
         {
            case "and":
            case "the":
            case "in":
            case "an":
            case "or":
            case "at":
            case "of":
            case "a":
               break;
            default:
               _loc3_ = param1.substr(0,1);
               _loc3_ = _loc3_.toUpperCase();
               _loc2_ = param1.substring(1);
               param1 = _loc3_ + _loc2_;
         }
         return param1;
      }
      
      private function getGuideText(param1:String) : String
      {
         var _loc2_:* = null;
         var _loc3_:* = param1;
         return "";
      }
      
      private function onCardDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _popupLayer.setChildIndex(_buddyCardMC,_popupLayer.numChildren - 1);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function stopListeners(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCharBoxOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         param1.stopPropagation();
         var _loc3_:int = int(!!_userInfo ? _userInfo.daysSinceLastLogin : 30);
         if(!goToBtn.isGray && _currUserIsBuddy)
         {
            if(locationPopupTxt.text == "")
            {
               _loc2_ = LocalizationManager.translateIdOnly(11251);
            }
            else
            {
               _loc2_ = locationPopupTxt.text;
            }
         }
         else if(_loc3_ == 0)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11252);
         }
         else if(_loc3_ == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11253);
         }
         else if(_loc3_ > 1 && _loc3_ < 31)
         {
            _loc2_ = LocalizationManager.translateIdAndInsertOnly(11254,_loc3_);
         }
         else if(_loc3_ > 30 || _loc3_ == -1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11255);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11256);
         }
         _locationTxtBeforeOverCharBox = locationPopupTxt.text;
         locationPopupTxt.text = _loc2_;
         locationPopup.visible = true;
         resizeLocationToolTip();
      }
      
      private function onCharBoxOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         locationPopup.visible = false;
         locationPopupTxt.text = _locationTxtBeforeOverCharBox;
         resizeLocationToolTip();
      }
      
      private function addCardListeners() : void
      {
         if(_buddyCardMC)
         {
            if(Utility.canBuddy())
            {
               addBuddyBtn.addEventListener("mouseDown",addRemoveBuddyDownHandler,false,0,true);
               addBuddyBtn.addEventListener("mouseOver",addRemoveBuddyDownOverHandler,false,0,true);
               addBuddyBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
               mailBtn.addEventListener("mouseDown",mailDownHandler,false,0,true);
               mailBtn.addEventListener("mouseOver",mailDownOverHandler,false,0,true);
               mailBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            }
            else
            {
               addBuddyBtn.activateGrayState(true);
               mailBtn.activateGrayState(true);
            }
            if(!Utility.canJAG() || shouldGrayOut())
            {
               mailBtn.activateGrayState(true);
            }
            if(Utility.canPVP())
            {
               gameTabBtn.addEventListener("mouseDown",sideMenuHandler,false,0,true);
               gameTabBtn.addEventListener("mouseOver",sideMenuOverHandler,false,0,true);
               gameTabBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            }
            else
            {
               gameTabBtn.activateGrayState(true);
            }
            if(Utility.canTrade())
            {
               tradeTabBtn.addEventListener("mouseDown",sideMenuHandler,false,0,true);
               tradeTabBtn.addEventListener("mouseOver",sideMenuOverHandler,false,0,true);
               tradeTabBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            }
            else
            {
               tradeTabBtn.activateGrayState(true);
            }
            removeBuddyBtn.addEventListener("mouseDown",addRemoveBuddyDownHandler,false,0,true);
            removeBuddyBtn.addEventListener("mouseOver",addRemoveBuddyDownOverHandler,false,0,true);
            removeBuddyBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            playerWallBtn.addEventListener("mouseDown",onPlayerWallDown,false,0,true);
            playerWallBtn.addEventListener("mouseOver",onPlayerWallOver,false,0,true);
            playerWallBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            denBtn.addEventListener("mouseDown",denDownHandler,false,0,true);
            denBtn.addEventListener("mouseOver",denDownOverHandler,false,0,true);
            denBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            bigDenBtn.addEventListener("mouseDown",denDownHandler,false,0,true);
            bigDenBtn.addEventListener("mouseOver",denDownOverHandler,false,0,true);
            bigDenBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            blockBtn.addEventListener("mouseDown",addRemoveBlockDownHandler,false,0,true);
            blockBtn.addEventListener("mouseOver",addRemoveBlockDownOverHandler,false,0,true);
            blockBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            unblockBtn.addEventListener("mouseDown",addRemoveBlockDownHandler,false,0,true);
            unblockBtn.addEventListener("mouseOver",addRemoveBlockDownOverHandler,false,0,true);
            unblockBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            reportBtn.addEventListener("mouseDown",reportDownHandler,false,0,true);
            reportBtn.addEventListener("mouseOver",reportDownOverHandler,false,0,true);
            reportBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            goToBtn.addEventListener("mouseDown",gotoDownHandler,false,0,true);
            goToBtn.addEventListener("mouseOver",goToRollOverHandler,false,0,true);
            goToBtn.addEventListener("mouseOut",goToRollOutHandler,false,0,true);
            petCertBtn.addEventListener("mouseDown",petCertBtnDownHandler,false,0,true);
            petCertBtn.addEventListener("mouseOver",petCertBtnOverHandler,false,0,true);
            petCertBtn.addEventListener("mouseOut",petCertBtnOutHandler,false,0,true);
            charsBtnUp.addEventListener("mouseDown",dropDownHandler,false,0,true);
            charsBtnUp.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            charsBtnUp.addEventListener("mouseOut",btnOutHandler,false,0,true);
            awardsBtnUp.addEventListener("mouseDown",dropDownHandler,false,0,true);
            awardsBtnUp.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            awardsBtnUp.addEventListener("mouseOut",btnOutHandler,false,0,true);
            petsBtnUp.addEventListener("mouseDown",dropDownHandler,false,0,true);
            petsBtnUp.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            petsBtnUp.addEventListener("mouseOut",btnOutHandler,false,0,true);
            charsBtnDn.addEventListener("mouseDown",dropDownHandler,false,0,true);
            charsBtnDn.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            charsBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            awardsBtnDn.addEventListener("mouseDown",dropDownHandler,false,0,true);
            awardsBtnDn.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            awardsBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            petsBtnDn.addEventListener("mouseDown",dropDownHandler,false,0,true);
            petsBtnDn.addEventListener("mouseOver",dropDownOverHandler,false,0,true);
            petsBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            checkListBtn.addEventListener("mouseDown",onCheckListBtn,false,0,true);
            jammerPartyBtn.addEventListener("mouseDown",jammerPartyDownHandler,false,0,true);
            jammerPartyBtn.addEventListener("mouseOver",jammerPartyOverHandler,false,0,true);
            jammerPartyBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            tradeHelpPopup.bx.addEventListener("mouseDown",closeTradeHelp,false,0,true);
            tradeTab.infoBtn.addEventListener("mouseDown",onInfoBtnDown,false,0,true);
            closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
            _buddyCardMC.addEventListener("mouseDown",stopListeners,false,0,true);
            _buddyCardMC.addEventListener("mouseOver",stopListeners,false,0,true);
            _buddyCardMC.addEventListener("mouseOut",stopListeners,false,0,true);
            _buddyCardMC.addEventListener("mouseDown",onCardDown,false,0,true);
            charBox.addEventListener("mouseOver",onCharBoxOver,false,0,true);
            charBox.addEventListener("mouseOut",onCharBoxOut,false,0,true);
         }
      }
      
      private function removeCardListeners() : void
      {
         if(_buddyCardMC)
         {
            if(Utility.canBuddy())
            {
               addBuddyBtn.removeEventListener("mouseDown",addRemoveBuddyDownHandler);
               addBuddyBtn.removeEventListener("mouseOver",addRemoveBuddyDownOverHandler);
               addBuddyBtn.removeEventListener("mouseOut",btnOutHandler);
               mailBtn.removeEventListener("mouseDown",mailDownHandler);
               mailBtn.removeEventListener("mouseOver",mailDownOverHandler);
               mailBtn.removeEventListener("mouseOut",btnOutHandler);
            }
            if(Utility.canTrade())
            {
               tradeTabBtn.removeEventListener("mouseDown",sideMenuHandler);
               tradeTabBtn.removeEventListener("mouseOver",sideMenuOverHandler);
               tradeTabBtn.removeEventListener("mouseOut",btnOutHandler);
            }
            if(Utility.canPVP())
            {
               gameTabBtn.removeEventListener("mouseDown",sideMenuHandler);
               gameTabBtn.removeEventListener("mouseOver",sideMenuOverHandler);
               gameTabBtn.removeEventListener("mouseOut",btnOutHandler);
            }
            removeBuddyBtn.removeEventListener("mouseDown",addRemoveBuddyDownHandler);
            removeBuddyBtn.removeEventListener("mouseOver",addRemoveBuddyDownOverHandler);
            removeBuddyBtn.removeEventListener("mouseOut",btnOutHandler);
            playerWallBtn.removeEventListener("mouseDown",onPlayerWallDown);
            playerWallBtn.removeEventListener("mouseOver",onPlayerWallOver);
            playerWallBtn.removeEventListener("mouseOut",btnOutHandler);
            denBtn.removeEventListener("mouseDown",denDownHandler);
            denBtn.removeEventListener("mouseOver",denDownOverHandler);
            denBtn.removeEventListener("mouseOut",btnOutHandler);
            bigDenBtn.removeEventListener("mouseDown",denDownHandler);
            bigDenBtn.removeEventListener("mouseOver",denDownOverHandler);
            bigDenBtn.removeEventListener("mouseOut",btnOutHandler);
            blockBtn.removeEventListener("mouseDown",addRemoveBlockDownHandler);
            blockBtn.removeEventListener("mouseOver",addRemoveBlockDownOverHandler);
            blockBtn.removeEventListener("mouseOut",btnOutHandler);
            unblockBtn.removeEventListener("mouseDown",addRemoveBlockDownHandler);
            unblockBtn.removeEventListener("mouseOver",addRemoveBlockDownOverHandler);
            unblockBtn.removeEventListener("mouseOut",btnOutHandler);
            reportBtn.removeEventListener("mouseDown",reportDownHandler);
            reportBtn.removeEventListener("mouseOver",reportDownOverHandler);
            reportBtn.removeEventListener("mouseOut",btnOutHandler);
            goToBtn.removeEventListener("mouseDown",gotoDownHandler);
            goToBtn.removeEventListener("mouseOver",goToRollOverHandler);
            goToBtn.removeEventListener("mouseOut",goToRollOutHandler);
            petCertBtn.removeEventListener("mouseDown",petCertBtnDownHandler);
            petCertBtn.removeEventListener("mouseOver",petCertBtnOverHandler);
            petCertBtn.removeEventListener("mouseOut",petCertBtnOutHandler);
            charsBtnUp.removeEventListener("mouseDown",dropDownHandler);
            charsBtnUp.removeEventListener("mouseOver",dropDownOverHandler);
            charsBtnUp.removeEventListener("mouseOut",btnOutHandler);
            awardsBtnUp.removeEventListener("mouseDown",dropDownHandler);
            awardsBtnUp.removeEventListener("mouseOver",dropDownOverHandler);
            awardsBtnUp.removeEventListener("mouseOut",btnOutHandler);
            petsBtnUp.removeEventListener("mouseDown",dropDownHandler);
            petsBtnUp.removeEventListener("mouseOver",dropDownOverHandler);
            petsBtnUp.removeEventListener("mouseOut",btnOutHandler);
            charsBtnDn.removeEventListener("mouseDown",dropDownHandler);
            charsBtnDn.removeEventListener("mouseOver",dropDownOverHandler);
            charsBtnDn.removeEventListener("mouseOut",btnOutHandler);
            awardsBtnDn.removeEventListener("mouseDown",dropDownHandler);
            awardsBtnDn.removeEventListener("mouseOver",dropDownOverHandler);
            awardsBtnDn.removeEventListener("mouseOut",btnOutHandler);
            petsBtnDn.removeEventListener("mouseDown",dropDownHandler);
            petsBtnDn.removeEventListener("mouseOver",dropDownOverHandler);
            petsBtnDn.removeEventListener("mouseOut",btnOutHandler);
            checkListBtn.removeEventListener("mouseDown",onCheckListBtn);
            jammerPartyBtn.removeEventListener("mouseDown",jammerPartyDownHandler);
            jammerPartyBtn.removeEventListener("mouseOver",jammerPartyOverHandler);
            jammerPartyBtn.removeEventListener("mouseOut",btnOutHandler);
            tradeHelpPopup.bx.removeEventListener("mouseDown",closeTradeHelp);
            tradeTab.infoBtn.removeEventListener("mouseDown",onInfoBtnDown);
            closeBtn.removeEventListener("mouseDown",onCloseBtn);
            _buddyCardMC.removeEventListener("mouseDown",stopListeners);
            _buddyCardMC.removeEventListener("mouseOver",stopListeners);
            _buddyCardMC.removeEventListener("mouseOut",stopListeners);
            _buddyCardMC.removeEventListener("mouseDown",onCardDown);
            charBox.removeEventListener("mouseOver",onCharBoxOver);
            charBox.removeEventListener("mouseOut",onCharBoxOut);
         }
      }
   }
}

