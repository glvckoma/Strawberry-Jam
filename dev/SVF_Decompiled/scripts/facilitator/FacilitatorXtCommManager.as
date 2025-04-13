package facilitator
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBStandardTitlePopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class FacilitatorXtCommManager
   {
      public static const PUNISH_REASON_BAN:int = -1;
      
      public static const PUNISH_REASON_SUSPEND:int = -2;
      
      public static const PUNISH_REASON_GENERAL_RISK:int = 0;
      
      public static const PUNISH_REASON_BULLYING:int = 1;
      
      public static const PUNISH_REASON_FIGHTING:int = 2;
      
      public static const PUNISH_REASON_PII:int = 3;
      
      public static const PUNISH_REASON_DATING_AND_SEXTING:int = 4;
      
      public static const PUNISH_REASON_VULGAR:int = 5;
      
      public static const PUNISH_REASON_DRUGS_AND_ALCOHOL:int = 6;
      
      public static const PUNISH_REASON_IN_GAME:int = 7;
      
      public static const PUNISH_REASON_ALARM:int = 8;
      
      public static const PUNISH_REASON_FRAUD:int = 9;
      
      public static const PUNISH_REASON_RACIST:int = 10;
      
      public static const PUNISH_REASON_RELIGION:int = 11;
      
      public static const PUNISH_REASON_WEBSITE:int = 12;
      
      public static const PUNISH_REASON_JUNK:int = 13;
      
      public static const PUNISH_REASON_GROOMING:int = 14;
      
      public static const PUNISH_REASON_PUBLIC_THREATS:int = 15;
      
      public static const PUNISH_REASON_REAL_NAME:int = 16;
      
      public static const PUNISH_REASON_TERRORIST_RECRUITMENT:int = 17;
      
      public static const PUNISH_REASON_CUSTOM1:int = 27;
      
      public static const PUNISH_REASON_CUSTOM2:int = 28;
      
      public static const PUNISH_REASON_CUSTOM3:int = 29;
      
      public static const PUNISH_REASON_CUSTOM4:int = 30;
      
      public static const PUNISH_REASON_CUSTOM5:int = 31;
      
      public static const PUNISH_TYPE_KICK:int = 3;
      
      public static const PUNISH_TYPE_REPORT:int = 4;
      
      public static const PUNISH_TYPE_TRADE_BLOCK:int = 6;
      
      public static const PUNISH_TYPE_REPORT_POST:int = 7;
      
      public static const PUNISH_TYPE_MASTERPIECE:int = 8;
      
      private static const CONTEXTUAL_WARNING_POPUP_TIME_MS:int = 10000;
      
      public static const RULE_MEAN:int = 1;
      
      public static const RULE_LANGUAGE:int = 2;
      
      public static const RULE_PERSONAL_INFO:int = 3;
      
      public static const RULE_SECURITY:int = 4;
      
      public static const RULE_BAD_DEN:int = 5;
      
      public static const RULE_SCAMMING:int = 6;
      
      public static const RULE_RELATIONSHIP:int = 7;
      
      public static const RULE_USERNAME:int = 13;
      
      public static const RULE_JAM_A_GRAM:int = 14;
      
      public static const RULE_JAMMER_WALL_POST:int = 15;
      
      public static const RULE_MASTERPIECE:int = 16;
      
      private static var _guiLayer:DisplayObjectContainer;
      
      private static var _punishPopups:Array;
      
      private static var _reportCallback:Function;
      
      private static var _reportWithAdditionalDataCallback:Function;
      
      private static var _reportedPlayers:Object;
      
      private static var _punishPopup:Sprite;
      
      private static var _punishPopupHelper:MediaHelper;
      
      public static var kickReason:int = -1;
      
      public static var kickMsg:String;
      
      public static var wasUserBanned:Boolean;
      
      public static var suspensionType:int;
      
      public static var suspensionDuration:int;
      
      private static var _isRulesPopupOpen:Boolean;
      
      private static var _contextualWarningTimer:Timer;
      
      private static var _openPunishPopupObject:Object;
      
      public function FacilitatorXtCommManager()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _guiLayer = param1;
         _punishPopups = [];
         _reportedPlayers = {};
         _punishPopup = new Sprite();
         _punishPopup.x = 900 * 0.5;
         _punishPopup.y = 550 * 0.5;
         _punishPopupHelper = new MediaHelper();
         _punishPopupHelper.init(1505,onPunishPopupImgReceived);
         _contextualWarningTimer = new Timer(10000);
      }
      
      public static function sendBanRequest(param1:String, param2:Number, param3:int, param4:String) : void
      {
         gMainFrame.server.setXtObject_Str("fb",[param1,param2,param3,param4]);
      }
      
      public static function sendSilenceRequest(param1:String, param2:Number, param3:int, param4:String) : void
      {
         gMainFrame.server.setXtObject_Str("fs",[param1,param2,param3,param4]);
      }
      
      public static function sendMuteRequest(param1:String, param2:Number, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("fm",[param1,param2,param3]);
      }
      
      public static function sendKickRequest(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("fk",[param1,param2]);
      }
      
      public static function sendGrantGemsRequest(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("fg",[param1,param2]);
      }
      
      public static function sendPrivateMessageRequest(param1:String, param2:String, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("fp",[param1,param2,param3]);
      }
      
      public static function sendClearDenRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("fc",[param1]);
      }
      
      public static function sendBanMyselfRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("fbm",[param1]);
      }
      
      public static function sendReportWithAdditionalDataRequest(param1:String, param2:int, param3:int, param4:String, param5:Function) : void
      {
         _reportWithAdditionalDataCallback = param5;
         if(param4 == null)
         {
            param4 = "";
         }
         gMainFrame.server.setXtObject_Str("fra",[param1,param3,param2,param4]);
      }
      
      public static function sendReportAPlayerRequest(param1:String, param2:int, param3:Function) : void
      {
         if(!_reportedPlayers[param1] || gMainFrame.clientInfo.roomType == 7)
         {
            _reportedPlayers[param1] = true;
            _reportCallback = param3;
            gMainFrame.server.setXtObject_Str("fr",[param1,param2]);
         }
         else
         {
            param3(true);
         }
      }
      
      public static function sendIdleTimeOut() : void
      {
         gMainFrame.server.setXtObject_Str("ft",[],gMainFrame.server.isWorldZone);
      }
      
      public static function sendInvisModeRequest(param1:Boolean) : void
      {
         if(param1 == gMainFrame.clientInfo.invisMode)
         {
            DebugUtility.debugTrace("WARNING: trying to change to invisMode:" + param1 + " when client is already at that state");
         }
         DebugUtility.debugTrace("sendInvisModeRequest called - shouldGoInvisible:" + param1);
         DebugUtility.debugTrace("sendInvisModeRequest called - gMainFrame.clientInfo.invisMode:" + gMainFrame.clientInfo.invisMode);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.avatarViewList:" + AvatarManager.avatarViewList);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.playerAvatarWorldView:" + (!!AvatarManager.avatarViewList ? AvatarManager.playerAvatarWorldView : null));
         var _loc2_:Array = !param1 && AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null ? [1,int(AvatarManager.playerAvatarWorldView.x),int(AvatarManager.playerAvatarWorldView.y),AvatarManager.playerAvatarWorldView.lastIdleAnim | (AvatarManager.playerAvatarWorldView.lastIdleFlip ? 2147483648 : 0),0] : [];
         DebugUtility.debugTrace("sendInvisModeRequest posArray:" + _loc2_);
         if(gMainFrame.server.isWorldXtReady)
         {
            DebugUtility.debugTrace("setXt is ready - sending fi");
            gMainFrame.server.setXtObject_Str("fi",_loc2_);
         }
         else
         {
            DebugUtility.debugTrace("setXt is NOT ready - setting trigger for fi");
            gMainFrame.server.triggerCmdWhenWorldXtReady("fi",_loc2_);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "fd":
               facilitatorDisciplineResponse(_loc2_);
               break;
            case "fk":
               facilitatorKickResponse(_loc2_);
               break;
            case "fb":
               facilitatorBanResponse(_loc2_);
               break;
            case "fm":
               facilitatorMuteResponse(_loc2_);
               break;
            case "fs":
               facilitatorSilenceResponse(_loc2_);
               break;
            case "fg":
               facilitatorGrantResponse(_loc2_);
               break;
            case "fp":
               facilitatorPrivateMessageResponse(_loc2_);
               break;
            case "fr":
               facilitatorReportAPlayerResponse(_loc2_);
               break;
            case "fra":
               facilitatorReportWithAdditionalDataResponse(_loc2_);
               break;
            case "fi":
               facilitatorInvisModeResponse(_loc2_);
               break;
            default:
               throw new Error("FacilitatorXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      public static function facilitatorDisciplineResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc7_:SBOkPopup = null;
         var _loc5_:SBStandardPopup = null;
         var _loc8_:GamePlay = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc4_:SBOkPopup = null;
         var _loc6_:String = param1[2];
         if(_loc6_ == "fb")
         {
            if(param1[3] == "1")
            {
               wasUserBanned = true;
               suspensionDuration = int(param1[4]);
               if(suspensionDuration == -1)
               {
                  suspensionType = -1;
               }
               else
               {
                  suspensionType = -2;
                  suspensionDuration = Math.ceil(suspensionDuration / 3600);
               }
               openPunishPopup(suspensionType,suspensionDuration);
               AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
            }
         }
         else if(_loc6_ == "fs")
         {
            _loc3_ = int(param1[3]);
            if(_loc3_ > 0)
            {
               _loc2_ = LocalizationManager.translateIdAndInsertOnly(11180,_loc3_);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else if(_loc3_ < 0)
            {
               _loc2_ = LocalizationManager.translateIdOnly(11181);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else
            {
               _loc2_ = LocalizationManager.translateIdOnly(11182);
               GuiManager.chatHist.enableFreeChat(true);
            }
            _loc7_ = new SBOkPopup(_guiLayer,_loc2_);
            _punishPopups.unshift(_loc7_);
         }
         else if(_loc6_ == "fk")
         {
            _loc2_ = LocalizationManager.translateIdOnly(11183);
            kickReason = int(param1[3]);
            if(kickReason > 0)
            {
               kickMsg = _loc2_;
               _loc5_ = new SBStandardPopup(_guiLayer,_loc2_);
            }
            else
            {
               kickMsg = _loc2_;
               _loc8_ = GamePlay(gMainFrame.gamePlay);
               _loc8_.onConnectionLost(null);
            }
         }
         else if(_loc6_ == "fp")
         {
            if(param1[4] == "0")
            {
               _loc2_ = LocalizationManager.translateIdOnly(11134) + param1[3];
               _punishPopups.unshift(new SBOkPopup(_guiLayer,_loc2_));
            }
            else
            {
               _punishPopups.unshift(new SBStandardTitlePopup(_guiLayer,LocalizationManager.translateIdOnly(11135),LocalizationManager.translateIdOnly(11136)));
            }
         }
         else if(_loc6_ == "fw")
         {
            showContextualWarningPopup(param1[3]);
            AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
         }
         else
         {
            if(!(_loc6_ == "fg" || _loc6_ == "fc"))
            {
               throw new Error("ERROR -- FacilitatorXtCommManager: Invalid cmd=" + _loc6_);
            }
            if(param1[3] == "1")
            {
               _loc10_ = Math.ceil(int(param1[4]) / 3600);
               if(_loc10_ == 1)
               {
                  if(_loc6_ == "fg")
                  {
                     _loc9_ = 18218;
                  }
                  else if(_loc6_ == "fc")
                  {
                     _loc9_ = 18217;
                  }
               }
               else if(_loc10_ < 24)
               {
                  if(_loc6_ == "fg")
                  {
                     _loc9_ = 18219;
                  }
                  else if(_loc6_ == "fc")
                  {
                     _loc9_ = 18399;
                  }
               }
               else
               {
                  _loc10_ = Math.ceil(_loc10_ / 24);
                  if(_loc10_ == 1)
                  {
                     if(_loc6_ == "fg")
                     {
                        _loc9_ = 18400;
                     }
                     else if(_loc6_ == "fc")
                     {
                        _loc9_ = 18402;
                     }
                  }
                  else if(_loc6_ == "fg")
                  {
                     _loc9_ = 18401;
                  }
                  else if(_loc6_ == "fc")
                  {
                     _loc9_ = 18403;
                  }
               }
               if(_loc6_ == "fg")
               {
                  if(Utility.canTrade())
                  {
                     Utility.toggleInteractionBit(1);
                  }
                  if(Utility.canGift())
                  {
                     Utility.toggleInteractionBit(2);
                  }
               }
               else if(_loc6_ == "fc")
               {
                  if(gMainFrame.userInfo.sgChatType != 0)
                  {
                     gMainFrame.userInfo.sgChatType = 0;
                  }
               }
               if(_loc9_ != 0)
               {
                  if(RoomXtCommManager.loadingNewRoom || LoadProgress.visible)
                  {
                     RoomManagerWorld.instance.setNeedsToSeeFacilitatorMessage(true,_loc9_,_loc10_);
                  }
                  else
                  {
                     _loc4_ = new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc9_,_loc10_));
                  }
               }
            }
            else if(_loc6_ == "fg")
            {
               if(Utility.canTradeNonDegraded() && !Utility.canTrade())
               {
                  Utility.toggleInteractionBit(1);
               }
               if(Utility.canGiftNonDegraded() && !Utility.canGift())
               {
                  Utility.toggleInteractionBit(2);
               }
            }
            else if(_loc6_ == "fc")
            {
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  gMainFrame.userInfo.sgChatType = gMainFrame.userInfo.sgChatTypeNonDegraded;
               }
            }
         }
      }
      
      private static function facilitatorKickResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11184);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11185);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorBanResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11186);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11187);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorMuteResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11188);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11189);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorSilenceResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11190);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11191);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorGrantResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11192);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11193);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorPrivateMessageResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11194);
         }
         else if(_loc3_ == -1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11195);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11196);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorReportAPlayerResponse(param1:Array) : void
      {
         if(_reportCallback != null)
         {
            _reportCallback(Boolean(param1[2]));
         }
         _reportCallback = null;
      }
      
      private static function facilitatorReportWithAdditionalDataResponse(param1:Array) : void
      {
         if(_reportWithAdditionalDataCallback != null)
         {
            _reportWithAdditionalDataCallback(Boolean(param1[2]));
            _reportWithAdditionalDataCallback = null;
         }
      }
      
      private static function facilitatorInvisModeResponse(param1:Array) : void
      {
         var _loc2_:* = false;
         var _loc3_:String = null;
         try
         {
            _loc2_ = param1[2] != "0";
            gMainFrame.clientInfo.invisMode = _loc2_;
            if(AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null)
            {
               AvatarManager.playerAvatarWorldView.alpha = _loc2_ ? 0.5 : 1;
            }
            DebugUtility.debugTrace("ghostMode - fi invis mode response received from server - now ghostMode:" + gMainFrame.clientInfo.invisMode);
         }
         catch(e:Error)
         {
            _loc3_ = "ERROR: Caught error in facilitatorInvisModeResponse: " + e.message + " " + e.getStackTrace();
            DebugUtility.debugTrace(_loc3_);
         }
      }
      
      public static function showContextualWarningPopup(param1:int) : void
      {
         openPunishPopup(param1,0);
         _contextualWarningTimer.start();
         _contextualWarningTimer.addEventListener("timer",onContextualWarningTimerFinished,false,0,true);
      }
      
      private static function onContextualWarningTimerFinished(param1:TimerEvent) : void
      {
         _contextualWarningTimer.stop();
         _guiLayer.removeChild(_punishPopup);
         DarkenManager.unDarken(_punishPopup);
         GuiManager.setFocusToChatText();
      }
      
      private static function getWarningFrameLabelString(param1:int) : String
      {
         switch(param1 - -2)
         {
            case 0:
            case 1:
               return "accountBan";
            case 3:
            case 4:
            case 12:
            case 17:
               return "bullying";
            case 5:
            case 18:
               return "personalInfo";
            case 11:
               return "scamming";
            default:
               return "behavior";
         }
      }
      
      private static function punishmentOkButtonHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_punishPopups && _punishPopups.length > 0)
         {
            _loc2_ = _punishPopups[0];
            _loc2_.destroy();
            _punishPopups.splice(0,1);
            _loc2_ = null;
         }
      }
      
      private static function onPunishPopupImgReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            _punishPopup.addChild(param1);
            _punishPopup.addEventListener("mouseDown",onPopupClicked,false,0,true);
            _punishPopupHelper.destroy();
            _punishPopupHelper = null;
            if(_openPunishPopupObject != null)
            {
               openPunishPopup(_openPunishPopupObject.punishType,_openPunishPopupObject.durationInHours);
               _openPunishPopupObject = null;
            }
         }
      }
      
      private static function onRulesBtnClicked(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(gMainFrame.server.isConnected)
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/autoBan/rules");
         }
         _isRulesPopupOpen = true;
         GuiManager.displayRulesPopup(true,onRulesXBtnDown);
      }
      
      private static function onPopupClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onRulesXBtnDown(param1:MouseEvent) : void
      {
         SBTracker.pop();
         _isRulesPopupOpen = false;
      }
      
      public static function openPunishPopup(param1:int, param2:int) : void
      {
         var _loc6_:MovieClip = null;
         var _loc5_:int = 0;
         if(_contextualWarningTimer.running)
         {
            _contextualWarningTimer.stop();
         }
         _contextualWarningTimer.delay = 10000;
         gMainFrame.stage.focus = _punishPopup;
         _loc5_ = 0;
         while(_loc5_ < _punishPopup.numChildren)
         {
            if(_punishPopup.getChildAt(_loc5_) is MovieClip)
            {
               _loc6_ = MovieClip(_punishPopup.getChildAt(_loc5_));
               break;
            }
            _loc5_++;
         }
         if(_loc6_ == null)
         {
            _openPunishPopupObject = {
               "punishType":param1,
               "durationInHours":param2
            };
            return;
         }
         LoadProgress.show(false);
         var _loc4_:MovieClip = MovieClip(_loc6_.getChildAt(0));
         var _loc3_:String = getWarningFrameLabelString(param1);
         _guiLayer.addChild(_punishPopup);
         if(_loc4_.currentFrameLabel != _loc3_)
         {
            _loc4_.gotoAndStop(_loc3_);
         }
         DarkenManager.darken(_punishPopup);
         if((param1 == -1 || param1 == -2) && _loc4_.rulesBtn != null)
         {
            _loc4_.rulesBtn.addEventListener("mouseDown",onRulesBtnClicked,false,0,true);
         }
         if(gMainFrame.server.isConnected)
         {
            if(_loc3_ == "accountBan")
            {
               SBTracker.trackPageview("game/play/popup/autoBan",-1,1);
            }
            else
            {
               SBTracker.trackPageview("game/play/popup/warning/" + _loc3_,-1,1);
            }
         }
         if(param1 == -2)
         {
            if(param2 % 24 == 0)
            {
               LocalizationManager.translateIdAndInsert(_loc4_.messageTxt,18407,param2 / 24);
            }
            else
            {
               LocalizationManager.translateIdAndInsert(_loc4_.messageTxt,18409,param2);
            }
            LocalizationManager.translateId(_loc4_.titleTxt,18433);
         }
         else if(param1 == -1)
         {
            LocalizationManager.translateId(_loc4_.messageTxt,18408);
            LocalizationManager.translateId(_loc4_.titleTxt,18432);
         }
         else if(_loc3_ == "scamming")
         {
            LocalizationManager.translateId(_loc4_.titleTxt,4144);
            LocalizationManager.translateId(_loc4_.messageTxt,4145);
         }
         else if(_loc3_ == "personalInfo")
         {
            LocalizationManager.translateId(_loc4_.titleTxt,4142);
            LocalizationManager.translateId(_loc4_.messageTxt,4140);
         }
         else if(_loc3_ == "bullying")
         {
            LocalizationManager.translateId(_loc4_.titleTxt,4136);
            LocalizationManager.translateId(_loc4_.messageTxt,4137);
         }
         else if(_loc3_ == "behavior")
         {
            if(param1 == 0)
            {
               LocalizationManager.translateId(_loc4_.titleTxt,19762);
               LocalizationManager.translateId(_loc4_.messageTxt,19761);
               _contextualWarningTimer.delay = 5000;
            }
            else
            {
               LocalizationManager.translateId(_loc4_.titleTxt,4138);
               LocalizationManager.translateId(_loc4_.messageTxt,4141);
            }
         }
         if(_isRulesPopupOpen)
         {
            onRulesBtnClicked(null);
         }
      }
   }
}

