package playerWall
{
   import buddy.BuddyManager;
   import collection.IntItemCollection;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.UpsellManager;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class PlayerWallManager
   {
      public static const PATTERN_MEDIA_ID:int = 3983;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _hudWallBtn:MovieClip;
      
      private static var _glowTimer:Timer;
      
      private static var _openWallUpdateTimer:Timer;
      
      private static var _myPlayerWallClosedTimer:Timer;
      
      private static var _myInbox:Vector.<PostMessage>;
      
      private static var _myNotifications:Vector.<PostMessage>;
      
      private static var _strangerInbox:Vector.<PostMessage>;
      
      private static var _myPlayerWall:PlayerWallGui;
      
      private static var _strangersPlayerWall:PlayerWallGui;
      
      private static var _isFirstTime:Boolean;
      
      private static var _statusText:String;
      
      private static var _currentMessageColorId:int;
      
      private static var _currentMessagePattern:int;
      
      private static var _myPrivacyId:int;
      
      private static var _myWallParameters:Object;
      
      private static var _isWaitingOnResponse:Boolean;
      
      private static var _myBlockedMessages:Object;
      
      private static var _myViewedWalls:Dictionary;
      
      public static var tokenMap:Object = {};
      
      public function PlayerWallManager()
      {
         super();
      }
      
      public static function init(param1:MovieClip) : void
      {
         PlayerWallXtCommManager.init();
         _guiLayer = GuiManager.guiLayer;
         _hudWallBtn = param1;
         _isFirstTime = true;
         _hudWallBtn.newPostCount.visible = false;
         _hudWallBtn.newPostCount.postCountTxt.text = 0;
         _glowTimer = new Timer(5000);
         _glowTimer.addEventListener("timer",glowTimerHandler,false,0,true);
         _openWallUpdateTimer = new Timer(7000);
         _openWallUpdateTimer.addEventListener("timer",onMessageUpdateTimer,false,0,true);
         _myPlayerWallClosedTimer = new Timer(60000);
         _myPlayerWallClosedTimer.addEventListener("timer",onMessageUpdateTimer,false,0,true);
         _myPlayerWallClosedTimer.start();
         _myBlockedMessages = {};
         _myViewedWalls = new Dictionary();
         var _loc2_:SharedObject = GuiManager.sharedObj;
         if(_loc2_ && _loc2_.data)
         {
            _currentMessageColorId = _loc2_.data.msgColor != null ? _loc2_.data.msgColor : 1;
            _currentMessagePattern = _loc2_.data.msgPattern != null ? _loc2_.data.msgPattern : 1;
         }
         else
         {
            _currentMessageColorId = 1;
            _currentMessagePattern = 1;
         }
         _myInbox = new Vector.<PostMessage>();
         _myNotifications = new Vector.<PostMessage>();
         _hudWallBtn.addEventListener("mouseDown",playerWallBtnDownHandler,false,0,true);
         firstTimeRequest();
      }
      
      public static function destroy() : void
      {
         if(_openWallUpdateTimer)
         {
            _openWallUpdateTimer.removeEventListener("timer",onMessageUpdateTimer);
            _openWallUpdateTimer.reset();
            _openWallUpdateTimer = null;
         }
         if(_myPlayerWallClosedTimer)
         {
            _myPlayerWallClosedTimer.removeEventListener("timer",onMessageUpdateTimer);
            _myPlayerWallClosedTimer.reset();
            _myPlayerWallClosedTimer = null;
         }
         closeWalls();
      }
      
      public static function closeWalls() : void
      {
         if(_myPlayerWall)
         {
            _myPlayerWall.destroy();
            _myPlayerWall = null;
         }
         if(_strangersPlayerWall)
         {
            _strangersPlayerWall.destroy();
            _strangersPlayerWall = null;
         }
      }
      
      public static function closeOpenPlayerWallDueToTokenFailures() : void
      {
         onMyPlayerWallClose(true);
         onStrangerPlayerWallClose();
      }
      
      public static function setForWaitingOnWallResponse(param1:Boolean) : void
      {
         _isWaitingOnResponse = param1;
      }
      
      public static function ownerNameOfCurrentOpenWall() : String
      {
         if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
         {
            return _myPlayerWall.owner;
         }
         if(_strangersPlayerWall)
         {
            return _strangersPlayerWall.owner;
         }
         return "";
      }
      
      public static function isMyWallOpen() : Boolean
      {
         return _myPlayerWall != null;
      }
      
      public static function checkAndRemoveMasterpieceItems(param1:IntItemCollection, param2:Function = null) : void
      {
         var _loc3_:Array = null;
         var _loc5_:IntItemCollection = new IntItemCollection();
         if(_myWallParameters && _myWallParameters.mp)
         {
            _loc3_ = _myWallParameters.mp;
            for each(var _loc6_ in _loc3_)
            {
               for each(var _loc4_ in param1.getCoreArray())
               {
                  if(_loc6_.iid == _loc4_)
                  {
                     _loc5_.pushIntItem(_loc4_);
                     break;
                  }
               }
            }
         }
         if(_loc5_.length > 0)
         {
            PlayerWallXtCommManager.sendRemoveMasterpiece(_loc5_,param2);
         }
      }
      
      public static function handleTokenResponse(param1:Array, param2:Boolean) : void
      {
         if(param1[2] == "1")
         {
            tokenMap[param1[6].toLowerCase()] = {
               "token":param1[3],
               "read":param1[4],
               "write":param1[5],
               "time":0
            };
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            PlayerWallManager.setForWaitingOnWallResponse(false);
            if(int(param1[2]) == -1)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22623));
            }
            else if(int(param1[2]) == -2)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22624));
            }
            else if(param2)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
            }
         }
      }
      
      public static function openStrangersPlayerWall(param1:String, param2:String, param3:String, param4:String = "", param5:Boolean = true) : void
      {
         if(param5)
         {
            if(_strangersPlayerWall)
            {
               _strangersPlayerWall.destroy();
               _strangersPlayerWall = null;
            }
            if(tokenMap[param1.toLowerCase()] != null)
            {
               _strangersPlayerWall = new PlayerWallGui();
               _strangerInbox = new Vector.<PostMessage>();
               _strangersPlayerWall.init(_strangerInbox,null,param1,param2,param3,"",_currentMessagePattern,_currentMessageColorId,param4,onStrangerPlayerWallClose);
            }
            else
            {
               PlayerWallXtCommManager.sendWallTokenRequest(param1,openStrangersPlayerWall,{"data":[param1,param2,param3,param4]},true,true);
            }
         }
         else
         {
            BuddyManager.setPlayerWallLoading(false);
            if(_myPlayerWall)
            {
               _myPlayerWall.isCurrentlyActive = true;
            }
         }
      }
      
      public static function onCheckResponse(param1:Boolean, param2:Object, param3:String, param4:Boolean) : void
      {
         if(param1)
         {
            if(updateTimestamp(param3,param2.t))
            {
               PlayerWallXtCommManager.sendGetFromPlayerWall(param3,null,param4);
            }
            if(!param4)
            {
               _openWallUpdateTimer.reset();
               _openWallUpdateTimer.start();
            }
            else if(_myPlayerWallClosedTimer)
            {
               _myPlayerWallClosedTimer.reset();
               _myPlayerWallClosedTimer.start();
            }
         }
         else if(param2)
         {
            if(tokenMap[param3] != null)
            {
               delete tokenMap[param3];
            }
            if(param2.e == "token")
            {
               PlayerWallXtCommManager.sendWallTokenRequest(param3,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                  "cmd":"CHK",
                  "username":param3,
                  "isFromHudTimer":param4
               },true,true);
            }
            else if(param2.e == "unavailable")
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
            }
         }
      }
      
      public static function onGetResponse(param1:Boolean, param2:Vector.<PostMessage>, param3:Vector.<PostMessage>, param4:Object, param5:Boolean, param6:String, param7:String = "", param8:Function = null) : void
      {
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         if(param1)
         {
            if(param5)
            {
               if(param2.length > _myInbox.length || param3.length > _myNotifications.length)
               {
                  if(param2.length > _myInbox.length)
                  {
                     _loc10_ = 0;
                     while(_loc10_ < param2.length)
                     {
                        if(param2[_loc10_].postTime > param4.rdt)
                        {
                           _loc9_++;
                        }
                        _loc10_++;
                     }
                  }
                  else
                  {
                     _loc10_ = 0;
                     while(_loc10_ < param3.length)
                     {
                        if(param3[_loc10_].postTime > param4.rdt)
                        {
                           _loc9_++;
                        }
                        _loc10_++;
                     }
                  }
                  if(_loc9_ > 0)
                  {
                     _hudWallBtn.newPostCount.visible = true;
                     _hudWallBtn.newPostCount.postCountTxt.text = int(_hudWallBtn.newPostCount.postCountTxt.text) + _loc9_;
                     _hudWallBtn.glow.visible = true;
                     _glowTimer.start();
                  }
                  _myInbox = param2.concat();
                  _myNotifications = param3.concat();
                  _myWallParameters = param4;
               }
            }
            else
            {
               if(param4 == "")
               {
                  param4 = "19";
               }
               if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
               {
                  _hudWallBtn.newPostCount.visible = false;
                  _hudWallBtn.glow.visible = false;
                  _glowTimer.reset();
                  _hudWallBtn.newPostCount.postCountTxt.text = 0;
                  isFirstTime = false;
                  _myWallParameters = param4;
                  _myPlayerWall.currWallParameters = param4;
                  _myNotifications = param3.concat();
                  _myInbox = _myPlayerWall.reloadMessages(param2.concat(),_myNotifications,0);
               }
               else if(_strangersPlayerWall)
               {
                  _strangersPlayerWall.currWallParameters = param4;
                  _strangerInbox = _strangersPlayerWall.reloadMessages(param2.concat(),null,0);
               }
            }
            if(!param5 && _openWallUpdateTimer)
            {
               _openWallUpdateTimer.reset();
               _openWallUpdateTimer.start();
            }
            else if(_myPlayerWallClosedTimer)
            {
               _myPlayerWallClosedTimer.reset();
               _myPlayerWallClosedTimer.start();
            }
         }
         else if(param7 && param7 == "token")
         {
            PlayerWallXtCommManager.sendWallTokenRequest(param6,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
               "cmd":"GET",
               "username":param6,
               "wallParameters":param4,
               "isFromHudTimer":param5,
               "callback":param8
            },true,true);
         }
      }
      
      public static function processMessageUpdate(param1:String, param2:String) : void
      {
         var _loc3_:PostMessage = null;
         var _loc4_:int = 0;
         var _loc5_:Vector.<PostMessage> = new Vector.<PostMessage>();
         if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
         {
            _loc5_ = _myInbox;
         }
         else
         {
            _loc5_ = _strangerInbox;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc3_ = _loc5_[_loc4_];
            if(_loc3_ != null && _loc3_.msgId == param1)
            {
               _loc5_[_loc4_].message = param2;
               if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
               {
                  _myInbox = _myPlayerWall.reloadMessages(_loc5_,_myNotifications,2,param2);
                  break;
               }
               if(_strangersPlayerWall)
               {
                  _strangerInbox = _strangersPlayerWall.reloadMessages(_loc5_,null,2,param2);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public static function onPrivacyResponse(param1:Boolean, param2:int) : void
      {
         if(param1)
         {
            gMainFrame.userInfo.playerWallSettings = param2;
         }
      }
      
      public static function onParametersResponse(param1:Boolean, param2:Object) : void
      {
         if(param1)
         {
            _myWallParameters = param2;
         }
         if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
         {
            _myPlayerWall.currWallParameters = _myWallParameters;
         }
      }
      
      public static function onWallCountIncrementResponse(param1:Boolean, param2:String) : void
      {
         if(param1)
         {
            _myViewedWalls[param2] = true;
         }
      }
      
      public static function onBlockedMessagesResponse(param1:Boolean, param2:Object) : void
      {
         var _loc4_:Array = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc4_ = param2.r;
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               _myBlockedMessages[_loc4_[_loc3_]] = _loc4_[_loc3_];
               _loc3_++;
            }
         }
      }
      
      public static function onSetBlockedMessageResponse(param1:Boolean, param2:String) : void
      {
         if(param1)
         {
            _myBlockedMessages[param2] = param2;
            if(_myPlayerWall && _myPlayerWall.isCurrentlyActive)
            {
               _myInbox = _myPlayerWall.reloadMessages(_myInbox,_myNotifications,3,param2);
            }
            else if(_strangersPlayerWall)
            {
               _strangerInbox = _strangersPlayerWall.reloadMessages(_strangerInbox,null,3,param2);
            }
         }
      }
      
      public static function onSendClearAllMessagesResponse(param1:Boolean) : void
      {
         var _loc2_:* = undefined;
         if(param1)
         {
            _myBlockedMessages = {};
            _loc2_ = new Vector.<PostMessage>();
            if(_myPlayerWall)
            {
               _myInbox = _myPlayerWall.reloadMessages(new Vector.<PostMessage>(),new Vector.<PostMessage>(),4);
            }
         }
      }
      
      public static function onSendRemoveMasterpieceResponse(param1:Boolean, param2:IntItemCollection) : void
      {
         var _loc3_:Object = null;
         if(param1)
         {
            if(_myWallParameters && _myWallParameters.mp)
            {
               _loc3_ = _myWallParameters.mp;
               for(var _loc5_ in _loc3_)
               {
                  for each(var _loc4_ in param2.getCoreArray())
                  {
                     if(_loc3_[_loc5_].iid == _loc4_)
                     {
                        delete _loc3_[_loc5_];
                        _myWallParameters.mp = _loc3_;
                        break;
                     }
                  }
               }
            }
            if(_myPlayerWall)
            {
               _myPlayerWall.currWallParameters = _myWallParameters;
               _myPlayerWall.reloadMasterpieceItems();
            }
         }
      }
      
      public static function onSendAcknowledgeNotificationResponse(param1:Boolean, param2:Array) : void
      {
         var _loc3_:PostMessage = null;
         var _loc4_:String = null;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            if(_myNotifications)
            {
               _loc6_ = 0;
               while(_loc6_ < param2.length)
               {
                  _loc4_ = param2[_loc6_];
                  _loc5_ = 0;
                  while(_loc5_ < _myNotifications.length)
                  {
                     _loc3_ = _myNotifications[_loc5_];
                     if(_loc3_ && _loc3_.parentMessageId == _loc4_)
                     {
                        _myNotifications[_loc5_].isRead = true;
                        break;
                     }
                     _loc5_++;
                  }
                  _loc6_++;
               }
            }
            if(_myPlayerWall)
            {
               _myPlayerWall.currNotifications = _myNotifications;
            }
         }
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(param1:Boolean) : void
      {
         _isFirstTime = param1;
      }
      
      public static function get myBlockedMessages() : Object
      {
         return _myBlockedMessages;
      }
      
      public static function get myWallParameters() : Object
      {
         return _myWallParameters;
      }
      
      public static function get myViewedWalls() : Dictionary
      {
         return _myViewedWalls;
      }
      
      public static function updateTimestamp(param1:String, param2:Number) : Boolean
      {
         var _loc3_:Object = tokenMap[param1.toLowerCase()];
         if(_loc3_)
         {
            if(_loc3_.time < param2)
            {
               tokenMap[param1.toLowerCase()].time = param2;
               return true;
            }
         }
         return false;
      }
      
      public static function startMyWallTimer() : void
      {
         if(_openWallUpdateTimer)
         {
            _openWallUpdateTimer.start();
         }
      }
      
      private static function playerWallBtnDownHandler(param1:Object, param2:Boolean = true) : void
      {
         if(param1 is MouseEvent)
         {
            if(param1.currentTarget.isGray)
            {
               return;
            }
         }
         if(gMainFrame.userInfo.webPlayerWallSettings != 0)
         {
            if(gMainFrame.userInfo.isMember)
            {
               if(param1 is MouseEvent)
               {
                  param1.currentTarget.activateLoadingState(true);
                  param1.stopPropagation();
               }
               _myPlayerWallClosedTimer.reset();
               _hudWallBtn.glow.visible = false;
               _glowTimer.reset();
               if(_myPlayerWall)
               {
                  _myPlayerWall.destroy();
                  _myPlayerWall = null;
               }
               if(param2)
               {
                  RoomManagerWorld.instance.forceStopMovement();
                  if(tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()] != null)
                  {
                     _myPlayerWall = new PlayerWallGui();
                     _myPlayerWall.init(_myInbox,_myNotifications,gMainFrame.server.userName,gMainFrame.userInfo.userNameModerated,gMainFrame.userInfo.myUUID,_statusText,_currentMessagePattern,_currentMessageColorId,"",onMyPlayerWallClose);
                     _hudWallBtn.newPostCount.visible = false;
                     _hudWallBtn.newPostCount.postCountTxt.text = 0;
                  }
                  else
                  {
                     PlayerWallXtCommManager.sendWallTokenRequest(gMainFrame.userInfo.myUserName,playerWallBtnDownHandler,gMainFrame.userInfo.myUserName,true,true);
                  }
               }
               else
               {
                  GuiManager.mainHud.playerWall.activateLoadingState(false);
               }
            }
            else
            {
               UpsellManager.displayPopup("jammerWall","playerWall");
            }
         }
         else
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23144));
         }
      }
      
      private static function onMyPlayerWallClose(param1:Boolean = false) : void
      {
         _openWallUpdateTimer.reset();
         if(!param1)
         {
            _myPlayerWallClosedTimer.start();
         }
         if(_myPlayerWall)
         {
            _currentMessageColorId = _myPlayerWall.myCurrMessageColorId;
            _currentMessagePattern = _myPlayerWall.currMessagePattern;
            _myPlayerWall.destroy();
            _myPlayerWall = null;
         }
      }
      
      private static function onStrangerPlayerWallClose() : void
      {
         _openWallUpdateTimer.reset();
         if(_strangersPlayerWall)
         {
            _currentMessageColorId = _strangersPlayerWall.myCurrMessageColorId;
            _currentMessagePattern = _strangersPlayerWall.currMessagePattern;
            _strangersPlayerWall.destroy();
            _strangersPlayerWall = null;
         }
         if(_myPlayerWall)
         {
            _myPlayerWall.isCurrentlyActive = true;
         }
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         _hudWallBtn.glow.visible = false;
      }
      
      private static function onMessageUpdateTimer(param1:TimerEvent) : void
      {
         var _loc2_:* = false;
         if(_myPlayerWallClosedTimer || _openWallUpdateTimer)
         {
            _loc2_ = param1.currentTarget == _myPlayerWallClosedTimer;
            if(_loc2_)
            {
               _myPlayerWallClosedTimer.reset();
            }
            else
            {
               _openWallUpdateTimer.reset();
            }
            if(_loc2_)
            {
               PlayerWallXtCommManager.sendCheckPlayerWall(gMainFrame.userInfo.myUserName,null,true);
            }
            else if(_strangersPlayerWall)
            {
               PlayerWallXtCommManager.sendCheckPlayerWall(_strangersPlayerWall.owner,null);
            }
            else
            {
               PlayerWallXtCommManager.sendCheckPlayerWall(gMainFrame.userInfo.myUserName,null);
            }
         }
      }
      
      private static function firstTimeRequest() : void
      {
         PlayerWallXtCommManager.sendWallTokenRequest(gMainFrame.userInfo.myUserName,onInitialTokenGet,null,false);
      }
      
      private static function onInitialTokenGet(param1:Boolean) : void
      {
         if(param1)
         {
            PlayerWallXtCommManager.sendGetBlockedMessages(onBlockedMessagesLoaded,param1);
         }
      }
      
      private static function onBlockedMessagesLoaded(param1:Boolean, param2:Object) : void
      {
         if(param1)
         {
            PlayerWallXtCommManager.sendGetFromPlayerWall(gMainFrame.userInfo.myUserName,null,true);
         }
      }
   }
}

