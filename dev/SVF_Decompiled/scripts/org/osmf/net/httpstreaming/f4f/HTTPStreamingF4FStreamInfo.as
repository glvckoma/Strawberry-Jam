package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   
   public class HTTPStreamingF4FStreamInfo
   {
      private var _streamName:String;
      
      private var _bitrate:Number;
      
      private var _bootstrap:BootstrapInfo;
      
      private var _additionalHeader:ByteArray;
      
      private var _streamMetadata:Object;
      
      private var _xmpMetadata:ByteArray;
      
      public function HTTPStreamingF4FStreamInfo(param1:BootstrapInfo, param2:String, param3:Number, param4:ByteArray, param5:Object, param6:ByteArray)
      {
         super();
         _streamName = param2;
         _bitrate = param3;
         _additionalHeader = param4;
         _bootstrap = param1;
         _streamMetadata = param5;
         _xmpMetadata = param6;
      }
      
      public function get streamName() : String
      {
         return _streamName;
      }
      
      public function get bitrate() : Number
      {
         return _bitrate;
      }
      
      public function get additionalHeader() : ByteArray
      {
         return _additionalHeader;
      }
      
      public function get bootstrapInfo() : BootstrapInfo
      {
         return _bootstrap;
      }
      
      public function get streamMetadata() : Object
      {
         return _streamMetadata;
      }
      
      public function get xmpMetadata() : ByteArray
      {
         return _xmpMetadata;
      }
   }
}

