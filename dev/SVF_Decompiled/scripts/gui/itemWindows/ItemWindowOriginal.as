package gui.itemWindows
{
   import avatar.AvatarManager;
   import den.DenItem;
   import den.DenMannequinInventory;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import gui.LoadingSpiral;
   import inventory.Iitem;
   import item.Item;
   import pet.GuiPet;
   import pet.PetItem;
   import pet.PetManager;
   import shop.ShopManager;
   
   public class ItemWindowOriginal extends ItemWindowBase
   {
      private var _isAvatarEditor:Boolean;
      
      private var _isTradeList:Boolean;
      
      private var _isChoosingForTradeList:Boolean;
      
      private var _generatorIndex:int;
      
      private var _giftItemIdx:int;
      
      private var _isDownGift:Boolean;
      
      private var _isPetItem:Boolean;
      
      private var _isActivePet:Boolean;
      
      private var _isAudio:Boolean;
      
      private var _isLastPlacedAudio:Boolean;
      
      private var _isTradeManager:Boolean;
      
      private var _isECard:Boolean;
      
      private var _isViewingATradeList:Boolean;
      
      private var _isRecycling:Boolean;
      
      private var _loadImmediately:Boolean;
      
      private var _showAddRemoveBtns:Boolean;
      
      private var _hasBeenHidden:Boolean;
      
      private var _inUse:Boolean;
      
      private var _hasSetInitialConditions:Boolean;
      
      private var _avInvId:int;
      
      private var _mannequinInvIdx:int;
      
      private var _hasSetState:Boolean;
      
      private var _isSellShop:Boolean;
      
      public function ItemWindowOriginal(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         var _loc11_:int = 0;
         var _loc10_:* = param4;
         _generatorIndex = param4;
         if(param9 != null)
         {
            _loadImmediately = param9.loadImmediately;
            _isRecycling = param9.isRecycling;
            _isViewingATradeList = param9.isViewingATradeList;
            _isECard = param9.isECard;
            _isAvatarEditor = param9.isAvatarEditor;
            _isTradeManager = param9.isTradeManager;
            _isAudio = param9.isAudio;
            _isPetItem = param9.isPetItem;
            _giftItemIdx = param9.giftItemIdx;
            _isTradeList = param9.isTradeList;
            _isChoosingForTradeList = param9.isChoosingForTradeList;
            _isSellShop = param9.isSellShop;
            _showAddRemoveBtns = param9.showAddRemoveBtns;
            _avInvId = !!param9.avInvId ? param9.avInvId : gMainFrame.userInfo.playerAvatarInfo.avInvId;
            _mannequinInvIdx = _isAvatarEditor ? param9.mannequinInvIdx : -1;
            if(param9.indexArray != null)
            {
               _loc11_ = int(param9.indexArray.length);
               _loc10_ = int(_loc11_ - 1 >= param4 ? param9.indexArray[param4] : param4);
            }
         }
         super("itemWindow",param1,param2,param3,_loc10_,param5,param6,param7,param8,true);
      }
      
      public function get removeBtn() : MovieClip
      {
         return _window.removeBtn;
      }
      
      public function get addBtn() : MovieClip
      {
         return _window.addBtn;
      }
      
      public function get cir() : MovieClip
      {
         return _window.cir;
      }
      
      public function get sizeCont() : MovieClip
      {
         return _window.sizeCont;
      }
      
      public function get gift() : MovieClip
      {
         return _window.gift;
      }
      
      public function get isDownGift() : Boolean
      {
         return _isDownGift;
      }
      
      public function get isActivePet() : Boolean
      {
         return _isActivePet;
      }
      
      public function get isLastPlacedAudio() : Boolean
      {
         return _isLastPlacedAudio;
      }
      
      public function get isAudio() : Boolean
      {
         return _isAudio;
      }
      
      public function get isUsable() : Boolean
      {
         return _currItem == null;
      }
      
      public function get currItem() : Object
      {
         return _currItem;
      }
      
      public function get itemName() : String
      {
         if(_currItem)
         {
            return _currItem.name;
         }
         return "";
      }
      
      public function get isInUse() : Boolean
      {
         return _inUse;
      }
      
      public function get mannequinInvIdx() : int
      {
         return _mannequinInvIdx;
      }
      
      override public function get numChildren() : int
      {
         return _window.numChildren;
      }
      
      override public function getChildAt(param1:int) : DisplayObject
      {
         return _window.getChildAt(param1);
      }
      
      public function resetDownGift() : void
      {
         if(_window)
         {
            _window.gift.visible = false;
         }
         _isDownGift = false;
      }
      
      public function set currDownGift(param1:Object) : void
      {
         _isDownGift = true;
         _window.gift.visible = true;
      }
      
      public function resetAudioDown() : void
      {
         _isLastPlacedAudio = false;
         _window.cir.gotoAndStop("up");
      }
      
      public function setAudioDown() : void
      {
         _isLastPlacedAudio = true;
         _window.cir.gotoAndStop("down");
      }
      
      public function get defId() : int
      {
         if(_currItem)
         {
            return _currItem.defId;
         }
         return -1;
      }
      
      public function get avtSpecific() : MovieClip
      {
         return _window.avtSpecific;
      }
      
      public function get hasBeenHidden() : Boolean
      {
         return _hasBeenHidden;
      }
      
      public function removeLoadedItem() : void
      {
         _hasBeenHidden = true;
         if(_currItem)
         {
            if(_iconLayerName != "" && Boolean(_currItem.hasOwnProperty(_iconLayerName)))
            {
               if(_currItem[_iconLayerName].parent == _window.iconLayer)
               {
                  _window.iconLayer.removeChild(_currItem[_iconLayerName]);
               }
            }
            else if(_currItem.parent == _window.iconLayer)
            {
               _window.iconLayer.removeChild(_currItem);
            }
         }
         resetDownGift();
         resetAudioDown();
         resetVisibility();
         super.removeEventListeners();
      }
      
      public function update() : void
      {
         if(_currItem)
         {
            if(_isCurrItemLoaded && !_hasBeenHidden)
            {
               if(_mannequinInvIdx != -1 && _currItem as DenItem)
               {
                  (_currItem as DenItem).rebuildMannequin();
               }
               _hasSetState = false;
               setStates();
            }
         }
      }
      
      public function updateWithInput(param1:*) : void
      {
         _hasBeenHidden = false;
         _currItem = param1;
         _isCurrItemLoaded = false;
         _hasSetState = false;
         removeEventListeners();
         loadCurrItem();
         addEventListeners();
      }
      
      public function resetWindowToOriginalState() : void
      {
         _hasSetInitialConditions = false;
         _hasBeenHidden = false;
         _isCurrItemLoaded = false;
         _hasSetState = false;
         removeEventListeners();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_hasSetInitialConditions)
         {
            setChildrenAndInitialConditions();
         }
         if(_currItem && !_isCurrItemLoaded && !_hasBeenHidden)
         {
            _isCurrItemLoaded = true;
            if(_currItem is PetItem)
            {
               (_currItem as PetItem).imageLoadedCallback = onPetItemLoaded;
            }
            if(_iconLayerName != "" && Boolean(_currItem.hasOwnProperty(_iconLayerName)))
            {
               _window.iconLayer.addChild(_currItem[_iconLayerName]);
            }
            else
            {
               _window.iconLayer.addChild(DisplayObject(_currItem));
            }
            setStates();
         }
         else if(_currItem == null)
         {
            _isCurrItemLoaded = false;
            resetVisibility();
            resetDownGift();
            resetAudioDown();
            if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
            {
               _window.addBtn.visible = true;
            }
            while(_window.iconLayer.numChildren > 1)
            {
               _window.iconLayer.removeChildAt(_window.iconLayer.numChildren - 1);
            }
         }
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
         if(!param1)
         {
            _isCurrItemLoaded = false;
            if(_currItem != null && Boolean(currItem.hasOwnProperty("destroy")))
            {
               _currItem.destroy();
            }
            while(_window.iconLayer.numChildren > 1)
            {
               _window.iconLayer.removeChildAt(_window.iconLayer.numChildren - 1);
            }
            setChildrenAndInitialConditions();
         }
         this.visible = param1;
         if(param1 && _currItem != null && _currItem is DenItem)
         {
            if(DenItem(_currItem).petItem)
            {
               DenItem(_currItem).setVersion(DenItem(_currItem).petItem.petBits[0],DenItem(_currItem).petItem.petBits[1],DenItem(_currItem).petItem.petBits[2]);
            }
            else
            {
               DenItem(_currItem).setVersion(DenItem(_currItem).version);
            }
            if(DenItem(_currItem).mannequinData != null)
            {
               DenItem(_currItem).mannequinData.setToAvatarBoxFrame();
            }
         }
      }
      
      private function setStates() : void
      {
         var _loc1_:Iitem = null;
         if(!_hasSetState)
         {
            _hasSetState = true;
            if(_isTradeManager)
            {
               if(_currItem is Item)
               {
                  _loc1_ = _currItem as Item;
                  _currItem = _loc1_.clone();
               }
               else if(_currItem is PetItem)
               {
                  _loc1_ = _currItem as PetItem;
                  _currItem = _loc1_.clone();
               }
               else
               {
                  _loc1_ = _currItem as DenItem;
                  _currItem = _loc1_.clone();
               }
            }
            if(_currItem.isMemberOnly)
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  _window.lock.visible = true;
                  if(!isSpecialList())
                  {
                     _window.gray.visible = true;
                  }
               }
               else
               {
                  _window.lockOpen.visible = true;
               }
            }
            if(_currItem.isOcean)
            {
               _window.ocean.visible = true;
            }
            if(_currItem.isRareDiamond)
            {
               _window.rareDiamondTag.visible = true;
            }
            else if(_currItem.isCustom)
            {
               _window.customDiamond.visible = true;
               _window.previewBtn.visible = _mouseDown != null ? true : false;
            }
            else
            {
               if(_currItem.isRare)
               {
                  _window.rare.visible = true;
               }
               _window.diamond.visible = _currItem.isDiamond;
            }
            if(_showAddRemoveBtns && (_isTradeList || _isTradeManager || _isSellShop))
            {
               _window.removeBtn.visible = true;
               _window.addBtn.visible = false;
            }
            if(_currItem is Item)
            {
               if(_currItem.getInUse(_avInvId))
               {
                  _window.cir.gotoAndStop("down");
                  _inUse = true;
               }
               else
               {
                  _window.cir.gotoAndStop("up");
                  _inUse = false;
               }
               if(_isAvatarEditor && !_isTradeList && !_isSellShop)
               {
                  if((_currItem as Item).enviroType != AvatarManager.roomEnviroType || _mannequinInvIdx != -1 && !DenMannequinInventory.canUseItem((_currItem as Item).invIdx,_mannequinInvIdx))
                  {
                     _window.cir.gotoAndStop("gray");
                  }
               }
            }
            else if(_currItem is DenItem)
            {
               if(_currItem.categoryId != 0 && !_isActivePet)
               {
                  _isLastPlacedAudio = true;
                  _window.cir.gotoAndStop("down");
                  _inUse = true;
               }
               else
               {
                  _window.cir.gotoAndStop("up");
                  _inUse = false;
               }
               if(_currItem.refId == 1)
               {
                  if(_currItem.invIdx == PetManager.myActivePetInvId)
                  {
                     _window.cir.gotoAndStop("green");
                     _isActivePet = true;
                  }
                  if(_mouseDown != null && (!DenItem(_currItem).petItem.isEgg || Boolean(DenItem(_currItem).petItem.isHatched)))
                  {
                     _window.certBtn.visible = true;
                  }
                  else
                  {
                     _window.certBtn.visible = false;
                  }
               }
               if(_currItem.specialType == 7 || _currItem.specialType == 6)
               {
                  _window.consumerItemBtn.visible = true;
                  _window.consumerItemBtn.activateGrayState(_currItem.specialType == 6);
               }
            }
            else if(_currItem is PetItem || _isPetItem)
            {
               if(_currItem.invIdx == PetManager.myActivePetInvId)
               {
                  _window.cir.gotoAndStop("green");
                  _isActivePet = true;
               }
               if(_mouseDown != null && (!PetItem(_currItem).isEgg || Boolean(PetItem(_currItem).isHatched)))
               {
                  _window.certBtn.visible = true;
               }
               else
               {
                  _window.certBtn.visible = false;
               }
               if(_currItem.isRare)
               {
                  _window.rare.visible = true;
               }
            }
            if(_currItem is Iitem && (_currItem as Iitem).isInDenShop)
            {
               if(ShopManager.currentOpenShopId != (_currItem as Iitem).denStoreInvId)
               {
                  _window.shopItem.visible = true;
               }
            }
            if(_isECard)
            {
               if(_giftItemIdx == _currItem.invIdx)
               {
                  this.gift.visible = true;
                  _isDownGift = true;
               }
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(!_hasSetInitialConditions)
         {
            _hasSetInitialConditions = true;
            if(_currItem)
            {
               if(!_spiral)
               {
                  _spiral = new LoadingSpiral(_window.iconLayer);
               }
               else
               {
                  _spiral.setNewParent(_window.iconLayer);
               }
               if(!_currItem.isIconLoaded)
               {
                  _currItem.imageLoadedCallback = _spiral.destroy();
               }
               else
               {
                  _spiral.destroy();
               }
               if(_loadImmediately)
               {
                  loadCurrItem();
               }
            }
            else if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
            {
               _window.addBtn.visible = true;
            }
            addEventListeners();
         }
      }
      
      override protected function onWindowLoadCallback() : void
      {
         if(_windowLoadedCallback != null)
         {
            resetVisibility();
            if(_loadImmediately)
            {
               setChildrenAndInitialConditions();
            }
            _windowLoadedCallback(this,_generatorIndex);
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window && _currItem)
         {
            if(_mouseDown != null && !(_currItem.isMemberOnly && _memberOnlyDown != null && !gMainFrame.userInfo.isMember && !isSpecialList()))
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
               _window.previewBtn.addEventListener("mouseDown",_mouseDown,false,0,true);
               _window.certBtn.addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOver",onWindowRollOver,false,0,true);
               }
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOut",onWindowRollOut,false,0,true);
               }
            }
            if(_memberOnlyDown != null && _currItem.isMemberOnly && !gMainFrame.userInfo.isMember && !isSpecialList())
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
         else if(_showAddRemoveBtns && (_isTradeList || _isTradeManager))
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
               _window.previewBtn.addEventListener("mouseDown",_mouseDown,false,0,true);
               _window.certBtn.addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
         }
      }
      
      override protected function removeEventListeners() : void
      {
         super.removeEventListeners();
         if(Boolean(_mouseDown))
         {
            _window.previewBtn.removeEventListener("mouseDown",_mouseDown);
            _window.certBtn.removeEventListener("mouseDown",_mouseDown);
         }
      }
      
      private function isSpecialList() : Boolean
      {
         return _isTradeList || _isTradeManager || _isChoosingForTradeList || _isViewingATradeList || _isECard || _isRecycling;
      }
      
      private function resetVisibility() : void
      {
         _window.lock.visible = false;
         _window.lockOpen.visible = false;
         _window.gray.visible = false;
         _window.gift.visible = false;
         _window.addBtn.visible = false;
         _window.removeBtn.visible = false;
         _window.ocean.visible = false;
         _window.rare.visible = false;
         _window.avtSpecific.visible = false;
         _window.avtSpecificIcon.visible = false;
         _window.avtSpecificHighlight.visible = false;
         _window.rareDiamondTag.visible = false;
         _window.diamond.visible = false;
         _window.customDiamond.visible = false;
         _window.previewBtn.visible = false;
         _window.certBtn.visible = false;
         _window.shopItem.visible = false;
         _window.consumerItemBtn.visible = false;
         super.onWindowRollOut(null);
      }
      
      private function onPetItemLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc3_:Number = NaN;
         if(_window)
         {
            _loc3_ = _window.iconLayer.width / Math.max(param1.width,param1.height);
            param1.scaleX = param1.scaleY = _loc3_;
            param1.y = _window.iconLayer.height * 0.5 - 20;
         }
      }
   }
}

