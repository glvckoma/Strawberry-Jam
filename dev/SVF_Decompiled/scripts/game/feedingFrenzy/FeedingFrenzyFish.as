package game.feedingFrenzy
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class FeedingFrenzyFish
   {
      public static const FISH_NEUTRAL:int = 0;
      
      public static const FISH_FLEE:int = 1;
      
      public static const FISH_ATTACK:int = 2;
      
      public static const GROUP_PATTERN_MULTIPLIER:int = 20;
      
      public static const GROWTH_THRESHOLD:Array = [400,700,1000];
      
      public static const GROUP_PATTERN:Array = [[0,-2],[-0.5,-1],[0.5,-1],[-1,0],[0,0],[1,0],[-0.5,1],[0.5,1],[0,2]];
      
      public var _clone:Object;
      
      public var _theGame:FeedingFrenzy;
      
      public var _groupParent:FeedingFrenzyFish;
      
      public var _groupPatternIndex:int;
      
      public var _type:int;
      
      public var _gotoPoint:Point = new Point();
      
      public var _speed:Number;
      
      public var _defaultSpeed:Number;
      
      public var _direction:Point = new Point();
      
      public var _currentSize:int;
      
      public var _currentGrowthPoints:Number;
      
      public var _init:Boolean;
      
      public var _queueDelete:Boolean;
      
      public var _state:int;
      
      public var _dist:Point = new Point();
      
      public var _mouseX:int;
      
      public var _mouseY:int;
      
      public var _prevMouseX:int;
      
      public var _prevMouseY:int;
      
      public var _checkTimer:Number;
      
      public function FeedingFrenzyFish(param1:FeedingFrenzy, param2:int = 0, param3:Boolean = true)
      {
         super();
         _theGame = param1;
         _type = param2;
         _checkTimer = 0;
         if(param3)
         {
            init();
         }
      }
      
      public function setType(param1:int) : void
      {
         _type = param1;
         _clone.fishType(_type);
         _clone.visible = false;
         _checkTimer = 0;
         _theGame._layerPlayer.addChild(_clone as DisplayObject);
         if(_groupParent == null)
         {
            _clone.y = Math.random() * 550;
            _gotoPoint.y = Math.random() * 550;
            if(Math.random() < 0.5)
            {
               _clone.x = 1000;
               _gotoPoint.x = -100;
            }
            else
            {
               _clone.x = -100;
               _gotoPoint.x = 1000;
            }
            _direction.x = _gotoPoint.x - _clone.x;
            _direction.y = _gotoPoint.y - _clone.y;
            _direction.normalize(1);
            _defaultSpeed = _theGame._fishSpeed[_type] + Math.random() * 10 - 5;
         }
         else
         {
            _clone.x = _groupParent._clone.x + GROUP_PATTERN[_groupPatternIndex][0] * 20;
            _clone.y = _groupParent._clone.y + GROUP_PATTERN[_groupPatternIndex][1] * 20;
            _defaultSpeed = _theGame._fishSpeed[_type];
         }
         _state = 0;
         _speed = _defaultSpeed;
         _queueDelete = false;
      }
      
      public function init() : void
      {
         var _loc1_:FeedingFrenzyFish = null;
         var _loc2_:int = 0;
         _init = false;
         if(_type != 7)
         {
            _clone = GETDEFINITIONBYNAME("ff_fish");
            if(_type >= 0)
            {
               _clone.fishType(_type);
            }
            else
            {
               _currentSize = _theGame._startingSize[Math.floor(_theGame._currentLevel / 10)][_theGame._currentLevel % 10] - 1;
               _clone.fishType(_currentSize,true);
            }
            _theGame._layerPlayer.addChild(_clone as DisplayObject);
            if(_type == -1)
            {
               _clone.x = 450;
               _clone.y = 225;
               _mouseX = _theGame._layerPlayer.mouseX;
               _mouseY = _theGame._layerPlayer.mouseY;
            }
            finishInit();
            if(_type != -1)
            {
               _clone.visible = false;
            }
         }
         else
         {
            _clone = {};
            finishInit();
            _loc2_ = 0;
            while(_loc2_ < GROUP_PATTERN.length)
            {
               _loc1_ = _theGame.getFish(0,false);
               _loc1_._groupPatternIndex = _loc2_;
               _loc1_._groupParent = this;
               if(_loc1_._clone)
               {
                  _loc1_.setType(0);
               }
               else
               {
                  _loc1_.init();
               }
               _loc1_._clone.visible = true;
               _theGame._fish.push(_loc1_);
               _loc2_++;
            }
         }
      }
      
      public function finishInit() : void
      {
         if(_type == -1)
         {
            _speed = 5;
         }
         else
         {
            if(_groupParent)
            {
               _clone.x = _groupParent._clone.x + GROUP_PATTERN[_groupPatternIndex][0] * 20;
               _clone.y = _groupParent._clone.y + GROUP_PATTERN[_groupPatternIndex][1] * 20;
            }
            else
            {
               _clone.y = Math.random() * 550;
               _gotoPoint.y = Math.random() * 550;
               if(Math.random() < 0.5)
               {
                  _clone.x = 1000;
                  _gotoPoint.x = -100;
               }
               else
               {
                  _clone.x = -100;
                  _gotoPoint.x = 1000;
               }
               _direction.x = _gotoPoint.x - _clone.x;
               _direction.y = _gotoPoint.y - _clone.y;
               _direction.normalize(1);
            }
            if(_type != 7)
            {
               if(_groupParent)
               {
                  _speed = _defaultSpeed = _theGame._fishSpeed[_type];
               }
               else
               {
                  _defaultSpeed = _theGame._fishSpeed[_type] + Math.random() * 10 - 5;
                  _speed = _defaultSpeed;
               }
            }
            else
            {
               _speed = _theGame._fishSpeed[0] * 0.5;
            }
         }
         _currentGrowthPoints = 0;
         _queueDelete = false;
         _init = true;
      }
      
      public function heartbeat(param1:Number, param2:int) : void
      {
         var _loc4_:* = NaN;
         var _loc3_:* = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:FeedingFrenzyFish = null;
         var _loc9_:Number = NaN;
         var _loc8_:int = 0;
         if(_init)
         {
            _loc6_ = Number(_clone.x);
            _loc7_ = Number(_clone.y);
            if(_type == -1)
            {
               _loc4_ = _mouseX;
               _loc3_ = _mouseY;
               _clone.x = _loc6_ + (_loc4_ - _loc6_) * _speed * param1;
               _clone.y = _loc7_ + (_loc3_ - _loc7_) * _speed * param1;
            }
            else
            {
               _checkTimer -= param1;
               if(_type == 3)
               {
                  if(_clone.blowfishSound)
                  {
                     _clone.blowfishSound = false;
                     _theGame._soundMan.playByName(_theGame._soundNameBlowfishPuff);
                  }
               }
               if(_state == 0)
               {
                  _loc4_ = _gotoPoint.x;
                  _loc3_ = _gotoPoint.y;
                  if(_groupParent)
                  {
                     _loc4_ = _gotoPoint.x = _groupParent._clone.x + GROUP_PATTERN[_groupPatternIndex][0] * 20;
                     _loc3_ = _gotoPoint.y = _groupParent._clone.y + GROUP_PATTERN[_groupPatternIndex][1] * 20;
                     _direction.x = _loc4_ - _clone.x;
                     _direction.y = _loc3_ - _clone.y;
                     _direction.normalize(1);
                     _clone.x = _loc6_ + _direction.x * _speed * param1;
                     _clone.y = _loc7_ + _direction.y * _speed * param1;
                     if(Math.abs(_clone.x - _loc4_) > Math.abs(_loc6_ - _loc4_))
                     {
                        _clone.x = _loc4_;
                     }
                     if(Math.abs(_clone.y - _loc3_) > Math.abs(_loc7_ - _loc3_))
                     {
                        _clone.y = _loc3_;
                     }
                  }
                  else
                  {
                     _clone.x = _loc6_ + _direction.x * _speed * param1;
                     _clone.y = _loc7_ + _direction.y * _speed * param1;
                     if(Math.abs(_clone.x - _loc4_) > Math.abs(_loc6_ - _loc4_) || Math.abs(_clone.y - _loc3_) > Math.abs(_loc7_ - _loc3_))
                     {
                        if(_clone.x < 0 || _clone.x > 900)
                        {
                           if(_type != 7)
                           {
                              _theGame.removeFish(this);
                           }
                           _theGame._fish.splice(param2,1);
                        }
                     }
                  }
               }
               else if(_state == 1 || _state == 2)
               {
                  _loc4_ = _gotoPoint.x;
                  _loc3_ = _gotoPoint.y;
                  _clone.x = _loc6_ + _direction.x * _speed * param1;
                  _clone.y = _loc7_ + _direction.y * _speed * param1;
                  if(Math.abs(_clone.x - _loc4_) > Math.abs(_loc6_ - _loc4_) || Math.abs(_clone.y - _loc3_) > Math.abs(_loc7_ - _loc3_))
                  {
                     if(_groupParent)
                     {
                        _checkTimer = 0;
                     }
                     setState(0);
                  }
               }
            }
            if(_loc4_ - _loc6_ > 0 && _clone.scaleX < 0 || _loc4_ - _loc6_ < 0 && _clone.scaleX > 0)
            {
               _clone.scaleX *= -1;
               _clone.turn();
            }
            if(_type == -1 && _clone.alpha == 1)
            {
               _loc8_ = 0;
               while(_loc8_ < _theGame._fish.length)
               {
                  _loc5_ = _theGame._fish[_loc8_];
                  if(_loc5_ != this && _loc5_._type != 7)
                  {
                     _dist.x = _loc5_._clone.x - _clone.x;
                     _dist.y = _loc5_._clone.y - _clone.y;
                     _loc9_ = _loc5_._clone.width * 0.5 + _clone.width * 0.5;
                     if(_currentSize < _loc5_._type && _theGame.boxCollisionTestLocal(_loc5_._clone.collisionMouth,_clone.collision))
                     {
                        _loc5_._clone.eat();
                        _theGame._soundMan.playByName(_theGame._soundNameDeath);
                        _queueDelete = true;
                     }
                     else if(_currentSize >= _loc5_._type && _theGame.boxCollisionTestLocal(_loc5_._clone.collision,_clone.collisionMouth))
                     {
                        _loc5_._queueDelete = true;
                        _clone.eat();
                        _theGame._soundMan.playByName(_theGame._soundNameFishEats);
                        _currentGrowthPoints += _theGame.getGrowthPoints(_loc5_._type);
                        if(_currentGrowthPoints >= GROWTH_THRESHOLD[_theGame._difficulty])
                        {
                           _currentSize++;
                           _currentGrowthPoints = 0;
                           _theGame.checkGrowthTarget();
                        }
                        _theGame.updateGrowth();
                     }
                     else if(_dist.length < _loc9_ + 50)
                     {
                        if(_currentSize >= _loc5_._type)
                        {
                           if(_theGame._difficulty > 0)
                           {
                              _loc5_._dist = _dist;
                              _loc5_.setState(1);
                           }
                        }
                        else
                        {
                           _loc5_._dist = _dist;
                           _loc5_.setState(2);
                        }
                     }
                  }
                  _loc8_++;
               }
            }
         }
      }
      
      public function setState(param1:int) : void
      {
         var _loc2_:int = _state;
         if(_state != param1 && _type != 7)
         {
            _state = param1;
            if(_state == 1)
            {
               if(_checkTimer <= 0)
               {
                  if(Math.random() < 0.5 || _groupParent)
                  {
                     _direction.x = _dist.x;
                     _direction.y = _dist.y;
                     _direction.normalize(1);
                     _speed = _defaultSpeed * 1.5;
                     _gotoPoint.x = _clone.x + _direction.x * 100;
                     _gotoPoint.y = _clone.y + _direction.y * 100;
                     if(_groupParent && _groupParent._checkTimer <= 0 && _groupPatternIndex == 4)
                     {
                        _groupParent._clone.x = _clone.x + _direction.x * 100;
                        _groupParent._clone.y = _clone.y + _direction.y * 100;
                        _groupParent._direction.x = _direction.x;
                        _groupParent._direction.y = _direction.y;
                        _groupParent._gotoPoint.x = _groupParent._clone.x + _direction.x * 1500;
                        _groupParent._gotoPoint.y = _groupParent._clone.y + _direction.y * 1500;
                        _groupParent._checkTimer = 4;
                     }
                  }
                  else
                  {
                     _state = _loc2_;
                  }
                  _checkTimer = 3;
               }
               else
               {
                  _state = _loc2_;
               }
            }
            else if(_state == 2)
            {
               _direction.x = -_dist.x;
               _direction.y = -_dist.y;
               _direction.normalize(1);
               _speed = _defaultSpeed * 1.5;
               _gotoPoint.x = _theGame._player1._clone.x;
               _gotoPoint.y = _theGame._player1._clone.y;
            }
            else if(_state == 0)
            {
               _gotoPoint.y = Math.random() * 550;
               if(Math.random() < 0.5)
               {
                  _gotoPoint.x = -100;
               }
               else
               {
                  _gotoPoint.x = 1000;
               }
               _direction.x = _gotoPoint.x - _clone.x;
               _direction.y = _gotoPoint.y - _clone.y;
               _direction.normalize(1);
               _speed = _defaultSpeed;
            }
         }
      }
   }
}

