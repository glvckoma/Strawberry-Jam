package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class GuiRadioButtonSingle
   {
      public var currRadioButton:MovieClip;
      
      public var bg:MovieClip;
      
      public var chkTxt:TextField;
      
      public var circle:MovieClip;
      
      public var grayBg:MovieClip;
      
      private var _selectedRadioButton:DisplayObject;
      
      private var _glow:GlowFilter;
      
      public function GuiRadioButtonSingle(param1:MovieClip, param2:TextField = null)
      {
         super();
         currRadioButton = param1;
         chkTxt = param2;
         bg = currRadioButton["bg"];
         circle = currRadioButton["_circle"];
         grayBg = currRadioButton["bgGray"];
         gray = false;
         circle.visible = false;
         _glow = new GlowFilter(5562619,1,6,6,2,2);
         currRadioButton.addEventListener("mouseDown",checkBoxClickHandler,false,0,true);
         currRadioButton.addEventListener("rollOver",onRollOver,false,0,true);
         currRadioButton.addEventListener("rollOut",onRollOut,false,0,true);
         if(chkTxt)
         {
            chkTxt.addEventListener("mouseDown",checkBoxClickHandler,false,0,true);
            chkTxt.addEventListener("rollOver",onRollOver,false,0,true);
            chkTxt.addEventListener("rollOut",onRollOut,false,0,true);
         }
      }
      
      public function destroy() : void
      {
         currRadioButton.removeEventListener("mouseDown",checkBoxClickHandler);
         currRadioButton.removeEventListener("rollOver",onRollOver);
         currRadioButton.removeEventListener("rollOut",onRollOut);
         if(chkTxt)
         {
            chkTxt.removeEventListener("mouseDown",checkBoxClickHandler);
            chkTxt.removeEventListener("rollOver",onRollOver);
            chkTxt.removeEventListener("rollOut",onRollOut);
         }
      }
      
      public function get gray() : Boolean
      {
         if(grayBg)
         {
            return grayBg.visible;
         }
         return false;
      }
      
      public function set gray(param1:Boolean) : void
      {
         if(grayBg)
         {
            grayBg.visible = param1;
            bg.visible = !param1;
            circle.visible = !param1;
         }
      }
      
      public function get selected() : Boolean
      {
         return circle.visible;
      }
      
      public function set selected(param1:Boolean) : void
      {
         circle.visible = param1;
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         if(!gray)
         {
            selected = !selected;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(!gray)
         {
            bg.filters = [_glow];
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
            bg.filters = null;
            if(chkTxt)
            {
               chkTxt.filters = null;
            }
         }
      }
   }
}

