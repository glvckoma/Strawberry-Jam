package it.gotoandplay.smartfoxserver.http
{
   import flash.events.Event;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class HttpRequest
   {
      private static var _responseHandler:Function;
      
      private static var _statusHandler:Function;
      
      private static var _errorHandler:Function;
      
      private var _message:String;
      
      private var _status:int;
      
      private var _isCompleted:Boolean;
      
      public function HttpRequest(param1:URLRequest, param2:String)
      {
         super();
         _message = param2;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.dataFormat = "text";
         _loc3_.addEventListener("complete",handleResponse);
         _loc3_.addEventListener("httpStatus",handleStatus);
         _loc3_.addEventListener("ioError",handleIOError);
         _loc3_.load(param1);
      }
      
      public static function init(param1:Function, param2:Function, param3:Function) : void
      {
         _responseHandler = param1;
         _statusHandler = param2;
         _errorHandler = param3;
      }
      
      private function handleResponse(param1:Event) : void
      {
         _responseHandler(param1,this);
      }
      
      private function handleStatus(param1:HTTPStatusEvent) : void
      {
         _status = param1.status;
         _statusHandler(param1,this);
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         if(!_isCompleted)
         {
            _errorHandler(param1,this);
         }
      }
      
      public function get message() : String
      {
         return _message;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function complete() : void
      {
         _isCompleted = true;
      }
   }
}

