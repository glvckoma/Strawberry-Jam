package
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import gui.GuiManager;
   
   public class VersionXtCommManager
   {
      public function VersionXtCommManager()
      {
         super();
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: VersionXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         var _loc3_:* = _loc2_[0];
         if("userDataVersion" !== _loc3_)
         {
            throw new Error("VersionXtCommManager illegal data:" + _loc2_[0]);
         }
         avatarVersionResponse(_loc2_);
      }
      
      private static function avatarVersionResponse(param1:Array) : void
      {
         GuiManager.openVersionPopup(param1[2] == "1");
      }
   }
}

