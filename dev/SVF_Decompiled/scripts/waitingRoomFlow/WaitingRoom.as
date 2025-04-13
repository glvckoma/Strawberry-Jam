package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.ResourceStack;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.system.Security;
   import flash.utils.Timer;
   import loadProgress.LoadProgress;
   
   public class WaitingRoom extends MovieClip
   {
      public var mainLayer:DisplayLayer;
      
      public var loadLayer:DisplayLayer;
      
      private var _waitingRoomFlashVars:Object;
      
      private var _resourceStack:ResourceStack;
      
      private var _pollTimer:Timer;
      
      private var _username:String;
      
      private var _waitingRoom:MovieClip;
      
      public function WaitingRoom(param1:Object)
      {
         super();
         _waitingRoomFlashVars = param1;
      }
      
      public function waitCtorHelper() : void
      {
         init();
      }
      
      public function init() : void
      {
         Security.allowDomain("*");
         _username = _waitingRoomFlashVars.username;
         mainLayer = new DisplayLayer();
         addChild(mainLayer);
         _resourceStack = new ResourceStack(gMainFrame.path,gMainFrame.loaderCache.openFile);
         _resourceStack.pushClass(new ConnectToWaitingRoomServerResourceStackable(_username),false);
         _resourceStack.pushClass(new LoadWaitingRoomMediaResourceStackable(setWaitingRoomMovieClip),false);
         _resourceStack.start(waitingRoomSetupDone);
         loadLayer = new DisplayLayer();
         addChild(loadLayer);
         LoadProgress.init(loadLayer);
         gMainFrame.stage.quality = gMainFrame.currStageQuality;
      }
      
      public function destroy() : void
      {
         _pollTimer.reset();
         _pollTimer = null;
      }
      
      public function setWaitingRoomMovieClip(param1:MovieClip) : void
      {
         _waitingRoom = param1;
         mainLayer.addChild(_waitingRoom);
      }
      
      private function waitingRoomSetupDone() : void
      {
         DebugUtility.debugTrace("waitingRoom setup done - starting poll timer");
         _pollTimer = new Timer(5000);
         _pollTimer.addEventListener("timer",handleWaitingRoomPollTimer);
         _pollTimer.start();
         LoadProgress.show(false);
      }
      
      private function handleWaitingRoomPollTimer(param1:TimerEvent) : void
      {
         var _loc2_:URLLoader = null;
         try
         {
            _loc2_ = new URLLoader();
            _loc2_.dataFormat = "text";
            _loc2_.addEventListener("complete",pollCompleteHandler,false,0,true);
            DebugUtility.debugTrace("ConnectToWaitingRoomServerResourceStackable init() - connect url:http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/poll username:" + _username);
            _loc2_.load(new URLRequest("http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/poll"));
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error polling waitingRoom server:" + e.getStackTrace());
            LoadProgress.show(true,"Error polling for full server - please try again later");
            _pollTimer.reset();
            return;
         }
      }
      
      private function pollCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         if(_loc2_ == "")
         {
            LoadProgress.show(true,"Error with poll of waiting room server - please try again later");
            return;
         }
         if(_loc2_ == "enter")
         {
            LoadProgress.show(true,"Ready- please refresh to log in now!");
         }
      }
   }
}

