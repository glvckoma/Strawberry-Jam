package game.twister
{
   import flash.display.Loader;
   import flash.geom.Point;
   
   public class TwisterPlayer
   {
      public static const ACCELERATION:int = 400;
      
      public static const MAX_VELOCITY_X:int = 150;
      
      public static const MAX_VELOCITY_Y:int = 200;
      
      public static const COLLISION_FACTOR:Number = 0.5;
      
      public static const ROTATION_RATE:Number = 8;
      
      public static const FLIGHT_SPEED:Number = 180;
      
      public static const STAR_DROP_INTERVAL:Number = 0.1;
      
      public var _clone:Object;
      
      public var _theGame:Twister;
      
      public var _currentXVel:Number;
      
      public var _currentYVel:Number;
      
      public var _colliding:Boolean;
      
      public var _bird_rotation:Number;
      
      public var _bird_posX:Number;
      
      public var _lastMousePos:Point;
      
      public var _moveDirection:Point;
      
      public var _angleToMouse:Number;
      
      public var _angleInRads:Number;
      
      public var _speed:Number;
      
      public var _movementVector:Point;
      
      public var _fakeWeight:Number;
      
      public var _tornadoPosX:Number;
      
      public var _delayStartTimer:Number;
      
      public var _displayCountdown:Boolean;
      
      public var _glowLoader:Loader;
      
      public var _starDropTimer:Number;
      
      public function TwisterPlayer(param1:Twister)
      {
         super();
         _theGame = param1;
         init();
      }
      
      public function init() : void
      {
         _clone = _theGame.getScene().getLayer("player");
         _clone.loader.scaleX = 0.6;
         _clone.loader.scaleY = 0.6;
         _lastMousePos = new Point(_theGame._layerPlayer.mouseX,_theGame._layerPlayer.mouseY);
         _angleToMouse = 0;
         _speed = 180;
         _movementVector = new Point(1,0);
         _moveDirection = new Point();
         _fakeWeight = 1;
         _angleInRads = 0;
         _bird_posX = _clone.loader.x;
         _bird_rotation = 0;
         _tornadoPosX = _theGame.getTornadoX();
         _delayStartTimer = 5;
         _displayCountdown = false;
         _starDropTimer = 0.1;
         _currentXVel = 0;
         _currentYVel = 0;
         _colliding = false;
         _theGame._layerPlayer.addChild(_clone.loader);
      }
      
      public function reset() : void
      {
         _angleToMouse = 0;
         _speed = 180;
         _movementVector.x = 1;
         _movementVector.y = 0;
         _fakeWeight = 1;
         _angleInRads = 0;
         _bird_posX = _clone.loader.x;
         _bird_rotation = 0;
         _clone.loader.content.bird.rotation = 0;
         _clone.loader.content.arrow.rotation = 0;
         _clone.loader.content.arrow.fadeArrow = 100;
         _clone.loader.y = 227;
         _tornadoPosX = _theGame.getTornadoX();
         _delayStartTimer = 5;
         _displayCountdown = false;
         _starDropTimer = 0.1;
         _glowLoader.visible = true;
         _currentXVel = 0;
         _currentYVel = 0;
         _colliding = false;
      }
      
      public function remove() : void
      {
         if(_clone && _clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function getXSpeed() : Number
      {
         if(_theGame._playerMovesHorizontally)
         {
            return 0;
         }
         return _currentXVel;
      }
      
      public function setColliding(param1:Boolean) : void
      {
         if(param1 && !_colliding)
         {
            _theGame._soundMan.playByName(_theGame._soundNameCollisionBird);
         }
         _colliding = param1;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc2_:Number = _theGame._layerPlayer.mouseX;
         var _loc5_:Number = _theGame._layerPlayer.mouseY;
         var _loc4_:Number = _loc5_ - _clone.loader.y;
         if(_delayStartTimer > 0)
         {
            _delayStartTimer -= param1;
            if(_delayStartTimer < 3 && _displayCountdown == false)
            {
               _displayCountdown = true;
               _theGame.doCountdown();
            }
         }
         _moveDirection.x = 0;
         _moveDirection.y = 0;
         if(Math.abs(_loc4_) > 1)
         {
            if(_loc4_ < 0)
            {
               _moveDirection.y = 1;
            }
            else if(_loc4_ > 0)
            {
               _moveDirection.y = -1;
            }
         }
         _lastMousePos.x = _loc2_;
         _lastMousePos.y = _loc5_;
         if(_moveDirection.y != 0)
         {
            _loc8_ = _bird_rotation * (3.141592653589793 / 180);
            _angleToMouse = Math.atan2(_loc5_ - _clone.loader.y,_loc2_ - _clone.loader.x);
            _loc7_ = Math.atan2(Math.sin(_angleToMouse - _loc8_),Math.cos(_angleToMouse - _loc8_));
            if(_delayStartTimer <= 0)
            {
               _bird_rotation += Math.max(Math.min(180 / 3.141592653589793 * _loc7_,8),-8);
               _loc8_ = _bird_rotation * (3.141592653589793 / 180);
               _clone.loader.content.bird.rotation = _bird_rotation;
               _angleInRads = _loc8_;
               _clone.loader.content.arrow.rotation = _angleToMouse * 180 / 3.141592653589793;
            }
         }
         _movementVector.x = Math.cos(_angleInRads) * _speed;
         _movementVector.y = Math.sin(_angleInRads) * _speed;
         _bird_posX += _movementVector.x * param1;
         _clone.loader.y += _movementVector.y * param1;
         _tornadoPosX += (180 - 20) * param1;
         var _loc3_:Number = _bird_posX - _tornadoPosX;
         _glowLoader.x = _clone.loader.x;
         _glowLoader.y = _clone.loader.y;
         Object(_glowLoader.content).bird.rotation = _clone.loader.content.bird.rotation;
         _starDropTimer -= param1;
         if(_starDropTimer <= 0)
         {
            _theGame.addStarTrail();
            _starDropTimer = 0.1;
         }
         var _loc6_:Number = _loc3_ - 100 * ((550 - _clone.loader.y) / 550);
         if(_loc6_ < 75)
         {
            _theGame.setGameState(5);
            _theGame._soundMan.playByName(_theGame._soundNameStingerFail);
            _theGame.stopBGSounds();
            return;
         }
         _theGame.setTornadoX(_clone.loader.x - _loc3_);
         if(_colliding)
         {
            _speed = 180 * 0.5;
         }
         else
         {
            _speed = 180;
         }
      }
   }
}

