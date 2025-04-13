package it.gotoandplay.smartfoxserver.handlers
{
   import flash.utils.getTimer;
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   import it.gotoandplay.smartfoxserver.util.Entities;
   import it.gotoandplay.smartfoxserver.util.FailCode;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class SysHandler implements IMessageHandler
   {
      private var sfs:SmartFoxClient;
      
      private var handlersTable:Array;
      
      public function SysHandler(param1:SmartFoxClient)
      {
         super();
         this.sfs = param1;
         handlersTable = [];
         handlersTable["apiOK"] = this.handleApiOK;
         handlersTable["apiKO"] = this.handleApiKO;
         handlersTable["logOK"] = this.handleLoginOk;
         handlersTable["logKO"] = this.handleLoginKo;
         handlersTable["logout"] = this.handleLogout;
         handlersTable["rmList"] = this.handleRoomList;
         handlersTable["uCount"] = this.handleUserCountChange;
         handlersTable["joinOK"] = this.handleJoinOk;
         handlersTable["joinKO"] = this.handleJoinKo;
         handlersTable["uER"] = this.handleUserEnterRoom;
         handlersTable["userGone"] = this.handleUserLeaveRoom;
         handlersTable["pubMsg"] = this.handlePublicMessage;
         handlersTable["prvMsg"] = this.handlePrivateMessage;
         handlersTable["dmnMsg"] = this.handleAdminMessage;
         handlersTable["modMsg"] = this.handleModMessage;
         handlersTable["dataObj"] = this.handleASObject;
         handlersTable["rVarsUpdate"] = this.handleRoomVarsUpdate;
         handlersTable["roomAdd"] = this.handleRoomAdded;
         handlersTable["roomDel"] = this.handleRoomDeleted;
         handlersTable["rndK"] = this.handleRandomKey;
         handlersTable["roundTripRes"] = this.handleRoundTripBench;
         handlersTable["uVarsUpdate"] = this.handleUserVarsUpdate;
         handlersTable["createRmKO"] = this.handleCreateRoomError;
         handlersTable["bList"] = this.handleBuddyList;
         handlersTable["bUpd"] = this.handleBuddyListUpdate;
         handlersTable["bAdd"] = this.handleBuddyAdded;
         handlersTable["roomB"] = this.handleBuddyRoom;
         handlersTable["leaveRoom"] = this.handleLeaveRoom;
         handlersTable["swSpec"] = this.handleSpectatorSwitched;
         handlersTable["bPrm"] = this.handleAddBuddyPermission;
         handlersTable["remB"] = this.handleRemoveBuddy;
         handlersTable["swPl"] = this.handlePlayerSwitched;
      }
      
      public function handleMessage(param1:Object, param2:String) : void
      {
         var _loc5_:XML = param1 as XML;
         var _loc4_:String = _loc5_.body.@action;
         var _loc3_:Function = handlersTable[_loc4_];
         if(_loc3_ != null)
         {
            _loc3_.apply(this,[param1]);
         }
         else
         {
            trace("Unknown sys command: " + _loc4_);
         }
      }
      
      public function handleApiOK(param1:Object) : void
      {
         sfs.isConnected = true;
         var _loc2_:SFSEvent = new SFSEvent("onConnection",{"success":true});
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleApiKO(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.success = false;
         _loc3_.error = "API are obsolete, please upgrade";
         _loc3_.failCode = FailCode.build(FailCode.getTypeFromConnectionMode(sfs.getConnectionMode()),512,524288);
         var _loc2_:SFSEvent = new SFSEvent("onConnection",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleLoginOk(param1:Object) : void
      {
         var _loc2_:int = int(param1.body.login.@id);
         var _loc4_:int = int(param1.body.login.@mod);
         var _loc5_:String = param1.body.login.@n;
         sfs.amIModerator = _loc4_ == 1;
         sfs.myUserId = _loc2_;
         sfs.myUserName = _loc5_;
         sfs.playerId = -1;
         var _loc6_:Object = {};
         _loc6_.success = true;
         _loc6_.name = _loc5_;
         _loc6_.error = "";
         var _loc3_:SFSEvent = new SFSEvent("onLogin",_loc6_);
         sfs.dispatchEvent(_loc3_);
      }
      
      public function handleLoginKo(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.success = false;
         _loc3_.error = param1.body.login.@e;
         var _loc2_:SFSEvent = new SFSEvent("onLogin",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleLogout(param1:Object) : void
      {
         sfs.__logout();
         var _loc2_:SFSEvent = new SFSEvent("onLogout",{});
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleRoomList(param1:Object) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Room = null;
         var _loc4_:Room = null;
         var _loc6_:Array = sfs.getAllRooms();
         var _loc7_:Array = [];
         for each(var _loc3_ in param1.body.rmList.rm)
         {
            _loc8_ = int(_loc3_.@id);
            _loc9_ = new Room(_loc8_,_loc3_.n,int(_loc3_.@maxu),int(_loc3_.@maxs),_loc3_.@temp == "1",_loc3_.@game == "1",_loc3_.@priv == "1",_loc3_.@lmb == "1",int(_loc3_.@ucnt),int(_loc3_.@scnt));
            if(_loc3_.vars.toString().length > 0)
            {
               populateVariables(_loc9_.getVariables(),_loc3_);
            }
            _loc4_ = _loc6_[_loc8_];
            if(_loc4_ != null)
            {
               _loc9_.setVariables(_loc4_.getVariables());
               _loc9_.setUserList(_loc4_.getUserList());
            }
            _loc7_[_loc8_] = _loc9_;
         }
         sfs.setRoomList(_loc7_);
         var _loc5_:Object = {};
         _loc5_.roomList = _loc7_;
         var _loc2_:SFSEvent = new SFSEvent("onRoomListUpdate",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleUserCountChange(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc3_:SFSEvent = null;
         var _loc2_:int = int(param1.body.@u);
         var _loc5_:int = int(param1.body.@s);
         var _loc6_:int = int(param1.body.@r);
         var _loc7_:Room = sfs.getAllRooms()[_loc6_];
         if(_loc7_ != null)
         {
            _loc7_.setUserCount(_loc2_);
            _loc7_.setSpectatorCount(_loc5_);
            _loc4_ = {};
            _loc4_.room = _loc7_;
            _loc3_ = new SFSEvent("onUserCountChange",_loc4_);
            sfs.dispatchEvent(_loc3_);
         }
      }
      
      public function handleJoinOk(param1:Object) : void
      {
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc4_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc5_:int = 0;
         var _loc14_:User = null;
         var _loc8_:int = int(param1.body.@r);
         var _loc3_:XMLList = param1.body;
         var _loc10_:XMLList = param1.body.uLs.u;
         var _loc15_:int = int(param1.body.pid.@id);
         sfs.activeRoomId = _loc8_;
         var _loc9_:Room = sfs.getRoom(_loc8_);
         _loc9_.clearUserList();
         sfs.playerId = _loc15_;
         _loc9_.setMyPlayerIndex(_loc15_);
         if(_loc3_.vars.toString().length > 0)
         {
         }
         _loc9_.clearVariables();
         populateVariables(_loc9_.getVariables(),_loc3_);
         for each(var _loc11_ in _loc10_)
         {
            _loc12_ = _loc11_.n;
            _loc13_ = int(_loc11_.@i);
            _loc4_ = _loc11_.@m == "1" ? true : false;
            _loc7_ = _loc11_.@s == "1" ? true : false;
            _loc5_ = int(_loc11_.@p == null ? -1 : int(_loc11_.@p));
            _loc14_ = new User(_loc13_,_loc12_);
            _loc14_.setModerator(_loc4_);
            _loc14_.setIsSpectator(_loc7_);
            _loc14_.setPlayerId(_loc5_);
            if(_loc11_.vars.toString().length > 0)
            {
               populateVariables(_loc14_.getVariables(),_loc11_);
            }
            _loc9_.addUser(_loc14_,_loc13_);
         }
         sfs.changingRoom = false;
         var _loc6_:Object = {};
         _loc6_.room = _loc9_;
         var _loc2_:SFSEvent = new SFSEvent("onJoinRoom",_loc6_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleJoinKo(param1:Object) : void
      {
         sfs.changingRoom = false;
         var _loc3_:Object = {};
         _loc3_.error = param1.body.error.@msg;
         var _loc2_:SFSEvent = new SFSEvent("onJoinRoomError",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleUserEnterRoom(param1:Object) : void
      {
         var _loc10_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.u.@i);
         var _loc11_:String = param1.body.u.n;
         var _loc3_:* = param1.body.u.@m == "1";
         var _loc9_:* = param1.body.u.@s == "1";
         var _loc7_:int = int(param1.body.u.@p != null ? int(param1.body.u.@p) : -1);
         var _loc4_:XMLList = param1.body.u.vars["var"];
         var _loc12_:Room = sfs.getRoom(_loc10_);
         var _loc5_:User = new User(_loc6_,_loc11_);
         _loc5_.setModerator(_loc3_);
         _loc5_.setIsSpectator(_loc9_);
         _loc5_.setPlayerId(_loc7_);
         _loc12_.addUser(_loc5_,_loc6_);
         if(param1.body.u.vars.toString().length > 0)
         {
            populateVariables(_loc5_.getVariables(),param1.body.u);
         }
         var _loc8_:Object = {};
         _loc8_.roomId = _loc10_;
         _loc8_.user = _loc5_;
         var _loc2_:SFSEvent = new SFSEvent("onUserEnterRoom",_loc8_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleUserLeaveRoom(param1:Object) : void
      {
         var _loc5_:int = int(param1.body.user.@id);
         var _loc7_:int = int(param1.body.@r);
         var _loc6_:Room = sfs.getRoom(_loc7_);
         if(_loc6_ == null)
         {
            trace("WARN - Leave Room not found, id: " + _loc7_);
            return;
         }
         var _loc3_:String = _loc6_.getUser(_loc5_).getName();
         _loc6_.removeUser(_loc5_);
         var _loc4_:Object = {};
         _loc4_.roomId = _loc7_;
         _loc4_.userId = _loc5_;
         _loc4_.userName = _loc3_;
         var _loc2_:SFSEvent = new SFSEvent("onUserLeaveRoom",_loc4_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handlePublicMessage(param1:Object) : void
      {
         var _loc7_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.user.@id);
         var _loc4_:String = param1.body.txt;
         var _loc3_:User = sfs.getRoom(_loc7_).getUser(_loc6_);
         var _loc5_:Object = {};
         _loc5_.message = Entities.decodeEntities(_loc4_);
         _loc5_.sender = _loc3_;
         _loc5_.roomId = _loc7_;
         var _loc2_:SFSEvent = new SFSEvent("onPublicMessage",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handlePrivateMessage(param1:Object) : void
      {
         var _loc8_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.user.@id);
         var _loc4_:String = param1.body.txt;
         var _loc7_:Room = sfs.getRoom(_loc8_);
         var _loc3_:User = null;
         if(_loc7_ != null)
         {
            _loc3_ = _loc7_.getUser(_loc6_);
         }
         var _loc5_:Object = {};
         _loc5_.message = Entities.decodeEntities(_loc4_);
         _loc5_.sender = _loc3_;
         _loc5_.roomId = _loc8_;
         _loc5_.userId = _loc6_;
         var _loc2_:SFSEvent = new SFSEvent("onPrivateMessage",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleAdminMessage(param1:Object) : void
      {
         var _loc6_:int = int(param1.body.@r);
         var _loc5_:int = int(param1.body.user.@id);
         var _loc3_:String = param1.body.txt;
         var _loc4_:Object = {};
         _loc4_.message = Entities.decodeEntities(_loc3_);
         var _loc2_:SFSEvent = new SFSEvent("onAdminMessage",_loc4_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleModMessage(param1:Object) : void
      {
         var _loc7_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.user.@id);
         var _loc4_:String = param1.body.txt;
         var _loc3_:User = null;
         var _loc8_:Room = sfs.getRoom(_loc7_);
         if(_loc8_ != null)
         {
            _loc3_ = _loc8_.getUser(_loc6_);
         }
         var _loc5_:Object = {};
         _loc5_.message = Entities.decodeEntities(_loc4_);
         _loc5_.sender = _loc3_;
         var _loc2_:SFSEvent = new SFSEvent("onModMessage",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleASObject(param1:Object) : void
      {
         var _loc8_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.user.@id);
         var _loc7_:String = param1.body.dataObj;
         var _loc3_:User = sfs.getRoom(_loc8_).getUser(_loc6_);
         var _loc4_:Object = ObjectSerializer.getInstance().deserialize(new XML(_loc7_));
         var _loc5_:Object = {};
         _loc5_.obj = _loc4_;
         _loc5_.sender = _loc3_;
         var _loc2_:SFSEvent = new SFSEvent("onObjectReceived",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleRoomVarsUpdate(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc7_:int = int(param1.body.@r);
         var _loc5_:int = int(param1.body.user.@id);
         var _loc6_:Room = sfs.getRoom(_loc7_);
         var _loc3_:Array = [];
         if(_loc6_ != null)
         {
            if(param1.body.vars.toString().length > 0)
            {
               populateVariables(_loc6_.getVariables(),param1.body,_loc3_);
            }
            _loc4_ = {};
            _loc4_.room = _loc6_;
            _loc4_.changedVars = _loc3_;
            _loc2_ = new SFSEvent("onRoomVariablesUpdate",_loc4_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      public function handleUserVarsUpdate(param1:Object) : void
      {
         var _loc3_:Array = null;
         var _loc5_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc6_:int = int(param1.body.user.@id);
         var _loc4_:User = null;
         var _loc8_:* = null;
         if(param1.body.vars.toString().length > 0)
         {
            for each(var _loc7_ in sfs.getAllRooms())
            {
               _loc4_ = _loc7_.getUser(_loc6_);
               if(_loc4_ != null)
               {
                  if(_loc8_ == null)
                  {
                     _loc8_ = _loc4_;
                  }
                  _loc3_ = [];
                  populateVariables(_loc4_.getVariables(),param1.body,_loc3_);
               }
            }
            _loc5_ = {};
            _loc5_.user = _loc8_;
            _loc5_.changedVars = _loc3_;
            _loc2_ = new SFSEvent("onUserVariablesUpdate",_loc5_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handleRoomAdded(param1:Object) : void
      {
         var _loc6_:int = int(param1.body.rm.@id);
         var _loc8_:String = param1.body.rm.name;
         var _loc5_:int = int(param1.body.rm.@max);
         var _loc2_:int = int(param1.body.rm.@spec);
         var _loc9_:Boolean = param1.body.rm.@temp == "1" ? true : false;
         var _loc13_:Boolean = param1.body.rm.@game == "1" ? true : false;
         var _loc12_:Boolean = param1.body.rm.@priv == "1" ? true : false;
         var _loc10_:Boolean = param1.body.rm.@limbo == "1" ? true : false;
         var _loc3_:Room = new Room(_loc6_,_loc8_,_loc5_,_loc2_,_loc9_,_loc13_,_loc12_,_loc10_);
         var _loc11_:Array = sfs.getAllRooms();
         _loc11_[_loc6_] = _loc3_;
         if(param1.body.rm.vars.toString().length > 0)
         {
            populateVariables(_loc3_.getVariables(),param1.body.rm);
         }
         var _loc7_:Object = {};
         _loc7_.room = _loc3_;
         var _loc4_:SFSEvent = new SFSEvent("onRoomAdded",_loc7_);
         sfs.dispatchEvent(_loc4_);
      }
      
      private function handleRoomDeleted(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc4_:int = int(param1.body.rm.@id);
         var _loc5_:Array = sfs.getAllRooms();
         if(_loc5_[_loc4_] != null)
         {
            _loc3_ = {};
            _loc3_.room = _loc5_[_loc4_];
            delete _loc5_[_loc4_];
            _loc2_ = new SFSEvent("onRoomDeleted",_loc3_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handleRandomKey(param1:Object) : void
      {
         var _loc4_:String = param1.body.k.toString();
         var _loc3_:Object = {};
         _loc3_.key = _loc4_;
         var _loc2_:SFSEvent = new SFSEvent("onRandomKey",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleRoundTripBench(param1:Object) : void
      {
         var _loc4_:int = getTimer();
         var _loc2_:int = _loc4_ - sfs.getBenchStartTime();
         var _loc5_:Object = {};
         _loc5_.elapsed = _loc2_;
         var _loc3_:SFSEvent = new SFSEvent("onRoundTripResponse",_loc5_);
         sfs.dispatchEvent(_loc3_);
      }
      
      private function handleCreateRoomError(param1:Object) : void
      {
         var _loc3_:String = param1.body.room.@e;
         var _loc4_:Object = {};
         _loc4_.error = _loc3_;
         var _loc2_:SFSEvent = new SFSEvent("onCreateRoomError",_loc4_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleBuddyList(param1:Object) : void
      {
         var _loc10_:Object = null;
         var _loc5_:XMLList = null;
         var _loc7_:XMLList = param1.body.bList;
         var _loc8_:XMLList = param1.body.mv;
         var _loc9_:Object = {};
         var _loc2_:SFSEvent = null;
         if(_loc8_ != null && _loc8_.toString().length > 0)
         {
            for each(var _loc4_ in _loc8_.v)
            {
               sfs.myBuddyVars[_loc4_.@n.toString()] = _loc4_.toString();
            }
         }
         if(_loc7_ != null && _loc7_.b.length != null)
         {
            if(_loc7_.toString().length > 0)
            {
               for each(var _loc3_ in _loc7_.b)
               {
                  _loc10_ = {};
                  _loc10_.isOnline = _loc3_.@s == "1" ? true : false;
                  _loc10_.name = _loc3_.n.toString();
                  _loc10_.id = _loc3_.@i;
                  _loc10_.isBlocked = _loc3_.@x == "1" ? true : false;
                  _loc10_.variables = {};
                  _loc5_ = _loc3_.vs;
                  if(_loc5_.toString().length > 0)
                  {
                     for each(var _loc6_ in _loc5_.v)
                     {
                        _loc10_.variables[_loc6_.@n.toString()] = _loc6_.toString();
                     }
                  }
                  sfs.buddyList.push(_loc10_);
               }
            }
            _loc9_.list = sfs.buddyList;
            _loc2_ = new SFSEvent("onBuddyList",_loc9_);
            sfs.dispatchEvent(_loc2_);
         }
         else
         {
            _loc9_.error = param1.body.err.toString();
            _loc2_ = new SFSEvent("onBuddyListError",_loc9_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handleBuddyListUpdate(param1:Object) : void
      {
         var _loc9_:Object = null;
         var _loc3_:XMLList = null;
         var _loc8_:Object = null;
         var _loc4_:Boolean = false;
         var _loc7_:Object = {};
         var _loc2_:SFSEvent = null;
         if(param1.body.err.toString().length > 0)
         {
            _loc7_.error = param1.body.err.toString();
            _loc2_ = new SFSEvent("onBuddyListError",_loc7_);
            sfs.dispatchEvent(_loc2_);
            return;
         }
         if(param1.body.b != null)
         {
            _loc9_ = {};
            _loc9_.isOnline = param1.body.b.@s == "1" ? true : false;
            _loc9_.name = param1.body.b.n.toString();
            _loc9_.id = param1.body.b.@i;
            _loc9_.isBlocked = param1.body.b.@x == "1" ? true : false;
            _loc3_ = param1.body.b.vs;
            _loc8_ = null;
            _loc4_ = false;
            for(var _loc6_ in sfs.buddyList)
            {
               _loc8_ = sfs.buddyList[_loc6_];
               if(_loc8_.name == _loc9_.name)
               {
                  sfs.buddyList[_loc6_] = _loc9_;
                  _loc9_.isBlocked = _loc8_.isBlocked;
                  _loc9_.variables = _loc8_.variables;
                  if(_loc3_.toString().length > 0)
                  {
                     for each(var _loc5_ in _loc3_.v)
                     {
                        _loc9_.variables[_loc5_.@n.toString()] = _loc5_.toString();
                     }
                  }
                  _loc4_ = true;
                  break;
               }
            }
            if(_loc4_)
            {
               _loc7_.buddy = _loc9_;
               _loc2_ = new SFSEvent("onBuddyListUpdate",_loc7_);
               sfs.dispatchEvent(_loc2_);
            }
         }
      }
      
      private function handleAddBuddyPermission(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.sender = param1.body.n.toString();
         _loc3_.message = "";
         if(param1.body.txt != undefined)
         {
            _loc3_.message = Entities.decodeEntities(param1.body.txt);
         }
         var _loc2_:SFSEvent = new SFSEvent("onBuddyPermissionRequest",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleBuddyAdded(param1:Object) : void
      {
         var _loc6_:Object = {};
         _loc6_.isOnline = param1.body.b.@s == "1" ? true : false;
         _loc6_.name = param1.body.b.n.toString();
         _loc6_.id = param1.body.b.@i;
         _loc6_.isBlocked = param1.body.b.@x == "1" ? true : false;
         _loc6_.variables = {};
         var _loc3_:XMLList = param1.body.b.vs;
         if(_loc3_.toString().length > 0)
         {
            for each(var _loc4_ in _loc3_.v)
            {
               _loc6_.variables[_loc4_.@n.toString()] = _loc4_.toString();
            }
         }
         sfs.buddyList.push(_loc6_);
         var _loc5_:Object = {};
         _loc5_.list = sfs.buddyList;
         var _loc2_:SFSEvent = new SFSEvent("onBuddyList",_loc5_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleRemoveBuddy(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc4_:String = param1.body.n.toString();
         var _loc6_:Object = null;
         for(var _loc3_ in sfs.buddyList)
         {
            _loc6_ = sfs.buddyList[_loc3_];
            if(_loc6_.name == _loc4_)
            {
               delete sfs.buddyList[_loc3_];
               _loc5_ = {};
               _loc5_.list = sfs.buddyList;
               _loc2_ = new SFSEvent("onBuddyList",_loc5_);
               sfs.dispatchEvent(_loc2_);
               break;
            }
         }
      }
      
      private function handleBuddyRoom(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc2_:String = param1.body.br.@r;
         var _loc4_:Array = _loc2_.split(",");
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc4_[_loc5_] = int(_loc4_[_loc5_]);
            _loc5_++;
         }
         var _loc6_:Object = {};
         _loc6_.idList = _loc4_;
         var _loc3_:SFSEvent = new SFSEvent("onBuddyRoom",_loc6_);
         sfs.dispatchEvent(_loc3_);
      }
      
      private function handleLeaveRoom(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc3_:int = int(param1.body.rm.@id);
         var _loc5_:Array = sfs.getAllRooms();
         if(_loc5_[_loc3_])
         {
            _loc4_ = {};
            _loc4_.roomId = _loc3_;
            _loc2_ = new SFSEvent("onRoomLeft",_loc4_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handleSpectatorSwitched(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc6_:User = null;
         var _loc3_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc7_:int = int(param1.body.@r);
         var _loc8_:int = int(param1.body.pid.@id);
         var _loc4_:Room = sfs.getRoom(_loc7_);
         if(_loc8_ > 0)
         {
            _loc4_.setUserCount(_loc4_.getUserCount() + 1);
            _loc4_.setSpectatorCount(_loc4_.getSpectatorCount() - 1);
         }
         if(param1.body.pid.@u != undefined)
         {
            _loc5_ = int(param1.body.pid.@u);
            _loc6_ = _loc4_.getUser(_loc5_);
            if(_loc6_ != null)
            {
               _loc6_.setIsSpectator(false);
               _loc6_.setPlayerId(_loc8_);
            }
         }
         else
         {
            sfs.playerId = _loc8_;
            _loc3_ = {};
            _loc3_.success = sfs.playerId > 0;
            _loc3_.newId = sfs.playerId;
            _loc3_.room = _loc4_;
            _loc2_ = new SFSEvent("onSpectatorSwitched",_loc3_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handlePlayerSwitched(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc7_:User = null;
         var _loc4_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc8_:int = int(param1.body.@r);
         var _loc9_:int = int(param1.body.pid.@id);
         var _loc3_:* = param1.body.pid.@u == undefined;
         var _loc5_:Room = sfs.getRoom(_loc8_);
         if(_loc9_ == -1)
         {
            _loc5_.setUserCount(_loc5_.getUserCount() - 1);
            _loc5_.setSpectatorCount(_loc5_.getSpectatorCount() + 1);
            if(!_loc3_)
            {
               _loc6_ = int(param1.body.pid.@u);
               _loc7_ = _loc5_.getUser(_loc6_);
               if(_loc7_ != null)
               {
                  _loc7_.setIsSpectator(true);
                  _loc7_.setPlayerId(_loc9_);
               }
            }
         }
         if(_loc3_)
         {
            sfs.playerId = _loc9_;
            _loc4_ = {};
            _loc4_.success = _loc9_ == -1;
            _loc4_.newId = _loc9_;
            _loc4_.room = _loc5_;
            _loc2_ = new SFSEvent("onPlayerSwitched",_loc4_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function populateVariables(param1:Array, param2:Object, param3:Array = null) : void
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         for each(var _loc5_ in param2.vars["var"])
         {
            _loc4_ = _loc5_.@n;
            _loc6_ = _loc5_.@t;
            _loc7_ = _loc5_;
            if(param3 != null)
            {
               param3.push(_loc4_);
               param3[_loc4_] = true;
            }
            if(_loc6_ == "b")
            {
               param1[_loc4_] = _loc7_ == "1" ? true : false;
            }
            else if(_loc6_ == "n")
            {
               param1[_loc4_] = Number(_loc7_);
            }
            else if(_loc6_ == "s")
            {
               param1[_loc4_] = _loc7_;
            }
            else if(_loc6_ == "x")
            {
               delete param1[_loc4_];
            }
         }
      }
      
      public function dispatchDisconnection() : void
      {
         var _loc1_:SFSEvent = new SFSEvent("onConnectionLost",null);
         sfs.dispatchEvent(_loc1_);
      }
   }
}

