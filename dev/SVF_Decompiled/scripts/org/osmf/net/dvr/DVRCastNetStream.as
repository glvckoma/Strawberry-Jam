package org.osmf.net.dvr
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import org.osmf.media.MediaResourceBase;
   
   public class DVRCastNetStream extends NetStream
   {
      private var recordingInfo:DVRCastRecordingInfo;
      
      public function DVRCastNetStream(param1:NetConnection, param2:MediaResourceBase)
      {
         super(param1);
         recordingInfo = param2.getMetadataValue("http://www.osmf.org/dvrCast/1.0/recordingInfo") as DVRCastRecordingInfo;
      }
      
      override public function play(... rest) : void
      {
         super.play(rest[0],recordingInfo.startOffset,-1);
      }
      
      override public function play2(param1:NetStreamPlayOptions) : void
      {
         if(param1)
         {
            param1.start = recordingInfo.startOffset;
            param1.len = -1;
         }
         super.play2(param1);
      }
   }
}

