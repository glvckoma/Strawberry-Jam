package org.osmf.elements
{
   import org.osmf.media.MediaResourceBase;
   import org.osmf.net.NetLoader;
   import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
   import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
   import org.osmf.traits.LoaderBase;
   
   public class VideoElement extends LightweightVideoElement
   {
      private var _alternateLoaders:Vector.<LoaderBase>;
      
      public function VideoElement(param1:MediaResourceBase = null, param2:NetLoader = null)
      {
         super(null,null);
         super.loader = param2;
         this.resource = param1;
      }
      
      override public function set resource(param1:MediaResourceBase) : void
      {
         loader = getLoaderForResource(param1,alternateLoaders);
         super.resource = param1;
      }
      
      private function get alternateLoaders() : Vector.<LoaderBase>
      {
         if(_alternateLoaders == null)
         {
            _alternateLoaders = new Vector.<LoaderBase>();
            _alternateLoaders.push(new HTTPStreamingNetLoader());
            _alternateLoaders.push(new RTMPDynamicStreamingNetLoader());
            _alternateLoaders.push(new NetLoader());
         }
         return _alternateLoaders;
      }
   }
}

