package gui
{
   import com.sbi.corelib.audio.SBAudio;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetDef;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class EggPetHatchedPopup
   {
      private const POPUP_MEDIA_ID:int = 5802;
      
      private const PET_NAMES_1:int = 205;
      
      private const PET_NAMES_2:int = 206;
      
      private var _hatchedPetListIndexes:Array;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _eggPetPopup:MovieClip;
      
      private var _currGuiPet:GuiPet;
      
      private var _myPetList:Array;
      
      private var _nameBarrel:MovieClip;
      
      private var _hatched:MovieClip;
      
      private var _itemWindowPetBarrel:MovieClip;
      
      private var _itemWindowPetHatched:MovieClip;
      
      private var _hatchedOkBtn:GuiSoundBtnSubMenu;
      
      private var _barrelOkBtn:GuiSoundBtnSubMenu;
      
      private var _hatchedTxt:TextField;
      
      private var _nameScroller1Asset:MovieClip;
      
      private var _nameScroller2Asset:MovieClip;
      
      private var _nameScroller1:GuiCarousel;
      
      private var _nameScroller2:GuiCarousel;
      
      private var _nameLever:MovieClip;
      
      private var _petNames:Array;
      
      private var _petNameText:TextField;
      
      private var _nameBarrelBx:GuiSoundBtnExit;
      
      public function EggPetHatchedPopup(param1:Array, param2:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _hatchedPetListIndexes = param1;
         _closeCallback = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5802,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(_eggPetPopup);
         GuiManager.guiLayer.removeChild(_eggPetPopup);
         removeEventListeners();
         if(_nameScroller1)
         {
            _nameScroller1.destroy();
            _nameScroller1 = null;
         }
         if(_nameScroller2)
         {
            _nameScroller2.destroy();
            _nameScroller2 = null;
         }
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
         _eggPetPopup = null;
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         _closeCallback = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _mediaHelper.destroy();
         _mediaHelper = null;
         _eggPetPopup = MovieClip(param1.getChildAt(0));
         _nameBarrel = _eggPetPopup.nameBarrel;
         _hatched = _eggPetPopup.hatched;
         _itemWindowPetHatched = _hatched.itemWindowPet;
         _itemWindowPetBarrel = _nameBarrel.itemWindowPet;
         _hatchedOkBtn = _hatched.okBtn;
         _hatchedTxt = _hatched.hatchedTxt.bodyTxt;
         _barrelOkBtn = _nameBarrel.okBtn;
         _nameScroller1Asset = _nameBarrel.nameScroller1;
         _nameScroller2Asset = _nameBarrel.nameScroller2;
         _nameLever = _nameBarrel.nameLever;
         _petNameText = _nameBarrel.aml_name_txt;
         _nameBarrelBx = _nameBarrel.bx;
         _myPetList = PetManager.myPetList;
         addEventListeners();
         loadPetNames();
         checkAndSetupPet();
         _eggPetPopup.x = 900 * 0.5;
         _eggPetPopup.y = 550 * 0.5;
         DarkenManager.showLoadingSpiral(false);
         GuiManager.guiLayer.addChild(_eggPetPopup);
         DarkenManager.darken(_eggPetPopup);
      }
      
      private function loadPetNames() : void
      {
         _petNames = [-1,-1];
         _nameLever.visible = false;
         GenericListXtCommManager.requestGenericList(205,onNamesLoaded);
         GenericListXtCommManager.requestGenericList(206,onNamesLoaded);
      }
      
      private function checkAndSetupPet() : void
      {
         var _loc1_:Object = null;
         var _loc2_:PetDef = null;
         _hatched.visible = true;
         _nameBarrel.visible = false;
         if(_hatchedPetListIndexes.length > 0)
         {
            if(_currGuiPet)
            {
               if(_itemWindowPetBarrel.contains(_currGuiPet))
               {
                  _itemWindowPetBarrel.removeChild(_currGuiPet);
               }
            }
            _loc1_ = _myPetList[_hatchedPetListIndexes[_hatchedPetListIndexes.length - 1]];
            _loc2_ = PetManager.getPetDef(_loc1_.defId);
            _currGuiPet = new GuiPet(_loc1_.createdTs,_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,_loc1_.personalityDefId,_loc1_.favoriteToyDefId,_loc1_.favoriteFoodDefId,onPetLoaded);
            _itemWindowPetHatched.addChild(_currGuiPet);
            LocalizationManager.translateIdAndInsert(_hatchedTxt,29532,_currGuiPet.getPetTitleName().toLowerCase());
         }
         else
         {
            destroy();
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _currGuiPet.scaleY = 5;
         _currGuiPet.scaleX = 5;
         _currGuiPet.y += 83;
      }
      
      private function onNamesLoaded(param1:int, param2:Array) : void
      {
         var _loc3_:Array = null;
         var _loc7_:String = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Object = [];
         var _loc5_:int = -1;
         switch(param1 - 205)
         {
            case 0:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc8_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc5_ = 1;
                  break;
               }
               _loc8_ = {
                  "names":[],
                  "types":[],
                  "locIds":[]
               };
               _loc5_ = 0;
               break;
            case 1:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc8_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc5_ = 0;
                  break;
               }
               _loc8_ = {
                  "names":[],
                  "femNames":[],
                  "locIds":[]
               };
               _loc5_ = 1;
               break;
         }
         if(_loc5_ != -1)
         {
            _loc6_ = 0;
            while(_loc6_ < param2.length)
            {
               if(_loc5_ == 0)
               {
                  _loc3_ = LocalizationManager.translateIdOnly(param2[_loc6_]).split("$");
                  _loc7_ = _loc3_[0];
                  _loc4_ = Utility.findIndexToInsert(_loc8_.names,_loc7_);
                  _loc8_.names.splice(_loc4_,0,_loc7_);
                  if(_loc3_[1])
                  {
                     _loc8_.types.splice(_loc4_,0,_loc3_[1]);
                  }
                  else
                  {
                     _loc8_.types.splice(_loc4_,0,"m");
                  }
               }
               else if(_loc5_ == 1)
               {
                  _loc3_ = LocalizationManager.translateIdOnly(param2[_loc6_]).split("$");
                  _loc7_ = _loc3_[0].toLowerCase();
                  _loc4_ = Utility.findIndexToInsert(_loc8_.names,_loc7_);
                  _loc8_.names.splice(_loc4_,0,_loc7_);
                  if(_loc3_[1])
                  {
                     _loc8_.femNames.splice(_loc4_,0,_loc3_[1].toLowerCase());
                  }
                  else
                  {
                     _loc8_.femNames.splice(_loc4_,0,_loc7_);
                  }
               }
               _loc8_.locIds.splice(_loc4_,0,param2[_loc6_]);
               _loc6_++;
            }
            _petNames[_loc5_] = _loc8_;
         }
         if(_petNames[0] != -1 && _petNames[1] != -1)
         {
            setupPetNames(_petNames[0].names,_petNames[1].names);
         }
      }
      
      private function setupPetNames(param1:Array, param2:Array) : void
      {
         _nameScroller1 = new GuiCarousel(_nameScroller1Asset);
         _nameScroller1.init(param1,name1Changed);
         _nameScroller2 = new GuiCarousel(_nameScroller2Asset);
         _nameScroller2.init(param2,name2Changed);
         _nameLever.visible = true;
      }
      
      private function name1Changed() : void
      {
         if(_nameScroller1 && _nameScroller2 && _nameScroller1.selectedContentItem && _nameScroller2.selectedContentItem)
         {
            _petNameText.text = _nameScroller1.selectedContentItem + _nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(_petNameText,_petNameText.text);
            if(_petNames[0].types[_nameScroller1.contentItemIndex] == "m")
            {
               if(_nameScroller2.contentItems != _petNames[1].names)
               {
                  _nameScroller2.contentItems = _petNames[1].names;
               }
            }
            else if(_nameScroller2.contentItems != _petNames[1].femNames && _petNames[1].femNames[0])
            {
               _nameScroller2.contentItems = _petNames[1].femNames;
            }
            if(_nameScroller2.soundsEnabled)
            {
               _nameScroller2.soundsEnabled = false;
               _nameScroller2.spinToIndex(_nameScroller2.contentItemIndex,true);
               _nameScroller2.soundsEnabled = !SBAudio.areSoundsMuted;
            }
            else
            {
               _nameScroller2.spinToIndex(_nameScroller2.contentItemIndex,true);
            }
         }
         if(_nameScroller1 && !_nameScroller1.soundsEnabled)
         {
            _nameScroller1.soundsEnabled = !SBAudio.areSoundsMuted;
         }
      }
      
      private function name2Changed() : void
      {
         if(_nameScroller1 && _nameScroller2 && _nameScroller1.selectedContentItem && _nameScroller2.selectedContentItem)
         {
            _petNameText.text = _nameScroller1.selectedContentItem + _nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(_petNameText,_petNameText.text);
         }
         if(_nameScroller2 && !_nameScroller2.soundsEnabled)
         {
            _nameScroller2.soundsEnabled = !SBAudio.areSoundsMuted;
         }
      }
      
      private function namePet() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(_currGuiPet && _nameScroller1 && _nameScroller1.hasLoaded && _nameScroller2 && _nameScroller2.hasLoaded)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = int(LocalizationManager.isCurrLanguageReversed() ? _petNames[1].locIds[_nameScroller2.contentItemIndex] : _petNames[0].locIds[_nameScroller1.contentItemIndex]);
            _loc1_ = int(LocalizationManager.isCurrLanguageReversed() ? _petNames[0].locIds[_nameScroller1.contentItemIndex] : _petNames[1].locIds[_nameScroller2.contentItemIndex]);
            _currGuiPet.petName = _loc2_ + "|" + _loc1_;
            PetXtCommManager.sendPetEggNameRequest(_currGuiPet.idx,_loc2_,_loc1_,onPetNameResponse);
         }
      }
      
      private function onPetNameResponse(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            GuiManager.openPetCertificatePopup(_currGuiPet,onPetCertificateClose);
         }
      }
      
      private function onPetCertificateClose() : void
      {
         _hatchedPetListIndexes.pop();
         checkAndSetupPet();
      }
      
      private function addEventListeners() : void
      {
         _nameBarrel.addEventListener("mouseDown",onPopup,false,0,true);
         _hatched.addEventListener("mouseDown",onPopup,false,0,true);
         _hatchedOkBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
         _barrelOkBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
         _nameBarrelBx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _nameLever.addEventListener("mouseDown",onNameLever,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _nameBarrel.removeEventListener("mouseDown",onPopup);
         _hatched.removeEventListener("mouseDown",onPopup);
         _hatchedOkBtn.removeEventListener("mouseDown",onOkBtn);
         _barrelOkBtn.removeEventListener("mouseDown",onOkBtn);
         _nameBarrelBx.removeEventListener("mouseDown",onCloseBtn);
         _nameLever.removeEventListener("mouseDown",onNameLever);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _hatchedOkBtn)
         {
            _hatched.visible = false;
            _nameBarrel.visible = true;
            _itemWindowPetHatched.removeChild(_currGuiPet);
            _itemWindowPetBarrel.addChild(_currGuiPet);
         }
         else if(param1.currentTarget == _barrelOkBtn)
         {
            namePet();
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onNameLever(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_nameLever.currentFrameLabel == "_up")
         {
            _nameScroller2.soundsEnabled = false;
            AJAudio.playRandomLever();
            _nameLever.gotoAndPlay("_play");
            _nameScroller1.pickRandomItem();
            _nameScroller2.pickRandomItem();
            _nameScroller2.soundsEnabled = true;
         }
      }
   }
}

