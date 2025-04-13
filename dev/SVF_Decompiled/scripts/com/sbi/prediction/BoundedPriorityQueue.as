package com.sbi.prediction
{
   public class BoundedPriorityQueue
   {
      public var maxSize:int;
      
      public var threshold:int;
      
      public var items:Array;
      
      public var priorities:Array;
      
      public function BoundedPriorityQueue(param1:int)
      {
         super();
         this.maxSize = param1;
         threshold = 0;
         items = [];
         priorities = [];
      }
      
      public function add(param1:Object, param2:int) : void
      {
         var _loc5_:* = 0;
         var _loc3_:int = 0;
         var _loc8_:* = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         if(items.length === maxSize)
         {
            if(param2 <= threshold)
            {
               return;
            }
            items.pop();
            priorities.pop();
         }
         if(priorities.length > 60)
         {
            _loc3_ = 0;
            _loc8_ = int(priorities.length);
            while(_loc3_ !== _loc8_)
            {
               _loc6_ = Math.floor((_loc3_ + _loc8_) / 2);
               if(param2 > priorities[_loc6_])
               {
                  _loc8_ = _loc6_;
               }
               else
               {
                  _loc3_ = _loc6_ + 1;
               }
            }
            _loc5_ = _loc3_;
         }
         else
         {
            _loc4_ = int(priorities.length);
            _loc7_ = 0;
            while(_loc7_ < _loc4_)
            {
               if(param2 > priorities[_loc7_])
               {
                  break;
               }
               _loc7_++;
            }
            _loc5_ = _loc7_;
         }
         items.splice(_loc5_,0,param1);
         priorities.splice(_loc5_,0,param2);
         threshold = !!priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
      }
      
      public function remove() : Object
      {
         if(items.length === 0)
         {
            return null;
         }
         priorities.shift();
         threshold = !!priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
         return items.shift();
      }
      
      public function removeItemAt(param1:int) : void
      {
         priorities.splice(param1,1);
         items.splice(param1,1);
         threshold = !!priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
      }
   }
}

