package com.sbi.corelib
{
   import flash.utils.Dictionary;
   
   public class Set
   {
      private var _set:Dictionary;
      
      private var _size:uint;
      
      public function Set()
      {
         super();
         _set = new Dictionary();
      }
      
      public function add(param1:Object) : Boolean
      {
         if(param1 == null)
         {
            return false;
         }
         if(!contains(param1))
         {
            _set[param1] = true;
            _size++;
            return true;
         }
         return false;
      }
      
      public function addAll(param1:Object) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = false;
         if(param1 != null)
         {
            if(param1 is Set)
            {
               for(_loc2_ in (param1 as Set).dictionary)
               {
                  if(add(_loc2_))
                  {
                     _loc3_ = true;
                  }
               }
            }
            else
            {
               for each(_loc2_ in param1)
               {
                  if(add(_loc2_))
                  {
                     _loc3_ = true;
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function clear() : void
      {
         if(!isEmpty())
         {
            for(var _loc1_ in _set)
            {
               delete _set[_loc1_];
            }
            _size = 0;
         }
      }
      
      public function contains(param1:Object) : Boolean
      {
         return param1 != null && _set[param1] != null;
      }
      
      public function containsAll(param1:Object) : Boolean
      {
         if(param1 == null || isEmpty())
         {
            return false;
         }
         if(param1 is Set)
         {
            for(var _loc2_ in (param1 as Set).dictionary)
            {
               if(!contains(_loc2_))
               {
                  return false;
               }
            }
         }
         else
         {
            for each(_loc2_ in param1)
            {
               if(!contains(_loc2_))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function isEmpty() : Boolean
      {
         return _size == 0;
      }
      
      public function remove(param1:Object) : Object
      {
         var _loc2_:Boolean = contains(param1);
         if(_loc2_)
         {
            delete _set[param1];
            _size--;
         }
         return _loc2_;
      }
      
      public function removeAll(param1:Object) : Boolean
      {
         if(param1 == null || isEmpty())
         {
            return false;
         }
         var _loc3_:Boolean = false;
         if(param1 is Set)
         {
            for(var _loc2_ in (param1 as Set).dictionary)
            {
               if(remove(_loc2_))
               {
                  _loc3_ = true;
               }
            }
         }
         else
         {
            for each(_loc2_ in param1)
            {
               if(remove(_loc2_))
               {
                  _loc3_ = true;
               }
            }
         }
         return _loc3_;
      }
      
      public function retainAll(param1:Object) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:Set = null;
         if(param1 == null || isEmpty())
         {
            return false;
         }
         var _loc4_:Boolean = false;
         if(param1 is Set)
         {
            _loc3_ = param1 as Set;
            if(_loc3_.isEmpty())
            {
               clear();
               _loc4_ = true;
            }
            else
            {
               for(_loc2_ in _set)
               {
                  if(!_loc3_.contains(_loc2_))
                  {
                     remove(_loc2_);
                     _loc4_ = true;
                  }
               }
            }
         }
         else if(param1.length == 0)
         {
            clear();
            _loc4_ = true;
         }
         else
         {
            for(_loc2_ in _set)
            {
               if(param1.indexOf(_loc2_) == -1)
               {
                  remove(_loc2_);
                  _loc4_ = true;
               }
            }
         }
         return _loc4_;
      }
      
      public function size() : uint
      {
         return _size;
      }
      
      public function toArray() : Array
      {
         var _loc2_:Array = [];
         for(var _loc1_ in _set)
         {
            _loc2_.push(_loc1_);
         }
         return _loc2_;
      }
      
      public function get dictionary() : Dictionary
      {
         return _set;
      }
   }
}

