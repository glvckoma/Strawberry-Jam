package org.osmf.net
{
   public class PortProtocol
   {
      private var _port:int;
      
      private var _protocol:String;
      
      public function PortProtocol()
      {
         super();
      }
      
      public function get port() : int
      {
         return _port;
      }
      
      public function set port(param1:int) : void
      {
         _port = param1;
      }
      
      public function get protocol() : String
      {
         return _protocol;
      }
      
      public function set protocol(param1:String) : void
      {
         _protocol = param1;
      }
   }
}

