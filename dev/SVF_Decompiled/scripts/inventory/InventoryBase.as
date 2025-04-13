package inventory
{
   import avatar.AccessoryState;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import item.Item;
   
   public class InventoryBase
   {
      protected var _itemCollection:IitemCollection;
      
      protected var _accState:AccessoryState;
      
      private var _indexedItemCollection:IntItemCollection;
      
      public function InventoryBase()
      {
         super();
      }
      
      public function init(param1:AccessoryState, param2:IitemCollection = null) : void
      {
         var _loc3_:int = 0;
         _accState = param1;
         _itemCollection = param2;
         _indexedItemCollection = new IntItemCollection();
         if(_itemCollection && _itemCollection.length > 0)
         {
            _loc3_ = 0;
            while(_loc3_ < _itemCollection.length)
            {
               _indexedItemCollection.setIntItem(_itemCollection.getIitem(_loc3_).invIdx,_loc3_);
               _loc3_++;
            }
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_itemCollection)
         {
            _loc1_ = 0;
            while(_loc1_ < _itemCollection.length)
            {
               _itemCollection.getIitem(_loc1_).destroy();
               _loc1_++;
            }
            _itemCollection = null;
            _indexedItemCollection = null;
         }
         if(_accState)
         {
            _accState.destroy();
            _accState = null;
         }
      }
      
      public function eraseAll() : void
      {
         _itemCollection = new IitemCollection();
         _indexedItemCollection = new IntItemCollection();
      }
      
      public function clone(param1:InventoryBase) : void
      {
         _itemCollection = new IitemCollection();
         _indexedItemCollection = new IntItemCollection();
         _accState = param1._accState;
         var _loc3_:IitemCollection = param1._itemCollection;
         for each(var _loc2_ in _loc3_.getCoreArray())
         {
            addItem(_loc2_.clone());
         }
      }
      
      public function addItem(param1:Iitem) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_itemCollection != null)
         {
            if(getItemIndexInItemArray(param1.invIdx) >= 0)
            {
               _loc3_ = int(_itemCollection.length);
               _loc2_ = 0;
               while(_loc2_ < _loc3_)
               {
                  if(_itemCollection.getIitem(_loc2_).ifItemDiffers(param1))
                  {
                     updateItem(param1);
                     break;
                  }
                  _loc2_++;
               }
            }
            else
            {
               _itemCollection.pushIitem(param1);
               _indexedItemCollection.setIntItem(param1.invIdx,_itemCollection.length - 1);
            }
         }
         else
         {
            _itemCollection.pushIitem(param1);
            _indexedItemCollection.setIntItem(param1.invIdx,_itemCollection.length - 1);
         }
      }
      
      public function removeItem(param1:Iitem) : void
      {
         var _loc2_:int = getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            _itemCollection.getCoreArray().splice(_loc2_,1);
            _indexedItemCollection.getCoreArray().splice(param1.invIdx,1);
         }
      }
      
      private function updateItem(param1:Iitem) : void
      {
         var _loc2_:int = getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            if(_accState != null)
            {
               _accState.replaceAccessory(_itemCollection.getIitem(_loc2_) as Item,param1 as Item);
            }
            _itemCollection.setIitem(_loc2_,param1);
            return;
         }
         throw new Error("WARNING: Inventory- Cannot update an item that doesn\'t exist in inventory.");
      }
      
      public function hasItem(param1:Iitem) : Boolean
      {
         if(getItemIndexInItemArray(param1.invIdx) >= 0)
         {
            return true;
         }
         return false;
      }
      
      protected function get itemArrayBase() : IitemCollection
      {
         return _itemCollection;
      }
      
      protected function set itemArrayBase(param1:IitemCollection) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _itemCollection = param1;
            _indexedItemCollection = new IntItemCollection();
            _loc2_ = 0;
            while(_loc2_ < _itemCollection.length)
            {
               _itemCollection.setIitem(_loc2_,_itemCollection.getIitem(_loc2_).clone());
               _indexedItemCollection.setIntItem(_itemCollection.getIitem(_loc2_).invIdx,_loc2_);
               _loc2_++;
            }
         }
      }
      
      public function get numItems() : int
      {
         return _itemCollection.length;
      }
      
      private function getItemIndexInItemArray(param1:int) : int
      {
         if(_indexedItemCollection.hasIntItem(param1))
         {
            return _indexedItemCollection.getIntItem(param1);
         }
         return -1;
      }
   }
}

