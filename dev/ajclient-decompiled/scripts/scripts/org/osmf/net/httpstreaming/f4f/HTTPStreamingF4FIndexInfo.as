package org.osmf.net.httpstreaming.f4f
{
   import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   
   public class HTTPStreamingF4FIndexInfo extends HTTPStreamingIndexInfoBase
   {
      
      private var _serverBaseURL:String;
      
      private var _dvrInfo:DVRInfo;
      
      private var _streamInfos:Vector.<HTTPStreamingF4FStreamInfo>;
      
      public function HTTPStreamingF4FIndexInfo(param1:String = null, param2:Vector.<HTTPStreamingF4FStreamInfo> = null, param3:DVRInfo = null)
      {
         super();
         _serverBaseURL = param1;
         _streamInfos = param2;
         _dvrInfo = param3;
      }
      
      public function get serverBaseURL() : String
      {
         return _serverBaseURL;
      }
      
      public function get streamInfos() : Vector.<HTTPStreamingF4FStreamInfo>
      {
         return _streamInfos;
      }
      
      public function get dvrInfo() : DVRInfo
      {
         return _dvrInfo;
      }
   }
}

