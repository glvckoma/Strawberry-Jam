package gui
{
   import Enums.TradeItem;
   import Party.PartyManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarEditorView;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarXtCommManager;
   import avatar.CustomAvatarDef;
   import avatar.NameBar;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.PetItemCollection;
   import collection.TradeItemCollection;
   import com.greensock.TimelineLite;
   import com.greensock.easing.SlowMo;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenMannequinInventory;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import gui.itemWindows.ItemWindowNameBarIcon;
   import gui.itemWindows.ItemWindowOriginal;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import quest.QuestManager;
   import shop.Shop;
   import shop.ShopManager;
   import shop.ShopWithPreview;
   
   public class AvatarEditor
   {
      public static const COLOR_TAB_ID:int = 0;
      
      public static const PATTERN_TAB_ID:int = 1;
      
      public static const EYE_TAB_ID:int = 2;
      
      private static var _mainScrollYPosition:Number = 0;
      
      private static var _tradeListViewType:int = 1;
      
      private const CLOTHING_VIEW_TYPE:int = 0;
      
      private const DEN_VIEW_TYPE:int = 1;
      
      private const CT_WIDTH:int = 240;
      
      private const CT_HEIGHT:int = 150;
      
      private const CT_NUM_COLS:int = 10;
      
      private const CT_NUM_ROWS:int = 5;
      
      private const CT_Y_TOP:int = 12;
      
      private const CT_Y_BOT:int = 176;
      
      private const CT_X:int = 21;
      
      private const CT_ID_C1:int = 0;
      
      private const CT_ID_C2:int = 1;
      
      private const CT_ID_EYES:int = 2;
      
      private const CT_ID_PATT:int = 3;
      
      private const CT_SECRET_COLOR:int = 102;
      
      private const NUM_X_WIN:int = 3;
      
      private const NUM_Y_WIN:int = 4;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const Y_WIN_START:Number = 0;
      
      private const SCROLLBAR_GAP:int = 3;
      
      private const AVEDITOR_MEDIA_ID:int = 1352;
      
      public var avEditor:MovieClip;
      
      public var xBtn:MovieClip;
      
      public var block:Sprite;
      
      private var _guiLayer:DisplayLayer;
      
      private var _isFFM:Boolean;
      
      private var _worldAvatar:Avatar;
      
      private var _avatarEditorView:AvatarEditorView;
      
      private var _itemIdsOn:IntItemCollection;
      
      private var _itemIdsOff:IntItemCollection;
      
      private var _tradeItemsIn:TradeItemCollection;
      
      private var _tradeItemsOut:TradeItemCollection;
      
      private var _currClothesArray:AccItemCollection;
      
      private var _patterns:AccItemCollection;
      
      private var _eyes:AccItemCollection;
      
      private var _headItems:AccItemCollection;
      
      private var _neckItems:AccItemCollection;
      
      private var _backItems:AccItemCollection;
      
      private var _legItems:AccItemCollection;
      
      private var _tailItems:AccItemCollection;
      
      private var _itemTypeItems:AccItemCollection;
      
      private var _allNewestClothes:AccItemCollection;
      
      private var _allOldestClothes:AccItemCollection;
      
      private var _fullHeadItems:AccItemCollection;
      
      private var _fullNeckItems:AccItemCollection;
      
      private var _fullBackItems:AccItemCollection;
      
      private var _fullLegItems:AccItemCollection;
      
      private var _fullTailItems:AccItemCollection;
      
      private var _fullItemTypeItems:AccItemCollection;
      
      private var _fullallNewestClothes:AccItemCollection;
      
      private var _fullAllOldestClothes:AccItemCollection;
      
      private var _currDenItemsArray:DenItemCollection;
      
      private var _currTradesArray:TradeItemCollection;
      
      private var _floorItems:DenItemCollection;
      
      private var _themeItems:DenItemCollection;
      
      private var _itemTypeDenItems:DenItemCollection;
      
      private var _allOldestDenItems:DenItemCollection;
      
      private var _allNewestDenItems:DenItemCollection;
      
      private var _fullClothesList:AccItemCollection;
      
      private var _petsList:PetItemCollection;
      
      private var _currPattern:int;
      
      private var _currEye:int;
      
      private var _currentTab:int;
      
      private var _recycle:RecycleItems;
      
      private var _eyePattWindow:MovieClip;
      
      private var _lArrowBtn:MovieClip;
      
      private var _rArrowBtn:MovieClip;
      
      private var _onCloseCallback:Function;
      
      private var _waitForApResponse:Boolean;
      
      private var _waitForIuResponse:Boolean;
      
      private var _sendDelayedTradeRequest:Boolean;
      
      private var _gamePalette:Array;
      
      private var _avatarPalette1:Array;
      
      private var _avatarPalette2:Array;
      
      private var _colorTableColor1:ColorTable;
      
      private var _colorTableColor2:ColorTable;
      
      private var _colorTablePatterns:ColorTable;
      
      private var _colorTableEyes:ColorTable;
      
      private var _customAvtIcon:MovieClip;
      
      private var _cellWidth:Number;
      
      private var _cellHeight:Number;
      
      private var _numXColors:int;
      
      private var _numYColors:int;
      
      private var _currCustomPatternColorIdx:int;
      
      private var _tabOpenId:int;
      
      private var _itemClothingWindows:WindowAndScrollbarGenerator;
      
      private var _itemTradeWindows:WindowAndScrollbarGenerator;
      
      public var numClothingItemsInTradeListInitially:int;
      
      public var numDenItemsInTradeListInitially:int;
      
      public var numPetItemsInTradeListInitially:int;
      
      private var _nameBars:Array;
      
      private var _nameBarData:int;
      
      private var _userInfo:UserInfo;
      
      private var _nameBarItemWindows:WindowAndScrollbarGenerator;
      
      private var _nameBarItemWinHeight:int;
      
      private var _namebarBadgeDefs:Array;
      
      private var _namebarBadgeMediaIds:Array;
      
      private var _namebarBadgeImages:Array;
      
      private var _shop:Shop;
      
      private var _spirals:Array;
      
      private var _petInventory:PetInventory;
      
      private var _myPet:GuiPet;
      
      private var _openCheckListImmediately:Boolean;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _attackBase:int;
      
      private var _achievementViewer:AchievementViewer;
      
      private var _gemTimeline:TimelineLite;
      
      private var _tradeItemSelect:DenAndClothesItemSelect;
      
      private var _isForMannequin:Boolean;
      
      private var _mannequinDenItemHelper:DenItemHelper;
      
      public function AvatarEditor()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:Function = null, param4:Boolean = false, param5:Boolean = false, param6:DenItemHelper = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _worldAvatar = param1;
         _onCloseCallback = param3;
         _guiLayer = param2;
         _isFFM = param4;
         _openCheckListImmediately = param5;
         _mannequinDenItemHelper = param6;
         _isForMannequin = param6 != null;
         _avatarEditorView = new AvatarEditorView();
         _avatarEditorView.init(_worldAvatar);
         _gamePalette = PaletteHelper.gamePalette;
         _avatarPalette1 = PaletteHelper.avatarPalette1;
         _avatarPalette2 = PaletteHelper.avatarPalette2;
         _patterns = new AccItemCollection();
         _eyes = new AccItemCollection();
         _tabOpenId = 0;
         _spirals = [];
         _currClothesArray = _allNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,_avatarEditorView.inventoryClothingItems);
         _headItems = Utility.sortItemsAll(_currClothesArray,8,9,10,_worldAvatar.roomType) as AccItemCollection;
         _neckItems = Utility.sortItemsAll(_currClothesArray,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
         _backItems = Utility.sortItemsAll(_currClothesArray,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
         _legItems = Utility.sortItemsAll(_currClothesArray,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
         _tailItems = Utility.sortItemsAll(_currClothesArray,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
         _itemTypeItems = Utility.sortByItem(_currClothesArray,_worldAvatar.roomType) as AccItemCollection;
         _allOldestClothes = new AccItemCollection(_allNewestClothes.getCoreArray().concat().reverse());
         if(_currClothesArray)
         {
            _currClothesArray = _allNewestClothes;
         }
         _fullClothesList = _fullallNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,gMainFrame.userInfo.playerAvatarInfo.getFullItems());
         if(_fullClothesList)
         {
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullItemTypeItems = Utility.sortByItem(_fullClothesList,_worldAvatar.roomType) as AccItemCollection;
            _fullAllOldestClothes = new AccItemCollection(_fullallNewestClothes.getCoreArray().concat().reverse());
         }
         if(param1.inventoryDenFull.denItemCollection)
         {
            _currDenItemsArray = _allNewestDenItems = Utility.discardDefaultAudioItem(param1.inventoryDenFull.denItemCollection);
            _floorItems = Utility.sortItems(_currDenItemsArray,0,1) as DenItemCollection;
            _themeItems = Utility.sortItems(_currDenItemsArray,2,3) as DenItemCollection;
            _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray) as DenItemCollection;
            _allOldestDenItems = new DenItemCollection();
            _allOldestDenItems.setCoreArray(_allNewestDenItems.getCoreArray().concat().reverse());
         }
         if(!_isForMannequin)
         {
            _currTradesArray = new TradeItemCollection();
            _currTradesArray.setCoreArray(gMainFrame.userInfo.getMyTradeList().concatCollection(null));
            _petsList = PetManager.myPetListAsIitem;
            numClothingItemsInTradeListInitially = TradeManager.numClothingItemsInMyTradeList;
            numDenItemsInTradeListInitially = TradeManager.numDenItemsInMyTradeList;
            numPetItemsInTradeListInitially = TradeManager.numPetItemsInMyTradeList;
         }
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1352,onMediaItemLoaded,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:* = null;
         DarkenManager.showLoadingSpiral(false);
         KeepAlive.stopKATimer(avEditor);
         removeListeners();
         if(avEditor.tradeBtnUp && avEditor.tradeBtnUp.visible)
         {
            if(_itemTradeWindows)
            {
               _mainScrollYPosition = _itemTradeWindows.scrollYValue;
            }
            else if(_itemClothingWindows)
            {
               _mainScrollYPosition = _itemClothingWindows.scrollYValue;
            }
         }
         if(_tradeItemSelect)
         {
            _tradeItemSelect.destroy();
            _tradeItemSelect = null;
         }
         if(_itemClothingWindows)
         {
            _itemClothingWindows.destroy();
            _itemClothingWindows = null;
         }
         if(_itemTradeWindows)
         {
            _itemTradeWindows.destroy();
            _itemTradeWindows = null;
         }
         if(_avatarEditorView)
         {
            avEditor.charBox.removeChild(_avatarEditorView);
            _avatarEditorView.destroy();
            _avatarEditorView = null;
            _itemIdsOn = null;
            _itemIdsOff = null;
            _tradeItemsIn = null;
            _tradeItemsOut = null;
            _patterns = null;
            _eyes = null;
            _avatarPalette1 = null;
            _avatarPalette2 = null;
         }
         if(_myPet)
         {
            _myPet.destroy();
            _myPet = null;
         }
         _colorTableColor1.destroy();
         _colorTableColor2.destroy();
         _colorTablePatterns.destroy();
         _colorTableEyes.destroy();
         _namebarBadgeMediaIds = null;
         _nameBars = null;
         _userInfo = null;
         _namebarBadgeImages = null;
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(_achievementViewer)
         {
            _achievementViewer.destroy();
            _achievementViewer = null;
         }
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
         if(_petInventory)
         {
            _petInventory.destroy();
            _petInventory = null;
         }
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         _currClothesArray = null;
         _headItems = null;
         _neckItems = null;
         _backItems = null;
         _legItems = null;
         _tailItems = null;
         _itemTypeItems = null;
         _allOldestClothes = null;
         _fullHeadItems = null;
         _fullNeckItems = null;
         _fullBackItems = null;
         _fullLegItems = null;
         _fullTailItems = null;
         _fullItemTypeItems = null;
         _fullAllOldestClothes = null;
         _currDenItemsArray = null;
         _floorItems = null;
         _themeItems = null;
         _itemTypeDenItems = null;
         _allOldestDenItems = null;
         _currTradesArray = null;
         _onCloseCallback = null;
         if(_spirals && _spirals.length > 0)
         {
            for each(_loc1_ in _spirals)
            {
               _loc1_.destroy();
            }
         }
         _spirals = null;
         AvatarManager.showAvtAndChatLayers(true);
         DarkenManager.unDarken(avEditor);
         _guiLayer.removeChild(avEditor);
      }
      
      public function get onCloseCallback() : Function
      {
         return _onCloseCallback;
      }
      
      public function set onCloseCallback(param1:Function) : void
      {
         _onCloseCallback = param1;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            avEditor = MovieClip(param1.getChildAt(0));
            if(_isForMannequin)
            {
               avEditor.gotoAndStop(2);
            }
            xBtn = avEditor.bx;
            avEditor.x = 900 * 0.5;
            avEditor.y = 550 * 0.5;
            if(!_isForMannequin)
            {
               block = avEditor.block;
               block.visible = _isFFM;
               _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName);
               _namebarBadgeImages = [];
               _nameBars = new Array("goldBtn","blackBtn","blueBtn","brownBtn","greenBtn","pinkBtn","purpleBtn","redBtn","tealBtn","whiteBtn");
               _nameBarData = gMainFrame.userInfo.playerUserInfo.nameBarData;
               _nameBarItemWinHeight = avEditor.namebarPopup.itemWindow.height;
            }
            _itemIdsOn = new IntItemCollection();
            _itemIdsOff = new IntItemCollection();
            _tradeItemsIn = new TradeItemCollection();
            _tradeItemsOut = new TradeItemCollection();
            setInitAssetVisibility();
            positionAndDrawAvatarView();
            createPatternsAndEyesArrays();
            _waitForApResponse = false;
            _waitForIuResponse = false;
            if(_currClothesArray)
            {
               createItemWindows(_currClothesArray,avEditor.itemBlock);
            }
            addListeners();
            KeepAlive.startKATimer(avEditor);
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
            DarkenManager.showLoadingSpiral(false);
            _guiLayer.addChild(avEditor);
            DarkenManager.darken(avEditor);
            QuestManager.avatarEditorInitComplete();
            AvatarManager.showAvtAndChatLayers(false);
            if(_openCheckListImmediately)
            {
               onPetBtnHandler(null);
            }
         }
      }
      
      public function get colorTableColor1() : ColorTable
      {
         return _colorTableColor1;
      }
      
      public function get colorTableColor2() : ColorTable
      {
         return _colorTableColor2;
      }
      
      public function get colorTablePatterns() : ColorTable
      {
         return _colorTablePatterns;
      }
      
      public function get colorTableEyes() : ColorTable
      {
         return _colorTableEyes;
      }
      
      public function get arrowBtnR() : MovieClip
      {
         return _rArrowBtn;
      }
      
      public function get arrowBtnL() : MovieClip
      {
         return _lArrowBtn;
      }
      
      private function setInitAssetVisibility() : void
      {
         var _loc1_:String = null;
         var _loc12_:int = 0;
         var _loc6_:UserInfo = null;
         var _loc9_:int = 0;
         var _loc7_:AvatarInfo = null;
         var _loc11_:Boolean = false;
         var _loc3_:String = null;
         var _loc2_:Array = _avatarEditorView.colors;
         var _loc4_:* = _loc2_[0] >> 24 & 0xFF;
         var _loc10_:* = _loc2_[0] >> 16 & 0xFF;
         var _loc8_:* = _loc2_[1] >> 24 & 0xFF;
         var _loc5_:* = _loc2_[2] >> 24 & 0xFF;
         _colorTableColor1 = new ColorTable();
         _colorTableColor1.init(0,240,150,10,5,_gamePalette,_avatarPalette1,_loc4_,onColorChanged,102);
         _colorTableColor2 = new ColorTable();
         _colorTableColor2.init(1,240,150,10,5,_gamePalette,_avatarPalette2,_loc10_,onColorChanged,102);
         _colorTablePatterns = new ColorTable();
         _colorTablePatterns.init(3,240,150,10,5,_gamePalette,_avatarPalette1,_loc8_,onColorChanged,102);
         _colorTableEyes = new ColorTable();
         _colorTableEyes.init(2,240,150,10,5,_gamePalette,_avatarPalette1,_loc5_,onColorChanged,102);
         _colorTableColor1.x = 21;
         _colorTableColor1.y = 12;
         _colorTableColor2.x = 21;
         _colorTableColor2.y = 176;
         _colorTablePatterns.x = 21;
         _colorTablePatterns.y = 176;
         _colorTableEyes.x = 21;
         _colorTableEyes.y = 176;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
         avEditor.colorTableBlock.colors.addChild(_colorTableColor1);
         avEditor.colorTableBlock.colors.addChild(_colorTableColor2);
         _eyePattWindow = avEditor.colorTableBlock.patternsAndEyes.previewWin;
         _lArrowBtn = avEditor.colorTableBlock.patternsAndEyes.arrowBtnL;
         _rArrowBtn = avEditor.colorTableBlock.patternsAndEyes.arrowBtnR;
         avEditor.patternTabUp.visible = false;
         avEditor.eyesTabUp.visible = false;
         avEditor.sortPopup.visible = false;
         if(!_isForMannequin)
         {
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = !!_fullClothesList ? true : false;
            avEditor.blackout.visible = false;
            avEditor.blackoutFull.visible = false;
            avEditor.tradeHelpPopup.visible = false;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            avEditor.block.visible = false;
            avEditor.namebarPopup.visible = false;
            _loc1_ = "gem";
            if(UserCurrency.getCurrency(1) > 0)
            {
               _loc1_ += "Tic";
            }
            if(UserCurrency.getCurrency(3) > 0)
            {
               _loc1_ += "Dia";
            }
            avEditor.money.gotoAndStop(_loc1_);
            avEditor.money.mouse.gems.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
            _loc12_ = 1;
            _gemTimeline = new TimelineLite();
            _gemTimeline.paused(true);
            _gemTimeline.to(avEditor.money.mouse.bg,0.1,{
               "scaleY":1,
               "alpha":0.3,
               "ease":SlowMo.ease
            },0);
            if(avEditor.money.mouse.tickets)
            {
               avEditor.money.mouse.tickets.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(1));
               _gemTimeline.to(avEditor.money.mouse.tickets,0.1,{
                  "y":"+=" + 40 * _loc12_,
                  "scaleX":1,
                  "scaleY":1,
                  "alpha":1,
                  "ease":SlowMo.ease
               },0);
               _loc12_++;
            }
            if(avEditor.money.mouse.diamonds)
            {
               avEditor.money.mouse.diamonds.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
               _gemTimeline.to(avEditor.money.mouse.diamonds,0.1,{
                  "y":"+=" + 40 * _loc12_,
                  "scaleX":1,
                  "scaleY":1,
                  "alpha":1,
                  "ease":SlowMo.ease
               },0);
            }
            _achievementViewer = new AchievementViewer();
            _achievementViewer.loadMedia(287,avEditor);
            if(_allNewestClothes.length <= 0)
            {
               avEditor.sortBtn.visible = false;
               avEditor.sortPopup.visible = false;
            }
            if(gMainFrame.clientInfo.roomType == 7 && !QuestManager.isQuestLikeNormalRoom() || PartyManager.isPetSpecificRequiredParty())
            {
               avEditor.petsBtn.activateGrayState(true);
            }
            else
            {
               loadPetView();
            }
            _loc6_ = gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName);
            _loc9_ = 0;
            while(_loc9_ < _nameBars.length)
            {
               LocalizationManager.updateToFit(avEditor.namebarPopup[_nameBars[_loc9_]].c.dark.txt,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE) && _loc6_ ? _loc6_.getModeratedUserName() : _worldAvatar.avName,false,false,false);
               avEditor.namebarPopup[_nameBars[_loc9_]].id = _loc9_;
               _loc9_++;
            }
            if(!gMainFrame.userInfo.isMember)
            {
               avEditor.nonmember.visible = true;
               avEditor.member.visible = false;
               LocalizationManager.updateToFit(avEditor.nonmember.c.txt,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE) && _loc6_ ? _loc6_.getModeratedUserName() : _worldAvatar.avName,false,false,false);
            }
            else
            {
               avEditor.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
               avEditor.member.xpShapeIcons = AvatarManager.playerAvatarWorldView.xpShapeIcons;
               avEditor.nonmember.visible = false;
               avEditor.member.visible = true;
               avEditor.member.setNubType(NameBar.BUDDY,false);
               avEditor.member.isBlocked = false;
               _loc7_ = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
               if(!_worldAvatar.isShaman && !_userInfo.isGuide)
               {
                  avEditor.member.setColorBadgeAndXp(_nameBarData,_loc7_.questLevel,_loc7_.isMember);
               }
               else
               {
                  avEditor.member.setColorBadgeAndXp(0,0,false);
               }
               avEditor.member.setAvName(_worldAvatar.avName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc6_,false);
               _loc11_ = (_nameBarData >> 16 & 0x0F) == 0 && _loc7_.isMember || (gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8) && !QuestManager.isQuestLikeNormalRoom();
               if(_loc11_)
               {
                  avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOn");
               }
               else
               {
                  avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOff");
                  avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
               }
               if(_loc7_.questLevel > 0)
               {
                  _loc3_ = avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
                  avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(_loc3_);
                  Utility.createXpShape(_loc7_.questLevel,_loc7_.isMember,avEditor.namebarPopup.advLockToggle.toggleBtn.shape[_loc3_].mouse.up.icon,null,2147483647);
               }
            }
            if(_isFFM)
            {
               if(avEditor.petsBtn.hasGrayState)
               {
                  avEditor.petsBtn.activateGrayState(true);
               }
               if(avEditor.shopBtn.hasGrayState)
               {
                  avEditor.shopBtn.activateGrayState(true);
               }
               if(avEditor.recycleClothesBtn.hasGrayState)
               {
                  avEditor.recycleClothesBtn.activateGrayState(true);
               }
               if(avEditor.tradeBtnDown.hasGrayState)
               {
                  avEditor.tradeBtnDown.activateGrayState(true);
               }
               avEditor.block.visible = true;
            }
            else
            {
               avEditor.fiveMinCursor.visible = false;
            }
            avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + ShopManager.maxItems;
         }
         else
         {
            LocalizationManager.updateToFit(avEditor.titleTxt,DenXtCommManager.getDenItemDef(_mannequinDenItemHelper.defId).name);
         }
         avEditor.searchBar.mouse.searchTxt.visible = false;
         avEditor.searchBar.shortTextWidth = avEditor.searchBar.mouse.txt.width + 10;
         avEditor.searchBar.wideTextWidth = avEditor.searchBar.mouse.searchTxt.width + 10;
         avEditor.searchBar.mouse.b.xBtn.visible = false;
         avEditor.sortPopup.sort1.activateSpecifiedItem(true,"time","sort1Dn");
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(_avatarEditorView && _avatarEditorView.parent)
            {
               avEditor.charBox.removeChild(_avatarEditorView);
            }
            _avatarEditorView = new AvatarEditorView();
            _avatarEditorView.init(_worldAvatar);
         }
         var _loc2_:Point = AvatarUtility.getAvatarViewPosition(_avatarEditorView.avTypeId);
         _avatarEditorView.x = _loc2_.x;
         _avatarEditorView.y = _loc2_.y;
         if(_isForMannequin)
         {
            avEditor.charBox.gotoAndStop(4);
         }
         else if(Utility.isOcean(_worldAvatar.enviroTypeFlag))
         {
            if(Utility.isLand(_worldAvatar.enviroTypeFlag))
            {
               avEditor.charBox.gotoAndStop(3);
            }
            else
            {
               avEditor.charBox.gotoAndStop(2);
            }
         }
         avEditor.charBox.addChild(_avatarEditorView);
         _avatarEditorView.playAnim(13,false,1);
      }
      
      private function colorCurrEyePattIcon() : void
      {
         var _loc1_:LayerBitmap = null;
         if(_tabOpenId == 1)
         {
            if(_patterns && _patterns.length > 0 && _patterns.getAccItem(_currPattern))
            {
               if(_patterns.getAccItem(_currPattern).icon.numChildren > 0)
               {
                  _loc1_ = _patterns.getAccItem(_currPattern).icon.getChildAt(0) as LayerBitmap;
                  _loc1_.setLayerColor(2,_avatarEditorView.colors[1]);
                  _loc1_.paint(0);
               }
               else
               {
                  _patterns.getAccItem(_currPattern).setIconColor(2,_avatarEditorView.colors[1]);
               }
            }
         }
         else if(_tabOpenId == 2)
         {
            if(_eyes && _eyes.length > 0 && _eyes.getAccItem(_currEye))
            {
               if(_eyes.getAccItem(_currEye).icon.numChildren > 0)
               {
                  _loc1_ = _eyes.getAccItem(_currEye).icon.getChildAt(0) as LayerBitmap;
                  _loc1_.setLayerColor(3,_avatarEditorView.colors[2]);
                  _loc1_.paint(0);
               }
               else
               {
                  _eyes.getAccItem(_currEye).setIconColor(3,_avatarEditorView.colors[2]);
               }
            }
         }
      }
      
      private function onColorChanged(param1:int, param2:int) : void
      {
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc14_:* = 0;
         var _loc16_:* = 0;
         var _loc5_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:* = 0;
         var _loc3_:* = 0;
         var _loc13_:* = 0;
         var _loc12_:* = 0;
         var _loc11_:* = 0;
         var _loc10_:* = 0;
         var _loc15_:Array = _avatarEditorView.colors;
         var _loc4_:uint = uint(_loc15_[0]);
         var _loc6_:uint = uint(_loc15_[1]);
         var _loc8_:uint = uint(_loc15_[2]);
         switch(param1)
         {
            case 0:
            case 1:
               _loc14_ = _loc4_ >> 8 & 0xFF;
               _loc16_ = _loc4_ & 0xFF;
               if(param1 == 0)
               {
                  _loc17_ = param2;
                  _loc18_ = _loc4_ >> 16 & 0xFF;
               }
               else
               {
                  _loc17_ = _loc4_ >> 24 & 0xFF;
                  _loc18_ = param2;
               }
               _loc4_ = uint(_loc17_ << 24 | _loc18_ << 16 | _loc14_ << 8 | _loc16_);
               break;
            case 2:
               _loc13_ = param2;
               _loc12_ = _loc8_ >> 16 & 0xFF;
               _loc11_ = _loc8_ >> 8 & 0xFF;
               _loc10_ = _loc8_ & 0xFF;
               _loc8_ = uint(_loc13_ << 24 | _loc12_ << 16 | _loc11_ << 8 | _loc10_);
               break;
            case 3:
               _loc5_ = param2;
               _loc7_ = _loc6_ >> 16 & 0xFF;
               _loc9_ = _loc6_ >> 8 & 0xFF;
               _loc3_ = _loc6_ & 0xFF;
               _loc6_ = uint(_loc5_ << 24 | _loc7_ << 16 | _loc9_ << 8 | _loc3_);
         }
         _avatarEditorView.colors = [_loc4_,_loc6_,_loc8_];
         if(param1 == 2 || param1 == 3)
         {
            colorCurrEyePattIcon();
         }
      }
      
      private function loadPetView() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType != 7 || QuestManager.isQuestLikeNormalRoom())
         {
            _loc1_ = PetManager.myPetList;
            while(avEditor.itemWindowPet2.numChildren > 0)
            {
               avEditor.itemWindowPet2.removeChildAt(0);
            }
            while(avEditor.itemWindowPet1.numChildren > 0)
            {
               avEditor.itemWindowPet1.removeChildAt(0);
            }
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_].idx == PetManager.myActivePetInvId)
               {
                  _loc3_ = _loc1_[_loc2_];
                  if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc3_.currPetDef,_loc3_.createdTs))
                  {
                     _myPet = new GuiPet(_loc3_.createdTs,_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,_loc3_.personalityDefId,_loc3_.favoriteToyDefId,_loc3_.favoriteFoodDefId,onPetLoaded);
                     if(_myPet.isGround())
                     {
                        avEditor.itemWindowPet2.addChild(_myPet);
                        break;
                     }
                     avEditor.itemWindowPet1.addChild(_myPet);
                  }
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc3_:Matrix = null;
         if(_myPet)
         {
            _myPet.scaleY = 2;
            _myPet.scaleX = 2;
            _loc3_ = _myPet.transform.matrix;
            _loc3_.scale(-1,1);
            _myPet.transform.matrix = _loc3_;
         }
      }
      
      private function sendChangesRequest() : void
      {
         var _loc1_:Boolean = false;
         wereItemsOnOriginally(_itemIdsOn,_itemIdsOff);
         if(!_isForMannequin)
         {
            if(_itemIdsOn.length > 0 || _itemIdsOff.length > 0)
            {
               ItemXtCommManager.requestItemUse(itemUseResponse,_itemIdsOn,_itemIdsOff);
               _waitForIuResponse = true;
               _loc1_ = true;
            }
            else if(_recycle)
            {
               DarkenManager.showLoadingSpiral(false);
               _recycle.init(0,_guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
            }
            if(gMainFrame.userInfo.playerUserInfo.nameBarData != _nameBarData)
            {
               AvatarXtCommManager.requestColorChange(_avatarEditorView.colors,_nameBarData,avatarPaintResponse);
               _waitForApResponse = true;
               _loc1_ = true;
            }
            else if(_worldAvatar.colors[0] != _avatarEditorView.colors[0] || _worldAvatar.colors[1] != _avatarEditorView.colors[1] || _worldAvatar.colors[2] != _avatarEditorView.colors[2])
            {
               AvatarXtCommManager.requestColorChange(_avatarEditorView.colors,gMainFrame.userInfo.playerUserInfo.nameBarData,avatarPaintResponse);
               _waitForApResponse = true;
               _loc1_ = true;
            }
            if(_tradeItemsIn.length > 0 || _tradeItemsOut.length > 0)
            {
               if(_waitForIuResponse)
               {
                  _sendDelayedTradeRequest = true;
               }
               else
               {
                  TradeManager.changeTradeList(_tradeItemsIn,_tradeItemsOut);
                  _tradeItemsIn = new TradeItemCollection();
                  _tradeItemsOut = new TradeItemCollection();
               }
            }
            if(!_waitForIuResponse && !_waitForApResponse)
            {
               if(_onCloseCallback != null && _shop == null && _recycle == null)
               {
                  _onCloseCallback();
               }
            }
            if(_loc1_)
            {
               DarkenManager.showLoadingSpiral(true);
            }
            else
            {
               _worldAvatar.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
            }
         }
         else if(_itemIdsOn.length > 0 || _itemIdsOff.length > 0 || (_worldAvatar.colors[0] != _avatarEditorView.colors[0] || _worldAvatar.colors[1] != _avatarEditorView.colors[1] || _worldAvatar.colors[2] != _avatarEditorView.colors[2]))
         {
            DenMannequinInventory.removeItemsFromUse(_itemIdsOff);
            DenMannequinInventory.setItemsInUse(_itemIdsOn,_mannequinDenItemHelper.mannequin.invIdx);
            _mannequinDenItemHelper.mannequin.updateColors(_avatarEditorView.colors);
            _mannequinDenItemHelper.mannequin.mannequinAvatarView.avatarData.copyColors(_avatarEditorView.avatarData.colors);
            _mannequinDenItemHelper.mannequin.mannequinAvatarView.avatarData.cloneShownAccFromAvatar(_avatarEditorView.avatarData);
            _mannequinDenItemHelper.rebuildMannequinView();
            _worldAvatar.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
            _onCloseCallback(true);
         }
         else
         {
            _onCloseCallback(false);
         }
      }
      
      private function itemUseResponse(param1:IntItemCollection, param2:IntItemCollection, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param3)
         {
            DebugUtility.debugTrace("AvatarEditor: Changes made to avatar were successful");
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               DebugUtility.debugTrace("Item #" + param1.getIntItem(_loc4_) + ": PUT ON");
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               DebugUtility.debugTrace("Item #" + param2.getIntItem(_loc4_) + ": TAKEN OFF");
               _loc5_++;
            }
         }
         applyChanges(param3);
      }
      
      private function avatarPaintResponse(param1:Boolean) : void
      {
         var _loc3_:AvatarInfo = null;
         var _loc2_:Array = null;
         if(param1 && _avatarEditorView)
         {
            _loc3_ = gMainFrame.userInfo.playerAvatarInfo;
            _loc2_ = _avatarEditorView.colors;
            if(_loc3_)
            {
               _loc3_.colors = _loc2_;
            }
            gMainFrame.userInfo.playerUserInfo.nameBarData = _nameBarData;
            _worldAvatar.setColors(_loc2_[0],_loc2_[1],_loc2_[2]);
            AvatarManager.playerAvatarWorldView.updateSpecialPatternColorsAndApply();
         }
         _waitForApResponse = false;
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null && _shop == null && _recycle == null)
            {
               _onCloseCallback();
            }
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function applyChanges(param1:Boolean) : void
      {
         var _loc2_:Avatar = null;
         if(!param1)
         {
            DarkenManager.showLoadingSpiral(false);
            DebugUtility.debugTrace("WARNING: Changes were not made to your avatar");
         }
         else
         {
            _loc2_ = _avatarEditorView.viewAvatar;
            AvatarManager.playerAvatar.rangedAttack = _loc2_.rangedAttack;
            AvatarManager.playerAvatar.meleeAttack = _loc2_.meleeAttack;
            AvatarManager.playerAvatar.defense = _loc2_.defense;
            AvatarManager.playerAvatar.fierceAttack = _loc2_.fierceAttack;
            AvatarManager.playerAvatar.healingPower = _loc2_.healingPower;
         }
         _itemIdsOn = new IntItemCollection();
         _itemIdsOff = new IntItemCollection();
         _waitForIuResponse = false;
         if(_sendDelayedTradeRequest)
         {
            TradeManager.changeTradeList(_tradeItemsIn,_tradeItemsOut);
            _tradeItemsIn = new TradeItemCollection();
            _tradeItemsOut = new TradeItemCollection();
         }
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null && _shop == null && _recycle == null)
            {
               _onCloseCallback();
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(xBtn != null && !xBtn.isGray)
         {
            sendChangesRequest();
         }
      }
      
      private function colorTableTabClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == avEditor.colorsTabDnBtn.name)
            {
               openTab(0);
            }
            else if(param1.currentTarget.name == avEditor.patternTabDnBtn.name)
            {
               openTab(1);
            }
            else if(param1.currentTarget.name == avEditor.eyesTabDnBtn.name)
            {
               openTab(2);
            }
            else
            {
               DebugUtility.debugTrace("Error AvatarEditor on colorTableTabClick handler: Invalid tab: " + param1.currentTarget.name);
            }
         }
      }
      
      private function colorTableTabOverClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == avEditor.colorsTabDnBtn.name)
            {
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14621),665,105);
            }
            else if(param1.currentTarget.name == avEditor.patternTabDnBtn.name)
            {
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14622),820,105);
            }
            else if(param1.currentTarget.name == avEditor.eyesTabDnBtn.name)
            {
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14623),742,105);
            }
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function openTab(param1:int) : void
      {
         if(param1 == 0)
         {
            openColorTableColorsTab();
         }
         else if(param1 == 1)
         {
            openColorTablePatternEyesTab(true);
         }
         else if(param1 == 2)
         {
            openColorTablePatternEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error AvatarEditor on openTab: Invalid tabId: " + param1);
         }
      }
      
      private function openColorTableColorsTab() : void
      {
         avEditor.colorsTabUp.visible = true;
         avEditor.eyesTabUp.visible = false;
         avEditor.patternTabUp.visible = false;
         _tabOpenId = 0;
         avEditor.colorTableBlock.colors.visible = true;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
      }
      
      private function openColorTablePatternEyesTab(param1:Boolean) : void
      {
         var _loc2_:CustomAvatarDef = null;
         avEditor.colorTableBlock.patternsAndEyes.visible = true;
         avEditor.colorTableBlock.colors.visible = false;
         while(_eyePattWindow.numChildren > 1)
         {
            _eyePattWindow.removeChildAt(1);
         }
         if(param1)
         {
            _tabOpenId = 1;
            avEditor.colorsTabUp.visible = false;
            avEditor.eyesTabUp.visible = false;
            avEditor.patternTabUp.visible = true;
            avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.visible = _worldAvatar.customAvId != -1;
            if(avEditor.colorTableBlock.patternsAndEyes.contains(_colorTableEyes))
            {
               avEditor.colorTableBlock.patternsAndEyes.removeChild(_colorTableEyes);
            }
            LocalizationManager.translateId(avEditor.colorTableBlock.patternsAndEyes.topTxt,11213);
            if(avEditor.colorTableBlock.patternsAndEyes.contains(_colorTableEyes))
            {
               avEditor.colorTableBlock.patternsAndEyes.removeChild(_colorTableEyes);
            }
            if(_worldAvatar.customAvId != -1)
            {
               if(_customAvtIcon)
               {
                  avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.addChild(_customAvtIcon);
               }
               else
               {
                  _loc2_ = gMainFrame.userInfo.getAvatarDefByAvType(_worldAvatar.customAvId,true) as CustomAvatarDef;
                  if(_loc2_)
                  {
                     _loadingSpiral = new LoadingSpiral(avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont,avEditor.colorTableBlock.patternsAndEyes.width * 0.5,avEditor.colorTableBlock.patternsAndEyes.height * 0.5);
                     _loadingMediaHelper = new MediaHelper();
                     _loadingMediaHelper.init(_loc2_.iconRefId,onCustomIconLoaded);
                  }
               }
            }
            else
            {
               avEditor.colorTableBlock.patternsAndEyes.addChild(_colorTablePatterns);
            }
            if(_patterns.length > 0)
            {
               if(_patterns.length <= 1 && _worldAvatar.customAvId == -1)
               {
                  _lArrowBtn.visible = false;
                  _rArrowBtn.visible = false;
               }
               if(_patterns.getAccItem(_currPattern))
               {
                  _eyePattWindow.addChild(_patterns.getAccItem(_currPattern).icon);
               }
            }
            else
            {
               _eyePattWindow.visible = false;
               avEditor.lArrBtn.visible = false;
               avEditor.rArrBtn.visible = false;
            }
         }
         else
         {
            _tabOpenId = 2;
            avEditor.colorsTabUp.visible = false;
            avEditor.eyesTabUp.visible = true;
            avEditor.patternTabUp.visible = false;
            LocalizationManager.translateId(avEditor.colorTableBlock.patternsAndEyes.topTxt,11214);
            if(avEditor.colorTableBlock.patternsAndEyes.contains(_colorTablePatterns))
            {
               avEditor.colorTableBlock.patternsAndEyes.removeChild(_colorTablePatterns);
            }
            if(_customAvtIcon && avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.contains(_customAvtIcon))
            {
               avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.removeChild(_customAvtIcon);
               avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.visible = false;
            }
            avEditor.colorTableBlock.patternsAndEyes.addChild(_colorTableEyes);
            if(_eyes.length > 0)
            {
               if(_eyes.length <= 1)
               {
                  _lArrowBtn.visible = false;
                  _rArrowBtn.visible = false;
               }
               if(_eyes.getAccItem(_currEye))
               {
                  _eyePattWindow.addChild(_eyes.getAccItem(_currEye).icon);
               }
            }
            else
            {
               _eyePattWindow.visible = false;
               _lArrowBtn.visible = false;
               _rArrowBtn.visible = false;
            }
         }
         colorCurrEyePattIcon();
         avEditor.colorTableBlock.patternsAndEyes.visible = true;
         avEditor.colorTableBlock.colors.visible = false;
      }
      
      private function onCustomIconLoaded(param1:MovieClip) : void
      {
         if(_avatarEditorView)
         {
            _customAvtIcon = MovieClip(param1.getChildAt(0));
            if(_loadingSpiral)
            {
               if(_loadingSpiral.parent == avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont)
               {
                  avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.removeChild(_loadingSpiral);
               }
               _loadingSpiral.destroy();
               _loadingSpiral = null;
            }
            avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.addChild(_customAvtIcon);
         }
      }
      
      private function createPatternsAndEyesArrays() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:Item = null;
         var _loc1_:AccItemCollection = _avatarEditorView.inventoryBodyModItems;
         _eyes = new AccItemCollection();
         _patterns = new AccItemCollection();
         var _loc2_:CustomAvatarDef = _worldAvatar.customAvId != -1 ? gMainFrame.userInfo.getAvatarDefByAvatar(_worldAvatar) as CustomAvatarDef : null;
         if(_loc2_ == null)
         {
            _patterns.pushAccItem(null);
         }
         _loc4_ = 0;
         while(_loc4_ < _loc1_.length)
         {
            if(_loc1_.getAccItem(_loc4_).layerId == 2)
            {
               if(_loc2_)
               {
                  if(_loc2_.patternRefIds.length > 1)
                  {
                     avEditor.colorsTabUp.activateGrayState(true);
                     avEditor.colorsTabDnBtn.activateGrayState(true);
                     openTab(2);
                  }
                  _loc5_ = int(_loc2_.patternRefIds.indexOf(_loc1_.getAccItem(_loc4_).defId));
                  if(_loc5_ != -1)
                  {
                     if(_loc2_.patternRefIds.length == 1 || _loc1_.getAccItem(_loc4_).getInUse(_worldAvatar.avInvId))
                     {
                        _currPattern = _patterns.length;
                     }
                     _patterns.pushAccItem(_loc1_.getAccItem(_loc4_));
                  }
               }
               else
               {
                  if(_loc1_.getAccItem(_loc4_).getInUse(_worldAvatar.avInvId))
                  {
                     _currPattern = _patterns.length;
                  }
                  _patterns.pushAccItem(_loc1_.getAccItem(_loc4_));
               }
            }
            else if(_loc1_.getAccItem(_loc4_).layerId == 3)
            {
               if(_loc1_.getAccItem(_loc4_).getInUse(_worldAvatar.avInvId))
               {
                  _currEye = _eyes.length;
               }
               _eyes.pushAccItem(_loc1_.getAccItem(_loc4_));
            }
            _loc4_++;
         }
         if(_loc2_)
         {
            if(_patterns.length != _loc2_.patternRefIds.length)
            {
               _currPattern = _patterns.length;
               _loc6_ = 0;
               while(_loc6_ < _loc2_.patternRefIds.length)
               {
                  _loc3_ = new Item();
                  _loc3_.init(_loc2_.patternRefIds[_loc6_]);
                  _patterns.pushAccItem(_loc3_);
                  _loc6_++;
               }
            }
            setCustomPatternColorIdx();
         }
      }
      
      private function setCustomPatternColorIdx() : void
      {
         var _loc4_:Array = null;
         var _loc3_:* = 0;
         var _loc1_:int = 0;
         var _loc2_:Item = _patterns.getAccItem(_currPattern);
         if(_loc2_)
         {
            _loc4_ = _loc2_.colors;
            _loc3_ = uint(_avatarEditorView.colors[1]);
            _loc1_ = 0;
            while(_loc1_ < _loc4_.length)
            {
               if(_loc4_[_loc1_] == _loc3_)
               {
                  _currCustomPatternColorIdx = _loc1_;
                  break;
               }
               _loc1_++;
            }
         }
      }
      
      private function arrowBtnHandler(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc11_:Item = null;
         var _loc9_:int = 0;
         var _loc10_:AccItemCollection = null;
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc8_:* = 0;
         var _loc2_:* = 0;
         var _loc7_:* = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _lArrowBtn.name)
         {
            _loc4_ = -1;
         }
         else if(param1.currentTarget.name == _rArrowBtn.name)
         {
            _loc4_ = 1;
         }
         while(_eyePattWindow.numChildren > 1)
         {
            _eyePattWindow.removeChildAt(1);
         }
         if(_tabOpenId == 1)
         {
            _loc11_ = _patterns.getAccItem(_currPattern);
            _loc9_ = _currPattern;
            _loc10_ = _patterns;
         }
         else if(_tabOpenId == 2)
         {
            _loc11_ = _eyes.getAccItem(_currEye);
            _loc9_ = _currEye;
            _loc10_ = _eyes;
         }
         if(_tabOpenId == 1 && _worldAvatar.customAvId != -1 && _patterns.getAccItem(_currPattern) != null)
         {
            _currCustomPatternColorIdx += _loc4_;
            if(_currCustomPatternColorIdx >= _patterns.getAccItem(_currPattern).colors.length)
            {
               _currCustomPatternColorIdx = 0;
               _loc9_ += _loc4_;
            }
            else if(_currCustomPatternColorIdx < 0)
            {
               _currCustomPatternColorIdx = _patterns.getAccItem(_currPattern).colors.length - 1;
               _loc9_ += _loc4_;
            }
         }
         else
         {
            _loc9_ += _loc4_;
         }
         if(_loc9_ < 0)
         {
            _loc9_ = _loc10_.length - 1;
         }
         else if(_loc9_ > _loc10_.length - 1)
         {
            _loc9_ = 0;
         }
         if(_loc9_ != (_tabOpenId == 1 ? _currPattern : _currEye))
         {
            if(_loc10_.getAccItem(_loc9_) == null)
            {
               hideItem(_loc11_);
            }
            else
            {
               _loc11_ = _loc10_.getAccItem(_loc9_);
               showItem(_loc11_,hideBodModWhenShowingBodMod);
            }
            if(_tabOpenId == 1)
            {
               _currPattern = _loc9_;
            }
            else if(_tabOpenId == 2)
            {
               _currEye = _loc9_;
            }
         }
         if(_tabOpenId == 1 && _worldAvatar.customAvId != -1 && _patterns.getAccItem(_currPattern) != null)
         {
            _loc3_ = uint(_patterns.getAccItem(_currPattern).colors[_currCustomPatternColorIdx]);
            _loc5_ = _loc3_ >> 24;
            _loc6_ = _loc3_ >> 16 & 0xFF;
            _loc8_ = _loc3_ >> 8 & 0xFF;
            _loc2_ = _loc3_ & 0xFF;
            _loc7_ = _loc7_ = uint(_loc5_ << 24 | _loc6_ << 16 | _loc8_ << 8 | _loc2_);
            _avatarEditorView.colors = [_avatarEditorView.colors[0],_loc7_,_avatarEditorView.colors[2]];
            (_loc10_.getAccItem(_loc9_) as Item).color = _loc3_;
         }
         if(_loc10_.getAccItem(_loc9_) && _loc10_.getAccItem(_loc9_).icon != null)
         {
            _eyePattWindow.addChild(_loc10_.getAccItem(_loc9_).icon);
         }
         colorCurrEyePattIcon();
      }
      
      public function showItem(param1:Item, param2:Function = null) : void
      {
         var _loc4_:int = 0;
         var _loc6_:AccItemCollection = null;
         var _loc3_:AccItemCollection = null;
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1)
         {
            _loc4_ = param1.invIdx;
            if(_itemIdsOn && _itemIdsOff)
            {
               if(param1.type == 1)
               {
                  _loc6_ = _avatarEditorView.inventoryClothingItems;
                  _loc3_ = _worldAvatar.inventoryClothing.itemCollection;
               }
               else
               {
                  _loc6_ = _avatarEditorView.inventoryBodyModItems;
                  _loc3_ = _worldAvatar.inventoryBodyMod.itemCollection;
               }
               _loc7_ = 0;
               while(_loc7_ < _loc6_.length)
               {
                  if(_loc6_.getAccItem(_loc7_).invIdx == param1.invIdx && (_loc6_.getAccItem(_loc7_).type == 0 || _loc6_.getAccItem(_loc7_).enviroType == _worldAvatar.roomType))
                  {
                     if(_itemIdsOff.getCoreArray().indexOf(_loc4_) != -1)
                     {
                        _itemIdsOff.getCoreArray().splice(_itemIdsOff.getCoreArray().indexOf(_loc4_),1);
                     }
                     _loc8_ = 0;
                     while(_loc8_ < _loc3_.length)
                     {
                        if(param1.invIdx == _loc3_.getAccItem(_loc8_).invIdx && (_loc3_.getAccItem(_loc8_).type == 0 || _loc3_.getAccItem(_loc8_).enviroType == _worldAvatar.roomType))
                        {
                           _loc5_ = true;
                           if(!_loc3_.getAccItem(_loc8_).getInUse(_worldAvatar.avInvId))
                           {
                              if(_itemIdsOn.getCoreArray().indexOf(_loc4_) == -1)
                              {
                                 _itemIdsOn.pushIntItem(_loc4_);
                                 if(_mannequinDenItemHelper)
                                 {
                                    _mannequinDenItemHelper.mannequin.updateLayer(param1,true);
                                 }
                              }
                              break;
                           }
                        }
                        _loc8_++;
                     }
                     if(!_loc5_ && _itemIdsOn.getCoreArray().indexOf(_loc4_) == -1)
                     {
                        _itemIdsOn.pushIntItem(_loc4_);
                        if(_mannequinDenItemHelper)
                        {
                           _mannequinDenItemHelper.mannequin.updateLayer(param1,true);
                        }
                     }
                     break;
                  }
                  _loc7_++;
               }
            }
            _avatarEditorView.showAccessory(param1,param2);
         }
      }
      
      public function hideItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc4_:AccItemCollection = null;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = param1.invIdx;
            if(_itemIdsOn && _itemIdsOff)
            {
               if(param1.type == 1)
               {
                  _loc4_ = _avatarEditorView.inventoryClothingItems;
               }
               else
               {
                  _loc4_ = _avatarEditorView.inventoryBodyModItems;
               }
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_.getAccItem(_loc3_).invIdx == param1.invIdx)
                  {
                     if(_itemIdsOff.getCoreArray().indexOf(_loc2_) == -1)
                     {
                        _itemIdsOff.pushIntItem(_loc2_);
                        if(_mannequinDenItemHelper)
                        {
                           _mannequinDenItemHelper.mannequin.updateLayer(param1,false);
                        }
                     }
                     if(_itemIdsOn.getCoreArray().indexOf(_loc2_) != -1)
                     {
                        _itemIdsOn.getCoreArray().splice(_itemIdsOn.getCoreArray().indexOf(_loc2_),1);
                     }
                     break;
                  }
                  _loc3_++;
               }
            }
            _avatarEditorView.hideAccessory(param1);
         }
      }
      
      public function onShopBtnHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.shopBtn.isGray)
         {
            return;
         }
         _shop = new ShopWithPreview();
         if(AvatarManager.roomEnviroType == 1)
         {
            _shop.init(50,1000,_worldAvatar,_guiLayer,onShopClose);
         }
         else
         {
            _shop.init(11,1000,_worldAvatar,_guiLayer,onShopClose);
         }
         sendChangesRequest();
      }
      
      public function onShopBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.shopBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),AvatarManager.roomEnviroType == 0 ? LocalizationManager.translateIdOnly(14624) : LocalizationManager.translateIdOnly(14625),0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onShopBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function onPetBtnHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.petsBtn.isGray)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         _petInventory = new PetInventory();
         _petInventory.init(onPetInventoryClose,false,_openCheckListImmediately);
      }
      
      private function onPetInventoryClose() : void
      {
         _petInventory = null;
         _openCheckListImmediately = false;
         reloadCurrencyCounts();
         loadPetView();
      }
      
      private function onPetBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.petsBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(11240),0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPetBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onRecycleClothesBtn(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(avEditor.recycleClothesBtn.isGray)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         _recycle = new RecycleItems();
         sendChangesRequest();
      }
      
      public function openRecycle() : void
      {
         if(_recycle && !_recycle.hasBeenInited())
         {
            DarkenManager.showLoadingSpiral(false);
            _recycle.init(0,_guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
         }
      }
      
      private function onRecycleClothesBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.recycleClothesBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(14626),0,-35);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
         if(param1)
         {
            reloadCurrencyCounts();
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            _itemIdsOn = new IntItemCollection();
            _itemIdsOff = new IntItemCollection();
            positionAndDrawAvatarView(true);
            createPatternsAndEyesArrays();
            _currClothesArray = _allNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,_avatarEditorView.inventoryClothingItems);
            _headItems = Utility.sortItemsAll(_currClothesArray,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _neckItems = Utility.sortItemsAll(_currClothesArray,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _backItems = Utility.sortItemsAll(_currClothesArray,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _legItems = Utility.sortItemsAll(_currClothesArray,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _tailItems = Utility.sortItemsAll(_currClothesArray,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeItems = Utility.sortByItem(_currClothesArray,_worldAvatar.roomType) as AccItemCollection;
            _allOldestClothes = new AccItemCollection(_allNewestClothes.getCoreArray().concat().reverse());
            if(_currClothesArray)
            {
               _currClothesArray = _allNewestClothes;
            }
            _fullClothesList = _fullallNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,gMainFrame.userInfo.playerAvatarInfo.getFullItems());
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray) as DenItemCollection;
            _fullAllOldestClothes = new AccItemCollection(_fullallNewestClothes.getCoreArray().concat().reverse());
            avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + ShopManager.maxItems;
            _currTradesArray = new TradeItemCollection(gMainFrame.userInfo.getMyTradeList().concatCollection(null));
            _itemTradeWindows = null;
            if(_itemClothingWindows)
            {
               _itemClothingWindows.destroy();
               _itemClothingWindows = null;
            }
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
      }
      
      private function onShopClose(param1:Boolean) : void
      {
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(param1)
         {
            reloadCurrencyCounts();
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            _itemIdsOn = new IntItemCollection();
            _itemIdsOff = new IntItemCollection();
            positionAndDrawAvatarView(true);
            createPatternsAndEyesArrays();
            _currClothesArray = _allNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,_avatarEditorView.inventoryClothingItems);
            _headItems = Utility.sortItemsAll(_currClothesArray,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _neckItems = Utility.sortItemsAll(_currClothesArray,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _backItems = Utility.sortItemsAll(_currClothesArray,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _legItems = Utility.sortItemsAll(_currClothesArray,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _tailItems = Utility.sortItemsAll(_currClothesArray,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeItems = Utility.sortByItem(_currClothesArray,_worldAvatar.roomType) as AccItemCollection;
            _allOldestClothes = new AccItemCollection(_allNewestClothes.getCoreArray().concat().reverse());
            if(_currClothesArray)
            {
               _currClothesArray = _allNewestClothes;
            }
            _fullClothesList = _fullallNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,gMainFrame.userInfo.playerAvatarInfo.getFullItems());
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray) as DenItemCollection;
            _fullAllOldestClothes = new AccItemCollection(_fullallNewestClothes.getCoreArray().concat().reverse());
            avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + ShopManager.maxItems;
            if(_itemClothingWindows)
            {
               _itemClothingWindows.destroy();
               _itemClothingWindows = null;
            }
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
      }
      
      private function numTradeItemsInClothesList(param1:AccItemCollection) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _currTradesArray.length)
         {
            if(_currTradesArray.getTradeItem(_loc3_).itemType == 0)
            {
               _loc4_ = 0;
               while(_loc4_ < param1.length)
               {
                  if(_currTradesArray.getTradeItem(_loc3_).invIdx == param1.getAccItem(_loc4_).invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function numTradeItemsInDenItemsList(param1:DenItemCollection) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _currTradesArray.length)
         {
            if(_currTradesArray.getTradeItem(_loc3_).itemType == 1)
            {
               _loc4_ = 0;
               while(_loc4_ < param1.length)
               {
                  if(_currTradesArray.getTradeItem(_loc3_).invIdx == param1.getDenItem(_loc4_).invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function createItemWindows(param1:Object, param2:MovieClip, param3:Boolean = false) : void
      {
         var _loc8_:WindowAndScrollbarGenerator = null;
         var _loc6_:Boolean = false;
         var _loc7_:Boolean = false;
         var _loc4_:Number = NaN;
         var _loc5_:Object = null;
         _loc6_ = false;
         _loc6_ = true;
         param1 == _currTradesArray ? _loc6_ : (_loc6_);
         if(_loc6_)
         {
            avEditor.searchBar.visible = false;
         }
         else if(param1 == _allNewestClothes || param1 == _currClothesArray || param1 == _fullClothesList)
         {
            onSearchBarDown(null);
            onSearchTextInput(null);
            if(_allNewestClothes.length <= 0)
            {
               avEditor.sortBtn.visible = false;
               avEditor.sortPopup.visible = false;
               avEditor.searchBar.visible = false;
            }
            else
            {
               avEditor.searchBar.visible = true;
            }
         }
         else
         {
            if(!(param1 == _currDenItemsArray || param1 == _allNewestDenItems))
            {
               throw new Error("None of our lists match given items list");
            }
            avEditor.searchBar.visible = false;
         }
         if(avEditor.tradeBtnUp && avEditor.tradeBtnUp.visible)
         {
            _loc7_ = true;
         }
         if(param2 == avEditor.itemBlock)
         {
            if(_loc7_)
            {
               _loc8_ = _itemTradeWindows;
            }
            else
            {
               _loc8_ = _itemClothingWindows;
            }
            if(param3 && _loc8_)
            {
               _mainScrollYPosition = _loc8_.scrollYValue;
            }
            while(avEditor.itemBlock.numChildren > 1)
            {
               avEditor.itemBlock.removeChildAt(avEditor.itemBlock.numChildren - 1);
            }
         }
         if(_loc8_ == null)
         {
            if(param2 == avEditor.itemBlock)
            {
               _loc4_ = _mainScrollYPosition;
            }
            _loc5_ = generateItemAndIndexArray(param1);
            _loc8_ = new WindowAndScrollbarGenerator();
            _loc8_.init(param2.width,param2.height,3,_loc4_,3,4,12,2,2,2 * 0.5,0,ItemWindowOriginal,_loc5_.items,"icon",0,{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut,
               "memberOnlyDown":memberOnlyDown
            },{
               "isAvatarEditor":true,
               "isTradeList":_loc6_,
               "showAddRemoveBtns":_loc6_,
               "isChoosingForTradeList":_loc7_,
               "indexArray":_loc5_.indexes,
               "mannequinInvIdx":(_mannequinDenItemHelper != null ? _mannequinDenItemHelper.mannequin.invIdx : -1)
            });
            if(param2 == avEditor.itemBlock)
            {
               if(_loc7_)
               {
                  _itemTradeWindows = _loc8_;
               }
               else
               {
                  _itemClothingWindows = _loc8_;
               }
            }
         }
         if(_itemClothingWindows && _itemClothingWindows == _loc8_)
         {
            updateCleanUpBtnVisibility();
         }
         else
         {
            avEditor.cleanUpBtn.visible = false;
         }
         param2.addChild(_loc8_);
      }
      
      private function generateItemAndIndexArray(param1:Object) : Object
      {
         var _loc13_:Boolean = false;
         var _loc2_:* = false;
         var _loc16_:int = 0;
         var _loc8_:int = 0;
         var _loc17_:TradeItemCollection = null;
         var _loc3_:IitemCollection = null;
         var _loc7_:int = 0;
         var _loc12_:int = 0;
         var _loc10_:Item = null;
         var _loc9_:PetItem = null;
         var _loc14_:DenItem = null;
         var _loc11_:int = 0;
         var _loc4_:Array = [];
         var _loc5_:Array = [];
         var _loc15_:Iitem = null;
         var _loc6_:int = 0;
         if(param1 is IitemCollection)
         {
            _loc3_ = param1 as IitemCollection;
            _loc16_ = int(_loc3_.length);
         }
         else if(param1 is TradeItemCollection)
         {
            _loc17_ = param1 as TradeItemCollection;
            _loc16_ = int(_loc17_.length);
         }
         _loc2_ = param1 == _currTradesArray;
         _loc7_ = 0;
         for(; _loc7_ < _loc16_; _loc7_++)
         {
            if(_loc7_ < _loc16_)
            {
               if(param1.length > _loc7_)
               {
                  if(_isForMannequin || avEditor.clothesBtnUp.visible)
                  {
                     _loc15_ = _loc3_.getIitem(_loc7_);
                  }
                  else if(_loc2_)
                  {
                     if(_loc17_.getTradeItem(_loc7_).itemType == 0)
                     {
                        _loc10_ = null;
                        _loc12_ = 0;
                        while(_loc12_ < _fullClothesList.length)
                        {
                           if(_fullClothesList.getAccItem(_loc12_).invIdx == _loc17_.getTradeItem(_loc7_).invIdx)
                           {
                              _loc10_ = _fullClothesList.getAccItem(_loc12_);
                              break;
                           }
                           _loc12_++;
                        }
                        if(_loc10_)
                        {
                           _loc15_ = new Item();
                           (_loc15_ as Item).init(_loc10_.defId,_loc10_.invIdx,_loc10_.color,_loc10_.cloneEquippedAvatars(),false,-1,_loc10_.denStoreInvId);
                        }
                     }
                     else if(_loc17_.getTradeItem(_loc7_).itemType == 3)
                     {
                        _loc9_ = null;
                        _loc12_ = 0;
                        while(_loc12_ < _petsList.length)
                        {
                           if(_petsList.getPetItem(_loc12_).invIdx == _loc17_.getTradeItem(_loc7_).invIdx)
                           {
                              _loc9_ = _petsList.getPetItem(_loc12_);
                              break;
                           }
                           _loc12_++;
                        }
                        if(_loc9_)
                        {
                           _loc15_ = new PetItem();
                           (_loc15_ as PetItem).init(_loc9_.createdTs,_loc9_.defId,_loc9_.petBits,_loc9_.traitDefId,_loc9_.toyDefId,_loc9_.foodDefId,_loc9_.invIdx,_loc9_.name,false,null,_loc9_.diamondItem,_loc9_.denStoreInvId);
                        }
                     }
                     else
                     {
                        _loc14_ = null;
                        _loc12_ = 0;
                        while(_loc12_ < _allNewestDenItems.length)
                        {
                           if(_allNewestDenItems.getDenItem(_loc12_).defId != 617)
                           {
                              if(_allNewestDenItems.getDenItem(_loc12_).invIdx == _loc17_.getTradeItem(_loc7_).invIdx)
                              {
                                 _loc14_ = _allNewestDenItems.getDenItem(_loc12_);
                                 break;
                              }
                           }
                           _loc12_++;
                        }
                        if(_loc14_)
                        {
                           _loc15_ = new DenItem();
                           (_loc15_ as DenItem).init(_loc14_.defId,_loc14_.invIdx,_loc14_.categoryId,_loc14_.version,_loc14_.refId,_loc14_.petItem,_loc14_.isApproved,_loc14_.uniqueImageId,_loc14_.uniqueImageCreator,_loc14_.uniqueImageCreatorDbId,_loc14_.uniqueImageCreatorUUID,_loc14_.mannequinData != null ? _loc14_.mannequinData.clone() : null,_loc14_.denStoreInvId);
                        }
                     }
                  }
                  else
                  {
                     _loc15_ = _loc3_.getIitem(_loc7_).clone();
                     _loc11_ = 0;
                     while(_loc11_ < _currTradesArray.length)
                     {
                        if((_loc15_ is Item && _currTradesArray.getTradeItem(_loc11_).itemType == 0 || _loc15_ is DenItem && _currTradesArray.getTradeItem(_loc11_).itemType == 1 || _loc15_ is PetItem && _currTradesArray.getTradeItem(_loc11_).itemType == 3) && _loc15_.invIdx == _currTradesArray.getTradeItem(_loc11_).invIdx)
                        {
                           _loc13_ = true;
                           break;
                        }
                        _loc11_++;
                     }
                     if(_loc13_)
                     {
                        _loc13_ = false;
                        _loc6_++;
                        continue;
                     }
                  }
                  _loc5_.push(_loc8_ + _loc6_);
                  if(_loc15_)
                  {
                     _loc4_.push(_loc15_);
                  }
               }
            }
            _loc8_++;
         }
         return {
            "items":_loc4_,
            "indexes":_loc5_
         };
      }
      
      private function openCloseTradeWindow() : void
      {
         var _loc1_:TradeItemCollection = null;
         if(_tradeItemSelect)
         {
            _tradeItemSelect.destroy();
            _tradeItemSelect = null;
         }
         else
         {
            _tradeItemSelect = new DenAndClothesItemSelect();
            _loc1_ = new TradeItemCollection(_currTradesArray.concatCollection(null));
            _tradeItemSelect.init(_fullallNewestClothes,_allNewestDenItems,_petsList,_guiLayer,null,onTradeItemSelectClose,0,_loc1_);
         }
      }
      
      private function onTradeItemSelectClose(param1:Iitem) : void
      {
         var _loc3_:int = 0;
         var _loc2_:TradeItem = null;
         if(param1)
         {
            if(param1 is Item)
            {
               _loc3_ = 0;
               TradeManager.adjustByOnNumClothingItemsInMyTradeList(1);
            }
            else if(param1 is DenItem)
            {
               _loc3_ = 1;
               TradeManager.adjustByOnNumDenItemsInMyTradeList(1);
            }
            else if(param1 is PetItem)
            {
               _loc3_ = 3;
               TradeManager.adjustByOnNumPetItemsInMyTradeList(1);
            }
            _loc2_ = new TradeItem(param1.invIdx,_loc3_);
            _currTradesArray.pushTradeItem(_loc2_);
            addRemoveTradeItemFromList(_loc2_,true);
            if(_itemTradeWindows)
            {
               _itemTradeWindows.findOpenWindowAndUpdate(param1.clone());
            }
         }
         openCloseTradeWindow();
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "gray")
            {
               return;
            }
            if(param1.currentTarget.cir.currentFrameLabel == "down")
            {
               param1.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("over");
            }
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "gray")
            {
               return;
            }
            if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("down");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "down")
            {
               param1.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private function winMouseClick(param1:MouseEvent, param2:Boolean = false) : void
      {
         var _loc9_:Object = null;
         var _loc7_:Array = null;
         var _loc3_:String = null;
         var _loc5_:String = null;
         var _loc8_:int = 0;
         var _loc4_:TradeItem = null;
         var _loc6_:* = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.name == "previewBtn")
         {
            if(avEditor.tradeBtnUp.visible)
            {
               _loc9_ = param1.currentTarget.parent.parent.currItem;
               if(_loc9_ is DenItem)
               {
                  GuiManager.openMasterpiecePreview((_loc9_ as DenItem).uniqueImageId,(_loc9_ as DenItem).uniqueImageCreator,(_loc9_ as DenItem).uniqueImageCreatorDbId,(_loc9_ as DenItem).uniqueImageCreatorUUID,(_loc9_ as DenItem).version,gMainFrame.userInfo.myUserName,_loc9_ as DenItem);
               }
            }
         }
         else if(param1.currentTarget.name == "certBtn")
         {
            if(avEditor.tradeBtnUp.visible)
            {
               _loc9_ = param1.currentTarget.parent.parent.currItem;
               if(_loc9_ is PetItem)
               {
                  GuiManager.openPetCertificatePopup((_loc9_ as PetItem).largeIcon as GuiPet,null);
               }
            }
         }
         else
         {
            if(_isForMannequin || avEditor.clothesBtnUp.visible)
            {
               _loc9_ = _currClothesArray.getAccItem(param1.currentTarget.index);
            }
            else if(avEditor.tradeBtnUp.visible)
            {
               _loc9_ = _currTradesArray.getTradeItem(param1.currentTarget.index);
            }
            if(_loc9_)
            {
               if(_isForMannequin || avEditor.clothesBtnUp.visible)
               {
                  if(param1.currentTarget.cir.currentFrameLabel == "gray")
                  {
                     if(!ItemXtCommManager.canUseItem(_loc9_.defId,_worldAvatar,_worldAvatar.customAvId != -1))
                     {
                        return;
                     }
                     if(!param2)
                     {
                        new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(31949),true,confirmToRemoveItemFromOtherMannequin,param1);
                        return;
                     }
                     if(!GuiManager.findMannequinAndRemoveAccessory(DenMannequinInventory.getIdOfWhoIsUsingThisItem(_loc9_.invIdx),_loc9_.invIdx))
                     {
                        return;
                     }
                  }
                  if(!ItemXtCommManager.canUseItem(_loc9_.defId,_worldAvatar,_worldAvatar.customAvId != -1))
                  {
                     _loc7_ = ItemXtCommManager.avTypeThatCanUseItem(_loc9_.defId);
                     if(_loc7_.length > 0)
                     {
                        if(_loc7_.length == 1)
                        {
                           new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_loc7_[0],false).titleStrRef)));
                        }
                        else
                        {
                           _loc3_ = "";
                           _loc8_ = 0;
                           while(_loc8_ < _loc7_.length)
                           {
                              _loc5_ = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_loc7_[_loc8_],false).titleStrRef);
                              if(_loc3_ == "")
                              {
                                 _loc3_ += _loc5_;
                              }
                              else
                              {
                                 _loc3_ += ", " + _loc5_;
                              }
                              _loc8_++;
                           }
                           new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,_loc3_));
                        }
                     }
                     return;
                  }
                  if(param1.currentTarget.cir.currentFrameLabel == "downMouse" && _loc9_.getInUse(_worldAvatar.avInvId))
                  {
                     hideItem(Item(_loc9_));
                     param1.currentTarget.cir.gotoAndStop("over");
                  }
                  else if(param1.currentTarget.cir.currentFrameLabel != "downMouse" && !_loc9_.getInUse(_worldAvatar.avInvId))
                  {
                     showItem(Item(_loc9_),hideItemWhenShowingItem);
                     param1.currentTarget.cir.gotoAndStop("downMouse");
                  }
                  else
                  {
                     DebugUtility.debugTrace("Item is in use? But not in use? Huuuuuuuuh");
                  }
                  updateCleanUpBtnVisibility();
               }
               else if(avEditor.tradeBtnUp.visible)
               {
                  if(gMainFrame.clientInfo.extCallsActive)
                  {
                     return;
                  }
                  param1.currentTarget.cir.gotoAndStop("up");
                  if(param1.currentTarget.removeBtn.visible)
                  {
                     _currTradesArray.getCoreArray().splice(param1.currentTarget.index,1);
                     _itemTradeWindows.deleteItem(param1.currentTarget.index,null);
                     _itemTradeWindows.updateItem(_itemTradeWindows.totalNumWindows - 1,null);
                     _loc4_ = _loc9_ as TradeItem;
                     if(_loc4_.itemType == 0)
                     {
                        TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                     }
                     else if(_loc4_.itemType == 3)
                     {
                        TradeManager.adjustByOnNumPetItemsInMyTradeList(-1);
                     }
                     else
                     {
                        TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                     }
                     addRemoveTradeItemFromList(_loc4_,false);
                  }
                  else
                  {
                     openCloseTradeWindow();
                  }
               }
               else
               {
                  DebugUtility.debugTrace("Wow nothing is visible? How is that possible?");
               }
               AJAudio.playSubMenuBtnClick();
            }
            else if(param1.currentTarget.addBtn.visible)
            {
               _loc6_ = _tradeListViewType == 0;
               if(_loc6_)
               {
                  _fullClothesList = _allNewestClothes;
               }
               else
               {
                  _currDenItemsArray = _allNewestDenItems;
               }
               openCloseTradeWindow();
            }
            else
            {
               DebugUtility.debugTrace("Curr Item is null, and the addBtn is not visible??");
            }
         }
      }
      
      private function confirmToRemoveItemFromOtherMannequin(param1:Object) : void
      {
         if(param1.status)
         {
            winMouseClick(param1.passback,true);
         }
      }
      
      private function memberOnlyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         UpsellManager.displayPopup("accessories","equipAccessory/" + _currClothesArray.getAccItem(param1.currentTarget.index).name);
      }
      
      private function hideItemWhenShowingItem(param1:Item) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc2_:int = int(_itemIdsOn.getCoreArray().indexOf(param1.invIdx));
         if(_loc2_ == -1)
         {
            _loc4_ = 0;
            while(_loc4_ < _currClothesArray.length)
            {
               if(_currClothesArray.getAccItem(_loc4_).invIdx == param1.invIdx)
               {
                  if(_itemIdsOff)
                  {
                     _itemIdsOff.pushIntItem(param1.invIdx);
                     break;
                  }
               }
               _loc4_++;
            }
         }
         if(_itemIdsOn)
         {
            if(_loc2_ != -1)
            {
               _itemIdsOn.getCoreArray().splice(_itemIdsOn.getCoreArray().indexOf(param1.invIdx),1);
            }
         }
         if(_itemClothingWindows)
         {
            _loc5_ = 0;
            while(_loc5_ < _itemClothingWindows.bg.numChildren)
            {
               _loc3_ = MovieClip(_itemClothingWindows.bg.getChildAt(_loc5_));
               if(_currClothesArray.getAccItem(_loc3_.index).invIdx == param1.invIdx)
               {
                  _loc3_.cir.gotoAndStop("up");
                  break;
               }
               _loc5_++;
            }
         }
      }
      
      private function hideBodModWhenShowingBodMod(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc4_:AccItemCollection = _avatarEditorView.inventoryBodyModItems;
         var _loc2_:int = int(_itemIdsOn.getCoreArray().indexOf(param1.invIdx));
         if(_loc2_ == -1)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               if(_loc4_.getAccItem(_loc3_).invIdx == param1.invIdx)
               {
                  if(_itemIdsOff)
                  {
                     _itemIdsOff.pushIntItem(param1.invIdx);
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(_itemIdsOn)
         {
            if(_loc2_ != -1)
            {
               _itemIdsOn.getCoreArray().splice(_itemIdsOn.getCoreArray().indexOf(param1.invIdx),1);
            }
         }
      }
      
      private function wereItemsOnOriginally(param1:IntItemCollection, param2:IntItemCollection) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:AccItemCollection = new AccItemCollection(_worldAvatar.inventoryClothing.itemCollection.concatCollection(_worldAvatar.inventoryBodyMod.itemCollection));
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               if(param1.getIntItem(_loc3_) == _loc5_.getAccItem(_loc4_).invIdx && _loc5_.getAccItem(_loc4_).getInUse(_worldAvatar.avInvId))
               {
                  param1.getCoreArray().splice(_loc3_,1);
                  _loc3_--;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               if(param2.getIntItem(_loc3_) == _loc5_.getAccItem(_loc4_).invIdx && !_loc5_.getAccItem(_loc4_).getInUse(_worldAvatar.avInvId))
               {
                  param2.getCoreArray().splice(_loc3_,1);
                  _loc3_--;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _itemIdsOn = param1;
         _itemIdsOff = param2;
      }
      
      private function addRemoveTradeItemFromList(param1:TradeItem, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:TradeItemCollection = gMainFrame.userInfo.getMyTradeList();
         if(param2)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc5_.length)
            {
               if(param1.isEqual(_loc5_.getTradeItem(_loc3_)))
               {
                  _loc4_ = 0;
                  while(_loc4_ < _tradeItemsOut.length)
                  {
                     if(param1.isEqual(_tradeItemsOut.getTradeItem(_loc4_)))
                     {
                        _tradeItemsOut.getCoreArray().splice(_loc4_,1);
                        break;
                     }
                     _loc4_++;
                  }
                  return;
               }
               _loc3_++;
            }
            _tradeItemsIn.pushTradeItem(param1);
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < _loc5_.length)
            {
               if(param1.isEqual(_loc5_.getTradeItem(_loc3_)))
               {
                  _tradeItemsOut.pushTradeItem(param1);
                  return;
               }
               _loc3_++;
            }
            _loc4_ = 0;
            while(_loc4_ < _tradeItemsIn.length)
            {
               if(param1.isEqual(_tradeItemsIn.getTradeItem(_loc4_)))
               {
                  _tradeItemsIn.getCoreArray().splice(_loc4_,1);
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function sortByHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
         if(avEditor.sortPopup.visible)
         {
            btnOutHandler(param1);
         }
      }
      
      private function sortByOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.sortBtn.isGray || avEditor.sortPopup.visible)
         {
            return;
         }
         GuiManager.toolTip.init(param1.currentTarget as MovieClip,LocalizationManager.translateIdOnly(24502),0,-param1.currentTarget.height * 0.5,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function sortBtnHandler(param1:MouseEvent) : void
      {
         var _loc3_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc4_:String = "";
         if(param1.currentTarget.name == avEditor.sortPopup.sort6.name)
         {
            _loc3_ = _currClothesArray = _headItems;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort5.name)
         {
            _loc3_ = _currClothesArray = _neckItems;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort4.name)
         {
            _loc3_ = _currClothesArray = _backItems;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort3.name)
         {
            _loc3_ = _currClothesArray = _legItems;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort2.name)
         {
            _loc3_ = _currClothesArray = _tailItems;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort1.name)
         {
            if(_currClothesArray == _allNewestClothes)
            {
               _loc3_ = _currClothesArray = _allOldestClothes;
               _loc4_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Dn");
            }
            else
            {
               _loc3_ = _currClothesArray = _allNewestClothes;
               _loc4_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Up");
            }
         }
         avEditor.sortBtn.gotoAndStop(param1.currentTarget.name + _loc4_);
         if(_loc3_)
         {
            _itemClothingWindows.destroy();
            _itemClothingWindows = null;
            _mainScrollYPosition = 0;
            avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
            createItemWindows(_loc3_,avEditor.itemBlock);
         }
      }
      
      private function clothesDenAndTradeHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == avEditor.clothesBtnDown.name)
         {
            if(param1.currentTarget.name == avEditor.clothesBtnDown.name)
            {
               _currClothesArray = _allNewestClothes;
            }
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
         else if(param1.currentTarget.name == avEditor.tradeBtnDown.name)
         {
            if(avEditor.tradeBtnDown.isGray)
            {
               return;
            }
            if(param1.currentTarget.name == avEditor.tradeBtnDown.name)
            {
               _currClothesArray = _allNewestClothes;
            }
            avEditor.tradeBtnUp.visible = true;
            avEditor.tradeBtnDown.visible = false;
            avEditor.clothesBtnUp.visible = false;
            avEditor.clothesBtnDown.visible = true;
            avEditor.sortBtn.visible = false;
            avEditor.sortPopup.visible = false;
            avEditor.itemCounter.visible = false;
            avEditor.infoBtn.visible = true;
            avEditor.howTxt.visible = true;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(129,0))
            {
               avEditor.tradeHelpPopup.visible = true;
               LocalizationManager.translateId(avEditor.tradeHelpPopup.txt,11217);
               AchievementXtCommManager.requestSetUserVar(129,0);
            }
            createItemWindows(_currTradesArray,avEditor.itemBlock,true);
         }
      }
      
      private function clothesAndTradeOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == avEditor.clothesBtnDown.name)
            {
               GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(24505),0,-param1.currentTarget.height * 0.5 - 5,true);
               GuiManager.toolTip.startTimer(param1);
            }
            else if(param1.currentTarget.name == avEditor.tradeBtnDown.name)
            {
               GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(24504),0,-param1.currentTarget.height * 0.5 - 5,true);
               GuiManager.toolTip.startTimer(param1);
            }
         }
      }
      
      private function blockMouseBlockerHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseTradeHelpPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.tradeHelpPopup.visible = false;
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(22);
      }
      
      private function onInfoBtnOver(param1:MouseEvent) : void
      {
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(24506),0,-param1.currentTarget.height * 0.5 - 10,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onNameBarPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.namebarPopup.visible = false;
      }
      
      private function onColorNameBar(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         param1.stopPropagation();
         if(!_userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            UpsellManager.displayPopup("namebars","namebarColor");
            return;
         }
         _nameBarData = (_nameBarData & 0x0FFFFF00) + param1.currentTarget.id;
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
         avEditor.member.setColorBadgeAndXp(_nameBarData,_loc3_.questLevel,_loc3_.isMember);
         avEditor.member.setAvName(_worldAvatar.avName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName),false);
         if(_loc3_.questLevel > 0)
         {
            _loc2_ = avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
            avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(_loc2_);
            Utility.createXpShape(_loc3_.questLevel,_loc3_.isMember,avEditor.namebarPopup.advLockToggle.toggleBtn.shape[_loc2_].mouse.up.icon,null,2147483647);
         }
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.callUpdateInWindowWithInput(avEditor.member.getCurrColorId());
         }
      }
      
      private function onNameBarPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMemberNameBar(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnClick();
         avEditor.namebarPopup.visible = !avEditor.namebarPopup.visible;
         if(avEditor.namebarPopup.visible)
         {
            if(_namebarBadgeImages.length > 0)
            {
               createNamebarIconWindows();
            }
            else
            {
               GenericListXtCommManager.requestGenericList(110,onNamebarBadgeIdsLoaded);
            }
         }
      }
      
      private function onMemberNameBarOver(param1:MouseEvent) : void
      {
         if(_isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onAdvIconToggle(param1:MouseEvent) : void
      {
         var _loc2_:AvatarInfo = null;
         param1.stopPropagation();
         if(gMainFrame.userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            if(param1.currentTarget.currentLabel == "off" || param1.currentTarget.currentLabel == "startingOff")
            {
               param1.currentTarget.gotoAndPlay("on");
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = true;
            }
            else
            {
               param1.currentTarget.gotoAndPlay("off");
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
            }
            if(_nameBarData != -1)
            {
               _nameBarData = (_nameBarData & 0xF0FFFF) + ((param1.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            else
            {
               _nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xF0FFFF) + ((param1.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
            avEditor.member.setColorBadgeAndXp(_nameBarData,_loc2_.questLevel,_loc2_.isMember);
         }
         else
         {
            UpsellManager.displayPopup("namebars","nameBarAdvIcon");
         }
      }
      
      private function onAdvIconToggleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onAdvIconToggleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onNamebarBadgeIdsLoaded(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         _namebarBadgeDefs = [];
         _namebarBadgeMediaIds = [];
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = GuiManager.getNamebarBadgeDef(param1[_loc2_]);
            if(_loc3_ && (_loc3_.pendingFlagsBit == 0 || Boolean(gMainFrame.userInfo.isPendingFlagSet(_loc3_.pendingFlagsBit))))
            {
               _namebarBadgeDefs.push(_loc3_);
               _namebarBadgeMediaIds.push(_loc3_.mediaRefId);
            }
            _loc2_++;
         }
         createNamebarIconWindows();
      }
      
      private function onNamebarIconsLoaded(param1:MovieClip, param2:MovieClip, param3:int) : void
      {
         if(param1 && param2)
         {
            _namebarBadgeImages[param3] = {
               "iconMouse":param1,
               "iconUp":param2
            };
         }
      }
      
      private function createNamebarIconWindows() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Boolean = false;
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         while(avEditor.namebarPopup.itemWindow.numChildren > 1)
         {
            avEditor.namebarPopup.itemWindow.removeChildAt(avEditor.namebarPopup.itemWindow.numChildren - 1);
         }
         if(_namebarBadgeImages && _namebarBadgeImages.length > 0 && _namebarBadgeImages[0] != null)
         {
            _loc1_ = _namebarBadgeImages;
         }
         else
         {
            _loc1_ = _namebarBadgeMediaIds;
            _loc2_ = true;
         }
         _nameBarItemWindows = new WindowAndScrollbarGenerator();
         _nameBarItemWindows.init(avEditor.namebarPopup.itemWindow.width,_nameBarItemWinHeight,0,0,5,7,0,4,5,5,2.5,ItemWindowNameBarIcon,_loc1_,"",0,{
            "mouseDown":onNamebarBadgeIconDown,
            "mouseOver":onNamebarBadgeIconOver,
            "mouseOut":onNamebarBadgeIconOut
         },{
            "currColorId":avEditor.member.getCurrColorId(),
            "loadIcons":_loc2_,
            "callbackFunction":onNamebarIconsLoaded
         },null,true,false);
         avEditor.namebarPopup.itemWindow.addChild(_nameBarItemWindows);
      }
      
      private function onNamebarBadgeIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playSubMenuBtnRollover();
         param1.currentTarget.mouse.gotoAndStop(3);
      }
      
      private function onNamebarBadgeIconOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.mouse.gotoAndStop(1);
      }
      
      private function onNamebarBadgeIconDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!gMainFrame.userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            UpsellManager.displayPopup("namebars","namebarIcon");
            return;
         }
         var _loc4_:Object = _namebarBadgeDefs[param1.currentTarget.index];
         if(!_loc4_ || !gMainFrame.userInfo.isPendingFlagSet(_loc4_.pendingFlagsBit))
         {
            return;
         }
         var _loc2_:int = _loc4_.defId - 1;
         if(_nameBarData != -1)
         {
            _nameBarData = (_nameBarData & 0x0FFF00FF) + (_loc2_ << 8);
         }
         else
         {
            _nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0x0FFF00FF) + (_loc2_ << 8);
         }
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
         avEditor.member.setColorBadgeAndXp(_nameBarData,_loc3_.questLevel,_loc3_.isMember);
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onGemsRollOverOut(param1:MouseEvent) : void
      {
         if(param1.type == "rollOver")
         {
            reloadCurrencyCounts();
            _gemTimeline.play();
         }
         else
         {
            _gemTimeline.reverse();
         }
      }
      
      private function onTrophyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_achievementViewer && _achievementViewer.hasBeenInited)
            {
               if(_achievementViewer.visible)
               {
                  _achievementViewer.close();
               }
               else
               {
                  _achievementViewer.open();
               }
            }
            else
            {
               if(_achievementViewer == null)
               {
                  _achievementViewer = new AchievementViewer();
               }
               _achievementViewer.init(avEditor.trophy.x + 15,avEditor.trophy.y + avEditor.trophy.height * 0.5 - 5,avEditor,287);
            }
         }
      }
      
      private function onTrophyOver(param1:MouseEvent) : void
      {
         GuiManager.toolTip.init(param1.currentTarget as MovieClip,LocalizationManager.translateIdOnly(24501),0,-param1.currentTarget.height * 0.5 - 10,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onSearchTextInput(param1:Event) : void
      {
         if(_itemClothingWindows)
         {
            _itemClothingWindows.handleSearchInput(avEditor.searchBar.mouse.searchTxt.text);
         }
      }
      
      private function onSearchBarDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = avEditor.searchBar;
         AJAudio.playHudBtnClick();
         if(param1)
         {
            param1.stopPropagation();
            if(_loc2_.open)
            {
               if(!_loc2_.mouse.b.hitTestPoint(param1.stageX,param1.stageY,true))
               {
                  return;
               }
               avEditor.sortBtn.visible = true;
               _loc2_.open = false;
               _loc2_.mouse.searchTxt.text = "";
               onSearchTextInput(null);
            }
            else
            {
               _loc2_.open = true;
               gMainFrame.stage.focus = _loc2_.mouse.searchTxt;
               avEditor.sortPopup.visible = false;
               avEditor.sortBtn.visible = false;
            }
         }
         else
         {
            avEditor.sortBtn.visible = true;
            _loc2_.open = false;
            _loc2_.mouse.searchTxt.text = "";
            onSearchTextInput(null);
         }
         _loc2_.mouse.b.xBtn.visible = _loc2_.open;
         _loc2_.mouse.txt.visible = !_loc2_.open;
         _loc2_.mouse.searchTxt.visible = _loc2_.open;
         resizeSearchBtn(_loc2_.mouse,_loc2_.open);
      }
      
      private function onSearchBarOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playHudBtnRollover();
      }
      
      private function onSearchBarOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCleanUpBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(24509),true,onCleanUpConfirm);
         }
      }
      
      private function onCleanUpOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(param1.currentTarget as MovieClip,LocalizationManager.translateIdOnly(24503),0,-param1.currentTarget.height * 0.5 - 10,true);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onCleanUpConfirm(param1:Object) : void
      {
         var _loc4_:AccItemCollection = null;
         var _loc5_:IntItemCollection = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1.status)
         {
            _loc4_ = _avatarEditorView.inventoryBodyModItems;
            _loc5_ = new IntItemCollection();
            _loc2_ = 0;
            while(_loc2_ < _itemIdsOn.length)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_.getAccItem(_loc3_).invIdx == _itemIdsOn.getIntItem(_loc2_))
                  {
                     _loc5_.pushIntItem(_itemIdsOn.getIntItem(_loc2_));
                     break;
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
            _itemIdsOn = _loc5_;
            _itemIdsOff = new IntItemCollection();
            if(_mannequinDenItemHelper)
            {
               _mannequinDenItemHelper.mannequin.removeItems();
            }
            _avatarEditorView.hideAllClothingItems(_itemIdsOff);
            _itemClothingWindows.callUpdateInWindow();
            _currClothesArray = _allNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,_avatarEditorView.inventoryClothingItems);
            _headItems = Utility.sortItemsAll(_currClothesArray,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _neckItems = Utility.sortItemsAll(_currClothesArray,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _backItems = Utility.sortItemsAll(_currClothesArray,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _legItems = Utility.sortItemsAll(_currClothesArray,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _tailItems = Utility.sortItemsAll(_currClothesArray,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeItems = Utility.sortByItem(_currClothesArray,_worldAvatar.roomType) as AccItemCollection;
            _allOldestClothes = new AccItemCollection(_allNewestClothes.getCoreArray().concat().reverse());
            if(_currClothesArray)
            {
               _currClothesArray = _allNewestClothes;
            }
            _fullClothesList = _fullallNewestClothes = Utility.sortItemsByEnviroType(_worldAvatar.roomType,gMainFrame.userInfo.playerAvatarInfo.getFullItems());
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,8,9,10,_worldAvatar.roomType) as AccItemCollection;
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,7,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,6,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,5,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,4,-1,-1,_worldAvatar.roomType) as AccItemCollection;
            _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray) as DenItemCollection;
            _fullAllOldestClothes = new AccItemCollection(_fullallNewestClothes.getCoreArray().concat().reverse());
            _fullClothesList = _allNewestClothes;
            avEditor.cleanUpBtn.visible = false;
            _currTradesArray = new TradeItemCollection(gMainFrame.userInfo.getMyTradeList().concatCollection(null));
            _itemTradeWindows = null;
         }
      }
      
      private function updateCleanUpBtnVisibility() : void
      {
         avEditor.cleanUpBtn.visible = _itemIdsOn.length > 0 || _avatarEditorView.numClothingItemsShown > 0;
      }
      
      private function resizeSearchBtn(param1:MovieClip, param2:Boolean) : void
      {
         param1.m.width = param2 ? avEditor.searchBar.wideTextWidth : avEditor.searchBar.shortTextWidth;
         param1.b.x = param1.m.x + param1.m.width;
      }
      
      private function reloadCurrencyCounts() : void
      {
         avEditor.money.mouse.gems.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
         if(avEditor.money.mouse.tickets)
         {
            avEditor.money.mouse.tickets.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(1));
         }
         if(avEditor.money.mouse.diamonds)
         {
            avEditor.money.mouse.diamonds.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
         }
      }
      
      private function addListeners() : void
      {
         var _loc1_:int = 0;
         avEditor.addEventListener("mouseDown",onPopup,false,0,true);
         xBtn.addEventListener("mouseDown",onClose,false,0,true);
         avEditor.sortBtn.addEventListener("mouseDown",sortByHandler,false,0,true);
         avEditor.sortBtn.addEventListener("mouseOver",sortByOverHandler,false,0,true);
         avEditor.sortBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.sortPopup.sort6.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort5.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort4.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort3.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort2.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort1.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _lArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         _rArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         if(!_isForMannequin)
         {
            block.addEventListener("mouseDown",blockMouseBlockerHandler,false,0,true);
            block.addEventListener("rollOut",blockMouseBlockerHandler,false,0,true);
            block.addEventListener("rollOver",blockMouseBlockerHandler,false,0,true);
            avEditor.petsBtn.addEventListener("mouseDown",onPetBtnHandler,false,0,true);
            avEditor.petsBtn.addEventListener("mouseOver",onPetBtnOverHandler,false,0,true);
            avEditor.petsBtn.addEventListener("mouseOut",onPetBtnOutHandler,false,0,true);
            avEditor.shopBtn.addEventListener("mouseDown",onShopBtnHandler,false,0,true);
            avEditor.shopBtn.addEventListener("mouseOver",onShopBtnOverHandler,false,0,true);
            avEditor.shopBtn.addEventListener("mouseOut",onShopBtnOutHandler,false,0,true);
            avEditor.clothesBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
            avEditor.clothesBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
            avEditor.clothesBtnDown.addEventListener("mouseOver",clothesAndTradeOverHandler,false,0,true);
            avEditor.clothesBtnDown.addEventListener("mouseOut",btnOutHandler,false,0,true);
            if(Utility.canTrade())
            {
               avEditor.tradeBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
               avEditor.tradeBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
               avEditor.tradeBtnDown.addEventListener("mouseOver",clothesAndTradeOverHandler,false,0,true);
               avEditor.tradeBtnDown.addEventListener("mouseOut",btnOutHandler,false,0,true);
            }
            else
            {
               avEditor.tradeBtnDown.activateGrayState(true);
            }
            avEditor.tradeHelpPopup.bx.addEventListener("mouseDown",onCloseTradeHelpPopup,false,0,true);
            avEditor.infoBtn.addEventListener("mouseDown",onInfoBtnDown,false,0,true);
            avEditor.infoBtn.addEventListener("mouseOver",onInfoBtnOver,false,0,true);
            avEditor.infoBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            avEditor.namebarPopup.addEventListener("mouseDown",onNameBarPopup,false,0,true);
            avEditor.namebarPopup["bx"].addEventListener("mouseDown",onNameBarPopupClose,false,0,true);
            _loc1_ = 0;
            while(_loc1_ < _nameBars.length)
            {
               avEditor.namebarPopup[_nameBars[_loc1_]].addEventListener("mouseDown",onColorNameBar,false,0,true);
               _loc1_++;
            }
            avEditor.member.addEventListener("mouseDown",onMemberNameBar,false,0,true);
            avEditor.member.addEventListener("mouseOver",onMemberNameBarOver,false,0,true);
            avEditor.nonmember.addEventListener("mouseDown",onMemberNameBar,false,0,true);
            avEditor.nonmember.addEventListener("mouseOver",onMemberNameBarOver,false,0,true);
            avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseDown",onAdvIconToggle,false,0,true);
            avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseOver",onAdvIconToggleOver,false,0,true);
            avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseOut",onAdvIconToggleOut,false,0,true);
            avEditor.recycleClothesBtn.addEventListener("mouseDown",onRecycleClothesBtn,false,0,true);
            avEditor.recycleClothesBtn.addEventListener("mouseOver",onRecycleClothesBtnOver,false,0,true);
            avEditor.recycleClothesBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
            avEditor.money.addEventListener("rollOver",onGemsRollOverOut,false,0,true);
            avEditor.money.addEventListener("rollOut",onGemsRollOverOut,false,0,true);
            avEditor.trophy.addEventListener("mouseDown",onTrophyDown,false,0,true);
            avEditor.trophy.addEventListener("mouseOver",onTrophyOver,false,0,true);
            avEditor.trophy.addEventListener("mouseOut",btnOutHandler,false,0,true);
         }
         avEditor.searchBar.addEventListener("change",onSearchTextInput,false,0,true);
         avEditor.searchBar.addEventListener("mouseDown",onSearchBarDown,false,0,true);
         avEditor.searchBar.addEventListener("mouseOver",onSearchBarOver,false,0,true);
         avEditor.searchBar.addEventListener("mouseOut",onSearchBarOut,false,0,true);
         avEditor.cleanUpBtn.addEventListener("mouseDown",onCleanUpBtn,false,0,true);
         avEditor.cleanUpBtn.addEventListener("mouseOver",onCleanUpOver,false,0,true);
         avEditor.cleanUpBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         var _loc1_:int = 0;
         avEditor.removeEventListener("mouseDown",onPopup);
         xBtn.removeEventListener("mouseDown",onClose);
         avEditor.sortBtn.removeEventListener("mouseDown",sortByHandler);
         avEditor.sortBtn.removeEventListener("mouseOver",sortByOverHandler);
         avEditor.sortBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.sortPopup.sort6.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort5.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort4.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort3.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort2.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort1.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.colorsTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.patternTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.eyesTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         _lArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
         _rArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
         if(!_isForMannequin)
         {
            block.removeEventListener("mouseDown",blockMouseBlockerHandler);
            block.removeEventListener("rollOut",blockMouseBlockerHandler);
            block.removeEventListener("rollOver",blockMouseBlockerHandler);
            avEditor.petsBtn.removeEventListener("mouseDown",onPetBtnHandler);
            avEditor.petsBtn.removeEventListener("mouseOver",onPetBtnOverHandler);
            avEditor.petsBtn.removeEventListener("mouseOut",onPetBtnOutHandler);
            avEditor.shopBtn.removeEventListener("mouseDown",onShopBtnHandler);
            avEditor.shopBtn.removeEventListener("mouseOver",onShopBtnOverHandler);
            avEditor.shopBtn.removeEventListener("mouseOut",onShopBtnOutHandler);
            avEditor.clothesBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
            avEditor.clothesBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
            avEditor.clothesBtnDown.removeEventListener("mouseOver",clothesAndTradeOverHandler);
            avEditor.clothesBtnDown.removeEventListener("mouseOut",btnOutHandler);
            if(Utility.canTrade())
            {
               avEditor.tradeBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
               avEditor.tradeBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
               avEditor.clothesBtnDown.removeEventListener("mouseOver",clothesAndTradeOverHandler);
               avEditor.clothesBtnDown.removeEventListener("mouseOut",btnOutHandler);
            }
            avEditor.tradeHelpPopup.bx.removeEventListener("mouseDown",onCloseTradeHelpPopup);
            avEditor.infoBtn.removeEventListener("mouseDown",onInfoBtnDown);
            avEditor.infoBtn.removeEventListener("mouseOver",onInfoBtnOver);
            avEditor.infoBtn.removeEventListener("mouseOut",btnOutHandler);
            avEditor.namebarPopup.removeEventListener("mouseDown",onNameBarPopup);
            avEditor.namebarPopup["bx"].removeEventListener("mouseDown",onNameBarPopupClose);
            if(_nameBars)
            {
               _loc1_ = 0;
               while(_loc1_ < _nameBars.length)
               {
                  avEditor.namebarPopup[_nameBars[_loc1_]].removeEventListener("mouseDown",onColorNameBar);
                  _loc1_++;
               }
            }
            avEditor.member.removeEventListener("mouseDown",onMemberNameBar);
            avEditor.nonmember.removeEventListener("mouseDown",onMemberNameBar);
            avEditor.member.removeEventListener("mouseOver",onMemberNameBarOver);
            avEditor.nonmember.removeEventListener("mouseOver",onMemberNameBarOver);
            avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseDown",onAdvIconToggle);
            avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseOver",onAdvIconToggleOver);
            avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseOut",onAdvIconToggleOut);
            avEditor.recycleClothesBtn.removeEventListener("mouseDown",onRecycleClothesBtn);
            avEditor.recycleClothesBtn.removeEventListener("mouseOver",onRecycleClothesBtnOver);
            avEditor.recycleClothesBtn.removeEventListener("mouseOut",btnOutHandler);
            avEditor.money.removeEventListener("rollOver",onGemsRollOverOut);
            avEditor.money.removeEventListener("rollOut",onGemsRollOverOut);
            avEditor.trophy.removeEventListener("mouseDown",onTrophyDown);
            avEditor.trophy.removeEventListener("mouseOver",onTrophyOver);
            avEditor.trophy.removeEventListener("mouseOut",btnOutHandler);
         }
         avEditor.searchBar.removeEventListener("change",onSearchTextInput);
         avEditor.searchBar.removeEventListener("mouseDown",onSearchBarDown);
         avEditor.searchBar.removeEventListener("mouseOver",onSearchBarOver);
         avEditor.searchBar.removeEventListener("mouseOut",onSearchBarOut);
         avEditor.cleanUpBtn.removeEventListener("mouseDown",onCleanUpBtn);
         avEditor.cleanUpBtn.removeEventListener("mouseOver",onCleanUpOver);
         avEditor.cleanUpBtn.removeEventListener("mouseOut",btnOutHandler);
      }
   }
}

