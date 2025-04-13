package org.osmf.events
{
   import org.osmf.utils.OSMFStrings;
   
   public final class MediaErrorCodes
   {
      public static const IO_ERROR:int = 1;
      
      public static const SECURITY_ERROR:int = 2;
      
      public static const ASYNC_ERROR:int = 3;
      
      public static const ARGUMENT_ERROR:int = 4;
      
      public static const URL_SCHEME_INVALID:int = 5;
      
      public static const HTTP_GET_FAILED:int = 6;
      
      public static const MEDIA_LOAD_FAILED:int = 7;
      
      public static const PLUGIN_VERSION_INVALID:int = 8;
      
      public static const PLUGIN_IMPLEMENTATION_INVALID:int = 9;
      
      public static const SOUND_PLAY_FAILED:int = 10;
      
      public static const NETCONNECTION_REJECTED:int = 11;
      
      public static const NETCONNECTION_APPLICATION_INVALID:int = 12;
      
      public static const NETCONNECTION_FAILED:int = 13;
      
      public static const NETCONNECTION_TIMEOUT:int = 14;
      
      public static const NETSTREAM_PLAY_FAILED:int = 15;
      
      public static const NETSTREAM_STREAM_NOT_FOUND:int = 16;
      
      public static const NETSTREAM_FILE_STRUCTURE_INVALID:int = 17;
      
      public static const NETSTREAM_NO_SUPPORTED_TRACK_FOUND:int = 18;
      
      public static const DRM_SYSTEM_UPDATE_ERROR:int = 19;
      
      public static const DVRCAST_SUBSCRIBE_FAILED:int = 20;
      
      public static const DVRCAST_CONTENT_OFFLINE:int = 21;
      
      public static const DVRCAST_STREAM_INFO_RETRIEVAL_FAILED:int = 22;
      
      public static const F4M_FILE_INVALID:int = 23;
      
      private static const errorMap:Array = [{
         "errorID":1,
         "message":"ioError"
      },{
         "errorID":2,
         "message":"securityError"
      },{
         "errorID":3,
         "message":"asyncError"
      },{
         "errorID":4,
         "message":"argumentError"
      },{
         "errorID":5,
         "message":"urlSchemeInvalid"
      },{
         "errorID":6,
         "message":"httpGetFailed"
      },{
         "errorID":7,
         "message":"mediaLoadFailed"
      },{
         "errorID":8,
         "message":"pluginVersionInvalid"
      },{
         "errorID":9,
         "message":"pluginImplementationInvalid"
      },{
         "errorID":10,
         "message":"soundPlayFailed"
      },{
         "errorID":11,
         "message":"netConnectionRejected"
      },{
         "errorID":12,
         "message":"netConnectionApplicationInvalid"
      },{
         "errorID":13,
         "message":"netConnectionFailed"
      },{
         "errorID":14,
         "message":"netConnectionTimeout"
      },{
         "errorID":15,
         "message":"netStreamPlayFailed"
      },{
         "errorID":16,
         "message":"netStreamStreamNotFound"
      },{
         "errorID":17,
         "message":"netStreamFileStructureInvalid"
      },{
         "errorID":18,
         "message":"netStreamNoSupportedTrackFound"
      },{
         "errorID":19,
         "message":"drmSystemUpdateError"
      },{
         "errorID":20,
         "message":"dvrCastSubscribeFailed"
      },{
         "errorID":21,
         "message":"dvrCastContentOffline"
      },{
         "errorID":22,
         "message":"dvrCastStreamInfoRetrievalFailed"
      },{
         "errorID":23,
         "message":"f4MFileINVALID"
      }];
      
      public function MediaErrorCodes()
      {
         super();
      }
      
      internal static function getMessageForErrorID(param1:int) : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = "";
         _loc2_ = 0;
         while(_loc2_ < errorMap.length)
         {
            if(errorMap[_loc2_].errorID == param1)
            {
               _loc3_ = OSMFStrings.getString(errorMap[_loc2_].message);
               break;
            }
            _loc2_++;
         }
         return _loc3_;
      }
   }
}

