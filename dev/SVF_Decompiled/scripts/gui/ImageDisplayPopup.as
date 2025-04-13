package gui
{
   import achievement.AchievementXtCommManager;
   import collection.StreamDefCollection;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ImageDisplayPopup
   {
      private const POPUP_MEDIA_ID:int = 2418;
      
      private const IMAGES_LIST_ID_GREATNATURE:int = 182;
      
      private const IMAGES_LIST_ID_PHOTOCONTEST:int = 609;
      
      private var _guiLayer:DisplayLayer;
      
      private var _popupMediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _imageIds:Array;
      
      private var _mediaIndex:int;
      
      private var _imageMediaHelper:MediaHelper;
      
      private var _itemWindow:MovieClip;
      
      private var _locStrs:Array;
      
      private var _closeCallback:Function;
      
      private var _currStreamDefs:StreamDefCollection;
      
      private var _userVarIdToCheck:int;
      
      private var _videoGenericListId:int;
      
      public function ImageDisplayPopup(param1:Function, param2:int, param3:int)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _closeCallback = param1;
         _guiLayer = GuiManager.guiLayer;
         _userVarIdToCheck = param3;
         _videoGenericListId = param2;
         _popupMediaHelper = new MediaHelper();
         _popupMediaHelper.init(2418,onMediaLoaded);
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(_popup);
         _guiLayer.removeChild(_popup);
         if(_popupMediaHelper)
         {
            _popupMediaHelper.destroy();
            _popupMediaHelper = null;
         }
         if(_imageMediaHelper)
         {
            _imageMediaHelper.destroy();
            _imageMediaHelper = null;
         }
         if(_loadingSpiral)
         {
            _loadingSpiral.destroy();
            _loadingSpiral = null;
         }
         removeEventListeners();
         _popup = null;
         _closeCallback = null;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _popup = param1.getChildAt(0) as MovieClip;
         _guiLayer.addChild(_popup);
         _popup.gotoAndStop("photoContest");
         if(_popup.info)
         {
            _popup.info.visible = false;
         }
         if(_popup.darkBg)
         {
            _popup.darkBg.visible = false;
         }
         _itemWindow = _popup.popupCont.itemWindow;
         _loadingSpiral = new LoadingSpiral(_itemWindow);
         _imageMediaHelper = new MediaHelper();
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         if(_popup.currentFrameLabel == "greatNatureProject")
         {
            _popup.popupCont.artistName.autoSize = "right";
            GenericListXtCommManager.requestStreamList(_videoGenericListId,onTutorialGLReceived);
            GenericListXtCommManager.requestGenericList(182,onImagesListReceived);
         }
         else
         {
            GenericListXtCommManager.requestGenericList(609,onImagesListReceived);
         }
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_popup);
      }
      
      private function onImagesListReceived(param1:int, param2:Array, param3:Array) : void
      {
         _imageIds = param2;
         _locStrs = param3;
         loadImage(null);
      }
      
      private function onTutorialGLReceived(param1:int, param2:StreamDefCollection) : void
      {
         _currStreamDefs = param2;
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(_userVarIdToCheck) < 0)
         {
            onInfo(null);
            AchievementXtCommManager.requestSetUserVar(_userVarIdToCheck,1);
         }
      }
      
      private function loadImage(param1:MouseEvent) : void
      {
         if(_popup)
         {
            _loadingSpiral.visible = true;
            if(param1)
            {
               if(param1.currentTarget == _popup.popupCont.lArrow)
               {
                  if(--_mediaIndex < 0)
                  {
                     _mediaIndex = _imageIds.length - 1;
                  }
               }
               else if(param1.currentTarget == _popup.popupCont.rArrow)
               {
                  if(++_mediaIndex > _imageIds.length - 1)
                  {
                     _mediaIndex = 0;
                  }
               }
            }
            _popup.popupCont.lArrow.activateGrayState(true);
            _popup.popupCont.rArrow.activateGrayState(true);
            LocalizationManager.translateId(_popup.popupCont.artistName,_locStrs[_mediaIndex]);
            if(_popup.popupCont.photoCredit)
            {
               _popup.popupCont.photoCredit.x = _popup.popupCont.artistName.x - _popup.popupCont.photoCredit.width - 2;
            }
            _imageMediaHelper.init(_imageIds[_mediaIndex],onImageLoaded);
         }
      }
      
      private function onImageLoaded(param1:MovieClip) : void
      {
         if(_popup)
         {
            while(_itemWindow.numChildren > 0)
            {
               _itemWindow.removeChildAt(0);
            }
            _itemWindow.addChild(param1);
            _loadingSpiral.visible = false;
            _popup.popupCont.lArrow.activateGrayState(false);
            _popup.popupCont.rArrow.activateGrayState(false);
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onArrow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         loadImage(param1);
      }
      
      private function onInfo(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         DarkenManager.showLoadingSpiral(true);
         GuiManager.initMoviePlayer(39,_currStreamDefs,false);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_popup.info && param1.currentTarget == _popup.info.xBtn)
         {
            _popup.darkBg.visible = false;
            _popup.info.visible = false;
         }
         else if(param1.currentTarget == _popup.popupCont.xBtn)
         {
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
      
      private function addEventListeners() : void
      {
         _popup.addEventListener("mouseDown",onPopup,false,0,true);
         _popup.popupCont.lArrow.addEventListener("mouseDown",onArrow,false,0,true);
         _popup.popupCont.rArrow.addEventListener("mouseDown",onArrow,false,0,true);
         if(_popup.popupCont.infoBtn)
         {
            _popup.popupCont.infoBtn.addEventListener("mouseDown",onInfo,false,0,true);
         }
         _popup.popupCont.xBtn.addEventListener("mouseDown",onClose,false,0,true);
         if(_popup.info)
         {
            _popup.info.xBtn.addEventListener("mouseDown",onClose,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         _popup.removeEventListener("mouseDown",onPopup);
         _popup.popupCont.lArrow.removeEventListener("mouseDown",onArrow);
         _popup.popupCont.rArrow.removeEventListener("mouseDown",onArrow);
         if(_popup.popupCont.infoBtn)
         {
            _popup.popupCont.infoBtn.removeEventListener("mouseDown",onInfo);
         }
         _popup.popupCont.xBtn.removeEventListener("mouseDown",onClose);
         if(_popup.info)
         {
            _popup.info.xBtn.removeEventListener("mouseDown",onClose);
         }
      }
   }
}

