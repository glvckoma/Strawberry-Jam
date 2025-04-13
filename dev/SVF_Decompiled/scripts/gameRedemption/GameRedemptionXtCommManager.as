package gameRedemption
{
   import avatar.AvatarManager;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.GuiManager;
   import localization.LocalizationManager;
   
   public class GameRedemptionXtCommManager
   {
      private static var _grcCallback:Function;
      
      public static const RESPONSE_REDEEM_SUCCESS:String = "1";
      
      public static const RESPONSE_CODE_NOT_VALID:String = "-1";
      
      public static const RESPONSE_CODE_WRONG_GAME:String = "-2";
      
      public static const RESPONSE_ACCOUNT_NOT_VERIFIED:String = "-3";
      
      public static const RESPONSE_CAPTCHA_GET_LIMIT_EXCEEDED:String = "-4";
      
      public static const RESPONSE_CAPTCHA_INCORRECT_ANSWER:String = "-5";
      
      public static const RESPONSE_CAPTCHA_POST_SHOW_NOW:String = "-6";
      
      public static const RESPONSE_CAPTCHA_POST_SHOW_ON_NEXT_REDEEM:String = "-7";
      
      private static var _captchaToShow:Object;
      
      private static var _hasAlternateDomains:Boolean;
      
      private static var _additionalDomainsCallback:Function;
      
      private static var _additionalDomainsPassback:Object;
      
      public function GameRedemptionXtCommManager()
      {
         super();
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
      }
      
      public static function requestRedeemCode(param1:String, param2:String, param3:String, param4:Function) : void
      {
         _grcCallback = param4;
         if(param2 == null || param3 == null)
         {
            param2 = param3 = "";
         }
         gMainFrame.server.setXtObject_Str("grc",[param1,param2,param3],gMainFrame.server.isWorldZone);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: GameRedemptionXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "grc":
               handleRedeemCodeResponse(_loc2_);
               break;
            case "grm":
               handleRedeemMembershipResponse(_loc2_);
               break;
            default:
               throw new Error("GameRedemptionXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      public static function get captchaToShowData() : Object
      {
         return _captchaToShow;
      }
      
      public static function set captchaToShowData(param1:Object) : void
      {
         _captchaToShow = param1;
      }
      
      public static function checkIfHasGiftInOtherDomain(param1:Function, param2:Object = null) : void
      {
         if(_hasAlternateDomains)
         {
            _hasAlternateDomains = false;
            _additionalDomainsCallback = param1;
            _additionalDomainsPassback = param2;
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(28683,gMainFrame.userInfo.myUserName),true,onAdditionalDomainsOk);
         }
         else if(param1 != null)
         {
            if(param2 != null)
            {
               param1(param2);
            }
            else
            {
               param1();
            }
         }
      }
      
      private static function onAdditionalDomainsOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         if(_additionalDomainsCallback != null)
         {
            if(_additionalDomainsPassback != null)
            {
               _additionalDomainsCallback(_additionalDomainsPassback);
            }
            else
            {
               _additionalDomainsCallback();
            }
         }
         _additionalDomainsCallback = null;
         _additionalDomainsPassback = null;
      }
      
      private static function handleRedeemCodeResponse(param1:Object) : void
      {
         var _loc3_:String = param1[2];
         var _loc2_:Object = param1[3] != null && param1[3] != "" ? JSON.parse(param1[3] as String) : null;
         _hasAlternateDomains = param1[4] != null && param1[4] == "1";
         if(_grcCallback != null)
         {
            _grcCallback(_loc3_,_loc2_);
            _grcCallback = null;
         }
         if(!gMainFrame.userInfo.needFastPass)
         {
            if(_loc3_ == "1")
            {
               GuiManager.setupInGameRedemptions();
            }
         }
      }
      
      private static function handleRedeemMembershipResponse(param1:Object) : void
      {
         var _loc3_:Point = null;
         var _loc2_:Boolean = false;
         var _loc4_:int = int(param1[2]);
         if(_loc4_ == 1)
         {
            GuiManager.onExpiringPopupClose(null);
            gMainFrame.clientInfo.subscriptionSourceType = param1[5];
            _loc3_ = null;
            if(AvatarManager.avatarViewList && AvatarManager.playerAvatarWorldView)
            {
               _loc3_ = new Point(AvatarManager.playerAvatarWorldView.x,AvatarManager.playerAvatarWorldView.y);
            }
            gMainFrame.clientInfo.accountType = param1[3];
            _loc2_ = Boolean(gMainFrame.userInfo.isMember);
            gMainFrame.userInfo.isMember = Utility.isMember(gMainFrame.clientInfo.accountType);
            if(_loc2_ != gMainFrame.userInfo.isMember)
            {
               gMainFrame.clientInfo.accountTypeChanged = true;
            }
            gMainFrame.clientInfo.numDaysLeftOnSubscription = param1[4];
            gMainFrame.userInfo.clearPlayerAvatarInfoType();
            GuiManager.rebuildMainHud();
            if(_loc3_)
            {
               AvatarManager.loadSelfAssets(null,_loc3_.x,_loc3_.y);
            }
         }
      }
   }
}

