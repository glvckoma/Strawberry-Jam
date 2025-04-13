package game.towerDefense
{
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class TowerDefenseEnemy
   {
      public static const STATE_MOVE:int = 0;
      
      public static const STATE_ROTATE:int = 1;
      
      public var _type:int;
      
      public var _hitPoints:int;
      
      public var _pathIndex:int;
      
      public var _distanceTraveled:Number;
      
      public var _speed:Number;
      
      public var _path:Array;
      
      public var _moveDirection:Point;
      
      public var _currentTilePos:Point;
      
      public var _theGame:TowerDefense;
      
      public var _clone:Object;
      
      public var _state:int;
      
      public var _targetRotation:int;
      
      public var _healthBar:Object;
      
      public var _waitingForRecycle:Boolean;
      
      public var _loadComplete:Boolean;
      
      public function TowerDefenseEnemy(param1:TowerDefense)
      {
         super();
         _theGame = param1;
         _moveDirection = new Point();
         _currentTilePos = new Point();
      }
      
      public function init(param1:int, param2:int, param3:Number) : void
      {
         var _loc4_:int = 0;
         _pathIndex = 0;
         _path = _theGame._paths[_theGame._pathIndex];
         if(!_loadComplete)
         {
            _clone = _theGame.getScene().cloneAsset("enemy");
            _clone.loader.contentLoaderInfo.addEventListener("complete",enemyLoadComplete);
         }
         _type = param1;
         _hitPoints = param2;
         _speed = param3;
         _distanceTraveled = 0;
         _waitingForRecycle = false;
         setCurrentTilePos();
         if(_path[0] == 0 || _path[0] == 13 || _path[0] == 126 || _path[0] == 139)
         {
            _loc4_ = _path[1] - _path[0];
         }
         else if(_path[0] % 14 == 0)
         {
            _loc4_ = 1;
         }
         else if(_path[0] < 14)
         {
            _loc4_ = 14;
         }
         else if(_path[0] % 14 == 13)
         {
            _loc4_ = -1;
         }
         else
         {
            _loc4_ = -14;
         }
         switch(_loc4_)
         {
            case 1:
               _clone.loader.x = -50;
               _clone.loader.y = Math.floor(_path[0] / 14) * 50;
               break;
            case -1:
               _clone.loader.x = 700;
               _clone.loader.y = Math.floor(_path[0] / 14) * 50;
               break;
            case 14:
               _clone.loader.x = _path[0] % 14 * 50;
               _clone.loader.y = -50;
               break;
            case -14:
               _clone.loader.x = _path[0] % 14 * 50;
               _clone.loader.y = 500;
               break;
            default:
               throw new Error("Invalid path data");
         }
         _state = 0;
         if(_loadComplete)
         {
            enemyLoadComplete(null);
         }
      }
      
      public function enemyLoadComplete(param1:Event) : void
      {
         var _loc2_:MovieClip = _clone.loader.content;
         _theGame.getScene().getLayer("healthbar").loader.x = 0;
         _theGame.getScene().getLayer("healthbar").loader.y = 0;
         _loc2_.enemyType(_type);
         if(_healthBar == null)
         {
            _healthBar = _theGame.getScene().cloneAsset("healthbar");
            _healthBar.loader.contentLoaderInfo.addEventListener("complete",healthBarLoadComplete);
            _loc2_.addChild(_healthBar.loader);
         }
         else
         {
            _healthBar.loader.content.hpMax = _healthBar.loader.content.hp = _hitPoints;
         }
         if(param1 != null)
         {
            param1.target.removeEventListener("complete",enemyLoadComplete);
         }
         _loadComplete = true;
         _pathIndex = -1;
         rotate();
      }
      
      public function healthBarLoadComplete(param1:Event) : void
      {
         param1.target.loader.content.hpMax = param1.target.loader.content.hp = _hitPoints;
         param1.target.removeEventListener("complete",healthBarLoadComplete);
      }
      
      public function isValidTarget() : Boolean
      {
         return !_waitingForRecycle;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_waitingForRecycle)
         {
            if(!_clone.loader.content.hasOwnProperty("dead") || _clone.loader.content.dead)
            {
               _waitingForRecycle = false;
               _clone.loader.parent.removeChild(_clone.loader);
               removeEnemy();
            }
         }
         else
         {
            _loc3_ = 5;
            param1 /= _loc3_;
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               updateEnemy(param1);
               _loc2_++;
            }
         }
      }
      
      private function updateEnemy(param1:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         switch(_state)
         {
            case 0:
               _loc3_ = Number(_clone.loader.x);
               _loc2_ = Number(_clone.loader.y);
               _clone.loader.x += _moveDirection.x * _speed * param1;
               _clone.loader.y += _moveDirection.y * _speed * param1;
               _distanceTraveled += Math.abs(_loc3_ - _clone.loader.x) + Math.abs(_loc2_ - _clone.loader.y);
               if(_pathIndex < _path.length)
               {
                  if(_clone.loader.x != _loc3_ && Math.abs(_clone.loader.x - _currentTilePos.x) > Math.abs(_loc3_ - _currentTilePos.x) || _clone.loader.y != _loc2_ && Math.abs(_clone.loader.y - _currentTilePos.y) > Math.abs(_loc2_ - _currentTilePos.y))
                  {
                     _clone.loader.x = _currentTilePos.x;
                     _clone.loader.y = _currentTilePos.y;
                     _state = 1;
                     rotate();
                  }
               }
               break;
            case 1:
               rotate();
         }
      }
      
      public function applyDamage(param1:int, param2:Boolean) : void
      {
         if(_hitPoints > 0)
         {
            _hitPoints -= param1;
            if(_hitPoints > 0)
            {
               _healthBar.loader.content.hp = _hitPoints;
               if(_clone.loader.content.hasOwnProperty("hit"))
               {
                  _clone.loader.content.hit(false,param2);
               }
            }
            else
            {
               _theGame.enemyKilled(_type,_pathIndex / _path.length);
               if(_clone.loader.content.hasOwnProperty("hit"))
               {
                  _clone.loader.content.hit(true,param2);
               }
               _waitingForRecycle = true;
               _theGame.play(_theGame["_soundNameEnemyKill" + (Math.floor(Math.random() * 4) + 1)]);
            }
         }
      }
      
      public function removeEnemy() : void
      {
         _theGame._enemies.splice(_theGame._enemies.indexOf(this),1);
         _theGame._enemyPool.push(this);
      }
      
      private function setCurrentTilePos() : void
      {
         _currentTilePos.x = _path[_pathIndex] % 14 * 50;
         _currentTilePos.y = Math.floor(_path[_pathIndex] / 14) * 50;
      }
      
      private function rotate() : void
      {
         var _loc1_:int = 0;
         _pathIndex++;
         if(_pathIndex < _path.length)
         {
            setCurrentTilePos();
            if(_pathIndex > 0)
            {
               _loc1_ = _path[_pathIndex] - _path[_pathIndex - 1];
            }
            else
            {
               _loc1_ = _path[0] - _clone.loader.y / 50 * 14 - _clone.loader.x / 50;
            }
            switch(_loc1_)
            {
               case 1:
                  _moveDirection.x = 1;
                  _moveDirection.y = 0;
                  if(_loadComplete && _clone.loader.content.hasOwnProperty("walk"))
                  {
                     _clone.loader.content.walk(2);
                  }
                  break;
               case -1:
                  _moveDirection.x = -1;
                  _moveDirection.y = 0;
                  if(_loadComplete && _clone.loader.content.hasOwnProperty("walk"))
                  {
                     _clone.loader.content.walk(1);
                  }
                  break;
               case 14:
                  _moveDirection.x = 0;
                  _moveDirection.y = 1;
                  if(_loadComplete && _clone.loader.content.hasOwnProperty("walk"))
                  {
                     _clone.loader.content.walk(3);
                  }
                  break;
               case -14:
                  _moveDirection.x = 0;
                  _moveDirection.y = -1;
                  if(_loadComplete && _clone.loader.content.hasOwnProperty("walk"))
                  {
                     _clone.loader.content.walk(0);
                  }
                  break;
               default:
                  throw new Error("Invalid path data");
            }
         }
         _state = 0;
      }
   }
}

