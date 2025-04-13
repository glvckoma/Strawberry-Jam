package avatar
{
   import com.adobe.utils.StringUtil;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBAJOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import game.MinigameInfo;
   import game.MinigameManager;
   import gui.ActionManager;
   import gui.ChatHistory;
   import gui.EmoticonManager;
   import gui.EmoticonUtility;
   import gui.GuiManager;
   import gui.SafeChatManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import nodeHop.NodeHopXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   
   public class UserCommXtCommManager
   {
      public static var RAW_STR:String;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_ONE_MINUTE:int = 22368;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_FULL_DEPLOY_IN_N_MINUTES:int = 22367;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_ONE_MINUTE:int = 22370;
      
      private static const BROADCAST_MESSAGE_LOC_ID_UPDATING_AJ_HOTFIX_IN_N_MINUTES:int = 22369;
      
      private static var _drainPopupDelay:Number;
      
      private static var _playerSfsUserId:int = -1;
      
      private static var _mainHud:MovieClip;
      
      private static var _chatHist:ChatHistory;
      
      private static var _emoteMgr:EmoticonManager;
      
      private static var _actionMgr:ActionManager;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _spellingCorrections:Object;
      
      private static var _emoteDefs:Object;
      
      private static var _specialWords:Object;
      
      private static var _replacedWords:Object;
      
      private static var _customPVPMessageCallback:Object;
      
      private static var _customPVPPassback:Object;
      
      private static var _originalPermEmoteBeingDisplayed:int;
      
      private static var _secondPermEmoteInUse:Boolean;
      
      public function UserCommXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         DebugUtility.debugTrace("UserCommXtCommManager init - initializing");
         _mainHud = GuiManager.mainHud;
         _chatHist = GuiManager.chatHist;
         _emoteMgr = GuiManager.emoteMgr;
         _actionMgr = GuiManager.actionMgr;
         _roomMgr = RoomManagerWorld.instance;
         _drainPopupDelay = Math.random() * 10 * 60 * 1000;
         if(_drainPopupDelay < 300000)
         {
            _drainPopupDelay = Math.random() * 10 * 60 * 1000;
         }
         _playerSfsUserId = AvatarManager.playerSfsUserId;
         RAW_STR = gMainFrame.server.rawProtocolSeparator;
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc1_.init(1036,onEmoticonDefsLoaded,null,2);
         DefPacksDefHelper.mediaArray[1036] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(10,onAutoCorrectListLoaded,null,1);
         DefPacksDefHelper.mediaArray["10"] = _loc1_;
         _specialWords = {};
         _specialWords[LocalizationManager.translateIdOnly(14855)] = LocalizationManager.translateIdOnly(11142);
         _originalPermEmoteBeingDisplayed = -1;
      }
      
      private static function onAutoCorrectListLoaded(param1:DefPacksDefHelper) : void
      {
         var _loc3_:int = 0;
         DefPacksDefHelper.mediaArray["10"] = null;
         var _loc2_:String = param1.def.toString().toLowerCase() as String;
         _spellingCorrections = {};
         _spellingCorrections["constructor"] = "constructor";
         var _loc4_:Array = _loc2_.split("\r\n");
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            _loc4_[_loc3_] = _loc4_[_loc3_].split(",");
            if(!(_loc4_[_loc3_][0] == null || _loc4_[_loc3_][0].length == 0 || _loc4_[_loc3_][1] == null || _loc4_[_loc3_][1].length == 0))
            {
               _spellingCorrections[StringUtil.trim(_loc4_[_loc3_][0])] = StringUtil.trim(_loc4_[_loc3_][1]);
            }
            _loc3_++;
         }
      }
      
      private static function onEmoticonDefsLoaded(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1036] = null;
         var _loc3_:Object = param1.def;
         var _loc2_:Object = {};
         for each(var _loc4_ in _loc3_)
         {
            _loc2_[_loc4_.id] = int(_loc4_.mediaRef);
         }
         _emoteDefs = _loc2_;
      }
      
      public static function destroy() : void
      {
      }
      
      public static function set playerSfsUserId(param1:int) : void
      {
         _playerSfsUserId = param1;
      }
      
      public static function getEmoticonMediaId(param1:int) : int
      {
         if(!_emoteDefs[param1])
         {
            return 0;
         }
         return _emoteDefs[param1];
      }
      
      public static function getEmoticonDefId(param1:int) : int
      {
         for(var _loc2_ in _emoteDefs)
         {
            if(_emoteDefs[_loc2_] == param1)
            {
               return int(_loc2_);
            }
         }
         return 0;
      }
      
      public static function addChatMessage(param1:String) : void
      {
         _chatHist.addMessage(gMainFrame.userInfo.playerAvatarInfo.avName,gMainFrame.userInfo.playerAvatarInfo.userName,gMainFrame.userInfo.playerUserInfo.getModeratedUserName(),param1);
      }
      
      public static function sendAvatarSafeChat(param1:String, param2:String, param3:Boolean = true) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.addAvatarMessage(param1,_playerSfsUserId,0);
         addChatMessage(param1);
         gMainFrame.server.sendMessage(param2 + RAW_STR + 1);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
         if(param3)
         {
            GuiManager.safeChatBtnDownHandler(null);
         }
      }
      
      public static function sendAvatarEmote(param1:Sprite) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.setAvatarEmote(param1);
         if(!EmoticonUtility.getEmoteString(param1))
         {
            throw new Error("setAvatarEmote: sent invalid emote sprite?!");
         }
         addChatMessage(EmoticonUtility.getEmoteString(param1));
         gMainFrame.server.sendMessage(EmoticonUtility.idForEmote(param1) + RAW_STR + 2);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
      }
      
      public static function sendAvatarAction(param1:Sprite) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         AvatarManager.setAvatarAction(param1);
         if(!_actionMgr.getActionString(param1))
         {
            throw new Error("setAvatarAction: sent invalid action sprite?!");
         }
         addChatMessage(_actionMgr.getActionString(param1));
         var _loc2_:AvatarWorldView = AvatarManager.avatarViewList[AvatarManager.playerSfsUserId];
         var _loc3_:int = _loc2_.lastIdleAnim;
         gMainFrame.server.sendMessage(_actionMgr.getActionString(param1) + RAW_STR + 3 + RAW_STR + _loc3_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            _chatHist.setFocusOnMsgText();
         }
      }
      
      public static function sendAvatarAttachmentEmot(param1:int, param2:String = null) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         if(param2 == null)
         {
            param2 = "";
         }
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + 4);
      }
      
      public static function sendAvatarBlendColor(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + 8);
      }
      
      public static function sendAvatarAlphaLevel(param1:uint) : void
      {
         gMainFrame.server.sendMessage(int(param1) + RAW_STR + 10);
      }
      
      public static function sendChatMessage(param1:int, param2:String) : void
      {
         if(gMainFrame.clientInfo.invisMode || !Utility.canChat())
         {
            return;
         }
         param2 = fixMispellings(param2);
         param2 = adjustCamelCase(param2);
         AvatarManager.addAvatarMessage("...",param1,0);
         param2 = adjustSpecialWords(param2);
         var _loc3_:int = gMainFrame.userInfo.sgChatType == 1 ? 0 : 9;
         gMainFrame.server.sendMessage(param2 + RAW_STR + _loc3_);
         if(_chatHist.enableFreeChatValue)
         {
            _chatHist.resetTreeSearch();
            _chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = _chatHist.chatMsgText;
         }
      }
      
      public static function adjustSpecialWords(param1:String) : String
      {
         var _loc4_:String = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:String = null;
         var _loc10_:String = null;
         var _loc3_:String = null;
         _replacedWords = {};
         var _loc6_:Array = param1.split(" ");
         var _loc11_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < _loc6_.length)
         {
            _loc7_ = _loc6_[_loc8_];
            _loc4_ = _loc7_.toLowerCase();
            for(var _loc2_ in _specialWords)
            {
               _loc9_ = int(_loc4_.indexOf(_loc2_));
               if(_loc9_ >= 0)
               {
                  _loc5_ = _loc7_.substr(0,_loc9_);
                  _loc10_ = _loc7_.substr(_loc9_,_loc2_.length);
                  _loc3_ = _loc7_.substr(_loc9_ + _loc2_.length);
                  _loc11_ = getCaseType(_loc10_);
                  _loc10_ = setCaseType(_specialWords[_loc2_],_loc11_);
                  _loc6_[_loc8_] = _loc5_ + _loc10_ + _loc3_;
                  _replacedWords[_loc6_[_loc8_]] = _loc7_;
               }
            }
            _loc8_++;
         }
         return _loc6_.join(" ");
      }
      
      private static function getCaseType(param1:String) : int
      {
         if(param1.toLowerCase() == param1)
         {
            return 0;
         }
         var _loc3_:String = param1.charAt(0);
         var _loc2_:int = int(param1.match(/[A-Z]/g).length);
         if(_loc2_ == param1.length)
         {
            return 1;
         }
         return 2;
      }
      
      private static function setCaseType(param1:String, param2:int) : String
      {
         if(param2 == 0)
         {
            return param1.toLowerCase();
         }
         if(param2 == 1)
         {
            return param1.toUpperCase();
         }
         param1 = param1.toLowerCase();
         var _loc3_:String = param1.charAt(0).toUpperCase();
         return _loc3_ + param1.substr(1);
      }
      
      public static function reverseSpecialWords(param1:String) : String
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         if(_replacedWords == null)
         {
            return param1;
         }
         var _loc2_:Array = param1.split(" ");
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_].toLowerCase();
            if(!(_replacedWords[_loc3_] == null || _loc3_ == "constructor"))
            {
               _loc2_[_loc4_] = _replacedWords[_loc3_];
            }
            _loc4_++;
         }
         _replacedWords = null;
         return _loc2_.join(" ");
      }
      
      public static function adjustCamelCase(param1:String) : String
      {
         var _loc2_:int = 0;
         var _loc7_:String = null;
         var _loc6_:String = null;
         var _loc8_:String = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = param1.split(" ");
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            _loc7_ = _loc6_.match(/[a-zA-Z]/g).join("");
            _loc8_ = _loc7_.charAt(0);
            _loc2_ = int(_loc7_.match(/[A-Z]/g).length);
            if(_loc2_ > 0 && _loc2_ != _loc7_.length)
            {
               if(_loc8_.match(/[A-z]/g).length == 1)
               {
                  _loc5_ = getIndexOfFirstLetter(_loc6_,_loc7_);
                  _loc3_[_loc4_] = _loc6_.substr(0,_loc5_) + _loc8_ + _loc6_.toLowerCase().substr(_loc5_ + 1,_loc6_.length);
               }
               else
               {
                  _loc3_[_loc4_] = _loc6_.toLowerCase();
               }
            }
            _loc4_++;
         }
         return _loc3_.join(" ");
      }
      
      public static function getFirstLetter(param1:String) : String
      {
         var _loc2_:String = param1.match(/[a-zA-Z]/g).join("");
         if(_loc2_.length > 0)
         {
            return _loc2_.charAt(0);
         }
         return null;
      }
      
      public static function getIndexOfFirstLetter(param1:String, param2:String) : int
      {
         var _loc3_:int = 0;
         if(param2 == "")
         {
            param2 = param1.match(/[a-zA-Z]/g).join();
         }
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1.charAt(_loc3_) == param2.charAt(0))
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public static function fixMispellings(param1:String) : String
      {
         var _loc4_:String = null;
         var _loc3_:int = 0;
         if(!_spellingCorrections || LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            return param1;
         }
         var _loc2_:Array = param1.split(" ");
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_].toLowerCase();
            _loc4_ = stripPunctuation(_loc4_);
            if(_spellingCorrections[_loc4_] != null)
            {
               _loc4_ = _spellingCorrections[_loc4_];
               _loc2_[_loc3_] = _loc4_;
            }
            _loc3_++;
         }
         return _loc2_.join(" ");
      }
      
      public static function stripPunctuation(param1:String) : String
      {
         return param1.replace(/[^A-Za-z0-9 ']+/g,"");
      }
      
      public static function sendAvatarSlide(param1:String) : void
      {
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         gMainFrame.server.sendMessage(param1 + RAW_STR + 6);
      }
      
      public static function sendPermEmote(param1:int) : void
      {
         if(_originalPermEmoteBeingDisplayed != -1)
         {
            if(param1 == -1)
            {
               if(_secondPermEmoteInUse)
               {
                  param1 = _originalPermEmoteBeingDisplayed;
                  _secondPermEmoteInUse = false;
               }
               _originalPermEmoteBeingDisplayed = -1;
            }
            else
            {
               _secondPermEmoteInUse = true;
            }
         }
         else
         {
            _originalPermEmoteBeingDisplayed = param1;
         }
         gMainFrame.server.sendMessage(param1 + RAW_STR + 5);
      }
      
      public static function sendPetAction(param1:int, param2:int = 0) : void
      {
         gMainFrame.server.sendMessage(param1 + "," + param2 + RAW_STR + 7);
      }
      
      public static function sendCustomAdventureMessage(param1:Boolean) : void
      {
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 11);
      }
      
      public static function sendCustomPVPMessage(param1:Boolean, param2:int, param3:Function = null, param4:Object = null) : void
      {
         _customPVPMessageCallback = param3;
         _customPVPPassback = param4;
         gMainFrame.server.sendMessage((param1 ? "on" : "off") + RAW_STR + 12 + RAW_STR + param2);
      }
      
      public static function onSendMessage(param1:MouseEvent, param2:String = "") : void
      {
         var _loc5_:Sprite = null;
         var _loc4_:String = null;
         if(_playerSfsUserId == -1)
         {
            DebugUtility.debugTrace("WARNING - UserCommXtCommManager.init was never called or the playerAvatarId is bad");
            _playerSfsUserId = AvatarManager.playerSfsUserId;
         }
         var _loc3_:String = param2 == "" ? _mainHud.chatBar.text01_chat.text : param2;
         _loc3_ = _loc3_.split("\r").join("");
         _loc3_ = _loc3_.split(RAW_STR).join("");
         _loc3_ = StringUtil.trim(_loc3_);
         if(_loc3_.length <= 0)
         {
            return;
         }
         var _loc6_:Object = EmoticonUtility.matchEmoteString(_loc3_);
         if(_loc6_.status)
         {
            if(_loc6_.sprite)
            {
               sendAvatarEmote(_loc6_.sprite);
               AvatarManager.setAvatarEmote(_loc6_.sprite,-2);
            }
            else
            {
               _loc5_ = _actionMgr.matchActionString(_loc3_);
               if(_loc5_)
               {
                  sendAvatarAction(_loc5_);
                  AvatarManager.setAvatarAction(_loc5_,-2);
               }
               else
               {
                  _loc4_ = SafeChatManager.safeChatCodeForString(onSendMessage,[param1,param2],_loc3_,gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom() ? 4 : 0);
                  if(_loc4_ == "")
                  {
                     return;
                  }
                  if(_loc4_)
                  {
                     sendAvatarSafeChat(_loc3_,_loc4_,false);
                     AvatarManager.addAvatarMessage(_loc3_,_playerSfsUserId,0);
                  }
                  else
                  {
                     sendChatMessage(_playerSfsUserId,_loc3_);
                  }
               }
            }
            return;
         }
         _chatHist.resetTreeSearch();
         _chatHist.chatMsgText.text = "";
         gMainFrame.stage.focus = _chatHist.chatMsgText;
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "uc":
               userCommChatResponse(_loc2_);
               break;
            case "ua":
               userCommAdminMessageResponse(_loc2_);
               break;
            default:
               throw new Error("UserCommXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      private static function userCommChatResponse(param1:Array) : void
      {
         var _loc2_:* = null;
         var _loc17_:int = 0;
         var _loc4_:Array = null;
         var _loc13_:Array = null;
         var _loc11_:Array = null;
         var _loc3_:Object = null;
         var _loc15_:Array = null;
         var _loc7_:MinigameInfo = null;
         var _loc14_:Boolean = false;
         var _loc18_:String = null;
         var _loc9_:Sprite = null;
         var _loc5_:Sprite = null;
         var _loc10_:Array = null;
         var _loc12_:int = 0;
         var _loc8_:Avatar = null;
         var _loc16_:Array = null;
         var _loc19_:int = int(param1[2]);
         var _loc20_:int = int(param1[4]);
         if(true)
         {
            if(_loc20_ == 5)
            {
               _loc17_ = int(param1[3]);
               if(_loc17_ >= 0)
               {
                  AvatarManager.setAvatarEmote(null,_loc19_,_loc17_);
               }
               else
               {
                  AvatarManager.setChatBalloonReadyForClear(_loc19_);
               }
            }
            else if(_loc20_ == 6)
            {
               if(_loc19_ != gMainFrame.server.userId)
               {
                  _roomMgr.attachAvatarToSlide(AvatarManager.avatarViewList[_loc19_],param1[3]);
               }
            }
            else if(_loc20_ == 7)
            {
               _loc4_ = param1[3].split(",");
               AvatarManager.setPetAction(_loc19_,_loc4_[0],_loc4_[1]);
            }
            else if(_loc20_ == 11)
            {
               _loc2_ = param1[3];
               if(_loc2_ == "off")
               {
                  AvatarManager.addCustomAdventureMessage("","off",_loc19_,0,0);
                  if(_loc19_ == AvatarManager.playerSfsUserId)
                  {
                     QuestManager.privateAdventureJoinClose(false,false);
                  }
               }
               else
               {
                  _loc13_ = _loc2_.split("|");
                  _loc11_ = _loc13_[0].split(",");
                  _loc3_ = QuestXtCommManager.getScriptDef(_loc11_[0]);
                  if(_loc3_)
                  {
                     AvatarManager.addCustomAdventureMessage(LocalizationManager.translateIdOnly(_loc3_.titleStrId),_loc13_[1] + "|" + _loc11_[0],_loc19_,_loc11_[2],int(param1[5]));
                  }
               }
            }
            else if(_loc20_ == 12)
            {
               _loc2_ = param1[3];
               _loc15_ = param1[3].split("|");
               _loc7_ = MinigameManager.minigameInfoCache.getMinigameInfo(_loc15_[1]);
               if(_loc15_[0] == "off")
               {
                  if(_loc19_ == AvatarManager.playerSfsUserId)
                  {
                     MinigameManager.readySelfForQuickMinigame(null,false);
                     MinigameManager.readySelfForPvpGame(null,null,false);
                  }
                  AvatarManager.addCustomPvpMessage("",_loc15_[0],_loc19_,0,0);
               }
               else
               {
                  if(_loc19_ == AvatarManager.playerSfsUserId)
                  {
                     MinigameManager.readySelfForPvpGame({"typeDefId":_loc15_[1]},null,true,true);
                     GuiManager.grayOutHudItemsForPrivateLobby(true,true);
                  }
                  AvatarManager.addCustomPvpMessage(LocalizationManager.translateIdOnly(_loc7_.titleStrId),_loc2_,_loc19_,0,int(param1[5]));
               }
               if(_customPVPMessageCallback)
               {
                  if(_customPVPPassback != null)
                  {
                     if(_customPVPPassback.hasOwnProperty("gameInfo"))
                     {
                        _customPVPMessageCallback(_customPVPPassback.gameInfo,_customPVPPassback.currUserName,_customPVPPassback.currUserNameModerated);
                     }
                     else if(_customPVPPassback.hasOwnProperty("gameEntry"))
                     {
                        _customPVPMessageCallback(_customPVPPassback.gameEntry,_customPVPPassback.frgJoinedCallback,_customPVPPassback.skipGameCard,_customPVPPassback.gameCloseCallback,_customPVPPassback.optionalParam);
                     }
                     else
                     {
                        _customPVPMessageCallback(_customPVPPassback);
                     }
                  }
                  else
                  {
                     _customPVPMessageCallback();
                  }
                  _customPVPMessageCallback = null;
               }
            }
            else
            {
               _loc2_ = param1[3];
               _loc14_ = false;
               if(_loc20_ == 1)
               {
                  _loc18_ = SafeChatManager.safeChatStringForCode(userCommChatResponse,[param1],_loc2_);
                  if(_loc18_ == "")
                  {
                     return;
                  }
                  if(_loc18_)
                  {
                     _loc2_ = _loc18_;
                  }
                  else
                  {
                     _loc14_ = true;
                  }
               }
               if(!_loc14_)
               {
                  switch(_loc20_)
                  {
                     case 0:
                     case 1:
                     case 9:
                        _loc2_ = adjustCamelCase(_loc2_);
                        if(_loc19_ == gMainFrame.server.userId)
                        {
                           _loc2_ = reverseSpecialWords(_loc2_);
                        }
                        AvatarManager.addAvatarMessage(_loc2_,_loc19_,int(param1[5]));
                        break;
                     case 2:
                        _loc9_ = EmoticonUtility.emoteForId(int(_loc2_));
                        if(_loc9_)
                        {
                           AvatarManager.setAvatarEmote(_loc9_,_loc19_);
                        }
                        else
                        {
                           _loc14_ = true;
                        }
                        _loc2_ = EmoticonUtility.stringForId(int(_loc2_));
                        break;
                     case 3:
                        _loc5_ = _actionMgr.matchActionString(_loc2_);
                        if(_loc5_)
                        {
                           AvatarManager.setAvatarAction(_loc5_,_loc19_);
                           break;
                        }
                        _loc14_ = true;
                        break;
                     case 4:
                        _loc10_ = _loc2_.split(",");
                        _loc12_ = int(_loc10_[0]);
                        AvatarManager._setAvatarAttachmentEmot(_loc12_,_loc10_[1],_loc19_);
                        break;
                     case 8:
                        AvatarManager._setAvatarBlendColor(_loc19_,uint(param1[3]));
                        return;
                     case 10:
                        AvatarManager._setAvatarAlphaLevel(_loc19_,uint(param1[3]));
                        return;
                     default:
                        _loc14_ = true;
                  }
               }
               if(_loc14_)
               {
                  DebugUtility.debugTrace("WARNING - got bad chat! msg:" + _loc2_ + " chatType:" + _loc20_ + " from userId:" + _loc19_);
                  return;
               }
               if(_loc20_ != 4)
               {
                  if(gMainFrame.clientInfo.extCallsActive)
                  {
                     _loc8_ = AvatarManager.getAvatarBySfsUserId(_loc19_);
                     DebugUtility.debugTrace("mrc:sending cm command - chattyUserId:" + _loc19_ + " chattyAv:" + _loc8_);
                     if(int(param1[5]) == 2)
                     {
                        _loc16_ = _loc2_.split("|");
                        _loc16_.splice(0,1);
                        _loc2_ = _loc16_.join("|");
                     }
                     ExternalInterface.call("mrc",["cm",_loc8_.userName,_loc2_,int(param1[5])]);
                     DebugUtility.debugTrace("mrc:cm command sent - chattyUserName:" + _loc8_.userName + " msg:" + _loc2_);
                  }
                  if((_loc19_ != gMainFrame.server.userId || _loc19_ == gMainFrame.server.userId && (_loc20_ == 0 || _loc20_ == 9)) && int(param1[5]) <= 1)
                  {
                     _chatHist.addMessageById(_loc19_,_loc2_);
                  }
               }
            }
         }
      }
      
      private static function userCommAdminMessageResponse(param1:Array) : void
      {
         var msgId:int;
         var msgSplit:Array;
         var isSystemMsg:Boolean;
         var data:Array = param1;
         var adminMsg:String = data[1];
         if(adminMsg == "__FORCE_RELOGIN__")
         {
            setTimeout(refreshPage,Math.abs(_roomMgr.shardId) * 911 % 5000,{"status":true});
         }
         else
         {
            msgSplit = adminMsg.split("|");
            if(msgSplit.length > 1)
            {
               msgId = int(msgSplit[0]);
               adminMsg = LocalizationManager.translateIdAndInsertOnly(msgId,msgSplit.slice(1));
            }
            isSystemMsg = data[2] == null || int(data[2]) == 1;
            if(!isSystemMsg)
            {
               gMainFrame.clientInfo.lastBroadcastMessage = adminMsg;
               GuiManager.updateSettingsMessage();
            }
            if(isSystemMsg || !gMainFrame.isInMinigame() && gMainFrame.clientInfo.roomType != 7)
            {
               if(msgId != 22367 && msgId != 22368 && msgId != 22369 && msgId != 22370)
               {
                  new SBAJOkPopup(GuiManager.guiLayer,adminMsg);
               }
               else
               {
                  setTimeout(function():void
                  {
                     new SBYesNoPopup(GuiManager.guiLayer,adminMsg,true,refreshPage);
                  },_drainPopupDelay);
               }
            }
            _chatHist.addPrivateMessage(LocalizationManager.translateIdOnly(15964),null,adminMsg);
         }
      }
      
      private static function refreshPage(param1:Object) : void
      {
         if(param1["status"])
         {
            NodeHopXtCommManager.sendNodeHopForDrainRequest();
         }
      }
      
      private static function getSpecialFormat() : TextFormat
      {
         var _loc1_:TextFormat = new TextFormat();
         _loc1_.color = 12845056;
         _loc1_.bold = true;
         return _loc1_;
      }
   }
}

