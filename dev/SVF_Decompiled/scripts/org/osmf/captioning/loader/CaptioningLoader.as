package org.osmf.captioning.loader
{
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.captioning.parsers.DFXPParser;
   import org.osmf.captioning.parsers.ICaptioningParser;
   import org.osmf.events.LoaderEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.HTTPLoadTrait;
   import org.osmf.utils.HTTPLoader;
   
   public class CaptioningLoader extends LoaderBase
   {
      private var httpLoader:HTTPLoader;
      
      public function CaptioningLoader(param1:HTTPLoader = null)
      {
         super();
         this.httpLoader = param1 != null ? param1 : new HTTPLoader();
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         return httpLoader.canHandleResource(param1);
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         var httpLoadTrait:HTTPLoadTrait;
         var loadTrait:LoadTrait = param1;
         var onHTTPLoaderStateChange:* = function(param1:LoaderEvent):void
         {
            var _loc2_:ICaptioningParser = null;
            var _loc3_:CaptioningDocument = null;
            if(param1.newState == "ready")
            {
               httpLoader.removeEventListener("loadStateChange",onHTTPLoaderStateChange);
               httpLoadTrait.removeEventListener("mediaError",onLoadError);
               _loc2_ = createCaptioningParser();
               try
               {
                  _loc3_ = _loc2_.parse(httpLoadTrait.urlLoader.data.toString());
               }
               catch(e:Error)
               {
                  updateLoadTrait(loadTrait,"loadError");
               }
               CaptioningLoadTrait(loadTrait).document = _loc3_;
               updateLoadTrait(loadTrait,"ready");
            }
            else if(param1.newState == "loadError")
            {
               httpLoader.removeEventListener("loadStateChange",onHTTPLoaderStateChange);
               updateLoadTrait(loadTrait,param1.newState);
            }
         };
         var onLoadError:* = function(param1:MediaErrorEvent):void
         {
            httpLoadTrait.removeEventListener("mediaError",onLoadError);
            loadTrait.dispatchEvent(param1.clone());
         };
         updateLoadTrait(loadTrait,"loading");
         httpLoader.addEventListener("loadStateChange",onHTTPLoaderStateChange);
         httpLoadTrait = new HTTPLoadTrait(httpLoader,loadTrait.resource);
         httpLoadTrait.addEventListener("mediaError",onLoadError);
         httpLoader.load(httpLoadTrait);
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,"unloading");
         updateLoadTrait(param1,"uninitialized");
      }
      
      protected function createCaptioningParser() : ICaptioningParser
      {
         return new DFXPParser();
      }
   }
}

