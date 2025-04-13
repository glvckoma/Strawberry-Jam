package pet
{
   import diamond.DiamondItem;
   import diamond.DiamondXtCommManager;
   import gui.DarkenManager;
   import gui.EggPetHatchedPopup;
   import gui.EggPetPurchasePopup;
   import gui.GuiManager;
   import inventory.Iitem;
   
   public class EggPetGuiManager
   {
      private static var _eggPetPurchasePopup:EggPetPurchasePopup;
      
      private static var _eggPetHatchedPopup:EggPetHatchedPopup;
      
      private static var _eggPetList:Array;
      
      public function EggPetGuiManager()
      {
         super();
      }
      
      public static function openEggPetPurchasePopup() : void
      {
         var _loc1_:Iitem = null;
         DarkenManager.showLoadingSpiral(true);
         if(_eggPetList == null)
         {
            GenericListXtCommManager.requestGenericList(624,onEggPetListLoaded);
         }
         else
         {
            _loc1_ = _eggPetList[Math.floor(Math.random() * _eggPetList.length)];
            _eggPetPurchasePopup = new EggPetPurchasePopup(_loc1_,onEggPetPurchaseClose);
         }
      }
      
      public static function openEggHatchedPopup(param1:Array) : void
      {
         _eggPetHatchedPopup = new EggPetHatchedPopup(param1,eggHatchedPopupClose);
      }
      
      private static function onEggPetPurchaseClose() : void
      {
         _eggPetPurchasePopup = null;
      }
      
      private static function eggHatchedPopupClose() : void
      {
         _eggPetHatchedPopup = null;
         GuiManager.guiStartupChecks(true);
      }
      
      private static function onEggPetListLoaded(param1:int, param2:Array) : void
      {
         var _loc3_:PetDef = null;
         var _loc7_:Iitem = null;
         var _loc5_:int = 0;
         var _loc4_:DiamondItem = null;
         var _loc6_:int = 8;
         var _loc8_:int = int(param2[_loc6_++]);
         _eggPetList = [];
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc4_ = DiamondXtCommManager.getDiamondItem(int(param2[_loc6_++]));
            if(_loc4_.isPet)
            {
               _loc3_ = PetManager.getPetDef(_loc4_.refDefId);
               if(_loc3_ && _loc3_.isEgg)
               {
                  _loc7_ = new PetItem();
                  (_loc7_ as PetItem).init(0,_loc4_.refDefId,null,0,0,0,0,null,true,null,_loc4_);
                  _eggPetList.push(_loc7_);
               }
            }
            _loc5_++;
         }
         openEggPetPurchasePopup();
      }
   }
}

