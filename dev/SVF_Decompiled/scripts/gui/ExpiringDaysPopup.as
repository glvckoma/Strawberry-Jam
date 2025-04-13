package gui
{
   import com.sbi.analytics.SBTracker;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Circular;
   import gskinner.motion.easing.Quadratic;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ExpiringDaysPopup
   {
      private var _mediaHelper:MediaHelper;
      
      private var _expiringPopup:MovieClip;
      
      private var _popupLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      public function ExpiringDaysPopup(param1:DisplayLayer, param2:Function, param3:MovieClip = null)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _popupLayer = param1;
         _closeCallback = param2;
         if(param3 == null)
         {
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(1953,onMediaLoaded);
         }
         else
         {
            onMediaLoaded(param3);
         }
      }
      
      public function destroy() : void
      {
         _expiringPopup.removeEventListener("mouseDown",popupMouseDownHandler);
         _expiringPopup["bx"].removeEventListener("mouseDown",popupCloseHandler);
         _expiringPopup["renewBtn"].removeEventListener("mouseDown",onRenew);
         DarkenManager.unDarken(_expiringPopup.parent.parent);
         if(_expiringPopup.parent.parent.parent == _popupLayer)
         {
            _popupLayer.removeChild(_expiringPopup.parent.parent);
         }
         _popupLayer = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(_mediaHelper)
            {
               _mediaHelper.destroy();
               _mediaHelper = null;
            }
            GuiManager.setSharedObj("expiration",new Date().millisecondsUTC);
            _expiringPopup = MovieClip(param1.getChildAt(0)).expiringMemberPopup;
            _expiringPopup.addEventListener("mouseDown",popupMouseDownHandler,false,0,true);
            _expiringPopup["bx"].addEventListener("mouseDown",popupCloseHandler,false,0,true);
            _expiringPopup["renewBtn"].addEventListener("mouseDown",onRenew,false,0,true);
            if(gMainFrame.clientInfo.subscriptionSourceType == 11)
            {
               if(gMainFrame.clientInfo.numDaysLeftOnSubscription > 0)
               {
                  LocalizationManager.translateId(_expiringPopup.expiringTxt,33548);
               }
               else
               {
                  LocalizationManager.translateId(_expiringPopup.expiringTxt,33599);
               }
            }
            else if(gMainFrame.clientInfo.numDaysLeftOnSubscription > 0)
            {
               LocalizationManager.translateId(_expiringPopup.expiringTxt,5401);
            }
            else
            {
               LocalizationManager.translateId(_expiringPopup.expiringTxt,33600);
            }
            if(gMainFrame.clientInfo.numDaysLeftOnSubscription > 1)
            {
               LocalizationManager.translateIdAndInsert(_expiringPopup.daysTxt,11119,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            else if(gMainFrame.clientInfo.numDaysLeftOnSubscription == 1)
            {
               LocalizationManager.translateIdAndInsert(_expiringPopup.daysTxt,11118,gMainFrame.clientInfo.numDaysLeftOnSubscription);
            }
            else
            {
               LocalizationManager.translateId(_expiringPopup.daysTxt,33601);
            }
            _expiringPopup.x = 900 * 0.5;
            _expiringPopup.y = 550 * 0.5;
            _popupLayer.addChild(_expiringPopup.parent.parent);
            _expiringPopup.scaleY = 0.1;
            _expiringPopup.scaleX = 0.1;
            new GTween(_expiringPopup,0.25,{
               "scaleX":1.2,
               "scaleY":1.2
            },{
               "ease":Circular.easeIn,
               "onComplete":onExpiringPopupTweenComplete
            });
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(_expiringPopup.parent.parent);
         }
      }
      
      private function popupMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback(param1);
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onRenew(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("/game/play/popup/demotion/renew");
         var _loc3_:String = gMainFrame.clientInfo.websiteURL + "membership";
         var _loc2_:URLRequest = new URLRequest(_loc3_);
         try
         {
            navigateToURL(_loc2_,"_blank");
         }
         catch(e:Error)
         {
         }
      }
      
      private function onExpiringPopupTweenComplete(param1:GTween) : void
      {
         new GTween(_expiringPopup,0.3,{
            "scaleX":1,
            "scaleY":1
         },{"ease":Quadratic.easeIn});
      }
   }
}

