package collection
{
   import den.DenStateItem;
   
   public class DenStateItemCollection extends BaseTypedCollection
   {
      public function DenStateItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getDenStateItem(param1:uint) : DenStateItem
      {
         return typedItems[param1] as DenStateItem;
      }
      
      public function setDenStateItem(param1:uint, param2:DenStateItem) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushDenStateItem(param1:DenStateItem) : uint
      {
         return pushCommon(param1);
      }
   }
}

