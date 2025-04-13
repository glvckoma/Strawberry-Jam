package org.osmf.net
{
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.utils.URL;
   
   public class NetStreamUtils
   {
      public static const PLAY_START_ARG_ANY:int = -2;
      
      public static const PLAY_START_ARG_LIVE:int = -1;
      
      public static const PLAY_START_ARG_RECORDED:int = 0;
      
      public static const PLAY_LEN_ARG_ALL:int = -1;
      
      public function NetStreamUtils()
      {
         super();
      }
      
      public static function getStreamNameFromURL(param1:String, param2:Boolean = false) : String
      {
         var _loc3_:FMSURL = null;
         var _loc4_:* = "";
         if(param1 != null)
         {
            if(isRTMPStream(param1))
            {
               _loc3_ = new FMSURL(param1,param2);
               _loc4_ = _loc3_.streamName;
               if(_loc3_.query != null && _loc3_.query != "")
               {
                  _loc4_ += "?" + _loc3_.query;
               }
            }
            else
            {
               _loc4_ = param1;
            }
         }
         return _loc4_;
      }
      
      public static function isStreamingResource(param1:MediaResourceBase) : Boolean
      {
         var _loc3_:URLResource = null;
         var _loc2_:* = false;
         if(param1 != null)
         {
            _loc3_ = param1 as URLResource;
            if(_loc3_ != null)
            {
               _loc2_ = Boolean(NetStreamUtils.isRTMPStream(_loc3_.url));
               if(_loc2_ == false)
               {
                  _loc2_ = _loc3_.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") != null;
               }
            }
         }
         return _loc2_;
      }
      
      public static function isRTMPStream(param1:String) : Boolean
      {
         var _loc4_:URL = null;
         var _loc3_:String = null;
         var _loc2_:* = false;
         if(param1 != null)
         {
            _loc4_ = new URL(param1);
            _loc3_ = _loc4_.protocol;
            if(_loc3_ != null && _loc3_.length > 0)
            {
               _loc2_ = _loc3_.search(/^rtmp$|rtmp[tse]$|rtmpte$/i) != -1;
            }
         }
         return _loc2_;
      }
      
      public static function getStreamType(param1:MediaResourceBase) : String
      {
         var _loc2_:String = "recorded";
         var _loc3_:StreamingURLResource = param1 as StreamingURLResource;
         if(_loc3_ != null)
         {
            _loc2_ = _loc3_.streamType;
         }
         return _loc2_;
      }
      
      public static function getPlayArgsForResource(param1:MediaResourceBase) : Object
      {
         var _loc2_:StreamingURLResource = null;
         var _loc3_:Number = -2;
         var _loc4_:Number = -1;
         switch(getStreamType(param1))
         {
            case "liveOrRecorded":
               _loc3_ = -2;
               break;
            case "live":
               _loc3_ = -1;
               break;
            case "recorded":
               _loc3_ = PLAY_START_ARG_RECORDED;
         }
         if(_loc3_ != -1 && param1 != null)
         {
            _loc2_ = param1 as StreamingURLResource;
            if(_loc2_ != null && isStreamingResource(_loc2_))
            {
               if(!isNaN(_loc2_.clipStartTime))
               {
                  _loc3_ = _loc2_.clipStartTime;
               }
               if(!isNaN(_loc2_.clipEndTime))
               {
                  _loc3_ = Math.max(0,_loc3_);
                  _loc4_ = Math.max(0,_loc2_.clipEndTime - _loc3_);
               }
            }
         }
         return {
            "start":_loc3_,
            "len":_loc4_
         };
      }
   }
}

