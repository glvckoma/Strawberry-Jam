package pet
{
   public class PetDef
   {
      private var _defId:int;
      
      private var _mediaRefId:int;
      
      private var _type:int;
      
      private var _isGround:Boolean;
      
      private var _title:String;
      
      private var _titleStrId:int;
      
      private var _isMember:Boolean;
      
      private var _cost:int;
      
      private var _status:int;
      
      private var _diamondDefId:int;
      
      private var _favoriteToyListId:int;
      
      private var _favoriteFoodListId:int;
      
      private var _isReward:Boolean;
      
      private var _isInDiamondStore:Boolean;
      
      private var _isEgg:Boolean;
      
      private var _availabilityEndTime:uint;
      
      private var _availabilityStartTime:uint;
      
      public function PetDef(param1:int, param2:int, param3:int, param4:Boolean, param5:String, param6:int, param7:Boolean, param8:int, param9:int, param10:int, param11:int, param12:int, param13:Boolean, param14:Boolean, param15:Boolean, param16:uint, param17:uint)
      {
         super();
         _defId = param1;
         _mediaRefId = param2;
         _type = param3;
         _isGround = param4;
         _title = param5;
         _titleStrId = param6;
         _isMember = param7;
         _cost = param8;
         _status = param9;
         _diamondDefId = param10;
         _favoriteToyListId = param11;
         _favoriteFoodListId = param12;
         _isReward = param13;
         _isInDiamondStore = param14;
         _isEgg = param15;
         _availabilityStartTime = param16;
         _availabilityEndTime = param17;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get mediaRefId() : int
      {
         return _mediaRefId;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get isGround() : Boolean
      {
         return _isGround;
      }
      
      public function get title() : String
      {
         return _title;
      }
      
      public function set title(param1:String) : void
      {
         _title = param1;
      }
      
      public function get titleStrId() : int
      {
         return _titleStrId;
      }
      
      public function get isMember() : Boolean
      {
         return _isMember;
      }
      
      public function get cost() : int
      {
         return _cost;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function get isDiamond() : Boolean
      {
         return _diamondDefId > 0;
      }
      
      public function get diamondDefId() : int
      {
         return _diamondDefId;
      }
      
      public function set diamondDefId(param1:int) : void
      {
         _diamondDefId = param1;
      }
      
      public function get favoriteToyListId() : int
      {
         return _favoriteToyListId;
      }
      
      public function get favoriteFoodListId() : int
      {
         return _favoriteFoodListId;
      }
      
      public function get isReward() : Boolean
      {
         return _isReward;
      }
      
      public function get isInDiamondStore() : Boolean
      {
         return _isInDiamondStore;
      }
      
      public function set isInDiamondStore(param1:Boolean) : void
      {
         _isInDiamondStore = param1;
      }
      
      public function get isEgg() : Boolean
      {
         return _isEgg;
      }
      
      public function get availabilityEndTime() : uint
      {
         return _availabilityEndTime;
      }
      
      public function get availabilityStartTime() : uint
      {
         return _availabilityStartTime;
      }
   }
}

