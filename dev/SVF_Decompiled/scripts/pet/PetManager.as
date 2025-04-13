package pet
{
   import Party.PartyManager;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import collection.PetItemCollection;
   import com.sbi.bit.ScalableBitField;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.PetCreator;
   import gui.PetMastery;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class PetManager
   {
      public static const TYPE_LAND_LOW:int = 0;
      
      public static const TYPE_LAND_HIGH:int = 1;
      
      public static const TYPE_OCEAN_LOW:int = 2;
      
      public static const TYPE_OCEAN_HIGH:int = 3;
      
      public static const TYPE_AMPHIB_LOW:int = 4;
      
      public static const TYPE_AMPHIB_HIGH:int = 5;
      
      public static const LIMITED_TIME:int = 1;
      
      public static const MASTERY_ACHIV_MIN_COUNT:int = 100;
      
      private static const EVT_ICON_ID:int = 44;
      
      private static var _petDefs:Vector.<PetDef>;
      
      private static var _myPetList:Array;
      
      private static var _myActivePetInvId:int;
      
      private static var _petFinder:PetCreator;
      
      private static var _petMasteryMgr:PetMastery;
      
      private static var _petFinderCallback:Function;
      
      private static var _unlockedPets:ScalableBitField;
      
      public function PetManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _myPetList = [];
      }
      
      public static function set petDefs(param1:Vector.<PetDef>) : void
      {
         _petDefs = param1;
      }
      
      public static function relocalizePetDefs() : void
      {
         for each(var _loc1_ in _petDefs)
         {
            if(_loc1_)
            {
               _loc1_.title = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
            }
         }
      }
      
      public static function openPetFinder(param1:String = "", param2:Function = null, param3:Boolean = false, param4:Array = null, param5:Iitem = null, param6:int = 0, param7:int = 0, param8:Boolean = false) : void
      {
         if(_petFinder)
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         _petFinder = new PetCreator();
         _petFinderCallback = param2;
         if(param1 == "")
         {
            _petFinder.init(-1,onPetFinderClose,false,null,param6,null,param7);
         }
         else
         {
            _petFinder.init(petDefIdForName(param1),onPetFinderClose,param3,param4,param6,param5,param7,param8);
         }
      }
      
      private static function onPetFinderClose(param1:Boolean) : void
      {
         var _loc2_:Function = null;
         if(_petFinder)
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         if(_petFinderCallback != null)
         {
            _loc2_ = _petFinderCallback;
            _petFinderCallback = null;
            if(_loc2_.length == 1)
            {
               _loc2_(param1);
            }
            else
            {
               _loc2_();
            }
         }
      }
      
      public static function checkAndOpenMasteryPopup(param1:Boolean) : void
      {
         if(myActivePet && myActivePet.masteryCounter >= 100 && param1)
         {
            if(!_petMasteryMgr)
            {
               _petMasteryMgr = new PetMastery();
               _petMasteryMgr.init();
            }
            _petMasteryMgr.displayMasteryPopup();
         }
      }
      
      public static function hasAtLeastOneHatchedEggPet() : Boolean
      {
         var _loc1_:PetDef = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _myPetList.length)
         {
            _loc1_ = getPetDef(_myPetList[_loc2_].defId);
            if(_loc1_)
            {
               if(_loc1_.isEgg && hasHatched(_myPetList[_loc2_].createdTs) && _myPetList[_loc2_].name == "")
               {
                  return true;
               }
            }
            _loc2_++;
         }
         return false;
      }
      
      public static function showPetHatchedPopups() : void
      {
         var _loc2_:PetDef = null;
         var _loc3_:int = 0;
         var _loc1_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < _myPetList.length)
         {
            _loc2_ = getPetDef(_myPetList[_loc3_].defId);
            if(_loc2_)
            {
               if(_loc2_.isEgg && hasHatched(_myPetList[_loc3_].createdTs) && _myPetList[_loc3_].name == "")
               {
                  _loc1_.push(_loc3_);
               }
            }
            _loc3_++;
         }
         if(_loc1_.length > 0)
         {
            EggPetGuiManager.openEggHatchedPopup(_loc1_);
         }
      }
      
      public static function onPetListResponse(param1:Array, param2:Function) : void
      {
         var _loc9_:Array = null;
         var _loc7_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 2;
         var _loc10_:String = param1[_loc6_++];
         if(_loc10_ == "1")
         {
            _loc7_ = param1[_loc6_++];
            _loc3_ = int(param1[_loc6_++]);
            _loc9_ = [];
            _loc8_ = -1;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc4_ = {
                  "idx":int(param1[_loc6_++]),
                  "createdTs":Number(param1[_loc6_++]),
                  "name":param1[_loc6_++],
                  "lBits":uint(param1[_loc6_++]),
                  "uBits":uint(param1[_loc6_++]),
                  "eBits":uint(param1[_loc6_++]),
                  "masteryCounter":uint(param1[_loc6_++]),
                  "isSparkling":false,
                  "personalityDefId":uint(param1[_loc6_++]),
                  "favoriteToyDefId":uint(param1[_loc6_++]),
                  "favoriteFoodDefId":uint(param1[_loc6_++]),
                  "denStoreInvId":int(param1[_loc6_++])
               };
               _loc4_.defId = getDefIdFromLBits(_loc4_.lBits);
               _loc4_.type = petTypeForDefId(_loc4_.defId);
               _loc4_.currPetDef = PetManager.getPetDef(_loc4_.lBits & 0xFF);
               _loc4_.isGround = _loc4_.currPetDef.isGround;
               _loc9_.push(_loc4_);
               _loc5_++;
            }
            _loc9_.sortOn("idx",16);
            if(_loc7_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _myPetList = _loc9_;
            }
         }
         if(param2 != null)
         {
            param2(_loc9_,_loc10_);
         }
      }
      
      public static function isGround(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 2 || param1 == 4;
      }
      
      public static function onPetCreateResponse(param1:Array, param2:Function) : void
      {
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:* = undefined;
         var _loc17_:int = 0;
         var _loc4_:* = 0;
         var _loc10_:* = 0;
         var _loc5_:* = 0;
         var _loc13_:String = null;
         var _loc11_:Number = NaN;
         var _loc15_:* = 0;
         var _loc6_:* = 0;
         var _loc12_:* = 0;
         var _loc16_:* = false;
         var _loc14_:int = 0;
         var _loc9_:int = 2;
         if(param1[_loc9_++] == "1")
         {
            _loc7_ = int(param1[_loc9_++]);
            _loc3_ = int(param1[_loc9_++]);
            _loc8_ = UserCurrency.getCurrency(_loc3_);
            if(_loc8_ == null)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc3_);
            }
            UserCurrency.setCurrency(_loc7_,_loc3_);
            if(_loc8_ != _loc7_)
            {
               AJAudio.playShopCachingSound();
            }
            _loc17_ = int(param1[_loc9_++]);
            _loc4_ = uint(param1[_loc9_++]);
            _loc10_ = uint(param1[_loc9_++]);
            _loc5_ = uint(param1[_loc9_++]);
            _loc13_ = param1[_loc9_++];
            _loc11_ = Number(param1[_loc9_++]);
            _loc15_ = uint(param1[_loc9_++]);
            _loc6_ = uint(param1[_loc9_++]);
            _loc12_ = uint(param1[_loc9_++]);
            _loc16_ = param1[_loc9_++] == "1";
            _loc14_ = getDefIdFromLBits(_loc4_);
            if(insertPet(_loc14_,_loc11_,_loc4_,_loc10_,_loc5_,_loc13_,_loc17_,_loc15_,_loc6_,_loc12_,_loc16_))
            {
               if(param2 != null)
               {
                  param2(true);
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14809));
            if(param2 != null)
            {
               param2(false);
            }
         }
      }
      
      public static function insertPet(param1:int, param2:Number, param3:int, param4:int, param5:int, param6:String, param7:int, param8:int, param9:int, param10:int, param11:Boolean, param12:int = 0) : Boolean
      {
         var _loc14_:PetItem = null;
         var _loc13_:PetDef = getPetDef(param1);
         if(_loc13_)
         {
            _loc14_ = new PetItem();
            _loc14_.init(param2,param1,[param3,param4,param5],param8,param9,param10,param7,param6);
            return insertPetItem(_loc14_,param11,param12);
         }
         return false;
      }
      
      public static function insertPetItem(param1:PetItem, param2:Boolean, param3:int) : Boolean
      {
         var _loc4_:Array = null;
         var _loc6_:Object = null;
         var _loc5_:PetDef = param1.currPetDef;
         if(_loc5_)
         {
            _loc4_ = param1.petBits;
            _loc6_ = {
               "idx":param1.invIdx,
               "name":param1.name,
               "defId":param1.defId,
               "type":_loc5_.type,
               "lBits":_loc4_[0],
               "uBits":_loc4_[1],
               "eBits":_loc4_[2],
               "isSparkling":false,
               "personalityDefId":param1.traitDefId,
               "favoriteToyDefId":param1.toyDefId,
               "favoriteFoodDefId":param1.foodDefId,
               "createdTs":param1.createdTs,
               "denStoreInvId":0,
               "masteryCounter":param3
            };
            _loc6_.masteryCounter = param3;
            _loc6_.currPetDef = _loc5_;
            _myPetList.push(_loc6_);
            DenXtCommManager.addPetToDen(param1);
            if(param2)
            {
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc5_,param1.createdTs))
               {
                  if(!_loc5_.isMember || Boolean(gMainFrame.userInfo.isMember))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(param1.createdTs,_loc4_[0],_loc4_[1],_loc4_[2],param1.name,param1.traitDefId,param1.toyDefId,param1.foodDefId);
                     myActivePetInvId = param1.invIdx;
                  }
               }
               AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
            }
            return true;
         }
         return false;
      }
      
      public static function onPetSwitchResponse(param1:Array, param2:Function) : void
      {
         var _loc3_:AvatarWorldView = null;
         var _loc19_:int = 0;
         var _loc11_:Boolean = false;
         var _loc16_:* = null;
         var _loc20_:UserInfo = null;
         var _loc12_:Object = null;
         var _loc4_:int = 0;
         var _loc13_:int = 0;
         var _loc6_:int = 0;
         var _loc17_:String = null;
         var _loc14_:Number = NaN;
         var _loc18_:* = 0;
         var _loc15_:* = 0;
         var _loc7_:* = 0;
         var _loc8_:Object = null;
         var _loc9_:AvatarInfo = null;
         var _loc10_:int = 2;
         var _loc21_:* = param1[_loc10_++] == "1";
         if(_loc21_)
         {
            _loc19_ = int(param1[_loc10_++]);
            _loc3_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc19_);
            if(_loc19_ == gMainFrame.server.userId)
            {
               myActivePetInvId = int(param1[_loc10_++]);
               if(_loc3_)
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(_loc16_ in _myPetList)
                     {
                        if(_loc16_.idx == myActivePetInvId)
                        {
                           _loc3_.setActivePet(_loc16_.createdTs,_loc16_.lBits,_loc16_.uBits,_loc16_.eBits,_loc16_.name,_loc16_.personalityDefId,_loc16_.favoriteFoodDefId,_loc16_.favoriteToyDefId);
                           _loc11_ = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     _loc3_.setActivePet(0,0,0,0,"",0,0,0);
                  }
                  _loc20_ = gMainFrame.userInfo.getUserInfoByUserName(_loc3_.userName);
                  for each(var _loc5_ in _loc20_.avList)
                  {
                     if(_loc5_.perUserAvId == _loc3_.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == 0)
                        {
                           _loc5_.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           _loc5_.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(_loc3_.userName,_loc20_);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  _loc12_ = myActivePet;
                  if(_loc12_)
                  {
                     _loc3_.setActivePet(_loc12_.createdTs,_loc12_.lBits,_loc12_.uBits,_loc12_.eBits,_loc12_.name,_loc12_.personalityDefId,_loc12_.favoriteFoodDefId,_loc12_.favoriteToyDefId);
                     _loc12_.isSparkling = false;
                  }
               }
            }
            else
            {
               _loc4_ = int(param1[_loc10_++]);
               _loc13_ = int(param1[_loc10_++]);
               _loc6_ = int(param1[_loc10_++]);
               _loc17_ = param1[_loc10_++];
               _loc14_ = Number(param1[_loc10_++]);
               _loc18_ = uint(param1[_loc10_++]);
               _loc15_ = uint(param1[_loc10_++]);
               _loc7_ = uint(param1[_loc10_++]);
               if(_loc3_)
               {
                  _loc3_.setActivePet(_loc14_,_loc4_,_loc13_,_loc13_,_loc17_,_loc18_,_loc15_,_loc7_);
               }
               _loc8_ = null;
               if(_loc4_ != 0)
               {
                  _loc8_ = {
                     "name":_loc17_,
                     "lBits":_loc4_,
                     "uBits":_loc13_,
                     "eBits":_loc6_,
                     "createdTs":_loc14_,
                     "personalityDefId":_loc18_,
                     "favoriteFoodDefId":_loc15_,
                     "favoriteToyDefId":_loc7_
                  };
                  _loc8_.defId = PetManager.getDefIdFromLBits(_loc8_.lBits);
                  _loc8_.type = PetManager.petTypeForDefId(_loc8_.defId);
                  _loc8_.isGround = PetManager.isGround(_loc8_.type);
               }
               _loc9_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc3_.userName);
               if(_loc9_)
               {
                  _loc9_.currPet = _loc8_;
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14810));
         }
         if(param2 != null)
         {
            param2(_loc21_);
         }
      }
      
      public static function onPetItemsResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:Object = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 2;
         var _loc10_:* = param1[_loc8_++] == "1";
         if(_loc10_)
         {
            UserCurrency.setCurrency(int(param1[_loc8_++]),0);
            AJAudio.playShopCachingSound();
            _loc5_ = myActivePet;
            if(_loc5_ == null)
            {
               trace("ERROR: myActivePet is null");
               return;
            }
            _loc7_ = int(param1[_loc8_++]);
            if(myActivePet.idx != _loc7_)
            {
               trace("ERROR: Invalid pet invId");
               return;
            }
            _loc4_ = int(param1[_loc8_++]);
            _loc9_ = int(param1[_loc8_++]);
            _loc6_ = int(param1[_loc8_++]);
            _loc5_.lBits = _loc4_;
            _loc5_.uBits = _loc9_;
            _loc5_.eBits = _loc6_;
            AvatarManager.playerAvatarWorldView.setActivePet(_loc5_.createdTs,_loc4_,_loc9_,_loc6_,myActivePetName,_loc5_.personalityDefId,_loc5_.favoriteFoodDefId,_loc5_.favoriteToyDefId);
            myActivePetInvId = _loc7_;
            _loc3_ = getDefIdFromLBits(_loc4_);
            DenXtCommManager.reloadPetInDen(_loc7_,_loc5_.createdTs,petTypeForDefId(_loc3_),_loc5_.name,_loc4_,_loc9_,_loc6_,_loc5_.personalityDefId,_loc5_.favoriteFoodDefId,_loc5_.favoriteToyDefId);
         }
         if(param2 != null)
         {
            param2(_loc10_);
         }
      }
      
      public static function onPetMasteryResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 2;
         var _loc9_:* = param1[_loc7_++] == "1";
         if(_loc9_)
         {
            _loc5_ = int(param1[_loc7_++]);
            _loc6_ = 0;
            while(_loc6_ < _myPetList.length)
            {
               if(_myPetList[_loc6_].idx == _loc5_)
               {
                  _loc3_ = int(param1[_loc7_++]);
                  _loc8_ = int(param1[_loc7_++]);
                  _loc4_ = int(param1[_loc7_++]);
                  _myPetList[_loc6_].lBits = _loc3_;
                  _myPetList[_loc6_].uBits = _loc8_;
                  _myPetList[_loc6_].eBits = _loc4_;
                  DenXtCommManager.reloadPetInDen(_loc5_,_myPetList[_loc6_].createdTs,_myPetList[_loc6_].type,_myPetList[_loc6_].name,_loc3_,_loc8_,_loc4_,_myPetList[_loc6_].personalityDefId,_myPetList[_loc6_].favoriteFoodDefId,_myPetList[_loc6_].favoriteToyDefId);
                  break;
               }
               _loc6_++;
            }
         }
         DarkenManager.showLoadingSpiral(false);
         if(param2 != null)
         {
            param2(_loc9_);
         }
      }
      
      public static function onPetDismissResponse(param1:Array, param2:Function) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc7_:Object = null;
         var _loc6_:* = param1[2] == "1";
         var _loc5_:int = int(param1[3]);
         if(_loc6_)
         {
            _loc7_ = removePetInvIdx([_loc5_]);
            _loc3_ = Boolean(_loc7_.isFound);
            _loc4_ = Boolean(_loc7_.wasActivePet);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
         }
         if(param2 != null)
         {
            param2(_loc6_,_loc3_,_loc4_);
         }
      }
      
      public static function onPetEggNameResponse(param1:Array, param2:Function) : void
      {
         var _loc6_:int = 0;
         var _loc4_:* = param1[2] == "1";
         var _loc5_:int = int(param1[3]);
         var _loc3_:String = param1[4];
         _loc6_ = 0;
         while(_loc6_ < _myPetList.length)
         {
            if(_myPetList[_loc6_].idx == _loc5_)
            {
               _myPetList[_loc6_].name = _loc3_;
               if(myActivePetInvId == _loc5_)
               {
                  AvatarManager.playerAvatarWorldView.setActivePet(_myPetList[_loc6_].createdTs,_myPetList[_loc6_].lBits,_myPetList[_loc6_].uBits,_myPetList[_loc6_].eBits,_loc3_,_myPetList[_loc6_].personalityDefId,_myPetList[_loc6_].favoriteFoodDefId,_myPetList[_loc6_].favoriteToyDefId);
               }
               DenXtCommManager.reloadPetInDen(_loc5_,_myPetList[_loc6_].createdTs,_myPetList[_loc6_].type,_myPetList[_loc6_].name,_myPetList[_loc6_].lBits,_myPetList[_loc6_].uBits,_myPetList[_loc6_].eBits,_myPetList[_loc6_].personalityDefId,_myPetList[_loc6_].favoriteFoodDefId,_myPetList[_loc6_].favoriteToyDefId);
               break;
            }
            _loc6_++;
         }
         if(param2 != null)
         {
            param2(_loc4_);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      public static function removePetInvIdx(param1:Array) : Object
      {
         var _loc2_:Boolean = false;
         var _loc6_:Boolean = false;
         var _loc3_:PetItem = null;
         var _loc7_:Object = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _myPetList.length)
            {
               if(_myPetList[_loc4_].idx == param1[_loc5_])
               {
                  _loc7_ = _myPetList[_loc4_];
                  if(_myActivePetInvId == _loc7_.idx)
                  {
                     _myActivePetInvId = 0;
                     if(AvatarManager.playerAvatarWorldView)
                     {
                        AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,0,"",0,0,0);
                     }
                     _loc6_ = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  }
                  _loc3_ = new PetItem();
                  _loc3_.init(_loc7_.createdTs,_loc7_.defId,[_loc7_.lBits,_loc7_.uBits,_loc7_.eBits],_loc7_.personalityDefId,_loc7_.favoriteToyDefId,_loc7_.favoriteFoodDefId,_loc7_.idx,_loc7_.name,false,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc7_.defId,2)));
                  DenXtCommManager.removePetFromDen(param1[_loc5_],_loc3_);
                  _myPetList.splice(_loc4_,1);
                  _loc2_ = true;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         return {
            "wasActivePet":_loc6_,
            "isFound":_loc2_
         };
      }
      
      public static function getPetSprite(param1:Number, param2:uint, param3:uint, param4:uint, param5:int, param6:Function = null) : Sprite
      {
         return Sprite(new PetBase(param1,param2,param3,param4,0,0,0,param6));
      }
      
      public static function getGuiPet(param1:Number, param2:int, param3:uint, param4:uint, param5:uint, param6:int, param7:String, param8:int, param9:int, param10:int, param11:Function = null) : GuiPet
      {
         return new GuiPet(param1,param2,param3,param4,param5,param6,param7,param8,param10,param9,param11);
      }
      
      public static function get myPetList() : Array
      {
         return _myPetList;
      }
      
      public static function get myPetListAsIitem() : PetItemCollection
      {
         var _loc1_:PetItem = null;
         var _loc2_:PetItemCollection = new PetItemCollection();
         for each(var _loc3_ in _myPetList)
         {
            _loc1_ = new PetItem();
            _loc1_.init(_loc3_.createdTs,_loc3_.defId,[_loc3_.lBits,_loc3_.uBits,_loc3_.eBits],_loc3_.personalityDefId,_loc3_.favoriteToyDefId,_loc3_.favoriteFoodDefId,_loc3_.idx,_loc3_.name,false,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc3_.defId,2)),_loc3_.denStoreInvId);
            _loc2_.pushPetItem(_loc1_);
         }
         return _loc2_;
      }
      
      public static function get myActivePetName() : String
      {
         var _loc1_:Object = getMyPetByInvId(_myActivePetInvId);
         if(_loc1_)
         {
            return _loc1_.name;
         }
         return "";
      }
      
      public static function set myActivePetInvId(param1:int) : void
      {
         _myActivePetInvId = param1;
      }
      
      public static function addToActivePetMastery(param1:int) : void
      {
         myActivePet.masteryCounter += param1;
      }
      
      public static function get myActivePetInvId() : int
      {
         return _myActivePetInvId;
      }
      
      public static function getMyPetByInvId(param1:int) : Object
      {
         var _loc2_:* = null;
         for each(_loc2_ in _myPetList)
         {
            if(_loc2_.idx == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function get myActivePet() : Object
      {
         var _loc1_:* = null;
         for each(_loc1_ in _myPetList)
         {
            if(_loc1_.idx == _myActivePetInvId)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public static function petTypeForDefId(param1:int) : int
      {
         if(_petDefs && _petDefs[param1])
         {
            return _petDefs[param1].type;
         }
         return -1;
      }
      
      public static function getPetDef(param1:int) : PetDef
      {
         if(_petDefs)
         {
            return _petDefs[param1];
         }
         return null;
      }
      
      public static function petForPetDefId(param1:int) : Object
      {
         var _loc2_:* = null;
         for each(_loc2_ in _myPetList)
         {
            if(_loc2_.defId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getEnviroTypeByPetType(param1:PetDef, param2:Number, param3:int = 0) : int
      {
         if(param1.isEgg && !hasHatched(param2))
         {
            return 0;
         }
         if(param1.type == 0)
         {
            return 0;
         }
         if(param1.type == 1)
         {
            return Utility.isAir(param3) ? 2 : 0;
         }
         if(param1.type == 3 || param1.type == 2)
         {
            return 1;
         }
         if(param1.type == 4 || param1.type == 5)
         {
            return AvatarManager.roomEnviroType;
         }
         return -1;
      }
      
      public static function setPetState(param1:MovieClip, param2:uint, param3:uint, param4:uint) : void
      {
         var _loc5_:* = param2 & 0xFF;
         DebugUtility.debugErrorTracking("setPetState with petMC=" + param1 + "lBits=" + param2 + "uBits=" + param3 + "eBits=" + param4 + "AvatarManager.roomEnviroType=" + AvatarManager.roomEnviroType);
         if(PetManager.petTypeForDefId(_loc5_) == 4)
         {
            param1.pet.setState(param2,param3,param4,AvatarManager.roomEnviroType);
         }
         else
         {
            param1.pet.setState(param2,param3);
         }
         DebugUtility.clearDebugErrorTracking();
      }
      
      public static function petDefIdForName(param1:String) : int
      {
         switch(param1)
         {
            case "frog":
               return 2;
            case "kitten":
               return 1;
            case "puppy":
               return 4;
            case "ducky":
               return 3;
            case "butterfly":
               return 5;
            case "hamster":
               return 6;
            case "bat":
               return 7;
            case "seahorse":
               return 8;
            case "anglerfish":
               return 9;
            case "reindeer":
               return 10;
            case "snake":
               return 11;
            case "jellyfish":
               return 12;
            case "bunny":
               return 13;
            case "hummingbird":
               return 14;
            case "turtle":
               return 15;
            case "monkey":
               return 16;
            case "tarantula":
               return 17;
            case "fox":
               return 18;
            case "owl":
               return 19;
            case "tiger":
               return 20;
            case "arcticwolfpup":
               return 21;
            case "raccoon":
               return 22;
            case "joey":
               return 23;
            case "eaglet":
               return 24;
            case "cheetah":
               return 25;
            case "rhino":
               return 26;
            case "giraffe":
               return 27;
            case "sugarglider":
               return 28;
            case "lionCub":
               return 29;
            case "panda":
               return 30;
            case "polarbearcub":
               return 31;
            case "gecko":
               return 32;
            case "pony":
               return 34;
            case "piglet":
               return 35;
            case "ferret":
               return 36;
            case "elephant":
               return 37;
            case "armadillo":
               return 38;
            case "peacock":
               return 39;
            case "bee":
               return 40;
            case "skunk":
               return 42;
            case "turkey":
               return 43;
            case "penguin":
               return 44;
            case "snowLeopard":
               return 45;
            case "mantis":
               return 46;
            case "ladybug":
               return 47;
            case "cricket":
               return 48;
            case "squirrel":
               return 49;
            case "mouse":
               return 50;
            case "firefly":
               return 51;
            case "lemur":
               return 52;
            case "hippo":
               return 53;
            case "goat":
               return 54;
            case "meerkat":
               return 55;
            case "goldenbunny":
               return 56;
            case "phantom":
               return 57;
            case "seal":
               return 58;
            case "otter":
               return 59;
            case "rarephantom":
               return 60;
            case "groundhog":
               return 61;
            case "llama":
               return 62;
            case "arcticfox":
               return 63;
            case "rooster":
               return 41;
            case "hyena":
               return 64;
            case "chick":
               return 67;
            case "goldenarmadillo":
               return 68;
            case "falcon":
               return 69;
            case "crocodile":
               return 70;
            case "platypus":
               return 71;
            case "shark":
               return 74;
            case "dolphin":
               return 75;
            case "echidna":
               return 76;
            case "sloth":
               return 65;
            case "dove":
               return 66;
            case "koala":
               return 77;
            case "goldenpony":
               return 73;
            case "phantomJW":
               return 72;
            case "lynx":
               return 80;
            case "octopus":
               return 81;
            case "fennecfoxjw":
               return 82;
            case "hedgehog":
               return 83;
            case "scorpion":
               return 84;
            case "crow":
               return 85;
            case "moose":
               return 86;
            case "poodle":
               return 87;
            case "lovebunny":
               return 88;
            case "sabertooth":
               return 89;
            case "direwolf":
               return 90;
            case "dodo":
               return 91;
            case "fantasypeacock":
               return 92;
            case "millipede":
               return 93;
            case "moth":
               return 94;
            case "vulture":
               return 95;
            case "coyote":
               return 96;
            case "meagynsbear":
               return 97;
            case "falcon2":
               return 98;
            case "lovebug":
               return 99;
            case "flyingpig":
               return 100;
            case "sparrow":
               return 101;
            case "fennecfox":
               return 102;
            case "cardinal":
               return 103;
            case "frilledlizard":
               return 104;
            case "dragonfly":
               return 105;
            case "magentaseal":
               return 106;
            case "pangolin":
               return 107;
            case "camel":
               return 108;
            case "snail":
               return 109;
            case "galacticfirefly":
               return 110;
            case "caterpillar":
               return 111;
            case "lamb":
               return 112;
            default:
               return -1;
         }
      }
      
      public static function petNameForDefId(param1:int) : String
      {
         switch(param1)
         {
            case 2:
               return "frog";
            case 1:
               return "kitten";
            case 4:
               return "puppy";
            case 3:
               return "ducky";
            case 5:
               return "butterfly";
            case 6:
               return "hamster";
            case 7:
               return "bat";
            case 8:
               return "seahorse";
            case 9:
               return "anglerfish";
            case 10:
               return "reindeer";
            case 11:
               return "snake";
            case 12:
               return "jellyfish";
            case 13:
               return "bunny";
            case 14:
               return "hummingbird";
            case 15:
               return "turtle";
            case 16:
               return "monkey";
            case 17:
               return "tarantula";
            case 18:
               return "fox";
            case 19:
               return "owl";
            case 20:
               return "tiger";
            case 21:
               return "arcticwolfpup";
            case 22:
               return "raccoon";
            case 23:
               return "joey";
            case 24:
               return "eaglet";
            case 25:
               return "cheetah";
            case 26:
               return "rhino";
            case 27:
               return "giraffe";
            case 28:
               return "sugarglider";
            case 29:
               return "lionCub";
            case 30:
               return "panda";
            case 31:
               return "polarbearcub";
            case 32:
               return "gecko";
            case 34:
               return "pony";
            case 35:
               return "piglet";
            case 36:
               return "ferret";
            case 37:
               return "elephant";
            case 38:
               return "armadillo";
            case 39:
               return "peacock";
            case 40:
               return "bee";
            case 42:
               return "skunk";
            case 43:
               return "turkey";
            case 44:
               return "penguin";
            case 45:
               return "snowLeopard";
            case 46:
               return "mantis";
            case 47:
               return "ladybug";
            case 48:
               return "cricket";
            case 49:
               return "squirrel";
            case 50:
               return "mouse";
            case 51:
               return "firefly";
            case 52:
               return "lemur";
            case 53:
               return "hippo";
            case 54:
               return "goat";
            case 55:
               return "meerkat";
            case 56:
               return "goldenbunny";
            case 57:
               return "phantom";
            case 58:
               return "seal";
            case 59:
               return "otter";
            case 60:
               return "rarephantom";
            case 61:
               return "groundhog";
            case 62:
               return "llama";
            case 63:
               return "arcticfox";
            case 41:
               return "rooster";
            case 64:
               return "hyena";
            case 67:
               return "chick";
            case 68:
               return "goldenarmadillo";
            case 69:
               return "falcon";
            case 70:
               return "crocodile";
            case 71:
               return "platypus";
            case 74:
               return "shark";
            case 75:
               return "dolphin";
            case 76:
               return "echidna";
            case 65:
               return "sloth";
            case 66:
               return "dove";
            case 77:
               return "koala";
            case 73:
               return "goldenpony";
            case 72:
               return "phantomJW";
            case 80:
               return "lynx";
            case 81:
               return "octopus";
            case 82:
               return "fennecfoxjw";
            case 83:
               return "hedgehog";
            case 84:
               return "scorpion";
            case 85:
               return "crow";
            case 86:
               return "moose";
            case 87:
               return "poodle";
            case 88:
               return "lovebunny";
            case 89:
               return "sabertooth";
            case 90:
               return "direwolf";
            case 91:
               return "dodo";
            case 92:
               return "fantasypeacock";
            case 93:
               return "millipede";
            case 94:
               return "moth";
            case 95:
               return "vulture";
            case 96:
               return "coyote";
            case 97:
               return "meagynsbear";
            case 98:
               return "falcon2";
            case 99:
               return "lovebug";
            case 100:
               return "flyingpig";
            case 101:
               return "sparrow";
            case 102:
               return "fennecfox";
            case 103:
               return "cardinal";
            case 104:
               return "frilledlizard";
            case 105:
               return "dragonfly";
            case 106:
               return "magentaseal";
            case 107:
               return "pangolin";
            case 108:
               return "camel";
            case 109:
               return "snail";
            case 110:
               return "galacticfirefly";
            case 111:
               return "caterpillar";
            case 112:
               return "lamb";
            default:
               return "";
         }
      }
      
      public static function getDefIdFromLBits(param1:int) : int
      {
         return param1 & 0xFF;
      }
      
      public static function sendPetSparkle(param1:int) : void
      {
         UserCommXtCommManager.sendPetAction(1,param1);
      }
      
      public static function getPetInventoryMax() : Number
      {
         return Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(338),1000);
      }
      
      public static function set unlockedPets(param1:String) : void
      {
         if(param1 != null && param1.length > 0)
         {
            _unlockedPets = new ScalableBitField(param1);
         }
      }
      
      public static function isPetAvailable(param1:Number) : Boolean
      {
         return _unlockedPets.isBitSet(param1 - 1);
      }
      
      public static function canCurrAvatarUsePet(param1:int, param2:PetDef, param3:Number) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc4_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc4_ = PartyManager.getPartyDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc4_ != null)
            {
               if(_loc4_.restrictions == 4 || _loc4_.restrictions == 8)
               {
                  _loc5_ = true;
               }
            }
         }
         return canBeUsedInEnviroType(param2,param3,AvatarManager.roomEnviroType) && (_loc5_ ? true : canBeUsedByEnviroTypeFlag(param2,param3,param1));
      }
      
      public static function hasHatched(param1:Number) : Boolean
      {
         return param1 + 259200 <= Utility.getInitialEpochTime();
      }
      
      public static function canPetGoInBothEnviroTypes(param1:PetDef, param2:Number) : Boolean
      {
         if(param1.isEgg && !hasHatched(param2))
         {
            return false;
         }
         if(param1.type == 4 || param1.type == 5)
         {
            return true;
         }
         return false;
      }
      
      private static function canBeUsedInEnviroType(param1:PetDef, param2:Number, param3:int) : Boolean
      {
         if(param1.isEgg && !hasHatched(param2))
         {
            return param3 == 0;
         }
         if(param1.type == 0 || param1.type == 1)
         {
            return param3 == 0;
         }
         if(param1.type == 2 || param1.type == 3)
         {
            return param3 == 1;
         }
         if(param1.type == 4 || param1.type == 5)
         {
            return param3 == 0 || param3 == 1;
         }
         return false;
      }
      
      private static function canBeUsedByEnviroTypeFlag(param1:PetDef, param2:Number, param3:int) : Boolean
      {
         if(param1.isEgg && !hasHatched(param2))
         {
            return !Utility.isAir(param3) && Utility.isLand(param3);
         }
         if(param1.type == 0)
         {
            return !Utility.isAir(param3) && Utility.isLand(param3);
         }
         if(param1.type == 1)
         {
            return Utility.isAir(param3) || Utility.isLand(param3);
         }
         if(param1.type == 2 || param1.type == 3)
         {
            return Utility.isOcean(param3);
         }
         if(param1.type == 4)
         {
            return !Utility.isAir(param3) && (Utility.isLand(param3) || Utility.isOcean(param3));
         }
         if(param1.type == 5)
         {
            return Utility.isLand(param3) || Utility.isOcean(param3);
         }
         return false;
      }
      
      public static function canPetGoInEnviroType(param1:PetDef, param2:Number, param3:int) : Boolean
      {
         var _loc4_:int = 0;
         if(param1.isEgg && !hasHatched(param2))
         {
            _loc4_ = 0;
         }
         else
         {
            _loc4_ = getEnviroTypeByPetType(param1,param2,param3);
         }
         if(Utility.isSameEnviroType(param3,_loc4_))
         {
            return true;
         }
         return false;
      }
      
      public static function checkIfHasPet(param1:int) : Boolean
      {
         var _loc4_:* = null;
         var _loc2_:int = 0;
         var _loc3_:PetDef = null;
         for each(_loc4_ in _myPetList)
         {
            _loc3_ = getPetDef(_loc4_.defId);
            if(_loc3_)
            {
               _loc2_ = getEnviroTypeByPetType(_loc3_,_loc4_.createdTs,param1);
               if(_loc2_ == 0)
               {
                  if(Utility.isSameEnviroType(param1,_loc2_) && !Utility.isAir(param1))
                  {
                     return true;
                  }
               }
               else if(Utility.isSameEnviroType(param1,_loc2_))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public static function createRandomPet(param1:int) : Array
      {
         var _loc6_:int = Math.random() * 19;
         var _loc4_:int = Math.random() * 19;
         var _loc2_:int = Math.random() * 5;
         var _loc3_:int = Math.random() * 3;
         var _loc8_:int = Math.random() * 3;
         var _loc9_:int = Math.random() * 3;
         return [param1,_loc6_,_loc4_,0,_loc2_,_loc3_,_loc8_,_loc9_,0,0,0,0,0,0,0];
      }
      
      public static function packPetBits(param1:Array) : Array
      {
         var _loc2_:uint = uint(param1[5] << 28 | param1[4] << 24 | param1[3] << 19 | param1[2] << 14 | param1[1] << 8 | param1[0]);
         var _loc4_:uint = uint(param1[11] << 20 | param1[10] << 16 | param1[9] << 12 | param1[8] << 8 | param1[7] << 4 | param1[6]);
         return [_loc2_,_loc4_,0];
      }
      
      public static function unpackPetBits(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc9_:* = param1 & 0xFF;
         var _loc15_:* = param1 >> 8 & 0x3F;
         var _loc12_:* = param1 >> 14 & 0x1F;
         var _loc13_:* = param1 >> 19 & 0x1F;
         var _loc10_:* = param1 >> 24 & 0x0F;
         var _loc11_:* = param1 >> 28 & 0x0F;
         var _loc7_:* = param2 & 0x0F;
         var _loc8_:* = param2 >> 4 & 0x0F;
         var _loc5_:* = param2 >> 8 & 0x0F;
         var _loc6_:* = param2 >> 12 & 0x0F;
         var _loc16_:* = param2 >> 16 & 0x0F;
         var _loc17_:* = param2 >> 20 & 0x0F;
         var _loc18_:* = param3 & 0x0F;
         var _loc14_:* = param3 >> 4 & 0x0F;
         var _loc4_:* = param3 >> 8 & 0x0F;
         return [_loc9_,_loc15_,_loc12_,_loc13_,_loc10_,_loc11_,_loc7_,_loc8_,_loc5_,_loc6_,_loc16_,_loc17_,_loc18_,_loc14_,_loc4_];
      }
   }
}

