package game
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuiButton
   {
      private var _mc:MovieClip;
      
      private var _clickFunc:Function;
      
      private var _grayBtn:MovieClip;
      
      private var _isGray:Boolean;
      
      private var _pressed:Boolean;
      
      private var _usePressedState:Boolean;
      
      public function GuiButton(param1:MovieClip, param2:Function)
      {
         super();
         _mc = param1;
         _grayBtn = param1.grayBtn;
         if(_grayBtn)
         {
            _grayBtn.visible = false;
         }
         _isGray = false;
         _clickFunc = param2;
         _mc.addEventListener("rollOver",mouseOver);
         _mc.addEventListener("rollOut",mouseOut);
         _mc.addEventListener("mouseDown",mouseClick);
         _mc.gotoAndStop("off");
      }
      
      public function setGrayState(param1:Boolean) : void
      {
         if(_grayBtn)
         {
            _isGray = param1;
            _grayBtn.visible = param1;
         }
         else
         {
            _isGray = false;
         }
      }
      
      public function setUsePressedState() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _mc.currentLabels.length)
         {
            if(_mc.currentLabels[_loc1_].name == "pressed")
            {
               _usePressedState = true;
               break;
            }
            _loc1_++;
         }
      }
      
      public function setPressedState(param1:Boolean) : void
      {
         _pressed = param1;
         if(_usePressedState)
         {
            if(_pressed)
            {
               if(_mc.currentFrameLabel != "pressed")
               {
                  _mc.gotoAndStop("pressed");
               }
            }
            else
            {
               _mc.gotoAndPlay("off");
            }
         }
      }
      
      public function release() : void
      {
         _mc.removeEventListener("rollOver",mouseOver);
         _mc.removeEventListener("rollOut",mouseOut);
         _mc.removeEventListener("mouseDown",mouseClick);
         _mc.parent.removeChild(_mc);
         _grayBtn = null;
         _isGray = false;
         _pressed = false;
         _usePressedState = false;
         _mc = null;
      }
      
      private function mouseOver(param1:MouseEvent) : void
      {
         if(!_isGray && !_pressed)
         {
            if(_mc.currentFrameLabel != "on")
            {
               _mc.gotoAndPlay("on");
            }
            AJAudio.playHudBtnRollover();
         }
      }
      
      private function mouseOut(param1:MouseEvent) : void
      {
         if(!_isGray && !_pressed)
         {
            if(_mc.currentFrameLabel != "off")
            {
               _mc.gotoAndPlay("off");
            }
         }
      }
      
      private function mouseClick(param1:MouseEvent) : void
      {
         if(!_isGray && !_pressed)
         {
            if(_clickFunc.length == 1)
            {
               _clickFunc(param1);
            }
            else
            {
               _clickFunc();
            }
            if(_usePressedState)
            {
               setPressedState(true);
            }
            AJAudio.playHudBtnClick();
         }
      }
   }
}

