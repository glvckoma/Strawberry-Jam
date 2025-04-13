package org.osmf.metadata
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.MetadataEvent;
   import org.osmf.utils.OSMFStrings;
   
   public class MetadataWatcher
   {
      private var parentMetadata:Metadata;
      
      private var namespaceURL:String;
      
      private var key:String;
      
      private var callback:Function;
      
      private var currentMetadata:Metadata;
      
      private var watching:Boolean;
      
      public function MetadataWatcher(param1:Metadata, param2:String, param3:String, param4:Function)
      {
         super();
         if(param1 == null || param2 == null || param4 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         this.parentMetadata = param1;
         this.namespaceURL = param2;
         this.key = param3;
         this.callback = param4;
      }
      
      public function watch(param1:Boolean = true) : void
      {
         if(watching == false)
         {
            watching = true;
            parentMetadata.addEventListener("valueAdd",onMetadataAdd,false,0,true);
            processWatchedMetadataChange(parentMetadata.getValue(namespaceURL) as Metadata);
            if(param1 == true)
            {
               if(key != null)
               {
                  callback(!!currentMetadata ? currentMetadata.getValue(key) : undefined);
               }
               else
               {
                  callback(!!currentMetadata ? currentMetadata : undefined);
               }
            }
         }
      }
      
      public function unwatch() : void
      {
         if(watching == true)
         {
            processWatchedMetadataChange(null,false);
            parentMetadata.removeEventListener("valueAdd",onMetadataAdd);
            watching = false;
         }
      }
      
      private function processWatchedMetadataChange(param1:Metadata, param2:Boolean = true) : void
      {
         var _loc3_:Metadata = null;
         if(currentMetadata != param1)
         {
            _loc3_ = currentMetadata;
            if(currentMetadata)
            {
               currentMetadata.removeEventListener("valueChange",onValueChange);
               currentMetadata.removeEventListener("valueAdd",onValueAdd);
               currentMetadata.removeEventListener("valueRemove",onValueRemove);
               parentMetadata.removeEventListener("valueRemove",onMetadataRemove);
            }
            else
            {
               parentMetadata.removeEventListener("valueAdd",onMetadataAdd);
            }
            currentMetadata = param1;
            if(param1)
            {
               param1.addEventListener("valueChange",onValueChange,false,0,true);
               param1.addEventListener("valueAdd",onValueAdd,false,0,true);
               param1.addEventListener("valueRemove",onValueRemove,false,0,true);
               parentMetadata.addEventListener("valueRemove",onMetadataRemove);
            }
            else
            {
               parentMetadata.addEventListener("valueAdd",onMetadataAdd);
            }
         }
      }
      
      private function onMetadataAdd(param1:MetadataEvent) : void
      {
         var _loc2_:Metadata = param1.value as Metadata;
         if(_loc2_ && param1.key == namespaceURL)
         {
            processWatchedMetadataChange(_loc2_);
            if(key == null)
            {
               callback(_loc2_);
            }
            else
            {
               callback(_loc2_.getValue(key));
            }
         }
      }
      
      private function onMetadataRemove(param1:MetadataEvent) : void
      {
         var _loc2_:Metadata = param1.value as Metadata;
         if(_loc2_ && param1.key == namespaceURL)
         {
            processWatchedMetadataChange(null);
            callback(undefined);
         }
      }
      
      private function onValueChange(param1:MetadataEvent) : void
      {
         if(key)
         {
            if(key == param1.key)
            {
               callback(param1.value);
            }
         }
         else
         {
            callback(param1.target as Metadata);
         }
      }
      
      private function onValueAdd(param1:MetadataEvent) : void
      {
         if(key)
         {
            if(key == param1.key)
            {
               callback(param1.value);
            }
         }
         else
         {
            callback(param1.target as Metadata);
         }
      }
      
      private function onValueRemove(param1:MetadataEvent) : void
      {
         if(key)
         {
            if(key == param1.key)
            {
               callback(undefined);
            }
         }
         else
         {
            callback(param1.target as Metadata);
         }
      }
   }
}

