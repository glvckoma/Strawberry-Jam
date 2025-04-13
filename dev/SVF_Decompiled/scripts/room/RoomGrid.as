package room
{
   import avatar.AvatarManager;
   import com.baseoneonline.astar.AStar;
   import com.baseoneonline.astar.Graph;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import gui.GuiManager;
   
   public class RoomGrid implements Graph
   {
      public static const GRID_CELL_OPEN:uint = 0;
      
      public static const GRID_CELL_WALL:uint = 1;
      
      public static const GRID_CELL_AIR:uint = 2;
      
      public static const GRID_CELL_PHANTOM:uint = 3;
      
      private static const COST_DIAG:Number = Math.sqrt(2);
      
      private var GRID_DEPTH_LIMIT:uint = 128;
      
      private var startPos:Object;
      
      private var _grid:Object;
      
      private var _astar:AStar;
      
      public function RoomGrid()
      {
         super();
         _astar = new AStar();
      }
      
      public function setGridDepth(param1:uint) : void
      {
         GRID_DEPTH_LIMIT = param1;
      }
      
      public function setGrid(param1:Object) : void
      {
         var _loc2_:int = 0;
         var _loc7_:ByteArray = null;
         var _loc3_:* = undefined;
         var _loc5_:int = 0;
         var _loc4_:* = 0;
         var _loc8_:* = 0;
         var _loc6_:int = 0;
         if(param1.hasOwnProperty("packedGrid"))
         {
            _loc7_ = param1.packedGrid;
            _loc7_.position = 0;
            _loc3_ = new Vector.<uint>(param1.height * param1.width);
            _loc5_ = 0;
            while(_loc5_ < _loc7_.length / 2)
            {
               _loc4_ = _loc7_.readUnsignedShort();
               _loc8_ = uint(_loc4_ >> 14);
               if(GuiManager.isBeYourPetRoom())
               {
                  if(_loc8_ & 2 && AvatarManager.playerAvatarWorldView && !AvatarManager.playerAvatarWorldView.isActivePetGroundPet())
                  {
                     _loc8_ = 0;
                  }
               }
               else if(AvatarManager.playerAvatar)
               {
                  if(Utility.isAir(AvatarManager.playerAvatar.enviroTypeFlag))
                  {
                     if((_loc8_ & 2) == 0)
                     {
                        _loc8_ = 0;
                     }
                  }
                  else if(Utility.isLand(AvatarManager.playerAvatar.enviroTypeFlag))
                  {
                     if((_loc8_ & 1) == 0)
                     {
                        _loc8_ = 0;
                     }
                  }
               }
               _loc4_ &= 16383;
               _loc6_ = 0;
               while(_loc6_ < _loc4_)
               {
                  _loc3_[_loc2_++] = _loc8_;
                  _loc6_++;
               }
               _loc5_++;
            }
            param1.grid = _loc3_;
         }
         _grid = param1;
         _astar.setGraph(this);
      }
      
      public function get hasReachedGoal() : Boolean
      {
         return _astar.hasReachedGoal();
      }
      
      public function enableVolume(param1:String, param2:Boolean = true) : void
      {
         var _loc5_:Array = null;
         var _loc9_:int = 0;
         var _loc3_:Object = null;
         var _loc10_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:* = 0;
         var _loc12_:* = 0;
         var _loc11_:int = 0;
         if(_grid.hasOwnProperty("dynamicVolumes"))
         {
            _loc5_ = _grid.dynamicVolumes;
            while(_loc9_ < _loc5_.length)
            {
               _loc3_ = _loc5_[_loc9_];
               if(_loc3_.name == param1)
               {
                  _loc3_.packedBlock.position = 0;
                  _loc10_ = int(_loc3_.y);
                  _loc6_ = _loc3_.x + _loc3_.y * _grid.width;
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_.packedBlock.length / 2)
                  {
                     _loc8_ = uint(_loc3_.packedBlock.readUnsignedShort());
                     _loc12_ = uint(_loc8_ >> 14);
                     _loc8_ &= 16383;
                     _loc11_ = 0;
                     while(_loc11_ < _loc8_)
                     {
                        if(_loc12_ > 0)
                        {
                           _grid.grid[_loc6_] = param2 ? _loc12_ : 0;
                        }
                        _loc6_++;
                        _loc7_++;
                        if(_loc7_ == _loc3_.width)
                        {
                           _loc7_ = 0;
                           _loc6_ += _grid.width - _loc3_.width;
                        }
                        _loc11_++;
                     }
                     _loc4_++;
                  }
               }
               _loc9_++;
            }
         }
      }
      
      public function getCellIndex(param1:int, param2:int) : int
      {
         param1 -= _grid.min.x;
         param2 -= _grid.min.y;
         param1 /= _grid.r2;
         param2 /= _grid.r2;
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 >= _grid.width)
         {
            param1 = _grid.width - 1;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         if(param2 >= _grid.height)
         {
            param2 = _grid.height - 1;
         }
         return int(param1 + param2 * _grid.width);
      }
      
      public function convertWorldPosToGrid(param1:Number, param2:Number) : Object
      {
         param1 -= _grid.min.x;
         param2 -= _grid.min.y;
         param1 /= _grid.r2;
         param2 /= _grid.r2;
         var _loc3_:Boolean = true;
         if(param1 < 0 || param1 >= _grid.width || param2 < 0 || param2 >= _grid.height)
         {
            _loc3_ = false;
         }
         return {
            "x":int(param1),
            "y":int(param2),
            "bInBounds":_loc3_
         };
      }
      
      public function convertCellToCoords(param1:int) : Object
      {
         var _loc3_:Number = int(param1 / _grid.width);
         var _loc2_:Number = Math.abs(param1 % _grid.width);
         return {
            "x":_loc2_,
            "y":_loc3_
         };
      }
      
      public function getCellIndexToWorldPos(param1:int) : Object
      {
         var _loc3_:Number = int(param1 / _grid.width);
         var _loc2_:Number = param1 - _loc3_ * _grid.width;
         _loc2_ *= _grid.r2;
         _loc3_ *= _grid.r2;
         _loc2_ += _grid.min.x + _grid.r;
         _loc3_ += _grid.min.y + _grid.r;
         return {
            "x":_loc2_,
            "y":_loc3_
         };
      }
      
      public function convertGridPosToWorld(param1:int, param2:int) : Object
      {
         var _loc4_:Number = param1 * _grid.r2 + _grid.min.x + _grid.r;
         var _loc3_:Number = param2 * _grid.r2 + _grid.min.y + _grid.r;
         return {
            "x":_loc4_,
            "y":_loc3_
         };
      }
      
      public function getBottomYGridPosToWorld(param1:int) : Number
      {
         return param1 * _grid.r2 + _grid.min.y + _grid.r2;
      }
      
      public function getLeftGridPosToWorld(param1:int) : Number
      {
         return param1 * _grid.r2 + _grid.min.x;
      }
      
      public function getRightGridPosToWorld(param1:int) : Number
      {
         return param1 * _grid.r2 + _grid.min.x + _grid.r2;
      }
      
      public function testGridCell(param1:int, param2:int) : uint
      {
         if(param1 >= 0 && param1 < _grid.width && param2 >= 0 && param2 < _grid.height)
         {
            return _grid.grid[param2 * _grid.width + param1];
         }
         return 1;
      }
      
      public function findPath(param1:Point, param2:Point) : Vector.<int>
      {
         if(!_grid)
         {
            return new Vector.<int>();
         }
         return _astar.solve(getCellIndex(param1.x,param1.y),getCellIndex(param2.x,param2.y));
      }
      
      public function findPathOptimized(param1:Point, param2:Point) : Vector.<int>
      {
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         if(!_grid)
         {
            return null;
         }
         var _loc7_:int = getCellIndex(param1.x,param1.y);
         var _loc5_:int = getCellIndex(param2.x,param2.y);
         if(_loc7_ < 0 || _loc5_ < 0 || _loc7_ > size() || _loc5_ > size())
         {
            return null;
         }
         var _loc3_:Vector.<int> = _astar.solve(_loc7_,_loc5_);
         var _loc4_:Vector.<int> = new Vector.<int>();
         if(_loc3_.length == 1)
         {
            return _loc3_;
         }
         var _loc11_:* = getCellDir(_loc3_[0],_loc3_[1]);
         var _loc6_:int = int(_loc3_.length);
         var _loc9_:* = 0;
         _loc10_ = 1;
         while(_loc10_ < _loc6_)
         {
            _loc8_ = getCellDir(_loc3_[_loc10_ - 1],_loc3_[_loc10_]);
            if(_loc11_ != _loc8_)
            {
               _loc11_ = _loc8_;
               if(_loc9_ != _loc10_ - 1)
               {
                  _loc4_.push(_loc3_[_loc10_]);
                  _loc9_ = _loc10_;
               }
            }
            _loc10_++;
         }
         if(_loc4_.length == 0 || _loc4_.length && _loc4_[_loc4_.length - 1] != _loc3_[_loc3_.length - 1])
         {
            _loc4_.push(_loc3_[_loc3_.length - 1]);
         }
         return _loc4_;
      }
      
      public function getCellDiameter() : int
      {
         return _grid.r2;
      }
      
      private function getCellDir(param1:int, param2:int) : int
      {
         var _loc3_:int = -1;
         var _loc4_:int = int(_grid.width);
         if(param1 - _loc4_ == param2)
         {
            _loc3_ = 0;
         }
         else if(param1 - _loc4_ + 1 == param2)
         {
            _loc3_ = 1;
         }
         else if(param1 + 1 == param2)
         {
            _loc3_ = 2;
         }
         else if(param1 + _loc4_ + 1 == param2)
         {
            _loc3_ = 3;
         }
         else if(param1 + _loc4_ == param2)
         {
            _loc3_ = 4;
         }
         else if(param1 + _loc4_ - 1 == param2)
         {
            _loc3_ = 5;
         }
         else if(param1 - 1 == param2)
         {
            _loc3_ = 6;
         }
         else if(param1 - _loc4_ - 1 == param2)
         {
            _loc3_ = 7;
         }
         return _loc3_;
      }
      
      public function setStartGridPos(param1:int) : void
      {
         startPos = convertCellToCoords(param1);
      }
      
      public function getNeighbors(param1:int, param2:Vector.<int>) : Vector.<int>
      {
         var _loc4_:int = 0;
         var _loc5_:Object = convertCellToCoords(param1);
         var _loc7_:int = int(_loc5_.x);
         var _loc9_:int = int(_loc5_.y);
         var _loc6_:int = int(_grid.width);
         var _loc8_:int = int(_grid.height);
         var _loc3_:* = Math.abs(_loc5_.x - 1 - startPos.x) < GRID_DEPTH_LIMIT;
         var _loc10_:* = Math.abs(_loc5_.x + 1 - startPos.x) < GRID_DEPTH_LIMIT;
         var _loc11_:* = Math.abs(_loc5_.y - 1 - startPos.y) < GRID_DEPTH_LIMIT;
         var _loc12_:* = Math.abs(_loc5_.y + 1 - startPos.y) < GRID_DEPTH_LIMIT;
         param2.length = 0;
         if(_loc7_ > 0)
         {
            _loc4_ = param1 - 1;
            if(!_grid.grid[_loc4_] && _loc3_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc9_ > 0)
         {
            _loc4_ = param1 - _loc6_;
            if(!_grid.grid[_loc4_] && _loc11_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc7_ < _loc6_ - 1)
         {
            _loc4_ = param1 + 1;
            if(!_grid.grid[_loc4_] && _loc10_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc9_ < _loc8_ - 1)
         {
            _loc4_ = param1 + _loc6_;
            if(!_grid.grid[_loc4_] && _loc12_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc7_ > 0 && _loc9_ > 0)
         {
            _loc4_ = param1 - 1 - _loc6_;
            if(!_grid.grid[_loc4_] && !_grid.grid[param1 - 1] && !_grid.grid[param1 - _loc6_] && _loc11_ && _loc3_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc7_ < _loc6_ - 1 && _loc9_ > 0)
         {
            _loc4_ = param1 + 1 - _loc6_;
            if(!_grid.grid[_loc4_] && !_grid.grid[param1 + 1] && !_grid.grid[param1 - _loc6_] && _loc11_ && _loc10_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc7_ > 0 && _loc9_ < _loc8_ - 1)
         {
            _loc4_ = param1 - 1 + _loc6_;
            if(!_grid.grid[_loc4_] && !_grid.grid[param1 - 1] && !_grid.grid[param1 + _loc6_] && _loc12_ && _loc3_)
            {
               param2.push(_loc4_);
            }
         }
         if(_loc7_ < _loc6_ - 1 && _loc9_ < _loc8_ - 1)
         {
            _loc4_ = param1 + 1 + _loc6_;
            if(!_grid.grid[_loc4_] && !_grid.grid[param1 + 1] && !_grid.grid[param1 + _loc6_] && _loc12_ && _loc10_)
            {
               param2.push(_loc4_);
            }
         }
         return param2;
      }
      
      public function distance(param1:int, param2:int) : Number
      {
         var _loc3_:Object = getCellIndexToWorldPos(param1);
         var _loc5_:Object = getCellIndexToWorldPos(param2);
         var _loc4_:Number = Math.min(Math.abs(_loc3_.x - _loc5_.x),Math.abs(_loc3_.y - _loc5_.y));
         var _loc6_:Number = Math.abs(_loc3_.x - _loc5_.x) + Math.abs(_loc3_.y - _loc5_.y);
         return COST_DIAG * _loc4_ + _loc6_ - 2 * _loc4_;
      }
      
      public function size() : int
      {
         if(_grid == null)
         {
            return 0;
         }
         return _grid.width * _grid.height;
      }
      
      public function getNearestEmptyCell(param1:Number, param2:Number) : Object
      {
         var _loc3_:Object = convertWorldPosToGrid(param1,param2);
         var _loc4_:int = int(_loc3_.x);
         var _loc5_:int = int(_loc3_.y);
         if(testGridCell(_loc4_,_loc5_))
         {
            if(!testGridCell(_loc4_ + 1,_loc5_))
            {
               _loc4_++;
            }
            else if(!testGridCell(_loc4_ - 1,_loc5_))
            {
               _loc4_--;
            }
            else if(!testGridCell(_loc4_,_loc5_ - 1))
            {
               _loc5_ -= 1;
            }
            else if(!testGridCell(_loc4_ + 1,_loc5_ - 1))
            {
               _loc4_++;
               _loc5_--;
            }
            else if(!testGridCell(_loc4_ - 1,_loc5_ - 1))
            {
               _loc4_--;
               _loc5_--;
            }
            else if(!testGridCell(_loc4_,_loc5_ + 1))
            {
               _loc5_++;
            }
            else if(!testGridCell(_loc4_ + 1,_loc5_ + 1))
            {
               _loc4_++;
               _loc5_++;
            }
            else if(!testGridCell(_loc4_ - 1,_loc5_ + 1))
            {
               _loc4_--;
               _loc5_++;
            }
            else
            {
               trace("failed");
            }
         }
         return convertGridPosToWorld(_loc4_,_loc5_);
      }
      
      public function findClosestOpenGridCell(param1:Number, param2:Number, param3:Boolean = true) : Object
      {
         var _loc4_:Object = convertWorldPosToGrid(param1,param2);
         var _loc7_:int = int(_loc4_.x);
         var _loc9_:int = int(_loc4_.y);
         var _loc6_:int = int(_grid.width);
         var _loc8_:int = int(_grid.height);
         var _loc10_:int = 3;
         while(_loc10_ < 20)
         {
            _loc4_ = scanBox(_loc7_,_loc9_,_loc10_,param3);
            if(_loc4_)
            {
               break;
            }
            _loc10_ += 2;
            _loc7_--;
            _loc9_--;
         }
         if(_loc4_)
         {
            _loc4_ = convertGridPosToWorld(_loc4_.x,_loc4_.y);
         }
         return _loc4_;
      }
      
      private function scanBox(param1:int, param2:int, param3:int, param4:Boolean = true) : Object
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         param3--;
         param4 ? param1++ : param1--;
         while(_loc6_ < 4)
         {
            if(!testGridCell(param1,param2))
            {
               return {
                  "x":param1,
                  "y":param2
               };
            }
            _loc5_++;
            if(_loc5_ == param3)
            {
               _loc5_ = 0;
               _loc6_++;
            }
            if(param4)
            {
               switch(_loc6_)
               {
                  case 0:
                     param1++;
                     break;
                  case 1:
                     param2++;
                     break;
                  case 2:
                     param1--;
                     break;
                  case 3:
                     param2--;
                     break;
               }
               continue;
            }
            switch(_loc6_)
            {
               case 0:
                  param1--;
                  break;
               case 1:
                  param2++;
                  break;
               case 2:
                  param1++;
                  break;
               case 3:
                  param2--;
                  break;
            }
         }
         return null;
      }
   }
}

