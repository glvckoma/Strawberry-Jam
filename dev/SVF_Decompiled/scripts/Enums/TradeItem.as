package Enums
{
   public class TradeItem
   {
      public static const ITEM_TYPE_ACCESSORY_ITEM:int = 0;
      
      public static const ITEM_TYPE_DEN_ITEM:int = 1;
      
      public static const ITEM_TYPE_AUDIO_ITEM:int = 2;
      
      public static const ITEM_TYPE_PET_ITEM:int = 3;
      
      private var _invIdx:int;
      
      private var _itemType:int;
      
      public function TradeItem(param1:int, param2:int)
      {
         super();
         _invIdx = param1;
         _itemType = param2;
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get itemType() : int
      {
         return _itemType;
      }
      
      public function isEqual(param1:TradeItem) : Boolean
      {
         return _invIdx == param1.invIdx && _itemType == param1.itemType;
      }
   }
}

