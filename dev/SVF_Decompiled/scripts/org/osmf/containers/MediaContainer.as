package org.osmf.containers
{
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.layout.LayoutMetadata;
   import org.osmf.layout.LayoutRenderer;
   import org.osmf.layout.LayoutRendererBase;
   import org.osmf.layout.LayoutTargetEvent;
   import org.osmf.layout.LayoutTargetSprite;
   import org.osmf.layout.MediaElementLayoutTarget;
   import org.osmf.media.MediaElement;
   import org.osmf.utils.OSMFStrings;
   
   public class MediaContainer extends LayoutTargetSprite implements IMediaContainer
   {
      private var layoutTargets:Dictionary = new Dictionary();
      
      private var _layoutRenderer:LayoutRendererBase;
      
      private var _backgroundColor:Number;
      
      private var _backgroundAlpha:Number;
      
      private var lastAvailableWidth:Number;
      
      private var lastAvailableHeight:Number;
      
      public function MediaContainer(param1:LayoutRendererBase = null, param2:LayoutMetadata = null)
      {
         super(param2);
         _layoutRenderer = param1 || new LayoutRenderer();
         _layoutRenderer.container = this;
      }
      
      public function addMediaElement(param1:MediaElement) : MediaElement
      {
         var _loc2_:MediaElementLayoutTarget = null;
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         if(layoutTargets[param1] == undefined)
         {
            param1.dispatchEvent(new ContainerChangeEvent("containerChange",false,false,param1.container,this));
            _loc2_ = MediaElementLayoutTarget.getInstance(param1);
            layoutTargets[param1] = _loc2_;
            _layoutRenderer.addTarget(_loc2_);
            param1.addEventListener("containerChange",onElementContainerChange);
            return param1;
         }
         throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
      }
      
      public function removeMediaElement(param1:MediaElement) : MediaElement
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString("nullParam"));
         }
         var _loc3_:MediaElementLayoutTarget = layoutTargets[param1];
         if(_loc3_)
         {
            param1.removeEventListener("containerChange",onElementContainerChange);
            _layoutRenderer.removeTarget(_loc3_);
            delete layoutTargets[param1];
            _loc2_ = param1;
            if(param1.container == this)
            {
               param1.dispatchEvent(new ContainerChangeEvent("containerChange",false,false,param1.container,null));
            }
            return _loc2_;
         }
         throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
      }
      
      public function containsMediaElement(param1:MediaElement) : Boolean
      {
         return layoutTargets[param1] != undefined;
      }
      
      public function get layoutRenderer() : LayoutRendererBase
      {
         return _layoutRenderer;
      }
      
      public function get clipChildren() : Boolean
      {
         return scrollRect != null;
      }
      
      public function set clipChildren(param1:Boolean) : void
      {
         if(param1 && scrollRect == null)
         {
            scrollRect = new Rectangle(0,0,_layoutRenderer.measuredWidth,_layoutRenderer.measuredHeight);
         }
         else if(param1 == false && scrollRect)
         {
            scrollRect = null;
         }
      }
      
      public function get backgroundColor() : Number
      {
         return _backgroundColor;
      }
      
      public function set backgroundColor(param1:Number) : void
      {
         if(param1 != _backgroundColor)
         {
            _backgroundColor = param1;
            drawBackground();
         }
      }
      
      public function get backgroundAlpha() : Number
      {
         return _backgroundAlpha;
      }
      
      public function set backgroundAlpha(param1:Number) : void
      {
         if(param1 != _backgroundAlpha)
         {
            _backgroundAlpha = param1;
            drawBackground();
         }
      }
      
      override public function layout(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         super.layout(param1,param2,param3);
         lastAvailableWidth = param1;
         lastAvailableHeight = param2;
         if(!isNaN(backgroundColor))
         {
            drawBackground();
         }
         if(scrollRect)
         {
            scrollRect = new Rectangle(0,0,param1,param2);
         }
      }
      
      override public function validateNow() : void
      {
         _layoutRenderer.validateNow();
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString("directDisplayListModError"));
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString("directDisplayListModError"));
      }
      
      override public function removeChild(param1:DisplayObject) : DisplayObject
      {
         throw new IllegalOperationError(OSMFStrings.getString("directDisplayListModError"));
      }
      
      override public function setChildIndex(param1:DisplayObject, param2:int) : void
      {
         throw new IllegalOperationError(OSMFStrings.getString("directDisplayListModError"));
      }
      
      override protected function onAddChildAt(param1:LayoutTargetEvent) : void
      {
         super.addChildAt(param1.displayObject,param1.index);
      }
      
      override protected function onRemoveChild(param1:LayoutTargetEvent) : void
      {
         super.removeChild(param1.displayObject);
      }
      
      override protected function onSetChildIndex(param1:LayoutTargetEvent) : void
      {
         super.setChildIndex(param1.displayObject,param1.index);
      }
      
      private function drawBackground() : void
      {
         graphics.clear();
         if(!isNaN(_backgroundColor) && _backgroundAlpha != 0 && lastAvailableWidth && lastAvailableHeight)
         {
            graphics.beginFill(_backgroundColor,_backgroundAlpha);
            graphics.drawRect(0,0,lastAvailableWidth,lastAvailableHeight);
            graphics.endFill();
         }
      }
      
      private function onElementContainerChange(param1:ContainerChangeEvent) : void
      {
         if(param1.oldContainer == this)
         {
            removeMediaElement(param1.target as MediaElement);
         }
      }
   }
}

