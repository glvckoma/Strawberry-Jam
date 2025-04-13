package avatar
{
   import Enums.DenItemDef;
   import collection.AccItemCollection;
   import den.DenMannequinInventory;
   import flash.display.MovieClip;
   import gui.LoadingSpiral;
   import item.Item;
   import item.ItemXtCommManager;
   import room.RoomManagerWorld;
   
   public class MannequinData
   {
      public var baseColor:uint;
      
      public var patternColor:uint;
      
      public var patternDefId:int;
      
      public var eyeColor:uint;
      
      public var eyeDefId:int;
      
      public var tailInvId:int;
      
      public var legInvId:int;
      
      public var backInvId:int;
      
      public var neckInvId:int;
      
      public var headInvId:int;
      
      public var tailColor:uint;
      
      public var tailDefId:int;
      
      public var legColor:uint;
      
      public var legDefId:int;
      
      public var backColor:uint;
      
      public var backDefId:int;
      
      public var neckColor:uint;
      
      public var neckDefId:int;
      
      public var headColor:uint;
      
      public var headDefId:int;
      
      public var invIdx:int;
      
      private var _mannequinAvatarView:AvatarView;
      
      private var _mannaquinLoadingSpiral:LoadingSpiral;
      
      private var _viewContainer:MovieClip;
      
      private var _denDef:DenItemDef;
      
      private var _isLoading:Boolean;
      
      private var _refreshAvatarView:Boolean;
      
      private var _isMyItem:Boolean;
      
      public function MannequinData()
      {
         super();
      }
      
      public function init(param1:DenItemDef, param2:Object, param3:int, param4:Boolean, param5:int, param6:Boolean) : int
      {
         _isMyItem = param6;
         invIdx = param5;
         var _loc7_:AvatarDef = gMainFrame.userInfo.getAvatarDefByAvType(param1.mannequinAvatarDefId,false);
         if(param2 != null)
         {
            if(param4)
            {
               return setupDataInvIdsOnly(_loc7_,param2,param3);
            }
            return setupDataFull(_loc7_,param2,param3);
         }
         baseColor = _loc7_.mannequinColorLayer1;
         patternColor = _loc7_.mannequinColorLayer2;
         patternDefId = _loc7_.defPattern;
         eyeColor = _loc7_.mannequinColorLayer3;
         eyeDefId = _loc7_.defEyes;
         tailInvId = 0;
         legInvId = 0;
         backInvId = 0;
         neckInvId = 0;
         headInvId = 0;
         return param3;
      }
      
      public function clone() : MannequinData
      {
         var _loc1_:MannequinData = new MannequinData();
         _loc1_._isMyItem = _isMyItem;
         _loc1_.invIdx = invIdx;
         _loc1_.baseColor = baseColor;
         _loc1_.patternColor = patternColor;
         _loc1_.patternDefId = patternDefId;
         _loc1_.eyeColor = eyeColor;
         _loc1_.eyeDefId = eyeDefId;
         _loc1_.tailInvId = tailInvId;
         _loc1_.legInvId = legInvId;
         _loc1_.backInvId = backInvId;
         _loc1_.neckInvId = neckInvId;
         _loc1_.headInvId = headInvId;
         _loc1_.tailColor = tailColor;
         _loc1_.tailDefId = tailDefId;
         _loc1_.legColor = legColor;
         _loc1_.legDefId = legDefId;
         _loc1_.backColor = backColor;
         _loc1_.backDefId = backDefId;
         _loc1_.neckColor = neckColor;
         _loc1_.neckDefId = neckDefId;
         _loc1_.headColor = headColor;
         _loc1_.headDefId = headDefId;
         return _loc1_;
      }
      
      public function get mannequinAvatarView() : AvatarView
      {
         return _mannequinAvatarView;
      }
      
      public function hasThisInvIdOnAndRemove(param1:int) : Boolean
      {
         switch(param1)
         {
            case tailInvId:
               tailInvId = 0;
               return true;
            case legInvId:
               legInvId = 0;
               return true;
            case backInvId:
               backInvId = 0;
               return true;
            case neckInvId:
               neckInvId = 0;
               return true;
            case headInvId:
               headInvId = 0;
               return true;
            default:
               return false;
         }
      }
      
      public function setToAvatarBoxFrame() : void
      {
         if(_mannequinAvatarView && _viewContainer)
         {
            _viewContainer.gotoAndStop(2);
         }
      }
      
      public function setupMannequinAvatarView(param1:DenItemDef, param2:MovieClip) : AvatarView
      {
         var _loc3_:Avatar = null;
         if(!_isLoading)
         {
            if(_mannequinAvatarView && _mannequinAvatarView.parent)
            {
               _viewContainer.avatarBox.removeChild(_mannequinAvatarView);
               _mannequinAvatarView.destroy();
            }
            _refreshAvatarView = false;
            _isLoading = true;
            _viewContainer = param2;
            _denDef = param1;
            _viewContainer.gotoAndStop(2);
            _mannaquinLoadingSpiral = new LoadingSpiral(_viewContainer.avatarBox);
            _loc3_ = new Avatar();
            _loc3_.avName = param1.name;
            _loc3_.init(-1,-1,_loc3_.avName,param1.mannequinAvatarDefId,[baseColor,patternColor,eyeColor],-1,null,"",-1,AvatarManager.roomEnviroType,null,null,null,null,null,true);
            if(RoomManagerWorld.instance.isMyDen || _isMyItem)
            {
               _loc3_.userName = gMainFrame.userInfo.myUserName;
               _loc3_.avInvId = gMainFrame.userInfo.playerAvatarInfo.avInvId;
               _loc3_.itemResponseIntegrate(generateBodModsAndClothingList(true));
            }
            else
            {
               _loc3_.itemResponseIntegrate(generateBodModsAndClothingList(false));
            }
            _mannequinAvatarView = new AvatarView();
            _mannequinAvatarView.init(_loc3_);
            _mannequinAvatarView.playAnim(param1.mannequinCatId,false,3,onMannequinAvatarViewLoaded);
            _mannequinAvatarView.frame = param1.mannequinFrame;
            switch(param1.mannequinAvatarDefId)
            {
               case 33:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 33;
                  break;
               case 28:
                  _mannequinAvatarView.x = 11;
                  _mannequinAvatarView.y = 29;
                  break;
               case 29:
                  _mannequinAvatarView.x = 5;
                  _mannequinAvatarView.y = 36;
                  break;
               case 8:
                  _mannequinAvatarView.x = 30;
                  _mannequinAvatarView.y = 30;
                  break;
               case 4:
                  _mannequinAvatarView.x = 19;
                  _mannequinAvatarView.y = 30;
                  break;
               case 25:
                  _mannequinAvatarView.x = 19;
                  _mannequinAvatarView.y = 34;
                  break;
               case 18:
                  _mannequinAvatarView.x = 23;
                  _mannequinAvatarView.y = 30;
                  break;
               case 24:
                  _mannequinAvatarView.x = 25;
                  _mannequinAvatarView.y = 33;
                  break;
               case 1:
                  _mannequinAvatarView.x = 22;
                  _mannequinAvatarView.y = 31;
                  break;
               case 6:
                  _mannequinAvatarView.x = 16;
                  _mannequinAvatarView.y = 30;
                  break;
               case 5:
                  _mannequinAvatarView.x = 17;
                  _mannequinAvatarView.y = 35;
                  break;
               case 37:
                  _mannequinAvatarView.x = 22;
                  _mannequinAvatarView.y = 35;
                  break;
               case 15:
                  _mannequinAvatarView.x = 35;
                  _mannequinAvatarView.y = 33;
                  break;
               case 14:
                  _mannequinAvatarView.x = 16;
                  _mannequinAvatarView.y = 33;
                  break;
               case 38:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 33;
                  break;
               case 42:
                  _mannequinAvatarView.x = 12;
                  _mannequinAvatarView.y = 35;
                  break;
               case 16:
                  _mannequinAvatarView.x = 18;
                  _mannequinAvatarView.y = 33;
                  break;
               case 26:
                  _mannequinAvatarView.x = 17;
                  _mannequinAvatarView.y = 33;
                  break;
               case 10:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 36;
                  break;
               case 31:
                  _mannequinAvatarView.x = 11;
                  _mannequinAvatarView.y = 31;
                  break;
               case 45:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 34;
                  break;
               case 41:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 36;
                  break;
               case 3:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 36;
                  break;
               case 40:
                  _mannequinAvatarView.x = 30;
                  _mannequinAvatarView.y = 33;
                  break;
               case 35:
                  _mannequinAvatarView.x = 83;
                  _mannequinAvatarView.y = 65;
                  _mannequinAvatarView.scaleX = 0.6;
                  _mannequinAvatarView.scaleY = 0.6;
                  break;
               case 2:
                  _mannequinAvatarView.x = 53;
                  _mannequinAvatarView.y = 65;
                  _mannequinAvatarView.scaleX = 0.55;
                  _mannequinAvatarView.scaleY = 0.55;
                  break;
               case 13:
                  _mannequinAvatarView.x = 10;
                  _mannequinAvatarView.y = 33;
                  break;
               case 39:
                  _mannequinAvatarView.x = 90;
                  _mannequinAvatarView.y = 108;
                  _mannequinAvatarView.scaleX = 0.65;
                  _mannequinAvatarView.scaleY = 0.65;
                  break;
               case 11:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 36;
                  break;
               case 36:
                  _mannequinAvatarView.x = 15;
                  _mannequinAvatarView.y = 34;
                  break;
               case 44:
                  _mannequinAvatarView.x = 21;
                  _mannequinAvatarView.y = 30;
                  break;
               case 12:
                  _mannequinAvatarView.x = 70;
                  _mannequinAvatarView.y = 25;
                  _mannequinAvatarView.scaleX = 0.55;
                  _mannequinAvatarView.scaleY = 0.55;
                  break;
               case 20:
                  _mannequinAvatarView.x = 83;
                  _mannequinAvatarView.y = 40;
                  _mannequinAvatarView.scaleX = 0.6;
                  _mannequinAvatarView.scaleY = 0.6;
                  break;
               case 22:
                  _mannequinAvatarView.x = 77;
                  _mannequinAvatarView.y = 30;
                  _mannequinAvatarView.scaleX = 0.55;
                  _mannequinAvatarView.scaleY = 0.55;
                  break;
               case 21:
                  _mannequinAvatarView.x = 62;
                  _mannequinAvatarView.y = 26;
                  _mannequinAvatarView.scaleX = 0.5;
                  _mannequinAvatarView.scaleY = 0.5;
                  break;
               case 19:
                  _mannequinAvatarView.x = 68;
                  _mannequinAvatarView.y = 27;
                  _mannequinAvatarView.scaleX = 0.6;
                  _mannequinAvatarView.scaleY = 0.6;
                  break;
               case 34:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 30;
                  break;
               case 43:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 32;
                  break;
               case 23:
               case 9:
               case 27:
               case 17:
               case 7:
                  _mannequinAvatarView.x = 26;
                  _mannequinAvatarView.y = 32;
                  break;
               case 30:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 29;
                  break;
               case 32:
               case 46:
                  _mannequinAvatarView.x = 20;
                  _mannequinAvatarView.y = 34;
                  break;
               case 47:
                  _mannequinAvatarView.x = 23;
                  _mannequinAvatarView.y = 31;
            }
         }
         else
         {
            _refreshAvatarView = true;
         }
         return _mannequinAvatarView;
      }
      
      public function refreshAvatarItems() : void
      {
         if(_mannequinAvatarView != null)
         {
            if(_isLoading)
            {
               _refreshAvatarView = true;
            }
            else
            {
               recreateAvatarForView();
            }
         }
      }
      
      public function updateColors(param1:Array) : void
      {
         baseColor = param1[0];
         patternColor = param1[1];
         eyeColor = param1[2];
      }
      
      public function updateLayer(param1:Item, param2:Boolean) : void
      {
         var _loc3_:int = param1.layerId;
         switch(_loc3_ - 1)
         {
            case 0:
               break;
            case 1:
               patternDefId = param2 ? param1.defId : 0;
               patternColor = param2 ? param1.color : 0;
               break;
            case 2:
               eyeDefId = param1.defId;
               eyeColor = param1.color;
               break;
            case 3:
               tailInvId = param2 ? param1.invIdx : 0;
               break;
            case 4:
               legInvId = param2 ? param1.invIdx : 0;
               break;
            case 5:
               backInvId = param2 ? param1.invIdx : 0;
               break;
            case 6:
               neckInvId = param2 ? param1.invIdx : 0;
               break;
            case 7:
            case 8:
            case 9:
               headInvId = param2 ? param1.invIdx : 0;
         }
      }
      
      public function removeItems() : void
      {
         DenMannequinInventory.removeItemFromUse(tailInvId);
         DenMannequinInventory.removeItemFromUse(legInvId);
         DenMannequinInventory.removeItemFromUse(neckInvId);
         DenMannequinInventory.removeItemFromUse(headInvId);
         DenMannequinInventory.removeItemFromUse(backInvId);
         tailInvId = 0;
         legInvId = 0;
         neckInvId = 0;
         headInvId = 0;
         backInvId = 0;
      }
      
      public function compare(param1:MannequinData, param2:Boolean) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(param2)
         {
            if(baseColor == param1.baseColor && patternColor == param1.patternColor && patternDefId == param1.patternDefId && eyeColor == param1.eyeColor && eyeDefId == param1.eyeDefId && tailInvId == param1.tailInvId && legInvId == param1.legInvId && backInvId == param1.backInvId && neckInvId == param1.neckInvId && headInvId == param1.headInvId)
            {
               return true;
            }
            return false;
         }
         if(baseColor == param1.baseColor && patternColor == param1.patternColor && patternDefId == param1.patternDefId && eyeColor == param1.eyeColor && eyeDefId == param1.eyeDefId && tailColor == param1.tailColor && tailDefId == param1.tailDefId && legColor == param1.legColor && legDefId == param1.legDefId && backColor == param1.backColor && backDefId == param1.backDefId && neckColor == param1.neckColor && neckDefId == param1.neckDefId && headColor == param1.headColor && headDefId == param1.headDefId)
         {
            return true;
         }
         return false;
      }
      
      public function copyFromOther(param1:MannequinData) : void
      {
         _isMyItem = param1._isMyItem;
         invIdx = param1.invIdx;
         baseColor = param1.baseColor;
         patternColor = param1.patternColor;
         patternDefId = param1.patternDefId;
         eyeColor = param1.eyeColor;
         eyeDefId = param1.eyeDefId;
         tailInvId = param1.tailInvId;
         legInvId = param1.legInvId;
         backInvId = param1.backInvId;
         neckInvId = param1.neckInvId;
         headInvId = param1.headInvId;
         tailColor = param1.tailColor;
         tailDefId = param1.tailDefId;
         legColor = param1.legColor;
         legDefId = param1.legDefId;
         backColor = param1.backColor;
         backDefId = param1.backDefId;
         neckColor = param1.neckColor;
         neckDefId = param1.neckDefId;
         headColor = param1.headColor;
         headDefId = param1.headDefId;
         setupMannequinAvatarView(_denDef,_viewContainer);
      }
      
      private function setupBodMods(param1:AvatarDef, param2:Object, param3:int) : int
      {
         baseColor = uint(param2[param3]) > 0 ? uint(param2[param3]) : param1.mannequinColorLayer1;
         param3++;
         patternColor = uint(param2[param3]) > 0 ? uint(param2[param3]) : param1.mannequinColorLayer2;
         param3++;
         patternDefId = param2[param3] > 0 ? param2[param3] : param1.defPattern;
         param3++;
         eyeColor = uint(param2[param3]) > 0 ? uint(param2[param3]) : param1.mannequinColorLayer3;
         param3++;
         eyeDefId = param2[param3] > 0 ? param2[param3] : param1.defEyes;
         param3++;
         return param3;
      }
      
      private function setupDataInvIdsOnly(param1:AvatarDef, param2:Object, param3:int) : int
      {
         param3 = setupBodMods(param1,param2,param3);
         tailInvId = param2[param3++];
         legInvId = param2[param3++];
         backInvId = param2[param3++];
         neckInvId = param2[param3++];
         headInvId = param2[param3++];
         setupMannequinInventory();
         return param3;
      }
      
      private function setupDataFull(param1:AvatarDef, param2:Object, param3:int) : int
      {
         param3 = setupBodMods(param1,param2,param3);
         tailDefId = param2[param3++];
         tailColor = tailDefId > 0 ? param2[param3++] : 0;
         tailInvId = tailDefId > 0 ? param2[param3++] : 0;
         legDefId = param2[param3++];
         legColor = legDefId > 0 ? param2[param3++] : 0;
         legInvId = legDefId > 0 ? param2[param3++] : 0;
         backDefId = param2[param3++];
         backColor = backDefId > 0 ? param2[param3++] : 0;
         backInvId = backDefId > 0 ? param2[param3++] : 0;
         neckDefId = param2[param3++];
         neckColor = neckDefId > 0 ? param2[param3++] : 0;
         neckInvId = neckDefId > 0 ? param2[param3++] : 0;
         headDefId = param2[param3++];
         headColor = headDefId > 0 ? param2[param3++] : 0;
         headInvId = headDefId > 0 ? param2[param3++] : 0;
         setupMannequinInventory();
         return param3;
      }
      
      private function onMannequinAvatarViewLoaded(param1:int) : void
      {
         if(_mannaquinLoadingSpiral != null)
         {
            _mannaquinLoadingSpiral.destroy();
            _mannaquinLoadingSpiral = null;
         }
         if(_mannequinAvatarView)
         {
            if(_viewContainer)
            {
               _mannequinAvatarView.pauseAnim(true);
               _viewContainer.avatarBox.addChild(_mannequinAvatarView);
               if(_refreshAvatarView)
               {
                  recreateAvatarForView();
               }
            }
         }
         _isLoading = false;
         _refreshAvatarView = false;
      }
      
      private function recreateAvatarForView() : void
      {
         var _loc1_:Avatar = new Avatar();
         _loc1_.avName = _denDef.name;
         _loc1_.init(-1,-1,_loc1_.avName,_denDef.mannequinAvatarDefId,[baseColor,patternColor,eyeColor],-1,null,"",-1,AvatarManager.roomEnviroType,null,null,null,null,null,true);
         if(RoomManagerWorld.instance.isMyDen || _isMyItem)
         {
            _loc1_.userName = gMainFrame.userInfo.myUserName;
            _loc1_.avInvId = gMainFrame.userInfo.playerAvatarInfo.avInvId;
            _loc1_.itemResponseIntegrate(generateBodModsAndClothingList(true));
         }
         else
         {
            _loc1_.itemResponseIntegrate(generateBodModsAndClothingList(false));
         }
         if(_mannequinAvatarView)
         {
            _mannequinAvatarView.resetAvatar(_loc1_);
         }
      }
      
      private function generateBodModsAndClothingList(param1:Boolean) : AccItemCollection
      {
         var _loc6_:Item = null;
         var _loc2_:AccItemCollection = null;
         var _loc3_:int = 0;
         var _loc4_:AccItemCollection = ItemXtCommManager.generateBodyModList(0,patternDefId,eyeDefId,false);
         var _loc5_:AccItemCollection = new AccItemCollection();
         if(param1)
         {
            _loc2_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_.getAccItem(_loc3_).enviroType == AvatarManager.roomEnviroType || _loc2_.getAccItem(_loc3_).isLandAndOcean)
               {
                  _loc6_ = _loc2_.getAccItem(_loc3_).clone() as Item;
                  _loc6_.forceInUse(true);
                  if(_loc6_.invIdx == tailInvId || _loc6_.invIdx == legInvId || _loc6_.invIdx == backInvId || _loc6_.invIdx == neckInvId || _loc6_.invIdx == headInvId)
                  {
                     _loc6_.setInUse(0,true);
                  }
                  else
                  {
                     _loc6_.setInUse(0,false);
                  }
                  _loc5_.pushAccItem(_loc6_);
               }
               _loc3_++;
            }
         }
         else
         {
            if(tailDefId != 0)
            {
               _loc6_ = new Item();
               _loc6_.init(tailDefId,1,tailColor);
               _loc6_.forceInUse(true);
               _loc6_.setInUse(0,true);
               _loc5_.pushAccItem(_loc6_);
            }
            if(legDefId != 0)
            {
               _loc6_ = new Item();
               _loc6_.init(legDefId,2,legColor);
               _loc6_.forceInUse(true);
               _loc6_.setInUse(0,true);
               _loc5_.pushAccItem(_loc6_);
            }
            if(backDefId != 0)
            {
               _loc6_ = new Item();
               _loc6_.init(backDefId,3,backColor);
               _loc6_.forceInUse(true);
               _loc6_.setInUse(0,true);
               _loc5_.pushAccItem(_loc6_);
            }
            if(neckDefId != 0)
            {
               _loc6_ = new Item();
               _loc6_.init(neckDefId,4,neckColor);
               _loc6_.forceInUse(true);
               _loc6_.setInUse(0,true);
               _loc5_.pushAccItem(_loc6_);
            }
            if(headDefId != 0)
            {
               _loc6_ = new Item();
               _loc6_.init(headDefId,5,headColor);
               _loc6_.forceInUse(true);
               _loc6_.setInUse(0,true);
               _loc5_.pushAccItem(_loc6_);
            }
         }
         return new AccItemCollection(_loc5_.concatCollection(_loc4_));
      }
      
      private function setupMannequinInventory() : void
      {
         DenMannequinInventory.setItemInUse(tailInvId,invIdx);
         DenMannequinInventory.setItemInUse(legInvId,invIdx);
         DenMannequinInventory.setItemInUse(backInvId,invIdx);
         DenMannequinInventory.setItemInUse(neckInvId,invIdx);
         DenMannequinInventory.setItemInUse(headInvId,invIdx);
      }
   }
}

