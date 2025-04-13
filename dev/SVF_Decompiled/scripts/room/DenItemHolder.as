package room
{
   import Party.PartyXtCommManager;
   import avatar.AvatarManager;
   import buddy.BuddyList;
   import collection.DenItemCollection;
   import collection.DenStateItemCollection;
   import com.sbi.bit.BitUtility;
   import com.sbi.graphics.SortLayer;
   import den.DenItem;
   import den.DenStateItem;
   import den.DenXtCommManager;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import game.MinigameManager;
   import gui.AvatarEditor;
   import gui.EcoPointsPopup;
   import gui.EcoScorePopup;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import loader.DenItemHelper;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import shop.ShopManager;
   
   public class DenItemHolder extends EventDispatcher
   {
      private const MOUSE_DOWN_TYPE:int = 0;
      
      private const MOUSE_OVER_TYPE:int = 1;
      
      private const MOUSE_OUT_TYPE:int = 2;
      
      private var _currItems:DenStateItemCollection;
      
      private var _itemsInit:DenStateItemCollection;
      
      private var _savedDenItemHelpers:Array;
      
      private var _layerManager:LayerManager;
      
      private var _dragItem:DenStateItem;
      
      private var _itemFilter:DenStateItem;
      
      private var _dragPoint:Point;
      
      private var _closeBtn:MovieClip;
      
      private var _flipBtn:MovieClip;
      
      private var _flipBtnVer:MovieClip;
      
      private var _linkBtn:MovieClip;
      
      private var _themePos:Point;
      
      private var _isWaitingToSetItemsForFirstTime:Boolean;
      
      private var _roomMode:int;
      
      private var _lastItemInvId:int;
      
      private var _itemToEnterInvId:int;
      
      private var _itemRadiusBmpData:BitmapData;
      
      private var _lastSelectedItem:DenStateItem;
      
      private var _mannaquinAvEditor:AvatarEditor;
      
      private var _mannaquinDenItemHelper:DenItemHelper;
      
      private var _ecoScorePopup:EcoScorePopup;
      
      private var _ecoPointsPopup:EcoPointsPopup;
      
      public function DenItemHolder(param1:LayerManager)
      {
         super();
         _themePos = new Point();
         _dragPoint = new Point();
         _layerManager = param1;
         _closeBtn = GETDEFINITIONBYNAME("closeBtn");
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _flipBtn = GETDEFINITIONBYNAME("itemRotateBtnCont");
         _flipBtn.addEventListener("mouseDown",onFlipBtn,false,0,true);
         _flipBtnVer = GETDEFINITIONBYNAME("itemRotateBtnCont");
         _flipBtnVer.rotation = 90;
         _flipBtnVer.addEventListener("mouseDown",onFlipBtn,false,0,true);
         _linkBtn = GETDEFINITIONBYNAME("portalLinkBtnCont");
         _linkBtn.addEventListener("mouseDown",onLinkBtn,false,0,true);
         release();
         _lastItemInvId = -1;
      }
      
      public function release() : void
      {
         _isWaitingToSetItemsForFirstTime = true;
         if(_currItems)
         {
            for each(var _loc1_ in _currItems.getCoreArray())
            {
               if(_loc1_.denItemHelper)
               {
                  _loc1_.denItemHelper.destroy();
               }
            }
         }
         _currItems = new DenStateItemCollection();
         _itemsInit = new DenStateItemCollection();
         _savedDenItemHelpers = [];
         _lastSelectedItem = null;
         _dragItem = null;
         updateCloseBtn();
      }
      
      public function clearDen() : void
      {
         release();
         var _loc1_:DenStateItem = new DenStateItem(617,-1,40435715,0,0,0,50,0,0,3,0,4,0,0,0,"MusDenDef",0,"",0,0,"","",-1,"",false,null,0,0,null,null,2);
         setItem(_loc1_);
      }
      
      public function get numberOfInitItems() : int
      {
         return _itemsInit.length;
      }
      
      public function get numberOfInUseItems() : int
      {
         return _currItems.length;
      }
      
      public function get isDragging() : Boolean
      {
         return _dragItem != null;
      }
      
      public function get lastSelectedItem() : DenStateItem
      {
         return _lastSelectedItem;
      }
      
      public function reloadItems() : void
      {
         var _loc1_:int = 0;
         if(_savedDenItemHelpers)
         {
            _loc1_ = 0;
            while(_loc1_ < _savedDenItemHelpers.length)
            {
               itemLoaded(_savedDenItemHelpers[_loc1_],true);
               _loc1_++;
            }
         }
      }
      
      public function updateConsumers(param1:Dictionary) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         for each(var _loc4_ in _currItems.getCoreArray())
         {
            for(_loc2_ in param1)
            {
               if(_loc4_.invIdx == _loc2_)
               {
                  if(!(_loc4_.ecoConsumerStateId == 0 && param1[_loc2_] == 2))
                  {
                     if(!(_loc4_.ecoConsumerStateId == 2 && param1[_loc2_] == 0))
                     {
                        if(_loc4_.ecoConsumerStateId != 2)
                        {
                           sendMouseEventToItem(_loc4_.denItemHelper.content as MovieClip);
                        }
                        else if(param1[_loc2_] != 2)
                        {
                           sendMouseEventToItem(_loc4_.denItemHelper.content as MovieClip);
                        }
                     }
                  }
                  _loc4_.ecoConsumerStateId = param1[_loc2_];
               }
            }
         }
         var _loc5_:DenItemCollection = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            for(_loc2_ in param1)
            {
               if(_loc5_.getDenItem(_loc3_).invIdx == _loc2_)
               {
                  _loc5_.getDenItem(_loc3_).ecoConsumerStateId = param1[_loc2_];
                  break;
               }
            }
            _loc3_++;
         }
         AvatarManager.playerAvatar.inventoryDenPartial.denItemCollection = _loc5_;
         _loc5_ = AvatarManager.playerAvatar.inventoryDenFull.denItemCollection;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            for(_loc2_ in param1)
            {
               if(_loc5_.getDenItem(_loc3_).invIdx == _loc2_)
               {
                  _loc5_.getDenItem(_loc3_).ecoConsumerStateId = param1[_loc2_];
                  break;
               }
            }
            _loc3_++;
         }
         gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc5_;
      }
      
      public function setItems(param1:DenStateItemCollection, param2:Boolean = false) : void
      {
         var _loc8_:DenStateItem = null;
         var _loc4_:* = null;
         var _loc3_:Boolean = false;
         var _loc7_:int = 0;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc10_:DenStateItem = null;
         var _loc9_:Boolean = false;
         if(_isWaitingToSetItemsForFirstTime && param2)
         {
            _isWaitingToSetItemsForFirstTime = false;
         }
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            _loc8_ = param1.getDenStateItem(_loc7_);
            if(_loc8_)
            {
               if(_loc8_.catId > 0)
               {
                  _loc3_ = false;
                  for each(_loc4_ in _currItems.getCoreArray())
                  {
                     if(_loc8_.refId == _loc4_.refId && _loc8_.invIdx == _loc4_.invIdx)
                     {
                        _loc4_.flipped = _loc8_.flipped;
                        _loc5_ = _loc8_.x + _loc4_.offsetX;
                        _loc6_ = _loc8_.y + _loc4_.offsetY;
                        setItemMatrix(_loc4_,_loc5_,_loc6_,_loc4_.flipped);
                        if(_loc4_.sortCatId == 99 && _loc4_.denItemHelper)
                        {
                           _loc4_.denItemHelper.setVersion(_loc8_.version,_loc8_.version2,_loc8_.version3);
                        }
                        if(_loc4_.specialType == 1)
                        {
                           _loc4_.userNameLink = _loc8_.userNameLink;
                           if(_loc4_.denItemHelper && _loc4_.denItemHelper.content && _loc4_.denItemHelper.content.hasOwnProperty("active"))
                           {
                              if(_loc4_.userNameLink != "")
                              {
                                 Object(_loc4_.denItemHelper.content).active(true);
                              }
                              else
                              {
                                 Object(_loc4_.denItemHelper.content).active(false);
                              }
                           }
                           BuddyList.destroyInWorldBuddyList();
                        }
                        if(_loc4_.uniqueImageId != _loc8_.uniqueImageId)
                        {
                           _loc4_.uniqueImageId = _loc8_.uniqueImageId;
                           _loc4_.uniqueImageCreator = _loc8_.uniqueImageCreator;
                           if(_loc4_.denItemHelper)
                           {
                              (_loc4_.denItemHelper as DenItemHelper).uniqueImageId = _loc4_.uniqueImageId;
                              (_loc4_.denItemHelper as DenItemHelper).uniqueImageCreator = _loc4_.uniqueImageCreator;
                              (_loc4_.denItemHelper as DenItemHelper).loadUniqueImage();
                           }
                        }
                        if(_loc4_.specialType == 4)
                        {
                           if(!_loc4_.mannequinData.compare(_loc8_.mannequinData,true))
                           {
                              _loc4_.mannequinData.copyFromOther(_loc8_.mannequinData);
                           }
                        }
                        _loc4_.ecoConsumerStateId = _loc8_.ecoConsumerStateId;
                        _loc3_ = true;
                        break;
                     }
                  }
                  if(!_loc3_)
                  {
                     _loc10_ = _loc8_.clone();
                     _loc10_.userAction = param2;
                     setItem(_loc10_);
                  }
               }
               else
               {
                  for each(_loc4_ in _currItems.getCoreArray())
                  {
                     if(_loc8_.refId == _loc4_.refId && _loc8_.invIdx == _loc4_.invIdx)
                     {
                        releaseItem(_loc4_,param2);
                        if(_loc4_.specialType == 5)
                        {
                           ShopManager.ifShopToSellOpenCloseIt();
                        }
                        break;
                     }
                  }
               }
            }
            _loc7_++;
         }
         for each(_loc4_ in _currItems.getCoreArray())
         {
            if(_loc4_.sortCatId == 4)
            {
               _loc9_ = true;
               break;
            }
         }
         if(!_loc9_)
         {
            _loc8_ = new DenStateItem(0,-1,40435715,0,0,0,50,0,0,3,0,4,0,0,0,"MusDenDef",0,"",0,0,"","",-1,"",param2,null,0,0,null,null,2);
            setItem(_loc8_);
         }
         if(!param2)
         {
            updateInitialState();
         }
         if(_isWaitingToSetItemsForFirstTime)
         {
            _isWaitingToSetItemsForFirstTime = false;
         }
      }
      
      public function rebuildMannequins() : void
      {
         var _loc1_:* = null;
         for each(_loc1_ in _currItems.getCoreArray())
         {
            if(_loc1_.mannequinData != null)
            {
               _loc1_.mannequinData.refreshAvatarItems();
            }
         }
      }
      
      public function removeAccessoryAndRebuildMannequin(param1:DenItem, param2:int, param3:int) : void
      {
         var _loc6_:DenStateItem = null;
         var _loc5_:int = 0;
         var _loc4_:Boolean = false;
         for each(_loc6_ in _currItems.getCoreArray())
         {
            if(_loc6_.mannequinData != null && _loc6_.invIdx == param2)
            {
               _loc6_.mannequinData.hasThisInvIdOnAndRemove(param3);
               _loc6_.mannequinData.refreshAvatarItems();
               _loc4_ = true;
               break;
            }
         }
         if(!_loc4_)
         {
            _loc6_ = new DenStateItem(param1.defId,param1.invIdx,param1.defId << 16 | param1.categoryId,0,0,param1.version,param1.version2,param1.version3,0,param1.categoryId,param1.refId,param1.sortId,param1.minigameDefId,param1.layerId,param1.enviroType,param1.strmName,0,"",param1.specialType,param1.listId,param1.uniqueImageId,param1.uniqueImageCreator,param1.uniqueImageCreatorDbId,param1.uniqueImageCreatorUUID,false,null,0,0,param1.petItem,param1.mannequinData,param1.ecoConsumerStateId);
            _loc5_ = 0;
            while(_loc5_ < _itemsInit.length)
            {
               if(_itemsInit.getDenStateItem(_loc5_).mannequinData != null && _itemsInit.getDenStateItem(_loc5_).mannequinData.invIdx == param2)
               {
                  _loc4_ = true;
                  _itemsInit.setDenStateItem(_loc5_,_loc6_.clone());
                  break;
               }
               _loc5_++;
            }
            if(!_loc4_)
            {
               _itemsInit.pushDenStateItem(_loc6_.clone());
            }
         }
      }
      
      public function removeItem(param1:int, param2:int) : void
      {
         for each(var _loc3_ in _currItems.getCoreArray())
         {
            if(_loc3_.refId == param2 && _loc3_.invIdx == param1)
            {
               releaseItem(_loc3_);
               break;
            }
         }
      }
      
      public function saveState(param1:int = -1) : void
      {
         var _loc2_:* = null;
         var _loc13_:* = null;
         var _loc7_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc4_:Object = null;
         var _loc9_:* = null;
         var _loc8_:int = 0;
         var _loc5_:DenItemHolderEvent = null;
         var _loc3_:Array = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc6_:Array = [];
         for each(_loc2_ in _itemsInit.getCoreArray())
         {
            _loc7_ = false;
            for each(_loc13_ in _currItems.getCoreArray())
            {
               if(_loc13_.refId == _loc2_.refId && _loc13_.invIdx == _loc2_.invIdx)
               {
                  _loc7_ = true;
                  if(_loc13_.sortCatId != 4 && (_loc13_.x != _loc2_.x || _loc13_.y != _loc2_.y || _loc13_.flipped != _loc2_.flipped || _loc13_.userNameLink != _loc2_.userNameLink || _loc13_.uniqueImageId != _loc2_.uniqueImageId || _loc13_.uniqueImageCreator != _loc2_.uniqueImageCreator || _loc13_.mannequinData == null && _loc2_.mannequinData != null || _loc13_.mannequinData != null && !_loc13_.mannequinData.compare(_loc2_.mannequinData,true)))
                  {
                     if(_loc13_.mannequinData == null && _loc2_.mannequinData != null || _loc13_.mannequinData != null && !_loc13_.mannequinData.compare(_loc2_.mannequinData,true))
                     {
                        _loc12_ = true;
                     }
                     _loc6_.push({
                        "di":_loc13_.denItemHelper,
                        "f":_loc13_.flipped,
                        "i":_loc13_.invIdx,
                        "x":_loc13_.x,
                        "s":_loc13_.sortCatId,
                        "y":_loc13_.y,
                        "offX":_loc13_.offsetX,
                        "offY":_loc13_.offsetY,
                        "r":_loc13_.refId,
                        "userNameLink":_loc13_.userNameLink,
                        "uniqueImageId":_loc13_.uniqueImageId,
                        "uniqueImageCreator":_loc13_.uniqueImageCreator,
                        "mannequinData":_loc13_.mannequinData
                     });
                  }
                  break;
               }
            }
            if(!_loc7_)
            {
               _loc6_.push({
                  "f":0,
                  "i":_loc2_.invIdx,
                  "s":_loc2_.sortCatId,
                  "x":0,
                  "y":0,
                  "d":0,
                  "r":_loc2_.refId,
                  "userNameLink":"",
                  "uniqueImageId":"",
                  "uniqueImageCreator":"",
                  "mannequinData":_loc2_.mannequinData
               });
            }
         }
         for each(_loc13_ in _currItems.getCoreArray())
         {
            _loc7_ = false;
            for each(_loc2_ in _itemsInit.getCoreArray())
            {
               if(_loc2_.refId == _loc13_.refId && _loc2_.invIdx == _loc13_.invIdx)
               {
                  _loc7_ = true;
                  break;
               }
            }
            if(!_loc7_)
            {
               _loc6_.push({
                  "f":_loc13_.flipped,
                  "di":_loc13_.defId,
                  "i":_loc13_.invIdx,
                  "s":_loc13_.sortCatId,
                  "x":_loc13_.x,
                  "y":_loc13_.y,
                  "offX":_loc13_.offsetX,
                  "offY":_loc13_.offsetY,
                  "r":_loc13_.refId,
                  "userNameLink":_loc13_.userNameLink,
                  "uniqueImageId":_loc13_.uniqueImageId,
                  "uniqueImageCreator":_loc13_.uniqueImageCreator,
                  "mannequinData":_loc13_.mannequinData
               });
            }
         }
         if(_loc6_.length > 0)
         {
            updateInitialState();
            if(param1 != -1)
            {
               _loc8_ = 0;
               while(_loc8_ < _loc6_.length)
               {
                  if(_loc6_[_loc8_].i == param1)
                  {
                     _loc6_.push(_loc6_[_loc8_]);
                     _loc6_.splice(_loc8_,1);
                     break;
                  }
                  _loc8_++;
               }
            }
            _loc5_ = new DenItemHolderEvent("OnSaveState");
            _loc3_ = [];
            for each(_loc9_ in _loc6_)
            {
               if(_loc9_.i != -1)
               {
                  if(_loc9_.di)
                  {
                     _loc10_ = _loc9_.x - _loc9_.offX;
                     _loc11_ = _loc9_.y - _loc9_.offY;
                     _loc4_ = {
                        "i":_loc9_.i,
                        "s":_loc9_.s,
                        "d":1,
                        "x":_loc10_,
                        "y":_loc11_,
                        "f":_loc9_.f,
                        "r":_loc9_.r,
                        "userNameLink":_loc9_.userNameLink,
                        "uniqueImageId":_loc9_.uniqueImageId,
                        "uniqueImageCreator":_loc9_.uniqueImageCreator,
                        "mannequinData":_loc9_.mannequinData
                     };
                  }
                  else
                  {
                     _loc4_ = {
                        "i":_loc9_.i,
                        "s":_loc9_.s,
                        "d":0,
                        "x":0,
                        "y":0,
                        "f":0,
                        "r":_loc9_.r,
                        "userNameLink":_loc9_.userNameLink,
                        "uniqueImageId":_loc9_.uniqueImageId,
                        "uniqueImageCreator":_loc9_.uniqueImageCreator,
                        "mannequinData":_loc9_.mannequinData
                     };
                  }
                  _loc3_.push(_loc4_);
               }
            }
            _loc5_.array = _loc3_;
            _loc5_.hasUpdates = _loc12_;
            dispatchEvent(_loc5_);
         }
      }
      
      public function removeHighlightState() : void
      {
         if(_closeBtn.parent)
         {
            _closeBtn.parent.removeChild(_closeBtn);
         }
         if(_flipBtn.parent)
         {
            _flipBtn.parent.removeChild(_flipBtn);
         }
         if(_linkBtn.parent)
         {
            _linkBtn.parent.removeChild(_linkBtn);
         }
         if(_itemFilter)
         {
            if(_itemFilter.denItemHelper.displayObject)
            {
               _itemFilter.denItemHelper.displayObject.filters = [];
            }
            _itemFilter = null;
         }
      }
      
      private function updateInitialState() : void
      {
         _itemsInit = new DenStateItemCollection();
         for each(var _loc1_ in _currItems.getCoreArray())
         {
            _itemsInit.pushDenStateItem(_loc1_.clone());
         }
      }
      
      public function handleMouse(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:DenStateItem = null;
         if(param3)
         {
            if(_dragItem)
            {
               if(_dragItem.specialType == 1)
               {
                  if(BuddyList.isOverWorldBuddyList(param1,param2))
                  {
                     RoomManagerWorld.instance.forceMouseUp();
                     return;
                  }
               }
               _loc5_ = _dragItem.x + param1 - _dragPoint.x;
               _loc4_ = _dragItem.y + param2 - _dragPoint.y;
               setItemMatrix(_dragItem,_loc5_,_loc4_,_dragItem.flipped);
               setBtnPos(_loc5_ + _dragItem.denItemHelper.contentWidth - 30,_loc4_);
               _dragPoint.x = param1;
               _dragPoint.y = param2;
            }
         }
         else
         {
            if(_dragItem && _dragItem.specialType == 1)
            {
               _loc6_ = hitTest(param1,param2);
               if(BuddyList.isOverWorldBuddyList(param1,param2))
               {
                  return;
               }
               if(_loc6_ != _dragItem)
               {
                  BuddyList.closeWorldBuddyList();
                  _dragItem = _loc6_;
               }
            }
            else
            {
               _dragItem = hitTest(param1,param2);
            }
            if(_dragItem)
            {
               _dragPoint.x = param1;
               _dragPoint.y = param2;
            }
            updateCloseBtn();
         }
      }
      
      public function setThemePosition(param1:int, param2:int) : void
      {
         _themePos = new Point(param1,param2);
      }
      
      public function setRoomMode(param1:int) : void
      {
         _roomMode = param1;
         stopListenersOnPets(_roomMode == 1);
         stopMouseOnNonMouseItems(_roomMode == 1);
      }
      
      public function stopListenersOnPets(param1:Boolean) : void
      {
         for each(var _loc2_ in _currItems.getCoreArray())
         {
            if(_loc2_.denItemHelper && _loc2_.denItemHelper.content && _loc2_.denItemHelper.content.hasOwnProperty("listenToMouse"))
            {
               if(_loc2_.specialType != 7)
               {
                  Object(_loc2_.denItemHelper.content).listenToMouse = !param1;
               }
            }
         }
      }
      
      public function stopMouseOnNonMouseItems(param1:Boolean) : void
      {
         for each(var _loc2_ in _currItems.getCoreArray())
         {
            if(_loc2_.denItemHelper && _loc2_.denItemHelper.content && _loc2_.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely") && _loc2_.denItemHelper.displayObject)
            {
               Sprite(_loc2_.denItemHelper.displayObject).mouseEnabled = !param1;
               Sprite(_loc2_.denItemHelper.displayObject).mouseChildren = !param1;
            }
         }
      }
      
      public function shouldStopMovement(param1:Point) : Boolean
      {
         var _loc5_:DenStateItem = null;
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc2_:int = int(_currItems.length);
         if(_loc2_ > 0)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc5_ = _currItems.getDenStateItem(_loc4_);
               if(!isTheme(_loc5_.sortCatId) && _loc5_.sortCatId != 4)
               {
                  if(_loc5_.denItemHelper.displayObject.numChildren > 0)
                  {
                     _loc3_ = Loader(_loc5_.denItemHelper.displayObject.getChildAt(0)).content as MovieClip;
                     if(_loc3_.parent.name == "moveToDisabled")
                     {
                        if(_loc3_.hitTestPoint(param1.x,param1.y,true))
                        {
                           return true;
                        }
                     }
                  }
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      public function portalItemTest(param1:Boolean, param2:Point) : void
      {
         var _loc4_:int = 0;
         var _loc7_:DenStateItem = null;
         var _loc6_:int = 0;
         var _loc3_:Sprite = null;
         var _loc5_:Object = null;
         if(!RoomXtCommManager.isSwitching)
         {
            _loc4_ = int(_currItems.length);
            if(_loc4_ > 0)
            {
               _loc6_ = 0;
               while(_loc6_ < _loc4_)
               {
                  _loc7_ = _currItems.getDenStateItem(_loc6_);
                  if(_loc7_.specialType == 1 && _loc7_.userNameLink != "" || _loc7_.specialType == 3)
                  {
                     if(_loc7_.denItemHelper.content)
                     {
                        if(param1)
                        {
                           if(Object(_loc7_.denItemHelper.displayObject.getChildAt(0)).content.clickObject.hitTestPoint(param2.x,param2.y,true))
                           {
                              _loc3_ = Sprite(Object(_loc7_.denItemHelper.displayObject.getChildAt(0)).content.radiusObject);
                              _itemToEnterInvId = _loc7_.invIdx;
                              _itemRadiusBmpData = new BitmapData(_loc3_.width,_loc3_.height);
                              _itemRadiusBmpData.draw(_loc3_);
                           }
                           else
                           {
                              _itemToEnterInvId = -1;
                              if(_itemRadiusBmpData)
                              {
                                 _itemRadiusBmpData.dispose();
                                 _itemRadiusBmpData = null;
                              }
                           }
                           _lastItemInvId = -1;
                        }
                        if(_itemToEnterInvId == _loc7_.invIdx)
                        {
                           _loc5_ = Object(_loc7_.denItemHelper.content).getRadiusObject();
                           if(!AvatarManager.playerAvatarWorldView.bmpDataHitTest(_itemRadiusBmpData,new Point(_loc7_.x + _loc5_.x,_loc7_.y + _loc5_.y)))
                           {
                              return;
                           }
                           if(_lastItemInvId == _loc7_.invIdx)
                           {
                              return;
                           }
                           if(_lastItemInvId == -1)
                           {
                              if(_loc7_.specialType == 3)
                              {
                                 DenXtCommManager.requestDenPhantom(AvatarManager.playerAvatarWorldView.isPhantom ? 0 : 1);
                              }
                              else
                              {
                                 RoomXtCommManager.sendRoomJoinRequest("den" + _loc7_.userNameLink,_loc7_.invIdx);
                              }
                              _lastItemInvId = _loc7_.invIdx;
                              return;
                           }
                        }
                     }
                  }
                  _loc6_++;
               }
            }
         }
         _lastItemInvId = -1;
      }
      
      private function isTheme(param1:int) : Boolean
      {
         return param1 > 1 && param1 < 4;
      }
      
      private function setItem(param1:DenStateItem) : void
      {
         var _loc4_:DenItemHolderEvent = null;
         var _loc2_:DenItemHolderEvent = null;
         var _loc3_:DenItemHelper = new DenItemHelper();
         if(isTheme(param1.sortCatId))
         {
            for each(var _loc5_ in _currItems.getCoreArray())
            {
               if(_loc5_.sortCatId == param1.sortCatId)
               {
                  releaseItem(_loc5_);
                  _loc4_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc4_.id = _loc5_.invIdx;
                  _loc4_.refId = _loc5_.refId;
                  _loc4_.array = [_loc5_];
                  dispatchEvent(_loc4_);
                  break;
               }
            }
         }
         else if(param1.sortCatId == 4)
         {
            for each(var _loc6_ in _currItems.getCoreArray())
            {
               if(_loc6_.sortCatId == param1.sortCatId)
               {
                  releaseItem(_loc6_);
                  _loc2_ = new DenItemHolderEvent("OnItemRemoved");
                  _loc2_.id = _loc6_.invIdx;
                  _loc2_.refId = _loc6_.refId;
                  _loc2_.array = [_loc6_];
                  dispatchEvent(_loc2_);
                  break;
               }
            }
            RoomManagerWorld.instance.playMusic(param1.strmName + ".mp3",param1.version2 / 100);
         }
         param1.denItemHelper = _loc3_;
         _currItems.pushDenStateItem(param1);
         _loc3_.initDS(param1,itemLoaded);
         if(_roomMode == 1)
         {
            if(param1.denItemHelper && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("listenToMouse"))
            {
               Object(param1.denItemHelper.content).listenToMouse = false;
            }
         }
         else if(param1.denItemHelper && param1.denItemHelper.displayObject && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely"))
         {
            Sprite(param1.denItemHelper.displayObject).mouseEnabled = false;
            Sprite(param1.denItemHelper.displayObject).mouseChildren = false;
         }
         if(param1.denItemHelper && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("active"))
         {
            if(param1.userNameLink != "")
            {
               Object(param1.denItemHelper.content).active(true);
            }
            else
            {
               Object(param1.denItemHelper.content).active(false);
            }
         }
         if(param1.minigameDefId > 0 || param1.listLauncherId > 0 || _loc3_.isUniqueImageItem)
         {
            addListenersToItem(_loc3_,param1);
         }
         else if(param1.specialType == 1)
         {
            addPortalListenersToItem(_loc3_,param1);
         }
         else if(param1.specialType == 2)
         {
            _loc3_.setupItemWithEmotes(param1);
         }
         else if(param1.defId == 3192 || param1.defId == 3193 || param1.defId == 3250 || param1.defId == 3585)
         {
            addListenersToItem(_loc3_,param1);
         }
         else if(param1.defId >= 3312 && param1.defId <= 3319)
         {
            addListenersToItem(_loc3_,param1);
         }
         else if(param1.specialType == 5)
         {
            addListenersToItem(_loc3_,param1);
         }
         else if(RoomManagerWorld.instance.isMyDen)
         {
            if(param1.defId == 3216)
            {
               addListenersToItem(_loc3_,param1);
            }
            else if(param1.specialType == 4)
            {
               addListenersToItem(_loc3_,param1);
            }
            else if(param1.specialType == 6)
            {
               addListenersToItem(_loc3_,param1);
            }
            else if(param1.specialType == 7)
            {
               if(param1.denItemHelper && param1.denItemHelper.content && param1.denItemHelper.content.hasOwnProperty("listenToMouse"))
               {
                  Object(param1.denItemHelper.content).listenToMouse = false;
               }
               addListenersToItem(_loc3_,param1);
            }
         }
         if(_isWaitingToSetItemsForFirstTime || !param1.userAction)
         {
            _itemsInit.pushDenStateItem(param1.clone());
         }
      }
      
      private function updateCloseBtn() : void
      {
         if(_dragItem)
         {
            if(_closeBtn.parent != _dragItem.denItemHelper.displayObject)
            {
               setBtnPos(_dragItem.x + _dragItem.denItemHelper.contentWidth - 30,_dragItem.y);
               _layerManager.room_chat.addChild(_closeBtn);
               _layerManager.room_chat.addChild(_flipBtn);
               _layerManager.room_chat.addChild(_flipBtnVer);
               if(_dragItem.specialType == 1)
               {
                  _layerManager.room_chat.addChild(_linkBtn);
               }
               else if(_linkBtn.parent)
               {
                  _linkBtn.parent.removeChild(_linkBtn);
                  BuddyList.closeWorldBuddyList();
               }
            }
            if(_itemFilter != _dragItem)
            {
               if(_itemFilter)
               {
                  _itemFilter.denItemHelper.displayObject.filters = [];
               }
               _itemFilter = _dragItem;
               _itemFilter.denItemHelper.displayObject.filters = [new GlowFilter(16777215,1,8,8,8)];
            }
         }
         else
         {
            if(_closeBtn.parent)
            {
               _closeBtn.parent.removeChild(_closeBtn);
            }
            if(_flipBtn.parent)
            {
               _flipBtn.parent.removeChild(_flipBtn);
            }
            if(_flipBtnVer.parent)
            {
               _flipBtnVer.parent.removeChild(_flipBtnVer);
            }
            if(_linkBtn.parent)
            {
               _linkBtn.parent.removeChild(_linkBtn);
               BuddyList.closeWorldBuddyList();
            }
            if(_itemFilter)
            {
               if(_itemFilter.denItemHelper.displayObject)
               {
                  _itemFilter.denItemHelper.displayObject.filters = [];
               }
               _itemFilter = null;
            }
         }
      }
      
      private function setBtnPos(param1:Number, param2:Number) : void
      {
         _closeBtn.x = param1;
         _closeBtn.y = param2;
         _flipBtn.x = param1 + 15;
         _flipBtn.y = param2 + 55;
         _flipBtnVer.x = param1 + 15;
         _flipBtnVer.y = param2 + 90;
         _linkBtn.x = param1 + 15;
         _linkBtn.y = param2 + 125;
         BuddyList.updateWorldBuddyListPosition(_linkBtn);
      }
      
      private function onCloseBtn(param1:Event) : void
      {
         var _loc2_:DenItemHolderEvent = null;
         param1.stopPropagation();
         if(_dragItem)
         {
            _loc2_ = new DenItemHolderEvent("OnItemRemoved");
            _loc2_.id = _dragItem.invIdx;
            _loc2_.refId = _dragItem.refId;
            _loc2_.array = [_dragItem];
            releaseItem(_dragItem);
            _dragItem = null;
            updateCloseBtn();
            dispatchEvent(_loc2_);
         }
      }
      
      private function onFlipBtn(param1:Event) : void
      {
         param1.stopPropagation();
         if(_dragItem)
         {
            if(param1.currentTarget == _flipBtn)
            {
               _dragItem.flipped = !BitUtility.isBitSetForNumber(0,_dragItem.flipped) ? _dragItem.flipped ^ 1 : _dragItem.flipped ^ 1;
               setItemMatrix(_dragItem,_dragItem.x,_dragItem.y,_dragItem.flipped);
            }
            else if(param1.currentTarget == _flipBtnVer)
            {
               if(!BitUtility.isBitSetForNumber(1,_dragItem.flipped))
               {
                  _dragItem.flipped |= 2;
               }
               else
               {
                  _dragItem.flipped = !BitUtility.isBitSetForNumber(1,_dragItem.flipped) ? _dragItem.flipped | 2 : _dragItem.flipped ^ 2;
               }
               setItemMatrix(_dragItem,_dragItem.x,_dragItem.y,_dragItem.flipped);
            }
         }
      }
      
      private function onLinkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_dragItem)
         {
            BuddyList.buildInWorldBuddyList(_linkBtn,_dragItem,onSelectUserToLink,_dragItem.userNameLink);
         }
      }
      
      private function onSelectUserToLink(param1:String) : void
      {
         if(_dragItem)
         {
            _dragItem.userNameLink = param1;
            if(_dragItem.denItemHelper && _dragItem.denItemHelper.content && _dragItem.denItemHelper.content.hasOwnProperty("active"))
            {
               if(param1 != "")
               {
                  Object(_dragItem.denItemHelper.content).active(true);
               }
               else
               {
                  Object(_dragItem.denItemHelper.content).active(false);
               }
            }
         }
      }
      
      private function isInInitList(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < _itemsInit.length)
         {
            if(_itemsInit.getDenStateItem(_loc3_).refId == param2 && _itemsInit.getDenStateItem(_loc3_).invIdx == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function releaseItem(param1:DenStateItem, param2:Boolean = true) : void
      {
         var _loc3_:int = int(_currItems.getCoreArray().indexOf(param1));
         if(_loc3_ >= 0)
         {
            _currItems.getCoreArray().splice(_loc3_,1);
            if(param1.defId)
            {
               if(param1.denItemHelper.displayObject.parent)
               {
                  param1.denItemHelper.displayObject.parent.removeChild(param1.denItemHelper.displayObject);
               }
               if(param1.denItemHelper.minigameDefId > 0 || param1.denItemHelper.listLauncherId > 0 || param1.denItemHelper.uniqueImageId != "")
               {
                  removeListenersFromItem(param1.denItemHelper);
               }
               else if(param1.specialType == 1)
               {
                  removePortalListenersFromItem(param1.denItemHelper);
               }
               else if(param1.defId == 3192 || param1.defId == 3193 || param1.defId == 3250 || param1.defId == 3585)
               {
                  removeListenersFromItem(param1.denItemHelper);
               }
               else if(param1.defId >= 3312 && param1.defId <= 3319)
               {
                  removeListenersFromItem(param1.denItemHelper);
               }
               else if(RoomManagerWorld.instance.isMyDen)
               {
                  if(param1.defId == 3216)
                  {
                     removeListenersFromItem(param1.denItemHelper);
                  }
                  else if(param1.specialType == 4)
                  {
                     removeListenersFromItem(param1.denItemHelper);
                     if(param1.mannequinData && !param2)
                     {
                        param1.mannequinData.removeItems();
                     }
                  }
               }
               else if(param1.specialType == 5)
               {
                  removeListenersFromItem(param1.denItemHelper);
               }
               if(param1.specialType == 1)
               {
                  removePortalListenersFromItem(param1.denItemHelper);
                  _lastItemInvId = -1;
                  _itemToEnterInvId = -1;
               }
               if(_itemRadiusBmpData)
               {
                  _itemRadiusBmpData.dispose();
                  _itemRadiusBmpData = null;
               }
            }
         }
         if(!param2)
         {
            _loc3_ = 0;
            while(_loc3_ < _itemsInit.length)
            {
               if(_itemsInit.getDenStateItem(_loc3_).invIdx == param1.invIdx)
               {
                  _itemsInit.getCoreArray().splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
         _lastSelectedItem = null;
      }
      
      private function setItemMatrix(param1:DenStateItem, param2:Number, param3:Number, param4:int) : void
      {
         var _loc14_:Sprite = null;
         var _loc10_:Loader = null;
         var _loc13_:MovieClip = null;
         var _loc11_:Matrix = null;
         var _loc12_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:DisplayObject = param1.denItemHelper.displayObject;
         param1.x = param2;
         param1.y = param3;
         var _loc9_:Matrix = _loc5_.transform.matrix;
         _loc9_.identity();
         var _loc6_:* = param2;
         var _loc7_:* = param3;
         if(param1.denItemHelper.bFlipLabel)
         {
            _loc14_ = _loc5_ as Sprite;
            _loc10_ = _loc14_.getChildAt(0) as Loader;
            _loc13_ = _loc10_.content as MovieClip;
            _loc13_.gotoAndStop(BitUtility.isBitSetForNumber(0,param4) ? "flip" : 1);
            if(BitUtility.isBitSetForNumber(1,param4))
            {
               _loc7_ += _loc5_.height;
               _loc6_ += _loc5_.width;
            }
         }
         else if(param4 > 0)
         {
            if(BitUtility.isBitSetForNumber(0,param4))
            {
               _loc6_ += _loc5_.width;
            }
            if(BitUtility.isBitSetForNumber(1,param4))
            {
               if(param1.denItemHelper.isUniqueImageItem)
               {
                  _loc7_ += _loc5_.height * 0.8;
                  if(!BitUtility.isBitSetForNumber(0,param4))
                  {
                     _loc6_ += _loc5_.width;
                  }
                  else
                  {
                     _loc6_ -= _loc5_.width;
                  }
               }
               else
               {
                  _loc7_ += _loc5_.height;
                  if(!BitUtility.isBitSetForNumber(0,param4))
                  {
                     _loc6_ += _loc5_.width;
                  }
                  else
                  {
                     _loc6_ -= _loc5_.width;
                  }
               }
            }
            _loc9_.scale(BitUtility.isBitSetForNumber(0,param4) ? -1 : 1,1);
         }
         if(param1.denItemHelper.isUniqueImageItem)
         {
            _loc11_ = Object(param1.denItemHelper.content).item1.imageCont.transform.matrix;
            _loc12_ = Math.abs(_loc11_.b);
            _loc8_ = Math.abs(_loc11_.a);
            _loc11_.a = 1;
            _loc11_.b = 1;
            _loc11_.a = BitUtility.isBitSetForNumber(0,param4) ? -1 : 1;
            _loc11_.b = BitUtility.isBitSetForNumber(0,param4) ? -1 : 1;
            _loc11_.a *= _loc8_;
            _loc11_.b *= _loc12_;
            Object(param1.denItemHelper.content).item1.imageCont.transform.matrix = _loc11_;
         }
         _loc9_.translate(_loc6_,_loc7_);
         _loc5_.transform.matrix = _loc9_;
         if(BitUtility.isBitSetForNumber(1,param4))
         {
            _loc5_.rotation = 180;
         }
         else
         {
            _loc5_.rotation = 0;
         }
      }
      
      private function hitTest(param1:int, param2:int) : DenStateItem
      {
         var _loc3_:* = null;
         var _loc7_:int = 0;
         var _loc9_:DenStateItem = null;
         var _loc6_:DisplayObject = null;
         var _loc4_:Rectangle = null;
         var _loc10_:Number = NaN;
         var _loc8_:* = -999999999;
         var _loc11_:int = 99999999;
         var _loc5_:int = int(_currItems.length);
         while(_loc7_ < _loc5_)
         {
            _loc9_ = _currItems.getDenStateItem(_loc7_);
            if(!isTheme(_loc9_.sortCatId))
            {
               _loc6_ = _loc9_.denItemHelper.displayObject;
               _loc4_ = _loc6_.getBounds(_layerManager.room_avatars);
               _loc4_.height = Math.max(105,_loc4_.height);
               _loc10_ = _loc4_.bottom - Number(_loc6_.name);
               if(param1 > _loc4_.left && param1 < _loc4_.right && param2 > _loc4_.top && param2 < _loc4_.bottom)
               {
                  if(_loc9_.layerId <= _loc11_)
                  {
                     if(_loc9_.layerId == 1 || _loc10_ > _loc8_)
                     {
                        _loc11_ = _loc9_.layerId;
                        _loc8_ = _loc10_;
                        _loc3_ = _loc9_;
                        if(_loc11_ == 1)
                        {
                           _loc8_ = -999999999;
                        }
                     }
                  }
               }
            }
            _loc7_++;
         }
         return _loc3_;
      }
      
      private function itemLoaded(param1:DenItemHelper, param2:Boolean = false) : void
      {
         var _loc8_:* = null;
         var _loc3_:Sprite = null;
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:SortLayer = null;
         if(!param2)
         {
            _savedDenItemHelpers.push(param1);
         }
         for each(var _loc9_ in _currItems.getCoreArray())
         {
            if(_loc9_.denItemHelper == param1)
            {
               _loc8_ = _loc9_;
               break;
            }
         }
         if(_loc8_ && _loc8_.sortCatId != 4)
         {
            _loc3_ = param1.displayObject;
            _loc8_.offsetX = -(param1.contentWidth * 0.5);
            _loc8_.offsetY = -param1.contentHeight;
            if(param2)
            {
               _loc8_.x -= _loc8_.offsetX;
               _loc8_.y -= _loc8_.offsetY;
            }
            _loc5_ = _loc8_.x + _loc8_.offsetX;
            _loc7_ = _loc8_.y + _loc8_.offsetY;
            _loc4_ = _loc8_.newPlaced;
            if(_loc8_.newPlaced)
            {
               _loc7_ += param1.contentHeight * 0.5;
               _loc8_.newPlaced = false;
            }
            if(_roomMode == 1 || _loc8_.specialType == 7)
            {
               if(_loc8_.denItemHelper && _loc8_.denItemHelper.content && _loc8_.denItemHelper.content.hasOwnProperty("listenToMouse"))
               {
                  Object(_loc8_.denItemHelper.content).listenToMouse = false;
               }
            }
            else if(_loc3_ && _loc8_.denItemHelper && _loc8_.denItemHelper.content && _loc8_.denItemHelper.content.hasOwnProperty("ignoreMouseCompletely"))
            {
               Sprite(_loc3_).mouseEnabled = false;
               Sprite(_loc3_).mouseChildren = false;
            }
            if(_loc8_.denItemHelper && _loc8_.denItemHelper.content && _loc8_.denItemHelper.content.hasOwnProperty("active"))
            {
               if(_loc8_.userNameLink != "")
               {
                  Object(_loc8_.denItemHelper.content).active(true);
               }
               else
               {
                  Object(_loc8_.denItemHelper.content).active(false);
               }
            }
            if(_loc8_.denItemHelper)
            {
               if(_loc8_.denItemHelper.isUniqueImageItem)
               {
                  addListenersToItem(_loc8_.denItemHelper,_loc8_);
               }
            }
            if(_loc8_.specialType == 7 && _loc8_.ecoConsumerStateId == 1)
            {
               sendMouseEventToItem(_loc8_.denItemHelper.content as MovieClip);
            }
            _loc10_ = _loc8_.layerId;
            setItemMatrix(_loc8_,_loc5_,_loc7_,_loc8_.flipped);
            if(isTheme(_loc8_.sortCatId))
            {
               _loc10_ = 100;
               _loc3_.x = 0;
               _loc3_.y = 0;
               setItemMatrix(_loc8_,0,0,0);
            }
            if(!_loc4_)
            {
               for each(var _loc6_ in _itemsInit.getCoreArray())
               {
                  if(_loc8_.refId == _loc6_.refId && _loc8_.invIdx == _loc6_.invIdx)
                  {
                     if(_loc8_.x != _loc6_.x || _loc8_.y != _loc6_.y)
                     {
                        _loc6_.x = _loc8_.x;
                        _loc6_.y = _loc8_.y;
                        _loc6_.offsetX = _loc8_.offsetX;
                        _loc6_.offsetY = _loc8_.offsetY;
                        break;
                     }
                  }
               }
            }
            switch(_loc10_)
            {
               case 1:
                  _layerManager.room_bkg_main.addChild(_loc3_);
                  break;
               case 100:
                  _layerManager.room_bkg_main.addChildAt(_loc3_,0);
                  break;
               default:
                  _loc11_ = param1.sortOffset;
                  _loc12_ = RoomManagerWorld.instance.inPreviewMode ? _layerManager.preview_room_avatar : _layerManager.room_avatars;
                  if(_loc11_)
                  {
                     _loc3_.name = String(_loc11_);
                  }
                  _loc12_.addChild(_loc3_);
            }
         }
      }
      
      private function addListenersToItem(param1:DenItemHelper, param2:DenStateItem) : void
      {
         param1.addMouseListeners(param2,onItemDown,onItemOver,onItemOut);
      }
      
      private function addPortalListenersToItem(param1:DenItemHelper, param2:DenStateItem) : void
      {
         param1.addPortalListeners(param2,onPortalItemDown,onPortalItemOver,onPortalItemOut);
      }
      
      private function removeListenersFromItem(param1:DenItemHelper) : void
      {
         param1.removeMouseListeners();
      }
      
      private function removePortalListenersFromItem(param1:DenItemHelper) : void
      {
         param1.removePortalListeners();
      }
      
      private function onItemDown(param1:MouseEvent, param2:DenItemHelper) : void
      {
         var _loc3_:Object = null;
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         _lastSelectedItem = param2.denStateItem as DenStateItem;
         if(param2.minigameDefId > 0)
         {
            _loc3_ = {
               "typeDefId":param2.minigameDefId,
               "fromMyDenItem":RoomManagerWorld.instance.isMyDen
            };
            MinigameManager.handleGameClick(_loc3_,null);
         }
         else if(param2.listLauncherId > 0)
         {
            GuiManager.openPageFlipBook(param2.listLauncherId,true,1);
         }
         else if(param2.isUniqueImageItem)
         {
            GuiManager.openMasterpiecePreview(param2.uniqueImageId,param2.uniqueImageCreator,param2.uniqueImageCreatorDbId,param2.uniqueImageCreatorUUID,param2.version,RoomManagerWorld.instance.denOwnerName,param2.currDenItem);
         }
         else if(param2.defId == 3192 || param2.defId == 3193 || param2.defId == 3250 || param2.defId == 3585)
         {
            QuestManager.showTalkingDialog(GuiManager.guiLayer,LocalizationManager.translateIdOnly(30423).split("|"),0,-1,true,PartyXtCommManager.sendJoinPartyRequest,48);
         }
         else if(param2.defId >= 3312 && param2.defId <= 3319)
         {
            switch(param2.defId - 3312)
            {
               case 0:
                  RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 1:
                  RoomXtCommManager.sendRoomJoinRequest("crystal_sands.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 2:
                  RoomXtCommManager.sendRoomJoinRequest("appondale.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 3:
                  RoomXtCommManager.sendRoomJoinRequest("sarepia.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 4:
                  RoomXtCommManager.sendRoomJoinRequest("mountains_of_shivveer.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 5:
                  RoomXtCommManager.sendRoomJoinRequest("lost_temple_of_zios.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 6:
                  RoomXtCommManager.sendRoomJoinRequest("aussie.room_main#" + RoomManagerWorld.instance.shardId);
                  break;
               case 7:
                  RoomXtCommManager.sendRoomJoinRequest("coral_canyons.room_main#" + RoomManagerWorld.instance.shardId);
            }
         }
         else if(param2.defId == 3216)
         {
            GenericListGuiManager.genericListVolumeClicked(669);
         }
         else if(param2.isMannequin)
         {
            _mannaquinDenItemHelper = param2;
            _mannaquinAvEditor = new AvatarEditor();
            _mannaquinAvEditor.init(_mannaquinDenItemHelper.mannequin.mannequinAvatarView.avatarData,GuiManager.guiLayer,onMannequinAvEditorClose,false,false,_mannaquinDenItemHelper);
         }
         else if(param2.isDenStore)
         {
            ShopManager.launchDenShopStore(_lastSelectedItem.invIdx);
         }
         else if(param2.denStateItem.specialType == 6)
         {
            _ecoScorePopup = new EcoScorePopup(onEcoPopupClose);
         }
         else if(param2.denStateItem.specialType == 7 && (param2.content as MovieClip).clickFromCode == null || (param2.content as MovieClip).clickFromCode == false)
         {
            _ecoPointsPopup = new EcoPointsPopup(param2.denStateItem,onEcoPointsPopupClose);
         }
      }
      
      private function onPortalItemDown(param1:MouseEvent, param2:DenItemHelper) : void
      {
      }
      
      private function onItemOver(param1:MouseEvent, param2:DenItemHelper) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         if(param2.isMannequin)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         var _loc3_:Sprite = Sprite(param1.currentTarget);
         GuiManager.toolTip.init(_layerManager.room_orbs,param2.minigameDefId > 0 ? MinigameManager.getGameName(param2.minigameDefId) : LocalizationManager.translateIdOnly(param2.denStateItem.denItemHelper.nameStrId),param2.denStateItem.x + _loc3_.width * 0.5,param2.denStateItem.y + _loc3_.height - 75);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPortalItemOver(param1:MouseEvent, param2:DenItemHelper) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         if(param2.denStateItem.userNameLink != "")
         {
            sendMouseEvent(param1,true);
         }
      }
      
      private function onItemOut(param1:MouseEvent) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onPortalItemOut(param1:MouseEvent) : void
      {
         if(_roomMode != 0)
         {
            return;
         }
         param1.stopPropagation();
         sendMouseEvent(param1,true);
      }
      
      private function sendMouseEvent(param1:MouseEvent, param2:Boolean = false) : void
      {
         var _loc6_:Sprite = null;
         var _loc5_:Loader = null;
         var _loc3_:MovieClip = null;
         var _loc4_:int = -1;
         switch(param1.type)
         {
            case "mouseDown":
               _loc4_ = 0;
               break;
            case "mouseOver":
               _loc4_ = 1;
               break;
            case "mouseOut":
               _loc4_ = 2;
         }
         if(_loc4_ >= 0)
         {
            if(param2)
            {
               _loc6_ = Sprite(param1.currentTarget.parent);
            }
            else
            {
               _loc6_ = Sprite(param1.currentTarget);
            }
            if(_loc6_.parent)
            {
               _loc5_ = Loader(_loc6_.getChildAt(0));
               if(_loc5_)
               {
                  _loc3_ = MovieClip(_loc5_.content);
                  if(_loc3_)
                  {
                     if(_loc3_.hasOwnProperty("handleMouse"))
                     {
                        _loc3_.handleMouse(_loc4_);
                     }
                  }
               }
            }
         }
      }
      
      private function sendMouseEventToItem(param1:MovieClip) : void
      {
         var _loc2_:Boolean = false;
         if(param1)
         {
            if(param1.hasOwnProperty("handleMouse"))
            {
               param1.handleMouse("mouseDown");
            }
            else
            {
               _loc2_ = Boolean(param1.listenToMouse);
               param1.listenToMouse = true;
               param1.clickFromCode = true;
               MovieClip(param1.item1).dispatchEvent(new MouseEvent("mouseDown"));
               param1.listenToMouse = _loc2_;
               param1.clickFromCode = false;
            }
         }
      }
      
      private function onMannequinAvEditorClose(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:DenItemCollection = null;
         var _loc4_:int = 0;
         _mannaquinAvEditor.destroy();
         _mannaquinAvEditor = null;
         if(param1)
         {
            _loc3_ = gMainFrame.userInfo.playerUserInfo.denItemsPartial;
            _loc4_ = _mannaquinDenItemHelper.denStateItem.invIdx;
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if(_loc3_.getDenItem(_loc2_).invIdx == _loc4_)
               {
                  _loc3_.getDenItem(_loc2_).mannequinData = _mannaquinDenItemHelper.mannequin.clone();
                  break;
               }
               _loc2_++;
            }
            AvatarManager.playerAvatar.inventoryDenPartial.denItemCollection = _loc3_;
            _loc3_ = AvatarManager.playerAvatar.inventoryDenFull.denItemCollection;
            _loc2_ = 0;
            while(_loc2_ < _loc3_.length)
            {
               if(_loc3_.getDenItem(_loc2_).invIdx == _loc4_)
               {
                  _loc3_.getDenItem(_loc2_).mannequinData = _mannaquinDenItemHelper.mannequin.clone();
                  break;
               }
               _loc2_++;
            }
            gMainFrame.userInfo.playerUserInfo.denItemsFull = _loc3_;
            saveState(_loc4_);
         }
         _mannaquinDenItemHelper = null;
      }
      
      private function onEcoPopupClose() : void
      {
         _ecoScorePopup.destroy();
         _ecoScorePopup = null;
         if(GuiManager.denEditor)
         {
            GuiManager.denEditor.reloadDenItems();
         }
      }
      
      private function onEcoPointsPopupClose() : void
      {
         _ecoPointsPopup.destroy();
         _ecoPointsPopup = null;
         if(GuiManager.denEditor)
         {
            GuiManager.denEditor.reloadDenItems();
         }
      }
   }
}

