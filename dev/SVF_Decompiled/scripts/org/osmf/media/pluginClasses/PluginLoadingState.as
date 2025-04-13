package org.osmf.media.pluginClasses
{
   internal class PluginLoadingState
   {
      public static const LOADING:PluginLoadingState = new PluginLoadingState("Loading");
      
      public static const LOADED:PluginLoadingState = new PluginLoadingState("Loaded");
      
      private var _state:String;
      
      public function PluginLoadingState(param1:String)
      {
         super();
         _state = param1;
      }
      
      public function get state() : String
      {
         return _state;
      }
   }
}

