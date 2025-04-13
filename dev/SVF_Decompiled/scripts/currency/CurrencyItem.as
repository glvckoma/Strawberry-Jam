package currency
{
   import diamond.DiamondItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import inventory.Iitem;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   
   public class CurrencyItem implements Iitem
   {
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      private var _currencyExchangeDef:Object;
      
      private var _defId:int;
      
      private var _mediaId:int;
      
      private var _result:int;
      
      private var _resultType:int;
      
      private var _value:int;
      
      private var _currencyType:int;
      
      private var _name:String;
      
      private var _itemStatus:int;
      
      private var _isMemberOnly:Boolean;
      
      private var _enviroType:int;
      
      private var _endTime:uint;
      
      private var _mediaIdLarge:int;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaHelperLarge:MediaHelper;
      
      private var _waitForSmallIcon:Boolean;
      
      private var _waitForLargeIcon:Boolean;
      
      private var _icon:Sprite;
      
      private var _largeIcon:Sprite;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      public function CurrencyItem()
      {
         super();
      }
      
      public function init(param1:int) : void
      {
         _defId = param1;
         _currencyExchangeDef = ItemXtCommManager.getCurrencyExchangeDef(param1);
         _mediaId = _mediaIdLarge = _currencyExchangeDef.mediaId;
         _value = _currencyExchangeDef.value;
         _name = _currencyExchangeDef.name;
         _isMemberOnly = false;
         _enviroType = 0;
         _currencyType = _currencyExchangeDef.currencyType;
         _result = _currencyExchangeDef.result;
         _resultType = _currencyExchangeDef.resultType;
         _endTime = _currencyExchangeDef.availabilityEndTime;
         _icon = new Sprite();
         _largeIcon = new Sprite();
         _waitForSmallIcon = _waitForLargeIcon = true;
         makeIcons();
      }
      
      public function destroy() : void
      {
         _icon = null;
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:CurrencyItem = param1 as CurrencyItem;
         if(_loc2_)
         {
            if(_defId == param1.defId)
            {
               if(value != _loc2_.value || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || name != _loc2_.name || _endTime != _loc2_._endTime)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function clone() : Iitem
      {
         var _loc1_:CurrencyItem = new CurrencyItem();
         _loc1_.init(_defId);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      private function makeIcons() : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_mediaId,onIconLoaded,true);
         _mediaHelperLarge = new MediaHelper();
         _mediaHelperLarge.init(_mediaIdLarge,onLargeIconLoaded,true);
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(_mediaId == param1.mediaHelper.id)
         {
            if(_icon)
            {
               _icon.addChild(param1);
            }
         }
         if(_imageLoadedCallback != null)
         {
            _imageLoadedCallback();
         }
         _isIconLoaded = true;
      }
      
      private function onLargeIconLoaded(param1:MovieClip) : void
      {
         if(_mediaIdLarge == param1.mediaHelper.id)
         {
            if(_largeIcon)
            {
               _largeIcon.addChild(param1);
            }
         }
      }
      
      public function get icon() : Sprite
      {
         return _icon;
      }
      
      public function get largeIcon() : Sprite
      {
         return _largeIcon;
      }
      
      public function get mediaId() : int
      {
         return _mediaId;
      }
      
      public function get mediaIdLarge() : int
      {
         return _mediaIdLarge;
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _isMemberOnly;
      }
      
      public function set isMemberOnly(param1:Boolean) : void
      {
         throw new Error("CurrencyItem does not implement changing member only value");
      }
      
      public function get isOnSale() : Boolean
      {
         return _itemStatus == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return _itemStatus == 3;
      }
      
      public function get isRare() : Boolean
      {
         return _itemStatus == 4;
      }
      
      public function get isNew() : Boolean
      {
         return _itemStatus == 1;
      }
      
      public function get isOcean() : Boolean
      {
         return _enviroType == 1;
      }
      
      public function get isLand() : Boolean
      {
         return _enviroType == 0;
      }
      
      public function get isLandAndOcean() : Boolean
      {
         return _enviroType == 3;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
      }
      
      public function set itemStatus(param1:int) : void
      {
         _itemStatus = param1;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function set currencyType(param1:int) : void
      {
         _currencyType = param1;
      }
      
      public function get value() : *
      {
         return _value;
      }
      
      public function set value(param1:int) : void
      {
         _value = param1;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get endTime() : uint
      {
         return _endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         _endTime = param1;
      }
      
      public function get startTime() : uint
      {
         if(_currencyExchangeDef)
         {
            return _currencyExchangeDef.availabilityStartTime;
         }
         return 0;
      }
      
      public function get isIconLoaded() : Boolean
      {
         return _isIconLoaded;
      }
      
      public function get imageLoadedCallback() : Function
      {
         return _imageLoadedCallback;
      }
      
      public function set imageLoadedCallback(param1:Function) : void
      {
         _imageLoadedCallback = param1;
      }
      
      public function get enviroType() : int
      {
         throw new Error("CurrencyItem does not contain a enviroType");
      }
      
      public function get diamondDefId() : int
      {
         throw new Error("CurrencyItem does not contain diamondDefId");
      }
      
      public function set diamondDefId(param1:int) : void
      {
         throw new Error("CurrencyItem does not support setting this value");
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         throw new Error("CurrencyItem does not contain combinedCurrencyItem");
      }
      
      public function get isShopItem() : Boolean
      {
         throw new Error("CurrencyItem does not contain isShopItem");
      }
      
      public function get layerId() : int
      {
         throw new Error("CurrencyItem does not contain layerId");
      }
      
      public function get invIdx() : int
      {
         throw new Error("CurrencyItem does not contain invIdx");
      }
      
      public function get recycleValue() : int
      {
         throw new Error("CurrencyItem does not contain recycleValue");
      }
      
      public function get isDiamond() : Boolean
      {
         return false;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      public function get isApproved() : Boolean
      {
         return true;
      }
      
      public function set isApproved(param1:Boolean) : void
      {
      }
      
      public function get isCustom() : Boolean
      {
         return false;
      }
      
      public function updateValueWithNewStatus(param1:int) : void
      {
      }
      
      public function get diamondItem() : DiamondItem
      {
         return null;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
      }
      
      public function get isAvailable() : Boolean
      {
         if(_currencyExchangeDef == null)
         {
            return false;
         }
         return Utility.isAvailable(_currencyExchangeDef.availabilityStartTime,_currencyExchangeDef.availabilityEndTime);
      }
      
      public function get isInDenShop() : Boolean
      {
         return false;
      }
      
      public function get itemType() : int
      {
         return -1;
      }
      
      public function get denStoreInvId() : int
      {
         return 0;
      }
      
      public function set denStoreInvId(param1:int) : void
      {
      }
      
      public function set asShopItemSized(param1:Boolean) : void
      {
      }
   }
}

