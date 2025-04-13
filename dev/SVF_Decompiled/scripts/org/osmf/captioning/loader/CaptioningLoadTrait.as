package org.osmf.captioning.loader
{
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class CaptioningLoadTrait extends LoadTrait
   {
      private var _document:CaptioningDocument;
      
      public function CaptioningLoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super(param1,param2);
      }
      
      public function get document() : CaptioningDocument
      {
         return _document;
      }
      
      public function set document(param1:CaptioningDocument) : void
      {
         _document = param1;
      }
   }
}

