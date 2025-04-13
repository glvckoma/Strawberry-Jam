package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import flash.display.MovieClip;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   import resource.BaseResourceStackable;
   
   public class LoadWaitingRoomMediaResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      private const WAITING_ROOM_MEDIA_ID:int = 1678;
      
      public var waitingRoom:MovieClip;
      
      private var _setWaitingRoomClipCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      public function LoadWaitingRoomMediaResourceStackable(param1:Function)
      {
         super();
         _setWaitingRoomClipCallback = param1;
      }
      
      override public function init(param1:Function) : void
      {
         super.init(param1);
         try
         {
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(1678,handleWaitingRoomMediaLoaded);
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error loading waitingRoom media:" + e.getStackTrace());
            LoadProgress.show(true,"Error loading waiting room - please try again later");
            return;
         }
      }
      
      private function handleWaitingRoomMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _setWaitingRoomClipCallback(param1);
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

