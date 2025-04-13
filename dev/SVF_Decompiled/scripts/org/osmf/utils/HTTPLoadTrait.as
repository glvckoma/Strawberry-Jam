package org.osmf.utils
{
   import flash.net.URLLoader;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class HTTPLoadTrait extends LoadTrait
   {
      private var _urlLoader:URLLoader;
      
      public function HTTPLoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super(param1,param2);
      }
      
      public function get urlLoader() : URLLoader
      {
         return _urlLoader;
      }
      
      public function set urlLoader(param1:URLLoader) : void
      {
         _urlLoader = param1;
      }
   }
}

