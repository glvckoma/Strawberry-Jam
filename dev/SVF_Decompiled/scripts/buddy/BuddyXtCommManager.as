package buddy
{
   import com.sbi.client.SFEvent;
   
   public class BuddyXtCommManager
   {
      private static var _requestCallback:Function;
      
      private static var _buddyRoomCallback:Function;
      
      private static var _buddyBlockInfoInProgress:Boolean;
      
      private static var _tryToAddBuddyAfterUnblock:Boolean;
      
      public function BuddyXtCommManager()
      {
         super();
      }
      
      public static function sendBuddyListRequest(param1:Function = null) : void
      {
         _requestCallback = param1;
         gMainFrame.server.setXtObject_Str("bl",[]);
      }
      
      public static function sendBuddyAddRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("ba",[param1]);
      }
      
      public static function sendBuddyConfirmRequest(param1:String, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("bc",[param1,param2 ? "1" : "0"]);
      }
      
      public static function sendBuddyDeleteRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bd",[param1]);
      }
      
      public static function sendBuddyRoomRequest(param1:String, param2:Function = null) : void
      {
         _buddyRoomCallback = param2;
         gMainFrame.server.setXtObject_Str("br",[param1],true,false,false);
      }
      
      public static function sendBuddyBlockRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("bb",[param1]);
      }
      
      public static function sendBuddyUnblockRequest(param1:String, param2:Boolean = false) : void
      {
         _tryToAddBuddyAfterUnblock = param2;
         gMainFrame.server.setXtObject_Str("bu",[param1]);
      }
      
      public static function sendBuddyBlockInfoRequest(param1:String) : void
      {
         if(!_buddyBlockInfoInProgress && param1 != null && param1 != "")
         {
            _buddyBlockInfoInProgress = true;
            gMainFrame.server.setXtObject_Str("bi",[param1]);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "bl":
               buddyListblockedListResponse(_loc2_);
               break;
            case "ba":
               buddyAddRequestResponse(int(_loc2_[2]),_loc2_[3],_loc2_[4]);
               break;
            case "bs":
               buddyStatusResponse(_loc2_);
               break;
            case "bd":
               buddyDeleteResponse(_loc2_[2]);
               break;
            case "br":
               buddyRoomResponse(_loc2_);
               break;
            case "bb":
               buddyBlockResponse(_loc2_);
               break;
            case "bu":
               buddyUnblockResponse(_loc2_);
               break;
            case "bi":
               buddyIsBlockingMeResponse(_loc2_);
               break;
            default:
               throw new Error("BuddyXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function buddyListblockedListResponse(param1:Object) : void
      {
         if(param1[2] == "0")
         {
            BuddyManager.buddyListResponseHandler(param1);
         }
         else
         {
            BuddyManager.blockedListResponseHandler(param1);
         }
         if(_requestCallback != null)
         {
            _requestCallback();
            _requestCallback = null;
         }
      }
      
      private static function buddyAddRequestResponse(param1:int, param2:String, param3:int) : void
      {
         BuddyManager.buddyAddRequestResponseHandler(param1,param2,param3);
      }
      
      private static function buddyStatusResponse(param1:Object) : void
      {
         if(param1[2] == "1")
         {
            BuddyManager.buddyStatusResponseHandler(param1[3],param1[4],param1[5],param1[6] == "1",int(param1[7]),int(param1[8]),null,param1[9],param1[10],param1[11]);
         }
         else
         {
            BuddyManager.buddyStatusResponseHandler(param1[3],param1[4],param1[5],param1[6] == "1",int(param1[7]),int(param1[8]),param1[9]);
         }
      }
      
      private static function buddyDeleteResponse(param1:String) : void
      {
         BuddyManager.buddyDeleteResponseHandler(param1);
      }
      
      private static function buddyRoomResponse(param1:Object) : void
      {
         var _loc3_:String = param1[2];
         var _loc2_:String = param1[3];
         var _loc4_:* = param1[5] == "1";
         BuddyManager.buddyRoomResponseHandler(_loc3_,_loc2_,param1[4],_loc4_);
         if(_buddyRoomCallback != null)
         {
            _buddyRoomCallback(_loc3_,_loc2_,_loc4_);
            _buddyRoomCallback = null;
         }
      }
      
      private static function buddyBlockResponse(param1:Object) : void
      {
         BuddyManager.buddyBlockResponseHandler(param1[2],param1[3] == "1");
      }
      
      private static function buddyUnblockResponse(param1:Object) : void
      {
         BuddyManager.buddyUnblockResponseHandler(param1[2],param1[3] == "1",_tryToAddBuddyAfterUnblock);
      }
      
      private static function buddyIsBlockingMeResponse(param1:Object) : void
      {
         BuddyManager.buddyBlockInfoResponseHandler(param1[2],param1[3] == "1");
         _buddyBlockInfoInProgress = false;
      }
   }
}

