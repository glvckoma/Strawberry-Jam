package it.gotoandplay.smartfoxserver
{
   import com.adobe.crypto.MD5;
   import com.hurlant.util.Base64;
   import com.sbi.corelib.crypto.SBCrypto;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.SecureSocket;
   import flash.net.Socket;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Capabilities;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   import it.gotoandplay.smartfoxserver.handlers.ExtHandler;
   import it.gotoandplay.smartfoxserver.handlers.IMessageHandler;
   import it.gotoandplay.smartfoxserver.handlers.SysHandler;
   import it.gotoandplay.smartfoxserver.http.HttpConnection;
   import it.gotoandplay.smartfoxserver.http.HttpEvent;
   import it.gotoandplay.smartfoxserver.util.Entities;
   import it.gotoandplay.smartfoxserver.util.FailCode;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class SmartFoxClient extends EventDispatcher
   {
      private static const PUB_KEY_SERVICE_LB:String = "4ba64c9f0ada96f259ab19c96d237f64";
      
      private static const PUB_KEY_ISS_LB_V1:String = "970b11a43e6de41d6377a986fde11026";
      
      private static const EOM:int = 0;
      
      private static const MSG_XML:String = "<";
      
      private static const MSG_JSON:String = "{";
      
      private static var MSG_STR:String = "%";
      
      private static var MIN_POLL_SPEED:Number = 0;
      
      private static var DEFAULT_POLL_SPEED:Number = 750;
      
      private static var MAX_POLL_SPEED:Number = 10000;
      
      public static const MODMSG_TO_USER:String = "u";
      
      public static const MODMSG_TO_ROOM:String = "r";
      
      public static const MODMSG_TO_ZONE:String = "z";
      
      public static const XTMSG_TYPE_XML:String = "xml";
      
      public static const XTMSG_TYPE_STR:String = "str";
      
      public static const XTMSG_TYPE_JSON:String = "json";
      
      public static const CONNECTION_MODE_DISCONNECTED:String = "disconnected";
      
      public static const CONNECTION_MODE_SOCKET:String = "socket";
      
      public static const CONNECTION_MODE_HTTP:String = "http";
      
      private var byteBuffer:ByteArray = new ByteArray();
      
      public var _ingressActive:Boolean = false;
      
      public var _ingressHProxyActive:Boolean = false;
      
      private var roomList:Array;
      
      private var connected:Boolean;
      
      private var benchStartTime:int;
      
      private var sysHandler:SysHandler;
      
      private var extHandler:ExtHandler;
      
      private var majVersion:Number;
      
      private var minVersion:Number;
      
      private var subVersion:Number;
      
      private var messageHandlers:Array;
      
      private var socketConnection:Socket;
      
      private var autoConnectOnConfigSuccess:Boolean = false;
      
      private var _connectingToBluebox:Boolean = false;
      
      public var ipAddress:String;
      
      public var port:int = 9339;
      
      public var defaultZone:String;
      
      private var _socketConnectionFailureHandled:Boolean;
      
      private var isHttpMode:Boolean = false;
      
      private var _httpPollSpeed:int = DEFAULT_POLL_SPEED;
      
      private var httpConnection:HttpConnection;
      
      public var blueBoxIpAddress:String;
      
      public var blueBoxPort:Number = 0;
      
      public var smartConnect:Boolean = true;
      
      private var _smartConnectAllowed:Boolean = true;
      
      private var _numPollFailures:int;
      
      public var buddyList:Array;
      
      public var myBuddyVars:Array;
      
      public var debug:Boolean;
      
      public var myUserId:int;
      
      public var myUserName:String;
      
      public var playerId:int;
      
      public var amIModerator:Boolean;
      
      public var activeRoomId:int;
      
      public var changingRoom:Boolean;
      
      public var httpPort:int = 8080;
      
      public var key:String;
      
      public var properties:Object = null;
      
      public function SmartFoxClient(param1:Boolean = false)
      {
         super();
         this.majVersion = 1;
         this.minVersion = 6;
         this.subVersion = 5;
         this.activeRoomId = -1;
         this.debug = param1;
         this.messageHandlers = [];
         this.setupMessageHandlers();
         if(this.useSecureMode())
         {
            this._smartConnectAllowed = false;
            this.socketConnection = new SecureSocket();
         }
         else
         {
            this.socketConnection = new Socket();
         }
         this.socketConnection.addEventListener("connect",this.handleSocketConnection);
         this.socketConnection.addEventListener("close",this.handleSocketDisconnection);
         this.socketConnection.addEventListener("socketData",this.handleSocketData);
         this.socketConnection.addEventListener("ioError",this.handleSocketIOError);
         this.socketConnection.addEventListener("networkError",this.handleSocketIOError);
         this.socketConnection.addEventListener("securityError",this.handleSocketSecurityError);
         this.httpConnection = new HttpConnection(this);
         this.httpConnection.addEventListener("onHttpConnect",this.handleHttpConnect);
         this.httpConnection.addEventListener("onHttpClose",this.handleHttpClose);
         this.httpConnection.addEventListener("onHttpData",this.handleHttpData);
         this.httpConnection.addEventListener("onHttpError",this.handleHttpError);
         this.httpConnection.addEventListener("onHttpPollError",this.handleHttpPollError);
      }
      
      public function get smartConnectAllowed() : Boolean
      {
         return this._smartConnectAllowed;
      }
      
      public function get rawProtocolSeparator() : String
      {
         return MSG_STR;
      }
      
      public function set rawProtocolSeparator(param1:String) : void
      {
         if(param1 != "<" && param1 != "{")
         {
            MSG_STR = param1;
         }
      }
      
      public function get isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function set isConnected(param1:Boolean) : void
      {
         this.connected = param1;
      }
      
      public function get httpPollSpeed() : int
      {
         return this._httpPollSpeed;
      }
      
      public function set httpPollSpeed(param1:int) : void
      {
         if(param1 >= 0 && param1 <= 10000)
         {
            this._httpPollSpeed = param1;
         }
      }
      
      public function loadConfig(param1:String = "config.xml", param2:Boolean = true) : void
      {
         this.autoConnectOnConfigSuccess = param2;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.addEventListener("complete",this.onConfigLoadSuccess);
         _loc3_.addEventListener("ioError",this.onConfigLoadFailure);
         _loc3_.load(new URLRequest(param1));
      }
      
      public function getConnectionMode() : String
      {
         var _loc1_:String = "disconnected";
         if(this.isConnected)
         {
            if(this.isHttpMode)
            {
               _loc1_ = "http";
            }
            else
            {
               _loc1_ = "socket";
            }
         }
         return _loc1_;
      }
      
      public function connect(param1:String, param2:int = 9339) : void
      {
         if(!this.connected)
         {
            this.initialize();
            this.ipAddress = "127.0.0.1";
            this.port = param2;
            this.debugMessage("SmartFoxClient.connect: " + this.getConnectionUrl());
            this.socketConnection.connect(this.getSocketIpAddress(),param2);
         }
         else
         {
            this.debugMessage("*** ALREADY CONNECTED ***");
         }
      }
      
      public function connectBluebox() : void
      {
         if(!this.connected)
         {
            this.initialize();
            this.tryBlueBoxConnection(new ErrorEvent("error",false,false,"Already connected when trying to force httpProxy connection?!"));
         }
         else
         {
            this.debugMessage("*** ALREADY HTTP CONNECTED ***");
         }
      }
      
      public function disconnect(param1:Boolean = true) : void
      {
         if(this.connected)
         {
            this.connected = false;
            if(!this.isHttpMode)
            {
               this.socketConnection.close();
            }
            else
            {
               this.httpConnection.close();
            }
            if(param1)
            {
               this.sysHandler.dispatchDisconnection();
            }
         }
      }
      
      public function addBuddy(param1:String) : void
      {
         var _loc2_:* = null;
         if(param1 != this.myUserName && !this.checkBuddyDuplicates(param1))
         {
            _loc2_ = "<n>" + param1 + "</n>";
            this.send({"t":"sys"},"addB",-1,_loc2_);
         }
      }
      
      public function autoJoin() : void
      {
         if(!this.checkRoomList())
         {
            return;
         }
         var _loc1_:Object = {"t":"sys"};
         this.send(_loc1_,"autoJoin",!!this.activeRoomId ? this.activeRoomId : -1,"");
      }
      
      public function clearBuddyList() : void
      {
         this.buddyList = [];
         this.send({"t":"sys"},"clearB",-1,"");
         var _loc2_:Object = {};
         _loc2_.list = this.buddyList;
         var _loc1_:SFSEvent = new SFSEvent("onBuddyList",_loc2_);
         dispatchEvent(_loc1_);
      }
      
      public function createRoom(param1:Object, param2:int = -1) : void
      {
         var _loc7_:* = undefined;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = this.activeRoomId;
         }
         var _loc6_:Object = {"t":"sys"};
         var _loc10_:String = !!param1.isGame ? "1" : "0";
         var _loc4_:String = "1";
         var _loc3_:String = param1.maxUsers == null ? "0" : String(param1.maxUsers);
         var _loc5_:String = param1.maxSpectators == null ? "0" : String(param1.maxSpectators);
         var _loc8_:String = !!param1.joinAsSpectator ? "1" : "0";
         if(param1.isGame && param1.exitCurrentRoom != null)
         {
            _loc4_ = !!param1.exitCurrentRoom ? "1" : "0";
         }
         var _loc9_:String = "<room tmp=\'1\' gam=\'" + _loc10_ + "\' spec=\'" + _loc5_ + "\' exit=\'" + _loc4_ + "\' jas=\'" + _loc8_ + "\'>";
         _loc9_ = _loc9_ + ("<name><![CDATA[" + (param1.name == null ? "" : param1.name) + "]]></name>");
         _loc9_ = _loc9_ + ("<pwd><![CDATA[" + (param1.password == null ? "" : param1.password) + "]]></pwd>");
         _loc9_ = _loc9_ + ("<max>" + _loc3_ + "</max>");
         if(param1.uCount != null)
         {
            _loc9_ += "<uCnt>" + (!!param1.uCount ? "1" : "0") + "</uCnt>";
         }
         if(param1.extension != null)
         {
            _loc9_ += "<xt n=\'" + param1.extension.name;
            _loc9_ = _loc9_ + ("\' s=\'" + param1.extension.script + "\' />");
         }
         if(param1.vars == null)
         {
            _loc9_ += "<vars></vars>";
         }
         else
         {
            _loc9_ += "<vars>";
            for(_loc7_ in param1.vars)
            {
               _loc9_ += this.getXmlRoomVariable(param1.vars[_loc7_]);
            }
            _loc9_ += "</vars>";
         }
         _loc9_ += "</room>";
         this.send(_loc6_,"createRoom",param2,_loc9_);
      }
      
      public function getAllRooms() : Array
      {
         return this.roomList;
      }
      
      public function setRoomList(param1:Array) : void
      {
         this.roomList = param1;
      }
      
      public function getBuddyByName(param1:String) : Object
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this.buddyList)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getBuddyById(param1:int) : Object
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this.buddyList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getBuddyRoom(param1:Object) : void
      {
         if(param1.id != -1)
         {
            this.send({"t":"sys"},"roomB",-1,"<b id=\'" + param1.id + "\' />");
         }
      }
      
      public function getRoom(param1:int) : Room
      {
         if(!this.checkRoomList())
         {
            return null;
         }
         return this.roomList[param1];
      }
      
      public function getRoomByName(param1:String) : Room
      {
         var _loc2_:* = undefined;
         if(!this.checkRoomList())
         {
            return null;
         }
         var _loc3_:* = null;
         for each(_loc2_ in this.roomList)
         {
            if(_loc2_.getName() == param1)
            {
               _loc3_ = _loc2_;
               break;
            }
         }
         return _loc3_;
      }
      
      public function getRoomList() : void
      {
         var _loc1_:Object = {"t":"sys"};
         this.send(_loc1_,"getRmList",this.activeRoomId,"");
      }
      
      public function getActiveRoom() : Room
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return null;
         }
         return this.roomList[this.activeRoomId];
      }
      
      public function getRandomKey() : void
      {
         this.send({"t":"sys"},"rndK",-1,"");
      }
      
      public function getUploadPath() : String
      {
         return "http://" + this.ipAddress + ":" + this.httpPort + "/default/uploads/";
      }
      
      public function getVersion() : String
      {
         return this.majVersion + "." + this.minVersion + "." + this.subVersion;
      }
      
      public function joinRoom(param1:*, param2:String = "", param3:Boolean = false, param4:Boolean = false, param5:int = -1) : void
      {
         var _loc6_:* = undefined;
         var _loc9_:* = null;
         var _loc8_:* = null;
         var _loc12_:* = 0;
         var _loc10_:* = null;
         if(!this.checkRoomList())
         {
            return;
         }
         var _loc7_:int = -1;
         var _loc11_:* = param3 ? 1 : 0;
         if(!this.changingRoom)
         {
            if(typeof param1 == "number")
            {
               _loc7_ = param1;
            }
            else if(typeof param1 == "string")
            {
               for each(_loc6_ in this.roomList)
               {
                  if(_loc6_.getName() == param1)
                  {
                     _loc7_ = int(_loc6_.getId());
                     break;
                  }
               }
            }
            if(_loc7_ != -1)
            {
               _loc9_ = {"t":"sys"};
               _loc8_ = param4 ? "0" : "1";
               _loc12_ = param5 > -1 ? param5 : int(this.activeRoomId);
               if(this.activeRoomId == -1)
               {
                  _loc8_ = "0";
                  _loc12_ = -1;
               }
               _loc10_ = "<room id=\'" + _loc7_ + "\' pwd=\'" + param2 + "\' spec=\'" + _loc11_ + "\' leave=\'" + _loc8_ + "\' old=\'" + _loc12_ + "\' />";
               this.send(_loc9_,"joinRoom",this.activeRoomId,_loc10_);
               this.changingRoom = true;
            }
            else
            {
               this.debugMessage("SmartFoxError: requested room to join does not exist!");
            }
         }
      }
      
      public function leaveRoom(param1:int) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         var _loc2_:Object = {"t":"sys"};
         var _loc3_:String = "<rm id=\'" + param1 + "\' />";
         this.send(_loc2_,"leaveRoom",param1,_loc3_);
      }
      
      public function loadBuddyList() : void
      {
         this.send({"t":"sys"},"loadB",-1,"");
      }
      
      public function login(param1:String, param2:String, param3:String) : void
      {
         var _loc5_:Object = {"t":"sys"};
         var _loc6_:String = "<login z=\'" + param1 + "\'><nick><![CDATA[" + param2 + "]]></nick><pword><![CDATA[" + param3 + "]]></pword></login>";
         var _loc4_:* = param1 != "sbiAccountZone";
         this.send(_loc5_,"login",0,_loc6_,_loc4_);
      }
      
      public function logout() : void
      {
         var _loc1_:Object = {"t":"sys"};
         this.send(_loc1_,"logout",-1,"");
      }
      
      public function removeBuddy(param1:String) : void
      {
         var _loc5_:* = undefined;
         var _loc7_:* = null;
         var _loc4_:* = null;
         var _loc8_:* = null;
         var _loc6_:* = null;
         var _loc2_:* = null;
         var _loc3_:Boolean = false;
         for(_loc5_ in this.buddyList)
         {
            _loc7_ = this.buddyList[_loc5_];
            if(_loc7_.name == param1)
            {
               delete this.buddyList[_loc5_];
               _loc3_ = true;
               break;
            }
         }
         if(_loc3_)
         {
            _loc4_ = {"t":"sys"};
            _loc8_ = "<n>" + param1 + "</n>";
            this.send(_loc4_,"remB",-1,_loc8_);
            _loc6_ = {};
            _loc6_.list = this.buddyList;
            _loc2_ = new SFSEvent("onBuddyList",_loc6_);
            dispatchEvent(_loc2_);
         }
      }
      
      public function roundTripBench() : void
      {
         this.benchStartTime = getTimer();
         this.send({"t":"sys"},"roundTrip",this.activeRoomId,"");
      }
      
      public function sendBuddyPermissionResponse(param1:Boolean, param2:String) : void
      {
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<n res=\'" + (param1 ? "g" : "r") + "\'>" + param2 + "</n>";
         this.send(_loc3_,"bPrm",-1,_loc4_);
      }
      
      public function sendPublicMessage(param1:String, param2:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = this.activeRoomId;
         }
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<txt><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         this.send(_loc3_,"pubMsg",param2,_loc4_);
      }
      
      public function sendPrivateMessage(param1:String, param2:int, param3:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param3 == -1)
         {
            param3 = this.activeRoomId;
         }
         var _loc4_:Object = {"t":"sys"};
         var _loc5_:String = "<txt rcp=\'" + param2 + "\'><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         this.send(_loc4_,"prvMsg",param3,_loc5_);
      }
      
      public function sendModeratorMessage(param1:String, param2:String, param3:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         var _loc4_:Object = {"t":"sys"};
         var _loc5_:String = "<txt t=\'" + param2 + "\' id=\'" + param3 + "\'><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         this.send(_loc4_,"modMsg",this.activeRoomId,_loc5_);
      }
      
      public function sendObject(param1:Object, param2:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = this.activeRoomId;
         }
         var _loc4_:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(param1) + "]]>";
         var _loc3_:Object = {"t":"sys"};
         this.send(_loc3_,"asObj",param2,_loc4_);
      }
      
      public function sendObjectToGroup(param1:Object, param2:Array, param3:int = -1) : void
      {
         var _loc5_:* = undefined;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param3 == -1)
         {
            param3 = this.activeRoomId;
         }
         var _loc4_:String = "";
         for(_loc5_ in param2)
         {
            if(!isNaN(param2[_loc5_]))
            {
               _loc4_ += param2[_loc5_] + ",";
            }
         }
         _loc4_ = _loc4_.substr(0,_loc4_.length - 1);
         param1._$$_ = _loc4_;
         var _loc6_:Object = {"t":"sys"};
         var _loc7_:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(param1) + "]]>";
         this.send(_loc6_,"asObjG",param3,_loc7_);
      }
      
      public function sendXtMessage(param1:String, param2:String, param3:*, param4:String = "xml", param5:int = -1) : void
      {
         var _loc13_:* = null;
         var _loc10_:* = null;
         var _loc9_:* = null;
         var _loc12_:* = null;
         var _loc7_:* = NaN;
         var _loc8_:* = null;
         var _loc11_:* = null;
         var _loc6_:* = null;
         if(!this.checkRoomList())
         {
            return;
         }
         if(param5 == -1)
         {
            param5 = this.activeRoomId;
         }
         if(param4 == "xml")
         {
            _loc13_ = {"t":"xt"};
            _loc10_ = {
               "name":param1,
               "cmd":param2,
               "param":param3
            };
            _loc9_ = "<![CDATA[" + ObjectSerializer.getInstance().serialize(_loc10_) + "]]>";
            this.send(_loc13_,"xtReq",param5,_loc9_);
         }
         else if(param4 == "str")
         {
            _loc12_ = MSG_STR + "xt" + MSG_STR + param1 + MSG_STR + param2 + MSG_STR + param5 + MSG_STR;
            _loc7_ = 0;
            while(_loc7_ < param3.length)
            {
               _loc12_ += param3[_loc7_].toString() + MSG_STR;
               _loc7_++;
            }
            this.sendString(_loc12_);
         }
         else if(param4 == "json")
         {
            _loc8_ = {};
            _loc8_.x = param1;
            _loc8_.c = param2;
            _loc8_.r = param5;
            _loc8_.p = param3;
            _loc11_ = {};
            _loc11_.t = "xt";
            _loc11_.b = _loc8_;
            _loc6_ = JSON.stringify(_loc11_);
            this.sendJson(_loc6_);
         }
      }
      
      public function setBuddyBlockStatus(param1:String, param2:Boolean) : void
      {
         var _loc6_:* = null;
         var _loc5_:* = null;
         var _loc4_:* = null;
         var _loc3_:Object = this.getBuddyByName(param1);
         if(_loc3_ != null)
         {
            if(_loc3_.isBlocked != param2)
            {
               _loc3_.isBlocked = param2;
               _loc6_ = "<n x=\'" + (param2 ? "1" : "0") + "\'>" + param1 + "</n>";
               this.send({"t":"sys"},"setB",-1,_loc6_);
               _loc5_ = {};
               _loc5_.buddy = _loc3_;
               _loc4_ = new SFSEvent("onBuddyListUpdate",_loc5_);
               dispatchEvent(_loc4_);
            }
         }
      }
      
      public function setBuddyVariables(param1:Array) : void
      {
         var _loc2_:* = undefined;
         var _loc5_:* = null;
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<vars>";
         for(_loc2_ in param1)
         {
            _loc5_ = param1[_loc2_];
            if(this.myBuddyVars[_loc2_] != _loc5_)
            {
               this.myBuddyVars[_loc2_] = _loc5_;
               _loc4_ += "<var n=\'" + _loc2_ + "\'><![CDATA[" + _loc5_ + "]]></var>";
            }
         }
         _loc4_ += "</vars>";
         this.send(_loc3_,"setBvars",-1,_loc4_);
      }
      
      public function setRoomVariables(param1:Array, param2:int = -1, param3:Boolean = true) : void
      {
         var _loc4_:* = undefined;
         var _loc6_:* = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = this.activeRoomId;
         }
         var _loc5_:Object = {"t":"sys"};
         if(param3)
         {
            _loc6_ = "<vars>";
         }
         else
         {
            _loc6_ = "<vars so=\'0\'>";
         }
         for each(_loc4_ in param1)
         {
            _loc6_ += this.getXmlRoomVariable(_loc4_);
         }
         _loc6_ += "</vars>";
         this.send(_loc5_,"setRvars",param2,_loc6_);
      }
      
      public function setUserVariables(param1:Object, param2:int = -1) : void
      {
         var _loc5_:User = null;
         var _loc8_:Room = null;
         var _loc9_:* = undefined;
         var _loc4_:* = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = this.activeRoomId;
         }
         var _loc3_:Object = {"t":"sys"};
         _loc8_ = this.getActiveRoom();
         _loc5_ = _loc8_.getUser(this.myUserId);
         _loc5_.setVariables(param1);
         var _loc6_:int = _loc5_.getId();
         for each(_loc9_ in this.getAllRooms())
         {
            _loc4_ = _loc9_.getUser(_loc6_);
            if(_loc4_ != null && _loc4_ != _loc5_)
            {
               _loc4_.setVariables(param1);
            }
         }
         var _loc7_:String = this.getXmlUserVariable(param1);
         this.send(_loc3_,"setUvars",param2,_loc7_);
      }
      
      public function switchSpectator(param1:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param1 == -1)
         {
            param1 = this.activeRoomId;
         }
         this.send({"t":"sys"},"swSpec",param1,"");
      }
      
      public function switchPlayer(param1:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(param1 == -1)
         {
            param1 = this.activeRoomId;
         }
         this.send({"t":"sys"},"swPl",param1,"");
      }
      
      public function uploadFile(param1:FileReference, param2:int = -1, param3:String = "", param4:int = -1) : void
      {
         if(param2 == -1)
         {
            param2 = this.myUserId;
         }
         if(param3 == "")
         {
            param3 = this.myUserName;
         }
         if(param4 == -1)
         {
            param4 = this.httpPort;
         }
         param1.upload(new URLRequest("http://" + this.ipAddress + ":" + param4 + "/default/Upload.py?id=" + param2 + "&nick=" + param3));
         this.debugMessage("[UPLOAD]: http://" + this.ipAddress + ":" + param4 + "/default/Upload.py?id=" + param2 + "&nick=" + param3);
      }
      
      public function __logout() : void
      {
         this.initialize(true);
      }
      
      public function sendString(param1:String) : void
      {
         this.debugMessage("[Sending - STR]: " + param1);
         if(this.isHttpMode)
         {
            this.httpConnection.send(param1);
         }
         else
         {
            this.writeToSocket(param1);
         }
      }
      
      public function sendJson(param1:String) : void
      {
         this.debugMessage("[Sending - JSON]: " + param1);
         if(this.isHttpMode)
         {
            this.httpConnection.send(param1);
         }
         else
         {
            this.writeToSocket(param1);
         }
      }
      
      public function getBenchStartTime() : int
      {
         return this.benchStartTime;
      }
      
      public function clearRoomList() : void
      {
         this.roomList = [];
      }
      
      public function isSecureSocketSupported() : Boolean
      {
         return SecureSocket.isSupported && this.doesSecureSocketActuallyWorkHere();
      }
      
      private function doesSecureSocketActuallyWorkHere() : Boolean
      {
         return Capabilities.manufacturer != "Adobe Linux";
      }
      
      public function useSecureMode() : Boolean
      {
         return false;
      }
      
      public function getConnectionUrl() : String
      {
         var _loc1_:* = null;
         if(this._connectingToBluebox || this.isHttpMode)
         {
            _loc1_ = this.httpConnection.getBaseUrl();
         }
         else
         {
            _loc1_ = (this.socketConnection is SecureSocket ? "tlssocket" : "socket") + "://" + this.getSocketIpAddress() + ":" + this.port;
         }
         return _loc1_;
      }
      
      public function isIngressActive() : Boolean
      {
         return this.isHttpMode ? this._ingressHProxyActive : Boolean(this._ingressActive);
      }
      
      private function initialize(param1:Boolean = false) : void
      {
         this.changingRoom = false;
         this.amIModerator = false;
         this.playerId = -1;
         this.activeRoomId = -1;
         this.myUserId = -1;
         this.myUserName = "";
         this.roomList = [];
         this.buddyList = [];
         this.myBuddyVars = [];
         if(!param1)
         {
            this.connected = false;
            this.isHttpMode = false;
         }
         this._socketConnectionFailureHandled = false;
      }
      
      private function onConfigLoadSuccess(param1:Event) : void
      {
         var _loc2_:* = null;
         var _loc3_:URLLoader = param1.target as URLLoader;
         var _loc4_:XML = new XML(_loc3_.data);
         this.ipAddress = this.blueBoxIpAddress = _loc4_.ip;
         this.port = int(_loc4_.port);
         this.defaultZone = _loc4_.zone;
         if(_loc4_.blueBoxIpAddress != undefined)
         {
            this.blueBoxIpAddress = _loc4_.blueBoxIpAddress;
         }
         if(_loc4_.blueBoxPort != undefined)
         {
            this.blueBoxPort = _loc4_.blueBoxPort;
         }
         if(_loc4_.debug != undefined)
         {
            this.debug = _loc4_.debug.toLowerCase() == "true" ? true : false;
         }
         if(_loc4_.smartConnect != undefined)
         {
            this.smartConnect = _loc4_.smartConnect.toLowerCase() == "true" ? true : false;
         }
         if(_loc4_.httpPort != undefined)
         {
            this.httpPort = int(_loc4_.httpPort);
         }
         if(_loc4_.httpPollSpeed != undefined)
         {
            this.httpPollSpeed = int(_loc4_.httpPollSpeed);
         }
         if(_loc4_.rawProtocolSeparator != undefined)
         {
            this.rawProtocolSeparator = _loc4_.rawProtocolSeparator;
         }
         if(this.autoConnectOnConfigSuccess)
         {
            this.connect(this.ipAddress,this.port);
         }
         else
         {
            _loc2_ = new SFSEvent("onConfigLoadSuccess",{});
            dispatchEvent(_loc2_);
         }
      }
      
      private function onConfigLoadFailure(param1:IOErrorEvent) : void
      {
         var _loc3_:Object = {"message":param1.text};
         var _loc2_:SFSEvent = new SFSEvent("onConfigLoadFailure",_loc3_);
         dispatchEvent(_loc2_);
      }
      
      private function setupMessageHandlers() : void
      {
         this.sysHandler = new SysHandler(this);
         this.extHandler = new ExtHandler(this);
         this.addMessageHandler("sys",this.sysHandler);
         this.addMessageHandler("xt",this.extHandler);
      }
      
      private function addMessageHandler(param1:String, param2:IMessageHandler) : void
      {
         if(this.messageHandlers[param1] == null)
         {
            this.messageHandlers[param1] = param2;
         }
         else
         {
            this.debugMessage("Warning, message handler called: " + param1 + " already exist!");
         }
      }
      
      public function debugMessage(param1:String) : void
      {
         var _loc2_:* = null;
         if(this.debug)
         {
            DebugUtility.debugTrace(param1);
            _loc2_ = new SFSEvent("onDebugMessage",{"message":param1});
            dispatchEvent(_loc2_);
         }
      }
      
      private function send(param1:Object, param2:String, param3:Number, param4:String, param5:Boolean = false) : void
      {
         if(param5)
         {
            param1.h = SBCrypto.hmacSha256(this.key,param4);
         }
         var _loc6_:String = this.makeXmlHeader(param1);
         _loc6_ = _loc6_ + ("<body action=\'" + param2 + "\' r=\'" + param3 + "\'>" + param4 + "</body>" + this.closeHeader());
         this.debugMessage("[Sending]: " + _loc6_);
         if(this.isHttpMode)
         {
            this.httpConnection.send(_loc6_);
         }
         else
         {
            this.writeToSocket(_loc6_);
         }
      }
      
      private function writeToSocket(param1:String) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         _loc2_.writeByte(0);
         this.socketConnection.writeBytes(_loc2_);
         this.socketConnection.flush();
      }
      
      private function makeXmlHeader(param1:Object) : String
      {
         var _loc2_:* = undefined;
         var _loc3_:String = "<msg";
         for(_loc2_ in param1)
         {
            _loc3_ += " " + _loc2_ + "=\'" + param1[_loc2_] + "\'";
         }
         return _loc3_ + ">";
      }
      
      private function closeHeader() : String
      {
         return "</msg>";
      }
      
      private function checkBuddyDuplicates(param1:String) : Boolean
      {
         var _loc3_:* = undefined;
         var _loc2_:Boolean = false;
         for each(_loc3_ in this.buddyList)
         {
            if(_loc3_.name == param1)
            {
               _loc2_ = true;
               break;
            }
         }
         return _loc2_;
      }
      
      private function xmlReceived(param1:String) : void
      {
         var _loc6_:XML = null;
         _loc6_ = new XML(param1);
         var _loc3_:String = _loc6_.@t;
         var _loc4_:String = _loc6_.body.@action;
         var _loc5_:int = int(_loc6_.body.@r);
         var _loc2_:IMessageHandler = this.messageHandlers[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc6_,"xml");
         }
      }
      
      private function jsonReceived(param1:String) : void
      {
         var _loc3_:Object = JSON.parse(param1);
         var _loc4_:String = _loc3_["t"];
         var _loc2_:IMessageHandler = this.messageHandlers[_loc4_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc3_["b"],"json");
         }
      }
      
      private function strReceived(param1:String) : void
      {
         var _loc4_:Array = null;
         _loc4_ = param1.substr(1,param1.length - 2).split(MSG_STR);
         var _loc3_:String = _loc4_[0];
         var _loc2_:IMessageHandler = this.messageHandlers[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc4_.splice(1,_loc4_.length - 1),"str");
         }
      }
      
      private function getXmlRoomVariable(param1:Object) : String
      {
         var _loc6_:String = null;
         var _loc2_:String = param1.name.toString();
         var _loc7_:* = param1.val;
         var _loc4_:String = !!param1.priv ? "1" : "0";
         var _loc5_:String = !!param1.persistent ? "1" : "0";
         var _loc3_:String = null;
         _loc6_ = typeof _loc7_;
         if(_loc6_ == "boolean")
         {
            _loc3_ = "b";
            _loc7_ = !!_loc7_ ? "1" : "0";
         }
         else if(_loc6_ == "number")
         {
            _loc3_ = "n";
         }
         else if(_loc6_ == "string")
         {
            _loc3_ = "s";
         }
         else if(_loc7_ == null && _loc6_ == "object" || _loc6_ == "undefined")
         {
            _loc3_ = "x";
            _loc7_ = "";
         }
         if(_loc3_ != null)
         {
            return "<var n=\'" + _loc2_ + "\' t=\'" + _loc3_ + "\' pr=\'" + _loc4_ + "\' pe=\'" + _loc5_ + "\'><![CDATA[" + _loc7_ + "]]></var>";
         }
         return "";
      }
      
      private function getXmlUserVariable(param1:Object) : String
      {
         var _loc6_:* = undefined;
         var _loc2_:* = undefined;
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc5_:String = "<vars>";
         for(_loc6_ in param1)
         {
            _loc2_ = param1[_loc6_];
            _loc4_ = typeof _loc2_;
            _loc3_ = null;
            if(_loc4_ == "boolean")
            {
               _loc3_ = "b";
               _loc2_ = !!_loc2_ ? "1" : "0";
            }
            else if(_loc4_ == "number")
            {
               _loc3_ = "n";
            }
            else if(_loc4_ == "string")
            {
               _loc3_ = "s";
            }
            else if(_loc2_ == null && _loc4_ == "object" || _loc4_ == "undefined")
            {
               _loc3_ = "x";
               _loc2_ = "";
            }
            if(_loc3_ != null)
            {
               _loc5_ += "<var n=\'" + _loc6_ + "\' t=\'" + _loc3_ + "\'><![CDATA[" + _loc2_ + "]]></var>";
            }
         }
         return _loc5_ + "</vars>";
      }
      
      private function checkRoomList() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.roomList == null || this.roomList.length == 0)
         {
            _loc1_ = false;
            this.errorTrace("The room list is empty!\nThe client API cannot function properly until the room list is populated.\nPlease consult the documentation for more infos.");
         }
         return _loc1_;
      }
      
      private function checkJoin() : Boolean
      {
         var _loc1_:Boolean = true;
         if(this.activeRoomId < 0)
         {
            _loc1_ = false;
            this.errorTrace("You haven\'t joined any rooms!\nIn order to interact with the server you should join at least one room.\nPlease consult the documentation for more infos.");
         }
         return _loc1_;
      }
      
      private function errorTrace(param1:String) : void
      {
         DebugUtility.debugTrace("****************************************************************");
         DebugUtility.debugTrace(param1);
         DebugUtility.debugTrace("****************************************************************");
      }
      
      private function handleHttpConnect(param1:HttpEvent) : void
      {
         this.handleSocketConnection(null);
         this.connected = true;
         this._connectingToBluebox = false;
         this.httpConnection.send("poll");
      }
      
      private function handleHttpClose(param1:HttpEvent) : void
      {
         this.debugMessage("HttpClose");
         this.initialize();
         var _loc2_:SFSEvent = new SFSEvent("onConnectionLost",{});
         dispatchEvent(_loc2_);
         this._connectingToBluebox = false;
      }
      
      private function handleHttpData(param1:HttpEvent) : void
      {
         var _loc5_:* = null;
         var _loc4_:int = 0;
         var _loc2_:String = param1.params.data as String;
         var _loc3_:Array = _loc2_.split("\n");
         if(_loc3_[0] != "")
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length - 1)
            {
               _loc5_ = _loc3_[_loc4_];
               if(_loc5_.length > 0)
               {
                  this.handleMessage(_loc5_);
               }
               _loc4_++;
            }
            this._numPollFailures = 0;
            if(this._httpPollSpeed > 0)
            {
               setTimeout(this.handleDelayedPoll,this._httpPollSpeed);
            }
            else
            {
               this.handleDelayedPoll();
            }
         }
      }
      
      private function handleDelayedPoll() : void
      {
         if(this.connected)
         {
            this.httpConnection.send("poll");
         }
      }
      
      private function handleHttpError(param1:HttpEvent) : void
      {
         this.errorTrace("HttpError type:" + param1.type + " message:" + param1.params.message);
         if(!this.connected && this._connectingToBluebox)
         {
            this.dispatchConnectionError(2,256,131072);
         }
         this._connectingToBluebox = false;
      }
      
      private function handleHttpPollError(param1:HttpEvent) : void
      {
         ++this._numPollFailures;
         this.errorTrace("HttpError type:" + param1.type + " numPollFailures:" + this._numPollFailures);
         if(this._numPollFailures <= 3)
         {
            setTimeout(this.handleDelayedPoll,this._numPollFailures * 1000);
         }
         else
         {
            this.errorTrace("Dispatching connection failure for too many poll failures");
            this.dispatchConnectionError(2,512,1048576);
         }
      }
      
      private function handleSocketConnection(param1:Event) : void
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc6_:* = null;
         var _loc4_:* = null;
         var _loc5_:* = null;
         if(!this._connectingToBluebox && this.socketConnection is SecureSocket)
         {
            _loc3_ = this.socketConnection as SecureSocket;
            if(_loc3_.serverCertificate == null)
            {
               this.debugMessage("SmartFoxClient.handleSocketConnection: skipping cert pin: serverCertificate is null");
            }
            else if(_loc3_.serverCertificate.encoded == null)
            {
               this.debugMessage("SmartFoxClient.handleSocketConnection: skipping cert pin: serverCertificate.encoded is null");
            }
            else
            {
               _loc2_ = Base64.encodeByteArray(_loc3_.serverCertificate.encoded);
               _loc6_ = MD5.hash(_loc2_);
               if(_loc6_ != "4ba64c9f0ada96f259ab19c96d237f64" && _loc6_ != "970b11a43e6de41d6377a986fde11026")
               {
                  this.dispatchConnectionError(1,256,262144);
                  return;
               }
            }
         }
         if(this.isIngressActive())
         {
            this.debugMessage("SmartFoxClient.handleSocketConnection: sending ApiOK");
            this.sysHandler.handleApiOK(null);
         }
         else
         {
            _loc4_ = {"t":"sys"};
            _loc5_ = "<ver v=\'" + this.majVersion.toString() + this.minVersion.toString() + this.subVersion.toString() + "\' />";
            this.debugMessage("SmartFoxClient.handleSocketConnection: sending verChk");
            this.send(_loc4_,"verChk",0,_loc5_);
         }
      }
      
      private function handleSocketDisconnection(param1:Event) : void
      {
         this.initialize();
         var _loc2_:SFSEvent = new SFSEvent("onConnectionLost",{});
         dispatchEvent(_loc2_);
      }
      
      private function handleSocketIOError(param1:IOErrorEvent) : void
      {
         this.errorTrace("handleIOError evt:" + param1);
         this.handleSocketConnectionFailure(param1);
      }
      
      private function handleSocketSecurityError(param1:SecurityErrorEvent) : void
      {
         this.errorTrace("Security Error:  " + param1.text);
         this.handleSocketConnectionFailure(param1);
      }
      
      private function handleSocketConnectionFailure(param1:ErrorEvent) : void
      {
         if(!this._socketConnectionFailureHandled)
         {
            this._socketConnectionFailureHandled = true;
            this.errorTrace("handleSocketConnectionFailure: manufacturer:" + Capabilities.manufacturer);
            if(!this.useSecureMode())
            {
               this.tryBlueBoxConnection(param1);
            }
            else if(!this.connected)
            {
               this.dispatchConnectionError(1,256,FailCode.getReasonFromEvent(param1));
            }
         }
      }
      
      private function tryBlueBoxConnection(param1:ErrorEvent) : void
      {
         var _loc3_:* = null;
         var _loc2_:int = 0;
         if(!this.connected)
         {
            if(!this._connectingToBluebox)
            {
               if(this.smartConnectAllowed && this.smartConnect)
               {
                  this.debugMessage("Trying BlueBox");
                  this.isHttpMode = true;
                  _loc3_ = this.getBlueBoxIpAddress();
                  _loc2_ = this.getBlueBoxPort();
                  this._connectingToBluebox = true;
                  this.httpConnection.connect(_loc3_,_loc2_,this.useSecureMode());
               }
               else
               {
                  this.debugMessage("tryBlueBoxConnection: Ignoring BlueBox connection attempt: smartConnectAllowed:" + this.smartConnectAllowed + " smartConnect:" + this.smartConnect);
                  this.dispatchConnectionError(1,256,131072);
               }
            }
            else
            {
               this.debugMessage("tryBlueBoxConnection: Blocking concurrent BlueBox connection attempt");
            }
         }
         else
         {
            this.debugMessage("[WARN] Connection error: " + param1.text);
         }
      }
      
      private function handleSocketData(param1:Event) : void
      {
         var §~~unused§:*;
         var _loc2_:int = 0;
         var _loc3_:int = int(this.socketConnection.bytesAvailable);
         while(true)
         {
            _loc3_--;
            if(_loc3_ < 0)
            {
               break;
            }
            _loc2_ = this.socketConnection.readByte();
            if(_loc2_ != 0)
            {
               this.byteBuffer.writeByte(_loc2_);
            }
            else
            {
               try
               {
                  this.handleMessage(this.byteBuffer.toString());
               }
               catch(err:Error)
               {
                  this.debugMessage("[WARN] Unexpected exception during handleMessage: " + err);
                  if(err.getStackTrace() != null)
                  {
                     this.debugMessage(err.getStackTrace());
                  }
               }
               this.byteBuffer.clear();
            }
         }
      }
      
      private function handleMessage(param1:String) : void
      {
         this.debugMessage("[ RECEIVED ]: " + param1 + ", (len: " + param1.length + ")");
         var _loc2_:String = param1.charAt(0);
         if(_loc2_ == "<")
         {
            this.xmlReceived(param1);
         }
         else if(_loc2_ == MSG_STR)
         {
            this.strReceived(param1);
         }
         else if(_loc2_ == "{")
         {
            this.jsonReceived(param1);
         }
      }
      
      private function dispatchConnectionError(param1:int, param2:int, param3:int) : void
      {
         var _loc5_:Object = null;
         _loc5_ = {};
         _loc5_.success = false;
         _loc5_.error = "I/O Error";
         _loc5_.failCode = FailCode.build(param1,param2,param3);
         var _loc4_:SFSEvent = new SFSEvent("onConnection",_loc5_);
         dispatchEvent(_loc4_);
      }
      
      private function getSocketIpAddress() : String
      {
         var _loc1_:String = this.ipAddress;
         if(this.socketConnection is SecureSocket)
         {
            _loc1_ = _loc1_.replace(/\.(stage|prod)\.animaljam\.internal$/,"-$1.animaljam.com");
            _loc1_ = "lb-" + _loc1_;
         }
         return _loc1_;
      }
      
      private function getBlueBoxIpAddress() : String
      {
         return this.blueBoxIpAddress != null ? this.blueBoxIpAddress : this.ipAddress;
      }
      
      private function getBlueBoxPort() : int
      {
         return this.blueBoxPort > 0 ? this.blueBoxPort : this.httpPort;
      }
   }
}

