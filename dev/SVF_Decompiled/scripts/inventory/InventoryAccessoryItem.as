package inventory
{
   import avatar.AccessoryState;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   
   public class InventoryAccessoryItem extends InventoryBase
   {
      public function InventoryAccessoryItem()
      {
         super();
      }
      
      override public function init(param1:AccessoryState, param2:IitemCollection = null) : void
      {
         super.init(param1,new AccItemCollection());
      }
      
      public function get itemCollection() : AccItemCollection
      {
         if(_itemCollection)
         {
            return _itemCollection as AccItemCollection;
         }
         return null;
      }
      
      public function set itemCollection(param1:AccItemCollection) : void
      {
         if(param1 != null)
         {
            super.itemArrayBase = param1 as IitemCollection;
         }
      }
   }
}

