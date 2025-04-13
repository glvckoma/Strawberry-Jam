package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import org.osmf.events.LoaderEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.utils.OSMFStrings;
   
   public class LoaderBase extends EventDispatcher
   {
      public function LoaderBase()
      {
         super();
      }
      
      public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         return false;
      }
      
      final public function load(param1:LoadTrait) : void
      {
         validateLoad(param1);
         executeLoad(param1);
      }
      
      final public function unload(param1:LoadTrait) : void
      {
         validateUnload(param1);
         executeUnload(param1);
      }
      
      protected function executeLoad(param1:LoadTrait) : void
      {
      }
      
      protected function executeUnload(param1:LoadTrait) : void
      {
      }
      
      final protected function updateLoadTrait(param1:LoadTrait, param2:String) : void
      {
         var _loc3_:String = null;
         if(param2 != param1.loadState)
         {
            _loc3_ = param1.loadState;
            dispatchEvent(new LoaderEvent("loadStateChange",false,false,this,param1,_loc3_,param2));
         }
      }
      
      private function validateLoad(param1:LoadTrait) : void
      {
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         if(param1.loadState == "ready")
         {
            throw new IllegalOperationError(OSMFStrings.getString("alreadyReady"));
         }
         if(param1.loadState == "loading")
         {
            throw new IllegalOperationError(OSMFStrings.getString("alreadyLoading"));
         }
         if(canHandleResource(param1.resource) == false)
         {
            throw new IllegalOperationError(OSMFStrings.getString("loaderCantHandleResource"));
         }
      }
      
      private function validateUnload(param1:LoadTrait) : void
      {
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         if(param1.loadState == "unloading")
         {
            throw new IllegalOperationError(OSMFStrings.getString("alreadyUnloading"));
         }
         if(param1.loadState == "uninitialized")
         {
            throw new IllegalOperationError(OSMFStrings.getString("alreadyUnloaded"));
         }
         if(canHandleResource(param1.resource) == false)
         {
            throw new IllegalOperationError(OSMFStrings.getString("loaderCantHandleResource"));
         }
      }
   }
}

