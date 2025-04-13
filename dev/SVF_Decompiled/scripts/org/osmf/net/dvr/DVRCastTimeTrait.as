package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.events.TimeEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   internal class DVRCastTimeTrait extends TimeTrait
   {
      private var durationUpdateTimer:Timer;
      
      private var oldDuration:Number;
      
      private var stream:NetStream;
      
      private var streamInfo:DVRCastStreamInfo;
      
      private var recordingInfo:DVRCastRecordingInfo;
      
      public function DVRCastTimeTrait(param1:NetConnection, param2:NetStream, param3:MediaResourceBase)
      {
         super(NaN);
         if(param1 == null || param2 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         this.stream = param2;
         param2.addEventListener("netStatus",onNetStatus);
         durationUpdateTimer = new Timer(500);
         durationUpdateTimer.addEventListener("timer",onDurationUpdateTimer);
         durationUpdateTimer.start();
         streamInfo = param3.getMetadataValue("http://www.osmf.org/dvrCast/1.0/streamInfo") as DVRCastStreamInfo;
         recordingInfo = param3.getMetadataValue("http://www.osmf.org/dvrCast/1.0/recordingInfo") as DVRCastRecordingInfo;
      }
      
      override public function get duration() : Number
      {
         var _loc1_:Number = NaN;
         if(streamInfo.isRecording)
         {
            _loc1_ = recordingInfo.startDuration - recordingInfo.startOffset + (new Date().time - recordingInfo.startTime.time) / 1000;
         }
         else
         {
            _loc1_ = streamInfo.currentLength - recordingInfo.startOffset;
         }
         return isNaN(_loc1_) ? NaN : Math.max(0,_loc1_);
      }
      
      override public function get currentTime() : Number
      {
         return stream.time;
      }
      
      private function onDurationUpdateTimer(param1:TimerEvent) : void
      {
         var _loc2_:Number = duration;
         if(_loc2_ != oldDuration)
         {
            oldDuration = _loc2_;
            dispatchEvent(new TimeEvent("durationChange",false,false,_loc2_));
         }
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         if(param1.info.code == "NetStream.Play.Stop")
         {
            if(durationUpdateTimer)
            {
               durationUpdateTimer.stop();
            }
            signalComplete();
         }
      }
   }
}

