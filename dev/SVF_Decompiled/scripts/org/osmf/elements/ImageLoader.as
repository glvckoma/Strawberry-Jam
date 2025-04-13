package org.osmf.elements
{
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.URL;
   
   public class ImageLoader extends LoaderBase
   {
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["image/png","image/gif","image/jpeg"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["image"]);
      
      private var checkPolicyFile:Boolean;
      
      public function ImageLoader(param1:Boolean = true)
      {
         super();
         this.checkPolicyFile = param1;
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
            return _loc4_.path.search(/\.gif$|\.jpg$|\.png$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         LoaderUtils.loadLoadTrait(param1,updateLoadTrait,false,checkPolicyFile);
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         LoaderUtils.unloadLoadTrait(param1,updateLoadTrait);
      }
   }
}

