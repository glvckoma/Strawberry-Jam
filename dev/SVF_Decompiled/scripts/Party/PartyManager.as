package Party
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.sbi.bit.BitUtility;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import currency.UserCurrency;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loadProgress.LoadProgress;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import masterpiece.MasterpieceDisplayItem;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PartyManager
   {
      public static const RESTRICTIONS_NONE:int = 0;
      
      public static const RESTRICTIONS_AVATAR:int = 1;
      
      public static const RESTRICTIONS_MEMBERONLY:int = 2;
      
      public static const RESTRICTIONS_PET:int = 4;
      
      public static const RESTRICTIONS_PET_ONLY:int = 8;
      
      public static const PARTY_DEF_MASTERPIECE:int = 47;
      
      private static const PARTY_POPUP_MEDIA_ID:int = 1215;
      
      private static var _partyDefs:Object;
      
      private static var _partyPopup:PartyPopup;
      
      private static var _timeOffset:int;
      
      private static var _masterpieceDisplayItems:Array;
      
      public function PartyManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _timeOffset = Math.abs(RoomManagerWorld.instance.shardId) * 10 % 60;
         requestPartyDefs(null);
      }
      
      public static function openPartyPopup() : void
      {
         if(_partyPopup)
         {
            _partyPopup.destroy();
         }
         _partyPopup = new PartyPopup(onPartyPopupClose,_timeOffset);
      }
      
      public static function showPartyPopup(param1:Boolean) : void
      {
         if(_partyPopup)
         {
            _partyPopup.showPopup(param1);
         }
         else
         {
            openPartyPopup();
         }
      }
      
      public static function closePartyPopup(param1:Boolean = false) : void
      {
         if(param1 && _partyPopup)
         {
            _partyPopup.showPopup(false);
         }
         else
         {
            onPartyPopupClose();
         }
      }
      
      public static function updateTime(param1:int) : void
      {
         if(_partyPopup)
         {
            _partyPopup.updateTime(param1);
         }
      }
      
      public static function get partyDefs() : Object
      {
         return _partyDefs;
      }
      
      public static function getPartyDef(param1:int) : Object
      {
         return _partyDefs[param1];
      }
      
      public static function roomSoireeResponse(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 2;
         if(param1[_loc3_++] == "0")
         {
            if(RoomXtCommManager._joiningBuddyCrossNode)
            {
               RoomXtCommManager._joiningBuddyCrossNode = false;
               RoomXtCommManager._loadingNewRoom = false;
               RoomXtCommManager.sendRoomJoinRequest(gMainFrame.clientInfo.startUpRoom + "#-1");
               return;
            }
            _loc2_ = param1[_loc3_++];
            RoomXtCommManager.loadingNewRoom = false;
            if(_loc2_ == "NM")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14779));
            }
            else if(_loc2_ == "NA")
            {
               GuiManager.showBarrierPopup(0,false,false,param1[_loc3_++]);
            }
            else if(_loc2_ == "NP")
            {
               DarkenManager.showLoadingSpiral(false);
               GuiManager.showBarrierPopup(0,false,false,param1[_loc3_++]);
            }
         }
      }
      
      public static function partyListResponse(param1:Object) : void
      {
         if(_partyPopup)
         {
            _partyPopup.partyListResponse(param1);
         }
      }
      
      public static function customPartyListResponse(param1:Object) : void
      {
         if(_partyPopup)
         {
            _partyPopup.customPartyListResponse(param1);
         }
      }
      
      public static function customPartyCreateResponse(param1:Object) : void
      {
         var _loc2_:UserInfo = null;
         var _loc6_:* = false;
         var _loc4_:int = 0;
         var _loc5_:int = 2;
         var _loc3_:* = param1[_loc5_++] == "1";
         if(_loc3_)
         {
            _loc6_ = param1[_loc5_++] == "1";
            if(_loc6_)
            {
               _loc2_ = gMainFrame.userInfo.playerUserInfo;
               if(_loc2_)
               {
                  _loc2_.timeLeftHostingCustomParty = int(param1[_loc5_++]);
                  gMainFrame.userInfo.playerUserInfo = _loc2_;
                  AvatarManager.updateCustomPartyHostingDataForMyself();
               }
            }
         }
         else
         {
            _loc2_ = gMainFrame.userInfo.playerUserInfo;
            if(_loc2_)
            {
               _loc2_.timeLeftHostingCustomParty = -1;
               gMainFrame.userInfo.playerUserInfo = _loc2_;
               AvatarManager.updateCustomPartyHostingDataForMyself();
            }
            switch(param1[_loc5_++])
            {
               case "ND":
                  _loc4_ = 24247;
                  break;
               case "EXISTS":
                  _loc4_ = 24249;
                  break;
               case "NM":
                  _loc4_ = 24236;
                  break;
               case "INV":
               case "NR":
               case "DIS":
               default:
                  _loc4_ = 24248;
            }
            onPartyPopupClose(true);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(_loc4_));
         }
      }
      
      public static function customPartyJoinResponse(param1:Object) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 2;
         var _loc2_:* = param1[_loc4_++] == "1";
         if(!_loc2_)
         {
            switch(param1[_loc4_++])
            {
               case "NPP":
               case "BLK":
               case "DIS":
                  _loc3_ = 24251;
                  break;
               default:
                  _loc3_ = 24251;
            }
            onPartyPopupClose(true);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(_loc3_));
         }
      }
      
      public static function customPartyIsHostingResponse(param1:Object, param2:String, param3:Function) : void
      {
         var _loc5_:UserInfo = null;
         var _loc4_:int = int(param1[2]);
         if(param2 != null && param2 != "")
         {
            _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(param2);
            if(_loc5_)
            {
               _loc5_.timeLeftHostingCustomParty = _loc4_;
            }
         }
         if(param3 != null)
         {
            param3(_loc4_,_loc5_);
         }
      }
      
      public static function customPartyKillResponse(param1:Object) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.playerUserInfo;
         if(_loc2_)
         {
            _loc2_.timeLeftHostingCustomParty = -1;
            gMainFrame.userInfo.playerUserInfo = _loc2_;
            AvatarManager.updateCustomPartyHostingDataForMyself();
         }
         onPartyPopupClose(true);
         var _loc3_:int = int(param1[2]);
         Utility.setupDiamondRefundPopup(GuiManager.guiLayer,_loc3_,null);
         UserCurrency.setCurrency(UserCurrency.getCurrency(3) + _loc3_,3);
      }
      
      public static function requestPartyDefs(param1:Function) : void
      {
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(1047,onPartyDataResponse,param1,2);
         DefPacksDefHelper.mediaArray[1047] = _loc2_;
      }
      
      public static function sendCustomPartyJoin(param1:String, param2:String, param3:String) : void
      {
         DarkenManager.showLoadingSpiral(true);
         if(param3 == null)
         {
            PartyXtCommManager.sendCustomPartyNodeId(param1,param2,onGetPartyNodeId);
         }
         else if(param3 == gMainFrame.server.serverIp)
         {
            PartyXtCommManager.sendCustomPartyJoinRequest(param2);
         }
         else
         {
            gMainFrame.clientInfo.autoStartRoom = param2;
            gMainFrame.clientInfo.autoStartRoomShardId = -4;
            DebugUtility.debugTrace("using autoStartRoom to prep resend custom party join request after switching server nodes - customPartyCreatorUUID:" + gMainFrame.clientInfo.autoStartRoom + " autoStartRoomShardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
            if(!gMainFrame.switchServersIfNeeded(param3))
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
               return;
            }
         }
      }
      
      public static function isBeYourPetParty() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc1_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc1_ != null && _loc1_.restrictions == 8)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function isPetSpecificRequiredParty() : Boolean
      {
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc1_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc1_ != null && _loc1_.restrictions == 4 && BitUtility.numberOfBitsSet(_loc1_.petDefScalableFlags) == 1)
            {
               return true;
            }
         }
         return false;
      }
      
      public static function canSwitchToAvatar(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc3_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc3_ != null)
            {
               if(_loc3_.restrictions == 1)
               {
                  if(BitUtility.bitwiseAnd(_loc3_.avatarDefFlags,BitUtility.leftShiftNumbers(param1.avTypeId - 1)) == 0)
                  {
                     if(param2)
                     {
                        GuiManager.showBarrierPopup(0,true);
                     }
                     return false;
                  }
               }
               else if(_loc3_.restrictions == 4 || _loc3_.restrictions == 8)
               {
                  if(!PetManager.checkIfHasPet(param1.enviroTypeFlag))
                  {
                     if(param2)
                     {
                        GuiManager.showBarrierPopup(0,true,true);
                     }
                     return false;
                  }
               }
            }
         }
         return true;
      }
      
      public static function canSwitchPet(param1:Boolean = false) : Boolean
      {
         var _loc2_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc2_ = _partyDefs[gMainFrame.clientInfo.secondaryDefId];
            if(_loc2_ != null && (_loc2_.restrictions == 4 || _loc2_.restrictions == 8))
            {
               if(param1)
               {
                  GuiManager.showBarrierPopup(0,true);
               }
               return false;
            }
         }
         return true;
      }
      
      public static function setupMasterpiecesInRoom(param1:Array) : void
      {
         var _loc2_:MasterpieceDisplayItem = null;
         var _loc6_:Object = null;
         var _loc5_:int = 0;
         _masterpieceDisplayItems = [];
         var _loc3_:Object = gMainFrame.clientInfo.customRoomData;
         var _loc4_:int = Math.min(12,_loc3_.pool.length);
         if(_loc3_)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               if(_loc5_ < _loc4_)
               {
                  _loc6_ = _loc3_.pool[_loc5_];
               }
               else
               {
                  _loc6_ = _loc3_.pluspool[_loc5_ - _loc4_];
               }
               if(_loc6_ != null)
               {
                  _loc2_ = new MasterpieceDisplayItem();
                  _loc2_.initFromPool(_loc6_,onMasterpieceDisplayItemLoaded,param1[_loc5_].s.content.imageCont);
                  _masterpieceDisplayItems[_loc2_.uniqueImageId] = _loc2_;
               }
               _loc5_++;
            }
         }
      }
      
      public static function handleMasterpieceClick(param1:Object) : void
      {
         var _loc2_:Object = null;
         while(param1.parent && param1.parent != _loc2_)
         {
            if(param1.parent is MasterpieceDisplayItem)
            {
               GuiManager.openMasterpiecePreview((param1.parent as MasterpieceDisplayItem).uniqueImageId,(param1.parent as MasterpieceDisplayItem).uniqueImageCreator,(param1.parent as MasterpieceDisplayItem).uniqueImageCreatorDbId,(param1.parent as MasterpieceDisplayItem).uniqueImageCreatorUUID,(param1.parent as MasterpieceDisplayItem).versionId,null);
               break;
            }
            _loc2_ = param1.parent;
            param1 = param1.parent;
         }
      }
      
      private static function onMasterpieceDisplayItemLoaded(param1:MasterpieceDisplayItem, param2:Object) : void
      {
         var _loc3_:Number = param2.itemLayer.width / param1.width;
         if(param1.height * _loc3_ > param2.itemLayer.height)
         {
            _loc3_ = param2.itemLayer.height / param1.height;
         }
         param1.scaleX = param1.scaleY = _loc3_;
         param2.addChild(param1);
         delete _masterpieceDisplayItems[param1.uniqueImageId];
      }
      
      private static function onPartyDataResponse(param1:DefPacksDefHelper) : void
      {
         DefPacksDefHelper.mediaArray[1047] = null;
         _partyDefs = param1.def;
         if(param1.passback != null)
         {
            param1.passback();
         }
      }
      
      private static function onPartyPopupClose(param1:Boolean = false) : void
      {
         if(_partyPopup)
         {
            _partyPopup.destroy(param1);
            _partyPopup = null;
         }
      }
      
      private static function onGetPartyNodeId(param1:String, param2:Object) : void
      {
         if(param2[2] == "1")
         {
            sendCustomPartyJoin(param1,param2[3],param2[4]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
   }
}

