package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_RandomClick extends RoomObject
   {
      private var _frameCountdown:int;
      
      public function RoomObject_RandomClick(param1:MovieClip)
      {
         super(param1);
         param1.stop();
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(_bHold == false && param1 == true)
         {
            _frameCountdown = 5 + int(Math.random() * _mc.totalFrames) / 2;
            _bHold = true;
         }
      }
      
      override public function onEnterFrame() : void
      {
         if(_bHold)
         {
            _mc.gotoAndStop(_mc.totalFrames);
            if(_frameCountdown == 0)
            {
               _bHold = false;
            }
            else
            {
               _frameCountdown--;
            }
         }
         else
         {
            _mc.gotoAndStop(0);
         }
      }
   }
}

