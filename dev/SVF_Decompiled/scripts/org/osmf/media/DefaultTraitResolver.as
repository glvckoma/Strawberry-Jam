package org.osmf.media
{
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   public class DefaultTraitResolver extends MediaTraitResolver
   {
      private var defaultTrait:MediaTraitBase;
      
      private var trait:MediaTraitBase;
      
      public function DefaultTraitResolver(param1:String, param2:MediaTraitBase)
      {
         super(param1);
         if(param2 == null)
         {
            throw new ArgumentError(OSMFStrings.getString("nullParam"));
         }
         if(param2.traitType != param1)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         this.defaultTrait = param2;
         setResolvedTrait(param2);
      }
      
      override protected function processAddTrait(param1:MediaTraitBase) : void
      {
         if(trait == null)
         {
            setResolvedTrait(trait = param1);
         }
      }
      
      override protected function processRemoveTrait(param1:MediaTraitBase) : MediaTraitBase
      {
         var _loc2_:MediaTraitBase = null;
         if(param1 && param1 == trait)
         {
            _loc2_ = trait;
            trait = null;
            setResolvedTrait(defaultTrait);
         }
         return _loc2_;
      }
   }
}

