package loader
{
   import com.sbi.loader.FileServerEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.system.LoaderContext;
   import localization.LocalizationManager;
   
   public class MediaHelper
   {
      private var _id:uint;
      
      private var _callback:Function;
      
      private var _passback:Object;
      
      private var _loader:Loader;
      
      private var _loadProgressFunc:Function;
      
      private var _mc:MovieClip;
      
      public function MediaHelper()
      {
         super();
      }
      
      public function init(param1:uint, param2:Function = null, param3:Object = null, param4:Function = null) : void
      {
         if(param1 == 0)
         {
            return;
         }
         _id = param1;
         _callback = param2;
         _passback = param3;
         _loadProgressFunc = param4;
         _loader = new Loader();
         MediaFileServer.instance.addEventListener("OnNewData",handleMediaData);
         MediaFileServer.instance.addEventListener("progress",onLoadProgress);
         MediaFileServer.instance.requestFile(_id);
      }
      
      public function destroy() : void
      {
         MediaFileServer.instance.removeEventListener("OnNewData",handleMediaData);
         _mc = null;
         _passback = null;
         _loader = null;
         _callback = null;
         _loadProgressFunc = null;
      }
      
      public function get id() : int
      {
         if(_loader == null)
         {
            throw new Error("attempt to get id of an uninitialized MediaHelper instance!");
         }
         return _id;
      }
      
      private function handleMediaData(param1:FileServerEvent) : void
      {
         var _loc2_:LoaderContext = null;
         if(param1.id != _id)
         {
            return;
         }
         if(param1.success)
         {
            MediaFileServer.instance.removeEventListener("OnNewData",handleMediaData);
            _loader.contentLoaderInfo.addEventListener("complete",onBytesLoaded);
            _loader.contentLoaderInfo.addEventListener("progress",onLoadProgress);
            _loc2_ = new LoaderContext();
            _loc2_.allowCodeImport = true;
            _loader.loadBytes(param1.data,_loc2_);
         }
      }
      
      private function onLoadProgress(param1:ProgressEvent) : void
      {
         if(_loadProgressFunc != null)
         {
            _loadProgressFunc(param1);
         }
      }
      
      private function onBytesLoaded(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _mc = MovieClip(_loc2_.content);
         LocalizationManager.findAllTextfields(_mc);
         if(_passback != null)
         {
            _mc.mediaHelper = this;
            _mc.passback = _passback;
         }
         param1.target.removeEventListener("complete",onBytesLoaded);
         param1.target.removeEventListener("OnLoadProgress",onLoadProgress);
         _loadProgressFunc = null;
         if(_mc.hasOwnProperty("__rslPreloader") && _mc.__rslPreloader)
         {
            _mc.addEventListener("enterFrame",onFrame);
         }
         else if(_callback != null)
         {
            _callback(_mc);
            _callback = null;
         }
      }
      
      private function onFrame(param1:Event) : void
      {
         if(_mc.__rslPreloader == null)
         {
            _mc.removeEventListener("enterFrame",onFrame);
            if(_callback != null)
            {
               _callback(_mc);
               _callback = null;
            }
         }
      }
   }
}

