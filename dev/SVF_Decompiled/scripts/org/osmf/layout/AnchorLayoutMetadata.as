package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class AnchorLayoutMetadata extends NonSynthesizingMetadata
   {
      public static const LEFT:String = "left";
      
      public static const TOP:String = "top";
      
      public static const RIGHT:String = "right";
      
      public static const BOTTOM:String = "bottom";
      
      private var _left:Number;
      
      private var _top:Number;
      
      private var _right:Number;
      
      private var _bottom:Number;
      
      public function AnchorLayoutMetadata()
      {
         super();
      }
      
      override public function getValue(param1:String) : *
      {
         if(param1 == null)
         {
            return undefined;
         }
         if(param1 == "left")
         {
            return left;
         }
         if(param1 == "top")
         {
            return top;
         }
         if(param1 == "right")
         {
            return right;
         }
         if(param1 == "bottom")
         {
            return bottom;
         }
         return undefined;
      }
      
      public function get left() : Number
      {
         return _left;
      }
      
      public function set left(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_left != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"left",param1,_left);
            _left = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get top() : Number
      {
         return _top;
      }
      
      public function set top(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_top != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"top",param1,_top);
            _top = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get right() : Number
      {
         return _right;
      }
      
      public function set right(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_right != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"right",param1,_right);
            _right = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get bottom() : Number
      {
         return _bottom;
      }
      
      public function set bottom(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_bottom != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"bottom",param1,_bottom);
            _bottom = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

