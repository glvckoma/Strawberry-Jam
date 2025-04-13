package playerWall
{
   public class PostMessage
   {
      private var _message:String;
      
      private var _senderUserName:String;
      
      private var _patternId:int;
      
      private var _colorId:int;
      
      private var _msgId:String;
      
      private var _postTime:Number;
      
      private var _isBuddy:Boolean;
      
      private var _senderModeratedUserName:String;
      
      private var _avtDefId:int;
      
      private var _avtColors:Array;
      
      private var _avtEyeDefId:int;
      
      private var _avtPatternDefId:int;
      
      private var _senderDbId:int;
      
      private var _localizationId:int;
      
      private var _avtCustomId:int;
      
      private var _parentMessageId:String;
      
      private var _senderUUID:String;
      
      private var _isRead:Boolean;
      
      public function PostMessage(param1:String, param2:String, param3:int, param4:String, param5:String, param6:int, param7:int, param8:Number, param9:Boolean, param10:int, param11:Array, param12:int, param13:int, param14:int, param15:int, param16:String, param17:String, param18:Boolean)
      {
         super();
         _msgId = param1;
         _message = param2;
         _senderDbId = param3;
         _senderUserName = param4;
         _patternId = param6;
         _colorId = param7;
         _postTime = param8;
         _isBuddy = param9;
         _senderModeratedUserName = param5;
         _avtDefId = param10;
         _avtColors = param11;
         _avtEyeDefId = param12;
         _avtPatternDefId = param13;
         _avtCustomId = param15;
         _localizationId = param14;
         _parentMessageId = param16;
         _senderUUID = param17;
         _isRead = param18;
      }
      
      public function get msgId() : String
      {
         return _msgId;
      }
      
      public function get message() : String
      {
         return _message;
      }
      
      public function get senderDbId() : int
      {
         return _senderDbId;
      }
      
      public function get senderUserName() : String
      {
         return _senderUserName;
      }
      
      public function get senderModeratedUserName() : String
      {
         return _senderModeratedUserName;
      }
      
      public function get patternId() : int
      {
         return _patternId;
      }
      
      public function get colorId() : int
      {
         return _colorId;
      }
      
      public function get postTime() : Number
      {
         return _postTime;
      }
      
      public function get isBuddy() : Boolean
      {
         return _isBuddy;
      }
      
      public function get avtDefId() : int
      {
         return _avtDefId;
      }
      
      public function get avtColors() : Array
      {
         return _avtColors;
      }
      
      public function get avtEyeDefId() : int
      {
         return _avtEyeDefId;
      }
      
      public function get avtPatternDefId() : int
      {
         return _avtPatternDefId;
      }
      
      public function get localizationId() : int
      {
         return _localizationId;
      }
      
      public function get avtCustomId() : int
      {
         return _avtCustomId;
      }
      
      public function get parentMessageId() : String
      {
         return _parentMessageId;
      }
      
      public function get senderUUID() : String
      {
         return _senderUUID;
      }
      
      public function get isRead() : Boolean
      {
         return _isRead;
      }
      
      public function set msgId(param1:String) : void
      {
         _msgId = param1;
      }
      
      public function set message(param1:String) : void
      {
         _message = param1;
      }
      
      public function set senderDbId(param1:int) : void
      {
         _senderDbId = param1;
      }
      
      public function set senderUserName(param1:String) : void
      {
         _senderUserName = param1;
      }
      
      public function set senderModeratedUserName(param1:String) : void
      {
         _senderModeratedUserName = param1;
      }
      
      public function set patternId(param1:int) : void
      {
         _patternId = param1;
      }
      
      public function set colorId(param1:int) : void
      {
         _colorId = param1;
      }
      
      public function set postTime(param1:Number) : void
      {
         _postTime = param1;
      }
      
      public function set isBuddy(param1:Boolean) : void
      {
         _isBuddy = param1;
      }
      
      public function set avtDefId(param1:int) : void
      {
         _avtDefId = param1;
      }
      
      public function set avtColors(param1:Array) : void
      {
         _avtColors = param1;
      }
      
      public function set avtEyeDefId(param1:int) : void
      {
         _avtEyeDefId = param1;
      }
      
      public function set avtPatternDefId(param1:int) : void
      {
         _avtPatternDefId = param1;
      }
      
      public function set localizationId(param1:int) : void
      {
         _localizationId = param1;
      }
      
      public function set avtCustomId(param1:int) : void
      {
         _avtCustomId = param1;
      }
      
      public function set isRead(param1:Boolean) : void
      {
         _isRead = param1;
      }
   }
}

