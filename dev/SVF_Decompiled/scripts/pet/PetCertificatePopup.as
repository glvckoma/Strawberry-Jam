package pet
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.globalization.DateTimeFormatter;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PetCertificatePopup
   {
      private var _petCertificatePopup:MovieClip;
      
      private var _pet:GuiPet;
      
      private var _closeCallback:Function;
      
      private var _nameTxt:TextField;
      
      private var _adoptedTxt:TextField;
      
      private var _personalityTxt:TextField;
      
      private var _favoriteToyTxt:TextField;
      
      private var _favoriteFoodTxt:TextField;
      
      private var _itemWindowPet:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _rareTag:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      public function PetCertificatePopup()
      {
         super();
      }
      
      public function init(param1:GuiPet, param2:Function) : void
      {
         DarkenManager.showLoadingSpiral(true,true);
         _pet = param1;
         _closeCallback = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5097,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:Function = null;
         if(_closeCallback != null)
         {
            _loc1_ = _closeCallback;
            _closeCallback = null;
            _loc1_();
            return;
         }
         removeEventListeners();
         DarkenManager.unDarken(_petCertificatePopup);
         GuiManager.guiLayer.removeChild(_petCertificatePopup);
         _petCertificatePopup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _petCertificatePopup = param1.getChildAt(0) as MovieClip;
         _closeBtn = _petCertificatePopup.bx;
         _nameTxt = _petCertificatePopup.nameTxt;
         _adoptedTxt = _petCertificatePopup.adoptedTxt;
         _personalityTxt = _petCertificatePopup.personalityTxt;
         _favoriteToyTxt = _petCertificatePopup.favoriteToyTxt;
         _favoriteFoodTxt = _petCertificatePopup.favoriteFoodTxt;
         _itemWindowPet = _petCertificatePopup.itemWindowPet;
         _rareTag = _petCertificatePopup.rareTag;
         _rareTag.visible = false;
         _petCertificatePopup.x = 900 * 0.5;
         _petCertificatePopup.y = 550 * 0.5;
         _pet = _pet.clone(onPetLoaded);
         _itemWindowPet.addChild(_pet);
         setupTextFields();
         addEventListeners();
         GuiManager.guiLayer.addChild(_petCertificatePopup);
         DarkenManager.darken(_petCertificatePopup);
      }
      
      private function setupTextFields() : void
      {
         var _loc1_:DateTimeFormatter = null;
         var _loc2_:Date = null;
         LocalizationManager.updateToFit(_nameTxt,_pet.petName);
         if(_pet.createdTs == 0)
         {
            LocalizationManager.updateToFit(_adoptedTxt,"???");
         }
         else
         {
            _loc1_ = new DateTimeFormatter(LocalizationManager.localeForNumberFormatting,"medium","none");
            _loc2_ = new Date(_pet.createdTs * 1000);
            LocalizationManager.updateToFit(_adoptedTxt,_loc1_.format(_loc2_));
         }
         var _loc3_:PetDef = PetManager.getPetDef(_pet.getDefID());
         if(_loc3_)
         {
            if(_pet.personalityDefId != 0)
            {
               GenericListXtCommManager.requestGenericList(432,onPersonalityListLoaded);
            }
            if(_pet.favoriteToyDefId != 0)
            {
               GenericListXtCommManager.requestGenericList(_loc3_.favoriteToyListId,onFavToyListLoaded);
            }
            if(_pet.favoriteFoodDefId != 0)
            {
               GenericListXtCommManager.requestGenericList(_loc3_.favoriteFoodListId,onFavFoodListLoaded);
            }
            if(_loc3_.isReward || _loc3_.status == 4)
            {
               _rareTag.visible = true;
            }
         }
      }
      
      private function addEventListeners() : void
      {
         _petCertificatePopup.addEventListener("mouseDown",onPopup,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _petCertificatePopup.removeEventListener("mouseDown",onPopup);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc3_:Rectangle = Utility.getVisibleBounds(param1);
         var _loc4_:int = _loc3_.y + _loc3_.height;
         var _loc5_:int = _loc3_.x + _loc3_.width;
         var _loc6_:Number = _itemWindowPet.height / Math.max(_loc5_,_loc4_);
         _pet.scaleX = _loc6_;
         _pet.scaleY = _loc6_;
         _pet.y += _loc4_ * _loc6_ * 0.5;
      }
      
      private function onPersonalityListLoaded(param1:int, param2:Array) : void
      {
         var _loc3_:int = 0;
         if(_pet)
         {
            _loc3_ = 0;
            while(_loc3_ < param2.length)
            {
               if(param2[_loc3_] == _pet.personalityDefId)
               {
                  LocalizationManager.translateId(_personalityTxt,param2[_loc3_]);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function onFavToyListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         var _loc4_:int = 0;
         if(_pet)
         {
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               if(param2[_loc4_] == _pet.favoriteToyDefId)
               {
                  LocalizationManager.translateId(_favoriteToyTxt,param3[_loc4_]);
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function onFavFoodListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         var _loc4_:int = 0;
         if(_pet)
         {
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               if(param2[_loc4_] == _pet.favoriteFoodDefId)
               {
                  LocalizationManager.translateId(_favoriteFoodTxt,param3[_loc4_]);
                  break;
               }
               _loc4_++;
            }
         }
      }
   }
}

