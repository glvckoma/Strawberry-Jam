package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class AbsoluteLayoutMetadata extends NonSynthesizingMetadata
   {
      public static const X:String = "x";
      
      public static const Y:String = "y";
      
      public static const WIDTH:String = "width";
      
      public static const HEIGHT:String = "height";
      
      private var _x:Number;
      
      private var _y:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      public function AbsoluteLayoutMetadata()
      {
         super();
      }
      
      override public function getValue(param1:String) : *
      {
         if(param1 == null)
         {
            return undefined;
         }
         if(param1 == "x")
         {
            return x;
         }
         if(param1 == "y")
         {
            return y;
         }
         if(param1 == "width")
         {
            return width;
         }
         if(param1 == "height")
         {
            return height;
         }
         return undefined;
      }
      
      public function get x() : Number
      {
         return _x;
      }
      
      public function set x(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_x != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"x",param1,_x);
            _x = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get y() : Number
      {
         return _y;
      }
      
      public function set y(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_y != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"y",param1,_y);
            _y = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get width() : Number
      {
         return _width;
      }
      
      public function set width(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_width != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"width",param1,_width);
            _width = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get height() : Number
      {
         return _height;
      }
      
      public function set height(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_height != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"height",param1,_height);
            _height = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

