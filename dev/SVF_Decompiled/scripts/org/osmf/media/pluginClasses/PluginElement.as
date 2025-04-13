package org.osmf.media.pluginClasses
{
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   internal class PluginElement extends LoadableElementBase
   {
      public function PluginElement(param1:PluginLoader, param2:MediaResourceBase = null)
      {
         super(param2,param1);
      }
      
      override protected function createLoadTrait(param1:MediaResourceBase, param2:LoaderBase) : LoadTrait
      {
         return new PluginLoadTrait(param2,param1);
      }
   }
}

