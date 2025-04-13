package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_GemPickup extends RoomObject
   {
      public function RoomObject_GemPickup(param1:MovieClip)
      {
         super(param1);
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(param1 && _bHold == false)
         {
            _mc.visible = false;
            _bHold = true;
            release();
         }
      }
   }
}

