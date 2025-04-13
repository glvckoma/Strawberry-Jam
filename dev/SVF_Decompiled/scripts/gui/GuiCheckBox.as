package gui
{
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class GuiCheckBox
   {
      public var box:MovieClip;
      
      public var grayBox:MovieClip;
      
      public var check:MovieClip;
      
      public var chkTxt:TextField;
      
      private var _currCheckBox:MovieClip;
      
      private var _checkCallback:Function;
      
      private var _glow:GlowFilter;
      
      public function GuiCheckBox(param1:MovieClip, param2:Function = null)
      {
         super();
         _currCheckBox = param1;
         _checkCallback = param2;
      }
      
      public function init(param1:TextField = null) : void
      {
         chkTxt = param1;
         box = _currCheckBox["_box"];
         check = box["_check"];
         grayBox = _currCheckBox["_boxGray"];
         if(grayBox)
         {
            grayBox.visible = false;
         }
         if(!(box && check))
         {
            throw new Error("GuiCheckBox is missing parts or they are named incorrectly!");
         }
         box.stop();
         check.stop();
         _currCheckBox.tabEnabled = true;
         _glow = new GlowFilter(5562619,1,6,6,2,2);
         _currCheckBox.addEventListener("keyDown",checkBoxKeyDownHandler,false,0,true);
         _currCheckBox.addEventListener("mouseDown",checkBoxClickHandler,false,0,true);
         _currCheckBox.addEventListener("rollOver",onRollOver,false,0,true);
         _currCheckBox.addEventListener("rollOut",onRollOut,false,0,true);
         if(chkTxt != null)
         {
            chkTxt.addEventListener("mouseDown",checkBoxClickHandler,false,0,true);
            chkTxt.addEventListener("rollOver",onRollOver,false,0,true);
            chkTxt.addEventListener("rollOut",onRollOut,false,0,true);
         }
      }
      
      public function destroy() : void
      {
         _currCheckBox.removeEventListener("keyDown",checkBoxKeyDownHandler);
         _currCheckBox.removeEventListener("mouseDown",checkBoxClickHandler);
         _currCheckBox.removeEventListener("rollOver",onRollOver);
         _currCheckBox.removeEventListener("rollOut",onRollOut);
         if(chkTxt != null)
         {
            chkTxt.removeEventListener("mouseDown",checkBoxClickHandler);
            chkTxt.removeEventListener("rollOver",onRollOver);
            chkTxt.removeEventListener("rollOut",onRollOut);
         }
         _currCheckBox = null;
         _checkCallback = null;
      }
      
      public function get currCheckBox() : MovieClip
      {
         return _currCheckBox;
      }
      
      public function get gray() : Boolean
      {
         if(grayBox)
         {
            return grayBox.visible;
         }
         return false;
      }
      
      public function set gray(param1:Boolean) : void
      {
         if(grayBox)
         {
            grayBox.visible = param1;
            box.visible = !param1;
         }
      }
      
      public function get checked() : Boolean
      {
         return check.visible;
      }
      
      public function set checked(param1:Boolean) : void
      {
         check.visible = param1;
      }
      
      private function checkBoxKeyDownHandler(param1:KeyboardEvent) : void
      {
         if(!gray)
         {
            if(param1.keyCode == 32)
            {
               checked = !checked;
            }
            if(_checkCallback != null)
            {
               _checkCallback(this);
            }
         }
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         if(!gray)
         {
            checked = !checked;
            if(_checkCallback != null)
            {
               _checkCallback(this);
            }
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(!gray)
         {
            box.filters = [_glow];
            if(chkTxt)
            {
               chkTxt.filters = [_glow];
            }
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(!gray)
         {
            box.filters = null;
            if(chkTxt)
            {
               chkTxt.filters = null;
            }
         }
      }
   }
}

