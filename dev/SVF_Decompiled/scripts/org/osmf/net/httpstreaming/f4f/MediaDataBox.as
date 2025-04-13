package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   
   internal class MediaDataBox extends Box
   {
      private var _data:ByteArray;
      
      public function MediaDataBox()
      {
         super();
      }
      
      public function get data() : ByteArray
      {
         return _data;
      }
      
      public function set data(param1:ByteArray) : void
      {
         _data = param1;
      }
   }
}

