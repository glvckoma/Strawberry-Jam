package org.osmf.net.httpstreaming.f4f
{
   internal class AdobeSegmentRunTable extends FullBox
   {
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _segmentFragmentPairs:Vector.<SegmentFragmentPair>;
      
      public function AdobeSegmentRunTable()
      {
         super();
         _segmentFragmentPairs = new Vector.<SegmentFragmentPair>();
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return _qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(param1:Vector.<String>) : void
      {
         _qualitySegmentURLModifiers = param1;
      }
      
      public function get segmentFragmentPairs() : Vector.<SegmentFragmentPair>
      {
         return _segmentFragmentPairs;
      }
      
      public function addSegmentFragmentPair(param1:SegmentFragmentPair) : void
      {
         var _loc2_:SegmentFragmentPair = _segmentFragmentPairs.length <= 0 ? null : _segmentFragmentPairs[_segmentFragmentPairs.length - 1];
         var _loc3_:uint = 0;
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.fragmentsAccrued + (param1.firstSegment - _loc2_.firstSegment) * _loc2_.fragmentsPerSegment;
         }
         param1.fragmentsAccrued = _loc3_;
         _segmentFragmentPairs.push(param1);
      }
      
      public function findSegmentIdByFragmentId(param1:uint) : uint
      {
         var _loc2_:SegmentFragmentPair = null;
         var _loc3_:* = 0;
         if(param1 < 1)
         {
            return 0;
         }
         _loc3_ = 1;
         while(_loc3_ < _segmentFragmentPairs.length)
         {
            _loc2_ = _segmentFragmentPairs[_loc3_];
            if(_loc2_.fragmentsAccrued >= param1)
            {
               return calculateSegmentId(_segmentFragmentPairs[_loc3_ - 1],param1);
            }
            _loc3_++;
         }
         return calculateSegmentId(_segmentFragmentPairs[_segmentFragmentPairs.length - 1],param1);
      }
      
      public function get totalFragments() : uint
      {
         return _segmentFragmentPairs[_segmentFragmentPairs.length - 1].fragmentsPerSegment + _segmentFragmentPairs[_segmentFragmentPairs.length - 1].fragmentsAccrued;
      }
      
      private function calculateSegmentId(param1:SegmentFragmentPair, param2:uint) : uint
      {
         return param1.firstSegment + int((param2 - param1.fragmentsAccrued - 1) / param1.fragmentsPerSegment);
      }
   }
}

