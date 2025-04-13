package gui.itemWindows
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.LoadingSpiral;
   import gui.WindowAndScrollbarGenerator;
   import pet.GuiPet;
   import pet.PetDef;
   import pet.PetManager;
   
   public class ItemWindowPets extends ItemWindowBase
   {
      private var _isRecycling:Boolean;
      
      private var _currGuiPet:GuiPet;
      
      public function ItemWindowPets(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _isRecycling = param9.isRecycling;
         super("itemWindowPets",param1,param2,param3,param4,param5,param6,param7,param8,true);
      }
      
      public function get cir() : MovieClip
      {
         return _window.cir;
      }
      
      public function get gray() : MovieClip
      {
         return _window.gray;
      }
      
      public function get cageIcon() : MovieClip
      {
         return _window.cageIcon;
      }
      
      public function get newPetIcon() : MovieClip
      {
         return _window.newPet;
      }
      
      public function get hasPet() : Boolean
      {
         return _currItem;
      }
      
      public function get sizeCont() : MovieClip
      {
         return _window.sizeCont;
      }
      
      public function get shopItem() : MovieClip
      {
         return _window.shopItem;
      }
      
      public function update(param1:Object) : void
      {
         if("petObject" in param1)
         {
            if(_currGuiPet)
            {
               _currGuiPet.updateAllBits(param1.petObject.lBits,param1.petObject.uBits,param1.petObject.eBits);
            }
         }
         else if("isRecycling" in param1)
         {
            _isRecycling = param1.isRecycling;
            if(_currItem)
            {
               _window.cageIcon.visible = _isRecycling;
            }
         }
      }
      
      public function removeLoadedItem() : void
      {
         if(_currGuiPet)
         {
            _window.iconLayer.removeChild(_currGuiPet);
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
         _currItem = null;
         setChildrenAndInitialConditions();
         _spiral.visible = false;
         _window.newPet.visible = true;
      }
      
      override public function destroy() : void
      {
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
         _spiral = null;
         super.destroy();
      }
      
      override public function setStatesForVisibility(param1:Boolean, param2:Object = null) : void
      {
         if(_currGuiPet)
         {
            if(!param1)
            {
               _isCurrItemLoaded = false;
               _window.iconLayer.removeChild(_currGuiPet);
               _currGuiPet.destroy();
               _currGuiPet = null;
            }
         }
         this.visible = param1;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc3_:PetDef = null;
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            if(_currItem)
            {
               if(_spiral)
               {
                  _spiral.visible = true;
               }
               _loc3_ = PetManager.getPetDef(_currItem.defId);
               _currGuiPet = new GuiPet(_currItem.createdTs,_currItem.idx,_currItem.lBits,_currItem.uBits,_currItem.eBits,_currItem.type,_currItem.name,_currItem.personalityDefId,_currItem.favoriteToyDefId,_currItem.favoriteFoodDefId,onPetLoaded);
               _window.cageIcon.visible = _isRecycling;
               if(_currGuiPet.isEggAndHasNotHatched())
               {
                  _window.ocean.visible = false;
               }
               else
               {
                  _window.ocean.visible = _currGuiPet.canGoInOcean();
               }
               if(!gMainFrame.userInfo.isMember)
               {
                  _window.lockOpen.visible = false;
                  if(_loc3_.isMember)
                  {
                     _window.gray.visible = true;
                     _window.lock.visible = true;
                  }
                  else
                  {
                     _window.lock.visible = false;
                     _window.gray.visible = false;
                  }
               }
               else
               {
                  _window.lock.visible = false;
                  _window.gray.visible = false;
                  if(_loc3_.isMember)
                  {
                     _window.lockOpen.visible = true;
                  }
                  else
                  {
                     _window.lockOpen.visible = false;
                  }
               }
               trace(_currItem.denStoreInvId);
               if(_currItem.denStoreInvId > 0)
               {
                  _window.shopItem.visible = true;
               }
               _window.newPet.visible = false;
               if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc3_,_currItem.createdTs))
               {
                  _window.gray.visible = true;
               }
               else if(PetManager.myActivePetInvId == _currGuiPet.idx)
               {
                  _window.cir.gotoAndStop("down");
               }
               _window.rare.visible = _loc3_.status == 4;
               _currGuiPet.scaleY = 2;
               _currGuiPet.scaleX = 2;
               _isCurrItemLoaded = true;
               _window.iconLayer.addChild(_currGuiPet);
               return;
            }
            _window.newPet.visible = true;
         }
         if(_spiral)
         {
            _spiral.destroy();
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_spiral == null)
         {
            _spiral = new LoadingSpiral(_window.iconLayer,0,-_window.iconLayer.height * 0.5);
         }
         _window.lockOpen.visible = false;
         _window.lock.visible = false;
         _window.gray.visible = false;
         _window.ocean.visible = false;
         _window.cageIcon.visible = false;
         _window.newPet.gray.visible = false;
         _window.newPet.visible = false;
         _window.rare.visible = false;
         _window.shopItem.visible = false;
         _window.cir.gotoAndStop("up");
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null && _currItem)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOver",onWindowRollOver,false,0,true);
               }
            }
            if(_mouseOut != null && _currItem)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
               if(_useToolTip)
               {
                  addEventListener("rollOut",onWindowRollOut,false,0,true);
               }
            }
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
      
      override protected function onWindowRollOver(param1:MouseEvent) : void
      {
         if(_currItem && _useToolTip && this.parent != null)
         {
            if(_windowGenerator == null)
            {
               _windowGenerator = WindowAndScrollbarGenerator(this.parent.parent);
            }
            _windowGenerator.toolTip.init(_windowGenerator.parent.parent,_currGuiPet.petName,this.x + _windowGenerator.boxWidth * 0.5 + _windowGenerator.parent.x + _itemXLocation,this.y + _windowGenerator.boxHeight - _itemYLocation + _windowGenerator.parent.y - 5);
            _windowGenerator.toolTip.startTimer(param1);
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         if(_spiral)
         {
            _spiral.destroy();
         }
      }
   }
}

