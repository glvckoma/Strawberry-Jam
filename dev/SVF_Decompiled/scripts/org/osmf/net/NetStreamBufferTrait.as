package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.traits.BufferTrait;
   
   public class NetStreamBufferTrait extends BufferTrait
   {
      private var netStream:NetStream;
      
      private var changeBufferLengthTimer:Timer;
      
      public function NetStreamBufferTrait(param1:NetStream)
      {
         super();
         this.netStream = param1;
         bufferTime = param1.bufferTime;
         param1.addEventListener("netStatus",onNetStatus,false,0,true);
         changeBufferLengthTimer = new Timer(250);
         changeBufferLengthTimer.addEventListener("timer",onChangeBufferLength,false,0,true);
         changeBufferLengthTimer.start();
      }
      
      override public function get bufferLength() : Number
      {
         return netStream.bufferLength;
      }
      
      override protected function bufferTimeChangeStart(param1:Number) : void
      {
         netStream.bufferTime = param1;
      }
      
      private function onChangeBufferLength(param1:TimerEvent) : void
      {
         setBufferLength(netStream.bufferLength);
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Start":
            case "NetStream.Buffer.Empty":
               bufferTime = netStream.bufferTime;
               setBuffering(true);
               if(netStream.bufferTime == 0)
               {
                  setBuffering(false);
               }
               break;
            case "NetStream.Buffer.Flush":
            case "NetStream.Buffer.Full":
               setBuffering(false);
         }
      }
   }
}

