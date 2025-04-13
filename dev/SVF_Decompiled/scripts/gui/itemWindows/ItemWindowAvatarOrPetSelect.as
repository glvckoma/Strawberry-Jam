package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarDef;
   import avatar.AvatarItem;
   import avatar.AvatarUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import gui.LoadingSpiral;
   import inventory.Iitem;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   
   public class ItemWindowAvatarOrPetSelect extends ItemWindowBase
   {
      private var _mediaHelper:MediaHelper;
      
      private var _forCreation:Boolean;
      
      private var _avType:int;
      
      private var _shouldShowDiamond:Boolean;
      
      private var _customAvId:int;
      
      private var _creationAvatar:Avatar;
      
      private var _isPet:Boolean;
      
      private var _currGuiPet:GuiPet;
      
      private var _selectedIndex:Function;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _currIitem:Iitem;
      
      private var _avatarDef:AvatarDef;
      
      private var _currIcon:MovieClip;
      
      private var _hasSetInitialConditions:Boolean;
      
      public function ItemWindowAvatarOrPetSelect(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         if(param2)
         {
            _isPet = param9.isPet == null ? false : true;
            _selectedIndex = param9.selectedIndex == null ? null : param9.selectedIndex;
            if(!_isPet)
            {
               _currIitem = param2 as AvatarItem;
               _creationAvatar = param9.creationAvatars[param4];
               _avatarDef = gMainFrame.userInfo.getAvatarDefByAvatar(_creationAvatar);
               _forCreation = param9.forCreation == null ? false : param9.forCreation;
               _avType = param9.avTypes[param4];
               _customAvId = _creationAvatar.customAvId;
               _shouldShowDiamond = _currIitem.isDiamond && !AvatarUtility.getAvatarDefIsViewableWithAvId(_avType,_customAvId);
            }
            else
            {
               _currIitem = param2 as PetItem;
               _shouldShowDiamond = _currIitem.isDiamond && !PetManager.isPetAvailable((_currIitem as PetItem).defId);
            }
         }
         super("avatarOrPetWindowCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get currWindow() : MovieClip
      {
         return _window;
      }
      
      public function get customAvId() : int
      {
         return _customAvId;
      }
      
      public function selectItem() : void
      {
         if(_window.currentFrameLabel != (!_isPet && isDiamond) ? "diamond_down" : "down")
         {
            _window.gotoAndStop(!_isPet && isDiamond ? "diamond_down" : "down");
         }
      }
      
      public function deselect() : void
      {
         if(_window.currentFrameLabel != (!_isPet && isDiamond) ? "diamond_up" : "up")
         {
            _window.gotoAndStop(!_isPet && isDiamond ? "diamond_up" : "up");
         }
      }
      
      public function setupLayers() : void
      {
         _window.diamond.visible = _shouldShowDiamond;
      }
      
      public function get isDiamond() : Boolean
      {
         if(_currItem && _currIitem)
         {
            return _currIitem.isDiamond;
         }
         return false;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         if(_forCreation)
         {
            loadCurrItem();
         }
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         if(_window && _currItem)
         {
            if(_isPet)
            {
               if(!_isCurrItemLoaded)
               {
                  if(!_hasSetInitialConditions)
                  {
                     setChildrenAndInitialConditions();
                  }
                  _currIitem.imageLoadedCallback = onPetLoaded;
                  _currGuiPet = _currIitem.icon as GuiPet;
                  setupCommonItems();
                  _window.itemWindow.addChild(_currGuiPet);
                  _isCurrItemLoaded = true;
               }
               else if(_loadingSpiral)
               {
                  _loadingSpiral.destroy();
                  _loadingSpiral = null;
               }
            }
            else if(_currItem && !_isCurrItemLoaded)
            {
               if(!_hasSetInitialConditions)
               {
                  setChildrenAndInitialConditions();
               }
               _itemYLocation = param1;
               _itemXLocation = param2;
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(_avatarDef.iconMediaId,onCurrItemLoaded);
            }
            else if(_currItem && _currIcon)
            {
               if(_loadingSpiral)
               {
                  _loadingSpiral.destroy();
                  _loadingSpiral = null;
               }
               _isCurrItemLoaded = true;
               setupCommonItems();
               if(_iconLayerName != "" && Boolean(_currIcon.hasOwnProperty(_iconLayerName)))
               {
                  _window.itemWindow.addChild(_currIcon[_iconLayerName]);
               }
               else
               {
                  _window.itemWindow.addChild(DisplayObject(_currIcon));
               }
            }
            else if(_loadingSpiral)
            {
               _loadingSpiral.destroy();
               _loadingSpiral = null;
            }
            if(index == selectedIndex())
            {
               selectItem();
            }
            else
            {
               deselect();
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(!_hasSetInitialConditions)
         {
            _window.memberLock.visible = false;
            _window.endangered.visible = false;
            _window.ocean.visible = false;
            _window.diamond.visible = false;
            _window.daysLeftTag.visible = false;
            _window.clearanceTag.visible = false;
            _window.rare.visible = false;
            _loadingSpiral = new LoadingSpiral(_window.itemWindow,_window.itemWindow.width * 0.5,_window.itemWindow.height * 0.5);
            _hasSetInitialConditions = true;
            addEventListeners();
            if(_forCreation)
            {
               loadCurrItem();
            }
         }
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
         if(_isPet)
         {
            if(_currGuiPet)
            {
               _currGuiPet.animatePet(param1);
            }
            this.visible = param1;
         }
         else
         {
            super.setStatesForVisibility(param1,_currIcon);
         }
      }
      
      private function selectedIndex() : int
      {
         if(_selectedIndex != null)
         {
            return _selectedIndex();
         }
         return 0;
      }
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currIcon = param1.getChildAt(0) as MovieClip;
            _isCurrItemLoaded = true;
            loadCurrItem();
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         param1.scaleY = 2;
         param1.scaleX = 2;
         param1.x = 53;
         param1.y = 85;
         if(_currGuiPet)
         {
            _currGuiPet.animatePet(this.visible);
         }
      }
      
      private function setupCommonItems() : void
      {
         var _loc1_:Array = null;
         if(!gMainFrame.userInfo.isMember && _currIitem.isMemberOnly)
         {
            _window.memberLock.visible = true;
         }
         _window.clearanceTag.visible = _currIitem.isOnClearance;
         _window.diamond.visible = _shouldShowDiamond;
         setupNumDaysLeft();
         if(_isPet)
         {
            if(_currGuiPet.canGoInOcean())
            {
               _window.ocean.visible = true;
            }
            _window.rare.visible = _currIitem.isRare;
         }
         else
         {
            if(!_forCreation && Utility.isOcean(_avatarDef.enviroTypeFlag))
            {
               _window.ocean.visible = true;
            }
            if(AvatarUtility.isEndangered(_avatarDef.availability))
            {
               if(_avType == 13 || _avType == 16 || _avType == 26)
               {
                  LocalizationManager.translateId(_window.endangered.txt,11177);
               }
               else if(_avType == 6)
               {
                  LocalizationManager.translateId(_window.endangered.txt,14226);
               }
               else
               {
                  LocalizationManager.translateId(_window.endangered.txt,11178);
               }
               _window.endangered.visible = true;
            }
            if(AvatarUtility.isExtinct(_avatarDef.availability))
            {
               _loc1_ = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
               _currIcon.filters = [new ColorMatrixFilter(_loc1_)];
            }
            if(_currIitem.isDiamond && _window.currentFrameLabel != "diamond_down")
            {
               _window.gotoAndStop("diamond_up");
            }
         }
      }
      
      private function setupNumDaysLeft() : void
      {
         var _loc1_:int = 0;
         if(!_currIitem.isRare && !_currIitem.isNew && !_currIitem.isOnSale)
         {
            _loc1_ = Math.ceil((_currIitem.endTime - Utility.getCurrEpochTime()) / 60 / 60 / 24);
            if(_loc1_ > 0 && _loc1_ <= 10)
            {
               if(_loc1_ == 1)
               {
                  LocalizationManager.translateId(_window.daysLeftTag.txt,18061);
               }
               else
               {
                  LocalizationManager.translateIdAndInsert(_window.daysLeftTag.txt,6260,_loc1_);
               }
               _window.daysLeftTag.visible = true;
               MovieClip(_window.daysLeftTag.parent).clearanceTag.visible = false;
            }
            else
            {
               _window.daysLeftTag.visible = false;
            }
         }
         else
         {
            _window.daysLeftTag.visible = false;
         }
      }
   }
}

