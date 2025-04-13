package org.osmf.elements.f4mClasses
{
   import flash.utils.ByteArray;
   
   internal class Media
   {
      public var drmAdditionalHeader:DRMAdditionalHeader = new DRMAdditionalHeader();
      
      public var bootstrapInfo:BootstrapInfo;
      
      public var metadata:Object;
      
      public var xmp:ByteArray;
      
      public var url:String;
      
      public var bitrate:Number;
      
      public var moov:ByteArray;
      
      public var width:Number;
      
      public var height:Number;
      
      public var multicastGroupspec:String;
      
      public var multicastStreamName:String;
      
      public function Media()
      {
         super();
      }
   }
}

