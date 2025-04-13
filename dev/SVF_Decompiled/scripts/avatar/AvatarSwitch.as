package avatar
{
   import buddy.BuddyEvent;
   import buddy.BuddyManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.media.SoundTransform;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.GuiNameTypeScreen;
   import inventory.Iitem;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class AvatarSwitch
   {
      public static const ASTRANSFORM_MEDIA_ID_TOP:int = 33;
      
      public static const ASTRANSFORM_MEDIA_ID_BOTTOM:int = 34;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_TOP:int = 1171;
      
      public static const ASTRANSFORM_OCEAN_MEDIA_ID_BOTTOM:int = 1172;
      
      public static var activeAvatarIdx:int;
      
      public static var playerUserInfo:UserInfo;
      
      public static var nameTypeScreen:GuiNameTypeScreen;
      
      public static var playerUsername:String;
      
      public static var playerSfsUserId:int;
      
      public static var isSlotAvail:int;
      
      public static var isAddingSlot:Boolean;
      
      public static var availSlotFlags:uint;
      
      public static var isChoosing:Boolean;
      
      private static var _avatars:Array;
      
      private static var _switchCallback:Function;
      
      private static var _addIdx:int;
      
      private static var _switchIdx:int;
      
      private static var _addAvatarCallback:Function;
      
      private static var _addFastPassAvatarCallback:Function;
      
      private static var _addAvatar:Avatar;
      
      private static var _addAvName:String;
      
      private static var _removeCallback:Function;
      
      private static var _removeIdx:int;
      
      private static var _isChoosing:Boolean;
      
      private static var _isSwitchingDen:Boolean;
      
      private static var _asTransformVec:Vector.<MediaHelper>;
      
      private static var _secondChosenAvtIdx:int;
      
      private static var _numOpenNonMemberSlots:int;
      
      private static var _orderingOfAvatars:Array;
      
      private static var _caIdx:int;
      
      private static var _avatarName:String;
      
      private static var _avatarNameIndexes:Array;
      
      private static var _avatarDiamondDefId:int;
      
      private static var _shopId:int;
      
      private static var _itemInShopDefId:int;
      
      private static var _status:int;
      
      public function AvatarSwitch()
      {
         super();
      }
      
      public static function init() : void
      {
         _asTransformVec = new Vector.<MediaHelper>();
         _secondChosenAvtIdx = -1;
      }
      
      public static function destroy() : void
      {
         _asTransformVec = null;
      }
      
      public static function playerInfoSet() : void
      {
         playerUserInfo = gMainFrame.userInfo.playerUserInfo;
         playerUsername = !!playerUserInfo ? playerUserInfo.userName : gMainFrame.userInfo.myUserName;
         playerSfsUserId = gMainFrame.server.userId;
         if(_avatars == null)
         {
            _avatars = [];
         }
         if(playerUserInfo)
         {
            updateAvatars();
         }
      }
      
      public static function updateCurrentAvatarAfterRedemption(param1:Avatar) : void
      {
         var _loc2_:int = 0;
         if(_avatars)
         {
            _loc2_ = 0;
            while(_loc2_ < _avatars.length)
            {
               if(_avatars[_loc2_])
               {
                  if(_avatars[_loc2_].perUserAvId == gMainFrame.userInfo.myPerUserAvId)
                  {
                     _avatars[_loc2_] = param1;
                     break;
                  }
               }
               _loc2_++;
            }
         }
      }
      
      public static function updateAfterRedeemingAvatar(param1:uint) : void
      {
         myAvatarListCallback(param1);
         playerUserInfo = null;
         _avatars = [];
         playerInfoSet();
         GuiManager.showHudAvt();
      }
      
      private static function updateAvatars() : void
      {
         var _loc1_:Avatar = null;
         var _loc2_:int = 0;
         var _loc5_:Avatar = null;
         if(_avatars.length == 0)
         {
            for each(var _loc4_ in playerUserInfo.avList)
            {
               if(_loc4_.perUserAvId == playerUserInfo.currPerUserAvId)
               {
                  _loc1_ = AvatarManager.playerAvatar;
               }
               else
               {
                  _loc1_ = _avatars[_orderingOfAvatars[_loc4_.avInvId]];
                  if(!_loc1_)
                  {
                     _loc1_ = new Avatar();
                     _loc1_ = AvatarUtility.generateNew(_loc4_.perUserAvId,_loc1_,_loc4_.userName,playerSfsUserId,AvatarManager.roomEnviroType,null,true);
                  }
               }
               _avatars[_orderingOfAvatars[_loc4_.avInvId]] = _loc1_;
               _loc1_ = null;
            }
         }
         var _loc3_:int = int(_avatars.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_avatars[_loc2_] != null)
            {
               _loc5_ = _avatars[_loc2_];
               if(playerUserInfo.currPerUserAvId == _loc5_.perUserAvId)
               {
                  if(activeAvatarIdx != _loc2_)
                  {
                     _avatars.unshift(_avatars.splice(_loc2_,1)[0]);
                     activeAvatarIdx = _switchIdx = 0;
                     break;
                  }
                  activeAvatarIdx = _switchIdx = _loc2_;
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      public static function shouldChoose() : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_])
            {
               if(isMemberOnlyAvatar(_loc2_))
               {
                  _loc1_++;
               }
               else
               {
                  if(Utility.isOcean(_avatars[_loc2_].enviroTypeFlag))
                  {
                     _loc3_++;
                  }
                  _loc4_++;
               }
            }
            _loc2_++;
         }
         if(_loc4_ < 3 && _loc4_ > 0 && _loc3_ < 2 && _loc4_ != _loc3_)
         {
            return false;
         }
         return true;
      }
      
      public static function isMemberOnlyAvatar(param1:int) : Boolean
      {
         return gMainFrame.userInfo.getAvatarMemberInfoByAvType(_avatars[param1].avTypeId);
      }
      
      public static function get numTotalAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_])
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function isAvInvIdUsable(param1:int) : Boolean
      {
         if(gMainFrame.userInfo.isMember && param1 < 1000)
         {
            return true;
         }
         param1 += 1;
         if(availSlotFlags == 4294967295 || (availSlotFlags & 0xFFFF) == param1 || (availSlotFlags & 4294901760) >> 16 == param1)
         {
            return true;
         }
         return false;
      }
      
      public static function adjustAvailSlotFlags(param1:int, param2:Boolean) : void
      {
         param1 += 1;
         if(!gMainFrame.userInfo.isMember)
         {
            if((availSlotFlags & 0xFFFF) == 0)
            {
               if(param2)
               {
                  availSlotFlags |= param1;
               }
               else
               {
                  availSlotFlags |= 4294901760;
               }
            }
            else if((availSlotFlags & 4294901760) >> 16 == 0)
            {
               if(param2)
               {
                  availSlotFlags |= param1 << 16;
               }
               else
               {
                  availSlotFlags &= 65535;
               }
            }
         }
      }
      
      public static function get orderingOfAvatars() : Array
      {
         return _orderingOfAvatars;
      }
      
      public static function set orderingOfAvatars(param1:Array) : void
      {
         _orderingOfAvatars = param1;
      }
      
      public static function get avatars() : Array
      {
         return _avatars;
      }
      
      public static function getNumUsableLandAvatars(param1:Boolean, param2:Boolean) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _avatars.length)
         {
            if(_avatars[_loc4_] && Utility.isLand(_avatars[_loc4_].enviroTypeFlag))
            {
               if(param1 || param2)
               {
                  _loc3_++;
               }
               else if(isAvInvIdUsable(_avatars[_loc4_].avInvId))
               {
                  _loc3_++;
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public static function get numMemberAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_] && gMainFrame.userInfo.getAvatarMemberInfoByAvType(_avatars[_loc2_].avTypeId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numNonMemberAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(_avatars[_loc2_].avTypeId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numNonMemberOceanOnlyAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(_avatars[_loc2_].avTypeId) && (Utility.isOcean(_avatars[_loc2_].enviroTypeFlag) && !Utility.isLand(_avatars[_loc2_].enviroTypeFlag) && !Utility.isLandAndOcean(_avatars[_loc2_].enviroTypeFlag)))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function getNumNonMemberAvailableAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_] && !gMainFrame.userInfo.getAvatarMemberInfoByAvType(_avatars[_loc2_].avTypeId) && isAvInvIdUsable(_avatars[_loc2_].avInvId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function get numAvailAvatars() : int
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatars.length)
         {
            if(_avatars[_loc2_] && isAvInvIdUsable(_avatars[_loc2_].avInvId))
            {
               _loc1_++;
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public static function isSwitching() : Boolean
      {
         return activeAvatarIdx != _switchIdx;
      }
      
      public static function isSlotAvailable(param1:int) : Boolean
      {
         return isAvInvIdUsable(_avatars[param1].avInvId);
      }
      
      public static function get numOpenNonMemberSlots() : int
      {
         return _numOpenNonMemberSlots;
      }
      
      public static function set numOpenNonMemberSlots(param1:int) : void
      {
         _numOpenNonMemberSlots = param1;
      }
      
      public static function addSlot() : void
      {
         AvatarXtCommManager.requestAvatarBuy(showNewAvatarPopup);
      }
      
      public static function showNewAvatarPopup(param1:Boolean) : void
      {
         if(param1)
         {
            isAddingSlot = false;
            addNewWorldAvatar(_caIdx,_avatarName,_avatarNameIndexes,_avatarDiamondDefId);
         }
         DarkenManager.showLoadingSpiral(false);
         if(_addAvatarCallback != null)
         {
            _addAvatarCallback(param1 ? 1 : 0);
         }
      }
      
      public static function addAvatar(param1:int, param2:Boolean = false, param3:Function = null, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:int = -1, param8:Boolean = false, param9:int = -1, param10:int = -1, param11:Iitem = null) : void
      {
         _addIdx = param1;
         _addAvatarCallback = param3;
         _isChoosing = param4;
         _shopId = param9;
         _itemInShopDefId = param10;
         _isSwitchingDen = param6;
         isAddingSlot = param2;
         var _loc12_:int = AvatarUtility.numNonMemberAvatars();
         GuiManager.openAvatarCreator(param5,_loc12_ >= 1 && _loc12_ - numNonMemberOceanOnlyAvatars > 0 ? false : param4,param7,param8,param11);
      }
      
      public static function addFastPassAvatar(param1:Function) : void
      {
         _addFastPassAvatarCallback = param1;
         GuiManager.openFastPassAvatarCreator();
      }
      
      public static function set addFastPassAvatarCallback(param1:Function) : void
      {
         _addFastPassAvatarCallback = param1;
      }
      
      public static function set addAvatarCallback(param1:Function) : void
      {
         _addAvatarCallback = param1;
      }
      
      public static function addNewWorldAvatar(param1:int, param2:String, param3:Array, param4:int = -1, param5:int = -1, param6:Boolean = false) : void
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         if(isAddingSlot)
         {
            _caIdx = param1;
            _avatarName = param2;
            _avatarNameIndexes = param3;
            _avatarDiamondDefId = param4;
            addSlot();
         }
         else
         {
            _addAvatar = AvatarUtility.findCreationAvatarByType(param1,param5);
            _addAvName = param2;
            if(_addAvatar != null && param3[0] != null && param3[1] != null && param3[2] != null)
            {
               _loc8_ = int(LocalizationManager.isCurrLanguageReversed() ? param3[2] : param3[1]);
               _loc7_ = int(LocalizationManager.isCurrLanguageReversed() ? param3[1] : param3[2]);
               SBTracker.pop();
               if(QuestManager.isInPrivateAdventureState)
               {
                  QuestManager.privateAdventureJoinClose(true);
               }
               if(param6)
               {
                  AvatarXtCommManager.requestAvatarFastPassAdd([_addAvatar.avTypeId,param3[0],_loc8_,_loc7_],addFastPassAvatarResponse);
               }
               else
               {
                  AvatarXtCommManager.requestAvatarAdd([param3[0],_loc8_,_loc7_,_addAvatar.avTypeId,_addAvatar.customAvId,param4,_shopId],addAvatarResponse);
               }
            }
            else
            {
               DebugUtility.debugTrace("Failed to request add avatar with addAvatar = " + _addAvatar + " AvatarNameIndexes[0] = " + param3[0] + " AvatarNameIndexes[1] = " + param3[1] + " AvatarNameIndexes[2] = " + param3[2] + " addAvatar.avTypeId = " + (_addAvatar != null ? _addAvatar.avTypeId : null));
            }
         }
      }
      
      public static function addAvatarResponse(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:Avatar = null;
         var _loc5_:AvatarWorldView = null;
         _status = param1;
         if(_status == 1)
         {
            _loc4_ = new Avatar();
            _loc4_.init(param2,param3,_addAvName,_addAvatar.avTypeId,null,_addAvatar.customAvId,null,playerUsername,playerSfsUserId);
            _loc4_.copyColors(_addAvatar.colors);
            _loc4_.cloneShownAccFromAvatar(_addAvatar);
            _loc4_.accState.hideAllClothingArticles();
            if(_isChoosing)
            {
               _avatars.splice(_addIdx,0,_loc4_);
               AvatarXtCommManager.requestADForAvatar(_loc4_.perUserAvId,true,onChoosingAdReceive,_loc4_);
               return;
            }
            adjustAvailSlotFlags(param3,true);
            if(!Utility.isSameEnviroType(_loc4_.enviroTypeFlag,AvatarManager.roomEnviroType))
            {
               _avatars.splice(_addIdx,1);
               _avatars.unshift(_loc4_);
               _addIdx = 0;
            }
            else
            {
               _avatars.splice(_addIdx,0,_loc4_);
            }
            _loc5_ = AvatarManager.avatarViewList[playerSfsUserId];
            if(_loc5_ != null)
            {
               _loc5_.isCurrentlySwitching = false;
            }
            if(_isSwitchingDen && _addAvatarCallback != null)
            {
               _addAvatarCallback(_status);
            }
            else
            {
               switchAvatars(_addIdx);
            }
         }
         if(_status != 1)
         {
            DarkenManager.showLoadingSpiral(false);
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(_status);
               _addAvatarCallback = null;
            }
         }
      }
      
      public static function addFastPassAvatarResponse(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_addFastPassAvatarCallback != null)
         {
            _addFastPassAvatarCallback(param1);
            _addFastPassAvatarCallback = null;
         }
         if(param1)
         {
            AvatarXtCommManager.requestAvatarList([gMainFrame.userInfo.myUserName],AvatarSwitch.myAvatarListCallback);
            gMainFrame.userInfo.needFastPass = false;
            RoomManagerWorld.instance.setUpWorldJoin();
         }
      }
      
      private static function onChoosingAdReceive(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(_addAvatarCallback != null)
         {
            _addAvatarCallback(_status);
            _addAvatarCallback = null;
         }
      }
      
      public static function switchAvatars(param1:int, param2:Function = null) : void
      {
         if(param1 < 0 || param1 >= _avatars.length)
         {
            throw new Error("Invalid switchIdx:" + param1);
         }
         _switchCallback = param2;
         _switchIdx = param1;
         RoomXtCommManager.isSwitching = true;
         _isChoosing = false;
         DarkenManager.showLoadingSpiral(true);
         RoomManagerWorld.instance.forceStopMovement();
         AvatarXtCommManager.requestAvatarSwitch([_avatars[param1].perUserAvId]);
      }
      
      public static function setAvatarSwitchCallback(param1:Function) : void
      {
         _switchCallback = param1;
      }
      
      public static function avatarSwitchResponse(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc10_:AvatarWorldView = null;
         var _loc5_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:MediaHelper = null;
         var _loc9_:MediaHelper = null;
         var _loc8_:AvatarWorldView = null;
         DarkenManager.showLoadingSpiral(false);
         if(!_isChoosing)
         {
            if(_addAvatarCallback != null)
            {
               _addAvatarCallback(true);
               _addAvatarCallback = null;
            }
         }
         var _loc6_:int = 2;
         var _loc7_:Boolean = Boolean(int(param1[_loc6_++]));
         if(_loc7_)
         {
            _loc4_ = int(param1[_loc6_++]);
            _loc10_ = AvatarManager.avatarViewList[_loc4_];
            if(_loc10_ == null)
            {
               DebugUtility.debugTrace("ERROR: invalid avatar worldview savw:" + _loc10_ + " sfsUserId:" + _loc4_ + " data:" + param1);
               return;
            }
            _loc10_.setAvatarAsPhantom(false);
            _loc10_.setActivePet(0,0,0,0,"",0,0,0);
            if(_loc10_.getChildAt(0).hasOwnProperty("onbottom1"))
            {
               _loc5_ = _loc10_.numChildren - 1;
               while(_loc5_ > 0)
               {
                  _loc2_ = _loc10_.getChildAt(_loc5_);
                  if(_loc2_ is MovieClip && Boolean(MovieClip(_loc2_).hasOwnProperty("isTransformTop")))
                  {
                     endTransformAnim(MovieClip(_loc2_));
                     break;
                  }
                  _loc5_--;
               }
               endTransformAnim(_loc10_.getChildAt(0) as MovieClip);
            }
            if(_asTransformVec == null)
            {
               DebugUtility.debugTrace("ERROR: invalid AvatarSwitch state _asTransformTopMHVec: data:" + param1);
               return;
            }
            if(!_loc10_.isCurrentlySwitching)
            {
               _loc10_.isCurrentlySwitching = true;
               _loc3_ = new MediaHelper();
               _loc3_.init(_loc10_.roomType == 0 ? 33 : 1171,asTransformMediaHelper,[_loc10_,param1]);
               _asTransformVec.push(_loc3_);
               _loc9_ = new MediaHelper();
               _loc9_.init(_loc10_.roomType == 0 ? 34 : 1172,asTransformMediaHelper,[_loc10_]);
               _asTransformVec.push(_loc9_);
            }
            if(_loc4_ == playerSfsUserId)
            {
               GuiManager.setSwapBtnGray(true);
            }
         }
         else
         {
            _loc8_ = AvatarManager.avatarViewList[playerSfsUserId];
            _loc8_.isCurrentlySwitching = false;
            DebugUtility.debugTrace("switch error!!!");
            RoomXtCommManager.isSwitching = false;
            if(!QuestManager.isInPrivateAdventureState)
            {
               GuiManager.setSwapBtnGray(false);
            }
            if(_switchIdx != activeAvatarIdx)
            {
               _switchIdx = activeAvatarIdx;
            }
         }
         if(_switchCallback != null)
         {
            _switchCallback(_loc7_,true);
            if(!_loc7_)
            {
               _switchCallback = null;
            }
         }
      }
      
      public static function myAvatarListCallback(param1:uint) : void
      {
         availSlotFlags = param1;
      }
      
      public static function removeAvatar(param1:int, param2:Function) : void
      {
         if(param1 < 0 || param1 >= _avatars.length)
         {
            throw new Error("Invalid removeIdx:" + param1);
         }
         if(_avatars.length <= 1)
         {
            throw new Error("Tried to remove avatar when less than 2 were left!");
         }
         _removeCallback = param2;
         _removeIdx = param1;
         AvatarXtCommManager.requestAvatarKill([_avatars[param1].perUserAvId],avatarKillResponse);
      }
      
      public static function avatarKillResponse(param1:Boolean, param2:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Boolean = false;
         var _loc3_:UserInfo = null;
         if(param1)
         {
            _loc4_ = isSlotAvailable(_removeIdx);
            _loc5_ = int(_avatars[_removeIdx].avInvId);
            _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_avatars[_removeIdx].userName);
            _loc3_.allItemsInUseOff(_avatars[_removeIdx].avInvId);
            _loc3_.removeAvatarFromList(_avatars[_removeIdx].perUserAvId);
            _avatars.splice(_removeIdx,1);
         }
         if(_removeCallback != null)
         {
            _removeCallback(param1,_removeIdx,_loc5_,param2,_loc4_);
         }
         _removeIdx = -1;
      }
      
      public static function chooseTwo(param1:Array, param2:Function) : void
      {
         _switchIdx = _avatars[param1[0]].enviroTypeFlag == 2 ? param1[1] : param1[0];
         _secondChosenAvtIdx = -1;
         var _loc3_:Array = [];
         _loc3_[0] = _avatars[param1[0]].avInvId;
         if(param1[1] != null && AvatarSwitch._avatars[param1[1]])
         {
            _loc3_[1] = _avatars[param1[1]].avInvId;
            _secondChosenAvtIdx = param1[1];
         }
         AvatarXtCommManager.requestAvatarOrdain(_loc3_,param2);
      }
      
      private static function asTransformMediaHelper(param1:MovieClip) : void
      {
         if(!param1.hasOwnProperty("mediaHelper"))
         {
            return;
         }
         var _loc4_:MediaHelper = MediaHelper(param1.mediaHelper);
         var _loc2_:int = _loc4_.id;
         if(_loc2_ != 33 && _loc2_ != 34 && _loc2_ != 1171 && _loc2_ != 1172)
         {
            return;
         }
         param1.addEventListener("enterFrame",transformEnterFrameHandler);
         var _loc3_:AvatarView = AvatarView((param1.passback as Array)[0]);
         if(_loc2_ == 33 || _loc2_ == 1171)
         {
            param1.data = (param1.passback as Array)[1] as Array;
            DebugUtility.debugTrace("got top media for sfsUserId:" + int(param1.data[3]));
            param1.isTransformTop = true;
            _loc3_.addChild(param1);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc4_),1);
         }
         else
         {
            param1.isTransformBottom = true;
            _loc3_.addChildAt(param1,0);
            _asTransformVec.splice(_asTransformVec.indexOf(_loc4_),1);
         }
         param1.gotoAndPlay(1);
         param1.mediaHelper.destroy();
         delete param1.mediaHelper;
         delete param1.passback;
      }
      
      private static function transformEnterFrameHandler(param1:Event) : void
      {
         var _loc4_:Array = null;
         var _loc24_:int = 0;
         var _loc13_:int = 0;
         var _loc25_:* = false;
         var _loc19_:Avatar = null;
         var _loc27_:Avatar = null;
         var _loc5_:AvatarInfo = null;
         var _loc15_:AvatarInfo = null;
         var _loc2_:AvatarWorldView = null;
         var _loc9_:int = 0;
         var _loc20_:Object = null;
         var _loc12_:AvatarInfo = null;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc17_:int = 0;
         var _loc11_:String = null;
         var _loc21_:Number = NaN;
         var _loc23_:int = 0;
         var _loc10_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc18_:Object = null;
         var _loc16_:BuddyEvent = null;
         var _loc26_:AvatarWorldView = null;
         var _loc14_:AvatarWorldView = null;
         var _loc22_:MovieClip = MovieClip(param1.target);
         if(_loc22_.parent == null || AvatarView(_loc22_.parent).avatarData == null)
         {
            endTransformAnim(_loc22_);
            return;
         }
         if(_loc22_.currentFrameLabel != null)
         {
            DebugUtility.debugTrace("entered frame:" + _loc22_.currentFrameLabel + " on transform effect for sfsUserId:" + AvatarView(_loc22_.parent).userId);
         }
         if(_loc22_.currentFrameLabel == "hideAvatar")
         {
            AvatarView(_loc22_.parent).hideAvatar();
            if(_loc22_.hasOwnProperty("data"))
            {
               _loc4_ = _loc22_.data;
               _loc24_ = 3;
               _loc13_ = int(_loc4_[_loc24_++]);
               _loc25_ = _loc13_ == playerSfsUserId;
               _loc19_ = AvatarManager.getAvatarBySfsUserId(_loc13_);
               if(_loc19_)
               {
                  if(_loc25_)
                  {
                     _loc27_ = _avatars[_switchIdx];
                     _loc27_.perUserAvId = _loc19_.perUserAvId;
                     _loc27_.avTypeId = _loc19_.avTypeId;
                     _loc27_.copyColors(_loc19_.colors);
                     _loc27_.avName = _loc19_.avName;
                     _loc27_.cloneShownAccFromAvatar(_loc19_);
                     _loc27_.customAvId = _loc19_.customAvId;
                     _loc27_.avInvId = _loc19_.avInvId;
                     AvatarManager.clearPlayerSplashColor();
                     _loc5_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc19_.userName,int(_loc4_[_loc24_]));
                  }
                  _loc19_.removeAllItems();
                  _loc19_.perUserAvId = int(_loc4_[_loc24_++]);
                  _loc19_.avInvId = int(_loc4_[_loc24_++]);
                  _loc19_.customAvId = int(_loc4_[_loc24_++]);
                  _loc19_.avTypeId = int(_loc4_[_loc24_++]);
                  _loc19_.setColors(uint(_loc4_[_loc24_++]),uint(_loc4_[_loc24_++]),uint(_loc4_[_loc24_++]));
                  _loc19_.avName = _loc4_[_loc24_++];
                  if(_loc19_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && (_loc5_ == null || _loc5_.uuid == ""))
                  {
                     AvatarXtCommManager.requestADForAvatar(_loc19_.perUserAvId,true,null,_loc19_);
                  }
                  else
                  {
                     _loc15_ = new AvatarInfo();
                     _loc15_.perUserAvId = _loc19_.perUserAvId;
                     _loc15_.avName = _loc19_.avName;
                     _loc15_.userName = _loc19_.userName;
                     _loc15_.colors = _loc19_.colors.concat();
                     _loc15_.type = _loc19_.avTypeId;
                     _loc15_.customAvId = _loc19_.customAvId;
                     _loc15_.avInvId = _loc19_.avInvId;
                  }
                  _loc2_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc13_);
                  if(_loc2_)
                  {
                     if(_loc2_.parent != null)
                     {
                        _loc2_.parent.removeChild(_loc2_);
                     }
                     if(Utility.isAir(_loc19_.enviroTypeFlag))
                     {
                        _loc2_.x += AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                        _loc2_.y += AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                        AvatarManager.getFlyingLayer.addChild(_loc2_);
                     }
                     else
                     {
                        _loc2_.x -= AvatarManager.getAvatarLayer.x + AvatarManager.getAvatarLayer.parent.x - AvatarManager.getFlyingLayer.x;
                        _loc2_.y -= AvatarManager.getAvatarLayer.y + AvatarManager.getAvatarLayer.parent.y - AvatarManager.getFlyingLayer.y;
                        AvatarManager.getAvatarLayer.addChild(_loc2_);
                     }
                  }
                  if(_loc25_)
                  {
                     if(Utility.isAir(_loc27_.enviroTypeFlag) != Utility.isAir(_loc19_.enviroTypeFlag))
                     {
                        RoomManagerWorld.instance.rebuildGrid();
                        if(_loc2_ == null && !Utility.isAir(_loc19_.enviroTypeFlag) || RoomManagerWorld.instance.collisionTestGrid(_loc2_.x,_loc2_.y))
                        {
                           RoomManagerWorld.instance.teleportPlayerToDefault();
                        }
                     }
                     gMainFrame.userInfo.myPerUserAvId = _loc19_.perUserAvId;
                     GuiManager.positionHudAvatar();
                     _avatars.splice(activeAvatarIdx,1);
                     _avatars.unshift(_avatars[_switchIdx - 1]);
                     _avatars.splice(_switchIdx,1);
                     if(_secondChosenAvtIdx != -1)
                     {
                        _avatars.unshift(_avatars[_secondChosenAvtIdx - 1]);
                        _avatars.splice(_secondChosenAvtIdx,1);
                     }
                     _avatars.unshift(_loc19_);
                     activeAvatarIdx = 0;
                     _switchIdx = 0;
                     _secondChosenAvtIdx = -1;
                     _loc9_ = int(_loc4_[_loc24_++]);
                     _loc20_ = PetManager.getMyPetByInvId(_loc9_);
                     if(AvatarManager.playerAvatarWorldView)
                     {
                        _loc2_ = AvatarManager.playerAvatarWorldView;
                        if(_loc20_)
                        {
                           _loc2_.setActivePet(_loc20_.createdTs,_loc20_.lBits,_loc20_.uBits,_loc20_.eBits,_loc20_.name,_loc20_.personalityDefId,_loc20_.favoriteFoodDefId,_loc20_.favoriteToyDefId);
                        }
                        else
                        {
                           _loc2_.setActivePet(0,0,0,0,"",0,0,0);
                        }
                        _loc2_.clearSpecialPattern();
                        _loc2_.setupParticles();
                     }
                     PetManager.myActivePetInvId = _loc9_;
                     _loc12_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc19_.userName,_loc19_.perUserAvId);
                     if(_loc12_ && _loc15_)
                     {
                        _loc15_.questLevel = int(_loc4_[_loc24_++]);
                        _loc15_.questHealthPercentage = _loc12_.questHealthPercentage;
                        _loc15_.healthBase = _loc12_.healthBase;
                        _loc15_.attackBase = _loc12_.attackBase;
                        _loc15_.attackMax = _loc12_.attackMax;
                        _loc15_.defenseBase = _loc12_.defenseBase;
                        _loc15_.defenseMax = _loc12_.defenseMax;
                        gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc19_.perUserAvId,_loc15_,true);
                        _loc19_.itemResponseIntegrate(gMainFrame.userInfo.getUserInfoByUserName(_loc19_.userName).getPartialItemList(_loc19_.avTypeId,true),false);
                        _loc2_.updateNameBarLevelShape(_loc15_.questLevel);
                     }
                  }
                  else
                  {
                     ItemXtCommManager.requestItemListForAvatar(null,_loc19_,false,false);
                     if(AvatarManager.buddyCardAvatarView && _loc19_.userName.toLowerCase() == AvatarManager.buddyCardAvatarView.userName.toLowerCase())
                     {
                        BuddyManager.updateCurrBuddyCardAvatar(_loc19_);
                     }
                     _loc3_ = int(_loc4_[_loc24_++]);
                     _loc8_ = int(_loc4_[_loc24_++]);
                     _loc17_ = int(_loc4_[_loc24_++]);
                     _loc11_ = _loc4_[_loc24_++];
                     _loc21_ = Number(_loc4_[_loc24_++]);
                     _loc23_ = int(_loc4_[_loc24_++]);
                     _loc10_ = int(_loc4_[_loc24_++]);
                     _loc6_ = int(_loc4_[_loc24_++]);
                     _loc7_ = int(_loc4_[_loc24_++]);
                     _loc2_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc13_);
                     if(_loc2_)
                     {
                        _loc2_.setActivePet(_loc21_,_loc3_,_loc8_,_loc17_,_loc11_,_loc23_,_loc10_,_loc6_);
                     }
                     _loc18_ = {
                        "name":_loc11_,
                        "lBits":_loc3_,
                        "uBits":_loc8_,
                        "eBits":_loc17_,
                        "createdTs":_loc21_,
                        "personalityDefId":_loc23_,
                        "favoriteFoodDefId":_loc10_,
                        "favoriteToyDefId":_loc6_
                     };
                     _loc18_.defId = PetManager.getDefIdFromLBits(_loc18_.lBits);
                     _loc18_.type = PetManager.petTypeForDefId(_loc18_.defId);
                     _loc18_.isGround = PetManager.isGround(_loc18_.type);
                     _loc15_.currPet = _loc18_;
                     _loc15_.questLevel = _loc7_;
                     gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc19_.perUserAvId,_loc15_,true);
                     _loc2_.updateNameBarLevelShape(_loc15_.questLevel);
                     _loc2_.clearSpecialPattern();
                     _loc2_.setupParticles();
                     _loc16_ = new BuddyEvent("OnBuddyChanged");
                     _loc16_.userName = _loc15_.userName;
                     BuddyManager.eventDispatcher.dispatchEvent(_loc16_);
                  }
                  AvatarWorldView(_loc22_.parent).setPos(_loc22_.parent.x,_loc22_.parent.y,false);
                  delete _loc22_.data;
                  if(_switchCallback != null)
                  {
                     _switchCallback(true);
                     _switchCallback = null;
                  }
               }
            }
         }
         else if(_loc22_.currentFrameLabel == "changeAvatar")
         {
            AvatarView(_loc22_.parent).showAvatar();
         }
         else if(_loc22_.currentFrameLabel == "tintOn")
         {
            _loc26_ = AvatarWorldView(_loc22_.parent);
            if(_loc26_.roomType == 0)
            {
               _loc26_.setBlendColor(4290903190,7534606);
            }
            else
            {
               _loc26_.setBlendColor(4294967295,16777107);
            }
         }
         else if(_loc22_.currentFrameLabel == "tintOff")
         {
            _loc14_ = AvatarWorldView(_loc22_.parent);
            _loc14_.setBlendColor(0);
            _loc14_.setAlphaLevel(100);
            if(_loc14_.userId == playerSfsUserId)
            {
               AvatarManager.clearPlayerSplashColor();
            }
         }
         else if(_loc22_.currentFrame == _loc22_.totalFrames)
         {
            endTransformAnim(_loc22_);
         }
      }
      
      private static function endTransformAnim(param1:MovieClip) : void
      {
         var _loc3_:AvatarWorldView = AvatarWorldView(param1.parent);
         if(param1.parent != null && _loc3_.avatarData != null)
         {
            DebugUtility.debugTrace("ending one of two transitions for sfsUserId:" + _loc3_.userId);
         }
         param1.removeEventListener("enterFrame",transformEnterFrameHandler);
         var _loc2_:SoundTransform = param1.soundTransform;
         _loc2_.volume = 0;
         param1.soundTransform = _loc2_;
         param1.gotoAndStop(1);
         RoomXtCommManager.isSwitching = false;
         if(_loc3_.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() && !QuestManager.isInPrivateAdventureState)
         {
            GuiManager.setSwapBtnGray(false);
         }
         if(param1.parent != null)
         {
            param1.parent.removeChild(param1);
         }
         _loc3_.isCurrentlySwitching = false;
      }
   }
}

