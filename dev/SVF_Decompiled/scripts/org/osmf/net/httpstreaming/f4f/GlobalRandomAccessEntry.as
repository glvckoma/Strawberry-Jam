package org.osmf.net.httpstreaming.f4f
{
   internal class GlobalRandomAccessEntry
   {
      private var _time:Number;
      
      private var _segment:uint;
      
      private var _fragment:uint;
      
      private var _afraOffset:Number;
      
      private var _offsetFromAfra:Number;
      
      public function GlobalRandomAccessEntry()
      {
         super();
      }
      
      public function get time() : Number
      {
         return _time;
      }
      
      public function set time(param1:Number) : void
      {
         _time = param1;
      }
      
      public function get segment() : uint
      {
         return _segment;
      }
      
      public function set segment(param1:uint) : void
      {
         _segment = param1;
      }
      
      public function get fragment() : uint
      {
         return _fragment;
      }
      
      public function set fragment(param1:uint) : void
      {
         _fragment = param1;
      }
      
      public function get afraOffset() : Number
      {
         return _afraOffset;
      }
      
      public function set afraOffset(param1:Number) : void
      {
         _afraOffset = param1;
      }
      
      public function get offsetFromAfra() : Number
      {
         return _offsetFromAfra;
      }
      
      public function set offsetFromAfra(param1:Number) : void
      {
         _offsetFromAfra = param1;
      }
   }
}

