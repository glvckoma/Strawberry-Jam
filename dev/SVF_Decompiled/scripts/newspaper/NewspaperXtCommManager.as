package newspaper
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   
   public class NewspaperXtCommManager
   {
      private static var _seenCallback:Function;
      
      public function NewspaperXtCommManager()
      {
         super();
      }
      
      public static function sendSetPageSeenRequest(param1:int, param2:Function = null) : void
      {
         _seenCallback = param2;
         gMainFrame.server.setXtObject_Str("nps",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: NewspaperXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         var _loc3_:* = _loc2_[0];
         if("nps" === _loc3_)
         {
            NewspaperManager.updateNewspaperData(_loc2_[2],_loc2_[3]);
            if(_seenCallback != null)
            {
               _seenCallback(_loc2_[2],_loc2_[3]);
               _seenCallback = null;
            }
         }
      }
   }
}

