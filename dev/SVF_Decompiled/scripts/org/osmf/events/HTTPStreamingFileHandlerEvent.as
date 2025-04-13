package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.net.httpstreaming.f4f.AdobeBootstrapBox;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   
   public class HTTPStreamingFileHandlerEvent extends Event
   {
      public static const NOTIFY_SEGMENT_DURATION:String = "notifySegmentDuration";
      
      public static const NOTIFY_SCRIPT_DATA:String = "notifyScriptData";
      
      public static const NOTIFY_BOOTSTRAP_BOX:String = "notifyBootstrapBox";
      
      public static const NOTIFY_ERROR:String = "notifyError";
      
      private var _segmentDuration:Number;
      
      private var _scriptDataObject:FLVTagScriptDataObject;
      
      private var _scriptDataFirst:Boolean;
      
      private var _scriptDataImmediate:Boolean;
      
      private var _abst:AdobeBootstrapBox;
      
      private var _error:Boolean;
      
      public function HTTPStreamingFileHandlerEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Number = 0, param5:FLVTagScriptDataObject = null, param6:Boolean = false, param7:Boolean = false, param8:AdobeBootstrapBox = null, param9:Boolean = false)
      {
         super(param1,param2,param3);
         _segmentDuration = param4;
         _scriptDataObject = param5;
         _scriptDataFirst = param6;
         _scriptDataImmediate = param7;
         _abst = param8;
         _error = param9;
      }
      
      public function get segmentDuration() : Number
      {
         return _segmentDuration;
      }
      
      public function get scriptDataObject() : FLVTagScriptDataObject
      {
         return _scriptDataObject;
      }
      
      public function get scriptDataFirst() : Boolean
      {
         return _scriptDataFirst;
      }
      
      public function get scriptDataImmediate() : Boolean
      {
         return _scriptDataImmediate;
      }
      
      public function get bootstrapBox() : AdobeBootstrapBox
      {
         return _abst;
      }
      
      public function get error() : Boolean
      {
         return _error;
      }
      
      override public function clone() : Event
      {
         return new HTTPStreamingFileHandlerEvent(type,bubbles,cancelable,segmentDuration,scriptDataObject,scriptDataFirst,scriptDataImmediate,bootstrapBox,error);
      }
   }
}

