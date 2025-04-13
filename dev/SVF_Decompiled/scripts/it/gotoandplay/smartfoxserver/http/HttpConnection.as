package it.gotoandplay.smartfoxserver.http
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.HTTPStatusEvent;
   import flash.events.IOErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   
   public class HttpConnection extends EventDispatcher
   {
      private static const HANDSHAKE:String = "connect";
      
      private static const DISCONNECT:String = "disconnect";
      
      private static const CONN_LOST:String = "ERR#01";
      
      public static const POLL:String = "poll";
      
      public static const HANDSHAKE_TOKEN:String = "#";
      
      private static const servletUrl:String = "BlueBox/HttpBox.do";
      
      private static const paramName:String = "sfsHttp";
      
      private var smartFoxClient:SmartFoxClient;
      
      private var sessionId:String;
      
      private var connected:Boolean = false;
      
      private var ipAddr:String;
      
      private var port:int;
      
      private var baseUrl:String;
      
      private var webUrl:String;
      
      private var urlRequest:URLRequest;
      
      private var codec:IHttpProtocolCodec;
      
      public function HttpConnection(param1:SmartFoxClient)
      {
         super();
         codec = new RawProtocolCodec();
         HttpRequest.init(handleResponse,handleStatus,handleIOError);
         this.smartFoxClient = param1;
         param1.debugMessage("HttpConnection ctor");
      }
      
      public function getSessionId() : String
      {
         return this.sessionId;
      }
      
      public function getBaseUrl() : String
      {
         return baseUrl;
      }
      
      public function isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function connect(param1:String, param2:int = 8080, param3:Boolean = false) : void
      {
         this.ipAddr = param1;
         this.port = param2;
         this.baseUrl = (param3 ? "https://bb-" : "http://") + this.ipAddr;
         if(!param3 && param2 != 80 || param3 && param2 != 443)
         {
            this.baseUrl += ":" + this.port;
         }
         this.webUrl = baseUrl + "/" + "BlueBox/HttpBox.do";
         this.sessionId = null;
         urlRequest = new URLRequest(webUrl);
         urlRequest.method = "POST";
         smartFoxClient.debugMessage("connect: " + baseUrl);
         send("connect");
      }
      
      public function close() : void
      {
         send("disconnect");
      }
      
      public function send(param1:String) : void
      {
         var _loc2_:URLVariables = null;
         if(connected || param1 == "connect" || param1 == "poll")
         {
            _loc2_ = new URLVariables();
            _loc2_["sfsHttp"] = codec.encode(this.sessionId,param1);
            urlRequest.data = _loc2_;
            smartFoxClient.debugMessage("[Sending - BlueBox]: " + urlRequest.data);
            new HttpRequest(urlRequest,param1);
         }
         else
         {
            smartFoxClient.debugMessage("send: can\'t send message before being connected: " + param1);
         }
      }
      
      private function handleResponse(param1:Event, param2:HttpRequest) : void
      {
         var _loc5_:HttpEvent = null;
         var _loc4_:URLLoader = param1.target as URLLoader;
         var _loc3_:String = _loc4_.data as String;
         var _loc6_:Object = {};
         if(_loc3_.charAt(0) == "#")
         {
            if(sessionId == null)
            {
               sessionId = codec.decode(_loc3_);
               connected = true;
               smartFoxClient.debugMessage("handleResponse: init sessionId: " + sessionId);
               _loc6_.sessionId = this.sessionId;
               _loc6_.success = true;
               _loc5_ = new HttpEvent("onHttpConnect",_loc6_);
               dispatchEvent(_loc5_);
            }
            else
            {
               smartFoxClient.debugMessage("**ERROR** SessionId is being rewritten");
            }
         }
         else
         {
            if(_loc3_.indexOf("ERR#01") == 0)
            {
               _loc6_.data = {};
               _loc5_ = new HttpEvent("onHttpClose",_loc6_);
            }
            else
            {
               _loc6_.data = _loc3_;
               _loc5_ = new HttpEvent("onHttpData",_loc6_);
            }
            dispatchEvent(_loc5_);
         }
      }
      
      private function handleStatus(param1:HTTPStatusEvent, param2:HttpRequest) : void
      {
         var _loc3_:HttpEvent = null;
         if(param1.status < 200 || param1.status >= 400)
         {
            if(param2.message == "poll")
            {
               param2.complete();
               _loc3_ = new HttpEvent("onHttpPollError",null);
               dispatchEvent(_loc3_);
            }
         }
      }
      
      private function handleIOError(param1:IOErrorEvent, param2:HttpRequest) : void
      {
         var _loc3_:Object = {};
         _loc3_.message = param1.text;
         var _loc4_:HttpEvent = new HttpEvent("onHttpError",_loc3_);
         dispatchEvent(_loc4_);
      }
   }
}

