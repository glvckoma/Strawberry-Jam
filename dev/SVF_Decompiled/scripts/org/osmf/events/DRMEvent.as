package org.osmf.events
{
   import flash.events.Event;
   
   public class DRMEvent extends Event
   {
      public static const DRM_STATE_CHANGE:String = "drmStateChange";
      
      private var _drmState:String;
      
      private var _startDate:Date;
      
      private var _endDate:Date;
      
      private var _period:Number;
      
      private var _serverURL:String;
      
      private var _token:Object;
      
      private var _mediaError:MediaError;
      
      public function DRMEvent(param1:String, param2:String, param3:Boolean = false, param4:Boolean = false, param5:Date = null, param6:Date = null, param7:Number = 0, param8:String = null, param9:Object = null, param10:MediaError = null)
      {
         super(param1,param3,param4);
         _drmState = param2;
         _token = param9;
         _mediaError = param10;
         _startDate = param5;
         _endDate = param6;
         _period = param7;
         _serverURL = param8;
      }
      
      public function get token() : Object
      {
         return _token;
      }
      
      public function get mediaError() : MediaError
      {
         return _mediaError;
      }
      
      public function get startDate() : Date
      {
         return _startDate;
      }
      
      public function get endDate() : Date
      {
         return _endDate;
      }
      
      public function get period() : Number
      {
         return _period;
      }
      
      public function get drmState() : String
      {
         return _drmState;
      }
      
      public function get serverURL() : String
      {
         return _serverURL;
      }
      
      override public function clone() : Event
      {
         return new DRMEvent(type,_drmState,bubbles,cancelable,_startDate,_endDate,_period,_serverURL,_token,_mediaError);
      }
   }
}

