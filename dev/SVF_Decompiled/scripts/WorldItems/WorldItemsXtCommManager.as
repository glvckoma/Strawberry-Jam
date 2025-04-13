package WorldItems
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   
   public class WorldItemsXtCommManager
   {
      private static var _witCallback:Function;
      
      public function WorldItemsXtCommManager()
      {
         super();
      }
      
      public static function sendAcceptGift(param1:int, param2:int = 0, param3:uint = 0, param4:Function = null) : void
      {
         _witCallback = param4;
         gMainFrame.server.setXtObject_Str("wig",[param1,param2,param3]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: WorldItemsXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         var _loc3_:* = _loc2_[0];
         if("wig" === _loc3_)
         {
            if(_witCallback != null)
            {
               _witCallback(_loc2_[2],_loc2_[3]);
               _witCallback = null;
            }
         }
      }
   }
}

