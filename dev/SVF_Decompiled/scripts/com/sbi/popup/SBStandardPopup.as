package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public dynamic class SBStandardPopup extends SBPopup
   {
      protected var _text:TextField;
      
      protected var _skin:MovieClip;
      
      protected var _content:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      protected var _verticalOffset:Number = 0;
      
      protected var _btnTxtGap:Number = 0;
      
      protected var _btnHeight:Number = 0;
      
      protected var _resizeCallback:Function;
      
      public function SBStandardPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:MovieClip = null, param5:MovieClip = null, param6:Boolean = true, param7:Boolean = true, param8:Boolean = false, param9:Boolean = false, param10:String = null, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Array = null)
      {
         if(param5)
         {
            _skin = param5;
         }
         else
         {
            _skin = GETDEFINITIONBYNAME("PopupSkin");
         }
         if(param4)
         {
            _content = param4;
         }
         else
         {
            _content = GETDEFINITIONBYNAME("PopupContent");
         }
         _top = _skin.ba.t;
         _mid = _skin.ba.m;
         _bot = _skin.ba.b;
         _text = _content.text;
         _text.autoSize = "center";
         if(param2)
         {
            setText(param2);
         }
         super(param1,_skin,_content,param6,param7,param8,param9,param3,param10,param11,param12,param13,param14,param15);
      }
      
      public function setText(param1:String) : void
      {
         _text.text = param1;
         resize();
      }
      
      public function setHtmlText(param1:String) : void
      {
         _text.htmlText = param1;
         resize();
      }
      
      private function resize() : void
      {
         _mid.height = Math.round(_text.height);
         _mid.y = -(_mid.height * 0.5) + _verticalOffset;
         _top.y = _mid.y - _top.height;
         _bot.y = _mid.y + _mid.height - 1;
         _text.y = 0;
         _skin.c.height = _text.height + _btnTxtGap + _btnHeight;
         _skin.c.y = _mid.y;
         if(_resizeCallback != null)
         {
            _resizeCallback();
         }
         _content.x = _skin["c"].x;
         _content.y = _skin["c"].y;
         _content.width = _skin["c"].width;
         _content.height = _skin["c"].height;
      }
   }
}

