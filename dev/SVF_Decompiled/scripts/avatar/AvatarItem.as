package avatar
{
   import com.sbi.graphics.LayerAnim;
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import flash.display.Sprite;
   import flash.geom.Point;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class AvatarItem implements Iitem
   {
      private var _currAvatar:Avatar;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _diamondItem:DiamondItem;
      
      private var _invIdx:int;
      
      private var _currAvatarDef:AvatarDef;
      
      private var _customAvType:int;
      
      private var _endTime:uint;
      
      private var _isShopItem:Boolean;
      
      private var _currAvatarView:AvatarView;
      
      private var _status:int;
      
      public function AvatarItem()
      {
         super();
      }
      
      public function init(param1:int, param2:int = 0, param3:Boolean = false, param4:int = -1, param5:DiamondItem = null) : void
      {
         _customAvType = param4;
         if(param4 != -1)
         {
            _currAvatarDef = gMainFrame.userInfo.getAvatarDefByAvType(param4,true) as AvatarDef;
         }
         else
         {
            _currAvatarDef = gMainFrame.userInfo.getAvatarDefByAvType(param1,false) as AvatarDef;
         }
         _status = !!param5 ? param5.status : _currAvatarDef.status;
         _isIconLoaded = false;
         _invIdx = param2;
         _diamondItem = param5;
         _isShopItem = param3;
         _endTime = !!param5 ? param5.availabilityEndTime : _currAvatarDef.availabilityEndTime;
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:AvatarItem = param1 as AvatarItem;
         if(_loc2_)
         {
            if(_currAvatarDef && defId == param1.defId)
            {
               if(value != _loc2_.value || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || _endTime != _loc2_._endTime)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get avt() : Avatar
      {
         return AvatarUtility.findCreationAvatarByType(defId,_customAvType);
      }
      
      public function get layerId() : int
      {
         throw new Error("AvatarItem does not contain layerId");
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get name() : String
      {
         return LocalizationManager.translateIdOnly(_currAvatarDef.titleStrRef);
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _currAvatarDef.isMemOnly;
      }
      
      public function set isMemberOnly(param1:Boolean) : void
      {
         throw new Error("AvatarItem does not implement changing member only value");
      }
      
      public function get enviroType() : int
      {
         return _currAvatarDef.enviroTypeFlag;
      }
      
      public function get recycleValue() : int
      {
         if(_diamondItem)
         {
            return _diamondItem.value;
         }
         return _currAvatarDef.cost * gMainFrame.clientInfo.recyclePercentage;
      }
      
      public function get currencyType() : int
      {
         if(_diamondItem)
         {
            return 3;
         }
         return 0;
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
         if(_diamondItem)
         {
            return _diamondItem.startTime;
         }
         if(_currAvatarDef)
         {
            return _currAvatarDef.availabilityStartTime;
         }
         return 0;
      }
      
      public function get itemStatus() : int
      {
         return _status;
      }
      
      public function get value() : *
      {
         if(_diamondItem)
         {
            return _diamondItem.isOnSale ? _diamondItem.value : (isOnSale ? Math.ceil(_diamondItem.value * 0.5) : _diamondItem.value);
         }
         return isOnSale ? Math.ceil(_currAvatarDef.cost * 0.5) : _currAvatarDef.cost;
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
         return _customAvType != -1 ? CustomAvatarDef(_currAvatarDef).avatarRefId : _currAvatarDef.defId;
      }
      
      public function get customAvType() : int
      {
         return _customAvType;
      }
      
      public function set defId(param1:int) : void
      {
         throw new Error("Should not be changing this defId here");
      }
      
      public function get icon() : Sprite
      {
         var _loc1_:Point = null;
         if(!_currAvatarView)
         {
            _currAvatar = AvatarUtility.findCreationAvatarByType(defId,_customAvType);
            _currAvatarView = new AvatarView();
            _currAvatarView.init(_currAvatar);
            _loc1_ = AvatarUtility.getAnimalItemWindowOffset(defId);
            _currAvatarView.x = _loc1_.x;
            _currAvatarView.y = _loc1_.y;
            _currAvatarView.playAnim(13,false,1,onAvatarLoaded);
         }
         return _currAvatarView;
      }
      
      public function get largeIcon() : Sprite
      {
         return icon();
      }
      
      public function get isShopItem() : Boolean
      {
         return _isShopItem;
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return null;
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
      
      public function destroy() : void
      {
         _currAvatarDef = null;
         if(_currAvatarView)
         {
            _currAvatarView.destroy();
            _currAvatarView = null;
         }
      }
      
      public function clone() : Iitem
      {
         var _loc1_:AvatarItem = new AvatarItem();
         _loc1_.init(defId,_invIdx,_isShopItem,_customAvType,_diamondItem);
         _loc1_.updateValueWithNewStatus(_status);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      public function get isOnSale() : Boolean
      {
         return itemStatus == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return itemStatus == 3;
      }
      
      public function get isRare() : Boolean
      {
         return itemStatus == 4;
      }
      
      public function get isNew() : Boolean
      {
         return itemStatus == 1;
      }
      
      public function get isLandAndOcean() : Boolean
      {
         return Utility.isLandAndOcean(enviroType);
      }
      
      public function get isOcean() : Boolean
      {
         return Utility.isOcean(enviroType);
      }
      
      public function get isLand() : Boolean
      {
         return Utility.isLand(enviroType);
      }
      
      public function get isDiamond() : Boolean
      {
         return _diamondItem != null;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      private function onAvatarLoaded(param1:LayerAnim, param2:int) : void
      {
         _isIconLoaded = true;
         if(_imageLoadedCallback != null)
         {
            _imageLoadedCallback();
            _imageLoadedCallback = null;
         }
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
            _status = param1;
         }
      }
      
      public function get isAvailable() : Boolean
      {
         if(_diamondItem)
         {
            if(AvatarUtility.getAvatarDefIsViewable(avt,_customAvType != -1))
            {
               return true;
            }
            return _diamondItem.isAvailable;
         }
         if(_currAvatarDef == null)
         {
            return false;
         }
         return Utility.isAvailable(_currAvatarDef.availabilityStartTime,_currAvatarDef.availabilityEndTime);
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

