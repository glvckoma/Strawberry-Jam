package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class LayoutAttributesMetadata extends NonSynthesizingMetadata
   {
      public static const INDEX:String = "index";
      
      public static const SCALE_MODE:String = "scaleMode";
      
      public static const VERTICAL_ALIGN:String = "verticalAlign";
      
      public static const HORIZONTAL_ALIGN:String = "horizontalAlign";
      
      public static const SNAP_TO_PIXEL:String = "snapToPixel";
      
      public static const MODE:String = "layoutMode";
      
      public static const INCLUDE_IN_LAYOUT:String = "includeInLayout";
      
      private var _index:Number = NaN;
      
      private var _scaleMode:String;
      
      private var _verticalAlign:String;
      
      private var _horizontalAlign:String;
      
      private var _snapToPixel:Boolean;
      
      private var _layoutMode:String;
      
      private var _includeInLayout:Boolean;
      
      public function LayoutAttributesMetadata()
      {
         super();
         _verticalAlign = null;
         _horizontalAlign = null;
         _scaleMode = null;
         _snapToPixel = true;
         _layoutMode = "none";
         _includeInLayout = true;
      }
      
      override public function getValue(param1:String) : *
      {
         if(param1 == null)
         {
            return undefined;
         }
         if(param1 == "index")
         {
            return index;
         }
         if(param1 == "scaleMode")
         {
            return scaleMode;
         }
         if(param1 == "verticalAlign")
         {
            return verticalAlign;
         }
         if(param1 == "horizontalAlign")
         {
            return horizontalAlign;
         }
         if(param1 == "snapToPixel")
         {
            return snapToPixel;
         }
         if(param1 == "includeInLayout")
         {
            return snapToPixel;
         }
         return undefined;
      }
      
      public function get index() : Number
      {
         return _index;
      }
      
      public function set index(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_index != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"index",param1,_index);
            _index = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get scaleMode() : String
      {
         return _scaleMode;
      }
      
      public function set scaleMode(param1:String) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_scaleMode != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"scaleMode",param1,_scaleMode);
            _scaleMode = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get verticalAlign() : String
      {
         return _verticalAlign;
      }
      
      public function set verticalAlign(param1:String) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_verticalAlign != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"verticalAlign",param1,_verticalAlign);
            _verticalAlign = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get horizontalAlign() : String
      {
         return _horizontalAlign;
      }
      
      public function set horizontalAlign(param1:String) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_horizontalAlign != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"horizontalAlign",param1,_horizontalAlign);
            _horizontalAlign = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get snapToPixel() : Boolean
      {
         return _snapToPixel;
      }
      
      public function set snapToPixel(param1:Boolean) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_snapToPixel != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"snapToPixel",param1,_snapToPixel);
            _snapToPixel = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get layoutMode() : String
      {
         return _layoutMode;
      }
      
      public function set layoutMode(param1:String) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_layoutMode != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"layoutMode",param1,_layoutMode);
            _layoutMode = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get includeInLayout() : Boolean
      {
         return _includeInLayout;
      }
      
      public function set includeInLayout(param1:Boolean) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_includeInLayout != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"includeInLayout",param1,_layoutMode);
            _includeInLayout = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

