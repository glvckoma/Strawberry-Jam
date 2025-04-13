package den
{
   import collection.IntItemCollection;
   import flash.utils.Dictionary;
   
   public class DenMannequinInventory
   {
      private static var _invIdsUsed:Dictionary;
      
      public function DenMannequinInventory()
      {
         super();
         _invIdsUsed = new Dictionary(true);
      }
      
      public static function setItemInUse(param1:int, param2:int) : void
      {
         if(param1 > 0 && _invIdsUsed[param1] == null)
         {
            _invIdsUsed[param1] = param2;
         }
      }
      
      public static function removeItemFromUse(param1:int) : void
      {
         if(param1 > 0)
         {
            _invIdsUsed[param1] = null;
         }
      }
      
      public static function removeItemsFromUse(param1:IntItemCollection) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            removeItemFromUse(param1.getIntItem(_loc2_));
            _loc2_++;
         }
      }
      
      public static function setItemsInUse(param1:IntItemCollection, param2:int) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            setItemInUse(param1.getIntItem(_loc3_),param2);
            _loc3_++;
         }
      }
      
      public static function canUseItem(param1:int, param2:int) : Boolean
      {
         if(param1 > 0 && (_invIdsUsed[param1] == null || _invIdsUsed[param1] == param2))
         {
            return true;
         }
         return false;
      }
      
      public static function getIdOfWhoIsUsingThisItem(param1:int) : int
      {
         if(_invIdsUsed[param1] == null)
         {
            return -1;
         }
         return _invIdsUsed[param1];
      }
   }
}

