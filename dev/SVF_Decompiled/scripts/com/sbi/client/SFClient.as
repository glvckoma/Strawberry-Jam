package com.sbi.client
{
   import com.sbi.debug.DebugUtility;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import flash.net.Socket;
   import flash.utils.clearTimeout;
   import flash.utils.setTimeout;
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   
   public class SFClient extends EventDispatcher
   {
      public static const STATUS_ONLINE:int = 1;
      
      public static const STATUS_OFFLINE_ACTIVE:int = 0;
      
      public static const STATUS_OFFLINE_ARCHIVED:int = -1;
      
      public static const STATUS_OFFLINE_UNKNOWN:int = -2;
      
      public static const STATUS_DIFFERENT_VERSION:int = -3;
      
      public static const INIT_ROOM_ID:int = 1;
      
      public static const FIRST_MESSAGE_HTTP_PROXY_FALLBACK_CALLBACK_TIMEOUT:int = new Socket().timeout;
      
      protected var _sfs:SmartFoxClient;
      
      protected var _ingressXt:String;
      
      protected var _ingressXtPort:int;
      
      protected var _serverIps:Array;
      
      protected var _serverIp:String;
      
      protected var _serverPort:int;
      
      private var _isConnected:Boolean;
      
      private var _isLoggedIn:Boolean;
      
      private var _isWorldLoggedIn:Boolean;
      
      private var _currSubRoom:SFRoom;
      
      private var _currRoom:SFRoom;
      
      private var _currentPrimaryRoomId:int = -1;
      
      private var _currentSubRoomId:int = -1;
      
      private var _currentPrimaryRoomUsers:Object;
      
      private var _currentSubRoomUsers:Object;
      
      private var _triggerWhenWorldXtReadyCmd:String;
      
      private var _triggerWhenWorldXtReadyObj:Array;
      
      private var _roomIds:Array;
      
      private var _userName:String;
      
      private var _myUser:User;
      
      private var _gemCount:int;
      
      private var _password:String;
      
      private var _zone:String;
      
      private var _isWorldZone:Boolean;
      
      private var _pingTimeAvg:uint;
      
      private var _pingTimeTotal:uint;
      
      private var _pingTimeCount:uint;
      
      private var _firstMessageHttpProxyFallbackProcessId:uint;
      
      public function SFClient()
      {
         super();
         _roomIds = [];
         setUpServer();
      }
      
      private function setUpServer() : void
      {
         _isConnected = false;
         _isLoggedIn = false;
         _isWorldLoggedIn = false;
         _sfs = new SmartFoxClient(true);
         _sfs.smartConnect = false;
         _sfs.key = null;
         _sfs.addEventListener("onConnection",onConnection);
         _sfs.addEventListener("onConnectionLost",onConnectionLost);
         _sfs.addEventListener("onLogin",onLogin);
         _sfs.addEventListener("onExtensionResponse",onExtensionResponse);
         _sfs.addEventListener("onRoomListUpdate",onRoomListUpdate);
         _sfs.addEventListener("onRoomAdded",onRoomAdded);
         _sfs.addEventListener("onCreateRoomError",onCreateRoomError);
         _sfs.addEventListener("onRoomDeleted",onRoomDeleted);
         _sfs.addEventListener("onUserEnterRoom",onUserEnterRoom);
         _sfs.addEventListener("onUserLeaveRoom",onUserLeaveRoom);
         _sfs.addEventListener("onRoomLeft",onRoomLeft);
         _sfs.addEventListener("onUserCountChange",onUserCountChange);
         _sfs.addEventListener("onBuddyList",onBuddyList);
         _sfs.addEventListener("onBuddyListError",onBuddyListError);
         _sfs.addEventListener("onBuddyListUpdate",onBuddyListUpdate);
         _sfs.addEventListener("onBuddyPermissionRequest",onBuddyPermissionRequest);
         _sfs.addEventListener("onBuddyRoom",onBuddyRoom);
         _sfs.addEventListener("onAdminMessage",onAdminMessage);
         _sfs.addEventListener("onModMessage",onModeratorMessage);
         _sfs.addEventListener("onPrivateMessage",onPrivateMessage);
         _sfs.addEventListener("onPublicMessage",onPublicMessage);
         _sfs.addEventListener("onRandomKey",onRandomKey);
      }
      
      public function setServerConfig(param1:String, param2:String, param3:Array, param4:int, param5:int, param6:String) : void
      {
         var _loc8_:Array = null;
         var _loc7_:* = 0;
         var _loc11_:Array = null;
         if(param1)
         {
            _loc8_ = param1.split(":");
            if(_loc8_.length == 2)
            {
               _ingressXt = _loc8_[0];
               _ingressXtPort = _loc8_[1];
            }
         }
         var _loc9_:String = null;
         if(param2)
         {
            _loc11_ = param2.split(":");
            if(_loc11_.length == 2)
            {
               _loc9_ = _loc11_[0];
               _loc7_ = int(_loc11_[1]);
            }
         }
         _serverIps = param3;
         var _loc10_:int = Math.floor(Math.random() * _serverIps.length);
         _serverIp = param3[_loc10_];
         _serverPort = param4;
         if(_ingressXt == null || _ingressXt == "")
         {
            _ingressXt = _serverIp;
            _ingressXtPort = _serverPort;
         }
         else
         {
            _sfs._ingressActive = true;
         }
         if(_loc9_ == null || _loc9_ == "")
         {
            _loc9_ = _serverIp;
            _loc7_ = param5;
         }
         else
         {
            _sfs._ingressHProxyActive = true;
         }
         _sfs.blueBoxIpAddress = _loc9_;
         _sfs.blueBoxPort = _loc7_;
         _sfs.debug = param6 == "true";
      }
      
      public function setNewServer(param1:int) : void
      {
         switchServerNode(_serverIps[param1]);
      }
      
      public function switchServerNode(param1:String) : void
      {
         _serverIp = param1;
         if(autoAttemptHttp && !_sfs._ingressHProxyActive)
         {
            _sfs.blueBoxIpAddress = _serverIp;
         }
         if(!_sfs._ingressActive)
         {
            _ingressXt = _serverIp;
         }
      }
      
      public function isBlueboxMode() : Boolean
      {
         return _sfs.getConnectionMode() == "http";
      }
      
      public function getConnectionMode() : String
      {
         return _sfs.getConnectionMode();
      }
      
      public function connect() : void
      {
         if(!_isConnected)
         {
            if(gMainFrame.clientInfo.forceHttpProxy)
            {
               _sfs.smartConnect = true;
               _sfs.connectBluebox();
            }
            else
            {
               if(!_sfs.useSecureMode() && _firstMessageHttpProxyFallbackProcessId == 0)
               {
                  _firstMessageHttpProxyFallbackProcessId = setTimeout(firstMessageHttpProxyFallbackCallback,FIRST_MESSAGE_HTTP_PROXY_FALLBACK_CALLBACK_TIMEOUT);
               }
               _sfs.connect(_ingressXt,_ingressXtPort);
            }
         }
         else
         {
            getKey();
         }
      }
      
      public function logIn(param1:String, param2:String, param3:String) : void
      {
         if(_sfs.key == null)
         {
            DebugUtility.debugTrace("***ERROR ERROR ERROR - attempted to login without a valid encryption key!***");
            return;
         }
         _userName = param2;
         _zone = param1;
         _isWorldZone = _zone == "sbiLogin";
         _password = param3;
         _sfs.login(_zone,param2,param3);
      }
      
      public function logout() : void
      {
         DebugUtility.debugTrace("logout");
         if(_sfs.isConnected)
         {
            _sfs.logout();
         }
      }
      
      public function disconnect(param1:Boolean = true) : void
      {
         _isLoggedIn = false;
         _isWorldLoggedIn = false;
         _isConnected = false;
         _sfs.key = null;
         _sfs.disconnect(param1);
      }
      
      public function get ingressXtServerIp() : String
      {
         return _ingressXt;
      }
      
      public function get ingressXtServerPort() : int
      {
         return _ingressXtPort;
      }
      
      public function get serverIps() : Array
      {
         return _serverIps;
      }
      
      public function get serverIp() : String
      {
         return _serverIp;
      }
      
      public function get serverPort() : int
      {
         return _sfs.port;
      }
      
      public function get blueboxServerIp() : String
      {
         return _sfs.blueBoxIpAddress;
      }
      
      public function get blueboxServerPort() : int
      {
         return _sfs.blueBoxPort;
      }
      
      public function getConnectionUrl() : String
      {
         return _sfs.getConnectionUrl();
      }
      
      public function get isWorldXtReady() : Boolean
      {
         return _isWorldLoggedIn;
      }
      
      public function triggerCmdWhenWorldXtReady(param1:String, param2:Array) : void
      {
         _triggerWhenWorldXtReadyCmd = param1;
         _triggerWhenWorldXtReadyObj = param2;
      }
      
      public function triggerWorldXtReadyCmd() : void
      {
         if(_triggerWhenWorldXtReadyCmd != null && _triggerWhenWorldXtReadyObj != null)
         {
            setXtObject_Str(_triggerWhenWorldXtReadyCmd,_triggerWhenWorldXtReadyObj);
            _triggerWhenWorldXtReadyCmd = null;
            _triggerWhenWorldXtReadyObj = null;
         }
      }
      
      public function setXtObject_Str(param1:String, param2:Array, param3:Boolean = true, param4:Boolean = false, param5:Boolean = true) : void
      {
         var _loc6_:String = null;
         if(_sfs.isConnected)
         {
            if(param2 == null)
            {
               param2 = [];
            }
            _loc6_ = param3 ? "o" : "a";
            _sfs.sendXtMessage(_loc6_,param1,param2,"str",getCurrentRoomId(param4));
            if(param5)
            {
               KeepAlive.restartTimeLeftTimer();
            }
         }
      }
      
      public function setXtObject_XML(param1:String, param2:String, param3:Object, param4:Boolean = false) : void
      {
         if(_sfs.isConnected)
         {
            if(param3 == null)
            {
               param3 = {};
            }
            _sfs.sendXtMessage(param1,param2,param3,"xml",getCurrentRoomId(param4));
         }
      }
      
      public function setXtObject_JSON(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(_sfs.isConnected)
         {
            if(param2 == null)
            {
               param2 = {};
            }
            _sfs.sendXtMessage("a",param1,param2,"json",getCurrentRoomId(param3));
         }
      }
      
      public function getKey() : void
      {
         var _loc1_:SFEvent = null;
         if(_sfs.key == null)
         {
            _sfs.getRandomKey();
         }
         else
         {
            _loc1_ = new SFEvent("OnConnect");
            _loc1_.status = true;
            dispatchEvent(_loc1_);
         }
      }
      
      public function createRoom(param1:String, param2:uint, param3:uint, param4:Boolean, param5:Boolean, param6:String, param7:String) : void
      {
         throw new Error("createRoom on client should not be used if at all possible!");
      }
      
      public function setToJoinIRG(param1:Boolean) : void
      {
         _currentSubRoomId = param1 ? 0 : -1;
      }
      
      public function leaveRoom(param1:int) : void
      {
         _sfs.leaveRoom(param1);
      }
      
      public function leaveCurrentRoom(param1:Boolean = false) : void
      {
         _sfs.leaveRoom(param1 ? _currentSubRoomId : _currentPrimaryRoomId);
         _currentSubRoomId = -1;
      }
      
      public function sendMessage(param1:String, param2:int = -2) : void
      {
         if(_sfs.isConnected)
         {
            if(param2 == -2)
            {
               param2 = _currentPrimaryRoomId;
            }
            _sfs.sendPublicMessage(param1,param2);
            KeepAlive.restartTimeLeftTimer();
         }
      }
      
      public function isInMyRoom(param1:int, param2:Boolean) : Boolean
      {
         if(!param2 && _currentPrimaryRoomUsers == null)
         {
            return false;
         }
         if(param2 && _currentSubRoomUsers == null)
         {
            return false;
         }
         return param2 ? _currentSubRoomUsers[param1] != undefined : _currentPrimaryRoomUsers[param1] != undefined;
      }
      
      public function loadBuddyList() : void
      {
         _sfs.loadBuddyList();
      }
      
      public function getBuddyById(param1:int) : Object
      {
         return _sfs.getBuddyById(param1);
      }
      
      public function getBuddyByName(param1:String) : Object
      {
         return _sfs.getBuddyByName(param1);
      }
      
      public function sendBuddyPermissionResponse(param1:Boolean, param2:String) : void
      {
         _sfs.sendBuddyPermissionResponse(param1,param2);
      }
      
      public function setBuddyBlockStatus(param1:String, param2:Boolean) : void
      {
         _sfs.setBuddyBlockStatus(param1,param2);
      }
      
      public function getBuddyRoomByName(param1:String) : void
      {
         var _loc2_:Object = _sfs.getBuddyByName(param1);
         _sfs.getBuddyRoom(_loc2_);
      }
      
      public function getBuddyRoomById(param1:int) : void
      {
         var _loc2_:Object = _sfs.getBuddyById(param1);
         _sfs.getBuddyRoom(_loc2_);
      }
      
      public function getBuddyRoom(param1:Object) : void
      {
         if(!param1)
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj:" + param1);
         }
         if(!param1.hasOwnProperty("id"))
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj.hasOwnProperty(\"id\"):" + param1.hasOwnProperty("id"));
         }
         var _loc2_:Boolean = false;
         for each(var _loc3_ in _sfs.buddyList)
         {
            if(_loc3_.id == param1.id)
            {
               _loc2_ = true;
               break;
            }
         }
         if(_loc2_)
         {
            _sfs.getBuddyRoom(_loc3_);
            return;
         }
         throw new Error("Invalid buddy obj used to request buddy room! Could not find match in client buddy list. userobj.id:" + param1.id);
      }
      
      public function removeBuddy(param1:String) : void
      {
         _sfs.removeBuddy(param1);
      }
      
      public function getCurrentRoom(param1:Boolean = false) : SFRoom
      {
         return param1 ? _currSubRoom : _currRoom;
      }
      
      public function getCurrentRoomId(param1:Boolean = false) : int
      {
         if(!param1)
         {
            return _currentPrimaryRoomId;
         }
         if(_currentSubRoomId <= 0)
         {
            throw new Error("Attempt to send message to sub room without valid subRoomId! (no in-room game room currently joined?)");
         }
         return _currentSubRoomId;
      }
      
      public function getPvpSubRoomId() : int
      {
         return _currentSubRoomId;
      }
      
      public function setCurrSubRoomId(param1:int) : void
      {
         if(_currentSubRoomId != -1)
         {
            DebugUtility.debugTrace("WARNING: setting currSubRoomId to " + param1 + " but _currSubRoomId was not -1. It was " + _currentSubRoomId);
         }
         _currentSubRoomId = param1;
      }
      
      public function getCurrentRoomName(param1:Boolean = false) : String
      {
         var _loc2_:SFRoom = getCurrentRoom(param1);
         if(!_loc2_)
         {
            DebugUtility.debugTrace("WARNING: null room object! trying to get room name before joining any rooms? useSubRoom:" + param1);
            return null;
         }
         return _loc2_.name;
      }
      
      public function setInitRoom() : void
      {
         var _loc1_:Array = _sfs.getAllRooms();
         if(_loc1_.length > 0)
         {
            return;
         }
         _loc1_[1] = new Room(1,"_init",10000,0,false,false,false,true);
      }
      
      public function joinDefaultRoom() : void
      {
         var _loc2_:Array = _sfs.getAllRooms();
         var _loc1_:Room = _loc2_[1];
         _loc1_.addUser(_myUser,_myUser.getId());
         _sfs.activeRoomId = 1;
         _currRoom = new SFRoom();
         _currRoom.name = "_init";
         _currRoom.id = 1;
         _currRoom.users = 1;
         _currRoom.maxUsers = 10000;
         _currRoom.spectators = 0;
         _currRoom.maxSpectators = 0;
         _currRoom.isPrivate = false;
         _currRoom.isGame = false;
         _currRoom.isLimbo = true;
         _currRoom.isTemp = true;
      }
      
      public function setRoomList(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:Array = _sfs.getAllRooms();
         _loc7_.splice(0,_loc7_.length);
         var _loc6_:int = 2;
         var _loc2_:int = int(param1[_loc6_++]);
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc8_ = int(param1[_loc6_++]);
            _loc7_[_loc8_] = new Room(_loc8_,param1[_loc6_++],int(param1[_loc6_++]),0,param1[_loc6_++] == "1",param1[_loc6_++] == "1",false,_loc5_ < 1,int(param1[_loc6_++]));
            _loc5_++;
         }
         _roomIds.splice(0,_roomIds.length);
         for each(var _loc3_ in _loc7_)
         {
            _roomIds.push(_loc3_.getId());
         }
         if(_currentPrimaryRoomId != -1)
         {
            setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         }
         else if(_roomIds.length == 1)
         {
            _currentPrimaryRoomId = roomIds[0];
         }
         if(_currentSubRoomId > 0)
         {
            setAPIUserList(_currentSubRoomId,_currentSubRoomUsers);
         }
         var _loc4_:SFEvent = new SFEvent("OnRoomList");
         _loc4_.status = true;
         dispatchEvent(_loc4_);
      }
      
      public function setAPIUserList(param1:int, param2:Object) : void
      {
         var _loc3_:Room = _sfs.getRoom(param1);
         if(!_loc3_)
         {
            DebugUtility.debugTrace("ERROR: setAPIUserList called with invalid roomId:" + param1);
            return;
         }
         var _loc5_:Array = _loc3_.getUserList();
         if(!_loc5_)
         {
            DebugUtility.debugTrace("ERROR: setAPIUserList got a null userlist from the room?!");
            return;
         }
         _loc5_.splice(0,_loc5_.length);
         if(!param2)
         {
            DebugUtility.debugTrace("ERROR: setAPIUserList called with invalid currUsers:" + param2);
            return;
         }
         for(var _loc4_ in param2)
         {
            _loc5_[_loc4_] = param2[_loc4_];
         }
      }
      
      private function firstMessageHttpProxyFallbackCallback() : void
      {
         gMainFrame.clientInfo.forceHttpProxy = true;
         connect();
      }
      
      private function onConnection(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = null;
         _currentPrimaryRoomId = -1;
         _currentSubRoomId = -1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","SFClient onConnection"]);
         }
         var _loc3_:Boolean = Boolean(param1.params.success);
         if(_loc3_)
         {
            _isConnected = true;
            DebugUtility.debugTrace("Connected: " + getConnectionUrl());
            if(_firstMessageHttpProxyFallbackProcessId > 0)
            {
               clearTimeout(_firstMessageHttpProxyFallbackProcessId);
            }
            if(gMainFrame.server.isBlueboxMode())
            {
               Utility.addExternalEventListener("beforeunload",gMainFrame.server.disconnect,"unloadAJClient");
            }
            if(_sfs.isIngressActive())
            {
               setInitRoom();
               setXtObject_Str("sv",[_serverIp],false);
            }
            getKey();
         }
         else
         {
            DebugUtility.debugTrace("Failed to connect to: " + getConnectionUrl());
            DebugUtility.debugTraceObject("evt.params",param1.params);
            _loc2_ = new SFEvent("OnConnect");
            _loc2_.status = false;
            _loc2_.statusId = param1.params.failCode;
            dispatchEvent(_loc2_);
         }
      }
      
      private function onConnectionLost(param1:SFSEvent) : void
      {
         DebugUtility.debugTrace("Connection Lost");
         _isConnected = false;
         _sfs.key = null;
         _isLoggedIn = false;
         _isWorldLoggedIn = false;
         _currentPrimaryRoomId = -1;
         _currentSubRoomId = -1;
         _currRoom = null;
         _currSubRoom = null;
         var _loc2_:SFEvent = new SFEvent("OnConectionLost");
         _loc2_.status = true;
         dispatchEvent(_loc2_);
      }
      
      private function onLogin(param1:SFSEvent) : void
      {
         var _loc3_:Boolean = Boolean(param1.params.success);
         if(!_loc3_)
         {
            DebugUtility.debugTrace("Error: " + param1.params.error);
         }
         else
         {
            _isLoggedIn = true;
            DebugUtility.debugTrace("Logged in!");
         }
         _currentPrimaryRoomId = -1;
         _currentSubRoomId = -1;
         _currRoom = null;
         _currSubRoom = null;
         var _loc2_:SFEvent = new SFEvent("OnLogin");
         _loc2_.status = _loc3_;
         _loc2_.userName = param1.params.name;
         dispatchEvent(_loc2_);
      }
      
      private function onExtensionResponse(param1:SFSEvent) : void
      {
         var _loc2_:Object = param1.params.dataObj;
         var _loc3_:SFEvent = null;
         if(_loc2_._cmd == "login")
         {
            DebugUtility.debugTrace("SFClient XtReply: data._cmd == login");
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","SFClient xtResponse - ON_LOGIN"]);
            }
            _loc3_ = new SFEvent("OnLogin");
            _loc3_.status = true;
            _loc3_.obj = _loc2_.params;
            _currentPrimaryRoomId = -1;
            _currentSubRoomId = -1;
            _currRoom = null;
            _currSubRoom = null;
            if(_loc2_.status == "1")
            {
               _myUser = new User(_sfs.myUserId = _loc2_.params.userId,_sfs.myUserName = _loc2_.params.userName);
               _loc3_.userName = _loc2_.params.userName;
               _isLoggedIn = true;
               _isWorldLoggedIn = true;
            }
            else
            {
               _loc3_.status = false;
               _loc3_.message = _loc2_.message;
               _loc3_.statusId = _loc2_.statusId;
            }
            dispatchEvent(_loc3_);
         }
         else
         {
            _loc3_ = new SFEvent("OnXtReply");
            _loc3_.status = true;
            _loc3_.obj = param1.params.dataObj;
            dispatchEvent(_loc3_);
         }
      }
      
      private function onRoomListUpdate(param1:SFSEvent) : void
      {
         DebugUtility.debugTrace("Updated Room List");
         _roomIds.splice(0,_roomIds.length);
         for each(var _loc2_ in param1.params.roomList)
         {
            _roomIds.push(_loc2_.getId());
         }
         if(_currentPrimaryRoomId != -1)
         {
            setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         }
         else if(_roomIds.length == 1)
         {
            _currentPrimaryRoomId = roomIds[0];
         }
         if(_currentSubRoomId > 0)
         {
            setAPIUserList(_currentSubRoomId,_currentSubRoomUsers);
         }
         var _loc3_:SFEvent = new SFEvent("OnRoomList");
         _loc3_.status = true;
         dispatchEvent(_loc3_);
      }
      
      private function onRoomAdded(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onRoomCreated");
         _loc2_.status = true;
         _loc2_.roomId = param1.params.room.getId();
         dispatchEvent(_loc2_);
      }
      
      private function onRoomDeleted(param1:SFSEvent) : void
      {
         setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         var _loc2_:SFEvent = new SFEvent("onRoomDeleted");
         _loc2_.status = true;
         if(param1 && param1.params && param1.params.room)
         {
            _loc2_.roomId = param1.params.room.getId();
         }
         dispatchEvent(_loc2_);
      }
      
      private function onCreateRoomError(param1:SFSEvent) : void
      {
         _currentSubRoomUsers = null;
         setAPIUserList(_currentSubRoomId,_currentSubRoomUsers);
         _currentSubRoomId = -1;
         var _loc2_:SFEvent = new SFEvent("onRoomCreated");
         _loc2_.status = false;
         _loc2_.message = param1.params.error;
         DebugUtility.debugTrace("SFClient: ERROR: could not create room! Message:" + _loc2_.message);
         dispatchEvent(_loc2_);
      }
      
      public function handleRoomJoin(param1:SFRoom) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = param1.id;
         if(_currentSubRoomId == 0 && param1.isSubRoom)
         {
            _currSubRoom = param1;
            _currentSubRoomId = _loc2_;
         }
         else
         {
            _currRoom = param1;
            _currentPrimaryRoomId = _loc2_;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","handleRoomJoin called"]);
         }
         var _loc5_:Array = _sfs.getAllRooms();
         (_loc5_[_loc2_] = new Room(_loc2_,param1.name,param1.maxUsers,param1.maxSpectators,param1.isTemp,param1.isGame,param1.isPrivate,param1.isLimbo,param1.users,param1.spectators)).addUser(_myUser,_myUser.getId());
         _sfs.activeRoomId = _loc2_;
         var _loc4_:SFEvent = new SFEvent("OnJoinRoom");
         _loc4_.status = true;
         _loc4_.roomId = _loc2_;
         _loc4_.obj = {};
         _loc4_.obj.room = param1;
         _loc4_.obj.subRoom = _currSubRoom;
         dispatchEvent(_loc4_);
      }
      
      public function handleRoomJoinError(param1:String, param2:String = "") : void
      {
         var _loc3_:SFEvent = new SFEvent("OnJoinRoom");
         _loc3_.status = false;
         _loc3_.message = param1;
         _loc3_.obj = {};
         _loc3_.obj.roomFull = param1 == "This room is currently full";
         _loc3_.obj.denOwner = param2;
         dispatchEvent(_loc3_);
      }
      
      public function handleSubRoomExit() : void
      {
         if(_currentSubRoomId <= 0)
         {
            throw new Error("Trying to leave a sub room when not in one?");
         }
         _currentSubRoomId = -1;
         _currSubRoom = null;
      }
      
      private function onRoomLeft(param1:SFSEvent) : void
      {
         if(_currentSubRoomId == 0)
         {
            throw new Error("Left a room while in the middle of making a sub room?!");
         }
         if(param1.params.roomId == _currentSubRoomId)
         {
            _currentSubRoomUsers = null;
            _currentSubRoomId = -1;
         }
         else
         {
            _currentPrimaryRoomUsers = null;
            setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         }
         var _loc2_:SFEvent = new SFEvent("OnLeftRoom");
         _loc2_.status = true;
         _loc2_.roomId = param1.params.roomId;
         dispatchEvent(_loc2_);
      }
      
      private function onUserEnterRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("OnUserEnteredRoom");
         _loc2_.status = true;
         _loc2_.userId = param1.params.user.getId();
         _loc2_.userName = param1.params.user.getName();
         _loc2_.roomId = param1.params.roomId;
         if(_loc2_.roomId == _currentPrimaryRoomId)
         {
            _currentPrimaryRoomUsers[_loc2_.userId] = param1.params.user;
            setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         }
         else if(_loc2_.roomId == _currentSubRoomId)
         {
            _currentSubRoomUsers[_loc2_.userId] = param1.params.user;
            setAPIUserList(_currentSubRoomId,_currentSubRoomUsers);
         }
         else
         {
            DebugUtility.debugTrace("ERROR: User entered not-one-of-mine roomId:" + _loc2_.roomId + " _currentPrimaryRoomId:" + _currentPrimaryRoomId + " _currentSubRoomId:" + _currentSubRoomId);
         }
         dispatchEvent(_loc2_);
      }
      
      private function onUserLeaveRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("OnUserLeftRoom");
         _loc2_.status = true;
         _loc2_.userId = param1.params.userId;
         _loc2_.roomId = param1.params.roomId;
         if(_loc2_.roomId == _currentPrimaryRoomId)
         {
            delete _currentPrimaryRoomUsers[_loc2_.userId];
            setAPIUserList(_currentPrimaryRoomId,_currentPrimaryRoomUsers);
         }
         else if(_loc2_.roomId == _currentSubRoomId)
         {
            delete _currentSubRoomUsers[_loc2_.userId];
            setAPIUserList(_currentSubRoomId,_currentSubRoomUsers);
         }
         else
         {
            DebugUtility.debugTrace("ERROR: User left not-one-of-mine roomId:" + _loc2_.roomId + " _currentPrimaryRoomId:" + _currentPrimaryRoomId + " _currentSubRoomId:" + _currentSubRoomId);
         }
         dispatchEvent(_loc2_);
      }
      
      private function onUserCountChange(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onRoomPopulationChange");
         _loc2_.status = true;
         _loc2_.roomId = param1.params.room.getId();
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyList(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onBuddyList");
         _loc2_.status = true;
         _loc2_.obj = param1.params.list;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyListError(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onBuddyList");
         _loc2_.status = false;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyListUpdate(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onBuddyListUpdate");
         _loc2_.status = true;
         _loc2_.userName = param1.params.buddy.name;
         _loc2_.obj = param1.params.buddy;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyPermissionRequest(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onBuddyRequest");
         _loc2_.status = true;
         _loc2_.userName = param1.params.sender;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("onBuddyRoom");
         _loc2_.status = true;
         _loc2_.roomId = param1.params.idList[0];
         dispatchEvent(_loc2_);
      }
      
      private function onAdminMessage(param1:SFSEvent) : void
      {
         DebugUtility.debugTrace("onAdminMessage:" + param1.params.message);
      }
      
      private function onModeratorMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("OnChatMessage");
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onPrivateMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("OnChatMessage");
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onPublicMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent("OnChatMessage");
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onRandomKey(param1:SFSEvent) : void
      {
         _sfs.key = param1.params.key;
         DebugUtility.debugTrace("Random key received from server: " + _sfs.key);
         var _loc2_:SFEvent = new SFEvent("OnConnect");
         _loc2_.status = true;
         dispatchEvent(_loc2_);
      }
      
      public function get allowAutoAttemptHttp() : Boolean
      {
         return _sfs.smartConnectAllowed;
      }
      
      public function get autoAttemptHttp() : Boolean
      {
         return _sfs.smartConnect;
      }
      
      public function set autoAttemptHttp(param1:Boolean) : void
      {
         _sfs.smartConnect = param1;
      }
      
      public function get isWorldZone() : Boolean
      {
         return _isWorldZone;
      }
      
      public function get userId() : int
      {
         return _sfs.myUserId;
      }
      
      public function get userName() : String
      {
         return _sfs.myUserName;
      }
      
      public function get gemCount() : int
      {
         return _gemCount;
      }
      
      public function set gemCount(param1:int) : void
      {
         _gemCount = param1;
      }
      
      public function get signInUserName() : String
      {
         return _userName;
      }
      
      public function get password() : String
      {
         return _password;
      }
      
      public function get roomIds() : Array
      {
         return _roomIds;
      }
      
      public function get buddyList() : Array
      {
         return _sfs.buddyList;
      }
      
      public function get rawProtocolSeparator() : String
      {
         return _sfs.rawProtocolSeparator;
      }
      
      public function get isLoggedIn() : Boolean
      {
         return _isLoggedIn;
      }
      
      public function get isConnected() : Boolean
      {
         return _isConnected;
      }
      
      public function getIsConnected() : Boolean
      {
         return _isConnected;
      }
      
      public function get hashKey() : String
      {
         return _sfs.key;
      }
   }
}

