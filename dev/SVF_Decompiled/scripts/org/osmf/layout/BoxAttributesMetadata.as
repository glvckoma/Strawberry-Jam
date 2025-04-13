package org.osmf.layout
{
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.NonSynthesizingMetadata;
   
   internal class BoxAttributesMetadata extends NonSynthesizingMetadata
   {
      public static const RELATIVE_SUM:String = "relativeSum";
      
      public static const ABSOLUTE_SUM:String = "absoluteSum";
      
      private var _relativeSum:Number;
      
      private var _absoluteSum:Number;
      
      public function BoxAttributesMetadata()
      {
         super();
         _relativeSum = 0;
         _absoluteSum = 0;
      }
      
      override public function getValue(param1:String) : *
      {
         if(param1 == null)
         {
            return undefined;
         }
         if(param1 == "relativeSum")
         {
            return relativeSum;
         }
         if(param1 == "absoluteSum")
         {
            return absoluteSum;
         }
         return undefined;
      }
      
      public function get relativeSum() : Number
      {
         return _relativeSum;
      }
      
      public function set relativeSum(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_relativeSum != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"relativeSum",param1,_relativeSum);
            _relativeSum = param1;
            dispatchEvent(_loc2_);
         }
      }
      
      public function get absoluteSum() : Number
      {
         return _absoluteSum;
      }
      
      public function set absoluteSum(param1:Number) : void
      {
         var _loc2_:MetadataEvent = null;
         if(_absoluteSum != param1)
         {
            _loc2_ = new MetadataEvent("valueChange",false,false,"absoluteSum",param1,_absoluteSum);
            _absoluteSum = param1;
            dispatchEvent(_loc2_);
         }
      }
   }
}

