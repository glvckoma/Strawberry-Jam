package nodeHop
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   
   public class NodeHopXtCommManager
   {
      public function NodeHopXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendNodeHopForDrainRequest() : void
      {
         gMainFrame.server.setXtObject_Str("nd",[]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         DebugUtility.debugTrace("data:" + _loc2_);
         var _loc3_:* = _loc2_[0];
         if("nd" !== _loc3_)
         {
            throw new Error("NodeHop unknown data:" + _loc2_[0]);
         }
         handleNodeHopDrainResponse(_loc2_);
      }
      
      private static function handleNodeHopDrainResponse(param1:Array) : void
      {
         Utility.reloadSWFOrGetIp(true,true,param1[2]);
      }
   }
}

