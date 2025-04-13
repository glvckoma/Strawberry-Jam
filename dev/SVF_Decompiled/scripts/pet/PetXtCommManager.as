package pet
{
   import com.sbi.client.SFEvent;
   import diamond.DiamondItem;
   import diamond.DiamondXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   
   public class PetXtCommManager
   {
      public static var canLoadPetList:Boolean;
      
      private static var _plCallback:Function;
      
      private static var _pdCallback:Function;
      
      private static var _psCallback:Function;
      
      private static var _pcCallback:Function;
      
      private static var _piCallback:Function;
      
      private static var _pmCallback:Function;
      
      private static var _pnCallback:Function;
      
      public function PetXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
      }
      
      public static function destroy() : void
      {
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "pl":
               onPetListResponse(_loc2_);
               break;
            case "pc":
               onPetCreateResponse(_loc2_);
               break;
            case "ps":
               onPetSwitchResponse(_loc2_);
               break;
            case "pi":
               onPetItemsResponse(_loc2_);
               break;
            case "pm":
               onPetMasteryResponse(_loc2_);
               break;
            case "pd":
               onPetDismissResponse(_loc2_);
               break;
            case "pu":
               onPetUnlockResponse(_loc2_);
               break;
            case "pn":
               onPetEggNameResponse(_loc2_);
         }
      }
      
      public static function set petCreateCallback(param1:Function) : void
      {
         _pcCallback = param1;
      }
      
      public static function sendPetListRequest(param1:String, param2:Function = null) : void
      {
         _plCallback = param2;
         gMainFrame.server.setXtObject_Str("pl",[param1]);
      }
      
      public static function sendPetCreateRequest(param1:int, param2:int, param3:int, param4:uint, param5:int, param6:int, param7:Function = null, param8:Boolean = false) : void
      {
         _pcCallback = param7;
         gMainFrame.server.setXtObject_Str("pc",[param1,param2,param3,param4,param5,param6,param8 ? "1" : "0"]);
      }
      
      public static function sendPetShopBuyRequest(param1:int, param2:int, param3:int, param4:int, param5:uint, param6:int, param7:int, param8:Function = null, param9:Boolean = false) : void
      {
         _pcCallback = param8;
         gMainFrame.server.setXtObject_Str("pb",[param1,param2,param3,param4,param5,param6,param7,param9 ? "1" : "0"]);
      }
      
      public static function sendPetDismissRequest(param1:int, param2:Function = null) : void
      {
         _pdCallback = param2;
         gMainFrame.server.setXtObject_Str("pd",[param1]);
      }
      
      public static function sendPetSwitchRequest(param1:int, param2:Function = null) : void
      {
         _psCallback = param2;
         gMainFrame.server.setXtObject_Str("ps",[param1]);
      }
      
      public static function sendPetItemRequest(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         _piCallback = param5;
         gMainFrame.server.setXtObject_Str("pi",[param1,param2,param3,param4]);
      }
      
      public static function sendPetMasteryRequest(param1:int, param2:int, param3:Function = null) : void
      {
         _pmCallback = param3;
         gMainFrame.server.setXtObject_Str("pm",[param1,param2]);
      }
      
      public static function sendPetEggNameRequest(param1:int, param2:int, param3:int, param4:Function) : void
      {
         _pnCallback = param4;
         gMainFrame.server.setXtObject_Str("pn",[param1,param2,param3]);
      }
      
      public static function petDefsResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Vector.<PetDef> = new Vector.<PetDef>();
         for each(var _loc2_ in param1.def)
         {
            VectorUtility.safeAdd(_loc5_,int(_loc2_.id),new PetDef(int(_loc2_.id),int(_loc2_.mediaRefId),int(_loc2_.type),PetManager.isGround(_loc2_.type),LocalizationManager.translateIdOnly(int(_loc2_.titleStrId)),int(_loc2_.titleStrId),_loc2_.isMember == "1",int(_loc2_.cost),int(_loc2_.status),DiamondXtCommManager.getDiamondDefIdByRefId(_loc2_.id,2),int(_loc2_.toyListId),int(_loc2_.foodListId),_loc2_.isReward == "1",false,_loc2_.isEgg == "1",uint(_loc2_.availabilityStartTime),uint(_loc2_.availabilityEndTime)));
         }
         DefPacksDefHelper.mediaArray[1046] = null;
         var _loc3_:Array = PetManager.myPetList;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].type == -1)
            {
               _loc3_[_loc4_].type = PetManager.petTypeForDefId(_loc3_[_loc4_].defId);
            }
            _loc4_++;
         }
         GenericListXtCommManager.requestGenericList(214,onDiamondPetListLoaded,{
            "petDefs":_loc5_,
            "callback":param1.passback
         });
      }
      
      private static function onDiamondPetListLoaded(param1:int, param2:Array, param3:Object) : void
      {
         var _loc6_:int = 0;
         var _loc4_:DiamondItem = null;
         var _loc8_:Vector.<PetDef> = param3.petDefs;
         var _loc5_:Function = param3.callback;
         var _loc7_:int = 8;
         var _loc9_:int = int(param2[_loc7_++]);
         _loc6_ = 0;
         while(_loc6_ < _loc9_)
         {
            _loc4_ = DiamondXtCommManager.getDiamondItem(int(param2[_loc7_++]));
            if(_loc4_.isPet && _loc8_.length > _loc4_.refDefId)
            {
               _loc8_[_loc4_.refDefId].isInDiamondStore = true;
            }
            _loc6_++;
         }
         PetManager.petDefs = _loc8_;
         canLoadPetList = true;
         sendPetListRequest(gMainFrame.server.userName);
         if(_loc5_ != null)
         {
            _loc5_();
            _loc5_ = null;
         }
      }
      
      private static function onPetListResponse(param1:Array) : void
      {
         PetManager.onPetListResponse(param1,_plCallback);
         _plCallback = null;
      }
      
      private static function onPetCreateResponse(param1:Array) : void
      {
         PetManager.onPetCreateResponse(param1,_pcCallback);
         _pcCallback = null;
      }
      
      private static function onPetItemsResponse(param1:Array) : void
      {
         PetManager.onPetItemsResponse(param1,_piCallback);
         _piCallback = null;
      }
      
      private static function onPetMasteryResponse(param1:Array) : void
      {
         PetManager.onPetMasteryResponse(param1,_pmCallback);
         _pmCallback = null;
      }
      
      private static function onPetDismissResponse(param1:Array) : void
      {
         PetManager.onPetDismissResponse(param1,_pdCallback);
         _pdCallback = null;
      }
      
      private static function onPetUnlockResponse(param1:Array) : void
      {
         PetManager.unlockedPets = param1[2];
      }
      
      private static function onPetSwitchResponse(param1:Array) : void
      {
         PetManager.onPetSwitchResponse(param1,_psCallback);
         _psCallback = null;
      }
      
      private static function onPetEggNameResponse(param1:Array) : void
      {
         PetManager.onPetEggNameResponse(param1,_pnCallback);
         _pnCallback = null;
      }
   }
}

