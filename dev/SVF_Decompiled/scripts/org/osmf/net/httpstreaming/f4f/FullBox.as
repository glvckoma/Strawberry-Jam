package org.osmf.net.httpstreaming.f4f
{
   internal class FullBox extends Box
   {
      private var _version:uint;
      
      private var _flags:uint;
      
      public function FullBox()
      {
         super();
      }
      
      public function get version() : uint
      {
         return _version;
      }
      
      public function set version(param1:uint) : void
      {
         _version = param1;
      }
      
      public function get flags() : uint
      {
         return _flags;
      }
      
      public function set flags(param1:uint) : void
      {
         _flags = param1;
      }
   }
}

