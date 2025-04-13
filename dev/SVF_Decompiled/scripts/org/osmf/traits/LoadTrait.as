package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.LoaderEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.utils.OSMFStrings;
   
   public class LoadTrait extends MediaTraitBase
   {
      private var loader:LoaderBase;
      
      private var _resource:MediaResourceBase;
      
      private var _loadState:String;
      
      private var _bytesLoaded:Number;
      
      private var _bytesTotal:Number;
      
      public function LoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super("load");
         this.loader = param1;
         _resource = param2;
         _loadState = "uninitialized";
         if(param1 != null)
         {
            param1.addEventListener("loadStateChange",onLoadStateChange,false,2147483647,true);
         }
      }
      
      public function get resource() : MediaResourceBase
      {
         return _resource;
      }
      
      public function get loadState() : String
      {
         return _loadState;
      }
      
      public function load() : void
      {
         if(loader)
         {
            if(_loadState == "ready")
            {
               throw new IllegalOperationError(OSMFStrings.getString("alreadyReady"));
            }
            if(_loadState == "loading")
            {
               throw new IllegalOperationError(OSMFStrings.getString("alreadyLoading"));
            }
            loader.load(this);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString("mustSetLoader"));
      }
      
      public function unload() : void
      {
         if(loader)
         {
            if(_loadState == "unloading")
            {
               throw new IllegalOperationError(OSMFStrings.getString("alreadyUnloading"));
            }
            if(_loadState == "uninitialized")
            {
               throw new IllegalOperationError(OSMFStrings.getString("alreadyUnloaded"));
            }
            loader.unload(this);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString("mustSetLoader"));
      }
      
      public function get bytesLoaded() : Number
      {
         return _bytesLoaded;
      }
      
      public function get bytesTotal() : Number
      {
         return _bytesTotal;
      }
      
      final protected function setLoadState(param1:String) : void
      {
         if(_loadState != param1)
         {
            loadStateChangeStart(param1);
            _loadState = param1;
            loadStateChangeEnd();
         }
      }
      
      final protected function setBytesLoaded(param1:Number) : void
      {
         if(isNaN(param1) || param1 > bytesTotal || param1 < 0)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         if(param1 != _bytesLoaded)
         {
            bytesLoadedChangeStart(param1);
            _bytesLoaded = param1;
            bytesLoadedChangeEnd();
         }
      }
      
      final protected function setBytesTotal(param1:Number) : void
      {
         if(param1 < _bytesLoaded || param1 < 0)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         if(param1 != _bytesTotal)
         {
            bytesTotalChangeStart(param1);
            _bytesTotal = param1;
            bytesTotalChangeEnd();
         }
      }
      
      protected function bytesLoadedChangeStart(param1:Number) : void
      {
      }
      
      protected function bytesLoadedChangeEnd() : void
      {
      }
      
      protected function bytesTotalChangeStart(param1:Number) : void
      {
      }
      
      protected function bytesTotalChangeEnd() : void
      {
         dispatchEvent(new LoadEvent("bytesTotalChange",false,false,null,_bytesTotal));
      }
      
      protected function loadStateChangeStart(param1:String) : void
      {
      }
      
      protected function loadStateChangeEnd() : void
      {
         dispatchEvent(new LoadEvent("loadStateChange",false,false,_loadState));
      }
      
      private function onLoadStateChange(param1:LoaderEvent) : void
      {
         if(param1.loadTrait == this)
         {
            setLoadState(param1.newState);
         }
      }
   }
}

