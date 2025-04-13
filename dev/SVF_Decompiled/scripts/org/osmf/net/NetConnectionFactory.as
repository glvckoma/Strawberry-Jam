package org.osmf.net
{
   import flash.net.NetConnection;
   import flash.utils.Dictionary;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   import org.osmf.utils.URL;
   
   public class NetConnectionFactory extends NetConnectionFactoryBase
   {
      private static const DEFAULT_TIMEOUT:Number = 10000;
      
      private static const DEFAULT_PORTS:String = "1935,443,80";
      
      private static const DEFAULT_PROTOCOLS_FOR_RTMP:String = "rtmp,rtmpt,rtmps";
      
      private static const DEFAULT_PROTOCOLS_FOR_RTMPE:String = "rtmpe,rtmpte";
      
      private static const DEFAULT_CONNECTION_ATTEMPT_INTERVAL:Number = 200;
      
      private static const PROTOCOL_RTMP:String = "rtmp";
      
      private static const PROTOCOL_RTMPS:String = "rtmps";
      
      private static const PROTOCOL_RTMPT:String = "rtmpt";
      
      private static const PROTOCOL_RTMPE:String = "rtmpe";
      
      private static const PROTOCOL_RTMPTE:String = "rtmpte";
      
      private static const PROTOCOL_HTTP:String = "http";
      
      private static const PROTOCOL_HTTPS:String = "https";
      
      private static const PROTOCOL_FILE:String = "file";
      
      private static const PROTOCOL_EMPTY:String = "";
      
      private static const MP3_EXTENSION:String = ".mp3";
      
      private var shareNetConnections:Boolean;
      
      private var negotiator:NetNegotiator;
      
      private var connectionDictionary:Dictionary;
      
      private var keyDictionary:Dictionary;
      
      private var pendingDictionary:Dictionary;
      
      private var _connectionAttemptInterval:Number = 200;
      
      private var _timeout:Number = 10000;
      
      public function NetConnectionFactory(param1:Boolean = true)
      {
         super();
         this.shareNetConnections = param1;
      }
      
      public function get timeout() : Number
      {
         return _timeout;
      }
      
      public function set timeout(param1:Number) : void
      {
         _timeout = param1;
      }
      
      public function get connectionAttemptInterval() : Number
      {
         return _connectionAttemptInterval;
      }
      
      public function set connectionAttemptInterval(param1:Number) : void
      {
         _connectionAttemptInterval = param1;
      }
      
      override public function create(param1:URLResource) : void
      {
         var sharedConnection:SharedConnection;
         var connectionsUnderway:Vector.<URLResource>;
         var pendingConnections:Vector.<URLResource>;
         var urlIncludesFMSApplicationInstance:Boolean;
         var netConnectionURLs:Vector.<String>;
         var netConnections:Vector.<NetConnection>;
         var j:int;
         var negotiator:NetNegotiator;
         var onConnected:*;
         var onConnectionFailed:*;
         var resource:URLResource = param1;
         var key:String = createNetConnectionKey(resource);
         if(connectionDictionary == null)
         {
            connectionDictionary = new Dictionary();
            keyDictionary = new Dictionary();
            pendingDictionary = new Dictionary();
         }
         sharedConnection = connectionDictionary[key] as SharedConnection;
         connectionsUnderway = pendingDictionary[key] as Vector.<URLResource>;
         if(sharedConnection != null && shareNetConnections)
         {
            sharedConnection.count++;
            dispatchEvent(new NetConnectionFactoryEvent("creationComplete",false,false,sharedConnection.netConnection,resource));
         }
         else if(connectionsUnderway != null)
         {
            connectionsUnderway.push(resource);
         }
         else
         {
            onConnected = function(param1:NetConnectionFactoryEvent):void
            {
               var _loc4_:Number = NaN;
               var _loc6_:URLResource = null;
               var _loc5_:SharedConnection = null;
               var _loc3_:SharedConnection = null;
               negotiator.removeEventListener("creationComplete",onConnected);
               negotiator.removeEventListener("creationError",onConnectionFailed);
               var _loc7_:Vector.<NetConnectionFactoryEvent> = new Vector.<NetConnectionFactoryEvent>();
               var _loc2_:Vector.<URLResource> = pendingDictionary[key];
               _loc4_ = 0;
               while(_loc4_ < _loc2_.length)
               {
                  _loc6_ = _loc2_[_loc4_] as URLResource;
                  if(shareNetConnections)
                  {
                     _loc5_ = connectionDictionary[key] as SharedConnection;
                     if(_loc5_ != null)
                     {
                        _loc5_.count++;
                     }
                     else
                     {
                        _loc3_ = new SharedConnection();
                        _loc3_.count = 1;
                        _loc3_.netConnection = param1.netConnection;
                        connectionDictionary[key] = _loc3_;
                        keyDictionary[_loc3_.netConnection] = key;
                     }
                  }
                  _loc7_.push(new NetConnectionFactoryEvent("creationComplete",false,false,param1.netConnection,_loc6_));
                  _loc4_++;
               }
               delete pendingDictionary[key];
               for each(var _loc8_ in _loc7_)
               {
                  dispatchEvent(_loc8_);
               }
            };
            onConnectionFailed = function(param1:NetConnectionFactoryEvent):void
            {
               negotiator.removeEventListener("creationComplete",onConnected);
               negotiator.removeEventListener("creationError",onConnectionFailed);
               var _loc2_:Vector.<URLResource> = pendingDictionary[key];
               for each(var _loc3_ in _loc2_)
               {
                  dispatchEvent(new NetConnectionFactoryEvent("creationError",false,false,null,_loc3_,param1.mediaError));
               }
               delete pendingDictionary[key];
            };
            pendingConnections = new Vector.<URLResource>();
            pendingConnections.push(resource);
            pendingDictionary[key] = pendingConnections;
            urlIncludesFMSApplicationInstance = Boolean(resource is StreamingURLResource ? StreamingURLResource(resource).urlIncludesFMSApplicationInstance : false);
            netConnectionURLs = createNetConnectionURLs(resource.url,urlIncludesFMSApplicationInstance);
            netConnections = new Vector.<NetConnection>();
            j = 0;
            while(j < netConnectionURLs.length)
            {
               netConnections.push(createNetConnection());
               j++;
            }
            negotiator = new NetNegotiator(_connectionAttemptInterval,_timeout);
            negotiator.addEventListener("creationComplete",onConnected);
            negotiator.addEventListener("creationError",onConnectionFailed);
            negotiator.createNetConnection(resource,netConnectionURLs,netConnections);
         }
      }
      
      override public function closeNetConnection(param1:NetConnection) : void
      {
         var _loc3_:String = null;
         var _loc2_:SharedConnection = null;
         if(shareNetConnections)
         {
            _loc3_ = keyDictionary[param1] as String;
            if(_loc3_ != null)
            {
               _loc2_ = connectionDictionary[_loc3_] as SharedConnection;
               _loc2_.count--;
               if(_loc2_.count == 0)
               {
                  param1.close();
                  delete connectionDictionary[_loc3_];
                  delete keyDictionary[param1];
               }
            }
         }
         else
         {
            super.closeNetConnection(param1);
         }
      }
      
      protected function createNetConnectionKey(param1:URLResource) : String
      {
         var _loc2_:FMSURL = new FMSURL(param1.url);
         return _loc2_.protocol + _loc2_.host + _loc2_.port + _loc2_.appName + _loc2_.instanceName;
      }
      
      protected function createNetConnection() : NetConnection
      {
         return new NetConnection();
      }
      
      protected function createNetConnectionURLs(param1:String, param2:Boolean = false) : Vector.<String>
      {
         var _loc3_:Vector.<String> = new Vector.<String>();
         var _loc5_:Vector.<PortProtocol> = buildPortProtocolSequence(param1);
         for each(var _loc4_ in _loc5_)
         {
            _loc3_.push(buildConnectionAddress(param1,param2,_loc4_));
         }
         return _loc3_;
      }
      
      private function buildPortProtocolSequence(param1:String) : Vector.<PortProtocol>
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:PortProtocol = null;
         var _loc6_:Vector.<PortProtocol> = new Vector.<PortProtocol>();
         var _loc2_:URL = new URL(param1);
         var _loc10_:String = _loc2_.port == "" ? "1935,443,80" : _loc2_.port;
         var _loc7_:String = "";
         switch(_loc2_.protocol)
         {
            case "rtmp":
               _loc7_ = "rtmp,rtmpt,rtmps";
               break;
            case "rtmpe":
               _loc7_ = "rtmpe,rtmpte";
               break;
            case "rtmps":
            case "rtmpt":
            case "rtmpte":
               _loc7_ = _loc2_.protocol;
         }
         var _loc8_:Array = _loc10_.split(",");
         var _loc3_:Array = _loc7_.split(",");
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc8_.length)
            {
               _loc9_ = new PortProtocol();
               _loc9_.protocol = _loc3_[_loc4_];
               _loc9_.port = _loc8_[_loc5_];
               _loc6_.push(_loc9_);
               _loc5_++;
            }
            _loc4_++;
         }
         return _loc6_;
      }
      
      private function buildConnectionAddress(param1:String, param2:Boolean, param3:PortProtocol) : String
      {
         var _loc4_:FMSURL = new FMSURL(param1,param2);
         var _loc5_:String = param3.protocol + "://" + _loc4_.host + ":" + param3.port + "/" + _loc4_.appName + (_loc4_.useInstance ? "/" + _loc4_.instanceName : "");
         if(_loc4_.query != null && _loc4_.query != "")
         {
            _loc5_ += "?" + _loc4_.query;
         }
         return _loc5_;
      }
   }
}

import flash.net.NetConnection;

class SharedConnection
{
   public var count:Number;
   
   public var netConnection:NetConnection;
   
   public function SharedConnection()
   {
      super();
   }
}
