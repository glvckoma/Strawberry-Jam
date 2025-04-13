package org.osmf.net
{
   import flash.utils.ByteArray;
   import org.osmf.media.URLResource;
   
   public class StreamingURLResource extends URLResource
   {
      private var _streamType:String;
      
      private var _clipStartTime:Number;
      
      private var _clipEndTime:Number;
      
      private var _connectionArguments:Vector.<Object>;
      
      private var _drmContentData:ByteArray;
      
      private var _urlIncludesFMSApplicationInstance:Boolean = false;
      
      public function StreamingURLResource(param1:String, param2:String = null, param3:Number = NaN, param4:Number = NaN, param5:Vector.<Object> = null, param6:Boolean = false, param7:ByteArray = null)
      {
         _streamType = param2 || "recorded";
         _clipStartTime = param3;
         _clipEndTime = param4;
         _urlIncludesFMSApplicationInstance = param6;
         _drmContentData = param7;
         _connectionArguments = param5;
         super(param1);
      }
      
      public function get streamType() : String
      {
         return _streamType;
      }
      
      public function set streamType(param1:String) : void
      {
         _streamType = param1;
      }
      
      public function get clipStartTime() : Number
      {
         return _clipStartTime;
      }
      
      public function set clipStartTime(param1:Number) : void
      {
         _clipStartTime = param1;
      }
      
      public function get clipEndTime() : Number
      {
         return _clipEndTime;
      }
      
      public function set clipEndTime(param1:Number) : void
      {
         _clipEndTime = param1;
      }
      
      public function get connectionArguments() : Vector.<Object>
      {
         return _connectionArguments;
      }
      
      public function set connectionArguments(param1:Vector.<Object>) : void
      {
         _connectionArguments = param1;
      }
      
      public function get drmContentData() : ByteArray
      {
         return _drmContentData;
      }
      
      public function set drmContentData(param1:ByteArray) : void
      {
         _drmContentData = param1;
      }
      
      public function get urlIncludesFMSApplicationInstance() : Boolean
      {
         return _urlIncludesFMSApplicationInstance;
      }
      
      public function set urlIncludesFMSApplicationInstance(param1:Boolean) : void
      {
         _urlIncludesFMSApplicationInstance = param1;
      }
   }
}

