package gui
{
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gui.itemWindows.ItemWindowToggle;
   import localization.LocalizationManager;
   
   public class MySettings
   {
      public static var SETTINGS_BUDDY_REQUESTS:int = 0;
      
      public static var SETTINGS_GAME_INVITES:int = 1;
      
      public static var SETTINGS_DOOR_BELL:int = 2;
      
      public static var SETTINGS_AUTO_SERVER_TRAVEL:int = 3;
      
      public static var SETTINGS_USERNAME_BADGE:int = 4;
      
      public static var SETTINGS_DEN_PLAYER_ICON:int = 5;
      
      public static var SETTINGS_JAMMER_WALL_ICON:int = 6;
      
      public static var SETTINGS_CHAT_PREDICTION:int = 7;
      
      public static var TOGGLE_TYPE_TOGGLE_BTN:int = 0;
      
      public static var TOGGLE_TYPE_TEXT:int = 1;
      
      public static var TOGGLE_TYPE_CURSOR:int = 2;
      
      public static var TOGGLE_TYPE_JOIN:int = 3;
      
      public static var TOGGLE_TYPE_SCRUB:int = 4;
      
      private var _mySettings:MovieClip;
      
      private var _popupLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _wallPrivacyDropDown:GuiDropdown;
      
      private var _toggleWindows:WindowGenerator;
      
      private var _toggleScrollBar:SBScrollbar;
      
      public function MySettings()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:int, param3:int, param4:Function = null) : void
      {
         _popupLayer = param1;
         _closeCallback = param4;
         _mySettings = GETDEFINITIONBYNAME("MySettings");
         _mySettings.x = param2;
         _mySettings.y = param3;
         _popupLayer.addChild(_mySettings);
         setupContent();
         addEventListeners();
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         _popupLayer.removeChild(_mySettings);
         _closeCallback = null;
         _mySettings = null;
         if(_toggleWindows)
         {
            _toggleWindows.destroy();
            _toggleWindows = null;
         }
         if(_toggleScrollBar)
         {
            _toggleScrollBar.destroy();
            _toggleWindows = null;
         }
      }
      
      public function updateSoundBtn() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _toggleWindows.bg.numChildren)
         {
            if((_toggleWindows.bg.getChildAt(_loc1_) as ItemWindowToggle).currFrameLabel == "music")
            {
               (_toggleWindows.bg.getChildAt(_loc1_) as ItemWindowToggle).resetConditions();
               break;
            }
            _loc1_++;
         }
      }
      
      public function updateWorldMessage() : void
      {
      }
      
      private function setupContent() : void
      {
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         if(gMainFrame.userInfo.isMember)
         {
            _mySettings.statusNonmember.visible = false;
            _loc1_ = int(gMainFrame.clientInfo.numDaysLeftOnSubscription);
            if(_loc1_ > 0)
            {
               _mySettings.gotoAndStop("memberScrollSubscription");
               _loc2_ = 5;
            }
            else
            {
               _mySettings.gotoAndStop("memberScroll");
               _loc2_ = 6;
            }
            _loc5_ = int(_mySettings.itemWindow.height);
            _loc3_ = int(_mySettings.itemWindow.width);
            if(_loc1_ > 0)
            {
               if(_loc1_ > 1)
               {
                  LocalizationManager.translateIdAndInsert(_mySettings.timeRemaining.timeTxt,11361,_loc1_);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(_mySettings.timeRemaining.timeTxt,11362,_loc1_);
               }
            }
         }
         else
         {
            _mySettings.statusMember.visible = false;
            _mySettings.gotoAndStop("nonMemScroll");
            _mySettings.joinBtn.addEventListener("mouseDown",onJoinBtn,false,0,true);
            _loc2_ = 5;
            _loc5_ = int(_mySettings.itemWindow.height);
            _loc3_ = int(_mySettings.itemWindow.width);
         }
         var _loc4_:Array = [{
            "type":TOGGLE_TYPE_JOIN,
            "frame":"redeemCode",
            "labelTxt":24819,
            "btnTxt":24820
         },{
            "type":TOGGLE_TYPE_JOIN,
            "frame":"world",
            "labelTxt":6395,
            "btnTxt":6366
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"nameBadge",
            "labelTxt":23912,
            "onTxt":6241,
            "offTxt":23918
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"jammerWallIcon",
            "labelTxt":27948,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"lock",
            "labelTxt":6271,
            "onTxt":6393,
            "offTxt":6301
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"denPlayerIcon",
            "labelTxt":25452,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"doorBell",
            "labelTxt":18420,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"music",
            "labelTxt":6373,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_SCRUB,
            "frame":"",
            "labelTxt":14666
         },{
            "type":TOGGLE_TYPE_CURSOR,
            "frame":"",
            "labelTxt":6269
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"buddyRequest",
            "labelTxt":6251,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"gameInvites",
            "labelTxt":6282,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"autoServer",
            "labelTxt":23667,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_TOGGLE_BTN,
            "frame":"predictTxt",
            "labelTxt":29116,
            "onTxt":6324,
            "offTxt":6322
         },{
            "type":TOGGLE_TYPE_JOIN,
            "frame":"twoFactor",
            "labelTxt":36824,
            "btnTxt":36825
         }];
         if(gMainFrame.clientInfo.userEmail == null || gMainFrame.clientInfo.userEmail == "")
         {
            _loc4_.splice(3,0,{
               "type":TOGGLE_TYPE_JOIN,
               "frame":"verifyEmail",
               "labelTxt":33036,
               "btnTxt":33035
            });
         }
         _toggleWindows = new WindowGenerator();
         _toggleWindows.init(1,_loc2_,_loc4_.length,0,4,0,ItemWindowToggle,_loc4_,null,null,{"onClose":onClose});
         _mySettings.itemWindow.addChild(_toggleWindows);
         _toggleScrollBar = new SBScrollbar();
         _toggleScrollBar.init(_toggleWindows,_loc3_,_loc5_,2,"scrollbar2",_toggleWindows.boxHeight + 4);
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
      
      private function onJoinBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function addEventListeners() : void
      {
         with(_mySettings)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            bx.addEventListener(MouseEvent.MOUSE_DOWN,onClose,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         with(_mySettings)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            bx.removeEventListener(MouseEvent.MOUSE_DOWN,onClose);
            if(joinBtn)
            {
               joinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinBtn);
            }
         }
      }
   }
}

