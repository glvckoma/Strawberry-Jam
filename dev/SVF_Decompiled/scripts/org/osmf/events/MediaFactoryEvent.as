package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   
   public class MediaFactoryEvent extends Event
   {
      public static const PLUGIN_LOAD:String = "pluginLoad";
      
      public static const PLUGIN_LOAD_ERROR:String = "pluginLoadError";
      
      public static const MEDIA_ELEMENT_CREATE:String = "mediaElementCreate";
      
      private var _resource:MediaResourceBase;
      
      private var _mediaElement:MediaElement;
      
      public function MediaFactoryEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:MediaResourceBase = null, param5:MediaElement = null)
      {
         super(param1,param2,param3);
         _resource = param4;
         _mediaElement = param5;
      }
      
      public function get resource() : MediaResourceBase
      {
         return _resource;
      }
      
      public function get mediaElement() : MediaElement
      {
         return _mediaElement;
      }
      
      override public function clone() : Event
      {
         return new MediaFactoryEvent(type,bubbles,cancelable,_resource,_mediaElement);
      }
   }
}

