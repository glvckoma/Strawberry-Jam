package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   
   public dynamic class SBAJOkPopup extends SBPopup
   {
      protected var _messageText:TextField;
      
      protected var _titleText:TextField;
      
      protected var _skin:MovieClip;
      
      protected var _content:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      private var _titleToMessageDifference:int = 5;
      
      private var _btnTxtGap:int = 10;
      
      private var _verticalOffset:int = 13;
      
      private var _okBtn:MovieClip;
      
      private var _okBtnCallback:Function;
      
      public function SBAJOkPopup(param1:DisplayObjectContainer, param2:String = null, param3:String = null, param4:Function = null, param5:Boolean = true, param6:MovieClip = null, param7:MovieClip = null, param8:Boolean = true, param9:Boolean = true, param10:Boolean = false, param11:Boolean = false, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Number = undefined, param16:Array = null)
      {
         if(param4 != null)
         {
            _okBtnCallback = param4;
         }
         else
         {
            _okBtnCallback = onOkBtn;
         }
         _skin = GETDEFINITIONBYNAME("BroadcastPopupSkin");
         _content = GETDEFINITIONBYNAME("BroadcastPopupContent");
         _top = _skin.ba.t;
         _mid = _skin.ba.m;
         _bot = _skin.ba.b;
         _okBtn = _content.okBtn;
         _okBtn.addEventListener("mouseDown",_okBtnCallback,false,0,true);
         _messageText = _content.text;
         _titleText = _content.titleTxt;
         _messageText.autoSize = "center";
         _titleText.autoSize = "center";
         setMessageText(param2);
         if(param3)
         {
            _titleText.text = param3;
         }
         super(param1,_skin,_content,param8,param9,param10,param11,param5,param3,param12,param13,param14,param15,param16);
      }
      
      public static function destroyInParentChain(param1:DisplayObject) : void
      {
         while(param1 && param1 != gMainFrame.stage && !(param1 is SBOkPopup))
         {
            param1 = param1.parent;
         }
         if(param1 is SBOkPopup)
         {
            SBOkPopup(param1).destroy();
         }
      }
      
      override public function destroy() : void
      {
         _okBtn.removeEventListener("mouseDown",_okBtnCallback);
         super.destroy();
      }
      
      public function setMessageText(param1:String) : void
      {
         _messageText.text = param1;
         resize();
      }
      
      private function resize() : void
      {
         _mid.height = Math.floor(_messageText.height);
         _mid.y = Math.floor(-(_mid.height * 0.5));
         _top.y = _mid.y - _top.height;
         _bot.y = _mid.y + _mid.height;
         _titleText.y = 0;
         _messageText.y = _titleText.height + _titleToMessageDifference;
         _okBtn.y = _messageText.y + _messageText.height + _btnTxtGap + _okBtn.height * 0.5;
         _skin.c.height = _titleText.height + _titleToMessageDifference + _messageText.height + _btnTxtGap + _okBtn.height;
         _skin.c.y = -(_skin.ba.height * 0.5) + _verticalOffset;
         _content.x = _skin.c.x;
         _content.y = _skin.c.y;
         _content.width = _skin.c.width;
         _content.height = _skin.c.height;
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
   }
}

