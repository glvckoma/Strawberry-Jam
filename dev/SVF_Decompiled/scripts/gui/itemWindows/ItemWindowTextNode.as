package gui.itemWindows
{
   import flash.events.MouseEvent;
   
   public class ItemWindowTextNode extends ItemWindowBase
   {
      private var _originalText:String;
      
      public function ItemWindowTextNode(param1:Function, param2:String, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("chatTextNode",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function onWindowLoadCallback() : void
      {
         setChildrenAndInitialConditions();
         addEventListeners();
         super.onWindowLoadCallback();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_currItem)
         {
            setupText();
         }
         addEventListener("rollOver",onRollOver,false,0,true);
         addEventListener("rollOut",onRollOut,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         removeEventListener("rollOver",onRollOver);
         removeEventListener("rollOut",onRollOut);
         super.removeEventListeners();
      }
      
      public function get text() : String
      {
         return _originalText;
      }
      
      public function updateToBeCentered(param1:int) : void
      {
         _window.x += (param1 - _window.width) * 0.5;
      }
      
      private function setupText() : void
      {
         var _loc2_:int = 0;
         var _loc1_:String = null;
         _window.txt.text = _currItem;
         _originalText = String(_currItem);
         if(_window.txt.textWidth > _window.txt.width)
         {
            _window.txt.text = "";
            _loc2_ = 0;
            _loc1_ = "";
            while(_window.txt.textWidth < _window.txt.width)
            {
               _loc1_ += String(_currItem).charAt(_loc2_);
               _window.txt.text = _loc1_ + "...";
               _loc2_++;
            }
            _window.txt.text = _loc1_.slice(0,_loc1_.length - 1) + "...";
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window && _window.currentFrameLabel != "on")
         {
            _window.gotoAndStop("on");
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_window && _window.currentFrameLabel != "off")
         {
            _window.gotoAndStop("off");
         }
      }
   }
}

