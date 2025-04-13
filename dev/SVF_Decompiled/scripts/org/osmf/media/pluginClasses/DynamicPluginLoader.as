package org.osmf.media.pluginClasses
{
   import flash.display.DisplayObject;
   import org.osmf.elements.SWFLoader;
   import org.osmf.elements.loaderClasses.LoaderLoadTrait;
   import org.osmf.events.LoaderEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfo;
   import org.osmf.traits.LoadTrait;
   
   internal class DynamicPluginLoader extends PluginLoader
   {
      private static const PLUGININFO_PROPERTY_NAME:String = "pluginInfo";
      
      public function DynamicPluginLoader(param1:MediaFactory, param2:String)
      {
         super(param1,param2);
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         return new SWFLoader().canHandleResource(param1);
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         var swfLoader:SWFLoader;
         var loaderLoadTrait:LoaderLoadTrait;
         var loadTrait:LoadTrait = param1;
         var onSWFLoaderStateChange:* = function(param1:LoaderEvent):void
         {
            var _loc2_:DisplayObject = null;
            var _loc3_:PluginInfo = null;
            if(param1.newState == "ready")
            {
               swfLoader.removeEventListener("loadStateChange",onSWFLoaderStateChange);
               loaderLoadTrait.removeEventListener("mediaError",onLoadError);
               _loc2_ = loaderLoadTrait.loader.content;
               _loc3_ = _loc2_["pluginInfo"] as PluginInfo;
               loadFromPluginInfo(loadTrait,_loc3_,loaderLoadTrait.loader);
            }
            else if(param1.newState == "loadError")
            {
               swfLoader.removeEventListener("loadStateChange",onSWFLoaderStateChange);
               updateLoadTrait(loadTrait,param1.newState);
            }
         };
         var onLoadError:* = function(param1:MediaErrorEvent):void
         {
            loaderLoadTrait.removeEventListener("mediaError",onLoadError);
            loadTrait.dispatchEvent(param1.clone());
         };
         updateLoadTrait(loadTrait,"loading");
         swfLoader = new SWFLoader(true);
         swfLoader.validateLoadedContentFunction = validateLoadedContent;
         swfLoader.addEventListener("loadStateChange",onSWFLoaderStateChange);
         loaderLoadTrait = new LoaderLoadTrait(swfLoader,loadTrait.resource);
         loaderLoadTrait.addEventListener("mediaError",onLoadError);
         swfLoader.load(loaderLoadTrait);
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,"unloading");
         var _loc2_:PluginLoadTrait = param1 as PluginLoadTrait;
         unloadFromPluginInfo(_loc2_.pluginInfo);
         _loc2_.loader.unloadAndStop();
         updateLoadTrait(param1,"uninitialized");
      }
      
      private function validateLoadedContent(param1:DisplayObject) : Boolean
      {
         var _loc2_:Object = !!param1.hasOwnProperty("pluginInfo") ? param1["pluginInfo"] : null;
         return _loc2_ != null ? isPluginCompatible(_loc2_) : false;
      }
   }
}

