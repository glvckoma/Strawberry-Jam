package gui
{
   import avatar.AvatarManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class PetMastery
   {
      private const MASTERY_MEDIA_ID:int = 1381;
      
      private var _masteryPopup:MovieClip;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currPet:GuiPet;
      
      public function PetMastery()
      {
         super();
      }
      
      public function init() : void
      {
         _guiLayer = GuiManager.guiLayer;
      }
      
      public function displayMasteryPopup() : void
      {
         if(_masteryPopup)
         {
            setupInitialConditions();
            _guiLayer.addChild(_masteryPopup);
            DarkenManager.darken(_masteryPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(1381,onMediaLoaded);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _masteryPopup = MovieClip(param1.getChildAt(0));
            setupInitialConditions();
            _masteryPopup.x = 900 * 0.5;
            _masteryPopup.y = 550 * 0.5;
            _guiLayer.addChild(_masteryPopup);
            DarkenManager.darken(_masteryPopup);
            addEventListeners();
         }
      }
      
      private function setupInitialConditions() : void
      {
         var _loc5_:int = 0;
         var _loc4_:* = 0;
         var _loc7_:* = 0;
         var _loc8_:* = 0;
         var _loc6_:* = 0;
         var _loc1_:* = 0;
         var _loc2_:* = 0;
         var _loc3_:Object = PetManager.myActivePet;
         if(_loc3_)
         {
            _loc5_ = 1;
            _loc4_ = int(_loc3_.uBits);
            _loc7_ = _loc4_ & 0x0F;
            _loc8_ = _loc4_ >> 4 & 0x0F;
            _loc6_ = _loc4_ >> 12 & 0x0F;
            _loc1_ = _loc4_ >> 16 & 0x0F;
            _loc2_ = _loc4_ >> 20 & 0x0F;
            _loc4_ = _loc2_ << 20 | _loc1_ << 16 | _loc6_ << 12 | _loc5_ << 8 | _loc8_ << 4 | _loc7_;
            _loc3_.uBits = _loc5_ << 8 | _loc4_;
            _currPet = new GuiPet(_loc3_.createdTs,_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,_loc3_.personalityDefId,_loc3_.favoriteToyDefId,_loc3_.favoriteFoodDefId,onPetLoaded);
            while(_masteryPopup.itemBlock.numChildren > 0)
            {
               _masteryPopup.itemBlock.removeChildAt(0);
            }
            _masteryPopup.itemBlock.addChild(_currPet);
            AvatarManager.playerAvatarWorldView.setActivePet(_currPet.createdTs,_currPet.getLBits(),_currPet.getUBits(),_currPet.getEBits(),_currPet.name,_currPet.personalityDefId,_currPet.favoriteFoodDefId,_currPet.favoriteToyDefId);
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _currPet.scaleY = 2.5;
         _currPet.scaleX = 2.5;
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMasteryClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_masteryPopup);
         _guiLayer.removeChild(_masteryPopup);
      }
      
      private function addEventListeners() : void
      {
         _masteryPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _masteryPopup.xb.addEventListener("mouseDown",onMasteryClose,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _masteryPopup.removeEventListener("mouseDown",onPopup);
         _masteryPopup.xb.removeEventListener("mouseDown",onMasteryClose);
      }
   }
}

