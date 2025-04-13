package shop
{
   import inventory.Iitem;
   
   public class MyShopItem
   {
      private var _currItem:Iitem;
      
      private var _currencyType:int;
      
      private var _cost:int;
      
      private var _shopInvIdx:int;
      
      public function MyShopItem(param1:Iitem, param2:int, param3:int, param4:int)
      {
         super();
         _currItem = param1;
         _currencyType = param2;
         _cost = param3;
         _shopInvIdx = param4;
      }
      
      public function get currItem() : Iitem
      {
         return _currItem;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function set currencyType(param1:int) : void
      {
         _currencyType = param1;
      }
      
      public function get cost() : int
      {
         return _cost;
      }
      
      public function set cost(param1:int) : void
      {
         _cost = param1;
      }
      
      public function get shopInvIdx() : int
      {
         return _shopInvIdx;
      }
      
      public function set shopInvIdx(param1:int) : void
      {
         _shopInvIdx = param1;
      }
   }
}

