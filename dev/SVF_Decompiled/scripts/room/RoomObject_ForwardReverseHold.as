package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_ForwardReverseHold extends RoomObject
   {
      public function RoomObject_ForwardReverseHold(param1:MovieClip)
      {
         super(param1);
         param1.gotoAndStop(1);
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(param1 && _bHold == false && Boolean(_mc.hasOwnProperty("mouseDown")))
         {
            _mc.mouseDown();
         }
         _bHold = param1;
      }
      
      override public function onEnterFrame() : void
      {
         if(_mc)
         {
            if(_dir == 1 && _mc.currentFrame != _mc.totalFrames)
            {
               _mc.gotoAndStop(_mc.totalFrames);
            }
            else if(_dir == -1 && _mc.currentFrame != 1)
            {
               _mc.gotoAndStop(1);
            }
         }
      }
   }
}

