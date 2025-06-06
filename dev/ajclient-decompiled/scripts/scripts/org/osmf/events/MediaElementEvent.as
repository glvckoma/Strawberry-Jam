package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.metadata.Metadata;
   
   public class MediaElementEvent extends Event
   {
      
      public static const TRAIT_ADD:String = "traitAdd";
      
      public static const TRAIT_REMOVE:String = "traitRemove";
      
      public static const METADATA_ADD:String = "metadataAdd";
      
      public static const METADATA_REMOVE:String = "metadataRemove";
      
      private var _traitType:String;
      
      private var _namespaceURL:String;
      
      private var _metadata:Metadata;
      
      public function MediaElementEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:String = null, param5:String = null, param6:Metadata = null)
      {
         super(param1,param2,param3);
         _traitType = param4;
         _namespaceURL = param5;
         _metadata = param6;
      }
      
      override public function clone() : Event
      {
         return new MediaElementEvent(type,bubbles,cancelable,traitType,namespaceURL,metadata);
      }
      
      public function get traitType() : String
      {
         return _traitType;
      }
      
      public function get namespaceURL() : String
      {
         return _namespaceURL;
      }
      
      public function get metadata() : Metadata
      {
         return _metadata;
      }
   }
}

