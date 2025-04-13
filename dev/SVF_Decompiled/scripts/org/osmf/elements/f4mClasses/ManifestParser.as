package org.osmf.elements.f4mClasses
{
   import flash.utils.ByteArray;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.MulticastResource;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.URL;
   
   public class ManifestParser
   {
      private namespace xmlns = "http://ns.adobe.com/f4m/1.0";
      
      public function ManifestParser()
      {
         super();
      }
      
      public function parse(param1:String, param2:String = null) : Manifest
      {
         var _loc10_:Media = null;
         var _loc5_:Manifest = new Manifest();
         var _loc12_:Boolean = false;
         var _loc9_:XML = new XML(param1);
         if(_loc9_.id.length() > 0)
         {
            _loc5_.id = _loc9_.id.text();
         }
         if(_loc9_.duration.length() > 0)
         {
            _loc5_.duration = _loc9_.duration.text();
         }
         if(_loc9_.startTime.length() > 0)
         {
            _loc5_.startTime = DateUtil.parseW3CDTF(_loc9_.startTime.text());
         }
         if(_loc9_.mimeType.length() > 0)
         {
            _loc5_.mimeType = _loc9_.mimeType.text();
         }
         if(_loc9_.streamType.length() > 0)
         {
            _loc5_.streamType = _loc9_.streamType.text();
         }
         if(_loc9_.deliveryType.length() > 0)
         {
            _loc5_.deliveryType = _loc9_.deliveryType.text();
         }
         if(_loc9_.baseURL.length() > 0)
         {
            _loc5_.baseURL = _loc9_.baseURL.text();
         }
         if(_loc9_.urlIncludesFMSApplicationInstance.length() > 0)
         {
            _loc5_.urlIncludesFMSApplicationInstance = _loc9_.urlIncludesFMSApplicationInstance.text() == "true";
         }
         var _loc8_:String = _loc5_.baseURL != null ? _loc5_.baseURL : param2;
         var _loc15_:int = 0;
         var _loc14_:* = _loc9_.dvrInfo;
         for each(var _loc11_ in _loc14_)
         {
            parseDVRInfo(_loc11_,_loc8_,_loc5_);
         }
         var _loc6_:* = false;
         var _loc3_:Boolean = false;
         for each(var _loc7_ in _loc9_.media)
         {
            _loc10_ = parseMedia(_loc7_,_loc8_);
            if(_loc10_.multicastGroupspec != null && _loc10_.multicastGroupspec.length > 0 && (_loc10_.multicastStreamName == null || _loc10_.multicastStreamName.length <= 0) || _loc10_.multicastStreamName != null && _loc10_.multicastStreamName.length > 0 && (_loc10_.multicastGroupspec == null || _loc10_.multicastGroupspec.length <= 0))
            {
               _loc3_ = true;
            }
            if(_loc10_.multicastGroupspec != null && _loc10_.multicastGroupspec.length > 0)
            {
               _loc12_ = true;
            }
            _loc5_.media.push(_loc10_);
            if(!_loc6_)
            {
               _loc6_ = isNaN(_loc10_.bitrate);
            }
         }
         if(_loc3_)
         {
            throw new ArgumentError(OSMFStrings.getString("multicastParameterInvalid"));
         }
         if(_loc5_.media.length > 1 && _loc12_)
         {
            throw new ArgumentError(OSMFStrings.getString("multicastNotSupportMBR"));
         }
         if(_loc12_)
         {
            _loc5_.streamType = "live";
         }
         if(_loc5_.media.length > 1 && _loc6_)
         {
            throw new ArgumentError(OSMFStrings.getString("f4mBitrateMissing"));
         }
         for each(var _loc4_ in _loc9_.drmAdditionalHeader)
         {
            parseDRMAdditionalHeader(_loc4_,_loc5_.media,_loc8_,_loc5_);
         }
         for each(var _loc13_ in _loc9_.bootstrapInfo)
         {
            parseBootstrapInfo(_loc13_,_loc5_.media,_loc8_,_loc5_);
         }
         generateRTMPBaseURL(_loc5_);
         return _loc5_;
      }
      
      private function parseMedia(param1:XML, param2:String) : Media
      {
         var _loc6_:Base64Decoder = null;
         var _loc4_:ByteArray = null;
         var _loc5_:String = null;
         var _loc3_:Object = null;
         var _loc7_:Media = new Media();
         if(param1.attribute("url").length() > 0)
         {
            _loc7_.url = param1.@url;
            if(param1.attribute("bitrate").length() > 0)
            {
               _loc7_.bitrate = param1.@bitrate;
            }
            if(param1.attribute("drmAdditionalHeaderId").length() > 0)
            {
               _loc7_.drmAdditionalHeader.id = param1.@drmAdditionalHeaderId;
            }
            if(param1.attribute("bootstrapInfoId").length() > 0)
            {
               _loc7_.bootstrapInfo = new BootstrapInfo();
               _loc7_.bootstrapInfo.id = param1.@bootstrapInfoId;
            }
            if(param1.attribute("height").length() > 0)
            {
               _loc7_.height = param1.@height;
            }
            if(param1.attribute("width").length() > 0)
            {
               _loc7_.width = param1.@width;
            }
            if(param1.attribute("groupspec").length() > 0)
            {
               _loc7_.multicastGroupspec = param1.@groupspec;
            }
            if(param1.attribute("multicastStreamName").length() > 0)
            {
               _loc7_.multicastStreamName = param1.@multicastStreamName;
            }
            if(param1.moov.length() > 0)
            {
               _loc6_ = new Base64Decoder();
               _loc6_.decode(param1.moov.text());
               _loc7_.moov = _loc6_.drain();
            }
            if(param1.metadata.length() > 0)
            {
               _loc6_ = new Base64Decoder();
               _loc6_.decode(param1.metadata.text());
               _loc4_ = _loc6_.drain();
               _loc4_.position = 0;
               _loc4_.objectEncoding = 0;
               try
               {
                  _loc5_ = _loc4_.readObject() as String;
                  _loc3_ = _loc4_.readObject();
                  _loc7_.metadata = _loc3_;
               }
               catch(e:Error)
               {
               }
            }
            if(param1.xmpMetadata.length() > 0)
            {
               _loc6_ = new Base64Decoder();
               _loc6_.decode(param1.xmpMetadata.text());
               _loc7_.xmp = _loc6_.drain();
            }
            return _loc7_;
         }
         throw new ArgumentError(OSMFStrings.getString("f4mMediaURLMissing"));
      }
      
      private function parseDVRInfo(param1:XML, param2:String, param3:Manifest) : void
      {
         var _loc7_:String = null;
         var _loc5_:Number = NaN;
         var _loc4_:String = null;
         var _loc6_:DVRInfo = new DVRInfo();
         if(param1.attribute("id").length() > 0)
         {
            _loc6_.id = param1.@id;
         }
         if(param1.attribute("url").length() > 0)
         {
            _loc7_ = param1.@url;
            if(!isAbsoluteURL(_loc7_))
            {
               _loc7_ = param2 + "/" + _loc7_;
            }
            _loc6_.url = _loc7_;
         }
         if(param1.attribute("beginOffset").length() > 0)
         {
            _loc6_.beginOffset = Math.max(0,parseInt(param1.@beginOffset));
         }
         if(param1.attribute("endOffset").length() > 0)
         {
            _loc5_ = new Number(param1.@endOffset);
            if(_loc5_ > 0 && _loc5_ < 1)
            {
               _loc6_.endOffset = 1;
            }
            else
            {
               _loc6_.endOffset = Math.max(0,_loc5_);
            }
         }
         if(param1.attribute("offline").length() > 0)
         {
            _loc4_ = param1.@offline;
            _loc6_.offline = _loc4_.toLowerCase() == "true";
         }
         param3.dvrInfo = _loc6_;
      }
      
      private function parseDRMAdditionalHeader(param1:XML, param2:Vector.<Media>, param3:String, param4:Manifest) : void
      {
         var _loc7_:* = null;
         var _loc5_:String = null;
         var _loc8_:Base64Decoder = null;
         var _loc9_:String = null;
         var _loc6_:DRMAdditionalHeader = new DRMAdditionalHeader();
         if(param1.attribute("id").length() > 0)
         {
            _loc6_.id = param1.@id;
         }
         if(param1.attribute("url").length() > 0)
         {
            _loc9_ = param1.@url;
            if(!isAbsoluteURL(_loc9_))
            {
               _loc9_ = param3 + "/" + _loc9_;
            }
            _loc6_.url = _loc9_;
         }
         else
         {
            _loc5_ = param1.text();
            _loc8_ = new Base64Decoder();
            _loc8_.decode(_loc5_);
            _loc6_.data = _loc8_.drain();
         }
         param4.drmAdditionalHeaders.push(_loc6_);
         for each(_loc7_ in param2)
         {
            if(_loc7_.drmAdditionalHeader.id == _loc6_.id)
            {
               _loc7_.drmAdditionalHeader = _loc6_;
            }
         }
      }
      
      private function parseBootstrapInfo(param1:XML, param2:Vector.<Media>, param3:String, param4:Manifest) : void
      {
         var _loc7_:* = null;
         var _loc5_:String = null;
         var _loc8_:Base64Decoder = null;
         var _loc9_:String = null;
         var _loc6_:BootstrapInfo = new BootstrapInfo();
         if(param1.attribute("profile").length() > 0)
         {
            _loc6_.profile = param1.@profile;
            if(param1.attribute("id").length() > 0)
            {
               _loc6_.id = param1.@id;
            }
            if(param1.attribute("url").length() > 0)
            {
               _loc9_ = param1.@url;
               if(!isAbsoluteURL(_loc9_) && param3 != null)
               {
                  _loc9_ = param3 + "/" + _loc9_;
               }
               _loc6_.url = _loc9_;
            }
            else
            {
               _loc5_ = param1.text();
               _loc8_ = new Base64Decoder();
               _loc8_.decode(_loc5_);
               _loc6_.data = _loc8_.drain();
            }
            for each(_loc7_ in param2)
            {
               if(_loc7_.bootstrapInfo == null)
               {
                  _loc7_.bootstrapInfo = _loc6_;
               }
               else if(_loc7_.bootstrapInfo.id == _loc6_.id)
               {
                  _loc7_.bootstrapInfo = _loc6_;
               }
            }
            return;
         }
         throw new ArgumentError(OSMFStrings.getString("f4mProfileMissing"));
      }
      
      private function generateRTMPBaseURL(param1:Manifest) : void
      {
         if(param1.baseURL == null)
         {
            for each(var _loc2_ in param1.media)
            {
               if(NetStreamUtils.isRTMPStream(_loc2_.url))
               {
                  param1.baseURL = _loc2_.url;
                  break;
               }
            }
         }
      }
      
      public function createResource(param1:Manifest, param2:URLResource) : MediaResourceBase
      {
         var _loc6_:StreamingURLResource = null;
         var _loc8_:Media = null;
         var _loc11_:* = undefined;
         var _loc10_:String = null;
         var _loc19_:String = null;
         var _loc13_:* = null;
         var _loc12_:String = null;
         var _loc18_:DynamicStreamingResource = null;
         var _loc9_:* = undefined;
         var _loc14_:String = null;
         var _loc4_:DynamicStreamingItem = null;
         var _loc16_:Metadata = null;
         var _loc17_:Metadata = null;
         var _loc15_:URL = new URL(param2.url);
         var _loc3_:String = "/" + _loc15_.path;
         _loc3_ = _loc3_.substr(0,_loc3_.lastIndexOf("/"));
         var _loc7_:String = _loc15_.protocol + "://" + _loc15_.host + (_loc15_.port != "" ? ":" + _loc15_.port : "") + _loc3_;
         if(param1.media.length == 1)
         {
            _loc8_ = param1.media[0] as Media;
            _loc10_ = _loc8_.url;
            _loc13_ = null;
            if(isAbsoluteURL(_loc10_))
            {
               _loc13_ = _loc8_.url.substr(0,_loc8_.url.lastIndexOf("/"));
            }
            else if(param1.baseURL != null)
            {
               _loc13_ = param1.baseURL;
            }
            else
            {
               _loc13_ = _loc7_;
            }
            if(_loc8_.multicastGroupspec != null && _loc8_.multicastGroupspec.length > 0 && _loc8_.multicastStreamName != null && _loc8_.multicastStreamName.length > 0)
            {
               if(isAbsoluteURL(_loc10_))
               {
                  _loc6_ = new MulticastResource(_loc10_,param1.streamType);
               }
               else if(param1.baseURL != null)
               {
                  _loc6_ = new MulticastResource(param1.baseURL + "/" + _loc10_,streamType(param1));
               }
               else
               {
                  _loc6_ = new MulticastResource(_loc7_ + "/" + _loc10_,streamType(param1));
               }
               MulticastResource(_loc6_).groupspec = _loc8_.multicastGroupspec;
               MulticastResource(_loc6_).streamName = _loc8_.multicastStreamName;
            }
            else if(isAbsoluteURL(_loc10_))
            {
               _loc6_ = new StreamingURLResource(_loc10_,param1.streamType);
            }
            else if(param1.baseURL != null)
            {
               _loc6_ = new StreamingURLResource(param1.baseURL + "/" + _loc10_,streamType(param1));
            }
            else
            {
               _loc6_ = new StreamingURLResource(_loc7_ + "/" + _loc10_,streamType(param1));
            }
            _loc6_.urlIncludesFMSApplicationInstance = param1.urlIncludesFMSApplicationInstance;
            if(_loc8_.bootstrapInfo != null)
            {
               _loc11_ = new Vector.<String>();
               _loc11_.push(_loc13_);
               _loc19_ = _loc8_.bootstrapInfo.url;
               if(_loc8_.bootstrapInfo.url != null && isAbsoluteURL(_loc8_.bootstrapInfo.url) == false)
               {
                  _loc19_ = _loc7_ + "/" + _loc19_;
                  _loc8_.bootstrapInfo.url = _loc19_;
               }
               _loc17_ = new Metadata();
               _loc17_.addValue("bootstrap",_loc8_.bootstrapInfo);
               if(_loc11_.length > 0)
               {
                  _loc17_.addValue("serverBaseUrls",_loc11_);
               }
            }
            if(_loc8_.metadata != null)
            {
               if(_loc17_ == null)
               {
                  _loc17_ = new Metadata();
               }
               _loc17_.addValue("streamMetadata",_loc8_.metadata);
            }
            if(_loc8_.xmp != null)
            {
               if(_loc17_ == null)
               {
                  _loc17_ = new Metadata();
               }
               _loc17_.addValue("xmpMetadata",_loc8_.xmp);
            }
            if(_loc8_.drmAdditionalHeader != null)
            {
               _loc16_ = new Metadata();
               if(Media(param1.media[0]).drmAdditionalHeader != null && Media(param1.media[0]).drmAdditionalHeader.data != null)
               {
                  _loc16_.addValue("DRMAdditionalHeader",Media(param1.media[0]).drmAdditionalHeader.data);
                  _loc6_.drmContentData = extractDRMMetadata(Media(param1.media[0]).drmAdditionalHeader.data);
               }
            }
            if(_loc17_ != null)
            {
               _loc6_.addMetadataValue("http://www.osmf.org/httpstreaming/1.0",_loc17_);
            }
            if(_loc16_ != null)
            {
               _loc6_.addMetadataValue("http://www.osmf.org/drm/1.0",_loc16_);
            }
         }
         else if(param1.media.length > 1)
         {
            _loc12_ = param1.baseURL != null ? param1.baseURL : _loc7_;
            _loc11_ = new Vector.<String>();
            _loc11_.push(_loc12_);
            _loc18_ = new DynamicStreamingResource(_loc12_,streamType(param1));
            _loc18_.urlIncludesFMSApplicationInstance = param1.urlIncludesFMSApplicationInstance;
            _loc9_ = new Vector.<DynamicStreamingItem>();
            if(NetStreamUtils.isRTMPStream(_loc12_) == false)
            {
               _loc17_ = new Metadata();
               _loc18_.addMetadataValue("http://www.osmf.org/httpstreaming/1.0",_loc17_);
               _loc17_.addValue("serverBaseUrls",_loc11_);
            }
            for each(_loc8_ in param1.media)
            {
               if(isAbsoluteURL(_loc8_.url))
               {
                  _loc14_ = NetStreamUtils.getStreamNameFromURL(_loc8_.url);
               }
               else
               {
                  _loc14_ = _loc8_.url;
               }
               _loc4_ = new DynamicStreamingItem(_loc14_,_loc8_.bitrate,_loc8_.width,_loc8_.height);
               _loc9_.push(_loc4_);
               if(_loc8_.drmAdditionalHeader != null)
               {
                  if(_loc18_.getMetadataValue("http://www.osmf.org/drm/1.0") == null)
                  {
                     _loc16_ = new Metadata();
                     _loc18_.addMetadataValue("http://www.osmf.org/drm/1.0",_loc16_);
                  }
                  if(_loc8_.drmAdditionalHeader != null && _loc8_.drmAdditionalHeader.data != null)
                  {
                     _loc16_.addValue(_loc4_.streamName,extractDRMMetadata(_loc8_.drmAdditionalHeader.data));
                     _loc16_.addValue("DRMAdditionalHeader" + _loc4_.streamName,_loc8_.drmAdditionalHeader.data);
                  }
               }
               if(_loc8_.bootstrapInfo != null)
               {
                  _loc19_ = !!_loc8_.bootstrapInfo.url ? _loc8_.bootstrapInfo.url : null;
                  if(_loc8_.bootstrapInfo.url != null && isAbsoluteURL(_loc8_.bootstrapInfo.url) == false)
                  {
                     _loc19_ = _loc7_ + "/" + _loc19_;
                     _loc8_.bootstrapInfo.url = _loc19_;
                  }
                  _loc17_.addValue("bootstrap" + _loc4_.streamName,_loc8_.bootstrapInfo);
               }
               if(_loc8_.metadata != null)
               {
                  _loc17_.addValue("streamMetadata" + _loc4_.streamName,_loc8_.metadata);
               }
               if(_loc8_.xmp != null)
               {
                  _loc17_.addValue("xmpMetadata" + _loc4_.streamName,_loc8_.xmp);
               }
            }
            _loc18_.streamItems = _loc9_;
            _loc6_ = _loc18_;
         }
         else if(param1.baseURL == null)
         {
            throw new ArgumentError(OSMFStrings.getString("f4mMediaURLMissing"));
         }
         if(param1.mimeType != null)
         {
            _loc6_.mediaType = "video";
            _loc6_.mimeType = param1.mimeType;
         }
         var _loc5_:StreamingURLResource = param2 as StreamingURLResource;
         if(_loc5_ != null)
         {
            _loc6_.clipStartTime = _loc5_.clipStartTime;
            _loc6_.clipEndTime = _loc5_.clipEndTime;
         }
         _loc6_.addMetadataValue("http://www.osmf.org/derivedResource/1.0",param2);
         addDVRInfo(param1,_loc6_);
         return _loc6_;
      }
      
      private function isAbsoluteURL(param1:String) : Boolean
      {
         var _loc2_:URL = new URL(param1);
         return _loc2_.absolute;
      }
      
      private function extractDRMMetadata(param1:ByteArray) : ByteArray
      {
         var _loc4_:Object = null;
         var _loc3_:Object = null;
         var _loc6_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Object = null;
         var _loc5_:Object = null;
         var _loc7_:String = null;
         var _loc8_:Base64Decoder = null;
         var _loc2_:ByteArray = null;
         param1.position = 0;
         param1.objectEncoding = 0;
         try
         {
            _loc4_ = param1.readObject();
            _loc3_ = param1.readObject();
            _loc6_ = _loc3_["Encryption"];
            _loc9_ = _loc6_["Params"];
            _loc10_ = _loc9_["KeyInfo"];
            _loc5_ = _loc10_["FMRMS_METADATA"];
            _loc7_ = _loc5_["Metadata"] as String;
            _loc8_ = new Base64Decoder();
            _loc8_.decode(_loc7_);
            _loc2_ = _loc8_.drain();
         }
         catch(e:Error)
         {
            _loc2_ = null;
         }
         return _loc2_;
      }
      
      private function addDVRInfo(param1:Manifest, param2:StreamingURLResource) : void
      {
         if(param1.dvrInfo == null)
         {
            return;
         }
         var _loc3_:Metadata = new Metadata();
         _loc3_.addValue("beginOffset",param1.dvrInfo.beginOffset);
         _loc3_.addValue("endOffset",param1.dvrInfo.endOffset);
         _loc3_.addValue("dvrOffline",param1.dvrInfo.offline);
         _loc3_.addValue("dvrId",param1.dvrInfo.id);
         param2.addMetadataValue("http://www.osmf.org/dvr/1.0",_loc3_);
      }
      
      private function streamType(param1:Manifest) : String
      {
         return param1.streamType == "live" && param1.dvrInfo != null ? "dvr" : param1.streamType;
      }
   }
}

