package org.osmf.net.dvr
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
   
   public class DVRCastNetLoader extends RTMPDynamicStreamingNetLoader
   {
      public function DVRCastNetLoader(param1:DVRCastNetConnectionFactory = null)
      {
         if(param1 == null)
         {
            param1 = new DVRCastNetConnectionFactory();
         }
         super(param1);
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc3_:StreamingURLResource = null;
         if(super.canHandleResource(param1))
         {
            _loc3_ = param1 as StreamingURLResource;
            if(_loc3_ != null)
            {
               _loc2_ = _loc3_.streamType == "dvr" && NetStreamUtils.isRTMPStream(_loc3_.url);
            }
         }
         return _loc2_;
      }
      
      override protected function createNetStream(param1:NetConnection, param2:URLResource) : NetStream
      {
         return new DVRCastNetStream(param1,param2);
      }
      
      override protected function processFinishLoading(param1:NetStreamLoadTrait) : void
      {
         param1.setTrait(new DVRCastDVRTrait(param1.connection,param1.netStream,param1.resource));
         param1.setTrait(new DVRCastTimeTrait(param1.connection,param1.netStream,param1.resource));
         updateLoadTrait(param1,"ready");
      }
   }
}

