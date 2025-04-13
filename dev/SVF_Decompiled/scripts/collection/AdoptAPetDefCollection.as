package collection
{
   import Enums.AdoptAPetDef;
   
   public class AdoptAPetDefCollection extends BaseTypedCollection
   {
      public function AdoptAPetDefCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getAdoptAPetItem(param1:uint) : AdoptAPetDef
      {
         return typedItems[param1] as AdoptAPetDef;
      }
      
      public function setAdoptAPetItem(param1:uint, param2:AdoptAPetDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushAdoptAPetItem(param1:AdoptAPetDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

