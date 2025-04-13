package com.sbi.loader
{
   import flash.events.EventDispatcher;
   
   public class BaseFileServer extends EventDispatcher
   {
      private var _contentPath:String;
      
      private var _loaderArray:Array;
      
      private var _cacheArray:Array;
      
      private var _loadProgressFunc:Function;
      
      public function BaseFileServer(param1:String)
      {
         super();
         _contentPath = param1;
         _loaderArray = [];
         _cacheArray = [];
      }
      
      public function updatePath(param1:String) : void
      {
         _contentPath = param1;
      }
      
      public function clearFromCache(param1:String, param2:Object) : void
      {
         if(_cacheArray[param1])
         {
            if(_cacheArray[param1][param2])
            {
               delete _cacheArray[param1][param2];
            }
         }
         if(_loaderArray[param1])
         {
            if(_loaderArray[param1][param2])
            {
               delete _loaderArray[param1][param2];
            }
         }
      }
      
      public function requestFile(param1:Object, param2:Boolean = false, param3:int = 0, param4:Boolean = true, param5:Function = null) : void
      {
         var _loc6_:LoaderCacheEntry_URL = null;
         if(param2 || getFromCache(param1) == false)
         {
            if(!(!!_loaderArray[_contentPath] ? _loaderArray[_contentPath][param1] : false))
            {
               _loc6_ = new LoaderCacheEntry_URL(_contentPath + param1,false);
               _loc6_.id = param1;
               _loc6_.contentType = param3;
               _loc6_.addEventListener("OnLoadComplete",onResultGetData);
               _loadProgressFunc = param5;
               if(_loadProgressFunc != null)
               {
                  _loc6_.addEventListener("OnLoadProgress",_loadProgressFunc);
               }
               _loc6_.load("binary",param4);
               if(_loaderArray[_contentPath] == null)
               {
                  _loaderArray[_contentPath] = [];
               }
               _loaderArray[_contentPath][param1] = {
                  "l":_loc6_,
                  "c":1
               };
            }
            else
            {
               _loaderArray[_contentPath][param1].c++;
            }
         }
      }
      
      public function requestFiles(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            requestFile(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function getFromCache(param1:Object) : Boolean
      {
         var _loc2_:Object = searchCache(param1);
         if(_loc2_)
         {
            newEvent(_loc2_.id,_loc2_.data,true,_loc2_.contentType);
         }
         return _loc2_ == null ? false : true;
      }
      
      private function searchCache(param1:Object) : Object
      {
         return !!_cacheArray[_contentPath] ? _cacheArray[_contentPath][param1] : null;
      }
      
      private function onResultGetData(param1:LoaderEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:FileServerEvent = new FileServerEvent("OnNewData");
         _loc3_.id = param1.entry.id;
         _loc3_.contentType = param1.entry.contentType;
         var _loc5_:Object = param1.entry.data;
         if(_loc5_ == null)
         {
            _loc3_.success = false;
         }
         else
         {
            _loc3_.data = _loc5_;
            if(_cacheArray[_contentPath] == null)
            {
               _cacheArray[_contentPath] = [];
            }
            _cacheArray[_contentPath][_loc3_.id] = {
               "id":_loc3_.id,
               "data":_loc5_,
               "contentType":_loc3_.contentType
            };
         }
         var _loc4_:Object = _loaderArray[_contentPath][_loc3_.id];
         if(_loc4_)
         {
            _loc4_.l.removeEventListener("OnLoadComplete",onResultGetData);
            if(_loadProgressFunc != null)
            {
               _loc4_.l.removeEventListener("OnLoadProgress",_loadProgressFunc);
            }
            _loc2_ = int(_loc4_.c);
            _loaderArray[_contentPath][_loc3_.id] = null;
            while(_loc2_-- > 0)
            {
               newEvent(_loc3_.id,_loc3_.data,_loc3_.success,_loc3_.contentType);
            }
         }
      }
      
      private function newEvent(param1:Object, param2:*, param3:Boolean, param4:int = 0) : void
      {
         var _loc5_:FileServerEvent = new FileServerEvent("OnNewData");
         _loc5_.id = param1;
         _loc5_.data = param2;
         _loc5_.success = param3;
         _loc5_.contentType = param4;
         dispatchEvent(_loc5_);
      }
   }
}

class SingletonLock
{
   public function SingletonLock()
   {
      super();
   }
}
