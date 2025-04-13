package diamond
{
   public class DiamondItem
   {
      public static const TYPE_ACCESSORY:int = 0;
      
      public static const TYPE_DEN_ITEM:int = 1;
      
      public static const TYPE_PET:int = 2;
      
      public static const TYPE_AVATAR:int = 3;
      
      public static const TYPE_DEN:int = 4;
      
      public static const TYPE_AVATAR_CUSTOM:int = 5;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      private var _defId:int;
      
      private var _type:int;
      
      private var _refDefId:int;
      
      private var _status:int;
      
      private var _value:int;
      
      private var _availabilityStartTime:uint;
      
      private var _availabilityEndTime:uint;
      
      public function DiamondItem(param1:int)
      {
         super();
         var _loc2_:Object = DiamondXtCommManager.getDiamondDef(param1);
         _defId = param1;
         _type = _loc2_.type;
         _refDefId = _loc2_.refDefId;
         _status = _loc2_.status;
         _value = isOnSale ? Math.ceil(_loc2_.value * 0.5) : _loc2_.value;
         _availabilityStartTime = _loc2_.availabilityStartTime;
         _availabilityEndTime = _loc2_.availabilityEndTime;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get type() : int
      {
         return _type;
      }
      
      public function get refDefId() : int
      {
         return _refDefId;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function get value() : int
      {
         return _value;
      }
      
      public function get isAccessory() : Boolean
      {
         return _type == 0;
      }
      
      public function get isAvatar() : Boolean
      {
         return _type == 3;
      }
      
      public function get isAvatarCustom() : Boolean
      {
         return _type == 5;
      }
      
      public function get isDenItem() : Boolean
      {
         return _type == 1;
      }
      
      public function get isPet() : Boolean
      {
         return _type == 2;
      }
      
      public function get isDen() : Boolean
      {
         return _type == 4;
      }
      
      public function get isOnSale() : Boolean
      {
         return _status == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return _status == 3;
      }
      
      public function get isRare() : Boolean
      {
         return _status == 4;
      }
      
      public function get isNew() : Boolean
      {
         return _status == 1;
      }
      
      public function get isAvailable() : Boolean
      {
         return Utility.isAvailable(_availabilityStartTime,_availabilityEndTime);
      }
      
      public function get availabilityEndTime() : uint
      {
         return _availabilityEndTime;
      }
      
      public function get startTime() : uint
      {
         return _availabilityStartTime;
      }
   }
}

