package org.osmf.net
{
   internal class FMSHost
   {
      private var _host:String;
      
      private var _port:String;
      
      public function FMSHost(param1:String, param2:String = "1935")
      {
         super();
         _host = param1;
         _port = param2;
      }
      
      public function get host() : String
      {
         return _host;
      }
      
      public function set host(param1:String) : void
      {
         _host = param1;
      }
      
      public function get port() : String
      {
         return _port;
      }
      
      public function set port(param1:String) : void
      {
         _port = param1;
      }
   }
}

