package avatar
{
   import collection.AccItemCollection;
   import collection.IntItemCollection;
   import com.sbi.debug.DebugUtility;
   import item.Item;
   
   public class AccessoryState
   {
      private var _accShownItems:AccItemCollection;
      
      private var _accShownLayers:IntItemCollection;
      
      public var ownerAvatar:Avatar;
      
      public function AccessoryState()
      {
         super();
      }
      
      public function init(param1:Avatar) : void
      {
         _accShownItems = new AccItemCollection();
         _accShownLayers = new IntItemCollection();
         ownerAvatar = param1;
         if(ownerAvatar.avName == null)
         {
            DebugUtility.debugTrace("break here");
         }
      }
      
      public function destroy() : void
      {
         if(_accShownItems)
         {
            _accShownItems = null;
         }
         if(_accShownLayers)
         {
            _accShownLayers = null;
         }
      }
      
      public function copyShownAccRef(param1:AccessoryState) : void
      {
         DebugUtility.debugTrace("AccState copyAcc - ownerAvatar:" + ownerAvatar + (!!ownerAvatar ? " name:" + ownerAvatar.avName : "") + " copyFrom avatar:" + param1.ownerAvatar + " name:" + param1.ownerAvatar.avName);
         accShownItems = param1.accShownItems;
         accShownLayers = param1.accShownLayers;
      }
      
      public function cloneShownAcc(param1:AccessoryState) : void
      {
         var _loc2_:int = 0;
         accShownItems = param1.accShownItems;
         _loc2_ = 0;
         while(_loc2_ < accShownItems.length)
         {
            accShownItems.setAccItem(_loc2_,accShownItems.getAccItem(_loc2_).clone() as Item);
            _loc2_++;
         }
         accShownLayers = param1.accShownLayers;
      }
      
      public function matchShownItems(param1:AccessoryState, param2:AccItemCollection, param3:AccItemCollection) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = int(param1.accShownItems.length);
         accShownLayers = param1.accShownLayers;
         _loc5_ = 0;
         loop0:
         for(; _loc5_ < _loc4_; _loc5_++)
         {
            if(param1.accShownItems.getAccItem(_loc5_).type != 1)
            {
               if(param1.accShownItems.getAccItem(_loc5_).type == 0)
               {
                  _loc7_ = 0;
                  while(_loc7_ < param3.length)
                  {
                     if(param1.accShownItems.getAccItem(_loc5_).invIdx == param3.getAccItem(_loc7_).invIdx)
                     {
                        accShownItems.setAccItem(_loc5_,param3.getAccItem(_loc7_));
                        break;
                     }
                     _loc7_++;
                  }
               }
               continue;
            }
            _loc6_ = 0;
            while(true)
            {
               if(_loc6_ >= param2.length)
               {
                  continue loop0;
               }
               if(param1.accShownItems.getAccItem(_loc5_).invIdx == param2.getAccItem(_loc6_).invIdx)
               {
                  accShownItems.setAccItem(_loc5_,param2.getAccItem(_loc6_));
                  continue loop0;
               }
               _loc6_++;
            }
         }
      }
      
      public function get accShownItems() : AccItemCollection
      {
         return _accShownItems;
      }
      
      public function set accShownItems(param1:AccItemCollection) : void
      {
         _accShownItems.setCoreArray(_accShownItems.concatCollection(param1));
      }
      
      public function get accShownLayers() : IntItemCollection
      {
         return _accShownLayers;
      }
      
      public function set accShownLayers(param1:IntItemCollection) : void
      {
         _accShownLayers.setCoreArray(_accShownLayers.concatCollection(param1));
      }
      
      public function get numClothingItemsShown() : int
      {
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = int(_accShownItems.length);
         while(_loc2_ < _loc3_)
         {
            _loc1_ = _accShownItems.getAccItem(_loc2_).layerId;
            if(_loc1_ > 3)
            {
               _loc4_++;
            }
            _loc2_++;
         }
         return _loc4_;
      }
      
      public function get accItemsWithoutBodMods() : AccItemCollection
      {
         var _loc2_:int = 0;
         var _loc1_:AccItemCollection = new AccItemCollection();
         _loc2_ = 0;
         while(_loc2_ < _accShownItems.length)
         {
            if(_accShownItems.getAccItem(_loc2_).type != 0)
            {
               _loc1_.pushAccItem(_accShownItems.getAccItem(_loc2_));
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function showAccessory(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            _loc3_ = int(_accShownItems.length);
            while(_loc2_ < _loc3_)
            {
               if(_accShownItems.getAccItem(_loc2_).invIdx == param1.invIdx)
               {
                  DebugUtility.debugTrace("accessory showId:" + _accShownItems.getAccItem(_loc2_).invIdx + " is already visible!");
                  break;
               }
               _loc2_++;
            }
            if(_loc2_ == _loc3_)
            {
               param1.setInUse(ownerAvatar.avInvId,true);
               adjustAvatarQuestValues(true,param1);
               _accShownItems.pushAccItem(param1);
               _accShownLayers.pushIntItem(param1.layerId);
            }
         }
         else
         {
            DebugUtility.debugTrace("WARNING: showAccessory received a null item");
         }
      }
      
      public function replaceAccessory(param1:Item, param2:Item) : void
      {
         var _loc4_:int = 0;
         if(param1.accId != param2.accId)
         {
            throw new Error("Tried to replace accessory with different accId! Layers may not match! oldId:" + param1.accId + " newId:" + param2.accId);
         }
         var _loc3_:int = int(_accShownItems.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if(_accShownItems.getAccItem(_loc4_).defId == param1.defId)
            {
               _accShownItems.setAccItem(_loc4_,param2);
               if(!param2.getInUse(ownerAvatar.avInvId))
               {
                  _accShownItems.getCoreArray().splice(_loc4_,1);
                  _accShownLayers.getCoreArray().splice(_loc4_,1);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public function isAccessoryVisibleByItemId(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_accShownItems.getAccItem(_loc3_).invIdx == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByAccId(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_accShownItems.getAccItem(_loc3_).accId == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByLayer(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_accShownLayers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_accShownLayers.getIntItem(_loc2_) == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function getAccessoryVisibleDefIdByLayer(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_accShownLayers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_accShownLayers.getIntItem(_loc2_) == param1)
            {
               return _accShownItems.getAccItem(_loc2_).defId;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function hideAccessory(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            _loc3_ = int(_accShownItems.length);
            while(_loc2_ < _loc3_)
            {
               if(_accShownItems.getAccItem(_loc2_).invIdx == param1.invIdx)
               {
                  param1.setInUse(ownerAvatar.avInvId,false);
                  adjustAvatarQuestValues(false,param1);
                  _accShownItems.getCoreArray().splice(_loc2_,1);
                  _accShownLayers.getCoreArray().splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      public function hideAll() : void
      {
         while(_accShownItems.length > 0)
         {
            hideAccessory(_accShownItems.getAccItem(0));
         }
      }
      
      public function removeAllItems() : void
      {
         _accShownItems = new AccItemCollection();
         _accShownLayers = new IntItemCollection();
         ownerAvatar.meleeAttack = [0,0];
         ownerAvatar.rangedAttack = [0,0];
         ownerAvatar.fierceAttack = [0,0];
         ownerAvatar.healingPower = [0,0];
         ownerAvatar.defense = [0,0];
      }
      
      public function hideAllExceptBase() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         while(_loc1_ < _loc2_)
         {
            if(_accShownLayers.getIntItem(_loc1_) != 1)
            {
               hideAccessory(_accShownItems.getAccItem(_loc1_));
               _loc2_--;
            }
            else
            {
               _loc1_++;
            }
         }
      }
      
      public function hideAllClothingArticles(param1:IntItemCollection = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = int(_accShownItems.length);
         while(_loc3_ < _loc4_)
         {
            _loc2_ = _accShownItems.getAccItem(_loc3_).layerId;
            if(_loc2_ > 3)
            {
               if(param1)
               {
                  param1.pushIntItem(_accShownItems.getAccItem(_loc3_).invIdx);
               }
               hideAccessory(_accShownItems.getAccItem(_loc3_));
               _loc4_--;
            }
            else
            {
               _loc3_++;
            }
         }
      }
      
      private function adjustAvatarQuestValues(param1:Boolean, param2:Item) : void
      {
         if(param2.attack < 0)
         {
            if(param1)
            {
               var _loc3_:* = 0;
               var _loc4_:* = ownerAvatar.healingPower[_loc3_] + param2.attack * -1;
               ownerAvatar.healingPower[_loc3_] = _loc4_;
            }
            else
            {
               _loc4_ = 0;
               _loc3_ = ownerAvatar.healingPower[_loc4_] - param2.attack * -1;
               ownerAvatar.healingPower[_loc4_] = _loc3_;
            }
         }
         else if(param2.combatType == 1)
         {
            if(param1)
            {
               _loc3_ = 0;
               _loc4_ = ownerAvatar.rangedAttack[_loc3_] + param2.attack;
               ownerAvatar.rangedAttack[_loc3_] = _loc4_;
            }
            else
            {
               _loc4_ = 0;
               _loc3_ = ownerAvatar.rangedAttack[_loc4_] - param2.attack;
               ownerAvatar.rangedAttack[_loc4_] = _loc3_;
            }
         }
         else if(param1)
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.meleeAttack[_loc3_] + param2.attack;
            ownerAvatar.meleeAttack[_loc3_] = _loc4_;
         }
         else
         {
            _loc4_ = 0;
            _loc3_ = ownerAvatar.meleeAttack[_loc4_] - param2.attack;
            ownerAvatar.meleeAttack[_loc4_] = _loc3_;
         }
         if(param1)
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.fierceAttack[_loc3_] + param2.fierceAttack;
            ownerAvatar.fierceAttack[_loc3_] = _loc4_;
            ownerAvatar.defense[0] += param2.defense;
         }
         else
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.fierceAttack[_loc3_] - param2.fierceAttack;
            ownerAvatar.fierceAttack[_loc3_] = _loc4_;
            ownerAvatar.defense[0] -= param2.defense;
         }
         switch(param2.modifierType - 1)
         {
            case 0:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.rangedAttack[_loc3_] + param2.modifierValue;
                  ownerAvatar.rangedAttack[_loc3_] = _loc4_;
                  break;
               }
               _loc4_ = 1;
               _loc3_ = ownerAvatar.rangedAttack[_loc4_] - param2.modifierValue;
               ownerAvatar.rangedAttack[_loc4_] = _loc3_;
               break;
            case 1:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.meleeAttack[_loc3_] + param2.modifierValue;
                  ownerAvatar.meleeAttack[_loc3_] = _loc4_;
                  break;
               }
               _loc4_ = 1;
               _loc3_ = ownerAvatar.meleeAttack[_loc4_] - param2.modifierValue;
               ownerAvatar.meleeAttack[_loc4_] = _loc3_;
               break;
            case 2:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.defense[_loc3_] + param2.modifierValue;
                  ownerAvatar.defense[_loc3_] = _loc4_;
                  break;
               }
               _loc4_ = 1;
               _loc3_ = ownerAvatar.defense[_loc4_] - param2.modifierValue;
               ownerAvatar.defense[_loc4_] = _loc3_;
               break;
            case 3:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.healingPower[_loc3_] + param2.modifierValue;
                  ownerAvatar.healingPower[_loc3_] = _loc4_;
                  break;
               }
               _loc4_ = 1;
               _loc3_ = ownerAvatar.healingPower[_loc4_] - param2.modifierValue;
               ownerAvatar.healingPower[_loc4_] = _loc3_;
               break;
         }
      }
   }
}

