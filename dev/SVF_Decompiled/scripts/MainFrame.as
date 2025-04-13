package
{
   import avatar.AvatarManager;
   import avatar.UserInfoCache;
   import com.sbi.analytics.GATracker;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFClient;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.loader.LoaderCache;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import game.MinigameManager;
   import gamePlayFlow.GamePlay;
   import gui.GuiManager;
   import loadProgress.LoadProgress;
   import room.LayerManager;
   import room.RoomManagerWorld;
   
   public class MainFrame extends Sprite
   {
      public static const VIEW_WIDTH:int = 900;
      
      public static const VIEW_HEIGHT:int = 550;
      
      public static const ROOMS_FOLDER:String = "roomDefs/";
      
      public static const AUDIO_FOLDER:String = "audio/";
      
      public static const CDN_SALT:String = "J@mnim4L";
      
      public static const MSG_ID_LOGIN_IN_USE:int = -11;
      
      public static const MSG_ID_LOGIN_ACCT_MAINT:int = -12;
      
      public static const MSG_ID_LOGIN_CONNECTION:int = -14;
      
      public static const MSG_ID_LOGIN_BANNED:int = -15;
      
      public static const MSG_ID_LOGIN_SERVER_MAINT:int = -16;
      
      public static const MSG_ID_LOGIN_CLIENT_MISMATCH:int = -24;
      
      public static var avatarCreationLogin:MovieClip;
      
      public static var avatarCreationVO:MovieClip;
      
      public static var handleLocalExternalCall:Function;
      
      private static const _configDebugFile:String = "clientdevtest.xml";
      
      private static const _configDebugTemplateFile:String = "clientdevtest.template.xml";
      
      private static var _configLoadedCallback:Function;
      
      private static var m:MainFrame;
      
      private static var _flashVarUserName:String;
      
      private static var _client:SFClient = null;
      
      private static var _path:String = null;
      
      private static var _stage:Stage;
      
      private static var _gamePlay:DisplayObjectContainer;
      
      private static var _waitingRoom:DisplayObjectContainer;
      
      private static var _createAccount:DisplayObjectContainer;
      
      private static var _loaderCache:LoaderCache;
      
      private static var _currStageQuality:String;
      
      public var userInfo:UserInfoCache;
      
      public var clientInfo:Object;
      
      public var classNames:Array;
      
      private var _layerInfo:Object;
      
      public function MainFrame()
      {
         super();
      }
      
      public static function getInstance(param1:Object = null, param2:Function = null, param3:String = "", param4:DisplayObjectContainer = null) : MainFrame
      {
         var _loc7_:Stage = null;
         var _loc8_:Boolean = false;
         var _loc5_:Shape = null;
         var _loc9_:Boolean = false;
         var _loc6_:URLLoader = null;
         if(m == null)
         {
            if(param3 == null || param4 == null || param4.stage == null)
            {
               throw new Error("ERROR: Attempted to call initial getInstance on MainFrame without correct parameters!");
            }
            _loc7_ = param4.stage;
            LoadProgress.init(_loc7_);
            LoadProgress.show(true,2);
            LoaderCache.cdnSalt = "J@mnim4L";
            _loc8_ = ExternalInterface.available;
            if(_loc8_)
            {
               DebugUtility.debugTrace("extIntAvail is true");
               DebugUtility.debugTrace("mrc dm init starting up call returned:" + ExternalInterface.call("mrc",["dm","init:starting up"]));
               ExternalInterface.addCallback("handleResize",handleResize);
            }
            else
            {
               DebugUtility.debugTrace("extIntAvail is false");
            }
            _loc5_ = new Shape();
            _loc5_.graphics.clear();
            _loc5_.graphics.lineStyle(1,16777215);
            _loc5_.graphics.beginFill(16777215);
            _loc5_.graphics.drawRect(0,0,900,550);
            _loc5_.graphics.endFill();
            param4.addChild(_loc5_);
            param4.mask = _loc5_;
            _loc7_.showDefaultContextMenu = false;
            _loc7_.scaleMode = "showAll";
            m = new MainFrame();
            m.init(new Singleton(),param3,_loc7_);
            gMainFrame = m;
            _currStageQuality = "medium";
            _loc7_.addEventListener("keyDown",keyDownListener,false,0,true);
            _loc7_.addEventListener("rightMouseDown",onRightMouseDown,false,0,true);
            if(_loc8_)
            {
               try
               {
                  DebugUtility.debugTrace("init:adding mec callback");
                  ExternalInterface.addCallback("mec",handleLocalExternalCall);
                  DebugUtility.debugTrace("init:mec added, calling lc...");
                  ExternalInterface.call("mrc",["lc"]);
                  DebugUtility.debugTrace("init:... lc called, waiting for ixm...");
               }
               catch(e:Error)
               {
                  DebugUtility.debugTrace("init:ERROR hit during AJC ext mod setup! msg:" + e.message + " stack:" + e.getStackTrace());
               }
            }
            DebugUtility.debugTrace("init: setting extCallsActive to false");
            gMainFrame.clientInfo.extCallsActive = false;
            DebugUtility.debugTrace("init: set extCallsActive to false");
            _configLoadedCallback = param2;
            _loc9_ = param1 && param1.smartfoxServer;
            DebugUtility.debugTrace("MainFrame.getInstance - haveFlashVars:" + _loc9_);
            gMainFrame.clientInfo.devMode = !_loc9_;
            if(_loc9_)
            {
               if("username" in param1 && param1.username != undefined)
               {
                  _flashVarUserName = param1.username;
               }
               else
               {
                  _flashVarUserName = "";
               }
               DebugUtility.debugTrace("MainFrame.getInstance - flashVars.ingressXt:" + param1.ingressXt + " flashVars.ingressHProxy:" + param1.ingressHProxy + " flashVars.smartfoxServer:" + param1.smartfoxServer + " flashVars.smartfoxPort:" + param1.smartfoxPort + " flashVars.blueboxPort:" + param1.blueboxPort + " flashVars.content:" + param1.content + " flashVars.website:" + param1.website);
               if(!(param1.smartfoxServer && param1.smartfoxPort && param1.blueboxServer && param1.blueboxPort && param1.content && param1.website))
               {
                  DebugUtility.debugTrace("MainFrame.getInstance - Invalid FlashVars! Throwing error...");
                  throw new Error("Invalid FlashVars!");
               }
               if(!param1.hasOwnProperty("startupRoom"))
               {
                  param1.startupRoom = "jamaa_township.room_main";
               }
               if(!param1.hasOwnProperty("worldmapRoom"))
               {
                  param1.worldmapRoom = "world_map/room_main.xroom";
               }
               if(!param1.hasOwnProperty("dangermapRoom"))
               {
                  param1.dangermapRoom = "danger_map/room_main.xroom";
               }
               if(!param1.hasOwnProperty("clientDebug"))
               {
                  param1.clientDebug = "false";
               }
               if(!param1.hasOwnProperty("forceHttpProxy"))
               {
                  param1.forceHttpProxy = "false";
               }
               if(!param1.hasOwnProperty("build_version"))
               {
                  param1.build_version = "0";
               }
               if(!param1.hasOwnProperty("deploy_version"))
               {
                  param1.deploy_version = "0";
               }
               if(!param1.hasOwnProperty("locale"))
               {
                  param1.locale = "en-US";
               }
               if(!param1.hasOwnProperty("sg_params"))
               {
                  param1.sg_params = "";
               }
               if(!param1.hasOwnProperty("buddyRoomTimerInterval"))
               {
                  param1.buddyRoomTimerInterval = "30000";
               }
               if(!param1.hasOwnProperty("country"))
               {
                  param1.country = "US";
               }
               if(String(param1.sg_params).indexOf("%") >= 0)
               {
                  throw new Error("Invalid sg_params!");
               }
               gMainFrame.clientInfo.localMode = false;
               LoaderCache.localMode = false;
               applyConfigVars(param1);
            }
            else
            {
               _loc6_ = new URLLoader();
               _loc6_.dataFormat = "text";
               _loc6_.addEventListener("complete",configDebugLoadCompleteHandler);
               _loc6_.addEventListener("ioError",configDebugLoadIOErrorHandler);
               _loc6_.load(new URLRequest("clientdevtest.xml"));
            }
         }
         GATracker.init();
         SBTracker.create();
         return m;
      }
      
      public static function isInitialized() : Boolean
      {
         return m != null;
      }
      
      private static function keyDownListener(param1:KeyboardEvent) : void
      {
         if(ExternalInterface.available && (param1.keyCode < 37 || param1.keyCode > 40))
         {
            ExternalInterface.call("handleKey",{
               "altKey":param1.altKey,
               "ctrlKey":param1.ctrlKey,
               "shiftKey":param1.shiftKey,
               "keyCode":param1.keyCode
            });
         }
         if(gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.accountType == 5)
         {
            if(!param1.ctrlKey && param1.shiftKey && !param1.altKey && param1.keyCode == 123)
            {
               if(!_client.isConnected || gMainFrame.clientInfo.forceHttpProxy)
               {
                  return;
               }
               if(_gamePlay)
               {
                  _gamePlay["reconnecting"] = true;
                  _gamePlay["showLoadProgress"](true,10);
               }
               gMainFrame.clientInfo.forceHttpProxy = true;
               _client.disconnect();
            }
         }
      }
      
      private static function onRightMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
      }
      
      private static function applyConfigVars(param1:Object) : void
      {
         for(var _loc7_ in param1)
         {
            gMainFrame.clientInfo[_loc7_] = param1[_loc7_];
         }
         var _loc8_:String = param1.ingressXt;
         var _loc3_:String = param1.ingressHProxy;
         var _loc6_:Array = [param1.smartfoxServer];
         var _loc10_:int = 1;
         while(param1.hasOwnProperty("smartfoxServer" + _loc10_))
         {
            _loc6_.push(param1["smartfoxServer" + _loc10_]);
            _loc10_++;
         }
         gMainFrame.server.setServerConfig(_loc8_,_loc3_,_loc6_,param1.smartfoxPort,param1.blueboxPort,param1.clientDebug);
         var _loc11_:String = param1.forceHttpProxy;
         gMainFrame.clientInfo.forceHttpProxy = _loc11_ == "true";
         var _loc5_:String = "";
         if(param1.hasOwnProperty("gameSessionId"))
         {
            _loc5_ = param1.gameSessionId;
            if(_loc5_ != null && _loc5_ != "")
            {
               gMainFrame.clientInfo.sessionId = int(_loc5_);
            }
         }
         var _loc12_:String = param1.build_version;
         gMainFrame.clientInfo.buildVersion = _loc12_;
         LoaderCache.buildVersion = _loc12_;
         var _loc9_:String = param1.deploy_version;
         gMainFrame.clientInfo.deployVersion = _loc9_;
         LoaderCache.deployVersion = _loc9_;
         var _loc4_:String = param1.locale;
         gMainFrame.clientInfo.locale = _loc4_;
         gMainFrame.clientInfo.websiteURL = param1.website;
         var _loc13_:String = param1.content;
         if(_loc13_ != null)
         {
            while(_loc13_.substring(_loc13_.length - 1) == "/")
            {
               _loc13_ = _loc13_.substring(0,_loc13_.length - 1);
            }
            _loc13_ += "/";
         }
         gMainFrame.clientInfo.contentURL = _loc13_;
         LoaderCache.contentURL = _loc13_;
         var _loc14_:* = param1.webRefPath == "create_account";
         gMainFrame.clientInfo.isCreateAccount = _loc14_;
         var _loc2_:* = param1.waitingMode == "true";
         gMainFrame.clientInfo.waitingMode = _loc2_;
         var _loc15_:int = int(param1.buddyRoomTimerInterval);
         gMainFrame.clientInfo.buddyRoomTimerInterval = _loc15_;
         gMainFrame.clientInfo.startUpRoom = String(param1.startupRoom);
         gMainFrame.clientInfo.worldMapRoom = "roomDefs/" + param1.worldmapRoom;
         gMainFrame.clientInfo.dangerMapRoom = "roomDefs/" + param1.dangermapRoom;
         gMainFrame.clientInfo.clientDebug = param1.clientDebug;
         gMainFrame.clientInfo.sgParams = String(param1.sg_params);
         gMainFrame.clientInfo.mdUrl = String(param1.mdUrl);
         gMainFrame.clientInfo.currentTimestamp = Number(param1.currentTimestamp);
         gMainFrame.clientInfo.sbTrackerIp = String(param1.sbStatTrackerIp);
         gMainFrame.clientInfo.sbTrackerModulator = param1.sbStatModulator;
         gMainFrame.clientInfo.authToken = param1.auth_token;
         gMainFrame.clientInfo.countryCode = param1.country;
         gMainFrame.clientInfo.playerWallHost = String(param1.playerWallHost);
         if("redemptionCode" in param1)
         {
            gMainFrame.clientInfo.redemptionCode = String(param1.redemptionCode);
         }
         gMainFrame.clientInfo.clientPlatform = !!param1.hasOwnProperty("clientPlatform") ? String(param1.clientPlatform) : Utility.getPlayerType();
         gMainFrame.clientInfo.clientPlatformVersion = !!param1.hasOwnProperty("clientPlatformVersion") ? String(param1.clientPlatformVersion) : Utility.getFlashVersion();
         gMainFrame.clientInfo.refererUuid = "referer_uuid" in param1 ? param1.referer_uuid : "";
         gMainFrame.clientInfo.selectedAvatarId = "selectedAvatarId" in param1 ? param1.selectedAvatarId : null;
         gMainFrame.clientInfo.df = "df" in param1 ? param1.df : "";
         DebugUtility.debugTrace("-configXml/flashVars info-");
         DebugUtility.debugTrace("ingressXt:" + param1.ingressXt);
         DebugUtility.debugTrace("ingressHProxy:" + param1.ingressHProxy);
         DebugUtility.debugTrace("smartfoxServer:" + param1.smartfoxServer);
         DebugUtility.debugTrace("smartfoxPort:" + param1.smartfoxPort);
         DebugUtility.debugTrace("blueboxPort:" + param1.blueboxPort);
         DebugUtility.debugTrace("gameSessionIdStr:" + _loc5_);
         DebugUtility.debugTrace("buildVersionStr:" + _loc12_);
         DebugUtility.debugTrace("deployVersionStr:" + _loc9_);
         DebugUtility.debugTrace("localeStr:" + _loc4_);
         DebugUtility.debugTrace("contentURL:" + gMainFrame.clientInfo.contentURL);
         DebugUtility.debugTrace("websiteURL:" + gMainFrame.clientInfo.websiteURL);
         DebugUtility.debugTrace("isCreateAccount:" + _loc14_ + " webRefPath:" + param1.webRefPath);
         DebugUtility.debugTrace("isWaitingMode:" + _loc2_ + " cfgVars.waitingMode:" + param1.waitingMode);
         DebugUtility.debugTrace("startUpRoom:" + gMainFrame.clientInfo.startUpRoom);
         DebugUtility.debugTrace("worldMapRoom:" + gMainFrame.clientInfo.worldMapRoom);
         DebugUtility.debugTrace("dangerMapRoom:" + gMainFrame.clientInfo.dangerMapRoom);
         DebugUtility.debugTrace("clientDebug:" + param1.clientDebug);
         DebugUtility.debugTrace("forceHttpProxy:" + param1.forceHttpProxy);
         DebugUtility.debugTrace("sgParams:" + gMainFrame.clientInfo.sgParams);
         DebugUtility.debugTrace("buddyRoomTimerInterval:" + gMainFrame.clientInfo.buddyRoomTimerInterval);
         DebugUtility.debugTrace("countryCode:" + gMainFrame.clientInfo.countryCode);
         DebugUtility.debugTrace("clientPlatform:" + gMainFrame.clientInfo.clientPlatform);
         DebugUtility.debugTrace("clientPlatformVersion:" + gMainFrame.clientInfo.clientPlatformVersion);
         _loaderCache = new LoaderCache();
         if(!gMainFrame.clientInfo.devMode && !gMainFrame.clientInfo.isCreateAccount && (_flashVarUserName == "" || !("auth_token" in param1) || param1.auth_token == null || param1.auth_token == undefined || param1.auth_token == ""))
         {
            gMainFrame.clientInfo.failedToInitiate = true;
         }
         _configLoadedCallback();
      }
      
      private static function configDebugLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.dataFormat = "text";
         _loc2_.addEventListener("complete",configDebugLoadCompleteHandler);
         _loc2_.addEventListener("ioError",configDebugTemplateLoadIOErrorHandler);
         _loc2_.load(new URLRequest("clientdevtest.template.xml"));
      }
      
      private static function configDebugTemplateLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         throw new Error("IOError reading clientdevtest.xml or clientdevtest.template.xml! ioe:" + param1);
      }
      
      private static function configDebugLoadCompleteHandler(param1:Event) : void
      {
         var _loc3_:String = null;
         var _loc4_:XML = new XML(param1.target.data);
         var _loc2_:Object = {};
         _loc2_["blueboxPort"] = "80";
         _loc2_["buddyRoomTimerInterval"] = "30000";
         _loc2_["build_version"] = "0";
         _loc2_["country"] = "US";
         _loc2_["deploy_version"] = "0";
         _loc2_["forceHttpProxy"] = "false";
         _loc2_["locale"] = "en";
         _loc2_["sbStatModulator"] = "0";
         _loc2_["sg_params"] = "";
         _loc2_["smartfoxPort"] = "443";
         _loc2_["waitingMode"] = "false";
         _loc2_["webRefPath"] = "";
         parseConfigXml(_loc2_,_loc4_);
         if(_loc4_.hasOwnProperty("envName") && _loc4_.hasOwnProperty("environments"))
         {
            _loc3_ = _loc4_.envName.text();
            if(_loc4_.environments.hasOwnProperty(_loc3_))
            {
               DebugUtility.debugTrace("configDebugLoadCompleteHandler: using environment:" + _loc3_);
               parseConfigXml(_loc2_,_loc4_.environments[_loc3_][0]);
            }
         }
         for(var _loc5_ in _loc2_)
         {
            if(_loc2_[_loc5_] is XMLList && XMLList(_loc2_[_loc5_]).length() > 1)
            {
               throw new Error("Invalid clientdevtest xml config! Found multiple tags of same name:" + _loc5_);
            }
         }
         requireConfigKey("content",_loc2_);
         requireConfigKey("mdUrl",_loc2_);
         requireConfigKey("playerWallHost",_loc2_);
         requireConfigKey("website",_loc2_);
         applyConfigVars(_loc2_);
      }
      
      private static function parseConfigXml(param1:Object, param2:XML) : void
      {
         var _loc3_:XMLList = null;
         var _loc5_:int = 0;
         applyConfigValue("blueboxPort",param1,param2);
         applyConfigValue("buddyRoomTimerInterval",param1,param2);
         applyConfigValue("build_version",param1,param2);
         applyConfigConditionally("clientDebug",param1,param2,"true","false");
         applyConfigValue("clientPlatform",param1,param2);
         applyConfigValue("clientPlatformVersion",param1,param2);
         applyConfigValue("content",param1,param2);
         applyConfigValue("country",param1,param2);
         applyConfigValue("dangermapRoom",param1,param2);
         applyConfigValue("deploy_version",param1,param2);
         applyConfigValue("df",param1,param2);
         applyConfigValue("forceHttpProxy",param1,param2);
         applyConfigValue("ingressHProxy",param1,param2);
         applyConfigValue("ingressXt",param1,param2);
         applyConfigValue("locale",param1,param2);
         applyConfigValue("mdUrl",param1,param2);
         applyConfigValue("playerWallHost",param1,param2);
         applyConfigValue("sbStatModulator",param1,param2);
         applyConfigValue("smartfoxPort",param1,param2);
         applyConfigValue("smartfoxServer",param1,param2);
         applyConfigValue("startupRoom",param1,param2);
         applyConfigValue("waitingMode",param1,param2);
         applyConfigValue("webRefPath",param1,param2);
         applyConfigValue("website",param1,param2);
         applyConfigValue("worldmapRoom",param1,param2);
         if(param2.hasOwnProperty("autoLogins"))
         {
            _loc3_ = param2.autoLogins.children();
            _loc5_ = 0;
            for each(var _loc4_ in _loc3_)
            {
               _loc5_++;
               gMainFrame.clientInfo["autoLogin" + _loc5_] = [String(_loc4_.name.text()),String(_loc4_.token.text())];
            }
         }
         if(param2.hasOwnProperty("local"))
         {
            if(param2.local.text() == "false")
            {
               gMainFrame.clientInfo.localMode = false;
               LoaderCache.localMode = false;
            }
            else
            {
               gMainFrame.clientInfo.localMode = true;
            }
         }
         var _loc7_:int = 1;
         while(param2.hasOwnProperty("smartfoxServer" + _loc7_))
         {
            param1["smartfoxServer" + _loc7_] = param2["smartfoxServer" + _loc7_].text();
            _loc7_++;
         }
         var _loc6_:int = 1;
         while(param2.hasOwnProperty("blueboxServer" + _loc6_))
         {
            param1["blueboxServer" + _loc6_] = param2["blueboxServer" + _loc6_].text();
            _loc6_++;
         }
      }
      
      private static function applyConfigValue(param1:String, param2:Object, param3:XML) : void
      {
         if(param3.hasOwnProperty(param1))
         {
            param2[param1] = param3[param1].text();
         }
      }
      
      private static function applyConfigConditionally(param1:String, param2:Object, param3:XML, param4:String, param5:String) : void
      {
         if(param3.hasOwnProperty(param1))
         {
            param2[param1] = param3[param1].text();
            if(param2[param1] != param4)
            {
               param2[param1] = param5;
            }
         }
      }
      
      private static function requireConfigKey(param1:String, param2:Object) : void
      {
         if(!param2.hasOwnProperty(param1))
         {
            throw new Error("Missing required value in clientdevtest xml config! " + param1);
         }
      }
      
      private static function handleResize(param1:int, param2:int) : void
      {
         var _loc3_:Number = 100 - Math.min(Math.min(30,(param1 / 900 - 1) * 30),Math.min(30,(param2 / 550 - 1) * 30));
         if(_stage.contentsScaleFactor > 1)
         {
            gMainFrame.currStageQuality = "low";
         }
         else
         {
            gMainFrame.currStageQuality = "medium";
         }
         gMainFrame.stage.quality = gMainFrame.currStageQuality;
         RoomManagerWorld.instance.updateRoomZoom(_loc3_);
      }
      
      public function init(param1:Singleton, param2:String, param3:Stage) : void
      {
         _path = param2;
         _stage = param3;
         _client = new SFClient();
         userInfo = new UserInfoCache();
         userInfo.init();
         clientInfo = {};
         clientInfo.invisMode = false;
         classNames = null;
      }
      
      public function get server() : SFClient
      {
         return _client;
      }
      
      public function get path() : String
      {
         return _path;
      }
      
      override public function get stage() : Stage
      {
         return _stage;
      }
      
      public function get currStageQuality() : String
      {
         return _currStageQuality;
      }
      
      public function set currStageQuality(param1:String) : void
      {
         _currStageQuality = param1;
      }
      
      public function set createAccount(param1:DisplayObjectContainer) : void
      {
         _createAccount = param1;
      }
      
      public function get createAccount() : DisplayObjectContainer
      {
         return _createAccount;
      }
      
      public function set waitingRoom(param1:DisplayObjectContainer) : void
      {
         _waitingRoom = param1;
      }
      
      public function get waitingRoom() : DisplayObjectContainer
      {
         return _waitingRoom;
      }
      
      public function set gamePlay(param1:DisplayObjectContainer) : void
      {
         _gamePlay = param1;
      }
      
      public function get gamePlay() : DisplayObjectContainer
      {
         return _gamePlay;
      }
      
      public function get layerManager() : LayerManager
      {
         return (_gamePlay as GamePlay).layerManager;
      }
      
      public function get loaderCache() : LoaderCache
      {
         return _loaderCache;
      }
      
      public function set layerInfo(param1:Object) : void
      {
         _layerInfo = param1;
         ImageServerURL.instance.layerInfo = param1;
      }
      
      public function get myFlashVarUserName() : String
      {
         return _flashVarUserName;
      }
      
      public function set myFlashVarUserName(param1:String) : void
      {
         _flashVarUserName = param1;
      }
      
      public function isInMinigame() : Boolean
      {
         return _gamePlay != null && _gamePlay["isInMinigame"]();
      }
      
      public function setAvatarOffsets(param1:Array) : void
      {
         LayerAnim.avOffsets = param1;
      }
      
      public function switchServersIfNeeded(param1:String) : Boolean
      {
         DebugUtility.debugTrace("switchServersIfNeeded called with newNode:" + param1);
         var _loc2_:* = param1;
         DebugUtility.debugTrace("checking new node:" + _loc2_ + " vs old node:" + _client.serverIp);
         if(_client.serverIp == _loc2_)
         {
            return false;
         }
         MinigameManager.readySelfForPvpGame(null,"",false);
         MinigameManager.readySelfForQuickMinigame(null,false);
         GuiManager.grayOutHudItemsForPrivateLobby(false);
         GuiManager.closeJoinGamesPopup();
         AvatarManager.playerCustomPVP = null;
         _gamePlay["reconnecting"] = true;
         _gamePlay["showLoadProgress"](true,10);
         _client.switchServerNode(_loc2_);
         _client.disconnect();
         return true;
      }
   }
}

class Singleton
{
   public function Singleton()
   {
      super();
   }
}
