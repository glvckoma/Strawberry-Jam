package org.osmf.net
{
   public class DynamicStreamingItem
   {
      private var _bitrate:Number;
      
      private var _stream:String;
      
      private var _width:int;
      
      private var _height:int;
      
      public function DynamicStreamingItem(param1:String, param2:Number, param3:int = -1, param4:int = -1)
      {
         super();
         _stream = param1;
         _bitrate = param2;
         _width = param3;
         _height = param4;
      }
      
      public function get streamName() : String
      {
         return _stream;
      }
      
      public function set streamName(param1:String) : void
      {
         _stream = param1;
      }
      
      public function get bitrate() : Number
      {
         return _bitrate;
      }
      
      public function set bitrate(param1:Number) : void
      {
         _bitrate = param1;
      }
      
      public function get width() : int
      {
         return _width;
      }
      
      public function set width(param1:int) : void
      {
         _width = param1;
      }
      
      public function get height() : int
      {
         return _height;
      }
      
      public function set height(param1:int) : void
      {
         _height = param1;
      }
   }
}

