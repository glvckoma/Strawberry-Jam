package gui
{
   import Enums.DenItemDef;
   import Party.PartyManager;
   import achievement.AchievementXtCommManager;
   import com.greensock.TweenLite;
   import com.greensock.easing.Quad;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.ApplicationDomain;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import giftPopup.GiftPopup;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PageFlip extends Sprite
   {
      public static const BOOK_TYPE_NORMAL_EBOOK:int = 0;
      
      public static const BOOK_TYPE_AJ_EBOOK:int = 1;
      
      public static const BOOK_TYPE_MEMBERSHIP:int = 2;
      
      public static const BOOK_TYPE_COMIC_EBOOK:int = 3;
      
      private static const SINGLE_PAGE_PAGES_ID:int = 500;
      
      private static const SINGLE_PAGE_LAST_PAGE_ID:int = 500;
      
      private static const EBOOK_PAGES_ID:int = 567;
      
      private static const EBOOK_PAGES_ID_TALL:int = 879;
      
      private static const EBOOK_MEDIA_ID:int = 566;
      
      private static const AJ_EBOOK_MEDIA_ID:int = 566;
      
      private static const RECTANGULAR_EBOOK_MEDIA_ID:int = 878;
      
      private static const RECTANGULAR_AJ_EBOOK_MEDIA_ID:int = 3006;
      
      private static const JOURNEYBOOK_PAGES_ID:int = 1184;
      
      private static const JOURNEYBOOK_MEDIA_ID:int = 1183;
      
      private static const INFO_POPUP_MEDIA_ID:int = 1201;
      
      private static const MEMBER_BOOK_MEDIA_ID:int = 3578;
      
      private static const MEMBER_BOOK_PAGES_ID:int = 5731;
      
      private static const EBOOK_COMIC_MEDIA_ID:int = 5296;
      
      private static const COMIC_BOOK_PAGES_ID:int = 5297;
      
      private static const LEFT_TOP_BTN_ID:int = 176;
      
      private static const RIGHT_TOP_BTN_ID:int = 177;
      
      private static const LEFT_BOTTOM_BTN_ID:int = 180;
      
      private static const RIGHT_BOTTOM_BTN_ID:int = 181;
      
      private static const ZOOM_BTN_ID:int = 568;
      
      private static const JOURNEYBOOK_SOUNDS_ID:int = 1332;
      
      private static const JB_KEEP_GIFT:int = 31;
      
      private static const JB_DISCARD_GIFT:int = 30;
      
      private static const JB_PAGE_SEEN:int = 29;
      
      private static const JB_BAHARI_BAY_UV:int = 289;
      
      private static const JB_CRYSTAL_REEF_UV:int = 290;
      
      private static const JB_DEEP_BLUE_UV:int = 291;
      
      private static const JB_KANI_COVE_UV:int = 288;
      
      private static const JB_LTOZ_UV:int = 295;
      
      private static const JB_SHIVEER_UV:int = 298;
      
      private static const JB_SAREPIA_UV:int = 311;
      
      private static const JB_APPONDALE_UV:int = 320;
      
      private static const JB_CORALCANYONS_UV:int = 333;
      
      private static const JB_CRYSTAL_SANDS_UV:int = 337;
      
      private static const JB_BIRDS_PARADISE_UV:int = 365;
      
      private static const JB_OUTBACK_UV:int = 371;
      
      private static const JB_ALPHA_UV:int = 456;
      
      private static const JB_ALPHA_UV_1:int = 457;
      
      private static const JB_BALLOOSH_UV:int = 459;
      
      private static const JB_ALPHA_UV_2:int = 460;
      
      private static const EBOOK_OTTER_STAMPS_UV:int = 381;
      
      private static const EBOOK_PANDA_STAMPS_UV:int = 401;
      
      private static const EBOOK_POLARBEAR_STAMPS_UV:int = 402;
      
      private static const EBOOK_OWL_STAMPS_UV:int = 407;
      
      private static const EBOOK_LION_STAMPS_UV:int = 408;
      
      private static const EBOOK_CHEETAH_STAMPS_UV:int = 411;
      
      private static const EBOOK_LLAMA_STAMPS_UV:int = 412;
      
      private static const EBOOK_SNOW_LEOPARD_STAMPS_UV:int = 416;
      
      private static const EBOOK_LYNX_STAMPS_UV:int = 418;
      
      private static const EBOOK_FOX_STAMPS_UV:int = 422;
      
      private static const EBOOK_SNOW_LEOPARD_STICKERS_UV:int = 417;
      
      private static const JB_BAHARI_BAY_NAME:String = "bahari_bay";
      
      private static const JB_CRYSTAL_REEF_NAME:String = "crystal_reef";
      
      private static const JB_DEEP_BLUE_NAME:String = "deep_blue";
      
      private static const JB_KANI_COVE_NAME:String = "kani_cove";
      
      private static const JB_LTOZ_NAME:String = "lost_temple_of_zios";
      
      private static const JB_SHIVEER_NAME:String = "Mt_Shiveer";
      
      private static const JB_SAREPIA_NAME:String = "Sarepia_Forest";
      
      private static const JB_APPONDALE_NAME:String = "Appondale";
      
      private static const JB_CORALCANYONS_NAME:String = "coral_canyons";
      
      private static const JB_CRYSTAL_SANDS_NAME:String = "crystal_sands";
      
      private static const JB_BIRDS_PARADISE_NAME:String = "birds_of_paradise";
      
      private static const JB_OUTBACK_NAME:String = "kimbara_outback";
      
      private static const JB_ALPHA_NAME:String = "alpha";
      
      private static const JB_BALLOOSH_NAME:String = "balloosh";
      
      private static const EBOOK_OTTER_NAME:String = "Otters";
      
      private static const EBOOK_PANDA_NAME:String = "Panda";
      
      private static const EBOOK_POLARBEAR_NAME:String = "PolarBear";
      
      private static const EBOOK_OWL_NAME:String = "Owl";
      
      private static const EBOOK_LION_NAME:String = "lion";
      
      private static const EBOOK_CHEETAH_NAME:String = "cheetah";
      
      private static const EBOOK_LLAMA_NAME:String = "llama";
      
      private static const EBOOK_SNOW_LEOPARD_NAME:String = "snowLeopard";
      
      private static const EBOOK_LYNX_NAME:String = "lynx";
      
      private static const EBOOK_FOX_NAME:String = "fox";
      
      private static const EBOOK_OTTER_NUM_STAMPS:int = 7;
      
      private static const EBOOK_PANDA_NUM_STAMPS:int = 4;
      
      private static const EBOOK_POLARBEAR_NUM_STAMPS:int = 5;
      
      private static const EBOOK_OWL_NUM_STAMPS:int = 5;
      
      private static const EBOOK_LION_NUM_STAMPS:int = 5;
      
      private static const EBOOK_CHEETAH_NUM_STAMPS:int = 5;
      
      private static const EBOOK_LLAMA_NUM_STAMPS:int = 5;
      
      private static const EBOOK_SNOW_LEOPARDS_NUM_STAMPS:int = 4;
      
      private static const EBOOK_LYNX_NUM_STAMPS:int = 3;
      
      private static const EBOOK_FOX_NUM_STAMPS:int = 2;
      
      private static const EBOOK_SNOW_LEOPARD_NUM_STICKERS:int = 8;
      
      private static const EBOOK_KEEP_GIFT:int = 2;
      
      private static const EBOOK_DISCARD_GIFT:int = 1;
      
      public static var pageFlipOpen:Boolean;
      
      private var _popupLayer:DisplayLayer;
      
      private var _pageWidth:Number;
      
      private var _pageHeight:Number;
      
      private var _pageColor:int;
      
      private var _numberOfPages:Number;
      
      private var _autoStepSpeed:Number;
      
      private var _snapDistance:Number;
      
      private var _dragSmoothness:Number;
      
      private var _cornerBtnPositions:int;
      
      private var _showCornerBtns:Boolean;
      
      private var _playFlipSound:Boolean;
      
      private var _pageWidthAndHeight:Number;
      
      private var _pivotY:Number;
      
      private var _flipDirection:Number;
      
      private var _vertDir:Number;
      
      private var _pageNumber:Number;
      
      private var _currentPage:Number;
      
      private var _autoFlipTargetPage:Number;
      
      private var _ShouldBeDragging:Boolean;
      
      private var _pageFlipPercent:Number;
      
      private var _flipSound:Sound;
      
      private var _soundChannel:SoundChannel;
      
      private var _pageRatio:Number;
      
      private var _startX:Number;
      
      private var _pageOffset:Number;
      
      private var _step:Number;
      
      private var _bFlipAuto:Boolean;
      
      private var _fullPageBounds:Rectangle;
      
      private var _rightPageBounds:Rectangle;
      
      private var _leftPageBounds:Rectangle;
      
      private var _bookType:int;
      
      private var _directionAfterFlip:Number;
      
      private var _pageDrag:Boolean;
      
      private var _isSinglePF:Boolean;
      
      private var _enableDragging:Boolean;
      
      private var _currPageLoaded:Boolean;
      
      private var _currPageVarsLoaded:Boolean;
      
      private var _pageFlipComplete:Boolean;
      
      private var _zoomedIn:Boolean;
      
      private var _setPagesOnly:Boolean;
      
      private var _isRectangular:Boolean;
      
      private var _infoPopupDefId:int;
      
      private var _flipInProgress:int;
      
      private var _pageFlipBase:MovieClip;
      
      private var _stationaryRightPage:MovieClip;
      
      private var _flippingBottomPageMask:Sprite;
      
      private var _flippingTopPageMask:Sprite;
      
      private var _flippingPageShadowMask:MovieClip;
      
      private var _shadowStationaryMask:MovieClip;
      
      private var _flippingBottomPage:MovieClip;
      
      private var _flippingTopPage:MovieClip;
      
      private var _stationaryLeftPage:MovieClip;
      
      private var _blankPage1:MovieClip;
      
      private var _blankPage2:MovieClip;
      
      private var _blankPage3:MovieClip;
      
      private var _blankPage4:MovieClip;
      
      private var _blankPageLast:MovieClip;
      
      private var _eBook:MovieClip;
      
      private var _membershipBook:MovieClip;
      
      private var _journeyBook:MovieClip;
      
      private var _isJourneyBook:Boolean;
      
      private var _flippingShadow:Sprite;
      
      private var _shadowsShadow:Sprite;
      
      private var _rightBottomBtn:MovieClip;
      
      private var _leftBottomBtn:MovieClip;
      
      private var _xBtn:MovieClip;
      
      private var _zoomBtn:MovieClip;
      
      private var _print:Sprite;
      
      private var _loadedPages:Array;
      
      private var _spiralLeftPage:LoadingSpiral;
      
      private var _spiralRightPage:LoadingSpiral;
      
      private var _spiralTopFlippingPage:LoadingSpiral;
      
      private var _spiralBottomFlippingPage:LoadingSpiral;
      
      private var _pageStart:int;
      
      private var _mediaViews:Array;
      
      private var _buttonsView:Array;
      
      private var _pagesArray:Array;
      
      private var _pageHolderViews:Array;
      
      private var _topPageTween:TweenLite;
      
      private var _bottomPageTween:TweenLite;
      
      private var _draggedItem:MovieClip;
      
      private var _pageNumberTxt:int;
      
      private var _pageFlipIncrement:int;
      
      private var _buttonsLoaded:int;
      
      private var _pagesLoaded:int;
      
      private var _pageTurnedTo:int;
      
      private var _numberOfLoadedPages:int;
      
      private var _numberOfFlips:int;
      
      private var _numButtonsToLoad:int;
      
      private var _closeCallback:Function;
      
      private var _flipCallback:Function;
      
      private var _pageNameArray:Array;
      
      private var _pageNumToOpen:int;
      
      private var _loadedPageNumber:Array;
      
      private var _giftPopup:GiftPopup;
      
      private var _genericPopup:MovieClip;
      
      private var _currGiftItem:MovieClip;
      
      private var _infoPopup:MovieClip;
      
      private var _infoPopupMediaHelper:MediaHelper;
      
      private var _gameLaunchObj:Object;
      
      private var _stickerInstances:Object;
      
      private var _pastedStickerInstances:Vector.<MovieClip>;
      
      private var _pageNumForStickers:Number;
      
      private var _quizPages:Array;
      
      private var _numQuizAnswersChecked:int;
      
      private var _numQuizQuestions:int;
      
      public function PageFlip()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Array = null, param3:Boolean = false, param4:Function = null, param5:Function = null, param6:Boolean = false, param7:int = 0, param8:Boolean = false, param9:Boolean = false, param10:int = 1, param11:int = -1) : void
      {
         var _loc12_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(true);
         _pageColor = 16777215;
         _numberOfPages = 0;
         _autoStepSpeed = 0.1;
         _snapDistance = 0.002;
         _dragSmoothness = 0.5;
         _cornerBtnPositions = 20;
         _showCornerBtns = true;
         _playFlipSound = true;
         pageFlipOpen = true;
         _isSinglePF = param3;
         _enableDragging = param8;
         _closeCallback = param4;
         _flipCallback = param5;
         _isJourneyBook = param9;
         _pageNameArray = [];
         _loadedPageNumber = [];
         _pageNumToOpen = param10;
         _popupLayer = param1;
         _isRectangular = param6;
         _bookType = param7;
         _pageHolderViews = [];
         _infoPopupDefId = param11;
         _pagesArray = param2;
         if(_isJourneyBook && !AJAudio.hasLoadedJourneyBookBookSfx)
         {
            _loc12_ = new MediaHelper();
            _loc12_.init(1332,onLoadJBSounds);
            _pageHolderViews.push(_loc12_);
         }
         else
         {
            loadHolderMovieClips();
         }
      }
      
      private function openPageFlip() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         _pageWidth = _blankPage1.width;
         _pageHeight = _blankPage1.height;
         _pageWidthAndHeight = _pageWidth + _pageHeight;
         _flipDirection = 1;
         _vertDir = -1;
         _pivotY = _pageHeight * 0.5 + _pageWidth;
         _pageNumber = 2.5;
         _currentPage = 0.5;
         _pageStart = _pageNumToOpen;
         _numberOfFlips = 1;
         _pageTurnedTo = 1;
         _buttonsLoaded = 0;
         _pageFlipIncrement = 1;
         if(_isSinglePF)
         {
            _numberOfPages += _currentPage + 0.5 + (_pagesArray.length * 2 - 2);
            if(_isJourneyBook && JBManager.numUnseenPages == _pagesArray.length || _infoPopupDefId != -1)
            {
               _infoPopupMediaHelper = new MediaHelper();
               _infoPopupMediaHelper.init(1201,infoPopupCallback);
            }
            _loc2_ = 1;
            while(_loc2_ < _pageNumToOpen)
            {
               _pageNumber = fixPageNum(_currentPage + 2);
               _currentPage = _pageNumber;
               _loc2_++;
            }
            _pageTurnedTo = _pageNumToOpen;
            _numberOfFlips = _pageNumToOpen;
         }
         else
         {
            _pageFlipIncrement = 2;
            _pageStart = 2;
            _currentPage = 2.5;
            _pageNumber = 4.5;
            _numberOfFlips = _pageStart;
            if(_pagesArray.length % 2 != 0)
            {
               throw new Error("Number of pages must be a multiple of 2");
            }
            _numberOfPages = _pagesArray.length + (_pagesArray.length * 0.5 % 2 == 0 ? 1 : 0.5);
            _loc2_ = 2;
            while(_loc2_ < _pageNumToOpen)
            {
               _pageNumber = fixPageNum(_currentPage + 2);
               _loc3_ = Math.round((_pageNumber - _currentPage) * 0.5);
               _loc1_ = _pageNumber > _currentPage ? 1 : -1;
               _pageTurnedTo += _loc3_;
               _loc4_ = Math.abs(_loc3_);
               _loc1_ == 1 ? (_isSinglePF ? (_numberOfFlips = _numberOfFlips + _loc4_) : (int(_numberOfFlips = _numberOfFlips + _loc4_ * 2))) : (int(_isSinglePF ? (_numberOfFlips = _numberOfFlips - _loc4_) : (int(_numberOfFlips = _numberOfFlips - _loc4_ * 2))));
               _numberOfFlips = Math.min(_numberOfPages,_numberOfFlips);
               _currentPage = _pageNumber;
               _loc2_ += 2;
            }
            _pageStart = _numberOfFlips;
         }
         _ShouldBeDragging = false;
         _pageFlipPercent = 0;
         _numberOfLoadedPages = 0;
         _spiralLeftPage = new LoadingSpiral();
         _spiralRightPage = new LoadingSpiral();
         _spiralTopFlippingPage = new LoadingSpiral();
         _spiralBottomFlippingPage = new LoadingSpiral();
         _loadedPages = [];
         _mediaViews = [];
         _buttonsView = [];
         this.addEventListener("mouseDown",mouseDownHandler,false,0,true);
         this.addEventListener("mouseUp",mouseUpHandler,false,0,true);
         loadPages(_pageStart);
         loadButtons();
         DarkenManager.showLoadingSpiral(false);
         if(_eBook)
         {
            this.x = 0;
            this.y = 0;
            _popupLayer.addChild(_eBook);
            _eBook.x = 900 * 0.5;
            _eBook.y = 550 * 0.5;
            _eBook.addEventListener("mouseDown",mouseDownHandler,false,0,true);
            _eBook.addEventListener("mouseUp",mouseUpHandler,false,0,true);
            _eBook.bx.addEventListener("mouseDown",allBtnDownHandler,false,0,true);
            if(_xBtn)
            {
               _xBtn.visible = false;
            }
            _eBook.itemWindow.addChild(this);
            DarkenManager.darken(_eBook);
         }
         else if(_journeyBook)
         {
            this.x = 0;
            this.y = 0;
            _popupLayer.addChild(_journeyBook);
            _journeyBook.x = 0;
            _journeyBook.y = 550 * 0.5;
            _journeyBook.addEventListener("mouseDown",mouseDownHandler,false,0,true);
            _journeyBook.itemWindow.addChild(this);
            DarkenManager.darken(_journeyBook);
         }
         else if(_membershipBook)
         {
            this.x = 0;
            this.y = 0;
            _popupLayer.addChild(_membershipBook);
            _membershipBook.x = 900 * 0.5;
            _membershipBook.y = 550 * 0.5;
            _membershipBook.addEventListener("mouseDown",mouseDownHandler,false,0,true);
            _membershipBook.addEventListener("mouseUp",mouseUpHandler,false,0,true);
            _membershipBook.bx.addEventListener("mouseDown",allBtnDownHandler,false,0,true);
            _membershipBook.joinClubBtn.addEventListener("mouseDown",onJoinClubBtn,false,0,true);
            if(_xBtn)
            {
               _xBtn.visible = false;
            }
            _membershipBook.itemWindow.addChild(this);
            DarkenManager.darken(_membershipBook);
         }
         else
         {
            this.x = 900 * 0.5;
            this.y = 550 * 0.5;
            _popupLayer.addChild(this);
            DarkenManager.darken(this);
         }
         _pageFlipBase = new MovieClip();
         this.addChild(_pageFlipBase);
         _pageFlipBase.y = -(_pageWidth + _pageHeight * 0.5);
         if(_isSinglePF && !_isJourneyBook)
         {
            _pageFlipBase.x = -_pageWidth * 0.5;
         }
         if(_eBook)
         {
            if(_isRectangular)
            {
               _fullPageBounds = new Rectangle(900 - 30,_eBook.height + 110,-840,-_eBook.height - 210);
            }
            else
            {
               _fullPageBounds = new Rectangle(900 + 160,_eBook.height,-1225,-_eBook.height - 5);
            }
         }
         else
         {
            _fullPageBounds = new Rectangle(_pageWidth * 2,_pageHeight,900 - _pageWidth * 4,550 - _pageHeight * 2);
         }
         _rightPageBounds = new Rectangle(0,_pageHeight,0,550 - _pageHeight * 2);
         _leftPageBounds = new Rectangle(_pageWidth * 2,_pageHeight,0,550 - _pageHeight * 2);
         initPage(_pageNumber,_flipDirection,_vertDir);
         if(_flipCallback != null)
         {
            if(!_isJourneyBook)
            {
               _flipCallback(_pageTurnedTo);
            }
         }
      }
      
      public function destroy() : void
      {
         if(_eBook)
         {
            DarkenManager.unDarken(_eBook);
            if(_eBook && _eBook.parent == _popupLayer)
            {
               _popupLayer.removeChild(_eBook);
            }
            if(_zoomBtn && _zoomBtn.parent == _popupLayer)
            {
               _popupLayer.removeChild(_zoomBtn);
            }
            _zoomBtn.removeEventListener("mouseDown",magnify);
         }
         else if(_journeyBook)
         {
            DarkenManager.unDarken(_journeyBook);
            if(_popupLayer && _popupLayer.parent == _journeyBook)
            {
               _popupLayer.removeChild(_journeyBook);
            }
         }
         else if(_membershipBook)
         {
            DarkenManager.unDarken(_membershipBook);
            if(_popupLayer && _popupLayer.parent == _membershipBook)
            {
               _popupLayer.removeChild(_membershipBook);
            }
         }
         else
         {
            DarkenManager.unDarken(this);
            if(_popupLayer && _popupLayer.parent == this)
            {
               _popupLayer.removeChild(this);
            }
         }
         if(_infoPopup)
         {
            onInfoPopupClose(null);
         }
         KeepAlive.stopKATimer(_rightBottomBtn);
         removeListeners();
         _buttonsView = null;
         _mediaViews = null;
         _loadedPages = null;
         if(_eBook)
         {
            while(_eBook.numChildren > 0)
            {
               _eBook.removeChildAt(0);
            }
         }
         else if(_journeyBook)
         {
            while(_journeyBook.numChildren > 0)
            {
               _journeyBook.removeChildAt(0);
            }
         }
         else if(_membershipBook)
         {
            while(_membershipBook.numChildren > 0)
            {
               _membershipBook.removeChildAt(0);
            }
         }
         else
         {
            while(this.numChildren > 0)
            {
               this.removeChildAt(0);
            }
         }
         _pageFlipBase = null;
         _stationaryRightPage = null;
         _flippingBottomPageMask = null;
         _flippingTopPageMask = null;
         _flippingPageShadowMask = null;
         _shadowStationaryMask = null;
         _flippingBottomPage = null;
         _flippingTopPage = null;
         _stationaryLeftPage = null;
         _flippingShadow = null;
         _shadowsShadow = null;
         _rightBottomBtn = null;
         _leftBottomBtn = null;
         _xBtn = null;
         _print = null;
         _closeCallback = null;
         _flipCallback = null;
         _pageNumberTxt = NaN;
         _pageFlipIncrement = NaN;
         _buttonsLoaded = NaN;
         _numberOfLoadedPages = NaN;
         _pageTurnedTo = NaN;
         _spiralLeftPage.destroy();
         _spiralRightPage.destroy();
         _spiralTopFlippingPage.destroy();
         _spiralBottomFlippingPage.destroy();
         pageFlipOpen = false;
         _topPageTween = null;
         _bottomPageTween = null;
         _draggedItem = null;
      }
      
      private function removeListeners() : void
      {
         if(_pageFlipBase)
         {
            _pageFlipBase.removeEventListener("enterFrame",onEnterFrame);
         }
         if(_pagesLoaded == _pageHolderViews.length && _buttonsLoaded == _numButtonsToLoad)
         {
            _leftBottomBtn.removeEventListener("mouseOver",allBtnOverHandler);
            _rightBottomBtn.removeEventListener("mouseOver",allBtnOverHandler);
            _xBtn.removeEventListener("mouseOver",allBtnOverHandler);
            _leftBottomBtn.removeEventListener("mouseOut",allBtnOutHandler);
            _rightBottomBtn.removeEventListener("mouseOut",allBtnOutHandler);
            _xBtn.removeEventListener("mouseOut",allBtnOutHandler);
            _leftBottomBtn.removeEventListener("mouseDown",allBtnDownHandler);
            _rightBottomBtn.removeEventListener("mouseDown",allBtnDownHandler);
            _xBtn.removeEventListener("mouseDown",allBtnDownHandler);
            _leftBottomBtn.removeEventListener("mouseUp",allBtnUpHandler);
            _rightBottomBtn.removeEventListener("mouseUp",allBtnUpHandler);
            _xBtn.removeEventListener("mouseUp",allBtnUpHandler);
         }
         if(_eBook)
         {
            _eBook.removeEventListener("mouseDown",mouseDownHandler);
            _eBook.removeEventListener("mouseUp",mouseUpHandler);
            _eBook.bx.removeEventListener("mouseDown",allBtnDownHandler);
            _zoomBtn.removeEventListener("mouseDown",magnify);
         }
         if(_membershipBook)
         {
            _membershipBook.removeEventListener("mouseDown",mouseDownHandler);
            _membershipBook.removeEventListener("mouseUp",mouseUpHandler);
            _membershipBook.bx.removeEventListener("mouseDown",allBtnDownHandler);
            _membershipBook.joinClubBtn.removeEventListener("mouseDown",onJoinClubBtn);
         }
         if(_journeyBook)
         {
            _journeyBook.removeEventListener("mouseDown",mouseDownHandler);
         }
      }
      
      private function onLoadJBSounds(param1:MovieClip) : void
      {
         var _loc2_:ApplicationDomain = null;
         if(param1)
         {
            if(!AJAudio.hasLoadedJourneyBookBookSfx)
            {
               _loc2_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("JBBookFactClose",_loc2_.getDefinition("JBBookFactClose") as Class,0.6);
               AJAudio.loadSfx("JBBookFactOpen",_loc2_.getDefinition("JBBookFactOpen") as Class,0.6);
               AJAudio.hasLoadedJourneyBookBookSfx = true;
            }
            _pageHolderViews = [];
            loadHolderMovieClips();
         }
      }
      
      private function loadHolderMovieClips() : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = -1;
         if(_isSinglePF)
         {
            if(_isJourneyBook)
            {
               _loc3_ = _loc4_ = 1184;
               _loc2_ = 1183;
            }
            else
            {
               _loc3_ = 500;
               _loc4_ = 500;
            }
         }
         else if(_bookType == 1)
         {
            _loc2_ = _isRectangular ? 3006 : 566;
            _loc3_ = _loc4_ = _isRectangular ? 879 : 567;
         }
         else if(_bookType == 2)
         {
            _loc2_ = 3578;
            _loc3_ = _loc4_ = 5731;
         }
         else if(_bookType == 3)
         {
            _loc2_ = 5296;
            _loc3_ = _loc4_ = 5297;
         }
         else if(_bookType == 0)
         {
            _loc2_ = _isRectangular ? 878 : 566;
            _loc3_ = _loc4_ = _isRectangular ? 879 : 567;
         }
         if(!_isJourneyBook)
         {
            _currPageVarsLoaded = true;
         }
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(_loc3_,pageHolderCallback);
         _pageHolderViews[0] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(_loc3_,pageHolderCallback);
         _pageHolderViews[1] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(_loc3_,pageHolderCallback);
         _pageHolderViews[2] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(_loc3_,pageHolderCallback);
         _pageHolderViews[3] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(_loc4_,pageHolderCallback,true);
         _pageHolderViews[4] = _loc1_;
         if(_loc2_ > -1)
         {
            _loc1_ = new MediaHelper();
            _loc1_.init(_loc2_,pageHolderCallback,true);
            _pageHolderViews[5] = _loc1_;
         }
      }
      
      private function pageHolderCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            if(param1.getChildAt(0).hasOwnProperty("noAnim"))
            {
               param1.cacheAsBitmap = true;
            }
            if(param1.passback && param1.mediaHelper == _pageHolderViews[4])
            {
               _blankPageLast = param1;
               param1.cacheAsBitmap = true;
            }
            else if(param1.passback && param1.mediaHelper == _pageHolderViews[5])
            {
               if(param1.mediaHelper.id == 1183)
               {
                  _journeyBook = MovieClip(param1.getChildAt(0));
               }
               else if(param1.mediaHelper.id == 3578)
               {
                  _membershipBook = MovieClip(param1.getChildAt(0));
               }
               else
               {
                  _eBook = MovieClip(param1.getChildAt(0));
               }
            }
            else
            {
               param1.cacheAsBitmap = true;
               if(_blankPage1 == null)
               {
                  _blankPage1 = param1;
               }
               else if(_blankPage2 == null)
               {
                  _blankPage2 = param1;
               }
               else if(_blankPage3 == null)
               {
                  _blankPage3 = param1;
               }
               else if(_blankPage4 == null)
               {
                  _blankPage4 = param1;
               }
            }
            if(param1.mediaHelper)
            {
               param1.mediaHelper.destroy();
               delete param1.mediaHelper;
            }
            _pagesLoaded++;
         }
         if(_pagesLoaded == _pageHolderViews.length)
         {
            openPageFlip();
         }
      }
      
      private function infoPopupCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            _infoPopup = MovieClip(param1.getChildAt(0));
            _popupLayer.addChild(_infoPopup);
            _infoPopup.bx.addEventListener("mouseDown",onInfoPopupClose,false,0,true);
            _infoPopup.addEventListener("mouseDown",onImageDown,false,0,true);
            if(_infoPopupDefId != -1)
            {
               LocalizationManager.translateId(_infoPopup.txt,_infoPopupDefId == 27 ? 11363 : (_infoPopupDefId == 48 ? 30383 : 11364));
            }
            else
            {
               LocalizationManager.translateId(_infoPopup.txt,11364);
            }
            _infoPopup.x = 900 * 0.5;
            _infoPopup.y = 255;
         }
      }
      
      private function onInfoPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _infoPopup.removeEventListener("mouseDown",onImageDown);
         _infoPopup.bx.removeEventListener("mouseDown",onInfoPopupClose);
         _popupLayer.removeChild(_infoPopup);
         _infoPopup = null;
      }
      
      private function loadButtons() : void
      {
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_ = new MediaHelper();
         _loc1_.init(177,buttonsCallback,true);
         _buttonsView[1] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(180,buttonsCallback,true);
         _buttonsView[2] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(181,buttonsCallback,true);
         _buttonsView[3] = _loc1_;
         if(_eBook)
         {
            _loc1_ = new MediaHelper();
            _loc1_.init(568,buttonsCallback,true);
            _buttonsView[4] = _loc1_;
            _numButtonsToLoad = 4;
         }
         else
         {
            _numButtonsToLoad = 3;
         }
      }
      
      private function buttonsCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _buttonsView.length)
         {
            if(_buttonsView[_loc2_] == param1.mediaHelper)
            {
               _buttonsView[_loc2_] = param1;
               param1.cacheAsBitmap = true;
               _buttonsLoaded++;
            }
            _loc2_++;
         }
         if(param1.mediaHelper)
         {
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
         if(_buttonsLoaded == _numButtonsToLoad)
         {
            initBtns();
         }
      }
      
      private function loadPages(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         if(_isSinglePF)
         {
            _loc2_.init(_pagesArray[param1 - 1],mediaHelperCallback,param1);
            _mediaViews[param1 - 1] = _loc2_;
         }
         else
         {
            _loc2_.init(_pagesArray[param1 - 2],mediaHelperCallback,param1);
            _mediaViews[param1 - 2] = _loc2_;
            _loc2_ = new MediaHelper();
            _loc2_.init(_pagesArray[param1 - 1],mediaHelperCallback,param1);
            _mediaViews[param1 - 1] = _loc2_;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:MovieClip = null;
         if(_pageFlipBase)
         {
            _loc5_ = 0;
            while(_loc5_ < _mediaViews.length)
            {
               if(_mediaViews[_loc5_] == param1.mediaHelper)
               {
                  delete _mediaViews[_loc5_];
                  _numberOfLoadedPages++;
                  if(_isSinglePF)
                  {
                     _loc2_ = _pageFlipIncrement + _loc5_ * 2;
                     _loadedPages[_pageFlipIncrement + _loc5_ * 2] = param1;
                  }
                  else
                  {
                     _loc2_ = _pageFlipIncrement + _loc5_;
                     if(_bookType == 1 || _bookType == 3)
                     {
                        if(_isRectangular)
                        {
                           if(_bookType == 3)
                           {
                              param1.scaleX = 0.7;
                              param1.scaleY = 0.7;
                           }
                           else
                           {
                              param1.scaleX = 0.499;
                              param1.scaleY = 0.499;
                           }
                        }
                        else
                        {
                           param1.scaleX = 0.413;
                           param1.scaleY = 0.413;
                        }
                     }
                     _loadedPages[_loc2_] = param1;
                     if(param1.getChildAt(0).hasOwnProperty("noAnim"))
                     {
                        param1.cacheAsBitmap = true;
                     }
                  }
                  checkPageForButtons(param1,_loc2_);
                  if(_flipInProgress == 1 || _pageFlipComplete == true)
                  {
                     _currentPage = _pageNumber;
                  }
                  if(_numberOfFlips == param1.passback)
                  {
                     if(_numberOfLoadedPages == _pageFlipIncrement)
                     {
                        _numberOfLoadedPages = 0;
                        _loadedPageNumber[param1.passback - _pageFlipIncrement] = true;
                        _currPageLoaded = true;
                     }
                     if(_flipInProgress == 1 || _pageFlipComplete == true)
                     {
                        if(_pageNumber < _numberOfPages)
                        {
                           _setPagesOnly = true;
                        }
                        if(!(_pageFlipComplete || _pageFlipPercent > 0.95))
                        {
                           _currentPage = _pageNumber;
                           setStationary(true);
                           _loc4_ = _flipDirection == 1 ? _pageNumber - 0.5 : _pageNumber + 0.5;
                           if(_loadedPages[_loc4_] != null)
                           {
                              _loc3_ = _loadedPages[_loc4_];
                              _loc3_.x = -_flipDirection * _pageWidth * 0.5;
                              _loc3_.y = -_vertDir * _pivotY;
                              _flippingBottomPage.addChild(_loc3_);
                           }
                           else
                           {
                              _spiralBottomFlippingPage.setNewParent(_flippingBottomPage,_flipDirection * _pageWidth * 0.5,-_vertDir * _pivotY);
                           }
                           setupButtonsPositions();
                        }
                        break;
                     }
                     initPage(_pageNumber,_flipDirection,_vertDir);
                  }
                  break;
               }
               _loc5_++;
            }
         }
      }
      
      private function checkPageForButtons(param1:MovieClip, param2:int) : void
      {
         var _loc16_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc9_:Array = null;
         var _loc14_:Array = null;
         var _loc7_:int = 0;
         var _loc17_:Object = null;
         var _loc3_:* = null;
         var _loc5_:Boolean = false;
         var _loc12_:Object = null;
         var _loc15_:SharedObject = null;
         var _loc13_:Object = null;
         var _loc10_:Array = null;
         var _loc8_:int = 0;
         var _loc11_:int = 0;
         if(param1)
         {
            _loc16_ = param1.numChildren;
            _loc6_ = 0;
            while(_loc6_ < param1.numChildren)
            {
               _loc4_ = param1.getChildAt(_loc6_);
               if(_loc4_ != null)
               {
                  _loc9_ = [];
                  _loc7_ = 0;
                  while(_loc7_ < _loc4_.numChildren)
                  {
                     _loc17_ = _loc4_.getChildAt(_loc7_);
                     if(_loc17_.name.indexOf("movie") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onMovieDown,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("jb_title") == 0)
                     {
                        _pageNameArray[param2] = _loc17_.name.substr(9);
                     }
                     else if(_loc17_.name.indexOf("jb_gift") == 0)
                     {
                        if(_loc4_.JBGift == null)
                        {
                           _loc4_.JBGift = [];
                        }
                        _loc14_ = _loc17_.name.substr(8).split("_");
                        _loc3_ = _loc17_;
                        _loc3_.id = _loc14_[0] + "_" + _loc14_[1];
                        _loc3_.type = "jb";
                        _loc3_.sequence = _loc14_.length > 2 ? _loc14_[2] : 0;
                        _loc4_.JBGift[_loc3_.sequence] = _loc3_;
                     }
                     else if(_loc17_.name.indexOf("jb") == 0)
                     {
                        _loc14_ = _loc17_.name.substr(3).split("_");
                        if(_loc9_[_loc14_.length > 1 ? _loc14_[1] : 0] == null)
                        {
                           _loc9_[_loc14_.length > 1 ? _loc14_[1] : 0] = [];
                        }
                        _loc17_.jbId = _loc14_[0];
                        _loc9_[_loc14_.length > 1 ? _loc14_[1] : 0].push(_loc17_.jbId);
                     }
                     else if(_loc17_.name.indexOf("submitBtn") == 0)
                     {
                        if(_loc17_.name.indexOf("Quiz") >= 0)
                        {
                           _loc17_.activateGrayState(true);
                        }
                        _loc17_.addEventListener("mouseDown",onSubmitDown,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("turnTo") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onTurnToBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("linkTo") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onLinkToBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("joinRoom") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onJoinRoomBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("joinParty") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onJoinPartyBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("imgPoll") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onImgPoll,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("loadPopup") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onLoadPopup,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("gameBtn") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onGameBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("petBtn") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onPetBtn,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("badgeCont") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onBadgeCont,false,0,true);
                        _loc14_ = _loc17_.name.split("_");
                        if(_loc14_ && _loc14_.length > 0)
                        {
                           _loc17_.badgePageName = _loc14_[1];
                           _loc17_.badgeId = int(_loc14_[2]);
                        }
                        else
                        {
                           _loc17_.badgeId = 0;
                           _loc17_.badgePageName = "";
                        }
                        if(gMainFrame.userInfo.userVarCache.getUserVarValueById(eBookUserVarIdForPageName(_loc17_.badgePageName)) != -1 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(eBookUserVarIdForPageName(_loc17_.badgePageName),_loc17_.badgeId)))
                        {
                           _loc17_.gotoAndStop("color");
                        }
                     }
                     else if(_loc17_.name.indexOf("stickersInPage") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onStickerInPage,false,0,true);
                        _loc14_ = _loc17_.name.split("_");
                        if(_loc14_ && _loc14_.length > 0)
                        {
                           _loc17_.stickerPageName = _loc14_[1];
                           _loc17_.stickerId = int(_loc14_[2]);
                        }
                        else
                        {
                           _loc17_.stickerId = 0;
                           _loc17_.stickerPageName = "";
                        }
                        if(gMainFrame.userInfo.userVarCache.getUserVarValueById(eBookUserVarIdForStickerName(_loc17_.stickerPageName)) != -1 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(eBookUserVarIdForStickerName(_loc17_.stickerPageName),_loc17_.stickerId)))
                        {
                           _loc17_.gotoAndStop("color");
                        }
                     }
                     else if(_loc17_.name.indexOf("stickersToPaste") == 0)
                     {
                        _loc5_ = false;
                        if(_loc17_.name.indexOf("available") < 0)
                        {
                           _loc14_ = _loc17_.name.split("_");
                           if(_loc14_ && _loc14_.length > 0)
                           {
                              _loc17_.stickerPageName = _loc14_[1];
                              _loc17_.stickerId = int(_loc14_[2]);
                           }
                           else
                           {
                              _loc17_.stickerId = 0;
                              _loc17_.stickerPageName = "";
                           }
                           if(gMainFrame.userInfo.userVarCache.getUserVarValueById(eBookUserVarIdForStickerName(_loc17_.stickerPageName)) != -1 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(eBookUserVarIdForStickerName(_loc17_.stickerPageName),_loc17_.stickerId)))
                           {
                              _loc5_ = true;
                           }
                        }
                        else
                        {
                           _loc5_ = true;
                        }
                        if(_stickerInstances == null)
                        {
                           _stickerInstances = {};
                           _pageNumForStickers = _pageNumber;
                        }
                        if(_stickerInstances[_loc17_.name])
                        {
                           _loc12_ = _stickerInstances[_loc17_.name];
                           if(_loc12_ is MovieClip)
                           {
                              _loc12_ = [_loc12_,_loc17_];
                           }
                           else
                           {
                              _loc12_.push(_loc17_);
                           }
                           _stickerInstances[_loc17_.name] = _loc12_;
                        }
                        else
                        {
                           _stickerInstances[_loc17_.name] = _loc17_;
                        }
                        _loc17_.currLoaderAppDomain = param1.loaderInfo.applicationDomain;
                        _loc17_.stickerFrame = _loc4_.stickerFrame;
                        _loc17_.addEventListener("mouseDown",onStickerPasteMouseDown,false,0,true);
                        if(_loc5_)
                        {
                           if(_loc17_.visible)
                           {
                              _loc15_ = GuiManager.sharedObj;
                              if(_loc15_ && _loc15_.data && _loc15_.data.stickerPositions)
                              {
                                 _loc13_ = _loc15_.data.stickerPositions[_loc17_.name];
                                 if(_loc13_)
                                 {
                                    setupDraggedItem(_loc17_ as MovieClip);
                                    _draggedItem.stopDrag();
                                    _draggedItem.x = _loc13_.x;
                                    _draggedItem.y = _loc13_.y;
                                    this.addChild(_draggedItem);
                                    _draggedItem.visible = false;
                                    if(_pastedStickerInstances == null)
                                    {
                                       _pastedStickerInstances = new Vector.<MovieClip>();
                                    }
                                    _pastedStickerInstances.push(_draggedItem);
                                    _draggedItem = null;
                                 }
                              }
                              if(_loc17_.visible)
                              {
                                 _loc17_.gotoAndStop("color");
                              }
                           }
                        }
                        else
                        {
                           _loc17_.gotoAndStop("gray");
                           _loc17_.visible = false;
                        }
                     }
                     else if(_loc17_.name.indexOf("expandTxt") == 0)
                     {
                        _loc17_.addEventListener("rollOver",onExpandRollOverOut,false,0,true);
                        _loc17_.addEventListener("rollOut",onExpandRollOverOut,false,0,true);
                     }
                     else if(_loc17_.name.indexOf("quiz_gift") == 0)
                     {
                        _loc4_.quizGift = _loc17_;
                        _loc10_ = _loc17_.name.substr(10).split("_");
                        _loc4_.quizGift.userVarId = _loc10_.pop();
                        _loc4_.quizGift.id = _loc10_.join("_");
                        _loc4_.quizGift.type = "quiz";
                        if(gMainFrame.userInfo.userVarCache.isBitSet(_loc4_.quizGift.userVarId,2))
                        {
                           _loc4_.quizGift.enable(false);
                        }
                        else if(gMainFrame.userInfo.userVarCache.isBitSet(_loc4_.quizGift.userVarId,1))
                        {
                           _loc4_.quizGift.enable(false);
                           _loc4_.quizGift.addEventListener("mouseDown",onGiftDown,false,0,true);
                        }
                     }
                     else if(_loc17_.name.indexOf("quiz") == 0)
                     {
                        _loc17_.currPageNum = param2;
                        setupQuiz(_loc17_ as MovieClip);
                     }
                     else if(_loc17_.name.indexOf("tryAgainBtn") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",tryAgainBtn,false,0,true);
                        _loc17_.visible = false;
                     }
                     else if(_loc17_.name.indexOf("feedback") == 0)
                     {
                        _loc17_.addEventListener("mouseDown",onFeedbackBtn,false,0,true);
                     }
                     _loc7_++;
                  }
                  if(_loc9_.length > 0)
                  {
                     if(_loc4_.numJBItemsTotal == null)
                     {
                        _loc4_.numJBItemsTotal = [];
                        _loc4_.numJBItemsSeen = [];
                        _loc4_.numJBItemsLoaded = [];
                     }
                     _loc8_ = 0;
                     while(_loc8_ < _loc9_.length)
                     {
                        _loc4_.numJBItemsTotal.push(_loc9_[_loc8_].length);
                        _loc4_.numJBItemsSeen.push(0);
                        _loc4_.numJBItemsLoaded.push(0);
                        _loc8_++;
                     }
                     _loc8_ = 0;
                     while(_loc8_ < _loc9_.length)
                     {
                        _loc11_ = 0;
                        while(_loc11_ < _loc9_[_loc8_].length)
                        {
                           NGFactManager.requestJourneyBookFactDef(_loc9_[_loc8_][_loc11_],onJBFactDefReceived,param2,_loc8_);
                           _loc11_++;
                        }
                        _loc8_++;
                     }
                  }
                  else
                  {
                     _currPageVarsLoaded = true;
                  }
               }
               _loc6_++;
            }
         }
      }
      
      private function onPetBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         PetManager.openPetFinder(PetManager.petNameForDefId(param1.currentTarget.name.split("_")[1]),null,false,null,null,0,0,true);
      }
      
      private function onBadgeCont(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Number = NaN;
         param1.stopPropagation();
         if(param1.currentTarget.currentFrameLabel != "color")
         {
            param1.currentTarget.gotoAndPlay("play");
            _loc2_ = eBookUserVarIdForPageName(param1.currentTarget.badgePageName);
            _loc4_ = eBookNumStampsForUserVarId(_loc2_);
            _loc3_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc2_));
            if(_loc3_ != -1 && !gMainFrame.userInfo.userVarCache.isBitSet(_loc2_,param1.currentTarget.badgeId) && gMainFrame.userInfo.userVarCache.numBitsSet(_loc3_,_loc4_) + 1 == _loc4_)
            {
               GuiManager.setupGemGiftPopup(100);
            }
            AchievementXtCommManager.requestSetUserVar(_loc2_,param1.currentTarget.badgeId);
         }
      }
      
      private function onStickerInPage(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:String = null;
         var _loc8_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:Number = NaN;
         param1.stopPropagation();
         if(param1.currentTarget.currentFrameLabel != "color")
         {
            _loc2_ = param1.currentTarget.name.split("_");
            _loc2_[0] = "stickersToPaste";
            _loc3_ = _loc2_.join("_");
            if(_stickerInstances)
            {
               _loc8_ = _stickerInstances[_loc3_];
               if(_loc8_)
               {
                  if(_loc8_ is MovieClip)
                  {
                     _loc8_.visible = true;
                     _loc8_.gotoAndStop("color");
                  }
                  else if(_loc8_ is Array)
                  {
                     _loc5_ = 0;
                     while(_loc5_ < _loc8_.length)
                     {
                        _loc8_[_loc5_].visible = true;
                        _loc8_[_loc5_].gotoAndStop("color");
                        _loc5_++;
                     }
                  }
               }
            }
            param1.currentTarget.gotoAndPlay("play");
            _loc6_ = eBookUserVarIdForStickerName(param1.currentTarget.stickerPageName);
            _loc4_ = eBookNumStickersForUserVarId(_loc6_);
            _loc7_ = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc6_));
            AchievementXtCommManager.requestSetUserVar(_loc6_,param1.currentTarget.stickerId);
         }
      }
      
      private function setupDraggedItem(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = param1.name.split("_");
         var _loc2_:String = _loc5_[0] + "Library";
         _loc4_ = 1;
         while(_loc4_ < _loc5_.length)
         {
            _loc2_ += "_" + _loc5_[_loc4_];
            _loc4_++;
         }
         _draggedItem = new (param1.currLoaderAppDomain.getDefinition(_loc2_) as Class)();
         this.addEventListener("mouseUp",onStickerPasteMouseUp,false,0,true);
         _draggedItem.addEventListener("mouseDown",onPastedStickerDown,false,0,true);
         _draggedItem.scaleY = 0.5;
         _draggedItem.scaleX = 0.5;
         _draggedItem.startDrag(true,new Rectangle(-_pageWidth,-_pageHeight * 0.5,_pageWidth * 2 - _draggedItem.width,_pageHeight - _draggedItem.height));
         _draggedItem.stickerInPage = param1;
         var _loc3_:Object = _stickerInstances[param1.name];
         if(_loc3_ && _loc3_ is Array)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc3_[_loc4_].visible = false;
               _loc3_[_loc4_].gotoAndStop("gray");
               _loc4_++;
            }
         }
         else
         {
            param1.visible = false;
            param1.gotoAndStop("gray");
         }
      }
      
      private function onStickerPasteMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         setupDraggedItem(param1.currentTarget as MovieClip);
         this.addChild(_draggedItem);
      }
      
      private function onPastedStickerDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _draggedItem = param1.currentTarget as MovieClip;
         this.addChild(_draggedItem);
         this.addEventListener("mouseUp",onStickerPasteMouseUp,false,0,true);
         _draggedItem.startDrag(true,new Rectangle(-_pageWidth,-_pageHeight * 0.5,_pageWidth * 2 - _draggedItem.width,_pageHeight - _draggedItem.height));
      }
      
      private function onStickerPasteMouseUp(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc3_:SharedObject = null;
         var _loc5_:Object = null;
         param1.stopPropagation();
         if(_draggedItem)
         {
            _draggedItem.stopDrag();
            _loc3_ = GuiManager.sharedObj;
            if(_draggedItem.hitTestObject(_draggedItem.stickerInPage.stickerFrame))
            {
               if(_loc3_ && _loc3_.data && _loc3_.data.stickerPositions && _loc3_.data.stickerPositions[_draggedItem.stickerInPage.name])
               {
                  delete _loc3_.data.stickerPositions[_draggedItem.stickerInPage.name];
                  GuiManager.setSharedObj("stickerPositions",_loc3_.data.stickerPositions);
               }
               this.removeChild(_draggedItem);
               _draggedItem.stickerInPage.visible = true;
               _draggedItem.stickerInPage.gotoAndStop("color");
               _draggedItem.removeEventListener("mouseDown",onPastedStickerDown);
               if(_pastedStickerInstances)
               {
                  _loc4_ = int(_pastedStickerInstances.indexOf(_draggedItem));
                  if(_loc4_ != -1)
                  {
                     _pastedStickerInstances.splice(_loc4_,1);
                  }
               }
            }
            else
            {
               if(_pastedStickerInstances == null)
               {
                  _pastedStickerInstances = new Vector.<MovieClip>();
               }
               _loc4_ = int(_pastedStickerInstances.indexOf(_draggedItem));
               if(_loc4_ == -1)
               {
                  _pastedStickerInstances.push(_draggedItem);
               }
               if(_loc3_ && _loc3_.data && _loc3_.data.stickerPositions)
               {
                  _loc3_.data.stickerPositions[_draggedItem.stickerInPage.name] = new Point(_draggedItem.x,_draggedItem.y);
                  GuiManager.setSharedObj("stickerPositions",_loc3_.data.stickerPositions);
               }
               else
               {
                  _loc5_ = {};
                  _loc5_[_draggedItem.stickerInPage.name] = new Point(_draggedItem.x,_draggedItem.y);
                  GuiManager.setSharedObj("stickerPositions",_loc5_);
               }
            }
            _draggedItem = null;
         }
      }
      
      private function onExpandRollOverOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.type == "rollOut")
         {
            param1.currentTarget.gotoAndPlay("off");
         }
         else
         {
            param1.currentTarget.gotoAndPlay("on");
         }
      }
      
      private function onGameBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _gameLaunchObj = {"typeDefId":param1.currentTarget.name.split("_")[1]};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(_gameLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([_gameLaunchObj.typeDefId],false,onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(_gameLaunchObj,null,true);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_gameLaunchObj,null,true);
      }
      
      private function onMovieDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         var _loc5_:Array = [];
         _loc5_ = param1.currentTarget.name.split("_");
         var _loc3_:int = int(_loc5_[1]);
         var _loc6_:Boolean = _loc5_.length >= 3 ? _loc5_[2] == true : false;
         var _loc2_:String = _loc5_.length >= 4 ? _loc5_[3] : null;
         var _loc4_:int = int(_loc5_.length >= 5 ? _loc5_[4] : null);
         var _loc7_:int = int(_loc5_.length >= 6 ? _loc5_[5] : null);
         GenericListGuiManager.genericListVolumeClicked(_loc3_,{
            "shouldRepeat":_loc6_,
            "msg":_loc2_,
            "width":_loc4_,
            "height":_loc7_
         });
      }
      
      private function onSubmitDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name.indexOf("Quiz") >= 0)
            {
               _loc4_ = 0;
               while(_loc4_ < _quizPages.length)
               {
                  _loc2_ = _quizPages[_loc4_];
                  _loc5_ = 1;
                  while(_loc5_ <= _numQuizQuestions)
                  {
                     if("question_" + _loc5_ in _loc2_)
                     {
                        _loc6_ = _loc2_["question_" + _loc5_];
                        _loc7_ = 1;
                        while(_loc7_ <= 3)
                        {
                           if(_loc6_["answerBox" + _loc7_].checked)
                           {
                              if(_loc6_["answer" + _loc7_].isCorrect)
                              {
                                 _loc6_["answer" + _loc7_].correct.visible = true;
                                 _loc3_++;
                              }
                              else
                              {
                                 _loc6_["answer" + _loc7_].incorrect.visible = true;
                              }
                           }
                           _loc7_++;
                        }
                        _loc6_.mouseEnabled = false;
                        _loc6_.mouseChildren = false;
                     }
                     _loc5_++;
                  }
                  _loc4_++;
               }
               if(_loc3_ == _numQuizQuestions)
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdOnly(23731));
                  _loc2_ = MovieClip(_loadedPages[_quizPages[1].currPageNum].getChildAt(0));
                  if(!gMainFrame.userInfo.userVarCache.isBitSet(_loc2_.quizGift.userVarId,1))
                  {
                     AchievementXtCommManager.requestSetUserVar(_loc2_.quizGift.userVarId,1);
                     _loc2_.quizGift.enable(true);
                     _loc2_.quizGift.addEventListener("mouseDown",onGiftDown,false,0,true);
                  }
                  _quizPages[1].parent.submitBtnQuiz.activateGrayState(true);
               }
               else
               {
                  new SBOkPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(23732,_loc3_));
                  _quizPages[1].parent.tryAgainBtn.visible = true;
               }
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               FeedbackManager.openFeedbackPopup(4);
            }
         }
      }
      
      private function tryAgainBtn(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc5_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         param1.stopPropagation();
         _quizPages[1].parent.tryAgainBtn.visible = false;
         _loc3_ = 0;
         while(_loc3_ < _quizPages.length)
         {
            _loc2_ = _quizPages[_loc3_];
            _loc4_ = 1;
            while(_loc4_ <= _numQuizQuestions)
            {
               if("question_" + _loc4_ in _loc2_)
               {
                  _loc5_ = _loc2_["question_" + _loc4_];
                  _loc6_ = 1;
                  while(_loc6_ <= 3)
                  {
                     _loc5_["answerBox" + _loc6_].checked = false;
                     _loc5_["answer" + _loc6_].correct.visible = false;
                     _loc5_["answer" + _loc6_].incorrect.visible = false;
                     _loc6_++;
                  }
                  _loc5_.mouseEnabled = true;
                  _loc5_.mouseChildren = true;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _numQuizAnswersChecked = 0;
         _quizPages[1].parent.submitBtnQuiz.activateGrayState(false);
      }
      
      private function onFeedbackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FeedbackManager.openFeedbackPopup(param1.currentTarget.name.split("_")[1]);
      }
      
      private function onTurnToBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(param1.currentTarget.name.split("_")[1]);
         _vertDir = 1;
         turnTo(_currentPage + _loc2_ * 2,Boolean(_loc2_ % 2));
      }
      
      private function onLinkToBtn(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = null;
         param1.stopPropagation();
         var _loc4_:Array = param1.currentTarget.name.split("_");
         var _loc5_:String = _loc4_[1];
         var _loc3_:String = "";
         if(_loc5_ == "blog")
         {
            if(_loc4_.length > 2)
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/" + _loc4_[2].split("$").join("-");
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_POR)
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/pt";
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_SPA)
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/es";
            }
            else if(LocalizationManager.currentLanguage == LocalizationManager.LANG_FRE)
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/fr";
            }
            else
            {
               _loc3_ = "http://dailyexplorer.animaljam.com/";
            }
         }
         else if(_loc5_ == "outfitters")
         {
            _loc3_ = "http://shop.animaljam.com/";
            if(_loc4_[2])
            {
               _loc3_ += _loc4_[2].split("$").join("/");
            }
         }
         else if(_loc5_ == "jump")
         {
            _loc3_ = "http://jump.animaljam.com/";
         }
         else if(_loc5_ == "academy")
         {
            _loc3_ = "http://academy.animaljam.com/";
         }
         else if(_loc5_ == "blogCat")
         {
            _loc3_ = "http://dailyexplorer.animaljam.com/?cat=" + _loc4_[2];
         }
         if(_loc3_ != "")
         {
            _loc2_ = new URLRequest(_loc3_);
            try
            {
               navigateToURL(_loc2_,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
         else
         {
            DebugUtility.debugTrace("Request string is == \'\' and currName = " + _loc5_);
         }
      }
      
      private function onJoinRoomBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Array = param1.currentTarget.name.replace("joinRoom_","").split("$")[0].split("_");
         new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14775,LocalizationManager.translateIdOnly(_loc2_[0])),true,onConfirmJoinRoom,param1.currentTarget.name);
      }
      
      private function onConfirmJoinRoom(param1:Object) : void
      {
         var _loc3_:Array = null;
         var _loc4_:String = null;
         var _loc2_:Array = null;
         if(param1.status)
         {
            _loc3_ = param1.passback.split("$");
            _loc3_.shift();
            _loc4_ = _loc3_.join("$");
            _loc4_ = _loc4_.replace("$",".");
            _loc2_ = _loc4_.split("$");
            _loc4_ = _loc2_[0];
            _loc4_ = _loc4_.toLowerCase() + "#" + RoomManagerWorld.instance.shardId;
            if(_loc4_ != gMainFrame.server.getCurrentRoomName())
            {
               if(_loc2_.length == 2)
               {
                  RoomManagerWorld.instance.setGotoSpawnPoint(_loc2_[1].toLowerCase());
               }
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager.sendRoomJoinRequest(_loc4_);
            }
         }
      }
      
      private function onJoinPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.name.split("_")[1]);
         new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdAndInsertOnly(14776,LocalizationManager.translateIdOnly(PartyManager.getPartyDef(_loc2_).titleStrId)),true,onConfirmJoinParty,_loc2_);
      }
      
      private function onConfirmJoinParty(param1:Object) : void
      {
         if(param1.status)
         {
            gMainFrame.server.setXtObject_Str("sj",[param1.passback]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onImgPoll(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Array = param1.currentTarget.name.split("_");
         ImagePoll.displayPoll(_loc2_[1],_loc2_[2],2926,0,3,1);
      }
      
      private function onLoadPopup(param1:MouseEvent) : void
      {
         var _loc2_:MediaHelper = null;
         param1.stopPropagation();
         var _loc3_:Array = param1.currentTarget.name.split("_");
         if(isNaN(_loc3_[1]))
         {
            GuiManager[_loc3_[1]]();
         }
         else if(!_genericPopup)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = new MediaHelper();
            _loc2_.init(_loc3_[1],onPopupLoaded);
         }
         else
         {
            _popupLayer.addChild(_genericPopup);
            DarkenManager.darken(_genericPopup);
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _genericPopup = MovieClip(param1.getChildAt(0));
            _genericPopup.addEventListener("mouseDown",mouseDownHandler,false,0,true);
            _genericPopup.bx.addEventListener("mouseDown",onPopupClose,false,0,true);
            _popupLayer.addChild(_genericPopup);
            _genericPopup.x = 900 * 0.5;
            _genericPopup.y = 550 * 0.5;
            DarkenManager.darken(_genericPopup);
         }
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _popupLayer.removeChild(_genericPopup);
         DarkenManager.unDarken(_genericPopup);
      }
      
      private function onJBItemDown(param1:MouseEvent) : void
      {
         NGFactManager.showJourneyBookFact(param1.currentTarget.jbId);
      }
      
      private function onJBItemOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.itemName != "")
         {
            GuiManager.toolTip.init(_popupLayer,param1.currentTarget.itemName,param1.currentTarget.x + 900 * 0.5,param1.currentTarget.y + 550 * 0.5);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onJBItemOut(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onGiftDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:DenItemDef = null;
         var _loc4_:Object = null;
         _currGiftItem = MovieClip(param1.currentTarget);
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         if(param1.currentTarget.id.indexOf("d") == 0)
         {
            _loc2_ = DenXtCommManager.getDenItemDef(param1.currentTarget.id.substr(2));
            _loc3_ = 2;
            _giftPopup = new GiftPopup();
            _giftPopup.init(_popupLayer,param1.currentTarget.getImage(),_loc2_.name,param1.currentTarget.id.substr(2),2,_loc3_,onKeepGift,onRejectGift,onCloseGift);
         }
         else
         {
            _loc4_ = ItemXtCommManager.getItemDef(param1.currentTarget.id.substr(2));
            _loc3_ = 1;
            _giftPopup = new GiftPopup();
            _giftPopup.init(_popupLayer,param1.currentTarget.getImage(),_loc4_.name,param1.currentTarget.id.substr(2),2,_loc3_,onKeepGift,onRejectGift,onCloseGift);
         }
      }
      
      private function onKeepGift() : void
      {
         DarkenManager.showLoadingSpiral(true);
         var _loc1_:MovieClip = MovieClip(_loadedPages[Math.round(_currentPage)].getChildAt(0));
         if(_loc1_.JBGift)
         {
            AchievementXtCommManager.requestSetUserVar(jbUserVarIdForPageName(_pageNameArray[Math.round(_currentPage)],_currGiftItem.sequence),31,onSetUserVarResponse);
         }
         else if(_loc1_.quizGift)
         {
            AchievementXtCommManager.requestSetUserVar(_loc1_.quizGift.userVarId,2,onSetUserVarResponse);
         }
      }
      
      private function onRejectGift() : void
      {
         DarkenManager.showLoadingSpiral(true);
         var _loc1_:MovieClip = MovieClip(_loadedPages[Math.round(_currentPage)].getChildAt(0));
         if(_loc1_.JBGift)
         {
            AchievementXtCommManager.requestSetUserVar(jbUserVarIdForPageName(_pageNameArray[Math.round(_currentPage)],_currGiftItem.sequence),30,onSetUserVarResponse);
         }
         else if(_loc1_.quizGift)
         {
            AchievementXtCommManager.requestSetUserVar(_loc1_.quizGift.userVarId,1,onSetUserVarResponse);
         }
      }
      
      private function onCloseGift() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
      }
      
      private function onSetUserVarResponse(param1:int, param2:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:int = fixPageNum(_currentPage) + 0.5;
         var _loc4_:MovieClip = MovieClip(_loadedPages[_loc3_].getChildAt(0));
         if(_loc4_.quizGift)
         {
            _loc4_.quizGift.enable(false);
            _loc4_.quizGift.removeEventListener("mouseDown",onGiftDown);
         }
         else if(_loc4_.JBGift[_currGiftItem.sequence])
         {
            _loc4_.JBGift[_currGiftItem.sequence].enable(false);
            _loc4_.JBGift[_currGiftItem.sequence].removeEventListener("mouseDown",onGiftDown);
            JBManager.numUnclaimedGifts--;
            GuiManager.updateJBIcon(true);
         }
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _currGiftItem = null;
      }
      
      private function onJBFactDefReceived(param1:Object, param2:int, param3:int) : void
      {
         var _loc4_:MovieClip = null;
         var _loc6_:String = null;
         var _loc5_:MovieClip = null;
         if(_pageFlipBase)
         {
            _loc4_ = MovieClip(_loadedPages[param2].getChildAt(0));
            _loc6_ = "jb_" + param1.id;
            if(param3 > 0)
            {
               _loc6_ += "_" + param3;
            }
            _loc5_ = _loc4_[_loc6_];
            if(!_loc5_)
            {
               _loc4_.numJBItemsLoaded[param3] = _loc4_.numJBItemsTotal[param3];
               _currPageVarsLoaded = true;
               showButtons();
               return;
            }
            _loc4_.numJBItemsLoaded[param3]++;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,29) && _loc4_.numJBItemsLoaded[param3] == 1)
            {
               JBManager.removeUnseenPage(param1.userVarId);
               AchievementXtCommManager.requestSetUserVar(param1.userVarId,29);
            }
            if(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx))
            {
               _loc4_.numJBItemsSeen[param3]++;
               _loc5_.enable();
               _loc5_.itemName = new String(LocalizationManager.translateIdOnly(param1.title));
               GuiManager.toolTip.resetTimerAndSetVisibility();
               _loc5_.addEventListener("mouseDown",onJBItemDown,false,0,true);
               _loc5_.addEventListener("mouseOver",onJBItemOver,false,0,true);
               _loc5_.addEventListener("mouseOut",onJBItemOut,false,0,true);
               if(_loc4_.numJBItemsSeen[param3] == _loc4_.numJBItemsTotal[param3] && _loc4_.JBGift[param3])
               {
                  if(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,31) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,30)))
                  {
                     _loc4_.JBGift[param3].enable(false);
                  }
                  else
                  {
                     _loc4_.JBGift[param3].enable(true);
                     _loc4_.JBGift[param3].addEventListener("mouseDown",onGiftDown,false,0,true);
                  }
               }
            }
            if(_loc4_.numJBItemsLoaded[param3] == _loc4_.numJBItemsTotal[param3])
            {
               _currPageVarsLoaded = true;
               if(_currPageLoaded && _flipInProgress == 0)
               {
                  flipComplete();
               }
               else if(_flipInProgress == 0 && _pageFlipComplete == false)
               {
                  if(Math.round(_currentPage) == param2)
                  {
                     _flipCallback(_pageNameArray[param2]);
                  }
               }
            }
         }
      }
      
      private function setupQuiz(param1:MovieClip) : void
      {
         var _loc2_:Array = param1.name.split("_");
         if(_loc2_.length > 1 && !isNaN(_loc2_[1]))
         {
            if(_quizPages == null)
            {
               _quizPages = [];
            }
            _quizPages.push(param1);
            if(_quizPages.length == 2)
            {
               GenericListXtCommManager.requestGenericList(_loc2_[1],onQuizLocStrLoaded,null);
            }
         }
      }
      
      private function onQuizLocStrLoaded(param1:int, param2:Array) : void
      {
         var _loc6_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc11_:Array = null;
         var _loc10_:MovieClip = null;
         var _loc9_:MovieClip = null;
         var _loc13_:* = false;
         var _loc4_:int = 0;
         var _loc7_:Array = null;
         var _loc5_:int = 0;
         _numQuizQuestions = 0;
         _quizPages.sortOn("currPageNum",16);
         var _loc3_:MovieClip = MovieClip(_loadedPages[_quizPages[1].currPageNum].getChildAt(0));
         var _loc12_:Boolean = Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_loc3_.quizGift.userVarId,1));
         _loc6_ = 0;
         while(_loc6_ < _quizPages.length)
         {
            _loc8_ = _quizPages[_loc6_];
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               if("question_" + (_loc4_ + 1) in _loc8_)
               {
                  _loc11_ = LocalizationManager.translateIdOnly(param2[_loc4_]).split("|");
                  _loc10_ = _loc8_["question_" + (_loc4_ + 1)];
                  LocalizationManager.updateToFit(_loc10_.questionTxt,_loc11_.shift());
                  _loc7_ = [0,1,2];
                  Utility.shuffleArray(_loc11_,_loc7_);
                  _loc5_ = 0;
                  while(_loc5_ < _loc7_.length)
                  {
                     _loc13_ = _loc7_[_loc5_] == 0;
                     _loc9_ = _loc10_["answer" + (_loc5_ + 1)];
                     LocalizationManager.updateToFit(_loc9_.txt,_loc11_[_loc7_[_loc5_]]);
                     _loc10_["answerBox" + (_loc5_ + 1)] = new GuiCheckBox(_loc9_.answer_box,onQuizCheckBoxChecked);
                     _loc10_["answerBox" + (_loc5_ + 1)].init(_loc9_.txt);
                     _loc10_["answerBox" + (_loc5_ + 1)].checked = _loc13_ && _loc12_ ? true : false;
                     _loc9_.incorrect.visible = false;
                     _loc9_.correct.visible = _loc13_ && _loc12_ ? true : false;
                     _loc9_.isCorrect = _loc13_ ? true : false;
                     _loc5_++;
                  }
                  if(_loc12_)
                  {
                     _loc10_.mouseEnabled = false;
                     _loc10_.mouseChildren = false;
                  }
                  _numQuizQuestions++;
               }
               _loc4_++;
            }
            _loc6_++;
         }
         _numQuizAnswersChecked = 0;
      }
      
      private function onQuizCheckBoxChecked(param1:GuiCheckBox) : void
      {
         var _loc4_:GuiCheckBox = null;
         var _loc3_:int = 0;
         var _loc2_:MovieClip = param1.currCheckBox.parent.parent as MovieClip;
         _loc3_ = 1;
         while(_loc3_ < 4)
         {
            _loc4_ = _loc2_["answerBox" + _loc3_] as GuiCheckBox;
            if(_loc4_ != param1)
            {
               if(_loc4_.checked)
               {
                  _numQuizAnswersChecked--;
               }
               _loc4_.checked = false;
            }
            else if(param1.checked)
            {
               _numQuizAnswersChecked++;
            }
            else
            {
               _numQuizAnswersChecked--;
            }
            _loc3_++;
         }
         if(_numQuizAnswersChecked == _numQuizQuestions)
         {
            _quizPages[1].parent.submitBtnQuiz.activateGrayState(false);
         }
         else
         {
            _quizPages[1].parent.submitBtnQuiz.activateGrayState(true);
         }
      }
      
      private function onImageDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function removeIfChildAdded(param1:DisplayObjectContainer, param2:DisplayObject) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < param1.numChildren)
         {
            if(param1.getChildAt(_loc3_) == param2)
            {
               param1.removeChildAt(_loc3_);
               return;
            }
            _loc3_++;
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_zoomedIn)
         {
            if(_eBook)
            {
               _eBook.startDrag(false,_fullPageBounds);
            }
            else
            {
               this.startDrag(false,_fullPageBounds);
            }
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_zoomedIn)
         {
            this.stopDrag();
         }
      }
      
      private function removeMovieClip(param1:DisplayObject) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
         }
      }
      
      private function makeMasks() : void
      {
         removeIfChildAdded(_pageFlipBase,_flippingBottomPageMask);
         _flippingBottomPageMask = new Sprite();
         _flippingBottomPageMask.mouseChildren = false;
         _flippingBottomPageMask.mouseEnabled = false;
         _flippingBottomPageMask.cacheAsBitmap = true;
         _flippingBottomPageMask.graphics.beginFill(21760,1);
         _flippingBottomPageMask.graphics.lineTo(_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
         _flippingBottomPageMask.graphics.curveTo(0,-_vertDir * 2 * _pageWidthAndHeight,-_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
         _flippingBottomPageMask.graphics.lineTo(0,0);
         _flippingBottomPageMask.graphics.endFill();
         _pageFlipBase.addChild(_flippingBottomPageMask);
         removeIfChildAdded(_pageFlipBase,_flippingTopPageMask);
         _flippingTopPageMask = new Sprite();
         _flippingTopPageMask.mouseChildren = false;
         _flippingTopPageMask.mouseEnabled = false;
         _flippingTopPageMask.cacheAsBitmap = true;
         _flippingTopPageMask.graphics.beginFill(21760,1);
         _flippingTopPageMask.graphics.lineTo(_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
         _flippingTopPageMask.graphics.curveTo(0,-_vertDir * 2 * _pageWidthAndHeight,-_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
         _flippingTopPageMask.graphics.lineTo(0,0);
         _flippingTopPageMask.graphics.endFill();
         _pageFlipBase.addChild(_flippingTopPageMask);
         removeIfChildAdded(_pageFlipBase,_flippingPageShadowMask);
         _flippingPageShadowMask = new MovieClip();
         drawPage(_flippingPageShadowMask,-_flipDirection,_vertDir);
         _flippingPageShadowMask.rotation = _vertDir * _flipDirection * 90;
         _pageFlipBase.addChild(_flippingPageShadowMask);
         _flippingPageShadowMask.mouseChildren = false;
         _flippingPageShadowMask.mouseEnabled = false;
         removeIfChildAdded(_pageFlipBase,_shadowStationaryMask);
         _shadowStationaryMask = new MovieClip();
         drawPage(_shadowStationaryMask,_flipDirection,_vertDir);
         _pageFlipBase.addChild(_shadowStationaryMask);
         _shadowStationaryMask.mouseChildren = false;
         _shadowStationaryMask.mouseEnabled = false;
         _flippingBottomPage.mask = _flippingBottomPageMask;
         _flippingTopPage.mask = _flippingTopPageMask;
         _flippingShadow.mask = _flippingPageShadowMask;
         _shadowsShadow.mask = _shadowStationaryMask;
      }
      
      private function range0to1(param1:Number) : Number
      {
         return param1 > 1 ? 1 : (param1 < 0 ? 0 : param1);
      }
      
      private function makeShade(param1:Sprite, param2:Number, param3:Number) : void
      {
         var _loc8_:Array = [0,0,0,0,0,0,0];
         var _loc5_:Array = [0.6,0.4,0.2,0,0,0,0];
         var _loc7_:Array = [0,1,17,51,89,132,255];
         var _loc4_:Matrix = new Matrix();
         _loc4_.createGradientBox(param2 * _pageWidth,-param3 * _pageHeight,0,0,-param3 * _pageWidth);
         var _loc6_:Graphics = param1.graphics;
         _loc6_.beginGradientFill("linear",_loc8_,_loc5_,_loc7_,_loc4_);
         _loc6_.moveTo(0,-_pageWidth * param3);
         _loc6_.lineTo(0,-_pageWidthAndHeight * param3);
         _loc6_.lineTo(param2 * _pageWidth,-_pageWidthAndHeight * param3);
         _loc6_.lineTo(param2 * _pageWidth,-_pageWidth * param3);
         _loc6_.lineTo(0,-_pageWidth * param3);
         _loc6_.endFill();
      }
      
      private function makeShadow(param1:Sprite, param2:Number) : void
      {
         var _loc4_:Array = null;
         var _loc6_:Array = null;
         var _loc7_:Array = null;
         var _loc9_:Number = NaN;
         var _loc8_:Number = Math.sqrt(_pageWidth * _pageWidth + _pageWidthAndHeight * _pageWidthAndHeight);
         var _loc3_:Matrix = new Matrix();
         _loc7_ = [0,0,0,0,0,0,0];
         _loc4_ = [0.6,0.4,0.2,0,0,0,0];
         _loc6_ = [0,1,17,51,89,132,255];
         _loc3_.createGradientBox(param2 * _pageWidth,_vertDir * (_loc8_ - _pageWidth),0,0,0);
         var _loc5_:Graphics = param1.graphics;
         _loc5_.beginGradientFill("linear",_loc7_,_loc4_,_loc6_,_loc3_);
         _loc5_.moveTo(0,-_vertDir * _pageWidth);
         _loc5_.lineTo(0,-_vertDir * _loc8_);
         _loc5_.lineTo(param2 * _pageWidth,-_vertDir * _loc8_);
         _loc5_.lineTo(param2 * _pageWidth,-_vertDir * _pageWidth);
         _loc5_.lineTo(0,-_vertDir * _pageWidth);
         _loc5_.endFill();
      }
      
      private function getPageRatio() : Number
      {
         if(_ShouldBeDragging)
         {
            if(_isSinglePF)
            {
               _pageRatio = -_flipDirection * (mouseX - _startX - _flipDirection * _cornerBtnPositions) / ((_isJourneyBook ? 2 : 10) * _pageWidth);
            }
            else
            {
               _pageRatio = -_flipDirection * (mouseX - _startX - _flipDirection * _cornerBtnPositions) / (2 * _pageWidth);
            }
         }
         else
         {
            _pageRatio > 0.6666666666666666 ? (_pageRatio = _pageRatio + _autoStepSpeed) : (_pageRatio = _pageRatio - _autoStepSpeed);
         }
         return range0to1(_pageRatio);
      }
      
      private function startFlip(param1:Number, param2:Number, param3:int) : void
      {
         var _loc4_:int = 0;
         _flipInProgress = 1;
         param2 == 1 ? (_isSinglePF ? (_numberOfFlips = _numberOfFlips + param3) : (int(_numberOfFlips = _numberOfFlips + param3 * 2))) : (int(_isSinglePF ? (_numberOfFlips = _numberOfFlips - param3) : (int(_numberOfFlips = _numberOfFlips - param3 * 2))));
         _numberOfFlips = Math.min(_numberOfPages,_numberOfFlips);
         _pageFlipComplete = false;
         if(_eBook)
         {
            if(_pageNumForStickers == _currentPage)
            {
               if(_pastedStickerInstances)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _pastedStickerInstances.length)
                  {
                     _pastedStickerInstances[_loc4_].visible = false;
                     _loc4_++;
                  }
               }
            }
         }
         if(!_loadedPageNumber[_numberOfFlips - _pageFlipIncrement])
         {
            initPage(param1,param2,_vertDir);
            if(_isJourneyBook)
            {
               _currPageVarsLoaded = false;
            }
            _currPageLoaded = false;
            loadPages(_numberOfFlips);
         }
         else
         {
            initPage(param1,param2,_vertDir);
            _currentPage = param1;
         }
         _startX = param2 * _pageWidth;
         if(_showCornerBtns)
         {
            _rightBottomBtn.visible = _leftBottomBtn.visible = false;
         }
         _pageOffset = 0;
         renderPageFlip(_pageFlipPercent);
         _pageFlipBase.addEventListener("enterFrame",onEnterFrame);
         if(_playFlipSound)
         {
            AJAudio.playNewspaperSound();
         }
      }
      
      private function setupButtonsPositions() : void
      {
         var _loc2_:Number = -_vertDir * (_pageWidth + _pageHeight * 0.5);
         var _loc1_:Number = _pageHeight / 2;
         if(_showCornerBtns && _buttonsLoaded == _numButtonsToLoad)
         {
            _rightBottomBtn.y = _leftBottomBtn.y = _loc2_ + _loc1_;
            _xBtn.y = _loc2_ - _loc1_;
            if(_enableDragging)
            {
               if(_isSinglePF)
               {
                  _rightBottomBtn.x = _pageWidth - _rightBottomBtn.width;
                  _xBtn.x = _pageWidth - _xBtn.width;
               }
               else
               {
                  _rightBottomBtn.x = _pageWidth - _rightBottomBtn.width;
                  _xBtn.x = _pageWidth - _xBtn.width;
                  _leftBottomBtn.x = -_pageWidth + _leftBottomBtn.width;
               }
            }
            bringButtonsToFront();
         }
      }
      
      private function flipAuto(param1:Number) : void
      {
         _step = (param1 - _pageFlipPercent) * _dragSmoothness;
         _pageFlipPercent += _step;
         renderPageFlip(_pageFlipPercent);
         if(_pageFlipPercent > 1 - _snapDistance)
         {
            renderPageFlip(1);
            if(_currPageLoaded)
            {
               flipComplete();
            }
            if(_bFlipAuto)
            {
               if(_currentPage < _autoFlipTargetPage)
               {
                  startFlip(_currentPage + _directionAfterFlip * 2,_directionAfterFlip,0);
               }
               else
               {
                  _bFlipAuto = false;
               }
            }
         }
      }
      
      public function turnTo(param1:Number, param2:Boolean = true) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(this.hasEventListener("mouseUp"))
         {
            this.removeEventListener("mouseUp",onStickerPasteMouseUp);
         }
         if(_draggedItem)
         {
            if(_draggedItem.parent && _draggedItem.parent == this)
            {
               this.removeChild(_draggedItem);
            }
            _draggedItem.stickerInPage.visible = true;
            _draggedItem.stickerInPage.gotoAndStop("color");
            _draggedItem.stopDrag();
            _draggedItem = null;
         }
         if(param2)
         {
            _pageNumber = fixPageNum(param1);
         }
         else
         {
            _pageNumber = param1;
         }
         if(_pageNumber != _currentPage)
         {
            if(_flipInProgress == 0)
            {
               _loc4_ = Math.round((_pageNumber - _currentPage) * 0.5);
               _loc3_ = _pageNumber > _currentPage ? 1 : -1;
               _pageTurnedTo += _loc4_;
               startFlip(_pageNumber,_loc3_,Math.abs(_loc4_));
            }
         }
      }
      
      private function fixPageNum(param1:Number) : Number
      {
         var _loc2_:int = param1 % 2;
         if(_loc2_ == 0)
         {
            return param1 + 0.5;
         }
         if(_loc2_ == 1)
         {
            return param1 - 0.5;
         }
         return param1;
      }
      
      private function turnBack() : void
      {
         if(_currentPage > 0.5)
         {
            turnTo(_currentPage - 2);
         }
      }
      
      private function turnAhead() : void
      {
         if(_currentPage < _numberOfPages)
         {
            turnTo(_currentPage + 2);
         }
      }
      
      public function flipTo(param1:Number) : void
      {
         param1 = fixPageNum(param1);
         if(param1 > _currentPage)
         {
            _directionAfterFlip = 1;
         }
         else
         {
            if(param1 >= _currentPage)
            {
               return;
            }
            _directionAfterFlip = -1;
         }
         _bFlipAuto = true;
         _autoFlipTargetPage = param1;
         startFlip(_currentPage + _directionAfterFlip * 2,_directionAfterFlip,0);
      }
      
      private function drawPage(param1:MovieClip, param2:Number, param3:Number) : void
      {
         param1.graphics.beginFill(_pageColor,0);
         param1.graphics.moveTo(0,-param3 * _pageWidth);
         param1.graphics.lineTo(0,-param3 * _pageWidth);
         param1.graphics.lineTo(0,-param3 * _pageWidthAndHeight);
         param1.graphics.lineTo(param2 * _pageWidth,-param3 * _pageWidthAndHeight);
         param1.graphics.lineTo(param2 * _pageWidth,-param3 * _pageWidth);
         param1.graphics.endFill();
         param1.cacheAsBitmap = true;
      }
      
      private function renderPageFlip(param1:Number) : void
      {
         var _loc2_:Number = _vertDir * _flipDirection * 45 * param1;
         _flippingBottomPageMask.rotation = _flippingTopPageMask.rotation = -_loc2_;
         _flippingBottomPage.rotation = _flippingPageShadowMask.rotation = _vertDir * (_flipDirection * 90) - _loc2_ * 2;
         _flippingShadow.rotation = _shadowsShadow.rotation = _vertDir * (_flipDirection * 45) - _loc2_;
      }
      
      private function showButtons() : void
      {
         if(_flipInProgress == 0)
         {
            if(_enableDragging)
            {
               setupButtonsPositions();
            }
            if(_showCornerBtns && _currPageLoaded && _currPageVarsLoaded && _buttonsLoaded == _numButtonsToLoad)
            {
               if(_stationaryLeftPage)
               {
                  _stationaryLeftPage.visible = true;
               }
               _rightBottomBtn.alpha = _leftBottomBtn.alpha = _xBtn.alpha = 1;
               if(_isSinglePF && _currentPage != 0.5 || !_isSinglePF && _currentPage != 2.5)
               {
                  _leftBottomBtn.visible = true;
               }
               else
               {
                  _leftBottomBtn.visible = false;
               }
               if(_currentPage != _numberOfPages)
               {
                  if(_pageTurnedTo * 2 <= _numberOfPages + 0.5)
                  {
                     _rightBottomBtn.visible = true;
                  }
                  else
                  {
                     _rightBottomBtn.visible = false;
                  }
                  if(!_eBook && !_membershipBook)
                  {
                     _xBtn.visible = true;
                  }
               }
               else
               {
                  _rightBottomBtn.visible = false;
               }
            }
         }
      }
      
      private function flipComplete(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         _pageFlipBase.removeEventListener("enterFrame",onEnterFrame);
         _pageFlipPercent = 0;
         _flipInProgress = 0;
         _pageFlipComplete = true;
         if(_eBook)
         {
            if(_pageNumForStickers == _pageNumber)
            {
               if(_pastedStickerInstances)
               {
                  _loc2_ = 0;
                  while(_loc2_ < _pastedStickerInstances.length)
                  {
                     _pastedStickerInstances[_loc2_].visible = true;
                     _loc2_++;
                  }
               }
            }
         }
         if(_bookType == 2 && (_membershipBook.titleBannerCont.currentFrameLabel != "playOn" && _membershipBook.titleBannerCont.currentFrameLabel != "on"))
         {
            _membershipBook.titleBannerCont.gotoAndPlay("playOn");
         }
         if(_showCornerBtns && _currPageLoaded && _currPageVarsLoaded && _buttonsLoaded == _numButtonsToLoad)
         {
            if(_flipCallback != null && _pageOffset != 0)
            {
               if(_isJourneyBook)
               {
                  _flipCallback(_pageNameArray[Math.round(_currentPage)]);
               }
               else
               {
                  _flipCallback(_pageTurnedTo);
               }
            }
         }
         if(param1)
         {
            _setPagesOnly = false;
            setStationary();
            initPage(_currentPage + _flipDirection * 2,_flipDirection,_vertDir);
         }
      }
      
      private function createShadow() : void
      {
         removeIfChildAdded(_pageFlipBase,_flippingShadow);
         _flippingShadow = new Sprite();
         _flippingShadow.mouseChildren = false;
         _flippingShadow.mouseEnabled = false;
         makeShadow(_flippingShadow,-_flipDirection);
         _flippingShadow.rotation = _vertDir * _flipDirection * 45;
         _pageFlipBase.addChild(_flippingShadow);
         removeIfChildAdded(_pageFlipBase,_shadowsShadow);
         _shadowsShadow = new Sprite();
         _shadowsShadow.mouseChildren = false;
         _shadowsShadow.mouseEnabled = false;
         makeShadow(_shadowsShadow,_isSinglePF && !_isJourneyBook ? 1 : _flipDirection);
         _shadowsShadow.rotation = _vertDir * _flipDirection * 45;
         _pageFlipBase.addChild(_shadowsShadow);
      }
      
      private function LB() : void
      {
         if(_currentPage != 0.5)
         {
            if(!_isSinglePF || _isJourneyBook)
            {
               _stationaryLeftPage.visible = true;
            }
         }
         else if(_currentPage == _numberOfPages + 0.5)
         {
            _stationaryRightPage.visible = false;
         }
         if(_pageNumber == 0.5 && !_isJourneyBook)
         {
            _shadowsShadow.visible = false;
         }
      }
      
      private function setFlipping() : void
      {
         var _loc3_:Sprite = null;
         removeIfChildAdded(_pageFlipBase,_flippingTopPage);
         _flippingTopPage = new MovieClip();
         var _loc5_:MovieClip = new MovieClip();
         var _loc2_:int = _flipDirection == 1 ? _currentPage + 0.5 : _currentPage - 0.5;
         if(_loc2_ <= _numberOfPages + 0.5)
         {
            if(_loc2_ >= _numberOfPages)
            {
               drawPage(_loc5_,_flipDirection,_vertDir);
               _flippingTopPage.addChild(_loc5_);
               if(_isJourneyBook && _flipDirection < 0)
               {
                  _blankPageLast.scaleX = -1;
               }
               else
               {
                  _blankPageLast.scaleX = 1;
               }
               _blankPageLast.x = _flipDirection * _pageWidth * 0.5;
               _blankPageLast.y = -_vertDir * _pivotY;
               _flippingTopPage.addChild(_blankPageLast);
            }
            else
            {
               drawPage(_loc5_,_flipDirection,_vertDir);
               _flippingTopPage.addChild(_loc5_);
               if(_isJourneyBook && _flipDirection < 0)
               {
                  _blankPage3.scaleX = -1;
               }
               else
               {
                  _blankPage3.scaleX = 1;
               }
               _blankPage3.x = _flipDirection * _pageWidth * 0.5;
               _blankPage3.y = -_vertDir * _pivotY;
               _flippingTopPage.addChild(_blankPage3);
            }
            if(_isSinglePF && !_isJourneyBook)
            {
               if(_flipInProgress == 1)
               {
                  if(_flipDirection < 0)
                  {
                     _flippingTopPage.alpha = 0;
                     _topPageTween = new TweenLite(_flippingTopPage,0.7,{
                        "alpha":1,
                        "ease":Quad.easeIn
                     });
                  }
                  else
                  {
                     _topPageTween = new TweenLite(_flippingTopPage,0.7,{
                        "alpha":0,
                        "ease":Quad.easeIn
                     });
                  }
               }
            }
            if(_loadedPages[_loc2_] != null)
            {
               _print = new Sprite();
               _print = _loadedPages[_loc2_];
               _print.x = _flipDirection * _pageWidth * 0.5;
               _print.y = -_vertDir * _pivotY;
               _flippingTopPage.addChild(_print);
            }
            else
            {
               _spiralTopFlippingPage.setNewParent(_flippingTopPage,_flipDirection * _pageWidth * 0.5,-_vertDir * _pivotY);
            }
            if(_flipDirection != -1 || (!_isSinglePF || _isJourneyBook))
            {
               _loc3_ = new MovieClip();
               _loc3_.mouseChildren = false;
               _loc3_.mouseEnabled = false;
               makeShade(_loc3_,_flipDirection,_vertDir);
               _flippingTopPage.addChild(_loc3_);
               _pageFlipBase.addChild(_flippingTopPage);
            }
         }
         removeIfChildAdded(_pageFlipBase,_flippingBottomPage);
         _flippingBottomPage = new MovieClip();
         var _loc4_:MovieClip = new MovieClip();
         drawPage(_loc4_,-_flipDirection,_vertDir);
         _flippingBottomPage.addChild(_loc4_);
         if(_isJourneyBook && _flipInProgress == 1)
         {
            if(_flipDirection > 0)
            {
               _blankPage4.scaleX = -1;
            }
            else
            {
               _blankPage4.scaleX = 1;
            }
         }
         _blankPage4.x = -_flipDirection * _pageWidth * 0.5;
         _blankPage4.y = -_vertDir * _pivotY;
         _flippingBottomPage.addChild(_blankPage4);
         if(_isSinglePF && !_isJourneyBook)
         {
            if(_flipInProgress == 1)
            {
               if(_flipDirection < 0)
               {
                  _flippingBottomPage.alpha = 0;
                  _bottomPageTween = new TweenLite(_flippingBottomPage,0.7,{
                     "alpha":1,
                     "ease":Quad.easeIn
                  });
               }
               else
               {
                  _bottomPageTween = new TweenLite(_flippingBottomPage,0.7,{
                     "alpha":0,
                     "ease":Quad.easeIn
                  });
               }
            }
         }
         var _loc1_:Sprite = new MovieClip();
         if(_isSinglePF)
         {
            if(_flipDirection != 1 || _isJourneyBook)
            {
               _loc2_ = _flipDirection == 1 ? _pageNumber - 0.5 : _pageNumber + 0.5;
               if(_loadedPages[_loc2_] != null)
               {
                  _loc1_ = _loadedPages[_loc2_];
                  _loc1_.x = -_flipDirection * _pageWidth * 0.5;
                  _loc1_.y = -_vertDir * _pivotY;
                  _flippingBottomPage.addChild(_loc1_);
               }
               else if(!_isJourneyBook && _flipDirection == -1)
               {
                  _spiralBottomFlippingPage.setNewParent(_flippingBottomPage,_flipDirection * _pageWidth * 0.5,-_vertDir * _pivotY);
               }
            }
         }
         else
         {
            _loc2_ = _flipDirection == 1 ? _pageNumber - 0.5 : _pageNumber + 0.5;
            if(!_ShouldBeDragging && !_isJourneyBook && _pageNumber <= _numberOfPages)
            {
               _loc2_ += _flipDirection * 2;
            }
            if(_loadedPages[_loc2_] != null)
            {
               _loc1_ = _loadedPages[_loc2_];
               _loc1_.x = -_flipDirection * _pageWidth * 0.5;
               _loc1_.y = -_vertDir * _pivotY;
               _flippingBottomPage.addChild(_loc1_);
            }
            else
            {
               _spiralBottomFlippingPage.setNewParent(_flippingBottomPage,-_flipDirection * _pageWidth * 0.5,-_vertDir * _pivotY);
            }
         }
         _flippingBottomPage.rotation = -_flipDirection * _vertDir * 90;
         _pageFlipBase.addChild(_flippingBottomPage);
      }
      
      private function startDragging(param1:Number, param2:Number) : void
      {
         _ShouldBeDragging = true;
         initPage(_currentPage + param1 * 2,param1,param2);
         if(_isSinglePF && param1 == -1)
         {
            _startX = 0;
         }
         else
         {
            _startX = param1 * _pageWidth;
         }
         if(_showCornerBtns)
         {
            if(param1 == -1 && (_isSinglePF || _isJourneyBook))
            {
               _rightBottomBtn.alpha = 0;
            }
            else
            {
               _leftBottomBtn.alpha = 0;
               _rightBottomBtn.alpha = 0;
            }
         }
         _pageFlipPercent = 0;
         _pageFlipBase.addEventListener("enterFrame",onEnterFrame);
      }
      
      private function initPage(param1:Number, param2:Number, param3:Number) : void
      {
         _pageNumber = param1;
         _flipDirection = param2;
         _vertDir = param3;
         if(_vertDir == 1)
         {
            _pageFlipBase.y = _pageWidth + _pageHeight * 0.5;
         }
         else
         {
            _pageFlipBase.y = -(_pageWidth + _pageHeight * 0.5);
         }
         setStationary();
         if(_setPagesOnly)
         {
            _currentPage = _pageNumber - 2;
         }
         setFlipping();
         createShadow();
         makeMasks();
         LB();
         if(_setPagesOnly)
         {
            _currentPage = _pageNumber + 2;
         }
         if(_currPageLoaded)
         {
            setupButtonsPositions();
         }
         if(_currPageVarsLoaded && _currPageLoaded)
         {
            showButtons();
         }
      }
      
      private function setStationary(param1:Boolean = false) : void
      {
         var _loc3_:Sprite = null;
         var _loc5_:MovieClip = null;
         var _loc2_:Sprite = null;
         var _loc6_:Sprite = null;
         var _loc4_:int = -1;
         var _loc7_:MovieClip = new MovieClip();
         if(!_isSinglePF && _flipInProgress != 1)
         {
            if(_stationaryLeftPage && _stationaryLeftPage.parent && _stationaryLeftPage.parent == _pageFlipBase)
            {
               _loc4_ = _pageFlipBase.getChildIndex(_stationaryLeftPage);
            }
            removeIfChildAdded(_pageFlipBase,_stationaryLeftPage);
            _stationaryLeftPage = new MovieClip();
            if(_currentPage != 0.5)
            {
               drawPage(_loc7_,-1,_vertDir);
               _stationaryLeftPage.addChild(_loc7_);
               _blankPage1.x = -_pageWidth * 0.5;
               _blankPage1.y = -_vertDir * _pivotY;
               _stationaryLeftPage.addChild(_blankPage1);
               _pageNumberTxt = _flipDirection == 1 ? _currentPage - 0.5 : _pageNumber - 0.5;
               if(_pageNumberTxt != 0)
               {
                  if(_loadedPages[_pageNumberTxt] != null)
                  {
                     _loc3_ = new MovieClip();
                     _loc3_ = _loadedPages[_pageNumberTxt];
                     _loc3_.x = -_pageWidth * 0.5;
                     _loc3_.y = -_vertDir * _pivotY;
                     _stationaryLeftPage.addChild(_loc3_);
                  }
                  else
                  {
                     _spiralLeftPage.setNewParent(_stationaryLeftPage,_pageWidth * 0.5,-_vertDir * _pivotY);
                  }
                  _pageFlipBase.addChild(_stationaryLeftPage);
                  if(_loc4_ != -1)
                  {
                     _pageFlipBase.setChildIndex(_stationaryLeftPage,_loc4_);
                  }
                  _loc4_ = -1;
                  if(param1)
                  {
                     _stationaryLeftPage.visible = false;
                  }
               }
            }
         }
         if(_isJourneyBook)
         {
            if(_stationaryLeftPage && _stationaryLeftPage.parent && _stationaryLeftPage.parent == _pageFlipBase)
            {
               _loc4_ = _pageFlipBase.getChildIndex(_stationaryLeftPage);
            }
            removeIfChildAdded(_pageFlipBase,_stationaryLeftPage);
            _stationaryLeftPage = new MovieClip();
            drawPage(_loc7_,-1,_vertDir);
            _stationaryLeftPage.addChild(_loc7_);
            _blankPage1.scaleX = -1;
            _blankPage1.x = -_pageWidth * 0.5;
            _blankPage1.y = -_vertDir * _pivotY;
            _stationaryLeftPage.addChild(_blankPage1);
            _pageFlipBase.addChild(_stationaryLeftPage);
            if(_loc4_ != -1)
            {
               _pageFlipBase.setChildIndex(_stationaryLeftPage,_loc4_);
            }
            _loc4_ = -1;
         }
         if(_stationaryRightPage && _stationaryRightPage.parent && _stationaryRightPage.parent == _pageFlipBase)
         {
            _loc4_ = _pageFlipBase.getChildIndex(_stationaryRightPage);
         }
         removeIfChildAdded(_pageFlipBase,_stationaryRightPage);
         _stationaryRightPage = new MovieClip();
         if(_pageNumber <= _numberOfPages + 0.5)
         {
            _loc5_ = new MovieClip();
            _pageNumberTxt = _flipDirection == 1 ? _pageNumber + 0.5 : _currentPage + 0.5;
            if(_pageNumberTxt >= _numberOfPages)
            {
               drawPage(_loc5_,_flipDirection,_vertDir);
               _stationaryRightPage.addChild(_loc5_);
               _blankPageLast.x = _pageWidth * 0.5;
               _blankPageLast.y = -_vertDir * _pivotY;
               _stationaryRightPage.addChild(_blankPageLast);
            }
            else
            {
               drawPage(_loc5_,1,_vertDir);
               _stationaryRightPage.addChild(_loc5_);
               _blankPage2.x = _pageWidth * 0.5;
               _blankPage2.y = -_vertDir * _pivotY;
               _stationaryRightPage.addChild(_blankPage2);
            }
            if(_pageNumberTxt <= _numberOfPages + 0.5)
            {
               if(_loadedPages[_pageNumberTxt] != null)
               {
                  _loc2_ = new MovieClip();
                  _loc2_ = _loadedPages[_pageNumberTxt];
                  _loc2_.x = _pageWidth * 0.5;
                  _loc2_.y = -_vertDir * _pivotY;
                  _stationaryRightPage.addChild(_loc2_);
               }
               else
               {
                  _spiralRightPage.setNewParent(_stationaryRightPage,_pageWidth * 0.5,-_vertDir * _pivotY);
               }
               _pageFlipBase.addChild(_stationaryRightPage);
               if(_loc4_ != -1)
               {
                  _pageFlipBase.setChildIndex(_stationaryRightPage,_loc4_);
               }
            }
         }
         if(!_isSinglePF || _isJourneyBook || _flipDirection == -1)
         {
            _loc6_ = new MovieClip();
            _loc6_.mouseChildren = false;
            _loc6_.mouseEnabled = false;
            makeShade(_loc6_,-_flipDirection,_vertDir);
            if(_flipDirection > 0 && !_isSinglePF && _pageDrag)
            {
               _stationaryLeftPage.addChild(_loc6_);
            }
            else
            {
               _stationaryRightPage.addChild(_loc6_);
            }
         }
      }
      
      private function dropPage() : void
      {
         if(_pageRatio > 0.6666666666666666)
         {
            _currentPage += 2 * _flipDirection;
         }
         _pageDrag = _ShouldBeDragging = false;
         if(_showCornerBtns)
         {
            _rightBottomBtn.visible = true;
            _leftBottomBtn.visible = true;
            if(!_eBook && !_membershipBook)
            {
               _xBtn.visible = true;
            }
         }
      }
      
      private function stopDragging(param1:Number) : void
      {
         if(_pageDrag)
         {
            if(param1 > 0)
            {
               turnAhead();
            }
            else
            {
               turnBack();
            }
            _pageDrag = false;
         }
      }
      
      private function initBtns() : void
      {
         _leftBottomBtn = _buttonsView[2];
         _rightBottomBtn = _buttonsView[3];
         _xBtn = _buttonsView[1];
         if(_eBook)
         {
            _zoomBtn = _buttonsView[4];
            _zoomBtn.x = 900 * 0.5;
            _zoomBtn.y = 550 - 30;
            _popupLayer.addChild(_zoomBtn);
            _zoomBtn.addEventListener("mouseDown",magnify,false,0,true);
            _zoomBtn.magnifyBtnMinus.visible = false;
         }
         _pageFlipBase.addChild(_rightBottomBtn);
         _pageFlipBase.addChild(_leftBottomBtn);
         _pageFlipBase.addChild(_xBtn);
         KeepAlive.startKATimer(_rightBottomBtn);
         if(_currPageLoaded)
         {
            setupButtonsPositions();
         }
         _rightBottomBtn.x = _pageWidth;
         _xBtn.x = _pageWidth - _xBtn.width;
         if(_isSinglePF)
         {
            _leftBottomBtn.x = _leftBottomBtn.width;
            if(_pageTurnedTo * 2 > _numberOfPages + 0.5)
            {
               _rightBottomBtn.visible = false;
            }
         }
         else
         {
            _leftBottomBtn.x = -_pageWidth + _leftBottomBtn.width;
         }
         if(_isSinglePF)
         {
            if(_pageStart < 2)
            {
               _leftBottomBtn.visible = false;
            }
         }
         else if(_pageStart < 3)
         {
            _leftBottomBtn.visible = false;
         }
         if(!_currPageVarsLoaded)
         {
            _leftBottomBtn.visible = false;
            _rightBottomBtn.visible = false;
         }
         if(_eBook || _membershipBook)
         {
            _xBtn.visible = false;
         }
         _leftBottomBtn.addEventListener("mouseOver",allBtnOverHandler,false,0,true);
         _rightBottomBtn.addEventListener("mouseOver",allBtnOverHandler,false,0,true);
         _xBtn.addEventListener("mouseOver",allBtnOverHandler,false,0,true);
         _leftBottomBtn.addEventListener("mouseOut",allBtnOutHandler,false,0,true);
         _rightBottomBtn.addEventListener("mouseOut",allBtnOutHandler,false,0,true);
         _xBtn.addEventListener("mouseOut",allBtnOutHandler,false,0,true);
         _leftBottomBtn.addEventListener("mouseDown",allBtnDownHandler,false,0,true);
         _rightBottomBtn.addEventListener("mouseDown",allBtnDownHandler,false,0,true);
         _xBtn.addEventListener("mouseDown",allBtnDownHandler,false,0,true);
         _leftBottomBtn.addEventListener("mouseUp",allBtnUpHandler,false,0,true);
         _rightBottomBtn.addEventListener("mouseUp",allBtnUpHandler,false,0,true);
         _xBtn.addEventListener("mouseUp",allBtnUpHandler,false,0,true);
      }
      
      private function bringButtonsToFront() : void
      {
         _leftBottomBtn.parent.setChildIndex(_leftBottomBtn,_leftBottomBtn.parent.numChildren - 1);
         _rightBottomBtn.parent.setChildIndex(_rightBottomBtn,_rightBottomBtn.parent.numChildren - 1);
         _xBtn.parent.setChildIndex(_xBtn,_xBtn.parent.numChildren - 1);
      }
      
      private function allBtnOverHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case _leftBottomBtn:
               startDragging(-1,1);
               break;
            case _rightBottomBtn:
               startDragging(1,1);
         }
      }
      
      private function allBtnOutHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget != _xBtn)
         {
            _ShouldBeDragging = false;
            bringButtonsToFront();
         }
      }
      
      private function magnify(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_zoomedIn)
         {
            this.stopDrag();
            if(_eBook)
            {
               _eBook.scaleX -= 1.42;
               _eBook.scaleY -= 1.42;
               _eBook.x = 450;
               _eBook.y = 275;
               _zoomBtn.magnifyBtnPlus.visible = true;
               _zoomBtn.magnifyBtnMinus.visible = false;
            }
            else
            {
               this.scaleX -= 1.42;
               this.scaleY -= 1.42;
               this.x = 450;
               this.y = 275;
            }
            _zoomedIn = false;
         }
         else
         {
            if(_eBook)
            {
               _eBook.scaleX += 1.42;
               _eBook.scaleY += 1.42;
               _zoomBtn.magnifyBtnPlus.visible = false;
               _zoomBtn.magnifyBtnMinus.visible = true;
            }
            else
            {
               this.scaleX += 1.42;
               this.scaleY += 1.42;
            }
            _zoomedIn = true;
         }
      }
      
      private function allBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _xBtn || param1.currentTarget.name == "bx")
         {
            if(_closeCallback != null)
            {
               _closeCallback();
            }
            else
            {
               destroy();
            }
            return;
         }
         if(_currPageLoaded && _currPageVarsLoaded)
         {
            if(_bookType == 2)
            {
               _membershipBook.titleBannerCont.gotoAndPlay("playOff");
            }
            _pageDrag = true;
            if(param1.currentTarget == _leftBottomBtn)
            {
               _xBtn.visible = false;
               _rightBottomBtn.visible = false;
            }
            else
            {
               _leftBottomBtn.visible = false;
            }
         }
      }
      
      private function allBtnUpHandler(param1:MouseEvent) : void
      {
         if(_playFlipSound)
         {
            AJAudio.playNewspaperSound();
         }
         switch(param1.currentTarget)
         {
            case _leftBottomBtn:
               stopDragging(-1);
               break;
            case _rightBottomBtn:
               stopDragging(1);
         }
      }
      
      private function onJoinClubBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(_flipInProgress == 1)
         {
            flipAuto(range0to1(_pageOffset = _pageOffset + _autoStepSpeed));
         }
         else
         {
            _loc2_ = getPageRatio();
            _step = (_loc2_ - _pageFlipPercent) * _dragSmoothness;
            _pageFlipPercent += _step;
            renderPageFlip(_pageFlipPercent);
            if(!_ShouldBeDragging)
            {
               if(_pageFlipPercent < _snapDistance || _pageFlipPercent < 0.25)
               {
                  renderPageFlip(0);
                  _pageOffset = 0;
                  flipComplete();
               }
               else if(_pageFlipPercent > 1 - _snapDistance)
               {
                  renderPageFlip(1);
                  _pageOffset = 1;
                  flipComplete();
               }
            }
         }
      }
      
      private function jbUserVarIdForPageName(param1:String, param2:int = 0) : int
      {
         switch(param1)
         {
            case "bahari_bay":
               return 289;
            case "crystal_reef":
               return 290;
            case "deep_blue":
               return 291;
            case "kani_cove":
               return 288;
            case "lost_temple_of_zios":
               return 295;
            case "Mt_Shiveer":
               return 298;
            case "Sarepia_Forest":
               return 311;
            case "Appondale":
               return 320;
            case "coral_canyons":
               return 333;
            case "crystal_sands":
               return 337;
            case "birds_of_paradise":
               return 365;
            case "kimbara_outback":
               return 371;
            case "alpha":
               if(param2 == 0)
               {
                  return 456;
               }
               if(param2 == 1)
               {
                  return 457;
               }
               if(param2 == 2)
               {
                  return 460;
               }
               break;
            case "balloosh":
               break;
            default:
               return -1;
         }
         return 459;
      }
      
      private function eBookUserVarIdForStickerName(param1:String) : int
      {
         var _loc2_:* = param1;
         if("snowLeopard" !== _loc2_)
         {
            return -1;
         }
         return 417;
      }
      
      private function eBookUserVarIdForPageName(param1:String) : int
      {
         switch(param1)
         {
            case "Otters":
               return 381;
            case "Panda":
               return 401;
            case "PolarBear":
               return 402;
            case "Owl":
               return 407;
            case "lion":
               return 408;
            case "cheetah":
               return 411;
            case "llama":
               return 412;
            case "snowLeopard":
               return 416;
            case "lynx":
               return 418;
            case "fox":
               return 422;
            default:
               return -1;
         }
      }
      
      private function eBookNumStickersForUserVarId(param1:int) : int
      {
         switch(param1 - 417)
         {
            case 0:
               return 8;
            default:
               return -1;
         }
      }
      
      private function eBookNumStampsForUserVarId(param1:int) : int
      {
         switch(param1)
         {
            case 381:
               return 7;
            case 401:
               return 4;
            case 402:
               return 5;
            case 407:
               return 5;
            case 408:
               return 5;
            case 411:
               return 5;
            case 412:
               return 5;
            case 416:
               return 4;
            case 418:
               return 3;
            case 422:
               return 2;
            default:
               return -1;
         }
      }
   }
}

