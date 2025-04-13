package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.Responder;
   import flash.utils.Timer;
   import org.osmf.utils.OSMFStrings;
   
   internal class DVRCastStreamInfoRetriever extends EventDispatcher
   {
      private var connection:NetConnection;
      
      private var streamName:String;
      
      private var retries:Number;
      
      private var timer:Timer;
      
      private var _streamInfo:DVRCastStreamInfo;
      
      private var _error:Object;
      
      public function DVRCastStreamInfoRetriever(param1:NetConnection, param2:String)
      {
         super();
         if(param1 == null || param2 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         this.connection = param1;
         this.streamName = param2;
      }
      
      public function get streamInfo() : DVRCastStreamInfo
      {
         return _streamInfo;
      }
      
      public function get error() : Object
      {
         return _error;
      }
      
      public function retrieve(param1:int = 5, param2:Number = 3) : void
      {
         if(isNaN(this.retries))
         {
            if(!param1)
            {
               param1 = 1;
            }
            _streamInfo = null;
            _error = _error = {"message":OSMFStrings.getString("dvrMaximumRPCAttempts").replace("%i",param1)};
            this.retries = param1;
            timer = new Timer(param2 * 1000,1);
            getStreamInfo();
         }
      }
      
      private function getStreamInfo() : void
      {
         var _loc1_:Responder = new TestableResponder(onGetStreamInfoResult,onServerCallError);
         retries--;
         connection.call("DVRGetStreamInfo",_loc1_,streamName);
      }
      
      private function onGetStreamInfoResult(param1:Object) : void
      {
         if(param1 && param1.code == "NetStream.DVRStreamInfo.Success")
         {
            _error = null;
            _streamInfo = new DVRCastStreamInfo(param1.data);
            complete();
         }
         else if(param1 && param1.code == "NetStream.DVRStreamInfo.Retry")
         {
            if(retries != 0)
            {
               timer.addEventListener("timerComplete",onTimerComplete);
               timer.start();
            }
            else
            {
               complete();
            }
         }
         else
         {
            _error = {"message":OSMFStrings.getString("dvrUnexpectedServerResponse") + param1.code};
            complete();
         }
      }
      
      private function onServerCallError(param1:Object) : void
      {
         _error = param1;
         complete();
      }
      
      private function onTimerComplete(param1:TimerEvent) : void
      {
         timer.removeEventListener("timerComplete",onTimerComplete);
         getStreamInfo();
      }
      
      private function complete() : void
      {
         retries = NaN;
         timer = null;
         dispatchEvent(new Event("complete"));
      }
   }
}

