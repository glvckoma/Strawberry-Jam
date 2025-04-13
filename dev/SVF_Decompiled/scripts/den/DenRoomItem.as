package den
{
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import inventory.Iitem;
   import loader.MediaHelper;
   
   public class DenRoomItem implements Iitem
   {
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      private var _denRoomDef:Object;
      
      private var _invId:int;
      
      private var _defId:int;
      
      private var _value:int;
      
      private var _name:String;
      
      private var _itemStatus:int;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _enviroType:int;
      
      private var _currencyType:int;
      
      private var _endTime:uint;
      
      private var _recycleValue:int;
      
      private var _diamondItem:DiamondItem;
      
      private var _mediaId:int;
      
      private var _mediaIdLarge:int;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaHelperLarge:MediaHelper;
      
      private var _isMemberOnly:Boolean;
      
      private var _waitForSmallIcon:Boolean;
      
      private var _waitForLargeIcon:Boolean;
      
      private var _icon:Sprite;
      
      private var _largeIcon:Sprite;
      
      private var _isShopItem:Boolean;
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      public function DenRoomItem()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:Object) : void
      {
         _invId = param1;
         _defId = param2;
         _denRoomDef = param3;
         _diamondItem = DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(param2,4));
         if(_diamondItem)
         {
            _itemStatus = _diamondItem.status;
            _value = _diamondItem.value;
            _currencyType = 3;
            _endTime = _diamondItem.availabilityEndTime;
         }
         else
         {
            _itemStatus = _denRoomDef.itemStatus;
            _value = isOnSale ? Math.ceil(_denRoomDef.value * 0.5) : _denRoomDef.value;
            _currencyType = _denRoomDef.currencyType;
            _endTime = param3.availabilityEndTime;
         }
         _mediaId = param3.mediaId;
         _recycleValue = _denRoomDef.value * gMainFrame.clientInfo.recyclePercentage;
         _name = param3.name;
         _isMemberOnly = param3.membersOnly;
         _enviroType = param3.enviroType;
         _icon = new Sprite();
         _waitForSmallIcon = true;
         _combinedCurrencyItem = null;
      }
      
      public function destroy() : void
      {
         _icon = null;
         _largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:Object) : void
      {
         _invId = param1;
         _defId = param2;
         _denRoomDef = param3;
         _mediaId = param3.mediaId;
         _mediaIdLarge = param3.mediaIdLarge;
         _diamondItem = DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(param2,4));
         if(_diamondItem)
         {
            _itemStatus = _diamondItem.status;
            _value = _diamondItem.value;
            _currencyType = 3;
            _endTime = _diamondItem.availabilityEndTime;
         }
         else
         {
            _itemStatus = _denRoomDef.itemStatus;
            _value = isOnSale ? Math.ceil(_denRoomDef.value * 0.5) : _denRoomDef.value;
            _currencyType = 0;
            _endTime = param3.availabilityEndTime;
         }
         _name = param3.name;
         _isMemberOnly = param3.membersOnly;
         _enviroType = param3.enviroType;
         _recycleValue = param3.value * gMainFrame.clientInfo.recyclePercentage;
         _combinedCurrencyItem = null;
         _isShopItem = true;
         _icon = new Sprite();
         _largeIcon = new Sprite();
         _waitForSmallIcon = _waitForLargeIcon = true;
         makeShopIcons();
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:DenRoomItem = param1 as DenRoomItem;
         if(_loc2_)
         {
            if(_defId == param1.defId)
            {
               if(value != _loc2_.value || _name != _loc2_._name || _isMemberOnly != _loc2_._isMemberOnly || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || _recycleValue != _loc2_._recycleValue || _currencyType != _loc2_._currencyType || _endTime != _loc2_._endTime)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function clone() : Iitem
      {
         var _loc1_:DenRoomItem = new DenRoomItem();
         if(_isShopItem)
         {
            _loc1_.initShopItem(_invId,_defId,_denRoomDef);
         }
         else
         {
            _loc1_.init(_invId,_defId,_denRoomDef);
         }
         _loc1_.updateValueWithNewStatus(_itemStatus);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      private function makeIcon() : void
      {
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(_mediaId,mediaHelperCallback,true);
      }
      
      private function makeShopIcons() : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_mediaId,mediaHelperCallback,true);
         _mediaHelperLarge = new MediaHelper();
         _mediaHelperLarge.init(_mediaIdLarge,mediaHelperCallback,true);
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         if(_mediaId == param1.mediaHelper.id)
         {
            if(_icon)
            {
               _icon.addChild(param1);
            }
            if(!_isShopItem)
            {
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
            if(_mediaHelper)
            {
               _mediaHelper.destroy();
               _mediaHelper = null;
            }
         }
         else if(_mediaIdLarge == param1.mediaHelper.id)
         {
            if(_largeIcon)
            {
               _largeIcon.addChild(param1);
            }
            if(!_isShopItem)
            {
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            if(_mediaHelperLarge)
            {
               _mediaHelperLarge.destroy();
               _mediaHelperLarge = null;
            }
         }
         if(_imageLoadedCallback != null)
         {
            _imageLoadedCallback();
         }
         _isIconLoaded = true;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function get invIdx() : int
      {
         return _invId;
      }
      
      public function get value() : *
      {
         return _value;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
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
         return _enviroType;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function get endTime() : uint
      {
         return _endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         throw new Error("DenRoomItem does not implement changing endTime");
      }
      
      public function get startTime() : uint
      {
         if(_diamondItem)
         {
            return _diamondItem.startTime;
         }
         if(_denRoomDef)
         {
            return _denRoomDef.availabilityStartTime;
         }
         return 0;
      }
      
      public function get recycleValue() : int
      {
         return _recycleValue;
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
         throw new Error("DenRoomItem does not implement changing member only value");
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
      
      public function get isDiamond() : Boolean
      {
         return _diamondItem != null;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      public function get diamondItem() : DiamondItem
      {
         return _diamondItem;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
         _diamondItem = param1;
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return _combinedCurrencyItem;
      }
      
      public function get isShopItem() : Boolean
      {
         return _isShopItem;
      }
      
      public function get layerId() : int
      {
         throw new Error("Unused in this class");
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
         if(!isRare)
         {
            _itemStatus = param1;
            if(isOnSale)
            {
               if(_diamondItem)
               {
                  if(_diamondItem.isOnSale)
                  {
                     _value = _diamondItem.value;
                  }
                  else
                  {
                     _value = Math.ceil(_diamondItem.value * 0.5);
                  }
               }
               else
               {
                  _value = Math.ceil(_denRoomDef.value * 0.5);
               }
            }
            else
            {
               _value = !!_diamondItem ? _diamondItem.value : _denRoomDef.value;
            }
            _recycleValue = _denRoomDef.recycleValue == 0 ? _denRoomDef.value * gMainFrame.clientInfo.recyclePercentage : _denRoomDef.recycleValue;
         }
      }
      
      public function get isAvailable() : Boolean
      {
         if(_diamondItem)
         {
            return _diamondItem.isAvailable;
         }
         if(_denRoomDef)
         {
            return Utility.isAvailable(_denRoomDef.availabilityStartTime,_denRoomDef.availabilityEndTime);
         }
         return false;
      }
      
      public function get isInDenShop() : Boolean
      {
         return false;
      }
      
      public function set isInDenShop(param1:Boolean) : void
      {
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

