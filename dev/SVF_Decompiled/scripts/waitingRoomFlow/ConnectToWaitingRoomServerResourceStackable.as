package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import loadProgress.LoadProgress;
   import resource.BaseResourceStackable;
   
   public class ConnectToWaitingRoomServerResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      private var _username:String;
      
      public function ConnectToWaitingRoomServerResourceStackable(param1:String)
      {
         super();
         _username = param1;
      }
      
      override public function init(param1:Function) : void
      {
         var _loc2_:URLLoader = null;
         super.init(param1);
         try
         {
            _loc2_ = new URLLoader();
            _loc2_.dataFormat = "text";
            _loc2_.addEventListener("complete",connectCompleteHandler,false,0,true);
            DebugUtility.debugTrace("ConnectToWaitingRoomServerResourceStackable init() - connect url:http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/connect username:" + _username);
            _loc2_.load(new URLRequest("http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/connect"));
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error connecting to waitingRoom server:" + e.getStackTrace());
            LoadProgress.show(true,"Error waiting for full server - please try again later");
            return;
         }
      }
      
      private function connectCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         DebugUtility.debugTrace("my status is:" + _loc2_);
         if(_loc2_ == "")
         {
            LoadProgress.show(true,"Error connecting to waiting room server - please try again later");
            return;
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

