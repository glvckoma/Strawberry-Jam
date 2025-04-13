package org.osmf.net.httpstreaming.dvr
{
   import flash.net.NetConnection;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.net.httpstreaming.HTTPNetStream;
   import org.osmf.traits.DVRTrait;
   
   public class HTTPStreamingDVRCastDVRTrait extends DVRTrait
   {
      private var _connection:NetConnection;
      
      private var _stream:HTTPNetStream;
      
      private var _dvrInfo:DVRInfo;
      
      public function HTTPStreamingDVRCastDVRTrait(param1:NetConnection, param2:HTTPNetStream, param3:DVRInfo)
      {
         _connection = param1;
         _stream = param2;
         _dvrInfo = param3;
         _stream.addEventListener("DVRStreamInfo",onDVRStreamInfo);
         super(param3.isRecording);
      }
      
      private function onDVRStreamInfo(param1:DVRStreamInfoEvent) : void
      {
         _dvrInfo = param1.info as DVRInfo;
         setIsRecording(_dvrInfo == null ? false : _dvrInfo.isRecording);
      }
   }
}

