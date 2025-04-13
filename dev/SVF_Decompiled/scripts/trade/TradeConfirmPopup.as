package trade
{
   import com.sbi.popup.SBPopupManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import gui.DarkenManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class TradeConfirmPopup
   {
      public static const TYPE_NORMAL:int = 0;
      
      public static const TYPE_RARE:int = 1;
      
      public static const TYPE_RARES:int = 2;
      
      public static const TYPE_DIAMOND:int = 3;
      
      public static const TYPE_DIAMONDS:int = 4;
      
      public static const TYPE_RARE_DIAMONDS:int = 5;
      
      public static const TYPE_RARE_DIAMOND:int = 6;
      
      private static const TRADE_POPUP_MEDIA_ID:int = 3891;
      
      private var _mediaHelper:MediaHelper;
      
      private var _parentLayer:DisplayObjectContainer;
      
      private var _type:int;
      
      private var _confirmCallback:Function;
      
      private var _passback:Object;
      
      private var _confirmPopup:MovieClip;
      
      private var _frameName:String;
      
      private var _isForGifting:Boolean;
      
      public function TradeConfirmPopup(param1:DisplayObjectContainer, param2:int, param3:Boolean, param4:Function = null, param5:Object = null)
      {
         super();
         SBPopupManager.nonSBPopups.push(this);
         DarkenManager.showLoadingSpiral(true);
         _parentLayer = param1;
         _type = param2;
         _isForGifting = param3;
         switch(_type - 1)
         {
            case 0:
            case 1:
               _frameName = "rare";
               break;
            case 2:
            case 3:
               _frameName = "diamond";
               break;
            case 4:
            case 5:
               _frameName = "rareDiamond";
               break;
            default:
               _frameName = "reg";
         }
         _confirmCallback = param4;
         _passback = param5;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(3891,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         SBPopupManager.destroySpecificNonSBPopup(this);
         removeEventListeners();
         DarkenManager.unDarken(_confirmPopup);
         _parentLayer.removeChild(_confirmPopup);
         _confirmPopup = null;
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _confirmPopup = MovieClip(param1.getChildAt(0));
         _confirmPopup.x = 900 * 0.5;
         _confirmPopup.y = 550 * 0.5;
         _parentLayer.addChild(_confirmPopup);
         DarkenManager.darken(_confirmPopup);
         _confirmPopup.gotoAndStop(_frameName);
         if(_isForGifting)
         {
            if(_type == 2 || _type == 1)
            {
               LocalizationManager.translateId(_confirmPopup.popupTxt,27607,true);
            }
            else if(_type == 4 || _type == 3)
            {
               LocalizationManager.translateId(_confirmPopup.popupTxt,27608,true);
            }
            else if(_type == 5 || _type == 6)
            {
               LocalizationManager.translateId(_confirmPopup.popupTxt,27680,true);
            }
            else
            {
               LocalizationManager.translateId(_confirmPopup.popupTxt,27609);
            }
            LocalizationManager.translateId(_confirmPopup.yesBtn.yesTxt,4);
         }
         else if(_type == 2)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,21881,true);
         }
         else if(_type == 1)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,21646,true);
         }
         else if(_type == 4)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,21882,true);
         }
         else if(_type == 3)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,21648,true);
         }
         else if(_type == 6)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,27681,true);
         }
         else if(_type == 5)
         {
            LocalizationManager.translateId(_confirmPopup.popupTxt,21880,true);
         }
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         if(_confirmPopup)
         {
            _confirmPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _confirmPopup.yesBtn.addEventListener("mouseDown",onConfirm,false,0,true);
            _confirmPopup.noBtn.addEventListener("mouseDown",onConfirm,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         if(_confirmPopup)
         {
            _confirmPopup.removeEventListener("mouseDown",onPopup);
            _confirmPopup.yesBtn.removeEventListener("mouseDown",onConfirm);
            _confirmPopup.noBtn.removeEventListener("mouseDown",onConfirm);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onConfirm(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_confirmCallback != null)
         {
            if(_passback != null)
            {
               _confirmCallback(param1.currentTarget == _confirmPopup.yesBtn,_passback);
               _passback = null;
            }
            else
            {
               _confirmCallback(param1.currentTarget == _confirmPopup.yesBtn);
            }
            _confirmCallback = null;
         }
         else
         {
            destroy();
         }
      }
   }
}

