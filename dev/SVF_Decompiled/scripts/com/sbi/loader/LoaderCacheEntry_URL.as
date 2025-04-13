package com.sbi.loader
{
   import com.sbi.debug.DebugUtility;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class LoaderCacheEntry_URL extends LoaderCacheEntry_Base
   {
      private var _isObj:Boolean;
      
      public function LoaderCacheEntry_URL(param1:String, param2:Boolean = true)
      {
         super(param1);
         _isObj = param2;
         _loader = new URLLoader();
         _loader.addEventListener("progress",loadProgress,false,0,true);
         _loader.addEventListener("complete",loadComplete,false,0,true);
         _loader.addEventListener("ioError",ioError,false,0,true);
      }
      
      override public function destroy() : void
      {
         _loader.removeEventListener("progress",loadProgress);
         _loader.removeEventListener("complete",loadComplete);
         _loader.removeEventListener("ioError",ioError);
         if(_completeCallback != null)
         {
            removeEventListener("OnLoadComplete",_completeCallback);
            _completeCallback = null;
         }
      }
      
      override public function load(param1:String = "binary", param2:Boolean = true) : void
      {
         var _loc3_:URLRequest = null;
         if(!_isLoaded)
         {
            _loc3_ = LoaderCache.fetchCDNURLRequest(_swf,"/",param2);
            _loader.dataFormat = param1;
            DebugUtility.debugTrace("LoaderCacheEntry_URL - URLLoader.load being called for cdnURL:" + _loc3_.url + " dataFormat:" + param1);
            _loader.load(_loc3_);
         }
         else
         {
            onLoadCompleteEvent();
         }
      }
      
      private function loadComplete(param1:Event) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:Object = null;
         _isLoaded = true;
         _data = _loader.data;
         if(_data is ByteArray)
         {
            _loc2_ = _loader.data as ByteArray;
            try
            {
               _loc2_.uncompress();
            }
            catch(err:Error)
            {
            }
            _loc2_.position = 0;
            if(_isObj)
            {
               _loc3_ = _loc2_.readObject();
               if(_loc2_.bytesAvailable == 0)
               {
                  _data = _loc3_;
               }
               else
               {
                  _loc2_.position = 0;
                  _data = _loc2_;
               }
            }
            else
            {
               _data = _loc2_;
            }
         }
         onLoadCompleteEvent();
      }
   }
}

