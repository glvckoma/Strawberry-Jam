package pet
{
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class PetItem implements Iitem
   {
      private var _currPetDef:PetDef;
      
      private var _currGuiPet:GuiPet;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _diamondItem:DiamondItem;
      
      private var _invIdx:int;
      
      private var _isShopItem:Boolean;
      
      private var _endTime:uint;
      
      private var _status:int;
      
      private var _petBits:Array;
      
      private var _petName:String;
      
      private var _traitDefId:int;
      
      private var _toyDefId:int;
      
      private var _foodDefId:int;
      
      private var _createdTs:Number;
      
      private var _denStoreInvId:int;
      
      private var _asShopItemSized:Boolean;
      
      public function PetItem()
      {
         super();
      }
      
      public function init(param1:Number, param2:int, param3:Array, param4:int, param5:int, param6:int, param7:int = 0, param8:String = null, param9:Boolean = false, param10:Function = null, param11:DiamondItem = null, param12:int = 0) : void
      {
         _createdTs = param1;
         _currPetDef = PetManager.getPetDef(param2);
         _petBits = param3;
         _traitDefId = param4;
         _toyDefId = param5;
         _foodDefId = param6;
         _status = !!param11 ? param11.status : _currPetDef.status;
         _isIconLoaded = false;
         _invIdx = param7;
         _petName = param8;
         _diamondItem = param11;
         _isShopItem = param9;
         _endTime = !!param11 ? param11.availabilityEndTime : _currPetDef.availabilityEndTime;
         _imageLoadedCallback = param10;
         _denStoreInvId = param12;
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         var _loc2_:PetItem = param1 as PetItem;
         if(_loc2_)
         {
            if(_currPetDef && _currPetDef.defId == param1.defId)
            {
               if(value != _loc2_.value || isNew != _loc2_.isNew || isOnSale != _loc2_.isOnSale || _endTime != _loc2_._endTime || isInDenShop != _loc2_.isInDenShop)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function get layerId() : int
      {
         throw new Error("PetItem does not contain layerId");
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get currPetDef() : PetDef
      {
         return _currPetDef;
      }
      
      public function get name() : String
      {
         if(isEgg && !isHatched)
         {
            return "";
         }
         if(_petName != null)
         {
            return LocalizationManager.translatePetName(_petName);
         }
         return _currPetDef.title;
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _currPetDef.isMember;
      }
      
      public function get isEgg() : Boolean
      {
         return _currPetDef.isEgg;
      }
      
      public function get type() : int
      {
         return _currPetDef.type;
      }
      
      public function set isMemberOnly(param1:Boolean) : void
      {
         throw new Error("PetItem does not implement changing member only value");
      }
      
      public function get enviroType() : int
      {
         return PetManager.getEnviroTypeByPetType(_currPetDef,_createdTs);
      }
      
      public function get recycleValue() : int
      {
         if(_diamondItem)
         {
            return _diamondItem.value;
         }
         return _currPetDef.cost * gMainFrame.clientInfo.recyclePercentage;
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
         throw new Error("PetItem does not implement changing endTime");
      }
      
      public function get startTime() : uint
      {
         if(_diamondItem)
         {
            return _diamondItem.startTime;
         }
         if(_currPetDef)
         {
            return _currPetDef.availabilityStartTime;
         }
         return 0;
      }
      
      public function get itemStatus() : int
      {
         return _status;
      }
      
      public function set itemStatus(param1:int) : void
      {
         _status = param1;
      }
      
      public function get value() : *
      {
         if(_diamondItem)
         {
            return _diamondItem.isOnSale ? _diamondItem.value : (isOnSale ? Math.ceil(_diamondItem.value * 0.5) : _diamondItem.value);
         }
         return isOnSale ? Math.ceil(_currPetDef.cost * 0.5) : _currPetDef.cost;
      }
      
      public function get defId() : int
      {
         return _currPetDef.defId;
      }
      
      public function set defId(param1:int) : void
      {
         throw new Error("Should not be changing this defId here");
      }
      
      public function get icon() : Sprite
      {
         if(!_currGuiPet)
         {
            if(_petBits == null)
            {
               _petBits = PetManager.packPetBits(PetManager.createRandomPet(defId));
            }
            _currGuiPet = PetManager.getGuiPet(createdTs,defId,_petBits[0],_petBits[1],_petBits[2],_currPetDef.type,_currPetDef.title,_traitDefId,_foodDefId,_toyDefId,onPetLoaded);
         }
         return _currGuiPet;
      }
      
      public function get largeIcon() : Sprite
      {
         return icon;
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
         if(_currGuiPet)
         {
            _currGuiPet.destroy();
            _currGuiPet = null;
         }
      }
      
      public function clone() : Iitem
      {
         var _loc1_:PetItem = new PetItem();
         _loc1_.init(_createdTs,_currPetDef.defId,_petBits,_traitDefId,_toyDefId,_foodDefId,_invIdx,_petName,_isShopItem,imageLoadedCallback,_diamondItem,_denStoreInvId);
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
      
      public function get isOcean() : Boolean
      {
         return enviroType == 1;
      }
      
      public function get isLand() : Boolean
      {
         return enviroType == 0;
      }
      
      public function get isLandAndOcean() : Boolean
      {
         return enviroType == 3;
      }
      
      public function get isDiamond() : Boolean
      {
         return _diamondItem != null;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _isIconLoaded = true;
         if(_isShopItem || _asShopItemSized)
         {
            param1.scaleY = 3;
            param1.scaleX = 3;
            param1.y += param1.height * 0.35;
         }
         if(_imageLoadedCallback != null)
         {
            if(_imageLoadedCallback.length == 0)
            {
               _imageLoadedCallback();
            }
            else
            {
               _imageLoadedCallback(param1,param2);
            }
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
            itemStatus = param1;
         }
      }
      
      public function get diamondItem() : DiamondItem
      {
         return _diamondItem;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
         _diamondItem = param1;
      }
      
      public function get petBits() : Array
      {
         return _petBits;
      }
      
      public function setPetBits(param1:int, param2:int, param3:int) : void
      {
         _petBits = [param1,param2,param3];
      }
      
      public function get sortIdString() : String
      {
         return "";
      }
      
      public function get traitDefId() : int
      {
         return _traitDefId;
      }
      
      public function set traitDefId(param1:int) : void
      {
         _traitDefId = param1;
      }
      
      public function get toyDefId() : int
      {
         return _toyDefId;
      }
      
      public function set toyDefId(param1:int) : void
      {
         _toyDefId = param1;
      }
      
      public function get foodDefId() : int
      {
         return _foodDefId;
      }
      
      public function set foodDefId(param1:int) : void
      {
         _foodDefId = param1;
      }
      
      public function get createdTs() : Number
      {
         return _createdTs;
      }
      
      public function set createdTs(param1:Number) : void
      {
         _createdTs = param1;
      }
      
      public function get isHatched() : Boolean
      {
         return createdTs + 259200 <= Utility.getInitialEpochTime();
      }
      
      public function get isAvailable() : Boolean
      {
         if(_diamondItem)
         {
            if(PetManager.isPetAvailable(defId))
            {
               return true;
            }
            return _diamondItem.isAvailable;
         }
         if(_currPetDef == null)
         {
            return false;
         }
         return Utility.isAvailable(_currPetDef.availabilityStartTime,_currPetDef.availabilityEndTime);
      }
      
      public function get denStoreInvId() : int
      {
         return _denStoreInvId;
      }
      
      public function set denStoreInvId(param1:int) : void
      {
         _denStoreInvId = param1;
      }
      
      public function get isInDenShop() : Boolean
      {
         return _denStoreInvId > 0;
      }
      
      public function get itemType() : int
      {
         return 1;
      }
      
      public function set asShopItemSized(param1:Boolean) : void
      {
         _asShopItemSized = param1;
      }
   }
}

