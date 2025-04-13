package org.osmf.net.httpstreaming.f4f
{
   internal class LocalRandomAccessEntry
   {
      private var _time:Number;
      
      private var _offset:Number;
      
      public function LocalRandomAccessEntry()
      {
         super();
      }
      
      public function get time() : Number
      {
         return _time;
      }
      
      public function set time(param1:Number) : void
      {
         _time = param1;
      }
      
      public function get offset() : Number
      {
         return _offset;
      }
      
      public function set offset(param1:Number) : void
      {
         _offset = param1;
      }
   }
}

