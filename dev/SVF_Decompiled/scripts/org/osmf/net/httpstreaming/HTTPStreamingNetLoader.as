package org.osmf.net.httpstreaming
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetLoader;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamSwitchManager;
   import org.osmf.net.NetStreamSwitchManagerBase;
   import org.osmf.net.SwitchingRuleBase;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastDVRTrait;
   import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastTimeTrait;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler;
   import org.osmf.net.rtmpstreaming.DroppedFramesRule;
   
   public class HTTPStreamingNetLoader extends NetLoader
   {
      public function HTTPStreamingNetLoader()
      {
         super();
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         return param1.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") as Metadata != null;
      }
      
      override protected function createNetStream(param1:NetConnection, param2:URLResource) : NetStream
      {
         var _loc3_:HTTPStreamingFileHandlerBase = new HTTPStreamingF4FFileHandler();
         var _loc4_:HTTPStreamingIndexHandlerBase = new HTTPStreamingF4FIndexHandler(_loc3_);
         var _loc5_:HTTPNetStream = new HTTPNetStream(param1,_loc4_,_loc3_);
         _loc5_.manualSwitchMode = true;
         _loc5_.indexInfo = HTTPStreamingUtils.createF4FIndexInfo(param2);
         return _loc5_;
      }
      
      override protected function createNetStreamSwitchManager(param1:NetConnection, param2:NetStream, param3:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         var _loc4_:HTTPNetStreamMetrics = null;
         if(param3 != null)
         {
            _loc4_ = new HTTPNetStreamMetrics(param2 as HTTPNetStream);
            return new NetStreamSwitchManager(param1,param2,param3,_loc4_,getDefaultSwitchingRules(_loc4_));
         }
         return null;
      }
      
      override protected function processFinishLoading(param1:NetStreamLoadTrait) : void
      {
         var netStream:HTTPNetStream;
         var loadTrait:NetStreamLoadTrait = param1;
         var onDVRStreamInfo:* = function(param1:DVRStreamInfoEvent):void
         {
            netStream.removeEventListener("DVRStreamInfo",onDVRStreamInfo);
            loadTrait.setTrait(new HTTPStreamingDVRCastDVRTrait(loadTrait.connection,netStream,param1.info as DVRInfo));
            loadTrait.setTrait(new HTTPStreamingDVRCastTimeTrait(loadTrait.connection,netStream,param1.info as DVRInfo));
            updateLoadTrait(loadTrait,"ready");
         };
         var resource:URLResource = loadTrait.resource as URLResource;
         if(!dvrMetadataPresent(resource))
         {
            updateLoadTrait(loadTrait,"ready");
            return;
         }
         netStream = loadTrait.netStream as HTTPNetStream;
         netStream.addEventListener("DVRStreamInfo",onDVRStreamInfo);
         netStream.DVRGetStreamInfo(null);
      }
      
      private function dvrMetadataPresent(param1:URLResource) : Boolean
      {
         var _loc2_:Metadata = param1.getMetadataValue("http://www.osmf.org/dvr/1.0") as Metadata;
         return _loc2_ != null;
      }
      
      private function getDefaultSwitchingRules(param1:HTTPNetStreamMetrics) : Vector.<SwitchingRuleBase>
      {
         var _loc2_:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
         _loc2_.push(new DownloadRatioRule(param1));
         _loc2_.push(new DroppedFramesRule(param1));
         return _loc2_;
      }
   }
}

