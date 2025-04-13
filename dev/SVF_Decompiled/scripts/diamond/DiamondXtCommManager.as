package diamond
{
   import avatar.AvatarItem;
   import avatar.CustomAvatarDef;
   import collection.IitemCollection;
   import den.DenItem;
   import den.DenRoomItem;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import pet.PetItem;
   import pet.PetXtCommManager;
   
   public class DiamondXtCommManager
   {
      public static const DIAMOND_TYPE_ITEM:int = 0;
      
      public static const DIAMOND_TYPE_DEN_ITEM:int = 1;
      
      public static const DIAMOND_TYPE_PET:int = 2;
      
      public static const DIAMOND_TYPE_AVATAR:int = 3;
      
      public static const DIAMOND_TYPE_DEN:int = 4;
      
      public static var diamondDefsLoaded:Boolean;
      
      private static var _diamondDefs:Object = {};
      
      private static var _diamondRefDefs:Object = {};
      
      public function DiamondXtCommManager()
      {
         super();
      }
      
      public static function diamondResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc6_:DefPacksDefHelper = null;
         var _loc4_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1054] = null;
         var _loc5_:Object = {};
         _diamondRefDefs = {};
         for each(var _loc3_ in param1.def)
         {
            _loc2_ = {
               "defId":int(_loc3_.id),
               "value":int(_loc3_.cost),
               "refDefId":int(_loc3_.refId),
               "status":int(_loc3_.status),
               "type":int(_loc3_.type),
               "availabilityStartTime":uint(_loc3_.availabilityStartTime),
               "availabilityEndTime":uint(_loc3_.availabilityEndTime)
            };
            _loc5_[_loc2_.defId] = _loc2_;
            if(_diamondRefDefs[_loc2_.type])
            {
               _diamondRefDefs[_loc2_.type][_loc2_.refDefId] = _loc2_;
            }
            else
            {
               _diamondRefDefs[_loc2_.type] = {};
               _diamondRefDefs[_loc2_.type][_loc2_.refDefId] = _loc2_;
            }
         }
         _diamondDefs = _loc5_;
         diamondDefsLoaded = true;
         if(!gMainFrame.clientInfo.isCreateAccount)
         {
            _loc6_ = new DefPacksDefHelper();
            _loc6_.init(1046,PetXtCommManager.petDefsResponse,param1.passback,2);
            DefPacksDefHelper.mediaArray[1046] = _loc6_;
         }
         else if(param1.passback != null)
         {
            param1.passback();
         }
      }
      
      public static function getDiamondItem(param1:int) : DiamondItem
      {
         if(_diamondDefs[param1])
         {
            return new DiamondItem(param1);
         }
         return null;
      }
      
      public static function getDiamondDef(param1:int) : Object
      {
         return _diamondDefs[param1];
      }
      
      public static function getDiamondDefByRefId(param1:int, param2:int) : Object
      {
         return getDiamondDef(getDiamondDefIdByRefId(param1,param2));
      }
      
      public static function getDiamondDefIdByRefId(param1:int, param2:int) : int
      {
         var _loc4_:Object = null;
         var _loc3_:Object = _diamondRefDefs[param2];
         if(_loc3_)
         {
            _loc4_ = _loc3_[param1];
            if(_loc4_)
            {
               return _loc4_.defId;
            }
         }
         return -1;
      }
      
      public static function generateDiamondShopList(param1:int, param2:Array, param3:Array) : IitemCollection
      {
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc9_:Iitem = null;
         var _loc4_:DiamondItem = null;
         var _loc5_:CustomAvatarDef = null;
         var _loc11_:Object = null;
         var _loc10_:IitemCollection = new IitemCollection();
         _loc7_ = 0;
         while(_loc7_ < param1)
         {
            _loc4_ = getDiamondItem(int(param2[_loc7_]));
            if(_loc4_.isAccessory)
            {
               _loc6_ = ItemXtCommManager.getItemDef(_loc4_.refDefId);
               _loc9_ = new Item();
               (_loc9_ as Item).init(_loc6_.defId,_loc7_,_loc6_.colors[0],null,true);
               param3[_loc6_.defId] = _loc6_.colors.concat();
            }
            else if(_loc4_.isAvatar || _loc4_.isAvatarCustom)
            {
               _loc5_ = null;
               if(_loc4_.isAvatarCustom)
               {
                  _loc5_ = gMainFrame.userInfo.getCustomAvatarDefByAvType(_loc4_.refDefId);
               }
               _loc9_ = new AvatarItem();
               (_loc9_ as AvatarItem).init(!!_loc5_ ? _loc5_.avatarRefId : _loc4_.refDefId,_loc7_,true,!!_loc5_ ? _loc5_.defId : -1,_loc4_);
            }
            else if(_loc4_.isPet)
            {
               _loc9_ = new PetItem();
               (_loc9_ as PetItem).init(0,_loc4_.refDefId,null,0,0,0,_loc7_,null,true,null,_loc4_);
            }
            else if(_loc4_.isDenItem)
            {
               _loc9_ = new DenItem();
               (_loc9_ as DenItem).initShopItem(_loc4_.refDefId,-1);
            }
            else if(_loc4_.isDen)
            {
               _loc9_ = new DenRoomItem();
               _loc11_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc4_.refDefId);
               (_loc9_ as DenRoomItem).initShopItem(0,_loc11_.defId,_loc11_);
            }
            _loc10_.pushIitem(_loc9_);
            _loc7_++;
         }
         return _loc10_;
      }
   }
}

