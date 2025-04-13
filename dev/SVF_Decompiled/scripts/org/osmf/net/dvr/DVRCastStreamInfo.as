package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import org.osmf.utils.OSMFStrings;
   
   public class DVRCastStreamInfo
   {
      public var callTime:Date;
      
      public var offline:Boolean;
      
      public var beginOffset:Number;
      
      public var endOffset:Number;
      
      public var recordingStart:Date;
      
      public var recordingEnd:Date;
      
      public var isRecording:Boolean;
      
      public var streamName:String;
      
      public var lastUpdate:Date;
      
      public var currentLength:Number;
      
      public var maxLength:Number;
      
      public function DVRCastStreamInfo(param1:Object)
      {
         super();
         readFromDynamicObject(param1);
      }
      
      public function readFromDynamicObject(param1:Object) : void
      {
         try
         {
            callTime = param1.callTime;
            offline = param1.offline;
            beginOffset = param1.begOffset;
            endOffset = param1.endOffset;
            recordingStart = param1.startRec;
            recordingEnd = param1.stopRec;
            isRecording = param1.isRec;
            streamName = param1.streamName;
            lastUpdate = param1.lastUpdate;
            currentLength = param1.currLen;
            maxLength = param1.maxLen;
         }
         catch(e:Error)
         {
            throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
         }
      }
      
      public function readFromDVRCastStreamInfo(param1:DVRCastStreamInfo) : void
      {
         try
         {
            callTime = param1.callTime;
            offline = param1.offline;
            beginOffset = param1.beginOffset;
            endOffset = param1.endOffset;
            recordingStart = param1.recordingStart;
            recordingEnd = param1.recordingEnd;
            isRecording = param1.isRecording;
            streamName = param1.streamName;
            lastUpdate = param1.lastUpdate;
            currentLength = param1.currentLength;
            maxLength = param1.maxLength;
         }
         catch(e:Error)
         {
            throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
         }
      }
      
      public function toString() : String
      {
         return "callTime: " + callTime + "\noffline: " + offline + "\nbeginOffset: " + beginOffset + "\nendOffset: " + endOffset + "\nrecordingStart: " + recordingStart + "\nrecordingEnd: " + recordingEnd + "\nisRecording: " + isRecording + "\nstreamName: " + streamName + "\nlastUpdate: " + lastUpdate + "\ncurrentLength: " + currentLength + "\nmaxLength: " + maxLength;
      }
   }
}

