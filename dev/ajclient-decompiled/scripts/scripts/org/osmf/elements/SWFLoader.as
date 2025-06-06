package org.osmf.elements
{
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.URL;
   
   public class SWFLoader extends LoaderBase
   {
      
      public static var allowValidationOfLoadedContent:Boolean = true;
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["swf"]);
      
      private var useCurrentSecurityDomain:Boolean = false;
      
      private var _validateLoadedContentFunction:Function = null;
      
      public function SWFLoader(param1:Boolean = false)
      {
         super();
         this.useCurrentSecurityDomain = param1;
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc4_:URL = null;
         var _loc2_:int = MediaTypeUtil.checkMetadataMatchWithResource(param1,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(_loc2_ != 2)
         {
            return _loc2_ == 0;
         }
         var _loc3_:URLResource = param1 as URLResource;
         if(_loc3_ != null && _loc3_.url != null)
         {
            _loc4_ = new URL(_loc3_.url);
            return _loc4_.path.search(/\.swf$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         LoaderUtils.loadLoadTrait(param1,updateLoadTrait,useCurrentSecurityDomain,false,validateLoadedContentFunction);
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         LoaderUtils.unloadLoadTrait(param1,updateLoadTrait);
      }
      
      public function get validateLoadedContentFunction() : Function
      {
         return allowValidationOfLoadedContent ? _validateLoadedContentFunction : null;
      }
      
      public function set validateLoadedContentFunction(param1:Function) : void
      {
         _validateLoadedContentFunction = param1;
      }
   }
}

