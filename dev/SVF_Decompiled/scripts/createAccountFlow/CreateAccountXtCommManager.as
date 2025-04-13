package createAccountFlow
{
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import localization.LocalizationManager;
   
   public class CreateAccountXtCommManager
   {
      public static const LOGINAVAILABLE_TYPE_USERNAME:int = 0;
      
      public static const LOGINAVAILABLE_TYPE_AVATARNAME:int = 1;
      
      public static const LOGINAVAILABLE_TYPE_SUGGESTIONS:int = 2;
      
      public static var logIn:CreateAccount;
      
      private static var _laReturnType:int;
      
      public function CreateAccountXtCommManager()
      {
         super();
      }
      
      public static function init(param1:CreateAccount) : void
      {
         logIn = param1;
         _laReturnType = -1;
         XtReplyDemuxer.addModule(handleXtReply,"l");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function sendLoginAvailableRequest(param1:int, param2:String, param3:int, param4:int, param5:int) : void
      {
         _laReturnType = param1;
         gMainFrame.server.setXtObject_Str("la",[param1,param2,param3,LocalizationManager.isCurrLanguageReversed() ? param5 : param4,LocalizationManager.isCurrLanguageReversed() ? param4 : param5,LocalizationManager.currentLanguage,gMainFrame.clientInfo.deployVersion],false);
      }
      
      public static function sendLoginMXLookup(param1:String, param2:Boolean = true) : void
      {
         gMainFrame.server.setXtObject_Str("le",[param1,gMainFrame.clientInfo.deployVersion,param2 ? "1" : "0"],false);
      }
      
      public static function sendLoginCreateRequest(param1:Array, param2:Array) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 2;
         var _loc4_:Array = [param1[_loc5_++],param1[_loc5_++],param1[_loc5_++],param1[_loc5_++],param1[_loc5_++],param2[_loc3_++],param2[_loc3_++],param2[_loc3_++],param2[_loc3_++],LocalizationManager.accountLanguage,gMainFrame.clientInfo.countryCode,gMainFrame.clientInfo.deployVersion];
         if(gMainFrame.clientInfo.refererUuid != null && gMainFrame.clientInfo.refererUuid != "")
         {
            _loc4_.push(gMainFrame.clientInfo.refererUuid);
         }
         _loc3_ += 4;
         if(_loc5_ != param1.length)
         {
            throw new Error("Expected end of loginCreate data array lcdi:" + _loc5_ + " did not match length:" + param1.length + "!");
         }
         if(_loc3_ != param2.length)
         {
            throw new Error("Expected end of loginNew data array lndi:" + _loc3_ + " did not match length:" + param2.length + "!");
         }
         gMainFrame.server.setXtObject_Str("lc",_loc4_,gMainFrame.server.isWorldZone);
      }
      
      public static function sendLoginNewRequest(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = [param1[_loc3_++],param1[_loc3_++],param1[_loc3_++],param1[_loc3_++],param1[_loc3_++],param1[_loc3_++]];
         var _loc4_:Array = param1[_loc3_++];
         if(_loc3_ != param1.length)
         {
            throw new Error("Expected end of loginNew data array lndi:" + _loc3_ + " did not match length:" + param1.length + "!");
         }
         loginNewAvatarHelper(_loc4_,_loc2_);
         gMainFrame.server.setXtObject_Str("ln",_loc2_,gMainFrame.server.isWorldZone);
      }
      
      private static function loginNewAvatarHelper(param1:Array, param2:Array) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = int(param1.length);
         param2.push(_loc4_);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            param2.push(param1[_loc3_].defId);
            _loc3_++;
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         DebugUtility.debugTrace("data:" + _loc2_);
         switch(_loc2_[0])
         {
            case "la":
               logIn.handleLoginAvailable(_loc2_,_laReturnType);
               break;
            case "lc":
               logIn.handleLoginCreate(_loc2_);
               break;
            default:
               throw new Error("LogIn illegal data:" + _loc2_[0]);
         }
      }
   }
}

