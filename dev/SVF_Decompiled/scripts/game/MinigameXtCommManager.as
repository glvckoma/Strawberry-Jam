package game
{
   import com.sbi.client.SFEvent;
   
   public class MinigameXtCommManager
   {
      public static const PVP_REQUEST_OR_ACCEPT:int = 0;
      
      public static const PVP_DENY_DENIED_OR_CANCEL:int = 1;
      
      private static var _miCallback:Function;
      
      public function MinigameXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         XtReplyDemuxer.addModule(handleXtReply,"m");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendMinigameInfoRequest(param1:Array, param2:Boolean = false, param3:Function = null) : void
      {
         _miCallback = param3;
         gMainFrame.server.setXtObject_Str("mi",param1,true,param2);
      }
      
      public static function sendMinigameJoinRequest(param1:int, param2:Boolean = false, param3:Boolean = false, param4:int = 0, param5:int = -1) : void
      {
         gMainFrame.server.setXtObject_Str("mj",[param1,param3 ? "1" : "0",param4,param5],true,param2);
      }
      
      public static function sendMinigameStartRequest(param1:int, param2:Boolean = false) : void
      {
         gMainFrame.server.setXtObject_Str("ms",[param1],true,param2);
      }
      
      public static function sendMinigameLeaveRequest() : void
      {
         gMainFrame.server.setXtObject_Str("ml",null,true,true);
      }
      
      public static function sendMinigameMessageRequest(param1:Array, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("mm",param1,true,param2);
      }
      
      public static function sendMinigamePvpMsg(param1:int, param2:int, param3:String = "") : void
      {
         if(param3 != "")
         {
            gMainFrame.server.setXtObject_Str("mp",[param1,param2,param3]);
         }
         else
         {
            gMainFrame.server.setXtObject_Str("mp",[param1,param2]);
         }
      }
      
      public static function sendMinigameCustomPvpJoinMsg(param1:int, param2:int, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("mcp",[param1,param2,param3]);
      }
      
      public static function sendMinigameLeaderboardRequest(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("mlb",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:* = param1.obj;
         switch(_loc2_[0])
         {
            case "mi":
               handleMinigameInfo(_loc2_);
               break;
            case "ms":
               MinigameManager.startGame(_loc2_);
               break;
            case "mj":
               MinigameManager.joinGameResponse(_loc2_);
               break;
            case "ml":
            case "mm":
               MinigameManager.messageGame(_loc2_);
               break;
            case "me":
               MinigameManager.minigameEndResponse(_loc2_);
               break;
            case "mr":
               MinigameManager.minigameRoomRemovedResponse(_loc2_);
               break;
            case "mp":
               MinigameManager.pvpResponse(_loc2_);
               break;
            case "mg":
               MinigameManager.minigameGems(_loc2_);
               break;
            case "ma":
               MinigameManager.minigamePetMastery(_loc2_);
               break;
            case "mlb":
               MinigameManager.leaderBoardResponse(_loc2_);
               break;
            default:
               throw new Error("MinigameManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function handleMinigameInfo(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc5_:MinigameInfo = null;
         var _loc2_:int = 2;
         var _loc4_:int = parseInt(param1[_loc2_++]);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = new MinigameInfo();
            _loc5_.init(parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),param1[_loc2_++],param1[_loc2_++],parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseFloat(param1[_loc2_++]),null,parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]),parseInt(param1[_loc2_++]));
            MinigameManager.minigameInfoCache.setMinigameInfo(_loc5_.gameDefId,_loc5_);
            _loc3_++;
         }
         if(_miCallback != null)
         {
            _miCallback();
            _miCallback = null;
         }
      }
   }
}

