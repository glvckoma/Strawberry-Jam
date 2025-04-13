package com.sbi.popup
{
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiRadioButtonGroup;
   import localization.LocalizationManager;
   
   public class SBPollPopupAdjustable extends SBPollPopup
   {
      public static const POLL_POPUP_WOOD_MEDIA_ID:int = 3931;
      
      private var _options:Array;
      
      public function SBPollPopupAdjustable()
      {
         super();
      }
      
      override protected function setUpPollPopup() : void
      {
         var _loc2_:int = 0;
         _pollPopup.bx.addEventListener("mouseDown",onCloseBtnDown,false,0,true);
         _pollPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         var _loc3_:String = _pollDef.poll;
         var _loc1_:int = int(_loc3_.indexOf("|"));
         LocalizationManager.updateToFit(_pollPopup.bodyTxt,_loc3_.substring(0,_loc1_));
         var _loc4_:Array = _loc3_.substring(_loc1_ + 1,_loc3_.length).split("|");
         if(_randomizeOrder)
         {
            _loc4_ = Utility.shuffleArray(_loc4_,_randOptionLookup);
         }
         _numOptions = _loc4_.length;
         LocalizationManager.updateToFit(_pollPopup.titleTxt,_pollDef.title);
         _options = [];
         _loc2_ = 1;
         while(_loc2_ < 6)
         {
            if(_loc2_ < _numOptions + 1)
            {
               _pollPopup["answer" + _loc2_ + "Txt"].text = _loc4_[_loc2_ - 1];
               _pollPopup["option" + _loc2_].addEventListener("click",onOptionSelected,false,0,true);
               _options.push(_pollPopup["option" + _loc2_]);
            }
            else
            {
               _pollPopup["answer" + _loc2_ + "Txt"].visible = false;
               _pollPopup["option" + _loc2_].visible = false;
            }
            _loc2_++;
         }
         _optionsGroup = new GuiRadioButtonGroup(_options);
         DarkenManager.showLoadingSpiral(false);
         open(_pollPopup);
      }
      
      override protected function onOptionSelected(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         processVote();
      }
      
      override public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_optionsGroup)
         {
            _optionsGroup.destroy();
            _optionsGroup = null;
         }
         _loc1_ = 1;
         while(_loc1_ < _numOptions + 1)
         {
            _pollPopup["option" + _loc1_].removeEventListener("click",onOptionSelected);
            _loc1_++;
         }
         super.destroy();
      }
      
      private function processVote(param1:String = null) : void
      {
         if(_onVoteCallback != null)
         {
            _onVoteCallback(_tab,_randOptionLookup[_optionsGroup.selected] + 1,param1);
         }
         close(_pollPopup);
         _onDoneCallback();
      }
      
      private function setupNameInput() : void
      {
         _pollPopup.submitBtn.addEventListener("mouseDown",onSubmitNameBtn,false,0,true);
         _pollPopup.name_txt.addEventListener("mouseDown",onNameText,false,0,true);
         _pollPopup.name_txt.alpha = 0.5;
      }
      
      private function onSubmitNameBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_pollPopup.name_txt.alpha == 1 && _pollPopup.name_txt.length > 0)
         {
            processVote(_pollPopup.name_txt.text);
         }
      }
      
      private function onNameText(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.alpha == 0.5)
         {
            param1.currentTarget.text = "";
            param1.currentTarget.alpha = 1;
            param1.currentTarget.removeEventListener("mouseDown",onNameText);
         }
      }
   }
}

