package room
{
   import achievement.AchievementXtCommManager;
   import avatar.AvatarManager;
   import buddy.BuddyManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.client.SFRoom;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import game.MinigameManager;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.WelcomeToCarnival;
   import loadProgress.LoadProgress;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestXtCommManager;
   
   public class RoomXtCommManager
   {
      public static const RT_PARAM_GET_SHARD_FROM_DEN:int = -1;
      
      public static const RT_PARAM_NEW_REGISTRANT_EXPERIENCE_REDIRECT:int = -2;
      
      public static const RT_PARAM_SEEK_BUDDY:int = -3;
      
      public static const RT_PARAM_PRIVATE_PARTY:int = -4;
      
      public static var roomCountResponseCallback:Function;
      
      public static var isSwitching:Boolean;
      
      public static var _joinRoomName:String;
      
      public static var _seekBuddyName:String;
      
      public static var _loadingNewRoom:Boolean;
      
      private static var _denJoinPending:Boolean;
      
      private static var _waitForLangPack:Boolean;
      
      private static var _savedRPData:Object;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _rfCallback:Function;
      
      private static var _roomDefs:Object;
      
      public static var _welcomePopup:WelcomeToCarnival;
      
      public static var _joiningBuddyCrossNode:Boolean;
      
      public function RoomXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _joiningBuddyCrossNode = false;
         _denJoinPending = false;
         _waitForLangPack = false;
         _savedRPData = null;
         _roomMgr = RoomManagerWorld.instance;
         XtReplyDemuxer.addModule(handleXtReply,"r");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
         roomCountResponseCallback = null;
      }
      
      public static function sendRoomCountRequest() : void
      {
         gMainFrame.server.setXtObject_Str("rc",[],true,false,false);
      }
      
      public static function sendMoreShardRequest() : void
      {
         gMainFrame.server.setXtObject_Str("rm",[]);
      }
      
      public static function sendRoomFFMRequest(param1:Function) : void
      {
         _rfCallback = param1;
         gMainFrame.server.setXtObject_Str("rf",[]);
      }
      
      public static function sendNonDenRoomJoinRequest(param1:String) : void
      {
         sendRoomJoinRequestFull(param1);
      }
      
      public static function set waitForLangPack(param1:Boolean) : void
      {
         _waitForLangPack = param1;
      }
      
      public static function sendRoomJoinRequest(param1:String, param2:int = -1, param3:Boolean = false, param4:Boolean = false, param5:Boolean = true, param6:RoomJoinType = null) : void
      {
         if(param1.slice(0,3) == "den" && !param3)
         {
            DenXtCommManager.requestDenJoinFull(param1,param2,param4,param5);
         }
         else
         {
            sendRoomJoinRequestFull(param1,param4,param5,param6);
         }
      }
      
      private static function sendRoomJoinRequestFull(param1:String, param2:Boolean = false, param3:Boolean = true, param4:RoomJoinType = null) : void
      {
         if(_loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING rj request to room=" + param1 + " because user is already joining a new room!");
            return;
         }
         if(isSwitching)
         {
            DarkenManager.showLoadingSpiral(false);
            return;
         }
         if(gMainFrame.server.getCurrentRoom())
         {
            if(param1 == gMainFrame.server.getCurrentRoomName())
            {
               trace("WARNING: User is already in this room!");
               SBTracker.trackPageview("/game/play/error/rjRequestTriedToJoinAlreadyInRoom/",-1,1);
               DarkenManager.showLoadingSpiral(false);
               return;
            }
         }
         AvatarManager.joiningNewRoom = true;
         _loadingNewRoom = true;
         if(param4 == null)
         {
            param4 = RoomJoinType.AUTO;
         }
         var _loc6_:int = int(param1.indexOf("@"));
         if(_loc6_ < 0)
         {
            _joinRoomName = param1;
         }
         else
         {
            _joinRoomName = param1.substring(0,_loc6_);
         }
         if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
         {
            SBTracker.trackPageview("/game/play/loading/changeRooms");
         }
         var _loc7_:String = param3 ? "1" : "0";
         var _loc5_:Boolean = param2 || _roomMgr.forceInvisMode;
         if(param1 == null || param1 == "")
         {
            DebugUtility.debugTrace("ERROR: tried to join empty string or null room! rjNameOrId:" + param1 + " joinType:" + param4 + " forceInvisNow:" + _loc5_ + " confirmLanguageChange:" + param3 + " _joinRoomName:" + _joinRoomName);
            SBTracker.trackPageview("/game/play/error/rjRequestTriedToJoinNullOrEmptyStringRoom/",-1,1);
            DarkenManager.showLoadingSpiral(false);
            return;
         }
         if(!_loc5_)
         {
            gMainFrame.server.setXtObject_Str("rj",[param1,_loc7_,"0",param4]);
         }
         else
         {
            gMainFrame.server.setXtObject_Str("rj",[param1,_loc7_,"1",param4]);
            _roomMgr.forceInvisMode = true;
         }
      }
      
      public static function sendRoomLeaveRequest(param1:int, param2:Boolean = false) : void
      {
         gMainFrame.server.setXtObject_Str("rl",[param1],true,param2);
         gMainFrame.server.handleSubRoomExit();
      }
      
      public static function denJoinRequested(param1:String) : void
      {
         _loadingNewRoom = true;
         _joinRoomName = param1;
         _denJoinPending = true;
      }
      
      public static function get loadingNewRoom() : Boolean
      {
         return _loadingNewRoom;
      }
      
      public static function getRoomDef(param1:int) : Object
      {
         return _roomDefs[param1];
      }
      
      public static function set loadingNewRoom(param1:Boolean) : void
      {
         _loadingNewRoom = param1;
      }
      
      public static function startRoomLoadIfReady() : void
      {
         _waitForLangPack = false;
         if(_savedRPData)
         {
            roomPropertiesResponse(_savedRPData);
            _savedRPData = null;
         }
      }
      
      public static function roomDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc3_:Object = null;
         var _loc5_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1011] = null;
         var _loc4_:Object = {};
         for each(var _loc2_ in param1.def)
         {
            _loc3_ = {
               "defId":int(_loc2_.id),
               "pathName":_loc2_.pathName,
               "enviroType":int(_loc2_.type),
               "isPlatformer":_loc2_.isPlatformer == "1"
            };
            _loc4_[_loc3_.defId] = _loc3_;
         }
         _roomDefs = _loc4_;
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "rj":
               roomJoinResponse(_loc2_);
               break;
            case "rp":
               roomPropertiesResponse(_loc2_);
               break;
            case "rc":
               roomCountResponse(_loc2_);
               break;
            case "rf":
               roomFFMResponse(_loc2_);
               break;
            case "rl":
               roomListResponse(_loc2_);
               break;
            case "rm":
               roomMoreResponse(_loc2_);
               break;
            default:
               throw new Error("RoomXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function roomJoinResponse(param1:Object) : void
      {
         var _loc4_:SFRoom = null;
         var _loc6_:String = null;
         var _loc5_:Array = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:String = null;
         var _loc12_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 2;
         if(param1[_loc10_++] == "1")
         {
            _joiningBuddyCrossNode = false;
            _loc4_ = new SFRoom();
            _loc4_.name = param1[_loc10_++];
            _loc4_.id = int(param1[_loc10_++]);
            _loc4_.users = int(param1[_loc10_++]);
            _loc4_.maxUsers = int(param1[_loc10_++]);
            _loc4_.spectators = int(param1[_loc10_++]);
            _loc4_.maxSpectators = int(param1[_loc10_++]);
            _loc4_.isPrivate = param1[_loc10_++] == "1";
            _loc4_.isGame = param1[_loc10_++] == "1";
            _loc4_.isLimbo = param1[_loc10_++] == "1";
            _loc4_.isTemp = param1[_loc10_++] == "1";
            _loc4_.isSubRoom = param1[_loc10_++] == "1";
            _loc6_ = param1[_loc10_++];
            if(_loc4_.name.indexOf("pparty") == 0)
            {
               _loc5_ = _loc6_.split("|");
               _loc6_ = LocalizationManager.translateIdOnly(_loc5_[0]) + " " + LocalizationManager.translateIdOnly(_loc5_[1]) + " " + LocalizationManager.translateIdOnly(_loc5_[2]);
            }
            _loc8_ = int(param1[_loc10_++]);
            _loc7_ = int(param1[_loc10_++]);
            if(gMainFrame.userInfo.myPerUserAvId != _loc7_)
            {
               gMainFrame.userInfo.myPerUserAvId = _loc7_;
               if(AvatarManager.isMyUserInCustomAdventureHosting())
               {
                  gMainFrame.userInfo.playerAvatarInfo.type = -1;
               }
            }
            PetManager.myActivePetInvId = int(param1[_loc10_++]);
            _loc11_ = int(param1[_loc10_++]);
            _roomMgr.customMusicDef = int(param1[_loc10_++]);
            if(param1.hasOwnProperty(_loc10_))
            {
               _loc3_ = int(param1[_loc10_++]);
               _roomMgr.shardId = _loc3_;
            }
            if(_loc11_ != LocalizationManager.currentLanguage && !MinigameManager.inInRoomGame())
            {
               LocalizationXtCommManager.requestLocalizationPack(_loc11_);
            }
            gMainFrame.server.handleRoomJoin(_loc4_);
            _roomMgr.forceInvisMode = false;
            if(!_loc4_.isGame || _loc4_.name.indexOf("den") == 0 || _loc4_.name.indexOf("party") == 0 || _loc4_.name.indexOf("pparty") == 0 || _loc4_.name.indexOf("staging") == 0)
            {
               GuiManager.setRoomNameDisplay(_loc6_,_loc8_);
            }
            if(_loc4_.name.indexOf("venue_carnival") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(343) < 1)
               {
                  _welcomePopup = new WelcomeToCarnival();
                  _welcomePopup.init();
                  DarkenManager.showLoadingSpiral(true);
                  AchievementXtCommManager.requestSetUserVar(343,1);
               }
            }
            else if(_loc4_.name.indexOf("room_diamonds") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(368) < 1)
               {
                  GuiManager.openDiamondShopInfo();
                  AchievementXtCommManager.requestSetUserVar(368,1);
               }
            }
            delete gMainFrame.clientInfo.autoStartRoom;
            QuestXtCommManager.roomJoined(_loc4_.name);
         }
         else
         {
            if(_joiningBuddyCrossNode)
            {
               _joiningBuddyCrossNode = false;
               _loadingNewRoom = false;
               sendRoomJoinRequest(gMainFrame.clientInfo.startUpRoom + "#-1");
               return;
            }
            _loc2_ = param1[_loc10_++];
            if(_loc2_ == "N")
            {
               _loc12_ = param1[_loc10_++];
               if(_loc12_ == "null")
               {
                  new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14834),false);
                  AvatarManager.joiningNewRoom = false;
                  _denJoinPending = false;
                  _seekBuddyName = null;
                  return;
               }
               if(_denJoinPending)
               {
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  gMainFrame.clientInfo.autoStartRoomShardId = -1;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(_loc12_))
                  {
                     throw new Error("got join room response saying to switch server nodes, but was already on that node!");
                  }
               }
               else if(_seekBuddyName)
               {
                  gMainFrame.clientInfo.autoStartRoom = _seekBuddyName;
                  gMainFrame.clientInfo.autoStartRoomShardId = -3;
                  if(!gMainFrame.switchServersIfNeeded(_loc12_))
                  {
                     new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
                     AvatarManager.joiningNewRoom = false;
                     _denJoinPending = false;
                     _seekBuddyName = null;
                     return;
                  }
               }
               else
               {
                  if(_joinRoomName.indexOf("#") < 0)
                  {
                     throw new Error("join room request for sfs room:" + _joinRoomName + " somehow is on another server node:" + _loc12_ + " (current node:" + gMainFrame.server.serverIp + ")?!");
                  }
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  _loc9_ = int(_joinRoomName.substr(_joinRoomName.indexOf("#") + 1));
                  if(_loc9_ == -1)
                  {
                     _loc9_ = -2;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = _loc9_;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(_loc12_))
                  {
                     new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
                     AvatarManager.joiningNewRoom = false;
                     _denJoinPending = false;
                     _seekBuddyName = null;
                     return;
                  }
               }
               _roomMgr.clearLastGoodRoomForServerSwitch();
            }
            else if(_loc2_.indexOf("DJE") == 0)
            {
               if(_loc2_.charAt(3) == "C")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,{
                     "switchRooms":false,
                     "switchDens":true
                  });
               }
               else if(_loc2_.charAt(3) == "E")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,{
                     "switchRooms":true,
                     "switchDens":false
                  });
               }
               else if(_loc2_.charAt(3) == "K")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14837),true,GuiManager.switchToOceanAnimal,{
                     "switchRooms":false,
                     "switchDens":false
                  });
               }
            }
            else if(_loc2_ == "BSJ" || _loc2_ == "BSJP")
            {
               _loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14838));
            }
            else if(_loc2_ == "SSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14839));
            }
            else if(_loc2_ == "CSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14840));
            }
            else if(_loc2_ == "QSJL")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14841));
            }
            else if(_loc2_ == "BQSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14842));
            }
            else if(_loc2_ == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14843));
            }
            else if(_loc2_ == "RQJF_NL")
            {
               _loadingNewRoom = false;
               if(!BuddyManager.joinBuddyInQuest())
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14843));
               }
            }
            else if(_loc2_ == "SQQJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14844));
            }
            else if(_loc2_ != "LC")
            {
               gMainFrame.server.handleRoomJoinError(_loc2_,param1[_loc10_]);
            }
            _loadingNewRoom = false;
         }
         AvatarManager.joiningNewRoom = false;
         _denJoinPending = false;
         _seekBuddyName = null;
      }
      
      private static function roomPropertiesResponse(param1:Object) : void
      {
         if(_waitForLangPack)
         {
            _savedRPData = param1;
            return;
         }
         _roomMgr.loadRoom(param1[2],int(param1[3]),int(param1[4]),int(param1[5]),int(param1[6]),int(param1[7]),param1[8] != null && param1[8] != "" ? JSON.parse(param1[8]) : null);
         AvatarManager.finishHandleAvatarCreate();
      }
      
      private static function roomCountResponse(param1:Object) : void
      {
         if(roomCountResponseCallback != null)
         {
            roomCountResponseCallback(param1);
         }
      }
      
      private static function roomMoreResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(!isNaN(Number(param1[2])))
         {
            _loc2_ = int(param1[2]);
            if(_loc2_ <= 0)
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14847),false);
               return;
            }
         }
         GamePlay(gMainFrame.gamePlay).showServerSelectorMore(param1);
      }
      
      private static function roomFFMResponse(param1:Object) : void
      {
         if(param1[2] == "1" && _rfCallback != null)
         {
            _rfCallback();
         }
      }
      
      private static function roomListResponse(param1:Object) : void
      {
         gMainFrame.server.setRoomList(param1);
      }
   }
}

