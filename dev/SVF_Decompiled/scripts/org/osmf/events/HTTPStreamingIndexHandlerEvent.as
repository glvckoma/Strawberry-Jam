package org.osmf.events
{
   import flash.events.Event;
   import flash.net.URLRequest;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   
   public class HTTPStreamingIndexHandlerEvent extends Event
   {
      public static const NOTIFY_INDEX_READY:String = "notifyIndexReady";
      
      public static const NOTIFY_RATES:String = "notifyRates";
      
      public static const REQUEST_LOAD_INDEX:String = "requestLoadIndex";
      
      public static const NOTIFY_ERROR:String = "notifyError";
      
      public static const NOTIFY_SEGMENT_DURATION:String = "notifySegmentDuration";
      
      public static const NOTIFY_SCRIPT_DATA:String = "notifyScriptData";
      
      private var _streamNames:Array;
      
      private var _rates:Array;
      
      private var _request:URLRequest;
      
      private var _requestContext:Object;
      
      private var _binaryData:Boolean;
      
      private var _segmentDuration:Number;
      
      private var _scriptDataObject:FLVTagScriptDataObject;
      
      private var _scriptDataFirst:Boolean;
      
      private var _scriptDataImmediate:Boolean;
      
      private var _live:Boolean;
      
      private var _offset:Number;
      
      public function HTTPStreamingIndexHandlerEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Number = NaN, param6:Array = null, param7:Array = null, param8:URLRequest = null, param9:Object = null, param10:Boolean = true, param11:Number = 0, param12:FLVTagScriptDataObject = null, param13:Boolean = false, param14:Boolean = false)
      {
         super(param1,param2,param3);
         _live = param4;
         _offset = param5;
         _streamNames = param6;
         _rates = param7;
         _request = param8;
         _requestContext = param9;
         _binaryData = param10;
         _segmentDuration = param11;
         _scriptDataObject = param12;
         _scriptDataFirst = param13;
         _scriptDataImmediate = param14;
      }
      
      public function get live() : Boolean
      {
         return _live;
      }
      
      public function get offset() : Number
      {
         return _offset;
      }
      
      public function get streamNames() : Array
      {
         return _streamNames;
      }
      
      public function get rates() : Array
      {
         return _rates;
      }
      
      public function get request() : URLRequest
      {
         return _request;
      }
      
      public function get requestContext() : Object
      {
         return _requestContext;
      }
      
      public function get binaryData() : Boolean
      {
         return _binaryData;
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
      
      override public function clone() : Event
      {
         return new HTTPStreamingIndexHandlerEvent(type,bubbles,cancelable,live,offset,streamNames,rates,request,requestContext,binaryData,segmentDuration,scriptDataObject,scriptDataFirst,scriptDataImmediate);
      }
   }
}

