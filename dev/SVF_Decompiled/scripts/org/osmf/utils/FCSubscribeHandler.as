package org.osmf.utils
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.utils.Timer;
   
   public class FCSubscribeHandler
   {
      private var maxRetry:Number = 5;
      
      private var currentTry:Number = 0;
      
      private var retryTimer:Timer;
      
      private var nc:NetConnection;
      
      private var owner:Object;
      
      public var nsName:String;
      
      public function FCSubscribeHandler()
      {
         super();
      }
      
      public function run(param1:String, param2:String, param3:Object) : void
      {
         this.nsName = param1;
         this.owner = param3;
         nc = new NetConnection();
         nc.addEventListener("netStatus",netConnectHandler);
         nc.client = this;
         nc.connect(param2);
      }
      
      protected function netConnectHandler(param1:NetStatusEvent) : void
      {
         trace("NC: " + param1.info.code);
         if(param1.info.code == "NetConnection.Connect.Success")
         {
            fcSubscribeRetry();
         }
         else if(param1.info.code == "NetStream.Play.UnpublishNotify")
         {
            trace("publish");
         }
         else if(param1.info.code == "NetStream.Unpublish.Success")
         {
            trace("unpublish");
         }
      }
      
      private function fcSubscribeRetry() : void
      {
         retryTimer = new Timer(1000,3);
         retryTimer.addEventListener("timerComplete",retryFCSubscribe);
         retryTimer.start();
      }
      
      private function retryFCSubscribe(param1:TimerEvent) : void
      {
         if(currentTry != maxRetry)
         {
            nc.call("FCSubscribe",null,nsName);
            currentTry++;
         }
         else
         {
            cleanupTimer();
         }
      }
      
      public function onFCSubscribe(param1:Object) : void
      {
         trace(param1.code);
         if(param1.code != "NetStream.Play.StreamNotFound")
         {
            if(param1.code == "NetStream.Play.Start")
            {
               cleanupTimer();
               trace("ready to play");
               owner.fcSubscribeDone();
            }
         }
      }
      
      public function onFCUnpublish(param1:Object) : void
      {
         trace("hi");
      }
      
      private function cleanupTimer() : void
      {
         retryTimer.stop();
         retryTimer = null;
      }
   }
}

