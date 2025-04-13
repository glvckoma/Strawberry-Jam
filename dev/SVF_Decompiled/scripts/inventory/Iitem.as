package inventory
{
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import flash.display.Sprite;
   
   public interface Iitem
   {
      function get layerId() : int;
      
      function get invIdx() : int;
      
      function get name() : String;
      
      function get isMemberOnly() : Boolean;
      
      function set isMemberOnly(param1:Boolean) : void;
      
      function get enviroType() : int;
      
      function get recycleValue() : int;
      
      function get currencyType() : int;
      
      function get endTime() : uint;
      
      function set endTime(param1:uint) : void;
      
      function get startTime() : uint;
      
      function get itemStatus() : int;
      
      function get value() : *;
      
      function get defId() : int;
      
      function set defId(param1:int) : void;
      
      function get icon() : Sprite;
      
      function get largeIcon() : Sprite;
      
      function get isShopItem() : Boolean;
      
      function get combinedCurrencyItem() : CombinedCurrencyItem;
      
      function get isIconLoaded() : Boolean;
      
      function get imageLoadedCallback() : Function;
      
      function set imageLoadedCallback(param1:Function) : void;
      
      function destroy() : void;
      
      function clone() : Iitem;
      
      function ifItemDiffers(param1:Iitem) : Boolean;
      
      function get isOnSale() : Boolean;
      
      function get isOnClearance() : Boolean;
      
      function get isRare() : Boolean;
      
      function get isNew() : Boolean;
      
      function get isOcean() : Boolean;
      
      function get isLand() : Boolean;
      
      function get isLandAndOcean() : Boolean;
      
      function get isDiamond() : Boolean;
      
      function get isRareDiamond() : Boolean;
      
      function get isApproved() : Boolean;
      
      function set isApproved(param1:Boolean) : void;
      
      function get isCustom() : Boolean;
      
      function updateValueWithNewStatus(param1:int) : void;
      
      function set diamondItem(param1:DiamondItem) : void;
      
      function get diamondItem() : DiamondItem;
      
      function get isAvailable() : Boolean;
      
      function get isInDenShop() : Boolean;
      
      function get denStoreInvId() : int;
      
      function set denStoreInvId(param1:int) : void;
      
      function get itemType() : int;
      
      function set asShopItemSized(param1:Boolean) : void;
   }
}

