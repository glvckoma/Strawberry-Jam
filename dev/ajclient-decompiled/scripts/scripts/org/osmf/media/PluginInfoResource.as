package org.osmf.media
{
   public class PluginInfoResource extends MediaResourceBase
   {
      
      private var _pluginInfo:PluginInfo;
      
      public function PluginInfoResource(param1:PluginInfo)
      {
         super();
         _pluginInfo = param1;
      }
      
      public function get pluginInfo() : PluginInfo
      {
         return _pluginInfo;
      }
   }
}

