package den
{
   import avatar.MannequinData;
   import loader.DenItemHelper;
   import localization.LocalizationManager;
   import pet.PetItem;
   
   public class DenStateItem
   {
      private var _defId:int;
      
      private var _invIdx:int;
      
      private var _packedId:int;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _version:int;
      
      private var _version2:int;
      
      private var _version3:int;
      
      private var _flipped:int;
      
      private var _catId:int;
      
      private var _refId:int;
      
      private var _sortCatId:int;
      
      private var _minigameDefId:int;
      
      private var _layerId:int;
      
      private var _enviroType:int;
      
      private var _strmName:String;
      
      private var _nameStrId:int;
      
      private var _userNameLink:String;
      
      private var _specialType:int;
      
      private var _listLauncherId:int;
      
      private var _uniqueImageId:String;
      
      private var _uniqueImageCreator:String;
      
      private var _uniqueImageCreatorDbId:int;
      
      private var _uniqueImageCreatorUUID:String;
      
      private var _userAction:Boolean;
      
      private var _denItemHelper:DenItemHelper;
      
      private var _offsetX:int;
      
      private var _offsetY:int;
      
      private var _newPlaced:Boolean;
      
      private var _petItem:PetItem;
      
      private var _mannequinData:MannequinData;
      
      private var _ecoConsumerStateId:int;
      
      public function DenStateItem(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int, param11:int, param12:int, param13:int, param14:int, param15:int, param16:String, param17:int, param18:String, param19:int, param20:int, param21:String, param22:String, param23:int, param24:String, param25:Boolean, param26:DenItemHelper, param27:int, param28:int, param29:PetItem, param30:MannequinData, param31:int)
      {
         super();
         _defId = param1;
         _invIdx = param2;
         _packedId = param3;
         _x = param4;
         _y = param5;
         _version = param6;
         _version2 = param7;
         _version3 = param8;
         _flipped = param9;
         _catId = param10;
         _refId = param11;
         _sortCatId = param12;
         _minigameDefId = param13;
         _layerId = param14;
         _enviroType = param15;
         _strmName = param16;
         _nameStrId = param17;
         _userNameLink = param18;
         _specialType = param19;
         _listLauncherId = param20;
         _uniqueImageId = param21;
         if(param22.charAt(0) == "#")
         {
            _uniqueImageCreator = LocalizationManager.translateIdOnly(int(param22.substr(1)));
         }
         else
         {
            _uniqueImageCreator = param22;
         }
         _uniqueImageCreatorDbId = param23;
         _uniqueImageCreatorUUID = param24;
         _userAction = param25;
         _denItemHelper = param26;
         _offsetX = param27;
         _offsetY = param28;
         _petItem = param29;
         _mannequinData = param30;
         _ecoConsumerStateId = param31;
      }
      
      public function clone() : DenStateItem
      {
         return new DenStateItem(_defId,_invIdx,_packedId,_x,_y,_version,_version2,_version3,_flipped,_catId,_refId,_sortCatId,_minigameDefId,_layerId,_enviroType,_strmName,_nameStrId,_userNameLink,_specialType,_listLauncherId,_uniqueImageId,_uniqueImageCreator,_uniqueImageCreatorDbId,_uniqueImageCreatorUUID,_userAction,_denItemHelper,_offsetX,_offsetY,_petItem,!!_mannequinData ? _mannequinData.clone() : null,_ecoConsumerStateId);
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
         return _invIdx;
      }
      
      public function set invIdx(param1:int) : void
      {
         _invIdx = param1;
      }
      
      public function get packedId() : int
      {
         return _packedId;
      }
      
      public function set packedId(param1:int) : void
      {
         _packedId = param1;
      }
      
      public function get x() : int
      {
         return _x;
      }
      
      public function set x(param1:int) : void
      {
         _x = param1;
      }
      
      public function get y() : int
      {
         return _y;
      }
      
      public function set y(param1:int) : void
      {
         _y = param1;
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
      
      public function get flipped() : int
      {
         return _flipped;
      }
      
      public function set flipped(param1:int) : void
      {
         _flipped = param1;
      }
      
      public function get catId() : int
      {
         return _catId;
      }
      
      public function set catId(param1:int) : void
      {
         _catId = param1;
      }
      
      public function get refId() : int
      {
         return _refId;
      }
      
      public function set refId(param1:int) : void
      {
         _refId = param1;
      }
      
      public function get sortCatId() : int
      {
         return _sortCatId;
      }
      
      public function set sortCatId(param1:int) : void
      {
         _sortCatId = param1;
      }
      
      public function get minigameDefId() : int
      {
         return _minigameDefId;
      }
      
      public function set minigameDefId(param1:int) : void
      {
         _minigameDefId = param1;
      }
      
      public function get layerId() : int
      {
         return _layerId;
      }
      
      public function set layerId(param1:int) : void
      {
         _layerId = param1;
      }
      
      public function get enviroType() : int
      {
         return _enviroType;
      }
      
      public function set enviroType(param1:int) : void
      {
         _enviroType = param1;
      }
      
      public function get strmName() : String
      {
         return _strmName;
      }
      
      public function set strmName(param1:String) : void
      {
         _strmName = param1;
      }
      
      public function get nameStrId() : int
      {
         return _nameStrId;
      }
      
      public function set nameStrId(param1:int) : void
      {
         _nameStrId = param1;
      }
      
      public function get userNameLink() : String
      {
         return _userNameLink;
      }
      
      public function set userNameLink(param1:String) : void
      {
         _userNameLink = param1;
      }
      
      public function get specialType() : int
      {
         return _specialType;
      }
      
      public function set specialType(param1:int) : void
      {
         _specialType = param1;
      }
      
      public function get listLauncherId() : int
      {
         return _listLauncherId;
      }
      
      public function set listLauncherId(param1:int) : void
      {
         _listLauncherId = param1;
      }
      
      public function get uniqueImageId() : String
      {
         return _uniqueImageId;
      }
      
      public function set uniqueImageId(param1:String) : void
      {
         _uniqueImageId = param1;
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
      
      public function set uniqueImageCreatorDbId(param1:int) : void
      {
         _uniqueImageCreatorDbId = param1;
      }
      
      public function get uniqueImageCreatorUUID() : String
      {
         return _uniqueImageCreatorUUID;
      }
      
      public function set uniqueImageCreatorUUID(param1:String) : void
      {
         _uniqueImageCreatorUUID = param1;
      }
      
      public function get userAction() : Boolean
      {
         return _userAction;
      }
      
      public function set userAction(param1:Boolean) : void
      {
         _userAction = param1;
      }
      
      public function get denItemHelper() : DenItemHelper
      {
         return _denItemHelper;
      }
      
      public function set denItemHelper(param1:DenItemHelper) : void
      {
         _denItemHelper = param1;
      }
      
      public function get offsetX() : int
      {
         return _offsetX;
      }
      
      public function set offsetX(param1:int) : void
      {
         _offsetX = param1;
      }
      
      public function get offsetY() : int
      {
         return _offsetY;
      }
      
      public function set offsetY(param1:int) : void
      {
         _offsetY = param1;
      }
      
      public function get newPlaced() : Boolean
      {
         return _newPlaced;
      }
      
      public function set newPlaced(param1:Boolean) : void
      {
         _newPlaced = param1;
      }
      
      public function get petItem() : PetItem
      {
         return _petItem;
      }
      
      public function set petItem(param1:PetItem) : void
      {
         _petItem = param1;
      }
      
      public function get mannequinData() : MannequinData
      {
         return _mannequinData;
      }
      
      public function set mannequinData(param1:MannequinData) : void
      {
         _mannequinData = param1;
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

