package game.fashionShow
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarUtility;
   import avatar.CustomAvatarDef;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.IntItemCollection;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerBitmap;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.popup.SBPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Point;
   import gui.ColorTable;
   import gui.LoadingSpiral;
   import gui.SBScrollbar;
   import gui.WindowGenerator;
   import gui.itemWindows.ItemWindowOriginal;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class FashionShowAvatarEditor
   {
      public static const COLOR_TAB_ID:int = 0;
      
      public static const PATTERN_TAB_ID:int = 1;
      
      public static const EYE_TAB_ID:int = 2;
      
      private const CT_WIDTH:int = 240;
      
      private const CT_HEIGHT:int = 120;
      
      private const CT_NUM_COLS:int = 10;
      
      private const CT_NUM_ROWS:int = 4;
      
      private const CT_Y_TOP:int = 42;
      
      private const CT_Y_BOT:int = 200;
      
      private const CT_X:int = 20;
      
      private const CT_ID_C1:int = 0;
      
      private const CT_ID_C2:int = 1;
      
      private const CT_ID_EYES:int = 2;
      
      private const CT_ID_PATT:int = 3;
      
      private const NUM_X_WIN:int = 3;
      
      private const NUM_Y_WIN:int = 4;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const SCROLLBAR_GAP:int = 5;
      
      private const NAME_BAR_ICONS_LIST_ID:int = 38;
      
      public var avEditor:MovieClip;
      
      public var xBtn:MovieClip;
      
      public var block:Sprite;
      
      private var _avatarEditorPopup:SBPopup;
      
      private var _guiLayer:Sprite;
      
      private var _worldAvatar:Avatar;
      
      private var _avatarEditorView:FashionShowAvatarEditorView;
      
      private var _itemsOn:IntItemCollection;
      
      private var _itemsOff:IntItemCollection;
      
      private var _currClothesArray:AccItemCollection;
      
      private var _patterns:AccItemCollection;
      
      private var _eyes:AccItemCollection;
      
      private var _headItems:AccItemCollection;
      
      private var _neckItems:AccItemCollection;
      
      private var _backItems:AccItemCollection;
      
      private var _legItems:AccItemCollection;
      
      private var _tailItems:AccItemCollection;
      
      private var _allNewestClothes:AccItemCollection;
      
      private var _allOldestClothes:AccItemCollection;
      
      private var _currPattern:int;
      
      private var _currEye:int;
      
      private var _currentTab:int;
      
      private var _verifyCloseCallback:Function;
      
      private var _onCloseCallback:Function;
      
      private var _onCloseDemoCallback:Function;
      
      private var _waitForApResponse:Boolean;
      
      private var _waitForIuResponse:Boolean;
      
      private var _gamePalette:Array;
      
      private var _avatarPalette1:Array;
      
      private var _avatarPalette2:Array;
      
      private var _colorTableColor1:ColorTable;
      
      private var _colorTableColor2:ColorTable;
      
      private var _colorTablePatterns:ColorTable;
      
      private var _colorTableEyes:ColorTable;
      
      private var _cellWidth:Number;
      
      private var _cellHeight:Number;
      
      private var _numXColors:int;
      
      private var _numYColors:int;
      
      private var _currCustomPatternColorIdx:int;
      
      private var _customAvtIcon:MovieClip;
      
      private var _tabOpenId:int;
      
      private var _scrollBar:SBScrollbar;
      
      private var _itemWindows:WindowGenerator;
      
      private var _numItemsInCurrentArray:int;
      
      private var _nameBars:Array;
      
      private var _nameBarData:int;
      
      private var _ui:UserInfo;
      
      private var _nameBarScrollBar:SBScrollbar;
      
      private var _nameBarItemWindows:WindowGenerator;
      
      private var _nameBarNumIcons:int;
      
      private var _nameBarItemWinHeight:int;
      
      private var _iconsMediaHelperArray:Array;
      
      private var _iconsDataArray:Array;
      
      private var _iconImages:Array;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _loadingSpiral:LoadingSpiral;
      
      public function FashionShowAvatarEditor()
      {
         super();
      }
      
      public function init(param1:Boolean, param2:Avatar, param3:Sprite, param4:Function, param5:Function = null, param6:Function = null, param7:int = 450, param8:int = 250) : SBPopup
      {
         var _loc10_:Object = null;
         var _loc9_:ColorTransform = null;
         _worldAvatar = param2;
         _verifyCloseCallback = param4;
         _onCloseCallback = param5;
         _onCloseDemoCallback = param6;
         _guiLayer = param3;
         avEditor = GETDEFINITIONBYNAME("BD_AvatarEditorContent");
         if(!param1)
         {
            avEditor.ocean();
         }
         avEditor.petsBtn.visible = false;
         avEditor.shopBtn.visible = false;
         _avatarEditorPopup = new SBPopup(param3,GETDEFINITIONBYNAME("BD_AvatarEditorSkin"),avEditor,true,true,false,false,true);
         if(!param1)
         {
            _loc10_ = _avatarEditorPopup;
            _loc10_.content.curtain.ocean();
            _loc9_ = new ColorTransform(1,1,1,1,-30,0,0,0);
            _loc10_.skin.s.ba.transform.colorTransform = _loc9_;
         }
         _avatarEditorPopup.bxClosesPopup = false;
         xBtn = _avatarEditorPopup.skin.s["bx"];
         block = _avatarEditorPopup.skin.s["block"];
         block.visible = false;
         _avatarEditorPopup.x = param7;
         _avatarEditorPopup.y = param8;
         _gamePalette = PaletteHelper.gamePalette;
         _avatarPalette1 = PaletteHelper.avatarPalette1;
         _avatarPalette2 = PaletteHelper.avatarPalette2;
         _avatarEditorView = new FashionShowAvatarEditorView();
         _avatarEditorView.init(_worldAvatar);
         avEditor.avNameTxt.text = _worldAvatar.avName;
         _ui = gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName);
         _itemsOn = new IntItemCollection();
         _itemsOff = new IntItemCollection();
         _iconsMediaHelperArray = [];
         _iconsDataArray = [];
         _iconImages = [];
         _nameBars = new Array("goldBtn","blackBtn","blueBtn","brownBtn","greenBtn","pinkBtn","purpleBtn","redBtn","tealBtn","whiteBtn");
         _nameBarData = gMainFrame.userInfo.playerUserInfo.nameBarData;
         _nameBarItemWinHeight = avEditor.namebarItemWindow.height;
         _patterns = new AccItemCollection();
         _eyes = new AccItemCollection();
         _tabOpenId = 0;
         _currClothesArray = _allNewestClothes = _avatarEditorView.clothingItemArray;
         _headItems = Utility.sortItemsAll(_currClothesArray,8,9,10) as AccItemCollection;
         _neckItems = Utility.sortItemsAll(_currClothesArray,7) as AccItemCollection;
         _backItems = Utility.sortItemsAll(_currClothesArray,6) as AccItemCollection;
         _legItems = Utility.sortItemsAll(_currClothesArray,5) as AccItemCollection;
         _tailItems = Utility.sortItemsAll(_currClothesArray,4) as AccItemCollection;
         _allOldestClothes = new AccItemCollection(_allNewestClothes.getCoreArray().concat().reverse());
         setInitAssetVisibility();
         positionAndDrawAvatarView();
         createPatternsAndEyesArrays();
         _waitForApResponse = false;
         _waitForIuResponse = false;
         createItemWindows(_currClothesArray,avEditor.itemBlock);
         addListeners();
         KeepAlive.startKATimer(_avatarEditorPopup);
         if(_onCloseCallback == null)
         {
            xBtn.visible = false;
         }
         return _avatarEditorPopup;
      }
      
      public function destroy() : void
      {
         KeepAlive.stopKATimer(_avatarEditorPopup);
         removeListeners();
         if(_scrollBar)
         {
            _scrollBar.destroy();
         }
         _scrollBar = null;
         if(_itemWindows)
         {
            _itemWindows.destroy();
         }
         _itemWindows = null;
         if(_avatarEditorView)
         {
            avEditor.charBox.removeChild(_avatarEditorView);
            _avatarEditorView.destroy();
            _avatarEditorView = null;
            _itemsOn = null;
            _itemsOff = null;
            _patterns = null;
            _eyes = null;
            _avatarPalette1 = null;
            _avatarPalette2 = null;
         }
         _colorTableColor1.destroy();
         _colorTableColor2.destroy();
         _colorTablePatterns.destroy();
         _colorTableEyes.destroy();
         _iconsDataArray = null;
         _iconsMediaHelperArray = null;
         _nameBarData = -1;
         _nameBars = null;
         _ui = null;
         _iconImages = null;
         if(_nameBarScrollBar)
         {
            _nameBarScrollBar.destroy();
         }
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
         }
         _currClothesArray = null;
         _headItems = null;
         _neckItems = null;
         _backItems = null;
         _legItems = null;
         _tailItems = null;
         _allOldestClothes = null;
         _onCloseDemoCallback = null;
         _verifyCloseCallback = null;
         _onCloseCallback = null;
         _avatarEditorPopup.destroy();
         _avatarEditorPopup = null;
      }
      
      public function get onCloseCallback() : Function
      {
         return _onCloseCallback;
      }
      
      public function set onCloseCallback(param1:Function) : void
      {
         _onCloseCallback = param1;
      }
      
      private function setInitAssetVisibility() : void
      {
         var _loc5_:int = 0;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
         var _loc1_:Array = _avatarEditorView.colors;
         var _loc2_:* = _loc1_[0] >> 24 & 0xFF;
         var _loc6_:* = _loc1_[0] >> 16 & 0xFF;
         var _loc4_:* = _loc1_[1] >> 24 & 0xFF;
         var _loc3_:* = _loc1_[2] >> 24 & 0xFF;
         _colorTableColor1 = new ColorTable();
         _colorTableColor1.init(0,240,120,10,4,_gamePalette,_avatarPalette1,_loc2_,onColorChanged);
         _colorTableColor2 = new ColorTable();
         _colorTableColor2.init(1,240,120,10,4,_gamePalette,_avatarPalette2,_loc6_,onColorChanged);
         _colorTablePatterns = new ColorTable();
         _colorTablePatterns.init(3,240,120,10,4,_gamePalette,_avatarPalette1,_loc4_,onColorChanged);
         _colorTableEyes = new ColorTable();
         _colorTableEyes.init(2,240,120,10,4,_gamePalette,_avatarPalette1,_loc3_,onColorChanged);
         _colorTableColor1.x = 20;
         _colorTableColor1.y = 42;
         _colorTableColor2.x = 20;
         _colorTableColor2.y = 200;
         _colorTablePatterns.x = 20;
         _colorTablePatterns.y = 200;
         _colorTableEyes.x = 20;
         _colorTableEyes.y = 200;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
         avEditor.colorTableBlock.colors.addChild(_colorTableColor1);
         avEditor.colorTableBlock.colors.addChild(_colorTableColor2);
         LocalizationManager.translateId(avEditor.sort6.txt,11205);
         LocalizationManager.translateId(avEditor.sort5.txt,11206);
         LocalizationManager.translateId(avEditor.sort4.txt,11207);
         LocalizationManager.translateId(avEditor.sort3.txt,11208);
         LocalizationManager.translateId(avEditor.sort2.txt,11211);
         LocalizationManager.translateId(avEditor.sort1.txt,11212);
         avEditor.clothesBtnUp.visible = true;
         avEditor.clothesBtnDown.visible = false;
         avEditor.tradeBtnUp.visible = false;
         avEditor.tradeBtnDown.visible = false;
         avEditor.tradeWindow.visible = false;
         avEditor.blackout.visible = false;
         avEditor.patternTabUp.visible = false;
         avEditor.eyesTabUp.visible = false;
         avEditor.sortPopup.visible = false;
         avEditor.tradeHelpPopup.visible = false;
         avEditor.infoBtn.visible = false;
         avEditor.howTxt.visible = false;
         avEditor.tradePetBtnDown.visible = false;
         avEditor.tradePetBtnUp.visible = false;
         if(_allNewestClothes.length <= 0)
         {
            avEditor.sortBtn.visible = false;
         }
         avEditor.namebarPopup.visible = false;
         _loc5_ = 0;
         while(_loc5_ < _nameBars.length)
         {
            avEditor.namebarPopup[_nameBars[_loc5_]].txt.text = _worldAvatar.avName;
            avEditor.namebarPopup[_nameBars[_loc5_]].id = _loc5_;
            _loc5_++;
         }
         if(!gMainFrame.clientInfo.isMember)
         {
            avEditor.nonmember.visible = true;
            avEditor.member.visible = false;
         }
         else
         {
            avEditor.nonmember.visible = false;
            avEditor.member.visible = true;
            avEditor.avNameTxt.visible = false;
            avEditor.member.nubType = "buddy";
            avEditor.member.isBlocked = false;
            if(!_worldAvatar.isShaman && !_ui.isGuide)
            {
               avEditor.member.setNameBarColor(gMainFrame.userInfo.playerUserInfo.nameBarData);
            }
            else
            {
               avEditor.member.setNameBarColor(0);
            }
            avEditor.member.setAvName(_worldAvatar.avName,false);
         }
         avEditor.itemCountTxt.text = _allNewestClothes.length;
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         var _loc2_:Point = AvatarUtility.getAvatarViewPosition(_avatarEditorView.avTypeId);
         _avatarEditorView.x = _loc2_.x;
         _avatarEditorView.y = _loc2_.y;
         avEditor.charBox.addChild(_avatarEditorView);
         _avatarEditorView.playAnim(13);
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
      
      public function sendChangesRequest() : void
      {
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null)
            {
               _onCloseCallback();
            }
         }
      }
      
      private function itemUseResponse(param1:Array, param2:Array, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param3)
         {
            DebugUtility.debugTrace("FashionShowAvatarEditor: Changes made to avatar were successful");
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               DebugUtility.debugTrace("Item #" + param1[_loc4_] + ": PUT ON");
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               DebugUtility.debugTrace("Item #" + param2[_loc5_] + ": TAKEN OFF");
               _loc5_++;
            }
         }
         applyChanges(param3);
      }
      
      private function avatarPaintResponse(param1:Boolean) : void
      {
         var _loc3_:AvatarInfo = null;
         var _loc2_:Array = null;
         if(param1)
         {
            _loc3_ = gMainFrame.userInfo.playerAvatarInfo;
            _loc2_ = _avatarEditorView.colors;
            if(_loc3_)
            {
               _loc3_.colors = _loc2_;
            }
            gMainFrame.userInfo.playerUserInfo.nameBarData = _nameBarData;
            _worldAvatar.setColors(_loc2_[0],_loc2_[1],_loc2_[2]);
         }
         _waitForApResponse = false;
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null)
            {
               _onCloseCallback();
            }
         }
      }
      
      private function applyChanges(param1:Boolean) : void
      {
         if(!param1)
         {
            DebugUtility.debugTrace("WARNING: Changes were not made to your avatar");
         }
         _waitForIuResponse = false;
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null)
            {
               _onCloseCallback();
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_verifyCloseCallback != null)
         {
            _verifyCloseCallback();
         }
         else
         {
            sendChangesRequest();
         }
      }
      
      private function buttonTopicHandler(param1:MouseEvent) : void
      {
         if(_verifyCloseCallback != null)
         {
            onClose(param1);
         }
         else if(_onCloseDemoCallback != null)
         {
            _onCloseDemoCallback();
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
               DebugUtility.debugTrace("Error FashionShowAvatarEditor on colorTableTabClick handler: Invalid tab: " + param1.currentTarget.name);
            }
         }
      }
      
      private function colorTableTabOverClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name != avEditor.colorsTabDnBtn.name)
            {
               if(param1.currentTarget.name != avEditor.patternTabDnBtn.name)
               {
                  if(param1.currentTarget.name == avEditor.eyesTabDnBtn.name)
                  {
                  }
               }
            }
         }
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
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
            DebugUtility.debugTrace("Error FashionShowAvatarEditor on openTab: Invalid tabId: " + param1);
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
         var _loc2_:Object = null;
         avEditor.colorTableBlock.patternsAndEyes.visible = true;
         avEditor.colorTableBlock.colors.visible = false;
         while(avEditor.eyePattWindow.numChildren > 1)
         {
            avEditor.eyePattWindow.removeChildAt(1);
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
                  _loc2_ = gMainFrame.userInfo.getAvatarDefByAvType(_worldAvatar.customAvId,true);
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
                  avEditor.lArrowBtn.visible = false;
                  avEditor.rArrowBtn.visible = false;
               }
               if(_patterns.getAccItem(_currPattern))
               {
                  avEditor.eyePattWindow.addChild(_patterns.getAccItem(_currPattern).icon);
               }
            }
            else
            {
               avEditor.eyePattWindow.visible = false;
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
            LocalizationManager.translateId(avEditor.eyesPattTopTxt,11214);
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
                  avEditor.lArrowBtn.visible = false;
                  avEditor.rArrowBtn.visible = false;
               }
               if(_eyes.getAccItem(_currEye))
               {
                  avEditor.eyePattWindow.addChild(_eyes.getAccItem(_currEye).icon);
               }
            }
            else
            {
               avEditor.eyePattWindow.visible = false;
               avEditor.lArrowBtn.visible = false;
               avEditor.rArrowBtn.visible = false;
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
      
      private function sortItems(param1:Array, param2:int, param3:int, param4:int = -1, param5:int = -1) : Array
      {
         var _loc7_:Array = null;
         var _loc10_:int = 0;
         var _loc6_:Array = param1.concat();
         _loc7_ = [];
         var _loc8_:* = param2;
         var _loc9_:int = 0;
         while(_loc8_ < _loc6_.length)
         {
            _loc10_ = int(_loc6_[_loc8_].layerId);
            if(_loc10_ == param3 || _loc10_ == param4 || _loc10_ == param5)
            {
               _loc7_[_loc9_] = _loc6_[_loc8_];
               _loc6_.splice(_loc8_,1);
               _loc9_++;
               _loc8_--;
            }
            _loc8_++;
         }
         return _loc7_;
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
         if(param1.currentTarget.name == avEditor.lArrowBtn.name)
         {
            _loc4_ = -1;
         }
         else if(param1.currentTarget.name == avEditor.rArrowBtn.name)
         {
            _loc4_ = 1;
         }
         while(avEditor.eyePattWindow.numChildren > 1)
         {
            avEditor.eyePattWindow.removeChildAt(1);
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
            avEditor.eyePattWindow.addChild(_loc10_.getAccItem(_loc9_).icon);
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
            if(_itemsOn && _itemsOff)
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
                     if(_itemsOff.getCoreArray().indexOf(_loc4_) != -1)
                     {
                        _itemsOff.getCoreArray().splice(_itemsOff.getCoreArray().indexOf(_loc4_),1);
                     }
                     _loc8_ = 0;
                     while(_loc8_ < _loc3_.length)
                     {
                        if(param1.invIdx == _loc3_.getAccItem(_loc8_).invIdx && (_loc3_.getAccItem(_loc8_).type == 0 || _loc3_.getAccItem(_loc8_).enviroType == _worldAvatar.roomType))
                        {
                           _loc5_ = true;
                           if(!_loc3_.getAccItem(_loc8_).getInUse(_worldAvatar.avInvId))
                           {
                              if(_itemsOn.getCoreArray().indexOf(_loc4_) == -1)
                              {
                                 _itemsOn.pushIntItem(_loc4_);
                              }
                              break;
                           }
                        }
                        _loc8_++;
                     }
                     if(!_loc5_ && _itemsOn.getCoreArray().indexOf(_loc4_) == -1)
                     {
                        _itemsOn.pushIntItem(_loc4_);
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
            if(_itemsOn && _itemsOff)
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
                     if(_itemsOff.getCoreArray().indexOf(_loc2_) == -1)
                     {
                        _itemsOff.pushIntItem(_loc2_);
                     }
                     if(_itemsOn.getCoreArray().indexOf(_loc2_) != -1)
                     {
                        _itemsOn.getCoreArray().splice(_itemsOn.getCoreArray().indexOf(_loc2_),1);
                     }
                     break;
                  }
                  _loc3_++;
               }
            }
            _avatarEditorView.hideAccessory(param1);
         }
      }
      
      private function hideBodModWhenShowingBodMod(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc4_:AccItemCollection = _avatarEditorView.inventoryBodyModItems;
         var _loc2_:int = int(_itemsOn.getCoreArray().indexOf(param1.invIdx));
         if(_loc2_ == -1)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc4_.length)
            {
               if(_loc4_.getAccItem(_loc3_).invIdx == param1.invIdx)
               {
                  if(_itemsOff)
                  {
                     _itemsOff.pushIntItem(param1.invIdx);
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(_itemsOn)
         {
            if(_loc2_ != -1)
            {
               _itemsOn.getCoreArray().splice(_itemsOn.getCoreArray().indexOf(param1.invIdx),1);
            }
         }
      }
      
      private function createItemWindows(param1:AccItemCollection, param2:MovieClip) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Item = null;
         if(_scrollBar && _scrollBar.getScrollContentParent == param2)
         {
            _scrollBar.destroy();
            _scrollBar = null;
         }
         if(_itemWindows && _itemWindows.parent == param2)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(param2 == avEditor.itemBlock)
         {
            while(avEditor.itemBlock.numChildren > 0)
            {
               avEditor.itemBlock.removeChildAt(0);
            }
         }
         if(param1 == _allNewestClothes || param1 == _currClothesArray)
         {
            _loc6_ = int(param1.length);
            _loc7_ = Math.ceil(param1.length / 3) * 3;
            var _loc3_:Array = [];
            _loc4_ = 0;
            while(_loc4_ < _loc6_)
            {
               _loc5_ = null;
               if(param1.getAccItem(_loc4_))
               {
                  _loc5_ = param1.getAccItem(_loc4_);
               }
               if(_loc5_)
               {
                  _loc3_.push(_loc5_);
               }
               _loc4_++;
            }
            _itemWindows = new WindowGenerator();
            _itemWindows.init(3,4,Math.max(_loc7_,3 * 4),2,2,0,ItemWindowOriginal,_loc3_,"icon",{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{"avInvId":_worldAvatar});
            param2.addChild(_itemWindows);
            createScrollbar();
            return;
         }
         throw new Error("None of our lists match given items list");
      }
      
      private function createScrollbar() : void
      {
         if(_itemWindows)
         {
            _scrollBar = new SBScrollbar();
            _scrollBar.init(_itemWindows,_itemWindows.width,_itemWindows.boxHeight * 4 + 2 * (4 - 1) + 2,5,"scrollbar2",_itemWindows.boxHeight + 2);
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc3_:* = 0;
         var _loc2_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "down")
            {
               param1.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("over");
            }
            _loc3_ = 0;
            _loc2_ = 0;
            while(_loc2_ < _currClothesArray.length)
            {
               if(param1.currentTarget.index == _currClothesArray.getAccItem(_loc2_).invIdx)
               {
                  _loc3_ = _loc2_;
                  break;
               }
               _loc2_++;
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
            if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("down");
            }
            else
            {
               param1.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private function winMouseClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.clothesBtnUp.visible || avEditor.tradeWindow.visible && avEditor.tradeWindow.clothesBtnUp.visible)
         {
            _loc2_ = _currClothesArray.getAccItem(param1.currentTarget.index);
         }
         if(_loc2_)
         {
            if(!avEditor.tradeWindow.visible && avEditor.clothesBtnUp.visible)
            {
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse" && _loc2_.getInUse(_worldAvatar.avInvId))
               {
                  hideItem(Item(_loc2_));
                  param1.currentTarget.cir.gotoAndStop("over");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "downMouse" && !_loc2_.getInUse(_worldAvatar.avInvId))
               {
                  showItem(Item(_loc2_),hideItemWhenShowingItem);
                  param1.currentTarget.cir.gotoAndStop("downMouse");
               }
               else
               {
                  DebugUtility.debugTrace("Item is in use? But not in use? Huuuuuuuuh");
               }
            }
            else
            {
               DebugUtility.debugTrace("Wow nothing is visible? How is that possible?");
            }
            AJAudio.playSubMenuBtnClick();
         }
         else
         {
            DebugUtility.debugTrace("Curr Item is null, and the addBtn is not visible??");
         }
      }
      
      private function hideItemWhenShowingItem(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ < _currClothesArray.length)
         {
            if(_currClothesArray.getAccItem(_loc3_).invIdx == param1.invIdx)
            {
               _loc5_ = 0;
               while(_loc5_ < _worldAvatar.inventoryClothing.numItems)
               {
                  if(_worldAvatar.inventoryClothing.itemCollection.getAccItem(_loc5_).invIdx == param1.invIdx)
                  {
                     break;
                  }
                  _loc5_++;
               }
               if(_itemsOff)
               {
                  if(_worldAvatar.inventoryClothing.itemCollection.getAccItem(_loc5_).getInUse(_worldAvatar.avInvId))
                  {
                     _itemsOff.pushIntItem(param1.invIdx);
                  }
                  break;
               }
            }
            _loc3_++;
         }
         if(_itemsOn)
         {
            if(_itemsOn.getCoreArray().indexOf(param1.invIdx) != -1)
            {
               _itemsOn.getCoreArray().splice(_itemsOn.getCoreArray().indexOf(param1.invIdx),1);
            }
         }
         _loc4_ = 0;
         while(_loc4_ < _itemWindows.bg.numChildren)
         {
            _loc2_ = MovieClip(_itemWindows.bg.getChildAt(_loc4_));
            if(_currClothesArray.getAccItem(_loc2_.index).invIdx == param1.invIdx)
            {
               _loc2_.cir.gotoAndStop("up");
               break;
            }
            _loc4_++;
         }
      }
      
      private function sortByHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!avEditor.tradeWindow.visible)
         {
            avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
         }
         else
         {
            avEditor.tradeSort.visible = !avEditor.tradeSort.visible;
         }
      }
      
      private function sortBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:AccItemCollection = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.name == avEditor.sort6.name)
         {
            _loc2_ = _currClothesArray = _headItems;
         }
         else if(param1.currentTarget.name == avEditor.sort5.name)
         {
            _loc2_ = _currClothesArray = _neckItems;
         }
         else if(param1.currentTarget.name == (avEditor.sort4.name || avEditor.tradeSort4.name))
         {
            _loc2_ = _currClothesArray = _backItems;
         }
         else if(param1.currentTarget.name == (avEditor.sort3.name || avEditor.tradeSort3.name))
         {
            _loc2_ = _currClothesArray = _legItems;
         }
         else if(param1.currentTarget.name == (avEditor.sort2.name || avEditor.tradeSort2.name))
         {
            _loc2_ = _currClothesArray = _allNewestClothes;
         }
         else if(param1.currentTarget.name == (avEditor.sort1.name || avEditor.tradeSort1.name))
         {
            _loc2_ = _currClothesArray = _allOldestClothes;
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.bg.name)
         {
            avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         if(_loc2_)
         {
            if(avEditor.tradeWindow.visible)
            {
               avEditor.tradeSort.visible = !avEditor.tradeSort.visible;
               createItemWindows(_loc2_,avEditor.tradeItemBlock);
            }
            else
            {
               avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
               createItemWindows(_loc2_,avEditor.itemBlock);
            }
         }
      }
      
      private function onCloseTradeWindow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.tradeWindow.visible = !avEditor.tradeWindow.visible;
         avEditor.blackout.visible = !avEditor.blackout.visible;
         LocalizationManager.translateId(avEditor.tradeSort6.txt,11205);
         LocalizationManager.translateId(avEditor.tradeSort5.txt,11206);
         LocalizationManager.translateId(avEditor.tradeSort4.txt,11207);
         LocalizationManager.translateId(avEditor.tradeSort3.txt,11208);
         LocalizationManager.translateId(avEditor.tradeSort2.txt,11211);
         LocalizationManager.translateId(avEditor.tradeSort1.txt,11212);
         avEditor.tradeSort5.visible = true;
         avEditor.tradeSort6.visible = true;
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
      }
      
      private function onNameBarPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.namebarPopup.visible = false;
      }
      
      private function onColorNameBar(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _nameBarData = (_nameBarData & 0xFF00) + param1.currentTarget.id;
         avEditor.member.setNameBarColor(_nameBarData);
         avEditor.member.setAvName(_worldAvatar.avName,false);
         createIconWindows(_iconImages.length * 0.5);
      }
      
      private function onNameBarPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onIconIdsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_iconsDataArray.length != param2.length)
         {
            _iconsDataArray = param2.slice();
         }
         createIconWindows(param2.length);
      }
      
      private function loadIcon(param1:int, param2:int) : void
      {
         var _loc3_:MediaHelper = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2);
         _iconsMediaHelperArray.push(_loc3_);
         _loc3_ = new MediaHelper();
         _loc3_.init(param1,onIconsLoaded,param2 + 1);
         _iconsMediaHelperArray.push(_loc3_);
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _iconImages[param1.passback] = param1;
            if(param1.passback % 2 == 0)
            {
               _iconsDataArray[param1.passback * 0.5].mouse.icon.addChild(param1);
            }
            else
            {
               _iconsDataArray[(param1.passback - 1) * 0.5].up.icon.addChild(param1);
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
      }
      
      private function createIconWindows(param1:int) : void
      {
      }
      
      private function onIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playSubMenuBtnRollover();
         param1.currentTarget.mouse.gotoAndStop(3);
      }
      
      private function onIconOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.mouse.gotoAndStop(1);
      }
      
      private function onIconDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playSubMenuBtnClick();
         if(_nameBarData != -1)
         {
            _nameBarData = (_nameBarData & 0xFF) + (param1.currentTarget.id << 8);
         }
         else
         {
            _nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xFF) + (param1.currentTarget.id << 8);
         }
         avEditor.member.setNameBarColor(_nameBarData);
      }
      
      private function addListeners() : void
      {
         if(_avatarEditorPopup)
         {
            xBtn.addEventListener("mouseDown",onClose,false,0,true);
            block.addEventListener("mouseDown",blockMouseBlockerHandler,false,0,true);
            block.addEventListener("rollOut",blockMouseBlockerHandler,false,0,true);
            block.addEventListener("rollOver",blockMouseBlockerHandler,false,0,true);
         }
         if(!avEditor)
         {
            return;
         }
         avEditor.button_topic.addEventListener("mouseDown",buttonTopicHandler,false,0,true);
         avEditor.sortBtn.addEventListener("mouseDown",sortByHandler,false,0,true);
         avEditor.sort6.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sort5.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sort4.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sort3.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sort2.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sort1.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.bg.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.lArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         avEditor.rArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         if(_avatarEditorPopup)
         {
            xBtn.removeEventListener("mouseDown",onClose);
            block.removeEventListener("mouseDown",blockMouseBlockerHandler);
            block.removeEventListener("rollOut",blockMouseBlockerHandler);
            block.removeEventListener("rollOver",blockMouseBlockerHandler);
         }
         if(!avEditor)
         {
            return;
         }
         avEditor.sortBtn.removeEventListener("mouseDown",sortByHandler);
         avEditor.tradeSortBtn.removeEventListener("mouseDown",sortByHandler);
         avEditor.sort6.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sort5.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sort4.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sort3.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sort2.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sort1.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.bg.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.colorsTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.patternTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.eyesTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.lArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
         avEditor.rArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
      }
   }
}

