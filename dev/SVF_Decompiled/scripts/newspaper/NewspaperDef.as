package newspaper
{
   public class NewspaperDef
   {
      private var _defId:int;
      
      private var _name:String;
      
      private var _paperMediaId:int;
      
      private var _iconMediaId:int;
      
      private var _giftType:int;
      
      private var _giftRefId:int;
      
      private var _giftAmount:int;
      
      private var _country:String;
      
      private var _availabilityEndTime:uint;
      
      private var _availabilityStartTime:uint;
      
      private var _status:int;
      
      private var _usability:int;
      
      public function NewspaperDef(param1:int, param2:String, param3:int, param4:int, param5:int, param6:int, param7:int, param8:String, param9:uint, param10:uint, param11:int)
      {
         super();
         _defId = param1;
         _name = param2;
         _paperMediaId = param3;
         _iconMediaId = param4;
         _giftType = param5;
         _giftRefId = param6;
         _giftAmount = param7;
         _country = param8;
         _availabilityEndTime = param10;
         _availabilityStartTime = param9;
         _usability = param11;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get paperMediaId() : int
      {
         return _paperMediaId;
      }
      
      public function get iconMediaId() : int
      {
         return _iconMediaId;
      }
      
      public function get giftType() : int
      {
         return _giftType;
      }
      
      public function get giftRefId() : int
      {
         return _giftRefId;
      }
      
      public function get giftAmount() : int
      {
         return _giftAmount;
      }
      
      public function get availabilityEndTime() : uint
      {
         return _availabilityEndTime;
      }
      
      public function set availabilityEndTime(param1:uint) : void
      {
         _availabilityEndTime = param1;
      }
      
      public function set availabilityStartTime(param1:uint) : void
      {
         _availabilityStartTime = param1;
      }
      
      public function get availabilityStartTime() : uint
      {
         return _availabilityStartTime;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function set status(param1:int) : void
      {
         _status = param1;
      }
      
      public function get country() : String
      {
         return _country;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get isAvailable() : Boolean
      {
         return Utility.isAvailable(_availabilityStartTime,_availabilityEndTime);
      }
      
      public function getIsViewable(param1:Boolean) : Boolean
      {
         if(_usability == 0)
         {
            return true;
         }
         if(_usability == 1 && param1)
         {
            return true;
         }
         if(_usability == 2 && !param1)
         {
            return true;
         }
         return false;
      }
   }
}

