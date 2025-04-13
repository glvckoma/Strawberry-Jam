package avatar
{
   import collection.AvatarDefCollection;
   import collection.CustomAvatarDefCollection;
   import collection.DenItemCollection;
   import collection.TradeItemCollection;
   import com.sbi.bit.BitUtility;
   import com.sbi.debug.DebugUtility;
   import flash.utils.Dictionary;
   import localization.LocalizationManager;
   
   public class UserInfoCache
   {
      public var myBuddyCount:int;
      
      public var isMember:Boolean;
      
      public var isModerator:Boolean;
      
      public var isGuide:Boolean;
      
      public var isSilenced:Boolean;
      
      public var denPrivacySettings:int;
      
      public var sgChatType:int;
      
      public var sgChatTypeNonDegraded:int;
      
      public var firstFiveMinutes:int;
      
      public var needFastPass:Boolean;
      
      public var pendingFlags:Number;
      
      public var activeDenRoomInvId:int;
      
      public var numLogins:int;
      
      public var createdAt:Number;
      
      public var playerWallSettings:int;
      
      public var webPlayerWallSettings:int;
      
      public var eCardPrivacySettings:int;
      
      public var worldMapRoomName:String;
      
      public var avtDefsCached:Boolean;
      
      private var _myUUID:String;
      
      private var _myUserName:String;
      
      private var _userInfo:Object;
      
      private var _perUserAvIdToUserName:Dictionary;
      
      private var _myPerUserAvId:int;
      
      private var _myUserVarCache:UserVarCache;
      
      private var _avatarDefs:AvatarDefCollection;
      
      private var _customAvatarDefs:CustomAvatarDefCollection;
      
      private var _customAvatarDefsByRef:Vector.<Vector.<CustomAvatarDef>>;
      
      private var _denRoomDefs:Object;
      
      private var _genericListDefsInfo:Object;
      
      private var _myTradeList:TradeItemCollection;
      
      private var _landPetsInDen:DenItemCollection;
      
      private var _oceanPetsInDen:DenItemCollection;
      
      public function UserInfoCache()
      {
         super();
      }
      
      public function init() : void
      {
         _userInfo = {};
         _myPerUserAvId = -1;
         _myUserName = "";
         avtDefsCached = false;
         _myUserVarCache = new UserVarCache();
         _myUserVarCache.init();
         _perUserAvIdToUserName = new Dictionary(true);
         _avatarDefs = new AvatarDefCollection();
         _customAvatarDefs = new CustomAvatarDefCollection();
         _customAvatarDefsByRef = new Vector.<Vector.<CustomAvatarDef>>();
         _genericListDefsInfo = {};
         _myTradeList = new TradeItemCollection();
      }
      
      public function destroy() : void
      {
         _userInfo = null;
         _avatarDefs = null;
         _customAvatarDefs = null;
         _customAvatarDefsByRef = null;
         _denRoomDefs = null;
         _genericListDefsInfo = null;
         _myTradeList = null;
      }
      
      public function getUserInfoByUserName(param1:String) : UserInfo
      {
         return _userInfo[param1];
      }
      
      public function setUserInfoByUserName(param1:String, param2:UserInfo) : void
      {
         var _loc4_:UserInfo = null;
         var _loc3_:* = null;
         if(param1 && param1 != "")
         {
            _loc4_ = _userInfo[param1] = param2;
            for each(_loc3_ in _loc4_.avList)
            {
               _perUserAvIdToUserName[_loc3_.perUserAvId] = param1;
            }
         }
      }
      
      public function getAvatarInfoByUsernamePerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         if(param1 != null)
         {
            for each(var _loc4_ in _userInfo)
            {
               for each(var _loc3_ in _loc4_.avList)
               {
                  if(_loc3_.userName.toLowerCase() == param1.toLowerCase() && _loc3_.perUserAvId == param2)
                  {
                     return _loc3_;
                  }
               }
            }
         }
         return null;
      }
      
      public function updateAllAvatarInfoQuestXPIfZeroByUserName(param1:String, param2:int, param3:int) : void
      {
         if(param1 != null)
         {
            for each(var _loc5_ in _userInfo)
            {
               for each(var _loc4_ in _loc5_.avList)
               {
                  if(_loc4_.questLevel == 0)
                  {
                     _loc4_.questXp = param2;
                     _loc4_.questLevel = param3;
                  }
               }
            }
         }
      }
      
      public function changeUserName(param1:String, param2:String, param3:int) : void
      {
         var _loc5_:UserInfo = null;
         if(_userInfo.hasOwnProperty(param1))
         {
            _loc5_ = _userInfo[param1];
            _userInfo[param2] = _loc5_;
            _userInfo[param2].userName = param2;
            _userInfo[param2].userNameModeratedFlag = param3;
            for each(var _loc4_ in _loc5_.avList)
            {
               _loc4_.userName = param2;
               _perUserAvIdToUserName[_loc4_.perUserAvId] = param2;
            }
            delete _userInfo[param1];
         }
      }
      
      public function getAvatarInfoByUserName(param1:String) : AvatarInfo
      {
         if(_userInfo.hasOwnProperty(param1))
         {
            return _userInfo[param1].avList[_userInfo[param1].currPerUserAvId];
         }
         return null;
      }
      
      public function getAvatarInfoByUserNameThenPerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         if(_userInfo.hasOwnProperty(param1))
         {
            return _userInfo[param1].avList[param2];
         }
         return null;
      }
      
      public function get myPerUserAvId() : int
      {
         return _myPerUserAvId;
      }
      
      public function setCurrAvDbId(param1:String, param2:int) : void
      {
         if(_userInfo.hasOwnProperty(param1))
         {
            _userInfo[param1].currPerUserAvId = param2;
         }
      }
      
      public function set myPerUserAvId(param1:int) : void
      {
         _myPerUserAvId = param1;
         if(_userInfo.hasOwnProperty(myUserName) && _userInfo[myUserName])
         {
            UserInfo(_userInfo[myUserName]).currPerUserAvId = param1;
         }
      }
      
      public function setAvatarInfoByUsernamePerUserAvId(param1:int, param2:AvatarInfo, param3:Boolean = false) : void
      {
         var _loc4_:String = param2.userName;
         if(!_userInfo.hasOwnProperty(_loc4_))
         {
            throw new Error("Invalid setAvatarInfo! Needs userName!");
         }
         _userInfo[_loc4_].avList[param1] = param2;
         if(param3)
         {
            _userInfo[_loc4_].currPerUserAvId = param1;
            _perUserAvIdToUserName[param1] = _loc4_;
         }
      }
      
      public function setAccountTypeByUserName(param1:String, param2:int) : void
      {
         param1 = param1.toLowerCase();
         if(_userInfo.hasOwnProperty(param1))
         {
            _userInfo[param1].accountType = param2;
         }
      }
      
      public function set playerAvatarInfo(param1:AvatarInfo) : void
      {
         _myPerUserAvId = param1.perUserAvId;
         myUserName = param1.userName;
         var _loc2_:UserInfo = UserInfo(_userInfo[myUserName]);
         if(_loc2_)
         {
            _loc2_.avList[_myPerUserAvId] = param1;
            _loc2_.currPerUserAvId = _myPerUserAvId;
         }
      }
      
      public function get playerAvatarInfo() : AvatarInfo
      {
         try
         {
            return _userInfo[myUserName].avList[_myPerUserAvId];
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error trying to get playerAvatarInfo! msg:" + e.message);
         }
         return null;
      }
      
      public function clearPlayerAvatarInfoType() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         if(_userInfo && _userInfo[myUserName])
         {
            _loc1_ = _userInfo[myUserName].avList;
            if(_loc1_ != null)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc1_.length)
               {
                  if(_loc1_[_loc2_])
                  {
                     _loc1_[_loc2_].type = -1;
                     _loc1_[_loc2_].uuid = "";
                  }
                  _loc2_++;
               }
            }
         }
      }
      
      public function get myUserName() : String
      {
         return _myUserName;
      }
      
      public function set myUserName(param1:String) : void
      {
         _myUserName = param1;
      }
      
      public function get playerUserInfo() : UserInfo
      {
         return getUserInfoByUserName(myUserName);
      }
      
      public function set playerUserInfo(param1:UserInfo) : void
      {
         setUserInfoByUserName(myUserName,param1);
      }
      
      public function get userVarCache() : UserVarCache
      {
         return _myUserVarCache;
      }
      
      public function get userNameModerated() : String
      {
         if(gMainFrame.clientInfo.userNameModerated > 0)
         {
            return _myUserName;
         }
         return LocalizationManager.translateIdOnly(11098);
      }
      
      public function setAvatarDefs(param1:AvatarDefCollection) : void
      {
         _avatarDefs = param1;
         avtDefsCached = true;
      }
      
      public function getAvatarDefsCount() : int
      {
         return _avatarDefs.length;
      }
      
      public function setCustomAvatarDefs(param1:CustomAvatarDefCollection, param2:Vector.<Vector.<CustomAvatarDef>>) : void
      {
         _customAvatarDefs = param1;
         _customAvatarDefsByRef = param2;
      }
      
      public function getAvatarColorLayer1InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).colorLayer1;
         }
         return 0;
      }
      
      public function getAvatarColorLayer2InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).colorLayer2;
         }
         return 0;
      }
      
      public function getAvatarColorLayer3InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).colorLayer3;
         }
         return 0;
      }
      
      public function getAvatarDefEyesInfoByAvType(param1:int) : uint
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).defEyes;
         }
         return 0;
      }
      
      public function getAvatarMemberInfoByAvType(param1:int) : Boolean
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).isMemOnly;
         }
         return false;
      }
      
      public function getAvatarEnviroTypeFlagByAvType(param1:int) : int
      {
         if(_avatarDefs.getAvatrDefItem(param1))
         {
            return _avatarDefs.getAvatrDefItem(param1).enviroTypeFlag;
         }
         return 0;
      }
      
      public function getCustomAvatarDefByAvType(param1:int) : CustomAvatarDef
      {
         return _customAvatarDefs.getCustomAvatarDefItem(param1);
      }
      
      public function getCustomAvatarDefsByAvRefId(param1:int) : Vector.<CustomAvatarDef>
      {
         return _customAvatarDefsByRef[param1];
      }
      
      public function getAvatarDefByAvType(param1:int, param2:Boolean) : AvatarDef
      {
         if(param2)
         {
            return _customAvatarDefs.getCustomAvatarDefItem(param1);
         }
         return _avatarDefs.getAvatrDefItem(param1);
      }
      
      public function getAvatarDefByAvatar(param1:Avatar) : AvatarDef
      {
         if(param1)
         {
            if(param1.customAvId != -1)
            {
               return _customAvatarDefs.getCustomAvatarDefItem(param1.customAvId);
            }
            return _avatarDefs.getAvatrDefItem(param1.avTypeId);
         }
         return null;
      }
      
      public function set denRoomDefs(param1:Object) : void
      {
         _denRoomDefs = param1;
      }
      
      public function get denRoomDefs() : Object
      {
         return _denRoomDefs;
      }
      
      public function getDenRoomDefByDefId(param1:int) : Object
      {
         return _denRoomDefs[param1];
      }
      
      public function set genericListDefs(param1:Object) : void
      {
         _genericListDefsInfo = param1;
      }
      
      public function getGenericListDefByDefId(param1:int) : Object
      {
         return _genericListDefsInfo[param1];
      }
      
      public function getMyTradeList() : TradeItemCollection
      {
         return _myTradeList;
      }
      
      public function set myTradeList(param1:TradeItemCollection) : void
      {
         _myTradeList = param1;
      }
      
      public function removeFromMyTradeList(param1:int) : void
      {
         _myTradeList.getCoreArray().splice(param1,1);
      }
      
      public function setMyPetsInDenByEnviroType(param1:DenItemCollection, param2:int) : void
      {
         if(param2 == 0 || param2 == 2)
         {
            _landPetsInDen = param1;
         }
         else
         {
            _oceanPetsInDen = param1;
         }
      }
      
      public function getMyPetsInDenByEnviroType(param1:int) : DenItemCollection
      {
         if(param1 == 0 || param1 == 2)
         {
            return _landPetsInDen;
         }
         return _oceanPetsInDen;
      }
      
      public function updatePetsDenShopUse(param1:int, param2:int, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         if(_landPetsInDen)
         {
            _loc4_ = 0;
            while(_loc4_ < _landPetsInDen.length)
            {
               if(_landPetsInDen.getDenItem(_loc4_).petItem.invIdx == param1)
               {
                  if(param3)
                  {
                     _landPetsInDen.getCoreArray().splice(_loc4_,1);
                     _loc4_--;
                  }
                  else
                  {
                     _landPetsInDen.getDenItem(_loc4_).petItem.denStoreInvId = param2;
                  }
               }
               _loc4_++;
            }
         }
         if(_oceanPetsInDen)
         {
            _loc4_ = 0;
            while(_loc4_ < _oceanPetsInDen.length)
            {
               if(_oceanPetsInDen.getDenItem(_loc4_).petItem.invIdx == param1)
               {
                  if(param3)
                  {
                     _oceanPetsInDen.getCoreArray().splice(_loc4_,1);
                     _loc4_--;
                  }
                  else
                  {
                     _oceanPetsInDen.getDenItem(_loc4_).petItem.denStoreInvId = param2;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      public function isPendingFlagSet(param1:int) : Boolean
      {
         return BitUtility.bitwiseAnd(pendingFlags,BitUtility.leftShiftNumbers(param1)) != 0;
      }
      
      public function get myUUID() : String
      {
         return _myUUID;
      }
      
      public function set myUUID(param1:String) : void
      {
         _myUUID = param1;
      }
   }
}

