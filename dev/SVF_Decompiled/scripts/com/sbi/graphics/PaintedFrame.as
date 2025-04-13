package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class PaintedFrame
   {
      private var _isValid:Boolean;
      
      private var _min:Point;
      
      private var _max:Point;
      
      private var _frameData:BitmapData;
      
      public function PaintedFrame(param1:Point, param2:Point)
      {
         super();
         _isValid = true;
         _min = param1.clone();
         _max = param2.clone();
         _frameData = new BitmapData(calcWidth(),calcHeight(),true,0);
      }
      
      public function destroy() : void
      {
         _isValid = false;
         _frameData.dispose();
      }
      
      public function flip() : PaintedFrame
      {
         var _loc1_:PaintedFrame = new PaintedFrame(_min,_max);
         var _loc2_:Matrix = new Matrix(-1,0,0,1,_frameData.width,0);
         _loc1_.frameData.draw(_frameData,_loc2_);
         return _loc1_;
      }
      
      public function get isValid() : Boolean
      {
         return _isValid;
      }
      
      public function set isValid(param1:Boolean) : void
      {
         _isValid = param1;
      }
      
      public function get frameData() : BitmapData
      {
         return _frameData;
      }
      
      public function copyBoundsTo(param1:Point, param2:Point) : void
      {
         param1.copyFrom(_min);
         param2.copyFrom(_max);
      }
      
      public function updateAnchorPoint(param1:Point, param2:Boolean) : void
      {
         param1.copyFrom(_min);
         if(param2)
         {
            param1.x = 500 - _max.x;
         }
      }
      
      public function validateBounds(param1:Point, param2:Point) : Boolean
      {
         return _min.equals(param1) && _max.equals(param2);
      }
      
      private function calcWidth() : int
      {
         return 1 + _max.x - _min.x;
      }
      
      private function calcHeight() : int
      {
         return 1 + _max.y - _min.y;
      }
   }
}

