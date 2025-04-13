package inventory
{
   import avatar.AccessoryState;
   import collection.DenItemCollection;
   import collection.IitemCollection;
   
   public class InventoryDenItem extends InventoryBase
   {
      public function InventoryDenItem()
      {
         super();
      }
      
      override public function init(param1:AccessoryState, param2:IitemCollection = null) : void
      {
         super.init(param1,new DenItemCollection());
      }
      
      public function get denItemCollection() : DenItemCollection
      {
         if(_itemCollection)
         {
            return _itemCollection as DenItemCollection;
         }
         return null;
      }
      
      public function set denItemCollection(param1:DenItemCollection) : void
      {
         if(param1)
         {
            super.itemArrayBase = param1 as IitemCollection;
         }
      }
   }
}

