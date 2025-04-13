package org.osmf.elements
{
   import flash.events.Event;
   import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.OSMFStrings;
   
   public class LoadFromDocumentElement extends ProxyElement
   {
      private var _resource:MediaResourceBase;
      
      private var loadTrait:LoadFromDocumentLoadTrait;
      
      private var loader:LoaderBase;
      
      public function LoadFromDocumentElement(param1:MediaResourceBase = null, param2:LoaderBase = null)
      {
         super(null);
         this.loader = param2;
         this.resource = param1;
         if(param2 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
      }
      
      override public function set resource(param1:MediaResourceBase) : void
      {
         if(_resource != param1 && param1 != null)
         {
            _resource = param1;
            loadTrait = new LoadFromDocumentLoadTrait(loader,resource);
            loadTrait.addEventListener("loadStateChange",onLoadStateChange,false,2147483647);
            if(super.getTrait("load") != null)
            {
               super.removeTrait("load");
            }
            super.addTrait("load",loadTrait);
         }
      }
      
      override public function get resource() : MediaResourceBase
      {
         return _resource;
      }
      
      private function onLoaderStateChange(param1:Event) : void
      {
         removeTrait("load");
         proxiedElement = loadTrait.mediaElement;
      }
      
      private function onLoadStateChange(param1:LoadEvent) : void
      {
         var proxiedLoadTrait:LoadTrait;
         var onProxiedElementLoadStateChange:*;
         var event:LoadEvent = param1;
         if(event.loadState == "ready")
         {
            onProxiedElementLoadStateChange = function(param1:LoadEvent):void
            {
               if(param1.loadState == "loading")
               {
                  param1.stopImmediatePropagation();
               }
               else
               {
                  proxiedLoadTrait.removeEventListener("loadStateChange",onProxiedElementLoadStateChange);
               }
            };
            event.stopImmediatePropagation();
            removeTrait("load");
            proxiedLoadTrait = loadTrait.mediaElement.getTrait("load") as LoadTrait;
            proxiedLoadTrait.addEventListener("loadStateChange",onProxiedElementLoadStateChange,false,2147483647);
            proxiedElement = loadTrait.mediaElement;
            if(proxiedLoadTrait.loadState == "uninitialized")
            {
               proxiedLoadTrait.load();
            }
         }
      }
   }
}

