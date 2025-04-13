package game.gemBreaker
{
   import flash.geom.Point;
   
   public class GemBreakerGrid
   {
      public static const CIRCLE_YSHIFT:Number = 0.86602540378444;
      
      private var _data:Array;
      
      private var _counter:int;
      
      private var _hasShifted:Boolean;
      
      public function GemBreakerGrid()
      {
         super();
         _data = [];
         _hasShifted = false;
      }
      
      public function length() : int
      {
         return _data.length;
      }
      
      public function getRowLength(param1:int) : int
      {
         return !!_data[param1] ? _data[param1].length : 0;
      }
      
      public function isRowEmpty(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         if(_data[param1] != null)
         {
            _loc2_ = 0;
            while(_loc2_ < _data[param1].length)
            {
               if(_data[param1][_loc2_] != null)
               {
                  return false;
               }
               _loc2_++;
            }
         }
         return true;
      }
      
      public function put(param1:int, param2:int, param3:GemBreakerGem) : Boolean
      {
         param3._state = 0;
         if(param1 >= 0 && _data[param1] == null)
         {
            _data[param1] = [];
         }
         if(_data[param1][param2] == null)
         {
            _data[param1][param2] = param3;
            return true;
         }
         return _data[param1][param2] == param3;
      }
      
      public function dropDisconnectedElements() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _data[0].length)
         {
            if(_data[0][_loc1_] != null)
            {
               markHangingElements(0,_loc1_);
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < _data.length)
         {
            _loc2_ = 0;
            while(_data[_loc1_] != null && _loc2_ < _data[_loc1_].length)
            {
               if(_data[_loc1_][_loc2_] != null)
               {
                  if(_data[_loc1_][_loc2_]._state != 1)
                  {
                     _data[_loc1_][_loc2_].setState(2);
                     _data[_loc1_][_loc2_] = null;
                  }
                  else
                  {
                     _data[_loc1_][_loc2_]._state = 0;
                  }
               }
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function markHangingElements(param1:int, param2:int) : void
      {
         if(param1 < 0 || param2 < 0 || _data[param1] == null || _data[param1][param2] == null || _data[param1][param2]._state != 0)
         {
            return;
         }
         _data[param1][param2]._state = 1;
         markHangingElements(param1,param2 - 1);
         markHangingElements(param1,param2 + 1);
         markHangingElements(param1 - 1,param2);
         markHangingElements(param1 + 1,param2);
         markHangingElements(param1 - 1,param2 + (param1 % 2 == hasShifted() ? -1 : 1));
         markHangingElements(param1 + 1,param2 + (param1 % 2 == hasShifted() ? -1 : 1));
      }
      
      public function eliminateNeighbors(param1:int, param2:int, param3:int = -1) : int
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param1 < 0 || param2 < 0 || _data[param1] == null || _data[param1][param2] == null || _data[param1][param2]._state != 0)
         {
            return 0;
         }
         var _loc6_:Boolean = false;
         if(param3 == -1)
         {
            param3 = int(_data[param1][param2]._type);
            _counter = 0;
            _loc6_ = true;
         }
         if(_data[param1][param2]._type == param3)
         {
            _data[param1][param2]._state = 1;
            _counter++;
            eliminateNeighbors(param1,param2 - 1,param3);
            eliminateNeighbors(param1,param2 + 1,param3);
            eliminateNeighbors(param1 - 1,param2,param3);
            eliminateNeighbors(param1 + 1,param2,param3);
            eliminateNeighbors(param1 - 1,param2 + (param1 % 2 == hasShifted() ? -1 : 1),param3);
            eliminateNeighbors(param1 + 1,param2 + (param1 % 2 == hasShifted() ? -1 : 1),param3);
         }
         if(_loc6_)
         {
            _loc4_ = 0;
            while(_loc4_ < _data.length)
            {
               _loc5_ = 0;
               while(_data[_loc4_] != null && _loc5_ < _data[_loc4_].length)
               {
                  if(_data[_loc4_][_loc5_] != null && _data[_loc4_][_loc5_]._state != 0)
                  {
                     if(_counter >= 3)
                     {
                        _data[_loc4_][_loc5_]._player.removeGem(_data[_loc4_][_loc5_]);
                        _data[_loc4_][_loc5_] = null;
                     }
                     else
                     {
                        _data[_loc4_][_loc5_]._state = 0;
                     }
                  }
                  _loc5_++;
               }
               _loc4_++;
            }
            dropDisconnectedElements();
            return _counter >= 3 ? _counter : 0;
         }
         return 0;
      }
      
      public function checkCollision(param1:GemBreakerGem, param2:Number, param3:Number, param4:int) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         _loc8_ = _data.length - 1;
         while(_loc8_ >= 0)
         {
            _loc9_ = 0;
            while(_data[_loc8_] != null && _loc9_ < _data[_loc8_].length)
            {
               if(_data[_loc8_][_loc9_] != null)
               {
                  _loc7_ = (_loc9_ + 1) * param2 + (_loc8_ % 2 == hasShifted() ? 0 : param2 / 2) + param3;
                  _loc6_ = (_loc8_ + 1) * param2 * 0.86602540378444;
                  _loc5_ = (_loc7_ - param1._clone.loader.x) * (_loc7_ - param1._clone.loader.x) + (_loc6_ - param1._clone.loader.y) * (_loc6_ - param1._clone.loader.y);
                  if(_loc5_ <= (param2 - param4) * (param2 - param4))
                  {
                     return true;
                  }
               }
               _loc9_++;
            }
            _loc8_--;
         }
         return false;
      }
      
      public function getGridCoords(param1:GemBreakerGem, param2:Number) : Point
      {
         var _loc3_:Point = new Point();
         _loc3_.x = Math.max(Math.round(param1._clone.loader.y / (0.86602540378444 * param2)) - 1,0);
         _loc3_.y = Math.max(Math.round((param1._clone.loader.x - param1._player._xOffset - (_loc3_.x % 2 == hasShifted() ? 0 : param2 / 2)) / param2) - 1,0);
         return _loc3_;
      }
      
      public function getGridCoordsByPos(param1:Number, param2:Number, param3:Number, param4:Number) : Point
      {
         var _loc5_:Point = new Point();
         _loc5_.x = Math.max(Math.round(param2 / (0.86602540378444 * param4)) - 1,0);
         _loc5_.y = Math.max(Math.round((param1 - param3 - (_loc5_.x % 2 == hasShifted() ? 0 : param4 / 2)) / param4) - 1,0);
         return _loc5_;
      }
      
      public function shiftDown(param1:Number) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         _hasShifted = !_hasShifted;
         _loc2_ = 0;
         while(_loc2_ < _data.length)
         {
            _loc3_ = 0;
            while(_data[_loc2_] != null && _loc3_ < _data[_loc2_].length)
            {
               if(_data[_loc2_][_loc3_] != null)
               {
                  _data[_loc2_][_loc3_]._clone.loader.y += 0.86602540378444 * param1;
               }
               _loc3_++;
            }
            _loc2_++;
         }
         _data.unshift([]);
      }
      
      public function hasShifted() : int
      {
         return int(_hasShifted);
      }
      
      public function isOccupied(param1:int, param2:int) : Boolean
      {
         return _data[param1] != null && _data[param1][param2] != null;
      }
      
      public function clear() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         _hasShifted = false;
         _loc1_ = 0;
         while(_loc1_ < _data.length)
         {
            _loc2_ = 0;
            while(_data[_loc1_] != null && _loc2_ < _data[_loc1_].length)
            {
               _data[_loc1_][_loc2_] = null;
               _loc2_++;
            }
            _loc1_++;
         }
      }
      
      public function getElement(param1:int, param2:int) : Object
      {
         if(_data[param1] && _data[param1][param2])
         {
            return _data[param1][param2];
         }
         return null;
      }
      
      public function numRowElements(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_data[param1])
         {
            _loc3_ = 0;
            while(_loc3_ < _data[param1].length)
            {
               if(_data[param1][_loc3_])
               {
                  _loc2_++;
               }
               _loc3_++;
            }
         }
         return _loc2_;
      }
      
      public function rowContainsPropertyValue(param1:int, param2:String, param3:*) : Boolean
      {
         var _loc4_:int = 0;
         if(_data[param1])
         {
            _loc4_ = 0;
            while(_loc4_ < _data[param1].length)
            {
               if(_data[param1][_loc4_] && _data[param1][_loc4_].hasOwnProperty(param2) && _data[param1][_loc4_][param2] == param3)
               {
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
   }
}

