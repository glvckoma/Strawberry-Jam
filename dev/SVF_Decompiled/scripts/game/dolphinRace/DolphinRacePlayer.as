package game.dolphinRace
{
   import avatar.Avatar;
   import avatar.AvatarXtCommManager;
   import collection.AccItemCollection;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import game.MinigameManager;
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class DolphinRacePlayer
   {
      public static const SOUND_SURFACE_TYPE_OFF:int = 0;
      
      public static const SOUND_SURFACE_TYPE_DEFAULT:int = 1;
      
      public static const SOUND_SURFACE_TYPE_MUD:int = 2;
      
      public static const SOUND_SURFACE_TYPE_WATER:int = 3;
      
      public static const SOUND_SURFACE_TYPE_WEEDS:int = 4;
      
      public static const SOUND_SURFACE_TYPE_HAY:int = 5;
      
      private static const HURDLE_BUFFER_AMOUNT:int = 100;
      
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      private static const AI_EMOTE_NONE:int = 0;
      
      private static const AI_EMOTE_JUMP:int = 1;
      
      private static const AI_EMOTE_FALL:int = 2;
      
      public static const SPEED_BOOST_TIMER:Number = 1.5;
      
      public static const MAX_SPEED_BOOST:int = 575;
      
      public static const MAX_SPEED_RUN:int = 425;
      
      public static const MAX_SPEED_FALL:int = 200;
      
      public static const MAX_SPEED_FINISH:int = 200;
      
      public static const BOOST_ACCELERATION:int = 450;
      
      public static const RUN_ACCELERATION:int = 150;
      
      public static const SLOWDOWN_ACCELERATION:int = 650;
      
      public static const STOP_ACCELERATION:int = 350;
      
      public static const JUMP_TIMER:Number = 1.1;
      
      public static const DIVE_TIMER:Number = 1;
      
      public static const ANIM_MOVE:int = 29;
      
      public static const ANIM_JUMP_IN:int = 40;
      
      public static const ANIM_DIVE_IN:int = 41;
      
      public static const ANIM_IDLE_EAST:int = 32;
      
      public static const ANIM_DANCE:int = 38;
      
      private static const _defaultcolors:Array = [1761558272,1718173440,338181888,1063862016];
      
      public var _maxRunSpeed:int = 425;
      
      public var _theGame:DolphinRace;
      
      public var _avatar:DolphinRaceAvatarView;
      
      public var _replacedAvatar:DolphinRaceAvatarView;
      
      public var _animsLoaded:Boolean;
      
      public var _jumpingDivingTimer:Number;
      
      public var _jumpType:Boolean;
      
      public var _playerID:int;
      
      public var _dbID:int;
      
      public var _avID:int;
      
      public var _colors:Array;
      
      public var _trackLane:int;
      
      public var _localPlayer:Boolean;
      
      public var _trackX:Number;
      
      public var _actualX:Number;
      
      public var _startX:Number;
      
      public var _introSpeed:Number;
      
      public var _debugCircle:Sprite;
      
      public var _speedX:Number;
      
      public var _updatePositionTimer:Number;
      
      public var _serverPositionX:Number;
      
      public var _serverVelocityX:Number;
      
      public var _prevPosY:Number;
      
      public var _timeElapsed:Number;
      
      public var _serverPositionY:Number;
      
      public var _trackLayer:MovieClip;
      
      public var _trackRipple:MovieClip;
      
      public var _raceCompleteState:int;
      
      public var _finishPlace:int;
      
      public var _aiGameRandomizer:RandomSeed;
      
      public var _aiRaceRandomizer:RandomSeed;
      
      public var _isAI:Boolean;
      
      public var _aiProfile:DolphinRaceAIProfile;
      
      public var _aiJumpDiveDetector:Number;
      
      public var _name:String;
      
      public var _userName:String;
      
      public var _upcomingHurdleIndex:int;
      
      public var _emote:MovieClip;
      
      public var _aiEmoteTimer:Number;
      
      public var _aiStartLineJumpDiveTimer:Number;
      
      public var _aiEmoteType:int;
      
      public var _laneMarkerIndex:int;
      
      public var _aiHurdleDecide:Array;
      
      public var _speedBoostTimer:Number;
      
      public var _perfectRace:Boolean;
      
      public var _soundSurfaceType:int;
      
      public var _moveAnimationLooped:Boolean;
      
      public var _absoluteX:Number;
      
      public var _playerMarker:Object;
      
      public var _ringCounter:int;
      
      public var _upArrow:Boolean;
      
      public var _downArrow:Boolean;
      
      public var _velY:Number;
      
      public var _waterLevel:Number;
      
      public var _jumpState:int;
      
      public var _customAvId:int;
      
      private var _myGlow:GlowFilter;
      
      private var _accelY:Number = 1000;
      
      private var _gravity:Number = 2000;
      
      private var _exitBoost:Number = 300;
      
      private var _enterBrake:Number = 300;
      
      private var _waterFriction:Number = 0.01;
      
      public function DolphinRacePlayer(param1:DolphinRace)
      {
         super();
         _theGame = param1;
      }
      
      public function getPositionX() : Number
      {
         return _absoluteX;
      }
      
      public function setPositionX(param1:Number) : void
      {
         _absoluteX = param1;
      }
      
      public function resetY() : void
      {
         _trackLayer.parent.y = _waterLevel;
         _serverPositionY = _prevPosY = _waterLevel;
         _timeElapsed = 0;
         _jumpState = 0;
      }
      
      public function replacePlayer(param1:DolphinRacePlayer) : void
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
            _trackLayer.addChild(_avatar);
         }
         _absoluteX = param1._absoluteX;
         _laneMarkerIndex = param1._laneMarkerIndex;
         _jumpingDivingTimer = param1._jumpingDivingTimer;
         _trackX = param1._trackX;
         _actualX = param1._actualX;
         _startX = param1._startX;
         _introSpeed = param1._introSpeed;
         _speedX = param1._speedX;
         _updatePositionTimer = param1._updatePositionTimer;
         _serverPositionX = param1._serverPositionX;
         _serverVelocityX = param1._serverVelocityX;
         _raceCompleteState = param1._raceCompleteState;
         _finishPlace = param1._finishPlace;
         _upcomingHurdleIndex = param1._upcomingHurdleIndex;
         _aiEmoteTimer = 0;
         _aiStartLineJumpDiveTimer = 0;
         _aiEmoteType = 0;
         _aiJumpDiveDetector = 0;
         _soundSurfaceType = param1._soundSurfaceType;
         _ringCounter = param1._ringCounter;
         if(_avatar)
         {
            _avatar.visible = true;
         }
      }
      
      public function setupHumanPlayer(param1:int, param2:Boolean, param3:int, param4:int, param5:int, param6:int, param7:int, param8:int, param9:String, param10:String, param11:int) : void
      {
         _name = param9;
         _userName = param10;
         _isAI = false;
         _avatar = null;
         _raceCompleteState = 0;
         _serverPositionX = param8;
         _localPlayer = param2;
         _playerID = param1;
         _dbID = param3;
         _avID = param4;
         _colors = new Array(param5,param6,param7);
         _customAvId = param11;
         if(_localPlayer)
         {
            _myGlow = new GlowFilter();
            _myGlow.color = 16769024;
            _myGlow.blurX = 5;
            _myGlow.blurY = 5;
            _myGlow.strength = 1.2;
         }
      }
      
      public function setupAIPlayer(param1:int, param2:int, param3:int, param4:String) : void
      {
         _name = param4;
         _isAI = true;
         _aiGameRandomizer = new RandomSeed(param1);
         _avatar = null;
         _raceCompleteState = 0;
         _serverPositionX = param3;
         _localPlayer = true;
         _playerID = param2;
         _dbID = -1;
         _avID = -1;
         _aiEmoteTimer = 0;
         _aiStartLineJumpDiveTimer = 0;
         _aiHurdleDecide = [];
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
            _trackLayer.addChild(_avatar);
         }
         if(_avatar)
         {
            _avatar.visible = true;
            _trackRipple.visible = true;
            _trackRipple.splash.visible = true;
            _trackRipple.effects.visible = false;
         }
         _aiEmoteTimer = Math.random() * 30;
         _laneMarkerIndex = 0;
         _aiJumpDiveDetector = 0;
         _upcomingHurdleIndex = 0;
         _startX = param1;
         _raceCompleteState = 0;
         _jumpingDivingTimer = 0;
         _speedX = 0;
         _serverPositionX = _startX;
         _serverVelocityX = 0;
         _actualX = _startX;
         setPositionX(-100);
         _introSpeed = (0.2 + Math.random() * 0.2) * 425;
         _speedBoostTimer = 0;
         _playerMarker.pMarkerBoostOff();
         _ringCounter = 0;
         _theGame.updatePearl(_ringCounter);
         _perfectRace = true;
         if(_animsLoaded)
         {
            playAnimationState(29);
         }
      }
      
      public function start() : void
      {
         _aiEmoteType = 0;
         if(_jumpingDivingTimer <= 0)
         {
            playAnimationState(29);
            _soundSurfaceType = 1;
         }
         else
         {
            _soundSurfaceType = 0;
         }
      }
      
      public function percentComplete() : Number
      {
         if(_raceCompleteState > 0)
         {
            return 1;
         }
         return (getPositionX() - _startX) / _theGame._trackLength;
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
            _avatar.InitDolphinRaceAvatarView();
            _trackLayer.addChild(_avatar);
            _emote = GETDEFINITIONBYNAME("DolphinRace_emote_popup");
            _avatar.addChild(_emote);
            if(_isAI)
            {
               initAIAccessories();
            }
            _loc2_ = new Array(6);
            _loc2_[0] = 40;
            _loc2_[1] = 29;
            _loc2_[2] = 32;
            _loc2_[3] = 38;
            _loc2_[4] = 41;
            _avatar.preloadAnims(_loc2_,redrawCallback);
         }
      }
      
      public function init(param1:MovieClip, param2:int, param3:MovieClip) : void
      {
         var _loc4_:Avatar = new Avatar();
         _avatar = new DolphinRaceAvatarView();
         _avatar.init(_loc4_);
         _soundSurfaceType = 0;
         _trackLayer = param1;
         _trackRipple = param3;
         _avatar.visible = false;
         _animsLoaded = false;
         _serverVelocityX = 0;
         _trackX = 0;
         _speedX = 0;
         _jumpingDivingTimer = 0;
         _updatePositionTimer = 0;
         _trackLane = param2;
         setPositionX(_serverPositionX);
         _avatar.x = 30;
         _avatar.y = 35;
         _velY = 0;
         _waterLevel = _trackLayer.parent.y;
         _serverPositionY = _prevPosY = _waterLevel;
         _timeElapsed = 0;
         _playerMarker = GETDEFINITIONBYNAME("DolphinRace_playerMarker");
         _playerMarker.pMarkerPlayer(1);
         _playerMarker.x = 0;
         _playerMarker.y = 0;
         _trackLayer.addChildAt(_playerMarker as DisplayObject,0);
         if(_isAI)
         {
            _loc4_.init(-1,-1,"DolphinRaceAI" + _trackLane,19,[0,0,0],_customAvId,null,"",-1,1);
            _loc4_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(19,0,0,false));
         }
         else
         {
            if(_avID != -1)
            {
               _loc4_.init(_avID,-1,"DolphinRace" + _trackLane,19,_colors,_customAvId,null,_userName,-1,1);
               AvatarXtCommManager.requestADForAvatar(_avID,true,initFinalize,_loc4_);
            }
            else
            {
               _loc4_.init(-1,-1,"DolphinRace" + _trackLane,19,[_defaultcolors[param2],_defaultcolors[param2],1073692671],_customAvId,null,"",-1,1);
               _loc4_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(19,11,2,false));
               initFinalize();
            }
            if(_localPlayer)
            {
               _avatar.filters = [_myGlow];
            }
         }
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _avatar)
         {
            playAnimationState(29);
            if(_debugCircle)
            {
               _trackLayer.addChild(_debugCircle);
            }
            _animsLoaded = true;
         }
      }
      
      public function remove() : void
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
      
      public function showEmote(param1:int) : void
      {
         if(_emote != null && param1 >= 1 && param1 <= 6)
         {
            _emote.setEmote(param1);
         }
      }
      
      public function setAIRaceRanomizer(param1:int) : void
      {
         var _loc2_:int = 0;
         _aiRaceRandomizer = new RandomSeed(param1);
         _aiProfile = _theGame._aiProfiles[_aiRaceRandomizer.integer(0,_theGame._aiProfiles.length)];
         if(_aiHurdleDecide.length > 0)
         {
            _aiHurdleDecide.splice(0,_aiHurdleDecide.length);
         }
         _loc2_ = 0;
         while(_loc2_ < 64)
         {
            _aiHurdleDecide.push(_aiRaceRandomizer.integer(100) < _aiProfile._jumpDetectionProbability);
            _loc2_++;
         }
      }
      
      public function receiveFall() : void
      {
         _serverVelocityX = 200;
      }
      
      public function receiveJump(param1:Number) : void
      {
         _jumpState = 1;
         _velY = param1;
         _prevPosY = _trackLayer.parent.y;
         _timeElapsed = 0;
      }
      
      public function receivePositionData(param1:int, param2:int, param3:int, param4:int) : void
      {
         _serverPositionX = param1;
         _serverPositionY = param2;
         _serverVelocityX = param3;
         _prevPosY = _trackLayer.parent.y;
         _timeElapsed = 0;
         if(_jumpState == 2)
         {
            _jumpState = 0;
         }
         switch(param4 - 1)
         {
            case 0:
               if(_jumpingDivingTimer <= 0)
               {
                  doJump();
               }
               break;
            case 1:
               if(_jumpingDivingTimer <= 0)
               {
                  doDive();
               }
               break;
            case 2:
               _raceCompleteState = 1;
               break;
            case 3:
               if(_raceCompleteState != 2)
               {
                  _raceCompleteState = 2;
                  if(_theGame._gameState == 5)
                  {
                     playAnimationState(38);
                  }
               }
               _soundSurfaceType = 0;
         }
      }
      
      public function updateJumptimer(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(_jumpingDivingTimer > 0)
         {
            _jumpingDivingTimer -= param1;
            if(_jumpType == true)
            {
               _loc3_ = 26;
               _loc2_ = _loc3_ - Math.round(_jumpingDivingTimer * _loc3_ / 1.1);
               if(_loc2_ <= 5)
               {
                  _loc2_ += 21;
               }
               else if(Object(_trackLayer.parent).double)
               {
                  _loc2_ = 46 - _loc3_ + _loc2_ + 1;
               }
               else
               {
                  _loc2_ = 106 - _loc3_ + _loc2_ + 1;
               }
               Object(_trackLayer.parent).gotoAndPlay(_loc2_);
            }
            else
            {
               if(Object(_trackLayer.parent).double)
               {
                  _loc3_ = 34;
                  _loc2_ = _loc3_ - Math.round(_jumpingDivingTimer * _loc3_ / 1);
                  if(_loc2_ <= 5)
                  {
                     _loc2_ += 47;
                  }
                  else
                  {
                     _loc2_ = 80 - _loc3_ + _loc2_ + 1;
                  }
               }
               else
               {
                  _loc3_ = 24;
                  _loc2_ = _loc3_ - Math.round(_jumpingDivingTimer * _loc3_ / 1);
                  if(_loc2_ <= 5)
                  {
                     _loc2_ += 47;
                  }
                  else
                  {
                     _loc2_ = 130 - _loc3_ + _loc2_ + 1;
                  }
               }
               Object(_trackLayer.parent).gotoAndPlay(_loc2_);
            }
            if(_jumpingDivingTimer <= 0 || (_trackLayer.parent as Object).ready == true)
            {
               (_trackLayer.parent as MovieClip).gotoAndPlay("idle");
               _trackRipple.gotoAndPlay("idle");
               if(_isAI)
               {
                  _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),true);
               }
               cancelJump();
            }
         }
      }
      
      public function heartbeatIntro(param1:Number) : Boolean
      {
         var _loc2_:Number = NaN;
         if(_avatar != null)
         {
            updateJumptimer(param1);
            if(getPositionX() < _startX)
            {
               _loc2_ = _introSpeed * param1;
               setPositionX(getPositionX() + _loc2_);
               if(getPositionX() >= _startX)
               {
                  setPositionX(_startX);
                  playAnimationState(32);
                  _soundSurfaceType = 0;
               }
               else
               {
                  _soundSurfaceType = 1;
               }
            }
            if(_isAI)
            {
               if(_jumpingDivingTimer <= 0)
               {
                  if(_aiStartLineJumpDiveTimer > 0)
                  {
                     _aiStartLineJumpDiveTimer -= param1;
                     if(_aiStartLineJumpDiveTimer <= 0)
                     {
                        if(Math.random() < 0.5)
                        {
                           jump(true);
                           _trackRipple.visible = false;
                           _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
                        }
                        else
                        {
                           dive(true);
                           _trackRipple.visible = false;
                           _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
                        }
                     }
                  }
                  else
                  {
                     _aiStartLineJumpDiveTimer = Math.random() * 2 + 0.25;
                  }
               }
               if(_aiEmoteTimer > 0)
               {
                  _aiEmoteTimer -= param1;
                  if(_aiEmoteTimer <= 0)
                  {
                     showEmote(Math.random() * 6 + 1);
                  }
               }
            }
            return getPositionX() == _startX;
         }
         return false;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc11_:DolphinRaceHurdle = null;
         var _loc18_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc2_:Array = null;
         var _loc13_:int = 0;
         var _loc10_:* = false;
         var _loc21_:int = 0;
         var _loc7_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc23_:MovieClip = null;
         var _loc8_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc3_:int = 0;
         var _loc16_:int = 0;
         var _loc4_:Array = null;
         var _loc20_:int = 0;
         var _loc17_:int = 0;
         var _loc22_:Number = NaN;
         var _loc14_:Boolean = false;
         var _loc5_:Number = _maxRunSpeed;
         var _loc15_:Number = 150;
         updateJumptimer(param1);
         if(_speedBoostTimer > 0)
         {
            _speedBoostTimer -= param1;
            if(_speedBoostTimer > 0)
            {
               _loc5_ = 575;
               _loc15_ = 450;
            }
            else
            {
               cancelTurbo();
            }
         }
         if(_animsLoaded == true)
         {
            _loc10_ = false;
            _avatar.heartbeat();
            if(_localPlayer)
            {
               if(_isAI)
               {
                  if(_aiEmoteTimer > 0)
                  {
                     _aiEmoteTimer -= param1;
                     if(_aiEmoteTimer <= 0)
                     {
                        _loc21_ = 0;
                        switch(_aiEmoteType - 1)
                        {
                           case 0:
                              _loc21_ = Math.random() * 4 + 1;
                              break;
                           case 1:
                              _loc21_ = Math.random() * 3 + 4;
                        }
                        if(_loc21_ >= 1 && _loc21_ <= 6)
                        {
                           showEmote(_loc21_);
                           _aiEmoteTimer = 5 + Math.random() * 4;
                        }
                        _aiEmoteType = 0;
                     }
                  }
               }
               _loc7_ = _trackLayer.parent.y;
               updateY(param1);
               if(_raceCompleteState > 0)
               {
                  if(_raceCompleteState == 1)
                  {
                     if(getPositionX() < _theGame._trackLength + _startX + 200 + 100 * _trackLane)
                     {
                        _theGame.noMotionEffects();
                        _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
                        _trackRipple.visible = false;
                        if(_speedX > 200)
                        {
                           _speedX -= param1 * 350;
                           if(_speedX < 200)
                           {
                              _speedX = 200;
                           }
                        }
                        else if(_speedX < 200)
                        {
                           _speedX += param1 * 350;
                           if(_speedX > 200)
                           {
                              _speedX = 200;
                           }
                        }
                     }
                     else
                     {
                        _soundSurfaceType = 0;
                        _raceCompleteState = 2;
                        _speedX = 0;
                        _loc14_ = true;
                        playAnimationState(38);
                        setPositionX(_theGame._trackLength + _startX + 200 + 100 * _trackLane);
                     }
                  }
               }
               else if(_speedX < _loc5_)
               {
                  _speedX += param1 * _loc15_;
                  if(_speedX > _loc5_)
                  {
                     _speedX = _loc5_;
                  }
               }
               else if(_speedX > _loc5_)
               {
                  _speedX -= param1 * 650;
                  if(_speedX < _loc5_)
                  {
                     _speedX = _loc5_;
                  }
               }
               else
               {
                  (_trackLayer.parent as Object).flickerOff();
               }
               _loc9_ = getPositionX();
               _loc19_ = _speedX * param1;
               _loc23_ = (_trackLayer.parent as Object).collision;
               _loc8_ = _loc9_ + _loc23_.x - _loc23_.width / 2;
               _loc6_ = _trackLayer.parent.y + _loc23_.y - _loc23_.height / 2;
               while(_upcomingHurdleIndex < _theGame._theHurdles.length)
               {
                  _loc11_ = _theGame._theHurdles[_upcomingHurdleIndex];
                  if(_loc8_ < _loc11_.getRightEdgeX())
                  {
                     break;
                  }
                  _upcomingHurdleIndex++;
               }
               _loc3_ = _upcomingHurdleIndex;
               _loc16_ = -1;
               _loc4_ = [false,false,false,false,false];
               while(_loc3_ < _theGame._theHurdles.length)
               {
                  _loc11_ = _theGame._theHurdles[_loc3_];
                  if(_isAI && _jumpingDivingTimer <= 0 && _raceCompleteState == 0 && _aiHurdleDecide[_upcomingHurdleIndex % _aiHurdleDecide.length])
                  {
                     _loc20_ = 0;
                     if(_aiProfile)
                     {
                        _loc20_ = _aiProfile._jumpDetectionDistance;
                     }
                     if(_loc11_._spawnX - _loc20_ >= _loc9_ && _loc11_._spawnX - _loc20_ <= _loc9_ + _loc19_)
                     {
                        if(_loc11_._type == 1)
                        {
                           _loc16_ = _loc11_._class;
                        }
                        else
                        {
                           switch(_loc11_._class)
                           {
                              case 0:
                              case 1:
                              case 2:
                              case 3:
                              case 4:
                                 _loc4_[_loc11_._class] = true;
                                 break;
                              case 5:
                                 _loc4_[1] = true;
                                 _loc4_[2] = true;
                                 break;
                              case 6:
                                 _loc4_[1] = true;
                                 _loc4_[3] = true;
                                 break;
                              case 8:
                                 _loc4_[0] = true;
                                 _loc4_[1] = true;
                                 _loc4_[2] = true;
                                 break;
                              case 9:
                                 _loc4_[4] = true;
                                 _loc4_[3] = true;
                                 _loc4_[2] = true;
                           }
                        }
                     }
                  }
                  if(_loc8_ + _loc23_.width + 2 * _loc20_ < _loc11_.getLeftEdgeX())
                  {
                     break;
                  }
                  _loc17_ = _loc11_.testCollision(_loc8_,_loc23_.width,_loc6_,_loc23_.height,_trackLane,!_isAI);
                  if(_loc17_ > 0)
                  {
                     if(!_isAI && _loc11_._debugmc)
                     {
                        if(_loc11_._type == 1)
                        {
                           _loc11_._debugmc.visible = false;
                           (_trackLayer.parent as Object).getRing();
                        }
                        else
                        {
                           _loc11_._debugmc.bump(_loc17_);
                        }
                     }
                     if(_raceCompleteState == 0)
                     {
                        if(_loc11_._type == 2)
                        {
                           handleFall();
                        }
                        else
                        {
                           _ringCounter++;
                           if(_ringCounter >= 3)
                           {
                              boost(false);
                           }
                           if(_speedBoostTimer <= 0 && _localPlayer && !_isAI)
                           {
                              _theGame.updatePearl(_ringCounter);
                           }
                        }
                        if(_isAI && _aiEmoteTimer <= 0 && Math.random() < 0.25)
                        {
                           _aiEmoteType = 2;
                           _aiEmoteTimer = Math.random() * 2;
                        }
                     }
                  }
                  _loc3_++;
               }
               if(_loc16_ == -1)
               {
                  if(_loc4_[2])
                  {
                     if(_aiRaceRandomizer.integer(100) < 50)
                     {
                        if(!_loc4_[0])
                        {
                           _loc16_ = 0;
                        }
                        else if(!_loc4_[1])
                        {
                           _loc16_ = 1;
                        }
                        else if(!_loc4_[3])
                        {
                           _loc16_ = 3;
                        }
                        else
                        {
                           _loc16_ = 4;
                        }
                     }
                     else if(!_loc4_[4])
                     {
                        _loc16_ = 4;
                     }
                     else if(!_loc4_[3])
                     {
                        _loc16_ = 3;
                     }
                     else if(!_loc4_[1])
                     {
                        _loc16_ = 1;
                     }
                     else
                     {
                        _loc16_ = 0;
                     }
                  }
               }
               if(_loc16_ != -1)
               {
                  switch(_loc16_)
                  {
                     case 0:
                        jump(true);
                        break;
                     case 1:
                        jump(true);
                        jump(false);
                        break;
                     case 3:
                        dive(true);
                        dive(false);
                        break;
                     case 4:
                        dive(true);
                  }
                  if(_aiEmoteTimer <= 0 && Math.random() < 0.25)
                  {
                     _aiEmoteType = 1;
                     _aiEmoteTimer = Math.random() * 2;
                  }
               }
               _trackX = _loc19_;
               setPositionX(getPositionX() + _trackX);
               if(_raceCompleteState == 0)
               {
                  if(getPositionX() > _theGame._trackLength + _startX)
                  {
                     _raceCompleteState = 1;
                     _loc14_ = true;
                  }
                  if(!_isAI && getPositionX() > _theGame._trackLength + _startX - 800)
                  {
                     _theGame.addFinishBuoy(950);
                  }
               }
               if(_raceCompleteState == 0 || _speedX != 0)
               {
                  _updatePositionTimer += param1;
               }
               if(_updatePositionTimer >= 0.25 || _loc14_)
               {
                  if(_isAI == false || _loc14_)
                  {
                     _loc13_ = 0;
                     _loc2_ = [];
                     _loc2_[_loc13_++] = "pos";
                     _loc2_[_loc13_++] = _isAI ? -(_playerID + 1) : _playerID + 1;
                     _loc2_[_loc13_++] = String(int(getPositionX()));
                     _loc2_[_loc13_++] = String(int(_trackLayer.parent.y));
                     _loc2_[_loc13_++] = String(int(_speedX));
                     if(_raceCompleteState > 0)
                     {
                        if(_raceCompleteState == 2)
                        {
                           _loc2_[_loc13_++] = "4";
                        }
                        else
                        {
                           _loc2_[_loc13_++] = "3";
                        }
                     }
                     else if(_jumpingDivingTimer > 0)
                     {
                        if(_jumpType == false)
                        {
                           _loc2_[_loc13_++] = "2";
                        }
                        else
                        {
                           _loc2_[_loc13_++] = "1";
                        }
                     }
                     else
                     {
                        _loc2_[_loc13_++] = "0";
                     }
                     MinigameManager.msg(_loc2_);
                     _updatePositionTimer = 0;
                  }
                  _loc10_ = _speedX > 0;
               }
            }
            else
            {
               if(_raceCompleteState > 0)
               {
                  if(_raceCompleteState == 1)
                  {
                     if(_serverVelocityX > 200)
                     {
                        _serverVelocityX -= param1 * 350;
                        if(_serverVelocityX < 200)
                        {
                           _serverVelocityX = 200;
                        }
                     }
                     else if(_serverVelocityX < 200)
                     {
                        _serverVelocityX += param1 * 350;
                        if(_serverVelocityX > 200)
                        {
                           _serverVelocityX = 200;
                        }
                     }
                  }
                  else
                  {
                     _serverVelocityX = 0;
                     _serverPositionX = _theGame._trackLength + _startX + 200 + 100 * _trackLane;
                  }
               }
               else if(_serverVelocityX < _loc5_)
               {
                  _serverVelocityX += param1 * _loc15_;
                  if(_serverVelocityX > _loc5_)
                  {
                     _serverVelocityX = _loc5_;
                  }
               }
               else if(_serverVelocityX > _loc5_)
               {
                  _serverVelocityX -= param1 * 650;
                  if(_serverVelocityX < _loc5_)
                  {
                     _serverVelocityX = _loc5_;
                  }
               }
               _serverPositionX += _serverVelocityX * param1;
               if(_serverPositionX > _theGame._trackLength + _startX + 200 + 100 * _trackLane)
               {
                  _serverPositionX = _theGame._trackLength + _startX + 200 + 100 * _trackLane;
               }
               _loc22_ = _serverPositionX - getPositionX();
               setPositionX(getPositionX() + _loc22_ * 0.25);
               _loc10_ = _serverPositionX > 0;
               interpolateY(param1);
               if(_loc10_)
               {
                  _loc9_ = getPositionX();
                  _loc23_ = (_trackLayer.parent as Object).collision;
                  _loc8_ = _loc9_ + _loc23_.x - _loc23_.width / 2;
                  _loc6_ = _trackLayer.parent.y + _loc23_.y - _loc23_.height / 2;
                  _loc3_ = _upcomingHurdleIndex;
                  while(_loc3_ < _theGame._theHurdles.length)
                  {
                     _loc11_ = _theGame._theHurdles[_loc3_];
                     if(_loc8_ + _loc23_.width < _loc11_.getLeftEdgeX())
                     {
                        break;
                     }
                     if(_loc11_.testCollision(_loc8_,_loc23_.width,_loc6_,_loc23_.height,_trackLane,false))
                     {
                        if(_loc11_._type == 2)
                        {
                           handleFall();
                        }
                     }
                     _loc3_++;
                  }
               }
            }
            _actualX = Math.min(getPositionX(),_theGame._trackLength + _startX);
         }
      }
      
      public function interpolateY(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_jumpState == 0)
         {
            _timeElapsed += param1;
            _loc3_ = Math.min(_timeElapsed / 0.25,1);
            _trackLayer.parent.y = (1 - _loc3_) * _prevPosY + _loc3_ * _serverPositionY;
         }
         else if(_jumpState == 1)
         {
            if(_trackLayer.parent.y > _waterLevel + 20)
            {
               _timeElapsed += param1;
               _loc3_ = Math.min(_timeElapsed / 0.25,1);
               _trackLayer.parent.y = (1 - _loc3_) * _prevPosY + _loc3_ * _waterLevel;
            }
            else
            {
               _velY += _gravity * param1;
               _loc2_ = _trackLayer.parent.y;
               _trackLayer.parent.y += _velY * param1;
               if(_velY > 0 && _loc2_ <= _waterLevel && _trackLayer.parent.y > _waterLevel)
               {
                  _jumpState = 2;
                  _velY -= _enterBrake;
                  if(_velY < 0)
                  {
                     _velY = 0;
                  }
                  _trackRipple.diveSplash();
               }
            }
         }
         else
         {
            if(_velY > 0)
            {
               _velY -= _accelY * param1 * _waterFriction * _velY;
               _velY = Math.max(_velY,0);
            }
            else if(_velY < 0)
            {
               _velY -= _accelY * param1 * _waterFriction * _velY;
               _velY = Math.min(_velY,0);
            }
            _trackLayer.parent.y += _velY * param1;
         }
      }
      
      public function updateY(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Array = null;
         if(_trackLayer.parent.y >= _waterLevel)
         {
            if(_upArrow && _raceCompleteState != 2)
            {
               if(_velY >= 0)
               {
                  _velY -= 100;
               }
               _velY -= _accelY * param1;
            }
            else if(_downArrow && _raceCompleteState != 2 && 450 > _trackLayer.parent.y + _velY / (_accelY * _waterFriction))
            {
               if(_velY <= 0)
               {
                  _velY += 100;
               }
               _velY += _accelY * param1;
            }
            else if(_velY > 0)
            {
               _velY -= _accelY * param1 * _waterFriction * _velY;
               _velY = Math.max(_velY,0);
            }
            else if(_velY < 0)
            {
               _velY -= _accelY * param1 * _waterFriction * _velY;
               _velY = Math.min(_velY,0);
            }
         }
         else
         {
            _velY += _gravity * param1;
         }
         var _loc3_:Number = _trackLayer.parent.y;
         _trackLayer.parent.y += _velY * param1;
         if(_loc3_ >= _waterLevel && _trackLayer.parent.y < _waterLevel)
         {
            _velY -= _exitBoost;
            _theGame._soundMan.playByName(_theGame._soundNameAJDolphinWaterExit);
            _trackRipple.jumpSplash();
            _loc4_ = 0;
            _loc2_ = [];
            _loc2_[_loc4_++] = "jump";
            _loc2_[_loc4_++] = String(int(_velY));
            MinigameManager.msg(_loc2_);
         }
         else if(_loc3_ <= _waterLevel && _trackLayer.parent.y > _waterLevel)
         {
            _velY -= _enterBrake;
            if(_velY < 0)
            {
               _velY = 0;
            }
            _theGame._soundMan.playByName(_theGame._soundNameAJDolphinWaterEnter);
            _trackRipple.diveSplash();
         }
         if(_theGame._gameState != 5)
         {
            _updatePositionTimer += param1;
            if(_updatePositionTimer >= 0.25)
            {
               _loc4_ = 0;
               _loc2_ = [];
               _loc2_[_loc4_++] = "pos";
               _loc2_[_loc4_++] = _isAI ? -(_playerID + 1) : _playerID + 1;
               _loc2_[_loc4_++] = String(int(getPositionX()));
               _loc2_[_loc4_++] = String(int(_trackLayer.parent.y));
               _loc2_[_loc4_++] = String(int(_speedX));
               _loc2_[_loc4_++] = "0";
               MinigameManager.msg(_loc2_);
               _updatePositionTimer = 0;
            }
         }
      }
      
      private function playAnimationState(param1:int) : void
      {
         var _loc2_:Function = null;
         var _loc3_:int = 0;
         _moveAnimationLooped = false;
         switch(param1 - 29)
         {
            case 0:
               _moveAnimationLooped = true;
               _loc2_ = animationAtEnd;
               break;
            case 3:
               _jumpingDivingTimer = 0;
               _speedX = 0;
               break;
            case 9:
               _jumpingDivingTimer = 0;
               _speedX = 0;
               break;
            case 11:
               _jumpingDivingTimer = 1.1;
               _loc3_ = 1;
               _loc2_ = animationAtEnd;
               _jumpType = true;
               break;
            case 12:
               _jumpingDivingTimer = 1;
               _loc3_ = 1;
               _loc2_ = animationAtEnd;
               _jumpType = false;
         }
         _avatar.playAnim(param1,false,_loc3_,_loc2_);
      }
      
      private function handleFall() : void
      {
         var _loc1_:Array = null;
         _ringCounter = 0;
         cancelTurbo();
         if(_speedX > 200)
         {
            _speedX = 200;
            (_trackLayer.parent as Object).flickerOn();
         }
         if(!_isAI && _localPlayer)
         {
            _loc1_ = [];
            _loc1_[0] = "fall";
            _loc1_[1] = _playerID + 1;
            MinigameManager.msg(_loc1_);
         }
      }
      
      private function animationAtEnd(param1:LayerAnim, param2:int) : void
      {
         if(_avatar && param1)
         {
            switch(param2 - 29)
            {
               case 0:
                  _moveAnimationLooped = true;
                  if(_localPlayer && !_isAI)
                  {
                     _theGame._soundMan.playByName(_theGame._soundNameAJDolphinSwim);
                  }
                  break;
               case 11:
                  cancelJump();
                  break;
               case 12:
                  cancelJump();
            }
         }
      }
      
      public function cancelTurbo() : void
      {
         _speedBoostTimer = 0;
         _theGame.boost(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
         if(_localPlayer && !_isAI)
         {
            _theGame.updatePearl(_ringCounter);
         }
      }
      
      public function cancelJump() : void
      {
         _jumpingDivingTimer = 0;
         if(_theGame._gameState != 5)
         {
            playAnimationState(32);
         }
      }
      
      public function boost(param1:Boolean) : void
      {
         var _loc2_:Array = null;
         if(_avatar != null)
         {
            if(!param1)
            {
               _loc2_ = [];
               _loc2_[0] = "boo";
               MinigameManager.msg(_loc2_);
            }
            if(_raceCompleteState == 0)
            {
               _speedBoostTimer = 1.5;
               _theGame.boost(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),true);
               if(_localPlayer && !_isAI)
               {
                  _theGame.updatePearl(_ringCounter);
                  _theGame._soundMan.playByName(_theGame._soundNameAJDRTurbo);
               }
               _ringCounter = 0;
            }
         }
      }
      
      public function jump(param1:Boolean) : Boolean
      {
         if(param1)
         {
            if(_avatar != null && getPositionX() >= _startX)
            {
               if(_raceCompleteState == 0 && _jumpingDivingTimer <= 0 && _avatar._bInSplashVolume == false)
               {
                  doJump();
                  return true;
               }
            }
         }
         else
         {
            (_trackLayer.parent as Object).double = false;
         }
         return false;
      }
      
      private function doJump() : void
      {
         _jumpingDivingTimer = 1.1;
         _jumpType = true;
         (_trackLayer.parent as Object).double = true;
         (_trackLayer.parent as MovieClip).gotoAndStop("jump");
         _trackRipple.jumpSplash();
         if(_isAI)
         {
            _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
         }
         if(_theGame._gameState != 5)
         {
            playAnimationState(29);
         }
      }
      
      private function doDive() : void
      {
         _jumpingDivingTimer = 1;
         _jumpType = false;
         (_trackLayer.parent as Object).double = true;
         (_trackLayer.parent as MovieClip).gotoAndStop("dive");
         _trackRipple.diveSplash();
         if(_isAI)
         {
            _theGame.setWaterEffectVisibility(parseInt(_trackLayer.parent.name.charAt(_trackLayer.parent.name.length - 1)),false);
         }
         if(_theGame._gameState != 5)
         {
            playAnimationState(29);
         }
      }
      
      public function dive(param1:Boolean) : Boolean
      {
         if(param1)
         {
            if(_avatar != null && getPositionX() >= _startX)
            {
               if(_raceCompleteState == 0 && _jumpingDivingTimer <= 0 && _avatar._bInSplashVolume == false)
               {
                  doDive();
                  return true;
               }
            }
         }
         else
         {
            (_trackLayer.parent as Object).double = false;
         }
         return false;
      }
   }
}

