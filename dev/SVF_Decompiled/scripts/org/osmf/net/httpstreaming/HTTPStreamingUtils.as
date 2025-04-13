package org.osmf.net.httpstreaming
{
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FStreamInfo;
   
   public class HTTPStreamingUtils
   {
      public function HTTPStreamingUtils()
      {
         super();
      }
      
      public static function createHTTPStreamingMetadata(param1:String, param2:ByteArray, param3:Vector.<String>) : Metadata
      {
         var _loc4_:Metadata = new Metadata();
         var _loc5_:BootstrapInfo = new BootstrapInfo();
         if(param1 != null && param1.length > 0)
         {
            _loc5_.url = param1;
         }
         _loc5_.data = param2;
         _loc4_.addValue("bootstrap",_loc5_);
         if(param3 != null && param3.length > 0)
         {
            _loc4_.addValue("serverBaseUrls",param3);
         }
         return _loc4_;
      }
      
      public static function createF4FIndexInfo(param1:URLResource) : HTTPStreamingF4FIndexInfo
      {
         var _loc2_:* = undefined;
         var _loc6_:* = undefined;
         var _loc4_:DVRInfo = null;
         var _loc3_:HTTPStreamingF4FIndexInfo = null;
         var _loc5_:Metadata = param1.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") as Metadata;
         var _loc7_:Metadata = param1.getMetadataValue("http://www.osmf.org/dvr/1.0") as Metadata;
         if(_loc5_ != null)
         {
            _loc2_ = _loc5_.getValue("serverBaseUrls") as Vector.<String>;
            _loc6_ = generateStreamInfos(param1);
            _loc4_ = generateDVRInfo(_loc7_);
            _loc3_ = new HTTPStreamingF4FIndexInfo(_loc2_ != null && _loc2_.length > 0 ? _loc2_[0] : null,_loc6_,_loc4_);
         }
         return _loc3_;
      }
      
      public static function normalizeURL(param1:String) : String
      {
         var _loc4_:* = null;
         var _loc6_:int = 0;
         var _loc2_:* = "";
         var _loc3_:String = "";
         if(param1.indexOf("http://") == 0)
         {
            _loc3_ = "http://";
         }
         else if(param1.indexOf("https://") == 0)
         {
            _loc3_ = "https://";
         }
         if(_loc3_.length > 0)
         {
            _loc4_ = param1.substr(_loc3_.length);
         }
         else
         {
            _loc4_ = param1;
         }
         var _loc7_:Array = _loc4_.split("/");
         var _loc5_:int = int(_loc7_.indexOf(".."));
         while(_loc5_ >= 0)
         {
            _loc7_.splice(_loc5_ - 1,2);
            _loc5_ = int(_loc7_.indexOf(".."));
         }
         _loc2_ = _loc3_;
         if(_loc7_.length > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc7_.length)
            {
               if(_loc6_ != 0)
               {
                  _loc2_ += "/";
               }
               _loc2_ += _loc7_[_loc6_] as String;
               _loc6_++;
            }
         }
         return _loc2_;
      }
      
      private static function generateDVRInfo(param1:Metadata) : DVRInfo
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:DVRInfo = new DVRInfo();
         _loc2_.id = "";
         _loc2_.beginOffset = NaN;
         _loc2_.endOffset = NaN;
         _loc2_.offline = false;
         if(param1.getValue("dvrId") != null)
         {
            _loc2_.id = param1.getValue("dvrId") as String;
         }
         if(param1.getValue("beginOffset") != null)
         {
            _loc2_.beginOffset = param1.getValue("beginOffset") as uint;
         }
         if(param1.getValue("endOffset") != null)
         {
            _loc2_.endOffset = param1.getValue("endOffset") as uint;
         }
         if(param1.getValue("dvrOffline") != null)
         {
            _loc2_.offline = param1.getValue("dvrOffline") as Boolean;
         }
         return _loc2_;
      }
      
      private static function generateStreamInfos(param1:URLResource) : Vector.<HTTPStreamingF4FStreamInfo>
      {
         var _loc5_:Object = null;
         var _loc8_:ByteArray = null;
         var _loc11_:String = null;
         var _loc10_:Vector.<HTTPStreamingF4FStreamInfo> = new Vector.<HTTPStreamingF4FStreamInfo>();
         var _loc6_:Metadata = param1.getMetadataValue("http://www.osmf.org/drm/1.0") as Metadata;
         var _loc9_:Metadata = param1.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") as Metadata;
         var _loc2_:ByteArray = null;
         var _loc7_:BootstrapInfo = null;
         var _loc4_:DynamicStreamingResource = param1 as DynamicStreamingResource;
         if(_loc4_ != null)
         {
            for each(var _loc3_ in _loc4_.streamItems)
            {
               _loc2_ = null;
               _loc7_ = null;
               _loc5_ = null;
               _loc8_ = null;
               if(_loc6_ != null)
               {
                  _loc2_ = _loc6_.getValue("DRMAdditionalHeader" + _loc3_.streamName) as ByteArray;
               }
               if(_loc9_ != null)
               {
                  _loc7_ = _loc9_.getValue("bootstrap" + _loc3_.streamName) as BootstrapInfo;
                  _loc5_ = _loc9_.getValue("streamMetadata" + _loc3_.streamName);
                  _loc8_ = _loc9_.getValue("xmpMetadata" + _loc3_.streamName) as ByteArray;
               }
               _loc10_.push(new HTTPStreamingF4FStreamInfo(_loc7_,_loc3_.streamName,_loc3_.bitrate,_loc2_,_loc5_,_loc8_));
            }
         }
         else
         {
            if(_loc6_ != null)
            {
               _loc2_ = _loc6_.getValue("DRMAdditionalHeader") as ByteArray;
            }
            if(_loc9_ != null)
            {
               _loc7_ = _loc9_.getValue("bootstrap") as BootstrapInfo;
               _loc5_ = _loc9_.getValue("streamMetadata");
               _loc8_ = _loc9_.getValue("xmpMetadata") as ByteArray;
            }
            _loc11_ = param1.url;
            _loc10_.push(new HTTPStreamingF4FStreamInfo(_loc7_,_loc11_,NaN,_loc2_,_loc5_,_loc8_));
         }
         return _loc10_;
      }
   }
}

