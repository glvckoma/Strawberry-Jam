package gui
{
   import com.sbi.client.KeepAlive;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class InputPopup
   {
      private var _inputPopup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      public function InputPopup(param1:Function)
      {
         super();
         _closeCallback = param1;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(6276,onPopupLoaded);
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc2_:Function = null;
         if(_inputPopup)
         {
            if(_closeCallback != null)
            {
               _loc2_ = _closeCallback;
               _closeCallback = null;
               if(param1)
               {
                  _loc2_(_inputPopup.txt.alpha == 1 ? _inputPopup.txt.text : "");
               }
               else
               {
                  _loc2_("");
               }
               return;
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.destroy();
            }
            removeEventListeners();
            DarkenManager.unDarken(_inputPopup);
            GuiManager.guiLayer.removeChild(_inputPopup);
            _inputPopup = null;
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _inputPopup = MovieClip(param1.getChildAt(0));
         _inputPopup.x = 900 * 0.5;
         _inputPopup.y = 550 * 0.5;
         setupPredictiveText();
         addEventListeners();
         GuiManager.guiLayer.addChild(_inputPopup);
         DarkenManager.darken(_inputPopup);
      }
      
      private function setupPredictiveText() : void
      {
         _inputPopup.txt.maxChars = 21;
         _inputPopup.txt.alpha = 0.75;
         _inputPopup.countTxt.text = "0/" + _inputPopup.txt.maxChars;
         _inputPopup.countTxt.visible = true;
         _predictiveTextManager = new PredictiveTextManager();
         _predictiveTextManager.init(_inputPopup.txt,2,_inputPopup.predictTxtTag,null,-262,_inputPopup.predictTxtPopupCont,null,checkShouldCompleteSuggestion);
         _inputPopup.txt.selectable = true;
         _inputPopup.txt.text = LocalizationManager.translateIdOnly(23140);
      }
      
      private function addEventListeners() : void
      {
         _inputPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _inputPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _inputPopup.submitBtn.addEventListener("mouseDown",onSubmitBtn,false,0,true);
         _inputPopup.txt.addEventListener("keyDown",keyDownListener,false,0,true);
         _inputPopup.txt.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
         _inputPopup.txt.addEventListener("change",onTextChanged,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _inputPopup.removeEventListener("mouseDown",onPopup);
         _inputPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _inputPopup.submitBtn.removeEventListener("mouseDown",onSubmitBtn);
         _inputPopup.txt.removeEventListener("keyDown",keyDownListener);
         _inputPopup.txt.removeEventListener("mouseDown",msgTextDownHandler);
         _inputPopup.txt.removeEventListener("change",onTextChanged);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onSubmitBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_predictiveTextManager && _predictiveTextManager.isValid())
         {
            destroy(true);
         }
         else
         {
            _predictiveTextManager.showUnapprovedChatPopup();
         }
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy(false);
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(_inputPopup && _predictiveTextManager)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(_predictiveTextManager)
         {
            if(_inputPopup.txt.alpha != 1)
            {
               _inputPopup.txt.alpha = 1;
               _inputPopup.txt.text = "";
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onKeyDown(param1);
               setTimeout(updateCharCount,41.666666666666664);
            }
         }
      }
      
      private function updateCharCount() : void
      {
         if(_inputPopup)
         {
            _inputPopup.countTxt.visible = true;
            _inputPopup.countTxt.text = _inputPopup.txt.text.length + "/" + _inputPopup.txt.maxChars;
         }
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         if(_inputPopup.txt.alpha != 1)
         {
            _inputPopup.txt.alpha = 1;
            _predictiveTextManager.resetTreeSearch();
         }
      }
      
      private function onSendMessage(param1:MouseEvent) : void
      {
         if(!_inputPopup.submitBtn.isGray)
         {
            KeepAlive.restartTimeLeftTimer();
         }
      }
      
      private function checkShouldCompleteSuggestion(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Function = null) : void
      {
         checkShouldCompleteSuggestionWork(param1,param2,param3,param4);
      }
      
      private function checkShouldCompleteSuggestionWork(param1:String, param2:Boolean, param3:Boolean, param4:Function) : void
      {
         var _loc6_:TextField = null;
         var _loc5_:TextFormat = null;
         if(_inputPopup)
         {
            if(param2)
            {
               if(_inputPopup.txt.length > 0)
               {
                  _inputPopup.submitBtn.activateGrayState(!_predictiveTextManager.isValid());
               }
               else
               {
                  _inputPopup.submitBtn.activateGrayState(true);
               }
               return;
            }
            _loc6_ = new TextField();
            _loc5_ = _inputPopup.txt.getTextFormat();
            _loc6_.text = _inputPopup.txt.text + param1;
            _loc6_.setTextFormat(_loc5_);
            if(_loc6_.length > _inputPopup.txt.maxChars)
            {
               if(param4 != null)
               {
                  param4(param1,param3,false);
               }
            }
            else if(param4 != null)
            {
               param4(param1,param3,true);
            }
         }
      }
   }
}

