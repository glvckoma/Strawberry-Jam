package buddy
{
   import com.sbi.client.SFEvent;
   
   public class ReferAFriendXtCommManager
   {
      private static var _codeRequestCallback:Function;
      
      private static var _hasReferralAssociateCallback:Function;
      
      private static var _referralAssociationCallback:Function;
      
      private static var _referralReferralsCallback:Function;
      
      public function ReferAFriendXtCommManager()
      {
         super();
      }
      
      public static function sendCodeRequest(param1:Function) : void
      {
         _codeRequestCallback = param1;
         gMainFrame.server.setXtObject_Str("refc",[]);
      }
      
      public static function sendHasReferralAssociate(param1:Function) : void
      {
         _hasReferralAssociateCallback = param1;
         gMainFrame.server.setXtObject_Str("refh",[]);
      }
      
      public static function sendReferralAssociation(param1:Function, param2:String) : void
      {
         _referralAssociationCallback = param1;
         gMainFrame.server.setXtObject_Str("refa",[param2]);
      }
      
      public static function sendReferralReferralsRequest(param1:Function, param2:int, param3:int) : void
      {
         _referralReferralsCallback = param1;
         gMainFrame.server.setXtObject_Str("refr",[param2,param3]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "refc":
               codeRequestResponse(_loc2_);
               break;
            case "refa":
               referralAssociationResponse(_loc2_);
               break;
            case "refh":
               referralHasAssociateResponse(_loc2_);
               break;
            case "refr":
               referralReferralsResponse(_loc2_);
               break;
            default:
               throw new Error("ReferAFriendXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function codeRequestResponse(param1:Array) : void
      {
         var _loc3_:int = int(param1[2]);
         var _loc2_:String = param1[3];
         if(_codeRequestCallback != null)
         {
            _codeRequestCallback(_loc3_,_loc2_);
            _codeRequestCallback = null;
         }
      }
      
      private static function referralAssociationResponse(param1:Array) : void
      {
         var _loc2_:int = int(param1[2]);
         if(_referralAssociationCallback != null)
         {
            _referralAssociationCallback(_loc2_);
            _referralAssociationCallback = null;
         }
      }
      
      private static function referralHasAssociateResponse(param1:Array) : void
      {
         var _loc2_:int = int(param1[2]);
         if(_hasReferralAssociateCallback != null)
         {
            _hasReferralAssociateCallback(_loc2_);
            _hasReferralAssociateCallback = null;
         }
      }
      
      private static function referralReferralsResponse(param1:Array) : void
      {
         var _loc2_:int = int(param1[2]);
         if(_referralReferralsCallback != null)
         {
            _referralReferralsCallback(param1);
            _referralReferralsCallback = null;
         }
      }
   }
}

