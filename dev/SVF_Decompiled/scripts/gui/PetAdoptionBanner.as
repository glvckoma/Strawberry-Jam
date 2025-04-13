package gui
{
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import pet.PetItem;
   import pet.PetManager;
   
   public class PetAdoptionBanner
   {
      private static var _popupMediaHelper:MediaHelper;
      
      private static var _popup:MovieClip;
      
      private static var _diamondPetDef:int;
      
      public function PetAdoptionBanner()
      {
         super();
      }
      
      public static function init(param1:int) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _diamondPetDef = param1;
         _popupMediaHelper = new MediaHelper();
         _popupMediaHelper.init(3759,onMediaLoaded);
      }
      
      public static function destroy() : void
      {
         if(_popupMediaHelper)
         {
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
         }
         if(_popup)
         {
            _popup.removeEventListener("mouseDown",onPopup);
            _popup.bx.removeEventListener("mouseDown",onClose);
            _popup.adoptBtn.removeEventListener("mouseDown",onAdoptBtn);
            DarkenManager.unDarken(_popup);
            if(_popup.parent && _popup.parent == GuiManager.guiLayer)
            {
               GuiManager.guiLayer.removeChild(_popup);
            }
            _popup = null;
         }
      }
      
      private static function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _popup = MovieClip(param1.getChildAt(0));
            _popup.addEventListener("mouseDown",onPopup,false,0,true);
            _popup.bx.addEventListener("mouseDown",onClose,false,0,true);
            _popup.adoptBtn.addEventListener("mouseDown",onAdoptBtn,false,0,true);
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            GuiManager.guiLayer.addChild(_popup);
            DarkenManager.darken(_popup);
         }
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private static function onAdoptBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:PetItem = new PetItem();
         _loc2_.diamondItem = DiamondXtCommManager.getDiamondItem(_diamondPetDef);
         if(_loc2_.diamondItem)
         {
            PetManager.openPetFinder(PetManager.petNameForDefId(_loc2_.diamondItem.refDefId),onPetFinderClose,false,null,_loc2_,3,214);
         }
      }
      
      private static function onPetFinderClose() : void
      {
         destroy();
      }
   }
}

