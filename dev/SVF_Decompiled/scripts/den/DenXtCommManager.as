package den
{
   import Enums.DenItemDef;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.MannequinData;
   import buddy.BuddyManager;
   import collection.DenItemCollection;
   import collection.DenItemDefCollection;
   import collection.DenRoomItemCollection;
   import collection.DenStateItemCollection;
   import collection.IitemCollection;
   import collection.IntItemCollection;
   import collection.PetItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import currency.UserCurrency;
   import flash.utils.Dictionary;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetDef;
   import pet.PetItem;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import shop.ShopToSellXtCommManager;
   
   public class DenXtCommManager
   {
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _denChangePending:Boolean;
      
      private static var _pendingDenChangeItems:DenStateItemCollection;
      
      private static var _itemBuyCallback:Function;
      
      private static var _denEditorDIResponseCallback:Function;
      
      private static var _denItemsCallback:Function;
      
      private static var _denMasterpieceItemsCallback:Function;
      
      private static var _denListCallback:Function;
      
      private static var _denRecycleCallback:Function;
      
      private static var _recycleDiCallback:Function;
      
      private static var _denRoomBuyCallback:Function;
      
      private static var _denHighestCallback:Function;
      
      private static var _denPrivateCallback:Function;
      
      private static var _denChangeCallback:Function;
      
      private static var _dmcCallback:Function;
      
      private static var _onDenSaveSetCallback:Function;
      
      private static var _ecoRefreshCallback:Function;
      
      private static var _ecoCreditRedeemCallback:Function;
      
      private static var _ecoConsumerCallback:Function;
      
      private static var _isBuyingDenRoom:Boolean;
      
      private static var _cachedDlResponse:Object;
      
      private static var _denItemDefs:DenItemDefCollection;
      
      public function DenXtCommManager()
      {
         super();
      }
      
      public static function init(param1:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         _denListCallback = param1;
         _denChangePending = false;
         _pendingDenChangeItems = null;
         new DenMannequinInventory();
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(1030,denItemDefsResponse,null,2);
         DefPacksDefHelper.mediaArray[1030] = _loc2_;
         XtReplyDemuxer.addModule(handleXtReply,"d");
      }
      
      public static function destroy() : void
      {
         _denEditorDIResponseCallback = null;
         _denItemsCallback = null;
         _denRecycleCallback = null;
         _recycleDiCallback = null;
      }
      
      public static function requestDenStateChange(param1:Array, param2:Function) : void
      {
         var _loc3_:MannequinData = null;
         var _loc5_:int = 0;
         var _loc4_:Array = [];
         var _loc6_:int = 0;
         _loc4_[_loc6_++] = param1.length;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc3_ = param1[_loc5_].mannequinData;
            _loc4_[_loc6_++] = param1[_loc5_].r;
            _loc4_[_loc6_++] = param1[_loc5_].i;
            _loc4_[_loc6_++] = param1[_loc5_].d;
            _loc4_[_loc6_++] = param1[_loc5_].x;
            _loc4_[_loc6_++] = param1[_loc5_].y;
            _loc4_[_loc6_++] = !!param1[_loc5_].f ? param1[_loc5_].f : 0;
            _loc4_[_loc6_++] = param1[_loc5_].userNameLink == "" ? "off" : param1[_loc5_].userNameLink;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.baseColor;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.patternColor;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.patternDefId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.eyeColor;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.eyeDefId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.tailInvId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.legInvId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.backInvId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.neckInvId;
            _loc4_[_loc6_++] = _loc3_ == null ? 0 : _loc3_.headInvId;
            _loc5_++;
         }
         _onDenSaveSetCallback = param2;
         gMainFrame.server.setXtObject_Str("ds",_loc4_);
      }
      
      public static function requestDenItems(param1:Function = null) : void
      {
         _denItemsCallback = param1;
         gMainFrame.server.setXtObject_Str("di",[]);
      }
      
      public static function requestDenMasterpieceItems(param1:String, param2:Function) : void
      {
         _denMasterpieceItemsCallback = param2;
         gMainFrame.server.setXtObject_Str("dmi",[param1]);
      }
      
      public static function requestDenRoomList() : void
      {
         gMainFrame.server.setXtObject_Str("dl",[]);
      }
      
      public static function requestBuy(param1:Boolean, param2:int, param3:int, param4:Function, param5:Function, param6:int = 0, param7:Function = null, param8:int = 0, param9:int = 0, param10:Boolean = false, param11:Boolean = false, param12:String = "") : void
      {
         _itemBuyCallback = param4;
         _denEditorDIResponseCallback = param5;
         if(param1)
         {
            gMainFrame.server.setXtObject_Str("db",["0",param2,param3,param8,param9,param10 ? "1" : "0",param11 ? "1" : "0",param12]);
         }
         else
         {
            _isBuyingDenRoom = true;
            gMainFrame.server.setXtObject_Str("db",["-1",param2,param3,param6,param9]);
            _denRoomBuyCallback = param7;
         }
      }
      
      public static function requestRecycle(param1:Boolean, param2:IntItemCollection, param3:Function, param4:Function = null) : void
      {
         _denRecycleCallback = param3;
         _recycleDiCallback = param4;
         gMainFrame.server.setXtObject_Str("dr",[param1 ? "0" : "-1",param2.getCoreArray()]);
      }
      
      public static function requestDenChange(param1:int, param2:Function) : void
      {
         _denChangeCallback = param2;
         gMainFrame.server.setXtObject_Str("dc",[DenSwitch.denList.getDenRoomItem(param1).invIdx]);
      }
      
      public static function requestDenJoinFull(param1:String, param2:int = -1, param3:Boolean = true, param4:Boolean = true) : void
      {
         var _loc5_:String = null;
         if(!RoomXtCommManager.isSwitching)
         {
            if(RoomXtCommManager.loadingNewRoom)
            {
               DebugUtility.debugTrace("INGORING requestDenJoinFull request because user is already joining a new room!");
               return;
            }
            if(gMainFrame.server.getCurrentRoom())
            {
               if(param1 == gMainFrame.server.getCurrentRoomName())
               {
                  trace("WARNING: User is already in this den!");
                  DarkenManager.showLoadingSpiral(false);
                  return;
               }
            }
            DarkenManager.showLoadingSpiral(true);
            AvatarManager.joiningNewRoom = true;
            if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
            {
               SBTracker.trackPageview("/game/play/loading/changeRooms");
            }
            RoomXtCommManager.denJoinRequested(param1);
            _denChangePending = true;
            _loc5_ = param4 ? "1" : "0";
            gMainFrame.server.setXtObject_Str("dj",[param1,_loc5_,param2]);
            if(param3 || _roomMgr.forceInvisMode)
            {
               _roomMgr.forceInvisMode = true;
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      public static function requestDenHighest() : void
      {
         gMainFrame.server.setXtObject_Str("dh",[]);
      }
      
      public static function requestSetDenPrivacy(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["0",param1]);
      }
      
      public static function requestUserDenPrivacy(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("dp",["1",param1]);
      }
      
      public static function requestEmptyDen() : void
      {
         gMainFrame.server.setXtObject_Str("de",[]);
      }
      
      public static function requestDenPhantom(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("dph",[param1]);
      }
      
      public static function requestDenMasterpieceCreatorName(param1:String, param2:String, param3:Function) : void
      {
         _dmcCallback = param3;
         gMainFrame.server.setXtObject_Str("dmc",[param1,param2]);
      }
      
      public static function requestDenEcoCreditRefresh(param1:Function) : void
      {
         _ecoRefreshCallback = param1;
         gMainFrame.server.setXtObject_Str("dEf",[]);
      }
      
      public static function requestDenEcoCreditRedeem(param1:Function) : void
      {
         _ecoCreditRedeemCallback = param1;
         gMainFrame.server.setXtObject_Str("dEr",[]);
      }
      
      public static function requestDenEcoConsumer(param1:int, param2:Boolean, param3:Function) : void
      {
         _ecoConsumerCallback = param3;
         gMainFrame.server.setXtObject_Str("dEc",[param1,param2 ? "1" : "0"]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "ds":
               denStateResponse(_loc2_);
               break;
            case "dss":
               denStateSetResponse(_loc2_);
               break;
            case "dp":
               denPrivacyResponse(_loc2_);
               break;
            case "dpk":
               denPrivacyKickResponse();
               break;
            case "di":
               denItemsResponse(_loc2_);
               break;
            case "dc":
               denChangeResponse(_loc2_);
               break;
            case "db":
               denBuyResponse(_loc2_);
               break;
            case "dr":
               denRecycleResponse(_loc2_);
               break;
            case "dh":
               denHighestResponse(_loc2_);
               break;
            case "dl":
               denListResponse(_loc2_);
               break;
            case "drc":
               denRoomCount(_loc2_);
               break;
            case "de":
               denEmptyResponse(_loc2_);
               break;
            case "dmi":
               denMasterpieceInventoryResponse(_loc2_);
               break;
            case "dph":
               denPhantomResponse(_loc2_);
               break;
            case "dmc":
               denMasterpieceCreatorResponse(_loc2_);
               break;
            case "dEf":
               denEcoRefreshResponse(_loc2_);
               break;
            case "dEr":
               denEcoCreditRefreshResponse(_loc2_);
               break;
            case "dEc":
               denEcoConsumerResponse(_loc2_);
               break;
            default:
               ShopToSellXtCommManager.handleXtReply(param1);
         }
      }
      
      public static function denItemsResponse(param1:Object) : void
      {
         var _loc31_:int = 0;
         var _loc28_:int = 0;
         var _loc32_:int = 0;
         var _loc24_:int = 0;
         var _loc14_:* = false;
         var _loc33_:String = null;
         var _loc17_:int = 0;
         var _loc30_:String = null;
         var _loc4_:MannequinData = null;
         var _loc26_:int = 0;
         var _loc21_:int = 0;
         var _loc18_:DenItem = null;
         var _loc22_:DenItemDef = null;
         var _loc7_:PetItem = null;
         if(gMainFrame.userInfo.playerUserInfo == null)
         {
            return;
         }
         var _loc23_:int = 2;
         DenSwitch.activeDenIdx = int(param1[_loc23_++]);
         var _loc13_:int = int(param1[_loc23_++]);
         var _loc15_:int = int(param1[_loc23_++]);
         var _loc6_:DenItemCollection = new DenItemCollection();
         new DenMannequinInventory();
         var _loc20_:Array = [];
         var _loc8_:Boolean = true;
         _loc21_ = 0;
         while(_loc21_ < _loc13_)
         {
            _loc18_ = new DenItem();
            _loc31_ = int(param1[_loc23_++]);
            _loc28_ = int(param1[_loc23_++]);
            _loc32_ = int(param1[_loc23_++]);
            _loc24_ = int(param1[_loc23_++]);
            _loc14_ = param1[_loc23_++] == "true";
            _loc33_ = param1[_loc23_++];
            _loc17_ = int(param1[_loc23_++]);
            _loc30_ = param1[_loc23_++];
            _loc22_ = getDenItemDef(_loc28_);
            if(_loc22_)
            {
               if(_loc22_.sortCat == 4 && _loc32_ > 0)
               {
                  _loc8_ = false;
               }
               if(_loc22_.specialType == 4)
               {
                  _loc4_ = new MannequinData();
                  _loc23_ = _loc4_.init(_loc22_,param1,_loc23_,true,_loc31_,true);
               }
               _loc26_ = int(param1[_loc23_++]);
               _loc18_.init(_loc28_,_loc31_,_loc32_,_loc24_,0,null,_loc14_,_loc33_,"",_loc17_,_loc30_,_loc4_,_loc26_);
               _loc6_.setDenItem(_loc21_,_loc18_);
               if(_loc18_.minigameDefId > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc18_.minigameDefId))
               {
                  _loc20_.push(_loc18_.minigameDefId);
               }
            }
            _loc21_++;
         }
         _loc6_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc18_ = new DenItem();
         _loc18_.init(617,-1,_loc8_ ? 7 : 0);
         _loc6_.getCoreArray().unshift(_loc18_);
         var _loc3_:PetItemCollection = PetManager.myPetListAsIitem;
         var _loc27_:DenItemCollection = new DenItemCollection();
         var _loc19_:DenItemCollection = new DenItemCollection();
         _loc21_ = 0;
         while(_loc21_ < _loc3_.length)
         {
            _loc7_ = _loc3_.getPetItem(_loc21_);
            _loc18_ = new DenItem();
            _loc18_.init(_loc7_.defId,_loc7_.invIdx,0,0,1,_loc7_);
            if(PetManager.canPetGoInBothEnviroTypes(_loc7_.currPetDef,_loc7_.createdTs))
            {
               _loc27_.pushDenItem(_loc18_);
               _loc19_.pushDenItem(_loc18_);
            }
            else if(_loc18_.enviroType == 2 || _loc18_.enviroType == 0)
            {
               _loc27_.pushDenItem(_loc18_);
            }
            else
            {
               _loc19_.pushDenItem(_loc18_);
            }
            _loc21_++;
         }
         _loc27_.getCoreArray().sortOn("invIdx",0x10 | 2);
         _loc19_.getCoreArray().sortOn("invIdx",0x10 | 2);
         var _loc25_:int = 0;
         while(_loc25_ < _loc15_)
         {
            _loc31_ = int(param1[_loc23_ + _loc25_]);
            _loc21_ = 0;
            while(_loc21_ < _loc27_.length)
            {
               if(_loc27_.getDenItem(_loc21_).invIdx == _loc31_)
               {
                  _loc27_.getDenItem(_loc21_).categoryId = 1;
                  break;
               }
               _loc21_++;
            }
            _loc21_ = 0;
            while(_loc21_ < _loc19_.length)
            {
               if(_loc19_.getDenItem(_loc21_).invIdx == _loc31_)
               {
                  _loc19_.getDenItem(_loc21_).categoryId = 1;
                  break;
               }
               _loc21_++;
            }
            _loc25_++;
         }
         if(_loc20_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc20_);
         }
         gMainFrame.userInfo.playerUserInfo.denItemsPartial = enviroItems(_loc6_);
         if(AvatarManager.playerAvatar != null)
         {
            AvatarManager.playerAvatar.inventoryDenPartial.denItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
            AvatarManager.playerAvatar.inventoryDenFull.denItemCollection = _loc6_;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc6_;
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc27_,0);
         gMainFrame.userInfo.setMyPetsInDenByEnviroType(_loc19_,1);
         if(_denItemsCallback != null)
         {
            _denItemsCallback();
         }
         if(_denEditorDIResponseCallback != null)
         {
            _denEditorDIResponseCallback();
         }
         if(_recycleDiCallback != null)
         {
            _recycleDiCallback();
         }
      }
      
      public static function addPetToDen(param1:PetItem) : void
      {
         var _loc2_:DenItem = new DenItem();
         _loc2_.init(param1.defId,param1.invIdx,0,0,1,param1);
         if(PetManager.canPetGoInBothEnviroTypes(param1.currPetDef,param1.createdTs))
         {
            if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(0))
            {
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(0).getCoreArray().unshift(_loc2_);
            }
            else
            {
               gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),0);
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(0).pushDenItem(_loc2_);
            }
            if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(1))
            {
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(1).getCoreArray().unshift(_loc2_);
            }
            else
            {
               gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),1);
               gMainFrame.userInfo.getMyPetsInDenByEnviroType(1).pushDenItem(_loc2_);
            }
         }
         else if(gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType))
         {
            gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType).getCoreArray().unshift(_loc2_);
         }
         else
         {
            gMainFrame.userInfo.setMyPetsInDenByEnviroType(new DenItemCollection(),_loc2_.enviroType);
            gMainFrame.userInfo.getMyPetsInDenByEnviroType(_loc2_.enviroType).pushDenItem(_loc2_);
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      public static function removePetFromDen(param1:int, param2:PetItem) : void
      {
         if(PetManager.canPetGoInBothEnviroTypes(param2.currPetDef,param2.createdTs))
         {
            removePetFromDenByEnviroType(param1,0);
            removePetFromDenByEnviroType(param1,1);
         }
         else
         {
            removePetFromDenByEnviroType(param1,PetManager.getEnviroTypeByPetType(param2.currPetDef,param2.createdTs));
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      private static function removePetFromDenByEnviroType(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DenItemCollection = gMainFrame.userInfo.getMyPetsInDenByEnviroType(param2);
         if(!_loc4_)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            if(_loc4_.getDenItem(_loc3_).invIdx == param1)
            {
               _loc4_.getCoreArray().splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public static function reloadPetInDen(param1:int, param2:Number, param3:int, param4:String, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int) : void
      {
         if(PetManager.canPetGoInBothEnviroTypes(PetManager.getPetDef(param5 & 0xFF),param2))
         {
            updatePetInDenByEnviroType(param1,param2,0,param4,param5,param6,param7,param8,param9,param10);
            updatePetInDenByEnviroType(param1,param2,1,param4,param5,param6,param7,param8,param9,param10);
         }
         else
         {
            updatePetInDenByEnviroType(param1,param2,PetManager.getEnviroTypeByPetType(PetManager.getPetDef(param5 & 0xFF),param2),param4,param5,param6,param7,param8,param9,param10);
         }
         GuiManager.resetPetWindowListAndUpdateBtns();
      }
      
      private static function updatePetInDenByEnviroType(param1:int, param2:Number, param3:int, param4:String, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int) : void
      {
         var _loc11_:int = 0;
         var _loc12_:DenItem = null;
         var _loc13_:DenItemCollection = gMainFrame.userInfo.getMyPetsInDenByEnviroType(param3);
         if(!_loc13_)
         {
            return;
         }
         _loc11_ = 0;
         while(_loc11_ < _loc13_.length)
         {
            _loc12_ = _loc13_.getDenItem(_loc11_);
            if(_loc12_.invIdx == param1)
            {
               _loc12_.version = param5;
               _loc12_.version2 = param6;
               _loc12_.version3 = param7;
               _loc12_.petTraitDefId = param8;
               _loc12_.petFoodDefId = param9;
               _loc12_.petToyDefId = param10;
               _loc12_.createdTs = param2;
               _loc12_.name = LocalizationManager.translatePetName(param4);
               if(_loc12_.petItem)
               {
                  _loc12_.petItem.setPetBits(param5,param6,param7);
                  _loc12_.petItem.traitDefId = param8;
                  _loc12_.petItem.foodDefId = param9;
                  _loc12_.petItem.toyDefId = param10;
                  _loc12_.petItem.createdTs = param2;
               }
               break;
            }
            _loc11_++;
         }
      }
      
      public static function set denEditorDIResponseCallback(param1:Function) : void
      {
         _denEditorDIResponseCallback = param1;
      }
      
      private static function denBuyResponse(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc6_:int = int(param1[2]);
         var _loc2_:int = int(param1[5]);
         var _loc4_:int = int(param1[4]);
         var _loc3_:int = int(param1[6]);
         if(param1[3] == "")
         {
            _loc5_ = UserCurrency.getCurrency(_loc2_);
            if(_loc5_ == null)
            {
               throw new Error("DenXtCommManager: Received unknown currencyType: " + _loc2_);
            }
         }
         else
         {
            _loc5_ = param1[3];
         }
         if(_loc6_ == 1)
         {
            if(!UserCurrency.setCurrency(_loc5_,_loc2_))
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc2_);
            }
         }
         if(_itemBuyCallback != null)
         {
            _itemBuyCallback(_loc6_,_loc5_,_loc3_);
            _itemBuyCallback = null;
         }
      }
      
      private static function denRecycleResponse(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 2;
         var _loc2_:int = int(param1[_loc6_++]);
         var _loc4_:int = UserCurrency.getCurrency(0) as int;
         var _loc3_:int = int(param1[_loc6_] == "-1" ? _loc4_ : param1[_loc6_]);
         _loc6_++;
         var _loc7_:Vector.<int> = new Vector.<int>();
         if(_loc2_ > 0)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc7_.push(param1[_loc6_++]);
               _loc5_++;
            }
            UserCurrency.setCurrency(_loc3_,0);
         }
         if(_denRecycleCallback != null)
         {
            _denRecycleCallback(_loc7_);
         }
      }
      
      private static function denHighestResponse(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 2;
         var _loc2_:int = int(param1[_loc5_++]);
         var _loc3_:Array = new Array(_loc2_);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_[_loc4_] = param1[_loc5_++];
            _loc4_++;
         }
         if(_denHighestCallback != null)
         {
            _denHighestCallback(_loc3_);
         }
      }
      
      private static function denPrivateResponse(param1:Object) : void
      {
         if(_denPrivateCallback != null)
         {
            _denPrivateCallback(param1[3],param1[4] == "1");
         }
      }
      
      private static function denRoomCount(param1:Object) : void
      {
         var _loc5_:int = 2;
         var _loc3_:int = int(param1[_loc5_++]);
         var _loc2_:* = param1[_loc5_++] == "1";
         var _loc4_:String = param1[_loc5_++];
         GuiManager.updateDenRoomCount(_loc3_,_loc2_,_loc4_);
      }
      
      private static function denListResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc9_:DenRoomItemCollection = null;
         var _loc5_:int = 0;
         var _loc7_:DenRoomItem = null;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         if(gMainFrame.userInfo.denRoomDefs)
         {
            _loc6_ = 2;
            _loc2_ = int(param1[_loc6_++]);
            _loc9_ = new DenRoomItemCollection();
            _loc5_ = 0;
            while(_loc5_ < _loc2_)
            {
               _loc7_ = new DenRoomItem();
               _loc8_ = int(param1[_loc6_++]);
               _loc3_ = int(param1[_loc6_++]);
               _loc4_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc3_);
               if(_loc4_)
               {
                  _loc7_.init(_loc8_,_loc3_,_loc4_);
                  _loc9_.setDenRoomItem(_loc8_,_loc7_);
               }
               _loc5_++;
            }
            if(_denListCallback != null)
            {
               _denListCallback(_loc9_);
            }
            if(_isBuyingDenRoom)
            {
               if(_denRoomBuyCallback != null)
               {
                  _denRoomBuyCallback();
               }
               _isBuyingDenRoom = false;
               _denRoomBuyCallback = null;
            }
            if(GuiManager.denEditor)
            {
               GuiManager.denEditor.reloadDenItems();
            }
         }
         else
         {
            _cachedDlResponse = param1;
         }
      }
      
      public static function denRoomResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1040] = null;
         var _loc2_:Object = {};
         for each(var _loc3_ in param1.def)
         {
            _loc4_ = {
               "value":int(_loc3_.cost),
               "enviroType":int(_loc3_.enviroType),
               "mediaIdLarge":int(_loc3_.iconMediaRef),
               "defId":Number(_loc3_.id),
               "mediaId":int(_loc3_.mediaRef),
               "name":LocalizationManager.translateIdOnly(_loc3_.titleStrRef),
               "titleStrRef":int(_loc3_.titleStrRef),
               "status":int(_loc3_.storeStatus),
               "membersOnly":_loc3_.membersOnly == "1",
               "roomDefId":int(_loc3_.roomDefId),
               "availabilityStartTime":uint(_loc3_.availabilityStartTime),
               "availabilityEndTime":uint(_loc3_.availabilityEndTime)
            };
            _loc2_[_loc4_.defId] = _loc4_;
         }
         gMainFrame.userInfo.denRoomDefs = _loc2_;
         if(_cachedDlResponse)
         {
            denListResponse(_cachedDlResponse);
            _cachedDlResponse = null;
         }
      }
      
      public static function relocalizeDenRooms() : void
      {
         var _loc1_:Object = gMainFrame.userInfo.denRoomDefs;
         for each(var _loc2_ in _loc1_)
         {
            _loc2_.name = LocalizationManager.translateIdOnly(_loc2_.titleStrRef);
         }
         gMainFrame.userInfo.denRoomDefs = _loc1_;
      }
      
      private static function denStateResponse(param1:Object) : void
      {
         var _loc38_:int = 0;
         var _loc27_:int = 0;
         var _loc12_:* = false;
         var _loc33_:int = 0;
         var _loc34_:int = 0;
         var _loc24_:int = 0;
         var _loc2_:int = 0;
         var _loc22_:String = null;
         var _loc39_:String = null;
         var _loc15_:int = 0;
         var _loc36_:String = null;
         var _loc29_:int = 0;
         var _loc28_:* = 0;
         var _loc6_:int = 0;
         var _loc3_:MannequinData = null;
         var _loc4_:int = 0;
         var _loc21_:int = 0;
         var _loc19_:DenItemDef = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc17_:int = 0;
         var _loc25_:Number = NaN;
         var _loc30_:int = 0;
         var _loc16_:int = 0;
         var _loc11_:int = 0;
         var _loc8_:String = null;
         var _loc35_:PetItem = null;
         var _loc31_:PetDef = null;
         var _loc10_:Boolean = false;
         var _loc32_:int = 0;
         var _loc13_:DenStateItem = null;
         var _loc37_:DenStateItem = null;
         var _loc20_:int = 2;
         var _loc26_:int = int(param1[_loc20_++]);
         var _loc14_:int = int(param1[_loc20_++]);
         var _loc23_:* = param1[_loc20_++] == "1";
         var _loc9_:DenStateItemCollection = new DenStateItemCollection();
         DebugUtility.debugTrace("gettind den state with numItems=" + _loc26_ + "forceReload=" + _loc23_);
         var _loc18_:Array = [];
         _loc21_ = 0;
         while(_loc21_ < _loc26_)
         {
            _loc38_ = int(param1[_loc20_++]);
            _loc27_ = int(param1[_loc20_++]);
            _loc19_ = getDenItemDef(_loc27_);
            if(!_loc19_)
            {
               _loc9_.setDenStateItem(_loc21_,new DenStateItem(0,_loc38_,0,0,0,0,0,0,0,0,0,0,0,0,0,"",0,"",0,0,"","",-1,"",false,null,0,0,null,null,2));
            }
            else
            {
               _loc12_ = param1[_loc20_++] == "1";
               _loc33_ = int(param1[_loc20_++]);
               _loc34_ = int(param1[_loc20_++]);
               _loc24_ = int(param1[_loc20_++]);
               _loc2_ = int(param1[_loc20_++]);
               _loc22_ = param1[_loc20_] == "null" ? "" : param1[_loc20_];
               _loc20_++;
               _loc39_ = param1[_loc20_++];
               _loc15_ = int(param1[_loc20_++]);
               _loc36_ = param1[_loc20_++];
               if(_loc19_.specialType == 4)
               {
                  _loc3_ = new MannequinData();
                  _loc20_ = _loc3_.init(_loc19_,param1,_loc20_,false,_loc38_,RoomManagerWorld.instance.isMyDen);
               }
               _loc4_ = int(param1[_loc20_++]);
               _loc29_ = _loc19_.sortCat;
               if(_loc12_)
               {
                  if(_loc29_ == 0 || _loc29_ == 99 || _loc29_ == 6 || _loc29_ == 5)
                  {
                     _loc29_ = 1;
                  }
                  else if(_loc29_ == 1)
                  {
                     _loc29_ = 2;
                  }
                  else if(_loc29_ == 4)
                  {
                     _loc29_ = 3;
                  }
                  else if(_loc29_ == 2 || _loc29_ == 3)
                  {
                     _loc29_ = _roomMgr.denCatId;
                  }
                  else
                  {
                     _loc29_ = -1;
                  }
               }
               else
               {
                  _loc29_ = -1;
               }
               _loc28_ = uint(_loc27_ << 16 | _loc29_);
               _loc6_ = _loc19_.gameDefId;
               if(_loc6_ > 0 && !MinigameManager.minigameInfoCache.getMinigameInfo(_loc6_))
               {
                  _loc18_.push(_loc6_);
               }
               _loc9_.setDenStateItem(_loc21_,new DenStateItem(_loc27_,_loc38_,_loc28_,_loc33_,_loc34_,_loc24_,_loc19_.flag,0,_loc2_,_loc29_,0,_loc19_.sortCat,_loc19_.gameDefId,_loc19_.layer,_loc19_.enviroType,_loc19_.abbrName,_loc19_.nameStrId,_loc22_,_loc19_.specialType,_loc19_.listId,_loc39_,"",_loc15_,_loc36_,false,null,0,0,null,_loc3_,_loc4_));
            }
            _loc21_++;
         }
         _loc21_ = 0;
         while(_loc21_ < _loc14_)
         {
            _loc38_ = int(param1[_loc20_++]);
            _loc5_ = int(param1[_loc20_++]);
            _loc27_ = PetManager.getDefIdFromLBits(_loc5_);
            _loc31_ = PetManager.getPetDef(_loc27_);
            if(_loc31_ == null)
            {
               _loc9_.setDenStateItem(_loc21_,new DenStateItem(0,_loc38_,0,0,0,0,0,0,0,0,1,99,0,0,0,"",0,"",0,0,"","",-1,"",false,null,0,0,null,null,2));
            }
            else
            {
               _loc7_ = int(param1[_loc20_++]);
               _loc17_ = int(param1[_loc20_++]);
               _loc29_ = int(param1[_loc20_++]);
               _loc33_ = int(param1[_loc20_++]);
               _loc34_ = int(param1[_loc20_++]);
               _loc2_ = int(param1[_loc20_++]);
               _loc25_ = Number(param1[_loc20_++]);
               _loc30_ = int(param1[_loc20_++]);
               _loc16_ = int(param1[_loc20_++]);
               _loc11_ = int(param1[_loc20_++]);
               _loc8_ = param1[_loc20_++];
               _loc27_ = denItemDefIdForPetDefId(_loc27_);
               _loc28_ = uint(_loc27_ << 16 | _loc29_);
               _loc35_ = new PetItem();
               _loc35_.init(_loc25_,_loc31_.defId,[_loc5_,_loc7_,_loc17_],_loc30_,_loc16_,_loc11_,_loc38_,_loc8_);
               _loc9_.setDenStateItem(_loc26_ + _loc21_,new DenStateItem(_loc27_,_loc38_,_loc28_,_loc33_,_loc34_,_loc5_,_loc7_,_loc17_,_loc2_,_loc29_,1,99,0,0,PetManager.getEnviroTypeByPetType(_loc31_,_loc25_),"",_loc31_.titleStrId,"",0,0,"","",-1,"",false,null,0,0,_loc35_,null,2));
            }
            _loc21_++;
         }
         if(_loc18_.length > 0)
         {
            MinigameXtCommManager.sendMinigameInfoRequest(_loc18_);
         }
         if(_pendingDenChangeItems && _pendingDenChangeItems.length > 0)
         {
            _loc32_ = int(_pendingDenChangeItems.length);
            _loc20_ = 0;
            while(_loc20_ < _loc9_.getCoreArray().length)
            {
               _loc10_ = false;
               _loc21_ = 0;
               while(_loc21_ < _loc32_)
               {
                  if(_loc9_.getDenStateItem(_loc20_).refId == _pendingDenChangeItems.getDenStateItem(_loc21_).refId && _loc9_.getDenStateItem(_loc20_).invIdx == _pendingDenChangeItems.getDenStateItem(_loc21_).invIdx)
                  {
                     _loc10_ = true;
                     _loc37_ = _pendingDenChangeItems.getDenStateItem(_loc21_);
                     _loc13_ = _loc9_.getDenStateItem(_loc20_);
                     _loc37_.x = _loc13_.x;
                     _loc37_.y = _loc13_.y;
                     _loc37_.version = _loc13_.version;
                     _loc37_.version2 = _loc13_.version2;
                     _loc37_.flipped = _loc13_.flipped;
                     _loc37_.catId = _loc13_.catId;
                     _loc37_.userNameLink = _loc13_.userNameLink;
                     _loc37_.uniqueImageId = _loc13_.uniqueImageId;
                     _loc37_.uniqueImageCreator = _loc13_.uniqueImageCreator;
                     _loc37_.mannequinData = _loc13_.mannequinData;
                     break;
                  }
                  _loc21_++;
               }
               if(!_loc10_)
               {
                  _pendingDenChangeItems.pushDenStateItem(_loc9_.getDenStateItem(_loc20_));
               }
               _loc20_++;
            }
         }
         else
         {
            _pendingDenChangeItems = _loc9_;
         }
         if(!_denChangePending || _loc23_)
         {
            setDenItems();
         }
         if(_loc23_)
         {
            DarkenManager.showLoadingSpiral(false);
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.joiningNewRoom = false;
         }
      }
      
      private static function denStateSetResponse(param1:Object) : void
      {
         if(_onDenSaveSetCallback != null)
         {
            _onDenSaveSetCallback(param1 as Array);
            _onDenSaveSetCallback = null;
         }
      }
      
      private static function denEmptyResponse(param1:Object) : void
      {
         _roomMgr.denItemHolder.clearDen();
         if(GuiManager.denEditor)
         {
            GuiManager.denEditor.clearDenInUseItems();
         }
      }
      
      private static function denPrivacyResponse(param1:Object) : void
      {
         BuddyManager.onDenPrivacyResponse(param1[2],param1[3]);
      }
      
      private static function denPrivacyKickResponse() : void
      {
         _roomMgr.needsToSeeKickFromDenMessage = true;
      }
      
      private static function denChangeResponse(param1:Object) : void
      {
         _denChangePending = true;
         var _loc2_:int = int(param1[2]);
         if(param1.length >= 4)
         {
            gMainFrame.userInfo.myPerUserAvId = int(param1[3]);
            PetManager.myActivePetInvId = int(param1[4]);
         }
         var _loc3_:Object = gMainFrame.userInfo.getDenRoomDefByDefId(_loc2_);
         var _loc4_:Object = _loc3_ != null ? RoomXtCommManager.getRoomDef(_loc3_.roomDefId) : null;
         if(_denChangeCallback != null)
         {
            _denChangeCallback(_loc4_ != null && _loc3_ != null);
            _denChangeCallback = null;
         }
         if(_loc4_ && _loc3_)
         {
            _roomMgr.loadRoom(_loc4_.pathName,_loc3_.enviroType,2,_loc3_.defId,100,_loc3_.roomDefId,null);
         }
      }
      
      private static function denMasterpieceInventoryResponse(param1:Object) : void
      {
         var _loc2_:DenItem = null;
         var _loc4_:int = 0;
         var _loc6_:int = int(param1[2]);
         var _loc3_:DenItemCollection = new DenItemCollection();
         var _loc5_:int = 3;
         _loc4_ = 0;
         while(_loc4_ < _loc6_)
         {
            _loc2_ = new DenItem();
            _loc2_.init(param1[_loc5_++],param1[_loc5_++],0,param1[_loc5_++],0,null,param1[_loc5_++],param1[_loc5_++],"",param1[_loc5_++],param1[_loc5_++]);
            _loc3_.pushDenItem(_loc2_);
            _loc4_++;
         }
         if(_denMasterpieceItemsCallback != null)
         {
            _denMasterpieceItemsCallback(_loc3_);
            _denMasterpieceItemsCallback = null;
         }
      }
      
      private static function denMasterpieceCreatorResponse(param1:Object) : void
      {
         if(_dmcCallback != null)
         {
            _dmcCallback(param1[2]);
            _dmcCallback = null;
         }
      }
      
      private static function denPhantomResponse(param1:Object) : void
      {
         var _loc3_:AvatarWorldView = null;
         var _loc2_:* = param1[2] == "1";
         if(_loc2_)
         {
            _loc3_ = AvatarManager.getAvatarWorldViewBySfsUserId(param1[3]);
            if(_loc3_ != null)
            {
               _loc3_.setAvatarAsPhantom(param1[4] == "1");
            }
         }
      }
      
      public static function handleDenShopList(param1:Array, param2:int, param3:Function) : IitemCollection
      {
         var _loc8_:IitemCollection = null;
         var _loc6_:int = 0;
         var _loc7_:DenRoomItem = null;
         var _loc10_:Object = null;
         var _loc4_:int = 8;
         var _loc5_:String = param1[4];
         var _loc9_:int = int(param1[_loc4_++]);
         if(param2 == 1030)
         {
            _loc8_ = generateDenShopList(_loc9_,param1.splice(_loc4_++,param1.length));
         }
         else
         {
            _loc8_ = new IitemCollection();
            _loc6_ = 0;
            while(_loc6_ < _loc9_)
            {
               _loc7_ = new DenRoomItem();
               _loc10_ = gMainFrame.userInfo.getDenRoomDefByDefId(param1[_loc4_++]);
               _loc7_.initShopItem(_loc6_,_loc10_.defId,_loc10_);
               _loc8_.setIitem(_loc6_,_loc7_);
               _loc6_++;
            }
         }
         if(param3 != null)
         {
            param3(_loc8_,_loc5_);
         }
         return _loc8_;
      }
      
      public static function denEcoRefreshResponse(param1:Object) : void
      {
         if(_ecoRefreshCallback != null)
         {
            _ecoRefreshCallback(new EcoStateResponse(param1));
            _ecoRefreshCallback = null;
         }
      }
      
      public static function denEcoCreditRefreshResponse(param1:Object) : void
      {
         if(_ecoCreditRedeemCallback != null)
         {
            _ecoCreditRedeemCallback(param1[2] == "1",param1[3]);
            _ecoCreditRedeemCallback = null;
         }
      }
      
      public static function denEcoConsumerResponse(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 2;
         var _loc3_:int = int(param1[_loc5_++]);
         var _loc4_:int = int(param1[_loc5_++]);
         var _loc7_:int = int(param1[_loc5_++]);
         var _loc2_:Dictionary = new Dictionary();
         if(_loc7_ > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc7_)
            {
               _loc2_[int(param1[_loc5_++])] = param1[_loc5_++];
               _loc6_++;
            }
            _roomMgr.denItemHolder.updateConsumers(_loc2_);
         }
         if(_ecoConsumerCallback != null)
         {
            _ecoConsumerCallback(_loc3_,_loc4_,_loc2_);
            _ecoConsumerCallback = null;
         }
      }
      
      public static function generateDenShopList(param1:int, param2:Object) : IitemCollection
      {
         var _loc4_:int = 0;
         var _loc3_:DenItem = null;
         var _loc5_:IitemCollection = new IitemCollection();
         _loc4_ = 0;
         while(_loc4_ < param1)
         {
            _loc3_ = new DenItem();
            _loc3_.initShopItem(int(param2[_loc4_]),-1);
            _loc5_.pushIitem(_loc3_);
            _loc4_++;
         }
         return _loc5_;
      }
      
      public static function setDenItems() : void
      {
         if(_roomMgr)
         {
            if(_pendingDenChangeItems)
            {
               if(AvatarManager.playerAvatar != null)
               {
                  _roomMgr.denItemHolder.setItems(_pendingDenChangeItems);
                  _pendingDenChangeItems = null;
               }
               else
               {
                  AvatarManager.setDenItemsCallback = setDenItems;
               }
            }
         }
      }
      
      public static function denChangeDone() : void
      {
         _denChangePending = false;
         updateCatIdsForPendingFlooringAndWallpaper();
         setDenItems();
      }
      
      private static function updateCatIdsForPendingFlooringAndWallpaper() : void
      {
         var _loc2_:DenStateItem = null;
         var _loc1_:int = 0;
         if(!_pendingDenChangeItems || _pendingDenChangeItems.length <= 0)
         {
            return;
         }
         _loc1_ = 0;
         while(_loc1_ < _pendingDenChangeItems.length)
         {
            _loc2_ = _pendingDenChangeItems.getDenStateItem(_loc1_);
            if(_loc2_.sortCatId == 2 || _loc2_.sortCatId == 3)
            {
               _loc2_.catId = _roomMgr.denCatId;
               _loc2_.packedId = uint(_loc2_.defId << 16 | _loc2_.catId);
            }
            _loc1_++;
         }
      }
      
      public static function saveDenItemsState() : void
      {
         _roomMgr.denItemHolder.saveState();
      }
      
      public static function set denChangePending(param1:Boolean) : void
      {
         _denChangePending = param1;
      }
      
      public static function set recycleDiCallback(param1:Function) : void
      {
         _recycleDiCallback = param1;
      }
      
      public static function set denHighestCallback(param1:Function) : void
      {
         _denHighestCallback = param1;
      }
      
      public static function set denPrivateCallback(param1:Function) : void
      {
         _denPrivateCallback = param1;
      }
      
      private static function denItemDefsResponse(param1:DefPacksDefHelper) : void
      {
         _denItemDefs = new DenItemDefCollection();
         for each(var _loc2_ in param1.def)
         {
            _denItemDefs.setDenItemDefItem(int(_loc2_.id),new DenItemDef(_loc2_.abbrName,_loc2_.combinedCost,int(_loc2_.cost),int(_loc2_.currencyType),int(_loc2_.enviroType),int(_loc2_.flag),int(_loc2_.gameDefId),int(_loc2_.id),int(_loc2_.itemStatus),int(_loc2_.layer),int(_loc2_.mannequinAvatarDefId),int(_loc2_.mannequinCatId),int(_loc2_.mannequinCatId),int(_loc2_.membersOnly),int(_loc2_.nameStrId),int(_loc2_.parentArrayId),int(_loc2_.promoType),int(_loc2_.recycleValue),int(_loc2_.scalePercent),int(_loc2_.sortCat),int(_loc2_.specialType),int(_loc2_.typeCat),uint(_loc2_.availabilityStartTime),uint(_loc2_.availabilityEndTime),int(_loc2_.ecoPower)));
         }
         delete DefPacksDefHelper.mediaArray[1030];
         DefPacksDefHelper.mediaArray[1030] = null;
      }
      
      public static function relocalizeDenItems() : void
      {
         for each(var _loc1_ in _denItemDefs.getCoreArray())
         {
            _loc1_.name = LocalizationManager.translateIdOnly(_loc1_.nameStrId);
         }
      }
      
      public static function enviroItems(param1:DenItemCollection) : DenItemCollection
      {
         var _loc3_:DenItemCollection = new DenItemCollection();
         for each(var _loc2_ in param1.getCoreArray())
         {
            if(_loc2_.enviroType == AvatarManager.roomEnviroType || _loc2_.isLandAndOcean)
            {
               _loc3_.pushDenItem(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public static function denItemDefIdForPetDefId(param1:int) : int
      {
         switch(param1)
         {
            case 9:
               return 863;
            case 7:
               return 859;
            case 5:
               return 857;
            case 1:
               return 853;
            case 4:
               return 854;
            case 3:
               return 856;
            case 2:
               return 855;
            case 6:
               return 858;
            case 12:
               return 864;
            case 10:
               return 860;
            case 8:
               return 862;
            case 11:
               return 861;
            case 13:
               return 915;
            case 14:
               return 957;
            case 15:
               return 1089;
            case 16:
               return 1110;
            case 17:
               return 1138;
            case 18:
               return 1149;
            case 19:
               return 1171;
            case 20:
               return 1180;
            case 21:
               return 1206;
            case 22:
               return 1275;
            case 23:
               return 1331;
            case 24:
               return 1521;
            case 25:
               return 1567;
            case 26:
               return 1676;
            case 27:
               return 1662;
            case 28:
               return 1698;
            case 29:
               return 1780;
            case 30:
               return 1868;
            case 31:
               return 1867;
            case 32:
               return 1946;
            case 34:
               return 1995;
            case 35:
               return 2032;
            case 36:
               return 2292;
            case 37:
               return 2300;
            case 38:
               return 2301;
            case 39:
               return 2307;
            case 40:
               return 2350;
            case 42:
               return 2432;
            case 43:
               return 2463;
            case 44:
               return 2506;
            case 45:
               return 2513;
            case 46:
               return 2589;
            case 47:
               return 2588;
            case 48:
               return 2587;
            case 49:
               return 2591;
            case 50:
               return 2590;
            case 51:
               return 2592;
            case 52:
               return 2622;
            case 53:
               return 2656;
            case 54:
               return 2715;
            case 55:
               return 2775;
            case 56:
               return 2844;
            case 57:
               return 2861;
            case 58:
               return 2876;
            case 59:
               return 2877;
            case 60:
               return 2878;
            case 61:
               return 2884;
            case 62:
               return 2894;
            case 63:
               return 2977;
            case 41:
               return 2989;
            case 64:
               return 3039;
            case 67:
               return 3113;
            case 68:
               return 3117;
            case 69:
               return 3136;
            case 70:
               return 3137;
            case 71:
               return 3182;
            case 74:
               return 3205;
            case 75:
               return 3222;
            case 76:
               return 3241;
            case 65:
               return 3307;
            case 66:
               return 3306;
            case 77:
               return 3292;
            case 73:
               return 3321;
            case 72:
               return 2861;
            case 80:
               return 3362;
            case 81:
               return 3369;
            case 82:
               return 3367;
            case 83:
               return 3368;
            case 84:
               return 3377;
            case 85:
               return 3432;
            case 86:
               return 3448;
            case 87:
               return 3534;
            case 88:
               return 3546;
            case 89:
               return 3677;
            case 90:
               return 3738;
            case 91:
               return 3775;
            case 92:
               return 3815;
            case 93:
               return 3898;
            case 94:
               return 3899;
            case 95:
               return 3900;
            case 96:
               return 3928;
            case 97:
               return 3966;
            case 98:
               return 3994;
            case 99:
               return 4016;
            case 100:
               return 4096;
            case 101:
               return 4139;
            case 102:
               return 4147;
            case 103:
               return 4161;
            case 104:
               return 4173;
            case 105:
               return 4196;
            case 106:
               return 4227;
            case 107:
               return 4230;
            case 108:
               return 4272;
            case 109:
               return 4273;
            case 110:
               return 4374;
            case 111:
               return 4595;
            case 112:
               return 4758;
            default:
               return 853;
         }
      }
      
      public static function getDenItemDef(param1:int) : DenItemDef
      {
         return _denItemDefs.getDenItemDefItem(param1);
      }
   }
}

