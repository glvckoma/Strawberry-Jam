package adoptAPet
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   
   public class TierPathPopup
   {
      private const POPUP_MEDIA_ID:int = 7208;
      
      private var _tierPopup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      public function TierPathPopup(param1:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(7208,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_tierPopup);
         GuiManager.guiLayer.removeChild(_tierPopup);
         _closeCallback = null;
         _tierPopup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _tierPopup = MovieClip(param1.getChildAt(0));
         _tierPopup.x = 900 / 2;
         _tierPopup.y = 550 / 2;
         setupPathAndDots();
         addEventListeners();
         GuiManager.guiLayer.addChild(_tierPopup);
         DarkenManager.darken(_tierPopup);
      }
      
      private function setupPathAndDots() : void
      {
         var _loc4_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc8_:MovieClip = null;
         var _loc1_:* = null;
         var _loc7_:* = null;
         var _loc10_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc5_:int = int(AdoptAPetManager.TIERED_GIFT_COUNTS[AdoptAPetManager.TIERED_GIFT_COUNTS.length - 1]);
         var _loc9_:int = AdoptAPetManager.numTieredGiftCount;
         var _loc6_:Boolean = false;
         _tierPopup.pinkPath.gotoAndStop(_loc9_);
         _loc4_ = 1;
         while(_loc4_ <= _loc5_)
         {
            _loc3_ = _tierPopup["dot_" + _loc4_];
            _loc8_ = _tierPopup["threshold" + _loc4_];
            if(_loc4_ <= _loc9_)
            {
               _loc2_ = true;
            }
            if(_loc3_ != null)
            {
               _loc7_ = _loc3_;
               if(_loc2_)
               {
                  _loc10_ = false;
                  _loc2_ = false;
                  _loc1_ = _loc3_;
                  _loc3_.num.text = _loc4_;
                  _loc3_.star.visible = true;
                  if(_loc7_ != null)
                  {
                     _loc7_.num.visible = false;
                     if(_loc7_.num.text != "1")
                     {
                        _loc7_.star.visible = false;
                     }
                     else
                     {
                        _loc7_.star.visible = false;
                     }
                  }
               }
               else
               {
                  _loc3_.num.visible = false;
                  _loc3_.star.visible = false;
               }
            }
            else if(_loc8_ != null)
            {
               if(_loc4_ <= _loc9_)
               {
                  _loc10_ = true;
                  _loc8_.gotoAndStop("open");
               }
               else
               {
                  if(!_loc6_)
                  {
                     _loc8_.gotoAndStop("next");
                     _loc6_ = true;
                  }
                  else
                  {
                     _loc8_.gotoAndStop("future");
                  }
                  _loc8_.numTxt.text = _loc4_;
               }
            }
            else if(!_loc10_)
            {
               _loc2_ = false;
            }
            _loc4_++;
         }
         if(_loc1_ != null)
         {
            if(_loc10_)
            {
               _loc1_.num.visible = false;
               _loc1_.star.visible = false;
            }
            else
            {
               _loc1_.num.visible = true;
               _loc1_.star.visible = true;
               _loc1_.num.text = _loc9_;
            }
         }
      }
      
      private function addEventListeners() : void
      {
         _tierPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _tierPopup.bx.removeEventListener("mouseDown",onCloseBtn);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
   }
}

