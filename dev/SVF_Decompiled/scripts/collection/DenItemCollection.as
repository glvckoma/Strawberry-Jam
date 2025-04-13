package collection
{
   import den.DenItem;
   
   public class DenItemCollection extends IitemCollection
   {
      public function DenItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getDenItem(param1:uint) : DenItem
      {
         return items[param1] as DenItem;
      }
      
      public function setDenItem(param1:uint, param2:DenItem) : void
      {
         setItemCommon(param1,param2);
      }
      
      public function pushDenItem(param1:DenItem) : uint
      {
         return pushItemCommon(param1);
      }
   }
}

