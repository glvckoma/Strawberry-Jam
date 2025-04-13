package playerWall
{
   import buddy.BuddyManager;
   import collection.IntItemCollection;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import gui.DarkenManager;
   import gui.GuiManager;
   import localization.LocalizationManager;
   
   public class PlayerWallXtCommManager
   {
      private static var _requestor:URLLoader;
      
      private static var _deleteResponseCallback:Function;
      
      private static var _getResponseCallback:Function;
      
      private static var _putResponseCallback:Function;
      
      private static var _setSettingsResponseCallback:Function;
      
      private static var _getSettingsResponseCallback:Function;
      
      private static var _setParametersResponseCallback:Function;
      
      private static var _blockedMessagesCallback:Function;
      
      private static var _setBlockedMessageCallback:Function;
      
      private static var _wallTokenCallback:Function;
      
      private static var _checkResponseCallback:Function;
      
      private static var _sendClearAllMessagesCallback:Function;
      
      private static var _sendMasterpieceCallback:Function;
      
      private static var _setCounterIncrementResponseCallback:Function;
      
      private static var _sendAcknowledgeNotificationCallback:Function;
      
      private static var _wallTokenPassback:Object;
      
      private static var _setSettingsId:int;
      
      private static var _currentRequestUsername:String;
      
      private static var _messageToPost:PostMessage;
      
      private static var _currMessageuuid:String;
      
      private static var _setWallParameters:Object;
      
      private static var _messageToBeBlocked:String;
      
      private static var _wallTokenShouldShowFailure:Boolean;
      
      private static var _masterpieceInvIdsToRemove:IntItemCollection;
      
      private static var _setCounterIncrementWallOwner:String;
      
      private static var _sendAcknowledgeMessages:Array;
      
      private static var _isProcessingRequest:Boolean;
      
      private static var _currCommand:String;
      
      private static var _tokenFailures:int;
      
      private static var _isFromHudTimer:Boolean;
      
      public function PlayerWallXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _requestor = new URLLoader();
      }
      
      public static function destroy() : void
      {
      }
      
      public static function sendWallTokenRequest(param1:String, param2:Function = null, param3:Object = null, param4:Boolean = true, param5:Boolean = false) : void
      {
         if(_tokenFailures < 2)
         {
            if(param5)
            {
               _tokenFailures++;
            }
            PlayerWallManager.setForWaitingOnWallResponse(true);
            _wallTokenCallback = param2;
            _wallTokenPassback = param3;
            _wallTokenShouldShowFailure = param4;
            gMainFrame.server.setXtObject_Str("wt",[param1]);
         }
         else
         {
            PlayerWallManager.closeOpenPlayerWallDueToTokenFailures();
            _tokenFailures = 0;
         }
      }
      
      public static function sendSetWallSettingsRequest(param1:int, param2:Function) : void
      {
         _setSettingsResponseCallback = param2;
         _setSettingsId = param1;
         gMainFrame.server.setXtObject_Str("wss",[param1]);
      }
      
      public static function sendGetWallSettingsRequest(param1:String, param2:Function) : void
      {
         _getSettingsResponseCallback = param2;
         gMainFrame.server.setXtObject_Str("wsg",[param1]);
      }
      
      public static function sendSetWallParametersRequest(param1:Object, param2:Object, param3:Function) : void
      {
         _setParametersResponseCallback = param3;
         _setWallParameters = param1;
         gMainFrame.server.setXtObject_Str("wps",[JSON.stringify(param2)]);
      }
      
      public static function sendSetWallCounterIncrementRequest(param1:String, param2:Function) : void
      {
         _setCounterIncrementResponseCallback = param2;
         _setCounterIncrementWallOwner = param1;
         gMainFrame.server.setXtObject_Str("wci",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc3_:Array = null;
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: PlayerWallXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "wt":
               PlayerWallManager.handleTokenResponse(_loc2_,_wallTokenShouldShowFailure);
               if(_wallTokenCallback != null)
               {
                  if(_wallTokenPassback != null)
                  {
                     if(_wallTokenPassback.hasOwnProperty("data"))
                     {
                        _loc3_ = _wallTokenPassback.data;
                        switch(int(_loc3_.length) - 1)
                        {
                           case 0:
                              _wallTokenCallback(_loc3_[0],_loc2_[2] == "1");
                              break;
                           case 1:
                              _wallTokenCallback(_loc3_[0],_loc3_[1],_loc2_[2] == "1");
                              break;
                           case 2:
                              _wallTokenCallback(_loc3_[0],_loc3_[1],_loc3_[2],_loc2_[2] == "1");
                              break;
                           case 3:
                              _wallTokenCallback(_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3],_loc2_[2] == "1");
                              break;
                           case 4:
                              _wallTokenCallback(_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3],_loc3_[4],_loc2_[2] == "1");
                        }
                     }
                     else
                     {
                        _wallTokenCallback(_wallTokenPassback,_loc2_[2] == "1");
                     }
                     _wallTokenPassback = null;
                  }
                  else
                  {
                     _wallTokenCallback(_loc2_[2] == "1");
                  }
                  _wallTokenCallback = null;
               }
               break;
            case "wss":
               PlayerWallManager.onPrivacyResponse(_loc2_[2] == "1",_setSettingsId);
               if(_setSettingsResponseCallback != null)
               {
                  _setSettingsResponseCallback(_loc2_[2] == "1",_setSettingsId);
                  _setSettingsResponseCallback = null;
               }
               break;
            case "wsg":
               if(_getSettingsResponseCallback != null)
               {
                  _getSettingsResponseCallback(_loc2_[2]);
                  _getSettingsResponseCallback = null;
               }
               break;
            case "wps":
               setParametersResponse(_loc2_);
               break;
            case "wci":
               PlayerWallManager.onWallCountIncrementResponse(_loc2_[2] == "1",_setCounterIncrementWallOwner);
               if(_setCounterIncrementResponseCallback != null)
               {
                  _setCounterIncrementResponseCallback(_loc2_[2]);
                  _setCounterIncrementResponseCallback = null;
                  break;
               }
         }
      }
      
      public static function sendCheckPlayerWall(param1:String, param2:Function, param3:Boolean = false, param4:Boolean = true) : void
      {
         var _loc5_:Object = PlayerWallManager.tokenMap[param1.toLowerCase()];
         var _loc6_:String = null;
         if(_loc5_)
         {
            _loc6_ = _loc5_.token;
         }
         _currentRequestUsername = param1;
         _checkResponseCallback = param2;
         _isFromHudTimer = param3;
         if(_loc6_)
         {
            sendServiceRequest({
               "cmd":"CHK",
               "t":_loc6_
            });
         }
         else
         {
            sendWallTokenRequest(param1,sendCheckPlayerWall,{"data":[param1,param2,param3]},!param3,!param4);
         }
      }
      
      public static function sendPutToPlayerWall(param1:String, param2:PostMessage, param3:Object, param4:Function, param5:Boolean = true) : void
      {
         var _loc6_:Object = null;
         var _loc7_:Object = PlayerWallManager.tokenMap[param1.toLowerCase()];
         var _loc8_:String = null;
         if(_loc7_)
         {
            _loc8_ = _loc7_.token;
         }
         _messageToPost = param2;
         _currentRequestUsername = param1;
         _putResponseCallback = param4;
         if(_loc8_)
         {
            _loc6_ = {
               "cmd":"PUT",
               "t":_loc8_,
               "sid":param2.senderDbId,
               "s":param2.patternId,
               "c":param2.colorId,
               "m":param2.message,
               "ai":param2.avtDefId,
               "ac":param2.avtColors,
               "ae":param2.avtEyeDefId,
               "ap":param2.avtPatternDefId,
               "aci":param2.avtCustomId,
               "l":param2.localizationId,
               "p":param3
            };
            if(param2.parentMessageId != null && param2.parentMessageId.length > 0)
            {
               _loc6_.pp = param2.parentMessageId;
            }
            sendServiceRequest(_loc6_);
         }
         else
         {
            sendWallTokenRequest(param1,sendPutToPlayerWall,{"data":[param1,param4,param2,param3]},true,!param5);
         }
      }
      
      public static function sendDeleteFromPlayerWall(param1:String, param2:String, param3:Function, param4:Boolean = true) : void
      {
         var _loc5_:Object = PlayerWallManager.tokenMap[param1.toLowerCase()];
         var _loc6_:String = null;
         if(_loc5_)
         {
            _loc6_ = _loc5_.token;
         }
         _currentRequestUsername = param1;
         _currMessageuuid = param2;
         _deleteResponseCallback = param3;
         if(_loc6_)
         {
            sendServiceRequest({
               "cmd":"DEL",
               "t":_loc6_,
               "x":param2
            });
         }
         else
         {
            sendWallTokenRequest(param1,sendDeleteFromPlayerWall,{"data":[param1,param3,param2]},true,!param4);
         }
      }
      
      public static function sendGetFromPlayerWall(param1:String, param2:Function, param3:Boolean = false, param4:Boolean = true) : void
      {
         var _loc5_:Object = PlayerWallManager.tokenMap[param1.toLowerCase()];
         var _loc6_:String = null;
         if(_loc5_)
         {
            _loc6_ = _loc5_.token;
         }
         _currentRequestUsername = param1;
         _getResponseCallback = param2;
         _isFromHudTimer = param3;
         if(_loc6_)
         {
            sendServiceRequest({
               "cmd":"GET",
               "t":_loc6_
            });
         }
         else
         {
            sendWallTokenRequest(param1,sendGetFromPlayerWall,{"data":[param1,param2,param3]},true,!param4);
         }
      }
      
      public static function sendGetBlockedMessages(param1:Function, param2:Boolean = true) : void
      {
         _blockedMessagesCallback = param1;
         var _loc3_:Object = PlayerWallManager.tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()];
         var _loc4_:String = null;
         if(_loc3_)
         {
            _loc4_ = _loc3_.token;
         }
         _currentRequestUsername = gMainFrame.userInfo.myUserName;
         if(_loc4_)
         {
            sendServiceRequest({
               "cmd":"GMB",
               "t":_loc4_
            });
         }
         else
         {
            sendWallTokenRequest(_currentRequestUsername,sendGetBlockedMessages,{"callback":param1},true,!param2);
         }
      }
      
      public static function sendSetBlockedMessage(param1:String, param2:Function, param3:Boolean = true) : void
      {
         _setBlockedMessageCallback = param2;
         _messageToBeBlocked = param1;
         var _loc4_:Object = PlayerWallManager.tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _currentRequestUsername = gMainFrame.userInfo.myUserName;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"AMB",
               "t":_loc5_,
               "x":param1
            });
         }
         else
         {
            sendWallTokenRequest(_currentRequestUsername,sendSetBlockedMessage,{"data":[param2,param1]},true,!param3);
         }
      }
      
      public static function sendClearAllMessages(param1:Function, param2:Boolean = true) : void
      {
         _sendClearAllMessagesCallback = param1;
         var _loc3_:Object = PlayerWallManager.tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()];
         var _loc4_:String = null;
         if(_loc3_)
         {
            _loc4_ = _loc3_.token;
         }
         _currentRequestUsername = gMainFrame.userInfo.myUserName;
         if(_loc4_)
         {
            sendServiceRequest({
               "cmd":"CLW",
               "t":_loc4_
            });
         }
         else
         {
            sendWallTokenRequest(_currentRequestUsername,sendClearAllMessages,{"callback":param1},true,!param2);
         }
      }
      
      public static function sendRemoveMasterpiece(param1:IntItemCollection, param2:Function, param3:Boolean = true) : void
      {
         _masterpieceInvIdsToRemove = param1;
         _sendMasterpieceCallback = param2;
         var _loc4_:Object = PlayerWallManager.tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _currentRequestUsername = gMainFrame.userInfo.myUserName;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"RMP",
               "t":_loc5_,
               "mp":param1.getCoreArray()
            });
         }
         else
         {
            sendWallTokenRequest(_currentRequestUsername,sendRemoveMasterpiece,{"data":[param2,param1]},true,!param3);
         }
      }
      
      public static function sendAcknowledgeNotificationRequest(param1:Array, param2:Function, param3:Boolean = true) : void
      {
         var _loc4_:Object = PlayerWallManager.tokenMap[gMainFrame.userInfo.myUserName.toLowerCase()];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _sendAcknowledgeNotificationCallback = param2;
         _currentRequestUsername = gMainFrame.userInfo.myUserName;
         _sendAcknowledgeMessages = param1;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"ACK",
               "t":_loc5_,
               "x":param1
            });
         }
         else
         {
            sendWallTokenRequest(_currentRequestUsername,sendAcknowledgeNotificationRequest,{"data":[param2,param1]},true,!param3);
         }
      }
      
      public static function ContinueCommandAfterTokenRequest(param1:Object, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(param1 && param2)
         {
            _loc3_ = param1.cmd;
            _loc4_ = param1.username;
            switch(_loc3_)
            {
               case "CHK":
                  sendCheckPlayerWall(_loc4_,param1.callback,param1.isFromHudTimer,param2);
                  break;
               case "PUT":
                  sendPutToPlayerWall(_loc4_,param1.msgToPost,param1.wallParameters,param1.callback,param2);
                  break;
               case "DEL":
                  sendDeleteFromPlayerWall(_loc4_,param1.messageuuid,param1.callback,param2);
                  break;
               case "GET":
                  sendGetFromPlayerWall(_loc4_,param1.callback,param1.isFromHudTimer,param2);
                  break;
               case "GMP":
                  sendGetBlockedMessages(param1.callback,param2);
                  break;
               case "AMB":
                  sendSetBlockedMessage(param1.messageToBeBlocked,param1.callback,param2);
                  break;
               case "CLW":
                  sendClearAllMessages(param1.callback,param2);
                  break;
               case "RMP":
                  sendRemoveMasterpiece(param1.invIdToRemove,param1.callback,param2);
                  break;
               case "ACK":
                  sendAcknowledgeNotificationRequest(param1.messageId,param1.callback,param2);
            }
         }
         else
         {
            PlayerWallManager.closeOpenPlayerWallDueToTokenFailures();
         }
      }
      
      private static function checkResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onCheckResponse(_loc2_,param1,_currentRequestUsername,_isFromHudTimer);
         if(_checkResponseCallback != null)
         {
            _checkResponseCallback(_loc2_,param1);
         }
      }
      
      private static function deleteResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         if(_deleteResponseCallback != null)
         {
            _deleteResponseCallback(_loc2_,_currMessageuuid,param1.e);
            _deleteResponseCallback = null;
         }
      }
      
      private static function addResponse(param1:Object) : void
      {
         var _loc4_:Boolean = param1 != null ? Boolean(param1.PUT.s) : false;
         var _loc2_:int = int(param1.PUT.cs != null ? param1.PUT.cs : 0);
         var _loc3_:int = int(param1.PUT.tag != null ? param1.PUT.tag : 0);
         if(_loc4_)
         {
            _messageToPost.msgId = param1.x;
            _messageToPost.postTime = param1.t;
            getResponse(param1.GET);
         }
         if(_putResponseCallback != null)
         {
            _putResponseCallback(_loc4_,_messageToPost,_loc2_,_loc3_,param1.PUT.e);
            _putResponseCallback = null;
         }
      }
      
      public static function getResponse(param1:Object) : void
      {
         var _loc11_:Object = null;
         var _loc4_:int = 0;
         var _loc12_:String = null;
         var _loc10_:Boolean = false;
         var _loc2_:Array = null;
         var _loc6_:int = 0;
         var _loc13_:Array = null;
         var _loc8_:Object = null;
         var _loc7_:int = 0;
         var _loc3_:Vector.<PostMessage> = new Vector.<PostMessage>();
         var _loc9_:Vector.<PostMessage> = new Vector.<PostMessage>();
         if(param1 != null ? Boolean(param1.s) : false)
         {
            _loc2_ = param1.r;
            _loc6_ = 0;
            while(_loc6_ < _loc2_.length)
            {
               _loc11_ = _loc2_[_loc6_];
               if(_loc11_)
               {
                  _loc12_ = _loc11_.um == 1 ? _loc11_.un : LocalizationManager.translateIdOnly(11098);
                  _loc10_ = _loc11_.u == gMainFrame.userInfo.myUUID ? true : BuddyManager.isBuddy(_loc11_.un);
                  _loc3_.push(new PostMessage(_loc11_.x,_loc11_.m,_loc11_.uid,_loc11_.un,_loc12_,_loc11_.s,_loc11_.c,_loc11_.t,_loc10_,_loc11_.ai,_loc11_.ac,_loc11_.ae,_loc11_.ap,_loc11_.l,_loc11_.aci,_loc11_.pp,"",false));
               }
               else
               {
                  _loc4_++;
               }
               _loc6_++;
            }
            _loc13_ = param1.n;
            if(_loc13_ != null && _loc13_.length > 0)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc13_.length)
               {
                  _loc8_ = _loc13_[_loc7_];
                  if(_loc8_ != null)
                  {
                     _loc12_ = _loc8_.um == 1 ? _loc8_.un : LocalizationManager.translateIdOnly(11098);
                     _loc10_ = _loc8_.un == gMainFrame.userInfo.myUserName ? true : BuddyManager.isBuddy(_loc8_.un);
                     _loc9_.push(new PostMessage(_loc8_.x,_loc8_.m,0,_loc8_.un,_loc12_,0,_loc8_.c,_loc8_.t,_loc10_,_loc8_.ai,_loc8_.ac,_loc8_.ae,_loc8_.ap,_loc8_.l,_loc8_.aci,_loc8_.pp,_loc8_.u,_loc8_.read));
                  }
                  _loc7_++;
               }
               _loc9_.sort(orderTimestamp);
            }
            PlayerWallManager.updateTimestamp(_currentRequestUsername,param1.t);
            _loc3_.sort(orderTimestamp);
         }
         PlayerWallManager.onGetResponse(false,_loc3_,_loc9_,param1.p,_isFromHudTimer,_currentRequestUsername,param1.e,_getResponseCallback);
         if(_getResponseCallback != null)
         {
            _getResponseCallback(false);
            _getResponseCallback = null;
         }
      }
      
      private static function setSettingsResponse(param1:Array) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onPrivacyResponse(_loc2_,_setSettingsId);
         if(_setSettingsResponseCallback != null)
         {
            _setSettingsResponseCallback(_loc2_,_setSettingsId);
            _setSettingsResponseCallback = null;
         }
      }
      
      private static function setParametersResponse(param1:Array) : void
      {
         var _loc2_:* = param1[2] == "1";
         PlayerWallManager.onParametersResponse(_loc2_,_setWallParameters);
         if(_setParametersResponseCallback != null)
         {
            _setParametersResponseCallback(_loc2_,_setWallParameters);
            _setParametersResponseCallback = null;
         }
      }
      
      private static function getBlockedMessagesResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onBlockedMessagesResponse(_loc2_,param1);
         if(_blockedMessagesCallback != null)
         {
            _blockedMessagesCallback(_loc2_,param1);
            _blockedMessagesCallback = null;
         }
      }
      
      private static function setBlockedMessageResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onSetBlockedMessageResponse(_loc2_,_messageToBeBlocked);
         if(_setBlockedMessageCallback != null)
         {
            _setBlockedMessageCallback(_loc2_,_messageToBeBlocked);
            _setBlockedMessageCallback = null;
         }
      }
      
      private static function sendClearAllMessagesResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onSendClearAllMessagesResponse(_loc2_);
         if(_sendClearAllMessagesCallback != null)
         {
            _sendClearAllMessagesCallback(_loc2_);
            _sendClearAllMessagesCallback = null;
         }
      }
      
      private static function sendRemoveMasterpieceResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onSendRemoveMasterpieceResponse(_loc2_,_masterpieceInvIdsToRemove);
         if(_sendMasterpieceCallback != null)
         {
            _sendMasterpieceCallback(_loc2_,_masterpieceInvIdsToRemove);
            _sendMasterpieceCallback = null;
         }
      }
      
      private static function sendAcknowledgeNotificationResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onSendAcknowledgeNotificationResponse(_loc2_,_sendAcknowledgeMessages);
         if(_sendAcknowledgeNotificationCallback != null)
         {
            _sendAcknowledgeNotificationCallback(_loc2_,_sendAcknowledgeMessages,param1.e);
            _sendAcknowledgeNotificationCallback = null;
         }
      }
      
      public static function sendServiceRequest(... rest) : void
      {
         var _loc3_:URLRequestHeader = null;
         var _loc4_:String = null;
         var _loc2_:URLRequest = null;
         if(!_isProcessingRequest)
         {
            _isProcessingRequest = true;
            _currCommand = rest[0].cmd;
            _loc3_ = new URLRequestHeader("Content-type","application/json");
            _loc4_ = JSON.stringify(rest[0]);
            _loc2_ = new URLRequest(gMainFrame.clientInfo.playerWallHost);
            _loc2_.method = "POST";
            _loc2_.requestHeaders.push(_loc3_);
            _loc2_.data = _loc4_;
            _requestor = new URLLoader();
            _requestor.addEventListener("complete",httpRequestComplete);
            _requestor.addEventListener("ioError",httpRequestError);
            _requestor.addEventListener("securityError",httpRequestError);
            _requestor.load(_loc2_);
         }
      }
      
      private static function httpRequestComplete(param1:Event) : void
      {
         _isProcessingRequest = false;
         var _loc2_:Object = param1.target.data != "" ? JSON.parse(param1.target.data) : null;
         if(_loc2_ != null)
         {
            if("s" in _loc2_)
            {
               if(_loc2_.s == true)
               {
                  _tokenFailures = 0;
               }
            }
         }
         switch(_currCommand)
         {
            case "CHK":
               checkResponse(_loc2_);
               break;
            case "PUT":
               addResponse(_loc2_);
               if(_loc2_.PUT.s == true)
               {
                  _tokenFailures = 0;
               }
               break;
            case "DEL":
               deleteResponse(_loc2_);
               break;
            case "GET":
               getResponse(_loc2_);
               break;
            case "GMB":
               getBlockedMessagesResponse(_loc2_);
               break;
            case "AMB":
               setBlockedMessageResponse(_loc2_);
               break;
            case "CLW":
               sendClearAllMessagesResponse(_loc2_);
               break;
            case "RMP":
               sendRemoveMasterpieceResponse(_loc2_);
               break;
            case "ACK":
               sendAcknowledgeNotificationResponse(_loc2_);
         }
      }
      
      private static function httpRequestError(param1:ErrorEvent) : void
      {
         _isProcessingRequest = false;
         if(GuiManager.mainHud.playerWall)
         {
            GuiManager.mainHud.playerWall.activateLoadingState(false);
         }
         BuddyManager.setPlayerWallLoading(false);
         DarkenManager.showLoadingSpiral(false);
      }
      
      private static function orderTimestamp(param1:PostMessage, param2:PostMessage) : int
      {
         if(param1.postTime < param2.postTime)
         {
            return -1;
         }
         if(param1.postTime > param2.postTime)
         {
            return 1;
         }
         return 0;
      }
   }
}

