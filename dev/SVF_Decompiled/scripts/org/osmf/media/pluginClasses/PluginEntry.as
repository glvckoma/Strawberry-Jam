package org.osmf.media.pluginClasses
{
   import org.osmf.media.MediaElement;
   
   internal class PluginEntry
   {
      private var _pluginElement:MediaElement;
      
      private var _state:PluginLoadingState;
      
      public function PluginEntry(param1:MediaElement, param2:PluginLoadingState)
      {
         super();
         _pluginElement = param1;
         _state = param2;
      }
      
      public function get pluginElement() : MediaElement
      {
         return _pluginElement;
      }
      
      public function get state() : PluginLoadingState
      {
         return _state;
      }
      
      public function set state(param1:PluginLoadingState) : void
      {
         _state = param1;
      }
   }
}

