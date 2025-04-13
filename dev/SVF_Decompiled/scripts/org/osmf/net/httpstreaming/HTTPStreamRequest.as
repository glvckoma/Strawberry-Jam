package org.osmf.net.httpstreaming
{
   import flash.net.URLRequest;
   
   public class HTTPStreamRequest
   {
      private var _urlRequest:URLRequest;
      
      private var _quality:int;
      
      private var _truncateAt:Number;
      
      private var _retryAfter:Number;
      
      private var _unpublishNotify:Boolean;
      
      public function HTTPStreamRequest(param1:String = null, param2:int = -1, param3:Number = -1, param4:Number = -1, param5:Boolean = false)
      {
         super();
         if(param1)
         {
            _urlRequest = new URLRequest(HTTPStreamingUtils.normalizeURL(param1));
         }
         else
         {
            _urlRequest = null;
         }
         _quality = param2;
         _truncateAt = param3;
         _retryAfter = param4;
         _unpublishNotify = param5;
      }
      
      public function get urlRequest() : URLRequest
      {
         return _urlRequest;
      }
      
      public function get retryAfter() : Number
      {
         return _retryAfter;
      }
      
      public function get unpublishNotify() : Boolean
      {
         return _unpublishNotify;
      }
   }
}

