package org.osmf.layout
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import org.osmf.metadata.MetadataWatcher;
   
   public class LayoutRenderer extends LayoutRendererBase
   {
      private static const X:int = 1;
      
      private static const Y:int = 2;
      
      private static const WIDTH:int = 4;
      
      private static const HEIGHT:int = 8;
      
      private static const POSITION:int = 3;
      
      private static const DIMENSIONS:int = 12;
      
      private static const ALL:int = 15;
      
      private static const USED_METADATAS:Vector.<String> = new Vector.<String>(5,true);
      
      USED_METADATAS[0] = "http://www.osmf.org/layout/absolute/1.0";
      USED_METADATAS[1] = "http://www.osmf.org/layout/relative/1.0";
      USED_METADATAS[2] = "http://www.osmf.org/layout/anchor/1.0";
      USED_METADATAS[3] = "http://www.osmf.org/layout/padding/1.0";
      USED_METADATAS[4] = "http://www.osmf.org/layout/attributes/1.0";
      
      private var layoutMode:String = "none";
      
      private var lastCalculatedBounds:Rectangle;
      
      private var targetMetadataWatchers:Dictionary = new Dictionary();
      
      private var containerAbsoluteWatcher:MetadataWatcher;
      
      private var containerAttributesWatcher:MetadataWatcher;
      
      public function LayoutRenderer()
      {
         super();
      }
      
      override protected function get usedMetadatas() : Vector.<String>
      {
         return USED_METADATAS;
      }
      
      override protected function processContainerChange(param1:ILayoutTarget, param2:ILayoutTarget) : void
      {
         var oldContainer:ILayoutTarget = param1;
         var newContainer:ILayoutTarget = param2;
         if(oldContainer)
         {
            containerAbsoluteWatcher.unwatch();
            containerAttributesWatcher.unwatch();
         }
         if(newContainer)
         {
            containerAbsoluteWatcher = new MetadataWatcher(newContainer.layoutMetadata,"http://www.osmf.org/layout/absolute/1.0",null,function(... rest):void
            {
               invalidate();
            });
            containerAbsoluteWatcher.watch();
            containerAttributesWatcher = new MetadataWatcher(newContainer.layoutMetadata,"http://www.osmf.org/layout/attributes/1.0",null,function(param1:LayoutAttributesMetadata):void
            {
               layoutMode = !!param1 ? param1.layoutMode : "none";
               invalidate();
            });
            containerAttributesWatcher.watch();
         }
         invalidate();
      }
      
      override protected function processUpdateMediaDisplayBegin(param1:Vector.<ILayoutTarget>) : void
      {
         lastCalculatedBounds = null;
      }
      
      override protected function processUpdateMediaDisplayEnd() : void
      {
         lastCalculatedBounds = null;
      }
      
      override protected function processTargetAdded(param1:ILayoutTarget) : void
      {
         var watcher:MetadataWatcher;
         var target:ILayoutTarget = param1;
         var attributes:LayoutAttributesMetadata = target.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var relative:RelativeLayoutMetadata = target.layoutMetadata.getValue("http://www.osmf.org/layout/relative/1.0") as RelativeLayoutMetadata;
         if(layoutMode == "none" && relative == null && attributes == null && target.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") == null && target.layoutMetadata.getValue("http://www.osmf.org/layout/anchor/1.0") == null)
         {
            relative = new RelativeLayoutMetadata();
            relative.width = 100;
            relative.height = 100;
            target.layoutMetadata.addValue("http://www.osmf.org/layout/relative/1.0",relative);
            attributes = new LayoutAttributesMetadata();
            attributes.scaleMode ||= "letterbox";
            attributes.verticalAlign ||= "middle";
            attributes.horizontalAlign ||= "center";
            target.layoutMetadata.addValue("http://www.osmf.org/layout/attributes/1.0",attributes);
         }
         watcher = new MetadataWatcher(target.layoutMetadata,"http://www.osmf.org/layout/attributes/1.0","index",function(... rest):void
         {
            updateTargetOrder(target);
         });
         watcher.watch();
         targetMetadataWatchers[target] = watcher;
      }
      
      override protected function processTargetRemoved(param1:ILayoutTarget) : void
      {
         var _loc2_:MetadataWatcher = targetMetadataWatchers[param1];
         delete targetMetadataWatchers[param1];
         _loc2_.unwatch();
         _loc2_ = null;
      }
      
      override protected function compareTargets(param1:ILayoutTarget, param2:ILayoutTarget) : Number
      {
         var _loc4_:LayoutAttributesMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var _loc3_:LayoutAttributesMetadata = param2.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
         var _loc6_:* = !!_loc4_ ? _loc4_.index : NaN;
         var _loc5_:* = !!_loc3_ ? _loc3_.index : NaN;
         if(isNaN(_loc6_) && isNaN(_loc5_))
         {
            return 1;
         }
         if(!_loc6_)
         {
            _loc6_ = 0;
         }
         if(!_loc5_)
         {
            _loc5_ = 0;
         }
         return _loc6_ < _loc5_ ? -1 : (_loc6_ > _loc5_ ? 1 : 0);
      }
      
      override protected function calculateTargetBounds(param1:ILayoutTarget, param2:Number, param3:Number) : Rectangle
      {
         var _loc5_:* = NaN;
         var _loc6_:* = NaN;
         var _loc7_:BoxAttributesMetadata = null;
         var _loc16_:RelativeLayoutMetadata = null;
         var _loc8_:AnchorLayoutMetadata = null;
         var _loc13_:Point = null;
         var _loc15_:LayoutAttributesMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata || new LayoutAttributesMetadata();
         if(_loc15_.includeInLayout == false)
         {
            return new Rectangle();
         }
         var _loc12_:Rectangle = new Rectangle(0,0,param1.measuredWidth,param1.measuredHeight);
         var _loc14_:AbsoluteLayoutMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") as AbsoluteLayoutMetadata;
         var _loc9_:Number = 0;
         var _loc10_:Number = 0;
         var _loc11_:* = 15;
         if(_loc14_)
         {
            if(!isNaN(_loc14_.x))
            {
               _loc12_.x = _loc14_.x;
               _loc11_ ^= 1;
            }
            if(!isNaN(_loc14_.y))
            {
               _loc12_.y = _loc14_.y;
               _loc11_ ^= 2;
            }
            if(!isNaN(_loc14_.width))
            {
               _loc12_.width = _loc14_.width;
               _loc11_ ^= 4;
            }
            if(!isNaN(_loc14_.height))
            {
               _loc12_.height = _loc14_.height;
               _loc11_ ^= 8;
            }
         }
         if(_loc11_ != 0)
         {
            _loc16_ = param1.layoutMetadata.getValue("http://www.osmf.org/layout/relative/1.0") as RelativeLayoutMetadata;
            if(_loc16_)
            {
               if(_loc11_ & 1 && !isNaN(_loc16_.x))
               {
                  _loc12_.x = param2 * _loc16_.x / 100 || 0;
                  _loc11_ ^= 1;
               }
               if(_loc11_ & 4 && !isNaN(_loc16_.width))
               {
                  if(layoutMode == "horizontal")
                  {
                     _loc7_ = container.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/box/1.0") as BoxAttributesMetadata || new BoxAttributesMetadata();
                     _loc12_.width = Math.max(0,param2 - _loc7_.absoluteSum) * _loc16_.width / _loc7_.relativeSum;
                  }
                  else
                  {
                     _loc12_.width = param2 * _loc16_.width / 100;
                  }
                  _loc11_ ^= 4;
               }
               if(_loc11_ & 2 && !isNaN(_loc16_.y))
               {
                  _loc12_.y = param3 * _loc16_.y / 100 || 0;
                  _loc11_ ^= 2;
               }
               if(_loc11_ & 8 && !isNaN(_loc16_.height))
               {
                  if(layoutMode == "vertical")
                  {
                     _loc7_ = container.layoutMetadata.getValue("http://www.osmf.org/layout/attributes/box/1.0") as BoxAttributesMetadata || new BoxAttributesMetadata();
                     _loc12_.height = Math.max(0,param3 - _loc7_.absoluteSum) * _loc16_.height / _loc7_.relativeSum;
                  }
                  else
                  {
                     _loc12_.height = param3 * _loc16_.height / 100;
                  }
                  _loc11_ ^= 8;
               }
            }
         }
         if(_loc11_ != 0)
         {
            _loc8_ = param1.layoutMetadata.getValue("http://www.osmf.org/layout/anchor/1.0") as AnchorLayoutMetadata;
            if(_loc8_)
            {
               if(_loc11_ & 1 && !isNaN(_loc8_.left))
               {
                  _loc12_.x = _loc8_.left;
                  _loc11_ ^= 1;
               }
               if(_loc11_ & 2 && !isNaN(_loc8_.top))
               {
                  _loc12_.y = _loc8_.top;
                  _loc11_ ^= 2;
               }
               if(!isNaN(_loc8_.right) && param2)
               {
                  if(_loc11_ & 1 && !(_loc11_ & 4))
                  {
                     _loc12_.x = Math.max(0,param2 - _loc12_.width - _loc8_.right);
                     _loc11_ ^= 1;
                  }
                  else if(_loc11_ & 4 && !(_loc11_ & 1))
                  {
                     _loc12_.width = Math.max(0,param2 - _loc8_.right - _loc12_.x);
                     _loc11_ ^= 4;
                  }
                  else
                  {
                     _loc12_.x = Math.max(0,param2 - param1.measuredWidth - _loc8_.right);
                     _loc11_ ^= 1;
                  }
                  _loc9_ += _loc8_.right;
               }
               if(!isNaN(_loc8_.bottom) && param3)
               {
                  if(_loc11_ & 2 && !(_loc11_ & 8))
                  {
                     _loc12_.y = Math.max(0,param3 - _loc12_.height - _loc8_.bottom);
                     _loc11_ ^= 2;
                  }
                  else if(_loc11_ & 8 && !(_loc11_ & 2))
                  {
                     _loc12_.height = Math.max(0,param3 - _loc8_.bottom - _loc12_.y);
                     _loc11_ ^= 8;
                  }
                  else
                  {
                     _loc12_.y = Math.max(0,param3 - param1.measuredHeight - _loc8_.bottom);
                     _loc11_ ^= 2;
                  }
                  _loc10_ += _loc8_.bottom;
               }
            }
         }
         var _loc4_:PaddingLayoutMetadata = param1.layoutMetadata.getValue("http://www.osmf.org/layout/padding/1.0") as PaddingLayoutMetadata;
         if(_loc4_)
         {
            if(!isNaN(_loc4_.left))
            {
               _loc12_.x += _loc4_.left;
            }
            if(!isNaN(_loc4_.top))
            {
               _loc12_.y += _loc4_.top;
            }
            if(!isNaN(_loc4_.right) && !(_loc11_ & 4))
            {
               _loc12_.width -= _loc4_.right + (_loc4_.left || 0);
            }
            if(!isNaN(_loc4_.bottom) && !(_loc11_ & 8))
            {
               _loc12_.height -= _loc4_.bottom + (_loc4_.top || 0);
            }
         }
         if(_loc15_.scaleMode)
         {
            if(!(_loc11_ & 4 || _loc11_ & 8) && param1.measuredWidth && param1.measuredHeight)
            {
               _loc13_ = ScaleModeUtils.getScaledSize(_loc15_.scaleMode,_loc12_.width,_loc12_.height,param1.measuredWidth,param1.measuredHeight);
               _loc5_ = _loc12_.width - _loc13_.x;
               _loc6_ = _loc12_.height - _loc13_.y;
               _loc12_.width = _loc13_.x;
               _loc12_.height = _loc13_.y;
            }
         }
         if(layoutMode != "horizontal")
         {
            if(!_loc5_)
            {
               _loc5_ = param2 - (_loc12_.x || 0) - (_loc12_.width || 0) - _loc9_;
            }
         }
         if(layoutMode != "vertical")
         {
            if(!_loc6_)
            {
               _loc6_ = param3 - (_loc12_.y || 0) - (_loc12_.height || 0) - _loc10_;
            }
         }
         if(_loc6_)
         {
            switch(_loc15_.verticalAlign)
            {
               case null:
               case "top":
                  break;
               case "middle":
                  _loc12_.y += _loc6_ / 2;
                  break;
               case "bottom":
                  _loc12_.y += _loc6_;
            }
         }
         if(_loc5_)
         {
            switch(_loc15_.horizontalAlign)
            {
               case null:
               case "left":
                  break;
               case "center":
                  _loc12_.x += _loc5_ / 2;
                  break;
               case "right":
                  _loc12_.x += _loc5_;
            }
         }
         if(_loc15_.snapToPixel)
         {
            _loc12_.x = Math.round(_loc12_.x);
            _loc12_.y = Math.round(_loc12_.y);
            _loc12_.width = Math.round(_loc12_.width);
            _loc12_.height = Math.round(_loc12_.height);
         }
         if(layoutMode == "horizontal" || layoutMode == "vertical")
         {
            if(lastCalculatedBounds != null)
            {
               if(layoutMode == "horizontal")
               {
                  _loc12_.x = lastCalculatedBounds.x + lastCalculatedBounds.width;
               }
               else
               {
                  _loc12_.y = lastCalculatedBounds.y + lastCalculatedBounds.height;
               }
            }
            lastCalculatedBounds = _loc12_;
         }
         return _loc12_;
      }
      
      override protected function calculateContainerSize(param1:Vector.<ILayoutTarget>) : Point
      {
         var _loc2_:BoxAttributesMetadata = null;
         var _loc6_:Rectangle = null;
         var _loc5_:Rectangle = null;
         var _loc7_:* = null;
         var _loc3_:Point = new Point(NaN,NaN);
         var _loc4_:AbsoluteLayoutMetadata = container.layoutMetadata.getValue("http://www.osmf.org/layout/absolute/1.0") as AbsoluteLayoutMetadata;
         if(_loc4_)
         {
            _loc3_.x = _loc4_.width;
            _loc3_.y = _loc4_.height;
         }
         if(layoutMode != "none")
         {
            _loc2_ = new BoxAttributesMetadata();
            container.layoutMetadata.addValue("http://www.osmf.org/layout/attributes/box/1.0",_loc2_);
         }
         if(isNaN(_loc3_.x) || isNaN(_loc3_.y) || layoutMode != "none")
         {
            _loc6_ = new Rectangle();
            for each(var _loc8_ in param1)
            {
               if(_loc8_.layoutMetadata.includeInLayout)
               {
                  _loc5_ = calculateTargetBounds(_loc8_,_loc3_.x,_loc3_.y);
                  _loc5_.x ||= 0;
                  _loc5_.y ||= 0;
                  _loc5_.width ||= _loc8_.measuredWidth || 0;
                  _loc5_.height ||= _loc8_.measuredHeight || 0;
                  if(layoutMode == "horizontal")
                  {
                     if(!isNaN(_loc8_.layoutMetadata.percentWidth))
                     {
                        _loc2_.relativeSum += _loc8_.layoutMetadata.percentWidth;
                     }
                     else
                     {
                        _loc2_.absoluteSum += _loc5_.width;
                     }
                     if(_loc7_)
                     {
                        _loc5_.x = _loc7_.x + _loc7_.width;
                     }
                     _loc7_ = _loc5_;
                  }
                  else if(layoutMode == "vertical")
                  {
                     if(!isNaN(_loc8_.layoutMetadata.percentHeight))
                     {
                        _loc2_.relativeSum += _loc8_.layoutMetadata.percentHeight;
                     }
                     else
                     {
                        _loc2_.absoluteSum += _loc5_.height;
                     }
                     if(_loc7_)
                     {
                        _loc5_.y = _loc7_.y + _loc7_.height;
                     }
                     _loc7_ = _loc5_;
                  }
                  _loc6_ = _loc6_.union(_loc5_);
               }
            }
            _loc3_.x ||= _loc4_ == null || isNaN(_loc4_.width) ? _loc6_.width : _loc4_.width;
            _loc3_.y ||= _loc4_ == null || isNaN(_loc4_.height) ? _loc6_.height : _loc4_.height;
         }
         return _loc3_;
      }
   }
}

