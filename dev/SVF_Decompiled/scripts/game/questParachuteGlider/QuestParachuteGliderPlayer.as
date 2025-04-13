package game.questParachuteGlider
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import game.MinigameManager;
   import gskinner.motion.GTween;
   
   public class QuestParachuteGliderPlayer
   {
      private static const MAX_GRAVITY:Number = 300;
      
      private static const MAX_ACCELERATION:int = 150;
      
      private static const JUMP_ACCELERATION:int = 225;
      
      private static const SIDE_ACCELERATION:int = 700;
      
      private static const MAX_SPEED:int = 150;
      
      private static const MAX_SIDE_SPEED:int = 200;
      
      private static const MAX_SIDE_WIND_SPEED:int = 275;
      
      private static const MAX_WIND_SPEED:int = 150;
      
      private static const MAX_WIND_DRAG:Number = 5000;
      
      private static const MAX_WIND_ACCELERATOR:Number = 2500;
      
      private static const JUMP_HOLD_TIME:Number = 0.15;
      
      private static const PHANTOM_HOLD_TIME:Number = 0.75;
      
      private static const HITTYPE_NONE:int = 0;
      
      private static const HITTYPE_BRANCH:int = 1;
      
      private static const HITTYPE_PHANTOM:int = 2;
      
      private static const HITTYPE_WIND:int = 3;
      
      private static const HITTYPE_LAND:int = 4;
      
      private static const POLLUTETIMER:Number = 3.5;
      
      private static const POLLUTETIMER_RETURN_TO_IDLE:Number = 2.75;
      
      private static const POSITION_UPDATE_TIME:Number = 0.25;
      
      public var _theGame:QuestParachuteGlider;
      
      public var _localPlayer:Boolean;
      
      public var _netID:int;
      
      public var _clone:AvatarView;
      
      public var _updatePositionTimer:Number;
      
      public var _lastFrameVelocity:Point;
      
      public var _currentVelocity:Point;
      
      public var _currentAcceleration:Point;
      
      public var _serverWindTargetAcceleration:Point;
      
      public var _serverWindAcceleration:Point;
      
      public var _serverVelocity:Point;
      
      public var _serverAcceleration:Point;
      
      public var _serverPosition:Point;
      
      public var _serverHitType:int;
      
      public var _gemCount:int;
      
      public var _radius:int;
      
      public var _centerPointOffsetX:int;
      
      public var _centerPointOffsetY:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      private var _parachute:Object;
      
      private var _parachuteFrame:Sprite;
      
      private var _dropGems:Object;
      
      private var _polluteTimer:Number;
      
      private var _lastTreeBranchHit:Object;
      
      public var _landed:Boolean;
      
      private var _landedReceived:int;
      
      private var _positionHoldTimer:Number;
      
      public var _alpha:Number;
      
      private var _playerNum:int;
      
      public var _phantomsHit:int;
      
      public function QuestParachuteGliderPlayer(param1:QuestParachuteGlider)
      {
         super();
         _theGame = param1;
         _lastFrameVelocity = new Point();
         _currentVelocity = new Point();
         _currentAcceleration = new Point();
         _serverVelocity = new Point();
         _serverWindAcceleration = new Point();
         _serverWindTargetAcceleration = new Point();
         _serverAcceleration = new Point();
         _serverPosition = new Point();
         _polluteTimer = 0;
         _landed = false;
         _landedReceived = 0;
         _positionHoldTimer = 0;
         _alpha = 0;
         _phantomsHit = 0;
         _radius = 30;
         _centerPointOffsetX = -20;
         _centerPointOffsetY = -35;
      }
      
      public function preloadAnims(param1:String, param2:int) : void
      {
         _waitingForAllLoaded = true;
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param1,param2);
         var _loc5_:Avatar = new Avatar();
         if(_loc4_)
         {
            _loc5_.init(_loc4_.perUserAvId,_loc4_.avInvId,_loc4_.avName,_loc4_.type,_loc4_.colors,_loc4_.customAvId,null,param1);
         }
         else
         {
            _loc5_ = AvatarUtility.generateNew(param2,_loc5_,param1,AvatarManager.roomEnviroType);
         }
         _clone = new AvatarView();
         _clone.init(_loc5_);
         var _loc3_:Array = new Array(4);
         _loc3_[0] = 19;
         _loc3_[1] = 24;
         _loc3_[2] = 20;
         _loc3_[3] = 21;
         _clone.preloadAnims(_loc3_,redrawCallback);
      }
      
      public function init(param1:Array, param2:int, param3:Object, param4:int) : int
      {
         _netID = parseInt(param1[param2++]);
         _parachute = param3;
         _parachuteFrame = new Sprite();
         _parachute.loader.contentLoaderInfo.addEventListener("complete",onParachuteLoaderComplete);
         _dropGems = _theGame.getScene().cloneAsset("dropGems");
         _playerNum = param4;
         _serverPosition.x = parseInt(param1[param2++]);
         _serverPosition.y = parseInt(param1[param2++]);
         _serverPosition.y = 300;
         _clone.x = _serverPosition.x;
         _clone.y = _serverPosition.y;
         _serverHitType = 0;
         _gemCount = 0;
         _updatePositionTimer = 0;
         _localPlayer = _theGame.myId == _netID;
         _alpha = 1;
         playAnimationState(19);
         _theGame._layerPlayers.addChild(_dropGems.loader);
         _parachuteFrame.addChild(_parachute.loader);
         _theGame._layerPlayers.addChild(_parachuteFrame);
         _theGame._layerPlayers.addChild(_clone);
         _updatePositionTimer = 0;
         return param2;
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _clone)
         {
            _waitingForAllLoaded = false;
         }
      }
      
      public function remove() : void
      {
         if(_dropGems)
         {
            if(_dropGems.loader.parent)
            {
               _dropGems.loader.parent.removeChild(_dropGems.loader);
            }
            _theGame.getScene().releaseCloneAsset(_dropGems.loader);
            _dropGems = null;
         }
         if(_clone && _clone.parent)
         {
            _clone.parent.removeChild(_clone);
            _clone.destroy();
            _clone = null;
         }
         if(_parachute)
         {
            if(_parachute.loader.parent)
            {
               _parachute.loader.parent.removeChild(_parachute.loader);
            }
            _theGame.getScene().releaseCloneAsset(_parachute.loader);
            _parachute = null;
         }
         if(_parachuteFrame && _parachuteFrame.parent)
         {
            _parachuteFrame.parent.removeChild(_parachuteFrame);
            _parachuteFrame = null;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc9_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:* = null;
         var _loc10_:Boolean = false;
         var _loc8_:Point = null;
         var _loc18_:Rectangle = null;
         var _loc12_:Object = null;
         var _loc2_:Array = null;
         var _loc15_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc21_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc11_:Array = null;
         var _loc3_:Point = null;
         var _loc4_:Point = null;
         var _loc7_:Point = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!_waitingForAllLoaded)
         {
            _clone.alpha = _alpha;
            if(!_landed)
            {
               if(_landedReceived == 0)
               {
                  _loc19_ = -1;
                  _loc10_ = false;
                  _loc8_ = new Point();
                  if(_polluteTimer > 2.75)
                  {
                     _polluteTimer -= param1;
                     if(_polluteTimer <= 2.75)
                     {
                        playAnimationState(19);
                     }
                  }
                  else if(_polluteTimer > 0)
                  {
                     _polluteTimer -= param1;
                  }
                  if(_positionHoldTimer > 0)
                  {
                     _positionHoldTimer -= param1;
                     _lastFrameVelocity.x = 0;
                     _lastFrameVelocity.y = 0;
                  }
                  else
                  {
                     for each(_loc20_ in _theGame._winds)
                     {
                        if(_loc20_.clone)
                        {
                           _loc18_ = _loc20_.clone.getBounds(_theGame._layerWinds);
                           if(_serverPosition.x > _loc18_.x && _serverPosition.x < _loc18_.x + _loc18_.width && _serverPosition.y > _loc18_.y && _serverPosition.y < _loc18_.y + _loc18_.height)
                           {
                              if(_loc20_.ySpeed >= 0 || _serverWindAcceleration.y != 0 || _serverPosition.y > _loc18_.y + 50)
                              {
                                 if(_serverWindAcceleration.x == 0 && _loc20_.xSpeed != 0 || _serverWindAcceleration.y == 0 && _loc20_.ySpeed != 0)
                                 {
                                    _loc10_ = true;
                                    if(_serverWindAcceleration.x == 0 && _loc20_.xSpeed != 0)
                                    {
                                       _serverWindTargetAcceleration.x = _loc20_.xSpeed;
                                    }
                                    if(_serverWindAcceleration.y == 0 && _loc20_.ySpeed != 0)
                                    {
                                       _serverWindTargetAcceleration.y = _loc20_.ySpeed;
                                    }
                                    _theGame._soundMan.playByName(_theGame._soundNameWindGust);
                                 }
                              }
                              break;
                           }
                        }
                     }
                     if(_serverWindTargetAcceleration.x > 0)
                     {
                        _serverWindAcceleration.x += 2500 * param1;
                        if(_serverWindAcceleration.x > _serverWindTargetAcceleration.x)
                        {
                           _serverWindAcceleration.x = _serverWindTargetAcceleration.x;
                           _serverWindTargetAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindTargetAcceleration.x < 0)
                     {
                        _serverWindAcceleration.x -= 2500 * param1;
                        if(_serverWindAcceleration.x < _serverWindTargetAcceleration.x)
                        {
                           _serverWindAcceleration.x = _serverWindTargetAcceleration.x;
                           _serverWindTargetAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindAcceleration.x < 0)
                     {
                        _serverWindAcceleration.x += 5000 * param1;
                        if(_serverWindAcceleration.x > 0)
                        {
                           _serverWindAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindAcceleration.x > 0)
                     {
                        _serverWindAcceleration.x -= 5000 * param1;
                        if(_serverWindAcceleration.x < 0)
                        {
                           _serverWindAcceleration.x = 0;
                        }
                     }
                     if(_serverWindTargetAcceleration.y > 0)
                     {
                        _serverWindAcceleration.y += 2500 * param1;
                        if(_serverWindAcceleration.y > _serverWindTargetAcceleration.y)
                        {
                           _serverWindAcceleration.y = _serverWindTargetAcceleration.y;
                           _serverWindTargetAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindTargetAcceleration.y < 0)
                     {
                        _serverWindAcceleration.y -= 2500 * param1;
                        if(_serverWindAcceleration.y < _serverWindTargetAcceleration.y)
                        {
                           _serverWindAcceleration.y = _serverWindTargetAcceleration.y;
                           _serverWindTargetAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindAcceleration.y < 0)
                     {
                        _serverWindAcceleration.y += 5000 * param1;
                        if(_serverWindAcceleration.y > 0)
                        {
                           _serverWindAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindAcceleration.y > 0)
                     {
                        _serverWindAcceleration.y -= 5000 * param1;
                        if(_serverWindAcceleration.y < 0)
                        {
                           _serverWindAcceleration.y = 0;
                        }
                     }
                     if(_serverWindTargetAcceleration.y == 0)
                     {
                        if(_serverAcceleration.y < 150)
                        {
                           _serverAcceleration.y += 300 * param1;
                        }
                     }
                     else
                     {
                        _serverAcceleration.y = 0;
                     }
                     _serverVelocity.y += param1 * (_serverAcceleration.y + _serverWindAcceleration.y);
                     if(_serverWindAcceleration.y != 0)
                     {
                        if(_serverVelocity.y > 1.5 * 150)
                        {
                           _serverVelocity.y = 1.5 * 150;
                        }
                        if(_serverVelocity.y < -150)
                        {
                           _serverVelocity.y = -150;
                        }
                     }
                     else if(_serverVelocity.y > 150)
                     {
                        _serverVelocity.y -= 3 * 300 * param1;
                        if(_serverVelocity.y < 150)
                        {
                           _serverVelocity.y = 150;
                        }
                     }
                     if(_serverAcceleration.x != 0 || _serverWindAcceleration.x != 0)
                     {
                        _serverVelocity.x += param1 * (_serverAcceleration.x + _serverWindAcceleration.x);
                        if(_serverWindAcceleration.x != 0)
                        {
                           if(_serverVelocity.x > 275)
                           {
                              _serverVelocity.x = 275;
                           }
                           else if(_serverVelocity.x < -275)
                           {
                              _serverVelocity.x = -275;
                           }
                        }
                        else if(_serverVelocity.x > 200)
                        {
                           _serverVelocity.x -= 700 * param1;
                           if(_serverVelocity.x < 200)
                           {
                              _serverVelocity.x = 200;
                           }
                        }
                        else if(_serverVelocity.x < -200)
                        {
                           _serverVelocity.x += 700 * param1;
                           if(_serverVelocity.x > -200)
                           {
                              _serverVelocity.x = -200;
                           }
                        }
                     }
                     else if(_serverVelocity.x > 0)
                     {
                        _serverVelocity.x -= 700 * param1;
                        if(_serverVelocity.x < 0)
                        {
                           _serverVelocity.x = 0;
                        }
                     }
                     else if(_serverVelocity.x < 0)
                     {
                        _serverVelocity.x += 700 * param1;
                        if(_serverVelocity.x > 0)
                        {
                           _serverVelocity.x = 0;
                        }
                     }
                     _lastFrameVelocity.x = param1 * _serverVelocity.x;
                     _lastFrameVelocity.y = param1 * _serverVelocity.y;
                  }
                  _loc8_.x = _serverPosition.x + _centerPointOffsetX;
                  _loc8_.y = _serverPosition.y + _centerPointOffsetY;
                  if(_lastFrameVelocity.x != 0)
                  {
                     _serverPosition.x += _lastFrameVelocity.x;
                     if(_serverPosition.x > 850)
                     {
                        _serverPosition.x = 850;
                     }
                     else if(_serverPosition.x - _radius < 50)
                     {
                        _serverPosition.x = 50 + _radius;
                     }
                  }
                  _serverPosition.y += _lastFrameVelocity.y;
               }
               else
               {
                  _landedReceived--;
                  if(_landedReceived == 0)
                  {
                     setLanded();
                  }
               }
               _loc12_ = null;
               if(_serverVelocity.x != 0)
               {
                  _parachuteFrame.rotation = 7 * _serverVelocity.x / 200;
               }
               else
               {
                  _clone.rotation = 0;
                  _parachuteFrame.rotation = 0;
               }
               if(_localPlayer)
               {
                  _loc21_ = false;
                  _loc16_ = false;
                  _clone.x = _serverPosition.x;
                  _clone.y = _serverPosition.y;
                  if(_theGame._ground.clone && _theGame._ground.clone.loader.parent)
                  {
                     _loc8_.x = _serverPosition.x + _centerPointOffsetX;
                     _loc8_.y = _serverPosition.y + _centerPointOffsetY;
                     if(_lastFrameVelocity.y != 0)
                     {
                        if(_loc8_.y + _radius >= _theGame._ground.clone.loader.y)
                        {
                           _loc11_ = _theGame._ground.volumePoints;
                           _loc3_ = new Point();
                           _loc4_ = new Point();
                           _loc9_ = 0;
                           while(_loc9_ < _loc11_.length - 1)
                           {
                              _loc3_.x = _loc11_[_loc9_].x + _theGame._ground.clone.loader.x;
                              _loc4_.x = _loc11_[_loc9_ + 1].x + _theGame._ground.clone.loader.x;
                              _loc3_.y = _loc11_[_loc9_].y + _theGame._ground.clone.loader.y;
                              _loc4_.y = _loc11_[_loc9_ + 1].y + _theGame._ground.clone.loader.y;
                              if(Collision.movingCircleVsRay(_loc8_,_radius,_lastFrameVelocity,1,_loc3_,_loc4_) >= 0)
                              {
                                 setLanded();
                                 _loc21_ = true;
                                 break;
                              }
                              _loc9_++;
                           }
                        }
                     }
                  }
                  for(var _loc14_ in _theGame._gems)
                  {
                     if(_theGame._gems[_loc14_] && _theGame._gems[_loc14_].enabled == true)
                     {
                        _loc15_ = _theGame._gems[_loc14_].centerPointX - (_clone.x + _centerPointOffsetX);
                        _loc17_ = _theGame._gems[_loc14_].centerPointY - (_clone.y + _centerPointOffsetY);
                        _loc13_ = _radius + _theGame._gems[_loc14_].radius;
                        _loc15_ *= _loc15_;
                        _loc17_ *= _loc17_;
                        if(_loc15_ + _loc17_ < _loc13_ * _loc13_)
                        {
                           _loc2_ = [];
                           _loc2_[0] = "gem";
                           _loc2_[1] = String(_loc14_);
                           MinigameManager.msg(_loc2_);
                           _theGame.gemPickup(int(_loc14_));
                           _theGame._soundMan.playByName(_theGame._soundNameGemAdded);
                           break;
                        }
                     }
                  }
                  if(_polluteTimer <= 0)
                  {
                     for each(_loc12_ in _theGame._phantoms)
                     {
                        if(_loc12_.clone && _loc12_.clone.content && _loc12_.polluteTimer <= 0)
                        {
                           _loc15_ = _loc12_.clone.x + _loc12_.clone.content.collision.x + _loc12_.clone.content.collision.width / 2 - (_clone.x + _centerPointOffsetX);
                           _loc17_ = _loc12_.clone.y + _loc12_.clone.content.collision.y + _loc12_.clone.content.collision.height / 2 - (_clone.y + _centerPointOffsetY);
                           _loc13_ = _radius + _loc12_.clone.content.collision.width / 2;
                           _loc15_ *= _loc15_;
                           _loc17_ *= _loc17_;
                           if(_loc15_ + _loc17_ < _loc13_ * _loc13_)
                           {
                              setPolluted(_loc12_,false);
                              _loc16_ = true;
                              _theGame._soundMan.playByName(_theGame._soundNamePhantomShock);
                              break;
                           }
                        }
                     }
                  }
                  if(_serverWindTargetAcceleration.x == 0)
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
                  _updatePositionTimer += param1;
                  if(_updatePositionTimer > 0.25 || _loc19_ != -1 || _loc21_ || _loc16_ || _loc10_)
                  {
                     _loc2_ = [];
                     _loc2_[0] = "pos";
                     _loc2_[1] = String(int(_clone.x));
                     _loc2_[2] = String(int(_clone.y));
                     _loc2_[3] = String(int(_serverAcceleration.x));
                     _loc2_[4] = String(int(_serverAcceleration.y));
                     _loc2_[5] = String(int(_serverVelocity.x));
                     _loc2_[6] = String(int(_serverVelocity.y));
                     if(_loc21_)
                     {
                        _loc2_[7] = "4";
                     }
                     else if(_loc10_)
                     {
                        _loc2_[7] = "3";
                        _loc2_[8] = String(int(_serverWindTargetAcceleration.x));
                        _loc2_[9] = String(int(_serverWindTargetAcceleration.y));
                     }
                     else if(_loc16_)
                     {
                        _loc2_[7] = "2";
                        _loc2_[8] = String(_loc12_.phantomID);
                     }
                     else
                     {
                        _loc2_[7] = "0";
                     }
                     MinigameManager.msg(_loc2_);
                     _updatePositionTimer = 0;
                  }
               }
               else if(_landed)
               {
                  _clone.x = _serverPosition.x;
                  _clone.y = _serverPosition.y;
               }
               else
               {
                  _loc7_ = new Point();
                  _loc7_.x = _clone.x;
                  _loc7_.y = _clone.y;
                  _loc5_ = Point.distance(_loc7_,_serverPosition);
                  _currentVelocity.x = _serverPosition.x - _clone.x;
                  _currentVelocity.y = _serverPosition.y - _clone.y;
                  _serverHitType = 0;
                  _loc6_ = 0.2;
                  _clone.x += _currentVelocity.x * _loc6_;
                  _clone.y += _currentVelocity.y * _loc6_;
               }
               updateParachute();
            }
            else
            {
               _clone.rotation = 0;
               _parachuteFrame.rotation = 0;
            }
         }
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         var _loc6_:Boolean = false;
         _serverPosition.x = int(param1[param2++]);
         _serverPosition.y = int(param1[param2++]);
         _serverAcceleration.x = int(param1[param2++]);
         _serverAcceleration.y = int(param1[param2++]);
         _serverVelocity.x = int(param1[param2++]);
         _serverVelocity.y = int(param1[param2++]);
         _serverHitType = int(param1[param2++]);
         switch(_serverHitType - 2)
         {
            case 0:
               _loc5_ = int(param1[param2++]);
               _loc6_ = false;
               for each(_loc3_ in _theGame._phantoms)
               {
                  if(_loc3_.phantomID == _loc5_)
                  {
                     _loc6_ = true;
                     break;
                  }
               }
               if(!_loc6_)
               {
                  _loc3_ = null;
               }
               setPolluted(_loc3_,false);
               break;
            case 1:
               _serverWindTargetAcceleration.x = int(param1[param2++]);
               _serverWindTargetAcceleration.y = int(param1[param2++]);
               break;
            case 2:
               _landedReceived = 3;
         }
         return param2;
      }
      
      private function updateParachute() : void
      {
         if(_parachuteFrame)
         {
            _parachuteFrame.x = _clone.x - 112 + _parachute.loader.width / 2;
            _parachuteFrame.y = _clone.y - 230 + _parachute.loader.height;
            _parachute.loader.x = -_parachute.loader.width / 2;
            _parachute.loader.y = -_parachute.loader.height;
            if(_dropGems)
            {
               _dropGems.loader.x = _clone.x - 50;
               _dropGems.loader.y = _clone.y - 50;
            }
         }
      }
      
      private function playAnimationState(param1:int) : void
      {
         var _loc2_:Function = null;
         var _loc3_:int = 0;
         switch(param1 - 19)
         {
            case 0:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Float";
               }
               break;
            case 1:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Struggle";
               }
               break;
            case 2:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Land";
               }
               _loc2_ = animationAtEnd;
               break;
            case 5:
               _loc3_ = 0;
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "BounceUp";
               }
               _loc2_ = animationAtEnd;
         }
         _clone.playAnim(param1,false,_loc3_,_loc2_);
         if(_parachute)
         {
            updateParachute();
         }
      }
      
      private function animationAtEnd(param1:LayerAnim, param2:int) : void
      {
         if(_clone && param1)
         {
            switch(param2 - 21)
            {
               case 3:
                  playAnimationState(19);
            }
         }
      }
      
      public function receiveGem(param1:int) : void
      {
         _gemCount += 4;
      }
      
      public function setLanded() : void
      {
         _landed = true;
         new GTween(this,0.5,{"_alpha":0});
         playAnimationState(21);
      }
      
      public function setPolluted(param1:Object, param2:Boolean) : void
      {
         _phantomsHit++;
         if(!_dropGems.loader.content.dropGems)
         {
            _dropGems.loader.content.dropGems = true;
         }
         if(param2)
         {
            _gemCount = 0;
         }
         else
         {
            _gemCount -= 3;
            if(_gemCount < 0)
            {
               _gemCount = 0;
            }
         }
         playAnimationState(20);
         _polluteTimer = 3.5;
         _positionHoldTimer = 0.75;
         _serverAcceleration.x = 0;
         _serverVelocity.x = 0;
         _serverWindAcceleration.x = 0;
         _serverWindTargetAcceleration.x = 0;
         _serverAcceleration.y = 0;
         _serverVelocity.y = 0;
         _serverWindAcceleration.y = 0;
         _serverWindTargetAcceleration.y = 0;
         if(!param2 && param1)
         {
            param1.polluteTimer = 1;
            if(param1.clone && param1.clone.content)
            {
               param1.clone.content.gotoAndPlay("Pollute");
               param1.clone.content.currentLoop = "Pollute";
               param1.clone.content.transition = null;
            }
         }
      }
      
      public function onParachuteLoaderComplete(param1:Event) : void
      {
         param1.target.content.setColor(_playerNum);
         param1.target.content.transition = "Float";
         param1.target.removeEventListener("complete",onParachuteLoaderComplete);
      }
   }
}

