package org.osmf.net
{
   import flash.errors.IOError;
   import flash.events.AsyncErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   
   internal class NetNegotiator extends EventDispatcher
   {
      private var resource:URLResource;
      
      private var netConnectionURLs:Vector.<String>;
      
      private var netConnections:Vector.<NetConnection>;
      
      private var netConnectionArguments:Vector.<Object>;
      
      private var failedConnectionCount:int;
      
      private var timeOutTimer:Timer;
      
      private var connectionTimer:Timer;
      
      private var attemptIndex:int;
      
      private var mediaError:MediaError;
      
      private var connectionAttemptInterval:Number;
      
      private var _timeout:Number;
      
      public function NetNegotiator(param1:Number, param2:Number = 10000)
      {
         super();
         this.connectionAttemptInterval = param1;
         this._timeout = param2;
      }
      
      public function get timeout() : Number
      {
         return _timeout;
      }
      
      public function set timeout(param1:Number) : void
      {
         _timeout = param1;
      }
      
      public function createNetConnection(param1:URLResource, param2:Vector.<String>, param3:Vector.<NetConnection>) : void
      {
         this.resource = param1;
         this.netConnectionURLs = param2;
         this.netConnections = param3;
         var _loc4_:StreamingURLResource = param1 as StreamingURLResource;
         if(_loc4_ != null && _loc4_.connectionArguments != null && _loc4_.connectionArguments.length > 0)
         {
            this.netConnectionArguments = _loc4_.connectionArguments;
         }
         initializeConnectionAttempts();
         tryToConnect(null);
      }
      
      private function initializeConnectionAttempts() : void
      {
         timeOutTimer = new Timer(_timeout,1);
         timeOutTimer.addEventListener("timerComplete",masterTimeout);
         timeOutTimer.start();
         connectionTimer = new Timer(connectionAttemptInterval);
         connectionTimer.addEventListener("timer",tryToConnect);
         connectionTimer.start();
         failedConnectionCount = 0;
         attemptIndex = 0;
      }
      
      private function tryToConnect(param1:TimerEvent) : void
      {
         var _loc3_:MulticastResource = null;
         var _loc5_:String = null;
         var _loc2_:Array = null;
         netConnections[attemptIndex].addEventListener("netStatus",onNetStatus,false,0,true);
         netConnections[attemptIndex].addEventListener("securityError",onNetSecurityError,false,0,true);
         netConnections[attemptIndex].addEventListener("asyncError",onAsyncError,false,0,true);
         netConnections[attemptIndex].client = new NetClient();
         try
         {
            _loc3_ = resource as MulticastResource;
            if(_loc3_ != null && _loc3_.groupspec != null && _loc3_.groupspec.length > 0)
            {
               NetConnection(netConnections[attemptIndex]).connect(_loc3_.url);
            }
            else
            {
               _loc5_ = netConnectionURLs[attemptIndex];
               _loc2_ = [_loc5_];
               if(netConnectionArguments != null)
               {
                  for each(var _loc4_ in netConnectionArguments)
                  {
                     _loc2_.push(_loc4_);
                  }
               }
               NetConnection(netConnections[attemptIndex]).connect.apply(netConnections[attemptIndex],_loc2_);
            }
            attemptIndex++;
            if(attemptIndex >= netConnectionURLs.length)
            {
               connectionTimer.stop();
            }
         }
         catch(ioError:IOError)
         {
            handleFailedConnectionSession(new MediaError(1,ioError.message),netConnectionURLs[attemptIndex]);
         }
         catch(argumentError:ArgumentError)
         {
            handleFailedConnectionSession(new MediaError(4,argumentError.message),netConnectionURLs[attemptIndex]);
         }
         catch(securityError:SecurityError)
         {
            handleFailedConnectionSession(new MediaError(2,securityError.message),netConnectionURLs[attemptIndex]);
         }
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         var index:int;
         var tempTimer:Timer;
         var onTempTimer:*;
         var event:NetStatusEvent = param1;
         switch(event.info.code)
         {
            case "NetConnection.Connect.InvalidApp":
               handleFailedConnectionSession(new MediaError(12,event.info.description),NetConnection(event.target).uri);
               break;
            case "NetConnection.Connect.Rejected":
               if(event.info.hasOwnProperty("ex") && event.info.ex.code == 302)
               {
                  onTempTimer = function(param1:TimerEvent):void
                  {
                     tempTimer.removeEventListener("timer",onTempTimer);
                     tempTimer.stop();
                     tryToConnect(null);
                  };
                  index = int(netConnections.indexOf(event.target as NetConnection));
                  netConnectionURLs[index] = event.info.ex.redirect;
                  attemptIndex = index;
                  tempTimer = new Timer(100,1);
                  tempTimer.addEventListener("timer",onTempTimer);
                  tempTimer.start();
                  break;
               }
               handleFailedConnectionSession(new MediaError(11,event.info.description),NetConnection(event.target).uri);
               break;
            case "NetConnection.Connect.Failed":
               failedConnectionCount++;
               if(failedConnectionCount >= netConnectionURLs.length)
               {
                  handleFailedConnectionSession(new MediaError(13),NetConnection(event.target).uri);
               }
               break;
            case "NetConnection.Connect.Success":
               if(event.info.hasOwnProperty("data") && event.info.data.hasOwnProperty("version"))
               {
                  resource.addMetadataValue("http://www.osmf.org/fmsServerVersion/1.0",event.info.data.version);
               }
               shutDownUnsuccessfulConnections();
               dispatchEvent(new NetConnectionFactoryEvent("creationComplete",false,false,event.currentTarget as NetConnection,resource));
               break;
            case "NetStream.Publish.Start":
         }
      }
      
      private function shutDownUnsuccessfulConnections() : void
      {
         var _loc2_:int = 0;
         var _loc1_:NetConnection = null;
         timeOutTimer.stop();
         connectionTimer.stop();
         _loc2_ = 0;
         while(_loc2_ < netConnections.length)
         {
            _loc1_ = netConnections[_loc2_];
            if(!_loc1_.connected)
            {
               _loc1_.removeEventListener("netStatus",onNetStatus);
               _loc1_.removeEventListener("securityError",onNetSecurityError);
               _loc1_.removeEventListener("asyncError",onAsyncError);
               _loc1_.close();
               delete netConnections[_loc2_];
            }
            _loc2_++;
         }
      }
      
      private function handleFailedConnectionSession(param1:MediaError, param2:String) : void
      {
         shutDownUnsuccessfulConnections();
         dispatchEvent(new NetConnectionFactoryEvent("creationError",false,false,null,resource,param1));
      }
      
      private function onNetSecurityError(param1:SecurityErrorEvent) : void
      {
         handleFailedConnectionSession(new MediaError(2,param1.text),NetConnection(param1.target).uri);
      }
      
      private function onAsyncError(param1:AsyncErrorEvent) : void
      {
         handleFailedConnectionSession(new MediaError(3,param1.text),NetConnection(param1.target).uri);
      }
      
      private function masterTimeout(param1:TimerEvent) : void
      {
         handleFailedConnectionSession(new MediaError(14,"" + _timeout),"");
      }
   }
}

