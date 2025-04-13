package game.riverRace
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class RiverSegment
   {
      public static const SLOT_STARTX:int = 150;
      
      public static const RIVER_WIDTH:int = 615;
      
      public var _theGame:RiverRace;
      
      public var _scene:Sprite;
      
      public var _clone:Object;
      
      public var _riverWater:Object;
      
      public var _tileID:int;
      
      public var _flipType:int;
      
      public var _name:String;
      
      public var _volumes:Array;
      
      public var _startEnd:Boolean;
      
      public var _added:Boolean;
      
      public var _buoys:Array;
      
      public var _rocks:Array;
      
      public var _whirlpools:Array;
      
      public function RiverSegment(param1:RiverRace)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:Object, param2:String, param3:Boolean, param4:int = -1, param5:int = 1) : void
      {
         var _loc8_:int = 0;
         var _loc11_:* = null;
         var _loc6_:* = null;
         _scene = new Sprite();
         _clone = param1;
         _startEnd = param3;
         _tileID = param4;
         _flipType = param5;
         _name = param2;
         _added = false;
         var _loc10_:int = int(param1.loader.x);
         var _loc13_:int = int(param1.loader.y);
         _clone.loader.x = 0;
         _clone.loader.y = 0;
         flipTile(_clone.loader);
         _scene.addChild(_clone.loader);
         var _loc7_:Array = _theGame.getScene().getActorList("ActorVolume");
         var _loc12_:Number = -1;
         var _loc9_:Number = -1;
         _volumes = [];
         for each(_loc11_ in _loc7_)
         {
            if(_loc11_.name.search(param2 + "_volume_") != -1)
            {
               _volumes.push(_loc11_.points);
            }
         }
         for each(_loc6_ in _volumes)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc6_.length - 1)
            {
               _loc6_[_loc8_].x -= _loc10_;
               _loc6_[_loc8_].y -= _loc13_;
               _loc8_++;
            }
            _loc8_ = _loc6_.length - 1;
            while(_loc8_ >= 0)
            {
               if(_loc6_[_loc8_].x < 0 && _loc6_[_loc8_].y < 0 || _loc6_[_loc8_].x < 0 && _loc6_[_loc8_].y > _clone.loader.height || _loc6_[_loc8_].x > _clone.loader.width && _loc6_[_loc8_].y < 0 || _loc6_[_loc8_].x > _clone.loader.width && _loc6_[_loc8_].y > _clone.loader.height)
               {
                  _loc6_.splice(_loc8_,1);
               }
               else if(_loc6_[_loc8_].y < 0 || _loc6_[_loc8_].y > _clone.loader.height)
               {
                  if(_loc6_[_loc8_].y < 0)
                  {
                     _loc6_[_loc8_].y = 0;
                  }
                  else
                  {
                     _loc6_[_loc8_].y = _clone.loader.height;
                  }
                  if(_loc6_[_loc8_].x < _clone.loader.width - _loc6_[_loc8_].x)
                  {
                     if(_loc12_ == -1)
                     {
                        _loc12_ = Number(_loc6_[_loc8_].x);
                     }
                     else
                     {
                        _loc6_[_loc8_].x = _loc12_;
                     }
                  }
                  else if(_loc9_ == -1)
                  {
                     _loc9_ = Number(_loc6_[_loc8_].x);
                  }
                  else
                  {
                     _loc6_[_loc8_].x = _loc9_;
                  }
               }
               _loc8_--;
            }
         }
      }
      
      public function initRiverWater() : void
      {
         _riverWater.loader.content.gotoAndPlay("tile4_1");
      }
      
      public function onRiverWaterLoaderComplete(param1:Event) : void
      {
         if(_added)
         {
            initRiverWater();
         }
         param1.target.removeEventListener("complete",onRiverWaterLoaderComplete);
      }
      
      public function add(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         _added = true;
         if(_riverWater && _riverWater.loader.content)
         {
            initRiverWater();
         }
         _scene.x = 0;
         _scene.y = param1;
         _theGame._layerBackground.addChild(_scene);
         if(_startEnd)
         {
            if(param2)
            {
               _theGame._startingLine.loader.x = 0;
               _theGame._startingLine.loader.y = param1 + _theGame._startingLine.y;
               _theGame._currentBuoyY = _theGame._startingLine.loader.y;
               _theGame._layerForeground.addChild(_theGame._startingLine.loader);
            }
            else
            {
               _theGame._finishLine.loader.x = 0;
               _theGame._finishLine.loader.y = param1 + _theGame._finishLine.y;
               _theGame._layerBackground.addChild(_theGame._finishLine.loader);
            }
         }
         _buoys = [];
         _rocks = [];
         _whirlpools = [];
         while(_theGame._currentBuoyIndex < _theGame._levels[_theGame._levelIndex].length && -_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].offset + _theGame._currentBuoyY >= param1)
         {
            _loc3_ = null;
            _theGame._currentBuoyY += -_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].offset;
            if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].boost)
            {
               if(_theGame._inactiveBuoys.length > 0)
               {
                  _loc3_ = _theGame._inactiveBuoys[0];
                  _theGame._inactiveBuoys.splice(0,1);
                  initBuoy(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("arrows");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onBuoyLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].boost - 1);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._arrowOffsetY;
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _buoys.push(_loc3_);
            }
            else if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].rocks)
            {
               if(_theGame._inactiveRocks.length > 0)
               {
                  _loc3_ = _theGame._inactiveRocks[0];
                  _theGame._inactiveRocks.splice(0,1);
                  initRocks(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("rocks");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onRocksLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].rocks - 1);
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._rocksOffsetY;
               _rocks.push(_loc3_);
            }
            else if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].whirlpool)
            {
               if(_theGame._inactiveWhirlpools.length > 0)
               {
                  _loc3_ = _theGame._inactiveWhirlpools[0];
                  _theGame._inactiveWhirlpools.splice(0,1);
                  initWhirlpool(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("whirlpool");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onWhirlpoolLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].whirlpool - 1);
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._whirlpoolOffsetY;
               _whirlpools.push(_loc3_);
            }
            if(_loc3_)
            {
               _loc3_._active = true;
            }
            _theGame._currentBuoyIndex++;
         }
      }
      
      public function remove() : void
      {
         _added = false;
         while(_buoys && _buoys.length > 0)
         {
            if(_buoys[0].loader.parent)
            {
               _buoys[0].loader.parent.removeChild(_buoys[0].loader);
            }
            _theGame._inactiveBuoys.push(_buoys[0]);
            _buoys.splice(0,1);
         }
         _buoys = null;
         while(_rocks && _rocks.length > 0)
         {
            if(_rocks[0].loader.parent)
            {
               _rocks[0].loader.parent.removeChild(_rocks[0].loader);
            }
            _theGame._inactiveRocks.push(_rocks[0]);
            _rocks.splice(0,1);
         }
         _rocks = null;
         while(_whirlpools && _whirlpools.length > 0)
         {
            if(_whirlpools[0].loader.parent)
            {
               _whirlpools[0].loader.parent.removeChild(_whirlpools[0].loader);
            }
            _theGame._inactiveWhirlpools.push(_whirlpools[0]);
            _whirlpools.splice(0,1);
         }
         _whirlpools = null;
         if(_riverWater && _riverWater.loader.content)
         {
            _riverWater.loader.content.stop();
         }
         if(_startEnd)
         {
            if(_theGame._startingLine.loader.parent)
            {
               _theGame._startingLine.loader.parent.removeChild(_theGame._startingLine.loader);
            }
            if(_theGame._finishLine.loader.parent)
            {
               _theGame._finishLine.loader.parent.removeChild(_theGame._finishLine.loader);
            }
         }
         _scene.parent.removeChild(_scene);
      }
      
      public function onBuoyLoaderComplete(param1:Event) : void
      {
         initBuoy(param1.target);
         param1.target.removeEventListener("complete",onBuoyLoaderComplete);
      }
      
      public function onRocksLoaderComplete(param1:Event) : void
      {
         initRocks(param1.target);
         param1.target.removeEventListener("complete",onRocksLoaderComplete);
      }
      
      public function onWhirlpoolLoaderComplete(param1:Event) : void
      {
         initWhirlpool(param1.target);
         param1.target.removeEventListener("complete",onWhirlpoolLoaderComplete);
      }
      
      public function initBuoy(param1:Object) : void
      {
      }
      
      public function initRocks(param1:Object) : void
      {
      }
      
      public function initWhirlpool(param1:Object) : void
      {
      }
      
      public function flipTile(param1:Object) : void
      {
         var _loc6_:Matrix = null;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_flipType > 1)
         {
            _loc6_ = param1.transform.matrix;
            _loc6_.identity();
            _loc3_ = 1;
            _loc5_ = 1;
            _loc2_ = Number(param1.x);
            _loc4_ = Number(param1.y);
            if(_flipType == 2 || _flipType == 4)
            {
               _loc3_ *= -1;
               _loc2_ += param1.content.width;
            }
            if(_flipType == 3 || _flipType == 4)
            {
               _loc5_ *= -1;
               _loc4_ += param1.content.height;
            }
            _loc6_.scale(_loc3_,_loc5_);
            _loc6_.translate(_loc2_,_loc4_);
            param1.transform.matrix = _loc6_;
         }
      }
      
      public function getHeight() : int
      {
         return _clone.loader.height;
      }
      
      public function toggleRiverWater() : void
      {
         if(_riverWater && _riverWater.loader.content)
         {
            if(_riverWater.loader.parent)
            {
               _riverWater.loader.parent.removeChild(_riverWater.loader);
               _riverWater.loader.content.stop();
            }
            else
            {
               _scene.addChild(_riverWater.loader);
               initRiverWater();
            }
         }
      }
      
      public function testObstacleCollision(param1:RiverRacePlayer, param2:Point, param3:Point, param4:int) : void
      {
         var _loc8_:Rectangle = null;
         var _loc5_:Rectangle = null;
         var _loc6_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         if(param1._clone.loader.content)
         {
            _loc8_ = new Rectangle(param1._clone.loader.x + param1._clone.loader.content.collision.x,param1._clone.loader.y + param1._clone.loader.content.collision.y,param1._clone.loader.content.collision.width,param1._clone.loader.content.collision.height);
            _loc5_ = new Rectangle();
            if(_buoys)
            {
               _loc6_ = 0;
               while(_loc6_ < _buoys.length)
               {
                  _loc5_.x = _buoys[_loc6_].loader.content.collision.x + _buoys[_loc6_].loader.x;
                  _loc5_.y = _buoys[_loc6_].loader.content.collision.y + _buoys[_loc6_].loader.y;
                  _loc5_.width = _buoys[_loc6_].loader.content.collision.width;
                  _loc5_.height = _buoys[_loc6_].loader.content.collision.height;
                  if(_loc8_.intersects(_loc5_))
                  {
                     _buoys[_loc6_].loader.content.activateArrow();
                     param1.insideBuoy();
                  }
                  _loc6_++;
               }
            }
            if(_rocks)
            {
               _loc9_ = 0;
               while(_loc9_ < _rocks.length)
               {
                  _loc5_.x = _rocks[_loc9_].loader.content.collision.x + _rocks[_loc9_].loader.x;
                  _loc5_.y = _rocks[_loc9_].loader.content.collision.y + _rocks[_loc9_].loader.y;
                  _loc5_.width = _rocks[_loc9_].loader.content.collision.width;
                  _loc5_.height = _rocks[_loc9_].loader.content.collision.height;
                  if(_loc8_.intersects(_loc5_))
                  {
                     param1.insideRock();
                  }
                  _loc9_++;
               }
            }
            if(_whirlpools)
            {
               _loc7_ = 0;
               while(_loc7_ < _whirlpools.length)
               {
                  _loc5_.x = _whirlpools[_loc7_].loader.content.collision.x + _whirlpools[_loc7_].loader.x;
                  _loc5_.y = _whirlpools[_loc7_].loader.content.collision.y + _whirlpools[_loc7_].loader.y;
                  _loc5_.width = _whirlpools[_loc7_].loader.content.collision.width;
                  _loc5_.height = _whirlpools[_loc7_].loader.content.collision.height;
                  if(_loc8_.intersects(_loc5_))
                  {
                     param1.insideWhirlpool();
                  }
                  _loc7_++;
               }
            }
         }
      }
   }
}

