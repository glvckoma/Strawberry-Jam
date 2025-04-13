package collection
{
   import Enums.DenItemDef;
   
   public class DenItemDefCollection extends BaseTypedCollection
   {
      public function DenItemDefCollection()
      {
         super();
      }
      
      public function getDenItemDefItem(param1:uint) : DenItemDef
      {
         return typedItems[param1] as DenItemDef;
      }
      
      public function setDenItemDefItem(param1:uint, param2:DenItemDef) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushDenItemDefItem(param1:DenItemDef) : uint
      {
         return pushCommon(param1);
      }
   }
}

