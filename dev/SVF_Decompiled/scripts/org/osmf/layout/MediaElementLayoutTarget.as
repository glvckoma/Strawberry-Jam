package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaElementLayoutTarget extends EventDispatcher implements ILayoutTarget
   {
      private static const layoutTargets:Dictionary = new Dictionary(true);
      
      private var _mediaElement:MediaElement;
      
      private var _layoutMetadata:LayoutMetadata;
      
      private var displayObjectTrait:DisplayObjectTrait;
      
      private var _displayObject:DisplayObject;
      
      private var renderers:LayoutTargetRenderers;
      
      public function MediaElementLayoutTarget(param1:MediaElement, param2:Class)
      {
         super();
         if(param2 != ConstructorLock)
         {
            throw new IllegalOperationError(OSMFStrings.getString("illegalConstructorInvocation"));
         }
         _mediaElement = param1;
         _mediaElement.addEventListener("traitAdd",onMediaElementTraitsChange);
         _mediaElement.addEventListener("traitRemove",onMediaElementTraitsChange);
         _mediaElement.addEventListener("metadataAdd",onMetadataAdd);
         _mediaElement.addEventListener("metadataRemove",onMetadataRemove);
         renderers = new LayoutTargetRenderers(this);
         _layoutMetadata = _mediaElement.getMetadata("http://www.osmf.org/layout/1.0") as LayoutMetadata;
         addEventListener("addChildAt",onAddChildAt);
         addEventListener("setChildIndex",onSetChildIndex);
         addEventListener("removeChild",onRemoveChild);
         onMediaElementTraitsChange();
      }
      
      public static function getInstance(param1:MediaElement) : MediaElementLayoutTarget
      {
         var _loc2_:* = undefined;
         for(_loc2_ in layoutTargets)
         {
            if(_loc2_.mediaElement == param1)
            {
               break;
            }
            _loc2_ = null;
         }
         if(_loc2_ == null)
         {
            _loc2_ = new MediaElementLayoutTarget(param1,ConstructorLock);
            layoutTargets[_loc2_] = true;
         }
         return _loc2_;
      }
      
      public function get mediaElement() : MediaElement
      {
         return _mediaElement;
      }
      
      public function get layoutMetadata() : LayoutMetadata
      {
         if(_layoutMetadata == null)
         {
            _layoutMetadata = new LayoutMetadata();
            _mediaElement.addMetadata("http://www.osmf.org/layout/1.0",_layoutMetadata);
         }
         return _layoutMetadata;
      }
      
      public function get displayObject() : DisplayObject
      {
         return _displayObject;
      }
      
      public function get measuredWidth() : Number
      {
         return !!displayObjectTrait ? displayObjectTrait.mediaWidth : NaN;
      }
      
      public function get measuredHeight() : Number
      {
         return !!displayObjectTrait ? displayObjectTrait.mediaHeight : NaN;
      }
      
      public function measure(param1:Boolean = true) : void
      {
         if(_displayObject is ILayoutTarget)
         {
            ILayoutTarget(_displayObject).measure(param1);
         }
      }
      
      public function layout(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         if(_displayObject is ILayoutTarget)
         {
            ILayoutTarget(_displayObject).layout(param1,param2,param3);
         }
         else if(_displayObject != null && renderers.containerRenderer == null)
         {
            _displayObject.width = param1;
            _displayObject.height = param2;
         }
      }
      
      private function onMediaElementTraitsChange(param1:MediaElementEvent = null) : void
      {
         var _loc2_:DisplayObjectTrait = null;
         if(param1 == null || param1 && param1.traitType == "displayObject")
         {
            _loc2_ = param1 && param1.type == "traitRemove" ? null : _mediaElement.getTrait("displayObject") as DisplayObjectTrait;
            if(_loc2_ != displayObjectTrait)
            {
               if(displayObjectTrait)
               {
                  displayObjectTrait.removeEventListener("displayObjectChange",onDisplayObjectTraitDisplayObjecChange);
                  displayObjectTrait.removeEventListener("mediaSizeChange",onDisplayObjectTraitMediaSizeChange);
               }
               displayObjectTrait = _loc2_;
               if(displayObjectTrait)
               {
                  displayObjectTrait.addEventListener("displayObjectChange",onDisplayObjectTraitDisplayObjecChange);
                  displayObjectTrait.addEventListener("mediaSizeChange",onDisplayObjectTraitMediaSizeChange);
               }
               updateDisplayObject(!!displayObjectTrait ? displayObjectTrait.displayObject : null);
            }
         }
      }
      
      private function onMetadataAdd(param1:MediaElementEvent) : void
      {
         if(param1.namespaceURL == "http://www.osmf.org/layout/1.0")
         {
            _layoutMetadata = param1.metadata as LayoutMetadata;
         }
      }
      
      private function onMetadataRemove(param1:MediaElementEvent) : void
      {
         if(param1.namespaceURL == "http://www.osmf.org/layout/1.0")
         {
            _layoutMetadata = null;
         }
      }
      
      private function updateDisplayObject(param1:DisplayObject) : void
      {
         var _loc2_:DisplayObject = _displayObject;
         if(param1 != displayObject)
         {
            _displayObject = param1;
            dispatchEvent(new DisplayObjectEvent("displayObjectChange",false,false,_loc2_,param1));
         }
         if(param1 is ILayoutTarget && renderers.parentRenderer)
         {
            ILayoutTarget(param1).dispatchEvent(new LayoutTargetEvent("addToLayoutRenderer",false,false,renderers.parentRenderer));
         }
      }
      
      private function onDisplayObjectTraitDisplayObjecChange(param1:DisplayObjectEvent) : void
      {
         updateDisplayObject(param1.newDisplayObject);
      }
      
      private function onDisplayObjectTraitMediaSizeChange(param1:DisplayObjectEvent) : void
      {
         dispatchEvent(param1.clone());
      }
      
      private function onAddChildAt(param1:LayoutTargetEvent) : void
      {
         if(_displayObject is ILayoutTarget)
         {
            ILayoutTarget(_displayObject).dispatchEvent(param1.clone());
         }
         else if(_displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(_displayObject).addChildAt(param1.displayObject,param1.index);
         }
      }
      
      private function onRemoveChild(param1:LayoutTargetEvent) : void
      {
         if(_displayObject is ILayoutTarget)
         {
            ILayoutTarget(_displayObject).dispatchEvent(param1.clone());
         }
         else if(_displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(_displayObject).removeChild(param1.displayObject);
         }
      }
      
      private function onSetChildIndex(param1:LayoutTargetEvent) : void
      {
         if(_displayObject is ILayoutTarget)
         {
            ILayoutTarget(_displayObject).dispatchEvent(param1.clone());
         }
         else if(_displayObject is DisplayObjectContainer)
         {
            DisplayObjectContainer(_displayObject).setChildIndex(param1.displayObject,param1.index);
         }
      }
   }
}

class ConstructorLock
{
   public function ConstructorLock()
   {
      super();
   }
}
