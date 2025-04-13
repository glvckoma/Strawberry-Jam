package org.osmf.layout
{
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataSynthesizer;
   import org.osmf.metadata.NullMetadataSynthesizer;
   
   public class LayoutMetadata extends Metadata
   {
      public static const LAYOUT_NAMESPACE:String = "http://www.osmf.org/layout/1.0";
      
      private const SYNTHESIZER:NullMetadataSynthesizer = new NullMetadataSynthesizer();
      
      public function LayoutMetadata()
      {
         super();
      }
      
      public function get index() : Number
      {
         return !!lazyAttributes ? lazyAttributes.index : NaN;
      }
      
      public function set index(param1:Number) : void
      {
         eagerAttributes.index = param1;
      }
      
      public function get scaleMode() : String
      {
         return !!lazyAttributes ? lazyAttributes.scaleMode : null;
      }
      
      public function set scaleMode(param1:String) : void
      {
         eagerAttributes.scaleMode = param1;
      }
      
      public function get horizontalAlign() : String
      {
         return !!lazyAttributes ? lazyAttributes.horizontalAlign : null;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         eagerAttributes.horizontalAlign = param1;
      }
      
      public function get verticalAlign() : String
      {
         return !!lazyAttributes ? lazyAttributes.verticalAlign : null;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         eagerAttributes.verticalAlign = param1;
      }
      
      public function get snapToPixel() : Boolean
      {
         return !!lazyAttributes ? lazyAttributes.snapToPixel : true;
      }
      
      public function set snapToPixel(param1:Boolean) : void
      {
         eagerAttributes.snapToPixel = param1;
      }
      
      public function get layoutMode() : String
      {
         return !!lazyAttributes ? lazyAttributes.layoutMode : "none";
      }
      
      public function set layoutMode(param1:String) : void
      {
         eagerAttributes.layoutMode = param1;
      }
      
      public function get includeInLayout() : Boolean
      {
         return !!lazyAttributes ? lazyAttributes.includeInLayout : true;
      }
      
      public function set includeInLayout(param1:Boolean) : void
      {
         eagerAttributes.includeInLayout = param1;
      }
      
      public function get x() : Number
      {
         return !!lazyAbsolute ? lazyAbsolute.x : NaN;
      }
      
      public function set x(param1:Number) : void
      {
         eagerAbsolute.x = param1;
      }
      
      public function get y() : Number
      {
         return !!lazyAbsolute ? lazyAbsolute.y : NaN;
      }
      
      public function set y(param1:Number) : void
      {
         eagerAbsolute.y = param1;
      }
      
      public function get width() : Number
      {
         return !!lazyAbsolute ? lazyAbsolute.width : NaN;
      }
      
      public function set width(param1:Number) : void
      {
         eagerAbsolute.width = param1;
      }
      
      public function get height() : Number
      {
         return !!lazyAbsolute ? lazyAbsolute.height : NaN;
      }
      
      public function set height(param1:Number) : void
      {
         eagerAbsolute.height = param1;
      }
      
      public function get percentX() : Number
      {
         return !!lazyRelative ? lazyRelative.x : NaN;
      }
      
      public function set percentX(param1:Number) : void
      {
         eagerRelative.x = param1;
      }
      
      public function get percentY() : Number
      {
         return !!lazyRelative ? lazyRelative.y : NaN;
      }
      
      public function set percentY(param1:Number) : void
      {
         eagerRelative.y = param1;
      }
      
      public function get percentWidth() : Number
      {
         return !!lazyRelative ? lazyRelative.width : NaN;
      }
      
      public function set percentWidth(param1:Number) : void
      {
         eagerRelative.width = param1;
      }
      
      public function get percentHeight() : Number
      {
         return !!lazyRelative ? lazyRelative.height : NaN;
      }
      
      public function set percentHeight(param1:Number) : void
      {
         eagerRelative.height = param1;
      }
      
      public function get left() : Number
      {
         return !!lazyAnchor ? lazyAnchor.left : NaN;
      }
      
      public function set left(param1:Number) : void
      {
         eagerAnchor.left = param1;
      }
      
      public function get top() : Number
      {
         return !!lazyAnchor ? lazyAnchor.top : NaN;
      }
      
      public function set top(param1:Number) : void
      {
         eagerAnchor.top = param1;
      }
      
      public function get right() : Number
      {
         return !!lazyAnchor ? lazyAnchor.right : NaN;
      }
      
      public function set right(param1:Number) : void
      {
         eagerAnchor.right = param1;
      }
      
      public function get bottom() : Number
      {
         return !!lazyAnchor ? lazyAnchor.bottom : NaN;
      }
      
      public function set bottom(param1:Number) : void
      {
         eagerAnchor.bottom = param1;
      }
      
      public function get paddingLeft() : Number
      {
         return !!lazyPadding ? lazyPadding.left : NaN;
      }
      
      public function set paddingLeft(param1:Number) : void
      {
         eagerPadding.left = param1;
      }
      
      public function get paddingTop() : Number
      {
         return !!lazyPadding ? lazyPadding.top : NaN;
      }
      
      public function set paddingTop(param1:Number) : void
      {
         eagerPadding.top = param1;
      }
      
      public function get paddingRight() : Number
      {
         return !!lazyPadding ? lazyPadding.right : NaN;
      }
      
      public function set paddingRight(param1:Number) : void
      {
         eagerPadding.right = param1;
      }
      
      public function get paddingBottom() : Number
      {
         return !!lazyPadding ? lazyPadding.bottom : NaN;
      }
      
      public function set paddingBottom(param1:Number) : void
      {
         eagerPadding.bottom = param1;
      }
      
      override public function toString() : String
      {
         return "abs [" + x + ", " + y + ", " + width + ", " + height + "] " + "rel [" + percentX + ", " + percentY + ", " + percentWidth + ", " + percentHeight + "] " + "anch (" + left + ", " + top + ")(" + right + ", " + bottom + ") " + "pad [" + paddingLeft + ", " + paddingTop + ", " + paddingRight + ", " + paddingBottom + "] " + "layoutMode: " + layoutMode + " " + "index: " + index + " " + "scale: " + scaleMode + " " + "valign: " + verticalAlign + " " + "halign: " + horizontalAlign + " " + "snap: " + snapToPixel;
      }
      
      override public function get synthesizer() : MetadataSynthesizer
      {
         return SYNTHESIZER;
      }
      
      private function get lazyAttributes() : LayoutAttributesMetadata
      {
         return getValue("http://www.osmf.org/layout/attributes/1.0") as LayoutAttributesMetadata;
      }
      
      private function get eagerAttributes() : LayoutAttributesMetadata
      {
         var _loc1_:LayoutAttributesMetadata = lazyAttributes;
         if(_loc1_ == null)
         {
            _loc1_ = new LayoutAttributesMetadata();
            addValue("http://www.osmf.org/layout/attributes/1.0",_loc1_);
         }
         return _loc1_;
      }
      
      private function get lazyAbsolute() : AbsoluteLayoutMetadata
      {
         return getValue("http://www.osmf.org/layout/absolute/1.0") as AbsoluteLayoutMetadata;
      }
      
      private function get eagerAbsolute() : AbsoluteLayoutMetadata
      {
         var _loc1_:AbsoluteLayoutMetadata = lazyAbsolute;
         if(_loc1_ == null)
         {
            _loc1_ = new AbsoluteLayoutMetadata();
            addValue("http://www.osmf.org/layout/absolute/1.0",_loc1_);
         }
         return _loc1_;
      }
      
      private function get lazyRelative() : RelativeLayoutMetadata
      {
         return getValue("http://www.osmf.org/layout/relative/1.0") as RelativeLayoutMetadata;
      }
      
      private function get eagerRelative() : RelativeLayoutMetadata
      {
         var _loc1_:RelativeLayoutMetadata = lazyRelative;
         if(_loc1_ == null)
         {
            _loc1_ = new RelativeLayoutMetadata();
            addValue("http://www.osmf.org/layout/relative/1.0",_loc1_);
         }
         return _loc1_;
      }
      
      private function get lazyAnchor() : AnchorLayoutMetadata
      {
         return getValue("http://www.osmf.org/layout/anchor/1.0") as AnchorLayoutMetadata;
      }
      
      private function get eagerAnchor() : AnchorLayoutMetadata
      {
         var _loc1_:AnchorLayoutMetadata = lazyAnchor;
         if(_loc1_ == null)
         {
            _loc1_ = new AnchorLayoutMetadata();
            addValue("http://www.osmf.org/layout/anchor/1.0",_loc1_);
         }
         return _loc1_;
      }
      
      private function get lazyPadding() : PaddingLayoutMetadata
      {
         return getValue("http://www.osmf.org/layout/padding/1.0") as PaddingLayoutMetadata;
      }
      
      private function get eagerPadding() : PaddingLayoutMetadata
      {
         var _loc1_:PaddingLayoutMetadata = lazyPadding;
         if(_loc1_ == null)
         {
            _loc1_ = new PaddingLayoutMetadata();
            addValue("http://www.osmf.org/layout/padding/1.0",_loc1_);
         }
         return _loc1_;
      }
   }
}

