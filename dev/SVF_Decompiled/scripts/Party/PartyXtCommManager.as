package Party
{
   import com.sbi.client.SFEvent;
   import gui.DarkenManager;
   
   public class PartyXtCommManager
   {
      private static var _sphpUsername:String;
      
      private static var _sphpCallback:Function;
      
      private static var _spnCallback:Function;
      
      private static var _spnUsername:String;
      
      private static var _smCallback:Function;
      
      public function PartyXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
      }
      
      public static function sendJoinPartyRequest(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("sj",[param1]);
      }
      
      public static function sendPartyListRequest() : void
      {
         gMainFrame.server.setXtObject_Str("sl",[]);
      }
      
      public static function sendCustomPartyListRequest(param1:int, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("slp",[param1,param2]);
      }
      
      public static function sendCustomPartyJoinRequest(param1:String) : void
      {
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("sjp",[param1]);
      }
      
      public static function sendCustomPartyHostRequest(param1:int, param2:Array, param3:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("scp",[param1,param2[0],param2[1],param2[2],param3]);
      }
      
      public static function sendCustomPartyIsHosting(param1:String, param2:String, param3:Function) : void
      {
         if(param2 != null && param2 != "")
         {
            _sphpUsername = param1;
            _sphpCallback = param3;
            gMainFrame.server.setXtObject_Str("sphp",[param2]);
         }
         else if(param3 != null)
         {
            param3(0,null);
         }
      }
      
      public static function sendCustomPartyNodeId(param1:String, param2:String, param3:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _spnUsername = param1;
         _spnCallback = param3;
         gMainFrame.server.setXtObject_Str("spn",[param2]);
      }
      
      public static function sendPartyMasterpiece(param1:Function) : void
      {
         _smCallback = param1;
         gMainFrame.server.setXtObject_Str("sm",[]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "sl":
               PartyManager.partyListResponse(_loc2_);
               break;
            case "sj":
               PartyManager.roomSoireeResponse(_loc2_);
               break;
            case "slp":
               PartyManager.customPartyListResponse(_loc2_);
               break;
            case "scp":
               DarkenManager.showLoadingSpiral(false);
               PartyManager.customPartyCreateResponse(_loc2_);
               break;
            case "sphp":
               PartyManager.customPartyIsHostingResponse(_loc2_,_sphpUsername,_sphpCallback);
               _sphpCallback = null;
               _sphpUsername = "";
               break;
            case "sjp":
               DarkenManager.showLoadingSpiral(false);
               PartyManager.customPartyJoinResponse(_loc2_);
               break;
            case "spk":
               PartyManager.customPartyKillResponse(_loc2_);
               break;
            case "spn":
               DarkenManager.showLoadingSpiral(false);
               if(_spnCallback != null)
               {
                  _spnCallback(_spnUsername,_loc2_);
                  _spnCallback = null;
                  _spnUsername = "";
               }
               break;
            case "sm":
               if(_smCallback != null)
               {
                  _smCallback(_loc2_[2]);
                  _smCallback = null;
                  break;
               }
         }
      }
   }
}

