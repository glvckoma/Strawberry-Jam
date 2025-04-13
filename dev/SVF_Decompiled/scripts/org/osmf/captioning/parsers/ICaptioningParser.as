package org.osmf.captioning.parsers
{
   import org.osmf.captioning.model.CaptioningDocument;
   
   public interface ICaptioningParser
   {
      function parse(param1:String) : CaptioningDocument;
   }
}

