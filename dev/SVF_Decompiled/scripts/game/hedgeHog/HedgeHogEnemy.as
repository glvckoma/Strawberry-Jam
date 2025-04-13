package game.hedgeHog
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   
   public class HedgeHogEnemy
   {
      public static const MODE_ROAM:int = 0;
      
      public static const MODE_CHASE:int = 1;
      
      public static const MODE_FEAR:int = 2;
      
      public static const MODE_DIE:int = 3;
      
      public static const MODE_WAITING:int = 4;
      
      private static const RIGHT:int = 0;
      
      private static const UP:int = 1;
      
      private static const LEFT:int = 2;
      
      private static const DOWN:int = 3;
      
      public var MODE_SWITCH_TIME:int;
      
      private var _theGame:HedgeHog;
      
      public var i:int;
      
      public var j:int;
      
      public var turnX:Number;
      
      public var turnY:Number;
      
      public var turnDirection:int;
      
      public var _mode:int;
      
      public var _direction:int;
      
      public var _clone:Object;
      
      public var _speed:Number;
      
      public var _directions:Array = [0,0,0,0];
      
      public var _detectionRadius:Number;
      
      public var _detectionObject:Object;
      
      private var _tempObject:Object = {};
      
      public var _respawnTime:int;
      
      private var _respawnTimer:Number;
      
      private var _forceCheck:Boolean;
      
      private var _modeSwitchTimer:Number;
      
      private var _warningPlaying:Boolean;
      
      public function HedgeHogEnemy(param1:HedgeHog, param2:int, param3:int, param4:Number)
      {
         super();
         _theGame = param1;
         _clone = GETDEFINITIONBYNAME("hedgeHog_enemy");
         setStartingLocation(param2,param3);
         MODE_SWITCH_TIME = _theGame._phantomModeSwitchTime;
         _speed = _theGame._phantomBaseSpeed;
         _mode = 4;
         _detectionRadius = 200;
         _detectionObject = new Sprite();
         _detectionObject.graphics.beginFill(16711680);
         _detectionObject.graphics.drawCircle(0,0,_detectionRadius);
         _detectionObject.graphics.endFill();
         _detectionObject.alpha = 0.5;
         _clone.addChild(_detectionObject as DisplayObject);
         _respawnTime = _theGame._phantomRespawnTime;
         _respawnTimer = param4;
         _detectionObject.visible = false;
         _modeSwitchTimer = MODE_SWITCH_TIME;
         if(_respawnTimer > _theGame._powerUpWarningTime)
         {
            _mode = 4;
            _clone.visible = false;
         }
         else
         {
            _clone.spawnWarning();
         }
      }
      
      private function setStartingLocation(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         i = param1;
         j = param2;
         _theGame.setTurnXY(i,j,this);
         _clone.x = turnX;
         _clone.y = turnY;
         turnX = turnY = -1;
         _direction = -1;
         getPossibleDirections();
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            if(_directions[_loc3_] == 1)
            {
               _direction = _loc3_;
               break;
            }
            _loc3_++;
         }
         _directions[0] = _directions[1] = _directions[2] = _directions[3] = 0;
      }
      
      public function isSeekingPlayer() : Boolean
      {
         return _mode == 1 || _mode == 0;
      }
      
      public function changeMode(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         if((_mode != param1 || _mode == 2) && _respawnTimer <= 0)
         {
            _mode = param1;
            if(_mode == 2)
            {
               _warningPlaying = false;
               _clone.powerDown();
               _forceCheck = true;
               _speed = _theGame._phantomBaseSpeed * 0.5;
            }
            else if(_mode == 4)
            {
               _respawnTimer = _respawnTime;
               _loc2_ = _theGame.getPhantomSpawnIndex();
               _loc3_ = _theGame.getCurrentLevelArray();
               setStartingLocation(Math.floor(_theGame._phantomSpawnIndices[_loc2_] / _loc3_[0].length),_theGame._phantomSpawnIndices[_loc2_] % _loc3_[0].length);
            }
            else if(_mode == 3)
            {
               _clone.die();
            }
            else
            {
               _warningPlaying = false;
               _speed = _theGame._phantomBaseSpeed;
            }
         }
      }
      
      private function getDistSq(param1:Number, param2:Number) : Number
      {
         return (param1 - _theGame._player._clone.x) * (param1 - _theGame._player._clone.x) + (param2 - _theGame._player._clone.y) * (param2 - _theGame._player._clone.y);
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc8_:* = 0;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Number = NaN;
         var _loc4_:* = NaN;
         var _loc7_:int = i;
         var _loc6_:int = j;
         _theGame.getGridIndices(_clone.x,_clone.y,this);
         if(_mode == 4)
         {
            _respawnTimer -= param1;
            if(_respawnTimer < _theGame._powerUpWarningTime && !_warningPlaying)
            {
               _clone.visible = true;
               _clone.spawnWarning();
               _warningPlaying = true;
               _theGame.playPortal();
            }
            if(_respawnTimer <= 0)
            {
               _theGame.playPhantomSpawn();
               _clone.visible = true;
               _warningPlaying = false;
               _clone.spawn();
               if(_theGame._energizerTimer > 2)
               {
                  changeMode(2);
               }
               else if(_theGame._energizerTimer > 0)
               {
                  changeMode(2);
                  _clone.powerUpWarning();
               }
               else
               {
                  changeMode(0);
               }
            }
         }
         else if(_mode == 3)
         {
            if(_clone.busy == false)
            {
               _clone.visible = false;
               changeMode(4);
            }
         }
         else
         {
            if(_mode != 2)
            {
               _modeSwitchTimer -= param1;
               if(_modeSwitchTimer <= 0)
               {
                  changeMode(_mode == 0 ? 1 : 0);
                  _modeSwitchTimer = MODE_SWITCH_TIME;
               }
            }
            if(turnX < 0 && turnY < 0)
            {
               if(Math.abs(_loc7_ - i) > 1 && Math.abs(_loc7_ - i) < 5 || Math.abs(_loc6_ - j) > 1 && Math.abs(_loc6_ - j) < 5)
               {
                  trace("skipped a square!");
               }
               if(_loc7_ != i || _loc6_ != j)
               {
                  if(getPossibleDirections())
                  {
                     if(isSeekingPlayer())
                     {
                        if(_mode == 1 || getDistSq(_clone.x,_clone.y) < _detectionRadius * _detectionRadius)
                        {
                           _loc4_ = 1.7976931348623157e+308;
                           _loc9_ = 0;
                           while(_loc9_ < 4)
                           {
                              if(_directions[_loc9_] == 1)
                              {
                                 switch(_loc9_)
                                 {
                                    case 0:
                                       _loc5_ = i;
                                       _loc3_ = j + 1;
                                       break;
                                    case 1:
                                       _loc5_ = i - 1;
                                       _loc3_ = j;
                                       break;
                                    case 2:
                                       _loc5_ = i;
                                       _loc3_ = j - 1;
                                       break;
                                    case 3:
                                       _loc5_ = i + 1;
                                       _loc3_ = j;
                                 }
                                 _theGame.setTurnXY(_loc5_,_loc3_,_tempObject);
                                 _loc2_ = getDistSq(_tempObject.turnX,_tempObject.turnY);
                                 if(_loc2_ < _loc4_)
                                 {
                                    _loc4_ = _loc2_;
                                    _loc8_ = _loc9_;
                                 }
                              }
                              _loc9_++;
                           }
                        }
                        else
                        {
                           _loc8_ = Math.floor(Math.random() * 4);
                           while(_directions[_loc8_] == 0)
                           {
                              _loc8_++;
                              if(_loc8_ == _directions.length)
                              {
                                 _loc8_ = 0;
                              }
                           }
                        }
                     }
                     else if(_mode == 2)
                     {
                        _loc4_ = -1;
                        _loc9_ = 0;
                        while(_loc9_ < 4)
                        {
                           if(_directions[_loc9_] == 1)
                           {
                              switch(_loc9_)
                              {
                                 case 0:
                                    _loc5_ = i;
                                    _loc3_ = j + 1;
                                    break;
                                 case 1:
                                    _loc5_ = i - 1;
                                    _loc3_ = j;
                                    break;
                                 case 2:
                                    _loc5_ = i;
                                    _loc3_ = j - 1;
                                    break;
                                 case 3:
                                    _loc5_ = i + 1;
                                    _loc3_ = j;
                              }
                              _theGame.setTurnXY(_loc5_,_loc3_,_tempObject);
                              _loc2_ = getDistSq(_tempObject.turnX,_tempObject.turnY);
                              if(_loc2_ > _loc4_)
                              {
                                 _loc4_ = _loc2_;
                                 _loc8_ = _loc9_;
                              }
                           }
                           _loc9_++;
                        }
                     }
                     if(_loc8_ != _direction)
                     {
                        if(Math.abs(_loc8_ - _direction) == 2)
                        {
                           _direction = _loc8_;
                        }
                        else
                        {
                           _theGame.setTurningPointXY(_loc8_,_direction,this);
                           turnDirection = _loc8_;
                        }
                     }
                     _directions[0] = _directions[1] = _directions[2] = _directions[3] = 0;
                  }
                  else
                  {
                     _loc8_ = 0;
                     while(_loc8_ < 4)
                     {
                        if(_directions[_loc8_] == 1)
                        {
                           if(_loc8_ != _direction)
                           {
                              _theGame.setTurningPointXY(_loc8_,_direction,this);
                              turnDirection = _loc8_;
                           }
                           _directions[_loc8_] = 0;
                           break;
                        }
                        _loc8_++;
                     }
                  }
               }
            }
            if(_mode != 4)
            {
               if(_direction == 0)
               {
                  _clone.x += _speed * param1;
                  if(_clone.x > _theGame.getLevelExtent(0))
                  {
                     _clone.x = _theGame.getLevelExtent(2);
                  }
                  else if(turnX >= 0 && _clone.x >= turnX)
                  {
                     _clone.x = turnX;
                     _theGame.resetTurnXY(this);
                     _direction = turnDirection;
                  }
               }
               else if(_direction == 2)
               {
                  _clone.x -= _speed * param1;
                  if(_clone.x < _theGame.getLevelExtent(2))
                  {
                     _clone.x = _theGame.getLevelExtent(0);
                  }
                  else if(turnX >= 0 && _clone.x <= turnX)
                  {
                     _clone.x = turnX;
                     _theGame.resetTurnXY(this);
                     _direction = turnDirection;
                  }
               }
               else if(_direction == 3)
               {
                  _clone.y += _speed * param1;
                  if(_clone.y > _theGame.getLevelExtent(3))
                  {
                     _clone.y = _theGame.getLevelExtent(1);
                  }
                  else if(turnY >= 0 && _clone.y >= turnY)
                  {
                     _clone.y = turnY;
                     _theGame.resetTurnXY(this);
                     _direction = turnDirection;
                  }
               }
               else if(_direction == 1)
               {
                  _clone.y -= _speed * param1;
                  if(_clone.y < _theGame.getLevelExtent(1))
                  {
                     _clone.y = _theGame.getLevelExtent(3);
                  }
                  else if(turnY >= 0 && _clone.y <= turnY)
                  {
                     _clone.y = turnY;
                     _theGame.resetTurnXY(this);
                     _direction = turnDirection;
                  }
               }
            }
         }
      }
      
      private function getPossibleDirections() : Boolean
      {
         var _loc2_:Array = _theGame.getCurrentLevelArray();
         var _loc3_:int = 0;
         var _loc4_:int = i - 1 >= 0 ? i - 1 : _loc2_.length - 1;
         if((_direction != 3 || _forceCheck) && _loc2_[_loc4_][j] != 0)
         {
            _directions[1] = 1;
            _loc3_++;
         }
         _loc4_ = i + 1 < _loc2_.length ? i + 1 : 0;
         if((_direction != 1 || _forceCheck) && _loc2_[_loc4_][j] != 0)
         {
            _directions[3] = 1;
            _loc3_++;
         }
         var _loc1_:int = j - 1 >= 0 ? j - 1 : _loc2_[i].length - 1;
         if((_direction != 0 || _forceCheck) && _loc2_[i][_loc1_] != 0)
         {
            _directions[2] = 1;
            _loc3_++;
         }
         _loc1_ = j + 1 < _loc2_[i].length ? j + 1 : 0;
         if((_direction != 2 || _forceCheck) && _loc2_[i][_loc1_] != 0)
         {
            _directions[0] = 1;
            _loc3_++;
         }
         _forceCheck = false;
         if(_loc3_ == 0)
         {
            trace("uh oh");
         }
         return _loc3_ > 1;
      }
   }
}

