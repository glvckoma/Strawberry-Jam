package avatar
{
   public class AvatarDef
   {
      private var _defId:int;
      
      private var _colorLayer1:uint;
      
      private var _colorLayer2:uint;
      
      private var _colorLayer3:uint;
      
      private var _defPattern:int;
      
      private var _defEyes:int;
      
      private var _isMemOnly:Boolean;
      
      private var _enviroTypeFlag:int;
      
      private var _cost:int;
      
      private var _titleStrRef:int;
      
      private var _availability:int;
      
      private var _attackItemRefId:int;
      
      private var _iconMediaId:int;
      
      private var _status:int;
      
      private var _mannequinColorLayer1:uint;
      
      private var _mannequinColorLayer2:uint;
      
      private var _mannequinColorLayer3:uint;
      
      private var _availabilityStartTime:uint;
      
      private var _availabilityEndTime:uint;
      
      public function AvatarDef(param1:int, param2:uint, param3:uint, param4:uint, param5:int, param6:int, param7:Boolean, param8:int, param9:int, param10:int, param11:int, param12:int, param13:int, param14:int, param15:uint, param16:uint, param17:uint, param18:uint, param19:uint)
      {
         super();
         _defId = param1;
         _colorLayer1 = param2;
         _iconMediaId = param13;
         _attackItemRefId = param12;
         _availability = param11;
         _titleStrRef = param10;
         _cost = param9;
         _enviroTypeFlag = param8;
         _isMemOnly = param7;
         _defEyes = param6;
         _defPattern = param5;
         _colorLayer3 = param4;
         _colorLayer2 = param3;
         _status = param14;
         _mannequinColorLayer1 = param15;
         _mannequinColorLayer2 = param16;
         _mannequinColorLayer3 = param17;
         _availabilityStartTime = param18;
         _availabilityEndTime = param19;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function get iconMediaId() : int
      {
         return _iconMediaId;
      }
      
      public function get attackItemRefId() : int
      {
         return _attackItemRefId;
      }
      
      public function get availability() : int
      {
         return _availability;
      }
      
      public function get titleStrRef() : int
      {
         return _titleStrRef;
      }
      
      public function get cost() : int
      {
         return _cost;
      }
      
      public function get enviroTypeFlag() : int
      {
         return _enviroTypeFlag;
      }
      
      public function get isMemOnly() : Boolean
      {
         return _isMemOnly;
      }
      
      public function get defEyes() : int
      {
         return _defEyes;
      }
      
      public function get defPattern() : int
      {
         return _defPattern;
      }
      
      public function set defPattern(param1:int) : void
      {
         _defPattern = param1;
      }
      
      public function get colorLayer3() : uint
      {
         return _colorLayer3;
      }
      
      public function get colorLayer2() : uint
      {
         return _colorLayer2;
      }
      
      public function get colorLayer1() : uint
      {
         return _colorLayer1;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get patternRefIds() : Array
      {
         throw new Error("If this is not overrided by CustomAvatarDef then it is not valid");
      }
      
      public function get mannequinColorLayer1() : uint
      {
         return _mannequinColorLayer1;
      }
      
      public function get mannequinColorLayer2() : uint
      {
         return _mannequinColorLayer2;
      }
      
      public function get mannequinColorLayer3() : uint
      {
         return _mannequinColorLayer3;
      }
      
      public function get availabilityStartTime() : uint
      {
         return _availabilityStartTime;
      }
      
      public function get availabilityEndTime() : uint
      {
         return _availabilityEndTime;
      }
   }
}

