package collection
{
   import item.Item;
   
   public class AccItemCollection extends IitemCollection
   {
      public function AccItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getAccItem(param1:uint) : Item
      {
         return items[param1] as Item;
      }
      
      public function setAccItem(param1:uint, param2:Item) : void
      {
         setItemCommon(param1,param2);
      }
      
      public function pushAccItem(param1:Item) : uint
      {
         return pushItemCommon(param1);
      }
   }
}

