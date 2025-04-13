package org.osmf.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   internal class MediaTraitResolver extends EventDispatcher
   {
      private var _type:String;
      
      private var _resolvedTrait:MediaTraitBase;
      
      public function MediaTraitResolver(param1:String)
      {
         super();
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         _type = param1;
      }
      
      final public function get type() : String
      {
         return _type;
      }
      
      final protected function setResolvedTrait(param1:MediaTraitBase) : void
      {
         if(param1 != _resolvedTrait)
         {
            if(_resolvedTrait)
            {
               _resolvedTrait = null;
               dispatchEvent(new Event("change"));
            }
            _resolvedTrait = param1;
            dispatchEvent(new Event("change"));
         }
      }
      
      final public function get resolvedTrait() : MediaTraitBase
      {
         return _resolvedTrait;
      }
      
      final public function addTrait(param1:MediaTraitBase) : void
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         if(param1.traitType != type)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         processAddTrait(param1);
      }
      
      final public function removeTrait(param1:MediaTraitBase) : MediaTraitBase
      {
         if(param1 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         if(param1.traitType != type)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         return processRemoveTrait(param1);
      }
      
      protected function processAddTrait(param1:MediaTraitBase) : void
      {
      }
      
      protected function processRemoveTrait(param1:MediaTraitBase) : MediaTraitBase
      {
         return null;
      }
   }
}

