package buddy
{
   import localization.LocalizationManager;
   
   public class Buddy
   {
      private var _userName:String;
      
      private var _uuid:String;
      
      private var _onlineStatus:int;
      
      private var _userNameModerationFlag:int;
      
      private var _accountType:int;
      
      private var _timeLeftHostingCustomParty:int;
      
      public function Buddy()
      {
         super();
      }
      
      public function init(param1:String, param2:String, param3:int, param4:int, param5:int, param6:int = -1) : void
      {
         _userName = param1;
         _uuid = param2;
         _onlineStatus = param4;
         _userNameModerationFlag = param3;
         _accountType = param5;
         _timeLeftHostingCustomParty = param6;
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function get uuid() : String
      {
         return _uuid;
      }
      
      public function get userNameModerated() : String
      {
         if(_userNameModerationFlag > 0)
         {
            return _userName;
         }
         return LocalizationManager.translateIdOnly(11098);
      }
      
      public function get onlineStatus() : int
      {
         return _onlineStatus;
      }
      
      public function get isOnline() : Boolean
      {
         return _onlineStatus == 1;
      }
      
      public function get accountType() : int
      {
         return _accountType;
      }
      
      public function get userNameModeratedFlag() : int
      {
         return _userNameModerationFlag;
      }
      
      public function get timeLeftHostingCustomParty() : int
      {
         return _timeLeftHostingCustomParty;
      }
      
      public function set userName(param1:String) : void
      {
         _userName = param1;
      }
      
      public function set uuid(param1:String) : void
      {
         _uuid = param1;
      }
      
      public function set userNameModeratedFlag(param1:int) : void
      {
         _userNameModerationFlag = param1;
      }
      
      public function set onlineStatus(param1:int) : void
      {
         _onlineStatus = param1;
      }
      
      public function set timeLeftHostingCustomParty(param1:int) : void
      {
         _timeLeftHostingCustomParty = param1;
      }
   }
}

