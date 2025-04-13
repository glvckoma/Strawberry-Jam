package shop
{
   import avatar.AvatarManager;
   import flash.utils.Dictionary;
   import gui.DarkenManager;
   import gui.GuiManager;
   import inventory.Iitem;
   
   public class ShopManager
   {
      public static const SHOP_MEDIA_ID:int = 3934;
      
      public static const SHOP_CHARM_BUY_MEDIA_ID:int = 6620;
      
      public static const DEN_EDIT_TUTORIAL_SHOP_PREVIEW:int = 6;
      
      public static const DEN_EDIT_TUTORIAL_SHOP_BUY:int = 7;
      
      public static const DEN_EDIT_TUTORIAL_COMPLETE:int = 8;
      
      public static const MAX_STORE_ITEMS:int = 24;
      
      private static const EXTENDED_ITEM_COUNT_BIT_INDEX:int = 1;
      
      private static const NUM_EXTRA_SLOTS_DEN:int = 1600;
      
      private static const NUM_EXTRA_SLOTS_ACC:int = 900;
      
      private static const NUM_ACC_SLOTS:int = 100;
      
      private static const NUM_DEN_SLOTS:int = 400;
      
      private static const NUM_AUDIO_SLOTS:int = 48;
      
      private static const WARNING_ITEM_COUNT:int = 95;
      
      private static const WARNING_DEN_ITEM_COUNT:int = 395;
      
      private static const WARNING_DEN_AUDIO_COUNT:int = 45;
      
      private static const WARNING_DEN_ROOM_COUNT_OFFSET:int = 3;
      
      public static var currentOpenShopId:int = 0;
      
      private static var _shop:Shop;
      
      private static var _bundleShop:BundleShop;
      
      private static var _numRemovedCount:int;
      
      private static var _allRemovalsSucceeded:Boolean;
      
      private static var _itemSoldPopup:ItemSoldPopup;
      
      private static var _itemsSold:Array;
      
      public static var myShopItems:Dictionary = new Dictionary();
      
      public function ShopManager()
      {
         super();
      }
      
      public static function get maxItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 100 + 900;
         }
         return 100;
      }
      
      public static function get maxDenItems() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 400 + 1600;
         }
         return 400;
      }
      
      public static function get maxAudioItems() : int
      {
         return 48;
      }
      
      public static function get warningItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 95 + 900;
         }
         return 95;
      }
      
      public static function get warningDenItemCount() : int
      {
         if((gMainFrame.userInfo.pendingFlags & 1 << 1) != 0)
         {
            return 395 + 1600;
         }
         return 395;
      }
      
      public static function get warningAudioItemCount() : int
      {
         return 45;
      }
      
      public static function get warningDenRoomCount() : int
      {
         return 200 - 3;
      }
      
      public static function isWorldShopOpen() : Boolean
      {
         return _shop != null;
      }
      
      public static function closeWorldShop() : void
      {
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
      }
      
      public static function launchStore(param1:int, param2:int) : void
      {
         if(_shop)
         {
            _shop.destroy();
         }
         if((param2 == 1000 || param1 == 168 || param1 == 415 || param1 == 626 || param1 >= 676 && param1 <= 681) && param1 != 338 && param1 != 669)
         {
            _shop = new ShopWithPreview();
            _shop.init(param1,param2,AvatarManager.playerAvatar,GuiManager.guiLayer,onShopClose);
         }
         else if(param1 == 1)
         {
            _bundleShop = new BundleShop(onShopClose);
         }
         else
         {
            _shop = new Shop();
            _shop.init(param1,param2,AvatarManager.playerAvatar,GuiManager.guiLayer,onShopClose);
         }
      }
      
      public static function launchDenShopStore(param1:int) : void
      {
         if(_shop)
         {
            _shop.destroy();
         }
         currentOpenShopId = param1;
         _shop = new ShopToSell();
         _shop.init(param1,0,AvatarManager.playerAvatar,GuiManager.guiLayer,onShopClose);
      }
      
      private static function onShopClose(param1:Boolean) : void
      {
         currentOpenShopId = 0;
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(_bundleShop)
         {
            _bundleShop = null;
         }
      }
      
      public static function ifShopToSellOpenCloseIt(param1:int = -1) : Boolean
      {
         if(_shop && _shop is ShopToSell)
         {
            if(param1 == -1 || (_shop as ShopToSell).isDenSaleShopOwner && (_shop as ShopToSell).shopInvId == param1)
            {
               onShopClose(false);
               return true;
            }
         }
         return false;
      }
      
      public static function addShopItemToMyList(param1:MyShopData) : void
      {
         if(myShopItems == null)
         {
            myShopItems = new Dictionary();
         }
         myShopItems[param1.storeInvId] = param1;
      }
      
      public static function clearShopItems(param1:int) : void
      {
         delete myShopItems[param1];
      }
      
      public static function updateShopState(param1:int, param2:String) : void
      {
         if(myShopItems[param1])
         {
            myShopItems[param1].state = param2;
         }
         if(_shop && _shop is ShopToSell)
         {
            (_shop as ShopToSell).updateMyShopDataState(param2,param1);
         }
      }
      
      public static function removeShopItemFromMyList(param1:int, param2:Iitem, param3:int) : void
      {
         var _loc6_:* = undefined;
         var _loc5_:int = 0;
         var _loc4_:MyShopData = myShopItems[param1];
         if(_loc4_)
         {
            _loc6_ = _loc4_.shopItems;
            _loc5_ = 0;
            while(_loc5_ < _loc6_.length)
            {
               if(_loc6_[_loc5_].currItem.itemType == param2.itemType && _loc6_[_loc5_].currItem.defId == param2.defId && _loc6_[_loc5_].currItem.invIdx == param3)
               {
                  _loc6_.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
         }
         if(_shop && _shop is ShopToSell)
         {
            (_shop as ShopToSell).removeItemFromStore(param2,param3);
         }
      }
      
      public static function findAndRemoveDenShopItems(param1:Vector.<MyShopItem>, param2:Function, param3:Object) : void
      {
         var _loc7_:MyShopData = null;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:MyShopData = null;
         DarkenManager.showLoadingSpiral(true);
         var _loc5_:Dictionary = new Dictionary();
         _numRemovedCount = 0;
         _allRemovalsSucceeded = true;
         _loc8_ = 0;
         while(_loc8_ < param1.length)
         {
            _loc7_ = myShopItems[param1[_loc8_].shopInvIdx];
            if(_loc7_)
            {
               if(_loc5_[param1[_loc8_].shopInvIdx] == null)
               {
                  _loc6_++;
                  _loc5_[param1[_loc8_].shopInvIdx] = {
                     "shopData":_loc7_,
                     "removedItems":new Vector.<MyShopItem>()
                  };
               }
               _loc5_[param1[_loc8_].shopInvIdx].removedItems.push(param1[_loc8_]);
            }
            _loc8_++;
         }
         if(_loc6_ > 0)
         {
            for each(var _loc9_ in _loc5_)
            {
               _loc4_ = _loc9_.shopData;
               ShopToSellXtCommManager.requestStoreUpdateItems(_loc4_.storeInvId,_loc4_.state,null,_loc9_.removedItems,null,onRemovalComplete,{
                  "totalRequests":_loc6_,
                  "callback":param2,
                  "passback":param3
               });
            }
         }
         else
         {
            param2(true,param3);
         }
      }
      
      private static function onRemovalComplete(param1:Boolean, param2:Object) : void
      {
         if(!param1)
         {
            _allRemovalsSucceeded = false;
         }
         _numRemovedCount++;
         if(param2.totalRequests == _numRemovedCount)
         {
            if(param2.callback != null)
            {
               param2.callback(_allRemovalsSucceeded,param2.passback);
            }
         }
      }
      
      public static function showItemSoldPopup(param1:Iitem, param2:int, param3:int, param4:int = -1) : void
      {
         if(_itemSoldPopup)
         {
            if(_itemsSold == null)
            {
               _itemsSold = [];
            }
            _itemsSold.push({
               "shopItem":param1,
               "soldAmount":param2,
               "currencyType":param3
            });
         }
         else
         {
            _itemSoldPopup = new ItemSoldPopup(param1,param2,param3,onCloseSoldPopup,param4);
         }
      }
      
      private static function onCloseSoldPopup(param1:int) : void
      {
         var _loc2_:Object = null;
         if(_itemSoldPopup)
         {
            _itemSoldPopup.destroy();
            _itemSoldPopup = null;
         }
         if(_itemsSold && _itemsSold.length > 0)
         {
            _loc2_ = _itemsSold.pop();
            _itemSoldPopup = new ItemSoldPopup(_loc2_.shopItem,_loc2_.soldAmount,_loc2_.currencyType,onCloseSoldPopup,param1);
         }
         else if(param1 != -1)
         {
            launchDenShopStore(param1);
         }
      }
   }
}

