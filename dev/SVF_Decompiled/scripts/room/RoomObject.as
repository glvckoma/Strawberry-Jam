package room
{
   import flash.display.MovieClip;
   
   public class RoomObject
   {
      protected var _mc:MovieClip;
      
      protected var _dir:int;
      
      protected var _bHold:Boolean;
      
      protected var _mouseOver:Boolean;
      
      public function RoomObject(param1:MovieClip)
      {
         super();
         _dir = 0;
         _mc = param1;
      }
      
      public function get hold() : Boolean
      {
         return _bHold;
      }
      
      public function get mc() : MovieClip
      {
         return _mc;
      }
      
      public function mouseDown(param1:Boolean) : void
      {
         _bHold = param1;
      }
      
      public function release() : void
      {
         if(_mc)
         {
            _mc = null;
         }
      }
      
      public function setDir(param1:int) : void
      {
         _dir = param1;
      }
      
      public function setMouseOver(param1:Boolean) : void
      {
         _mouseOver = param1;
      }
      
      public function isMouseOver() : Boolean
      {
         return _mouseOver;
      }
      
      public function onEnterFrame() : void
      {
      }
   }
}

