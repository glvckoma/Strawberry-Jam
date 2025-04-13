package game.riverRace
{
   import achievement.AchievementXtCommManager;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import game.MinigameManager;
   
   public class RiverRacePlayer
   {
      private static const MAX_THROTTLE:Number = 50;
      
      private static const MAX_RAPIDS_THROTTLE:Number = 1000;
      
      private static const MAX_ACCELERATION:int = 400;
      
      private static const SIDE_ACCELERATION:int = 700;
      
      private static const SIDE_DECELERATION:int = 300;
      
      private static const MAX_SPEED:int = 300;
      
      private static const MIN_SPEED:int = 200;
      
      private static const ROCK_SPEED:int = 100;
      
      private static const WHIRLPOOL_SPEED:int = 100;
      
      private static const MAX_SIDE_SPEED:int = 200;
      
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      private static const PROGRESSBAR_RANGE:int = 500;
      
      private static const MAX_SPEED_TIME:Number = 2;
      
      public var _theGame:RiverRace;
      
      public var _localPlayer:Boolean;
      
      public var _netID:int;
      
      public var _clone:Object;
      
      public var _updatePositionTimer:Number;
      
      public var _lastFrameVelocity:Point;
      
      public var _maxSpeed:int;
      
      public var _currentVelocity:Point;
      
      public var _currentAcceleration:Point;
      
      public var _serverVelocity:Point;
      
      public var _serverAcceleration:Point;
      
      public var _serverPosition:Point;
      
      public var _gemCount:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      public var _debugCircle:Sprite;
      
      public var _finished:Boolean;
      
      public var _radius:Number;
      
      public var _speedMultiplier:Number;
      
      public var _color:String;
      
      public var _finishedPlace:int;
      
      public var _dbID:int;
      
      public var _collisionSoundDelay:Number;
      
      public var _playerIndex:int;
      
      public var _maxSpeedTimer:Number;
      
      public var _decelerateThrottle:Number;
      
      public var _turboSoundTimer:Number;
      
      public var _rockSoundTimer:Number;
      
      public var _whirlpoolSoundTimer:Number;
      
      public var _fastActive:Boolean;
      
      public var _userName:String;
      
      public function RiverRacePlayer(param1:RiverRace)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:String, param2:int, param3:Array, param4:int, param5:String) : int
      {
         _netID = parseInt(param3[param4++]);
         _localPlayer = _theGame.myId == _netID;
         _finishedPlace = 0;
         _maxSpeed = 200;
         _maxSpeedTimer = 0;
         _decelerateThrottle = 50;
         _turboSoundTimer = 0;
         _rockSoundTimer = 0;
         _whirlpoolSoundTimer = 0;
         _fastActive = false;
         _playerIndex = _theGame.getPlayerIndex(_localPlayer);
         _dbID = param2;
         _userName = param1;
         _lastFrameVelocity = new Point();
         _currentVelocity = new Point();
         _currentAcceleration = new Point();
         _serverVelocity = new Point();
         _serverAcceleration = new Point();
         _serverPosition = new Point();
         _finished = false;
         _color = param5;
         _theGame._progressBar.clone.loader.content.sizeColor(_localPlayer ? "large" : "small",_color,_playerIndex);
         _theGame._progressBar.clone.loader.content.boatProgress[_playerIndex] = 0;
         _theGame._progressBar.clone.loader.content.boatRange[_playerIndex] = 500;
         _clone = _theGame.getScene().cloneAsset("player_raft");
         _clone.loader.contentLoaderInfo.addEventListener("complete",onRaftLoaderComplete);
         _clone.loader.x = parseInt(param3[param4++]);
         _clone.loader.y = parseInt(param3[param4++]);
         _clone.loader.y = _theGame._startingLine.loader.y + _theGame._startingLine.height;
         _serverPosition.x = _clone.loader.x;
         _serverPosition.y = _clone.loader.y;
         _gemCount = 0;
         _collisionSoundDelay = 0;
         _updatePositionTimer = 0;
         _waitingForAllLoaded = false;
         if(_localPlayer)
         {
            _theGame._layerLocalPlayer.addChild(_clone.loader);
         }
         else
         {
            _theGame._layerPlayers.addChild(_clone.loader);
         }
         _radius = Math.min(_clone.width,_clone.height) / 2;
         _speedMultiplier = 1;
         return param4;
      }
      
      public function onRaftLoaderComplete(param1:Event) : void
      {
         if(_localPlayer)
         {
            _clone.loader.content.gotoAndStop(_color + "_big");
         }
         else
         {
            _clone.loader.content.gotoAndStop(_color + "_small");
         }
         _clone.loader.content.wake.alpha = 0;
         _clone.loader.content.slow();
         param1.target.removeEventListener("complete",onRaftLoaderComplete);
      }
      
      public function remove() : void
      {
         _theGame._progressBar.clone.loader.content.sizeColor("small","none",_playerIndex);
         if(_clone && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
         if(_debugCircle && _debugCircle.parent)
         {
            _debugCircle.parent.removeChild(_debugCircle);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc7_:Point = null;
         var _loc10_:Number = NaN;
         var _loc9_:Point = null;
         var _loc11_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc3_:Array = null;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc6_:Point = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!_waitingForAllLoaded)
         {
            if(_maxSpeedTimer > 0)
            {
               _maxSpeedTimer -= param1;
               if(_maxSpeedTimer <= 0)
               {
                  _maxSpeed = 200;
                  _decelerateThrottle = 50;
                  updateRaftEffect(false);
               }
            }
            _loc7_ = new Point();
            _loc10_ = _maxSpeed;
            if(_collisionSoundDelay > 0)
            {
               _collisionSoundDelay -= param1;
            }
            if(_turboSoundTimer > 0)
            {
               _turboSoundTimer -= param1;
            }
            if(_rockSoundTimer > 0)
            {
               _rockSoundTimer -= param1;
            }
            if(_whirlpoolSoundTimer > 0)
            {
               _whirlpoolSoundTimer -= param1;
            }
            _loc7_.x = _serverPosition.x + _clone.width / 2;
            _loc7_.y = _serverPosition.y + _clone.height / 2;
            if(!_finished)
            {
               _loc10_ *= _speedMultiplier;
            }
            if(_serverAcceleration.x != 0)
            {
               _serverVelocity.x += param1 * _serverAcceleration.x;
               if(_serverVelocity.x > 200)
               {
                  _serverVelocity.x = 200;
               }
               else if(_serverVelocity.x < -200)
               {
                  _serverVelocity.x = -200;
               }
            }
            else if(_serverVelocity.x > 0)
            {
               _serverVelocity.x -= 300 * param1;
               if(_serverVelocity.x < 0)
               {
                  _serverVelocity.x = 0;
               }
            }
            else if(_serverVelocity.x < 0)
            {
               _serverVelocity.x += 300 * param1;
               if(_serverVelocity.x > 0)
               {
                  _serverVelocity.x = 0;
               }
            }
            if(!_finished)
            {
               if(_serverAcceleration.y > -400)
               {
                  if(_speedMultiplier > 1)
                  {
                     _serverAcceleration.y -= 1000 * param1;
                  }
                  else
                  {
                     _serverAcceleration.y -= _decelerateThrottle * param1;
                  }
               }
            }
            else
            {
               _serverAcceleration.y = 0;
            }
            if(_serverAcceleration.y > 0)
            {
               if(_serverVelocity.y < _loc10_)
               {
                  _serverVelocity.y += param1 * _serverAcceleration.y;
                  if(_serverVelocity.y > _loc10_)
                  {
                     _serverVelocity.y = _loc10_;
                  }
               }
               else if(_serverVelocity.y > _loc10_)
               {
                  _serverVelocity.y -= _decelerateThrottle * param1;
                  if(_serverVelocity.y < _loc10_)
                  {
                     _serverVelocity.y = _loc10_;
                  }
               }
            }
            else if(_serverAcceleration.y < 0)
            {
               if(_serverVelocity.y > -_loc10_)
               {
                  _serverVelocity.y += param1 * _serverAcceleration.y;
                  if(_serverVelocity.y < -_loc10_)
                  {
                     _serverVelocity.y = -_loc10_;
                  }
               }
               else if(_serverVelocity.y < -_loc10_)
               {
                  _serverVelocity.y += _decelerateThrottle * param1;
                  if(_serverVelocity.y > -_loc10_)
                  {
                     _serverVelocity.y = -_loc10_;
                  }
               }
            }
            else if(_serverVelocity.y > 0)
            {
               _serverVelocity.y -= 2 * _decelerateThrottle * param1;
               if(_serverVelocity.y < 0)
               {
                  _serverVelocity.y = 0;
               }
            }
            else if(_serverVelocity.y < 0)
            {
               if(_finished)
               {
                  _serverVelocity.y += 6 * _decelerateThrottle * param1;
               }
               else
               {
                  _serverVelocity.y += 2 * _decelerateThrottle * param1;
               }
               if(_serverVelocity.y > 0)
               {
                  _serverVelocity.y = 0;
               }
            }
            _lastFrameVelocity.x = param1 * _serverVelocity.x;
            _lastFrameVelocity.y = param1 * _serverVelocity.y;
            _loc7_.x = _serverPosition.x + _clone.width / 2;
            _loc7_.y = _serverPosition.y + _clone.height / 2;
            if(_lastFrameVelocity.x != 0 || _lastFrameVelocity.y != 0)
            {
               _speedMultiplier = 1;
               _loc9_ = _theGame.TestShoreCollision(this,_loc7_,_lastFrameVelocity,_radius);
               if(_loc9_)
               {
                  _loc11_ = _serverVelocity.length;
                  _maxSpeed = 100;
                  _maxSpeedTimer = 0.25;
                  _decelerateThrottle = 10 * 50;
                  if(_localPlayer && _collisionSoundDelay <= 0 && _loc11_ > _maxSpeed / 2)
                  {
                     _collisionSoundDelay = 0.25;
                     _theGame._soundMan.playByName(_theGame._soundNameCollision);
                  }
                  _serverVelocity.x = _loc9_.x;
                  _serverVelocity.y = _loc9_.y;
                  _serverVelocity.x *= _loc11_;
                  _serverVelocity.y *= _loc11_;
                  _lastFrameVelocity.x = param1 * _serverVelocity.x;
                  _lastFrameVelocity.y = param1 * _serverVelocity.y;
                  _loc11_ = _serverVelocity.length;
               }
            }
            _serverPosition.x += _lastFrameVelocity.x;
            if(_serverPosition.x + _clone.width > 900)
            {
               _serverPosition.x = 900 - _clone.width;
            }
            else if(_serverPosition.x < 0)
            {
               _serverPosition.x = 0;
            }
            _serverPosition.y += _lastFrameVelocity.y;
            if(_clone.loader.content)
            {
               if(_serverVelocity.y < -25)
               {
                  if(_clone.loader.content.wake.alpha < 1)
                  {
                     _clone.loader.content.wake.alpha += 0.5 * param1;
                     if(_clone.loader.content.wake.alpha > 1)
                     {
                        _clone.loader.content.wake.alpha = 1;
                     }
                  }
               }
               else if(_clone.loader.content.wake.alpha > 0)
               {
                  _clone.loader.content.wake.alpha -= 3 * param1;
                  if(_clone.loader.content.wake.alpha < 0)
                  {
                     _clone.loader.content.wake.alpha = 0;
                  }
               }
            }
            _loc15_ = 500 * -_serverPosition.y / _theGame._maxTotalY;
            if(_loc15_ > 500)
            {
               _loc15_ = 500;
            }
            _theGame._progressBar.clone.loader.content.boatProgress[_playerIndex] = _loc15_;
            if(_localPlayer)
            {
               _clone.loader.x = _serverPosition.x;
               _clone.loader.y = _serverPosition.y;
               if(!_finished)
               {
                  if(_theGame._riverCurrentSegment > _theGame._levelProgression.length)
                  {
                     if(_clone.loader.y <= _theGame._finishLine.loader.y + _theGame._finishLine.height / 2)
                     {
                        _finished = true;
                        _loc3_ = [];
                        _loc3_[0] = "finished";
                        MinigameManager.msg(_loc3_);
                     }
                  }
                  if(!_finished)
                  {
                     if(_theGame._rightArrowDown)
                     {
                        _serverAcceleration.x = 700;
                     }
                     else if(_theGame._leftArrowDown)
                     {
                        _serverAcceleration.x = -700;
                     }
                     else
                     {
                        _serverAcceleration.x = 0;
                     }
                  }
                  else
                  {
                     _serverAcceleration.x = 0;
                  }
               }
               _updatePositionTimer += param1;
               if(_updatePositionTimer > 0.25)
               {
                  _loc3_ = [];
                  _loc3_[0] = "pos";
                  _loc3_[1] = String(int(_clone.loader.x));
                  _loc3_[2] = String(int(_clone.loader.y));
                  _loc3_[3] = String(int(_serverAcceleration.x));
                  _loc3_[4] = String(int(_serverAcceleration.y));
                  _loc3_[5] = String(int(_serverVelocity.x));
                  _loc3_[6] = String(int(_serverVelocity.y));
                  MinigameManager.msg(_loc3_);
                  _updatePositionTimer = 0;
               }
            }
            else
            {
               _loc6_ = new Point();
               _loc6_.x = _clone.loader.x;
               _loc6_.y = _clone.loader.y;
               _currentVelocity.x = _serverPosition.x - _clone.loader.x;
               _currentVelocity.y = _serverPosition.y - _clone.loader.y;
               _loc4_ = Point.distance(_loc6_,_serverPosition);
               _loc5_ = 0.2;
               _clone.loader.x += _currentVelocity.x * _loc5_;
               _clone.loader.y += _currentVelocity.y * _loc5_;
            }
            if(_debugCircle)
            {
               _debugCircle.x = _clone.loader.x + _clone.width / 2;
               _debugCircle.y = _clone.loader.y + _clone.height / 2;
            }
         }
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         _serverPosition.x = int(param1[param2++]);
         _serverPosition.y = int(param1[param2++]);
         _serverAcceleration.x = int(param1[param2++]);
         _serverAcceleration.y = int(param1[param2++]);
         _serverVelocity.x = int(param1[param2++]);
         _serverVelocity.y = int(param1[param2++]);
         return param2;
      }
      
      public function receiveGem(param1:int) : void
      {
         _gemCount += param1;
      }
      
      public function insideBuoy() : void
      {
         updateRaftEffect(true);
         _maxSpeed = 300;
         _maxSpeedTimer = 2;
         _decelerateThrottle = 50;
         if(_turboSoundTimer <= 0)
         {
            _turboSoundTimer = 1;
            _theGame._soundMan.playByName(_theGame._soundNameTurbo);
         }
      }
      
      public function insideRock() : void
      {
         updateRaftEffect(false);
         _maxSpeed = 100;
         _maxSpeedTimer = 0.25;
         _decelerateThrottle = 10 * 50;
         if(_rockSoundTimer <= 0)
         {
            _rockSoundTimer = 3;
            _theGame._soundMan.playByName(_theGame._soundNameRockCollision);
         }
      }
      
      public function insideWhirlpool() : void
      {
         updateRaftEffect(false);
         _maxSpeed = 100;
         _maxSpeedTimer = 0.25;
         _decelerateThrottle = 10 * 50;
         if(_whirlpoolSoundTimer <= 0)
         {
            _whirlpoolSoundTimer = 3;
            _theGame._soundMan.playByName(_theGame._soundNameWhirlpoolCollision);
         }
      }
      
      public function updateRaftEffect(param1:Boolean) : void
      {
         if(_clone.loader.content)
         {
            if(param1)
            {
               if(_fastActive == false || _maxSpeedTimer < 1.5)
               {
                  _clone.loader.content.fast();
                  _fastActive = true;
               }
            }
            else if(_fastActive == true)
            {
               _fastActive = false;
               _clone.loader.content.slow();
            }
         }
      }
      
      public function setFinishedPlace(param1:int, param2:int) : void
      {
         _finishedPlace = param1;
         switch(param1 - 1)
         {
            case 0:
               if(param2 == 4)
               {
                  if(_localPlayer && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
                  }
                  _gemCount += 30;
                  break;
               }
               if(param2 == 3)
               {
                  _gemCount += 20;
                  break;
               }
               if(param2 == 2)
               {
                  _gemCount += 10;
                  break;
               }
               _gemCount += 5;
               break;
            case 1:
               if(param2 == 4)
               {
                  _gemCount += 20;
                  break;
               }
               if(param2 == 3)
               {
                  _gemCount += 10;
                  break;
               }
               _gemCount += 5;
               break;
            case 2:
               if(param2 == 4)
               {
                  _gemCount += 10;
                  break;
               }
               _gemCount += 5;
               break;
            case 3:
               _gemCount += 5;
         }
      }
   }
}

