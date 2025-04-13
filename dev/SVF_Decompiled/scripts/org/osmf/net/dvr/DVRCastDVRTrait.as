package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.DVRTrait;
   import org.osmf.utils.OSMFStrings;
   
   internal class DVRCastDVRTrait extends DVRTrait
   {
      private var connection:NetConnection;
      
      private var stream:NetStream;
      
      private var streamInfo:DVRCastStreamInfo;
      
      private var recordingInfo:DVRCastRecordingInfo;
      
      private var streamInfoUpdateTimer:Timer;
      
      private var streamInfoRetriever:DVRCastStreamInfoRetriever;
      
      private var offset:Number;
      
      public function DVRCastDVRTrait(param1:NetConnection, param2:NetStream, param3:MediaResourceBase)
      {
         if(param1 != null && param2 != null)
         {
            this.stream = param2;
            streamInfo = param3.getMetadataValue("http://www.osmf.org/dvrCast/1.0/streamInfo") as DVRCastStreamInfo;
            recordingInfo = param3.getMetadataValue("http://www.osmf.org/dvrCast/1.0/recordingInfo") as DVRCastRecordingInfo;
            streamInfoRetriever = new DVRCastStreamInfoRetriever(param1,streamInfo.streamName);
            streamInfoRetriever.addEventListener("complete",onStreamInfoRetrieverComplete);
            streamInfoUpdateTimer = new Timer(3000);
            streamInfoUpdateTimer.addEventListener("timer",onStreamInfoUpdateTimer);
            streamInfoUpdateTimer.start();
            super(streamInfo.isRecording);
            updateProperties();
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
      }
      
      override protected function isRecordingChangeStart(param1:Boolean) : void
      {
         if(param1)
         {
            recordingInfo.startDuration = streamInfo.currentLength;
            recordingInfo.startTime = new Date();
         }
      }
      
      private function updateProperties() : void
      {
         setIsRecording(streamInfo.isRecording);
      }
      
      private function onStreamInfoUpdateTimer(param1:TimerEvent) : void
      {
         streamInfoRetriever.retrieve();
      }
      
      private function onStreamInfoRetrieverComplete(param1:Event) : void
      {
         if(streamInfoRetriever.streamInfo != null)
         {
            streamInfo.readFromDVRCastStreamInfo(streamInfoRetriever.streamInfo);
            updateProperties();
         }
         else
         {
            dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(22)));
         }
      }
   }
}

