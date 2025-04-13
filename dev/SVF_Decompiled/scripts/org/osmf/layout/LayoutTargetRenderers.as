package org.osmf.layout
{
   internal class LayoutTargetRenderers
   {
      public var containerRenderer:LayoutRendererBase;
      
      public var parentRenderer:LayoutRendererBase;
      
      public function LayoutTargetRenderers(param1:ILayoutTarget)
      {
         super();
         param1.addEventListener("addToLayoutRenderer",onAddedToLayoutRenderer);
         param1.addEventListener("removeFromLayoutRenderer",onRemovedFromLayoutRenderer);
         param1.addEventListener("setAsLayoutRendererContainer",onSetAsLayoutRendererContainer);
         param1.addEventListener("unsetAsLayoutRendererContainer",onUnsetAsLayoutRendererContainer);
      }
      
      private function onSetAsLayoutRendererContainer(param1:LayoutTargetEvent) : void
      {
         if(containerRenderer != param1.layoutRenderer)
         {
            containerRenderer = param1.layoutRenderer;
            containerRenderer.setParent(parentRenderer);
         }
      }
      
      private function onUnsetAsLayoutRendererContainer(param1:LayoutTargetEvent) : void
      {
         if(containerRenderer != null && containerRenderer == param1.layoutRenderer)
         {
            containerRenderer.setParent(null);
            containerRenderer = null;
         }
      }
      
      private function onAddedToLayoutRenderer(param1:LayoutTargetEvent) : void
      {
         if(parentRenderer != param1.layoutRenderer)
         {
            parentRenderer = param1.layoutRenderer;
            if(containerRenderer)
            {
               containerRenderer.setParent(parentRenderer);
            }
         }
      }
      
      private function onRemovedFromLayoutRenderer(param1:LayoutTargetEvent) : void
      {
         if(parentRenderer == param1.layoutRenderer)
         {
            parentRenderer = null;
            if(containerRenderer)
            {
               containerRenderer.setParent(null);
            }
         }
      }
   }
}

