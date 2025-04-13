package gui
{
   import Enums.StreamDef;
   import Party.PartyXtCommManager;
   import collection.StreamDefCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.audio.SBAudio;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import masterpiece.MasterpieceDisplayItem;
   
   public class BulletinBoard
   {
      private static const BBOARD_MEDIA_ID:int = 563;
      
      private static const WHATS_NEW_MEDIA_ID:int = 4428;
      
      private static const GALLERY_MEDIA_ID:int = 565;
      
      private static const TUT_STREAM_GL_ID:int = 8;
      
      private static const WHAT_NEW_IMAGES_ID:int = 369;
      
      private static const WHATS_NEW_VIDEOS_ID:int = 389;
      
      private static const EVT_LOC_ID:int = 670;
      
      private static const DESC_TXT_Y_POS:Number = 181.35;
      
      private static var _cachedMasterpieces:Object;
      
      private var _bulletinBoardPopup:MovieClip;
      
      private var _whatsNewPopup:MovieClip;
      
      private var _whatsNewImageIds:Array;
      
      private var _whatsNewImageIndex:int;
      
      private var _whatsNewImageLoadingSpiral:LoadingSpiral;
      
      private var _whatsNewVideoLoadingSpiral:LoadingSpiral;
      
      private var _currTutorialStreamDef:StreamDef;
      
      private var _currWhatsNewStreamDef:StreamDef;
      
      private var _artGalleryPopup:MovieClip;
      
      private var _artPageNum:int;
      
      private var _masterpieceDisplayItem:MasterpieceDisplayItem;
      
      private var _currMPPreview:MasterpiecePreview;
      
      private var _guiLayer:DisplayLayer;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _tutorialSpiral:LoadingSpiral;
      
      private var _artSpiral:LoadingSpiral;
      
      private var _closeCallback:Function;
      
      private var _gameLaunchObj:Object;
      
      private var _introMediaHelper:MediaHelper;
      
      private var _introCloseId:int;
      
      private var _intro:MovieClip;
      
      private var _introCloseBtn:MovieClip;
      
      private var _musicMutedByPlayer:Boolean;
      
      public function BulletinBoard()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _closeCallback = param2;
         _mediaHelpers = [];
         _tutorialSpiral = new LoadingSpiral();
         _artSpiral = new LoadingSpiral();
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(563,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         if(_bulletinBoardPopup)
         {
            removeBoardListeners();
            _guiLayer.removeChild(_bulletinBoardPopup);
            DarkenManager.unDarken(_bulletinBoardPopup);
            KeepAlive.stopKATimer(_bulletinBoardPopup);
            _bulletinBoardPopup = null;
         }
         if(_artGalleryPopup)
         {
            removeGalleryListeners();
            if(_artGalleryPopup.parent && _artGalleryPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_artGalleryPopup);
            }
            DarkenManager.unDarken(_artGalleryPopup);
            _artGalleryPopup = null;
         }
         if(_whatsNewPopup)
         {
            removeWhatsNewListeners();
            _whatsNewVideoLoadingSpiral.destroy();
            _whatsNewVideoLoadingSpiral = null;
            _whatsNewImageLoadingSpiral.destroy();
            _whatsNewImageLoadingSpiral = null;
            if(_whatsNewPopup.parent && _whatsNewPopup.parent == _guiLayer)
            {
               _guiLayer.removeChild(_whatsNewPopup);
            }
            DarkenManager.unDarken(_whatsNewPopup);
            _whatsNewPopup = null;
         }
         if(_loadingMediaHelper)
         {
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
         if(_tutorialSpiral)
         {
            _tutorialSpiral.destroy();
            _tutorialSpiral = null;
         }
         if(_artSpiral)
         {
            _artSpiral.destroy();
            _artSpiral = null;
         }
         if(_intro)
         {
            _intro.removeEventListener("mouseDown",onPopupDown);
            _intro = null;
         }
         if(_introCloseBtn)
         {
            _introCloseBtn.removeEventListener("mouseDown",onIntroClose);
            _introCloseBtn = null;
         }
         if(_currMPPreview)
         {
            _currMPPreview.destroy();
            _currMPPreview = null;
         }
         if(_masterpieceDisplayItem)
         {
            _masterpieceDisplayItem.destroy();
            _masterpieceDisplayItem = null;
         }
         _mediaHelpers = null;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc4_:Number = NaN;
         if(param1)
         {
            _loc3_ = 0;
            while(_loc3_ < _mediaHelpers.length)
            {
               if(_mediaHelpers[_loc3_] == param1.mediaHelper)
               {
                  var _loc5_:* = param1.mediaHelper.id;
                  if(563 !== _loc5_)
                  {
                     if((_currTutorialStreamDef && _currTutorialStreamDef.thumbnailId) !== _loc5_)
                     {
                        switch(_loc5_)
                        {
                           case _currWhatsNewStreamDef && _currWhatsNewStreamDef.thumbnailId:
                           case _introCloseId:
                              _introCloseBtn = MovieClip(param1.getChildAt(0));
                              _guiLayer.addChild(_introCloseBtn);
                              _introCloseBtn.x = 855;
                              _introCloseBtn.y = 10;
                              _introCloseBtn.addEventListener("mouseDown",onIntroClose,false,0,true);
                              break;
                           case 565:
                              DarkenManager.showLoadingSpiral(false);
                              _artGalleryPopup = MovieClip(param1.getChildAt(0));
                              onGalleryLeftRightDown(null);
                              addGalleryListeners();
                              _guiLayer.addChild(_artGalleryPopup);
                              _artGalleryPopup.x = 900 * 0.5;
                              _artGalleryPopup.y = 550 * 0.5;
                              DarkenManager.darken(_artGalleryPopup);
                              break;
                           case 4428:
                              DarkenManager.showLoadingSpiral(false);
                              _whatsNewPopup = MovieClip(param1.getChildAt(0));
                              _whatsNewImageLoadingSpiral = new LoadingSpiral(_whatsNewPopup.photoItemWindow,_whatsNewPopup.photoItemWindow.width * 0.5,_whatsNewPopup.photoItemWindow.height * 0.5);
                              _whatsNewVideoLoadingSpiral = new LoadingSpiral(_whatsNewPopup.videoItemWindow,_whatsNewPopup.videoItemWindow.width * 0.5,_whatsNewPopup.videoItemWindow.height * 0.5);
                              _whatsNewPopup.playMovBtn.visible = false;
                              addWhatsNewListeners();
                              _guiLayer.addChild(_whatsNewPopup);
                              _whatsNewPopup.x = 900 * 0.5;
                              _whatsNewPopup.y = 550 * 0.5;
                              DarkenManager.darken(_whatsNewPopup);
                              GenericListXtCommManager.requestGenericList(369,onWhatsNewImagesListLoaded);
                              GenericListXtCommManager.requestStreamList(389,onWhatsNewVideosLoaded);
                        }
                     }
                     if(param1.mediaHelper.id == _currTutorialStreamDef.thumbnailId)
                     {
                        _loc2_ = _bulletinBoardPopup;
                        _tutorialSpiral.destroy();
                     }
                     else
                     {
                        _loc2_ = _whatsNewPopup;
                        _whatsNewVideoLoadingSpiral.visible = false;
                     }
                     if(_loc2_)
                     {
                        _loc4_ = _loc2_.videoItemWindow.width / param1.width;
                        param1.scaleX = _loc4_;
                        param1.scaleY = _loc4_;
                        _loc2_.videoItemWindow.addChild(param1);
                        _loc2_.playMovBtn.visible = true;
                     }
                  }
                  else
                  {
                     DarkenManager.showLoadingSpiral(false);
                     _bulletinBoardPopup = MovieClip(param1.getChildAt(0));
                     _bulletinBoardPopup.x = 900 * 0.5;
                     _bulletinBoardPopup.y = 550;
                     _tutorialSpiral.setNewParent(_bulletinBoardPopup.videoItemWindow);
                     _bulletinBoardPopup.playMovBtn.visible = false;
                     _guiLayer.addChild(_bulletinBoardPopup);
                     DarkenManager.darken(_bulletinBoardPopup);
                     KeepAlive.startKATimer(_bulletinBoardPopup);
                     addBoardListeners();
                     if(_currTutorialStreamDef != null && _currTutorialStreamDef.thumbnailId > 0)
                     {
                        _loadingMediaHelper = new MediaHelper();
                        _loadingMediaHelper.init(_currTutorialStreamDef.thumbnailId,onMediaItemLoaded,true);
                        _mediaHelpers.push(_loadingMediaHelper);
                     }
                     GenericListXtCommManager.requestStreamList(8,onTutorialGLReceived);
                     if(_cachedMasterpieces == null)
                     {
                        _artSpiral.setNewParent(_bulletinBoardPopup.masterpieceGallery);
                        PartyXtCommManager.sendPartyMasterpiece(onMasterpiecesLoaded);
                     }
                     else
                     {
                        setupMasterpieceDisplayItem();
                     }
                  }
                  param1.mediaHelper.destroy();
                  delete param1.mediaHelper;
                  _mediaHelpers.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function displayText(param1:int) : void
      {
         if(_artGalleryPopup)
         {
            _artGalleryPopup.descTxt.y = 181.35;
            if(_artGalleryPopup.descTxt.numLines == 1)
            {
               _artGalleryPopup.descTxt.y += 11;
            }
         }
      }
      
      private function onIntroLoaded(param1:MovieClip) : void
      {
         gMainFrame.stage.quality = "high";
         DarkenManager.showLoadingSpiral(false);
         if(!SBAudio.isMusicMuted || !SBAudio.areSoundsMuted)
         {
            SBAudio.muteMusic(false);
            SBAudio.muteSounds();
            _musicMutedByPlayer = true;
         }
         _intro = param1;
         _intro.addEventListener("mouseDown",onPopupDown,false,0,true);
         _guiLayer.addChild(_intro);
         DarkenManager.darken(_intro);
         _intro.playMovie(onIntroClose);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_introCloseId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
         _introMediaHelper.destroy();
         _introMediaHelper = null;
      }
      
      private function onIntroClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_intro.parent == _guiLayer)
         {
            _guiLayer.removeChild(_intro);
         }
         if(_intro)
         {
            _intro.stopMovie();
            DarkenManager.unDarken(_intro);
         }
         if(_introCloseBtn && _introCloseBtn.parent == _guiLayer)
         {
            _guiLayer.removeChild(_introCloseBtn);
         }
         if(_musicMutedByPlayer)
         {
            _musicMutedByPlayer = false;
            SBAudio.unmuteMusic(false);
            SBAudio.unmuteSounds();
         }
         gMainFrame.stage.quality = gMainFrame.currStageQuality;
      }
      
      private function onTutorialGLReceived(param1:int, param2:StreamDefCollection) : void
      {
         _currTutorialStreamDef = param2.getStreamDefItem(0);
         _introCloseId = 178;
         LocalizationManager.translateId(_bulletinBoardPopup.videoTitleTxt,_currTutorialStreamDef.baseTitleId);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_currTutorialStreamDef.thumbnailId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private function onWhatsNewImagesListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _whatsNewImageIds = param2;
         _whatsNewImageIndex = 0;
         loadWhatsNewImage();
      }
      
      private function onWhatsNewVideosLoaded(param1:int, param2:StreamDefCollection) : void
      {
         _currWhatsNewStreamDef = param2.getStreamDefItem(0);
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_currWhatsNewStreamDef.thumbnailId,onMediaItemLoaded,true);
         _mediaHelpers.push(_loadingMediaHelper);
      }
      
      private function loadWhatsNewImage() : void
      {
         _whatsNewImageLoadingSpiral.visible = true;
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(_whatsNewImageIds[_whatsNewImageIndex],onWhatsNewImagesLoaded);
      }
      
      private function onWhatsNewImagesLoaded(param1:MovieClip) : void
      {
         _whatsNewImageLoadingSpiral.visible = false;
         while(_whatsNewPopup.photoItemWindow.numChildren > 1)
         {
            _whatsNewPopup.photoItemWindow.removeChildAt(_whatsNewPopup.photoItemWindow.numChildren - 1);
         }
         _whatsNewPopup.photoItemWindow.addChild(param1);
      }
      
      private function onMasterpiecesLoaded(param1:String) : void
      {
         _cachedMasterpieces = param1 != "" ? JSON.parse(param1) : "";
         if(_cachedMasterpieces != "")
         {
            setupMasterpieceDisplayItem();
         }
      }
      
      private function setupMasterpieceDisplayItem() : void
      {
         var _loc1_:Object = _cachedMasterpieces.pool[0];
         _masterpieceDisplayItem = new MasterpieceDisplayItem();
         _masterpieceDisplayItem.initFromPool(_loc1_,onMasterpieceDisplayItemLoaded,_bulletinBoardPopup.masterpieceGallery.itemLayer);
         _masterpieceDisplayItem.nameBarVisibility = false;
      }
      
      private function onMasterpieceDisplayItemLoaded(param1:MasterpieceDisplayItem, param2:MovieClip) : void
      {
         if(_artSpiral)
         {
            _artSpiral.visible = false;
         }
         while(param2.numChildren > 1)
         {
            param2.removeChildAt(param2.numChildren - 1);
         }
         var _loc3_:Number = param2.width / param1.width;
         if(param1.height * _loc3_ > param2.height)
         {
            _loc3_ = param2.height / param1.height;
         }
         param1.scaleX = param1.scaleY = _loc3_;
         param2.addChild(param1);
      }
      
      private function onMasterpiecePreviewLoaded(param1:Boolean = false) : void
      {
         if(_artSpiral)
         {
            _artSpiral.visible = false;
         }
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.pop();
         switch(param1.currentTarget.parent)
         {
            case _whatsNewPopup:
               _guiLayer.removeChild(_whatsNewPopup);
               DarkenManager.unDarken(_whatsNewPopup);
               break;
            case _artGalleryPopup:
               if(_currMPPreview)
               {
                  _currMPPreview.destroy();
                  _currMPPreview = null;
               }
               _guiLayer.removeChild(_artGalleryPopup);
               DarkenManager.unDarken(_artGalleryPopup);
               _artGalleryPopup.visible = false;
               _artSpiral.visible = false;
               break;
            case _bulletinBoardPopup:
               if(_closeCallback != null)
               {
                  _closeCallback();
                  break;
               }
               destroy();
               break;
         }
      }
      
      private function onPlayMovieDown(param1:MouseEvent) : void
      {
         var _loc3_:StreamDefCollection = null;
         var _loc2_:StreamDef = null;
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         _loc3_ = new StreamDefCollection();
         if(_bulletinBoardPopup && param1.currentTarget == _bulletinBoardPopup.playMovBtn)
         {
            _loc2_ = _currTutorialStreamDef;
         }
         else if(_whatsNewPopup && param1.currentTarget == _whatsNewPopup.playMovBtn)
         {
            _loc2_ = _currWhatsNewStreamDef;
         }
         _loc3_.pushStreamDefItem(_loc2_);
         GuiManager.initMoviePlayer(39,_loc3_,false,768,432);
         GuiManager.setVideoPlayerSkin(6);
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_gameLaunchObj,null,false);
      }
      
      private function onWhatsNewBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/whatNew",-1,1);
         if(_whatsNewPopup)
         {
            _guiLayer.addChild(_whatsNewPopup);
            DarkenManager.darken(_whatsNewPopup);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(4428,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
         }
      }
      
      private function onMasterpieceDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_artSpiral && _artSpiral.visible)
         {
            return;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page1",-1,1);
         if(_artGalleryPopup)
         {
            _guiLayer.addChild(_artGalleryPopup);
            DarkenManager.darken(_artGalleryPopup);
            _artGalleryPopup.visible = true;
            onGalleryLeftRightDown(null);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _loadingMediaHelper = new MediaHelper();
            _loadingMediaHelper.init(565,onMediaItemLoaded,true);
            _mediaHelpers.push(_loadingMediaHelper);
         }
      }
      
      private function onMasterpieceOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_masterpieceDisplayItem && _masterpieceDisplayItem.hasLoaded)
         {
            _bulletinBoardPopup.masterpieceGallery.gotoAndStop("mouse");
         }
      }
      
      private function onMasterpieceOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _bulletinBoardPopup.masterpieceGallery.gotoAndStop("out");
      }
      
      private function onGalleryLeftRightDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(!_artSpiral || !_artSpiral.visible)
         {
            if(param1)
            {
               param1.stopPropagation();
               if(param1.currentTarget.name == "lBtn")
               {
                  if(_artPageNum - 1 < 0)
                  {
                     _artPageNum = _cachedMasterpieces.pool.length + _cachedMasterpieces.pluspool.length - 1;
                  }
                  else
                  {
                     _artPageNum--;
                  }
               }
               else if(_artPageNum + 1 >= _cachedMasterpieces.pool.length + _cachedMasterpieces.pluspool.length)
               {
                  _artPageNum = 0;
               }
               else
               {
                  _artPageNum++;
               }
               SBTracker.trackPageview("/game/play/popup/jammerCentral/artGallery/#page" + (_artPageNum + 1),-1,1);
            }
            _loc2_ = _artPageNum > _cachedMasterpieces.pool.length - 1 ? _cachedMasterpieces.pluspool[_artPageNum - _cachedMasterpieces.pool.length] : _cachedMasterpieces.pool[_artPageNum];
            if(_currMPPreview)
            {
               _currMPPreview.destroy();
            }
            _artGalleryPopup.itemWindow.x = -450;
            _artGalleryPopup.itemWindow.y = -275;
            if(_loc2_.userName == "#11098")
            {
               _loc2_.userName = LocalizationManager.translateIdOnly(11098);
            }
            _currMPPreview = new MasterpiecePreview(_artGalleryPopup.itemWindow,0,_loc2_.resourceId,_loc2_.userName,_loc2_.creatorDBId,_loc2_.creatorId,_loc2_.frameId,null,null);
         }
      }
      
      private function onLeftRightWhatsNew(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _whatsNewPopup.leftBtn)
         {
            _whatsNewImageIndex--;
            if(_whatsNewImageIndex < 0)
            {
               _whatsNewImageIndex = _whatsNewImageIds.length - 1;
            }
         }
         else
         {
            _whatsNewImageIndex++;
            if(_whatsNewImageIndex > _whatsNewImageIds.length - 1)
            {
               _whatsNewImageIndex = 0;
            }
         }
         loadWhatsNewImage();
      }
      
      private function onSubmitWorkDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral/submit/art",-1,1);
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(4);
      }
      
      private function addGalleryListeners() : void
      {
         _artGalleryPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _artGalleryPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _artGalleryPopup.lBtn.addEventListener("mouseDown",onGalleryLeftRightDown,false,0,true);
         _artGalleryPopup.rBtn.addEventListener("mouseDown",onGalleryLeftRightDown,false,0,true);
      }
      
      private function removeGalleryListeners() : void
      {
         _artGalleryPopup.removeEventListener("mouseDown",onPopupDown);
         _artGalleryPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _artGalleryPopup.lBtn.removeEventListener("mouseDown",onGalleryLeftRightDown);
         _artGalleryPopup.rBtn.removeEventListener("mouseDown",onGalleryLeftRightDown);
      }
      
      private function addWhatsNewListeners() : void
      {
         _whatsNewPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _whatsNewPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _whatsNewPopup.leftBtn.addEventListener("mouseDown",onLeftRightWhatsNew,false,0,true);
         _whatsNewPopup.rightBtn.addEventListener("mouseDown",onLeftRightWhatsNew,false,0,true);
         _whatsNewPopup.playMovBtn.addEventListener("mouseDown",onPlayMovieDown,false,0,true);
      }
      
      private function removeWhatsNewListeners() : void
      {
         _whatsNewPopup.removeEventListener("mouseDown",onPopupDown);
         _whatsNewPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _whatsNewPopup.leftBtn.removeEventListener("mouseDown",onLeftRightWhatsNew);
         _whatsNewPopup.rightBtn.removeEventListener("mouseDown",onLeftRightWhatsNew);
         _whatsNewPopup.playMovBtn.removeEventListener("mouseDown",onPlayMovieDown);
      }
      
      private function addBoardListeners() : void
      {
         _bulletinBoardPopup.addEventListener("mouseDown",onPopupDown,false,0,true);
         _bulletinBoardPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
         _bulletinBoardPopup.playMovBtn.addEventListener("mouseDown",onPlayMovieDown,false,0,true);
         _bulletinBoardPopup.whatsNewBtn.addEventListener("mouseDown",onWhatsNewBtnDown,false,0,true);
         _bulletinBoardPopup.masterpieceGallery.addEventListener("mouseDown",onMasterpieceDown,false,0,true);
         _bulletinBoardPopup.masterpieceGallery.addEventListener("mouseOver",onMasterpieceOver,false,0,true);
         _bulletinBoardPopup.masterpieceGallery.addEventListener("mouseOut",onMasterpieceOut,false,0,true);
         _bulletinBoardPopup.submitWorkBtn.addEventListener("mouseDown",onSubmitWorkDown,false,0,true);
      }
      
      private function removeBoardListeners() : void
      {
         _bulletinBoardPopup.removeEventListener("mouseDown",onPopupDown);
         _bulletinBoardPopup.bx.removeEventListener("mouseDown",onPopupClose);
         _bulletinBoardPopup.playMovBtn.removeEventListener("mouseDown",onPlayMovieDown);
         _bulletinBoardPopup.whatsNewBtn.removeEventListener("mouseDown",onWhatsNewBtnDown);
         _bulletinBoardPopup.masterpieceGallery.removeEventListener("mouseDown",onMasterpieceDown);
         _bulletinBoardPopup.masterpieceGallery.removeEventListener("mouseOver",onMasterpieceOver);
         _bulletinBoardPopup.masterpieceGallery.removeEventListener("mouseOut",onMasterpieceOut);
         _bulletinBoardPopup.submitWorkBtn.removeEventListener("mouseDown",onSubmitWorkDown);
      }
   }
}

