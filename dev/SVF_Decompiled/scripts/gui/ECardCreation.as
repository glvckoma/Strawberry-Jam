package gui
{
   import avatar.AvatarManager;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserInfo;
   import buddy.*;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.TradeItemCollection;
   import com.greensock.TweenMax;
   import com.greensock.easing.Circ;
   import com.greensock.plugins.StageQualityPlugin;
   import com.greensock.plugins.TweenPlugin;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import ecard.ECardImageBase;
   import ecard.ECardXtCommManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import gui.itemWindows.ItemWindowBuddyList;
   import gui.itemWindows.ItemWindowECardPreview;
   import gui.itemWindows.ItemWindowStamp;
   import inventory.Iitem;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import playerWall.PlayerWallManager;
   import trade.TradeConfirmPopup;
   
   public class ECardCreation
   {
      private const NUM_VIS_STAMP_ROWS:int = 3;
      
      private const CREATION_MEDIA_ID:int = 4472;
      
      private var _eCardCreation:MovieClip;
      
      private var _eCardClothes:DenAndClothesItemSelect;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _tradeConfirmation:TradeConfirmPopup;
      
      private var _onCloseCallback:Function;
      
      private var _backBtnCallback:Function;
      
      private var _toUserName:String;
      
      private var _toModeratedUserName:String;
      
      private var _toAccountType:int;
      
      private var _currCardId:int;
      
      private var _currStampId:int;
      
      private var _messageType:int;
      
      private var _msg:String;
      
      private var _type:int;
      
      private var _giftItemIdx:int = -1;
      
      private var _isAllowedToType:Boolean;
      
      private var _keyboardEvent:KeyboardEvent;
      
      private var _createOnly:Boolean;
      
      private var _buddyListItemWindow:WindowAndScrollbarGenerator;
      
      private var _toolTipPositions:Object;
      
      private var _currIitemBeingRemoved:Iitem;
      
      private var _valentinesPopup:MovieClip;
      
      private var _cardMediaIds:Array;
      
      private var _stampMediaIds:Array;
      
      private var _currentECardImageBase:ECardImageBase;
      
      private var _currentStampImageBase:ECardImageBase;
      
      private var _loadInTween:TweenMax;
      
      private var _dummyMsgTxt:TextField;
      
      private var _stampWindow:WindowAndScrollbarGenerator;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _eCardLoadingSpiral:LoadingSpiral;
      
      private var _eCardWindowsLoadingSpiral:LoadingSpiral;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _itemWindowECards:WindowAndScrollbarGenerator;
      
      private var _defaultTxtYPosition:Number;
      
      public function ECardCreation()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:String, param3:String, param4:int, param5:Array, param6:Array, param7:Function, param8:Function, param9:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _toUserName = param2;
         _toModeratedUserName = param3;
         _toAccountType = param4;
         _cardMediaIds = param5;
         _stampMediaIds = param6;
         _backBtnCallback = param7;
         _onCloseCallback = param8;
         _createOnly = param9;
         TweenPlugin.activate([StageQualityPlugin]);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4472,onPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         removeListeners();
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(_eCardCreation);
         }
         SafeChatManager.destroy(_eCardCreation.chatTree);
         if(!_eCardCreation.backBtn.visible || param1)
         {
            DarkenManager.unDarken(_eCardCreation);
            if(_eCardCreation.parent == _guiLayer)
            {
               _guiLayer.removeChild(_eCardCreation);
            }
         }
         else if(!param1)
         {
            _loadInTween = new TweenMax(_eCardCreation,0.5,{
               "alpha":0,
               "onComplete":onLoadInTweenComplete,
               "ease":Circ.easeIn,
               "yoyo":true
            });
            return;
         }
         if(_stampWindow)
         {
            _stampWindow.destroy();
            _stampWindow = null;
         }
         if(_buddyListItemWindow)
         {
            _buddyListItemWindow.destroy();
            _buddyListItemWindow = null;
         }
         if(_itemWindowECards)
         {
            _itemWindowECards.destroy();
            _itemWindowECards = null;
         }
         GuiManager.displayRulesPopup(false);
         if(_eCardClothes)
         {
            _eCardClothes.destroy();
            _eCardClothes = null;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         if(_eCardLoadingSpiral)
         {
            _eCardLoadingSpiral.destroy();
            _eCardLoadingSpiral = null;
         }
         if(_eCardWindowsLoadingSpiral)
         {
            _eCardWindowsLoadingSpiral.destroy();
            _eCardWindowsLoadingSpiral = null;
         }
         if(_predictiveTextManager)
         {
            _predictiveTextManager.destroy();
            _predictiveTextManager = null;
         }
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyList",onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyChanged",onBuddyListChange);
      }
      
      public function get visibility() : Boolean
      {
         return _eCardCreation.visible;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         _eCardCreation = param1.getChildAt(0) as MovieClip;
         _eCardCreation.x = 900 * 0.5;
         _eCardCreation.y = 550 * 0.5;
         _eCardCreation.alpha = 0;
         _guiLayer.addChild(_eCardCreation);
         DarkenManager.darken(_eCardCreation);
         KeepAlive.startKATimer(_eCardCreation);
         _loadingSpiral = new LoadingSpiral(_eCardCreation.buddyList.itemBlock,_eCardCreation.buddyList.itemBlock.width * 0.5,_eCardCreation.buddyList.itemBlock.height * 0.5);
         _eCardLoadingSpiral = new LoadingSpiral(_eCardCreation.eCardItemWindow,_eCardCreation.eCardItemWindow.width * 0.5,_eCardCreation.eCardItemWindow.height * 0.5);
         _eCardWindowsLoadingSpiral = new LoadingSpiral(_eCardCreation.cardItemWindow,_eCardCreation.cardItemWindow.width * 0.5,_eCardCreation.cardItemWindow.height * 0.5);
         _msg = "0,0";
         _eCardCreation.buddyList.visible = false;
         _eCardCreation.giftIcon.visible = false;
         _eCardCreation.stampList.visible = false;
         _eCardCreation.textBtn.currTxt.tabEnabled = false;
         _eCardCreation.textBtn.tabEnabled = false;
         _eCardCreation.tabEnabled = false;
         _eCardCreation.addGiftBtn.activateGrayState(false);
         _eCardCreation.mouseOverEcard.leftBtn.activateGrayState(false);
         _eCardCreation.mouseOverEcard.rightBtn.activateGrayState(false);
         _eCardCreation.mouseOverEcard.leftBtn.visible = true;
         _eCardCreation.mouseOverEcard.rightBtn.visible = true;
         _eCardCreation.textBtn.currTxt.maxChars = 70;
         _eCardCreation.charCounter.text = "0/70";
         _eCardCreation.charCounter.visible = false;
         _eCardCreation.mouseOverEcard.alpha = 0;
         _eCardCreation.predictTxtTag.visible = false;
         _eCardCreation.cardSlot.visible = false;
         _eCardCreation.nonMemIcon.visible = false;
         if(_createOnly)
         {
            _eCardCreation.backBtn.visible = false;
         }
         _currCardId = 0;
         _currStampId = 0;
         _messageType = 1;
         BuddyManager.eventDispatcher.addEventListener("OnBuddyList",onBuddyListChange,false,0,true);
         BuddyManager.eventDispatcher.addEventListener("OnBuddyChanged",onBuddyListChange,false,0,true);
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:String = gMainFrame.stage.quality;
         _loadInTween = new TweenMax(_eCardCreation,0.4,{
            "alpha":1,
            "onComplete":onLoadInTweenComplete,
            "ease":Circ.easeIn,
            "stageQuality":{
               "stage":gMainFrame.stage,
               "during":"low",
               "after":_loc2_
            }
         });
      }
      
      private function onLoadInTweenComplete() : void
      {
         var _loc1_:int = 0;
         if(_loadInTween._yoyo)
         {
            destroy(true);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(!BuddyList.listRequested)
            {
               BuddyXtCommManager.sendBuddyListRequest();
               putInGrayedOutState(true);
               BuddyList.listRequested = true;
            }
            else
            {
               _loc1_ = BuddyManager.buddyCount;
               if(_toUserName == "")
               {
                  setupUsernameButton(true);
                  if(_eCardCreation.sendBtn.hasGrayState)
                  {
                     _eCardCreation.sendBtn.activateGrayState(true);
                  }
                  if(_loc1_ != 0)
                  {
                     toBtnHandler(null);
                  }
                  else
                  {
                     putInGrayedOutState(true);
                  }
                  _eCardCreation.buddyList.visible = !_eCardCreation.buddyList.visible == true && _loc1_ > 0 && _toUserName == "" ? true : false;
               }
               else
               {
                  toBtnHandler(null);
                  setupUsernameButton(false);
               }
            }
            _predictiveTextManager = new PredictiveTextManager();
            _predictiveTextManager.init(_eCardCreation.textBtn.currTxt,1,_eCardCreation.predictTxtTag,_eCardCreation.specialCharCont,-162,_eCardCreation.textBtn,null,checkShouldCompleteSuggestion);
            _eCardCreation.textBtn.currTxt.text = "";
            SafeChatManager.buildSafeChatTree(_eCardCreation.chatTree,"ECardTextTreeNode",1,onECardTextClose,null,onChatTreeLoaded);
            SafeChatManager.closeSafeChat(_eCardCreation.chatTree);
            setupToolTipPositions();
            setupECardWindows();
            addListeners();
         }
      }
      
      private function onChatTreeLoaded() : void
      {
         _eCardCreation.textBtn.currTxt.text = SafeChatManager.ctNodes[0][0];
      }
      
      private function getCurrCardId() : int
      {
         return _currCardId;
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _onCloseCallback();
      }
      
      private function setupUsernameButton(param1:Boolean) : void
      {
         var _loc2_:UserInfo = null;
         var _loc3_:MovieClip = _eCardCreation.toTab.nameBars;
         _eCardCreation.selectABuddy.visible = param1;
         if(param1)
         {
            _loc3_.member.visible = false;
            _loc3_.nonmember.visible = true;
            LocalizationManager.translateId(_loc3_.nonmember.txt,11276);
         }
         else
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_toUserName);
            if(_loc2_)
            {
               if(Utility.isMember(_loc2_.accountType))
               {
                  _eCardCreation.nonMemIcon.visible = false;
                  _loc3_.member.visible = true;
                  _loc3_.nonmember.visible = false;
                  _loc3_.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
                  _loc3_.member.setNubType(NameBar.BUDDY,false);
                  _loc3_.member.setColorAndBadge(_loc2_.nameBarData);
                  _loc3_.member.setAvName(_loc2_.getModeratedUserName(),Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),null,false);
                  _loc3_.member.isBlocked = BuddyManager.isBlocked(_toUserName);
               }
               else
               {
                  _eCardCreation.nonMemIcon.visible = true;
                  _loc3_.member.visible = false;
                  _loc3_.nonmember.visible = true;
                  _loc3_.nonmember.txt.text = _loc2_.getModeratedUserName();
               }
            }
            else
            {
               AvatarXtCommManager.requestAvatarGet(_toUserName,onAvatarGet);
            }
         }
      }
      
      private function onAvatarGet(param1:String, param2:Boolean, param3:int) : void
      {
         if(param1 == _toUserName)
         {
            setupUsernameButton(false);
         }
      }
      
      private function setupToolTipPositions() : void
      {
         var _loc1_:Point = null;
         _toolTipPositions = {};
         _loc1_ = _eCardCreation.sendBtn.localToGlobal(new Point(0,-_eCardCreation.sendBtn.height * 0.5 - 10));
         _toolTipPositions[_eCardCreation.sendBtn] = _loc1_;
         _loc1_ = _eCardCreation.backBtn.localToGlobal(new Point(0,-_eCardCreation.backBtn.height * 0.5 - 10));
         _toolTipPositions[_eCardCreation.backBtn] = _loc1_;
         _loc1_ = _eCardCreation.addTextBtn.localToGlobal(new Point(0,-_eCardCreation.addTextBtn.height * 0.5 + 12));
         _toolTipPositions[_eCardCreation.addTextBtn] = _loc1_;
         _loc1_ = _eCardCreation.addGiftBtn.localToGlobal(new Point(0,-_eCardCreation.addGiftBtn.height * 0.5 - 10));
         _toolTipPositions[_eCardCreation.addGiftBtn] = _loc1_;
         _loc1_ = _eCardCreation.addStampBtn.localToGlobal(new Point(0,-_eCardCreation.addStampBtn.height * 0.5 + 12));
         _toolTipPositions[_eCardCreation.addStampBtn] = _loc1_;
      }
      
      private function setupECardWindows() : void
      {
         _itemWindowECards = new WindowAndScrollbarGenerator();
         _itemWindowECards.init(_eCardCreation.cardItemWindow.width,_eCardCreation.cardItemWindow.height,0,0,1,4,0,0,2,0,1,ItemWindowECardPreview,_cardMediaIds,"",0,{"mouseDown":eCardBtnDownHandler},{
            "currIndexFunction":getCurrCardId,
            "shouldGrayOutPreview":shouldGrayOutPreview
         },onECardWindowsLoaded,true,false,false);
         _eCardCreation.cardItemWindow.addChild(_itemWindowECards);
      }
      
      private function onECardWindowsLoaded() : void
      {
         _eCardWindowsLoadingSpiral.visible = false;
      }
      
      private function createAndLoadStampsAndEcards() : void
      {
         if(_stampMediaIds && _stampWindow == null)
         {
            _stampWindow = new WindowAndScrollbarGenerator();
            _stampWindow.init(_eCardCreation.stampList.itemBlock.width,_eCardCreation.stampList.itemBlock.height,0,0,1,3,0,0,1,0,0.5,ItemWindowStamp,_stampMediaIds,"img2",0,{
               "mouseDown":stampBtnDownHandler,
               "mouseOver":stampBtnOverHandler,
               "mouseOut":stampBtnOutHandler
            },null,null,true,false,false);
            _eCardCreation.stampList.itemBlock.addChild(_stampWindow);
            _stampWindow.x = 0;
            _stampWindow.y = 0;
         }
      }
      
      private function drawCurrCardAndStamp() : void
      {
         drawCurrCard();
         drawCurrStamp();
      }
      
      private function shouldGrayOutPreview() : Boolean
      {
         return BuddyManager.buddyCount > 0 || _createOnly || _toUserName != "";
      }
      
      private function putInGrayedOutState(param1:Boolean) : void
      {
         var gray:Boolean = param1;
         with(_eCardCreation)
         {
            mouseOverEcard.leftBtn.activateGrayState(gray);
            mouseOverEcard.rightBtn.activateGrayState(gray);
            addStampBtn.activateGrayState(gray);
            addTextBtn.activateGrayState(gray);
            textBtn.activateGrayState(gray);
            if(!gray)
            {
               if(_toUserName != "")
               {
                  sendBtn.activateGrayState(gray);
               }
               if(Utility.canGift() && _giftItemIdx == -1)
               {
                  addGiftBtn.activateGrayState(gray);
               }
               drawCurrCardAndStamp();
            }
            else
            {
               _eCardLoadingSpiral.visible = false;
               _eCardCreation.selectABuddy.visible = false;
               if(BuddyList.listRequested)
               {
                  _eCardCreation.cardSlot.visible = true;
               }
               _eCardCreation.nonMemIcon.visible = false;
               sendBtn.activateGrayState(gray);
               addGiftBtn.activateGrayState(gray);
               if(_stampWindow)
               {
                  _stampWindow.destroy();
                  _stampWindow = null;
                  if(_stampListScrollButtons)
                  {
                     _stampListScrollButtons.destroy();
                     _stampListScrollButtons = null;
                  }
                  while(stampSlot.stampLayer.numChildren > 1)
                  {
                     stampSlot.stampLayer.removeChild(stampSlot.stampLayer.getChildAt(1));
                  }
               }
            }
            toTab.visible = !gray;
            textBtn.currTxt.selectable = !gray;
         }
      }
      
      private function drawCurrCard() : void
      {
         if(_cardMediaIds && _cardMediaIds[_currCardId])
         {
            while(_eCardCreation.eCardItemWindow.numChildren > 2)
            {
               _eCardCreation.eCardItemWindow.removeChildAt(_eCardCreation.eCardItemWindow.numChildren - 1);
            }
            _eCardLoadingSpiral.visible = true;
            _currentECardImageBase = new ECardImageBase();
            _currentECardImageBase.init(_cardMediaIds[_currCardId],onECardImageLoaded);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current card to draw");
         }
      }
      
      private function onECardImageLoaded() : void
      {
         if(_eCardLoadingSpiral)
         {
            _eCardLoadingSpiral.visible = false;
         }
         _eCardCreation.eCardItemWindow.addChild(_currentECardImageBase.img);
         _defaultTxtYPosition = _currentECardImageBase.msgTxt.y;
         _currentECardImageBase.msgTxt.text = _eCardCreation.textBtn.currTxt.text;
         _currentECardImageBase.msgTxt.restrict = LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG ? "A-Za-z0-9!\'.,():?\\- " : "A-Za-z0-9À-ÖØ-öø-ÿ!\'.,():?¿¡\\- ";
         _dummyMsgTxt = new TextField();
         _dummyMsgTxt.text = _currentECardImageBase.msgTxt.text;
         var _loc1_:TextFormat = _currentECardImageBase.msgTxt.getTextFormat();
         _dummyMsgTxt.setTextFormat(_loc1_);
         _dummyMsgTxt.defaultTextFormat = _loc1_;
         updateMessageText();
         onStampImageLoaded();
      }
      
      private function drawCurrStamp() : void
      {
         if(_stampMediaIds && _stampMediaIds[_currStampId])
         {
            _currentStampImageBase = new ECardImageBase();
            _currentStampImageBase.init(_stampMediaIds[_currStampId],onStampImageLoaded);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current stamp to draw");
         }
      }
      
      private function onStampImageLoaded() : void
      {
         if(_currentECardImageBase && _currentECardImageBase.img && _currentStampImageBase && _currentStampImageBase.img)
         {
            while(_currentECardImageBase.stamp.numChildren > 1)
            {
               _currentECardImageBase.stamp.removeChild(_currentECardImageBase.stamp.getChildAt(1));
            }
            _currentECardImageBase.stamp.addChild(_currentStampImageBase.img);
         }
      }
      
      private function mouseOverMsgText(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            CursorManager.showICursor(true);
         }
      }
      
      private function mouseOutMsgText(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            CursorManager.showICursor(false);
         }
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               addTextBtnHandler(param1);
            }
            else
            {
               if(!(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3))
               {
                  _isAllowedToType = true;
                  if(_messageType == 1)
                  {
                     _eCardCreation.textBtn.currTxt.text = "";
                     if(_currentECardImageBase && _currentECardImageBase.img)
                     {
                        _currentECardImageBase.msgTxt.text = "";
                        _dummyMsgTxt.text = "";
                        _currentECardImageBase.msgTxt.setSelection(_currentECardImageBase.msgTxt.length,_currentECardImageBase.msgTxt.length);
                     }
                     _msg = "";
                     _eCardCreation.charCounter.visible = true;
                     _eCardCreation.charCounter.text = "0/" + _eCardCreation.textBtn.currTxt.maxChars;
                  }
                  else if(_messageType == 2)
                  {
                     _predictiveTextManager.onTextClick();
                  }
                  return;
               }
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
               }
            }
            gMainFrame.stage.focus = null;
         }
      }
      
      private function onKeyFocusChange(param1:FocusEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(_isAllowedToType)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
            if(_currentECardImageBase && _currentECardImageBase.img && _currentECardImageBase.msgTxt.text.toLowerCase() != _eCardCreation.textBtn.currTxt.text.toLowerCase())
            {
               updateMessageText();
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(_isAllowedToType)
         {
            if(_eCardCreation.chatTree.visible)
            {
               SafeChatManager.closeSafeChat(_eCardCreation.chatTree);
               _eCardCreation.addTextBtn.downToUpState();
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onKeyDown(param1);
            }
            _messageType = 2;
         }
      }
      
      private function checkShouldCompleteSuggestion(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Function = null) : void
      {
         checkShouldCompleteSuggestionWork(param1,param2,param3,param4);
      }
      
      private function checkShouldCompleteSuggestionWork(param1:String, param2:Boolean, param3:Boolean, param4:Function) : void
      {
         var _loc6_:TextField = null;
         var _loc5_:TextFormat = null;
         if(param2)
         {
            updateMessageText();
            if(param4 != null)
            {
               param4(param1,param3,true,true);
               return;
            }
         }
         if(_currentECardImageBase && _currentECardImageBase.img)
         {
            _loc6_ = new TextField();
            _loc5_ = _currentECardImageBase.msgTxt.getTextFormat();
            _loc6_.text = _currentECardImageBase.msgTxt.text + param1;
            _loc6_.setTextFormat(_loc5_);
            if(_loc6_.length > _eCardCreation.textBtn.currTxt.maxChars)
            {
               if(param4 != null)
               {
                  param4(param1,param3,false);
               }
            }
            else if(param4 != null)
            {
               param4(param1,param3,true);
            }
         }
      }
      
      private function updateMessageText() : void
      {
         var _loc1_:TextFormat = null;
         if(_currentECardImageBase && _currentECardImageBase.img)
         {
            _currentECardImageBase.msgTxt.text = _dummyMsgTxt.text = _eCardCreation.textBtn.currTxt.text.toUpperCase();
            _loc1_ = _currentECardImageBase.msgTxt.getTextFormat();
            if(_dummyMsgTxt.textHeight / Number(_currentECardImageBase.msgTxt.getTextFormat().size) > 1 || _dummyMsgTxt.textHeight / 50 > 1 || _currentECardImageBase.msgTxt.numLines > 1)
            {
               _loc1_.size = 30;
               _currentECardImageBase.msgTxt.setTextFormat(_loc1_);
               _dummyMsgTxt.setTextFormat(_loc1_);
               if(_currentECardImageBase.msgTxt.textHeight / Number(_currentECardImageBase.msgTxt.getTextFormat().size) < 1)
               {
                  _currentECardImageBase.msgTxt.y = _defaultTxtYPosition + 13;
               }
               else
               {
                  _currentECardImageBase.msgTxt.y = _defaultTxtYPosition;
               }
            }
            else
            {
               _loc1_.size = 50;
               _currentECardImageBase.msgTxt.setTextFormat(_loc1_);
               _dummyMsgTxt.setTextFormat(_loc1_);
               _currentECardImageBase.msgTxt.y = _defaultTxtYPosition;
            }
            if(_messageType == 1)
            {
               _loc1_ = _eCardCreation.textBtn.currTxt.getTextFormat();
               _loc1_.color = 4531987;
               _eCardCreation.textBtn.currTxt.setTextFormat(_loc1_);
            }
            if(!_eCardCreation.charCounter.visible && _messageType != 1)
            {
               _eCardCreation.charCounter.visible = true;
            }
            _msg = _currentECardImageBase.msgTxt.text.toUpperCase();
            _eCardCreation.charCounter.text = _msg.length + "/" + _eCardCreation.textBtn.currTxt.maxChars;
         }
      }
      
      private function sendMailBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_eCardCreation.sendBtn.isGray || gMainFrame.clientInfo.extCallsActive)
         {
            return;
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(_msg.length == 0 || _msg.match(/\S/g).length == 0)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(11277));
            return;
         }
         if(!_predictiveTextManager.isValid() && _messageType != 1)
         {
            _predictiveTextManager.showUnapprovedChatPopup();
            return;
         }
         gMainFrame.stage.focus = null;
         sendECard(param1);
      }
      
      private function sendMailBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14648),_toolTipPositions[_eCardCreation.sendBtn].x,_toolTipPositions[_eCardCreation.sendBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function loadValentinesPopup() : void
      {
         if(_valentinesPopup)
         {
            _guiLayer.addChild(_valentinesPopup);
            DarkenManager.darken(_valentinesPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(6999,onValentinesPopupLoaded);
         }
      }
      
      private function onValentinesPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _valentinesPopup = param1.getChildAt(0) as MovieClip;
         _valentinesPopup.x = 900 / 2;
         _valentinesPopup.y = 550 / 2;
         _valentinesPopup.bx.addEventListener("mouseDown",onValentinesClose,false,0,true);
         _valentinesPopup.infoBtn.addEventListener("mouseDown",onValentinesInfo,false,0,true);
         _valentinesPopup.valentineBtn.addEventListener("mouseDown",onValentinesSend,false,0,true);
         _valentinesPopup.jagBtn.addEventListener("mouseDown",onValentinesSend,false,0,true);
         _guiLayer.addChild(_valentinesPopup);
         DarkenManager.darken(_valentinesPopup);
      }
      
      private function onValentinesClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _guiLayer.removeChild(_valentinesPopup);
         DarkenManager.unDarken(_valentinesPopup);
      }
      
      private function onValentinesInfo(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(32133));
      }
      
      private function onValentinesSend(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _guiLayer.removeChild(_valentinesPopup);
         DarkenManager.unDarken(_valentinesPopup);
         _valentinesPopup.bx.removeEventListener("mouseDown",onValentinesClose);
         _valentinesPopup.infoBtn.removeEventListener("mouseDown",onValentinesInfo);
         _valentinesPopup.valentineBtn.removeEventListener("mouseDown",onValentinesSend);
         _valentinesPopup.jagBtn.removeEventListener("mouseDown",onValentinesSend);
         sendECard(param1);
      }
      
      private function sendECard(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         backBtnHandler(param1);
         DarkenManager.showLoadingSpiral(true);
         if(_valentinesPopup && param1.currentTarget == _valentinesPopup.valentineBtn)
         {
            _loc2_ = ECardXtCommManager.sendECardSendRequest(_toUserName,_toModeratedUserName,_currentECardImageBase.mediaId,_currentStampImageBase.mediaId,_messageType,_msg,_type,_giftItemIdx,1,onSentResponseCallback);
         }
         else
         {
            _loc2_ = ECardXtCommManager.sendECardSendRequest(_toUserName,_toModeratedUserName,_currentECardImageBase.mediaId,_currentStampImageBase.mediaId,_messageType,_msg,_type,_giftItemIdx,0,onSentResponseCallback);
         }
         if(_valentinesPopup)
         {
            _valentinesPopup = null;
         }
         if(!_loc2_)
         {
            return;
         }
         AJAudio.playMailSentSound();
      }
      
      private function arrowBtnHandler(param1:Event) : void
      {
         var _loc2_:* = false;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc5_:int = 0;
         param1.stopPropagation();
         if(_eCardLoadingSpiral && !_eCardLoadingSpiral.visible)
         {
            if(param1 is KeyboardEvent)
            {
               if(gMainFrame.stage.focus != null)
               {
                  return;
               }
               _loc3_ = int((param1 as KeyboardEvent).keyCode);
               if(!(_loc3_ == 39 || _loc3_ == 37 || _loc3_ == 38 || _loc3_ == 40))
               {
                  return;
               }
               _loc2_ = _loc3_ == 37 || _loc3_ == 38;
            }
            else
            {
               _loc2_ = param1.currentTarget == _eCardCreation.mouseOverEcard.leftBtn;
            }
            _loc4_ = _loc2_ ? _eCardCreation.mouseOverEcard.leftBtn : _eCardCreation.mouseOverEcard.rightBtn;
            if(!_loc4_.isGray)
            {
               _loc5_ = _currCardId;
               if(_cardMediaIds)
               {
                  if(_loc2_)
                  {
                     if(_currCardId <= 0)
                     {
                        _currCardId = _cardMediaIds.length - 1;
                     }
                     else
                     {
                        _currCardId--;
                     }
                  }
                  else if(_currCardId >= _cardMediaIds.length - 1)
                  {
                     _currCardId = 0;
                  }
                  else
                  {
                     _currCardId++;
                  }
               }
               _itemWindowECards.callUpdateOnWindow(_loc5_);
               _itemWindowECards.callUpdateOnWindow(_currCardId);
               _itemWindowECards.scrollToIndex(_currCardId,false);
               drawCurrCard();
            }
         }
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         param1.preventDefault();
         param1.stopPropagation();
         arrowBtnHandler(param1);
      }
      
      private function onECardItemWindowOverOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.type == "mouseOver" && !_eCardCreation.mouseOverEcard.leftBtn.isGray)
         {
            _eCardCreation.mouseOverEcard.alpha = 1;
         }
         else
         {
            _eCardCreation.mouseOverEcard.alpha = 0;
         }
      }
      
      private function backBtnHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(_backBtnCallback != null)
         {
            _backBtnCallback(param1 == null ? true : false);
         }
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyList",onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener("OnBuddyChanged",onBuddyListChange);
      }
      
      private function backBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(11207),_toolTipPositions[_eCardCreation.backBtn].x,_toolTipPositions[_eCardCreation.backBtn].y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function backBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function addTextBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!_eCardCreation.addTextBtn.isGray)
         {
            if(_eCardCreation.stampList.visible)
            {
               _eCardCreation.stampList.visible = false;
               _eCardCreation.addStampBtn.downToUpState();
            }
            if(!_eCardCreation.chatTree.visible)
            {
               SafeChatManager.openSafeChat(false,_eCardCreation.chatTree);
               _eCardCreation.addTextBtn.upToDownState();
            }
            else
            {
               SafeChatManager.closeSafeChat(_eCardCreation.chatTree);
               _eCardCreation.addTextBtn.downToUpState();
            }
         }
      }
      
      private function addTextBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14649),_toolTipPositions[_eCardCreation.addTextBtn].x,_toolTipPositions[_eCardCreation.addTextBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onECardTextClose(param1:String, param2:String) : void
      {
         _predictiveTextManager.resetTreeSearch();
         _eCardCreation.addTextBtn.downToUpState();
         _eCardCreation.charCounter.visible = false;
         _eCardCreation.charCounter.text = "0/" + _eCardCreation.textBtn.currTxt.maxChars;
         if(_currentECardImageBase && _currentECardImageBase.img)
         {
            _eCardCreation.textBtn.currTxt.text = _currentECardImageBase.msgTxt.text = param1;
         }
         _messageType = 1;
         SafeChatManager.closeSafeChat(_eCardCreation.chatTree);
         updateMessageText();
         _msg = param2;
      }
      
      private function addGiftBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!param1.currentTarget.isGray)
         {
            if(gMainFrame.userInfo.isMember)
            {
               if(Utility.isMember(_toAccountType))
               {
                  if(_eCardClothes)
                  {
                     onEcardClothesClose(null);
                  }
                  _eCardClothes = new DenAndClothesItemSelect();
                  _eCardClothes.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.denItemCollection,PetManager.myPetListAsIitem,_guiLayer,onECardClothesAddBtn,onEcardClothesClose,1);
               }
               else
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(18193));
               }
            }
            else
            {
               UpsellManager.displayPopup("jamagram","Sending_Gift");
            }
         }
      }
      
      private function onEcardClothesClose(param1:Iitem) : void
      {
         if(_eCardClothes)
         {
            _eCardClothes.destroy();
            _eCardClothes = null;
         }
      }
      
      private function addGiftBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14650),_toolTipPositions[_eCardCreation.addGiftBtn].x,_toolTipPositions[_eCardCreation.addGiftBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function addStampBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!param1.currentTarget.isGray)
         {
            if(_eCardCreation.chatTree.visible)
            {
               SafeChatManager.closeSafeChat(_eCardCreation.chatTree);
               _eCardCreation.addTextBtn.downToUpState();
            }
            _eCardCreation.stampList.visible = !_eCardCreation.stampList.visible;
            createAndLoadStampsAndEcards();
         }
      }
      
      private function addStampBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14651),_toolTipPositions[_eCardCreation.addStampBtn].x,_toolTipPositions[_eCardCreation.addStampBtn].y);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function eCardBtnDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(shouldGrayOutPreview() && !_eCardLoadingSpiral.visible)
         {
            if(_cardMediaIds)
            {
               _loc2_ = _currCardId;
               _currCardId = param1.currentTarget.index;
               param1.currentTarget.update();
               _itemWindowECards.callUpdateOnWindow(_loc2_);
               drawCurrCard();
            }
         }
      }
      
      private function stampBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _currStampId = param1.currentTarget.index;
         _eCardCreation.stampList.visible = false;
         _eCardCreation.addStampBtn.downToUpState();
         drawCurrStamp();
         AJAudio.playSubMenuBtnClick();
      }
      
      private function stampBtnOverHandler(param1:MouseEvent) : void
      {
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function stampBtnOutHandler(param1:MouseEvent) : void
      {
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function toBtnHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_eCardCreation.buddyList.visible)
         {
            if(_buddyListItemWindow)
            {
               _buddyListItemWindow.destroy();
               _buddyListItemWindow = null;
            }
            if(_eCardCreation.buddyList.itemBlock.numChildren > 1)
            {
               _eCardCreation.buddyList.itemBlock.removeChild(_eCardCreation.buddyList.itemBlock.getChildAt(1));
            }
         }
         else
         {
            if(_buddyListItemWindow)
            {
               _buddyListItemWindow.destroy();
               _buddyListItemWindow = null;
            }
            makeNewBuddyList();
         }
         _eCardCreation.buddyList.visible = !_eCardCreation.buddyList.visible == true && BuddyManager.buddyCount > 0 && (_toUserName == "" || param1) ? true : false;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onBuddyListChange(param1:BuddyEvent) : void
      {
         makeNewBuddyList();
      }
      
      private function makeNewBuddyList() : void
      {
         var _loc1_:int = 0;
         if(_eCardCreation)
         {
            if(!BuddyList.listRequested)
            {
               BuddyXtCommManager.sendBuddyListRequest();
               BuddyList.listRequested = true;
               _loadingSpiral.setNewParent(_eCardCreation.buddyList.itemBlock,_eCardCreation.buddyList.itemBlock.width * 0.5,_eCardCreation.buddyList.itemBlock.height * 0.5);
               return;
            }
            if(_buddyListItemWindow)
            {
               _buddyListItemWindow.destroy();
               _buddyListItemWindow = null;
            }
            if(_eCardCreation.buddyList.visible)
            {
               while(_eCardCreation.buddyList.itemBlock.numChildren > 1)
               {
                  _eCardCreation.buddyList.itemBlock.removeChildAt(_eCardCreation.buddyList.itemBlock.numChildren - 1);
               }
            }
            _buddyListItemWindow = new WindowAndScrollbarGenerator();
            _buddyListItemWindow.init(_eCardCreation.buddyList.itemBlock.width,_eCardCreation.buddyList.itemBlock.height,5,0,1,5,0,0,1,0,0.5,ItemWindowBuddyList,BuddyList.buildBuddyList(),"",0,{"mouseDown":clickOnBuddyHandler},null,null,true,false,false,false,false);
            _eCardCreation.buddyList.itemBlock.addChild(_buddyListItemWindow);
            if(_itemWindowECards)
            {
               _itemWindowECards.callUpdateInWindow();
            }
            if(_toUserName == "")
            {
               setupUsernameButton(true);
               if(_eCardCreation.sendBtn.hasGrayState)
               {
                  _eCardCreation.sendBtn.activateGrayState(true);
               }
            }
            else
            {
               setupUsernameButton(false);
            }
            _loc1_ = BuddyManager.buddyCount;
            putInGrayedOutState(_loc1_ == 0 && !_createOnly && _toUserName == "");
            if(_loc1_ == 0)
            {
               _eCardCreation.toTab.mouseChildren = false;
               _eCardCreation.toTab.mouseEnabled = false;
               while(_eCardCreation.eCardItemWindow.numChildren > 2)
               {
                  _eCardCreation.eCardItemWindow.removeChildAt(_eCardCreation.eCardItemWindow.numChildren - 1);
               }
               _eCardCreation.buddyList.visible = false;
            }
            else
            {
               _eCardCreation.toTab.mouseChildren = true;
               _eCardCreation.toTab.mouseEnabled = true;
            }
            if(_loadingSpiral)
            {
               if(_loadingSpiral.parent == _eCardCreation.buddyList.itemBlock)
               {
                  _eCardCreation.buddyList.itemBlock.removeChild(_loadingSpiral);
               }
               _loadingSpiral.destroy();
               _loadingSpiral = null;
               _eCardCreation.buddyList.visible = BuddyManager.buddyCount > 0 && _toUserName == "" ? true : false;
            }
         }
      }
      
      private function clickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Buddy = param1.currentTarget.getBuddy();
         _toModeratedUserName = _loc2_.userNameModerated;
         _toUserName = _loc2_.userName;
         _toAccountType = _loc2_.accountType;
         setupUsernameButton(false);
         if(_toUserName != "")
         {
            if(_eCardCreation.sendBtn.hasGrayState)
            {
               _eCardCreation.sendBtn.activateGrayState(false);
            }
         }
         if(!Utility.isMember(_toAccountType))
         {
            removeGiftBtnHandler(null);
         }
         toBtnHandler(null);
      }
      
      private function onECardClothesAddBtn(param1:int, param2:Boolean = true) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Iitem = null;
         var _loc6_:IitemCollection = null;
         var _loc3_:int = 0;
         _giftItemIdx = param1;
         if(_giftItemIdx > 0)
         {
            _loc5_ = 0;
            _loc6_ = param2 ? gMainFrame.userInfo.playerAvatarInfo.getFullItems() : AvatarManager.playerAvatar.inventoryDenFull.denItemCollection;
            _loc3_ = 0;
            while(_loc3_ < _loc6_.length)
            {
               if(_loc6_.getIitem(_loc3_).invIdx == _giftItemIdx)
               {
                  _loc4_ = _loc6_.getIitem(_loc3_);
                  if(param2)
                  {
                     _currIitemBeingRemoved = _loc4_;
                  }
                  break;
               }
               _loc3_++;
            }
            if(_loc4_)
            {
               if(_loc4_.isDiamond)
               {
                  _loc5_ = 3;
               }
               else if(_loc4_.isRare)
               {
                  _loc5_ = 1;
               }
               else if(_loc4_.isRareDiamond)
               {
                  _loc5_ = 5;
               }
               _tradeConfirmation = new TradeConfirmPopup(_guiLayer,_loc5_,true,onConfirmGift,param2);
            }
         }
         onEcardClothesClose(null);
      }
      
      private function onConfirmGift(param1:Boolean, param2:Boolean) : void
      {
         var _loc4_:TradeItemCollection = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc4_ = gMainFrame.userInfo.getMyTradeList();
            if(param2)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_.getTradeItem(_loc3_).itemType == 0 && _loc4_.getTradeItem(_loc3_).invIdx == _giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(_loc3_);
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                     break;
                  }
                  _loc3_++;
               }
               _type = 1;
            }
            else
            {
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_.getTradeItem(_loc3_).itemType == 1 && _loc4_.getTradeItem(_loc3_).invIdx == _giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(_loc3_);
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                     break;
                  }
                  _loc3_++;
               }
               _type = 3;
            }
            _eCardCreation.addGiftBtn.activateGrayState(true);
            _eCardCreation.giftIcon.visible = true;
         }
         else
         {
            removeGiftBtnHandler(null);
         }
         if(_tradeConfirmation)
         {
            _tradeConfirmation.destroy();
            _tradeConfirmation = null;
         }
      }
      
      private function onSentResponseCallback(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1 < 1)
         {
            if(param1 == -1)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(24507));
            }
            else if(param1 == -2)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(25038,_toUserName));
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14717));
            }
         }
         else if(_giftItemIdx)
         {
            if(_currIitemBeingRemoved && _currIitemBeingRemoved.isCustom)
            {
               PlayerWallManager.checkAndRemoveMasterpieceItems(new IntItemCollection([_currIitemBeingRemoved.invIdx]));
            }
            _giftItemIdx = -1;
            _currIitemBeingRemoved = null;
         }
      }
      
      private function removeGiftBtnHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _giftItemIdx = -1;
         _currIitemBeingRemoved = null;
         _type = 0;
         if(_eCardCreation)
         {
            _eCardCreation.giftIcon.visible = false;
         }
         if(_eCardClothes)
         {
            _eCardClothes.removeGift();
         }
         if(_eCardCreation.addGiftBtn.hasGrayState)
         {
            _eCardCreation.addGiftBtn.activateGrayState(false);
         }
      }
      
      private function onRulesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.displayRulesPopup(true);
      }
      
      private function addListeners() : void
      {
         gMainFrame.stage.addEventListener("keyDown",onKeyDown,false,0,true);
         _eCardCreation.addEventListener("mouseDown",onPopup,false,0,true);
         _eCardCreation.bx.addEventListener("mouseDown",onClose,false,0,true);
         _eCardCreation.mouseOverEcard.addEventListener("mouseOver",onECardItemWindowOverOut,false,0,true);
         _eCardCreation.mouseOverEcard.addEventListener("mouseOut",onECardItemWindowOverOut,false,0,true);
         _eCardCreation.mouseOverEcard.leftBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         _eCardCreation.mouseOverEcard.rightBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         _eCardCreation.toTab.addEventListener("mouseDown",toBtnHandler,false,0,true);
         _eCardCreation.addStampBtn.addEventListener("mouseDown",addStampBtnHandler,false,0,true);
         _eCardCreation.addStampBtn.addEventListener("mouseOver",addStampBtnOverHandler,false,0,true);
         _eCardCreation.addStampBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _eCardCreation.addTextBtn.addEventListener("mouseDown",addTextBtnHandler,false,0,true);
         _eCardCreation.addTextBtn.addEventListener("mouseOver",addTextBtnOverHandler,false,0,true);
         _eCardCreation.addTextBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         if(Utility.canGift())
         {
            _eCardCreation.addGiftBtn.addEventListener("mouseDown",addGiftBtnHandler,false,0,true);
            _eCardCreation.addGiftBtn.addEventListener("mouseOver",addGiftBtnOverHandler,false,0,true);
            _eCardCreation.addGiftBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         }
         else
         {
            _eCardCreation.addGiftBtn.activateGrayState(true);
         }
         _eCardCreation.giftIcon.removeGiftBtn.addEventListener("mouseDown",removeGiftBtnHandler,false,0,true);
         _eCardCreation.sendBtn.addEventListener("mouseDown",sendMailBtnHandler,false,0,true);
         _eCardCreation.sendBtn.addEventListener("mouseOver",sendMailBtnOverHandler,false,0,true);
         _eCardCreation.sendBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _eCardCreation.backBtn.addEventListener("mouseDown",backBtnHandler,false,0,true);
         _eCardCreation.backBtn.addEventListener("mouseOver",backBtnOverHandler,false,0,true);
         _eCardCreation.backBtn.addEventListener("mouseOut",backBtnOutHandler,false,0,true);
         _eCardCreation.textBtn.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
         if(gMainFrame.userInfo.sgChatType == 2 || gMainFrame.userInfo.sgChatType == 1)
         {
            _eCardCreation.textBtn.currTxt.addEventListener("change",onTextChanged,false,0,true);
            _eCardCreation.textBtn.currTxt.addEventListener("keyFocusChange",onKeyFocusChange,false,0,true);
            _eCardCreation.textBtn.currTxt.addEventListener("keyDown",keyDownListener,false,0,true);
         }
         _eCardCreation.rulesBtn.addEventListener("mouseDown",onRulesBtn,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            _eCardCreation.textBtn.addEventListener("mouseOver",mouseOverMsgText,false,0,true);
            _eCardCreation.textBtn.addEventListener("mouseOut",mouseOutMsgText,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         gMainFrame.stage.addEventListener("keyDown",onKeyDown);
         _eCardCreation.removeEventListener("mouseDown",onPopup);
         _eCardCreation.bx.removeEventListener("mouseDown",onClose);
         _eCardCreation.mouseOverEcard.addEventListener("mouseOver",onECardItemWindowOverOut);
         _eCardCreation.mouseOverEcard.addEventListener("mouseOut",onECardItemWindowOverOut);
         _eCardCreation.mouseOverEcard.leftBtn.removeEventListener("mouseDown",arrowBtnHandler);
         _eCardCreation.mouseOverEcard.rightBtn.removeEventListener("mouseDown",arrowBtnHandler);
         _eCardCreation.toTab.removeEventListener("mouseDown",toBtnHandler);
         _eCardCreation.addStampBtn.removeEventListener("mouseDown",addStampBtnHandler);
         _eCardCreation.addStampBtn.removeEventListener("mouseOver",addStampBtnOverHandler);
         _eCardCreation.addStampBtn.removeEventListener("mouseOut",btnOutHandler);
         _eCardCreation.addTextBtn.removeEventListener("mouseDown",addTextBtnHandler);
         _eCardCreation.addTextBtn.removeEventListener("mouseOver",addTextBtnOverHandler);
         _eCardCreation.addTextBtn.removeEventListener("mouseOut",btnOutHandler);
         if(Utility.canGift())
         {
            _eCardCreation.addGiftBtn.removeEventListener("mouseDown",addGiftBtnHandler);
            _eCardCreation.addGiftBtn.removeEventListener("mouseOver",addGiftBtnOverHandler);
            _eCardCreation.addGiftBtn.removeEventListener("mouseOut",btnOutHandler);
         }
         _eCardCreation.giftIcon.removeGiftBtn.removeEventListener("mouseDown",removeGiftBtnHandler);
         _eCardCreation.sendBtn.removeEventListener("mouseDown",sendMailBtnHandler);
         _eCardCreation.sendBtn.removeEventListener("mouseOver",sendMailBtnOverHandler);
         _eCardCreation.sendBtn.removeEventListener("mouseOut",btnOutHandler);
         _eCardCreation.backBtn.removeEventListener("mouseDown",backBtnHandler);
         _eCardCreation.backBtn.removeEventListener("mouseOver",backBtnOverHandler);
         _eCardCreation.backBtn.removeEventListener("mouseOut",backBtnOutHandler);
         _eCardCreation.textBtn.removeEventListener("mouseDown",msgTextDownHandler);
         if(gMainFrame.userInfo.sgChatType == 2 || gMainFrame.userInfo.sgChatType == 1)
         {
            _eCardCreation.textBtn.currTxt.removeEventListener("change",onTextChanged);
            _eCardCreation.textBtn.currTxt.removeEventListener("keyFocusChange",onKeyFocusChange);
            _eCardCreation.textBtn.currTxt.removeEventListener("keyDown",keyDownListener);
         }
         _eCardCreation.rulesBtn.removeEventListener("mouseDown",onRulesBtn);
         if(Mouse["supportsNativeCursor"])
         {
            _eCardCreation.textBtn.removeEventListener("mouseOver",mouseOverMsgText);
            _eCardCreation.textBtn.removeEventListener("mouseOut",mouseOutMsgText);
         }
      }
   }
}

