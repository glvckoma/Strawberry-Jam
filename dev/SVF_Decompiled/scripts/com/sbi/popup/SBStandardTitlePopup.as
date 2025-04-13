package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public dynamic class SBStandardTitlePopup
   {
      public static const THANK_YOU_MEDIA_ID:int = 370;
      
      private var _popupMediaHelper:MediaHelper;
      
      private var _openWasCalled:Boolean;
      
      protected var _loadedMC:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      public function SBStandardTitlePopup(param1:DisplayObjectContainer, param2:String, param3:String = null, param4:int = 370, param5:Function = null, param6:Boolean = true, param7:Boolean = true)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _popupMediaHelper = new MediaHelper();
         _popupMediaHelper.init(param4,onMediaLoaded,{
            "parent":param1,
            "message":param2,
            "title":param3,
            "closeCallback":param5,
            "autoOpen":param6,
            "darken":param7
         });
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(_loadedMC);
         _loadedMC.passback.parent.removeChild(_loadedMC);
         _loadedMC.bx.removeEventListener("mouseDown",onClose);
         _loadedMC.removeEventListener("mouseDown",onPopup);
         _loadedMC = null;
         _top = null;
         _mid = null;
         _bot = null;
         _openWasCalled = false;
      }
      
      public function open() : void
      {
         if(_loadedMC)
         {
            _loadedMC.visible = true;
         }
         if(_loadedMC.passback.darken)
         {
            DarkenManager.darken(_loadedMC);
         }
         _openWasCalled = true;
      }
      
      public function close() : void
      {
         if(_loadedMC)
         {
            _loadedMC.visible = false;
         }
         if(_loadedMC.passback.darken)
         {
            DarkenManager.unDarken(_loadedMC);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _loadedMC = param1.getChildAt(0) as MovieClip;
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
            _loadedMC.x = 900 * 0.5;
            _loadedMC.y = 550 * 0.5;
            _loadedMC.parent.parent.x = _loadedMC.x;
            _loadedMC.parent.parent.y = _loadedMC.y;
            _loadedMC.bx.addEventListener("mouseDown",onClose);
            _loadedMC.addEventListener("mouseDown",onPopup);
            _loadedMC.passback = _loadedMC.parent["passback"];
            if(_loadedMC.passback.title)
            {
               _loadedMC.titleTxt.text = _loadedMC.passback.title;
            }
            if(_loadedMC.passback.message)
            {
               _loadedMC.txt.bodyTxt.autoSize = "center";
               _loadedMC.txt.bodyTxt.text = _loadedMC.passback.message;
            }
            _top = _loadedMC.ba.t;
            _mid = _loadedMC.ba.m;
            _bot = _loadedMC.ba.b;
            resize();
            if(!_loadedMC.passback.autoOpen && !_openWasCalled)
            {
               _loadedMC.visible = false;
            }
            else
            {
               open();
            }
            _loadedMC.passback.parent.addChild(_loadedMC);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_loadedMC.passback.closeCallback)
         {
            _loadedMC.passback.closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function resize() : void
      {
         _mid.height = Math.floor(_loadedMC.txt.height);
         _top.y = _mid.y - _mid.height * 0.5 - _top.height * 0.5;
         _bot.y = _mid.y + _mid.height * 0.5 + _bot.height * 0.5;
         _loadedMC.titleTxt.y = _top.y - 23;
         _loadedMC.bx.y = _loadedMC.titleTxt.y;
         _loadedMC.txt.y -= _mid.height * 0.5 - 29;
      }
   }
}

