package org.osmf.net
{
   import flash.utils.ByteArray;
   
   public class MulticastResource extends StreamingURLResource
   {
      private var _groupspec:String;
      
      private var _streamName:String;
      
      public function MulticastResource(param1:String, param2:String = null, param3:String = null, param4:Vector.<Object> = null, param5:Boolean = false, param6:ByteArray = null)
      {
         super(param1,"live",NaN,NaN,param4,param5,param6);
         _groupspec = param2;
         _streamName = param3;
      }
      
      public function get groupspec() : String
      {
         return _groupspec;
      }
      
      public function set groupspec(param1:String) : void
      {
         _groupspec = param1;
      }
      
      public function get streamName() : String
      {
         return _streamName;
      }
      
      public function set streamName(param1:String) : void
      {
         _streamName = param1;
      }
   }
}

