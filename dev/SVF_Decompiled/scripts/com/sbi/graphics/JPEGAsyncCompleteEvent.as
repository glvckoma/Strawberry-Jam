package com.sbi.graphics
{
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class JPEGAsyncCompleteEvent extends Event
   {
      public static const JPEGASYNC_COMPLETE:String = "JPEGAsyncComplete";
      
      public var ImageData:ByteArray;
      
      public function JPEGAsyncCompleteEvent(param1:ByteArray)
      {
         ImageData = param1;
         super("JPEGAsyncComplete");
      }
   }
}

