package com.baseoneonline.astar
{
   public interface Graph
   {
      function getNeighbors(param1:int, param2:Vector.<int>) : Vector.<int>;
      
      function distance(param1:int, param2:int) : Number;
      
      function size() : int;
      
      function setStartGridPos(param1:int) : void;
   }
}

