package org.osmf.elements.loaderClasses
{
   import flash.display.Loader;
   import flash.events.ProgressEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class LoaderLoadTrait extends LoadTrait
   {
      private var _loader:Loader;
      
      public function LoaderLoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super(param1,param2);
      }
      
      public function get loader() : Loader
      {
         return _loader;
      }
      
      public function set loader(param1:Loader) : void
      {
         _loader = param1;
      }
      
      override protected function loadStateChangeStart(param1:String) : void
      {
         if(param1 == "loading")
         {
            loader.contentLoaderInfo.addEventListener("progress",onContentLoadProgress,false,0,true);
         }
         else if(param1 == "ready")
         {
            setBytesTotal(loader.contentLoaderInfo.bytesTotal);
            setBytesLoaded(loader.contentLoaderInfo.bytesLoaded);
            loader.contentLoaderInfo.addEventListener("progress",onContentLoadProgress,false,0,true);
         }
         else if(param1 == "uninitialized")
         {
            setBytesLoaded(0);
         }
      }
      
      private function onContentLoadProgress(param1:ProgressEvent) : void
      {
         setBytesTotal(param1.bytesTotal);
         setBytesLoaded(param1.bytesLoaded);
      }
   }
}

