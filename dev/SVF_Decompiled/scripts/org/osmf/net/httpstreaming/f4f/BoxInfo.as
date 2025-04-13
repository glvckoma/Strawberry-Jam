package org.osmf.net.httpstreaming.f4f
{
   internal class BoxInfo
   {
      private var _size:Number;
      
      private var _type:String;
      
      public function BoxInfo(param1:Number, param2:String)
      {
         super();
         _size = param1;
         _type = param2;
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
   }
}

