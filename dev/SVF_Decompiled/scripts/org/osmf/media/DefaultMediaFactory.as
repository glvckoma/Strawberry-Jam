package org.osmf.media
{
   import org.osmf.elements.AudioElement;
   import org.osmf.elements.F4MElement;
   import org.osmf.elements.F4MLoader;
   import org.osmf.elements.ImageElement;
   import org.osmf.elements.ImageLoader;
   import org.osmf.elements.SWFElement;
   import org.osmf.elements.SWFLoader;
   import org.osmf.elements.SoundLoader;
   import org.osmf.elements.VideoElement;
   import org.osmf.net.MulticastNetLoader;
   import org.osmf.net.NetLoader;
   import org.osmf.net.dvr.DVRCastNetLoader;
   import org.osmf.net.httpstreaming.HTTPStreamingNetLoader;
   import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
   
   public class DefaultMediaFactory extends MediaFactory
   {
      private var rtmpStreamingNetLoader:RTMPDynamicStreamingNetLoader;
      
      private var f4mLoader:F4MLoader;
      
      private var dvrCastLoader:DVRCastNetLoader;
      
      private var netLoader:NetLoader;
      
      private var imageLoader:ImageLoader;
      
      private var swfLoader:SWFLoader;
      
      private var soundLoader:SoundLoader;
      
      private var httpStreamingNetLoader:HTTPStreamingNetLoader;
      
      private var multicastLoader:MulticastNetLoader;
      
      public function DefaultMediaFactory()
      {
         super();
         init();
      }
      
      private function init() : void
      {
         f4mLoader = new F4MLoader(this);
         addItem(new MediaFactoryItem("org.osmf.elements.f4m",f4mLoader.canHandleResource,function():MediaElement
         {
            return new F4MElement(null,f4mLoader);
         }));
         dvrCastLoader = new DVRCastNetLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.video.dvr.dvrcast",dvrCastLoader.canHandleResource,function():MediaElement
         {
            return new VideoElement(null,dvrCastLoader);
         }));
         httpStreamingNetLoader = new HTTPStreamingNetLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.video.httpstreaming",httpStreamingNetLoader.canHandleResource,function():MediaElement
         {
            return new VideoElement(null,httpStreamingNetLoader);
         }));
         multicastLoader = new MulticastNetLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.video.rtmfp.multicast",multicastLoader.canHandleResource,function():MediaElement
         {
            return new VideoElement(null,multicastLoader);
         }));
         rtmpStreamingNetLoader = new RTMPDynamicStreamingNetLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.video.rtmpdynamicStreaming",rtmpStreamingNetLoader.canHandleResource,function():MediaElement
         {
            return new VideoElement(null,rtmpStreamingNetLoader);
         }));
         netLoader = new NetLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.video",netLoader.canHandleResource,function():MediaElement
         {
            return new VideoElement(null,netLoader);
         }));
         soundLoader = new SoundLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.audio",soundLoader.canHandleResource,function():MediaElement
         {
            return new AudioElement(null,soundLoader);
         }));
         addItem(new MediaFactoryItem("org.osmf.elements.audio.streaming",netLoader.canHandleResource,function():MediaElement
         {
            return new AudioElement(null,netLoader);
         }));
         imageLoader = new ImageLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.image",imageLoader.canHandleResource,function():MediaElement
         {
            return new ImageElement(null,imageLoader);
         }));
         swfLoader = new SWFLoader();
         addItem(new MediaFactoryItem("org.osmf.elements.swf",swfLoader.canHandleResource,function():MediaElement
         {
            return new SWFElement(null,swfLoader);
         }));
      }
   }
}

