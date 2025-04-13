package game.gemBreaker
{
   import com.sbi.corelib.math.RandomSeed;
   import flash.geom.Point;
   import game.MinigameManager;
   import localization.LocalizationManager;
   
   public class GemBreakerPlayer
   {
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      public static const NUM_COLUMNS:int = 7;
      
      public static const RANDOM_GEM_TIME:Number = 1;
      
      public static const SHOOT_TIME:Number = 3;
      
      public static const INUM_PHANTOMS:int = 0;
      
      public static const INUM_COLORS:int = 1;
      
      public static const INUM_SHOTSBEFOREDROP:int = 2;
      
      public static const INUM_POWERUPS:int = 3;
      
      public static const IPOWERUPTYPE:int = 4;
      
      public static const INUM_OBSTACLES:int = 5;
      
      public static const INUM_ROWS:int = 6;
      
      public static const GEM_WIDTH:Number = 53;
      
      public static const GEM_HEIGHT:Number = 53;
      
      public var _theGame:GemBreaker;
      
      public var _localPlayer:Boolean;
      
      public var _otherPlayer:GemBreakerPlayer;
      
      public var _netID:int;
      
      public var _dbID:int;
      
      private var _clone:Object;
      
      public var _updatePositionTimer:Number;
      
      public var _gemCount:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      public var _shootTimer:Number;
      
      public var _shotSoundTimer:Number;
      
      public var _firingGem:GemBreakerGem;
      
      public var _nextGem:GemBreakerGem;
      
      public var _shotsFired:int;
      
      public var _gemPool:Array;
      
      public var _gemPoolTemp:Array;
      
      public var _activeGems:Array;
      
      public var _gemGrid:GemBreakerGrid;
      
      public var _gemTypes:Array;
      
      public var _score:int;
      
      public var _totalScore:int;
      
      public var _comboMultiplier:int;
      
      public var _randomizer:RandomSeed;
      
      public var _xOffset:Number;
      
      public var _randomGemsToAdd:int;
      
      public var _randomGemsToAddThisTurn:int;
      
      public var _randomGemTimer:Number;
      
      public var _gemsFiredThisTurn:int;
      
      public var _blocksToBePlaced:int;
      
      public var _phantomsToBePlaced:int;
      
      public var _phantomRandomChance:int;
      
      public var _queueShift:Boolean;
      
      public var _flyingGems:Array;
      
      public var _lost:Boolean;
      
      public var _shootingDisabled:Boolean;
      
      public var _lastType:int;
      
      public var _repeatType:int;
      
      public var _roundsWon:int;
      
      public var _shootQueue:Array;
      
      public var _shotsBeforeShift:int;
      
      public var _prevMouseX:Number;
      
      public var _prevMouseY:Number;
      
      public var _serverRotation:Number;
      
      public var _trailingRotation:Number;
      
      public var _levels:Array = [[2,2,8,0,0,0,3],[2,2,8,0,0,0,3],[2,2,8,0,0,0,3],[2,2,8,0,0,0,3],[2,2,8,0,0,1,4],[1,3,8,0,0,2,4],[3,3,8,0,0,1,4],[3,3,8,0,0,1,4],[3,3,8,0,0,1,4],[3,3,8,0,0,2,5],[1,4,8,0,0,3,5],[4,4,8,0,0,2,5],[4,4,8,0,0,2,5],[4,4,8,0,0,2,5],[4,4,8,0,0,3,5],[1,4,8,0,0,3,5],[5,4,8,0,0,3,5],[5,4,8,0,0,3,5],[5,4,8,0,0,3,5],[5,5,8,0,0,3,5],[1,5,8,0,0,3,5],[6,5,8,0,0,3,5],[6,5,8,0,0,3,5],[6,5,8,0,0,3,5],[6,5,8,0,0,3,5]];
      
      private var _userName:String;
      
      public function GemBreakerPlayer(param1:GemBreaker)
      {
         super();
         _theGame = param1;
      }
      
      public function reset(param1:Boolean = true) : void
      {
         var _loc2_:GemBreakerGem = null;
         while(_flyingGems.length)
         {
            _loc2_ = _flyingGems[0];
            _flyingGems.splice(0,1);
         }
         if(_firingGem)
         {
            safePush(_gemPoolTemp,_firingGem);
            _firingGem = null;
         }
         if(_nextGem)
         {
            safePush(_gemPoolTemp,_nextGem);
            _nextGem = null;
         }
         _gemCount = 0;
         _shotSoundTimer = 0;
         _shotsFired = 0;
         _shootTimer = 3;
         if(param1)
         {
            _score = 0;
            incrementScore(0);
         }
         _comboMultiplier = 1;
         _randomGemsToAdd = 0;
         _gemsFiredThisTurn = 0;
         _blocksToBePlaced = 0;
         _phantomsToBePlaced = 0;
         _updatePositionTimer = 0;
         _waitingForAllLoaded = false;
         _lost = false;
         _shootingDisabled = false;
      }
      
      public function init(param1:String, param2:int, param3:Array, param4:int, param5:Object, param6:uint) : int
      {
         var _loc7_:Object = null;
         _netID = parseInt(param3[param4++]);
         _clone = param5;
         _clone.x = _clone.y = 0;
         param3[param4++];
         _gemPool = [];
         _gemPoolTemp = [];
         _flyingGems = [];
         _activeGems = [];
         _gemTypes = [];
         _shootQueue = [];
         _gemTypes[0] = _gemTypes[1] = _gemTypes[2] = _gemTypes[3] = _gemTypes[4] = _gemTypes[5] = _gemTypes[6] = 0;
         _firingGem = null;
         _nextGem = null;
         _gemCount = 0;
         _shotSoundTimer = 0;
         _shotsFired = 0;
         _score = 0;
         incrementScore(0);
         _totalScore = 0;
         incrementTotalScore(0);
         _comboMultiplier = 1;
         _randomGemsToAdd = 0;
         _gemsFiredThisTurn = 0;
         _blocksToBePlaced = 0;
         _phantomsToBePlaced = 0;
         _shootTimer = 3;
         _randomizer = new RandomSeed(param6);
         _updatePositionTimer = 0;
         _waitingForAllLoaded = false;
         _lost = false;
         _theGame._layerPlayers.addChild(_clone.loader);
         _shootingDisabled = false;
         _roundsWon = 0;
         _localPlayer = _theGame.myId == _netID;
         _dbID = param2;
         _userName = param1;
         if(_theGame._totalPlayers == 1)
         {
            _xOffset = 238;
            _theGame.getScene().getLayer("combo1").loader.x = _theGame.getScene().getLayer("combo1").loader.x + _xOffset;
         }
         else if(!_localPlayer)
         {
            _xOffset = 475;
         }
         else
         {
            _xOffset = 0;
         }
         _clone.loader.rotation = -90;
         _clone.loader.x = _xOffset + 212;
         _clone.loader.y = 510;
         _prevMouseX = _clone.loader.x;
         _prevMouseY = _clone.loader.y;
         _serverRotation = Math.atan2(-_clone.loader.y,600 - _clone.loader.x) * 180 / 3.141592653589793;
         if(_serverRotation > -10)
         {
            _serverRotation = -10;
         }
         else if(_serverRotation < -170)
         {
            _serverRotation = -170;
         }
         _trailingRotation = _serverRotation;
         _loc7_ = _theGame.getScene().getLayer("background");
         if(_localPlayer)
         {
            LocalizationManager.updateToFit(_loc7_.loader.content.player1Name,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userName,_dbID).avName);
         }
         else
         {
            LocalizationManager.updateToFit(_loc7_.loader.content.player2Name,gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userName,_dbID).avName);
         }
         _gemGrid = new GemBreakerGrid();
         return param4;
      }
      
      private function getNewGem(param1:int, param2:Boolean) : GemBreakerGem
      {
         var _loc3_:GemBreakerGem = null;
         if(_gemPool.length == 0)
         {
            _loc3_ = new GemBreakerGem(_theGame,param1,this);
            _loc3_._bRandom = param2;
         }
         else
         {
            _loc3_ = _gemPool[0];
            _loc3_.reset(param1,param2);
            _gemPool.splice(0,1);
         }
         return _loc3_;
      }
      
      public function buildLevel(param1:int = -1) : void
      {
         var _loc8_:GemBreakerGem = null;
         var _loc15_:int = 0;
         var _loc7_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         while(_activeGems.length)
         {
            _loc8_ = _activeGems[0];
            _activeGems.splice(0,1);
            safePush(_gemPool,_loc8_);
            if(_loc8_._clone.loader.parent)
            {
               _loc8_._clone.loader.parent.removeChild(_loc8_._clone.loader);
            }
         }
         while(_gemPoolTemp.length)
         {
            _loc8_ = _gemPoolTemp[0];
            _gemPoolTemp.splice(0,1);
            safePush(_gemPool,_loc8_);
            if(_loc8_._clone.loader.parent)
            {
               _loc8_._clone.loader.parent.removeChild(_loc8_._clone.loader);
            }
         }
         _gemTypes[0] = _gemTypes[1] = _gemTypes[2] = _gemTypes[3] = _gemTypes[4] = _gemTypes[5] = _gemTypes[6] = 0;
         _gemGrid.clear();
         _shotsFired = 0;
         if(param1 < 0)
         {
            _score = 0;
            incrementScore(0);
         }
         _queueShift = false;
         _randomGemsToAddThisTurn = 0;
         _randomGemsToAdd = 0;
         if(param1 > 0)
         {
            _randomizer = new RandomSeed(param1);
            _shootQueue.splice(0,_shootQueue.length);
         }
         if(_theGame._totalPlayers == 2)
         {
            _shotsBeforeShift = 8;
            initFiringGems();
         }
         var _loc2_:int = int(_theGame._totalPlayers == 1 ? _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][6] : 3);
         var _loc3_:int = int(_theGame._totalPlayers == 1 ? _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][0] : 0);
         var _loc9_:int = int(_theGame._totalPlayers == 1 ? _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][5] : 0);
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc10_:int = _loc2_ - 2;
         _phantomRandomChance = 3;
         _loc15_ = int(_loc10_ % 2 == _gemGrid.hasShifted() ? 7 : 7 - 1);
         while(_loc11_ < _loc3_ && _loc10_ >= 0)
         {
            _loc13_ = Math.floor(_randomizer.random() * _loc15_);
            _loc8_ = getNewGem(0,false);
            placeGem(_loc10_,_loc13_,_loc8_);
            safePush(_activeGems,_loc8_);
            _theGame._layerGems.addChild(_loc8_._clone.loader);
            _loc11_++;
            if(_loc11_ < _loc3_ && _randomizer.random() < 0.5)
            {
               _loc14_ = Math.floor(_randomizer.random() * _loc15_);
               if(_loc14_ == _loc13_)
               {
                  _loc14_++;
                  if(_loc14_ == _loc15_)
                  {
                     _loc14_ = 0;
                  }
               }
               _loc8_ = getNewGem(0,false);
               placeGem(_loc10_,_loc14_,_loc8_);
               safePush(_activeGems,_loc8_);
               _theGame._layerGems.addChild(_loc8_._clone.loader);
               _loc11_++;
            }
            _loc10_ -= 2;
         }
         _phantomsToBePlaced = _loc3_ - _loc11_;
         _loc10_ = _loc2_ - 2;
         while(_loc12_ < _loc9_ && _loc10_ >= 0)
         {
            if(_gemGrid.numRowElements(_loc10_) < 2)
            {
               do
               {
                  _loc13_ = Math.floor(_randomizer.random() * _loc15_);
               }
               while(_gemGrid.getElement(_loc10_,_loc13_));
               
               _loc8_ = getNewGem(6,false);
               placeGem(_loc10_,_loc13_,_loc8_);
               safePush(_activeGems,_loc8_);
               _theGame._layerGems.addChild(_loc8_._clone.loader);
               _loc12_++;
               if(_loc12_ < _loc9_ && _gemGrid.numRowElements(_loc10_) < 2)
               {
                  _loc14_ = Math.floor(_randomizer.random() * _loc15_);
                  if(_loc14_ == _loc13_)
                  {
                     _loc14_++;
                     if(_loc14_ == _loc15_)
                     {
                        _loc14_ = 0;
                     }
                  }
                  _loc8_ = getNewGem(6,false);
                  placeGem(_loc10_,_loc14_,_loc8_);
                  safePush(_activeGems,_loc8_);
                  _theGame._layerGems.addChild(_loc8_._clone.loader);
                  _loc12_++;
               }
            }
            _loc10_ -= 2;
         }
         _blocksToBePlaced = _loc9_ - _loc12_;
         var _loc5_:int = int(_theGame._totalPlayers == 1 ? _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][1] : 5);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc15_ = int(_loc4_ % 2 == _gemGrid.hasShifted() ? 7 : 7 - 1);
            _loc6_ = 0;
            while(_loc6_ < _loc15_)
            {
               if(!_gemGrid.isOccupied(_loc4_,_loc6_))
               {
                  _loc7_ = Math.floor(_randomizer.random() * _loc5_) + 1;
                  _loc8_ = getNewGem(_loc7_,false);
                  placeGem(_loc4_,_loc6_,_loc8_);
                  safePush(_activeGems,_loc8_);
                  _theGame._layerGems.addChild(_loc8_._clone.loader);
               }
               _loc6_++;
            }
            _loc4_++;
         }
      }
      
      public function remove() : void
      {
         if(_clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function forceFinish() : void
      {
         var _loc2_:* = null;
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < 20)
         {
            for each(_loc2_ in _activeGems)
            {
               _loc2_.heartbeat(0.0416666666667);
            }
            for each(_loc2_ in _gemPoolTemp)
            {
               _loc2_.heartbeat(0.0416666666667);
            }
            _loc1_++;
         }
         if(_queueShift && _flyingGems.length == 0)
         {
            shiftGems();
            _queueShift = false;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc9_:* = null;
         var _loc4_:Number = NaN;
         var _loc2_:Array = null;
         var _loc3_:Number = NaN;
         var _loc8_:Array = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:* = false;
         if(!_waitingForAllLoaded)
         {
            if(_localPlayer && _theGame._gameState == 4)
            {
               if(_prevMouseX != _theGame.stage.mouseX || _prevMouseY != _theGame.stage.mouseY)
               {
                  _prevMouseX = _theGame.stage.mouseX;
                  _prevMouseY = _theGame.stage.mouseY;
                  _serverRotation = Math.atan2(_prevMouseY - _clone.loader.y,_prevMouseX - _clone.loader.x) * 180 / 3.141592653589793;
               }
               else if(_theGame._rightArrowDown)
               {
                  _serverRotation += 100 * param1;
               }
               else if(_theGame._leftArrowDown)
               {
                  _serverRotation -= 100 * param1;
               }
               if(_serverRotation > -10)
               {
                  _serverRotation = -10;
               }
               else if(_serverRotation < -170)
               {
                  _serverRotation = -170;
               }
               _trailingRotation = _serverRotation;
               if(_shotSoundTimer > 0)
               {
                  _shotSoundTimer -= param1;
               }
               if(_theGame._totalPlayers > 1)
               {
                  _updatePositionTimer += param1;
                  if(_updatePositionTimer > 0.25)
                  {
                     _loc2_ = [];
                     _loc2_[0] = "pos";
                     _loc2_[1] = String(int(_serverRotation));
                     MinigameManager.msg(_loc2_);
                     _updatePositionTimer = 0;
                  }
                  if(_firingGem != null && !_shootingDisabled)
                  {
                     _shootTimer -= param1;
                     if(_shootTimer <= 0)
                     {
                        shoot();
                     }
                     else
                     {
                        _theGame.getScene().getLayer("background").loader.content.showTime(_shootTimer,3);
                     }
                  }
               }
            }
            else
            {
               _loc3_ = 0.25;
               _trailingRotation += (_serverRotation - _trailingRotation) * _loc3_;
            }
            _clone.loader.rotation = _trailingRotation;
            if(_clone.loader.rotation > -10)
            {
               _clone.loader.rotation = -10;
            }
            else if(_clone.loader.rotation < -170)
            {
               _clone.loader.rotation = -170;
            }
            if(_firingGem == null)
            {
               _loc8_ = [];
               _loc6_ = 1;
               while(_loc6_ < _gemTypes.length - 1)
               {
                  if(_gemTypes[_loc6_] > 0)
                  {
                     _loc8_.push(_loc6_);
                  }
                  _loc6_++;
               }
               if(_nextGem == null)
               {
                  _loc7_ = Math.floor(_randomizer.random() * _loc8_.length);
                  _nextGem = getNewGem(_loc8_[_loc7_],false);
                  _lastType = _loc7_;
                  _repeatType = 0;
               }
               _firingGem = _nextGem;
               _loc7_ = Math.floor(_randomizer.random() * _loc8_.length);
               if(_loc7_ == _lastType)
               {
                  _repeatType++;
               }
               else
               {
                  _repeatType = 0;
               }
               if(_repeatType > 2 && _loc8_.length > 1)
               {
                  _loc7_++;
                  if(_loc7_ == _loc8_.length)
                  {
                     _loc7_ = 0;
                  }
               }
               _lastType = _loc7_;
               _nextGem = getNewGem(_loc8_[_loc7_],false);
               _theGame._layerGems.addChild(_firingGem._clone.loader);
               if(_localPlayer)
               {
                  _theGame.getScene().getLayer("background").loader.content.gemPreview.gemColor(_nextGem._type);
                  _theGame.getScene().getLayer("background").loader.content.gemPreview.appear();
               }
               _firingGem._clone.loader.x = _clone.loader.x - _theGame._layerGems.x;
               _firingGem._clone.loader.y = _clone.loader.y - _theGame._layerGems.y;
            }
            _loc5_ = _theGame._totalPlayers == 1;
            if(_loc5_)
            {
               _shootingDisabled = _phantomsToBePlaced == 0;
            }
            for each(_loc9_ in _activeGems)
            {
               _loc9_.heartbeat(param1);
               if(_loc5_ && _loc9_._type == 0 && _loc9_._state != 2)
               {
                  _shootingDisabled = false;
               }
            }
            for each(_loc9_ in _gemPoolTemp)
            {
               _loc9_.heartbeat(param1);
            }
            if(_queueShift && _flyingGems.length == 0)
            {
               shiftGems();
               _queueShift = false;
            }
            if(_theGame._totalPlayers == 1)
            {
               if(_phantomsToBePlaced > 0 && (_gemGrid.isRowEmpty(1) || _gemGrid.isRowEmpty(2)) || _gemGrid.isRowEmpty(1) && _gemGrid.rowContainsPropertyValue(0,"_type",0))
               {
                  _queueShift = true;
               }
            }
            else if(_firingGem != null && !_shootingDisabled && _flyingGems.length == 0 && !_queueShift && _shootQueue.length != 0)
            {
               receiveShootDataFromQueue();
            }
         }
      }
      
      public function placeRandomGems() : void
      {
         var _loc4_:GemBreakerGem = null;
         var _loc1_:Number = NaN;
         var _loc2_:int = 0;
         var _loc5_:Point = null;
         _shootingDisabled = false;
         _theGame._soundMan.playByName(_theGame._soundNameSendRows);
         var _loc3_:int = -1;
         if(_randomGemsToAddThisTurn == 4)
         {
            _loc3_ = Math.floor(_randomizer.random() * 4);
         }
         while(_randomGemsToAddThisTurn > 0)
         {
            _randomGemsToAddThisTurn--;
            _randomGemsToAdd--;
            if(_loc3_ == _randomGemsToAddThisTurn)
            {
               _loc2_ = 6;
            }
            else
            {
               _loc2_ = Math.floor(_randomizer.random() * 5) + 1;
            }
            _loc4_ = getNewGem(_loc2_,true);
            if(_loc4_ != null)
            {
               _theGame._layerGems.addChild(_loc4_._clone.loader);
               _loc1_ = -(_randomizer.random() * 120 + 30);
               _loc4_._bRandom = true;
               _loc4_._clone.loader.x = _clone.loader.x;
               _loc4_._clone.loader.y = _clone.loader.y;
               _loc4_._moveDirection.x = Math.cos(_loc1_ * 3.141592653589793 / 180);
               _loc4_._moveDirection.y = Math.sin(_loc1_ * 3.141592653589793 / 180);
               setGemTargetLocation(_loc4_,53,0);
               _loc4_._clone.loader.x = _loc4_._targetLocation.x;
               _loc4_._clone.loader.y = _loc4_._targetLocation.y;
               _loc5_ = _gemGrid.getGridCoords(_loc4_,53);
               placeGem(_loc5_.x,_loc5_.y,_loc4_);
               safePush(_activeGems,_loc4_);
               _loc4_ = null;
            }
         }
      }
      
      public function initFiringGems() : void
      {
         var _loc1_:int = 0;
         _loc1_ = Math.floor(_randomizer.random() * 5) + 1;
         _nextGem = getNewGem(_loc1_,false);
         _lastType = _loc1_;
         _repeatType = 0;
         _firingGem = _nextGem;
         _loc1_ = Math.floor(_randomizer.random() * 5) + 1;
         if(_loc1_ == _lastType)
         {
            _repeatType++;
         }
         else
         {
            _repeatType = 0;
         }
         _lastType = _loc1_;
         _nextGem = getNewGem(_loc1_,false);
         _theGame._layerGems.addChild(_firingGem._clone.loader);
         if(_localPlayer)
         {
            _theGame.getScene().getLayer("background").loader.content.gemPreview.gemColor(_nextGem._type);
            _theGame.getScene().getLayer("background").loader.content.gemPreview.appear();
         }
         _firingGem._clone.loader.x = _clone.loader.x - _theGame._layerGems.x;
         _firingGem._clone.loader.y = _clone.loader.y - _theGame._layerGems.y;
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         _serverRotation = int(param1[param2++]);
         return param2;
      }
      
      public function receiveShootDataFromQueue() : void
      {
         var _loc1_:Object = _shootQueue.shift();
         _firingGem._moveDirection.x = _loc1_._moveDirectionX;
         _firingGem._moveDirection.y = _loc1_._moveDirectionY;
         _firingGem._targetLocation.x = _loc1_._targetLocationX;
         _firingGem._targetLocation.x += _xOffset;
         _firingGem._targetLocation.y = _loc1_._targetLocationY;
         _firingGem._targetRowColumn.x = _loc1_._targetRowColumnX;
         _firingGem._targetRowColumn.y = _loc1_._targetRowColumnY;
         _firingGem._distanceToTravel = _loc1_._distanceToTravel;
         _randomGemsToAddThisTurn = _randomGemsToAdd = _loc1_._randomGemsToAdd;
         _shotsBeforeShift = _loc1_._shotsBeforeShift;
         shoot();
      }
      
      public function receiveShootData(param1:Array, param2:int) : int
      {
         var _loc3_:Object = {};
         _loc3_._moveDirectionX = param1[param2++];
         _loc3_._moveDirectionY = param1[param2++];
         _loc3_._targetLocationX = param1[param2++];
         _loc3_._targetLocationY = param1[param2++];
         _loc3_._targetRowColumnX = param1[param2++];
         _loc3_._targetRowColumnY = param1[param2++];
         _loc3_._distanceToTravel = param1[param2++];
         _loc3_._randomGemsToAdd = param1[param2++];
         _loc3_._shotsBeforeShift = param1[param2++];
         _shootQueue.push(_loc3_);
         return param2;
      }
      
      public function shootRandomGem() : void
      {
         var _loc1_:Number = NaN;
         var _loc2_:int = Math.floor(_randomizer.random() * 5) + 1;
         var _loc3_:GemBreakerGem = getNewGem(_loc2_,true);
         if(_loc3_ != null)
         {
            _theGame._layerGems.addChild(_loc3_._clone.loader);
            _loc1_ = -(_randomizer.random() * 120 + 30);
            _loc3_._bRandom = true;
            _loc3_._clone.loader.x = _clone.loader.x;
            _loc3_._clone.loader.y = _clone.loader.y;
            _loc3_._moveDirection.x = Math.cos(_loc1_ * 3.141592653589793 / 180);
            _loc3_._moveDirection.y = Math.sin(_loc1_ * 3.141592653589793 / 180);
            setGemTargetLocation(_loc3_,53);
            _loc3_.setMoving();
            safePush(_activeGems,_loc3_);
            _loc3_ = null;
         }
         _theGame._soundMan.playByName(_theGame._soundNameShoot);
      }
      
      public function shoot() : void
      {
         var _loc1_:Array = null;
         if(_firingGem != null && !_shootingDisabled && _flyingGems.length == 0)
         {
            _shotsFired++;
            if(_theGame._totalPlayers == 1)
            {
               _shotsBeforeShift = _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][2];
            }
            if(_shotsFired == _shotsBeforeShift)
            {
               _queueShift = true;
            }
            if(_localPlayer)
            {
               _firingGem._moveDirection.x = Math.cos(_clone.loader.rotation * 3.141592653589793 / 180);
               _firingGem._moveDirection.y = Math.sin(_clone.loader.rotation * 3.141592653589793 / 180);
               _shootTimer = 3;
               setGemTargetLocation(_firingGem,53);
            }
            safePush(_flyingGems,_firingGem);
            _firingGem.setMoving();
            safePush(_activeGems,_firingGem);
            if(_localPlayer && _theGame._totalPlayers > 1)
            {
               if(_randomGemsToAdd > 0 && _randomGemsToAddThisTurn == 0)
               {
                  _randomGemsToAddThisTurn = Math.min(_randomGemsToAdd,4);
               }
               _loc1_ = [];
               _loc1_[0] = "shoot";
               _loc1_[1] = _firingGem._moveDirection.x.toString();
               _loc1_[2] = _firingGem._moveDirection.y.toString();
               _loc1_[3] = _firingGem._targetLocation.x.toString();
               _loc1_[4] = _firingGem._targetLocation.y.toString();
               _loc1_[5] = _firingGem._targetRowColumn.x.toString();
               _loc1_[6] = _firingGem._targetRowColumn.y.toString();
               _loc1_[7] = _firingGem._distanceToTravel.toString();
               _loc1_[8] = _randomGemsToAddThisTurn.toString();
               _loc1_[9] = _shotsBeforeShift.toString();
               MinigameManager.msg(_loc1_);
            }
            _firingGem = null;
            if(_shotSoundTimer <= 0)
            {
               _theGame._soundMan.playByName(_theGame._soundNameShoot);
               _shotSoundTimer = 0.15;
            }
            if(_randomGemsToAddThisTurn > 0)
            {
               _shootingDisabled = true;
            }
         }
      }
      
      public function setGemTargetLocation(param1:GemBreakerGem, param2:Number, param3:int = 10) : void
      {
         var _loc4_:Point = new Point(param1._clone.loader.x,param1._clone.loader.y);
         var _loc7_:Point = new Point(param1._moveDirection.x,param1._moveDirection.y);
         var _loc6_:int = 0;
         var _loc5_:Number = 0;
         while(_loc6_ < 500)
         {
            _loc5_ += 8;
            param1._clone.loader.x += param1._moveDirection.x * 8;
            param1._clone.loader.y += param1._moveDirection.y * 8;
            if(param1._clone.loader.x < 55 + _xOffset && param1._moveDirection.x < 0 || param1._clone.loader.x > 360 + _xOffset && param1._moveDirection.x > 0)
            {
               param1._moveDirection.x *= -1;
               _loc6_ = 0;
            }
            if(param1._clone.loader.y < 50 || _gemGrid.checkCollision(param1,param2,_xOffset,param3))
            {
               param1._targetRowColumn = _gemGrid.getGridCoords(param1,param2);
               while(!_gemGrid.put(param1._targetRowColumn.x,param1._targetRowColumn.y,param1))
               {
                  param1._clone.loader.x -= param1._moveDirection.x * 8;
                  param1._clone.loader.y -= param1._moveDirection.y * 8;
                  _loc5_ -= 8;
                  param1._targetRowColumn = _gemGrid.getGridCoords(param1,param2);
                  _gemGrid.put(param1._targetRowColumn.x,param1._targetRowColumn.y,param1);
               }
               param1._targetLocation = getGemWorldCoords(param1._targetRowColumn.x,param1._targetRowColumn.y);
               break;
            }
            _loc6_++;
         }
         if(_loc6_ == 500)
         {
            trace("maxed out steps");
         }
         param1._clone.loader.x = _loc4_.x;
         param1._clone.loader.y = _loc4_.y;
         param1._moveDirection.x = _loc7_.x;
         param1._moveDirection.y = _loc7_.y;
         param1._distanceToTravel = _loc5_ - param3;
      }
      
      public function shiftGems() : void
      {
         var _loc9_:GemBreakerGem = null;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:* = 0;
         var _loc6_:int = 0;
         var _loc3_:Boolean = true;
         _shotsFired = 0;
         _gemGrid.shiftDown(53);
         _theGame._soundMan.playByName(_theGame._soundNameRowGrow);
         _loc4_ = 0;
         while(_loc4_ < _gemGrid.getRowLength(1))
         {
            _loc9_ = _gemGrid.getElement(1,_loc4_) as GemBreakerGem;
            if(_loc9_ && _loc9_._type == 0)
            {
               _loc3_ = false;
               break;
            }
            _loc4_++;
         }
         _loc10_ = int(_gemGrid.hasShifted() == 0 ? 7 : 7 - 1);
         if(_loc3_)
         {
            _loc2_ = Math.min(Math.floor(Math.random() * _phantomRandomChance),_phantomsToBePlaced);
            if(_loc2_ > 0 && _phantomRandomChance > 3)
            {
               _phantomRandomChance = 3;
               if(_loc2_ > 1)
               {
                  _loc2_ = Math.floor(Math.random() * 2) + 1;
               }
            }
            if(_loc2_ == 0 && _phantomsToBePlaced > 0)
            {
               _phantomRandomChance++;
            }
            _loc8_ = -1;
            _loc1_ = -1;
            while(_loc2_ > 0)
            {
               while(_loc1_ == _loc8_)
               {
                  _loc1_ = Math.floor(_randomizer.random() * _loc10_);
               }
               _loc9_ = getNewGem(0,false);
               placeGem(0,_loc1_,_loc9_);
               safePush(_activeGems,_loc9_);
               _theGame._layerGems.addChild(_loc9_._clone.loader);
               _loc2_--;
               _phantomsToBePlaced--;
               _loc8_ = _loc1_;
            }
            if(_gemGrid.numRowElements(0) < 2 && _blocksToBePlaced > 0)
            {
               _loc1_ = Math.floor(_randomizer.random() * _loc10_);
               while(_gemGrid.getElement(0,_loc1_))
               {
                  _loc1_ = Math.floor(_randomizer.random() * _loc10_);
               }
               _loc9_ = getNewGem(6,false);
               placeGem(0,_loc1_,_loc9_);
               safePush(_activeGems,_loc9_);
               _theGame._layerGems.addChild(_loc9_._clone.loader);
               _blocksToBePlaced--;
            }
         }
         var _loc5_:int = int(_theGame._totalPlayers == 1 ? _levels[Math.min(_theGame._levelIndex,_levels.length - 1)][1] : 5);
         _loc6_ = 0;
         while(_loc6_ < _loc10_)
         {
            if(!_gemGrid.isOccupied(0,_loc6_))
            {
               _loc7_ = Math.floor(_randomizer.random() * _loc5_) + 1;
               _loc9_ = getNewGem(_loc7_,false);
               placeGem(0,_loc6_,_loc9_);
               safePush(_activeGems,_loc9_);
               _theGame._layerGems.addChild(_loc9_._clone.loader);
            }
            _loc6_++;
         }
         if(!_gemGrid.isRowEmpty(9))
         {
            if(!_theGame._queueGameOver && _localPlayer)
            {
               _theGame._queueGameOver = true;
               playerLost();
            }
         }
      }
      
      public function playerLost() : void
      {
         var _loc1_:Array = null;
         _lost = true;
         if(_theGame._totalPlayers == 2)
         {
            if(_theGame._players[0] == this)
            {
               _theGame._players[1]._roundsWon++;
            }
            else
            {
               _theGame._players[0]._roundsWon++;
            }
            if(_localPlayer)
            {
               _theGame._newRoundSeed = _randomizer.integer(0,2147483647);
               _loc1_ = [];
               _loc1_[0] = "playerLost";
               _loc1_[1] = _theGame._newRoundSeed;
               MinigameManager.msg(_loc1_);
            }
         }
      }
      
      public function placeGem(param1:int, param2:int, param3:GemBreakerGem, param4:Boolean = false) : int
      {
         var _loc7_:int = int(param1 % 2 == _gemGrid.hasShifted() ? 7 : 7 - 1);
         var _loc6_:int = 0;
         if(_gemGrid.put(param1,param2,param3))
         {
            param3._clone.loader.x = (param2 + 1) * 53 + (_loc7_ == 7 ? 0 : 53 / 2) + _xOffset;
            param3._clone.loader.y = (param1 + 1) * 53 * 0.86602540378444;
            _gemTypes[param3._type]++;
         }
         else if(!_theGame._queueGameOver && _localPlayer)
         {
            _theGame._queueGameOver = true;
            playerLost();
         }
         if(param4)
         {
            _loc6_ = _gemGrid.eliminateNeighbors(param1,param2);
         }
         if(!_gemGrid.isRowEmpty(9))
         {
            if(!_theGame._queueGameOver && _localPlayer)
            {
               _theGame._queueGameOver = true;
               playerLost();
            }
         }
         if(_shootingDisabled && _randomGemsToAddThisTurn)
         {
            placeRandomGems();
         }
         return _loc6_;
      }
      
      public function safePush(param1:Array, param2:GemBreakerGem) : void
      {
         param1.push(param2);
      }
      
      public function getGemWorldCoords(param1:int, param2:int) : Point
      {
         var _loc3_:Point = new Point();
         var _loc5_:int = int(param1 % 2 == _gemGrid.hasShifted() ? 7 : 7 - 1);
         _loc3_.x = (param2 + 1) * 53 + (_loc5_ == 7 ? 0 : 53 / 2) + _xOffset;
         _loc3_.y = (param1 + 1) * 53 * 0.86602540378444;
         return _loc3_;
      }
      
      public function removeGem(param1:GemBreakerGem) : void
      {
         var _loc3_:* = null;
         var _loc2_:Boolean = false;
         _activeGems.splice(_activeGems.indexOf(param1),1);
         _gemTypes[param1._type]--;
         if(param1._state == 1)
         {
            safePush(_gemPoolTemp,param1);
            param1._clone.loader.content.gemBreak(param1._type);
         }
         else
         {
            safePush(_gemPool,param1);
         }
         if(_theGame._totalPlayers == 1 && param1._type == 0 && _gemTypes[0] == 0 && _phantomsToBePlaced == 0)
         {
            incrementScore(50000);
            incrementTotalScore(50000);
            _theGame.startNextRound();
         }
         else
         {
            _loc2_ = false;
            for each(_loc3_ in _activeGems)
            {
               if(_loc3_._type != 0)
               {
                  _loc2_ = true;
                  break;
               }
            }
            if(!_loc2_)
            {
               _queueShift = true;
            }
         }
      }
      
      public function incrementScore(param1:int) : void
      {
         _score += param1;
         if(_theGame._totalPlayers == 1 || _localPlayer)
         {
            _theGame.getScene().getLayer("background").loader.content.player1Score.text = _score.toString();
         }
         else
         {
            _theGame.getScene().getLayer("background").loader.content.player2Score.text = _score.toString();
         }
      }
      
      public function incrementTotalScore(param1:int) : void
      {
         _totalScore += param1;
         if(_theGame._totalPlayers == 1)
         {
            _theGame.getScene().getLayer("background").loader.content.player1ScoreTotal.text = _totalScore.toString();
         }
      }
      
      public function score(param1:int) : void
      {
         var _loc4_:* = null;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         for each(_loc4_ in _activeGems)
         {
            if(_loc4_._state == 2)
            {
               if(_loc4_._type != 0)
               {
                  _loc3_++;
               }
               else
               {
                  _loc2_++;
               }
            }
         }
         if(_loc3_ > 0)
         {
            _loc5_ += Math.pow(2,_loc3_) * 100;
         }
         _loc5_ += 500 * _loc2_;
         _loc5_ = _loc5_ + 200 * param1;
         var _loc6_:int = _loc3_ + param1 + _loc2_;
         if(_loc6_ >= 5)
         {
            if(_comboMultiplier < 8)
            {
               _comboMultiplier *= 2;
            }
            _theGame.getScene().getLayer("combo" + (_localPlayer ? 1 : 2)).loader.content.gotoAndPlay(0);
            LocalizationManager.translateIdAndInsert(_theGame.getScene().getLayer("combo" + (_localPlayer ? 1 : 2)).loader.content.combo.combo,11586,_comboMultiplier);
            _theGame._soundMan.playByName(_theGame._soundNameCombo);
            if(!_localPlayer && _theGame._totalPlayers > 1)
            {
               _otherPlayer._randomGemsToAdd += Math.min(_loc6_ - 4,4);
            }
         }
         else if(_loc6_ < 3)
         {
            _comboMultiplier = 1;
         }
         _loc5_ = Math.min(_loc5_ * _comboMultiplier,100000);
         incrementScore(_loc5_);
         incrementTotalScore(_loc5_);
         if(_loc5_ > 0 && _localPlayer)
         {
            _theGame._soundMan.playByName(_theGame._soundNameGetPoints);
         }
      }
   }
}

