package game.fallingPhantoms
{
   import avatar.Avatar;
   import avatar.AvatarXtCommManager;
   import collection.AccItemCollection;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class FallingPhantomsPlayer
   {
      private static const AI_EMOTE_NONE:int = 0;
      
      private static const AI_EMOTE_JUMP:int = 1;
      
      private static const AI_EMOTE_FALL:int = 2;
      
      public static const ANIM_JUMP_IN:int = 35;
      
      public static const ANIM_IDLE_EAST:int = 37;
      
      public var _theGame:FallingPhantoms;
      
      public var _avatar:FallingPhantomsAvatarView;
      
      public var _replacedAvatar:FallingPhantomsAvatarView;
      
      public var _animsLoaded:Boolean;
      
      public var _playerID:int;
      
      public var _dbID:int;
      
      public var _avID:int;
      
      public var _type:int;
      
      public var _colors:Array;
      
      public var _localPlayer:Boolean;
      
      public var _playerLeft:Boolean;
      
      public var _debugCircle:Sprite;
      
      public var _finishPlace:int;
      
      public var _aiGameRandomizer:RandomSeed;
      
      public var _isAI:Boolean;
      
      public var _aiProfile:FallingPhantomsAIProfile;
      
      public var _name:String;
      
      public var _playerLayer:Sprite;
      
      public var _aiRandomizer:RandomSeed;
      
      public var _currentAnim:int;
      
      public var _moveRight:Boolean;
      
      public var _moveLeft:Boolean;
      
      public var _gotoX:Number;
      
      public var _gotoTimer:Number;
      
      public var _receiveBonus:Boolean;
      
      public var _dropped:Boolean;
      
      public var _dead:Boolean;
      
      public var _gemMultiplier:int;
      
      public var _phantomThreshold:Number;
      
      public var _userName:String;
      
      public var _customAvId:int;
      
      private var _avatarArray:Array = [1,4,5,6,7,8,13,15,16,17,18,23,24,26];
      
      public function FallingPhantomsPlayer(param1:FallingPhantoms)
      {
         super();
         _theGame = param1;
         _currentAnim = -1;
      }
      
      public function replacePlayer(param1:FallingPhantomsPlayer) : void
      {
         if(param1._avatar && param1._avatar.parent)
         {
            param1._avatar.parent.removeChild(param1._avatar);
            _avatar.parent.removeChild(_avatar);
            if(_replacedAvatar == null)
            {
               _replacedAvatar = _avatar;
            }
            else
            {
               _avatar.destroy();
            }
            _avatar = param1._avatar;
            _playerLayer.addChild(_avatar);
         }
         _finishPlace = param1._finishPlace;
      }
      
      public function setupHumanPlayer(param1:int, param2:Boolean, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:String, param11:String, param12:int) : void
      {
         _userName = param11;
         _name = param10;
         _isAI = false;
         _avatar = null;
         _localPlayer = param2;
         _playerID = param1;
         _dbID = param3;
         _avID = param4;
         _type = param5;
         _colors = new Array(param6,param7,param8);
         _gotoX = param9;
         _customAvId = param12;
      }
      
      public function setupAIPlayer(param1:int, param2:int, param3:int, param4:String) : void
      {
         _name = param4;
         _isAI = true;
         _aiGameRandomizer = new RandomSeed(param1);
         _avatar = null;
         _localPlayer = true;
         _playerID = param2;
         _dbID = -1;
         _avID = -1;
         _customAvId = -1;
      }
      
      public function prepareForStart(param1:int) : void
      {
         if(_replacedAvatar != null)
         {
            if(_avatar)
            {
               if(_avatar.parent)
               {
                  _avatar.parent.removeChild(_avatar);
               }
               _avatar.destroy();
               _avatar = null;
            }
            _avatar = _replacedAvatar;
            _replacedAvatar = null;
            _playerLayer.addChild(_avatar);
         }
         if(_playerLayer)
         {
            _playerLayer.visible = true;
         }
      }
      
      private function pickRandomColors() : void
      {
         var _loc1_:uint = uint(PaletteHelper.avatarPalette1[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc4_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette2.length)]);
         var _loc5_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc8_:uint = uint(PaletteHelper.avatarPalette2[_aiGameRandomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc2_:Array = _avatar.avatarData.colors;
         var _loc3_:uint = uint(_loc2_[0]);
         var _loc6_:uint = uint(_loc2_[1]);
         var _loc7_:uint = uint(_loc2_[2]);
         _loc3_ = uint(_loc1_ << 24 | _loc4_ << 16 | (_loc3_ >> 8 & 0xFF) << 8 | _loc3_ & 0xFF);
         _loc6_ = uint(_loc5_ << 24 | (_loc6_ >> 16 & 0xFF) << 16 | (_loc6_ >> 8 & 0xFF) << 8 | _loc6_ & 0xFF);
         _loc7_ = uint(_loc8_ << 24 | (_loc7_ >> 16 & 0xFF) << 16 | (_loc7_ >> 8 & 0xFF) << 8 | _loc7_ & 0xFF);
         _avatar.avatarData.colors = [_loc3_,_loc6_,_loc7_];
      }
      
      private function pickEyeAndPattern() : void
      {
         var _loc1_:Item = null;
         var _loc3_:int = 0;
         var _loc4_:Vector.<Item> = new Vector.<Item>();
         var _loc2_:Vector.<Item> = new Vector.<Item>();
         if(_avatar.avatarData.inventoryBodyMod != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _avatar.avatarData.inventoryBodyMod.numItems)
            {
               _loc1_ = _avatar.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_);
               if(_loc1_.layerId == 2)
               {
                  _loc2_.push(_loc1_);
               }
               else if(_loc1_.layerId == 3)
               {
                  _loc4_.push(_loc1_);
               }
               _loc3_++;
            }
            if(_loc2_.length > 0)
            {
               _loc1_ = _loc2_[_aiGameRandomizer.integer(_loc2_.length)];
               if(!_loc1_.getInUse(_avatar.avInvId))
               {
                  _loc1_.forceInUse(true);
                  _avatar.avatarData.accStateShowAccessory(_loc1_);
               }
            }
            if(_loc4_.length > 0)
            {
               _loc1_ = _loc4_[_aiGameRandomizer.integer(_loc4_.length)];
               if(!_loc1_.getInUse(_avatar.avInvId))
               {
                  _loc1_.forceInUse(true);
                  _avatar.avatarData.accStateShowAccessory(_loc1_);
               }
            }
         }
      }
      
      public function pickRandomClothingItemByLayer(param1:int) : Item
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Item = null;
         var _loc4_:Item = null;
         var _loc5_:int = 0;
         _loc3_ = _aiGameRandomizer.integer(_theGame._availableItems.length);
         _loc2_ = 0;
         while(_loc2_ < _theGame._availableItems.length)
         {
            _loc4_ = _theGame._availableItems[_loc3_];
            _loc5_ = _aiGameRandomizer.integer(_theGame._availableItemColors[_loc4_.defId].length);
            _loc4_.color = _theGame._availableItemColors[_loc4_.defId][_loc5_];
            if(_loc4_.type == 1 && _loc4_.layerId == param1)
            {
               _loc6_ = new Item();
               _loc6_.init(_loc4_.defId,_loc4_.invIdx,_loc4_.color,EquippedAvatars.forced());
               return _loc6_;
            }
            _loc3_++;
            if(_loc3_ >= _theGame._availableItems.length)
            {
               _loc3_ = 0;
            }
            _loc2_++;
         }
         return null;
      }
      
      public function initAIAccessories() : void
      {
         var _loc3_:AccItemCollection = null;
         var _loc1_:int = 0;
         var _loc2_:Item = null;
         if(_isAI)
         {
            _loc3_ = new AccItemCollection();
            _loc1_ = 0;
            while(_loc1_ < _avatar.avatarData.inventoryBodyMod.numItems)
            {
               _loc3_.pushAccItem(_avatar.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc1_));
               _loc1_++;
            }
            if(_aiGameRandomizer.integer(100) > 20)
            {
               _loc2_ = pickRandomClothingItemByLayer(5);
               if(_loc2_ != null)
               {
                  _loc3_.pushAccItem(_loc2_);
               }
            }
            if(_aiGameRandomizer.integer(100) > 20)
            {
               _loc2_ = pickRandomClothingItemByLayer(6);
               if(_loc2_ != null)
               {
                  _loc3_.pushAccItem(_loc2_);
               }
            }
            if(_aiGameRandomizer.integer(100) > 20)
            {
               _loc2_ = pickRandomClothingItemByLayer(8);
               if(_loc2_ == null)
               {
                  _loc2_ = pickRandomClothingItemByLayer(9);
                  if(_loc2_ == null)
                  {
                     _loc2_ = pickRandomClothingItemByLayer(10);
                  }
               }
               if(_loc2_ != null)
               {
                  _loc3_.pushAccItem(_loc2_);
               }
            }
            if(_loc3_.length > _avatar.avatarData.inventoryBodyMod.numItems)
            {
               _avatar.avatarData.itemResponseIntegrate(_loc3_);
            }
            pickRandomColors();
            pickEyeAndPattern();
         }
      }
      
      public function initFinalize(param1:String = null) : void
      {
         var _loc2_:Array = null;
         if(_avatar != null)
         {
            _avatar.InitFallingPhantomsAvatarView();
            _playerLayer.addChild(_avatar);
            if(_localPlayer && !_isAI)
            {
               _playerLayer.parent.setChildIndex(_playerLayer,_playerLayer.parent.numChildren - 1);
            }
            if(_isAI)
            {
               initAIAccessories();
            }
            _loc2_ = new Array(2);
            _loc2_[0] = 14;
            _loc2_[1] = 9;
            _avatar.preloadAnims(_loc2_,redrawCallback);
         }
      }
      
      private function isSafe(param1:Number) : Boolean
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < _theGame._phantoms.length)
         {
            _loc2_ = _theGame._phantoms[_loc7_];
            if(_loc2_.y > _phantomThreshold)
            {
               _loc6_ = 0;
               do
               {
                  _loc4_ = _loc2_.rectangle.x - _loc2_.velX * _loc6_ * 0.04;
                  _loc5_ = 520 - _loc2_.velY * _loc6_ * 0.04;
                  if(520 - _loc5_ >= (_loc2_.rectangle.height + _avatar.rectangle.height) * 0.5)
                  {
                     break;
                  }
                  if(Math.abs(_loc4_ - param1) < (_loc2_.rectangle.width + _avatar.rectangle.width + 40) * 0.5)
                  {
                     return false;
                  }
                  _loc6_++;
               }
               while(_loc6_ < 10);
               
            }
            _loc7_++;
         }
         return true;
      }
      
      private function setGoto() : void
      {
         if(_aiProfile)
         {
            if(_aiProfile._type == 0)
            {
               _gotoX = _aiGameRandomizer.float(30,870);
               _gotoTimer = _aiGameRandomizer.float(1,5);
            }
            else if(_aiProfile._type == 1)
            {
               findSafeGoto();
            }
            else
            {
               findSafeGoto();
            }
         }
         if(_gotoX < _avatar.x)
         {
            _moveLeft = true;
            _moveRight = false;
         }
         else if(_gotoX > _avatar.x)
         {
            _moveRight = true;
            _moveLeft = false;
         }
         else
         {
            _moveRight = _moveLeft = false;
         }
      }
      
      private function findSafeGoto() : void
      {
         var _loc1_:Number = NaN;
         var _loc4_:int = 0;
         var _loc8_:Array = null;
         var _loc3_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:int = 0;
         var _loc2_:* = 0;
         if(_aiProfile._type == 1)
         {
            _loc1_ = 0;
         }
         else if(_aiProfile._type == 2)
         {
            _loc1_ = 150;
         }
         if(!isSafe(_avatar.x))
         {
            _loc8_ = [];
            _loc3_ = _aiGameRandomizer.float(0,20);
            _loc4_ = 0;
            _loc5_ = 0;
            do
            {
               _loc7_ = _avatar.rectangle.width * _loc4_ * 0.5 + _loc3_ + 30;
               if(_loc7_ < 870)
               {
                  _loc8_[_loc5_] = {};
                  _loc8_[_loc5_].x = _loc7_;
                  _loc8_[_loc5_].distance = Math.abs(_avatar.x - _loc8_[_loc5_].x);
                  _loc5_++;
               }
               _loc4_++;
            }
            while(_loc7_ < 870);
            
            if(_theGame._phantoms.length > 1)
            {
               _loc8_.sortOn("distance",[16]);
            }
            else
            {
               randomizeArray(_loc8_);
            }
            _loc4_ = 0;
            while(_loc4_ < _loc8_.length)
            {
               _loc2_ = _loc4_;
               if(isSafe(_loc8_[_loc2_].x))
               {
                  break;
               }
               _loc2_ = -1;
               _loc4_++;
            }
            if(_loc2_ >= 0)
            {
               _gotoX = Math.min(Math.max(_loc8_[_loc2_].x,30),870);
            }
            else
            {
               _gotoX = _avatar.x;
            }
         }
         else
         {
            _gotoX = _avatar.x;
         }
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         var _loc5_:Number = param1.length - 1;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc2_ = Math.round(_aiGameRandomizer.random() * _loc5_);
            _loc3_ = param1[_loc4_];
            param1[_loc4_] = param1[_loc2_];
            param1[_loc2_] = _loc3_;
            _loc4_++;
         }
         return param1;
      }
      
      public function init(param1:Sprite) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Avatar = new Avatar();
         _avatar = new FallingPhantomsAvatarView();
         _avatar.init(_loc3_);
         _playerLayer = param1;
         _playerLayer.visible = false;
         _playerLeft = false;
         if(_aiGameRandomizer)
         {
            _avatar.x = _aiGameRandomizer.float(30,870);
            _gotoTimer = _aiGameRandomizer.float(0.01,1);
            _gotoX = _avatar.x;
            _phantomThreshold = _aiGameRandomizer.float(150,250);
         }
         else
         {
            _avatar.x = _gotoX;
         }
         _avatar.y = 525;
         _avatar.rectangle = new Shape();
         _avatar.rectangle.graphics.beginFill(16711680);
         _avatar.rectangle.graphics.drawRect(-35,-50,70,100);
         _avatar.rectangle.graphics.endFill();
         _avatar.rectangle.alpha = 0.4;
         _playerLayer.addChild(_avatar.rectangle);
         _avatar.rectangle.visible = _theGame._showBBs;
         if(_isAI)
         {
            _loc2_ = int(_avatarArray[_aiGameRandomizer.integer(0,_avatarArray.length - 1)]);
            _loc3_.init(-1,-1,"FallingPhantomsAI",_loc2_,[0,0,0]);
            _loc3_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(_loc2_,0,0,false));
         }
         else if(_avID != -1)
         {
            _loc3_.init(_avID,-1,"FallingPhantoms",_type,_colors,_customAvId,null,_userName);
            AvatarXtCommManager.requestADForAvatar(_avID,true,initFinalize,_loc3_);
         }
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _avatar)
         {
            playAnimationState(14);
            _animsLoaded = true;
         }
      }
      
      public function receivePositionData(param1:int, param2:int) : void
      {
         _avatar.x = param1;
         if(param2 == 0)
         {
            _moveLeft = true;
            _moveRight = false;
         }
         else if(param2 == 1)
         {
            _moveRight = true;
            _moveLeft = false;
         }
         else
         {
            _moveLeft = _moveRight = false;
         }
      }
      
      public function remove(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         if(_avatar && !_dead)
         {
            if(!param1)
            {
               _loc2_ = GETDEFINITIONBYNAME("fallingPhantoms_deathPath");
               _theGame._layerPlayer.addChild(_loc2_ as DisplayObject);
               _loc2_.x = _avatar.x;
               _loc2_.y = _avatar.y;
               _loc2_.deathAnimation.addChild(_avatar);
               _avatar.y = 0;
               _avatar.x = 0;
               _loc2_.gotoAndPlay("die");
               _dead = true;
               _theGame._soundMan.playByName(_theGame._soundNameFPStingerDeath);
            }
            else
            {
               _avatar.rectangle.parent.removeChild(_avatar.rectangle);
               if(_avatar.parent)
               {
                  _avatar.parent.removeChild(_avatar);
               }
               _avatar.destroy();
               _avatar = null;
            }
         }
         if(_replacedAvatar)
         {
            if(_replacedAvatar.parent)
            {
               _replacedAvatar.parent.removeChild(_replacedAvatar);
            }
            _replacedAvatar.destroy();
            _replacedAvatar = null;
         }
      }
      
      public function cleanup() : void
      {
         if(_avatar)
         {
            if(_avatar.rectangle && _avatar.rectangle.parent)
            {
               _avatar.rectangle.parent.removeChild(_avatar.rectangle);
            }
            if(_avatar.parent)
            {
               _avatar.parent.removeChild(_avatar);
            }
            _avatar.destroy();
            _avatar = null;
         }
      }
      
      public function heartbeatIntro(param1:Number) : Boolean
      {
         if(_avatar != null)
         {
         }
         return true;
      }
      
      public function getCollisionOffsetX() : Number
      {
         switch(_currentAnim - 9)
         {
            case 0:
               return 10 * _avatar.scaleX;
            case 5:
               return 20 * _avatar.scaleX;
            default:
               return 0;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_animsLoaded == true)
         {
            if(_localPlayer)
            {
               _avatar.rectangle.x = _avatar.x;
               _avatar.rectangle.y = _avatar.y;
               switch(_currentAnim - 9)
               {
                  case 0:
                     _avatar.rectangle.x -= getCollisionOffsetX();
                     break;
                  case 5:
                     _avatar.rectangle.x -= getCollisionOffsetX();
               }
               if(_isAI)
               {
                  if(_gotoTimer > 0)
                  {
                     _gotoTimer -= param1;
                  }
                  else
                  {
                     _loc2_ = Math.abs(_avatar.x - _gotoX);
                     move(param1,_moveLeft,_moveRight);
                     if(Math.abs(_avatar.x - _gotoX) >= _loc2_)
                     {
                        _avatar.x = _gotoX;
                        setGoto();
                        move(param1,false,false);
                     }
                  }
               }
               else
               {
                  move(param1,_theGame._leftArrow,_theGame._rightArrow);
               }
               if(_debugCircle)
               {
                  _debugCircle.x = _avatar.x;
                  _debugCircle.y = _avatar.y;
               }
            }
            else
            {
               move(param1,_moveLeft,_moveRight);
            }
         }
      }
      
      public function move(param1:Number, param2:Boolean, param3:Boolean) : void
      {
         if(param2)
         {
            _avatar.x -= param1 * 250;
            _avatar.scaleX = -1;
            playAnimationState(9);
            if(_avatar.x < 30)
            {
               _avatar.x = 30;
               playAnimationState(14);
            }
         }
         else if(param3)
         {
            _avatar.x += param1 * 250;
            _avatar.scaleX = 1;
            playAnimationState(9);
            if(_avatar.x > 870)
            {
               _avatar.x = 870;
               playAnimationState(14);
            }
         }
         else
         {
            playAnimationState(14);
         }
      }
      
      private function playAnimationState(param1:int) : void
      {
         if(_currentAnim != param1 && _avatar)
         {
            _avatar.playAnim(param1,false,0,null);
            _currentAnim = param1;
         }
      }
      
      public function setAIRandomizer(param1:int) : void
      {
         _aiRandomizer = new RandomSeed(param1);
         _aiProfile = _theGame._aiProfiles[_aiRandomizer.integer(0,_theGame._aiProfiles.length)];
      }
   }
}

