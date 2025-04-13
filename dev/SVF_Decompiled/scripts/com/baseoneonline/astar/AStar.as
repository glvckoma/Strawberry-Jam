package com.baseoneonline.astar
{
   import flash.utils.Dictionary;
   
   public class AStar
   {
      private var graph:Graph;
      
      private var g:Vector.<Number>;
      
      private var h:Vector.<Number>;
      
      private var f:Vector.<Number>;
      
      private var parent:Vector.<int>;
      
      private var open:Vector.<int>;
      
      private var closed:Vector.<int>;
      
      private var closedDict:Dictionary;
      
      private var goalReached:Boolean = false;
      
      public function AStar(param1:Graph = null)
      {
         super();
         if(param1)
         {
            setGraph(param1);
         }
      }
      
      public function setGraph(param1:Graph) : void
      {
         this.graph = param1;
         updateGraph();
      }
      
      private function updateGraph() : void
      {
         var _loc1_:int = graph.size();
         g = new Vector.<Number>(_loc1_,true);
         h = new Vector.<Number>(_loc1_,true);
         f = new Vector.<Number>(_loc1_,true);
         parent = new Vector.<int>(_loc1_,true);
      }
      
      public function solve(param1:int, param2:int) : Vector.<int>
      {
         var _loc8_:Number = NaN;
         var _loc12_:* = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc3_:Number = NaN;
         var _loc11_:Vector.<int> = new Vector.<int>();
         goalReached = false;
         open = new Vector.<int>();
         closed = new Vector.<int>();
         closedDict = new Dictionary(true);
         open.push(param1);
         g[param1] = 0;
         h[param1] = graph.distance(param1,param2);
         f[param1] = h[param1];
         parent[param1] = -1;
         graph.setStartGridPos(param1);
         while(open.length > 0)
         {
            _loc8_ = Infinity;
            _loc12_ = -1;
            _loc5_ = 0;
            while(_loc5_ < open.length)
            {
               _loc4_ = open[_loc5_];
               if(f[_loc4_] < _loc8_)
               {
                  _loc8_ = f[_loc4_];
                  _loc12_ = _loc4_;
               }
               _loc5_++;
            }
            if(_loc12_ == param2)
            {
               goalReached = true;
               return createPath(param2,param1);
            }
            open.splice(open.indexOf(_loc12_),1);
            closed.push(_loc12_);
            closedDict[_loc12_] = 1;
            for each(var _loc13_ in graph.getNeighbors(_loc12_,_loc11_))
            {
               if(closedDict[_loc13_] != 1)
               {
                  _loc9_ = g[_loc12_] + graph.distance(_loc12_,_loc13_);
                  _loc7_ = false;
                  if(open.indexOf(_loc13_) == -1)
                  {
                     open.push(_loc13_);
                     _loc7_ = true;
                  }
                  else if(_loc9_ < g[_loc13_])
                  {
                     _loc7_ = true;
                  }
                  if(_loc7_)
                  {
                     parent[_loc13_] = _loc12_;
                     g[_loc13_] = _loc9_;
                     h[_loc13_] = graph.distance(_loc13_,param2);
                     f[_loc13_] = g[_loc13_] + h[_loc13_];
                  }
               }
            }
         }
         var _loc10_:* = Infinity;
         var _loc14_:* = -1;
         for each(var _loc6_ in closed)
         {
            _loc3_ = h[_loc6_];
            if(_loc3_ < _loc10_)
            {
               _loc10_ = _loc3_;
               _loc14_ = _loc6_;
            }
         }
         return createPath(_loc14_,param1);
      }
      
      public function hasReachedGoal() : Boolean
      {
         return goalReached;
      }
      
      private function createPath(param1:int, param2:int) : Vector.<int>
      {
         var _loc3_:Vector.<int> = new Vector.<int>();
         while(parent[param1] != -1)
         {
            _loc3_.push(param1);
            param1 = parent[param1];
         }
         _loc3_.push(param2);
         return _loc3_.reverse();
      }
   }
}

