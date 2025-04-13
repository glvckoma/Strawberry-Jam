package gamePlayFlow
{
   import Party.PartyManager;
   import Party.PartyXtCommManager;
   import WorldItems.WorldItemsXtCommManager;
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import adoptAPet.AdoptAPetData;
   import adoptAPet.AdoptAPetManager;
   import adoptAPet.AdoptAPetXtCommManager;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserCommXtCommManager;
   import buddy.BuddyManager;
   import buddy.BuddyXtCommManager;
   import buddy.ReferAFriendXtCommManager;
   import collection.AdoptAPetDataCollection;
   import collection.NewspaperDataCollection;
   import com.hurlant.util.Base64;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.graphics.Stats;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gameRedemption.GameRedemptionXtCommManager;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.FeedbackManager;
   import gui.Fonts;
   import gui.GuiManager;
   import gui.NGFactManager;
   import gui.PollManager;
   import gui.ServerSelector;
   import gui.TradeManager;
   import imageArray.ImageArrayInfoHelper;
   import item.ItemXtCommManager;
   import loadProgress.LoadProgress;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import movie.MovieXtCommManager;
   import newspaper.NewspaperData;
   import newspaper.NewspaperManager;
   import newspaper.NewspaperXtCommManager;
   import nodeHop.NodeHopXtCommManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import playerWall.PlayerWallManager;
   import playerWall.PlayerWallXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import resourceArray.ResourceArrayXtCommManager;
   import room.DebugGUICheckbox;
   import room.DebugGUISlider;
   import room.DebugGUITextbox;
   import room.LayerManager;
   import room.RoomJoinType;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeXtCommManager;
   import verification.VerificationXtCommManager;
   
   public class GamePlay extends MovieClip
   {
      private static var _roomMgrInitSetGotoUsername:String;
      
      private static var _instance:GamePlay;
      
      public static const HIDE_NONENGLISH_SHARDS_HACK:Boolean = true;
      
      public var loadLayer:DisplayLayer;
      
      private var _gamePlayFlashVars:Object;
      
      private var lastTimer:int;
      
      private var roomMgr:RoomManagerWorld;
      
      private var _layerManager:LayerManager;
      
      private var _loginSO:SharedObject;
      
      private var _loginUsername:String;
      
      private var _loginAuthToken:String;
      
      private var _reconnecting:Boolean;
      
      private var _connectingToServer:Boolean;
      
      private var _nextSFServerIdx:int;
      
      private var _idleTimeoutPopup:SBOkPopup;
      
      private var loginHACK:uint;
      
      private var idleBlackout:Sprite;
      
      private var _debugConnectionModeTxt:DebugGUITextbox;
      
      private var _debugServerNodeTxt:DebugGUITextbox;
      
      private var _debugShardIdTxt:DebugGUITextbox;
      
      private var _debugAudioVolumeSlider:DebugGUISlider;
      
      private var _debugCheckbox1:DebugGUICheckbox;
      
      private var _debugCheckbox2:DebugGUICheckbox;
      
      private var _debugCheckbox3:DebugGUICheckbox;
      
      private var _debugVersionTxt:DebugGUITextbox;
      
      private var _debugFlashvarTxt:DebugGUITextbox;
      
      private var _stats:Stats;
      
      private var _loginShardId:int;
      
      private var _rsShardInfoData:Object;
      
      private var _cachedShardInfo:Array;
      
      private var _cachedShardIdToNodeMap:Object;
      
      private var _loginEvent:Event;
      
      private var _connectEvent:Event;
      
      private var _hasInitedShardSelectionAssets:Boolean;
      
      private var _disconnectedByLoginFailure:Boolean;
      
      public function GamePlay(param1:Object, param2:Event, param3:Event)
      {
         super();
         _gamePlayFlashVars = param1;
         _loginEvent = param2;
         _connectEvent = param3;
      }
      
      public static function handleLocalExternalCall(param1:Object) : void
      {
         var instanceRoomMgr:RoomManagerWorld;
         var username:String;
         var modJoinRoomName:String;
         var usernamep:String;
         var jumpingToUser:Boolean;
         var alreadyInRoom:Boolean;
         var shouldGoInvisible:Boolean;
         var instanceStage:Stage;
         var denScreenshotData:BitmapData;
         var denScreenShotPixels:ByteArray;
         var d:String;
         var ixmRoomNameOrId:String;
         var ixmShardId:int;
         var initGhostMode:Boolean;
         var ijusername:String;
         var estr:String;
         var params:Object = param1;
         try
         {
            DebugUtility.debugTrace("mec received - got params[0]:" + params[0]);
            if(params[0] == "mjr")
            {
               if(_instance == null)
               {
                  return;
               }
               instanceRoomMgr = _instance.roomMgr;
               username = null;
               modJoinRoomName = params[1];
               if(params.hasOwnProperty("2"))
               {
                  usernamep = params[2];
                  if(usernamep != null && usernamep != "" && instanceRoomMgr != null)
                  {
                     username = usernamep;
                  }
               }
               jumpingToUser = username != null;
               alreadyInRoom = gMainFrame.server.getCurrentRoomName() == modJoinRoomName;
               if(!alreadyInRoom)
               {
                  DarkenManager.showLoadingSpiral(true);
                  if(jumpingToUser)
                  {
                     instanceRoomMgr.setGotoUsername(username,alreadyInRoom);
                     BuddyXtCommManager.sendBuddyRoomRequest(username,(function():*
                     {
                        var livemodJoinRoomBuddyRoomCallback:Function;
                        return livemodJoinRoomBuddyRoomCallback = function(param1:String, param2:String, param3:Boolean):void
                        {
                           var _loc7_:String = null;
                           var _loc4_:int = 0;
                           var _loc6_:int = int(param1.indexOf("@"));
                           var _loc5_:String = null;
                           if(_loc6_ >= 0)
                           {
                              _loc5_ = param1.substr(param1.indexOf("@") + 1);
                           }
                           if(_loc5_ == null || _loc5_ == gMainFrame.server.serverIp)
                           {
                              if(param3 || param1 == null || param1 == "" || param1 == "Unknown" || param1.slice(0,5) == "quest" || param1.slice(0,3) == "ffm" || param2 == null || param2 == "" || param2 == "Choosing Server" || param2 == LocalizationManager.translateIdOnly(11235))
                              {
                                 _loc7_ = "#-1";
                                 _loc4_ = int(param1.indexOf("#"));
                                 if(_loc4_ >= 0)
                                 {
                                    _loc7_ = param1.substr(_loc4_);
                                 }
                                 param1 = gMainFrame.clientInfo.startupRoom + _loc7_;
                              }
                              RoomXtCommManager._seekBuddyName = username;
                              RoomXtCommManager.sendRoomJoinRequest(param1,-1,false,true,true,RoomJoinType.DIRECT_JOIN_AND_HALT_ON_FAILURE);
                              DebugUtility.debugTrace("mjr:room join command received and jumping to user on this node - request for room:" + modJoinRoomName + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + instanceRoomMgr + " alreadyInRoom:" + alreadyInRoom + " jumpingToUser:" + jumpingToUser + ") user:" + username + " buddyRoomName:" + param1 + " sent to server");
                           }
                           else
                           {
                              DebugUtility.debugTrace("mjr:room join command received and jumping to user on other node - room:" + modJoinRoomName + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + instanceRoomMgr + " alreadyInRoom:" + alreadyInRoom + " jumpingToUser:" + jumpingToUser + ") user:" + username + " buddyRoomName:" + param1);
                              gMainFrame.clientInfo.autoStartRoom = username;
                              gMainFrame.clientInfo.autoStartRoomShardId = -3;
                              if(!gMainFrame.switchServersIfNeeded(_loc5_))
                              {
                                 new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
                                 return;
                              }
                           }
                        };
                     })());
                     return;
                  }
                  RoomXtCommManager.sendRoomJoinRequest(modJoinRoomName,-1,false,true,true,RoomJoinType.DIRECT_JOIN_AND_HALT_ON_FAILURE);
                  DebugUtility.debugTrace("mjr:room join command received, not jumping to user - request for room:" + modJoinRoomName + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + instanceRoomMgr + " alreadyInRoom:" + alreadyInRoom + " jumpingToUser:" + jumpingToUser + ") user:" + username + " sent to server");
               }
               else
               {
                  if(jumpingToUser)
                  {
                     instanceRoomMgr.setGotoUsername(username,alreadyInRoom);
                  }
                  DebugUtility.debugTrace("mjr:room join command received - already in room:" + modJoinRoomName + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + instanceRoomMgr + " alreadyInRoom:" + alreadyInRoom + " jumpingToUser:" + jumpingToUser + ") user:" + username);
               }
            }
            else if(params[0] == "mim")
            {
               shouldGoInvisible = params.hasOwnProperty("1") && params[1];
               FacilitatorXtCommManager.sendInvisModeRequest(shouldGoInvisible);
               DebugUtility.debugTrace("mim:invis mode command received - request sent to server - shouldGoInvisible:" + shouldGoInvisible);
            }
            else if(params[0] == "msn")
            {
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["sn",gMainFrame.server.serverIp]);
                  DebugUtility.debugTrace("mrc:sn command sent - ip:" + gMainFrame.server.serverIp);
               }
               DebugUtility.debugTrace("msn:get server node command received - sn response command sent");
            }
            else if(params[0] == "mds")
            {
               if(_instance == null)
               {
                  return;
               }
               if(ExternalInterface.available)
               {
                  AvatarManager.playerAvatarWorldView.visible = false;
                  _instance.stage.invalidate();
                  instanceStage = _instance.stage;
                  denScreenshotData = new BitmapData(instanceStage.stageWidth,instanceStage.stageHeight);
                  denScreenshotData.draw(instanceStage);
                  denScreenShotPixels = denScreenshotData.getPixels(new Rectangle(0,0,instanceStage.stageWidth,instanceStage.stageHeight));
                  d = Base64.encodeByteArray(denScreenShotPixels);
                  AvatarManager.playerAvatarWorldView.visible = true;
                  ExternalInterface.call("mrc",["ds",d]);
                  DebugUtility.debugTrace("mrc:ds command sent - denScreenshotData:" + denScreenshotData);
               }
               DebugUtility.debugTrace("mds:get den screenshot command received - ds response command sent");
            }
            else if(params[0] == "ixm")
            {
               DebugUtility.debugTrace("ixm:init external mode command received - setting extCallsActive to true");
               gMainFrame.clientInfo.extCallsActive = true;
               DebugUtility.debugTrace("ixm: extCallsActive set to true");
               DebugUtility.debugTrace("params.hasOwnProperty(\"1\"):" + params.hasOwnProperty("1"));
               if(params.hasOwnProperty("1") && params[1] != null)
               {
                  ixmRoomNameOrId = params[1];
                  DebugUtility.debugTrace("roomNameOrId - params[1]:" + ixmRoomNameOrId);
                  gMainFrame.clientInfo.autoStartRoom = ixmRoomNameOrId;
                  ixmShardId = int(parseInt(params[2]));
                  DebugUtility.debugTrace("shardId - params[2]:" + ixmShardId);
                  if(ixmRoomNameOrId.indexOf("den") == 0 && ixmShardId != -1)
                  {
                     DebugUtility.debugTrace("ixm: WARNING - ignoring shardId:" + ixmShardId + " because room name:" + ixmRoomNameOrId + " appears to be a den!");
                     ixmShardId = -1;
                  }
                  else if(ixmRoomNameOrId == "adventure&" && ixmShardId < 0)
                  {
                     DebugUtility.debugTrace("ixm: ERROR - invalid shardId:" + ixmShardId + "! room name was the adventure keyword:" + ixmRoomNameOrId + " so shardId needs to be an adventure script def id!");
                     return;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = ixmShardId;
                  DebugUtility.debugTrace("ixm:auto start room command received - request for " + params[1] + " set up to be caught during server selection screen init");
               }
               initGhostMode = true;
               DebugUtility.debugTrace("params.hasOwnProperty(\"4\"):" + params.hasOwnProperty("4"));
               if(params.hasOwnProperty("4"))
               {
                  initGhostMode = Boolean(params[4]);
                  DebugUtility.debugTrace("ghostMode - initGhostMode:" + initGhostMode);
                  if(!initGhostMode)
                  {
                     FacilitatorXtCommManager.sendInvisModeRequest(initGhostMode);
                     DebugUtility.debugTrace("ixm:invis mode request sent to server - initGhostMode:" + initGhostMode);
                  }
               }
               ijusername = "";
               if(params.hasOwnProperty("5"))
               {
                  DebugUtility.debugTrace("initJumpUser - params[5]:" + params[5]);
                  ijusername = params[5];
                  if(ijusername != null && ijusername != "")
                  {
                     _roomMgrInitSetGotoUsername = ijusername;
                  }
               }
               DebugUtility.debugTrace("ixm:auto jump to user position command - invisMode:" + gMainFrame.clientInfo.invisMode + " ijusername:" + ijusername + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            }
         }
         catch(e:Error)
         {
            estr = "ERROR: Caught error in handleLocalExternalCall: " + e.message + " " + e.getStackTrace();
            DebugUtility.debugTrace(estr);
         }
      }
      
      public function worldCtorHelper() : void
      {
         _instance = this;
         init();
      }
      
      public function init() : void
      {
         SBTracker.trackPageview("/game/play/loading/startup");
         DebugUtility.debugTrace("security:" + Security.sandboxType);
         DebugUtility.debugTrace("username:" + _gamePlayFlashVars.username);
         DebugUtility.debugTrace("auth_token:" + _gamePlayFlashVars.auth_token);
         _loginUsername = _gamePlayFlashVars.username;
         _loginAuthToken = _gamePlayFlashVars.auth_token;
         _connectingToServer = false;
         _nextSFServerIdx = 0;
         loginHACK = 0;
         _layerManager = null;
         loadLayer = new DisplayLayer();
         addChild(loadLayer);
         _debugConnectionModeTxt = new DebugGUITextbox(loadLayer,"(Initializing...)","Connection URL [F2]",false,false,true,250,35);
         _debugConnectionModeTxt.x = 10;
         _debugConnectionModeTxt.y = 250;
         _debugServerNodeTxt = new DebugGUITextbox(loadLayer,gMainFrame.server.serverIp,"Server Node [F2]",false,false,true,250,35);
         _debugServerNodeTxt.x = 10;
         _debugServerNodeTxt.y = 290;
         _debugShardIdTxt = new DebugGUITextbox(loadLayer,"(Initializing...)","Shard [F2]",false,false,true,250,35);
         _debugShardIdTxt.x = 10;
         _debugShardIdTxt.y = 330;
         _loginShardId = -1;
         _cachedShardIdToNodeMap = {};
         DebugUtility.debugTrace("gamePlay init() - _gamePlayFlashVars.isCreateAccount:" + _gamePlayFlashVars.isCreateAccount + " Server Node: " + gMainFrame.server.serverIp);
         try
         {
            _loginSO = SharedObject.getLocal("com/sbi/login","/");
         }
         catch(e:Error)
         {
            _loginSO = null;
         }
         LoadProgress.init(loadLayer);
         LoadProgress.updateProgress(4);
         initHUDAssets();
         gMainFrame.stage.quality = "medium";
      }
      
      public function get layerManager() : LayerManager
      {
         return _layerManager;
      }
      
      public function set reconnecting(param1:Boolean) : void
      {
         _reconnecting = param1;
         GuiManager.reconnecting = param1;
      }
      
      public function get reconnecting() : Boolean
      {
         return _reconnecting;
      }
      
      public function set debugShardIdTxt(param1:String) : void
      {
         _debugShardIdTxt.text = param1;
      }
      
      public function connectToNewServer() : void
      {
         if(_connectingToServer)
         {
            return;
         }
         if(ServerSelector.isOpen())
         {
            ServerSelector.destroy();
         }
         initConnect();
      }
      
      public function showLoadProgress(param1:Boolean, param2:int) : void
      {
         LoadProgress.show(param1);
      }
      
      public function isInMinigame() : Boolean
      {
         return MinigameManager.inMinigame();
      }
      
      public function initHUDAssets() : void
      {
         DebugUtility.debugTrace("initHUDAssets called... calling load on hudassets.swf before call to initPreConnect/initGamePalette");
         if(PaletteHelper.gamePalette != null)
         {
            initPreConnect();
         }
         else
         {
            initGamePalette();
         }
      }
      
      public function initGamePalette() : void
      {
         ImageServerURL.instance.addEventListener("OnGlobalPalette",handleGamePalette,false,0,true);
         ImageServerURL.instance.requestGlobalPalette();
      }
      
      private function handleGamePalette(param1:ImageServerEvent) : void
      {
         if(param1 && param1.genericData)
         {
            PaletteHelper.setGamePalette(param1.genericData.palette,param1.genericData.avatarPalette1,param1.genericData.avatarPalette2);
         }
         initPreConnect();
      }
      
      public function initPreConnect() : void
      {
         Fonts.init();
         if(_layerManager == null)
         {
            _layerManager = new LayerManager(this,loadLayer);
            roomMgr = RoomManagerWorld.instance;
            roomMgr.init(this.layerManager);
            if(_loginShardId == -1)
            {
               roomMgr.shardId = -1;
            }
         }
         XtReplyDemuxer.init();
         var _loc2_:DisplayLayer = _layerManager.gui;
         var _loc1_:DisplayLayer = _layerManager.fps;
         AchievementManager.init(_loc1_);
         UserCurrency.initCurrency();
         MinigameManager.init(_loc2_,roomMgr);
         AchievementXtCommManager.init(MinigameManager.inMinigame,GuiManager.onMyUserVarsReceived,GuiManager.setGemBonusValues);
         LayerAnim.useMaxThrottle = MinigameManager.inInRoomGame;
         GuiManager.init(_loc2_,_loc1_,_layerManager.room_avatars,_layerManager.room_chat,_layerManager.bkg,roomMgr.setFocus);
         AJAudio.init(RoomManagerWorld.instance.broadcastMute,GuiManager);
         ResourceArrayXtCommManager.init();
         XtReplyDemuxer.addModule(ResourceArrayXtCommManager.handleXtReply,"cr");
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"c");
         XtReplyDemuxer.addModule(AchievementXtCommManager.handleXtReply,"z");
         XtReplyDemuxer.addModule(GameRedemptionXtCommManager.handleXtReply,"gr");
         gMainFrame.server.addEventListener("OnConectionLost",onConnectionLost,false,0,true);
         initConnect();
      }
      
      public function initConnect() : void
      {
         if(!gMainFrame.server.isConnected)
         {
            if(!gMainFrame.clientInfo.df || Utility.isElectronVersionIncompatible())
            {
               showUpdateRequired();
               return;
            }
            if(gMainFrame.path == "")
            {
               gMainFrame.server.removeEventListener("OnConnect",onConnect);
               gMainFrame.server.removeEventListener("OnLogin",onWorldLogIn);
               gMainFrame.server.addEventListener("OnConnect",onConnect,false,0,true);
               gMainFrame.server.addEventListener("OnLogin",onWorldLogIn,false,0,true);
            }
            _connectingToServer = true;
            gMainFrame.server.connect();
            LoadProgress.updateProgress(5);
            _debugServerNodeTxt.text = gMainFrame.server.serverIp;
            DebugUtility.debugTrace("initConnect Server Node: " + gMainFrame.server.getConnectionUrl());
         }
         else
         {
            DebugUtility.debugTrace("ERROR: already connected?!");
         }
      }
      
      public function initShardSelectionAssets() : void
      {
         var _loc3_:ContextMenuItem = null;
         var _loc2_:ContextMenuItem = null;
         var _loc4_:ContextMenuItem = null;
         _hasInitedShardSelectionAssets = true;
         if(_loginShardId == -1)
         {
            roomMgr.shardId = -1;
         }
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            roomMgr.jamaaMilliseconds = gMainFrame.clientInfo.currentTimestamp * 1000;
         }
         var _loc6_:DisplayLayer = _layerManager.gui;
         var _loc1_:DisplayLayer = _layerManager.fps;
         GenericListXtCommManager.init();
         XtReplyDemuxer.addModule(ReferAFriendXtCommManager.handleXtReply,"ref");
         RoomXtCommManager.init();
         DenXtCommManager.init(DenSwitch.denListResponse);
         var _loc5_:ContextMenu = new ContextMenu();
         if(_loc5_)
         {
            _loc5_.addEventListener("menuSelect",onContextMenuHandler,false,0,true);
            _loc5_.hideBuiltInItems();
            if(_loc5_.customItems)
            {
               _loc3_ = new ContextMenuItem("Animal Jam");
               _loc5_.customItems.push(_loc3_);
               _loc2_ = new ContextMenuItem("OS: " + Capabilities.os,false,false);
               _loc4_ = new ContextMenuItem("Player: " + Capabilities.playerType + " " + Capabilities.version,false,false);
               _loc5_.customItems.push(_loc2_);
               _loc5_.customItems.push(_loc4_);
            }
            this.contextMenu = _loc5_;
         }
         stage.addEventListener("keyDown",keyDownListener,false,0,true);
      }
      
      public function initAssets() : void
      {
         LoadProgress.updateProgress(7);
         var _loc2_:DisplayLayer = _layerManager.gui;
         var _loc1_:DisplayLayer = _layerManager.fps;
         PartyManager.init();
         KeepAlive.init(_loc2_,gMainFrame.server.getIsConnected,FacilitatorXtCommManager.sendIdleTimeOut);
         MinigameManager.userId = gMainFrame.server.userId;
         BuddyManager.init(_loc2_,GuiManager.mainHud.buddyListBtn);
         NGFactManager.init(_loc2_,_layerManager.room_orbs);
         PollManager.init(_loc2_,_layerManager.room_orbs);
         FeedbackManager.init(_loc2_,_layerManager.room_orbs);
         ECardManager.init(_loc2_,GuiManager.mainHud.eCardBtn);
         ImageArrayInfoHelper.init();
         AvatarManager.init(_layerManager.room_avatars,_layerManager.room_chat,_layerManager.flying_avatars,_layerManager.preview_room_avatar,_layerManager.preview_room_flying_avatar);
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("auto jump to user position command - roomMgr:" + roomMgr + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            if(_roomMgrInitSetGotoUsername != null && _roomMgrInitSetGotoUsername != "")
            {
               roomMgr.setGotoUsername(_roomMgrInitSetGotoUsername,false);
            }
         }
         NodeHopXtCommManager.init();
         UserCommXtCommManager.init();
         ItemXtCommManager.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarManager.processAcIlCombo,GuiManager,DenXtCommManager.handleDenShopList);
         NameBar.getNamebarIconsFunc = GuiManager.getNamebarBadgeList;
         FacilitatorXtCommManager.init(_loc2_);
         TradeXtCommManager.init();
         PetManager.init();
         QuestXtCommManager.init();
         QuestManager.init(_layerManager);
         TradeManager.init(_loc2_);
         GuiManager.loadNameBarBadgeList();
         MinigameXtCommManager.init();
         ECardXtCommManager.init();
         AvatarXtCommManager.init(AvatarManager.avatarCreateResponse,AvatarManager.avatarUpdateResponse,AvatarManager.avatarPaintResponse,AvatarManager.avatarRemoveResponse,BuddyManager.avatarListResponse,AvatarManager.avatarList,AvatarManager.getAvatarByUserName,AvatarSwitch.avatarSwitchResponse);
         XtReplyDemuxer.addModule(UserCommXtCommManager.handleXtReply,"u");
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"i");
         XtReplyDemuxer.addModule(ECardXtCommManager.handleXtReply,"e");
         XtReplyDemuxer.addModule(FacilitatorXtCommManager.handleXtReply,"f");
         XtReplyDemuxer.addModule(BuddyXtCommManager.handleXtReply,"b");
         XtReplyDemuxer.addModule(QuestXtCommManager.handleXtReply,"q");
         XtReplyDemuxer.addModule(TradeXtCommManager.handleXtReply,"t");
         XtReplyDemuxer.addModule(AdoptAPetXtCommManager.handleXtReply,"pa");
         XtReplyDemuxer.addModule(PetXtCommManager.handleXtReply,"p");
         XtReplyDemuxer.addModule(PartyXtCommManager.handleXtReply,"s");
         XtReplyDemuxer.addModule(VersionXtCommManager.handleXtReply,"userDataVersion");
         XtReplyDemuxer.addModule(WorldItemsXtCommManager.handleXtReply,"wi");
         XtReplyDemuxer.addModule(PlayerWallXtCommManager.handleXtReply,"w");
         XtReplyDemuxer.addModule(VerificationXtCommManager.handleXtReply,"v");
         XtReplyDemuxer.addModule(NewspaperXtCommManager.handleXtReply,"np");
         XtReplyDemuxer.addModule(NodeHopXtCommManager.handleXtReply,"n");
         _loc1_.addChild(_debugConnectionModeTxt);
         _loc1_.addChild(_debugServerNodeTxt);
         _loc1_.addChild(_debugShardIdTxt);
         addEventListener("enterFrame",heartbeat,false,0,true);
         lastTimer = getTimer();
         ServerSelector.fillNamesArray(true);
         var _loc3_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc3_.init(1038,GenericListXtCommManager.genericListTypeResponse,null,2);
         DefPacksDefHelper.mediaArray[1038] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1025,QuestXtCommManager.questNPCDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1025] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1011,RoomXtCommManager.roomDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1011] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1040,DenXtCommManager.denRoomResponse,null,2);
         DefPacksDefHelper.mediaArray[1040] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1053,MovieXtCommManager.movieNodeResponse,null,2);
         DefPacksDefHelper.mediaArray[1053] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1052,QuestXtCommManager.scriptResponse,null,2);
         DefPacksDefHelper.mediaArray[1052] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1042,AchievementXtCommManager.onAchievementDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1042] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(1061,AdoptAPetXtCommManager.onAdoptAPetDefsResponse,null,2);
         DefPacksDefHelper.mediaArray[1061] = _loc3_;
         Utility.trackWhichBrowserIsUsed();
         SBTracker.trackPageview("/game/play/" + gMainFrame.clientInfo.clientPlatform);
         GuiManager.volumeMgr.loadAssets(mapAssetsLoaded);
      }
      
      public function mapAssetsLoaded() : void
      {
         var _loc1_:URLLoader = null;
         gMainFrame.server.setInitRoom();
         roomMgr.chosenLoginFinished();
         _debugAudioVolumeSlider = new DebugGUISlider();
         _debugAudioVolumeSlider.init(_layerManager,roomMgr.debugAudioVolumeChanged,false);
         _debugCheckbox1 = new DebugGUICheckbox();
         _debugCheckbox1.init(_layerManager.fps,null,"Background Layer",true);
         _debugCheckbox1.x = 400;
         _debugCheckbox1.y = 250;
         _debugCheckbox2 = new DebugGUICheckbox();
         _debugCheckbox2.init(_layerManager.fps,null,"Sortable Layer",true);
         _debugCheckbox2.x = 400;
         _debugCheckbox2.y = 275;
         _debugCheckbox3 = new DebugGUICheckbox();
         _debugCheckbox3.init(_layerManager.fps,null,"Foreground Layer",true);
         _debugCheckbox3.x = 400;
         _debugCheckbox3.y = 300;
         _debugVersionTxt = new DebugGUITextbox(stage,"buildinfo.xml not loaded yet!","Build Info [CTRL-F2]",false,true,true,350,85);
         _debugVersionTxt.x = 480;
         _debugVersionTxt.y = 328;
         if(gMainFrame.clientInfo.devMode)
         {
            _loc1_ = new URLLoader();
            _loc1_.dataFormat = "text";
            _loc1_.addEventListener("complete",buildInfoLocalDebugLoadCompleteHandler);
            _loc1_.addEventListener("ioError",buildInfoLocalDebugLoadErrorHandler);
            _loc1_.load(new URLRequest("buildinfo.xml"));
         }
         else
         {
            loadBuildInfoFromCDN();
         }
         _debugFlashvarTxt = new DebugGUITextbox(stage,"","Flashvars [CTRL-F2]",false,true,true,350,55);
         _debugFlashvarTxt.text = "content: " + gMainFrame.clientInfo.contentURL + "\nbuild_version: " + gMainFrame.clientInfo.buildVersion + "\ndeploy_version: " + gMainFrame.clientInfo.deployVersion;
         _debugFlashvarTxt.x = 480;
         _debugFlashvarTxt.y = 415;
      }
      
      private function buildInfoLocalDebugLoadErrorHandler(param1:IOErrorEvent) : void
      {
         loadBuildInfoFromCDN();
      }
      
      private function buildInfoLocalDebugLoadCompleteHandler(param1:Event) : void
      {
         if(param1.target.data)
         {
            parseBuildInfo(param1.target.data);
         }
         else
         {
            loadBuildInfoFromCDN();
         }
      }
      
      private function loadBuildInfoFromCDN() : void
      {
         gMainFrame.loaderCache.openFile("buildinfo.xml",buildInfoDebugLoadCompleteHandler,null,"text");
      }
      
      private function buildInfoDebugLoadCompleteHandler(param1:LoaderEvent) : void
      {
         if(param1.status)
         {
            parseBuildInfo(param1.entry.data);
         }
         else
         {
            _debugVersionTxt.text = "buildinfo.xml not found!";
         }
      }
      
      private function parseBuildInfo(param1:Object) : void
      {
         var _loc2_:XML = new XML(param1);
         _debugVersionTxt.text = "File Size: " + this.loaderInfo.bytesTotal + "\nCompile Time: " + _loc2_.time.text() + "\nTriggered By: " + _loc2_.triggeredBy.text() + "\nConfig: " + _loc2_.config.text() + "\nBranch: " + _loc2_.branch.text() + "\nRevision: " + _loc2_.revision.text();
      }
      
      public function destroy() : void
      {
         AvatarSwitch.destroy();
         GameRedemptionXtCommManager.destroy();
         AdoptAPetXtCommManager.destroy();
         SBPopupManager.destroyAll();
         XtReplyDemuxer.destroy();
         ItemXtCommManager.destroy();
         UserCommXtCommManager.destroy();
         AvatarManager.destroy();
         MinigameManager.destroy();
         BuddyManager.destroy();
         GuiManager.destroy();
         QuestManager.destroy();
         PlayerWallManager.destroy();
         roomMgr.destroy();
         roomMgr = null;
         removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyDownListener);
         gMainFrame.server.removeEventListener("OnConectionLost",onConnectionLost);
         if(gMainFrame.path == "")
         {
            gMainFrame.server.removeEventListener("OnConnect",onConnect);
            gMainFrame.server.removeEventListener("OnLogin",onWorldLogIn);
         }
      }
      
      public function showServerSelectorMore(param1:Object) : void
      {
         var _loc7_:String = null;
         var _loc9_:int = 0;
         var _loc8_:* = null;
         var _loc2_:Array = [];
         var _loc10_:* = -1;
         var _loc11_:int = 2;
         var _loc3_:int = 0;
         while(param1.hasOwnProperty(_loc11_))
         {
            _loc7_ = param1[_loc11_++];
            while(!isNaN(Number(param1[_loc11_])))
            {
               _loc9_ = int(param1[_loc11_++]);
               if(_loc9_ > _loc10_)
               {
                  _loc10_ = _loc9_;
               }
               if(roomMgr.shardId == _loc9_)
               {
                  _loc11_ += 3;
               }
               else
               {
                  _cachedShardIdToNodeMap[_loc9_] = _loc7_;
                  _loc2_[_loc3_++] = {
                     "i":_loc9_,
                     "l":param1[_loc11_++],
                     "p":param1[_loc11_++],
                     "b":param1[_loc11_++]
                  };
               }
            }
         }
         _loc2_.sortOn(["l","b","p","i"],[16,2 | 0x10,2 | 0x10,16]);
         _cachedShardInfo = _loc2_;
         var _loc5_:Object = {};
         var _loc4_:int = 0;
         var _loc6_:int = LocalizationManager.accountLanguage;
         for each(_loc8_ in _loc2_)
         {
            if(_loc8_.l == _loc6_)
            {
               if(int(_loc8_.p) < 4)
               {
                  _loc5_[_loc4_++] = _loc8_.i;
                  _loc5_[_loc4_++] = _loc8_.l;
                  _loc5_[_loc4_++] = int(_loc8_.p) > 0 ? _loc8_.p : (int(_loc8_.b) > 0 ? "1" : "0");
                  _loc5_[_loc4_++] = _loc8_.b;
               }
            }
         }
         for each(_loc8_ in _loc2_)
         {
            if(_loc8_.l != _loc6_)
            {
               if(!(_loc6_ == LocalizationManager.LANG_ENG && _loc8_.l != _loc6_))
               {
                  if(int(_loc8_.p) < 4)
                  {
                     _loc5_[_loc4_++] = _loc8_.i;
                     _loc5_[_loc4_++] = _loc8_.l;
                     _loc5_[_loc4_++] = int(_loc8_.p) > 0 ? _loc8_.p : (int(_loc8_.b) > 0 ? "1" : "0");
                     _loc5_[_loc4_++] = _loc8_.b;
                  }
               }
            }
         }
         for each(_loc8_ in _loc2_)
         {
            if(int(_loc8_.p) >= 4)
            {
               if(!(_loc6_ == LocalizationManager.LANG_ENG && _loc8_.l != _loc6_))
               {
                  _loc5_[_loc4_++] = _loc8_.i;
                  _loc5_[_loc4_++] = _loc8_.l;
                  _loc5_[_loc4_++] = int(_loc8_.p) > 0 ? _loc8_.p : (int(_loc8_.b) > 0 ? "1" : "0");
                  _loc5_[_loc4_++] = _loc8_.b;
               }
            }
         }
         ServerSelector.setupAllShards(_loc5_,_loc10_);
      }
      
      public function joinChosenShardIdNode(param1:int = -1, param2:String = null, param3:RoomJoinType = null) : void
      {
         if(param1 != -1)
         {
            _loginShardId = param1;
            roomMgr.shardId = param1;
            for each(var _loc4_ in _cachedShardInfo)
            {
               if(_loc4_.i == param1)
               {
                  if(_loc4_.l != LocalizationManager.accountLanguage)
                  {
                     RoomXtCommManager.waitForLangPack = true;
                     LocalizationXtCommManager.onLocalizationShardResponse(param1 + ":" + _loc4_.l);
                  }
                  break;
               }
            }
         }
         SBTracker.trackPageview("/game/play/loading/joinShard");
         roomMgr._gotNewShardId = true;
         roomMgr.joinNewShardRoom(param3);
      }
      
      private function serializeLoginParams(param1:String) : String
      {
         var _loc3_:Array = null;
         var _loc2_:String = null;
         if(param1 != null && param1.length > 0)
         {
            _loc3_ = [];
            _loc3_.push(param1);
            _loc3_.push(gMainFrame.clientInfo.sessionId != undefined ? gMainFrame.clientInfo.sessionId : "");
            _loc3_.push(LocalizationManager.accountLanguage);
            _loc3_.push(gMainFrame.clientInfo.deployVersion);
            _loc3_.push(gMainFrame.clientInfo.clientPlatform);
            _loc3_.push(gMainFrame.clientInfo.clientPlatformVersion);
            _loc3_.push(Utility.getOS());
            _loc3_.push(gMainFrame.clientInfo.df);
            _loc2_ = _loc3_.join("%");
         }
         return _loc2_;
      }
      
      public function loginToChosenServer() : void
      {
         var _loc2_:String = null;
         var _loc1_:SFEvent = null;
         LoadProgress.updateProgress(5);
         if(!gMainFrame.server.isConnected)
         {
            gMainFrame.server.connect();
         }
         else
         {
            _loc2_ = serializeLoginParams(_loginUsername);
            if(_loc2_ != null)
            {
               gMainFrame.server.logIn("sbiLogin",_loc2_,_loginAuthToken);
            }
            else
            {
               _loc1_ = new SFEvent("OnLogin");
               _loc1_.status = false;
               onWorldLogIn(_loc1_);
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.accountType == 5 || gMainFrame.clientInfo.extCallsActive)
         {
            if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 113)
            {
               if(_stats == null)
               {
                  _stats = new Stats();
                  _layerManager.fps.addChild(_stats);
                  _stats.visible = false;
               }
               _stats.visible = !_stats.visible;
               _debugServerNodeTxt.visible = !_debugServerNodeTxt.visible;
               _debugConnectionModeTxt.visible = !_debugConnectionModeTxt.visible;
               _debugShardIdTxt.visible = !_debugShardIdTxt.visible;
               if(_stats.visible)
               {
                  stage.addChild(_layerManager.fps);
               }
               else
               {
                  stage.removeChild(_layerManager.fps);
                  param1;
               }
            }
            else if(param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 113)
            {
               if(_debugVersionTxt && _debugFlashvarTxt)
               {
                  _debugVersionTxt.toggleVisiblity();
                  _debugFlashvarTxt.toggleVisiblity();
               }
            }
            else if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 115)
            {
               if(AJClient.globalDebugLog)
               {
                  AJClient.globalDebugLog.toggleVisiblity(stage);
               }
            }
            else if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 116)
            {
               GuiManager.toggleHud();
            }
            else if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 117)
            {
               if(gMainFrame.stage.quality == "HIGH")
               {
                  gMainFrame.stage.quality = "medium";
               }
               else if(gMainFrame.stage.quality == "MEDIUM")
               {
                  gMainFrame.stage.quality = "low";
               }
               else
               {
                  gMainFrame.stage.quality = "high";
               }
            }
         }
      }
      
      private function onContextMenuHandler(param1:ContextMenuEvent) : void
      {
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         AvatarManager.heartbeat(33,_loc2_ - lastTimer);
         roomMgr.heartbeat(33,_loc2_ - lastTimer,_loc2_);
         QuestManager.heartbeat(_loc2_);
         LayerAnim.heartbeat();
         PartyManager.updateTime(_loc2_);
         BuddyManager.heartbeat(_loc2_ - lastTimer);
         lastTimer = _loc2_;
      }
      
      public function onConnect(param1:SFEvent) : void
      {
         var _loc2_:String = null;
         _connectingToServer = false;
         if(param1.status)
         {
            _debugConnectionModeTxt.text = gMainFrame.server.getConnectionUrl();
            DebugUtility.debugTrace("onConnect - _gamePlayFlashVars.isCreateAccount:" + _gamePlayFlashVars.isCreateAccount + " gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive);
            if(!_hasInitedShardSelectionAssets)
            {
               initShardSelectionAssets();
            }
            loginToChosenServer();
         }
         else if(_reconnecting)
         {
            if(gMainFrame.server.allowAutoAttemptHttp && !gMainFrame.server.autoAttemptHttp)
            {
               gMainFrame.server.autoAttemptHttp = true;
               _debugServerNodeTxt.text = gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Attempting Reconnecting/Direct Bluebox Autoattempt Connection...";
               gMainFrame.server.connect();
               DebugUtility.debugTrace("trying bluebox Server Node: " + gMainFrame.server.getConnectionUrl());
            }
            else
            {
               new SBStandardPopup(this,LocalizationManager.translateIdOnly(14694),false);
            }
         }
         else if(gMainFrame.server.allowAutoAttemptHttp && !gMainFrame.server.autoAttemptHttp)
         {
            if(_nextSFServerIdx < gMainFrame.server.serverIps.length - 1)
            {
               gMainFrame.server.setNewServer(_nextSFServerIdx);
               _debugServerNodeTxt.text = gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Attempting Connection...";
               gMainFrame.server.connect();
               DebugUtility.debugTrace("trying next Server Node: " + gMainFrame.server.getConnectionUrl());
               ++_nextSFServerIdx;
            }
            else
            {
               gMainFrame.server.autoAttemptHttp = true;
               _nextSFServerIdx = 0;
               gMainFrame.server.setNewServer(_nextSFServerIdx);
               _debugServerNodeTxt.text = gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Starting Over With BlueBox Autoattempt Connection...";
               gMainFrame.server.connect();
               DebugUtility.debugTrace("trying first bluebox Server Node: " + gMainFrame.server.getConnectionUrl());
            }
         }
         else if(_nextSFServerIdx < gMainFrame.server.serverIps.length - 1)
         {
            gMainFrame.server.setNewServer(_nextSFServerIdx);
            DebugUtility.debugTrace("trying next bluebox Server Node: " + gMainFrame.server.serverIp);
            gMainFrame.server.connect();
            ++_nextSFServerIdx;
         }
         else
         {
            DebugUtility.debugTrace("entire cluster/game is down! _nextSFServerIdx:" + _nextSFServerIdx + " serverIps:" + gMainFrame.server.serverIps);
            gMainFrame.server.disconnect(false);
            _loc2_ = LocalizationManager.translateIdOnly(14695) + " [" + param1.statusId + "]";
            new SBStandardPopup(stage,_loc2_,false);
         }
      }
      
      public function onWorldLogIn(param1:SFEvent) : void
      {
         var _loc8_:int = 0;
         var _loc6_:Array = null;
         var _loc10_:AdoptAPetDataCollection = null;
         var _loc4_:AdoptAPetData = null;
         var _loc5_:Array = null;
         var _loc11_:NewspaperDataCollection = null;
         var _loc2_:NewspaperData = null;
         var _loc3_:int = 0;
         var _loc7_:Array = null;
         var _loc9_:String = null;
         LoadProgress.updateProgress(6);
         DebugUtility.debugTrace("World onLogIn, status:" + param1.status);
         if(param1.status)
         {
            DebugUtility.debugTrace("World onLogIn successful! gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive + " _layerManager:" + _layerManager + " evt.userName:" + param1.userName + " gMainFrame.server.serverIp:" + gMainFrame.server.serverIp + " evt.obj.firstFiveMinutes:" + param1.obj.firstFiveMinutes);
            DebugUtility.debugTrace("World onLogIn successful! roomMgr.shardId:" + roomMgr.shardId + " _loginUsername:" + _loginUsername + " _loginShardId:" + _loginShardId);
            gMainFrame.server.setInitRoom();
            _loc8_ = 0;
            while(_loc8_ < SbiConstants.CURRENCY_NAMES.length)
            {
               UserCurrency.setCurrency(param1.obj[SbiConstants.CURRENCY_NAMES[_loc8_] + "Count"],_loc8_);
               _loc8_++;
            }
            gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            gMainFrame.clientInfo.accountType = param1.obj.accountType;
            gMainFrame.clientInfo.avName = param1.obj.avName;
            gMainFrame.clientInfo.dailyGiftIndex = param1.obj.dailyGiftIndex;
            gMainFrame.clientInfo.hasOnlineBuddies = param1.obj.hasOnlineBuddies;
            gMainFrame.clientInfo.interactions = param1.obj.interactions;
            gMainFrame.clientInfo.jamaaDate = param1.obj.jamaaDate;
            gMainFrame.clientInfo.numAJHQGiftCards = param1.obj.numAJHQGiftCards;
            gMainFrame.clientInfo.numDaysLeftOnSubscription = param1.obj.numDaysLeftOnSubscription;
            gMainFrame.clientInfo.numRedemptionCards = param1.obj.numRedemptionCards;
            gMainFrame.clientInfo.numUnreadECards = param1.obj.numUnreadECards;
            gMainFrame.clientInfo.numAJHQBulkGiftCards = param1.obj.numAJHQBulkGiftCards;
            gMainFrame.clientInfo.recyclePercentage = param1.obj.recyclePercentage;
            gMainFrame.clientInfo.userNameModerated = param1.obj.userNameModerated;
            gMainFrame.clientInfo.userEmail = param1.obj.email;
            gMainFrame.clientInfo.pendingEmail = param1.obj.pendingEmail != null ? param1.obj.pendingEmail : "";
            gMainFrame.clientInfo.subscriptionSourceType = param1.obj.subscriptionSourceType;
            gMainFrame.userInfo.myPerUserAvId = param1.obj.perUserAvId;
            gMainFrame.userInfo.myUserName = param1.userName;
            gMainFrame.userInfo.isGuide = param1.obj.isGuide;
            gMainFrame.userInfo.isModerator = param1.obj.isModerator;
            gMainFrame.userInfo.denPrivacySettings = param1.obj.denPrivacySettings;
            gMainFrame.userInfo.isSilenced = param1.obj.isSilenced != null ? true : false;
            gMainFrame.userInfo.numLogins = param1.obj.numLogins;
            gMainFrame.userInfo.createdAt = param1.obj.createdAt;
            gMainFrame.userInfo.pendingFlags = param1.obj.pendingFlags;
            gMainFrame.userInfo.sgChatType = param1.obj.sgChatType;
            gMainFrame.userInfo.sgChatTypeNonDegraded = param1.obj.sgChatTypeNonDegraded;
            gMainFrame.userInfo.webPlayerWallSettings = param1.obj.webWallStatus;
            gMainFrame.userInfo.myUUID = param1.obj.uuid;
            gMainFrame.userInfo.playerWallSettings = param1.obj.playerWallSettings;
            gMainFrame.userInfo.eCardPrivacySettings = param1.obj.eCardPrivacySettings;
            _loc6_ = param1.obj.usableAdoptAPetDefs as Array;
            _loc10_ = new AdoptAPetDataCollection();
            _loc8_ = 0;
            while(_loc8_ < _loc6_.length)
            {
               _loc4_ = new AdoptAPetData(_loc6_[_loc8_]);
               _loc10_.setAdoptAPetDataItem(_loc4_.defId,_loc4_);
               _loc8_++;
            }
            AdoptAPetManager.setUsableAdoptAPetData(_loc10_);
            _loc5_ = param1.obj.newspaperDefs as Array;
            _loc11_ = new NewspaperDataCollection();
            _loc8_ = 0;
            while(_loc8_ < _loc5_.length)
            {
               _loc2_ = new NewspaperData(_loc5_[_loc8_]);
               _loc11_.setNewspaperDataItem(_loc2_.defId,_loc2_);
               _loc8_++;
            }
            NewspaperManager.setNewspaperData(_loc11_);
            gMainFrame.userInfo.isMember = Utility.isMember(param1.obj.accountType);
            gMainFrame.userInfo.firstFiveMinutes = param1.obj.pendingFlags & 1;
            gMainFrame.userInfo.needFastPass = (param1.obj.pendingFlags & 0x10) != 0;
            DenSwitch.setActiveDenIdx(param1.obj.activeDenRoomInvId);
            PetManager.myActivePetInvId = param1.obj.activePetInvId;
            _debugServerNodeTxt.text = gMainFrame.server.serverIp;
            gMainFrame.server.triggerWorldXtReadyCmd();
            gMainFrame.myFlashVarUserName = param1.userName;
            GuiManager.setupSharedObject();
            GuiManager.setupSoundButton();
            gMainFrame.clientInfo.invisMode = gMainFrame.userInfo.isModerator;
            if(_reconnecting)
            {
               _reconnecting = false;
               if(gMainFrame.userInfo.avtDefsCached)
               {
                  _loc3_ = int(gMainFrame.server.userId);
                  AvatarManager.playerSfsUserId = _loc3_;
                  UserCommXtCommManager.playerSfsUserId = _loc3_;
                  AvatarSwitch.playerSfsUserId = _loc3_;
                  MinigameManager.userId = _loc3_;
                  roomMgr.reconnectNodeSwitchLoginFinished();
                  return;
               }
            }
            gMainFrame.clientInfo.accountTypeChanged = param1.obj.accountTypeChanged;
            gMainFrame.clientInfo.lastBroadcastMessage = param1.obj.lastBroadcastMessage;
            gMainFrame.clientInfo.sessionId = param1.obj.sessionId;
            GuiManager.setupAllItems();
            if(gMainFrame.server.isBlueboxMode())
            {
               SBTracker.trackPageview("/game/play/isBlueBox",-1,1);
            }
            AvatarSwitch.init();
            initAssets();
         }
         else if(gMainFrame.clientInfo.hasOwnProperty("autoLogin" + ++loginHACK))
         {
            _loc7_ = gMainFrame.clientInfo["autoLogin" + loginHACK];
            gMainFrame.server.logIn("sbiLogin",serializeLoginParams(_loc7_[0]),_loc7_[1]);
            _loginUsername = _loc7_[0];
            _loginAuthToken = _loc7_[1];
         }
         else
         {
            _reconnecting = false;
            SBTracker.push();
            if(param1.obj && param1.obj.hasOwnProperty("dbUserId"))
            {
               gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            }
            else
            {
               gMainFrame.clientInfo.dbUserId = 0;
            }
            if(param1.statusId == -11)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/inUse");
               _loc9_ = LocalizationManager.translateIdOnly(11197);
            }
            else if(param1.statusId == -12)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/accountMaintenance");
               _loc9_ = LocalizationManager.translateIdOnly(11198);
            }
            else if(param1.statusId == -16)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/serverMaintenance");
               _loc9_ = LocalizationManager.translateIdOnly(11199);
            }
            else if(param1.statusId == -14)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/tooManyConnections");
               _loc9_ = LocalizationManager.translateIdOnly(11200);
            }
            else if(param1.statusId == -15)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/bannedUser");
               _loc9_ = LocalizationManager.translateIdOnly(11201);
            }
            else if(param1.statusId == -24)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/clientMismatch");
               Utility.reloadSWFOrGetIp();
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/loginError");
               _loc9_ = LocalizationManager.translateIdOnly(11202);
            }
            SBTracker.handleErrorTracking(gMainFrame.clientInfo.dbUserId,-1,0,Math.abs(param1.statusId),-1,"failure",gMainFrame.server.serverIp,-1,-1);
            new SBStandardPopup(gMainFrame.stage,_loc9_,false);
            _disconnectedByLoginFailure = true;
            gMainFrame.server.disconnect();
         }
      }
      
      private function showUpdateRequired() : void
      {
         SBTracker.trackPageview("/game/play/popup/loginError/electronMinVersion");
         var _loc1_:SBStandardPopup = new SBStandardPopup(gMainFrame.stage,"",false);
         var _loc2_:String = gMainFrame.clientInfo.websiteURL.replace(/www\./,"classic.");
         _loc2_ = _loc2_.replace(/(dev|stage)\./,"$1-classic.");
         var _loc3_:String = "<a href=\"" + _loc2_ + "\" target=\"_blank\">" + _loc2_ + "</a>";
         _loc1_.setHtmlText(LocalizationManager.translateIdOnly(36800).replace("%URL%",_loc3_));
      }
      
      public function onConnectionLost(param1:SFEvent) : void
      {
         var msg:String;
         var evt:SFEvent = param1;
         if(AvatarManager.playerSfsUserId >= 0)
         {
            roomMgr.exitRoom();
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.connectionLost();
         }
         if(_reconnecting)
         {
            connectToNewServer();
            return;
         }
         if(PlayerWallManager)
         {
            PlayerWallManager.destroy();
         }
         if(GuiManager.chatHist)
         {
            GuiManager.chatHist.showChatInput(false);
         }
         if(GuiManager.guiLayer && GuiManager.guiLayer.contains(LoadProgress.loadScreen))
         {
            GuiManager.guiLayer.removeChild(LoadProgress.loadScreen);
         }
         if(_idleTimeoutPopup)
         {
            DebugUtility.debugTrace("WARNING: idleTimeoutPopup is not null!");
            _idleTimeoutPopup.destroy();
            _idleTimeoutPopup = null;
         }
         idleBlackout = new Sprite();
         with(idleBlackout.graphics)
         {
            beginFill(0);
            drawRect(0,0,MainFrame.VIEW_WIDTH,MainFrame.VIEW_WIDTH);
         }
         while(_layerManager.gui.numChildren >= 1)
         {
            _layerManager.gui.removeChildAt(0);
         }
         _layerManager.gui.addChild(idleBlackout);
         if(!_disconnectedByLoginFailure)
         {
            if(FacilitatorXtCommManager.kickReason >= 0)
            {
               msg = FacilitatorXtCommManager.kickMsg;
               FacilitatorXtCommManager.kickReason = -1;
               FacilitatorXtCommManager.kickMsg = LocalizationManager.translateIdOnly(11183);
            }
            else
            {
               if(FacilitatorXtCommManager.wasUserBanned)
               {
                  FacilitatorXtCommManager.openPunishPopup(FacilitatorXtCommManager.suspensionType,FacilitatorXtCommManager.suspensionDuration);
                  return;
               }
               msg = LocalizationManager.translateIdOnly(11204);
            }
            _idleTimeoutPopup = new SBOkPopup(gMainFrame.stage,msg,false,idleTimeoutConfirmHandler);
         }
      }
      
      public function idleTimeoutConfirmHandler(param1:MouseEvent) : void
      {
         if(_idleTimeoutPopup)
         {
            _idleTimeoutPopup.destroy();
            _idleTimeoutPopup = null;
         }
         _layerManager.gui.removeChild(idleBlackout);
         try
         {
            LoadProgress.show(true,"Redirecting");
            navigateToURL(new URLRequest(gMainFrame.clientInfo.websiteURL + "signin"),"_self");
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error while trying to redirect after timeout! msg:" + e.message + e.getStackTrace());
         }
      }
   }
}

