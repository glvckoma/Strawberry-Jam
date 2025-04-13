package org.osmf.elements
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import org.osmf.elements.f4mClasses.DRMAdditionalHeader;
   import org.osmf.elements.f4mClasses.Manifest;
   import org.osmf.elements.f4mClasses.ManifestParser;
   import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.DefaultMediaFactory;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.net.httpstreaming.HTTPStreamingUtils;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.URL;
   
   public class F4MLoader extends LoaderBase
   {
      public static const F4M_MIME_TYPE:String = "application/f4m+xml";
      
      private static const F4M_EXTENSION:String = "f4m";
      
      private var supportedMimeTypes:Vector.<String> = new Vector.<String>();
      
      private var factory:MediaFactory;
      
      private var parser:ManifestParser;
      
      public function F4MLoader(param1:MediaFactory = null)
      {
         super();
         supportedMimeTypes.push("application/f4m+xml");
         if(param1 == null)
         {
            param1 = new DefaultMediaFactory();
         }
         this.parser = new ManifestParser();
         this.factory = param1;
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:URLResource = null;
         var _loc3_:String = null;
         var _loc4_:int = MediaTypeUtil.checkMetadataMatchWithResource(param1,new Vector.<String>(),supportedMimeTypes);
         if(_loc4_ == 0)
         {
            return true;
         }
         if(param1 is URLResource)
         {
            _loc2_ = URLResource(param1);
            _loc3_ = new URL(_loc2_.url).extension;
            return _loc3_ == "f4m";
         }
         return false;
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         var manifest:Manifest;
         var manifestLoader:URLLoader;
         var loadTrait:LoadTrait = param1;
         var onError:* = function(param1:ErrorEvent):void
         {
            manifestLoader.removeEventListener("complete",onComplete);
            manifestLoader.removeEventListener("ioError",onError);
            manifestLoader.removeEventListener("securityError",onError);
            updateLoadTrait(loadTrait,"loadError");
            loadTrait.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(0,param1.text)));
         };
         var onComplete:* = function(param1:Event):void
         {
            var unfinishedLoads:Number;
            var item:DRMAdditionalHeader;
            var completionCallback:*;
            var event:Event = param1;
            manifestLoader.removeEventListener("complete",onComplete);
            manifestLoader.removeEventListener("ioError",onError);
            manifestLoader.removeEventListener("securityError",onError);
            try
            {
               manifest = parser.parse(event.target.data,getRootUrl(URLResource(loadTrait.resource).url));
            }
            catch(parseError:Error)
            {
               updateLoadTrait(loadTrait,"loadError");
               loadTrait.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(parseError.errorID,parseError.message)));
            }
            if(manifest != null)
            {
               unfinishedLoads = 0;
               for each(item in manifest.drmAdditionalHeaders)
               {
                  if(item.url != null)
                  {
                     completionCallback = function(param1:Boolean):void
                     {
                        if(param1)
                        {
                           unfinishedLoads--;
                        }
                        if(unfinishedLoads == 0)
                        {
                           finishLoad();
                        }
                     };
                     unfinishedLoads++;
                     loadAdditionalHeader(item,completionCallback,onError);
                  }
               }
               if(unfinishedLoads == 0)
               {
                  finishLoad();
               }
            }
         };
         var finishLoad:* = function():void
         {
            var _loc3_:MediaResourceBase = null;
            var _loc1_:MediaElement = null;
            try
            {
               _loc3_ = parser.createResource(manifest,URLResource(loadTrait.resource));
               _loc1_ = factory.createMediaElement(_loc3_);
               if(_loc1_.hasOwnProperty("defaultDuration") && !isNaN(manifest.duration))
               {
                  _loc1_["defaultDuration"] = manifest.duration;
               }
               LoadFromDocumentLoadTrait(loadTrait).mediaElement = _loc1_;
               updateLoadTrait(loadTrait,"ready");
            }
            catch(error:Error)
            {
               updateLoadTrait(loadTrait,"loadError");
               loadTrait.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(23,error.message)));
            }
         };
         updateLoadTrait(loadTrait,"loading");
         manifestLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
         manifestLoader.addEventListener("complete",onComplete);
         manifestLoader.addEventListener("ioError",onError);
         manifestLoader.addEventListener("securityError",onError);
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,"uninitialized");
      }
      
      private function loadAdditionalHeader(param1:DRMAdditionalHeader, param2:Function, param3:Function) : void
      {
         var item:DRMAdditionalHeader = param1;
         var completionCallback:Function = param2;
         var onError:Function = param3;
         var onDRMLoadComplete:* = function(param1:Event):void
         {
            param1.target.removeEventListener("complete",onDRMLoadComplete);
            param1.target.removeEventListener("ioError",onError);
            param1.target.removeEventListener("securityError",onError);
            item.data = URLLoader(param1.target).data;
            completionCallback(true);
         };
         var drmLoader:URLLoader = new URLLoader();
         drmLoader.dataFormat = "binary";
         drmLoader.addEventListener("complete",onDRMLoadComplete);
         drmLoader.addEventListener("ioError",onError);
         drmLoader.addEventListener("securityError",onError);
         drmLoader.load(new URLRequest(HTTPStreamingUtils.normalizeURL(item.url)));
      }
      
      private function getRootUrl(param1:String) : String
      {
         return param1.substr(0,param1.lastIndexOf("/"));
      }
   }
}

