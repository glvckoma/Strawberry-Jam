package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiRadioButtonGroup;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public dynamic class SBPollPopup
   {
      public static const POLL_POPUP_MEDIA_ID:int = 369;
      
      private static const POLL_TY_POPUP_MEDIA_ID:int = 370;
      
      protected var _popupLayer:DisplayObjectContainer;
      
      protected var _tab:MovieClip;
      
      protected var _pollDef:Object;
      
      protected var _onVoteCallback:Function;
      
      protected var _onDoneCallback:Function;
      
      protected var _pollPopup:MovieClip;
      
      protected var _pollMediaHelper:MediaHelper;
      
      protected var _thankYouPopup:SBStandardTitlePopup;
      
      protected var _numOptions:int;
      
      protected var _randomizeOrder:Boolean;
      
      protected var _randOptionLookup:Array;
      
      protected var _answerSection:MovieClip;
      
      protected var _optionsGroup:GuiRadioButtonGroup;
      
      protected var _pollMediaId:int;
      
      public function SBPollPopup()
      {
         super();
      }
      
      public function init(param1:DisplayObjectContainer, param2:MovieClip, param3:int, param4:Function, param5:Function, param6:Boolean) : void
      {
         _popupLayer = param1;
         _tab = param2;
         _onVoteCallback = param4;
         _onDoneCallback = param5;
         _randomizeOrder = param6;
         _pollMediaId = param3;
         _pollDef = _tab.def;
         _pollMediaHelper = new MediaHelper();
         _pollMediaHelper.init(param3,onMediaLoaded,true);
         _randOptionLookup = [0,1,2,3,4];
         _thankYouPopup = new SBStandardTitlePopup(_popupLayer,LocalizationManager.translateIdOnly(14680),null,370,_onDoneCallback,false);
      }
      
      public function destroy() : void
      {
         _pollPopup.bx.removeEventListener("mouseDown",onCloseBtnDown);
         _pollPopup.removeEventListener("mouseDown",onPopupDown);
         _pollPopup = null;
         _thankYouPopup.destroy();
         _thankYouPopup = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _pollMediaHelper.destroy();
            _pollMediaHelper = null;
            _pollPopup = MovieClip(param1.getChildAt(0));
            setUpPollPopup();
         }
      }
      
      protected function setUpPollPopup() : void
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
         if(_numOptions == 2)
         {
            _answerSection = _pollPopup.answer2;
            _pollPopup.answer2.visible = true;
            _pollPopup.answer3.visible = false;
            _pollPopup.answer4.visible = false;
            _pollPopup.answer5.visible = false;
         }
         else if(_numOptions == 3)
         {
            _answerSection = _pollPopup.answer3;
            _pollPopup.answer2.visible = false;
            _pollPopup.answer3.visible = true;
            _pollPopup.answer4.visible = false;
            _pollPopup.answer5.visible = false;
         }
         else if(_numOptions == 4)
         {
            _answerSection = _pollPopup.answer4;
            _pollPopup.answer2.visible = false;
            _pollPopup.answer3.visible = false;
            _pollPopup.answer4.visible = true;
            _pollPopup.answer5.visible = false;
         }
         else
         {
            _answerSection = _pollPopup.answer5;
            if(_pollPopup.answer2)
            {
               _pollPopup.answer2.visible = false;
            }
            if(_pollPopup.answer3)
            {
               _pollPopup.answer3.visible = false;
            }
            if(_pollPopup.answer4)
            {
               _pollPopup.answer4.visible = false;
            }
            _pollPopup.answer5.visible = true;
         }
         _optionsGroup = new GuiRadioButtonGroup(_answerSection.options);
         if(_answerSection.voteBtn)
         {
            _answerSection.voteBtn.activateGrayState(true);
            _answerSection.voteBtn.addEventListener("mouseDown",onVoteBtnDown,false,0,true);
         }
         _loc2_ = 1;
         while(_loc2_ < _numOptions + 1)
         {
            _answerSection["answer" + _loc2_ + "Txt"].text = _loc4_[_loc2_ - 1];
            _answerSection.options["option" + _loc2_].addEventListener("click",onOptionSelected,false,0,true);
            _loc2_++;
         }
         DarkenManager.showLoadingSpiral(false);
         open(_pollPopup);
      }
      
      protected function open(param1:MovieClip) : void
      {
         _popupLayer.addChild(param1);
         param1.x = 900 * 0.5;
         param1.y = 550 * 0.5;
         DarkenManager.darken(param1);
         param1.visible = true;
      }
      
      protected function close(param1:MovieClip) : void
      {
         param1.visible = false;
         DarkenManager.unDarken(param1);
         _popupLayer.removeChild(param1);
      }
      
      private function onVoteBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            processVote();
         }
      }
      
      protected function processVote() : void
      {
         if(_onVoteCallback != null)
         {
            _onVoteCallback(_tab,_randOptionLookup[_optionsGroup.selected] + 1);
         }
         close(_pollPopup);
         _thankYouPopup.open();
      }
      
      protected function onCloseBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close(param1.currentTarget.parent);
         _onDoneCallback();
      }
      
      protected function onOptionSelected(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget == _answerSection.options.option1)
         {
            _answerSection.options.option1._circle.visible = true;
         }
         _loc2_ = 1;
         while(_loc2_ < _numOptions + 1)
         {
            _answerSection.options["option" + _loc2_].removeEventListener("mouseDown",onOptionSelected);
            _loc2_++;
         }
         _answerSection.voteBtn.activateGrayState(false);
      }
      
      protected function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

