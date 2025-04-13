package org.osmf.elements
{
   import org.osmf.elements.proxyClasses.ProxyMetadata;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.metadata.Metadata;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.OSMFStrings;
   
   public class ProxyElement extends MediaElement
   {
      private var _proxiedMetadata:ProxyMetadata;
      
      private var _proxiedElement:MediaElement;
      
      private var _blockedTraits:Vector.<String>;
      
      public function ProxyElement(param1:MediaElement = null)
      {
         super();
         this.addEventListener("traitAdd",onProxyTraitAdd,false,2147483647);
         this.addEventListener("traitRemove",onProxyTraitRemove,false,2147483647);
         this.addEventListener("containerChange",onProxyContainerChange);
         this.proxiedElement = param1;
      }
      
      public function get proxiedElement() : MediaElement
      {
         return _proxiedElement;
      }
      
      public function set proxiedElement(param1:MediaElement) : void
      {
         var _loc2_:* = null;
         if(param1 != _proxiedElement)
         {
            if(_proxiedElement != null)
            {
               toggleMediaElementListeners(_proxiedElement,false);
               for each(_loc2_ in _proxiedElement.traitTypes)
               {
                  if(super.hasTrait(_loc2_) == false && (_blockedTraits == null || _blockedTraits.indexOf(_loc2_) == -1))
                  {
                     super.dispatchEvent(new MediaElementEvent("traitRemove",false,false,_loc2_));
                  }
               }
            }
            _proxiedElement = param1;
            if(_proxiedElement != null)
            {
               ProxyMetadata(metadata).metadata = _proxiedElement.metadata;
               _proxiedElement.dispatchEvent(new ContainerChangeEvent("containerChange",false,false,_proxiedElement.container,container));
               toggleMediaElementListeners(_proxiedElement,true);
               for each(_loc2_ in _proxiedElement.traitTypes)
               {
                  if(super.hasTrait(_loc2_) == false && (_blockedTraits == null || _blockedTraits.indexOf(_loc2_) == -1))
                  {
                     super.dispatchEvent(new MediaElementEvent("traitAdd",false,false,_loc2_));
                  }
               }
            }
         }
      }
      
      override public function get traitTypes() : Vector.<String>
      {
         var _loc2_:Vector.<String> = new Vector.<String>();
         for each(var _loc1_ in MediaTraitType.ALL_TYPES)
         {
            if(hasTrait(_loc1_))
            {
               _loc2_.push(_loc1_);
            }
         }
         return _loc2_;
      }
      
      override public function hasTrait(param1:String) : Boolean
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         return getTrait(param1) != null;
      }
      
      override public function getTrait(param1:String) : MediaTraitBase
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         var _loc2_:MediaTraitBase = null;
         if(blocksTrait(param1) == false)
         {
            _loc2_ = super.getTrait(param1) || (proxiedElement != null ? proxiedElement.getTrait(param1) : null);
         }
         return _loc2_;
      }
      
      override public function get resource() : MediaResourceBase
      {
         return !!proxiedElement ? proxiedElement.resource : null;
      }
      
      override public function set resource(param1:MediaResourceBase) : void
      {
         if(proxiedElement != null)
         {
            proxiedElement.resource = param1;
         }
      }
      
      override protected function addTrait(param1:String, param2:MediaTraitBase) : void
      {
         if(blocksTrait(param1) == false && proxiedElement != null && proxiedElement.hasTrait(param1) == true)
         {
            super.dispatchEvent(new MediaElementEvent("traitRemove",false,false,param1));
         }
         super.addTrait(param1,param2);
      }
      
      override protected function removeTrait(param1:String) : MediaTraitBase
      {
         var _loc2_:MediaTraitBase = super.removeTrait(param1);
         if(blocksTrait(param1) == false && proxiedElement != null && proxiedElement.hasTrait(param1) == true)
         {
            super.dispatchEvent(new MediaElementEvent("traitAdd",false,false,param1));
         }
         return _loc2_;
      }
      
      override protected function createMetadata() : Metadata
      {
         return new ProxyMetadata();
      }
      
      final protected function get blockedTraits() : Vector.<String>
      {
         if(_blockedTraits == null)
         {
            _blockedTraits = new Vector.<String>();
         }
         return _blockedTraits;
      }
      
      final protected function set blockedTraits(param1:Vector.<String>) : void
      {
         var _loc4_:* = null;
         if(param1 == _blockedTraits)
         {
            return;
         }
         var _loc3_:Array = [];
         var _loc2_:Array = [];
         if(_proxiedElement != null)
         {
            for each(_loc4_ in MediaTraitType.ALL_TYPES)
            {
               if(param1.indexOf(_loc4_) != -1)
               {
                  if(_blockedTraits == null || _blockedTraits.indexOf(_loc4_) == -1)
                  {
                     _loc3_.push(_loc4_);
                  }
               }
               else if(_blockedTraits != null && _blockedTraits.indexOf(_loc4_) != -1)
               {
                  _loc2_.push(_loc4_);
               }
            }
         }
         if(_proxiedElement != null)
         {
            for each(_loc4_ in _loc3_)
            {
               if(proxiedElement.hasTrait(_loc4_) || super.hasTrait(_loc4_))
               {
                  dispatchEvent(new MediaElementEvent("traitRemove",false,false,_loc4_));
               }
            }
            _blockedTraits = param1;
            for each(_loc4_ in _loc2_)
            {
               if(proxiedElement.hasTrait(_loc4_) || super.hasTrait(_loc4_))
               {
                  dispatchEvent(new MediaElementEvent("traitAdd",false,false,_loc4_));
               }
            }
         }
         else
         {
            _blockedTraits = param1;
         }
      }
      
      private function toggleMediaElementListeners(param1:MediaElement, param2:Boolean) : void
      {
         if(param2)
         {
            _proxiedElement.addEventListener("mediaError",onMediaError);
            _proxiedElement.addEventListener("traitAdd",onTraitAdd);
            _proxiedElement.addEventListener("traitRemove",onTraitRemove);
            _proxiedElement.addEventListener("metadataAdd",onMetadataEvent);
            _proxiedElement.addEventListener("metadataRemove",onMetadataEvent);
         }
         else
         {
            _proxiedElement.removeEventListener("mediaError",onMediaError);
            _proxiedElement.removeEventListener("traitAdd",onTraitAdd);
            _proxiedElement.removeEventListener("traitRemove",onTraitRemove);
            _proxiedElement.removeEventListener("metadataAdd",onMetadataEvent);
            _proxiedElement.removeEventListener("metadataRemove",onMetadataEvent);
         }
      }
      
      private function onMediaError(param1:MediaErrorEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         processTraitsChangeEvent(param1);
      }
      
      private function onTraitRemove(param1:MediaElementEvent) : void
      {
         processTraitsChangeEvent(param1);
      }
      
      private function onMetadataEvent(param1:MediaElementEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function onProxyContainerChange(param1:ContainerChangeEvent) : void
      {
         if(proxiedElement != null)
         {
            proxiedElement.dispatchEvent(param1.clone());
         }
      }
      
      private function onProxyTraitAdd(param1:MediaElementEvent) : void
      {
         processProxyTraitsChangeEvent(param1);
      }
      
      private function onProxyTraitRemove(param1:MediaElementEvent) : void
      {
         processProxyTraitsChangeEvent(param1);
      }
      
      private function processTraitsChangeEvent(param1:MediaElementEvent) : void
      {
         if(blocksTrait(param1.traitType) == false && super.hasTrait(param1.traitType) == false)
         {
            super.dispatchEvent(param1.clone());
         }
      }
      
      private function processProxyTraitsChangeEvent(param1:MediaElementEvent) : void
      {
         if(blocksTrait(param1.traitType) == true)
         {
            param1.stopImmediatePropagation();
         }
      }
      
      private function blocksTrait(param1:String) : Boolean
      {
         return _blockedTraits && _blockedTraits.indexOf(param1) != -1;
      }
   }
}

