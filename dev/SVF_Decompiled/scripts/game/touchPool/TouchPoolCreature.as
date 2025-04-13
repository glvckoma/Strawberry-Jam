package game.touchPool
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class TouchPoolCreature
   {
      public static const TYPE_HORSESHOECRAB:int = 0;
      
      public static const TYPE_RAY:int = 1;
      
      public static const TYPE_SEASLUG:int = 2;
      
      public static const TYPE_HERMITCRAB:int = 3;
      
      public static const TYPE_STARFISH:int = 4;
      
      public static const TYPE_URCHIN:int = 5;
      
      public static const ROTATION_RATE:Number = 8;
      
      public static var RAYSPEEDLOW:int = 100;
      
      public static var RAYSPEEDHIGH:int = 140;
      
      public static var RAYSPEEDFLEE:int = 240;
      
      public static var HSCRABSPEEDLOW:int = 80;
      
      public static var HSCRABSPEEDHIGH:int = 120;
      
      public static var HSCRABSPEEDFLEE:int = 190;
      
      public static var SLUGSPEEDLOW:int = 5;
      
      public static var SLUGSPEEDHIGH:int = 15;
      
      public static var SLUGSPEEDFLEE:int = 35;
      
      public static var HERMITSPEEDLOW:int = 10;
      
      public static var HERMITSPEEDHIGH:int = 25;
      
      private var _theGame:TouchPool;
      
      public var _clone:Object;
      
      public var _type:int;
      
      public var _color:int;
      
      private var _speed:Number;
      
      private var _currentSpeed:Number;
      
      private var _rippleTimer:int;
      
      private var _fleeTimer:Number;
      
      private var _thinkTimer:Number;
      
      private var _creature_rotation:Number;
      
      private var _angleToMouse:Number;
      
      private var _currentPoint:int;
      
      public var _wake:Array;
      
      private var _currentWakeIndex:int;
      
      public var _content:MovieClip;
      
      private var _scaleFactorWakeSpread:Number;
      
      private var _numWakes:int;
      
      private var _wakeScaleFactor:int;
      
      public var _spawnIndex:int;
      
      public function TouchPoolCreature(param1:TouchPool)
      {
         super();
         _theGame = param1;
      }
      
      public static function getLogIndexFromType(param1:int) : int
      {
         switch(param1)
         {
            case 0:
               return 4;
            case 1:
               return 2;
            case 2:
               return 5;
            case 3:
               return 1;
            case 4:
               return 6;
            case 5:
               return 3;
            default:
               return -1;
         }
      }
      
      public static function getTypeFromLogIndex(param1:int) : int
      {
         switch(param1 - 1)
         {
            case 0:
               return 3;
            case 1:
               return 1;
            case 2:
               return 5;
            case 3:
               return 0;
            case 4:
               return 2;
            case 5:
               return 4;
            default:
               return -1;
         }
      }
      
      public static function getFactIndexFromType(param1:int) : int
      {
         switch(param1)
         {
            case 0:
               return 1;
            case 1:
               return 5;
            case 2:
               return 2;
            case 3:
               return 0;
            case 4:
               return 3;
            case 5:
               return 4;
            default:
               return -1;
         }
      }
      
      public function getNumGems() : int
      {
         switch(_type)
         {
            case 0:
            case 1:
               return 7;
            case 2:
            case 3:
               return 5;
            case 4:
            case 5:
               return 3;
            default:
               return 0;
         }
      }
      
      public function getTouchTime() : int
      {
         switch(_type)
         {
            case 0:
            case 1:
               return 4;
            case 2:
            case 3:
               return 3;
            case 4:
            case 5:
               return 2;
            default:
               return 0;
         }
      }
      
      public function setSpeed() : void
      {
         switch(_type)
         {
            case 0:
               _speed = Math.random() * Math.abs(HSCRABSPEEDHIGH - HSCRABSPEEDLOW) + HSCRABSPEEDLOW;
               break;
            case 1:
               _speed = Math.random() * Math.abs(RAYSPEEDHIGH - RAYSPEEDLOW) + RAYSPEEDLOW;
               break;
            case 2:
               _speed = Math.random() * Math.abs(SLUGSPEEDHIGH - SLUGSPEEDLOW) + SLUGSPEEDLOW;
               break;
            case 3:
               _speed = Math.random() * Math.abs(HERMITSPEEDHIGH - HERMITSPEEDLOW) + HERMITSPEEDLOW;
         }
      }
      
      public function setWakeSpread() : void
      {
         _wakeScaleFactor = 1;
         switch(_type)
         {
            case 0:
               _scaleFactorWakeSpread = 1;
               _numWakes = 4;
               _wakeScaleFactor = 1.35;
               break;
            case 1:
               _scaleFactorWakeSpread = 3;
               _numWakes = 4;
               _wakeScaleFactor = 2.3;
               break;
            case 2:
               _scaleFactorWakeSpread = 1;
               _numWakes = 6;
               _wakeScaleFactor = 1.6;
         }
      }
      
      public function getFleeSpeed() : int
      {
         switch(_type)
         {
            case 0:
               return HSCRABSPEEDFLEE;
            case 1:
               return RAYSPEEDFLEE;
            case 2:
               return SLUGSPEEDFLEE;
            default:
               return 0;
         }
      }
      
      public function init(param1:int, param2:int, param3:int, param4:Boolean) : void
      {
         var _loc5_:int = 0;
         _thinkTimer = 0;
         _type = param1;
         _clone = _theGame.getScene().getLayer("c" + (param1 * 2 + (param4 ? 0 : 1)));
         _content = _clone.loader.content;
         switch(param1)
         {
            case 0:
            case 1:
               setSpeed();
               break;
            case 2:
               setSpeed();
               _thinkTimer = 10;
               break;
            case 3:
               setSpeed();
               _content.walk();
         }
         if(_content.hasOwnProperty("init"))
         {
            _content.init();
         }
         _currentSpeed = _speed;
         _clone.loader.x = param2;
         _clone.loader.y = param3;
         _color = Math.floor(Math.random() * 5) + 1;
         _content.changeColor(_color);
         _currentPoint = Math.floor(Math.random() * _theGame._poolPoints.length);
         setWakeSpread();
         if(param1 < 3)
         {
            _wake = [];
            _loc5_ = 0;
            while(_loc5_ < _numWakes)
            {
               _wake[_loc5_] = GETDEFINITIONBYNAME("tierneyPool_wake");
               if(param1 == 2)
               {
                  _wake[_loc5_].alpha = 0.2;
               }
               _wake[_loc5_].scaleX = _wake[_loc5_].scaleY = _wakeScaleFactor;
               _loc5_++;
            }
            _currentWakeIndex = 0;
         }
         _creature_rotation = 0;
         _angleToMouse = 0;
         _rippleTimer = 0;
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:int = 0;
         var _loc2_:Object = null;
         if(_type <= 3)
         {
            _loc7_ = Number(_theGame._poolPoints[_currentPoint].x);
            _loc3_ = Number(_theGame._poolPoints[_currentPoint].y);
            _loc5_ = _creature_rotation * (3.141592653589793 / 180);
            _angleToMouse = Math.atan2(_loc3_ - _clone.loader.y,_loc7_ - _clone.loader.x);
            _loc6_ = Math.atan2(Math.sin(_angleToMouse - _loc5_),Math.cos(_angleToMouse - _loc5_));
            _creature_rotation += Math.max(Math.min(180 / 3.141592653589793 * _loc6_,8),-8);
            _loc5_ = _creature_rotation * (3.141592653589793 / 180);
            _content.creature.rotation = _creature_rotation + 90;
            _clone.loader.x += Math.cos(_loc5_) * _currentSpeed * param1;
            _clone.loader.y += Math.sin(_loc5_) * _currentSpeed * param1;
            if((_clone.loader.x - _loc7_) * (_clone.loader.x - _loc7_) + (_clone.loader.y - _loc3_) * (_clone.loader.y - _loc3_) < 3000)
            {
               _currentPoint = Math.floor(Math.random() * _theGame._poolPoints.length);
            }
            if(_fleeTimer > 0)
            {
               _fleeTimer -= param1;
            }
            if(_thinkTimer > 0)
            {
               _thinkTimer -= param1;
               if(_thinkTimer <= 0)
               {
                  _thinkTimer = 10;
                  if(_speed == 0)
                  {
                     setSpeed();
                  }
                  else if(_speed != SLUGSPEEDFLEE && Math.random() < 0.5)
                  {
                     _speed = 0;
                  }
               }
            }
            _loc4_ = 0;
            while(_loc4_ < _theGame._ripple.length)
            {
               if(_theGame._ripple[_loc4_].width > 0 && (_clone.loader.x - _theGame._ripple[_loc4_].x) * (_clone.loader.x - _theGame._ripple[_loc4_].x) + (_clone.loader.y - _theGame._ripple[_loc4_].y) * (_clone.loader.y - _theGame._ripple[_loc4_].y) < Math.pow(_clone.width + _theGame._ripple[_loc4_].width,2) * 0.25)
               {
                  if(_type == 3)
                  {
                     _loc2_ = GETDEFINITIONBYNAME("tierneyPool_dustCloud");
                     _theGame._dustClouds.push(_loc2_);
                     _theGame._soundMan.playByName(_theGame._soundNamePoof);
                     _loc2_.dustOn();
                     _loc2_.x = _clone.loader.x + _content.creature.x;
                     _loc2_.y = _clone.loader.y + _content.creature.y;
                     _theGame._layerGems.addChild(_loc2_ as DisplayObject);
                     _currentPoint += Math.floor(Math.random() * _theGame._poolPoints.length) + 1;
                     _currentPoint %= _theGame._poolPoints.length;
                     _clone.loader.x = _theGame._poolPoints[_currentPoint].x;
                     _clone.loader.y = _theGame._poolPoints[_currentPoint].y;
                  }
                  else if(_currentSpeed != getFleeSpeed())
                  {
                     _currentSpeed = getFleeSpeed();
                     _content.walk();
                     _rippleTimer = 0;
                  }
                  _fleeTimer = 3;
                  break;
               }
               _loc4_++;
            }
            if(_fleeTimer <= 0)
            {
               if(_currentSpeed != _speed)
               {
                  _currentSpeed = _speed;
                  _rippleTimer = 0;
                  _content.idle();
               }
            }
            if(_type != 3)
            {
               if(_rippleTimer == 0)
               {
                  _rippleTimer = getRippleTime();
                  _wake[_currentWakeIndex].rotation = _creature_rotation + 90;
                  _wake[_currentWakeIndex].x = _clone.loader.x + (!!_content.hasOwnProperty("creature") ? _content.creature.x : 0);
                  _wake[_currentWakeIndex].y = _clone.loader.y + (!!_content.hasOwnProperty("creature") ? _content.creature.y : 0);
                  _wake[_currentWakeIndex].gotoAndPlay(2);
                  _currentWakeIndex++;
                  if(_currentWakeIndex >= _wake.length)
                  {
                     _currentWakeIndex = 0;
                  }
               }
               else
               {
                  _rippleTimer -= 1;
               }
            }
         }
         if(_content.hasOwnProperty("creatureRotation"))
         {
            _content.creatureRotation(null);
         }
      }
      
      private function getRippleTime() : int
      {
         return Math.max(Math.floor(450 * _scaleFactorWakeSpread / _currentSpeed),1);
      }
      
      public function setRotation(param1:Number) : void
      {
         _content.creature.rotation = param1;
      }
      
      public function changeColor(param1:int) : void
      {
         _content.changeColor(param1);
      }
      
      public function removeEvents() : void
      {
         _content.removeEvents();
      }
   }
}

