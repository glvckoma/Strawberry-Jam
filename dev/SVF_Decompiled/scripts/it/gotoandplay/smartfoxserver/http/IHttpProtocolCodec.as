package it.gotoandplay.smartfoxserver.http
{
   public interface IHttpProtocolCodec
   {
      function encode(param1:String, param2:String) : String;
      
      function decode(param1:String) : String;
   }
}

