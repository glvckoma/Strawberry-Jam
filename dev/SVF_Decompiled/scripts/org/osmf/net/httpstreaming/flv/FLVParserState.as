package org.osmf.net.httpstreaming.flv
{
   internal class FLVParserState
   {
      internal static const FILE_HEADER:String = "fileHeader";
      
      internal static const FILE_HEADER_REST:String = "fileHeaderRest";
      
      internal static const TYPE:String = "type";
      
      internal static const HEADER:String = "header";
      
      internal static const DATA:String = "data";
      
      internal static const PREV_TAG:String = "prevTag";
      
      public function FLVParserState()
      {
         super();
      }
   }
}

