package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class GuiDropdown
   {
      public var dropdownTxt:TextField;
      
      public var dropdownBtn:MovieClip;
      
      public var dropdown:MovieClip;
      
      public var scrollContent:MovieClip;
      
      public var scrollView:MovieClip;
      
      public var highlight:MovieClip;
      
      public var mouseHighlight:MovieClip;
      
      public var scrollbar:SBScrollbar;
      
      public var selectedTxt:TextField;
      
      public var selectedIdx:int;
      
      public var scrollItems:Array;
      
      public var blockItemDown:Boolean;
      
      public var currDropDown:MovieClip;
      
      public function GuiDropdown(param1:MovieClip)
      {
         var _loc3_:int = 0;
         var _loc2_:DisplayObject = null;
         super();
         currDropDown = param1;
         dropdownTxt = currDropDown.dropdown_txt;
         dropdownBtn = currDropDown.dropdown_btn;
         dropdown = currDropDown._dropdown;
         scrollContent = dropdown.scroll_content;
         highlight = scrollContent.dropdown_h;
         mouseHighlight = scrollContent.mouse;
         scrollView = dropdown.scroll_view;
         scrollItems = [];
         _loc3_ = 0;
         while(_loc3_ < scrollContent.numChildren)
         {
            _loc2_ = scrollContent.getChildAt(_loc3_);
            if(_loc2_.name.indexOf("_item") == 0)
            {
               _loc2_.addEventListener("mouseDown",itemMouseDownHandler,false,0,true);
               if(mouseHighlight)
               {
                  _loc2_.addEventListener("mouseOver",itemMouseOverHandler,false,0,true);
                  _loc2_.addEventListener("mouseOut",itemMouseOutHandler,false,0,true);
               }
               scrollItems[int(_loc2_.name.substr(5)) - 1] = _loc2_;
            }
            _loc3_++;
         }
      }
      
      public function init(param1:Number, param2:int = 0, param3:String = null) : void
      {
         dropdown.visible = false;
         if(scrollContent.height > scrollView.height)
         {
            scrollbar = new SBScrollbar();
            scrollbar.init(scrollContent,scrollView.width,scrollView.height,param1,"scrollbar2",scrollContent["_item2"].y - scrollContent["_item1"].y);
         }
         if(param3)
         {
            this.selectedIdx = -1;
            dropdownTxt.text = param3;
         }
         else
         {
            this.selectedIdx = selectedIdx;
            selectedTxt = scrollItems[param2];
            dropdownTxt.text = selectedTxt.text;
         }
         if(param2 > 0)
         {
            if(scrollbar)
            {
               scrollbar.scrollToElement(param2 - (param2 >= 2 ? 2 : 0));
            }
            selectedIdx = param2;
            selectedTxt = scrollItems[param2];
            highlight.visible = true;
            highlight.y = selectedTxt.y + highlight.height * 0.5;
         }
         mouseHighlight.visible = false;
         scrollView.visible = false;
         dropdownBtn.addEventListener("mouseDown",dropdownBtnMouseDownHandler,false,0,true);
         currDropDown.addEventListener("keyDown",keyDownHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         var _loc1_:DisplayObject = null;
         _loc2_ = 0;
         while(_loc2_ < scrollContent.numChildren)
         {
            _loc1_ = scrollContent.getChildAt(_loc2_);
            if(_loc1_.name.indexOf("_item") == 0)
            {
               _loc1_.removeEventListener("mouseDown",itemMouseDownHandler);
               if(mouseHighlight)
               {
                  _loc1_.removeEventListener("mouseOver",itemMouseOverHandler);
                  _loc1_.removeEventListener("mouseOut",itemMouseOutHandler);
               }
            }
            _loc2_++;
         }
         scrollItems = null;
         if(scrollbar)
         {
            scrollbar.destroy();
            scrollbar = null;
         }
         dropdownBtn.removeEventListener("mouseDown",dropdownBtnMouseDownHandler);
         currDropDown.removeEventListener("keyDown",keyDownHandler);
      }
      
      public function reset(param1:int = 0, param2:String = null) : void
      {
         if(scrollbar)
         {
            scrollbar.scrollToElement(param1);
         }
         if(param1)
         {
            if(scrollbar)
            {
               scrollbar.scrollToElement(param1);
            }
            selectedIdx = param1;
            selectedTxt = scrollItems[param1];
            highlight.visible = true;
            highlight.y = selectedTxt.y + highlight.height * 0.5;
         }
         if(param2)
         {
            this.selectedIdx = -1;
            dropdownTxt.text = param2;
         }
         else
         {
            this.selectedIdx = selectedIdx;
            selectedTxt = scrollItems[param1];
            dropdownTxt.text = selectedTxt.text;
         }
      }
      
      public function closeDropdownSilent() : void
      {
         focusOutHandler(null);
         GuiSoundToggleButton(dropdownBtn).downToUpState();
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 32)
         {
            dropdownBtnMouseDownHandler(null);
         }
      }
      
      private function dropdownBtnMouseDownHandler(param1:MouseEvent) : void
      {
         dropdown.visible = !dropdown.visible;
      }
      
      private function focusOutHandler(param1:FocusEvent) : void
      {
         if(dropdown.visible)
         {
            dropdown.visible = false;
         }
      }
      
      private function itemMouseOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         mouseHighlight.visible = true;
         mouseHighlight.y = param1.currentTarget.y + mouseHighlight.height * 0.5;
      }
      
      private function itemMouseOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         mouseHighlight.visible = false;
      }
      
      private function itemMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!blockItemDown)
         {
            selectedTxt = TextField(param1.currentTarget);
            selectedIdx = int(selectedTxt.name.substr(5)) - 1;
            dropdownTxt.text = selectedTxt.text;
            highlight.visible = true;
            highlight.y = selectedTxt.y + highlight.height * 0.5;
            dropdownBtn.dispatchEvent(new MouseEvent("mouseDown"));
            dropdownBtn.dispatchEvent(new MouseEvent("rollOut"));
         }
      }
   }
}

