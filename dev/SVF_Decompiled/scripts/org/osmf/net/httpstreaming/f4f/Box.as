package org.osmf.net.httpstreaming.f4f
{
   internal class Box
   {
      private var _size:Number;
      
      private var _type:String;
      
      private var _boxLength:uint;
      
      public function Box()
      {
         super();
      }
      
      public function get size() : Number
      {
         return _size;
      }
      
      public function set size(param1:Number) : void
      {
         _size = param1;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function set type(param1:String) : void
      {
         _type = param1;
      }
      
      public function get boxLength() : uint
      {
         return _boxLength;
      }
      
      public function set boxLength(param1:uint) : void
      {
         _boxLength = param1;
      }
   }
}

