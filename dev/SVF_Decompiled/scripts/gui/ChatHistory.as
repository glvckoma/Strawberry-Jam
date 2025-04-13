package gui
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import buddy.BuddyManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.StyleSheet;
   import flash.text.TextField;
   import flash.ui.Mouse;
   import gui.itemWindows.ItemWindowTextNode;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomXtCommManager;
   
   public class ChatHistory
   {
      private const CHAT_DIM_ALPHA:Number = 0.5;
      
      private const CHAT_BRIGHT_ALPHA:Number = 1;
      
      private var _keyListenersActive:Boolean;
      
      private var _enableFreeChat:Boolean = true;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _predictiveText:MovieClip;
      
      private var _specialCharText:MovieClip;
      
      private var _chatText:TextField;
      
      private var _chatBarContainer:MovieClip;
      
      private var _chatRepeatBtn:MovieClip;
      
      private var _chatRepeatWindow:MovieClip;
      
      private var _repeatChatWindows:WindowGenerator;
      
      private var _chatRepeatArray:Array;
      
      private var _hasSetupChatRepeatBtn:Boolean;
      
      private var _isOverChatText:Boolean;
      
      public var chatHistory:MovieClip;
      
      public var chatUpDown:MovieClip;
      
      public var chatMsgText:TextField;
      
      public var chatSendBtn:MovieClip;
      
      public var sendMsgCallback:Function;
      
      public function ChatHistory(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip)
      {
         super();
         if(chatHistory)
         {
            throw new Error("ERROR: Singleton ChatHistory did not expect to be created twice!");
         }
         setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip, param12:Boolean) : void
      {
         _keyListenersActive = true;
         _isOverChatText = false;
         if(chatHistory)
         {
            chatHistory.removeEventListener("mouseDown",chatClickHandler);
         }
         if(chatUpDown)
         {
            chatUpDown.removeEventListener("mouseDown",openCloseHandler);
         }
         if(_chatText)
         {
            _chatText.removeEventListener("mouseDown",chatClickHandler);
            _chatText.removeEventListener("link",onChatLink);
            _chatText.removeEventListener("mouseOver",overChatText);
            _chatText.removeEventListener("mouseOut",outChatText);
         }
         if(chatMsgText)
         {
            chatMsgText.removeEventListener("keyDown",keyDownListener);
            chatMsgText.removeEventListener("mouseDown",msgTextDownHandler);
            if(Mouse["supportsNativeCursor"])
            {
               chatMsgText.removeEventListener("mouseOver",mouseOverMsgText);
               chatMsgText.removeEventListener("mouseOut",mouseOutMsgText);
            }
         }
         if(_chatRepeatBtn)
         {
            _chatRepeatBtn.removeEventListener("mouseDown",onChatRepeatBtn);
         }
         _hasSetupChatRepeatBtn = false;
         setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function resetChatPrivs(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         if(Utility.canChat())
         {
            _loc2_ = int(gMainFrame.userInfo.sgChatType);
            if(_loc2_ != 0 && _loc2_ != 3)
            {
               chatMsgText.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
               enableFreeChat(true);
               if(param1 && _predictiveTextManager)
               {
                  _predictiveTextManager.reload(chatMsgText,_predictiveText,_specialCharText,_chatBarContainer);
               }
               else
               {
                  _predictiveTextManager = new PredictiveTextManager();
                  _predictiveTextManager.init(chatMsgText,0,_predictiveText,_specialCharText,343,_chatBarContainer,sendMsgCallback);
               }
               if(_chatText)
               {
                  _chatText.selectable = false;
                  _chatText.htmlText = "";
               }
               _enableFreeChat = true;
            }
            else
            {
               enableFreeChat(false);
            }
         }
         else
         {
            enableFreeChat(false);
         }
      }
      
      public function destroy() : void
      {
         chatMsgText.removeEventListener("keyDown",keyDownListener);
         _keyListenersActive = false;
         chatMsgText.removeEventListener("mouseDown",msgTextDownHandler);
         if(_chatText)
         {
            _chatText.removeEventListener("mouseDown",chatClickHandler);
            _chatText.removeEventListener("link",onChatLink);
            _chatText.removeEventListener("mouseOver",overChatText);
            _chatText.removeEventListener("mouseOut",outChatText);
            _chatText = null;
         }
         chatHistory.removeEventListener("mouseDown",chatClickHandler);
         chatHistory.visible = false;
         chatHistory = null;
         chatUpDown.removeEventListener("mouseDown",openCloseHandler);
         chatUpDown.visible = false;
         chatUpDown = null;
      }
      
      public function showChatInput(param1:Boolean) : void
      {
         chatUpDown.visible = param1;
         chatMsgText.visible = param1;
         if(chatSendBtn)
         {
            chatSendBtn.visible = param1;
         }
      }
      
      public function addMessageById(param1:int, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc3_:UserInfo = null;
         var _loc5_:Avatar = AvatarManager.getAvatarBySfsUserId(param1);
         if(_loc5_)
         {
            _loc4_ = _loc5_.userName;
            if(_loc4_ != null && _loc4_ != "_unknown")
            {
               _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_loc4_);
               if(_loc3_)
               {
                  addMessage(_loc5_.avName,_loc4_,_loc3_.getModeratedUserName(),param2);
               }
            }
         }
      }
      
      public function addMessage(param1:String, param2:String, param3:String, param4:String) : void
      {
         var _loc5_:Boolean = false;
         var _loc6_:* = 0;
         var _loc7_:int = 0;
         var _loc8_:String = null;
         if(_chatText && param1 != null && param1.length > 0 && param2 && param4)
         {
            _chatText.htmlText += "<a href=\"event:" + param2 + "\">" + (Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE) ? param3 : param1) + ": " + "</a>" + param4 + "\n";
            if(_chatRepeatWindow && AvatarManager.playerAvatar && param2.toLowerCase() == AvatarManager.playerAvatar.userName.toLowerCase())
            {
               _loc7_ = 0;
               while(_loc7_ < _chatRepeatArray.length)
               {
                  if(_chatRepeatArray[_loc7_] == param4)
                  {
                     _loc5_ = true;
                     _loc6_ = _loc7_;
                     break;
                  }
                  _loc7_++;
               }
               if(!_loc5_)
               {
                  if(_chatRepeatArray.length >= 5)
                  {
                     _chatRepeatArray.shift();
                  }
                  _chatRepeatArray.push(param4);
                  onChatRepeatBtn(null);
               }
               else
               {
                  _chatRepeatArray.splice(_loc6_,1);
                  _chatRepeatArray.push(param4);
                  onChatRepeatBtn(null);
               }
               setupRepeatChat();
            }
         }
         else
         {
            _chatText.htmlText += "\"" + param4 + "\"" + "\n";
         }
         if(_chatText.numLines >= 100)
         {
            _loc8_ = _chatText.htmlText;
            _chatText.htmlText = _loc8_.substr(_loc8_.indexOf("\n") + 1);
         }
         if(!_isOverChatText)
         {
            _chatText.scrollV = _chatText.maxScrollV;
         }
      }
      
      public function removeEmotesFromChatRepeat() : void
      {
         var _loc1_:int = 0;
         if(_chatRepeatArray && _chatRepeatArray.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _chatRepeatArray.length)
            {
               if(EmoticonUtility.doesStringMatchAnEmote(_chatRepeatArray[_loc1_]))
               {
                  _chatRepeatArray.splice(_loc1_,1);
                  _loc1_--;
               }
               _loc1_++;
            }
            setupRepeatChat();
            onChatRepeatBtn(null);
         }
      }
      
      public function addPrivateMessage(param1:String, param2:String, param3:String) : void
      {
         if(_chatText)
         {
            if(param2 == null)
            {
               _chatText.htmlText += param1 + ": " + param3 + "\n";
            }
            else
            {
               _chatText.htmlText += param1 + " to " + param2 + ": " + param3 + "\n";
            }
         }
      }
      
      public function reAddKeyListeners() : void
      {
         if(!_keyListenersActive)
         {
            chatMsgText.addEventListener("keyDown",keyDownListener,false,0,true);
            _keyListenersActive = true;
         }
      }
      
      public function removeKeyListeners() : void
      {
         if(_keyListenersActive)
         {
            chatMsgText.removeEventListener("keyDown",keyDownListener);
            _keyListenersActive = false;
         }
      }
      
      public function clearChat() : void
      {
         if(_chatText)
         {
            _chatText.htmlText = "";
         }
         _chatRepeatArray = [];
         setupRepeatChat();
         onRepeatWindoesLoaded(true);
         if(_chatText)
         {
            _chatText.scrollV = 0;
         }
      }
      
      public function openChat() : void
      {
         if(chatHistory.currentFrameLabel != "open")
         {
            chatUpDown.gotoAndStop("down");
            chatHistory.gotoAndPlay("open");
            brightenChat();
            AJAudio.playChatOpenSound();
            closeChatRepeatWindow();
         }
      }
      
      public function closeChatRepeatWindow() : void
      {
         if(_chatRepeatWindow && _chatRepeatWindow.visible)
         {
            _chatRepeatWindow.visible = false;
            _chatRepeatBtn.downToUpState();
         }
      }
      
      public function dimChat() : void
      {
         if(chatHistory && chatHistory.currentFrameLabel == "open" && chatHistory.alpha == 1)
         {
            chatHistory.alpha = 0.5;
         }
      }
      
      public function brightenChat() : void
      {
         if(chatHistory.alpha != 1)
         {
            chatHistory.alpha = 1;
         }
      }
      
      public function closeChat() : void
      {
         if(chatHistory && chatHistory.currentFrameLabel != null && chatHistory.currentFrameLabel != "close")
         {
            _isOverChatText = false;
            brightenChat();
            chatUpDown.gotoAndStop("up");
            chatHistory.gotoAndPlay("close");
            AJAudio.playChatCloseSound();
         }
      }
      
      public function get enableFreeChatValue() : Boolean
      {
         return _enableFreeChat;
      }
      
      public function enableFreeChat(param1:Boolean) : void
      {
         _enableFreeChat = param1;
         chatMsgText.text = "";
         if(!param1)
         {
            chatMsgText.restrict = "";
            if(_chatText)
            {
               _chatText.selectable = false;
            }
         }
         else
         {
            chatMsgText.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
            if(_chatText)
            {
               _chatText.selectable = false;
            }
         }
         if(_specialCharText)
         {
            _specialCharText.visible = false;
         }
      }
      
      public function resetTreeSearch() : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         if(_predictiveTextManager && _predictiveTextManager.isAllowedFreeChat())
         {
            chatMsgText.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
         }
      }
      
      public function doesChatContainText() : Boolean
      {
         if(chatMsgText.text != "")
         {
            return true;
         }
         return false;
      }
      
      public function setFocusOnMsgText() : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes <= 0 || gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3 || !Utility.canChat())
         {
            gMainFrame.stage.focus = null;
         }
         else
         {
            gMainFrame.stage.focus = chatMsgText;
         }
      }
      
      public function setFocusToChatTextWithKeydown(param1:KeyboardEvent, param2:String) : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            gMainFrame.stage.focus = chatMsgText;
            if(chatMsgText)
            {
               keyDownListener(param1);
            }
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      public function toggleInGameHud(param1:Boolean) : void
      {
         if(param1)
         {
            chatMsgText.maxChars = 40;
         }
         else
         {
            chatMsgText.maxChars = 70;
         }
      }
      
      private function setupInitialItems(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip) : void
      {
         var _loc13_:StyleSheet = null;
         var _loc12_:Object = null;
         _keyListenersActive = true;
         chatHistory = param1;
         _predictiveText = param8;
         _specialCharText = param9;
         _chatBarContainer = param2;
         _chatRepeatBtn = param10;
         _chatRepeatWindow = param11;
         _chatRepeatArray = [];
         _isOverChatText = false;
         if(param1)
         {
            chatHistory.gotoAndStop(1);
            chatHistory.addEventListener("mouseDown",chatClickHandler,false,0,true);
            chatUpDown = param3;
            chatUpDown.gotoAndStop(1);
            chatUpDown["up"].mouse.gotoAndStop(1);
            chatUpDown.addEventListener("mouseDown",openCloseHandler,false,0,true);
         }
         if(param4)
         {
            param4.glow.visible = false;
         }
         chatMsgText = param5;
         toggleInGameHud(false);
         chatMsgText.text = "";
         if(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3)
         {
            chatMsgText.restrict = "";
         }
         else
         {
            chatMsgText.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
         }
         if(gMainFrame.userInfo.sgChatType != 2)
         {
            if(GuiManager.mainHud.ansChatBtn)
            {
               GuiManager.mainHud.ansChatBtn.visible = false;
            }
            param6 = GuiManager.mainHud.sendChatBtn;
            if(param6)
            {
               param6.visible = true;
            }
         }
         else
         {
            if(GuiManager.mainHud.sendChatBtn)
            {
               GuiManager.mainHud.sendChatBtn.visible = false;
            }
            param6 = GuiManager.mainHud.ansChatBtn;
            if(param6)
            {
               param6.visible = true;
            }
         }
         if(GuiManager.mainHud.emailChatBtn)
         {
            if((gMainFrame.clientInfo.userEmail == null || gMainFrame.clientInfo.userEmail == "") && (gMainFrame.clientInfo.pendingEmail == null || gMainFrame.clientInfo.pendingEmail == ""))
            {
               if(param6)
               {
                  param6.visible = false;
               }
               param6 = GuiManager.mainHud.emailChatBtn;
               if(param6)
               {
                  param6.visible = true;
               }
            }
            else
            {
               GuiManager.mainHud.emailChatBtn.visible = false;
            }
         }
         if(_chatRepeatWindow)
         {
            _chatRepeatWindow.visible = false;
         }
         setupLanguageFlag();
         param8.visible = false;
         _chatText = GuiManager.mainHud.chatHistTxt;
         chatSendBtn = param6;
         sendMsgCallback = param7;
         if(_chatText)
         {
            _chatText.addEventListener("mouseDown",chatClickHandler,false,0,true);
            _chatText.addEventListener("link",onChatLink,false,0,true);
            _chatText.addEventListener("mouseOver",overChatText,false,0,true);
            _chatText.addEventListener("mouseOut",outChatText,false,0,true);
            _loc13_ = new StyleSheet();
            _loc12_ = {};
            _loc12_.color = "#ff9900";
            _loc13_.setStyle("a:hover",_loc12_);
            _chatText.styleSheet = _loc13_;
         }
         chatMsgText.addEventListener("change",onTextFieldChanged,false,0,true);
         chatMsgText.addEventListener("keyDown",keyDownListener,false,0,true);
         chatMsgText.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            chatMsgText.addEventListener("mouseOver",mouseOverMsgText,false,0,true);
            chatMsgText.addEventListener("mouseOut",mouseOutMsgText,false,0,true);
         }
         if(chatSendBtn)
         {
            chatSendBtn.addEventListener("mouseDown",sendChatBtnDownHandler,false,0,true);
         }
         setupRepeatChat();
         resetChatPrivs();
         setFocusOnMsgText();
      }
      
      private function setupRepeatChat() : void
      {
         if(_chatRepeatBtn)
         {
            if(gMainFrame.userInfo.isMember && _chatRepeatArray.length > 0)
            {
               _chatRepeatBtn.visible = true;
               GuiManager.mainHud.bgChatRepeat.visible = true;
               if(!_hasSetupChatRepeatBtn)
               {
                  _chatRepeatBtn.addEventListener("mouseDown",onChatRepeatBtn,false,0,true);
               }
               _hasSetupChatRepeatBtn = true;
            }
            else if(_chatRepeatBtn.visible || GuiManager.mainHud.bgChatRepeat.visible)
            {
               _chatRepeatBtn.visible = false;
               GuiManager.mainHud.bgChatRepeat.visible = false;
               _chatRepeatBtn.removeEventListener("mouseDown",onChatRepeatBtn);
               _hasSetupChatRepeatBtn = false;
            }
         }
      }
      
      private function setupLanguageFlag() : void
      {
         if(LocalizationManager.currentLanguage != LocalizationManager.accountLanguage)
         {
            _chatBarContainer.flag.gotoAndStop(LocalizationManager.currentLanguage + 1);
            _chatBarContainer.text01_chat.width = 258.75;
            _chatBarContainer.text01_chat.x = -130.5;
            _chatBarContainer.flag.addEventListener("mouseDown",onEscapeFlagDown,false,0,true);
         }
         else
         {
            _chatBarContainer.flag.gotoAndStop("off");
            _chatBarContainer.text01_chat.width = 290.75;
            _chatBarContainer.text01_chat.x = -162.5;
            _chatBarContainer.flag.removeEventListener("mouseDown",onEscapeFlagDown);
         }
      }
      
      private function onEscapeFlagDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translatePreferredIdOnly(15989),true,onConfirmEscape);
      }
      
      private function onConfirmEscape(param1:Object) : void
      {
         if(param1.status)
         {
            if(QuestManager.inQuestRoom())
            {
               QuestManager.commandExit("flag");
            }
            else
            {
               RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#-1");
            }
         }
      }
      
      private function openCloseHandler(param1:MouseEvent) : void
      {
         if(chatHistory.currentFrameLabel == "open")
         {
            closeChat();
         }
         else if(!param1.currentTarget["up"].isGray)
         {
            openChat();
         }
      }
      
      private function mouseOverMsgText(param1:MouseEvent) : void
      {
         CursorManager.showICursor(true);
      }
      
      private function mouseOutMsgText(param1:MouseEvent) : void
      {
         CursorManager.showICursor(false);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            if(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3 || !Utility.canChat())
            {
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
               }
               gMainFrame.stage.focus = null;
               return;
            }
            gMainFrame.stage.focus = chatMsgText;
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onTextClick();
            }
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      private function chatClickHandler(param1:MouseEvent) : void
      {
         brightenChat();
      }
      
      private function onChatLink(param1:TextEvent) : void
      {
         if(param1.text && param1.text != "" && param1.text != gMainFrame.userInfo.myUserName)
         {
            BuddyManager.showBuddyCard({
               "userName":param1.text,
               "onlineStatus":0
            });
         }
      }
      
      private function overChatText(param1:MouseEvent) : void
      {
         _isOverChatText = true;
      }
      
      private function outChatText(param1:MouseEvent) : void
      {
         _isOverChatText = false;
      }
      
      private function onTextFieldChanged(param1:Event) : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(param1)
         {
            if(_enableFreeChat)
            {
               if(_predictiveTextManager)
               {
                  _predictiveTextManager.onKeyDown(param1);
               }
            }
         }
      }
      
      private function sendChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget == GuiManager.mainHud.emailChatBtn)
            {
               GuiManager.initEmailConfirmation(null,null,false);
            }
            else if(gMainFrame.userInfo.sgChatType == 2)
            {
               if(LocalizationManager.accountLanguage != LocalizationManager.currentLanguage)
               {
                  onEscapeFlagDown(null);
               }
               else
               {
                  FeedbackManager.openFeedbackPopup(19);
               }
            }
            else if(_enableFreeChat)
            {
               if(_predictiveTextManager)
               {
                  _predictiveTextManager.onSendBtnDown(param1);
               }
               chatSendBtn.down.visible = false;
               chatSendBtn.mouse.visible = true;
               chatSendBtn.mouse.gotoAndPlay(1);
            }
         }
      }
      
      private function onChatRepeatBtn(param1:MouseEvent) : void
      {
         if(param1 == null || !param1.currentTarget.isGray)
         {
            if(param1 != null && _chatRepeatWindow.visible)
            {
               _chatRepeatWindow.visible = false;
               return;
            }
            if(param1 == null && !_chatRepeatWindow.visible)
            {
               return;
            }
            _chatRepeatWindow.visible = true;
            if(chatHistory.visible)
            {
               closeChat();
            }
            if(_repeatChatWindows)
            {
               _repeatChatWindows.destroy();
               _repeatChatWindows = null;
            }
            while(_chatRepeatWindow.itemWindow.numChildren > 1)
            {
               _chatRepeatWindow.itemWindow.removeChildAt(1);
            }
            _repeatChatWindows = new WindowGenerator();
            _repeatChatWindows.init(1,_chatRepeatArray.length,_chatRepeatArray.length,0,0,0,ItemWindowTextNode,_chatRepeatArray,"",{
               "mouseDown":onRepeatChatSelected,
               "mouseOver":null,
               "mouseOut":null
            },null,onRepeatWindoesLoaded);
            _chatRepeatWindow.itemWindow.addChild(_repeatChatWindows);
         }
      }
      
      private function onRepeatWindoesLoaded(param1:Boolean = false) : void
      {
         if(_chatRepeatWindow)
         {
            _chatRepeatWindow.m.height = param1 ? 33 : Math.round(_repeatChatWindows.height);
            _chatRepeatWindow.m.width = _chatRepeatWindow.t.width = _chatRepeatWindow.b.width = param1 ? 268 : _repeatChatWindows.width + 2;
            _chatRepeatWindow.m.y = _chatRepeatWindow.b.y - _chatRepeatWindow.m.height;
            _chatRepeatWindow.t.y = _chatRepeatWindow.m.y - _chatRepeatWindow.t.height;
            _chatRepeatWindow.itemWindow.x = _chatRepeatWindow.m.x;
            _chatRepeatWindow.itemWindow.y = _chatRepeatWindow.m.y;
         }
      }
      
      private function onRepeatChatSelected(param1:MouseEvent) : void
      {
         if(!AvatarManager.playerAvatarWorldView.isSameMessage(param1.currentTarget.text))
         {
            sendMsgCallback(null,param1.currentTarget.text);
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeat",-1,1);
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeatDeny",-1,1);
         }
         closeChatRepeatWindow();
      }
   }
}

