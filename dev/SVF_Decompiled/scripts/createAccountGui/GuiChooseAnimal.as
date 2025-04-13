package createAccountGui
{
   import avatar.Avatar;
   import avatar.AvatarItem;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.NewWorldAvatar;
   import collection.IitemCollection;
   import com.greensock.TweenLite;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import createAccountFlow.CreateAccountGui;
   import currency.UserCurrency;
   import diamond.DiamondItem;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.LoadingSpiral;
   import gui.UpsellManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.itemWindows.ItemWindowAvatarOrPetSelect;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class GuiChooseAnimal
   {
      private const REGISTRATION_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const REGISTRATION_PANEL_X_DIRECTION:Number = -432;
      
      private const ANIMAL_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const ANIMAL_PANEL_X_DIRECTION:Number = -489;
      
      private const BACKGROUND_PANEL_TWEEN_TIME:Number = 0.5;
      
      private const BACKGROUND_PANEL_X_DIRECTION:Number = -450;
      
      private var _chooseScreen:MovieClip;
      
      private var _voBtn:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _itemWindow:MovieClip;
      
      private var _avatarHolder:MovieClip;
      
      private var _currAvatarImage:MovieClip;
      
      private var _currAvt:Avatar;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _buyBtnDiamondGreen:MovieClip;
      
      private var _buyBtnDiamondRed:MovieClip;
      
      private var _tag:MovieClip;
      
      private var _amlNameTxt:TextField;
      
      private var _titleText:TextField;
      
      private var _avatarWindows:WindowAndScrollbarGenerator;
      
      private var _itemsLoadingSpiral:LoadingSpiral;
      
      private var _currAvatarItems:IitemCollection;
      
      private var _currAvatarTypes:Array;
      
      private var _currCreationAvatars:Array;
      
      private var _oceanOnlyAvatarItems:IitemCollection;
      
      private var _oceanOnlyTypes:Array;
      
      private var _usableAvatarItems:IitemCollection;
      
      private var _usableAvatarTypes:Array;
      
      private var _usableCreationAvatars:Array;
      
      private var _usableCreationOceanAvatars:Array;
      
      private var _currBG:String;
      
      private var _avatarNamesByType:Object;
      
      private var _newAvatarFacilitator:NewWorldAvatar;
      
      private var _currType:int;
      
      private var _myCurrencyCount:int;
      
      private var _currCost:int;
      
      private var _currIndex:int;
      
      private var _isChoosingOceanAvatars:Boolean;
      
      private var _isChoosingFirstNonMember:Boolean;
      
      private var _isFromWorld:Boolean;
      
      private var _hasEnoughGems:Boolean;
      
      private var _isCreatingWithoutChoosing:Boolean;
      
      private var _diamondCost:int;
      
      private var _currencyType:int;
      
      private var _scrollYValue:int;
      
      private var _originalWindowsHeight:int;
      
      private var _originalWindowsWidth:int;
      
      private var _isMovingScreens:Boolean;
      
      private var _registrationPanel:MovieClip;
      
      private var _avatarSelect:MovieClip;
      
      private var _isFastPass:Boolean;
      
      private var _isRecreatingIcons:Boolean;
      
      private var _iItem:Iitem;
      
      private var _avatarTypeBeingChosen:int;
      
      private var _animalTween:TweenLite;
      
      private var _backgroundTween:TweenLite;
      
      private var _chooseAnimalTween:TweenLite;
      
      private var _onLoaded:Function;
      
      public function GuiChooseAnimal(param1:Object, param2:Boolean, param3:Boolean, param4:Function)
      {
         super();
         _chooseScreen = param2 ? param1.registrationPanel.chooseAnimal : param1.registrationPanel.chooseAnimal;
         _onLoaded = param4;
         _registrationPanel = MovieClip(_chooseScreen.parent);
         _avatarSelect = MovieClip(_chooseScreen.parent.parent);
         _amlNameTxt = _chooseScreen.animalNameText;
         _itemWindow = _chooseScreen.itemWindow;
         _titleText = _chooseScreen.titleText;
         _isFromWorld = param2;
         _isFastPass = param3;
         _voBtn = _chooseScreen.vo_btn;
         _playBtn = param1.play_btn;
         _backBtn = param1.back_btn;
         _nextBtn = param1.next_btn;
         _avatarHolder = param1.allAvatars;
         if(param2)
         {
            _buyBtnGreen = param1.buy_btn_green;
            _buyBtnRed = param1.buy_btn_red;
            _buyBtnDiamondGreen = param1.diamond_buy_btn_green;
            _buyBtnDiamondRed = param1.diamond_buy_btn_red;
            _tag = _chooseScreen.tag;
         }
      }
      
      public function init() : void
      {
         if(!_isFromWorld || _isFastPass)
         {
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
            _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
         }
         if(_isFromWorld)
         {
            _buyBtnGreen.visible = false;
            _buyBtnRed.visible = false;
            _buyBtnDiamondGreen.visible = false;
            _buyBtnDiamondRed.visible = false;
            _tag.visible = false;
            _voBtn.visible = _isFastPass;
            _chooseScreen.reg.visible = !_isFastPass;
            _chooseScreen.fastTrack.visible = _isFastPass;
         }
         _backBtn.visible = false;
         _playBtn.visible = false;
         _amlNameTxt.text = "";
         _avatarTypeBeingChosen = -1;
         _myCurrencyCount = UserCurrency.getCurrency(0);
         _newAvatarFacilitator = new NewWorldAvatar();
         _usableAvatarItems = new IitemCollection();
         _usableAvatarTypes = [];
         _usableCreationAvatars = [];
         _usableCreationOceanAvatars = [];
         _currAvatarItems = new IitemCollection();
         _currAvatarTypes = [];
         _currCreationAvatars = [];
         _avatarNamesByType = [];
         _oceanOnlyAvatarItems = new IitemCollection();
         _itemsLoadingSpiral = new LoadingSpiral(_itemWindow,_itemWindow.width * 0.5,_itemWindow.height * 0.5);
         _itemsLoadingSpiral.visible = true;
         if(gMainFrame.clientInfo.selectedAvatarId != null && gMainFrame.clientInfo.selectedAvatarId > 0)
         {
            _avatarTypeBeingChosen = gMainFrame.clientInfo.selectedAvatarId;
         }
         enterFromBoth();
         if((!_isFromWorld || _isFastPass) && CreateAccountGui.vo1Sound)
         {
            setupIcons();
         }
      }
      
      public function destroy() : void
      {
         if(_avatarWindows)
         {
            _avatarWindows.destroy();
            _avatarWindows = null;
         }
      }
      
      public function destroyReloadedItems() : void
      {
         if(_avatarWindows)
         {
            _avatarWindows.destroy();
            _avatarWindows = null;
         }
      }
      
      public function setup(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:Boolean = false, param6:Iitem = null) : void
      {
         _isMovingScreens = false;
         _currencyType = currencyType;
         _isFastPass = param5;
         _myCurrencyCount = UserCurrency.getCurrency(currencyType);
         _isChoosingOceanAvatars = param1;
         _isChoosingFirstNonMember = param2;
         _nextBtn.visible = true;
         _buyBtnGreen.visible = false;
         _buyBtnRed.visible = false;
         _buyBtnDiamondGreen.visible = false;
         _buyBtnDiamondRed.visible = false;
         _backBtn.visible = false;
         _isCreatingWithoutChoosing = param4;
         _iItem = param6;
         _avatarTypeBeingChosen = param3;
         setupIcons(true);
      }
      
      public function switchScreens(param1:Boolean, param2:int) : Boolean
      {
         if(_chooseAnimalTween)
         {
            _chooseAnimalTween.progress(1);
            _animalTween.progress(1);
            _backgroundTween.progress(1);
         }
         switch(param2 - -1)
         {
            case 0:
               enterFromBoth();
               break;
            case 1:
               if(param1 && leaveToNext())
               {
                  GuiAvatarCreationAssets.screenPosition++;
                  _chooseAnimalTween = new TweenLite(_chooseScreen,_isCreatingWithoutChoosing ? 0 : 0.5,{"x":"+=" + -432 * (param1 ? 1 : -1)});
                  _animalTween = new TweenLite(_currAvatarImage,_isCreatingWithoutChoosing ? 0 : 0.5,{"x":"+=" + -489 * (param1 ? 1 : -1)});
                  _backgroundTween = new TweenLite(_avatarSelect.bg[_currBG + "Bg"],_isCreatingWithoutChoosing ? 0 : 0.5,{"x":"+=" + -450 * (param1 ? 1 : -1)});
                  leaveToNext();
                  break;
               }
               if(!param1)
               {
                  GuiAvatarCreationAssets.screenPosition--;
                  if(!_isFromWorld || _isFastPass)
                  {
                     if(CreateAccountGui.vo1Sound)
                     {
                        CreateAccountGui.vo1Sound.stop();
                     }
                     _voBtn.stop();
                     _voBtn.gotoAndStop(1);
                  }
                  _newAvatarFacilitator.nameTypeScreenDone();
                  _isMovingScreens = true;
                  break;
               }
               return false;
               break;
            case 2:
               if(_isFromWorld)
               {
                  _buyBtnGreen.visible = false;
                  _buyBtnRed.visible = false;
                  _buyBtnDiamondGreen.visible = false;
                  _buyBtnDiamondRed.visible = false;
                  _nextBtn.visible = true;
               }
               _chooseAnimalTween = new TweenLite(_chooseScreen,_isCreatingWithoutChoosing ? 0 : 0.5,{"x":"+=" + -432 * (param1 ? 1 : -1)});
               _animalTween = new TweenLite(_currAvatarImage,_isCreatingWithoutChoosing ? 0 : 0.5,{"x":"+=" + -489 * (param1 ? 1 : -1)});
               enterFromBoth();
         }
         return true;
      }
      
      private function enterFromBoth() : void
      {
         if((!_isFromWorld || _isFastPass) && CreateAccountGui.vo1Sound)
         {
            if(!CreateAccountGui.vo1Sound.isPlaying)
            {
               CreateAccountGui.vo1Sound.play();
               if(CreateAccountGui.vo1Sound.sc)
               {
                  CreateAccountGui.vo1Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
                  _voBtn.play();
               }
            }
         }
         _isMovingScreens = false;
         if(_isFromWorld)
         {
            SBTracker.trackPageview("/game/play/popup/avatarCreation/ChooseAnimal");
         }
         else
         {
            CreateAccountGui.trackUserCreateAccountPageChange("ChooseAnimal");
         }
      }
      
      private function leaveToNext() : Boolean
      {
         var _loc1_:Object = null;
         if(_nextBtn.isGray)
         {
            return false;
         }
         if(!_isFromWorld || _isFastPass)
         {
            if(CreateAccountGui.vo1Sound)
            {
               CreateAccountGui.vo1Sound.stop();
            }
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         if(!gMainFrame.userInfo.isMember)
         {
            _loc1_ = AvatarUtility.findAvDefByType(_currType,currCustomAvId);
            if(_loc1_.isMemberOnly)
            {
               if(_isCreatingWithoutChoosing)
               {
                  return true;
               }
               UpsellManager.displayPopup("animals","createMembersOnlyAvatar");
            }
            else if(AvatarUtility.numNonMemberAvatars() >= 2 && !_isChoosingFirstNonMember && !_isCreatingWithoutChoosing)
            {
               UpsellManager.displayPopup("animalSlots","buyThirdAvatar");
            }
            else
            {
               if(!(_isChoosingFirstNonMember && _loc1_.enviroFlag == 2))
               {
                  _isMovingScreens = true;
                  return true;
               }
               new SBOkPopup(_avatarSelect.parent.parent,LocalizationManager.translateIdOnly(14689));
            }
            return false;
         }
         _isMovingScreens = true;
         return true;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return _isCreatingWithoutChoosing;
      }
      
      public function get currAvatarImage() : MovieClip
      {
         return _currAvatarImage;
      }
      
      public function get currAvatar() : Avatar
      {
         return _currAvt;
      }
      
      public function get currBG() : String
      {
         return _currBG;
      }
      
      public function get currType() : int
      {
         return _currType;
      }
      
      public function get currCustomAvId() : int
      {
         if(_currAvt)
         {
            return _currAvt.customAvId;
         }
         return -1;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return _hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return _diamondCost == -1 ? _currCost : _diamondCost;
      }
      
      public function get currAvatarName() : String
      {
         return LocalizationManager.translateIdOnly(_avatarNamesByType[_currType + (currCustomAvId == -1 ? "0" : String(currCustomAvId))]);
      }
      
      public function get isDiamondAvatar() : Boolean
      {
         var _loc1_:Object = AvatarUtility.findAvDefByType(_currType,currCustomAvId);
         if(_loc1_ && _loc1_.diamondItem)
         {
            return true;
         }
         return false;
      }
      
      public function get avatarDiamondDefId() : int
      {
         var _loc1_:Object = AvatarUtility.findAvDefByType(_currType,currCustomAvId);
         if(_loc1_ && _loc1_.diamondItem)
         {
            return _loc1_.diamondItem.defId;
         }
         return -1;
      }
      
      public function getCurrentIndex() : int
      {
         return _currIndex;
      }
      
      private function setCurrAvatarNameText() : void
      {
         var _loc1_:int = parseInt(_currType + (currCustomAvId == -1 ? "0" : String(currCustomAvId)));
         if(_avatarNamesByType[_loc1_])
         {
            LocalizationManager.translateId(_amlNameTxt,_avatarNamesByType[_loc1_]);
         }
      }
      
      private function setupIcons(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc3_:Avatar = null;
         var _loc7_:AvatarItem = null;
         var _loc6_:int = 0;
         var _loc4_:Array = AvatarUtility.creationAvatarsList;
         _usableAvatarItems = new IitemCollection();
         _usableAvatarTypes = [];
         _oceanOnlyAvatarItems = new IitemCollection();
         _oceanOnlyTypes = [];
         _usableCreationAvatars = [];
         _usableCreationOceanAvatars = [];
         _isRecreatingIcons = param1;
         _loc6_ = 0;
         while(_loc6_ < _loc4_.length)
         {
            _loc5_ = AvatarUtility.getAvatarDefByIndex(_loc6_);
            if(_loc5_)
            {
               _loc3_ = _loc4_[_loc6_];
               _loc2_ = int(gMainFrame.userInfo.getAvatarDefByAvatar(_loc3_).defId);
               if(!((!_isFromWorld || _isFastPass) && (_loc5_.diamondItem || _loc5_.isMemberOnly || !Utility.isLand(_loc5_.enviroFlag))))
               {
                  if(!((!_isFromWorld || _isFastPass) && (AvatarUtility.isEndangered(_loc5_.availability) || AvatarUtility.isExtinct(_loc5_.availability))))
                  {
                     if(_loc5_.diamondItem || AvatarUtility.getAvatarDefIsViewable(_loc3_,_loc3_.customAvId != -1))
                     {
                        _loc7_ = new AvatarItem();
                        _loc7_.init(_loc2_,_loc6_,true,_loc3_.customAvId,_loc5_.diamondItem);
                        _usableAvatarItems.pushIitem(_loc7_);
                        _usableAvatarTypes.push(_loc3_.avTypeId);
                        _usableCreationAvatars.push(_loc3_);
                        if(Utility.isOcean(_loc5_.enviroFlag) && !_isFastPass)
                        {
                           _oceanOnlyAvatarItems.pushIitem(_loc7_);
                           _oceanOnlyTypes.push(_loc3_.avTypeId);
                           _usableCreationOceanAvatars.push(_loc3_);
                        }
                     }
                     _avatarNamesByType[parseInt(_loc3_.avTypeId + (_loc3_.customAvId != -1 ? String(_loc3_.customAvId) : "0"))] = gMainFrame.userInfo.getAvatarDefByAvatar(_loc3_).titleStrRef;
                  }
               }
            }
            _loc6_++;
         }
         filterItemLists();
      }
      
      private function pickRandomAvatar(param1:int = -1) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1 == -1)
         {
            _currIndex = Math.floor(Math.random() * (_currAvatarTypes.length - 1 - 0 + 1)) + 0;
         }
         else
         {
            _loc2_ = int(_iItem && _iItem is AvatarItem ? (_iItem as AvatarItem).customAvType : -1);
            _loc3_ = 0;
            while(_loc3_ < _currAvatarTypes.length)
            {
               if(AvatarItem(_currAvatarItems.getIitem(_loc3_)).customAvType == _loc2_ && AvatarView(AvatarItem(_currAvatarItems.getIitem(_loc3_)).icon).avTypeId == param1)
               {
                  _currIndex = _loc3_;
                  break;
               }
               _loc3_++;
            }
         }
         _currType = _currAvatarTypes[_currIndex];
         _currAvt = _currCreationAvatars[_currIndex];
         setupCurrAvatar();
      }
      
      private function filterItemLists() : void
      {
         GenericListXtCommManager.filterIitems(_usableAvatarItems,false,_usableAvatarTypes,_usableCreationAvatars);
         GenericListXtCommManager.filterIitems(_oceanOnlyAvatarItems,false,_oceanOnlyTypes,_usableCreationOceanAvatars);
         if(_isChoosingOceanAvatars)
         {
            _currAvatarItems = _oceanOnlyAvatarItems;
            _currAvatarTypes = _oceanOnlyTypes;
            _currCreationAvatars = _usableCreationOceanAvatars;
         }
         else
         {
            _currAvatarItems = _usableAvatarItems;
            _currAvatarTypes = _usableAvatarTypes;
            _currCreationAvatars = _usableCreationAvatars;
         }
         if(_isRecreatingIcons || !_isFromWorld)
         {
            pickRandomAvatar(_avatarTypeBeingChosen);
         }
         if(!_isCreatingWithoutChoosing)
         {
            createAvatarWindows();
         }
         if(_isRecreatingIcons)
         {
            if(_currAvatarImage && _currBG)
            {
               if(!_isCreatingWithoutChoosing)
               {
                  _nextBtn.visible = true;
                  _tag.visible = true;
               }
               else
               {
                  _nextBtn.visible = false;
                  _tag.visible = false;
               }
            }
         }
         if(_onLoaded != null)
         {
            _onLoaded();
            _onLoaded = null;
         }
      }
      
      private function createAvatarWindows() : void
      {
         if(_avatarWindows && _avatarWindows.numWindowsCreated > 0)
         {
            _itemWindow.addChild(_avatarWindows);
            _avatarWindows.scrollToIndex(_currIndex / 3,true);
            if(_isFromWorld && !_isFastPass)
            {
               _scrollYValue = _avatarWindows.scrollYValue;
            }
            return;
         }
         _itemsLoadingSpiral.visible = true;
         if(_avatarWindows)
         {
            _scrollYValue = _avatarWindows.scrollYValue;
         }
         if(_avatarWindows)
         {
            _avatarWindows.destroy();
            _avatarWindows = null;
         }
         _avatarWindows = new WindowAndScrollbarGenerator();
         _avatarWindows.init(_itemWindow.width,_itemWindow.height,3,_scrollYValue,3,3,_currAvatarItems.length,2,2,1,1,ItemWindowAvatarOrPetSelect,_currAvatarItems.getCoreArray(),"",0,{
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         },{
            "forCreation":!_isFromWorld || _isFastPass,
            "avTypes":_currAvatarTypes,
            "creationAvatars":_currCreationAvatars,
            "selectedIndex":getCurrentIndex
         },onAvatarIconWindowsLoaded,false,false,false);
         _itemWindow.addChild(_avatarWindows);
      }
      
      private function onAvatarIconWindowsLoaded() : void
      {
         if(_isFromWorld && !_isFastPass)
         {
            _originalWindowsHeight = _avatarWindows.height;
            _originalWindowsWidth = _avatarWindows.width;
            _avatarWindows.scrollToIndex(_currIndex / 3,true);
         }
         _itemsLoadingSpiral.visible = false;
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_isMovingScreens && _currIndex != param1.currentTarget.index)
         {
            MovieClip(_avatarWindows.bg.getChildAt(_currIndex)).deselect();
            _currIndex = param1.currentTarget.index;
            _currType = _currAvatarTypes[param1.currentTarget.index];
            _currAvt = _currCreationAvatars[_currIndex];
            if(param1.currentTarget.currWindow.currentFrameLabel != (!!param1.currentTarget.isDiamond ? "diamond_down" : "down"))
            {
               param1.currentTarget.currWindow.gotoAndStop(!!param1.currentTarget.isDiamond ? "diamond_down" : "down");
            }
            param1.currentTarget.setupLayers();
            setupCurrAvatar();
         }
      }
      
      private function setupCurrAvatar() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc5_:Array = _avatarHolder.currentLabels;
         var _loc4_:String = currCustomAvId != -1 ? "special_" : "";
         var _loc1_:int = currCustomAvId != -1 ? currCustomAvId : _currType;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            _loc2_ = _loc5_[_loc3_].name.split("_");
            if(_loc4_ == "" && _loc2_[1] == _loc1_ || _loc4_.indexOf(_loc2_[0]) >= 0 && _loc2_[2] == _loc1_)
            {
               _currBG = _loc4_ == "" ? _loc2_[0] : _loc2_[1];
               _avatarHolder.gotoAndStop(_loc4_ + _currBG + "_" + _loc1_);
               _currAvatarImage = _avatarHolder[_loc4_ + "avatar" + _loc1_];
               break;
            }
            _loc3_++;
         }
         if(_currAvatarImage)
         {
            _animalTween = new TweenLite(_currAvatarImage,0.5,{"alpha":1});
            setupAvatarTextItems();
         }
         if(_currBG)
         {
            if(_avatarSelect.bg.currentFrameLabel != _currBG)
            {
               _avatarSelect.bg.gotoAndStop(_currBG);
               _backgroundTween = new TweenLite(_avatarSelect.bg[_currBG + "Bg"],0.5,{"alpha":1});
            }
         }
      }
      
      private function setupAvatarTextItems() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Boolean = false;
         if(_currAvatarImage)
         {
            setCurrAvatarNameText();
            _loc2_ = AvatarUtility.findAvDefByType(_currType,currCustomAvId);
            if(_isFromWorld)
            {
               _loc1_ = (_iItem && _iItem.isDiamond || _loc2_.diamondItem) && !AvatarUtility.getAvatarDefIsViewableWithAvId(_currType,currCustomAvId);
               if(_loc1_)
               {
                  _myCurrencyCount = UserCurrency.getCurrency(3);
                  if(_iItem && _iItem.isDiamond)
                  {
                     _currCost = _diamondCost = _iItem.value;
                  }
                  else
                  {
                     _currCost = _diamondCost = (_loc2_.diamondItem as DiamondItem).value;
                  }
               }
               else
               {
                  _myCurrencyCount = UserCurrency.getCurrency(0);
                  _diamondCost = -1;
                  if(_iItem && _iItem.isOnSale)
                  {
                     _currCost = Math.ceil(_loc2_.cost * 0.5);
                  }
                  else
                  {
                     _currCost = _loc2_.cost;
                  }
               }
               if(!_isChoosingFirstNonMember)
               {
                  _tag.txt.text = Utility.convertNumberToString(_currCost);
                  if(_myCurrencyCount < _currCost)
                  {
                     _hasEnoughGems = false;
                     _tag.gotoAndStop(_loc1_ ? "diamondRed" : "red");
                     _tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     _hasEnoughGems = true;
                     _tag.gotoAndStop(_loc1_ ? "diamondGreen" : "green");
                     _tag.textColor = "0xFFFFFFFF";
                  }
               }
               else
               {
                  _hasEnoughGems = true;
                  LocalizationManager.translateId(_tag.txt,11176);
               }
            }
            if(AvatarUtility.isEndangered(_loc2_.availability))
            {
               if(_currType == 13 || _currType == 16 || _currType == 26)
               {
                  LocalizationManager.translateId(_avatarSelect.endangeredSign.txt,11177);
               }
               else if(_currType == 6)
               {
                  LocalizationManager.translateId(_avatarSelect.endangeredSign.txt,14226);
               }
               else
               {
                  LocalizationManager.translateId(_avatarSelect.endangeredSign.txt,11178);
               }
               _avatarSelect.endangeredSign.visible = true;
            }
            else
            {
               _avatarSelect.endangeredSign.visible = false;
            }
            if(AvatarUtility.isEndangered(_loc2_.availability) || AvatarUtility.isExtinct(_loc2_.availability))
            {
               _nextBtn.activateGrayState(true);
               if(_isFromWorld)
               {
                  _tag.visible = false;
                  _nextBtn.sparkle.visible = false;
               }
            }
            else
            {
               _nextBtn.activateGrayState(false);
               if(_isFromWorld)
               {
                  _nextBtn.sparkle.visible = _loc2_.diamondItem != null;
                  _tag.visible = true;
               }
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:String = !!param1.currentTarget.isDiamond ? "diamond_" : "";
         if(param1.currentTarget.currWindow.currentFrameLabel == _loc2_ + "down")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "downMouse");
         }
         else if(param1.currentTarget.currWindow.currentFrameLabel != _loc2_ + "downMouse")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "over");
         }
         param1.currentTarget.setupLayers();
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:String = !!param1.currentTarget.isDiamond ? "diamond_" : "";
         if(param1.currentTarget.currWindow.currentFrameLabel == _loc2_ + "downMouse")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "down");
         }
         else if(param1.currentTarget.currWindow.currentFrameLabel != _loc2_ + "down")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "up");
         }
         param1.currentTarget.setupLayers();
      }
      
      private function stopVOButton(param1:Event) : void
      {
         if(CreateAccountGui)
         {
            CreateAccountGui.vo1Sound.stop();
         }
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(CreateAccountGui.vo1Sound.isPlaying)
         {
            CreateAccountGui.vo1Sound.stop();
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo1Sound.play();
            if(CreateAccountGui.vo1Sound.sc)
            {
               CreateAccountGui.vo1Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
               _voBtn.play();
            }
         }
      }
   }
}

