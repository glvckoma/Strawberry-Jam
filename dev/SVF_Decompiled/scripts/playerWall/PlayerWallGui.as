package playerWall
{
   import avatar.Avatar;
   import avatar.AvatarDef;
   import avatar.AvatarEditorView;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarView;
   import avatar.UserCommXtCommManager;
   import buddy.BuddyManager;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.IntItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.popup.SBOkCancelPopup;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.CursorManager;
   import gui.DarkenManager;
   import gui.EmoticonManager;
   import gui.EmoticonUtility;
   import gui.FeedbackManager;
   import gui.GuiManager;
   import gui.GuiRadioButtonGroup;
   import gui.InputPopup;
   import gui.LoadingSpiral;
   import gui.PredictiveTextManager;
   import gui.ReportAPlayer;
   import gui.SBScrollbar;
   import gui.SafeChatManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   import gui.itemWindows.ItemWindowMasterpiece;
   import gui.itemWindows.ItemWindowNotification;
   import gui.itemWindows.ItemWindowPattern;
   import gui.itemWindows.ItemWindowPlayerWallDecor;
   import gui.itemWindows.ItemWindowPost;
   import gui.itemWindows.ItemWindowSticker;
   import item.EquippedAvatars;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import masterpiece.MasterpieceDisplayItem;
   import pet.GuiPet;
   import pet.PetManager;
   import resourceArray.ResourceArrayXtCommManager;
   
   public class PlayerWallGui
   {
      private static var _scrollYPosition:Number = 0;
      
      private const PLAYER_WALL_MEDIA_ID:int = 1499;
      
      private const AVATAR_ICON_LIST_ID:int = 109;
      
      private const DECOR_ICONS_GENERIC_LIST_ID:int = 313;
      
      private const DECOR_ITEMS_GENERIC_LIST_ID:int = 314;
      
      private const STICKER_ICON_LIST_ID:int = 646;
      
      private const WINDOW_TYPE_WALLPAPER:int = 0;
      
      private const WINDOW_TYPE_STICKER:int = 1;
      
      private const WINDOW_TYPE_MASTERPIECE:int = 2;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inbox:Vector.<PostMessage>;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _playerWall:MovieClip;
      
      private var _owner:String;
      
      private var _ownerModeratedUsername:String;
      
      private var _ownerUUID:String;
      
      private var _status:String;
      
      private var _currPatternId:int;
      
      private var _myCurrColorId:int;
      
      private var _postWindows:WindowAndScrollbarGenerator;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _predictiveStatusManager:PredictiveTextManager;
      
      private var _emoteMgr:EmoticonManager;
      
      private var _reportMsgId:String;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _isMyWall:Boolean;
      
      private var _privacyId:int;
      
      private var _msgCode:String;
      
      private var _avatarIconWindowLoadingSpiral:LoadingSpiral;
      
      private var _numAvatarIconsLoaded:int;
      
      private var _avatarIcons:Array;
      
      private var _wallSettingsRadioBtns:GuiRadioButtonGroup;
      
      private var _wallDecorIconIds:Array;
      
      private var _wallDecorItemIds:Array;
      
      private var _currDecorIndex:int;
      
      private var _patternIconIds:Array;
      
      private var _patternWindows:WindowGenerator;
      
      private var _patternScrollBar:SBScrollbar;
      
      private var _messagePatternWindow:ItemWindowPattern;
      
      private var _wallParameters:Object;
      
      private var _hasLoadedDecor:Boolean;
      
      private var _messagePatternLoaded:Boolean;
      
      private var _updateTimer:Timer;
      
      private var _canWrite:Boolean;
      
      private var _currDragMasterpiece:MasterpieceDisplayItem;
      
      private var _dragStartPoint:Point;
      
      private var _masterpieceFrameIds:Array;
      
      private var _masterpieceLaunchObj:Object;
      
      private var _selectedMasterpieces:Array;
      
      private var _masterpieceDiCollection:DenItemCollection;
      
      private var _masterpieceItemsBeingLoaded:Array;
      
      private var _stickerItemsBeingLoaded:Array;
      
      private var _wallCustomizeWindows:WindowAndScrollbarGenerator;
      
      private var _stickerIconIds:Array;
      
      private var _currDragSticker:MovieClip;
      
      private var _selectedStickers:Array;
      
      private var _currWallDecor:MovieClip;
      
      private var _photoAvatar:Avatar;
      
      private var _photoAvatarView:AvatarView;
      
      private var _photoPet:GuiPet;
      
      private var _photoBackground:MovieClip;
      
      private var _inputPopup:InputPopup;
      
      private var _currReplyPost:ItemWindowPost;
      
      private var _notifications:Vector.<PostMessage>;
      
      private var _notificationWindows:WindowAndScrollbarGenerator;
      
      private var _isWallActive:Boolean;
      
      private var _jumpToMessageId:String;
      
      private var _hasLoadedSafeChat:Boolean;
      
      private var _customizationLoadingSpiral:LoadingSpiral;
      
      private var _hasShownDegradationPopup:Boolean;
      
      public function PlayerWallGui()
      {
         super();
      }
      
      public function init(param1:Vector.<PostMessage>, param2:Vector.<PostMessage>, param3:String, param4:String, param5:String, param6:String, param7:int, param8:int, param9:String, param10:Function) : void
      {
         if(MinigameManager.inMinigame())
         {
            return;
         }
         _guiLayer = GuiManager.guiLayer;
         _inbox = param1;
         _owner = param3;
         _ownerModeratedUsername = param4;
         _ownerUUID = param5;
         _status = param6;
         _currPatternId = param7;
         _myCurrColorId = param8;
         _closeCallback = param10;
         _jumpToMessageId = param9;
         _isMyWall = param3 == gMainFrame.userInfo.myUserName;
         _notifications = param2;
         _isWallActive = true;
         _updateTimer = new Timer(45000);
         _canWrite = _isMyWall ? true : PlayerWallManager.tokenMap[_owner.toLowerCase()].write == "1";
         SBTracker.trackPageview("game/play/playerWall/#" + (_isMyWall ? "openMyWall" : "openStrangersWall"));
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1499,onMediaLoaded);
         UserCommXtCommManager.sendPermEmote(4329);
      }
      
      public function destroy() : void
      {
         KeepAlive.stopKATimer(_playerWall);
         if(_postWindows)
         {
            _postWindows.destroy();
            _postWindows = null;
         }
         setupAvatarAndPetPhoto(false,true);
         setupSafeChat(true);
         setupSettingsPopup(true);
         setupMessageEntry(true);
         setupEmotePopup(true);
         setupColors(true);
         setupPatterns(true);
         setupWallCustomizePopup(true);
         setupNotificationsPopup(true);
         setupLikes(true);
         _mediaHelper = null;
         _inbox = null;
         _closeCallback = null;
         removeEventListeners();
         _updateTimer.stop();
         _updateTimer = null;
         for each(var _loc1_ in _masterpieceItemsBeingLoaded)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
               _loc1_ = null;
            }
         }
         _masterpieceItemsBeingLoaded = null;
         for each(var _loc2_ in _stickerItemsBeingLoaded)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
               _loc2_ = null;
            }
         }
         _stickerItemsBeingLoaded = null;
         if(_customizationLoadingSpiral != null)
         {
            _customizationLoadingSpiral.destroy();
            _customizationLoadingSpiral = null;
         }
         DarkenManager.unDarken(_playerWall);
         if(_playerWall && _playerWall.parent == _guiLayer)
         {
            _guiLayer.removeChild(_playerWall);
         }
         _playerWall = null;
         if(_isMyWall || !PlayerWallManager.isMyWallOpen())
         {
            UserCommXtCommManager.sendPermEmote(-1);
         }
      }
      
      public function reloadMessages(param1:Vector.<PostMessage>, param2:Vector.<PostMessage>, param3:int, param4:String = "") : Vector.<PostMessage>
      {
         var _loc10_:PostMessage = null;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc9_:Object = PlayerWallManager.myBlockedMessages;
         _loc8_ = 0;
         while(_loc8_ < param1.length)
         {
            _loc10_ = param1[_loc8_];
            if(_loc10_.msgId != param4 && _loc10_.msgId == _loc9_[_loc10_.msgId])
            {
               param1.splice(_loc8_,1);
               _loc8_--;
            }
            _loc8_++;
         }
         if(param2 != null)
         {
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               _loc10_ = param2[_loc8_];
               if(_loc10_.msgId != param4 && _loc10_.msgId == _loc9_[_loc10_.msgId])
               {
                  param2.splice(_loc8_,1);
                  _loc8_--;
               }
               _loc8_++;
            }
         }
         var _loc7_:* = -1;
         _loc8_ = 0;
         while(_loc8_ < param1.length)
         {
            if(param1[_loc8_].msgId == param4)
            {
               _loc7_ = _loc8_;
               break;
            }
            _loc8_++;
         }
         var _loc5_:* = -1;
         if(param2 != null)
         {
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               if(param2[_loc8_].msgId == param4)
               {
                  _loc5_ = _loc8_;
                  break;
               }
               _loc8_++;
            }
         }
         if(param1.length > 0)
         {
            param1 = reorderListForReplies(param1);
         }
         if(param1)
         {
            switch(param3)
            {
               case 0:
                  findDifferencesAndUpdatePosts(param1);
                  if(param2 != null && param2.length > 0)
                  {
                     findDifferencesAndUpdateNotifications(param2);
                  }
                  break;
               case 1:
               case 3:
                  deleteItemByIndexAndChildrenIfNecessary(_loc7_,param1,_postWindows);
                  if(param2 != null && _notificationWindows)
                  {
                     deleteItemByIndexAndChildrenIfNecessary(_loc5_,param2,_postWindows);
                  }
                  break;
               case 2:
                  _postWindows.updateItem(_loc7_,param1[_loc7_]);
                  if(param2 != null && _notificationWindows)
                  {
                     _notificationWindows.updateItem(_loc5_,param2[_loc5_]);
                  }
                  break;
               case 4:
                  _inbox = param1;
                  createWallPosts();
            }
            _playerWall.noPostCont.visible = param1.length == 0;
            _playerWall.cleanUpBtn.activateGrayState(param1.length == 0);
            if(param2)
            {
               _loc8_ = 0;
               while(_loc8_ < param2.length)
               {
                  if(!param2[_loc8_].isRead)
                  {
                     _loc6_++;
                  }
                  _loc8_++;
               }
               _playerWall.notificationBtn.numIcon.countTxt.text = String(_loc6_);
               _playerWall.notificationBtn.numIcon.visible = _loc6_ > 0;
            }
         }
         return param1;
      }
      
      public function reloadMasterpieceItems() : void
      {
         var _loc2_:MovieClip = _playerWall.frame_0;
         var _loc1_:int = 0;
         while(_loc2_)
         {
            while(_loc2_.itemLayer.numChildren > 1)
            {
               _loc2_.itemLayer.removeChildAt(_loc2_.itemLayer.numChildren - 1);
            }
            if(_loc2_.loadingSpiral)
            {
               (_loc2_.loadingSpiral as LoadingSpiral).destroy();
               delete _loc2_.loadingSpiral;
            }
            _loc1_++;
            _loc2_ = _playerWall["frame_" + _loc1_];
         }
         setupMasterpieces();
      }
      
      public function set currWallParameters(param1:Object) : void
      {
         _wallParameters = param1;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeObject(param1);
         _loc2_.position = 0;
         _wallParameters = _loc2_.readObject();
         if(_wallParameters == null)
         {
            _wallParameters = {"bg":"19"};
         }
         else if(_wallParameters.bg && _wallParameters.bg == -1)
         {
            _wallParameters.bg = 19;
         }
         if(_wallParameters.mp != null)
         {
            _selectedMasterpieces = _wallParameters.mp;
         }
         if(_wallParameters.stk != null)
         {
            _selectedStickers = _wallParameters.stk;
         }
         if(_wallParameters.visits != null)
         {
            if(_playerWall)
            {
               LocalizationManager.translateIdAndInsert(_playerWall.viewCount,30488,Utility.convertNumberToString(_wallParameters.visits));
            }
         }
         _currDecorIndex = int(_wallParameters.bg);
      }
      
      public function set currNotifications(param1:Vector.<PostMessage>) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _notifications = param1;
         if(_notifications)
         {
            _loc3_ = 0;
            while(_loc3_ < _notifications.length)
            {
               if(!_notifications[_loc3_].isRead)
               {
                  _loc2_++;
               }
               _loc3_++;
            }
         }
         _playerWall.notificationBtn.numIcon.countTxt.text = String(_loc2_);
         _playerWall.notificationBtn.numIcon.visible = _loc2_ > 0;
      }
      
      public function get myCurrMessageColorId() : int
      {
         return _myCurrColorId;
      }
      
      public function get currMessagePattern() : int
      {
         return _currPatternId;
      }
      
      public function get owner() : String
      {
         return _owner;
      }
      
      public function get status() : String
      {
         return _playerWall.statusTxt.text;
      }
      
      public function get isCurrentlyActive() : Boolean
      {
         return _isWallActive;
      }
      
      public function set isCurrentlyActive(param1:Boolean) : void
      {
         _isWallActive = param1;
      }
      
      private function reorderListForReplies(param1:Vector.<PostMessage>) : Vector.<PostMessage>
      {
         var _loc2_:PostMessage = null;
         var _loc5_:int = 0;
         var _loc3_:* = undefined;
         var _loc7_:int = 0;
         var _loc4_:Dictionary = new Dictionary();
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc2_ = param1[_loc5_];
            if(_loc2_.parentMessageId != null && _loc2_.parentMessageId.length > 0)
            {
               if(_loc4_[_loc2_.parentMessageId] == null)
               {
                  _loc4_[_loc2_.parentMessageId] = new Vector.<PostMessage>();
               }
               _loc4_[_loc2_.parentMessageId].push(_loc2_);
            }
            _loc5_++;
         }
         var _loc6_:Vector.<PostMessage> = new Vector.<PostMessage>();
         for each(var _loc8_ in param1)
         {
            if(_loc8_.parentMessageId == null || _loc8_.parentMessageId.length == 0)
            {
               _loc6_.push(_loc8_);
            }
            if(_loc4_[_loc8_.msgId] != null)
            {
               _loc3_ = _loc4_[_loc8_.msgId];
               _loc7_ = 0;
               while(_loc7_ < _loc3_.length)
               {
                  _loc6_.push(_loc3_[_loc7_]);
                  _loc7_++;
               }
            }
         }
         return _loc6_;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _playerWall = MovieClip(param1.getChildAt(0));
            KeepAlive.startKATimer(_playerWall);
            _playerWall.x = 900 * 0.5;
            _playerWall.y = 550 * 0.5;
            _playerWall.patternPopup.visible = false;
            _playerWall.colorPopup.visible = false;
            _playerWall.emotePopup.visible = false;
            _playerWall.postBtn.activateGrayState(true);
            _playerWall.replyBtn.activateGrayState(true);
            _playerWall.menuFrame.titleTxt.text = _owner;
            _playerWall.frame.titleTxt.text = _owner;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 0.5;
            _playerWall.settingsPopup.visible = false;
            _playerWall.predictiveText.visible = false;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.selectable = false;
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = false;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
            _playerWall.wallCustomize.visible = false;
            _playerWall.wallNotificationCont.visible = false;
            _playerWall.contentLoader.visible = true;
            _playerWall.noPostCont.visible = false;
            _playerWall.replyToTip.visible = false;
            _playerWall.replyBtn.visible = false;
            _playerWall.cancelBtn.visible = false;
            _playerWall.notificationBtn.numIcon.visible = false;
            _playerWall.wallNotificationCont.numIcon.visible = false;
            _playerWall.chatTree.visible = false;
            LocalizationManager.translateIdAndInsert(_playerWall.viewCount,30488,Utility.convertNumberToString(0));
            if(_isMyWall)
            {
               _playerWall.settingsBtn.visible = true;
               _playerWall.menuBtn.visible = true;
               _playerWall.notificationBtn.visible = true;
               _playerWall.menuFrame.visible = true;
               _playerWall.frame.visible = false;
               _privacyId = gMainFrame.userInfo.playerWallSettings;
               _playerWall.cleanUpBtn.activateGrayState(true);
            }
            else
            {
               _playerWall.settingsBtn.visible = false;
               _playerWall.menuBtn.visible = false;
               _playerWall.cleanUpBtn.visible = false;
               _playerWall.menuFrame.visible = false;
               _playerWall.frame.visible = true;
               _playerWall.notificationBtn.visible = false;
            }
            if(PlayerWallManager.isFirstTime || !_isMyWall)
            {
               PlayerWallXtCommManager.sendGetFromPlayerWall(_isMyWall ? gMainFrame.userInfo.myUserName : _owner,onFirstTimeGet);
            }
            else
            {
               setupWallCustomizePopup();
               setupWallDecorItems();
               setupMasterpieces();
               setupStickers();
               setupMessageEntry();
               setupSafeChat();
               setupPatterns();
               setupColors();
               setupEmotePopup();
               setupNotificationsPopup();
               setupLikes();
               setupViews();
               setupSettingsPopup(false,_privacyId);
               onSettingsChoose(null);
               updatePatternPopupColors();
               createWallPosts();
               PlayerWallManager.startMyWallTimer();
            }
            addEventListeners();
         }
      }
      
      private function setupSafeChat(param1:Boolean = false) : void
      {
         if(_canWrite)
         {
            if(param1)
            {
               SafeChatManager.destroy(_playerWall.chatTree);
            }
            else
            {
               _playerWall.speedChatBtn.downToUpState();
            }
         }
         else
         {
            _playerWall.speedChatBtn.activateGrayState(true);
            _playerWall.speedChatBtn.mouseChildren = false;
            _playerWall.speedChatBtn.mouseEnabled = false;
            _playerWall.chatTree.visible = false;
         }
      }
      
      private function setupSettingsPopup(param1:Boolean = false, param2:int = 0) : void
      {
         if(param1)
         {
            _playerWall.settingsPopup.removeEventListener("mouseDown",onPopup);
            _playerWall.settingsPopup.bx.removeEventListener("mouseDown",onSettingsClose);
            if(_wallSettingsRadioBtns)
            {
               _wallSettingsRadioBtns.currRadioButton.removeEventListener("mouseDown",onSettingsChoose);
               _wallSettingsRadioBtns.destroy();
               _wallSettingsRadioBtns = null;
            }
         }
         else
         {
            _playerWall.settingsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.settingsPopup.bx.addEventListener("mouseDown",onSettingsClose,false,0,true);
            _wallSettingsRadioBtns = new GuiRadioButtonGroup(_playerWall.settingsPopup.options);
            _wallSettingsRadioBtns.currRadioButton.addEventListener("mouseDown",onSettingsChoose,false,0,true);
            _wallSettingsRadioBtns.selected = param2;
         }
      }
      
      private function setupWallCustomizePopup(param1:Boolean = false) : void
      {
         if(param1)
         {
            _playerWall.wallCustomize.removeEventListener("mouseDown",onPopup);
            _playerWall.wallCustomize.bx.removeEventListener("mouseDown",onWallMenuClose);
            _playerWall.wallCustomize.createMasterpieceBtn.removeEventListener("mouseDown",onCreateAMasterpieceBtn);
            _playerWall.wallCustomize.wallpaperBtnDown.removeEventListener("mouseDown",decorStickersAndMasterpieceHandler);
            _playerWall.wallCustomize.stickerBtnDown.removeEventListener("mouseDown",decorStickersAndMasterpieceHandler);
            _playerWall.wallCustomize.masterpieceBtnDown.removeEventListener("mouseDown",decorStickersAndMasterpieceHandler);
            if(_wallCustomizeWindows)
            {
               _wallCustomizeWindows.destroy();
               _wallCustomizeWindows = null;
            }
         }
         else
         {
            _playerWall.wallCustomize.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.wallCustomize.bx.addEventListener("mouseDown",onWallMenuClose,false,0,true);
            _playerWall.wallCustomize.createMasterpieceBtn.addEventListener("mouseDown",onCreateAMasterpieceBtn,false,0,true);
            _playerWall.wallCustomize.wallpaperBtnDown.addEventListener("mouseDown",decorStickersAndMasterpieceHandler,false,0,true);
            _playerWall.wallCustomize.stickerBtnDown.addEventListener("mouseDown",decorStickersAndMasterpieceHandler,false,0,true);
            _playerWall.wallCustomize.masterpieceBtnDown.addEventListener("mouseDown",decorStickersAndMasterpieceHandler,false,0,true);
            if(_isMyWall)
            {
               currWallParameters = PlayerWallManager.myWallParameters;
            }
         }
      }
      
      private function setupCustomizationWindows(param1:int) : void
      {
         while(_playerWall.wallCustomize.itemWindow.numChildren > 2)
         {
            _playerWall.wallCustomize.itemWindow.removeChildAt(_playerWall.wallCustomize.itemWindow.numChildren - 1);
         }
         if(_wallCustomizeWindows)
         {
            _wallCustomizeWindows.destroy();
            _wallCustomizeWindows = null;
         }
         if(!_customizationLoadingSpiral)
         {
            _customizationLoadingSpiral = new LoadingSpiral(_playerWall.wallCustomize.itemWindow,_playerWall.wallCustomize.itemWindow.width * 0.5,_playerWall.wallCustomize.itemWindow.height * 0.5);
         }
         else
         {
            _customizationLoadingSpiral.visible = true;
         }
         if(param1 == 0)
         {
            if(_wallDecorIconIds == null)
            {
               GenericListXtCommManager.requestGenericList(313,onDecorIconsLoaded);
            }
            else
            {
               _wallCustomizeWindows = new WindowAndScrollbarGenerator();
               _wallCustomizeWindows.init(_playerWall.wallCustomize.itemWindow.width,_playerWall.wallCustomize.itemWindow.height,5,0,3,_wallDecorIconIds.length / 3,0,10,5,5,5,ItemWindowPlayerWallDecor,_wallDecorIconIds,"",_wallDecorIconIds.length,{
                  "mouseDown":onDecorMouseDown,
                  "mouseOver":null,
                  "mouseOut":null
               },null,wallCustomizationLoaded);
            }
         }
         else if(param1 == 1)
         {
            if(_stickerIconIds == null)
            {
               GenericListXtCommManager.requestGenericList(646,onStickerIconsLoaded);
            }
            else
            {
               _wallCustomizeWindows = new WindowAndScrollbarGenerator();
               _wallCustomizeWindows.init(_playerWall.wallCustomize.itemWindow.width,_playerWall.wallCustomize.itemWindow.height,5,0,2,_stickerIconIds.length / 2,0,2,2,5,2,ItemWindowSticker,_stickerIconIds,"",_stickerIconIds.length,{
                  "mouseDown":onStickerMouseDown,
                  "mouseOver":null,
                  "mouseOut":null
               },_selectedStickers,wallCustomizationLoaded,false,false);
            }
         }
         else if(param1 == 2)
         {
            _wallCustomizeWindows = new WindowAndScrollbarGenerator();
            _wallCustomizeWindows.init(_playerWall.wallCustomize.itemWindow.width,_playerWall.wallCustomize.itemWindow.height,5,0,2,2,_masterpieceDiCollection.length,2,2,5,2,ItemWindowMasterpiece,_masterpieceDiCollection.getCoreArray(),"icon",0,{
               "mouseDown":onMasterpieceMouseDown,
               "mouseOver":null,
               "mouseOut":null
            },_selectedMasterpieces,wallCustomizationLoaded,true,false,false);
            if(_masterpieceDiCollection.length == 0)
            {
               _playerWall.wallCustomize.noFramePopup.visible = true;
            }
            else
            {
               _playerWall.wallCustomize.noFramePopup.visible = false;
            }
         }
         if(_wallCustomizeWindows)
         {
            _playerWall.wallCustomize.itemWindow.addChild(_wallCustomizeWindows);
         }
         if(param1 != 2)
         {
            _playerWall.wallCustomize.noFramePopup.visible = false;
         }
         _playerWall.wallCustomize.createMasterpieceBtn.visible = param1 == 2;
         _playerWall.wallCustomize.wallpaperBtnUp.visible = param1 == 0;
         _playerWall.wallCustomize.wallpaperBtnDown.visible = param1 != 0;
         _playerWall.wallCustomize.stickerBtnUp.visible = param1 == 1;
         _playerWall.wallCustomize.stickerBtnDown.visible = param1 != 1;
         _playerWall.wallCustomize.masterpieceBtnUp.visible = param1 == 2;
         _playerWall.wallCustomize.masterpieceBtnDown.visible = param1 != 2;
         _playerWall.wallCustomize.stickerScrim.visible = param1 == 1;
         _playerWall.wallCustomize.masterpieceScrim.visible = param1 == 2;
         _playerWall.wallCustomize.wallPaperScrim.visible = param1 == 0;
      }
      
      private function wallCustomizationLoaded() : void
      {
         _customizationLoadingSpiral.visible = false;
      }
      
      private function setupWallDecorItems() : void
      {
         if(_wallDecorItemIds == null)
         {
            GenericListXtCommManager.requestGenericList(314,onDecorItemsLoaded);
         }
      }
      
      private function setupMasterpieces() : void
      {
         var _loc2_:MovieClip = null;
         if(_selectedMasterpieces)
         {
            for each(var _loc1_ in _selectedMasterpieces)
            {
               _loc2_ = _playerWall["frame_" + _loc1_.sid];
               if(_loc2_)
               {
                  while(_loc2_.itemLayer.numChildren > 1)
                  {
                     _loc2_.itemLayer.removeChildAt(_loc2_.itemLayer.numChildren - 1);
                  }
                  if(_loc2_.loadingSpiral)
                  {
                     (_loc2_.loadingSpiral as LoadingSpiral).destroy();
                     delete _loc2_.loadingSpiral;
                  }
                  _loc2_.loadingSpiral = new LoadingSpiral(_loc2_.itemLayer);
               }
            }
         }
         if(!_isMyWall)
         {
            DenXtCommManager.requestDenMasterpieceItems(_owner,onMasterpieceItemsReceived);
         }
         else
         {
            setupMasterpieceCollection(new DenItemCollection(gMainFrame.userInfo.playerUserInfo.denItemsFull.concatCollection(null)));
            setupMasterpiecesInFrames();
         }
      }
      
      private function setupStickers() : void
      {
         var _loc2_:MovieClip = null;
         if(_selectedStickers)
         {
            for each(var _loc1_ in _selectedStickers)
            {
               _loc2_ = _playerWall["sticker_" + _loc1_.pos];
               if(_loc2_)
               {
                  while(_loc2_.itemLayer.numChildren > 1)
                  {
                     _loc2_.itemLayer.removeChildAt(_loc2_.itemLayer.numChildren - 1);
                  }
                  if(_loc2_.loadingSpiral)
                  {
                     (_loc2_.loadingSpiral as LoadingSpiral).destroy();
                     delete _loc2_.loadingSpiral;
                  }
                  _loc2_.loadingSpiral = new LoadingSpiral(_loc2_.itemLayer);
               }
            }
         }
         setupStickersInFrames();
      }
      
      private function setupMasterpieceCollection(param1:DenItemCollection) : void
      {
         var _loc2_:int = 0;
         _masterpieceDiCollection = new DenItemCollection();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            if(param1.getDenItem(_loc2_).isCustom)
            {
               if(!_isMyWall)
               {
                  for each(var _loc3_ in _selectedMasterpieces)
                  {
                     if(_loc3_.iid == param1.getDenItem(_loc2_).invIdx)
                     {
                        _masterpieceDiCollection.pushDenItem(param1.getDenItem(_loc2_));
                        break;
                     }
                  }
               }
               else
               {
                  _masterpieceDiCollection.pushDenItem(param1.getDenItem(_loc2_));
               }
            }
            _loc2_++;
         }
      }
      
      private function onMasterpieceItemsReceived(param1:DenItemCollection) : void
      {
         setupMasterpieceCollection(param1);
         setupMasterpiecesInFrames();
      }
      
      private function setupStickersInFrames() : void
      {
         var _loc1_:Boolean = false;
         var _loc5_:MovieClip = null;
         var _loc2_:StickerItem = null;
         var _loc3_:IntItemCollection = new IntItemCollection();
         _stickerItemsBeingLoaded = [];
         for each(var _loc4_ in _selectedStickers)
         {
            _loc1_ = false;
            _loc5_ = _playerWall["sticker_" + _loc4_.pos];
            if(_loc5_)
            {
               _loc2_ = new StickerItem(_loc4_.id,onStickerSetupInFramesLoaded,_loc5_);
               _stickerItemsBeingLoaded[_loc4_.id] = _loc2_;
            }
         }
      }
      
      private function setupMasterpiecesInFrames() : void
      {
         var _loc1_:Boolean = false;
         var _loc6_:MovieClip = null;
         var _loc4_:MasterpieceDisplayItem = null;
         var _loc3_:IntItemCollection = new IntItemCollection();
         _masterpieceItemsBeingLoaded = [];
         for each(var _loc5_ in _selectedMasterpieces)
         {
            _loc1_ = false;
            _loc6_ = _playerWall["frame_" + _loc5_.sid];
            for each(var _loc2_ in _masterpieceDiCollection.getCoreArray())
            {
               if(_loc2_.invIdx == _loc5_.iid)
               {
                  if(_loc6_)
                  {
                     _loc4_ = new MasterpieceDisplayItem();
                     _loc4_.init(_loc2_,onMasterpieceSetupInFramesLoaded,_loc6_);
                     _masterpieceItemsBeingLoaded[_loc5_.sid] = _loc4_;
                  }
                  _loc1_ = true;
                  break;
               }
            }
            if(!_loc1_)
            {
               if(_loc6_ && _loc6_.loadingSpiral)
               {
                  (_loc6_.loadingSpiral as LoadingSpiral).destroy();
                  delete _loc6_.loadingSpiral;
               }
               _loc3_.pushIntItem(_loc5_.iid);
            }
         }
         if(_loc3_.length > 0)
         {
            PlayerWallXtCommManager.sendRemoveMasterpiece(_loc3_,null);
         }
      }
      
      private function onStickerSetupInFramesLoaded(param1:StickerItem, param2:MovieClip) : void
      {
         if(param2.loadingSpiral)
         {
            (param2.loadingSpiral as LoadingSpiral).destroy();
            delete param2.loadingSpiral;
         }
         while(param2.itemLayer.numChildren > 1)
         {
            param2.itemLayer.removeChildAt(param2.itemLayer.numChildren - 1);
         }
         var _loc3_:Number = param2.itemLayer.width / Math.max(param1.width,param1.height);
         param1.scaleX = param1.scaleY = _loc3_;
         param2.itemLayer.addChild(param1);
      }
      
      private function onMasterpieceSetupInFramesLoaded(param1:MasterpieceDisplayItem, param2:MovieClip) : void
      {
         if(param2.loadingSpiral)
         {
            (param2.loadingSpiral as LoadingSpiral).destroy();
            delete param2.loadingSpiral;
         }
         while(param2.itemLayer.numChildren > 1)
         {
            param2.itemLayer.removeChildAt(param2.itemLayer.numChildren - 1);
         }
         var _loc3_:Number = param2.itemLayer.width / Math.max(param1.width,param1.height);
         param1.scaleX = param1.scaleY = _loc3_;
         param2.itemLayer.addChild(param1);
      }
      
      private function setupMessageEntry(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(_predictiveTextManager)
            {
               _predictiveTextManager.destroy();
            }
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("keyDown",keyDownListener);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("change",onTextChanged);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseDown",msgTextDownHandler);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseOver",onTextOver);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseOut",onTextOut);
            if(_messagePatternWindow)
            {
               _messagePatternWindow.destroy();
               _messagePatternWindow = null;
            }
         }
         else if(_canWrite)
         {
            _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars = 70;
            _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = true;
            if(gMainFrame.userInfo.sgChatType != 0 && gMainFrame.userInfo.sgChatType != 3)
            {
               _predictiveTextManager = new PredictiveTextManager();
               _predictiveTextManager.init(_playerWall.messageTxtCont.txtColorCont.messageTxt,2,_playerWall.predictTxtTag,_playerWall.specialCharCont,-262,_playerWall.messageTxtCont,onSendMessage,checkShouldCompleteSuggestion);
            }
            else
            {
               _playerWall.predictTxtTag.visible = false;
               if(_playerWall.specialCharCont)
               {
                  _playerWall.specialCharCont.visible = false;
               }
            }
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("change",onTextChanged,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.selectable = true;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.text = LocalizationManager.translateIdOnly(23140);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("keyDown",keyDownListener,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseOver",onTextOver,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseOut",onTextOut,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
            _playerWall.messageTxtCont.gotoAndStop(_myCurrColorId);
            _messagePatternWindow = new ItemWindowPattern(onMessagePatternLoaded,3983,"",0,null,null,null,null,{
               "type":"post",
               "colorIndex":_myCurrColorId,
               "patternIndex":_currPatternId
            });
            _playerWall.messageEntryHolder.addChild(_messagePatternWindow);
         }
         else
         {
            _playerWall.specialCharCont.visible = false;
            _playerWall.predictTxtTag.visible = false;
            _playerWall.colorBtn.activateGrayState(true);
            _playerWall.colorBtn.mouseChildren = false;
            _playerWall.colorBtn.mouseEnabled = false;
            _playerWall.messageTxtCont.visible = false;
            _messagePatternLoaded = true;
            if(_hasLoadedDecor)
            {
               displayLoadedWall();
            }
         }
      }
      
      private function setupPatterns(param1:Boolean = false) : void
      {
         if(_canWrite)
         {
            if(param1)
            {
               _patternIconIds = null;
               if(_patternWindows)
               {
                  _patternWindows.destroy();
                  _patternWindows = null;
               }
            }
            else if(_patternIconIds == null)
            {
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(3983,onPatternLoaded);
            }
            else
            {
               _patternWindows = new WindowGenerator();
               _patternWindows.init(1,_patternIconIds.length,_patternIconIds.length,0,0,0,ItemWindowPattern,_patternIconIds,"",{
                  "mouseDown":onSelectPattern,
                  "mouseOver":null,
                  "mouseOut":null
               },{
                  "type":"swatch",
                  "colorIndex":_myCurrColorId
               },onPatternWindowsLoaded,false,false);
               _playerWall.patternPopup.itemWindow.addChild(_patternWindows);
            }
         }
         else
         {
            _playerWall.patternBtn.activateGrayState(true);
            _playerWall.patternBtn.mouseChildren = false;
            _playerWall.patternBtn.mouseEnabled = false;
         }
      }
      
      private function setupColors(param1:Boolean = false) : void
      {
         var _loc4_:MovieClip = null;
         var _loc2_:Boolean = true;
         var _loc3_:int = 1;
         while(_loc2_)
         {
            _loc4_ = _playerWall.colorPopup["colorBtn" + _loc3_];
            if(_loc4_)
            {
               if(param1)
               {
                  _loc4_.removeEventListener("mouseDown",onSelectColor);
               }
               else
               {
                  _loc4_.addEventListener("mouseDown",onSelectColor,false,0,true);
               }
               _loc4_.gotoAndStop(_loc3_);
            }
            if(!_loc4_)
            {
               _loc2_ = false;
            }
            _loc3_++;
         }
      }
      
      private function updatePatternPopupColors() : void
      {
         var _loc1_:int = 0;
         if(_patternWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < _patternWindows.mediaWindows.length)
            {
               ItemWindowPattern(_patternWindows.mediaWindows[_loc1_]).setColor(_myCurrColorId);
               _loc1_++;
            }
         }
         if(_messagePatternWindow)
         {
            ItemWindowPattern(_messagePatternWindow).setColor(_myCurrColorId);
         }
         _playerWall.messageTxtCont.gotoAndStop(_myCurrColorId);
      }
      
      private function setupEmotePopup(param1:Boolean = false) : void
      {
         if(_canWrite && (gMainFrame.userInfo.sgChatType != 0 && gMainFrame.userInfo.sgChatType != 3))
         {
            if(param1)
            {
               if(_emoteMgr)
               {
                  _emoteMgr.destroy();
               }
            }
            else
            {
               _emoteMgr = new EmoticonManager(1,onEmoteDown,_playerWall.emoteBtn,_playerWall.emotePopup,null,null,null,null,false);
            }
         }
         else
         {
            _playerWall.emoteBtn.activateGrayState(true);
            _playerWall.emoteBtn.mouseChildren = false;
            _playerWall.emoteBtn.mouseEnabled = false;
         }
      }
      
      private function setupNotificationsPopup(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _playerWall.wallNotificationCont.removeEventListener("mouseDown",onPopup);
            _playerWall.wallNotificationCont.bx.removeEventListener("mouseDown",onNotificationsBtn);
            if(_notificationWindows != null)
            {
               _notificationWindows.destroy();
               _notificationWindows = null;
            }
         }
         else
         {
            _playerWall.wallNotificationCont.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.wallNotificationCont.bx.addEventListener("mouseDown",onNotificationClose,false,0,true);
            if(_notifications)
            {
               _loc3_ = 0;
               while(_loc3_ < _notifications.length)
               {
                  if(!_notifications[_loc3_].isRead)
                  {
                     _loc2_++;
                  }
                  _loc3_++;
               }
            }
            _playerWall.notificationBtn.numIcon.countTxt.text = String(_loc2_);
            _playerWall.notificationBtn.numIcon.visible = _loc2_ > 0;
         }
      }
      
      private function setupLikes(param1:Boolean = false) : void
      {
         if(!param1)
         {
            _playerWall.likeBtn.activateLoadingState(true);
            ResourceArrayXtCommManager.sendResourceArrayGetRequest("jammerwall",_ownerUUID,true,onResourceArrayGet);
         }
      }
      
      private function setupViews() : void
      {
         if(!_isMyWall)
         {
            if(PlayerWallManager.myViewedWalls[_owner] == null)
            {
               PlayerWallXtCommManager.sendSetWallCounterIncrementRequest(_owner,onCounterIncrement);
            }
         }
      }
      
      private function createWallPosts() : void
      {
         var _loc3_:Array = null;
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc4_:PostMessage = null;
         if(_playerWall)
         {
            if(_postWindows)
            {
               _scrollYPosition = _postWindows.scrollYValue;
               _postWindows.destroy();
               _postWindows = null;
            }
            else
            {
               _scrollYPosition = 1.7976931348623157e+308;
            }
            _loc3_ = [];
            _loc2_ = PlayerWallManager.myBlockedMessages;
            _loc1_ = 0;
            while(_loc1_ < _inbox.length)
            {
               _loc4_ = _inbox[_loc1_];
               if(_loc4_.msgId == _loc2_[_loc4_.msgId])
               {
                  _inbox.splice(_loc1_,1);
                  _loc1_--;
               }
               else
               {
                  _loc3_.push(_loc4_);
               }
               _loc1_++;
            }
            _playerWall.contentLoader.visible = false;
            _playerWall.noPostCont.visible = _inbox.length == 0;
            _playerWall.cleanUpBtn.activateGrayState(_inbox.length == 0);
            _postWindows = new WindowAndScrollbarGenerator();
            _postWindows.init(_playerWall.itemHolder.width,_playerWall.itemHolder.height - 4,0,_scrollYPosition,1,5,0,0,0,6,0,ItemWindowPost,_loc3_,"",100,{
               "mouseDown":null,
               "mouseOver":null,
               "mouseOut":null
            },{
               "reportMsgBtnMouseDown":onReportDown,
               "deleteMsgBtnMouseDown":onDeleteDown,
               "replyMsgBtnMouseDown":onReplyDown,
               "isMyPost":_isMyWall
            },null,false,false,false,false,false);
            _playerWall.itemHolder.addChild(_postWindows);
            if(_jumpToMessageId != null && _jumpToMessageId != "")
            {
               _postWindows.findAndScrollTo("msgId",_jumpToMessageId,true);
            }
         }
      }
      
      private function closeAllLowerPopups() : void
      {
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         _playerWall.speedChatBtn.downToUpState();
         if(_emoteMgr)
         {
            _emoteMgr.closeEmotes();
         }
         if(_playerWall.colorPopup.visible)
         {
            _playerWall.colorPopup.visible = false;
            _playerWall.colorBtn.downToUpState();
         }
         if(_playerWall.patternPopup.visible)
         {
            _playerWall.patternPopup.visible = false;
            _playerWall.patternBtn.downToUpState();
         }
      }
      
      private function decorStickersAndMasterpieceHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(param1.currentTarget == _playerWall.wallCustomize.wallpaperBtnDown)
         {
            _loc2_ = 0;
         }
         else if(param1.currentTarget == _playerWall.wallCustomize.stickerBtnDown)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget == _playerWall.wallCustomize.masterpieceBtnDown)
         {
            _loc2_ = 2;
         }
         setupCustomizationWindows(_loc2_);
      }
      
      private function onSelectPattern(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _currPatternId = param1.currentTarget.getCurrentPatternIndex();
         ItemWindowPattern(_messagePatternWindow).setPattern(_currPatternId);
         GuiManager.setSharedObj("msgPattern",_currPatternId);
         _playerWall.patternPopup.visible = false;
         _playerWall.patternBtn.downToUpState();
      }
      
      private function onSelectColor(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _myCurrColorId = param1.currentTarget.currentFrame;
         GuiManager.setSharedObj("msgColor",_myCurrColorId);
         _playerWall.colorPopup.visible = false;
         _playerWall.colorBtn.downToUpState();
         updatePatternPopupColors();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ItemWindowPost = param1.currentTarget.parent.parent.parent;
         _reportMsgId = _loc2_.msgId;
         _reportAPlayer = new ReportAPlayer();
         _reportAPlayer.init(3,_guiLayer,onPostReport,true,_loc2_.senderUserName,_loc2_.senderModeratedUserName,false,_reportMsgId);
      }
      
      private function onStatusReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _reportAPlayer = new ReportAPlayer();
         _reportAPlayer.init(3,_guiLayer,onPostStatusReport,true,_owner,_ownerModeratedUsername,false);
      }
      
      private function onPostReport(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         if(param1 && _reportMsgId != "")
         {
            _playerWall.postBtn.activateGrayState(true);
            _playerWall.replyBtn.activateGrayState(true);
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendSetBlockedMessage(_reportMsgId,null);
            _reportMsgId = "";
         }
         SafeChatManager.destroy(_playerWall.chatTree);
         SafeChatManager.buildSafeChatTree(_playerWall.chatTree,"ECardTextTreeNode",5,onChatTreeClose,null);
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         _playerWall.speedChatBtn.downToUpState();
      }
      
      private function onPostStatusReport(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         SafeChatManager.destroy(_playerWall.chatTree);
         SafeChatManager.buildSafeChatTree(_playerWall.chatTree,"ECardTextTreeNode",5,onChatTreeClose,null);
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         _playerWall.speedChatBtn.downToUpState();
      }
      
      private function findDifferencesAndUpdatePosts(param1:Vector.<PostMessage>) : void
      {
         var _loc14_:PostMessage = null;
         var _loc2_:PostMessage = null;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc7_:Object = {};
         for each(_loc14_ in _inbox)
         {
            _loc7_[_loc14_.msgId] = _loc14_;
         }
         var _loc6_:Object = {};
         for each(_loc14_ in param1)
         {
            _loc6_[_loc14_.msgId] = _loc14_;
         }
         var _loc15_:Array = [];
         var _loc4_:Vector.<PostMessage> = new Vector.<PostMessage>();
         var _loc5_:Vector.<int> = new Vector.<int>();
         var _loc13_:Object = PlayerWallManager.myBlockedMessages;
         var _loc8_:int = Math.max(_inbox.length,param1.length);
         _loc9_ = 0;
         while(_loc9_ < _loc8_)
         {
            if(_loc9_ < param1.length)
            {
               _loc14_ = param1[_loc9_];
               _loc2_ = _loc7_[_loc14_.msgId];
               if(_loc2_ == null)
               {
                  if(_loc14_.msgId != _loc13_[_loc14_.msgId])
                  {
                     _loc15_.push({
                        "index":_loc9_,
                        "msg":_loc14_
                     });
                  }
               }
               else if(_loc2_.message != _loc14_.message)
               {
                  _loc4_.push(_loc14_);
               }
               if(_loc9_ < _inbox.length && _loc6_[_inbox[_loc9_].msgId] == null)
               {
                  if(_loc13_[_inbox[_loc9_].msgId] != null)
                  {
                     _loc3_++;
                  }
                  else
                  {
                     _loc5_.push(_loc9_ - _loc3_);
                  }
               }
            }
            else if(_loc9_ < _inbox.length)
            {
               _loc5_.push(_loc9_ - _loc3_);
            }
            _loc9_++;
         }
         if(_postWindows && _loc5_.length > 0)
         {
            _loc10_ = 0;
            while(_loc10_ < _loc5_.length)
            {
               _postWindows.deleteItem(_loc5_[_loc10_] - _loc11_,_inbox,true,false);
               _loc11_++;
               _loc10_++;
            }
         }
         _inbox = param1;
         if(_postWindows)
         {
            if(_loc15_.length > 0)
            {
               if(_loc15_.length == 1)
               {
                  _postWindows.insertItemAtSpecificPosition(_loc15_[0].msg,false,_loc15_[0].index);
               }
               else
               {
                  _loc10_ = 0;
                  while(_loc10_ < _loc15_.length)
                  {
                     _postWindows.insertItemAtSpecificPosition(_loc15_[_loc10_].msg,false,_loc15_[_loc10_].index);
                     _loc10_++;
                  }
               }
            }
            if(_loc4_.length > 0)
            {
               _loc12_ = 0;
               while(_loc12_ < _loc4_.length)
               {
                  _postWindows.findItemWithTypeAndUpdate(_loc4_[_loc12_],"msgId");
                  _loc12_++;
               }
            }
         }
         else
         {
            createWallPosts();
         }
      }
      
      private function findDifferencesAndUpdateNotifications(param1:Vector.<PostMessage>) : void
      {
         var _loc14_:PostMessage = null;
         var _loc2_:PostMessage = null;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc5_:Object = {};
         for each(_loc14_ in _notifications)
         {
            _loc5_[_loc14_.msgId] = _loc14_;
         }
         var _loc11_:Object = {};
         for each(_loc14_ in param1)
         {
            _loc11_[_loc14_.msgId] = _loc14_;
         }
         var _loc15_:Array = [];
         var _loc13_:Vector.<PostMessage> = new Vector.<PostMessage>();
         var _loc4_:Vector.<int> = new Vector.<int>();
         var _loc12_:Object = PlayerWallManager.myBlockedMessages;
         var _loc6_:int = Math.max(_notifications.length,param1.length);
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            if(_loc7_ < param1.length)
            {
               _loc14_ = param1[_loc7_];
               _loc2_ = _loc5_[_loc14_.msgId];
               if(_loc2_ == null)
               {
                  if(_loc14_.msgId != _loc12_[_loc14_.msgId])
                  {
                     _loc15_.push({
                        "index":_loc7_,
                        "msg":_loc14_
                     });
                  }
               }
               else if(_loc2_.message != _loc14_.message)
               {
                  _loc13_.push(_loc14_);
               }
               if(_loc7_ < _notifications.length && _loc11_[_notifications[_loc7_].msgId] == null)
               {
                  if(_loc12_[_notifications[_loc7_].msgId] != null)
                  {
                     _loc3_++;
                  }
                  else
                  {
                     _loc4_.push(_loc7_ - _loc3_);
                  }
               }
            }
            else if(_loc7_ < _notifications.length)
            {
               _loc4_.push(_loc7_ - _loc3_);
            }
            _loc7_++;
         }
         if(_notificationWindows && _loc4_.length > 0)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc4_.length)
            {
               _notificationWindows.deleteItem(_loc4_[_loc8_] - _loc9_,_notifications,true,false);
               _loc9_++;
               _loc8_++;
            }
         }
         _notifications = param1;
         if(_notificationWindows)
         {
            if(_loc15_.length > 0)
            {
               if(_loc15_.length == 1)
               {
                  _notificationWindows.insertItemAtSpecificPosition(_loc15_[0].msg,false,_loc15_[0].index);
               }
               else
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc15_.length)
                  {
                     _notificationWindows.insertItemAtSpecificPosition(_loc15_[_loc8_].msg,false,_loc15_[_loc8_].index);
                     _loc8_++;
                  }
               }
            }
            if(_loc13_.length > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < _loc13_.length)
               {
                  _notificationWindows.findItemWithTypeAndUpdate(_loc13_[_loc10_],"msgId");
                  _loc10_++;
               }
            }
         }
      }
      
      private function displayLoadedWall() : void
      {
         DarkenManager.showLoadingSpiral(false);
         GuiManager.mainHud.playerWall.activateLoadingState(false);
         BuddyManager.setPlayerWallLoading(false);
         BuddyManager.destroyBuddyCard();
         _guiLayer.addChild(_playerWall);
         DarkenManager.darken(_playerWall);
         _updateTimer.start();
      }
      
      private function setupAvatarAndPetPhoto(param1:Boolean = true, param2:Boolean = false) : void
      {
         var _loc5_:AvatarDef = null;
         var _loc6_:AccItemCollection = null;
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         if(_playerWall && _currWallDecor)
         {
            while(_currWallDecor.photoCont.itemWindow.bgWindow.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.bgWindow.removeChildAt(_currWallDecor.photoCont.itemWindow.bgWindow.numChildren - 1);
            }
            while(_currWallDecor.photoCont.itemWindow.charBox.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.charBox.removeChildAt(_currWallDecor.photoCont.itemWindow.charBox.numChildren - 1);
            }
            while(_currWallDecor.photoCont.itemWindow.itemWindowPet2R.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet2R.removeChildAt(_currWallDecor.photoCont.itemWindow.itemWindowPet2R.numChildren - 1);
            }
            while(_currWallDecor.photoCont.itemWindow.itemWindowPet1R.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet1R.removeChildAt(_currWallDecor.photoCont.itemWindow.itemWindowPet1R.numChildren - 1);
            }
            while(_currWallDecor.photoCont.itemWindow.itemWindowPet2L.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet2L.removeChildAt(_currWallDecor.photoCont.itemWindow.itemWindowPet2L.numChildren - 1);
            }
            while(_currWallDecor.photoCont.itemWindow.itemWindowPet1L.numChildren > 1)
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet1L.removeChildAt(_currWallDecor.photoCont.itemWindow.itemWindowPet1L.numChildren - 1);
            }
         }
         if(param2)
         {
            if(_photoAvatar)
            {
               _photoAvatar.destroy();
               _photoAvatar = null;
            }
            if(_photoAvatarView)
            {
               _photoAvatarView.destroy();
               _photoAvatarView = null;
            }
         }
         else if(_wallParameters.pb != null && _wallParameters.pb.avatar != null)
         {
            if(param1 || _photoAvatarView == null)
            {
               if(_photoBackground == null)
               {
                  _mediaHelper = new MediaHelper();
                  _mediaHelper.init(6275,onBackgroundPhotoLoaded);
                  return;
               }
               _loc5_ = gMainFrame.userInfo.getAvatarDefByAvType(_wallParameters.pb.avatar.id,false);
               _photoAvatar = new Avatar();
               _photoAvatar.init(-1,-1,"",_loc5_.defId,[_wallParameters.pb.avatar.color1,_wallParameters.pb.avatar.color2,_wallParameters.pb.avatar.color3]);
               _loc6_ = new AccItemCollection();
               _loc3_ = new Item();
               _loc3_.init(1,0,0,EquippedAvatars.forced());
               _loc6_.pushAccItem(_loc3_);
               _loc3_ = new Item();
               _loc3_.init(_wallParameters.pb.avatar.eyes,1,0,EquippedAvatars.forced());
               _loc3_.color = _loc3_.colors[0];
               _loc6_.pushAccItem(_loc3_);
               if(_wallParameters.pb.avatar.pattern && _wallParameters.pb.avatar.pattern != 0)
               {
                  _loc3_ = new Item();
                  _loc3_.init(_wallParameters.pb.avatar.pattern,2,_photoAvatar.colors[1],EquippedAvatars.forced());
                  _loc6_.pushAccItem(_loc3_);
               }
               if(_wallParameters.pb.items)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _wallParameters.pb.items.length)
                  {
                     _loc3_ = new Item();
                     _loc3_.init(_wallParameters.pb.items[_loc4_].id,_loc4_ + 2,_wallParameters.pb.items[_loc4_].color,EquippedAvatars.forced());
                     _loc6_.pushAccItem(_loc3_);
                     _loc4_++;
                  }
               }
               _photoAvatar.userName = AvatarManager.playerAvatar.userName;
               _photoAvatar.itemResponseIntegrate(_loc6_);
               _photoAvatarView = new AvatarEditorView();
               _photoAvatarView.init(_photoAvatar,null,null,true);
               _photoAvatarView.playAnim(14,false,0,onAvatarLoaded);
               if(_wallParameters.pb.pet)
               {
                  _photoPet = new GuiPet(_wallParameters.pb.pet.ts,0,_wallParameters.pb.pet.lbits,_wallParameters.pb.pet.uBits,_wallParameters.pb.pet.eBits,0,"",0,0,0,onPetLoaded);
               }
            }
            else
            {
               _currWallDecor.photoCont.itemWindow.charBox.addChild(_photoAvatarView);
            }
            _currWallDecor.photoCont.visible = true;
            _currWallDecor.photoCont.noPhotoCont.visible = false;
            if(_wallParameters.pb.bgid == null || _wallParameters.pb.bgid < 0 || _wallParameters.pb.bgid > _photoBackground.framesLoaded)
            {
               _wallParameters.pb.bgid = 0;
            }
            _photoBackground.gotoAndStop(_wallParameters.pb.bgid);
            _currWallDecor.photoCont.itemWindow.bgWindow.addChild(_photoBackground);
         }
         else if(!_isMyWall)
         {
            _currWallDecor.photoCont.visible = false;
         }
         else
         {
            _currWallDecor.photoCont.visible = true;
            _currWallDecor.photoCont.noPhotoCont.visible = true;
         }
      }
      
      private function onDeleteDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.parent.parent.darken(true);
         new SBOkCancelPopup(_guiLayer,LocalizationManager.translateIdOnly(23141),true,deleteMessageConfirmCallback,param1.currentTarget.parent.parent.parent);
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(_playerWall && param1.status)
         {
            _playerWall.postBtn.activateGrayState(true);
            _playerWall.replyBtn.activateGrayState(true);
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendDeleteFromPlayerWall(_owner,param1.passback.parentOrMyPostMessageId,onDeleteResponse);
         }
         else
         {
            param1.passback.darken(false);
         }
      }
      
      public function onDeleteResponse(param1:Boolean, param2:String, param3:String = "") : void
      {
         if(_playerWall)
         {
            if(_predictiveTextManager && _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 0.5 && _playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
            {
               _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
               _playerWall.replyBtn.activateGrayState(!_predictiveTextManager.isValid());
            }
            else
            {
               _playerWall.postBtn.activateGrayState(true);
               _playerWall.replyBtn.activateGrayState(true);
            }
            if(param1)
            {
               deleteItemAndChildrenIfNecessary(param2,_inbox,_postWindows);
               _playerWall.noPostCont.visible = _inbox.length == 0;
               _playerWall.cleanUpBtn.activateGrayState(_inbox.length == 0);
            }
            else if(param3)
            {
               if(param3 == "token")
               {
                  PlayerWallXtCommManager.sendWallTokenRequest(_owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                     "cmd":"DEL",
                     "username":_owner,
                     "messageuuid":String,
                     "callback":onDeleteResponse
                  },true,true);
               }
               else if(param3 == "unavailable")
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
               }
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22627));
            }
         }
      }
      
      private function deleteItemAndChildrenIfNecessary(param1:String, param2:Vector.<PostMessage>, param3:WindowAndScrollbarGenerator) : void
      {
         var _loc4_:PostMessage = null;
         var _loc5_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = param2[_loc5_];
            if(_loc4_ != null && _loc4_.msgId == param1)
            {
               param3.deleteItem(_loc5_,param2,true,false);
               if(_loc4_.parentMessageId == null || _loc4_.parentMessageId.length == 0)
               {
                  if(_loc5_ < param2.length)
                  {
                     _loc4_ = param2[_loc5_];
                     while(_loc4_ != null && _loc5_ < param2.length && (_loc4_.parentMessageId != null && _loc4_.parentMessageId.length > 0))
                     {
                        param3.deleteItem(_loc5_,param2,true,false);
                        if(_loc5_ < param2.length)
                        {
                           _loc4_ = param2[_loc5_];
                        }
                        else
                        {
                           _loc4_ = null;
                        }
                     }
                  }
               }
               break;
            }
            _loc5_++;
         }
      }
      
      private function deleteItemByIndexAndChildrenIfNecessary(param1:int, param2:Vector.<PostMessage>, param3:WindowAndScrollbarGenerator) : void
      {
         var _loc4_:PostMessage = param2[param1];
         param3.deleteItem(param1,param2,true,false);
         if(_loc4_.parentMessageId == null || _loc4_.parentMessageId.length == 0)
         {
            if(param1 < param2.length)
            {
               _loc4_ = param2[param1];
               while(_loc4_ != null && param1 < param2.length && (_loc4_.parentMessageId != null && _loc4_.parentMessageId.length > 0))
               {
                  param3.deleteItem(param1,param2,true,false);
                  if(param1 < param2.length)
                  {
                     _loc4_ = param2[param1];
                  }
                  else
                  {
                     _loc4_ = null;
                  }
               }
            }
         }
      }
      
      private function onReplyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _currReplyPost = param1.currentTarget.parent.parent.parent;
         _playerWall.replyToTip.visible = true;
         LocalizationManager.translateIdAndInsert(_playerWall.replyToTip.replyToTxt,30491,_currReplyPost.senderModeratedUserName);
         _playerWall.replyBtn.visible = true;
         _playerWall.cancelBtn.visible = true;
      }
      
      private function onPatternBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_emoteMgr)
            {
               _emoteMgr.closeEmotes();
            }
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            else
            {
               _playerWall.patternPopup.visible = true;
            }
         }
      }
      
      private function onColorBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_emoteMgr)
            {
               _emoteMgr.closeEmotes();
            }
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
            else
            {
               _playerWall.colorPopup.visible = true;
            }
         }
      }
      
      private function onEmoteBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3)
            {
               gMainFrame.stage.focus = null;
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406),true,openSafeChatAfterOk);
               }
               return;
            }
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
         }
      }
      
      private function onSafeChatBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.isGray)
            {
               return;
            }
         }
         if(_emoteMgr)
         {
            _emoteMgr.closeEmotes();
         }
         if(_playerWall.patternPopup.visible)
         {
            _playerWall.patternPopup.visible = false;
            _playerWall.patternBtn.downToUpState();
         }
         if(_playerWall.colorPopup.visible)
         {
            _playerWall.colorPopup.visible = false;
            _playerWall.colorBtn.downToUpState();
         }
         if(!_playerWall.speedChatBtn.isGray)
         {
            if(!_hasLoadedSafeChat)
            {
               SafeChatManager.buildSafeChatTree(_playerWall.chatTree,"ECardTextTreeNode",5,onChatTreeClose,null,onSafeChatLoaded);
               _hasLoadedSafeChat = true;
            }
            else if(!_playerWall.chatTree.visible)
            {
               SafeChatManager.openSafeChat(false,_playerWall.chatTree);
            }
            else
            {
               SafeChatManager.closeSafeChat(_playerWall.chatTree);
            }
         }
      }
      
      private function onSafeChatLoaded() : void
      {
         SafeChatManager.openSafeChat(false,_playerWall.chatTree);
      }
      
      private function onEmoteDown(param1:Sprite) : void
      {
         var _loc2_:String = null;
         if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha == 0.5)
         {
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
            if(_predictiveTextManager)
            {
               _predictiveTextManager.resetTreeSearch();
            }
         }
         if(_predictiveTextManager)
         {
            _loc2_ = EmoticonUtility.getEmoteString(param1);
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.text.length + _loc2_.length <= _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars)
            {
               _predictiveTextManager.addWordToPredictiveText(_loc2_);
               setTimeout(updateCharCount,41.666666666666664);
               gMainFrame.stage.focus = _playerWall.messageTxtCont.txtColorCont.messageTxt;
               _playerWall.speedChatBtn.activateGrayState(true);
            }
         }
      }
      
      private function onPostBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_predictiveTextManager)
         {
            _predictiveTextManager.onSendBtnDown(null);
         }
         else
         {
            onSendMessage();
         }
      }
      
      private function onSettingsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _playerWall.settingsPopup.visible = !_playerWall.settingsPopup.visible;
         if(!_playerWall.settingsPopup.visible)
         {
            _playerWall.settingsBtn[_playerWall.settingsBtn.currentFrameLabel + "Btn"].downToUpState();
         }
         closeAllLowerPopups();
      }
      
      private function onMenuBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         closeAllLowerPopups();
         _playerWall.wallCustomize.visible = true;
         setupCustomizationWindows(0);
      }
      
      private function onMasterpieceFrameDown(param1:MouseEvent) : void
      {
         var _loc3_:MasterpieceDisplayItem = null;
         param1.stopPropagation();
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_ && _loc2_.itemLayer.numChildren > 1)
         {
            _loc3_ = _loc2_.itemLayer.getChildAt(_loc2_.itemLayer.numChildren - 1) as MasterpieceDisplayItem;
            if(_loc3_)
            {
               GuiManager.openMasterpiecePreview(_loc3_.uniqueImageId,_loc3_.uniqueImageCreator,_loc3_.uniqueImageCreatorDbId,_loc3_.uniqueImageCreatorUUID,_loc3_.versionId,_owner,null);
            }
         }
      }
      
      private function onMasterpieceOrStickerFrameOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("mouse");
      }
      
      private function onMasterpieceOrStickerFrameOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("out");
         param1.currentTarget.glow.visible = false;
      }
      
      private function onStickerFrameDown(param1:MouseEvent) : void
      {
         var _loc3_:StickerItem = null;
         param1.stopPropagation();
         var _loc2_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc2_ && _loc2_.itemLayer.numChildren > 1)
         {
            _loc3_ = _loc2_.itemLayer.getChildAt(_loc2_.itemLayer.numChildren - 1) as StickerItem;
            if(!_loc3_)
            {
            }
         }
      }
      
      private function onSuggestWordsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FeedbackManager.openFeedbackPopup(18);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onDecorMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = _currDecorIndex;
         if(param1)
         {
            param1.stopPropagation();
            _wallCustomizeWindows.mediaWindows[_loc2_].downToUpState();
            _loc2_ = int(param1.currentTarget.index);
            _currDecorIndex = _loc2_;
            _wallParameters.bg = _currDecorIndex;
         }
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_wallDecorItemIds[_loc2_],onWallDecorItemLoaded);
      }
      
      private function onStickerMouseDown(param1:MouseEvent) : void
      {
         var _loc4_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:StickerItem = null;
         param1.stopPropagation();
         if((param1.currentTarget as ItemWindowSticker).inUse)
         {
            _loc5_ = (param1.currentTarget as ItemWindowSticker).stickerMediaId;
            if(_loc5_ > 0)
            {
               _loc4_ = _playerWall.sticker_0;
               _loc2_ = 0;
               loop1:
               while(_loc4_ != null)
               {
                  if(_loc4_.itemLayer.numChildren > 1)
                  {
                     _loc3_ = _loc4_.itemLayer.getChildAt(_loc4_.itemLayer.numChildren - 1) as StickerItem;
                     if(_loc3_ && _loc5_ == _loc3_.mediaId)
                     {
                        _loc4_.itemLayer.removeChild(_loc3_);
                        if(_selectedStickers)
                        {
                           var _loc8_:int = 0;
                           var _loc7_:Array = _selectedStickers;
                           while(true)
                           {
                              for(var _loc6_ in _loc7_)
                              {
                                 if(_selectedStickers[_loc6_].id == _loc5_)
                                 {
                                    _selectedStickers.splice(_loc6_,1);
                                    _wallParameters.stk = _selectedStickers;
                                    break loop1;
                                 }
                              }
                              break loop1;
                           }
                        }
                        break;
                     }
                  }
                  if(_loc4_.loadingSpiral)
                  {
                     (_loc4_.loadingSpiral as LoadingSpiral).destroy();
                     delete _loc4_.loadingSpiral;
                  }
                  _loc2_++;
                  _loc4_ = _playerWall["sticker_" + _loc2_];
               }
            }
            (param1.currentTarget as ItemWindowSticker).inUse = false;
         }
         else
         {
            _currDragSticker = param1.currentTarget.cloneItem(onStickerDragCloneLoaded);
            _dragStartPoint = new Point(param1.stageX,param1.stageY);
            _currDragSticker.startDrag();
            _playerWall.addChild(_currDragSticker);
            _playerWall.addEventListener("mouseUp",onStickerMouseUp,false,0,true);
            _loc4_ = _playerWall.sticker_0;
            _loc2_ = 0;
            while(_loc4_ != null)
            {
               _loc4_.gotoAndStop("out");
               _loc4_.glow.visible = true;
               _loc4_.mouseEnabled = false;
               _loc4_.mouseChildren = false;
               _loc2_++;
               _loc4_ = _playerWall["sticker_" + _loc2_];
            }
            (param1.currentTarget as ItemWindowSticker).inUse = true;
         }
      }
      
      private function onMasterpieceMouseDown(param1:MouseEvent) : void
      {
         var _loc5_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc7_:DenItem = null;
         var _loc3_:MasterpieceDisplayItem = null;
         var _loc4_:MasterpieceDisplayItem = null;
         param1.stopPropagation();
         if((param1.currentTarget as ItemWindowMasterpiece).inUse)
         {
            _loc7_ = (param1.currentTarget as ItemWindowMasterpiece).currItem;
            if(_loc7_)
            {
               _loc5_ = _playerWall.frame_0;
               _loc2_ = 0;
               loop1:
               while(_loc5_ != null)
               {
                  if(_loc5_.itemLayer.numChildren > 1)
                  {
                     _loc3_ = _loc5_.itemLayer.getChildAt(_loc5_.itemLayer.numChildren - 1) as MasterpieceDisplayItem;
                     if(_loc3_ && _loc7_.invIdx == _loc3_.invId)
                     {
                        _loc5_.itemLayer.removeChild(_loc3_);
                        if(_selectedMasterpieces)
                        {
                           var _loc9_:int = 0;
                           var _loc8_:Array = _selectedMasterpieces;
                           while(true)
                           {
                              for(var _loc6_ in _loc8_)
                              {
                                 if(_selectedMasterpieces[_loc6_].iid == _loc7_.invIdx)
                                 {
                                    _selectedMasterpieces.splice(_loc6_,1);
                                    _wallParameters.mp = _selectedMasterpieces;
                                    break loop1;
                                 }
                              }
                              break loop1;
                           }
                        }
                        break;
                     }
                  }
                  if(_loc5_.loadingSpiral)
                  {
                     (_loc5_.loadingSpiral as LoadingSpiral).destroy();
                     delete _loc5_.loadingSpiral;
                  }
                  _loc2_++;
                  _loc5_ = _playerWall["frame_" + _loc2_];
               }
            }
            (param1.currentTarget as ItemWindowMasterpiece).inUse = false;
         }
         else
         {
            _currDragMasterpiece = _loc4_ = param1.currentTarget.cloneItem(onDragItemLoaded) as MasterpieceDisplayItem;
            _dragStartPoint = new Point(param1.stageX,param1.stageY);
            _currDragMasterpiece.startDrag();
            _playerWall.addChild(_currDragMasterpiece);
            _playerWall.addEventListener("mouseUp",onMasterpieceMouseUp,false,0,true);
            _loc5_ = _playerWall.frame_0;
            _loc2_ = 0;
            while(_loc5_ != null)
            {
               _loc5_.gotoAndStop("out");
               _loc5_.glow.visible = true;
               _loc5_.mouseEnabled = false;
               _loc5_.mouseChildren = false;
               _loc2_++;
               _loc5_ = _playerWall["frame_" + _loc2_];
            }
            (param1.currentTarget as ItemWindowMasterpiece).inUse = true;
         }
      }
      
      private function onStickerDragCloneLoaded() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Number = NaN;
         if(_currDragSticker)
         {
            _loc1_ = _playerWall.globalToLocal(_dragStartPoint);
            _currDragSticker.x = _loc1_.x;
            _currDragSticker.y = _loc1_.y;
            _loc2_ = _playerWall.sticker_0.itemLayer.width / Math.max(_currDragSticker.width,_currDragSticker.height);
            _currDragSticker.scaleX = _currDragSticker.scaleY = _loc2_;
            if(_currDragSticker.parent != _playerWall)
            {
               _currDragSticker.x = _currDragSticker.y = 0;
               _currDragSticker = null;
            }
         }
      }
      
      private function onDragItemLoaded(param1:MasterpieceDisplayItem, param2:MovieClip) : void
      {
         var _loc3_:Point = null;
         var _loc4_:Number = NaN;
         if(_currDragMasterpiece)
         {
            _loc3_ = _playerWall.globalToLocal(_dragStartPoint);
            _currDragMasterpiece.x = _loc3_.x;
            _currDragMasterpiece.y = _loc3_.y;
            _loc4_ = _playerWall.frame_0.itemLayer.width / Math.max(_currDragMasterpiece.width,_currDragMasterpiece.height);
            _currDragMasterpiece.scaleX = _currDragMasterpiece.scaleY = _loc4_;
            _currDragMasterpiece.onLoadedCallback = null;
            if(_currDragMasterpiece.parent != _playerWall)
            {
               _currDragMasterpiece.x = _currDragMasterpiece.y = 0;
               _currDragMasterpiece = null;
            }
         }
      }
      
      private function onStickerMouseUp(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc7_:* = null;
         var _loc8_:* = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Object = null;
         param1.stopPropagation();
         if(_currDragSticker != null)
         {
            _currDragSticker.stopDrag();
            _loc3_ = _playerWall.sticker_0;
            _loc2_ = 0;
            _loc8_ = 2147483647;
            while(_loc3_ != null)
            {
               _loc4_ = Math.sqrt(Math.pow(_loc3_.x - _currDragSticker.x,2) + Math.pow(_loc3_.y - _currDragSticker.y,2));
               if(_loc4_ < _loc8_)
               {
                  _loc8_ = _loc4_;
                  _loc7_ = _loc3_;
               }
               _loc3_.glow.visible = false;
               _loc3_.gotoAndStop("out");
               _loc3_.mouseEnabled = true;
               _loc3_.mouseChildren = true;
               _loc2_++;
               _loc3_ = _playerWall["sticker_" + _loc2_];
            }
            if(_selectedStickers != null)
            {
               _selectedStickers.push({
                  "id":_currDragSticker.mediaId,
                  "pos":int(_loc7_.name.split("_")[1])
               });
            }
            else
            {
               _selectedStickers = [{
                  "id":_currDragSticker.mediaId,
                  "pos":int(_loc7_.name.split("_")[1])
               }];
            }
            if(_wallParameters)
            {
               _wallParameters.stk = _selectedStickers;
            }
            else
            {
               _wallParameters = {"stk":_selectedStickers};
            }
            while(_loc7_.itemLayer.numChildren > 1)
            {
               _loc9_ = _loc7_.itemLayer.getChildAt(_loc7_.itemLayer.numChildren - 1);
               if(_loc9_ is StickerItem)
               {
                  for(var _loc5_ in _selectedStickers)
                  {
                     if(_selectedStickers[_loc5_].id == (_loc9_ as StickerItem).mediaId)
                     {
                        for(var _loc6_ in _wallCustomizeWindows.mediaWindows)
                        {
                           if(_wallCustomizeWindows.mediaWindows[_loc6_].stickerMediaId == _selectedStickers[_loc5_].id)
                           {
                              _wallCustomizeWindows.callUpdateOnWindowWithInput(_loc6_,false);
                              break;
                           }
                        }
                        _selectedStickers.splice(_loc5_,1);
                        break;
                     }
                  }
               }
               _loc7_.itemLayer.removeChildAt(_loc7_.itemLayer.numChildren - 1);
            }
            if(_loc7_.loadingSpiral)
            {
               (_loc7_.loadingSpiral as LoadingSpiral).destroy();
               delete _loc7_.loadingSpiral;
            }
            _loc7_.itemLayer.addChild(_currDragSticker);
            _currDragSticker.x = _currDragSticker.y = 0;
            _currDragSticker = null;
         }
         _playerWall.removeEventListener("mouseUp",onStickerMouseUp);
      }
      
      private function onMasterpieceMouseUp(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         var _loc7_:* = null;
         var _loc8_:* = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Object = null;
         param1.stopPropagation();
         if(_currDragMasterpiece != null)
         {
            _currDragMasterpiece.stopDrag();
            _loc3_ = _playerWall.frame_0;
            _loc2_ = 0;
            _loc8_ = 2147483647;
            while(_loc3_ != null)
            {
               _loc4_ = Math.sqrt(Math.pow(_loc3_.x - _currDragMasterpiece.x,2) + Math.pow(_loc3_.y - _currDragMasterpiece.y,2));
               if(_loc4_ < _loc8_)
               {
                  _loc8_ = _loc4_;
                  _loc7_ = _loc3_;
               }
               _loc3_.glow.visible = false;
               _loc3_.gotoAndStop("out");
               _loc3_.mouseEnabled = true;
               _loc3_.mouseChildren = true;
               _loc2_++;
               _loc3_ = _playerWall["frame_" + _loc2_];
            }
            if(_selectedMasterpieces != null)
            {
               _selectedMasterpieces.push({
                  "iid":_currDragMasterpiece.invId,
                  "sid":int(_loc7_.name.split("_")[1])
               });
            }
            else
            {
               _selectedMasterpieces = [{
                  "iid":_currDragMasterpiece.invId,
                  "sid":int(_loc7_.name.split("_")[1])
               }];
            }
            if(_wallParameters)
            {
               _wallParameters.mp = _selectedMasterpieces;
            }
            else
            {
               _wallParameters = {"mp":_selectedMasterpieces};
            }
            while(_loc7_.itemLayer.numChildren > 1)
            {
               _loc9_ = _loc7_.itemLayer.getChildAt(_loc7_.itemLayer.numChildren - 1);
               if(_loc9_ is MasterpieceDisplayItem)
               {
                  for(var _loc5_ in _selectedMasterpieces)
                  {
                     if(_selectedMasterpieces[_loc5_].iid == (_loc9_ as MasterpieceDisplayItem).invId)
                     {
                        for(var _loc6_ in _masterpieceDiCollection.getCoreArray())
                        {
                           if(_masterpieceDiCollection.getDenItem(_loc6_).invIdx == _selectedMasterpieces[_loc5_].iid)
                           {
                              _wallCustomizeWindows.callUpdateOnWindowWithInput(_loc6_,false);
                              break;
                           }
                        }
                        _selectedMasterpieces.splice(_loc5_,1);
                        break;
                     }
                  }
               }
               _loc7_.itemLayer.removeChildAt(_loc7_.itemLayer.numChildren - 1);
            }
            if(_loc7_.loadingSpiral)
            {
               (_loc7_.loadingSpiral as LoadingSpiral).destroy();
               delete _loc7_.loadingSpiral;
            }
            _loc7_.itemLayer.addChild(_currDragMasterpiece);
            _currDragMasterpiece.x = _currDragMasterpiece.y = 0;
            if(_currDragMasterpiece.hasLoaded)
            {
               _currDragMasterpiece = null;
            }
         }
         _playerWall.removeEventListener("mouseUp",onMasterpieceMouseUp);
      }
      
      private function onWallDecorItemLoaded(param1:MovieClip) : void
      {
         if(_playerWall)
         {
            if(_currWallDecor != null)
            {
               if(_isMyWall)
               {
                  _currWallDecor.photoCont.removeEventListener("mouseDown",onPhotoCont);
                  _currWallDecor.postStatus.removeEventListener("mouseDown",onPostStatus);
               }
               else
               {
                  _currWallDecor.postStatus.mouse.mouse.reportBtn.removeEventListener("mouseDown",onStatusReportDown);
                  _currWallDecor.postStatus.removeEventListener("rollOver",onPostStatusOver);
                  _currWallDecor.postStatus.removeEventListener("rollOut",onPostStatusOut);
               }
               _playerWall.wallItemWindow.removeChild(_currWallDecor);
            }
            _currWallDecor = MovieClip(param1.getChildAt(0));
            if(_isMyWall)
            {
               _currWallDecor.photoCont.addEventListener("mouseDown",onPhotoCont,false,0,true);
               _currWallDecor.postStatus.addEventListener("mouseDown",onPostStatus,false,0,true);
            }
            else
            {
               _currWallDecor.postStatus.mouse.mouse.reportBtn.addEventListener("mouseDown",onStatusReportDown,false,0,true);
               _currWallDecor.postStatus.addEventListener("rollOver",onPostStatusOver,false,0,true);
               _currWallDecor.postStatus.addEventListener("rollOut",onPostStatusOut,false,0,true);
            }
            _currWallDecor.postStatus.mouse.mouse.reportBtn.visible = false;
            _playerWall.wallItemWindow.addChild(_currWallDecor);
            if(_wallParameters.tag != null && _wallParameters.tag != "" && (_wallParameters.langId == -1 || _wallParameters.langId == LocalizationManager.currentLanguage))
            {
               _currWallDecor.postStatus.mouse.mouse.statusTxt.txt.text = _wallParameters.tag;
            }
            else if(!_isMyWall)
            {
               _currWallDecor.postStatus.visible = false;
            }
            _hasLoadedDecor = true;
            if(!_guiLayer.contains(_playerWall))
            {
               if(_messagePatternLoaded)
               {
                  displayLoadedWall();
               }
               setupAvatarAndPetPhoto(true);
            }
            else
            {
               setupAvatarAndPetPhoto(false);
            }
         }
      }
      
      private function onTimerEvent(param1:Event) : void
      {
         if(_playerWall)
         {
            if(_postWindows)
            {
               _postWindows.callUpdateInWindow();
            }
            if(_notificationWindows)
            {
               _notificationWindows.callUpdateInWindow();
            }
            _updateTimer.reset();
            _updateTimer.start();
         }
      }
      
      private function onMessageEntry(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23230));
      }
      
      private function onPatternWindowsLoaded() : void
      {
         if(_playerWall)
         {
            _patternScrollBar = new SBScrollbar();
            _patternScrollBar.init(_patternWindows,_playerWall.patternPopup.itemWindow.width,_patternWindows.boxHeight * 8,3,"scrollbar2",_patternWindows.boxHeight,0);
         }
      }
      
      private function onDecorItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _wallDecorItemIds = param2;
            onDecorMouseDown(null);
         }
      }
      
      private function onMasterpieceFrameItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _masterpieceFrameIds = param2;
         }
      }
      
      private function onPatternLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(_playerWall)
         {
            param1 = MovieClip(param1.getChildAt(0)).swatchBtn.pattern;
            _patternIconIds = new Array(param1.currentLabels.length);
            _loc2_ = 0;
            while(_loc2_ < param1.currentLabels.length)
            {
               _patternIconIds[_loc2_] = 3983;
               _loc2_++;
            }
            setupPatterns();
         }
      }
      
      private function onSendMessage() : void
      {
         var _loc2_:Avatar = null;
         var _loc1_:PostMessage = null;
         if(!_playerWall.postBtn.isGray && !_playerWall.replyBtn.isGray)
         {
            KeepAlive.restartTimeLeftTimer();
            _playerWall.postBtn.activateGrayState(true);
            _playerWall.replyBtn.activateGrayState(true);
            _playerWall.speedChatBtn.activateGrayState(false);
            _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
            _loc2_ = AvatarManager.playerAvatar;
            _loc1_ = new PostMessage("0",_playerWall.messageTxtCont.txtColorCont.messageTxt.text,gMainFrame.clientInfo.dbUserId,gMainFrame.userInfo.myUserName,gMainFrame.userInfo.userNameModerated,_currPatternId,_myCurrColorId,new Date().valueOf(),false,_loc2_.avTypeId,_loc2_.colors,_loc2_.inUseEyeId,_loc2_.inUsePatternId,LocalizationManager.currentLanguage,_loc2_.customAvId,_currReplyPost != null ? _currReplyPost.parentOrMyPostMessageId : "",gMainFrame.userInfo.myUUID,false);
            PlayerWallXtCommManager.sendPutToPlayerWall(_owner,_loc1_,_wallParameters,onMessageSent);
         }
         else if(!_canWrite)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23230));
         }
      }
      
      private function onMessageSent(param1:Boolean, param2:PostMessage, param3:int, param4:int, param5:String = "") : void
      {
         if(_playerWall)
         {
            if(param1)
            {
               _playerWall.noPostCont.visible = _inbox.length == 0;
            }
            else
            {
               if(param3 > 4 && param3 != 7)
               {
                  FacilitatorXtCommManager.showContextualWarningPopup(param4);
               }
               else if(param3 == -1)
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               else if(param5)
               {
                  if(param5 == "token")
                  {
                     PlayerWallXtCommManager.sendWallTokenRequest(_owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                        "cmd":"PUT",
                        "username":_owner,
                        "msgToPost":param2,
                        "callback":onMessageSent
                     },true,true);
                  }
                  else if(param5 == "unavailable")
                  {
                     new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
                  }
               }
               else
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               _playerWall.postBtn.activateGrayState(true);
               _playerWall.replyBtn.activateGrayState(true);
            }
            _currReplyPost = null;
            _playerWall.replyBtn.visible = false;
            _playerWall.cancelBtn.visible = false;
            _playerWall.replyToTip.visible = false;
            if(_predictiveTextManager)
            {
               _predictiveTextManager.resetTreeSearch();
            }
            else
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.text = LocalizationManager.translateIdOnly(23140);
            }
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 0.5;
         }
      }
      
      private function onFirstTimeGet(param1:Boolean) : void
      {
         if(_playerWall)
         {
            KeepAlive.restartTimeLeftTimer();
            if(param1)
            {
               setupWallCustomizePopup();
               setupWallDecorItems();
               setupMasterpieces();
               setupStickers();
               setupMessageEntry();
               setupNotificationsPopup();
               setupLikes();
               setupViews();
               setupSettingsPopup(false,_privacyId);
               onSettingsChoose(null);
               addEventListeners();
               setupSafeChat();
               setupPatterns();
               setupColors();
               setupEmotePopup();
            }
         }
      }
      
      private function onPrivacySetResponse(param1:Boolean, param2:int) : void
      {
         if(_playerWall)
         {
            if(param1)
            {
               _privacyId = param2;
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14774));
            }
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
         if(_playerWall)
         {
            if(param2)
            {
               if(_playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
               {
                  _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
                  _playerWall.replyBtn.activateGrayState(!_predictiveTextManager.isValid());
               }
               else
               {
                  _playerWall.postBtn.activateGrayState(true);
                  _playerWall.replyBtn.activateGrayState(true);
               }
               return;
            }
            _loc6_ = new TextField();
            _loc5_ = _playerWall.messageTxtCont.txtColorCont.messageTxt.getTextFormat();
            _loc6_.text = _playerWall.messageTxtCont.txtColorCont.messageTxt.text + param1;
            _loc6_.setTextFormat(_loc5_);
            if(_loc6_.length > _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars)
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
      
      private function onDecorIconsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _wallDecorIconIds = param2;
            setupCustomizationWindows(0);
         }
      }
      
      private function onMessagePatternLoaded(param1:MovieClip) : void
      {
         if(_playerWall && _messagePatternWindow)
         {
            _messagePatternLoaded = true;
            if(_hasLoadedDecor)
            {
               displayLoadedWall();
            }
         }
      }
      
      private function onStickerIconsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _stickerIconIds = param2;
            setupCustomizationWindows(1);
         }
      }
      
      private function onPhotoSave(param1:Boolean, param2:Object) : void
      {
         if(param1)
         {
            setupAvatarAndPetPhoto(true);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(30733));
         }
      }
      
      private function onSetStatusResponse(param1:Boolean, param2:Object) : void
      {
         if(param1)
         {
            _currWallDecor.postStatus.mouse.mouse.statusTxt.txt.text = _wallParameters.tag;
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(30733));
         }
      }
      
      private function onWallMenuParametersSet(param1:Boolean, param2:Object) : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_wallDecorItemIds[_currDecorIndex],onWallDecorItemLoaded);
         if(!param1)
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(30733));
         }
      }
      
      private function onResourceArrayGet(param1:Boolean, param2:Boolean, param3:int, param4:Object) : void
      {
         _playerWall.likeBtn.activateLoadingState(false);
         if(param1)
         {
            _playerWall.likeBtn.setTextInLayer(Utility.convertNumberToString(param3),"numTxt");
            _playerWall.likeCount = param3;
            if(param2)
            {
               _playerWall.likeBtn.upToDownState();
               _playerWall.likeBtn.removeEventListener("mouseDown",onLikeBtn);
               _playerWall.likeBtn.mouseChildren = false;
               _playerWall.likeBtn.mouseEnabled = false;
            }
            _playerWall.likeBtn.visible = true;
         }
         else
         {
            _playerWall.likeBtn.setTextInLayer(Utility.convertNumberToString(0),"numTxt");
         }
      }
      
      private function onCounterIncrement(param1:Boolean) : void
      {
         if(param1)
         {
            if(_playerWall)
            {
               _wallParameters.visits++;
               LocalizationManager.translateIdAndInsert(_playerWall.viewCount,30488,Utility.convertNumberToString(_wallParameters.visits));
            }
         }
      }
      
      private function onAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         var _loc3_:Matrix = null;
         _photoAvatarView.visible = true;
         if(_wallParameters.pb.avatar.flip != null && _wallParameters.pb.avatar.flip == 1)
         {
            _loc3_ = _photoAvatarView.transform.matrix;
            _loc3_.scale(-1,1);
            _photoAvatarView.transform.matrix = _loc3_;
         }
         if(Utility.isAir(_photoAvatar.enviroTypeFlag))
         {
            if(_photoAvatar.avTypeId == 49)
            {
               _photoAvatarView.y = -10;
            }
            else
            {
               _photoAvatarView.y = -50;
            }
         }
         else
         {
            _photoAvatarView.y = -60;
         }
         _photoAvatarView.x = -75;
         _currWallDecor.photoCont.itemWindow.charBox.addChild(_photoAvatarView);
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc3_:Matrix = null;
         _photoPet.scaleY = 0.75;
         _photoPet.scaleX = 0.75;
         _photoPet.y = 15;
         if(_wallParameters.pb.pet.flip == null || _wallParameters.pb.pet.flip == 0 || _wallParameters.pb.pet.flip == 3)
         {
            _loc3_ = _photoPet.transform.matrix;
            _loc3_.scale(-1,1);
            _photoPet.transform.matrix = _loc3_;
         }
         if(_photoPet.isGround())
         {
            if(_wallParameters.pb.pet.flip != null && _wallParameters.pb.pet.flip < 2)
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet2L.addChild(_photoPet);
            }
            else
            {
               _currWallDecor.photoCont.itemWindow.itemWindowPet2R.addChild(_photoPet);
            }
         }
         else if(_wallParameters.pb.pet.flip != null && _wallParameters.pb.pet.flip < 2)
         {
            _currWallDecor.photoCont.itemWindow.itemWindowPet1L.addChild(_photoPet);
         }
         else
         {
            _currWallDecor.photoCont.itemWindow.itemWindowPet1R.addChild(_photoPet);
         }
      }
      
      private function onBackgroundPhotoLoaded(param1:MovieClip) : void
      {
         _photoBackground = MovieClip(param1.getChildAt(0));
         setupAvatarAndPetPhoto(true);
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(_playerWall && _predictiveTextManager)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(_predictiveTextManager)
         {
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 1)
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
               _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onKeyDown(param1);
               setTimeout(updateCharCount,41.666666666666664);
            }
         }
         else if(!_playerWall.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,_playerWall.chatTree);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14713));
         }
      }
      
      private function updateCharCount() : void
      {
         if(_playerWall)
         {
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = true;
            _playerWall.messageTxtCont.txtColorCont.charCounter.text = _playerWall.messageTxtCont.txtColorCont.messageTxt.text.length + "/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
            {
               _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
               _playerWall.replyBtn.activateGrayState(!_predictiveTextManager.isValid());
            }
            else
            {
               _playerWall.postBtn.activateGrayState(true);
               _playerWall.replyBtn.activateGrayState(true);
            }
         }
      }
      
      private function onSettingsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_wallSettingsRadioBtns.selected != _privacyId)
         {
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendSetWallSettingsRequest(_wallSettingsRadioBtns.selected,onPrivacySetResponse);
         }
         onSettingsBtn(param1);
      }
      
      private function onSettingsChoose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _playerWall.settingsBtn.gotoAndStop(_wallSettingsRadioBtns.selected + 1);
         if(_playerWall.settingsPopup.visible)
         {
            _playerWall.settingsBtn[_playerWall.settingsBtn.currentFrameLabel + "Btn"].upToDownState();
         }
      }
      
      private function onWallMenuClose(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         _playerWall.wallCustomize.visible = false;
         if(param1)
         {
            _loc2_ = checkForWallParameterChanges();
            if(_loc2_ != null)
            {
               PlayerWallXtCommManager.sendSetWallParametersRequest(_wallParameters,_loc2_,onWallMenuParametersSet);
            }
         }
         if(_wallCustomizeWindows)
         {
            _wallCustomizeWindows.destroy();
            _wallCustomizeWindows = null;
         }
      }
      
      private function checkForWallParameterChanges() : Object
      {
         var _loc17_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc13_:Object = null;
         var _loc8_:int = 0;
         var _loc11_:Object = null;
         var _loc16_:Array = null;
         var _loc20_:Array = null;
         var _loc19_:Object = null;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc14_:Array = null;
         var _loc9_:int = 0;
         var _loc15_:int = 0;
         var _loc6_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         var _loc10_:Object = {};
         var _loc12_:Object = PlayerWallManager.myWallParameters;
         for(var _loc18_ in _wallParameters)
         {
            _loc13_ = _wallParameters[_loc18_];
            _loc7_ = false;
            if(_loc12_[_loc18_] != null)
            {
               _loc11_ = _loc12_[_loc18_];
               switch(_loc18_)
               {
                  case "bg":
                     if(int(_loc13_) != int(_loc11_))
                     {
                        _loc7_ = true;
                        _loc10_.bg = _loc13_;
                     }
                     break;
                  case "visits":
                     if(int(_loc13_) != int(_loc11_))
                     {
                        _loc7_ = true;
                        _loc10_.visits = _loc13_;
                     }
                     break;
                  case "stk":
                     _loc16_ = _loc13_ as Array;
                     _loc20_ = _loc11_ as Array;
                     if(_loc16_ == null || _loc20_ == null || _loc16_.length != _loc20_.length)
                     {
                        _loc7_ = true;
                     }
                     else
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc16_.length)
                        {
                           if(!(_loc16_[_loc8_] != null && _loc20_[_loc8_] != null))
                           {
                              _loc7_ = true;
                              break;
                           }
                           if(_loc16_[_loc8_].id != _loc20_[_loc8_].id || _loc16_[_loc8_].pos != _loc20_[_loc8_].pos)
                           {
                              _loc7_ = true;
                              break;
                           }
                           _loc8_++;
                        }
                     }
                     if(_loc7_)
                     {
                        _loc10_.stk = _loc16_;
                     }
                     break;
                  case "tag":
                     if(String(_loc13_) != String(_loc11_))
                     {
                        _loc7_ = true;
                        _loc10_.tag = _loc13_;
                     }
                     break;
                  case "pb":
                     _loc19_ = _loc13_.avatar;
                     _loc3_ = _loc11_.avatar;
                     _loc4_ = _loc13_.items;
                     _loc14_ = _loc11_.items;
                     _loc9_ = int(_loc13_.bgid);
                     _loc15_ = int(_loc11_.bgid);
                     _loc6_ = _loc13_.pet;
                     _loc5_ = _loc11_.pet;
                     if(_loc19_ != null)
                     {
                        if(_loc3_ == null)
                        {
                           _loc7_ = true;
                        }
                        else if(_loc19_ != null && (_loc19_.color1 != _loc3_.color1 || _loc19_.color2 != _loc3_.color2 || _loc19_.color3 != _loc3_.color3 || _loc19_.eyes != _loc3_.eyes || _loc19_.flip != _loc3_.flip || _loc19_.id != _loc3_.id || _loc19_.pattern != _loc3_.pattern))
                        {
                           _loc7_ = true;
                        }
                        else if(_loc9_ != _loc15_)
                        {
                           _loc7_ = true;
                        }
                        else if(_loc6_ == null && _loc5_ != null || _loc5_ == null && _loc6_ != null)
                        {
                           _loc7_ = true;
                        }
                        else if(_loc6_ != null && _loc5_ != null && (_loc6_.ebits != _loc5_.ebits || _loc6_.flip != _loc5_.flip || _loc6_.id != _loc5_.id || _loc6_.lbits != _loc5_.lbits || _loc6_.ubits != _loc5_.ubits))
                        {
                           _loc7_ = true;
                        }
                        else if(_loc4_ == null && _loc14_ != null || _loc4_ != null && _loc14_ == null)
                        {
                           _loc7_ = true;
                        }
                        else if(_loc4_ != null && _loc14_ != null)
                        {
                           if(_loc4_.length != _loc14_.length)
                           {
                              _loc7_ = true;
                           }
                           else
                           {
                              _loc8_ = 0;
                              while(_loc8_ < _loc4_.length)
                              {
                                 if(_loc4_[_loc8_].id != _loc14_[_loc8_].id || _loc4_[_loc8_].color != _loc14_[_loc8_].color)
                                 {
                                    _loc7_ = true;
                                    break;
                                 }
                                 _loc8_++;
                              }
                           }
                        }
                     }
                     if(_loc7_)
                     {
                        _loc10_.pb = {
                           "avatar":_loc19_,
                           "bgid":_loc9_,
                           "pet":_loc6_,
                           "items":_loc4_
                        };
                     }
                     break;
                  case "mp":
                     _loc2_ = _loc13_ as Array;
                     _loc1_ = _loc11_ as Array;
                     if(_loc2_ == null || _loc1_ == null)
                     {
                        _loc7_ = true;
                     }
                     if(!_loc7_)
                     {
                        _loc8_ = 0;
                        while(_loc8_ < _loc2_.length)
                        {
                           if(_loc2_[_loc8_] == null || _loc2_[_loc8_].sid > 2)
                           {
                              _loc2_.splice(_loc8_,1);
                              _loc8_--;
                           }
                           _loc8_++;
                        }
                        if(_loc2_.length != _loc1_.length)
                        {
                           _loc7_ = true;
                        }
                        else
                        {
                           _loc8_ = 0;
                           while(_loc8_ < _loc2_.length)
                           {
                              if(!(_loc2_[_loc8_] != null && _loc1_[_loc8_] != null))
                              {
                                 _loc7_ = true;
                                 break;
                              }
                              if(_loc2_[_loc8_].iid != _loc1_[_loc8_].iid || _loc2_[_loc8_].sid != _loc1_[_loc8_].sid)
                              {
                                 _loc7_ = true;
                                 break;
                              }
                              _loc8_++;
                           }
                        }
                     }
                     if(_loc7_)
                     {
                        _loc10_.mp = _loc2_;
                        break;
                     }
               }
            }
            else
            {
               _loc7_ = true;
               _loc10_[_loc18_] = _loc13_;
            }
            if(_loc7_ == true)
            {
               _loc17_ = true;
            }
         }
         return _loc17_ ? _loc10_ : null;
      }
      
      private function onCreateAMasterpieceBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onWallMenuClose(param1);
         _masterpieceLaunchObj = {"typeDefId":51};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(_masterpieceLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([_masterpieceLaunchObj.typeDefId],false,onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(_masterpieceLaunchObj,null,true);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_masterpieceLaunchObj,null,true);
      }
      
      private function onChatTreeClose(param1:String, param2:String) : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
         _playerWall.messageTxtCont.txtColorCont.charCounter.visible = false;
         _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
         _playerWall.messageTxtCont.txtColorCont.messageTxt.text = param1;
         _msgCode = param2;
         _playerWall.postBtn.activateGrayState(false);
         _playerWall.replyBtn.activateGrayState(false);
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         onSendMessage();
         _playerWall.speedChatBtn.downToUpState();
         _playerWall.postBtn.activateGrayState(true);
         _playerWall.replyBtn.activateGrayState(true);
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
         updateCharCount();
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget == _playerWall.statusTxt)
         {
            _playerWall.statusTxt.setSelection(_playerWall.statusTxt.length,_playerWall.statusTxt.length);
            _playerWall.postStatusBtn.visible = true;
         }
         else
         {
            closeAllLowerPopups();
            if(!Utility.canChat())
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
               gMainFrame.stage.focus = null;
            }
            else if(!_playerWall.speedChatBtn.isGray && (gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3))
            {
               gMainFrame.stage.focus = null;
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded && !_hasShownDegradationPopup)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406),true,openSafeChatAfterOk);
               }
               else
               {
                  onSafeChatBtn(null);
               }
            }
            else if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 1)
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
               _predictiveTextManager.resetTreeSearch();
            }
         }
      }
      
      private function openSafeChatAfterOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _hasShownDegradationPopup = true;
         SBOkPopup.destroyInParentChain(param1.target.parent);
         onSafeChatBtn(null);
      }
      
      private function onTextOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         CursorManager.showICursor(true);
      }
      
      private function onTextOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         CursorManager.showICursor(false);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMessageTextDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_predictiveTextManager)
         {
            _predictiveTextManager.onTextClick();
         }
      }
      
      private function onClearPostsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            new SBOkCancelPopup(_guiLayer,LocalizationManager.translateIdOnly(24689),true,onConfirmClear);
         }
      }
      
      private function onConfirmClear(param1:Object) : void
      {
         if(param1.status)
         {
            _playerWall.contentLoader.visible = true;
            PlayerWallXtCommManager.sendClearAllMessages(null);
         }
      }
      
      private function onReplyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currReplyPost != null)
         {
            onSendMessage();
         }
      }
      
      private function onCancelBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _currReplyPost = null;
         _playerWall.replyBtn.visible = false;
         _playerWall.cancelBtn.visible = false;
         _playerWall.replyToTip.visible = false;
      }
      
      private function onNotificationsBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         param1.stopPropagation();
         _playerWall.wallNotificationCont.visible = !_playerWall.wallNotificationCont.visible;
         if(_playerWall.wallNotificationCont.visible)
         {
            if(_notificationWindows)
            {
               _playerWall.wallNotificationCont.itemWindow.removeChild(_notificationWindows);
               _notificationWindows.destroy();
            }
            _loc3_ = [];
            for each(var _loc5_ in _notifications)
            {
               _loc3_.push(_loc5_);
               if(!_loc5_.isRead)
               {
                  _loc2_++;
               }
            }
            _playerWall.notificationBtn.numIcon.countTxt.text = String(_loc2_);
            _playerWall.notificationBtn.numIcon.visible = _loc2_ > 0;
            _notificationWindows = new WindowAndScrollbarGenerator();
            _notificationWindows.init(_playerWall.wallNotificationCont.itemWindow.width,_playerWall.wallNotificationCont.itemWindow.height,0,0,1,6,0,0,2,0,0,ItemWindowNotification,_loc3_,"",0,{
               "mouseDown":onNotificationDown,
               "mouseOver":null,
               "mouseOut":null
            },null,null,true,false,false);
            _playerWall.wallNotificationCont.itemWindow.addChild(_notificationWindows);
         }
         else
         {
            if(_notificationWindows)
            {
               _playerWall.wallNotificationCont.itemWindow.removeChild(_notificationWindows);
               _notificationWindows.destroy();
               _notificationWindows = null;
            }
            if(_notifications)
            {
               _loc4_ = 0;
               while(_loc4_ < _notifications.length)
               {
                  if(!_notifications[_loc4_].isRead)
                  {
                     _loc2_++;
                  }
                  _loc4_++;
               }
            }
            _playerWall.notificationBtn.numIcon.countTxt.text = String(_loc2_);
            _playerWall.notificationBtn.numIcon.visible = _loc2_ > 0;
         }
      }
      
      private function onNotificationClose(param1:MouseEvent) : void
      {
         var _loc3_:ItemWindowNotification = null;
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         param1.stopPropagation();
         _playerWall.notificationBtn.downToUpState();
         _playerWall.wallNotificationCont.visible = false;
         if(_notificationWindows)
         {
            _loc2_ = [];
            _loc4_ = 0;
            while(_loc4_ < _notificationWindows.mediaWindows.length)
            {
               _loc3_ = _notificationWindows.mediaWindows[_loc4_];
               if(_loc3_ && !_loc3_.isRead)
               {
                  _loc2_.push(_loc3_.parentOrCurrMessageId);
               }
               _loc4_++;
            }
            if(_loc2_.length > 0)
            {
               PlayerWallXtCommManager.sendAcknowledgeNotificationRequest(_loc2_,null);
            }
            _playerWall.wallNotificationCont.itemWindow.removeChild(_notificationWindows);
            _notificationWindows.destroy();
            _notificationWindows = null;
         }
      }
      
      private function onPhotoCont(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openPhotoBooth(onPhotoBoothSave,true);
      }
      
      private function onPhotoBoothSave(param1:int, param2:int, param3:int) : void
      {
         var _loc10_:Avatar = null;
         var _loc13_:AvatarInfo = null;
         var _loc8_:Object = null;
         var _loc12_:Array = null;
         var _loc14_:Object = null;
         var _loc11_:AccItemCollection = null;
         var _loc5_:int = 0;
         var _loc9_:Object = null;
         var _loc4_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:Object = null;
         if(param3 != -1)
         {
            _loc10_ = AvatarManager.playerAvatar;
            _loc13_ = gMainFrame.userInfo.playerAvatarInfo;
            _loc8_ = {
               "color1":_loc13_.colors[0],
               "color2":_loc13_.colors[1],
               "color3":_loc13_.colors[2],
               "pattern":_loc10_.inUsePatternId,
               "id":_loc10_.avTypeId,
               "eyes":_loc10_.inUseEyeId
            };
            _loc12_ = null;
            _loc14_ = null;
            _loc11_ = _loc10_.accShownItemsWithoutBodMods;
            if(_loc11_.length > 0)
            {
               _loc12_ = [];
               _loc5_ = 0;
               while(_loc5_ < _loc11_.length)
               {
                  _loc12_.push({
                     "id":_loc11_.getAccItem(_loc5_).defId,
                     "color":_loc11_.getAccItem(_loc5_).color
                  });
                  _loc5_++;
               }
            }
            if(PetManager.myActivePet != null)
            {
               _loc9_ = PetManager.myActivePet;
               _loc14_ = {
                  "ts":_loc9_.createdTs,
                  "lbits":_loc9_.lBits,
                  "ubits":_loc9_.uBits,
                  "ebits":_loc9_.eBits,
                  "id":_loc9_.defId,
                  "flip":param2
               };
            }
            _loc4_ = false;
            if(_wallParameters.pb)
            {
               if(_wallParameters.pb.avatar == null)
               {
                  _loc4_ = true;
               }
               else if(_wallParameters.pb.avatar.flip == null || param1 != _wallParameters.pb.avatar.flip || (_wallParameters.pb.bgid == null || param3 != _wallParameters.pb.bgid))
               {
                  _loc4_ = true;
               }
               else if(_loc8_.color1 != _wallParameters.pb.avatar.color1 || _loc8_.color2 != _wallParameters.pb.avatar.color2 || _loc8_.color3 != _wallParameters.pb.avatar.color3 || _loc8_.pattern != _wallParameters.pb.avatar.pattern || _loc8_.id != _wallParameters.pb.avatar.id || _loc8_.eyes != _wallParameters.pb.avatar.eyes)
               {
                  _loc4_ = true;
               }
               else if(_loc12_ == null && _wallParameters.pb.items != null || _loc12_ != null && _wallParameters.pb.items == null || _loc12_ != null && _wallParameters.pb.items != null && _loc12_.length != _wallParameters.pb.items.length)
               {
                  _loc4_ = true;
               }
               else if(_loc12_ != null)
               {
                  _loc6_ = 0;
                  while(_loc6_ < _loc12_.length)
                  {
                     if(_loc12_[_loc6_].id != _wallParameters.pb.items[_loc6_].id || _loc12_[_loc6_].color != _wallParameters.pb.items[_loc6_].color)
                     {
                        _loc4_ = true;
                        break;
                     }
                     _loc6_++;
                  }
               }
               if(_loc4_ == false)
               {
                  if(_loc14_ == null && _wallParameters.pb.pet != null || _loc14_ != null && _wallParameters.pb.pet == null)
                  {
                     _loc4_ = true;
                  }
                  else if(_loc14_.lbits != _wallParameters.pb.pet.lbits || _loc14_.ubits != _wallParameters.pb.pet.ubits || _loc14_.ebits != _wallParameters.pb.pet.ebits || _loc14_.id != _wallParameters.pb.pet.id || (_wallParameters.pb.pet.flip == null || param2 != _wallParameters.pb.pet.flip))
                  {
                     _loc4_ = true;
                  }
               }
            }
            else
            {
               _loc4_ = true;
            }
            if(_loc4_)
            {
               _wallParameters.pb = {};
               _wallParameters.pb.avatar = {
                  "color1":_loc13_.colors[0],
                  "color2":_loc13_.colors[1],
                  "color3":_loc13_.colors[2],
                  "pattern":_loc10_.inUsePatternId,
                  "id":_loc10_.avTypeId,
                  "eyes":_loc10_.inUseEyeId,
                  "flip":param1
               };
               _wallParameters.pb.items = _loc12_;
               if(_loc14_ != null)
               {
                  _wallParameters.pb.pet = _loc14_;
               }
               _wallParameters.pb.bgid = param3;
               _loc7_ = checkForWallParameterChanges();
               if(_loc7_ != null)
               {
                  PlayerWallXtCommManager.sendSetWallParametersRequest(_wallParameters,_loc7_,onPhotoSave);
               }
            }
         }
      }
      
      private function onPostStatus(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_inputPopup == null)
         {
            _inputPopup = new InputPopup(onInputPopupClose);
         }
      }
      
      private function onInputPopupClose(param1:String) : void
      {
         var _loc2_:Object = null;
         if(param1 != null && param1.length > 0)
         {
            if(_wallParameters.tag == null || _wallParameters.tag != param1)
            {
               _wallParameters.tag = param1;
               _wallParameters.langId = LocalizationManager.currentLanguage;
               _loc2_ = checkForWallParameterChanges();
               if(_loc2_ != null)
               {
                  PlayerWallXtCommManager.sendSetWallParametersRequest(_wallParameters,_loc2_,onSetStatusResponse);
               }
            }
         }
         _inputPopup.destroy();
         _inputPopup = null;
      }
      
      private function onLikeBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.loadingCont.visible)
         {
            if(param1.currentTarget.down)
            {
               param1.currentTarget.downToUpState();
               param1.currentTarget.activateLoadingState(true);
               ResourceArrayXtCommManager.sendResourceArrayPutRequest("jammerwall",_ownerUUID,"",0,0,"",onResourceArrayPut);
            }
         }
      }
      
      private function onNotificationDown(param1:MouseEvent) : void
      {
         var _loc2_:ItemWindowNotification = ItemWindowNotification(param1.currentTarget);
         if(_loc2_ != null)
         {
            _isWallActive = false;
            DarkenManager.showLoadingSpiral(true);
            PlayerWallManager.openStrangersPlayerWall(_loc2_.senderUserName,_loc2_.moderatedUsername,_loc2_.senderUUID,_loc2_.messageId,true);
         }
      }
      
      private function onResourceArrayPut(param1:Boolean, param2:Object) : void
      {
         _playerWall.likeBtn.activateLoadingState(false);
         if(param1)
         {
            _playerWall.likeBtn.upToDownState();
            _playerWall.likeBtn.removeEventListener("mouseDown",onLikeBtn);
            _playerWall.likeBtn.mouseChildren = false;
            _playerWall.likeBtn.mouseEnabled = false;
            if("likeCount" in _playerWall)
            {
               _playerWall.likeCount++;
            }
            else
            {
               _playerWall.likeCount = 1;
            }
            _playerWall.likeBtn.setTextInLayer(Utility.convertNumberToString(_playerWall.likeCount),"numTxt");
         }
      }
      
      private function onPostStatusOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_isMyWall && _currWallDecor)
         {
            _currWallDecor.postStatus.mouse.mouse.reportBtn.visible = false;
         }
      }
      
      private function onPostStatusOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_isMyWall && _currWallDecor)
         {
            _currWallDecor.postStatus.mouse.mouse.reportBtn.visible = true;
         }
      }
      
      private function addEventListeners() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         if(_playerWall)
         {
            _playerWall.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
            _playerWall.patternBtn.addEventListener("mouseDown",onPatternBtn,false,0,true);
            _playerWall.colorBtn.addEventListener("mouseDown",onColorBtn,false,0,true);
            _playerWall.emoteBtn.addEventListener("mouseDown",onEmoteBtn,false,0,true);
            _playerWall.postBtn.addEventListener("mouseDown",onPostBtn,false,0,true);
            _playerWall.settingsBtn.addEventListener("mouseDown",onSettingsBtn,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseDown",onMessageTextDown,false,0,true);
            _playerWall.speedChatBtn.addEventListener("mouseDown",onSafeChatBtn,false,0,true);
            _playerWall.menuBtn.addEventListener("mouseDown",onMenuBtn,false,0,true);
            _playerWall.ansBtnCont.addEventListener("mouseDown",onSuggestWordsBtn,false,0,true);
            _playerWall.cleanUpBtn.addEventListener("mouseDown",onClearPostsBtn,false,0,true);
            _playerWall.replyBtn.addEventListener("mouseDown",onReplyBtn,false,0,true);
            _playerWall.cancelBtn.addEventListener("mouseDown",onCancelBtn,false,0,true);
            _playerWall.notificationBtn.addEventListener("mouseDown",onNotificationsBtn,false,0,true);
            _playerWall.likeBtn.addEventListener("mouseDown",onLikeBtn,false,0,true);
            _updateTimer.addEventListener("timer",onTimerEvent,false,0,true);
            if(!_canWrite)
            {
               _playerWall.messageEntryHolder.addEventListener("mouseDown",onMessageEntry,false,0,true);
            }
            _loc2_ = _playerWall.frame_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.addEventListener("mouseDown",onMasterpieceFrameDown,false,0,true);
               _loc2_.addEventListener("mouseOver",onMasterpieceOrStickerFrameOver,false,0,true);
               _loc2_.addEventListener("mouseOut",onMasterpieceOrStickerFrameOut,false,0,true);
               _loc2_.glow.visible = false;
               _loc1_++;
               _loc2_ = _playerWall["frame_" + _loc1_];
            }
            _loc2_ = _playerWall.sticker_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.addEventListener("mouseDown",onStickerFrameDown,false,0,true);
               _loc2_.addEventListener("mouseOver",onMasterpieceOrStickerFrameOver,false,0,true);
               _loc2_.addEventListener("mouseOut",onMasterpieceOrStickerFrameOut,false,0,true);
               _loc2_.glow.visible = false;
               _loc1_++;
               _loc2_ = _playerWall["sticker_" + _loc1_];
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         if(_playerWall)
         {
            _playerWall.removeEventListener("mouseDown",onPopup);
            _playerWall.bx.removeEventListener("mouseDown",onCloseBtn);
            _playerWall.patternBtn.removeEventListener("mouseDown",onPatternBtn);
            _playerWall.colorBtn.removeEventListener("mouseDown",onColorBtn);
            _playerWall.emoteBtn.removeEventListener("mouseDown",onEmoteBtn);
            _playerWall.postBtn.removeEventListener("mouseDown",onPostBtn);
            _playerWall.settingsBtn.removeEventListener("mouseDown",onSettingsBtn);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseDown",onMessageTextDown);
            _playerWall.speedChatBtn.removeEventListener("mouseDown",onSafeChatBtn);
            _playerWall.menuBtn.removeEventListener("mouseDown",onMenuBtn);
            _playerWall.ansBtnCont.removeEventListener("mouseDown",onSuggestWordsBtn);
            _playerWall.cleanUpBtn.removeEventListener("mouseDown",onClearPostsBtn);
            _playerWall.replyBtn.removeEventListener("mouseDown",onReplyBtn);
            _playerWall.cancelBtn.removeEventListener("mouseDown",onCancelBtn);
            _playerWall.notificationBtn.removeEventListener("mouseDown",onNotificationsBtn);
            _playerWall.likeBtn.removeEventListener("mouseDown",onLikeBtn);
            _updateTimer.removeEventListener("timer",onTimerEvent);
            if(!_canWrite)
            {
               _playerWall.messageEntryHolder.removeEventListener("mouseDown",onMessageEntry);
            }
            _loc2_ = _playerWall.frame_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.removeEventListener("mouseDown",onStickerFrameDown);
               _loc2_.removeEventListener("mouseOver",onMasterpieceOrStickerFrameOver);
               _loc2_.removeEventListener("mouseOut",onMasterpieceOrStickerFrameOut);
               _loc1_++;
               _loc2_ = _playerWall["frame_" + _loc1_];
            }
            _loc2_ = _playerWall.sticker_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.removeEventListener("mouseDown",onMasterpieceFrameDown);
               _loc2_.removeEventListener("mouseOver",onMasterpieceOrStickerFrameOver);
               _loc2_.removeEventListener("mouseOut",onMasterpieceOrStickerFrameOut);
               _loc1_++;
               _loc2_ = _playerWall["sticker_" + _loc1_];
            }
         }
      }
   }
}

