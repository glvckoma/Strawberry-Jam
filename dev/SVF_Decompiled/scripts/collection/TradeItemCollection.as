package collection
{
   import Enums.TradeItem;
   
   public class TradeItemCollection extends BaseTypedCollection
   {
      public function TradeItemCollection(param1:Array = null)
      {
         super(param1);
      }
      
      public function getTradeItem(param1:uint) : TradeItem
      {
         return typedItems[param1] as TradeItem;
      }
      
      public function setTradeItem(param1:uint, param2:TradeItem) : void
      {
         setCommon(param1,param2);
      }
      
      public function pushTradeItem(param1:TradeItem) : uint
      {
         return pushCommon(param1);
      }
   }
}

