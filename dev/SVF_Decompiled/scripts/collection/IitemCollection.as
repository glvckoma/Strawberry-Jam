package collection
{
   import inventory.Iitem;
   
   public class IitemCollection extends BaseItemCollection
   {
      public function IitemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getIitem(param1:uint) : Iitem
      {
         return items[param1];
      }
      
      public function setIitem(param1:uint, param2:Iitem) : void
      {
         setItemCommon(param1,param2);
      }
      
      public function pushIitem(param1:Iitem) : uint
      {
         return pushItemCommon(param1);
      }
   }
}

