package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public class SBMysteryMessagePopup
   {
      private var _parent:DisplayObjectContainer;
      
      private var _message:String;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _giftCallback:Function;
      
      private var _passback:Object;
      
      private var _showGift:Boolean;
      
      private var _type:int;
      
      public function SBMysteryMessagePopup(param1:DisplayObjectContainer, param2:int, param3:String = null, param4:Boolean = true, param5:Function = null, param6:Object = null)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _parent = param1;
         _type = param2;
         _message = param3;
         _giftCallback = param5;
         _passback = param6;
         _showGift = param4;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(5443,onMediaLoaded);
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
         var topHeight:Number;
         var distanceFromMiddleToImage:Number;
         var distanceFromBottomToGift:Number;
         var img:MovieClip = param1;
         if(img)
         {
            DarkenManager.showLoadingSpiral(false);
            _popup = MovieClip(img.getChildAt(0));
            _popup.gotoAndStop(_type + 1);
            _mediaHelper.destroy();
            _mediaHelper = null;
            _popup.txt.autoSize = "center";
            _popup.txt.text = _message;
            topHeight = Number(!!_popup.ba.t.hasOwnProperty("sizeCont") ? _popup.ba.t.sizeCont.height : _popup.ba.t.height);
            distanceFromMiddleToImage = _popup.ba.m.y - _popup.p.y;
            distanceFromBottomToGift = _popup.ba.b.y - _popup.gift.y;
            with(_popup.ba)
            {
               
               m.height = Math.floor(_popup.txt.height) + 65;
               m.y = Math.floor(-(m.height * 0.5));
               t.y = m.y - topHeight + 1;
               b.y = m.y + m.height;
               _popup.txt.y = m.y + 30;
            }
            _popup.p.y = _popup.ba.m.y - distanceFromMiddleToImage;
            _popup.gift.y = _popup.ba.b.y - distanceFromBottomToGift;
            _popup.gift.visible = _showGift;
            _popup.addEventListener("mouseDown",onPopup,false,0,true);
            _popup.gift.addEventListener("mouseDown",onGiftDown,false,0,true);
            _popup.ba.t.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
            _popup.x = 900 * 0.5;
            _popup.y = 550 * 0.5;
            _parent.addChild(_popup);
            DarkenManager.darken(_popup);
            SBPopupManager.nonSBPopups.push(this);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
         if(_giftCallback != null)
         {
            if(_passback != null)
            {
               _giftCallback(_passback);
            }
            else
            {
               _giftCallback();
            }
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
   }
}

