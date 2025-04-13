package org.osmf.media
{
   import org.osmf.events.LoadEvent;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class LoadableElementBase extends MediaElement
   {
      private var _loader:LoaderBase;
      
      public function LoadableElementBase(param1:MediaResourceBase = null, param2:LoaderBase = null)
      {
         super();
         _loader = param2;
         this.resource = param1;
      }
      
      override public function set resource(param1:MediaResourceBase) : void
      {
         super.resource = param1;
         updateLoadTrait();
      }
      
      final protected function get loader() : LoaderBase
      {
         return _loader;
      }
      
      final protected function set loader(param1:LoaderBase) : void
      {
         _loader = param1;
      }
      
      protected function createLoadTrait(param1:MediaResourceBase, param2:LoaderBase) : LoadTrait
      {
         return new LoadTrait(_loader,param1);
      }
      
      protected function processLoadingState() : void
      {
      }
      
      protected function processReadyState() : void
      {
      }
      
      protected function processUnloadingState() : void
      {
      }
      
      protected function getLoaderForResource(param1:MediaResourceBase, param2:Vector.<LoaderBase>) : LoaderBase
      {
         var _loc5_:Boolean = false;
         var _loc3_:* = loader;
         if(param1 != null && (loader == null || loader.canHandleResource(param1) == false))
         {
            _loc5_ = false;
            for each(var _loc4_ in param2)
            {
               if(loader == null || loader != _loc4_)
               {
                  if(_loc4_.canHandleResource(param1))
                  {
                     _loc3_ = _loc4_;
                     break;
                  }
               }
            }
            if(_loc3_ == null && param2 != null)
            {
               _loc3_ = param2[param2.length - 1];
            }
         }
         return _loc3_;
      }
      
      private function onLoadStateChange(param1:LoadEvent) : void
      {
         if(param1.loadState == "loading")
         {
            processLoadingState();
         }
         else if(param1.loadState == "ready")
         {
            processReadyState();
         }
         else if(param1.loadState == "unloading")
         {
            processUnloadingState();
         }
      }
      
      private function updateLoadTrait() : void
      {
         var _loc1_:LoadTrait = getTrait("load") as LoadTrait;
         if(_loc1_ != null)
         {
            if(_loc1_.loadState == "ready")
            {
               _loc1_.unload();
            }
            _loc1_.removeEventListener("loadStateChange",onLoadStateChange);
            removeTrait("load");
         }
         if(loader != null)
         {
            _loc1_ = createLoadTrait(resource,loader);
            _loc1_.addEventListener("loadStateChange",onLoadStateChange,false,10);
            addTrait("load",_loc1_);
         }
      }
   }
}

