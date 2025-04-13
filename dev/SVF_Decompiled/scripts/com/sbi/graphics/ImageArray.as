package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.utils.ByteArray;
   
   public class ImageArray
   {
      public static const VERSION:uint = 117967104;
      
      private var _frames:Array;
      
      public function ImageArray()
      {
         super();
         _frames = [];
      }
      
      public function get length() : int
      {
         return _frames.length;
      }
      
      public function release() : void
      {
         _frames.splice(0,_frames.length);
      }
      
      public function addBitmap(param1:BitmapData) : void
      {
         var _loc2_:Object = BitmapByteArray.scaleAndPackImage(param1);
         _frames.push(_loc2_);
      }
      
      public function attachShadow(param1:BitmapData) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(_frames.length)
         {
            _loc2_ = _frames[_frames.length - 1];
            _loc3_ = BitmapByteArray.scaleAndPackShadow(param1,_loc2_.x,_loc2_.y,_loc2_.w,_loc2_.h);
            _loc2_.s = _loc3_.b;
            _loc2_.sm = _loc3_.sm;
         }
      }
      
      public function addFrame(param1:Object) : void
      {
         _frames.push(param1);
      }
      
      public function loadPackage(param1:ByteArray) : void
      {
         release();
         param1.position = 0;
         try
         {
            param1.uncompress();
         }
         catch(err:Error)
         {
         }
         var _loc2_:Object = param1.readObject();
         if(_loc2_.v != 117967104)
         {
            return;
         }
         _frames = _loc2_.f;
      }
      
      public function getFrame(param1:int) : Object
      {
         return _frames[param1];
      }
      
      public function getPackage(param1:Boolean = true) : ByteArray
      {
         var _loc4_:ByteArray = null;
         var _loc2_:Object = null;
         if(_frames.length)
         {
            _loc2_ = {
               "v":117967104,
               "f":_frames
            };
            _loc4_ = new ByteArray();
            _loc4_.writeObject(_loc2_);
            _loc4_.position = 0;
            if(param1)
            {
               _loc4_.compress();
            }
         }
         return _loc4_;
      }
   }
}

