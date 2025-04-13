package Enums
{
   import localization.LocalizationManager;
   
   public class DenItemDef
   {
      public static var PROMO_TYPE_NONE:int = 0;
      
      public static var PROMO_TYPE_MCD:int = 1;
      
      private var _abbrName:String;
      
      private var _combinedCurrencyString:String;
      
      private var _cost:int;
      
      private var _currencyType:int;
      
      private var _enviroType:int;
      
      private var _flag:int;
      
      private var _gameDefId:int;
      
      private var _id:int;
      
      private var _itemStatus:int;
      
      private var _layer:int;
      
      private var _mannequinAvatarDefId:int;
      
      private var _mannequinCatId:int;
      
      private var _mannequinFrame:int;
      
      private var _membersOnly:int;
      
      private var _name:String;
      
      private var _nameStrId:int;
      
      private var _listId:int;
      
      private var _promoType:int;
      
      private var _recycleValue:int;
      
      private var _scalePercent:int;
      
      private var _sortCat:int;
      
      private var _specialType:int;
      
      private var _typeCat:int;
      
      private var _isMasterpiece:Boolean;
      
      private var _availabilityStartTime:uint;
      
      private var _availabilityEndTime:uint;
      
      private var _ecoPower:int;
      
      public function DenItemDef(param1:String, param2:String, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int, param11:int, param12:int, param13:int, param14:int, param15:int, param16:int, param17:int, param18:int, param19:int, param20:int, param21:int, param22:int, param23:uint, param24:uint, param25:int)
      {
         super();
         _abbrName = param1;
         _combinedCurrencyString = param2;
         _cost = param3;
         _currencyType = param4;
         _enviroType = param5;
         _flag = param6;
         _gameDefId = param7;
         _id = param8;
         _itemStatus = param9;
         _layer = param10;
         _mannequinAvatarDefId = param11;
         _mannequinCatId = param12;
         _mannequinFrame = param13;
         _membersOnly = param14;
         _name = LocalizationManager.translateIdOnly(param15);
         _nameStrId = param15;
         _listId = param16;
         _promoType = param17;
         _recycleValue = param18;
         _scalePercent = param19;
         _sortCat = param20;
         _specialType = param21;
         _typeCat = param22;
         _isMasterpiece = _id == 2725;
         _availabilityStartTime = param23;
         _availabilityEndTime = param24;
         _ecoPower = param25;
      }
      
      public function get abbrName() : String
      {
         return _abbrName;
      }
      
      public function get combinedCurrencyString() : String
      {
         return _combinedCurrencyString;
      }
      
      public function get cost() : int
      {
         return _cost;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function get enviroType() : int
      {
         return _enviroType;
      }
      
      public function get flag() : int
      {
         return _flag;
      }
      
      public function get gameDefId() : int
      {
         return _gameDefId;
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
      }
      
      public function get layer() : int
      {
         return _layer;
      }
      
      public function get mannequinAvatarDefId() : int
      {
         return _mannequinAvatarDefId;
      }
      
      public function get mannequinCatId() : int
      {
         return _mannequinCatId;
      }
      
      public function get mannequinFrame() : int
      {
         return _mannequinFrame;
      }
      
      public function get isMembersOnly() : Boolean
      {
         return _membersOnly == 1;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function set name(param1:String) : void
      {
         _name = param1;
      }
      
      public function get nameStrId() : int
      {
         return _nameStrId;
      }
      
      public function get listId() : int
      {
         return _listId;
      }
      
      public function get promoType() : int
      {
         return _promoType;
      }
      
      public function get recycleValue() : int
      {
         return _recycleValue;
      }
      
      public function get scalePercent() : int
      {
         return _scalePercent;
      }
      
      public function get sortCat() : int
      {
         return _sortCat;
      }
      
      public function get specialType() : int
      {
         return _specialType;
      }
      
      public function get typeCat() : int
      {
         return _typeCat;
      }
      
      public function get isMasterpiece() : Boolean
      {
         return _isMasterpiece;
      }
      
      public function get availabilityStartTime() : uint
      {
         return _availabilityStartTime;
      }
      
      public function get availabilityEndTime() : uint
      {
         return _availabilityEndTime;
      }
      
      public function get ecoPower() : int
      {
         return _ecoPower;
      }
   }
}

