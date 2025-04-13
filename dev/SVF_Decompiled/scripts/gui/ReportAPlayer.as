package gui
{
   import buddy.BuddyManager;
   import buddy.BuddyXtCommManager;
   import com.sbi.popup.SBPopup;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import playerWall.PlayerWallManager;
   
   public class ReportAPlayer
   {
      public static const REASONS_ALL:int = 0;
      
      public static const REASONS_PLAYER_CARD:int = 1;
      
      public static const REASONS_ECARD:int = 2;
      
      public static const REASONS_PLAYER_WALL:int = 3;
      
      public static const REASONS_MASTERPIECE:int = 4;
      
      private static var _reportFromCardPopup:SBPopup;
      
      private var _popupLayer:DisplayObjectContainer;
      
      private var _reportPopup:SBPopup;
      
      private var _agreeBox:GuiCheckBox;
      
      private var _reportConfirmMediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _dataToPassAlong:Object;
      
      private var _report:MovieClip;
      
      private var _reportFromCard:MovieClip;
      
      private var _reportFromCardConfirmPopup:MovieClip;
      
      private var _isFromPlayersCard:Boolean;
      
      private var _reportAPlayer:Boolean;
      
      private var _hasReported:Boolean;
      
      private var _playersAvatarUserName:String;
      
      private var _playersModeratedAvatarUserName:String;
      
      private var _reasonArray:Array;
      
      private var _reasonToId:Vector.<String>;
      
      private var _reasonsType:int;
      
      public function ReportAPlayer()
      {
         super();
      }
      
      public static function closeReportFromCardPopoup() : void
      {
         if(_reportFromCardPopup)
         {
            _reportFromCardPopup.close();
         }
      }
      
      public function init(param1:int, param2:DisplayObjectContainer, param3:Function = null, param4:Boolean = false, param5:String = null, param6:String = null, param7:Boolean = true, param8:* = null, param9:int = -1, param10:int = 450, param11:int = 275) : void
      {
         _popupLayer = param2;
         _closeCallback = param3;
         _isFromPlayersCard = param4;
         _playersAvatarUserName = param5;
         _playersModeratedAvatarUserName = param6;
         _hasReported = false;
         _reportAPlayer = param7;
         _dataToPassAlong = param8;
         _reasonsType = param1;
         if(param4)
         {
            _reasonArray = [[LocalizationManager.translateIdOnly(11372)],[LocalizationManager.translateIdOnly(14791)],[LocalizationManager.translateIdOnly(14793)],[LocalizationManager.translateIdOnly(14794)],[LocalizationManager.translateIdOnly(14795)],[LocalizationManager.translateIdOnly(15736)],[LocalizationManager.translateIdOnly(15737)]];
            if(param1 == 0)
            {
               _reasonArray.push([LocalizationManager.translateIdOnly(14792)]);
               _reasonArray.push([LocalizationManager.translateIdOnly(20088)]);
               _reasonArray.push([LocalizationManager.translateIdOnly(23217)]);
            }
            else if(param1 == 1)
            {
               _reasonArray.push([LocalizationManager.translateIdOnly(14792)]);
            }
            else if(param1 == 2)
            {
               _reasonArray.push([LocalizationManager.translateIdOnly(20088)]);
            }
            else if(param1 == 3)
            {
               _reasonArray.push([LocalizationManager.translateIdOnly(23217)]);
            }
            else if(param1 == 4)
            {
               _reasonArray.push([LocalizationManager.translateIdOnly(25195)]);
            }
            _reasonToId = new <String>[LocalizationManager.translateIdOnly(11372),LocalizationManager.translateIdOnly(14791),LocalizationManager.translateIdOnly(14792),LocalizationManager.translateIdOnly(14793),LocalizationManager.translateIdOnly(14794),LocalizationManager.translateIdOnly(14795),LocalizationManager.translateIdOnly(15736),LocalizationManager.translateIdOnly(15737),LocalizationManager.translateIdOnly(20088),LocalizationManager.translateIdOnly(23217),LocalizationManager.translateIdOnly(25195)];
            _reportFromCard = GETDEFINITIONBYNAME("ReportPopupReportContent");
            _reportFromCardPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupReportSkin"),_reportFromCard,true,true,false,false,true);
            _reportFromCardPopup.x = param10;
            _reportFromCardPopup.y = param11;
            _reportFromCardPopup.bxClosesPopup = false;
            LocalizationManager.translateId(_reportFromCard.reasonTxt,11372);
            LocalizationManager.translateIdAndInsert(_reportFromCard.titleTxt,11373,_playersModeratedAvatarUserName);
            SafeChatManager.buildSafeChatTree(_reportFromCard.reasonChatTree,"ECardTextTreeNode",1,onReasonTextClose,_reasonArray);
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
            if(param9 != -1)
            {
               _reportFromCard.reasonTxt.text = _reasonArray[param9];
            }
         }
         else
         {
            _report = GETDEFINITIONBYNAME("ReportPopupHowToContent2");
            _reportPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupHowToSkin"),_report);
            _reportPopup.x = param10;
            _reportPopup.y = param11;
            _reportPopup.bxClosesPopup = false;
         }
         addListeners();
      }
      
      public function destroy() : void
      {
         removeListeners();
         if(_reportFromCardPopup)
         {
            _reportFromCardPopup.destroy();
            _reportFromCardPopup = null;
         }
         if(_reportPopup)
         {
            _reportPopup.destroy();
            _reportPopup = null;
         }
         if(_reportFromCardConfirmPopup)
         {
            if(_agreeBox)
            {
               _agreeBox.destroy();
               _agreeBox = null;
            }
            DarkenManager.unDarken(_reportFromCardConfirmPopup);
            _popupLayer.removeChild(_reportFromCardConfirmPopup);
            _reportFromCardConfirmPopup = null;
         }
         GuiManager.displayRulesPopup(false);
         if(_reportFromCard)
         {
            SafeChatManager.destroy(_reportFromCard.reasonChatTree);
         }
         if(GuiManager.mainHud.reportBtn)
         {
            GuiManager.mainHud.reportBtn.downToUpState();
         }
         _closeCallback = null;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_hasReported && _agreeBox.checked)
         {
            if(!BuddyManager.isBlocked(_playersAvatarUserName) && _playersAvatarUserName != null && _playersAvatarUserName.length > 0)
            {
               BuddyXtCommManager.sendBuddyBlockRequest(_playersAvatarUserName);
               delete PlayerWallManager.tokenMap[_playersAvatarUserName.toLowerCase()];
            }
         }
         if(_closeCallback != null)
         {
            _closeCallback(_hasReported);
         }
         else
         {
            destroy();
         }
      }
      
      private function onReportBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_reportAPlayer)
         {
            FacilitatorXtCommManager.sendReportAPlayerRequest(_playersAvatarUserName,reasonIdForReason(_reportFromCard.reasonTxt.text),reportAPlayerResponse);
         }
         else
         {
            FacilitatorXtCommManager.sendReportWithAdditionalDataRequest(_playersAvatarUserName,_reasonsType == 3 ? 7 : 8,reasonIdForReason(_reportFromCard.reasonTxt.text),_dataToPassAlong as String,reportAPlayerResponse);
         }
         _reportFromCardPopup.close();
      }
      
      private function reasonIdForReason(param1:String) : int
      {
         switch(param1)
         {
            case _reasonToId[0]:
               return 1;
            case _reasonToId[1]:
               return 2;
            case _reasonToId[2]:
               return 5;
            case _reasonToId[3]:
               return 3;
            case _reasonToId[4]:
               return 4;
            case _reasonToId[5]:
               return 6;
            case _reasonToId[6]:
               return 7;
            case _reasonToId[7]:
               return 13;
            case _reasonToId[8]:
               return 14;
            case _reasonToId[9]:
               return 15;
            case _reasonToId[10]:
               return 16;
            default:
               throw new Error("Reason for reporting is invalid. Reason: " + param1);
         }
      }
      
      private function onNoHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onClose(param1);
      }
      
      private function onReasonHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_reportFromCard.reasonChatTree.visible)
         {
            SafeChatManager.openSafeChat(true,_reportFromCard.reasonChatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
         }
      }
      
      private function onReasonTextClose(param1:String, param2:String) : void
      {
         _reportFromCard.reasonTxt.text = param1;
         SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
      }
      
      private function onRules(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.displayRulesPopup(true);
      }
      
      private function reportAPlayerResponse(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _reportConfirmMediaHelper = new MediaHelper();
         _reportConfirmMediaHelper.init(2694,onReportConfirmLoaded,param1);
      }
      
      private function onReportConfirmLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _reportFromCardConfirmPopup = MovieClip(param1.getChildAt(0));
         _reportFromCardConfirmPopup.x = _reportFromCardPopup.x;
         _reportFromCardConfirmPopup.y = _reportFromCardPopup.y;
         if(param1.passback)
         {
            LocalizationManager.translateId(_reportFromCardConfirmPopup.titleTxt,11374);
            _hasReported = true;
         }
         else
         {
            LocalizationManager.translateId(_reportFromCardConfirmPopup.titleTxt,11375);
         }
         _reportFromCardConfirmPopup.okBtn.addEventListener("mouseDown",onClose,false,0,true);
         _agreeBox = new GuiCheckBox(_reportFromCardConfirmPopup.agree_box);
         _agreeBox.init(_reportFromCardConfirmPopup.bodyTxt);
         _agreeBox.checked = true;
         _reportConfirmMediaHelper.destroy();
         _reportConfirmMediaHelper = null;
         _popupLayer.addChild(_reportFromCardConfirmPopup);
         DarkenManager.darken(_reportFromCardConfirmPopup);
      }
      
      public function get visible() : Boolean
      {
         if(_reportPopup)
         {
            return _reportPopup.visible;
         }
         return false;
      }
      
      private function addListeners() : void
      {
         if(_isFromPlayersCard)
         {
            if(_reportFromCardPopup)
            {
               _reportFromCardPopup.skin.s["bx"].addEventListener("mouseDown",onClose,false,0,true);
            }
            _reportFromCard.reportBtn.addEventListener("mouseDown",onReportBtnHandler,false,0,true);
            _reportFromCard.noBtn.addEventListener("mouseDown",onNoHandler,false,0,true);
            _reportFromCard.addTxtBtn.addEventListener("mouseDown",onReasonHandler,false,0,true);
         }
         else
         {
            if(_reportPopup)
            {
               _reportPopup.skin.s["bx"].addEventListener("mouseDown",onClose,false,0,true);
            }
            _report.rulesReportBtn.addEventListener("mouseDown",onRules,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         if(_isFromPlayersCard)
         {
            if(_reportFromCardPopup)
            {
               _reportFromCardPopup.skin.s["bx"].removeEventListener("mouseDown",onClose);
            }
            if(_reportFromCardConfirmPopup)
            {
               _reportFromCardConfirmPopup.okBtn.addEventListener("mouseDown",onClose);
            }
            _reportFromCard.reportBtn.removeEventListener("mouseDown",onReportBtnHandler);
            _reportFromCard.noBtn.removeEventListener("mouseDown",onNoHandler);
            _reportFromCard.addTxtBtn.addEventListener("mouseDown",onReasonHandler);
         }
         else
         {
            if(_reportPopup)
            {
               _reportPopup.skin.s["bx"].removeEventListener("mouseDown",onClose);
            }
            _report.rulesReportBtn.removeEventListener("mouseDown",onRules);
         }
      }
   }
}

