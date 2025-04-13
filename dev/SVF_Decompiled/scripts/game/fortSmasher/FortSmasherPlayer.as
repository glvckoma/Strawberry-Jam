package game.fortSmasher
{
   import Box2D.Dynamics.b2Body;
   import flash.events.Event;
   import flash.geom.Point;
   import game.MinigameManager;
   
   public class FortSmasherPlayer
   {
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      public var _theGame:FortSmasher;
      
      public var _localPlayer:Boolean;
      
      public var _netID:int;
      
      public var _playerID:int;
      
      public var _slingshot:Object;
      
      public var _fort:Object;
      
      public var _updatePositionTimer:Number;
      
      public var _serverPosition:Point;
      
      public var _lastServerPosition:Point;
      
      public var _gemCount:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      public var _score:int;
      
      public var _lost:Boolean;
      
      public var _trailingPosX:Number;
      
      public var _trailingPosY:Number;
      
      public var _angleVector:Point;
      
      public var _pullDistance:Number;
      
      public var _angle:Number;
      
      public var _doHeartbeat:Boolean;
      
      public var _hasTurn:Boolean;
      
      public var _bodies:Array;
      
      public var _steps:int;
      
      public var _projectileType:int;
      
      public var _trail:Array;
      
      public var _trailFrames:int;
      
      public var _makeTrail:Boolean;
      
      public var _firstShot:Boolean;
      
      public var _launcherLoaded:Boolean;
      
      public var _numPhantoms:int;
      
      public var _anchor:Point;
      
      public var _hadFirstTurn:Boolean;
      
      public function FortSmasherPlayer(param1:FortSmasher)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:int, param2:Array, param3:int, param4:uint) : int
      {
         _serverPosition = new Point();
         _lastServerPosition = new Point();
         _playerID = param1;
         _netID = parseInt(param2[param3++]);
         _bodies = [];
         setProjectileType(0);
         _slingshot = _theGame.getScene().getLayer("slingshot" + (param1 + 1));
         _fort = _theGame.getScene().getLayer("forts" + (param1 + 1));
         _hasTurn = false;
         if(_playerID == 0)
         {
            _theGame._layerFort1.addChild(_fort.loader);
         }
         else
         {
            _theGame._layerFort2.addChild(_fort.loader);
         }
         _anchor = new Point();
         _anchor.x = _slingshot.loader.x;
         _anchor.y = _slingshot.loader.y - 60;
         param3++;
         param3++;
         _gemCount = 0;
         _score = 0;
         _updatePositionTimer = 0;
         _waitingForAllLoaded = false;
         _lost = false;
         _doHeartbeat = true;
         _theGame._layerPlayers.addChild(_slingshot.loader);
         _slingshot.loader.content.launcher.loadLauncher(0);
         _slingshot.loader.content.launcher.stretch(0,0);
         _trail = [];
         _trailFrames = 1;
         _firstShot = true;
         _launcherLoaded = false;
         _numPhantoms = 0;
         _pullDistance = -1;
         _hadFirstTurn = false;
         if(param1 == 1)
         {
            _slingshot.loader.scaleX = -1;
         }
         _angleVector = new Point();
         _localPlayer = _theGame.myId == _netID;
         if(_localPlayer)
         {
            _theGame.getScene().getLayer("fort_ui").loader.content.player(_playerID + 1);
            if(_theGame._totalPlayers == 2)
            {
               _theGame.getScene().getLayer("fort_ui").loader.content.addEventListener("exitFrame",UILoaded);
            }
         }
         _trailingPosX = 600;
         _trailingPosY = 0;
         return param3;
      }
      
      public function createBody(param1:b2Body) : void
      {
         var _loc2_:Object = {};
         _loc2_.body = param1;
         _loc2_.deleteTimer = 0;
         _bodies.push(_loc2_);
      }
      
      public function isCurrentBody(param1:b2Body) : Boolean
      {
         var _loc2_:int = int(_bodies.length);
         if(_bodies[_loc2_ - 1].body == param1 || param1.m_userData.type == 5 && _loc2_ >= 3 && (_bodies[_loc2_ - 2].body == param1 || _bodies[_loc2_ - 3].body == param1))
         {
            return true;
         }
         return false;
      }
      
      public function UILoaded(param1:Event) : void
      {
         _theGame.getScene().getLayer("fort_ui").loader.content.removeEventListener("exitFrame",UILoaded);
         _theGame.getScene().getLayer("fort_ui").loader.content.counter1Cont.counter1.visible = false;
         _theGame.getScene().getLayer("fort_ui").loader.content.counter2Cont.counter2.visible = false;
         _theGame.getScene().getLayer("fort_ui").loader.content.counter3Cont.counter3.visible = false;
         _theGame.getScene().getLayer("fort_ui").loader.content.counter4Cont.counter4.visible = false;
         _theGame.getScene().getLayer("fort_ui").loader.content.counter5Cont.counter5.visible = false;
      }
      
      public function destroySleepingBodies() : void
      {
         var _loc1_:b2Body = null;
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _bodies.length)
         {
            _loc1_ = _bodies[_loc3_].body;
            if(_bodies[_loc3_].deleteTimer == 0)
            {
               if(_loc1_.IsSleeping() || _loc1_.m_linearVelocity.LengthSquared() <= 1 && Math.abs(_loc1_.m_angularVelocity) <= 0.1)
               {
                  _bodies[_loc3_].deleteTimer = 1;
               }
            }
            else
            {
               _bodies[_loc3_].deleteTimer -= _theGame._timeStep * 2;
               if(_bodies[_loc3_].deleteTimer <= 0)
               {
                  if(_loc1_.IsSleeping() || _loc1_.m_linearVelocity.LengthSquared() <= 1 && Math.abs(_loc1_.m_angularVelocity) <= 0.1)
                  {
                     _theGame._world.DestroyBody(_loc1_);
                     _loc1_.m_userData.loader.content.destroy();
                     _theGame._projectilePool.push(_loc1_.m_userData);
                     _bodies.splice(_loc3_,1);
                     _loc3_--;
                     _loc2_ = true;
                  }
                  else
                  {
                     _bodies[_loc3_].deleteTimer = 0;
                  }
               }
            }
            _loc3_++;
         }
         if(_loc2_)
         {
            _theGame._soundMan.playByName(_theGame._soundNameFruitSplat);
         }
      }
      
      public function destroyBody(param1:b2Body = null) : void
      {
         var _loc2_:b2Body = null;
         var _loc3_:int = 0;
         if(!param1)
         {
            if(_bodies.length > 0)
            {
               _theGame._soundMan.playByName(_theGame._soundNameFruitSplat);
            }
            _loc3_ = 0;
            while(_loc3_ < _bodies.length)
            {
               _loc2_ = _bodies[_loc3_].body;
               _theGame._world.DestroyBody(_loc2_);
               _loc2_.m_userData.loader.content.destroy();
               _theGame._projectilePool.push(_loc2_.m_userData);
               _loc3_++;
            }
            _bodies.splice(0,_bodies.length);
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < _bodies.length)
            {
               _loc2_ = _bodies[_loc3_].body;
               if(param1 == _loc2_)
               {
                  _theGame._world.DestroyBody(_loc2_);
                  _loc2_.m_userData.loader.content.destroy();
                  _theGame._soundMan.playByName(_theGame._soundNameFruitSplat);
                  _bodies.splice(_loc3_,1);
                  _theGame._projectilePool.push(_loc2_.m_userData);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      public function isPlayerBody(param1:b2Body) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _bodies.length)
         {
            if(param1 == _bodies[_loc2_].body)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function setProjectileType(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Array = null;
         if(_projectileType != param1)
         {
            _theGame._soundMan.playByName(_theGame._soundNameFruitReload);
            if(_localPlayer && _theGame._totalPlayers == 2)
            {
               _loc3_ = [];
               _loc3_[0] = "setType";
               _loc3_[1] = String(param1);
               MinigameManager.msg(_loc3_);
            }
         }
         else if(param2)
         {
            _theGame._soundMan.playByName(_theGame._soundNameFruitReload);
         }
         _projectileType = param1;
         if(_slingshot)
         {
            _slingshot.loader.content.launcher.loadLauncher(_projectileType + 1);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc2_:Array = null;
         var _loc5_:Point = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!_waitingForAllLoaded && _doHeartbeat)
         {
            if(_localPlayer)
            {
               if(_hasTurn && _launcherLoaded && _theGame._gameState == 4 && !_theGame.DESIGN_MODE)
               {
                  _lastServerPosition.x = _serverPosition.x;
                  _lastServerPosition.y = _serverPosition.y;
                  _serverPosition.x = _trailingPosX = _theGame.stage.mouseX / _theGame._layerPlayers.scaleX - _theGame._layerPlayers.x;
                  _serverPosition.y = _trailingPosY = (_theGame.stage.mouseY - _theGame._layerPlayers.y) / _theGame._layerPlayers.scaleY;
                  if(_theGame._totalPlayers > 1)
                  {
                     _updatePositionTimer += param1;
                     if(_updatePositionTimer > 0.25 && (_lastServerPosition.x != _serverPosition.x || _lastServerPosition.y != _serverPosition.y))
                     {
                        _loc2_ = [];
                        _loc2_[0] = "pos";
                        _loc2_[1] = String(int(_serverPosition.x));
                        _loc2_[2] = String(int(_serverPosition.y));
                        MinigameManager.msg(_loc2_);
                        _updatePositionTimer = 0;
                     }
                  }
               }
            }
            else
            {
               _loc5_ = new Point();
               _launcherLoaded = true;
               _loc5_.x = _trailingPosX;
               _loc5_.y = _trailingPosY;
               _loc3_ = Point.distance(_loc5_,_serverPosition);
               _loc4_ = 0.25;
               _trailingPosX += (_serverPosition.x - _trailingPosX) * _loc4_;
               _trailingPosY += (_serverPosition.y - _trailingPosY) * _loc4_;
            }
            if(_hasTurn && _launcherLoaded)
            {
               _anchor.x = _slingshot.loader.x;
               _anchor.y = _slingshot.loader.y - 60;
               _loc6_ = _angle;
               _angle = Math.atan2(_trailingPosY - _anchor.y,_trailingPosX - _anchor.x);
               _pullDistance = Math.min(Math.sqrt((_trailingPosY - _anchor.y) * (_trailingPosY - _anchor.y) + (_trailingPosX - _anchor.x) * (_trailingPosX - _anchor.x)),80);
               if(_pullDistance < 20)
               {
                  _pullDistance = 20;
                  _angle = _loc6_;
               }
               if(_playerID == 0)
               {
                  if(_angle < 3.141592653589793 * 0.5 && _angle >= 0)
                  {
                     _angle -= 3.141592653589793;
                  }
                  else if(_angle > -1.5707963267948966 && _angle < 0)
                  {
                     _angle += 3.141592653589793;
                  }
                  if(_angle <= -1.5707963267948966 && _angle > -2.891592653589793)
                  {
                     _angle = Math.abs(-1.5707963267948966 - _angle) > Math.abs(-2.891592653589793 - _angle) ? -2.891592653589793 : 3.141592653589793 * 0.5;
                  }
                  _slingshot.loader.content.launcher.stretch(_angle * 180 / 3.141592653589793 + 180,_pullDistance);
               }
               else
               {
                  if(_angle >= 3.141592653589793 * 0.5)
                  {
                     _angle -= 3.141592653589793;
                  }
                  else if(_angle < -1.5707963267948966)
                  {
                     _angle += 3.141592653589793;
                  }
                  if(_angle >= -1.5707963267948966 && _angle < -0.25)
                  {
                     _angle = Math.abs(-1.5707963267948966 - _angle) > Math.abs(-0.25 - _angle) ? -0.25 : 3.141592653589793 * 0.5;
                  }
                  _slingshot.loader.content.launcher.stretch(-_angle * 180 / 3.141592653589793,_pullDistance);
               }
               _angleVector.x = Math.cos(_angle);
               _angleVector.y = Math.sin(_angle);
            }
         }
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         _serverPosition.x = int(param1[param2++]);
         _serverPosition.y = int(param1[param2++]);
         return param2;
      }
      
      public function receiveShootData(param1:Array, param2:int) : int
      {
         _pullDistance = param1[param2++];
         _angle = param1[param2++];
         _projectileType = param1[param2++];
         shoot(false);
         _theGame._clusterSteps = param1[param2++];
         if(_theGame._clusterSteps > 0)
         {
            _theGame._queueCluster = true;
         }
         return param2;
      }
      
      public function removeTrail() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _trail.length)
         {
            if(_trail[_loc1_].parent)
            {
               _trail[_loc1_].parent.removeChild(_trail[_loc1_]);
            }
            _theGame._trailDotPool.push(_trail[_loc1_]);
            _loc1_++;
         }
         _trail.splice(0,_trail.length);
      }
      
      public function shoot(param1:Boolean) : void
      {
         if(!_theGame.DESIGN_MODE)
         {
            if(_localPlayer)
            {
               _makeTrail = true;
               removeTrail();
               _slingshot.loader.content.previewOff();
            }
            _steps = 0;
            _doHeartbeat = false;
            _theGame.createBall(this,_projectileType);
            _theGame.launchBall(this,_pullDistance,_angle,param1);
         }
      }
   }
}

