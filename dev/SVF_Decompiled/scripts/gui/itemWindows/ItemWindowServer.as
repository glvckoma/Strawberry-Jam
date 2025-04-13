package gui.itemWindows
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class ItemWindowServer extends ItemWindowBase
   {
      public function ItemWindowServer(param1:Function, param2:MovieClip, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("serverBarSml",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            _isCurrItemLoaded = true;
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.txt.mouseEnabled = false;
         _window.buddy.mouseEnabled = false;
         _window.g1.mouseEnabled = false;
         _window.g2.mouseEnabled = false;
         _window.g3.mouseEnabled = false;
         _window.o1.mouseEnabled = false;
         _window.o2.mouseEnabled = false;
         _window.o3.mouseEnabled = false;
         _window.full.mouseEnabled = false;
         _window.full.mouseChildren = false;
      }
      
      public function get full() : Boolean
      {
         return _window.full.visible;
      }
      
      public function set text(param1:String) : void
      {
         _window.txt.text = param1;
      }
      
      public function get textField() : TextField
      {
         return _window.txt;
      }
      
      public function set buddy(param1:Boolean) : void
      {
         _window.buddy.visible = param1;
      }
      
      public function set flag(param1:int) : void
      {
         _window.flag.gotoAndStop(param1);
      }
      
      public function set population(param1:String) : void
      {
         switch(param1)
         {
            case "0":
               _window.full.visible = false;
               _window.o1.visible = false;
               _window.o2.visible = false;
               _window.o3.visible = false;
               break;
            case "1":
               _window.o1.visible = true;
               _window.o2.visible = false;
               _window.o3.visible = false;
               _window.full.visible = false;
               break;
            case "2":
               _window.o1.visible = true;
               _window.o2.visible = true;
               _window.o3.visible = false;
               _window.full.visible = false;
               break;
            case "3":
               _window.o1.visible = true;
               _window.o2.visible = true;
               _window.o3.visible = true;
               _window.full.visible = false;
               break;
            case "4":
               _window.full.visible = true;
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener("rollOver",_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener("rollOut",_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null)
            {
               addEventListener("mouseDown",_memberOnlyDown,false,0,true);
            }
         }
      }
   }
}

