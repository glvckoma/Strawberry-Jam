package com.sbi.loader
{
   import flash.display.Loader;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   
   public class LoaderCacheEntry_Base extends EventDispatcher
   {
      protected var _parent:LoaderCache;
      
      protected var _loader:*;
      
      protected var _swf:String;
      
      protected var _isLoaded:Boolean;
      
      protected var _completeCallback:Function;
      
      protected var _data:Object;
      
      protected var _id:*;
      
      protected var _contentType:int;
      
      private var _percent:Number;
      
      private var _err:String;
      
      private var _progressCallback:Function;
      
      public function LoaderCacheEntry_Base(param1:String)
      {
         super();
         _swf = param1;
      }
      
      public function set parent(param1:LoaderCache) : void
      {
         _parent = param1;
      }
      
      public function set id(param1:*) : void
      {
         _id = param1;
      }
      
      public function get id() : *
      {
         return _id;
      }
      
      public function set contentType(param1:int) : void
      {
         _contentType = param1;
      }
      
      public function get contentType() : int
      {
         return _contentType;
      }
      
      public function get name() : String
      {
         return _swf;
      }
      
      public function destroy() : void
      {
      }
      
      public function load(param1:String = "binary", param2:Boolean = true) : void
      {
      }
      
      public function setCompleteCallback(param1:Function) : void
      {
         if(_completeCallback != param1)
         {
            if(_completeCallback != null)
            {
               removeEventListener("OnLoadComplete",_completeCallback);
            }
            addEventListener("OnLoadComplete",param1,false,0,true);
            _completeCallback = param1;
         }
      }
      
      public function setProgressCallback(param1:Function) : void
      {
         if(_progressCallback != param1)
         {
            if(_progressCallback != null)
            {
               removeEventListener("OnLoadProgress",_progressCallback);
            }
            addEventListener("OnLoadProgress",param1,false,0,true);
            _progressCallback = param1;
         }
      }
      
      public function get progress() : Number
      {
         return _percent;
      }
      
      public function get loader() : Loader
      {
         return _loader;
      }
      
      public function get data() : Object
      {
         return _data;
      }
      
      protected function onLoadCompleteEvent() : void
      {
         var _loc1_:LoaderEvent = new LoaderEvent("OnLoadComplete");
         _loc1_.status = true;
         _loc1_.entry = this;
         dispatchEvent(_loc1_);
         if(_parent)
         {
            _parent.remove(_swf);
         }
      }
      
      protected function onLoadProgressEvent() : void
      {
         var _loc1_:LoaderEvent = new LoaderEvent("OnLoadProgress");
         _loc1_.status = true;
         _loc1_.entry = this;
         _loc1_.percent = _percent;
         dispatchEvent(_loc1_);
      }
      
      protected function loadProgress(param1:ProgressEvent) : void
      {
         _percent = param1.bytesLoaded / param1.bytesTotal;
         _percent *= 100;
         onLoadProgressEvent();
      }
      
      protected function ioError(param1:IOErrorEvent) : void
      {
         var _loc2_:LoaderEvent = new LoaderEvent("OnLoadComplete");
         _loc2_.status = false;
         _loc2_.entry = this;
         _loc2_.message = param1.text;
         dispatchEvent(_loc2_);
         if(_parent)
         {
            _parent.remove(_swf);
         }
      }
   }
}

