package org.osmf.layout
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.osmf.events.DisplayObjectEvent;
   
   public class LayoutTargetSprite extends Sprite implements ILayoutTarget
   {
      private var _layoutMetadata:LayoutMetadata;
      
      private var _measuredWidth:Number = NaN;
      
      private var _measuredHeight:Number = NaN;
      
      private var renderers:LayoutTargetRenderers = new LayoutTargetRenderers(this);
      
      public function LayoutTargetSprite(param1:LayoutMetadata = null)
      {
         _layoutMetadata = param1 || new LayoutMetadata();
         addEventListener("addChildAt",onAddChildAt);
         addEventListener("setChildIndex",onSetChildIndex);
         addEventListener("removeChild",onRemoveChild);
         mouseEnabled = true;
         mouseChildren = true;
         super();
      }
      
      public function get displayObject() : DisplayObject
      {
         return this;
      }
      
      public function get layoutMetadata() : LayoutMetadata
      {
         return _layoutMetadata;
      }
      
      public function get measuredWidth() : Number
      {
         return _measuredWidth;
      }
      
      public function get measuredHeight() : Number
      {
         return _measuredHeight;
      }
      
      public function measure(param1:Boolean = true) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:DisplayObjectEvent = null;
         if(param1 && renderers.containerRenderer)
         {
            renderers.containerRenderer.measure();
         }
         if(renderers.containerRenderer)
         {
            _loc4_ = renderers.containerRenderer.measuredWidth;
            _loc2_ = renderers.containerRenderer.measuredHeight;
         }
         else
         {
            _loc4_ = super.width / scaleX;
            _loc2_ = super.height / scaleY;
         }
         if(_loc4_ != _measuredWidth || _loc2_ != _measuredHeight)
         {
            _loc3_ = new DisplayObjectEvent("mediaSizeChange",false,false,null,null,_measuredWidth,_measuredHeight,_loc4_,_loc2_);
            _measuredWidth = _loc4_;
            _measuredHeight = _loc2_;
            dispatchEvent(_loc3_);
         }
      }
      
      public function layout(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         if(renderers.containerRenderer == null)
         {
            super.width = param1;
            super.height = param2;
         }
         else if(param3)
         {
            renderers.containerRenderer.layout(param1,param2);
         }
      }
      
      public function validateNow() : void
      {
         if(renderers.containerRenderer)
         {
            renderers.containerRenderer.validateNow();
         }
      }
      
      protected function onAddChildAt(param1:LayoutTargetEvent) : void
      {
         addChildAt(param1.displayObject,param1.index);
      }
      
      protected function onRemoveChild(param1:LayoutTargetEvent) : void
      {
         removeChild(param1.displayObject);
      }
      
      protected function onSetChildIndex(param1:LayoutTargetEvent) : void
      {
         setChildIndex(param1.displayObject,param1.index);
      }
      
      override public function set width(param1:Number) : void
      {
         _layoutMetadata.width = param1;
      }
      
      override public function get width() : Number
      {
         return _measuredWidth;
      }
      
      override public function set height(param1:Number) : void
      {
         _layoutMetadata.height = param1;
      }
      
      override public function get height() : Number
      {
         return _measuredHeight;
      }
   }
}

