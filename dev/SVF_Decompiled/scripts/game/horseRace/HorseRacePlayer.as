package game.horseRace
{
   import avatar.Avatar;
   import avatar.AvatarXtCommManager;
   import collection.AccItemCollection;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import game.MinigameManager;
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class HorseRacePlayer
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
      
      public static const SPEED_BOOST_TIMER:int = 2;
      
      public static const MAX_SPEED_BOOST:int = 600;
      
      public static const MAX_SPEED_RUN:int = 425;
      
      public static const MAX_SPEED_FALL:int = 100;
      
      public static const MAX_SPEED_FINISH:int = 200;
      
      public static const BOOST_ACCELERATION:int = 450;
      
      public static const RUN_ACCELERATION:int = 225;
      
      public static const SLOWDOWN_ACCELERATION:int = 650;
      
      public static const STOP_ACCELERATION:int = 350;
      
      public static const JUMP_TIMER:Number = 1.2;
      
      public static const ANIM_JUMP_IN:int = 35;
      
      public static const ANIM_IDLE_EAST:int = 37;
      
      private static const _defaultcolors:Array = [204734975,873202175,530842111,2753495551,543818239,1780482559];
      
      public var _maxRunSpeed:int = 425;
      
      public var _theGame:HorseRace;
      
      public var _avatar:HorseRaceAvatarView;
      
      public var _replacedAvatar:HorseRaceAvatarView;
      
      public var _animsLoaded:Boolean;
      
      public var _jumpingTimer:Number;
      
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
      
      public var _trackLayer:Sprite;
      
      public var _raceCompleteState:int;
      
      public var _finishPlace:int;
      
      public var _aiGameRandomizer:RandomSeed;
      
      public var _aiRaceRandomizer:RandomSeed;
      
      public var _isAI:Boolean;
      
      public var _aiProfile:HorseRaceAIProfile;
      
      public var _aiJumpDetector:Number;
      
      public var _name:String;
      
      public var _upcomingHurdleIndex:int;
      
      public var _emote:MovieClip;
      
      public var _aiEmoteTimer:Number;
      
      public var _aiStartLineJumpTimer:Number;
      
      public var _aiEmoteType:int;
      
      public var _laneMarkerIndex:int;
      
      public var _aiHurdleDecide:Array;
      
      public var _speedBoostTimer:Number;
      
      public var _boostsAvailable:int;
      
      public var _perfectRace:Boolean;
      
      public var _aiNextBoostUseX:int;
      
      public var _soundSurfaceType:int;
      
      public var _moveAnimationLooped:Boolean;
      
      public var _userName:String;
      
      public var _customAvId:int;
      
      public function HorseRacePlayer(param1:HorseRace)
      {
         super();
         _theGame = param1;
      }
      
      public function replacePlayer(param1:HorseRacePlayer) : void
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
         _laneMarkerIndex = param1._laneMarkerIndex;
         _jumpingTimer = param1._jumpingTimer;
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
         _aiStartLineJumpTimer = 0;
         _aiEmoteType = 0;
         _aiJumpDetector = 0;
         _speedBoostTimer = param1._speedBoostTimer;
         _boostsAvailable = param1._boostsAvailable;
         _soundSurfaceType = param1._soundSurfaceType;
         if(_trackLayer)
         {
            _trackLayer.visible = true;
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
         _aiStartLineJumpTimer = 0;
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
         if(_trackLayer)
         {
            _trackLayer.visible = true;
         }
         _aiEmoteTimer = Math.random() * 30;
         _laneMarkerIndex = 0;
         _aiJumpDetector = 0;
         _upcomingHurdleIndex = 0;
         _startX = param1;
         _raceCompleteState = 0;
         _jumpingTimer = 0;
         _speedX = 0;
         _serverPositionX = _startX;
         _serverVelocityX = 0;
         _actualX = _startX;
         _avatar.x = -100;
         _introSpeed = (0.2 + Math.random() * 0.2) * 425;
         _boostsAvailable = 3;
         _speedBoostTimer = 0;
         _perfectRace = true;
         if(_animsLoaded)
         {
            playAnimationState(9);
         }
      }
      
      public function start() : void
      {
         _aiEmoteType = 0;
         if(_jumpingTimer <= 0)
         {
            playAnimationState(9);
            _soundSurfaceType = 1;
         }
         else
         {
            _soundSurfaceType = 0;
         }
         if(_isAI)
         {
            _aiNextBoostUseX = _startX + _aiRaceRandomizer.integer(_theGame._trackLength / 2);
         }
      }
      
      public function percentComplete() : Number
      {
         if(_raceCompleteState > 0)
         {
            return 1;
         }
         return (_avatar.x - _startX) / _theGame._trackLength;
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
            _avatar.InitHorseRaceAvatarView();
            _trackLayer.addChild(_avatar);
            _emote = GETDEFINITIONBYNAME("HorseRace_emote_popup");
            _avatar.addChild(_emote);
            if(_isAI)
            {
               initAIAccessories();
            }
            _loc2_ = new Array(6);
            _loc2_[0] = 35;
            _loc2_[1] = 9;
            _loc2_[2] = 37;
            _loc2_[3] = 23;
            _avatar.preloadAnims(_loc2_,redrawCallback);
         }
      }
      
      public function init(param1:Sprite, param2:int, param3:int) : void
      {
         var _loc4_:Avatar = new Avatar();
         _avatar = new HorseRaceAvatarView();
         _avatar.init(_loc4_);
         _soundSurfaceType = 0;
         _trackLayer = param1;
         _trackLayer.visible = false;
         _animsLoaded = false;
         _serverVelocityX = 0;
         _trackX = 0;
         _speedX = 0;
         _jumpingTimer = 0;
         _updatePositionTimer = 0;
         _trackLane = param2;
         _avatar.x = _serverPositionX;
         _avatar.y = param3 + 15;
         if(_isAI)
         {
            _loc4_.init(-1,-1,"HorseRaceAI" + _trackLane,23,[0,0,0]);
            _loc4_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(23,0,0,false));
         }
         else if(_avID != -1)
         {
            _loc4_.init(_avID,-1,"HorseRace" + _trackLane,23,_colors,_customAvId,null,_userName);
            AvatarXtCommManager.requestADForAvatar(_avID,true,initFinalize,_loc4_);
         }
         else
         {
            _loc4_.init(-1,-1,"HorseRace" + _trackLane,23,[_defaultcolors[param2],_defaultcolors[param2],1073741311],_customAvId);
            _loc4_.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(23,11,2,false));
            initFinalize();
         }
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _avatar)
         {
            playAnimationState(9);
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
      
      public function receivePositionData(param1:int, param2:int, param3:int) : void
      {
         _serverPositionX = param1;
         _serverVelocityX = param2;
         switch(param3 - 1)
         {
            case 0:
               if(_jumpingTimer <= 0)
               {
                  playAnimationState(35);
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
                     playAnimationState(23);
                  }
               }
               _soundSurfaceType = 0;
         }
      }
      
      public function updateJumptimer(param1:Number) : void
      {
         if(_jumpingTimer > 0)
         {
            _jumpingTimer -= param1;
            if(_jumpingTimer <= 0)
            {
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
            if(_avatar.x < _startX)
            {
               _loc2_ = _introSpeed * param1;
               _avatar.x += _loc2_;
               if(_avatar.x >= _startX)
               {
                  _avatar.x = _startX;
                  playAnimationState(37);
                  _soundSurfaceType = 0;
               }
               else
               {
                  _soundSurfaceType = 1;
               }
            }
            if(_isAI)
            {
               if(_jumpingTimer <= 0)
               {
                  if(_aiStartLineJumpTimer > 0)
                  {
                     _aiStartLineJumpTimer -= param1;
                     if(_aiStartLineJumpTimer <= 0)
                     {
                        jump();
                     }
                  }
                  else
                  {
                     _aiStartLineJumpTimer = Math.random() * 2 + 0.25;
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
            return _avatar.x == _startX;
         }
         return false;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc6_:HorseRaceHurdle = null;
         var _loc12_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:* = false;
         var _loc15_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:int = 0;
         var _loc2_:Array = null;
         var _loc16_:Number = NaN;
         var _loc9_:String = null;
         var _loc7_:int = 0;
         var _loc10_:Boolean = false;
         var _loc3_:Number = _maxRunSpeed;
         var _loc11_:Number = 225;
         updateJumptimer(param1);
         if(_speedBoostTimer > 0)
         {
            _speedBoostTimer -= param1;
            if(_speedBoostTimer > 0)
            {
               _loc3_ = 600;
               _loc11_ = 450;
            }
            else
            {
               _speedBoostTimer = 0;
               _theGame._layerPlayerMarkers[_trackLane].pMarkerBoostOff();
               if(_isAI)
               {
                  _aiNextBoostUseX += _aiRaceRandomizer.integer(_theGame._trackLength / 2);
               }
            }
         }
         if(_animsLoaded == true)
         {
            _loc5_ = false;
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
                        _loc15_ = 0;
                        switch(_aiEmoteType - 1)
                        {
                           case 0:
                              _loc15_ = Math.random() * 4 + 1;
                              break;
                           case 1:
                              _loc15_ = Math.random() * 3 + 4;
                        }
                        if(_loc15_ >= 1 && _loc15_ <= 6)
                        {
                           showEmote(_loc15_);
                           _aiEmoteTimer = 5 + Math.random() * 4;
                        }
                        _aiEmoteType = 0;
                     }
                  }
               }
               if(_raceCompleteState > 0)
               {
                  if(_raceCompleteState == 1)
                  {
                     if(_avatar.x < _theGame._trackLength + _startX + 400 + 150 * (_trackLane % 2))
                     {
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
                        _loc10_ = true;
                        playAnimationState(23);
                        _avatar.x = _theGame._trackLength + _startX + 400 + 150 * (_trackLane % 2);
                     }
                  }
               }
               else if(_speedX < _loc3_)
               {
                  _speedX += param1 * _loc11_;
                  if(_speedX > _loc3_)
                  {
                     _speedX = _loc3_;
                  }
               }
               else if(_speedX > _loc3_)
               {
                  _speedX -= param1 * 650;
                  if(_speedX < _loc3_)
                  {
                     _speedX = _loc3_;
                  }
               }
               _loc4_ = _trackLayer.parent.x + _avatar.x;
               _loc13_ = _speedX * param1;
               while(_upcomingHurdleIndex < _theGame._theHurdles.length)
               {
                  _loc6_ = _theGame._theHurdles[_upcomingHurdleIndex];
                  _loc12_ = _loc6_._x + _theGame._layerHurdles.x + 100;
                  if(_loc12_ >= _loc4_)
                  {
                     if(_isAI && _jumpingTimer <= 0 && _raceCompleteState == 0 && _aiHurdleDecide[_upcomingHurdleIndex % _aiHurdleDecide.length])
                     {
                        _loc14_ = 100;
                        if(_aiProfile)
                        {
                           _loc14_ = _aiProfile._jumpDetectionDistance;
                        }
                        if(_loc12_ - _loc14_ >= _loc4_ && _loc12_ - _loc14_ <= _loc4_ + _loc13_)
                        {
                           jump();
                           if(_aiEmoteTimer <= 0 && Math.random() < 0.25)
                           {
                              _aiEmoteType = 1;
                              _aiEmoteTimer = Math.random() * 2;
                           }
                        }
                     }
                     if(_loc12_ >= _loc4_ && _loc12_ <= _loc4_ + _loc13_)
                     {
                        _upcomingHurdleIndex++;
                        if(_jumpingTimer <= 0 && _raceCompleteState == 0)
                        {
                           handleFall();
                           if(_isAI && _aiEmoteTimer <= 0 && Math.random() < 0.25)
                           {
                              _aiEmoteType = 2;
                              _aiEmoteTimer = Math.random() * 2;
                           }
                        }
                     }
                     break;
                  }
                  _upcomingHurdleIndex++;
               }
               _trackX = _loc13_;
               _avatar.x += _trackX;
               if(_isAI)
               {
                  if(_boostsAvailable > 0 && _avatar.x >= _aiNextBoostUseX)
                  {
                     boost(false);
                  }
               }
               if(_debugCircle)
               {
                  _debugCircle.x = _avatar.x;
                  _debugCircle.y = _avatar.y;
               }
               if(_raceCompleteState == 0)
               {
                  if(_avatar.x > _theGame._trackLength + _startX)
                  {
                     _raceCompleteState = 1;
                     _loc10_ = true;
                  }
               }
               if(_raceCompleteState == 0 || _speedX != 0)
               {
                  _updatePositionTimer += param1;
               }
               if(_updatePositionTimer >= 0.25 || _loc10_)
               {
                  if(_isAI == false || _loc10_)
                  {
                     _loc2_ = [];
                     _loc2_[0] = "pos";
                     _loc2_[1] = _isAI ? -(_playerID + 1) : _playerID + 1;
                     _loc2_[2] = String(int(_avatar.x));
                     _loc2_[3] = String(int(_speedX));
                     if(_raceCompleteState > 0)
                     {
                        if(_raceCompleteState == 2)
                        {
                           _loc2_[4] = "4";
                        }
                        else
                        {
                           _loc2_[4] = "3";
                        }
                     }
                     else if(_jumpingTimer > 0)
                     {
                        _loc2_[4] = "1";
                     }
                     else
                     {
                        _loc2_[4] = "0";
                     }
                     MinigameManager.msg(_loc2_);
                     _updatePositionTimer = 0;
                  }
                  _loc5_ = _speedX > 0;
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
                     _serverPositionX = _theGame._trackLength + _startX + 400 + 150 * (_trackLane % 2);
                  }
               }
               else if(_serverVelocityX < _loc3_)
               {
                  _serverVelocityX += param1 * _loc11_;
                  if(_serverVelocityX > _loc3_)
                  {
                     _serverVelocityX = _loc3_;
                  }
               }
               else if(_serverVelocityX > _loc3_)
               {
                  _serverVelocityX -= param1 * 650;
                  if(_serverVelocityX < _loc3_)
                  {
                     _serverVelocityX = _loc3_;
                  }
               }
               _serverPositionX += _serverVelocityX * param1;
               if(_serverPositionX > _theGame._trackLength + _startX + 400 + 150 * (_trackLane % 2))
               {
                  _serverPositionX = _theGame._trackLength + _startX + 400 + 150 * (_trackLane % 2);
               }
               _loc16_ = _serverPositionX - _avatar.x;
               _avatar.x += _loc16_ * 0.25;
               _loc5_ = _serverPositionX > 0;
               if(_loc5_)
               {
                  _loc4_ = _trackLayer.parent.x + _avatar.x;
                  while(_upcomingHurdleIndex < _theGame._theHurdles.length)
                  {
                     _loc6_ = _theGame._theHurdles[_upcomingHurdleIndex];
                     _loc12_ = _loc6_._x + _theGame._layerHurdles.x + 100;
                     if(_loc12_ >= _loc4_)
                     {
                        break;
                     }
                     _upcomingHurdleIndex++;
                  }
               }
            }
            _loc9_ = null;
            _loc7_ = 0;
            if(_jumpingTimer <= 0 && (_raceCompleteState == 0 || _loc5_))
            {
               _loc6_ = isInHurdle();
               if(_loc6_ != null)
               {
                  switch(_loc6_._type)
                  {
                     case 0:
                        _loc9_ = "hay";
                        _loc7_ = 5;
                        break;
                     case 1:
                        _loc9_ = "mud";
                        _loc7_ = 2;
                        break;
                     case 2:
                        _loc9_ = "water";
                        _loc7_ = 3;
                        break;
                     case 3:
                        _loc9_ = "grass";
                        _loc7_ = 4;
                  }
               }
            }
            if(_loc9_ == null)
            {
               if(_avatar._bInSplashVolume)
               {
                  _maxRunSpeed = 425;
                  _avatar.toggleSplash(false);
                  _soundSurfaceType = 1;
               }
            }
            else if(_avatar._bInSplashVolume == false)
            {
               _perfectRace = false;
               _maxRunSpeed = 100;
               _avatar.toggleSplash(true,_loc9_);
               _soundSurfaceType = _loc7_;
            }
            _actualX = Math.min(_avatar.x,_theGame._trackLength + _startX);
         }
      }
      
      private function isInHurdle() : HorseRaceHurdle
      {
         var _loc3_:Number = NaN;
         var _loc2_:HorseRaceHurdle = null;
         var _loc1_:Number = _trackLayer.parent.x + _avatar.x;
         if(_upcomingHurdleIndex > 0)
         {
            _loc3_ = _theGame._theHurdles[_upcomingHurdleIndex - 1]._x + _theGame._layerHurdles.x + 100;
            if(_loc3_ < _loc1_ && _loc3_ + _theGame._theHurdles[_upcomingHurdleIndex - 1]._width - 2 * 100 > _loc1_)
            {
               _loc2_ = _theGame._theHurdles[_upcomingHurdleIndex - 1];
            }
         }
         if(_loc2_ == null && _upcomingHurdleIndex < _theGame._theHurdles.length)
         {
            _loc3_ = _theGame._theHurdles[_upcomingHurdleIndex]._x + _theGame._layerHurdles.x + 100;
            if(_loc3_ < _loc1_ && _loc3_ + _theGame._theHurdles[_upcomingHurdleIndex]._width - 2 * 100 > _loc1_)
            {
               _loc2_ = _theGame._theHurdles[_upcomingHurdleIndex];
            }
         }
         return _loc2_;
      }
      
      private function playAnimationState(param1:int) : void
      {
         var _loc2_:Function = null;
         var _loc3_:int = 0;
         _moveAnimationLooped = false;
         switch(param1)
         {
            case 37:
               _jumpingTimer = 0;
               _speedX = 0;
               break;
            case 23:
               _jumpingTimer = 0;
               _speedX = 0;
               break;
            case 9:
               _moveAnimationLooped = true;
               _loc2_ = animationAtEnd;
               break;
            case 35:
               _jumpingTimer = 1.2;
               _loc3_ = 1;
               _loc2_ = animationAtEnd;
         }
         _avatar.playAnim(param1,false,_loc3_,_loc2_);
      }
      
      private function handleFall() : void
      {
         var _loc1_:int = 0;
         if(_localPlayer && !_isAI || Math.abs(_avatar.x - _theGame._myPlayer._avatar.x) < 350)
         {
            _loc1_ = Math.random() * _theGame._whineSounds.length;
            _theGame._soundMan.playByName(_theGame._whineSounds[_loc1_]);
         }
         _jumpingTimer = 0;
      }
      
      private function animationAtEnd(param1:LayerAnim, param2:int) : void
      {
         if(_avatar && param1)
         {
            switch(param2)
            {
               case 9:
                  _moveAnimationLooped = true;
                  break;
               case 35:
                  cancelJump();
            }
         }
      }
      
      public function cancelJump() : void
      {
         _jumpingTimer = 0;
         if(_theGame._gameState == 5)
         {
            playAnimationState(9);
            if(isInHurdle() != null)
            {
               if(_speedBoostTimer <= 0 && _speedX > 100)
               {
                  _speedX = 100;
               }
            }
         }
         else
         {
            playAnimationState(37);
         }
      }
      
      public function boost(param1:Boolean) : Boolean
      {
         if(_avatar != null)
         {
            if(param1 || _speedBoostTimer <= 0 && _raceCompleteState == 0 && _boostsAvailable > 0)
            {
               if(_localPlayer && !_isAI || Math.abs(_avatar.x - _theGame._myPlayer._avatar.x) < 350)
               {
                  _theGame._soundMan.playByName(_theGame._soundNameHorseTurbo);
               }
               _boostsAvailable--;
               _speedBoostTimer = 2;
               _theGame._layerPlayerMarkers[_trackLane].pMarkerBoostOn();
               return true;
            }
         }
         return false;
      }
      
      public function jump() : Boolean
      {
         var _loc1_:int = 0;
         if(_avatar != null && _avatar.x >= _startX)
         {
            if(_raceCompleteState == 0 && _jumpingTimer <= 0 && _avatar._bInSplashVolume == false)
            {
               if(_localPlayer && !_isAI || Math.abs(_avatar.x - _theGame._myPlayer._avatar.x) < 350)
               {
                  _loc1_ = Math.random() * _theGame._jumpSounds.length;
                  _theGame._soundMan.playByName(_theGame._jumpSounds[_loc1_]);
               }
               playAnimationState(35);
               return true;
            }
         }
         return false;
      }
   }
}

