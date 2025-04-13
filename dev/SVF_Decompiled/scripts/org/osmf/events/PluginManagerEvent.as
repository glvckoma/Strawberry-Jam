package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.media.MediaResourceBase;
   
   public class PluginManagerEvent extends Event
   {
      public static const PLUGIN_LOAD:String = "pluginLoad";
      
      public static const PLUGIN_LOAD_ERROR:String = "pluginLoadError";
      
      private var _resource:MediaResourceBase;
      
      public function PluginManagerEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:MediaResourceBase = null)
      {
         super(param1,param2,param3);
         _resource = param4;
      }
      
      public function get resource() : MediaResourceBase
      {
         return _resource;
      }
      
      override public function clone() : Event
      {
         return new PluginManagerEvent(type,bubbles,cancelable,_resource);
      }
   }
}

