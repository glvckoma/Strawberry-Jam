package org.osmf.elements.proxyClasses
{
   import flash.events.Event;
   import org.osmf.metadata.Metadata;
   
   public class ProxyMetadata extends Metadata
   {
      private var proxiedMetadata:Metadata;
      
      public function ProxyMetadata()
      {
         super();
         proxiedMetadata = new Metadata();
         proxiedMetadata.addEventListener("valueAdd",redispatchEvent);
         proxiedMetadata.addEventListener("valueChange",redispatchEvent);
         proxiedMetadata.addEventListener("valueRemove",redispatchEvent);
      }
      
      public function set metadata(param1:Metadata) : void
      {
         proxiedMetadata.removeEventListener("valueAdd",redispatchEvent);
         proxiedMetadata.removeEventListener("valueChange",redispatchEvent);
         proxiedMetadata.removeEventListener("valueRemove",redispatchEvent);
         for each(var _loc2_ in proxiedMetadata.keys)
         {
            param1.addValue(_loc2_,proxiedMetadata.getValue(_loc2_));
         }
         proxiedMetadata = param1;
         proxiedMetadata.addEventListener("valueAdd",redispatchEvent);
         proxiedMetadata.addEventListener("valueChange",redispatchEvent);
         proxiedMetadata.addEventListener("valueRemove",redispatchEvent);
      }
      
      override public function getValue(param1:String) : *
      {
         return proxiedMetadata.getValue(param1);
      }
      
      override public function addValue(param1:String, param2:Object) : void
      {
         proxiedMetadata.addValue(param1,param2);
      }
      
      override public function removeValue(param1:String) : *
      {
         return proxiedMetadata.removeValue(param1);
      }
      
      override public function get keys() : Vector.<String>
      {
         return proxiedMetadata.keys;
      }
      
      private function redispatchEvent(param1:Event) : void
      {
         dispatchEvent(param1.clone());
      }
   }
}

