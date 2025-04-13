package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetGroup;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   
   public class MulticastNetLoader extends NetLoader
   {
      public function MulticastNetLoader(param1:NetConnectionFactoryBase = null)
      {
         var _loc2_:NetConnectionFactory = null;
         if(param1 == null)
         {
            _loc2_ = new NetConnectionFactory();
            _loc2_.timeout = 60000;
         }
         super(param1 != null ? param1 : _loc2_);
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:MulticastResource = param1 as MulticastResource;
         return _loc2_ != null && _loc2_.groupspec != null && _loc2_.groupspec.length > 0 && _loc2_.streamName != null && _loc2_.streamName.length > 0;
      }
      
      override protected function createNetStream(param1:NetConnection, param2:URLResource) : NetStream
      {
         var _loc3_:MulticastResource = param2 as MulticastResource;
         return new NetStream(param1,_loc3_.groupspec);
      }
      
      override protected function processCreationComplete(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         var netGroup:NetGroup;
         var connection:NetConnection = param1;
         var loadTrait:LoadTrait = param2;
         var factory:NetConnectionFactoryBase = param3;
         var onNetStatus:* = function(param1:NetStatusEvent):void
         {
            switch(param1.info.code)
            {
               case "NetGroup.Connect.Success":
                  connection.removeEventListener("netStatus",onNetStatus);
                  netLoadTrait.netGroup = netGroup;
                  doProcessCreationComplete(connection,loadTrait,factory);
                  break;
               case "NetGroup.Connect.Failed":
               case "NetGroup.Connect.Rejected":
                  connection.removeEventListener("netStatus",onNetStatus);
                  updateLoadTrait(loadTrait,"loadError");
            }
         };
         var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
         var multicastResource:MulticastResource = netLoadTrait.resource as MulticastResource;
         connection.addEventListener("netStatus",onNetStatus);
         netGroup = new NetGroup(connection,multicastResource.groupspec);
      }
      
      private function doProcessCreationComplete(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         super.processCreationComplete(param1,param2,param3);
      }
   }
}

