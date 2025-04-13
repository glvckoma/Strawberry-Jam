package
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.ResourceStack;
   import com.sbi.popup.SBStandardPopup;
   import createAccountFlow.CreateAccount;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.ui.Mouse;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import loadProgress.LoadProgress;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import resource.LoadAvatarCarouselResourceStackable;
   import resource.LoadCursorResourceStackable;
   import room.DebugGUITextbox;
   import waitingRoomFlow.WaitingRoom;
   
   public class AJClient extends Sprite
   {
      private static var _globalDebugLog:DebugGUITextbox;
      
      private var _resourceStackLoader:ResourceStack;
      
      public function AJClient()
      {
         super();
         addEventListener("addedToStage",addedToStageHandler);
      }
      
      public static function get globalDebugLog() : DebugGUITextbox
      {
         return _globalDebugLog;
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         removeEventListener("addedToStage",addedToStageHandler);
         if(Capabilities.playerType != "Desktop")
         {
            Security.allowDomain("*");
            Security.allowInsecureDomain("*");
         }
         var _loc4_:Boolean = ExternalInterface.available;
         if(_loc4_)
         {
            DebugUtility.debugTrace("addedToStageHandler - extIntAvail is true");
            DebugUtility.debugTrace("mrc dm init ctor starting up call returned:" + ExternalInterface.call("mrc",["dm","AJClient addedToStageHandler starting up"]));
            ExternalInterface.call("handleGAEvent","flashStarted");
         }
         else
         {
            DebugUtility.debugTrace("addedToStageHandler - extIntAvail is false");
         }
         if(!MainFrame.isInitialized())
         {
            if(parent != null)
            {
               if(parent.hasOwnProperty("flashVars"))
               {
                  _loc2_ = parent["flashVars"];
               }
               else
               {
                  _loc2_ = parent.loaderInfo.parameters;
               }
            }
            else
            {
               _loc2_ = loaderInfo.parameters;
            }
            DebugUtility.debugTrace("addedToStageHandler - printing loaderInfo parameters flashvars...");
            _loc3_ = 0;
            for(var _loc5_ in _loc2_)
            {
               DebugUtility.debugTrace("  flashvar " + _loc5_ + ":" + _loc2_[_loc5_]);
               _loc3_++;
            }
            DebugUtility.debugTrace("addedToStageHandler - ...done printing loaderInfo parameters flashvars - i:" + _loc3_);
            MainFrame.handleLocalExternalCall = GamePlay.handleLocalExternalCall;
            MainFrame.getInstance(_loc2_,setupInit,"",this);
            LoadProgress.updateProgress(2);
            _globalDebugLog = new DebugGUITextbox(this,"","Debug Log [F4]",false,true,true,750,276,true);
            _globalDebugLog.x = 80;
            _globalDebugLog.y = 50;
            DebugUtility.setDebugGUIHandler(_globalDebugLog.appendHtml);
            loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError",handleGlobalErrors);
         }
         DebugUtility.debugTrace("AJClient addedToStageHandler finished");
      }
      
      public function setupInit() : void
      {
         gMainFrame.stage.addEventListener("Localization",LocalizationManager.onLocalizationEvent,false,0,true);
         LocalizationManager.currentLanguage = LocalizationManager.accountLanguage = LocalizationManager.getLanguageIdForLocale(gMainFrame.clientInfo.locale);
         LocalizationManager.countryCode = gMainFrame.clientInfo.countryCode;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(uint("1023" + LocalizationManager.currentLanguage),LocalizationXtCommManager.onLocalizationListResponse,loadResourceItems,2);
         DefPacksDefHelper.mediaArray["1023" + LocalizationManager.currentLanguage] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(uint("1055" + LocalizationManager.accountLanguage),LocalizationXtCommManager.onPreferredLocalizationListResponse,null,2);
         DefPacksDefHelper.mediaArray["1055" + LocalizationManager.accountLanguage] = _loc1_;
      }
      
      public function loadResourceItems() : void
      {
         LoadProgress.updateProgress(3);
         Utility.init(DarkenManager.showLoadingSpiral,DarkenManager.darken,DarkenManager.unDarken);
         _resourceStackLoader = new ResourceStack(gMainFrame.path,gMainFrame.loaderCache.openFile);
         _resourceStackLoader.pushFile("assets/sharedFonts.swf",true);
         _resourceStackLoader.pushFile("assets/HUDAssets.swf",true);
         if(gMainFrame.clientInfo.isCreateAccount)
         {
            _resourceStackLoader.pushClass(new LoadAvatarCarouselResourceStackable());
         }
         if(Mouse["supportsNativeCursor"])
         {
            _resourceStackLoader.pushClass(new LoadCursorResourceStackable());
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("aj_initialized");
         }
         if("failedToInitiate" in gMainFrame.clientInfo && gMainFrame.clientInfo.failedToInitiate == true)
         {
            _resourceStackLoader.start(onInitiationFailure);
         }
         else if(gMainFrame.clientInfo.isCreateAccount)
         {
            _resourceStackLoader.start(setupCreateAccount);
         }
         else if(gMainFrame.clientInfo.waitingMode)
         {
            _resourceStackLoader.start(setupWaitingRoom);
         }
         else
         {
            _resourceStackLoader.start(setupGamePlay);
         }
      }
      
      public function setupCreateAccount() : void
      {
         var _loc1_:CreateAccount = new CreateAccount(gMainFrame.clientInfo);
         addChild(_loc1_);
         gMainFrame.createAccount = _loc1_;
         _loc1_.loginCtorHelper();
      }
      
      public function setupWaitingRoom() : void
      {
         var _loc1_:WaitingRoom = new WaitingRoom(gMainFrame.clientInfo);
         addChild(_loc1_);
         gMainFrame.waitingRoom = _loc1_;
         _loc1_.waitCtorHelper();
      }
      
      public function setupGamePlay(param1:Event = null, param2:Event = null) : void
      {
         DebugUtility.debugTrace("setupGamePlay - loginEvt:" + param1 + " connectEvt:" + param2);
         if(gMainFrame.createAccount)
         {
            if(contains(gMainFrame.createAccount))
            {
               removeChild(gMainFrame.createAccount);
            }
            gMainFrame.createAccount = null;
            _resourceStackLoader = null;
         }
         DebugUtility.debugTrace("setupGamePlay - constructing GamePlay - gMainFrame.clientInfo:" + gMainFrame.clientInfo);
         var _loc3_:GamePlay = new GamePlay(gMainFrame.clientInfo,param1,param2);
         addChild(_loc3_);
         gMainFrame.gamePlay = _loc3_;
         DebugUtility.debugTrace("setupGamePlay - gp:" + _loc3_ + " calling worldCtorHelper");
         _loc3_.worldCtorHelper();
      }
      
      private function onInitiationFailure() : void
      {
         new SBStandardPopup(gMainFrame.stage,LocalizationManager.translateIdOnly(11202),false);
      }
      
      private function createAvatar() : void
      {
      }
      
      private function shardSelection() : void
      {
      }
      
      private function enterGame() : void
      {
      }
      
      private function handleGlobalErrors(param1:UncaughtErrorEvent) : void
      {
         GlobalErrorCatch.globalErrorListener(param1);
      }
   }
}

