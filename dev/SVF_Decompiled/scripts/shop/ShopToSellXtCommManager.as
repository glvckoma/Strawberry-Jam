package shop
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.PetItemCollection;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import den.DenMannequinInventory;
   import den.DenXtCommManager;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.StartupPopups;
   import inventory.Iitem;
   import item.Item;
   import localization.LocalizationManager;
   import pet.PetItem;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import room.RoomManagerWorld;
   
   public class ShopToSellXtCommManager
   {
      private static var _itemsAdded:Vector.<MyShopItem>;
      
      private static var _itemsRemoved:Vector.<MyShopItem>;
      
      private static var _itemsChanged:Vector.<MyShopItem>;
      
      private static var _storeInvId:int;
      
      private static var _dsbCallback:Function;
      
      private static var _dsbPassback:Object;
      
      private static var _dsbResponsesToProcess:Array;
      
      private static var _dsuCallbacks:Array = [];
      
      private static var _dsiCallbacks:Array = [];
      
      public function ShopToSellXtCommManager()
      {
         super();
      }
      
      public static function requestStoreUpdateItems(param1:int, param2:String, param3:Vector.<MyShopItem>, param4:Vector.<MyShopItem>, param5:Vector.<MyShopItem>, param6:Function = null, param7:Object = null) : void
      {
         var _loc10_:int = 0;
         _storeInvId = param1;
         _itemsAdded = param3;
         _itemsRemoved = param4;
         _itemsChanged = param5;
         var _loc9_:Array = [];
         var _loc8_:Array = [];
         var _loc11_:Array = [_storeInvId,param2];
         if(param3)
         {
            _loc10_ = 0;
            while(_loc10_ < param3.length)
            {
               _loc9_.push(param3[_loc10_].currItem.itemType);
               _loc9_.push(param3[_loc10_].currItem.invIdx);
               _loc9_.push(param3[_loc10_].currencyType);
               _loc9_.push(param3[_loc10_].cost);
               _loc10_++;
            }
         }
         if(param5)
         {
            _loc10_ = 0;
            while(_loc10_ < param5.length)
            {
               _loc9_.push(param5[_loc10_].currItem.itemType);
               _loc9_.push(param5[_loc10_].currItem.invIdx);
               _loc9_.push(param5[_loc10_].currencyType);
               _loc9_.push(param5[_loc10_].cost);
               _loc10_++;
            }
         }
         if(param4)
         {
            _loc10_ = 0;
            while(_loc10_ < param4.length)
            {
               _loc8_.push(param4[_loc10_].currItem.itemType);
               _loc8_.push(param4[_loc10_].currItem.invIdx);
               _loc10_++;
            }
         }
         if(_loc9_.length > 0)
         {
            _loc11_.push(_loc9_.length / 4);
            _loc11_ = _loc11_.concat(_loc9_);
         }
         else
         {
            _loc11_.push(0);
         }
         if(_loc8_.length > 0)
         {
            _loc11_.push(_loc8_.length / 2);
            _loc11_ = _loc11_.concat(_loc8_);
         }
         else
         {
            _loc11_.push(0);
         }
         _dsuCallbacks.push({
            "callback":param6,
            "passback":param7
         });
         gMainFrame.server.setXtObject_Str("dsu",_loc11_);
      }
      
      public static function requestStoreInfo(param1:String, param2:int, param3:Function, param4:Object) : void
      {
         _dsiCallbacks.push({
            "callback":param3,
            "passback":param4,
            "forMyself":param1.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase()
         });
         _storeInvId = param2;
         gMainFrame.server.setXtObject_Str("dsi",[param1,param2]);
      }
      
      public static function requestStoreBuy(param1:String, param2:MyShopItem, param3:String, param4:Function) : void
      {
         _dsbCallback = param4;
         gMainFrame.server.setXtObject_Str("dsb",[param1,param2.shopInvIdx,param3,param2.currItem.itemType,param2.currItem.invIdx,param2.currencyType,param2.cost]);
      }
      
      public static function get hasBuysToProcess() : Boolean
      {
         return _dsbResponsesToProcess != null && _dsbResponsesToProcess.length > 0;
      }
      
      public static function processBuyResponses() : void
      {
         var _loc1_:int = 0;
         if(_dsbResponsesToProcess && _dsbResponsesToProcess.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _dsbResponsesToProcess.length)
            {
               onDenStoreBuy(_dsbResponsesToProcess.shift());
               _loc1_--;
               _loc1_++;
            }
         }
         _dsbResponsesToProcess = null;
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "dsu":
               onDenStoreUpdate(_loc2_);
               break;
            case "dsi":
               onDenStoreInfo(_loc2_ as Array);
               break;
            case "dsb":
               onDenStoreBuy(_loc2_);
               break;
            default:
               throw new Error("ShopToSellXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function onDenStoreUpdate(param1:Object) : void
      {
         var _loc11_:String = null;
         var _loc5_:int = 0;
         var _loc10_:UserInfo = null;
         var _loc8_:Object = null;
         var _loc2_:int = 0;
         var _loc12_:int = 0;
         var _loc7_:Avatar = null;
         var _loc9_:AccItemCollection = null;
         var _loc13_:AccItemCollection = null;
         var _loc3_:Array = null;
         var _loc4_:Object = _dsuCallbacks.shift();
         if(param1[2] == "1")
         {
            _loc11_ = param1[3];
            _loc10_ = gMainFrame.userInfo.playerUserInfo;
            _loc8_ = gMainFrame.userInfo.playerUserInfo.avList;
            _loc2_ = int(gMainFrame.userInfo.playerAvatarInfo.type);
            _loc12_ = int(gMainFrame.userInfo.playerAvatarInfo.perUserAvId);
            _loc7_ = AvatarManager.getAvatarByUsernamePerUserAvId(_loc10_.userName,_loc12_);
            _loc9_ = _loc10_.getFullItemList(false);
            _loc13_ = _loc7_.inventoryClothing.itemCollection;
            _loc3_ = PetManager.myPetList;
            if(_itemsAdded)
            {
               _loc5_ = 0;
               while(_loc5_ < _itemsAdded.length)
               {
                  _itemsAdded[_loc5_].currItem.denStoreInvId = _storeInvId;
                  updateInDenShopValues(_loc9_,_loc13_,_loc10_.denItemsFull,_loc3_,_itemsAdded[_loc5_].currItem.itemType,_itemsAdded[_loc5_].currItem.invIdx,true);
                  updateMyDenShopList(_storeInvId,_itemsAdded[_loc5_].currItem,true,_itemsAdded[_loc5_].currencyType,_itemsAdded[_loc5_].cost);
                  _loc5_++;
               }
            }
            if(_itemsRemoved)
            {
               _loc5_ = 0;
               while(_loc5_ < _itemsRemoved.length)
               {
                  _itemsRemoved[_loc5_].currItem.denStoreInvId = 0;
                  updateInDenShopValues(_loc9_,_loc13_,_loc10_.denItemsFull,_loc3_,_itemsRemoved[_loc5_].currItem.itemType,_itemsRemoved[_loc5_].currItem.invIdx,false);
                  updateMyDenShopList(_storeInvId,_itemsRemoved[_loc5_].currItem,false,-1,-1);
                  _loc5_++;
               }
            }
            if(ShopManager.myShopItems && ShopManager.myShopItems.length > 0)
            {
               _loc5_ = 0;
               while(_loc5_ < _itemsChanged.length)
               {
                  updateMyDenShopList(_storeInvId,_itemsChanged[_loc5_].currItem,true,_itemsChanged[_loc5_].currencyType,_itemsChanged[_loc5_].cost);
                  _loc5_++;
               }
            }
            ShopManager.updateShopState(_storeInvId,_loc11_);
         }
         else
         {
            ShopManager.clearShopItems(_storeInvId);
            if(_loc4_ == null)
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(33933));
            }
         }
         GuiManager.resetWindowsAndTabsToNormal();
         if(_loc4_ != null)
         {
            _loc4_.callback(param1[2] == "1",_loc4_.passback);
         }
      }
      
      private static function updateInDenShopValues(param1:AccItemCollection, param2:AccItemCollection, param3:DenItemCollection, param4:Array, param5:int, param6:int, param7:Boolean) : void
      {
         var _loc8_:int = 0;
         if(param5 == 2)
         {
            _loc8_ = 0;
            while(_loc8_ < param1.length)
            {
               if(param1.getAccItem(_loc8_).invIdx == param6)
               {
                  param1.getAccItem(_loc8_).denStoreInvId = param7 ? _storeInvId : 0;
                  break;
               }
               _loc8_++;
            }
            _loc8_ = 0;
            while(true)
            {
               if(_loc8_ < param2.length)
               {
                  if(param2.getAccItem(_loc8_).invIdx != param6)
                  {
                     continue;
                  }
                  param2.getAccItem(_loc8_).denStoreInvId = param7 ? _storeInvId : 0;
               }
               _loc8_++;
            }
         }
         else if(param5 == 0)
         {
            _loc8_ = 0;
            while(true)
            {
               if(_loc8_ < param3.length)
               {
                  if(param3.getDenItem(_loc8_).invIdx != param6)
                  {
                     continue;
                  }
                  param3.getDenItem(_loc8_).denStoreInvId = param7 ? _storeInvId : 0;
               }
               _loc8_++;
            }
         }
         else if(param5 == 1)
         {
            _loc8_ = 0;
            while(_loc8_ < param4.length)
            {
               if(param4[_loc8_].idx == param6)
               {
                  param4[_loc8_].denStoreInvId = param7 ? _storeInvId : 0;
                  gMainFrame.userInfo.updatePetsDenShopUse(param6,param7 ? _storeInvId : 0,false);
                  break;
               }
               _loc8_++;
            }
         }
      }
      
      private static function updateMyDenShopList(param1:int, param2:Iitem, param3:Boolean, param4:int, param5:int) : void
      {
         var _loc9_:MyShopItem = null;
         var _loc6_:Boolean = false;
         var _loc10_:* = undefined;
         var _loc8_:int = 0;
         var _loc7_:MyShopData = ShopManager.myShopItems[param1];
         if(_loc7_)
         {
            _loc10_ = _loc7_.shopItems;
            _loc8_ = 0;
            while(_loc8_ < _loc10_.length)
            {
               _loc9_ = _loc10_[_loc8_];
               if(_loc9_.currItem.itemType == param2.itemType && _loc9_.currItem.invIdx == param2.invIdx)
               {
                  if(!param3)
                  {
                     _loc10_.splice(_loc8_,1);
                     break;
                  }
                  _loc9_.currencyType = param4;
                  _loc9_.cost = param5;
                  _loc6_ = true;
                  break;
               }
               _loc8_++;
            }
            if(!_loc6_ && param3)
            {
               _loc10_.push(new MyShopItem(param2,param4,param5,param1));
            }
         }
      }
      
      private static function onDenStoreInfo(param1:Array) : void
      {
         var _loc6_:MyShopData = null;
         var _loc16_:Iitem = null;
         var _loc3_:int = 0;
         var _loc28_:int = 0;
         var _loc22_:int = 0;
         var _loc2_:int = 0;
         var _loc15_:int = 0;
         var _loc17_:String = null;
         var _loc24_:UserInfo = null;
         var _loc23_:AccItemCollection = null;
         var _loc5_:PetItemCollection = null;
         var _loc4_:DenItemCollection = null;
         var _loc20_:int = 0;
         var _loc12_:* = undefined;
         var _loc26_:Boolean = false;
         var _loc18_:int = 0;
         var _loc8_:int = 0;
         var _loc14_:Boolean = false;
         var _loc11_:Iitem = null;
         var _loc27_:int = 0;
         var _loc7_:int = 0;
         var _loc19_:int = 2;
         param1[_loc19_++] = "1";
         var _loc21_:int = int(param1[_loc19_++]);
         var _loc13_:Vector.<MyShopItem> = new Vector.<MyShopItem>();
         var _loc9_:Object = _dsiCallbacks.shift();
         if(_loc21_ > -1)
         {
            _loc17_ = param1.length > _loc19_ ? param1[_loc19_++] : "";
            if(_loc9_.forMyself)
            {
               _loc24_ = gMainFrame.userInfo.playerUserInfo;
               _loc23_ = _loc24_.getFullItemList(false);
               _loc5_ = PetManager.myPetListAsIitem;
               _loc4_ = _loc24_.denItemsPartial;
               _loc12_ = new Vector.<MyShopItem>();
            }
            _loc18_ = 0;
            while(_loc18_ < _loc21_)
            {
               _loc2_ = int(param1[_loc19_++]);
               _loc15_ = int(param1[_loc19_++]);
               _loc3_ = int(param1[_loc19_++]);
               _loc28_ = int(param1[_loc19_++]);
               _loc22_ = int(param1[_loc19_++]);
               _loc16_ = null;
               _loc26_ = false;
               if(2 == _loc3_)
               {
                  if(_loc9_.forMyself)
                  {
                     _loc20_ = 0;
                     while(_loc20_ < _loc23_.length)
                     {
                        if(_loc23_.getAccItem(_loc20_).invIdx == _loc28_)
                        {
                           _loc16_ = _loc23_.getAccItem(_loc20_);
                           break;
                        }
                        _loc20_++;
                     }
                     if(_loc16_ == null)
                     {
                        _loc26_ = true;
                        _loc16_ = new Item();
                        (_loc16_ as Item).init(_loc22_,_loc28_,0,null,false,-1,_storeInvId);
                     }
                  }
                  else
                  {
                     _loc16_ = new Item();
                     (_loc16_ as Item).init(_loc22_,_loc28_,param1[_loc19_++],null,false,-1,_storeInvId);
                  }
               }
               else if(0 == _loc3_)
               {
                  if(_loc9_.forMyself)
                  {
                     _loc20_ = 0;
                     while(_loc20_ < _loc4_.length)
                     {
                        if(_loc4_.getDenItem(_loc20_).invIdx == _loc28_)
                        {
                           _loc16_ = _loc4_.getDenItem(_loc20_);
                           break;
                        }
                        _loc20_++;
                     }
                     if(_loc16_ == null)
                     {
                        _loc26_ = true;
                        _loc16_ = new DenItem();
                        (_loc16_ as DenItem).init(_loc22_,_loc28_,0,0,0,null,true,"","",-1,"",null,_storeInvId);
                     }
                  }
                  else
                  {
                     _loc16_ = new DenItem();
                     (_loc16_ as DenItem).init(_loc22_,_loc28_,0,param1[_loc19_++],0,null,param1[_loc19_++],param1[_loc19_++],"",param1[_loc19_++],param1[_loc19_++],null,_storeInvId);
                  }
               }
               else if(1 == _loc3_)
               {
                  if(_loc9_.forMyself)
                  {
                     _loc20_ = 0;
                     while(_loc20_ < _loc5_.length)
                     {
                        if(_loc5_.getPetItem(_loc20_).invIdx == _loc28_)
                        {
                           _loc16_ = _loc5_.getPetItem(_loc20_);
                           break;
                        }
                        _loc20_++;
                     }
                     if(_loc16_ == null)
                     {
                        _loc26_ = true;
                        _loc16_ = new PetItem();
                        (_loc16_ as PetItem).init(0,_loc22_,[0,0,0],0,0,0,_loc28_,null,false,null,null,_storeInvId);
                     }
                  }
                  else
                  {
                     _loc16_ = new PetItem();
                     (_loc16_ as PetItem).init(param1[_loc19_++],_loc22_,[param1[_loc19_++],param1[_loc19_++],param1[_loc19_++]],param1[_loc19_++],param1[_loc19_++],param1[_loc19_++],_loc28_,param1[_loc19_++],false,null,null,_storeInvId);
                     _loc8_ = int(param1[_loc19_++]);
                  }
               }
               if(_loc26_)
               {
                  _loc12_.push(new MyShopItem(_loc16_,_loc2_,_loc15_,_storeInvId));
                  DebugUtility.debugTrace("Item is null in den store");
               }
               else
               {
                  _loc13_.push(new MyShopItem(_loc16_,_loc2_,_loc15_,_storeInvId));
               }
               _loc18_++;
            }
            _loc6_ = new MyShopData(_storeInvId,_loc17_,_loc13_);
            if(_loc9_.forMyself)
            {
               _loc20_ = 0;
               while(_loc20_ < _loc23_.length)
               {
                  _loc11_ = _loc23_.getAccItem(_loc20_);
                  if(_loc11_.denStoreInvId == _storeInvId)
                  {
                     _loc27_ = _loc11_.invIdx;
                     _loc7_ = _loc11_.itemType;
                     _loc14_ = false;
                     _loc18_ = 0;
                     while(_loc18_ < _loc13_.length)
                     {
                        if(_loc27_ == _loc13_[_loc18_].currItem.invIdx && _loc7_ == _loc13_[_loc18_].currItem.itemType)
                        {
                           _loc14_ = true;
                           break;
                        }
                        _loc18_++;
                     }
                     if(!_loc14_)
                     {
                        _loc12_.push(new MyShopItem(_loc11_,0,0,_storeInvId));
                     }
                  }
                  _loc20_++;
               }
               _loc20_ = 0;
               while(_loc20_ < _loc4_.length)
               {
                  _loc11_ = _loc4_.getDenItem(_loc20_);
                  if(_loc11_.denStoreInvId == _storeInvId)
                  {
                     _loc27_ = _loc11_.invIdx;
                     _loc7_ = _loc11_.itemType;
                     _loc14_ = false;
                     _loc18_ = 0;
                     while(_loc18_ < _loc13_.length)
                     {
                        if(_loc27_ == _loc13_[_loc18_].currItem.invIdx && _loc7_ == _loc13_[_loc18_].currItem.itemType)
                        {
                           _loc14_ = true;
                           break;
                        }
                        _loc18_++;
                     }
                     if(!_loc14_)
                     {
                        _loc12_.push(new MyShopItem(_loc11_,0,0,_storeInvId));
                     }
                  }
                  _loc20_++;
               }
               _loc20_ = 0;
               while(_loc20_ < _loc5_.length)
               {
                  _loc11_ = _loc5_.getPetItem(_loc20_);
                  if(_loc11_.denStoreInvId == _storeInvId)
                  {
                     _loc27_ = _loc11_.invIdx;
                     _loc7_ = _loc11_.itemType;
                     _loc14_ = false;
                     _loc18_ = 0;
                     while(_loc18_ < _loc13_.length)
                     {
                        if(_loc27_ == _loc13_[_loc18_].currItem.invIdx && _loc7_ == _loc13_[_loc18_].currItem.itemType)
                        {
                           _loc14_ = true;
                           break;
                        }
                        _loc18_++;
                     }
                     if(!_loc14_)
                     {
                        _loc12_.push(new MyShopItem(_loc11_,0,0,_storeInvId));
                     }
                  }
                  _loc20_++;
               }
               ShopManager.addShopItemToMyList(_loc6_);
               if(_loc12_ && _loc12_.length > 0)
               {
                  requestStoreUpdateItems(_storeInvId,_loc17_,null,_loc12_,null,onAutoFixItems,{
                     "callbackData":_loc9_,
                     "newShopData":_loc6_
                  });
                  return;
               }
            }
         }
         else
         {
            _loc6_ = new MyShopData(_storeInvId,"",_loc13_);
         }
         if(_loc9_.callback != null)
         {
            _loc9_.callback(_loc6_,_loc9_.passback);
         }
      }
      
      private static function onAutoFixItems(param1:int, param2:Object) : void
      {
         if(param2.callbackData != null)
         {
            param2.callbackData.callback(param2.newShopData,param2.callbackData.passback);
         }
      }
      
      private static function onDenStoreBuy(param1:Object) : void
      {
         var _loc17_:String = null;
         var _loc9_:* = false;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc20_:String = null;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc21_:int = 0;
         var _loc14_:int = 0;
         var _loc7_:Iitem = null;
         var _loc11_:int = 0;
         var _loc8_:Boolean = false;
         var _loc3_:UserInfo = null;
         var _loc10_:AvatarInfo = null;
         var _loc19_:AccItemCollection = null;
         var _loc13_:int = 0;
         var _loc5_:int = 0;
         var _loc18_:int = 0;
         if(!StartupPopups.HAS_LOADED_STARTUP_POPUPS)
         {
            if(_dsbResponsesToProcess == null)
            {
               _dsbResponsesToProcess = [];
            }
            _dsbResponsesToProcess.push(param1);
            return;
         }
         var _loc12_:int = 2;
         var _loc22_:int = int(param1[_loc12_++]);
         if(_loc22_ == 1)
         {
            _loc17_ = param1[_loc12_++];
            _loc9_ = _loc17_ != gMainFrame.userInfo.myUserName;
            _loc15_ = int(param1[_loc12_++]);
            if(_loc9_)
            {
               _loc16_ = int(param1[_loc12_++]);
               _loc20_ = param1[_loc12_++];
            }
            _loc2_ = int(param1[_loc12_++]);
            _loc6_ = int(param1[_loc12_++]);
            _loc4_ = int(param1[_loc12_++]);
            _loc21_ = int(param1[_loc12_++]);
            _loc14_ = int(param1[_loc12_++]);
            if(_loc4_ == 2)
            {
               _loc7_ = new Item();
               (_loc7_ as Item).init(_loc14_,_loc16_,param1[_loc12_++]);
               _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(gMainFrame.userInfo.myUserName);
               _loc10_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,_loc3_.currPerUserAvId);
               (_loc7_ as Item).setInUse(_loc10_.avInvId,true);
               _loc19_ = _loc10_.getFullItems(true);
               if(_loc9_)
               {
                  _loc19_.getCoreArray().unshift(_loc7_);
               }
               else
               {
                  _loc13_ = int(_loc19_.length);
                  _loc11_ = 0;
                  while(_loc11_ < _loc13_)
                  {
                     if(_loc19_.getAccItem(_loc11_).invIdx == _loc21_)
                     {
                        _loc19_.getAccItem(_loc11_).setInUse(_loc10_.avInvId,false);
                        _loc19_.getCoreArray().splice(_loc11_,1);
                        DenMannequinInventory.removeItemFromUse(_loc21_);
                        break;
                     }
                     _loc11_++;
                  }
               }
               _loc10_.fullItemList = _loc19_;
               gMainFrame.userInfo.setAvatarInfoByUsernamePerUserAvId(_loc10_.perUserAvId,_loc10_);
               if(AvatarManager.playerAvatar)
               {
                  AvatarManager.playerAvatar.itemResponseIntegrate(_loc10_.getItems(true),false);
               }
               if(RoomManagerWorld.instance.isMyDen)
               {
                  RoomManagerWorld.instance.denItemHolder.rebuildMannequins();
               }
            }
            else if(_loc4_ == 0)
            {
               _loc7_ = new DenItem();
               (_loc7_ as DenItem).init(_loc14_,_loc21_,0,param1[_loc12_++],0,null,param1[_loc12_++],param1[_loc12_++],"",param1[_loc12_++],param1[_loc12_++]);
               DenXtCommManager.requestDenItems(onDenItemsRequestCallback);
               _loc8_ = true;
            }
            else if(_loc4_ == 1)
            {
               _loc7_ = new PetItem();
               (_loc7_ as PetItem).init(param1[_loc12_++],_loc14_,[param1[_loc12_++],param1[_loc12_++],param1[_loc12_++]],param1[_loc12_++],param1[_loc12_++],param1[_loc12_++],_loc16_,param1[_loc12_++]);
               _loc5_ = int(param1[_loc12_++]);
               if(_loc9_)
               {
                  PetManager.insertPetItem(_loc7_ as PetItem,false,_loc5_);
                  PetXtCommManager.sendPetSwitchRequest(_loc7_.invIdx,onPetSwitch);
                  _loc8_ = true;
               }
               else
               {
                  PetManager.removePetInvIdx([_loc21_]);
               }
               gMainFrame.userInfo.updatePetsDenShopUse((_loc7_ as PetItem).invIdx,_loc15_,!_loc9_);
            }
            if(_loc20_ != null)
            {
               ShopManager.updateShopState(_loc15_,_loc20_);
            }
            ShopManager.removeShopItemFromMyList(_loc15_,_loc7_,_loc21_);
            _loc18_ = int(param1[_loc12_++]);
            UserCurrency.setCurrency(_loc18_,_loc2_);
            _dsbPassback = {
               "status":_loc22_,
               "newCurrencyCount":_loc18_,
               "itemInvId":_loc21_,
               "currencyType":_loc2_
            };
            if(!_loc8_ && _dsbCallback != null)
            {
               _dsbCallback(_loc22_,_loc18_,_loc21_,_loc2_);
               _dsbCallback = null;
            }
            if(!_loc9_)
            {
               GuiManager.closeAnyInventoryRelatedWindows();
               ShopManager.clearShopItems(_loc15_);
               ShopManager.showItemSoldPopup(_loc7_,_loc6_,_loc2_,ShopManager.ifShopToSellOpenCloseIt(_loc15_) ? _loc15_ : -1);
            }
         }
         else if(_dsbCallback != null)
         {
            _dsbCallback(_loc22_,0,0,0);
            _dsbCallback = null;
         }
         else
         {
            ShopManager.clearShopItems(_storeInvId);
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(33933));
         }
      }
      
      private static function onDenItemsRequestCallback() : void
      {
         if(_dsbCallback != null)
         {
            _dsbCallback(_dsbPassback.status,_dsbPassback.newCurrencyCount,_dsbPassback.itemInvId,_dsbPassback.currencyType);
            _dsbPassback = null;
            _dsbCallback = null;
         }
      }
      
      private static function onPetSwitch(param1:*) : void
      {
         if(_dsbCallback != null)
         {
            _dsbCallback(_dsbPassback.status,_dsbPassback.newCurrencyCount,_dsbPassback.itemInvId,_dsbPassback.currencyType);
            _dsbPassback = null;
            _dsbCallback = null;
         }
      }
   }
}

