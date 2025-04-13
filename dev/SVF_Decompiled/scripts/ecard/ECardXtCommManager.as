package ecard
{
   import buddy.BuddyManager;
   import com.sbi.client.SFEvent;
   import com.sbi.popup.SBOkPopup;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.SafeChatManager;
   import localization.LocalizationManager;
   
   public class ECardXtCommManager
   {
      private static var _requestCallback:Function;
      
      private static var _readResponseCallback:Function;
      
      private static var _sendResponseCallback:Function;
      
      private static var _privacyResponseCallback:Function;
      
      private static var _giftResponseCallback:Function;
      
      private static var _giftRequestCallbackQueue:Object;
      
      public static var _deleteResponseCallback:Function;
      
      private static var NUM_JAGS_PER_NON_BUDDY_PER_SESSION:int = 5;
      
      private static var NUM_JAGS_PER_BUDDY_PER_SESSION:int = 25;
      
      private static var _jaggedPlayers:Object;
      
      private static var _privacySettingId:int;
      
      public function ECardXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _jaggedPlayers = {};
         _giftRequestCallbackQueue = {};
      }
      
      public static function sendECardListRequest(param1:Function = null) : void
      {
         var _loc2_:int = 0;
         if(param1 != null)
         {
            _loc2_ = 1;
            _requestCallback = param1;
         }
         gMainFrame.server.setXtObject_Str("el",[_loc2_]);
      }
      
      public static function sendECardReadRequest(param1:int, param2:Function = null) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param2 != null)
            {
               _readResponseCallback = param2;
            }
            DarkenManager.showLoadingSpiral(true);
            gMainFrame.server.setXtObject_Str("er",[param1]);
         }
      }
      
      public static function sendECardSendRequest(param1:String, param2:String, param3:int, param4:int, param5:int, param6:String, param7:int, param8:int, param9:int, param10:Function = null) : Boolean
      {
         if(_jaggedPlayers[param1] == null)
         {
            _jaggedPlayers[param1] = 0;
         }
         var _loc11_:int = BuddyManager.isBuddy(param1) ? NUM_JAGS_PER_BUDDY_PER_SESSION : NUM_JAGS_PER_NON_BUDDY_PER_SESSION;
         if(_jaggedPlayers[param1] < _loc11_)
         {
            _jaggedPlayers[param1]++;
            if(param10 != null)
            {
               _sendResponseCallback = param10;
            }
            gMainFrame.server.setXtObject_Str("es",[param1,param3,param4,param5,param6,param7,param8,param9]);
            return true;
         }
         DarkenManager.showLoadingSpiral(false);
         new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14691,param2));
         return false;
      }
      
      public static function sendECardDeleteRequest(param1:int, param2:Function = null) : void
      {
         if(param2 != null)
         {
            _deleteResponseCallback = param2;
         }
         DarkenManager.showLoadingSpiral(true);
         gMainFrame.server.setXtObject_Str("ed",[param1]);
      }
      
      public static function sendECardBuddyRequest(param1:int, param2:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("eb",[param1,param2 ? 1 : 0]);
      }
      
      public static function sendECardAcceptDiscardGiftRequest(param1:int, param2:Boolean, param3:Function, param4:int = -1, param5:ECard = null) : void
      {
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(param3 != null)
            {
               _giftResponseCallback = param3;
            }
            _giftRequestCallbackQueue[param1] = param5;
            gMainFrame.server.setXtObject_Str("eg",param4 >= 0 ? [param1,param2 ? 1 : 0,param4] : [param1,param2 ? 1 : 0]);
         }
         else if(param3 != null)
         {
            param3(0,true,param5);
         }
      }
      
      public static function sendECardClearCache() : void
      {
         gMainFrame.server.setXtObject_Str("ec",[]);
      }
      
      public static function sendECardPrivacySettingUpdateRequest(param1:int, param2:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _privacyResponseCallback = param2;
         _privacySettingId = param1;
         gMainFrame.server.setXtObject_Str("ei",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         DarkenManager.showLoadingSpiral(false);
         switch(_loc2_[0])
         {
            case "el":
               eCardListResponse(_loc2_);
               break;
            case "er":
               eCardReadResponse(_loc2_);
               break;
            case "ed":
               eCardDeleteResponse(_loc2_);
               break;
            case "es":
               eCardSendResponse(_loc2_);
               break;
            case "eg":
               eCardGiftResponse(_loc2_);
               break;
            case "eb":
               eCardBuddyResponse(_loc2_);
               break;
            case "ep":
               eCardPushHandler(_loc2_);
               break;
            case "eu":
               eCardUpdateHandler(_loc2_);
               break;
            case "ei":
               eCardIsolationHandler(_loc2_);
               break;
            default:
               throw new Error("ECardXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function eCardListResponse(param1:Object) : void
      {
         var _loc7_:ECard = null;
         var _loc5_:int = 0;
         if(!SafeChatManager.hasLoadedLists)
         {
            SafeChatManager.safeChatStringForCode(eCardListResponse,[param1],"",1);
            return;
         }
         var _loc2_:int = int(param1[2]);
         var _loc3_:Array = new Array(_loc2_);
         if(_loc2_ == -1)
         {
            _loc2_ = 0;
         }
         var _loc4_:int = 0;
         var _loc6_:int = 3;
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc7_ = new ECard();
            _loc7_.init(int(param1[_loc6_++]),param1[_loc6_++],int(param1[_loc6_++]),int(param1[_loc6_++]),param1[_loc6_++] == "1",param1[_loc6_++],int(param1[_loc6_++]),int(param1[_loc6_++]),uint(param1[_loc6_++]),param1[_loc6_++],int(param1[_loc6_++]),int(param1[_loc6_++]),int(param1[_loc6_++]),int(param1[_loc6_++]),int(param1[_loc6_++]),param1[_loc6_++],param1[_loc6_++]);
            if(_loc7_.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)"))
            {
               _loc7_.msg = SafeChatManager.safeChatStringForCode(null,null,_loc7_.msg,1);
            }
            if(_loc7_.type == 4)
            {
               _loc7_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc7_.giftName == "1" ? 11114 : 11097,Utility.convertNumberToString(int(_loc7_.giftName)));
            }
            else if(_loc7_.type == 9)
            {
               _loc7_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc7_.giftName == "1" ? 11116 : 11103,Utility.convertNumberToString(int(_loc7_.giftName)));
            }
            else if(_loc7_.type == 5)
            {
               _loc7_.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(_loc7_.giftName)));
            }
            else
            {
               _loc7_.giftName = LocalizationManager.translateIdOnly(int(_loc7_.giftName));
            }
            _loc3_[_loc2_ - 1 - _loc5_] = _loc7_;
            if(!_loc7_.isRead)
            {
               _loc4_++;
            }
            _loc5_++;
         }
         ECardManager.processECardList(_loc3_,_loc4_);
         if(_requestCallback != null)
         {
            _requestCallback(_loc3_);
            _requestCallback = null;
         }
      }
      
      private static function eCardReadResponse(param1:Object) : void
      {
         if(_readResponseCallback != null)
         {
            _readResponseCallback(int(param1[2]),param1[3] == "1");
         }
      }
      
      private static function eCardDeleteResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc6_:Boolean = param1[2] == "1" ? true : false;
         var _loc4_:int = int(param1[3]);
         var _loc3_:int = 4;
         var _loc5_:Array = new Array(_loc4_);
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc5_[_loc2_] = param1[_loc3_++];
            _loc2_++;
         }
         if(_deleteResponseCallback != null)
         {
            _deleteResponseCallback(_loc5_,_loc6_);
         }
      }
      
      private static function eCardSendResponse(param1:Object) : void
      {
         if(_sendResponseCallback != null)
         {
            _sendResponseCallback(param1[2]);
         }
      }
      
      private static function eCardGiftResponse(param1:Object) : void
      {
         var _loc2_:ECard = null;
         if(_giftResponseCallback != null)
         {
            _loc2_ = _giftRequestCallbackQueue[int(param1[2])];
            delete _giftRequestCallbackQueue[int(param1[2])];
            _giftResponseCallback(int(param1[2]),param1[3] == "1",_loc2_);
         }
      }
      
      private static function eCardBuddyResponse(param1:Object) : void
      {
         if(param1[2] == -1)
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14692));
         }
      }
      
      private static function eCardIsolationHandler(param1:Object) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc2_:* = param1[2] == "1";
         if(_loc2_)
         {
            gMainFrame.userInfo.eCardPrivacySettings = _privacySettingId;
         }
         if(_privacyResponseCallback != null)
         {
            _privacyResponseCallback(_loc2_,_privacySettingId);
            _privacyResponseCallback = null;
         }
      }
      
      private static function eCardPushHandler(param1:Object) : void
      {
         if(!SafeChatManager.hasLoadedLists)
         {
            SafeChatManager.safeChatStringForCode(eCardPushHandler,[param1],"",1);
            return;
         }
         var _loc2_:ECard = new ECard();
         var _loc3_:int = 2;
         _loc2_.init(int(param1[_loc3_++]),param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),param1[_loc3_++] == "1",param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),uint(param1[_loc3_++]),param1[_loc3_++],int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]),int(param1[_loc3_++]),param1[_loc3_++],param1[_loc3_++]);
         if(_loc2_.msg.match("(^[0-9]{1,2},[0-9]{1,2}$)|(^[0-9]{1,2}$)"))
         {
            _loc2_.msg = SafeChatManager.safeChatStringForCode(null,null,_loc2_.msg,1);
         }
         if(_loc2_.type == 4)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc2_.giftName == "1" ? 11114 : 11097,Utility.convertNumberToString(int(_loc2_.giftName)));
         }
         else if(_loc2_.type == 9)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(_loc2_.giftName == "1" ? 11116 : 11103,Utility.convertNumberToString(int(_loc2_.giftName)));
         }
         else if(_loc2_.type == 5)
         {
            _loc2_.giftName = LocalizationManager.translateIdAndInsertOnly(15000,LocalizationManager.translateIdOnly(int(_loc2_.giftName)));
         }
         else
         {
            _loc2_.giftName = LocalizationManager.translateIdOnly(int(_loc2_.giftName));
         }
         ECardManager.processECardPush(_loc2_);
      }
      
      private static function eCardUpdateHandler(param1:Object) : void
      {
         ECardManager.processECardUpdate(param1[2],param1[3]);
      }
   }
}

