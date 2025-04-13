package com.sbi.loader
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   
   public class LoaderCacheEntry_Loader extends LoaderCacheEntry_Base
   {
      public function LoaderCacheEntry_Loader(param1:String)
      {
         super(param1);
         _loader = new Loader();
         _loader.contentLoaderInfo.addEventListener("progress",loadProgress,false,0,true);
         _loader.contentLoaderInfo.addEventListener("complete",loadComplete,false,0,true);
         _loader.contentLoaderInfo.addEventListener("ioError",ioError,false,0,true);
      }
      
      override public function destroy() : void
      {
         _loader.contentLoaderInfo.removeEventListener("progress",loadProgress);
         _loader.contentLoaderInfo.removeEventListener("complete",loadComplete);
         _loader.contentLoaderInfo.removeEventListener("ioError",ioError);
         if(_completeCallback != null)
         {
            removeEventListener("OnLoadComplete",_completeCallback);
            _completeCallback = null;
         }
      }
      
      override public function load(param1:String = "binary", param2:Boolean = true) : void
      {
         var _loc3_:URLRequest = null;
         var _loc4_:LoaderContext = null;
         if(!_isLoaded)
         {
            if(LoaderCache.localMode && (_swf.slice(0,7) == "assets/" || _swf.slice(0,6) == "games/" || _swf.indexOf("/") == -1))
            {
               _loc3_ = new URLRequest(_swf);
            }
            else
            {
               _loc3_ = LoaderCache.fetchCDNURLRequest(_swf,"/",param2);
            }
            _loc4_ = new LoaderContext(true,ApplicationDomain.currentDomain);
            _loc4_.allowCodeImport = true;
            if(!LoaderCache.localMode && Capabilities.playerType !== "Desktop")
            {
               _loc4_.securityDomain = SecurityDomain.currentDomain;
            }
            _loader.load(_loc3_,_loc4_);
         }
         else
         {
            onLoadCompleteEvent();
         }
      }
      
      private function loadComplete(param1:Event) : void
      {
         _isLoaded = true;
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _data = _loc2_.content;
         onLoadCompleteEvent();
      }
   }
}

