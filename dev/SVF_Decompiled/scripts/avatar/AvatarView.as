package avatar
{
   import collection.AccItemCollection;
   import com.sbi.graphics.LayerAnim;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import item.Item;
   
   public class AvatarView extends Sprite
   {
      protected var _layerAnim:LayerAnim;
      
      protected var _avatar:Avatar;
      
      protected var _skipAnimEnviroCheck:Boolean;
      
      public var avTypeChangedCallback:Function;
      
      public var onAvatarChangedCallback:Function;
      
      private var _isOffScreen:Boolean;
      
      private var _holdAnimId:int;
      
      private var _lastAnimToHappen:int;
      
      public function AvatarView()
      {
         super();
      }
      
      public function set lastAnimToHappen(param1:int) : void
      {
         _lastAnimToHappen = param1;
      }
      
      public function get lastAnimToHappen() : int
      {
         return _lastAnimToHappen;
      }
      
      public function set holdAnimId(param1:int) : void
      {
         _holdAnimId = param1;
      }
      
      public function init(param1:Avatar, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:Boolean = false) : void
      {
         _holdAnimId = 0;
         _avatar = param1;
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         avTypeChangedCallback = param2;
         onAvatarChangedCallback = param3;
         _skipAnimEnviroCheck = param5;
         _layerAnim = LayerAnim.getNew(param4);
         _layerAnim.avDefId = _avatar.avTypeId;
         if(_avatar.colors)
         {
            _layerAnim.layers = setLayerHelper();
         }
         this.addChild(_layerAnim.bitmap);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         if(param1 && _avatar)
         {
            _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
            _avatar.destroy();
            _avatar = null;
         }
         avTypeChangedCallback = null;
         onAvatarChangedCallback = null;
         LayerAnim.destroy(_layerAnim);
         _layerAnim = null;
      }
      
      public function resetAvatar(param1:Avatar) : void
      {
         if(_avatar && _avatar.hasEventListener("OnAvatarChanged"))
         {
            _avatar.removeEventListener("OnAvatarChanged",avatarChanged);
         }
         _avatar = param1;
         _avatar.addEventListener("OnAvatarChanged",avatarChanged,false,0,true);
         if(_layerAnim)
         {
            _layerAnim.avDefId = _avatar.avTypeId;
            if(_avatar.colors)
            {
               _layerAnim.layers = setLayerHelper();
            }
         }
      }
      
      public function isValid() : Boolean
      {
         return _layerAnim != null;
      }
      
      public function hideAvatar() : void
      {
         if(_layerAnim != null)
         {
            _layerAnim.visible = false;
         }
      }
      
      public function showAvatar() : void
      {
         if(_layerAnim != null)
         {
            _layerAnim.visible = true;
         }
      }
      
      public function set isOffScreen(param1:Boolean) : void
      {
         _isOffScreen = param1;
      }
      
      public function get isOffScreen() : Boolean
      {
         return _isOffScreen;
      }
      
      public function pauseAnim(param1:Boolean) : void
      {
         _layerAnim.pause = param1;
      }
      
      public function advanceFrame() : void
      {
         _layerAnim.frame++;
      }
      
      public function get frame() : int
      {
         return _layerAnim.frame;
      }
      
      public function set frame(param1:int) : void
      {
         _layerAnim.frame = param1;
      }
      
      public function get flip() : Boolean
      {
         return _layerAnim.hFlip;
      }
      
      public function get animId() : int
      {
         return _layerAnim.animId;
      }
      
      protected function avatarChanged(param1:AvatarEvent) : void
      {
         if(_layerAnim)
         {
            if(_layerAnim.avDefId != _avatar.avTypeId)
            {
               _layerAnim.avDefId = _avatar.avTypeId;
               if(avTypeChangedCallback != null)
               {
                  avTypeChangedCallback(this);
               }
            }
            _layerAnim.layers = setLayerHelper();
            if(onAvatarChangedCallback != null)
            {
               onAvatarChangedCallback(this);
            }
         }
      }
      
      protected function setLayerHelper() : Array
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_:AccItemCollection = null;
         var _loc3_:* = null;
         if(_avatar.inventoryBodyMod && _avatar.inventoryBodyMod.itemCollection && _avatar.inventoryBodyMod.itemCollection.length >= 1)
         {
            _loc3_ = new AccItemCollection(_avatar.inventoryBodyMod.itemCollection.concatCollection(_avatar.inventoryClothing.itemCollection));
         }
         else
         {
            _loc1_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatar.userName,_avatar.perUserAvId);
            if(_loc1_)
            {
               _loc2_ = _skipAnimEnviroCheck ? _loc1_.getFullItems(true) : _loc1_.getItems(true);
               if(_loc2_)
               {
                  _loc3_ = _loc2_;
               }
            }
         }
         return AvatarUtility.layerArrayForItemsAndColors(_loc3_,_avatar.colors,_avatar.avInvId,_avatar.roomType,_skipAnimEnviroCheck);
      }
      
      public function playAnim(param1:int, param2:Boolean = false, param3:int = 0, param4:Function = null, param5:Boolean = false) : void
      {
         var _loc14_:Boolean = false;
         var _loc13_:AccItemCollection = null;
         var _loc6_:int = 0;
         var _loc15_:int = 0;
         var _loc11_:Array = null;
         var _loc8_:* = null;
         var _loc10_:Object = null;
         var _loc9_:Array = null;
         var _loc7_:* = 0;
         if(_layerAnim && _layerAnim.visible && (_holdAnimId == 0 || param1 == _holdAnimId))
         {
            if(!_isOffScreen)
            {
               _loc14_ = false;
               _loc13_ = _avatar.accShownItems;
               if(!_layerAnim.layers)
               {
                  _loc14_ = true;
               }
               else if(_layerAnim.layers.length != _loc13_.length)
               {
                  _loc14_ = true;
               }
               else
               {
                  _loc6_ = int(_loc13_.length);
                  _loc15_ = 0;
                  while(_loc15_ < _loc6_)
                  {
                     if(_layerAnim.layers.indexOf(_loc13_.getAccItem(_loc15_).accId) == -1)
                     {
                        _loc14_ = true;
                        break;
                     }
                     _loc15_++;
                  }
               }
               if(_loc14_)
               {
                  _loc11_ = [];
                  _loc8_ = _loc13_;
                  _loc9_ = _avatar.colors;
                  for each(var _loc12_ in _loc8_.getCoreArray())
                  {
                     if((_loc12_.layerId <= 3 || (_skipAnimEnviroCheck || _loc12_.enviroType == _avatar.roomType || _loc12_.isLandAndOcean)) && _loc12_.getInUse(_avatar.avInvId))
                     {
                        if(_loc12_.layerId == 1)
                        {
                           _loc7_ = uint(_loc9_[0]);
                        }
                        else if(_loc12_.layerId == 2)
                        {
                           _loc7_ = uint(_loc9_[1]);
                        }
                        else if(_loc12_.layerId == 3)
                        {
                           _loc7_ = uint(_loc9_[2]);
                        }
                        else
                        {
                           if(param5)
                           {
                              continue;
                           }
                           _loc7_ = _loc12_.color;
                        }
                        _loc10_ = {
                           "l":_loc12_.accId,
                           "c":_loc7_
                        };
                        _loc11_.push(_loc10_);
                     }
                  }
                  _layerAnim.layers = _loc11_;
               }
               _layerAnim.hFlip = param2;
               _layerAnim.playAnim(param1,param3,param4);
            }
            else
            {
               _lastAnimToHappen = param1;
            }
         }
      }
      
      public function reloadItemsFromCache() : void
      {
         var _loc1_:AccItemCollection = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_avatar.userName,_avatar.perUserAvId).getItems(true);
         _avatar.itemResponseIntegrate(_loc1_,_skipAnimEnviroCheck);
      }
      
      public function preloadAnims(param1:Array, param2:Function = null) : void
      {
         _layerAnim.preload(param1,param2);
      }
      
      public function blackOut() : void
      {
         var _loc1_:Array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0];
         _layerAnim.bitmap.filters = [new ColorMatrixFilter(_loc1_)];
      }
      
      public function get avatarData() : Avatar
      {
         return _avatar;
      }
      
      public function get userName() : String
      {
         if(_avatar != null)
         {
            return _avatar.userName;
         }
         return null;
      }
      
      public function get userId() : int
      {
         if(_avatar == null)
         {
            return -1;
         }
         return _avatar.sfsUserId;
      }
      
      public function get avTypeId() : int
      {
         return _avatar.avTypeId;
      }
      
      public function get customAvId() : int
      {
         return _avatar.customAvId;
      }
      
      public function get perUserAvId() : int
      {
         return _avatar.perUserAvId;
      }
      
      public function get avInvId() : int
      {
         return _avatar.avInvId;
      }
      
      public function get inventoryBodyModItems() : AccItemCollection
      {
         return _avatar.inventoryBodyMod.itemCollection;
      }
      
      public function get inventoryClothingItems() : AccItemCollection
      {
         return _avatar.inventoryClothing.itemCollection;
      }
      
      public function setAvtColors(param1:Array) : void
      {
         _avatar.colors = param1;
      }
      
      public function get avName() : String
      {
         return _avatar.avName;
      }
      
      public function get accShownItems() : AccItemCollection
      {
         return _avatar.accShownItems;
      }
   }
}

