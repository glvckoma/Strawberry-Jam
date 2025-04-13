package shop
{
   public class MyShopData
   {
      private var _state:String;
      
      private var _shopItems:Vector.<MyShopItem>;
      
      private var _storeInvId:int;
      
      public function MyShopData(param1:int, param2:String, param3:Vector.<MyShopItem>)
      {
         super();
         _storeInvId = param1;
         _shopItems = param3;
         _state = param2;
      }
      
      public function get storeInvId() : int
      {
         return _storeInvId;
      }
      
      public function set storeInvId(param1:int) : void
      {
         _storeInvId = param1;
      }
      
      public function get shopItems() : Vector.<MyShopItem>
      {
         return _shopItems;
      }
      
      public function set shopItems(param1:Vector.<MyShopItem>) : void
      {
         _shopItems = param1;
      }
      
      public function get state() : String
      {
         return _state;
      }
      
      public function set state(param1:String) : void
      {
         _state = param1;
      }
   }
}

