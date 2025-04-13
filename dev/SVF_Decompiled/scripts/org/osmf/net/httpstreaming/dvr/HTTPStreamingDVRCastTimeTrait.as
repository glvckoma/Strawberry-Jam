package org.osmf.net.httpstreaming.dvr
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.net.httpstreaming.HTTPNetStream;
   import org.osmf.traits.TimeTrait;
   
   public class HTTPStreamingDVRCastTimeTrait extends TimeTrait
   {
      private var _connection:NetConnection;
      
      private var _stream:HTTPNetStream;
      
      private var _dvrInfo:DVRInfo;
      
      public function HTTPStreamingDVRCastTimeTrait(param1:NetConnection, param2:HTTPNetStream, param3:DVRInfo)
      {
         super(NaN);
         _connection = param1;
         _stream = param2;
         _dvrInfo = param3;
         _stream.addEventListener("DVRStreamInfo",onDVRStreamInfo);
         _stream.addEventListener("netStatus",onNetStatus);
      }
      
      override public function get duration() : Number
      {
         if(_dvrInfo == null)
         {
            return NaN;
         }
         return _dvrInfo.curLength;
      }
      
      override public function get currentTime() : Number
      {
         return _stream.time;
      }
      
      private function onDVRStreamInfo(param1:DVRStreamInfoEvent) : void
      {
         _dvrInfo = param1.info as DVRInfo;
         setDuration(_dvrInfo.curLength);
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         var _loc2_:* = param1.info.code;
         if("NetStream.Play.UnpublishNotify" === _loc2_)
         {
            signalComplete();
         }
      }
   }
}

