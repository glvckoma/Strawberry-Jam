package collection
{
   import den.DenRoomItem;
   
   public class DenRoomItemCollection extends IitemCollection
   {
      public function DenRoomItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getDenRoomItem(param1:uint) : DenRoomItem
      {
         return items[param1] as DenRoomItem;
      }
      
      public function setDenRoomItem(param1:uint, param2:DenRoomItem) : void
      {
         setItemCommon(param1,param2);
      }
      
      public function pushDenRoomItem(param1:DenRoomItem) : uint
      {
         return pushItemCommon(param1);
      }
   }
}

