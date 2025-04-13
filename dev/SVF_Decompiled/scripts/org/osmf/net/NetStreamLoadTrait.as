package org.osmf.net
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetGroup;
   import flash.net.NetStream;
   import flash.utils.Dictionary;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   public class NetStreamLoadTrait extends LoadTrait
   {
      private var _connection:NetConnection;
      
      private var _switchManager:NetStreamSwitchManagerBase;
      
      private var traits:Dictionary = new Dictionary();
      
      private var _netConnectionFactory:NetConnectionFactoryBase;
      
      private var isStreamingResource:Boolean;
      
      private var _netStream:NetStream;
      
      private var _netGroup:NetGroup;
      
      public function NetStreamLoadTrait(param1:LoaderBase, param2:MediaResourceBase)
      {
         super(param1,param2);
         isStreamingResource = NetStreamUtils.isStreamingResource(param2);
      }
      
      public function get connection() : NetConnection
      {
         return _connection;
      }
      
      public function set connection(param1:NetConnection) : void
      {
         _connection = param1;
      }
      
      public function get netStream() : NetStream
      {
         return _netStream;
      }
      
      public function set netStream(param1:NetStream) : void
      {
         _netStream = param1;
      }
      
      public function get netGroup() : NetGroup
      {
         return _netGroup;
      }
      
      public function set netGroup(param1:NetGroup) : void
      {
         _netGroup = param1;
      }
      
      public function get switchManager() : NetStreamSwitchManagerBase
      {
         return _switchManager;
      }
      
      public function set switchManager(param1:NetStreamSwitchManagerBase) : void
      {
         _switchManager = param1;
      }
      
      public function setTrait(param1:MediaTraitBase) : void
      {
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         traits[param1.traitType] = param1;
      }
      
      public function getTrait(param1:String) : MediaTraitBase
      {
         return traits[param1];
      }
      
      public function get netConnectionFactory() : NetConnectionFactoryBase
      {
         return _netConnectionFactory;
      }
      
      public function set netConnectionFactory(param1:NetConnectionFactoryBase) : void
      {
         _netConnectionFactory = param1;
      }
      
      override protected function loadStateChangeStart(param1:String) : void
      {
         if(param1 == "ready")
         {
            if(!isStreamingResource && (netStream.bytesTotal <= 0 || netStream.bytesTotal == 4294967295))
            {
               netStream.addEventListener("netStatus",onNetStatus);
            }
         }
         else if(param1 == "uninitialized")
         {
            netStream = null;
            dispatchEvent(new LoadEvent("bytesLoadedChange",false,false,null,bytesLoaded));
            dispatchEvent(new LoadEvent("bytesTotalChange",false,false,null,bytesTotal));
         }
      }
      
      override public function get bytesLoaded() : Number
      {
         return isStreamingResource ? NaN : (netStream != null ? netStream.bytesLoaded : NaN);
      }
      
      override public function get bytesTotal() : Number
      {
         return isStreamingResource ? NaN : (netStream != null ? netStream.bytesTotal : NaN);
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         if(netStream != null && netStream.bytesTotal > 0)
         {
            dispatchEvent(new LoadEvent("bytesTotalChange",false,false,null,netStream.bytesTotal));
            netStream.removeEventListener("netStatus",onNetStatus);
         }
      }
   }
}

