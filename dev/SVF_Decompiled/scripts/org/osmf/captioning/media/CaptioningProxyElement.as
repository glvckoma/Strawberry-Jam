package org.osmf.captioning.media
{
   import org.osmf.captioning.loader.CaptioningLoadTrait;
   import org.osmf.captioning.loader.CaptioningLoader;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.elements.ProxyElement;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.TimelineMetadata;
   import org.osmf.traits.LoadTrait;
   
   public class CaptioningProxyElement extends ProxyElement
   {
      public static const MEDIA_ERROR_INVALID_PROXIED_ELEMENT:int = 2201;
      
      private static const ERROR_MISSING_CAPTION_METADATA:String = "Media Element is missing Captioning metadata";
      
      private static const ERROR_MISSING_RESOURCE:String = "Media Element is missing a valid resource";
      
      private var loadTrait:CaptioningLoadTrait;
      
      private var _continueLoadOnFailure:Boolean;
      
      public function CaptioningProxyElement(param1:MediaElement = null, param2:Boolean = true)
      {
         super(param1);
         _continueLoadOnFailure = param2;
      }
      
      public function get continueLoadOnFailure() : Boolean
      {
         return _continueLoadOnFailure;
      }
      
      override public function set proxiedElement(param1:MediaElement) : void
      {
         var _loc3_:MediaElement = null;
         var _loc4_:MediaResourceBase = null;
         var _loc2_:Metadata = null;
         var _loc5_:String = null;
         super.proxiedElement = param1;
         if(param1 != null)
         {
            _loc3_ = super.proxiedElement;
            _loc4_ = _loc3_ && _loc3_.resource != null ? _loc3_.resource : resource;
            if(_loc4_ == null)
            {
               dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(2201)));
            }
            else
            {
               _loc2_ = _loc4_.getMetadataValue("http://www.osmf.org/captioning/1.0") as Metadata;
               if(_loc2_ == null)
               {
                  if(!_continueLoadOnFailure)
                  {
                     dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(2201)));
                  }
               }
               else
               {
                  _loc5_ = _loc2_.getValue("uri");
                  if(_loc5_ != null)
                  {
                     loadTrait = new CaptioningLoadTrait(new CaptioningLoader(),new URLResource(_loc5_));
                     loadTrait.addEventListener("loadStateChange",onLoadStateChange,false,99);
                     addTrait("load",loadTrait);
                  }
                  else if(!_continueLoadOnFailure)
                  {
                     dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(2201)));
                  }
               }
            }
         }
      }
      
      private function onLoadStateChange(param1:LoadEvent) : void
      {
         var _loc3_:CaptioningDocument = null;
         var _loc2_:MediaElement = null;
         var _loc6_:TimelineMetadata = null;
         var _loc4_:int = 0;
         var _loc5_:Caption = null;
         if(param1.loadState == "ready")
         {
            _loc3_ = loadTrait.document;
            if(_loc3_)
            {
               _loc2_ = super.proxiedElement;
               _loc6_ = proxiedElement.getMetadata("http://www.osmf.org/temporal/captioning") as TimelineMetadata;
               if(_loc6_ == null)
               {
                  _loc6_ = new TimelineMetadata(proxiedElement);
                  proxiedElement.addMetadata("http://www.osmf.org/temporal/captioning",_loc6_);
               }
               _loc4_ = 0;
               while(_loc4_ < _loc3_.numCaptions)
               {
                  _loc5_ = _loc3_.getCaptionAt(_loc4_);
                  _loc6_.addMarker(_loc5_);
                  _loc4_++;
               }
            }
            cleanUp();
         }
         else if(param1.loadState == "loadError")
         {
            if(!_continueLoadOnFailure)
            {
               dispatchEvent(param1.clone());
            }
            else
            {
               cleanUp();
            }
         }
      }
      
      private function cleanUp() : void
      {
         removeTrait("load");
         var _loc1_:LoadTrait = getTrait("load") as LoadTrait;
         if(_loc1_ != null && _loc1_.loadState == "uninitialized")
         {
            _loc1_.load();
         }
      }
   }
}

