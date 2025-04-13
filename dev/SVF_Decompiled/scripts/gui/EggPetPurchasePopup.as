package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import inventory.Iitem;
   import loader.MediaHelper;
   import pet.PetManager;
   
   public class EggPetPurchasePopup
   {
      private const MEDIA_ID:int = 5801;
      
      private var _randomEggPet:Iitem;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _eggPetPurchasePopup:MovieClip;
      
      public function EggPetPurchasePopup(param1:Iitem, param2:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _randomEggPet = param1;
         _closeCallback = param2;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5801,onPurchasePopupLoaded);
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(_eggPetPurchasePopup);
         GuiManager.guiLayer.removeChild(_eggPetPurchasePopup);
         removeEventListeners();
         _eggPetPurchasePopup = null;
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
      }
      
      private function onPurchasePopupLoaded(param1:MovieClip) : void
      {
         _eggPetPurchasePopup = MovieClip(param1.getChildAt(0));
         _eggPetPurchasePopup.x = 900 * 0.5;
         _eggPetPurchasePopup.y = 550 * 0.5;
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         GuiManager.guiLayer.addChild(_eggPetPurchasePopup);
         DarkenManager.darken(_eggPetPurchasePopup);
      }
      
      private function addEventListeners() : void
      {
         _eggPetPurchasePopup.buyBtn.addEventListener("mouseDown",OnBuyBtn,false,0,true);
         _eggPetPurchasePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _eggPetPurchasePopup.addEventListener("mouseDown",onPopup,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _eggPetPurchasePopup.buyBtn.addEventListener("mouseDown",OnBuyBtn,false,0,true);
         _eggPetPurchasePopup.bx.addEventListener("mouseDown",onClose,false,0,true);
         _eggPetPurchasePopup.addEventListener("mouseDown",onPopup,false,0,true);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function OnBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         PetManager.openPetFinder(PetManager.petNameForDefId(_randomEggPet.defId),onPetFinderClose,false,null,_randomEggPet,_randomEggPet.currencyType,0,true);
      }
      
      private function onPetFinderClose() : void
      {
         destroy();
      }
   }
}

