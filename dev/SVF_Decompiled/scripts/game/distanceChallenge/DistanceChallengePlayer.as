package game.distanceChallenge
{
   import flash.geom.Point;
   
   public class DistanceChallengePlayer
   {
      private static const GRAVITY:Number = 4500;
      
      private static const WIND_RESISTANCE_UP:Number = 10000;
      
      private static const WIND_RESISTANCE_RIGHT:Number = -120;
      
      private static const GROUND_RESISTANCE_RIGHT:Number = -2750;
      
      private static const MAX_DRAG_RIGHT:Number = -500;
      
      private static const MAX_VELOCITY_UP:Number = 2000;
      
      private static const MAX_VELOCITY_DOWN:Number = 1000;
      
      private static const MAX_VELOCITY_RIGHT:Number = 3600;
      
      public var _theGame:DistanceChallenge;
      
      public var _clone:Object;
      
      public var _velocity:Point;
      
      public var _acceleration:Point;
      
      public var _started:Boolean;
      
      public var _currentObstacleType:int;
      
      public var _currentObstacleX:Number;
      
      public var _gameOver:Boolean;
      
      public var _currentSoundX:Number;
      
      public var _collisionTimer:Number;
      
      public function DistanceChallengePlayer(param1:DistanceChallenge)
      {
         super();
         _gameOver = false;
         _theGame = param1;
         _started = false;
         _clone = {};
         _clone = _theGame.getScene().cloneAsset("player");
         _clone.loader.visible = false;
         _theGame._layerPlayer.addChild(_clone.loader);
         _velocity = new Point(0,0);
         _acceleration = new Point(0,0);
         _currentObstacleType = -1;
         _currentSoundX = -1;
         _collisionTimer = 0;
      }
      
      public function remove() : void
      {
         if(_clone && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
            if(_clone.loader.content)
            {
               _clone.loader.content.reset();
               _theGame.getScene().releaseCloneAsset(_clone.loader);
            }
            _clone = null;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_clone.loader.content && param1 > 0)
         {
            _loc3_ = Math.round(param1 / 0.0416666666666667);
            param1 /= _loc3_;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               updatePlayer(param1);
               _loc2_++;
            }
         }
      }
      
      public function updatePlayer(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_started == false)
         {
            _clone.loader.x = _theGame._launcher.loader.content.ArmadilloX;
            _clone.loader.y = _theGame._launcher.loader.content.ArmadilloY;
         }
         else
         {
            if(_clone.loader.content.armadilloAudio == 1)
            {
               _theGame._soundMan.playByName(_theGame._soundNameArmSpmnOpen);
               _clone.loader.content.armadilloAudio = 0;
            }
            else if(_clone.loader.content.armadilloAudio == 2)
            {
               _theGame._soundMan.playByName(_theGame._soundNameArmSpmnClose);
               _clone.loader.content.armadilloAudio = 0;
            }
            _collisionTimer -= param1;
            _loc3_ = 0;
            while(_loc3_ < 6)
            {
               _loc5_ = 0;
               while(_loc5_ < 2)
               {
                  if(_theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.parent)
                  {
                     if((_loc3_ + 1 == 1 || _loc3_ + 1 == 3) && _clone.loader.x > _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x && _clone.loader.x < _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x + _theGame._backgroundElements[_loc3_].obstacle[_loc5_].width && _velocity.x > 300)
                     {
                        if(_currentSoundX != _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x)
                        {
                           if(Math.random() > 0.5)
                           {
                              _theGame._soundMan.playByName(_theGame._soundNameArmPassBy1);
                           }
                           else
                           {
                              _theGame._soundMan.playByName(_theGame._soundNameArmPassBy2);
                           }
                           _currentSoundX = _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x;
                        }
                     }
                     _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.content.armadilloSpeedX = _velocity.x;
                     if(_clone.loader.y > _clone.y - _clone.height / 3)
                     {
                        if(_currentObstacleType != _loc3_ || _currentObstacleX != _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x)
                        {
                           if(_clone.loader.x > _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x && _clone.loader.x < _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x + _theGame._backgroundElements[_loc3_].obstacle[_loc5_].width)
                           {
                              _currentObstacleType = _loc3_;
                              _currentObstacleX = _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x;
                              _theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.content.gotoAndPlay("on");
                              switch(_loc3_ + 1)
                              {
                                 case 1:
                                    _acceleration.x -= 800;
                                    _velocity.x = Math.max(0,_velocity.x - 400);
                                    _clone.loader.content.cactus();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmCactusClsn);
                                       _collisionTimer = 0.2;
                                    }
                                    break;
                                 case 4:
                                    _acceleration.x = Math.max(650,_acceleration.x + 650);
                                    _acceleration.y = -2500;
                                    _velocity.x = Math.max(750,_velocity.x + 750);
                                    _velocity.y = Math.min(_velocity.y,-110);
                                    _clone.loader.content.geyser();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmGeyser);
                                       _collisionTimer = 0.2;
                                    }
                                    break;
                                 case 3:
                                    _velocity.x = Math.max(0,_velocity.x - 400);
                                    _acceleration.x -= 800;
                                    _theGame.addSnowmanHead(_theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.x,_theGame._backgroundElements[_loc3_].obstacle[_loc5_].loader.y);
                                    _clone.loader.content.snowman();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmSnwmnClsn);
                                       _collisionTimer = 0.2;
                                    }
                                    break;
                                 case 2:
                                    _acceleration.x = Math.max(1000,_acceleration.x + 1000);
                                    _acceleration.y = -3500;
                                    _velocity.x = Math.max(750,_velocity.x + 750);
                                    _velocity.y = Math.min(_velocity.y,-150);
                                    _clone.loader.content.mole();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmMole);
                                       _theGame._soundMan.playByName(_theGame._soundNameArmWonderwmn);
                                       _collisionTimer = 0.2;
                                    }
                                    break;
                                 case 5:
                                    _velocity.x = Math.max(0,_velocity.x - 400);
                                    _acceleration.x -= 800;
                                    _clone.loader.content.other1();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmStump);
                                       _collisionTimer = 0.2;
                                    }
                                    break;
                                 case 6:
                                    _acceleration.x = Math.max(1000,_acceleration.x + 1000);
                                    _acceleration.y = -3500;
                                    _velocity.x = Math.max(750,_velocity.x + 750);
                                    _velocity.y = Math.min(_velocity.y,-150);
                                    _clone.loader.content.other2();
                                    if(_collisionTimer <= 0)
                                    {
                                       _theGame._soundMan.playByName(_theGame._soundNameArmLsSteam);
                                       _collisionTimer = 0.2;
                                       break;
                                    }
                              }
                           }
                        }
                     }
                  }
                  _loc5_++;
               }
               _loc3_++;
            }
            if(_clone.loader.y >= _clone.y + _clone.height / 2)
            {
               _acceleration.x += -2750 * param1;
            }
            else
            {
               _acceleration.x += -120 * param1;
            }
            if(_acceleration.x < -500)
            {
               _acceleration.x = -500;
            }
            if(_acceleration.y < 0)
            {
               _acceleration.y += 10000 * param1;
            }
            else if(_velocity.y != 0 || _clone.loader.y < _clone.y + _clone.height / 2)
            {
               _acceleration.y += 4500 * param1;
            }
            _loc2_ = _velocity.x;
            _loc4_ = _velocity.y;
            _velocity.x += _acceleration.x * param1;
            _velocity.x = Math.min(_velocity.x,3600);
            _velocity.x = Math.max(_velocity.x,0);
            if(_velocity.y < 0)
            {
               _velocity.y += _acceleration.y * param1;
               if(_velocity.y > 0)
               {
                  _velocity.y = 50;
                  _acceleration.y = 0;
               }
            }
            else
            {
               _velocity.y += _acceleration.y * param1;
            }
            _velocity.y = Math.min(_velocity.y,2000);
            _velocity.y = Math.max(_velocity.y,-1000);
            if(_loc2_ != 0 && _velocity.x < 2)
            {
               _velocity.x = 0;
               _acceleration.x = 0;
               _theGame._soundMan.playByName(_theGame._soundNameArmOutro);
               if(_theGame._windSound != null)
               {
                  _theGame._windSound.stop();
                  _theGame._windSound = null;
               }
            }
            _clone.loader.x += _velocity.x * param1;
            _clone.loader.y += _velocity.y * param1;
            _clone.loader.content.armadillo.armadillo.rotation += 2500 * (_velocity.x / 3600 * param1);
            _theGame.valueTracker(Math.round((_clone.loader.x - _clone.x) / 10));
            if(_clone.loader.y > _clone.y + _clone.height / 2 && _velocity.y > 0)
            {
               _clone.loader.y = _clone.y + _clone.height / 2;
               if(_velocity.y < 75)
               {
                  _velocity.y = 0;
               }
               else
               {
                  _velocity.y = -0.47 * _velocity.y;
               }
               _acceleration.y = 0;
               if(_velocity.y != 0)
               {
                  _clone.loader.content.bounce();
                  _theGame._soundMan.playByName(_theGame._soundNameArmBounce);
                  _loc3_ = Math.random() * 3;
                  switch(_loc3_)
                  {
                     case 0:
                        _theGame._soundMan.playByName(_theGame._soundNameArmCollision1);
                        break;
                     case 1:
                        _theGame._soundMan.playByName(_theGame._soundNameArmCollision2);
                        break;
                     default:
                        _theGame._soundMan.playByName(_theGame._soundNameArmCollision3);
                  }
               }
            }
            _clone.loader.content.armadilloSpeedX = _velocity.x;
            _clone.loader.content.armadilloSpeedY = _velocity.y;
            _clone.loader.content.armadilloX = _clone.loader.x;
            _clone.loader.content.armadilloY = _clone.loader.y;
            if(!_gameOver && _velocity.x == 0)
            {
               _theGame.setGameOver();
               _gameOver = true;
            }
         }
      }
      
      public function start() : void
      {
         var _loc1_:Number = NaN;
         if(!_started)
         {
            _clone.loader.visible = true;
            _loc1_ = 600 * _theGame._launcher.loader.content.firePower;
            if(_theGame._launcher.loader.content.adjustedStringAngle == 0)
            {
               _velocity.y = _loc1_;
            }
            else if(_theGame._launcher.loader.content.adjustedStringAngle == 180)
            {
               _velocity.y = -_loc1_ * 0.5;
            }
            else if(_theGame._launcher.loader.content.adjustedStringAngle > 90)
            {
               _velocity.y = Math.cos(_theGame._launcher.loader.content.adjustedStringAngle * 3.141592653589793 / 180) * _loc1_;
               _velocity.x = Math.sin(_theGame._launcher.loader.content.adjustedStringAngle * 3.141592653589793 / 180) * _loc1_;
            }
            else
            {
               _velocity.y = Math.cos(_theGame._launcher.loader.content.adjustedStringAngle * 3.141592653589793 / 180) * _loc1_;
               _velocity.x = Math.sin(_theGame._launcher.loader.content.adjustedStringAngle * 3.141592653589793 / 180) * _loc1_;
            }
            _theGame._soundMan.playByName(_theGame._soundNameArmLaunch);
            _started = true;
         }
      }
   }
}

