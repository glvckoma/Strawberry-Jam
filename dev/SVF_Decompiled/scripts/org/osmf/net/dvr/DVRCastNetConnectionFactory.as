package org.osmf.net.dvr
{
   import flash.events.Event;
   import flash.net.NetConnection;
   import flash.net.Responder;
   import flash.utils.Dictionary;
   import org.osmf.events.MediaError;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetConnectionFactory;
   import org.osmf.net.NetConnectionFactoryBase;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   
   public class DVRCastNetConnectionFactory extends NetConnectionFactoryBase
   {
      private var innerFactory:NetConnectionFactoryBase;
      
      private var subscribedStreams:Dictionary = new Dictionary();
      
      public function DVRCastNetConnectionFactory(param1:NetConnectionFactoryBase = null)
      {
         innerFactory = param1 || new NetConnectionFactory();
         innerFactory.addEventListener("creationComplete",onCreationComplete);
         innerFactory.addEventListener("creationError",onCreationError);
         super();
      }
      
      override public function create(param1:URLResource) : void
      {
         innerFactory.create(param1);
      }
      
      override public function closeNetConnection(param1:NetConnection) : void
      {
         var _loc2_:String = subscribedStreams[param1];
         if(_loc2_ != null)
         {
            param1.call("DVRUnsubscribe",null,_loc2_);
            delete subscribedStreams[param1];
         }
         innerFactory.closeNetConnection(param1);
      }
      
      private function onCreationComplete(param1:NetConnectionFactoryEvent) : void
      {
         var streamingResource:StreamingURLResource;
         var urlIncludesFMSApplicationInstance:Boolean;
         var dynamicResource:DynamicStreamingResource;
         var items:Vector.<DynamicStreamingItem>;
         var i:int;
         var responder:Responder;
         var event:NetConnectionFactoryEvent = param1;
         var onStreamSubscriptionResult:* = function(param1:Object):void
         {
            var _loc2_:DVRCastStreamInfoRetriever = null;
            totalRpcSubscribeInvocation--;
            if(totalRpcSubscribeInvocation <= 0)
            {
               _loc2_ = new DVRCastStreamInfoRetriever(netConnection,streamNames[0]);
               _loc2_.addEventListener("complete",onStreamInfoRetrieverComplete);
               _loc2_.retrieve();
            }
         };
         var onStreamInfoRetrieverComplete:* = function(param1:Event):void
         {
            var _loc2_:DVRCastRecordingInfo = null;
            var _loc3_:DVRCastStreamInfoRetriever = param1.target as DVRCastStreamInfoRetriever;
            removeEventListener("creationComplete",onCreationComplete);
            if(_loc3_.streamInfo != null)
            {
               if(_loc3_.streamInfo.offline == true)
               {
                  dispatchEvent(new NetConnectionFactoryEvent("creationError",false,false,netConnection,urlResource,new MediaError(21)));
                  i = 0;
                  while(i < streamNames.length)
                  {
                     netConnection.call("DVRUnsubscribe",null,streamNames[i]);
                     i++;
                  }
                  netConnection = null;
               }
               else
               {
                  _loc2_ = new DVRCastRecordingInfo();
                  _loc2_.startDuration = _loc3_.streamInfo.currentLength;
                  _loc2_.startOffset = calculateOffset(_loc3_.streamInfo);
                  _loc2_.startTime = new Date();
                  streamingResource.addMetadataValue("http://www.osmf.org/dvrCast/1.0/streamInfo",_loc3_.streamInfo);
                  streamingResource.addMetadataValue("http://www.osmf.org/dvrCast/1.0/recordingInfo",_loc2_);
                  subscribedStreams[netConnection] = streamNames[0];
                  dispatchEvent(new NetConnectionFactoryEvent("creationComplete",false,false,netConnection,urlResource));
               }
            }
            else
            {
               onServerCallError(_loc3_.error);
            }
         };
         var onServerCallError:* = function(param1:Object):void
         {
            dispatchEvent(new NetConnectionFactoryEvent("creationError",false,false,netConnection,urlResource,new MediaError(20,!!param1 ? param1.message : "")));
         };
         var urlResource:URLResource = event.resource as URLResource;
         var netConnection:NetConnection = event.netConnection;
         var streamNames:Vector.<String> = new Vector.<String>();
         var totalRpcSubscribeInvocation:int = 0;
         event.stopImmediatePropagation();
         streamingResource = urlResource as StreamingURLResource;
         urlIncludesFMSApplicationInstance = !!streamingResource ? streamingResource.urlIncludesFMSApplicationInstance : false;
         dynamicResource = streamingResource as DynamicStreamingResource;
         if(dynamicResource != null)
         {
            items = dynamicResource.streamItems;
            totalRpcSubscribeInvocation = int(items.length);
            i = 0;
            while(i < items.length)
            {
               streamNames.push(items[i].streamName);
               i++;
            }
         }
         else
         {
            totalRpcSubscribeInvocation = 1;
            streamNames.push(NetStreamUtils.getStreamNameFromURL(urlResource.url,urlIncludesFMSApplicationInstance));
         }
         responder = new TestableResponder(onStreamSubscriptionResult,onServerCallError);
         i = 0;
         while(i < streamNames.length)
         {
            event.netConnection.call("DVRSubscribe",responder,streamNames[i]);
            i++;
         }
      }
      
      private function onCreationError(param1:NetConnectionFactoryEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function calculateOffset(param1:DVRCastStreamInfo) : Number
      {
         return DVRUtils.calculateOffset(param1.beginOffset,param1.endOffset,param1.currentLength);
      }
   }
}

