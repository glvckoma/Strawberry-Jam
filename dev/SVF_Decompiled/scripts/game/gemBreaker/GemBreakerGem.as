package game.gemBreaker
{
   import flash.events.Event;
   import flash.geom.Point;
   
   public class GemBreakerGem
   {
      public static const GEMSTATE_READY:int = 0;
      
      public static const GEMSTATE_CHECKED:int = 1;
      
      public static const GEMSTATE_FALLING:int = 2;
      
      private var _theGame:GemBreaker;
      
      public var _clone:Object;
      
      public var _type:int;
      
      public var _moveDirection:Point;
      
      public var _targetLocation:Point;
      
      public var _targetRowColumn:Point;
      
      private var _moving:Boolean;
      
      private var _movingFinal:Boolean;
      
      private var _velocity:Number;
      
      public var _state:int;
      
      public var _player:GemBreakerPlayer;
      
      public var _distanceToTravel:Number;
      
      public var _distanceTraveled:Number;
      
      public var _distanceDropoff:Number;
      
      public var _bRandom:Boolean;
      
      public function GemBreakerGem(param1:GemBreaker, param2:int, param3:GemBreakerPlayer)
      {
         super();
         _theGame = param1;
         _type = param2;
         _moveDirection = new Point();
         _targetLocation = new Point();
         _targetRowColumn = new Point();
         _moving = false;
         _player = param3;
         init();
      }
      
      public function init() : void
      {
         _clone = _theGame.getScene().cloneAsset("gem");
         _clone.loader.contentLoaderInfo.addEventListener("complete",onGemLoaderComplete);
         _state = 0;
         _bRandom = false;
      }
      
      public function reset(param1:int, param2:Boolean) : void
      {
         _type = param1;
         _moving = false;
         _state = 0;
         _bRandom = param2;
         _clone.loader.content.gemColor(_type);
         _clone.loader.content.gemBlur(0,0,0);
         if(_bRandom)
         {
            _clone.loader.content.appear();
         }
      }
      
      public function onGemLoaderComplete(param1:Event) : void
      {
         _clone.loader.content.gemColor(_type);
         if(_bRandom)
         {
            _clone.loader.content.appear();
         }
         _clone.loader.contentLoaderInfo.removeEventListener("complete",onGemLoaderComplete);
      }
      
      public function remove() : void
      {
         if(_clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function setMoving() : void
      {
         _moving = true;
         _movingFinal = false;
         _velocity = 1000;
         _distanceTraveled = 0;
         _state = 0;
      }
      
      public function moveStep(param1:Number) : void
      {
         var _loc2_:Number = NaN;
         if(_moving)
         {
            if(_distanceToTravel < 125)
            {
               _velocity -= 3000 * param1;
               if(_velocity < 300)
               {
                  _velocity += 3000 * param1;
               }
            }
            _clone.loader.x += _moveDirection.x * param1 * _velocity;
            _clone.loader.y += _moveDirection.y * param1 * _velocity;
            _distanceToTravel -= param1 * _velocity;
            _distanceTraveled += param1 * _velocity;
            _loc2_ = Math.atan2(_moveDirection.y,_moveDirection.x) * 180 / 3.141592653589793 + 90;
            _clone.loader.content.gemBlur(0.75,0.5,_loc2_);
            if(_clone.loader.x < 55 + _player._xOffset && _moveDirection.x < 0 || _clone.loader.x > 360 + _player._xOffset && _moveDirection.x > 0)
            {
               _moveDirection.x *= -1;
               _theGame._soundMan.playByName(_theGame._soundNameCollision1);
            }
            if(_clone.loader.y < 30 || _distanceToTravel <= 5)
            {
               _movingFinal = true;
               _moving = false;
               _moveDirection.x = _targetLocation.x - _clone.loader.x;
               _moveDirection.y = _targetLocation.y - _clone.loader.y;
               _moveDirection.normalize(1);
               _velocity = 0;
               _clone.loader.content.gemBlur(0,0,0);
            }
         }
      }
      
      public function setState(param1:int) : void
      {
         if(param1 == 2)
         {
            _velocity = 0;
         }
         _state = param1;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Point = null;
         var _loc3_:int = 0;
         if(_moving)
         {
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               moveStep(param1 / 4);
               _loc2_++;
            }
         }
         if(_movingFinal)
         {
            _player._flyingGems.splice(_player._flyingGems.indexOf(this),1);
            _clone.loader.x = _targetLocation.x;
            _clone.loader.y = _targetLocation.y;
            _loc4_ = _player._gemGrid.getGridCoords(this,_theGame.getScene().getLayer("gem").loader.width);
            _loc3_ = _player.placeGem(_loc4_.x,_loc4_.y,this,true);
            _player.score(_loc3_);
            if(_loc3_ > 0)
            {
               _theGame._soundMan.playByName(_theGame._soundNameGemBreak);
            }
            else
            {
               _theGame._soundMan.playByName(_theGame._soundNameCollision1);
            }
            _movingFinal = false;
         }
         if(_state == 2)
         {
            _velocity += 1000 * param1;
            _clone.loader.y += param1 * _velocity;
            if(_clone.loader.y > 650)
            {
               if(_clone.loader.parent)
               {
                  _clone.loader.parent.removeChild(_clone.loader);
               }
               _player.removeGem(this);
            }
         }
         else if(_state == 1)
         {
            if(_clone.loader.content.finished)
            {
               if(_clone.loader.parent)
               {
                  _clone.loader.parent.removeChild(_clone.loader);
               }
               _player._gemPoolTemp.splice(_player._gemPoolTemp.indexOf(this),1);
               _player.safePush(_player._gemPool,this);
            }
         }
      }
      
      public function canRecycle() : Boolean
      {
         return false;
      }
   }
}

