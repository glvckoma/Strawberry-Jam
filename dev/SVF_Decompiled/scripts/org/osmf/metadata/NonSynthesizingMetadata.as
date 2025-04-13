package org.osmf.metadata
{
   public class NonSynthesizingMetadata extends Metadata
   {
      private var _synthesizer:MetadataSynthesizer = new NullMetadataSynthesizer();
      
      public function NonSynthesizingMetadata()
      {
         super();
      }
      
      override public function get synthesizer() : MetadataSynthesizer
      {
         return _synthesizer;
      }
   }
}

