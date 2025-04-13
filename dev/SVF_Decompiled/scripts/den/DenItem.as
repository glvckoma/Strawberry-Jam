package den
{
   import Enums.DenItemDef;
   import avatar.MannequinData;
   import currency.CombinedCurrencyItem;
   import diamond.DiamondItem;
   import diamond.DiamondXtCommManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import inventory.Iitem;
   import loader.DenItemHelper;
   import localization.LocalizationManager;
   import pet.PetDef;
   import pet.PetItem;
   import pet.PetManager;
   
   public class DenItem implements Iitem
   {
      public static const SORT_FLOOR:int = 0;
      
      public static const SORT_WALL:int = 1;
      
      public static const SORT_FLOORING:int = 2;
      
      public static const SORT_WALLPAPER:int = 3;
      
      public static const SORT_AUDIO:int = 4;
      
      public static const SORT_PLANT:int = 5;
      
      public static const SORT_TOY:int = 6;
      
      public static const SORT_PET:int = 99;
      
      public static const PLACE_CAT_FLOOR:int = 1;
      
      public static const PLACE_CAT_WALL:int = 2;
      
      public static const PLACE_CAT_ICONL:int = 3;
      
      public static const SPECIAL_TYPE_NORMAL:int = 0;
      
      public static const SPECIAL_TYPE_PORTAL:int = 1;
      
      public static const SPECIAL_TYPE_EMOTE:int = 2;
      
      public static const SPECIAL_TYPE_CHANGE:int = 3;
      
      public static const SPECIAL_TYPE_MANNEQUIN:int = 4;
      
      public static const SPECIAL_TYPE_DEN_STORE:int = 5;
      
      public static const SPECIAL_TYPE_ECO_GENERATOR:int = 6;
      
      public static const SPECIAL_TYPE_ECO_CONSUMER:int = 7;
      
      public static const REF_ID_DEN_ITEM:int = 0;
      
      public static const REF_ID_PET_ITEM:int = 1;
      
      public static const DEN_PET_LAYER_ID:int = 0;
      
      public static const DEF_AUDIO_DEF_ID:int = 617;
      
      public static const DEF_AUDIO_PACKED_ID:uint = 40435715;
      
      public static const DEF_AUDIO_INVIDX:int = -1;
      
      public static const DEF_AUDIO_STRMNAME:String = "MusDenDef";
      
      public static const DEF_AUDIO_VOL:int = 50;
      
      public static const DEF_DIAMOND_MASTERPIECE_ID:int = 221;
      
      public static const DEF_MASTERPIECE_ID:int = 2725;
      
      public static const WIND_SMALL_SIZE:int = 80;
      
      public static const WIND_MED_SIZE:int = 168;
      
      public static const WIND_LARGE_SIZE:int = 280;
      
      public static const ECO_CONSUMER_STATE_OFF:int = 0;
      
      public static const ECO_CONSUMER_STATE_ON:int = 1;
      
      public static const ECO_CONSUMER_STATE_OFFLINE:int = 2;
      
      private var _currDef:DenItemDef = null;
      
      private var _petDef:PetDef = null;
      
      private var _refId:int;
      
      private var _invIdx:int;
      
      private var _categoryId:int;
      
      private var _layerId:int;
      
      private var _name:String;
      
      private var _isMemberOnly:Boolean;
      
      private var _version:int;
      
      private var _version2:int;
      
      private var _version3:int;
      
      private var _strmName:String;
      
      private var _enviroType:int;
      
      private var _recycleValue:int;
      
      private var _currencyType:int;
      
      private var _endTime:uint;
      
      private var _specialType:int;
      
      private var _value:int;
      
      private var _defId:int;
      
      private var _sortId:int;
      
      private var _typeCatId:int;
      
      private var _petType:int;
      
      private var _isApproved:Boolean;
      
      private var _uniqueImageId:String;
      
      private var _uniqueImageCreator:String;
      
      private var _uniqueImageCreatorDbId:int;
      
      private var _uniqueImageCreatorUUID:String;
      
      private var _petTraitDefId:int;
      
      private var _petToyDefId:int;
      
      private var _petFoodDefId:int;
      
      private var _createdTs:Number;
      
      private var _petItem:PetItem;
      
      private var _mannequinData:MannequinData;
      
      private var _denStoreInvId:int;
      
      private var _ecoConsumerStateId:int;
      
      private var _itemStatus:int;
      
      private var _minigameDefId:int;
      
      private var _listId:int;
      
      private var _isIconLoaded:Boolean;
      
      private var _imageLoadedCallback:Function;
      
      private var _icon:Sprite;
      
      private var _iconHelper:DenItemHelper;
      
      private var _largeIcon:Sprite;
      
      private var _largeIconHelper:DenItemHelper;
      
      private var _isShopItem:Boolean;
      
      private var _listenToMouse:Boolean;
      
      private var _globalScale:Number = 1;
      
      private var _setRandomVersion:Boolean;
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      private var _diamondItem:DiamondItem;
      
      private var _asShopItemSized:Boolean;
      
      public function DenItem()
      {
         super();
      }
      
      public static function getIconId(param1:int) : int
      {
         if(param1 == 0 || param1 == 99 || param1 == 6 || param1 == 5)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 2;
         }
         if(param1 == 2 || param1 == 3 || param1 == 4)
         {
            return 3;
         }
         return param1 + 1;
      }
      
      public static function getInWorldId(param1:int, param2:int) : int
      {
         if(param1 == 0 || param1 == 99 || param1 == 6 || param1 == 5)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 2;
         }
         if(param1 == 4)
         {
            return 3;
         }
         return param2;
      }
      
      public function init(param1:int, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = 0, param6:PetItem = null, param7:Boolean = true, param8:String = "", param9:String = "", param10:int = -1, param11:String = "", param12:MannequinData = null, param13:int = 0, param14:int = 0) : void
      {
         _refId = param5;
         _invIdx = param2;
         _defId = param1;
         _categoryId = param3;
         _version = param4;
         _isApproved = param7;
         _uniqueImageId = param8;
         _denStoreInvId = param13;
         if(param9.charAt(0) == "#")
         {
            _uniqueImageCreator = LocalizationManager.translateIdOnly(int(param9.substr(1)));
         }
         else
         {
            _uniqueImageCreator = param9;
         }
         _uniqueImageCreatorDbId = param10;
         _uniqueImageCreatorUUID = param11;
         _mannequinData = param12;
         _ecoConsumerStateId = param14;
         _diamondItem = DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_defId,1));
         _largeIcon = null;
         _icon = null;
         _isIconLoaded = false;
         if(param5 == 1)
         {
            _petDef = PetManager.getPetDef(_defId);
            _defId = DenXtCommManager.denItemDefIdForPetDefId(_defId);
            _layerId = 0;
            _sortId = 99;
            _typeCatId = 99;
            _isMemberOnly = _petDef.isMember;
            if(_diamondItem)
            {
               _itemStatus = _diamondItem.status;
               _value = _diamondItem.value;
               _currencyType = 3;
               _endTime = _diamondItem.availabilityEndTime;
            }
            else
            {
               _itemStatus = _petDef.status;
               _value = isOnSale ? Math.ceil(_petDef.cost * 0.5) : _petDef.cost;
               _currencyType = 0;
               _endTime = _petDef.availabilityEndTime;
            }
            _strmName = "";
            _name = _petDef.title;
            _minigameDefId = 0;
            _listId = 0;
            _petType = _petDef.type;
            _recycleValue = _petDef.cost * gMainFrame.clientInfo.recyclePercentage;
            _globalScale = 1;
            _specialType = 0;
            _combinedCurrencyItem = null;
            _petItem = param6;
            if(_petItem)
            {
               _petTraitDefId = _petItem.traitDefId;
               _petToyDefId = _petItem.toyDefId;
               _petFoodDefId = _petItem.foodDefId;
               _createdTs = _petItem.createdTs;
               _version = _petItem.petBits[0];
               _version2 = _petItem.petBits[1];
               _version3 = _petItem.petBits[2];
            }
            _enviroType = PetManager.getEnviroTypeByPetType(_petDef,_createdTs);
         }
         else
         {
            _currDef = DenXtCommManager.getDenItemDef(param1);
            if(_currDef)
            {
               _layerId = _currDef.layer;
               _sortId = _currDef.sortCat;
               _typeCatId = _currDef.typeCat;
               _isMemberOnly = _currDef.isMembersOnly;
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
               _strmName = _defId == 617 ? "MusDenDef" : _currDef.abbrName;
               _name = _currDef.name;
               _minigameDefId = _currDef.gameDefId;
               _listId = _currDef.listId;
               _version2 = _currDef.flag;
               _enviroType = _currDef.enviroType;
               _recycleValue = _currDef.recycleValue == 0 ? _currDef.cost * gMainFrame.clientInfo.recyclePercentage : _currDef.recycleValue;
               _globalScale = _currDef.scalePercent / 100;
               _specialType = _currDef.specialType;
               if(_currencyType == 100)
               {
                  _combinedCurrencyItem = new CombinedCurrencyItem(_currDef.combinedCurrencyString);
               }
               if(_mannequinData == null && _currDef.specialType == 4)
               {
                  _mannequinData = new MannequinData();
                  _mannequinData.init(_currDef,null,0,false,_invIdx,true);
               }
            }
         }
      }
      
      public function destroy() : void
      {
         if(_iconHelper)
         {
            _iconHelper.destroy();
            _iconHelper = null;
         }
         _icon = null;
         if(_largeIconHelper)
         {
            _largeIconHelper.destroy();
            _largeIconHelper = null;
         }
         _largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:Boolean = false) : void
      {
         _defId = param1;
         _setRandomVersion = param3;
         _version = param2;
         _currDef = DenXtCommManager.getDenItemDef(param1);
         _diamondItem = DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_defId,1));
         _name = _currDef.name;
         _isMemberOnly = _currDef.isMembersOnly;
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
         _minigameDefId = _currDef.gameDefId;
         _listId = _currDef.listId;
         _sortId = _currDef.sortCat;
         _typeCatId = _currDef.typeCat;
         _enviroType = _currDef.enviroType;
         _strmName = _currDef.abbrName;
         _version2 = _currDef.flag;
         _isShopItem = true;
         _globalScale = _currDef.scalePercent / 100;
         _specialType = _currDef.specialType;
         if(_currencyType == 100)
         {
            _combinedCurrencyItem = new CombinedCurrencyItem(_currDef.combinedCurrencyString);
         }
      }
      
      public function ifItemDiffers(param1:Iitem) : Boolean
      {
         if(_invIdx == param1.invIdx)
         {
            return true;
         }
         return false;
      }
      
      public function clone() : Iitem
      {
         var _loc1_:DenItem = new DenItem();
         if(_isShopItem)
         {
            _loc1_.initShopItem(_defId,_version,_setRandomVersion);
         }
         else
         {
            _loc1_.init(_defId,_invIdx,_categoryId,_version,_refId,_petItem,_isApproved,_uniqueImageId,uniqueImageCreator,uniqueImageCreatorDbId,uniqueImageCreatorUUID,_mannequinData != null ? _mannequinData.clone() : null,_denStoreInvId,_ecoConsumerStateId);
         }
         _loc1_.updateValueWithNewStatus(_itemStatus);
         _loc1_.imageLoadedCallback = imageLoadedCallback;
         return _loc1_;
      }
      
      public function makeSmallIcon() : void
      {
         _icon = new Sprite();
         _iconHelper = new DenItemHelper();
         _iconHelper.init(this,iconReceived,petItem,0,0,_mannequinData);
      }
      
      public function makeLargeIcon() : void
      {
         _largeIcon = new Sprite();
         _largeIconHelper = new DenItemHelper();
         _largeIconHelper.init(this,largeIconReceived,petItem,0,0,_mannequinData);
      }
      
      public function getVersions() : Array
      {
         var _loc1_:Array = null;
         if(_iconHelper)
         {
            _loc1_ = _iconHelper.getVersions();
         }
         else if(_largeIconHelper)
         {
            _loc1_ = _largeIconHelper.getVersions();
         }
         if(_loc1_ == null)
         {
            _version = 0;
            _loc1_ = [];
         }
         return _loc1_;
      }
      
      public function setVersion(param1:int, param2:int = 0, param3:int = 0) : void
      {
         _version = param1;
         if(_iconHelper)
         {
            _iconHelper.setVersion(param1,param2,param3);
         }
         else if(_largeIconHelper)
         {
            _largeIconHelper.setVersion(param1,param2,param3);
         }
      }
      
      public function rebuildMannequin() : void
      {
         if(_mannequinData != null && _iconHelper != null && _isIconLoaded)
         {
            _iconHelper.rebuildMannequinView();
         }
      }
      
      private function iconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         if(!Utility.doesItAnimate(param1.displayObject))
         {
            param1.displayObject.cacheAsBitmap = true;
         }
         _icon.addChild(param1.displayObject);
         _isIconLoaded = true;
         resizeAndPositionIcon(false);
         if(_setRandomVersion)
         {
            _loc2_ = getVersions();
            if(_loc2_)
            {
               setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
         else
         {
            setVersion(_version);
         }
      }
      
      private function largeIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         if(!Utility.doesItAnimate(param1.displayObject))
         {
            param1.displayObject.cacheAsBitmap = true;
         }
         _largeIcon.addChild(param1.displayObject);
         _isIconLoaded = true;
         resizeAndPositionIcon(true);
         if(_setRandomVersion)
         {
            _loc2_ = getVersions();
            if(_loc2_)
            {
               setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
         else
         {
            setVersion(_version);
         }
      }
      
      private function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Sprite = null;
         var _loc5_:int = 0;
         if(param1)
         {
            _loc2_ = Sprite(_largeIcon.getChildAt(0));
         }
         else
         {
            _loc2_ = Sprite(_icon.getChildAt(0));
         }
         var _loc3_:MovieClip = MovieClip(Loader(_loc2_.getChildAt(0)).content);
         _loc5_ = 0;
         while(_loc5_ < _loc3_.currentLabels.length)
         {
            if(_loc3_.currentLabels[_loc5_].name == "icon")
            {
               _loc3_.gotoAndStop("icon");
               break;
            }
            _loc5_++;
         }
         if(_isShopItem || param1 || _asShopItemSized)
         {
            if(param1)
            {
               if(_loc3_.hasOwnProperty("listenToMouseInShop"))
               {
                  _listenToMouse = _loc3_.listenToMouseInShop;
               }
               else
               {
                  _listenToMouse = true;
               }
               _loc4_ = 280 / Math.max(_largeIcon.width,_largeIcon.height) * _globalScale;
               _largeIcon.width *= _loc4_;
               _largeIcon.height *= _loc4_;
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            else
            {
               _loc4_ = 168 / Math.max(_icon.width,_icon.height) * _globalScale;
               _icon.width *= _loc4_;
               _icon.height *= _loc4_;
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
         }
         else
         {
            _loc4_ = 80 / Math.max(_icon.width,_icon.height) * _globalScale;
            _icon.width *= _loc4_;
            _icon.height *= _loc4_;
            _icon.x = -(_icon.width * 0.5);
            _icon.y = -(_icon.height * 0.5);
         }
         listenToMouse(_listenToMouse,_loc3_);
         if(_imageLoadedCallback != null)
         {
            _imageLoadedCallback();
         }
      }
      
      public function listenToMouse(param1:Boolean, param2:MovieClip = null) : void
      {
         var _loc3_:Sprite = null;
         _listenToMouse = param1;
         if(!param2)
         {
            if(_largeIcon)
            {
               if(_largeIcon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(_largeIcon.getChildAt(0));
            }
            else
            {
               if(!_icon || _icon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(_icon.getChildAt(0));
            }
            if(!_loc3_)
            {
               return;
            }
            param2 = MovieClip(Loader(_loc3_.getChildAt(0)).content);
         }
         if(param2 && param2.hasOwnProperty("listenToMouse"))
         {
            param2.listenToMouse = _listenToMouse;
         }
      }
      
      public function set asShopItemSized(param1:Boolean) : void
      {
         _asShopItemSized = param1;
      }
      
      public function get sortId() : int
      {
         return _sortId;
      }
      
      public function get typeCatId() : int
      {
         return _typeCatId;
      }
      
      public function get diamondItem() : DiamondItem
      {
         return _diamondItem;
      }
      
      public function set diamondItem(param1:DiamondItem) : void
      {
         _diamondItem = param1;
      }
      
      public function get icon() : Sprite
      {
         if(!_icon)
         {
            makeSmallIcon();
         }
         return _icon;
      }
      
      public function get largeIcon() : Sprite
      {
         if(!_largeIcon)
         {
            makeLargeIcon();
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
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function updateValueWithNewStatus(param1:int) : void
      {
         if(_currencyType != 100 && !isRare)
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
                  _value = Math.ceil((_currDef != null ? _currDef.cost : (_petDef != null ? _petDef.cost : 0)) * 0.5);
               }
            }
            else
            {
               _value = !!_diamondItem ? _diamondItem.value : (_currDef != null ? _currDef.cost : (_petDef != null ? _petDef.cost : 0));
            }
            if(_currDef != null)
            {
               _recycleValue = _currDef.recycleValue == 0 ? _currDef.cost * gMainFrame.clientInfo.recyclePercentage : _currDef.recycleValue;
            }
            else if(_petDef != null)
            {
               _recycleValue = _petDef.cost * gMainFrame.clientInfo.recyclePercentage;
            }
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
         switch(_layerId - 1)
         {
            case 0:
            case 1:
               return LocalizationManager.translateIdOnly(11215).toLowerCase();
            default:
               return "";
         }
      }
      
      public function get refId() : int
      {
         return _refId;
      }
      
      public function get categoryId() : int
      {
         return _categoryId;
      }
      
      public function set categoryId(param1:int) : void
      {
         _categoryId = param1;
      }
      
      public function get version() : int
      {
         return _version;
      }
      
      public function set version(param1:int) : void
      {
         _version = param1;
      }
      
      public function get version2() : int
      {
         return _version2;
      }
      
      public function set version2(param1:int) : void
      {
         _version2 = param1;
      }
      
      public function get version3() : int
      {
         return _version3;
      }
      
      public function set version3(param1:int) : void
      {
         _version3 = param1;
      }
      
      public function get strmName() : String
      {
         return _strmName;
      }
      
      public function get specialType() : int
      {
         return _specialType;
      }
      
      public function get minigameDefId() : int
      {
         return _minigameDefId;
      }
      
      public function get listId() : int
      {
         return _listId;
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
      
      public function get name() : String
      {
         if(_petItem && _petItem.isEgg && !_petItem.isHatched)
         {
            return "";
         }
         return _name;
      }
      
      public function set name(param1:String) : void
      {
         _name = param1;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
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
         if(_petItem)
         {
            return _petItem.startTime;
         }
         if(_currDef)
         {
            return _currDef.availabilityStartTime;
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
      
      public function get isShopItem() : Boolean
      {
         return _isShopItem;
      }
      
      public function get petType() : int
      {
         return _petType;
      }
      
      public function get isApproved() : Boolean
      {
         return _isApproved;
      }
      
      public function set isApproved(param1:Boolean) : void
      {
         _isApproved = param1;
      }
      
      public function get uniqueImageId() : String
      {
         return _uniqueImageId;
      }
      
      public function get uniqueImageCreator() : String
      {
         return _uniqueImageCreator;
      }
      
      public function set uniqueImageCreator(param1:String) : void
      {
         _uniqueImageCreator = param1;
      }
      
      public function get uniqueImageCreatorDbId() : int
      {
         return _uniqueImageCreatorDbId;
      }
      
      public function get uniqueImageCreatorUUID() : String
      {
         return _uniqueImageCreatorUUID;
      }
      
      public function get isCustom() : Boolean
      {
         return _defId == 2725;
      }
      
      public function get petTraitDefId() : int
      {
         return _petTraitDefId;
      }
      
      public function set petTraitDefId(param1:int) : void
      {
         _petTraitDefId = param1;
      }
      
      public function get petToyDefId() : int
      {
         return _petToyDefId;
      }
      
      public function set petToyDefId(param1:int) : void
      {
         _petToyDefId = param1;
      }
      
      public function get petFoodDefId() : int
      {
         return _petFoodDefId;
      }
      
      public function set petFoodDefId(param1:int) : void
      {
         _petFoodDefId = param1;
      }
      
      public function get createdTs() : Number
      {
         return _createdTs;
      }
      
      public function set createdTs(param1:Number) : void
      {
         _createdTs = param1;
      }
      
      public function get petItem() : PetItem
      {
         return _petItem;
      }
      
      public function get mannequinData() : MannequinData
      {
         return _mannequinData;
      }
      
      public function set mannequinData(param1:MannequinData) : void
      {
         _mannequinData = param1;
      }
      
      public function set globalScale(param1:int) : void
      {
         _globalScale = param1;
      }
      
      public function get isAvailable() : Boolean
      {
         if(_diamondItem)
         {
            return _diamondItem.isAvailable;
         }
         if(_petItem)
         {
            return _petItem.isAvailable;
         }
         if(_currDef)
         {
            return Utility.isAvailable(_currDef.availabilityStartTime,_currDef.availabilityEndTime);
         }
         return false;
      }
      
      public function get isInDenShop() : Boolean
      {
         if(_petItem)
         {
            return _petItem.isInDenShop;
         }
         return _denStoreInvId > 0;
      }
      
      public function get denStoreInvId() : int
      {
         if(_petItem)
         {
            return _petItem.denStoreInvId;
         }
         return _denStoreInvId;
      }
      
      public function set denStoreInvId(param1:int) : void
      {
         if(_petItem)
         {
            _petItem.denStoreInvId = param1;
         }
         else
         {
            _denStoreInvId = param1;
         }
      }
      
      public function get itemType() : int
      {
         return 0;
      }
      
      public function get ecoScore() : int
      {
         if(_currDef)
         {
            return _currDef.ecoPower;
         }
         return 0;
      }
      
      public function get ecoConsumerStateId() : int
      {
         return _ecoConsumerStateId;
      }
      
      public function set ecoConsumerStateId(param1:int) : void
      {
         _ecoConsumerStateId = param1;
      }
   }
}

