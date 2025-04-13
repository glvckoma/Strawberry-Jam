package collection
{
   public class BaseTypedCollection
   {
      protected var typedItems:Array;
      
      public function BaseTypedCollection(param1:Array = null)
      {
         super();
         if(param1)
         {
            typedItems = param1;
         }
         else
         {
            typedItems = [];
         }
      }
      
      public function get length() : uint
      {
         return typedItems.length;
      }
      
      protected function setCommon(param1:uint, param2:*) : void
      {
         typedItems[param1] = param2;
      }
      
      protected function pushCommon(param1:*) : uint
      {
         return typedItems.push(param1);
      }
      
      public function concatCollection(param1:BaseTypedCollection) : Array
      {
         if(param1 != null)
         {
            return typedItems.concat(param1.getCoreArray());
         }
         return typedItems.concat();
      }
      
      public function getCoreArray() : Array
      {
         return typedItems;
      }
      
      public function setCoreArray(param1:Array) : void
      {
         typedItems = param1;
      }
      
      public function toString() : String
      {
         return "{typedItems:" + typedItems + "}";
      }
   }
}

