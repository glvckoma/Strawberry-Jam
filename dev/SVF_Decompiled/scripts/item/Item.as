package item
{
   import com.sbi.debug.DebugUtility;
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import diamond.DiamondXtCommManager;
   import flash.display.Sprite;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class Item implements Iitem
   {
      public static const BODY_MOD_TYPE:int = 0;
      
      public static const CLOTHING_TYPE:int = 1;
      
      public static const BASE_LAYER:int = 1;
      
      public static const PATTERN_LAYER:int = 2;
      
      public static const EYE_LAYER:int = 3;
      
      public static const TAIL_LAYER:int = 4;
      
      public static const LEG_LAYER:int = 5;
      
      public static const BACK_LAYER:int = 6;
      
      public static const NECK_LAYER:int = 7;
      
      public static const HEAD_LAYER_1:int = 8;
      
      public static const HEAD_LAYER_2:int = 9;
      
      public static const HEAD_LAYER_3:int = 10;
      
      public static const OCEAN_LEG_LAYER:int = 8;
      
      public static const OCEAN_BACK_LAYER:int = 6;
      
      public static const OCEAN_HEAD_LAYER:int = 7;
      
      public static const OCEAN_NECK_LAYER:int = 5;
      
      public static const NUM_DETAILS_PER_ITEM:int = 11;
      
      public static const COMBAT_TYPE_MELEE:int = 0;
      
      public static const COMBAT_TYPE_RANGED:int = 1;
      
      public static const MODIFIER_TYPE_NONE:int = 0;
      
      public static const MODIFIER_TYPE_RANGED:int = 1;
      
      public static const MODIFIER_TYPE_MELEE:int = 2;
      
      public static const MODIFIER_TYPE_DEFENSE:int = 3;
      
      public static const MODIFIER_TYPE_RESTORE:int = 4;
      
      private var _currDef:Object;
      
      private var _layerId:int;
      
      private var _invIdx:int;
      
      private var _accId:int;
      
      private var _color:uint;
      
      private var _name:String;
      
      private var _isGiftable:Boolean;
      
      private var _isMemberOnly:Boolean;
      
      private var _itemStatus:int;
      
      private var _type:int;
      
      private var _enviroType:int;
      
      private var _recycleValue:int;
      
      private var _currencyType:int;
      
      private var _avatarUseFlag:Object;
      
      private var _endTime:uint;
      
      private var _colors:Array;
      
      private var _equippedAvatars:EquippedAvatars;
      
      private var _value:int;
      
      private var _defId:int;
      
      private var _icon:Sprite;
      
      private var _iconHelper:SimpleIcon;
      
      private var _denStoreInvId:int;
      
      private var _largeIcon:Sprite;
      
      private var _largeIconHelper:SimpleIcon;
      
      private var _isShopItem:Boolean;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _iconLayerID:int = -1;
      
      private var _iconColorID:int = 0;
      
      private var _attackMediaRefId:int = 0;
      
      private var _defense:int = 0;
      
      private var _attack:int = 0;
      
      private var _combatType:int = 0;
      
      private var _fierce:int = 0;
      
      private var _modifierType:int = 0;
      
      private var _modifierValue:int = 0;
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      private var _specialScale:Number;
      
      private var _diamondItem:DiamondItem;
      
      private var _asShopItemSized:Boolean;
      
      public function Item()
      {
         super();
      }
      
      public function init(param1:int, param2:int = 0, param3:uint = 0, param4:EquippedAvatars = null, param5:Boolean = false, param6:Number = -1, param7:int = 0) : void
      {
         _defId = param1;
         _invIdx = param2;
         _color = param3;
         _equippedAvatars = param4 != null ? param4 : new EquippedAvatars();
         _isShopItem = param5;
         _specialScale = param6;
         _denStoreInvId = param7;
         _currDef = ItemXtCommManager.getItemDef(param1);
         if(_currDef == null)
         {
            DebugUtility.debugTrace("Item.init got invalid defId? defId:" + param1);
            return;
         }
         _layerId = _currDef.layerId;
         _accId = _currDef.accId;
         _name = _currDef.name;
         _isGiftable = _currDef.isGiftable;
         _diamondItem = DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_currDef.defId,0));
         if(_diamondItem)
         {
            _itemStatus = _diamondItem.status;
            _value = _diamondItem.value;
            _currencyType = 3;
            _endTime = _diamondItem.availabilityEndTime;
         }
         else
         {
            _itemStatus = _currDef.itemStatus;
            _value = isOnSale ? Math.ceil(_currDef.cost * 0.5) : _currDef.cost;
            _currencyType = _currDef.currencyType;
            _endTime = _currDef.availabilityEndTime;
         }
         _type = _currDef.type;
         _isMemberOnly = _currDef.isMembersOnly;
         _enviroType = _currDef.enviroType;
         _recycleValue = _currDef.recycleValue == 0 ? _currDef.cost * gMainFrame.clientInfo.recyclePercentage : _currDef.recycleValue;
         _avatarUseFlag = _currDef.avatarUseFlag;
         _colors = _currDef.colors;
         _attackMediaRefId = _currDef.attackMediaRefId;
         _defense = _currDef.defense;
         _attack = _currDef.attack;
         _combatType = _currDef.combatType;
         _fierce = _currDef.criticalHit;
         _modifierType = _currDef.modifierType;
         _modifierValue = _currDef.modifierValue;
         _largeIcon = null;
         _icon = null;
         if(_currencyType == 100)
         {
            _combinedCurrencyItem = new CombinedCurrencyItem(_currDef.combinedCurrencyString);
         }
         _isIconLoaded = false;
      }
      
      public function destroy() : void
      {
         if(_iconHelper)
         {
            _iconHelper.destroy();
            _iconHelper = null;
         }
         if(_largeIconHelper)
         {
            _largeIconHelper.destroy();
            _largeIconHelper = null;
         }
         if(_icon)
         {
            _icon = null;
         }
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:Item = param1 as Item;
         if(_loc2_)
         {
            if(_defId == param1.defId)
            {
               if(!_equippedAvatars.equals(_loc2_._equippedAvatars) || value != _loc2_.value || _color != _loc2_._color || _name != _loc2_._name || _isGiftable != _loc2_._isGiftable || _type != _loc2_._type || _layerId != _loc2_._layerId || _accId != _loc2_._accId || _isMemberOnly != _loc2_._isMemberOnly || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || _recycleValue != _loc2_._recycleValue || _currencyType != _loc2_._currencyType || _endTime != _loc2_._endTime || _specialScale != _loc2_.specialScale || isInDenShop != _loc2_.isInDenShop)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function clone() : Iitem
      {
         var _loc1_:Item = new Item();
         _loc1_.init(_defId,_invIdx,_color,_equippedAvatars.clone(),_isShopItem,_specialScale,_denStoreInvId);
         _loc1_.updateValueWithNewStatus(_itemStatus);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      public function makeSmallIcon() : void
      {
         if(_accId == 3)
         {
            return;
         }
         _isIconLoaded = false;
         _icon = new Sprite();
         _iconHelper = new SimpleIcon();
         _iconHelper.init(_color,_accId,1,_isShopItem,false,smallIconReceived);
      }
      
      public function makeLargeIcon() : void
      {
         if(_accId == 3)
         {
            return;
         }
         _isIconLoaded = false;
         _largeIcon = new Sprite();
         _largeIconHelper = new SimpleIcon();
         _largeIconHelper.init(_color,_accId,1,_isShopItem,false,largeIconReceived);
      }
      
      private function smallIconReceived() : void
      {
         _icon.addChild(_iconHelper.iconBitmap);
         resizeAndPositionIcon(false);
         _isIconLoaded = true;
         if(_iconLayerID >= 0)
         {
            if(_icon && _iconHelper)
            {
               _iconHelper.updateLayerColor(_iconLayerID,_iconColorID);
            }
            _iconLayerID = -1;
         }
      }
      
      private function largeIconReceived() : void
      {
         _largeIcon.addChild(_largeIconHelper.iconBitmap);
         resizeAndPositionIcon(true);
         _isIconLoaded = true;
      }
      
      public function setIconColor(param1:int, param2:uint) : void
      {
         _iconLayerID = param1;
         _iconColorID = param2;
         if(_icon && _iconHelper)
         {
            _iconHelper.updateLayerColor(_iconLayerID,_iconColorID);
         }
      }
      
      private function updateLargeIconColor() : void
      {
         if(_largeIcon && _largeIconHelper)
         {
            _largeIconHelper.updateLayerColor(_layerId,_color);
         }
      }
      
      private function updateIconColor() : void
      {
         if(_icon && _iconHelper)
         {
            _iconHelper.updateLayerColor(_layerId,_color);
         }
      }
      
      public function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         if(_isShopItem || param1 || _asShopItemSized)
         {
            if(param1)
            {
               _loc2_ = 1;
               _largeIcon.width *= _loc2_;
               _largeIcon.height *= _loc2_;
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            else
            {
               if(_specialScale > 0)
               {
                  _loc2_ = _specialScale;
               }
               else
               {
                  _loc2_ = 0.6;
               }
               _icon.width *= _loc2_;
               _icon.height *= _loc2_;
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
         }
         else
         {
            _loc2_ = 0.75;
            _icon.width *= _loc2_;
            _icon.height *= _loc2_;
            _icon.x = -(_icon.width * 0.5);
            _icon.y = -(_icon.height * 0.5);
         }
         if(_imageLoadedCallback != null)
         {
            _imageLoadedCallback();
         }
      }
      
      public function set asShopItemSized(param1:Boolean) : void
      {
         _asShopItemSized = param1;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
         _diamondItem = param1;
      }
      
      public function get diamondItem() : DiamondItem
      {
         return _diamondItem;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function get icon() : Sprite
      {
         if(!_icon)
         {
            makeSmallIcon();
         }
         else
         {
            updateIconColor();
         }
         return _icon;
      }
      
      public function get largeIcon() : Sprite
      {
         if(!_largeIcon)
         {
            makeLargeIcon();
         }
         else
         {
            updateLargeIconColor();
         }
         return _largeIcon;
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
      
      public function get startTime() : uint
      {
         if(_diamondItem)
         {
            return _diamondItem.startTime;
         }
         if(_currDef)
         {
            return _currDef.availabilityStartTime;
         }
         return 0;
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
      
      public function get attackMediaRefId() : int
      {
         return _attackMediaRefId;
      }
      
      public function get defense() : int
      {
         return _defense;
      }
      
      public function get attack() : int
      {
         return _attack;
      }
      
      public function get combatType() : int
      {
         return _combatType;
      }
      
      public function get modifierType() : int
      {
         return _modifierType;
      }
      
      public function get modifierValue() : int
      {
         return _modifierValue;
      }
      
      public function get fierceAttack() : int
      {
         return _fierce;
      }
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function cloneEquippedAvatars(param1:Boolean = false) : EquippedAvatars
      {
         if(param1 && _equippedAvatars.isEquippedOnAnyAvatars())
         {
            return EquippedAvatars.forced();
         }
         return _equippedAvatars.clone();
      }
      
      public function getInUse(param1:int = -1) : Boolean
      {
         return _equippedAvatars.isEquipped(param1);
      }
      
      public function setInUse(param1:int, param2:Boolean) : void
      {
         _equippedAvatars.setEquipped(param1,param2);
      }
      
      public function forceInUse(param1:Boolean) : void
      {
         _equippedAvatars.setForceInUse(param1);
      }
      
      public function updateValueWithNewStatus(param1:int) : void
      {
         if(_currencyType != 100 && !isRare && _currDef != null)
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
                  _value = Math.ceil(_currDef.cost * 0.5);
               }
            }
            else
            {
               _value = !!_diamondItem ? _diamondItem.value : _currDef.cost;
            }
            _recycleValue = _currDef.recycleValue == 0 ? _currDef.cost * gMainFrame.clientInfo.recyclePercentage : _currDef.recycleValue;
         }
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return _combinedCurrencyItem;
      }
      
      public function get sincleCurrencyCost() : int
      {
         return _value;
      }
      
      public function get value() : *
      {
         if(_currencyType == 100)
         {
            return _combinedCurrencyItem;
         }
         return _value;
      }
      
      public function get sortIdString() : String
      {
         switch(_layerId - 4)
         {
            case 0:
               return LocalizationManager.translateIdOnly(11209).toLowerCase();
            case 1:
               return LocalizationManager.translateIdOnly(11208).toLowerCase();
            case 2:
               return LocalizationManager.translateIdOnly(11207).toLowerCase();
            case 3:
               return LocalizationManager.translateIdOnly(11206).toLowerCase();
            case 4:
            case 5:
            case 6:
               return LocalizationManager.translateIdOnly(11205).toLowerCase();
            default:
               return "";
         }
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _isMemberOnly;
      }
      
      public function set isMemberOnly(param1:Boolean) : void
      {
         _isMemberOnly = param1;
      }
      
      public function get layerId() : int
      {
         return _layerId;
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get accId() : int
      {
         return _accId;
      }
      
      public function get color() : uint
      {
         return _color;
      }
      
      public function set color(param1:uint) : void
      {
         _color = param1;
      }
      
      public function get colors() : Array
      {
         return _colors;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get isGiftable() : Boolean
      {
         return _isGiftable;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get enviroType() : int
      {
         return _enviroType;
      }
      
      public function get recycleValue() : int
      {
         return _recycleValue;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function get avatarUseFlag() : Object
      {
         return _avatarUseFlag;
      }
      
      public function get endTime() : uint
      {
         return _endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         _endTime = param1;
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
      
      public function get isShopItem() : Boolean
      {
         return _isShopItem;
      }
      
      public function get specialScale() : Number
      {
         return _specialScale;
      }
      
      public function set specialScale(param1:Number) : void
      {
         _specialScale = param1;
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
      
      public function get isAvailable() : Boolean
      {
         if(_diamondItem)
         {
            return _diamondItem.isAvailable;
         }
         if(_currDef)
         {
            return Utility.isAvailable(_currDef.availabilityStartTime,_currDef.availabilityEndTime);
         }
         return false;
      }
      
      public function get isInDenShop() : Boolean
      {
         return _denStoreInvId > 0;
      }
      
      public function get denStoreInvId() : int
      {
         return _denStoreInvId;
      }
      
      public function get itemType() : int
      {
         return 2;
      }
      
      public function set denStoreInvId(param1:int) : void
      {
         _denStoreInvId = param1;
      }
   }
}

