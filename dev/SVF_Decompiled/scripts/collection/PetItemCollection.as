package collection
{
   import pet.PetItem;
   
   public class PetItemCollection extends IitemCollection
   {
      public function PetItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getPetItem(param1:uint) : PetItem
      {
         return items[param1] as PetItem;
      }
      
      public function setPetItem(param1:uint, param2:PetItem) : void
      {
         setItemCommon(param1,param2);
      }
      
      public function pushPetItem(param1:PetItem) : uint
      {
         return pushItemCommon(param1);
      }
   }
}

