package game.moatMadness
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class FrameAnimation
   {
      public var _container:Sprite;
      
      private var _activeImage:Bitmap;
      
      private var _totalFrames:int;
      
      private var _frameWidth:int;
      
      private var _frameHeight:int;
      
      private var _frame:int;
      
      private var _frameTime:Number;
      
      private var _frameTimer:Number;
      
      private var _imageFrames:Bitmap;
      
      private var _loopFrame:int;
      
      public function FrameAnimation(param1:Bitmap, param2:int, param3:int, param4:int, param5:int, param6:Number, param7:int = -1, param8:int = -1)
      {
         super();
         _container = new Sprite();
         _frameWidth = param4;
         _frameHeight = param5;
         _container.x = param2;
         _container.y = param3;
         _loopFrame = param8 - 1;
         _imageFrames = param1;
         var _loc9_:int = _imageFrames.width;
         var _loc10_:int = _imageFrames.height;
         _totalFrames = _loc9_ / _frameWidth * (_loc10_ / _frameHeight);
         if(param7 != -1 && param7 < _totalFrames)
         {
            _totalFrames = param7;
         }
         _frameTime = param6 / _totalFrames;
         _activeImage = new Bitmap();
         _activeImage.x = -_frameWidth / 2;
         _activeImage.y = -_frameHeight / 2;
         _container.addChild(_activeImage);
         setActiveFrame(0);
      }
      
      public function heartbeat(param1:Number) : void
      {
         if(!atFrameEnd())
         {
            _frameTimer -= param1;
            if(_frameTimer <= 0)
            {
               setActiveFrame(_frame + 1);
            }
         }
      }
      
      public function atFrameEnd() : Boolean
      {
         return _frame >= _totalFrames;
      }
      
      public function atNextToLastFrame(param1:int) : Boolean
      {
         return _frame >= _totalFrames - param1;
      }
      
      private function setActiveFrame(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Rectangle = null;
         var _loc6_:Point = null;
         var _loc4_:BitmapData = null;
         if(param1 >= _totalFrames)
         {
            if(_loopFrame >= 0)
            {
               param1 = _loopFrame;
            }
         }
         if(param1 < _totalFrames)
         {
            _loc2_ = _imageFrames.width;
            _loc9_ = _imageFrames.height;
            _loc5_ = _loc2_ / _frameWidth;
            _loc8_ = param1 % _loc5_;
            _loc7_ = param1 / _loc5_;
            _loc3_ = new Rectangle(_loc8_ * _frameWidth,_loc7_ * _frameHeight,_frameWidth,_frameHeight);
            _loc6_ = new Point(0,0);
            _loc4_ = new BitmapData(_frameWidth,_frameHeight);
            _loc4_.copyPixels(_imageFrames.bitmapData,_loc3_,_loc6_);
            _activeImage.bitmapData = _loc4_;
            _frame = param1;
            _frameTimer = _frameTime;
         }
         else
         {
            _frame = _totalFrames;
            _frameTimer = 0;
         }
      }
   }
}

