package collection
{
   import inventory.Iitem;
   
   public class BaseItemCollection
   {
      protected var items:Array;
      
      public function BaseItemCollection(param1:Array = null)
      {
         super();
         if(param1)
         {
            items = param1;
         }
         else
         {
            items = [];
         }
      }
      
      public function get length() : uint
      {
         return items.length;
      }
      
      protected function setItemCommon(param1:uint, param2:Iitem) : void
      {
         items[param1] = param2;
      }
      
      protected function pushItemCommon(param1:Iitem) : uint
      {
         return items.push(param1);
      }
      
      public function concatCollection(param1:BaseItemCollection) : Array
      {
         if(param1 != null)
         {
            return items.concat(param1.getCoreArray());
         }
         return items.concat();
      }
      
      public function getCoreArray() : Array
      {
         return items;
      }
      
      public function setCoreArray(param1:Array) : void
      {
         items = param1;
      }
      
      public function toString() : String
      {
         return "{items:" + items + "}";
      }
   }
}

