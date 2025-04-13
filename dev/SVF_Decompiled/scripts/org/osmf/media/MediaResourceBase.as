package org.osmf.media
{
   import flash.utils.Dictionary;
   
   public class MediaResourceBase
   {
      private var _metadata:Dictionary;
      
      private var _mediaType:String;
      
      private var _mimeType:String;
      
      public function MediaResourceBase()
      {
         super();
      }
      
      public function get mediaType() : String
      {
         return _mediaType;
      }
      
      public function set mediaType(param1:String) : void
      {
         _mediaType = param1;
      }
      
      public function get mimeType() : String
      {
         return _mimeType;
      }
      
      public function set mimeType(param1:String) : void
      {
         _mimeType = param1;
      }
      
      public function get metadataNamespaceURLs() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         if(_metadata != null)
         {
            for(var _loc2_ in _metadata)
            {
               _loc1_.push(_loc2_);
            }
         }
         return _loc1_;
      }
      
      public function addMetadataValue(param1:String, param2:Object) : void
      {
         if(_metadata == null)
         {
            _metadata = new Dictionary();
         }
         _metadata[param1] = param2;
      }
      
      public function getMetadataValue(param1:String) : Object
      {
         if(_metadata != null)
         {
            return _metadata[param1];
         }
         return null;
      }
      
      public function removeMetadataValue(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(_metadata != null)
         {
            _loc2_ = _metadata[param1];
            delete _metadata[param1];
            return _loc2_;
         }
         return null;
      }
   }
}

