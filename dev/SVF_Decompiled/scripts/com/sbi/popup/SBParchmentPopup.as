package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public dynamic class SBParchmentPopup
   {
      public static const TYPE_OK:int = 0;
      
      public static const TYPE_YES_NO:int = 1;
      
      public static const TYPE_CONTINUE_EXIT:int = 2;
      
      public static const TYPE_CONTINUE_ONLY:int = 3;
      
      private var _parent:DisplayObjectContainer;
      
      private var _type:int;
      
      private var _message:String;
      
      private var _darken:Boolean;
      
      private var _confirmCallback:Function;
      
      private var _passback:Object;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      public function SBParchmentPopup(param1:DisplayObjectContainer, param2:int = 0, param3:String = null, param4:Boolean = true, param5:Function = null, param6:Object = null)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _parent = param1;
         _type = param2;
         _message = param3;
         _darken = param4;
         _confirmCallback = param5;
         _passback = param6;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2106,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_popup)
         {
            DarkenManager.unDarken(_popup);
            if(_parent && _popup.parent && _popup.parent == _parent)
            {
               _parent.removeChild(_popup);
            }
            _popup.removeEventListener("mouseDown",onPopup);
            gMainFrame.stage.removeEventListener("keyDown",keyDownHandler);
            switch(_type)
            {
               case 0:
                  _popup.okBtn.removeEventListener("mouseDown",onBtnDown);
                  break;
               case 1:
                  _popup.yesBtn.removeEventListener("mouseDown",onBtnDown);
                  _popup.noBtn.removeEventListener("mouseDown",onBtnDown);
                  break;
               case 2:
                  _popup.contBtn.removeEventListener("mouseDown",onBtnDown);
                  _popup.exitBtn.removeEventListener("mouseDown",onBtnDown);
                  break;
               case 3:
                  _popup.contOnlyBtn.removeEventListener("mouseDown",onBtnDown);
            }
            _loc1_ = int(SBPopupManager.nonSBPopups.indexOf(this));
            if(_loc1_ >= 0)
            {
               SBPopupManager.nonSBPopups.splice(_loc1_,1);
            }
            _popup = null;
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var img:MovieClip = param1;
         if(img)
         {
            DarkenManager.showLoadingSpiral(false);
            _popup = MovieClip(img.getChildAt(0));
            _mediaHelper.destroy();
            _mediaHelper = null;
            gMainFrame.stage.addEventListener("keyDown",keyDownHandler,false,0,true);
            switch(_type)
            {
               case 0:
                  _popup.yesBtn.visible = false;
                  _popup.noBtn.visible = false;
                  _popup.contBtn.visible = false;
                  _popup.exitBtn.visible = false;
                  _popup.contOnlyBtn.visible = false;
                  _popup.okBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
                  break;
               case 1:
                  _popup.okBtn.visible = false;
                  _popup.contBtn.visible = false;
                  _popup.exitBtn.visible = false;
                  _popup.contOnlyBtn.visible = false;
                  _popup.yesBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
                  _popup.noBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
                  break;
               case 2:
                  _popup.okBtn.visible = false;
                  _popup.yesBtn.visible = false;
                  _popup.noBtn.visible = false;
                  _popup.contOnlyBtn.visible = false;
                  _popup.contBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
                  _popup.exitBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
                  break;
               case 3:
                  _popup.okBtn.visible = false;
                  _popup.yesBtn.visible = false;
                  _popup.noBtn.visible = false;
                  _popup.exitBtn.visible = false;
                  _popup.contBtn.visible = false;
                  _popup.contOnlyBtn.addEventListener("mouseDown",onBtnDown,false,0,true);
            }
            _popup.txt.autoSize = "center";
            _popup.txt.text = _message;
            with(_popup.ba)
            {
               
               m.height = Math.floor(_popup.txt.height) + 44 + 8;
               m.y = Math.floor(-(m.height * 0.5));
               t.y = m.y - t.height;
               b.y = m.y + m.height;
               _popup.txt.y = m.y + 4;
               _popup.yesBtn.y = m.y + _popup.txt.height + 13;
               _popup.noBtn.y = m.y + _popup.txt.height + 13;
               _popup.okBtn.y = m.y + _popup.txt.height + 9;
               _popup.contBtn.y = m.y + _popup.txt.height + 13;
               _popup.exitBtn.y = m.y + _popup.txt.height + 13;
               _popup.contOnlyBtn.y = m.y + _popup.txt.height + 13;
            }
            _popup.addEventListener("mouseDown",onPopup,false,0,true);
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            _parent.addChild(_popup);
            if(_darken)
            {
               DarkenManager.darken(_popup);
            }
            SBPopupManager.nonSBPopups.push(this);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onBtnDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_confirmCallback != null)
         {
            _loc2_ = {
               "status":param1.currentTarget == _popup.contBtn || param1.currentTarget == _popup.contOnlyBtn || param1.currentTarget == _popup.yesBtn || param1.currentTarget == _popup.okBtn,
               "passback":_passback
            };
            destroy();
            _confirmCallback(_loc2_);
         }
         else
         {
            destroy();
         }
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:Object = null;
         loop0:
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               switch(_type)
               {
                  case 0:
                  case 2:
                  case 3:
                     param1.stopPropagation();
                     if(_confirmCallback != null)
                     {
                        _loc2_ = {
                           "status":true,
                           "passback":_passback
                        };
                        destroy();
                        _confirmCallback(_loc2_);
                        break loop0;
                     }
                     destroy();
                     break loop0;
               }
         }
      }
   }
}

