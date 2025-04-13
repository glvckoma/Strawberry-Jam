package avatar
{
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class AvatarInfo
   {
      public var perUserAvId:int;
      
      public var avInvId:int;
      
      public var uuid:String;
      
      public var type:int;
      
      public var colors:Array;
      
      public var currEnviroType:int;
      
      public var landPetInvId:int;
      
      public var oceanPetInvId:int;
      
      public var questXp:int;
      
      public var questLevel:int;
      
      public var questXPPercentage:int;
      
      public var questHealthPercentage:int;
      
      public var questTorchStatus:Boolean;
      
      public var isDead:Boolean;
      
      public var healthBase:int;
      
      public var attackBase:int;
      
      public var attackMax:int;
      
      public var defenseBase:int;
      
      public var defenseMax:int;
      
      public var customAvId:int;
      
      private var _userName:String;
      
      private var _currPet:Object;
      
      private var _avName:String;
      
      public function AvatarInfo()
      {
         super();
      }
      
      public function init(param1:int = -1, param2:int = -1, param3:String = "", param4:String = "", param5:String = "", param6:int = -1, param7:Array = null, param8:int = 0, param9:Object = null, param10:int = -1, param11:int = 0, param12:int = 0, param13:int = 0, param14:int = 0, param15:int = 0, param16:int = 0, param17:int = 0, param18:int = 0, param19:int = 0, param20:int = 0, param21:int = 100, param22:Boolean = false) : void
      {
         isDead = false;
         perUserAvId = param1;
         avInvId = param2;
         _avName = param3;
         _userName = param4;
         uuid = param5;
         type = param6;
         colors = param7 == null ? [286331153,286331153,286331153] : param7;
         currEnviroType = param8;
         landPetInvId = param11;
         oceanPetInvId = param12;
         questXp = param13;
         questLevel = param14;
         questXPPercentage = param15;
         questHealthPercentage = param21;
         questTorchStatus = param22;
         attackBase = param17;
         attackMax = param18;
         defenseBase = param20;
         defenseMax = param19;
         healthBase = param16;
         _currPet = param9;
         customAvId = param10;
      }
      
      public function get currPet() : Object
      {
         if(_userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            return PetManager.myActivePet;
         }
         return _currPet;
      }
      
      public function set currPet(param1:Object) : void
      {
         if(_userName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _currPet = param1;
         }
      }
      
      public function getItems(param1:Boolean = false) : AccItemCollection
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            return _loc2_.getPartialItemList(type,param1);
         }
         return null;
      }
      
      public function getFullItems(param1:Boolean = false) : AccItemCollection
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            return _loc2_.getFullItemList(param1);
         }
         return null;
      }
      
      public function set fullItemList(param1:AccItemCollection) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            _loc2_.fullItemList = param1;
         }
      }
      
      public function get denItems() : DenItemCollection
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.denItemsFull;
         }
         return null;
      }
      
      public function get achievements() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.achievements;
         }
         return null;
      }
      
      public function set denItems(param1:DenItemCollection) : void
      {
         var _loc2_:UserInfo = null;
         if(param1)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_userName);
            if(_loc2_)
            {
               _loc2_.denItemsFull = param1;
            }
         }
      }
      
      public function get accountType() : int
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.accountType;
         }
         return 1;
      }
      
      public function get isMember() : Boolean
      {
         return Utility.isMember(accountType);
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(_avName);
      }
      
      public function set avName(param1:String) : void
      {
         _avName = param1;
      }
      
      public function get unlocalizedAvName() : String
      {
         return _avName;
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function set userName(param1:String) : void
      {
         _userName = param1;
      }
   }
}

