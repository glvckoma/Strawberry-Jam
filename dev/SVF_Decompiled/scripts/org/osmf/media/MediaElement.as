package org.osmf.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.containers.IMediaContainer;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.Metadata;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaElement extends EventDispatcher
   {
      private var traits:Dictionary = new Dictionary();
      
      private var traitResolvers:Dictionary = new Dictionary();
      
      private var unresolvedTraits:Dictionary = new Dictionary();
      
      private var _traitTypes:Vector.<String> = new Vector.<String>();
      
      private var _resource:MediaResourceBase;
      
      private var _metadata:Metadata;
      
      private var _container:IMediaContainer;
      
      public function MediaElement()
      {
         super();
         _metadata = createMetadata();
         _metadata.addEventListener("valueAdd",onMetadataValueAdd);
         _metadata.addEventListener("valueRemove",onMetadataValueRemove);
         _metadata.addEventListener("valueChange",onMetadataValueChange);
         setupTraitResolvers();
         setupTraits();
         addEventListener("containerChange",onContainerChange,false,1.7976931348623157e+308);
      }
      
      public function get traitTypes() : Vector.<String>
      {
         return _traitTypes.concat();
      }
      
      public function hasTrait(param1:String) : Boolean
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         return traits[param1] != null;
      }
      
      public function getTrait(param1:String) : MediaTraitBase
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         return traits[param1];
      }
      
      public function get resource() : MediaResourceBase
      {
         return _resource;
      }
      
      public function set resource(param1:MediaResourceBase) : void
      {
         _resource = param1;
      }
      
      public function get container() : IMediaContainer
      {
         return _container;
      }
      
      public function addMetadata(param1:String, param2:Metadata) : void
      {
         if(param1 == null || param2 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         this.metadata.addValue(param1,param2);
      }
      
      public function removeMetadata(param1:String) : Metadata
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         return metadata.removeValue(param1) as Metadata;
      }
      
      public function getMetadata(param1:String) : Metadata
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         return metadata.getValue(param1) as Metadata;
      }
      
      public function get metadataNamespaceURLs() : Vector.<String>
      {
         return metadata.keys;
      }
      
      protected function createMetadata() : Metadata
      {
         return new Metadata();
      }
      
      public function get metadata() : Metadata
      {
         return _metadata;
      }
      
      protected function addTrait(param1:String, param2:MediaTraitBase) : void
      {
         if(param1 == null || param2 == null || param1 != param2.traitType)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc3_:MediaTraitResolver = traitResolvers[param1];
         if(_loc3_ != null)
         {
            _loc3_.addTrait(param2);
         }
         else
         {
            setLocalTrait(param1,param2);
         }
      }
      
      protected function removeTrait(param1:String) : MediaTraitBase
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc3_:MediaTraitBase = traits[param1];
         var _loc2_:MediaTraitResolver = traitResolvers[param1];
         if(_loc2_ != null)
         {
            return _loc2_.removeTrait(_loc3_);
         }
         return setLocalTrait(param1,null);
      }
      
      final protected function addTraitResolver(param1:String, param2:MediaTraitResolver) : void
      {
         var _loc3_:MediaTraitBase = null;
         if(param2 == null || param2.type != param1)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         if(traitResolvers[param1] == null)
         {
            unresolvedTraits[param1] = traits[param1];
            traitResolvers[param1] = param2;
            _loc3_ = traits[param1];
            if(_loc3_)
            {
               param2.addTrait(_loc3_);
            }
            processResolvedTraitChange(param1,param2.resolvedTrait);
            param2.addEventListener("change",onTraitResolverChange);
            return;
         }
         throw new ArgumentError(OSMFStrings.getString("traitResolverAlreadyAdded"));
      }
      
      final protected function removeTraitResolver(param1:String) : MediaTraitResolver
      {
         if(param1 == null || traitResolvers[param1] == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc2_:MediaTraitResolver = traitResolvers[param1];
         _loc2_.removeEventListener("change",onTraitResolverChange);
         delete traitResolvers[param1];
         var _loc3_:MediaTraitBase = unresolvedTraits[param1];
         if(_loc3_ != traits[param1])
         {
            setLocalTrait(param1,_loc3_);
         }
         delete unresolvedTraits[param1];
         return _loc2_;
      }
      
      final protected function getTraitResolver(param1:String) : MediaTraitResolver
      {
         return traitResolvers[param1];
      }
      
      protected function setupTraitResolvers() : void
      {
      }
      
      protected function setupTraits() : void
      {
      }
      
      private function onMediaError(param1:MediaErrorEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function setLocalTrait(param1:String, param2:MediaTraitBase) : MediaTraitBase
      {
         var _loc3_:* = traits[param1];
         if(param2 == null)
         {
            if(_loc3_ != null)
            {
               _loc3_.removeEventListener("mediaError",onMediaError);
               _loc3_.dispose();
               dispatchEvent(new MediaElementEvent("traitRemove",false,false,param1));
               _traitTypes.splice(_traitTypes.indexOf(param1),1);
               delete traits[param1];
            }
         }
         else if(_loc3_ == null)
         {
            traits[param1] = _loc3_ = param2;
            _traitTypes.push(param1);
            _loc3_.addEventListener("mediaError",onMediaError);
            dispatchEvent(new MediaElementEvent("traitAdd",false,false,param1));
         }
         else if(_loc3_ != param2)
         {
            throw new ArgumentError(OSMFStrings.getString("traitInstanceAlreadyAdded"));
         }
         return _loc3_;
      }
      
      private function onTraitResolverChange(param1:Event) : void
      {
         var _loc2_:MediaTraitResolver = param1.target as MediaTraitResolver;
         processResolvedTraitChange(_loc2_.type,_loc2_.resolvedTrait);
      }
      
      private function processResolvedTraitChange(param1:String, param2:MediaTraitBase) : void
      {
         if(param2 != traits[param1])
         {
            setLocalTrait(param1,param2);
         }
      }
      
      private function onContainerChange(param1:ContainerChangeEvent) : void
      {
         if(_container == param1.oldContainer && _container != param1.newContainer)
         {
            _container = param1.newContainer;
         }
      }
      
      private function onMetadataValueAdd(param1:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent("metadataAdd",false,false,null,param1.key,param1.value as Metadata));
      }
      
      private function onMetadataValueChange(param1:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent("metadataRemove",false,false,null,param1.key,param1.oldValue as Metadata));
         dispatchEvent(new MediaElementEvent("metadataAdd",false,false,null,param1.key,param1.value as Metadata));
      }
      
      private function onMetadataValueRemove(param1:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent("metadataRemove",false,false,null,param1.key,param1.value as Metadata));
      }
   }
}

