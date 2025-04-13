package com.sbi.prediction
{
   public class LRUCache
   {
      public var dict:SetDictionary = null;
      
      public var list:LinkedList = null;
      
      private var _maxCacheSizeLimit:int = 0;
      
      public function LRUCache(param1:int = 10)
      {
         super();
         dict = new SetDictionary();
         list = new LinkedList();
         _maxCacheSizeLimit = param1;
      }
      
      public function insertInCache(param1:Object) : void
      {
         throw new ReferenceError("Object instance is null");
      }
      
      public function insertKeyInCache(param1:Object, param2:Object) : void
      {
         throw new ReferenceError("Object instance is null");
      }
      
      public function removeCacheElement() : void
      {
         dict.removeKey(list.removeAtEnd().key);
      }
      
      public function getData(param1:Object) : Object
      {
         throw new ReferenceError("Object instance is null");
      }
      
      public function clearCache() : void
      {
         throw new ReferenceError("Object instance is null");
      }
      
      public function getCacheSize() : int
      {
         throw new ReferenceError("Object instance is null");
      }
   }
}

