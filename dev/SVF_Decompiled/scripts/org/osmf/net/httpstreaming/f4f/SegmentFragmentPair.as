package org.osmf.net.httpstreaming.f4f
{
   internal class SegmentFragmentPair
   {
      private var _firstSegment:uint;
      
      private var _fragmentsPerSegment:uint;
      
      private var _fragmentsAccrued:uint;
      
      public function SegmentFragmentPair(param1:uint, param2:uint)
      {
         super();
         _firstSegment = param1;
         _fragmentsPerSegment = param2;
      }
      
      public function get firstSegment() : uint
      {
         return _firstSegment;
      }
      
      public function get fragmentsPerSegment() : uint
      {
         return _fragmentsPerSegment;
      }
      
      public function set fragmentsAccrued(param1:uint) : void
      {
         _fragmentsAccrued = param1;
      }
      
      public function get fragmentsAccrued() : uint
      {
         return _fragmentsAccrued;
      }
   }
}

