package movie
{
   import Enums.StreamDef;
   import collection.StreamDefCollection;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.printing.PrintJob;
   import gui.DarkenManager;
   import gui.FeedbackManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MovieManager
   {
      public static const NORMAL_SKIN:int = 1;
      
      public static const BRADY_BARR_SKIN:int = 2;
      
      public static const TIERNEY_THYS_SKIN:int = 3;
      
      public static const CAMI_SKIN:int = 4;
      
      public static const GABBY_SKIN:int = 5;
      
      public static const BIGGER_FRAME:int = 6;
      
      public static const VID_PLAYER_MEDIA_ID:int = 39;
      
      public static const VID_SELECTOR_MEDIA_ID:int = 202;
      
      private const MOVIES_PER_SCREEN:int = 4;
      
      private var _popupLayer:DisplayLayer;
      
      private var _movieSelector:MovieClip;
      
      private var _movieSelectorPopup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _pageNumber:int;
      
      private var _mediaItems:Array;
      
      private var _previewImages:Array;
      
      private var _videoPlayer:VideoPlayerOSMF;
      
      private var _spirals:Array;
      
      private var _movieMediaHelper:MediaHelper;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _videoPlayerId:int;
      
      private var _theaterScreen:Object;
      
      private var _isFromTheater:Boolean;
      
      private var _isAsking:Boolean;
      
      private var _titleTxt:String;
      
      private var _chooseRandom:Boolean;
      
      private var _printMediaHolder:Array;
      
      private var _numPrintItemsToLoad:int;
      
      private var _numPrintItemsLoaded:int;
      
      private var _loadedImages:Array;
      
      private var _randomPlayerSkinId:int;
      
      private var _shouldRepeat:Boolean;
      
      private var _defaultWidth:int = 512;
      
      private var _defaultHeight:int = 288;
      
      private var _skinFrameId:int = 1;
      
      private var _videoFrameId:int = 1;
      
      private var _streamDefs:StreamDefCollection;
      
      private var _closeBtn:MovieClip;
      
      private var _leftArrow:MovieClip;
      
      private var _rightArrow:MovieClip;
      
      private var _mw0:MovieClip;
      
      private var _mw1:MovieClip;
      
      private var _mw2:MovieClip;
      
      private var _mw3:MovieClip;
      
      private var _playMovBtn0:MovieClip;
      
      private var _playMovBtn1:MovieClip;
      
      private var _playMovBtn2:MovieClip;
      
      private var _playMovBtn3:MovieClip;
      
      public function MovieManager()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Object, param3:StreamDefCollection, param4:int = 202, param5:int = 39, param6:Function = null) : void
      {
         _popupLayer = param1;
         if(param4 > 0)
         {
            _movieMediaHelper = new MediaHelper();
            _movieMediaHelper.init(param4,movieHelperCallback);
         }
         _closeCallback = param6;
         if(param2)
         {
            if(param2 is MovieClip)
            {
               _theaterScreen = param2;
            }
            else if(param2.hasOwnProperty("loader"))
            {
               _theaterScreen = param2.loader.content;
            }
         }
         _videoPlayer = new VideoPlayerOSMF();
         if(_theaterScreen)
         {
            MovieClip(_theaterScreen).addChild(_videoPlayer);
            _isFromTheater = true;
         }
         else
         {
            param1.addChild(_videoPlayer);
            _isFromTheater = false;
         }
         _pageNumber = 0;
         _videoPlayerId = param5;
         _streamDefs = param3;
         _spirals = [];
         _previewImages = [];
         _mediaItems = [];
      }
      
      public function get videoPlayer() : VideoPlayerOSMF
      {
         return _videoPlayer;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_movieSelectorPopup)
         {
            removeListeners();
            KeepAlive.stopKATimer(_movieSelectorPopup);
            _popupLayer.removeChild(_movieSelectorPopup);
            DarkenManager.unDarken(_movieSelectorPopup);
         }
         _movieSelectorPopup = null;
         _movieSelector = null;
         _isFromTheater = false;
         _isAsking = false;
         _theaterScreen = null;
         _titleTxt = null;
         if(_movieMediaHelper)
         {
            _movieMediaHelper.destroy();
            _movieMediaHelper = null;
         }
         if(_printMediaHelper)
         {
            _printMediaHelper.destroy();
            _printMediaHelper = null;
         }
         if(_mediaItems)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaItems.length)
            {
               _mediaItems[_loc1_].destroy();
               _loc1_++;
            }
            _mediaItems.splice(0,_mediaItems.length);
            _mediaItems = null;
         }
         _loc2_ = 0;
         while(_loc2_ < _spirals.length)
         {
            _spirals[_loc2_].destroy();
            _loc2_++;
         }
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         _spirals = null;
         _previewImages = null;
         _mediaItems = null;
         _closeBtn = null;
         _leftArrow = null;
         _rightArrow = null;
         _mw0 = null;
         _mw1 = null;
         _mw2 = null;
         _mw3 = null;
         _playMovBtn0 = null;
         _playMovBtn1 = null;
         _playMovBtn2 = null;
         _playMovBtn3 = null;
         _closeCallback = null;
      }
      
      public function toggleVisibility() : void
      {
         if(_movieSelectorPopup)
         {
            if(_movieSelectorPopup.visible)
            {
               DarkenManager.unDarken(_movieSelectorPopup);
            }
            else
            {
               DarkenManager.darken(_movieSelectorPopup);
            }
            _movieSelectorPopup.visible = !_movieSelectorPopup.visible;
         }
      }
      
      public function setSkinFrame(param1:int) : void
      {
         _skinFrameId = param1;
         if(_movieSelector && _movieSelector.currentFrame != param1)
         {
            _movieSelector.gotoAndPlay(param1);
         }
      }
      
      public function setVideoFrameId(param1:int) : void
      {
         _videoFrameId = param1;
      }
      
      public function togglePlayPauseVideoPlayer(param1:Boolean) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.togglePlayPause(param1);
         }
      }
      
      public function setQuestionBtn() : void
      {
         if(_movieSelector && _movieSelector.askTab)
         {
            if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
            {
               _movieSelector.askTab.askBradyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
            else if(_movieSelector.askTab.hasOwnProperty("askCamiBtn"))
            {
               _movieSelector.askTab.askCamiBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
            else if(_movieSelector.askTab.hasOwnProperty("askGabbyBtn"))
            {
               _movieSelector.askTab.askGabbyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
            else
            {
               _movieSelector.askTab.askTierneyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
         }
         else
         {
            _isAsking = true;
         }
      }
      
      public function setTitleTxt(param1:String) : void
      {
         if(_movieSelector)
         {
            LocalizationManager.translateId(_movieSelector.titleTxt,int(param1));
         }
         else
         {
            _titleTxt = param1;
         }
      }
      
      public function chooseRandom(param1:Boolean, param2:int = 1, param3:Boolean = false, param4:int = 530, param5:int = 298) : void
      {
         _chooseRandom = param1;
         _randomPlayerSkinId = param2;
         if(_movieSelector && _chooseRandom)
         {
            _videoPlayer.init(_streamDefs,_videoPlayerId,-1,param3,param4,param5,onVideoPlayerClose);
            _videoPlayer.setSkinFrame(param2);
            toggleVisibility();
         }
      }
      
      public function setShouldRepeat(param1:Boolean) : void
      {
         _shouldRepeat = param1;
      }
      
      public function setDefaultWidthHeight(param1:int, param2:int) : void
      {
         _defaultWidth = param1;
         _defaultHeight = param2;
      }
      
      private function movieHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:MediaHelper = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _movieSelectorPopup = param1;
            KeepAlive.startKATimer(_movieSelectorPopup);
            _movieSelectorPopup.visible = false;
            _popupLayer.addChild(_movieSelectorPopup);
            _movieSelector = MovieClip(_movieSelectorPopup.getChildAt(0));
            if(_movieSelector.currentFrame != _skinFrameId)
            {
               _movieSelector.gotoAndPlay(_skinFrameId);
            }
            _loc3_ = int(_streamDefs.length);
            _loc4_ = 1;
            while(_loc4_ < Math.min(5,_loc3_ + 1))
            {
               _spirals[_loc4_ - 1] = new LoadingSpiral(_movieSelector["mw" + _loc4_].itemLayer);
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc2_ = new MediaHelper();
               _loc2_.init(_streamDefs.getStreamDefItem(_loc5_).thumbnailId,previewHelperCallback,true);
               _mediaItems[_loc5_] = _loc2_;
               _loc5_++;
            }
            _movieSelectorPopup.x = 900 * 0.5;
            _movieSelectorPopup.y = 550 * 0.5;
            _closeBtn = MovieClip(_movieSelectorPopup.getChildAt(0)["bx"]);
            _leftArrow = _movieSelector["arrowLBtn"];
            _rightArrow = _movieSelector["arrowRBtn"];
            _mw0 = _movieSelector["mw1"];
            _mw1 = _movieSelector["mw2"];
            _mw2 = _movieSelector["mw3"];
            _mw3 = _movieSelector["mw4"];
            _playMovBtn0 = _mw0["playMovBtn"];
            _playMovBtn1 = _mw1["playMovBtn"];
            _playMovBtn2 = _mw2["playMovBtn"];
            _playMovBtn3 = _mw3["playMovBtn"];
            _playMovBtn0.visible = false;
            _playMovBtn1.visible = false;
            _playMovBtn2.visible = false;
            _playMovBtn3.visible = false;
            _mw0.movieDescTxt.visible = false;
            _mw1.movieDescTxt.visible = false;
            _mw2.movieDescTxt.visible = false;
            _mw3.movieDescTxt.visible = false;
            _mw0.newTag.visible = false;
            _mw1.newTag.visible = false;
            _mw2.newTag.visible = false;
            _mw3.newTag.visible = false;
            _mw0.daysLeftTag.visible = false;
            _mw1.daysLeftTag.visible = false;
            _mw2.daysLeftTag.visible = false;
            _mw3.daysLeftTag.visible = false;
            if(_loc3_ <= 4)
            {
               _leftArrow.activateGrayState(true);
               _rightArrow.activateGrayState(true);
            }
            if(!_isAsking)
            {
               if(_movieSelector.askTab)
               {
                  _movieSelector.askTab.visible = false;
               }
            }
            if(_titleTxt)
            {
               LocalizationManager.translateId(_movieSelector.titleTxt,int(_titleTxt));
            }
            addListeners();
            if(!_theaterScreen)
            {
               toggleVisibility();
            }
            if(_theaterScreen)
            {
               _videoPlayer.init(_streamDefs,-1,-1);
            }
            if(_chooseRandom)
            {
               _videoPlayer.init(_streamDefs,!!_theaterScreen ? -1 : _videoPlayerId,-1,_shouldRepeat,512,288,onVideoPlayerClose);
               _videoPlayer.setSkinFrame(_randomPlayerSkinId);
               toggleVisibility();
            }
         }
      }
      
      private function onVideoPlayerClose() : void
      {
         onClose(null);
      }
      
      private function addListeners() : void
      {
         _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _playMovBtn0.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn1.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn2.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn3.addEventListener("mouseDown",onPlay,false,0,true);
         _leftArrow.addEventListener("mouseDown",onSideBtn,false,0,true);
         _rightArrow.addEventListener("mouseDown",onSideBtn,false,0,true);
         _movieSelectorPopup.addEventListener("mouseDown",onMoviePopup,false,0,true);
         if(_isAsking)
         {
            if(_movieSelector.askTab)
            {
               if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  _movieSelector.askTab.askBradyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
               else if(_movieSelector.askTab.hasOwnProperty("askCamiBtn"))
               {
                  _movieSelector.askTab.askCamiBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
               else if(_movieSelector.askTab.hasOwnProperty("askGabbyBtn"))
               {
                  _movieSelector.askTab.askGabbyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
               else
               {
                  _movieSelector.askTab.askTierneyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeListeners() : void
      {
         _closeBtn.removeEventListener("mouseDown",onClose);
         _playMovBtn0.removeEventListener("mouseDown",onPlay);
         _playMovBtn1.removeEventListener("mouseDown",onPlay);
         _playMovBtn2.removeEventListener("mouseDown",onPlay);
         _playMovBtn3.removeEventListener("mouseDown",onPlay);
         _leftArrow.removeEventListener("mouseDown",onSideBtn);
         _rightArrow.removeEventListener("mouseDown",onSideBtn);
         _movieSelectorPopup.removeEventListener("mouseDown",onMoviePopup);
         if(_isAsking)
         {
            if(_movieSelector.askTab)
            {
               if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  _movieSelector.askTab.askBradyBtn.removeEventListener("mouseDown",onAskBtn);
               }
               else if(_movieSelector.askTab.hasOwnProperty("askCamiBtn"))
               {
                  _movieSelector.askTab.askCamiBtn.removeEventListener("mouseDown",onAskBtn);
               }
               else if(_movieSelector.askTab.hasOwnProperty("askGabbyBtn"))
               {
                  _movieSelector.askTab.askGabbyBtn.removeEventListener("mouseDown",onAskBtn);
               }
               else
               {
                  _movieSelector.askTab.askTierneyBtn.removeEventListener("mouseDown",onAskBtn);
               }
            }
         }
      }
      
      private function onMoviePopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_closeCallback != null)
         {
            if(!_chooseRandom)
            {
               _closeCallback();
            }
         }
         else
         {
            destroy();
         }
      }
      
      private function onAskBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(param1.currentTarget.name == "askBradyBtn")
         {
            FeedbackManager.openFeedbackPopup(1);
         }
         else if(param1.currentTarget.name == "askCamiBtn")
         {
            FeedbackManager.openFeedbackPopup(21);
         }
         else if(param1.currentTarget.name == "askGabbyBtn")
         {
            FeedbackManager.openFeedbackPopup(22);
         }
         else
         {
            FeedbackManager.openFeedbackPopup(11);
         }
      }
      
      private function previewHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc5_:StreamDef = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc2_:Object = null;
         if(_mediaItems)
         {
            _loc6_ = 0;
            while(_loc6_ < _mediaItems.length)
            {
               if(_mediaItems[_loc6_] == param1.mediaHelper)
               {
                  _previewImages[_loc6_] = param1;
                  if(_loc6_ < 4)
                  {
                     _loc5_ = _streamDefs.getStreamDefItem(_loc6_);
                     _loc3_ = this["_mw" + _loc6_];
                     _spirals[_loc6_].destroy();
                     _loc3_.movieDescTxt.visible = true;
                     _loc3_.playMovBtn.visible = true;
                     _loc3_.itemLayer.addChild(param1);
                     LocalizationManager.translateId(_loc3_.movieDescTxt,_loc5_.baseTitleId);
                     _loc3_.newTag.visible = _loc5_.isNew;
                     _loc2_ = param1.getChildAt(0);
                     _loc4_ = 0;
                     while(_loc4_ < _loc2_.numChildren)
                     {
                        if(_loc2_.getChildAt(_loc4_).name.indexOf("beakerBtn") >= 0)
                        {
                           _loc2_.getChildAt(_loc4_).addEventListener("mouseDown",onBeakerDown,false,0,true);
                        }
                        _loc4_++;
                     }
                  }
                  break;
               }
               _loc6_++;
            }
            if(_mediaItems.length < 4)
            {
               _loc4_ = int(_mediaItems.length);
               while(_loc4_ < 4)
               {
                  this["_mw" + _loc4_].visible = false;
                  _loc4_++;
               }
            }
         }
      }
      
      private function reloadPreviews() : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc4_:StreamDef = null;
         var _loc5_:int = 0;
         var _loc1_:Object = null;
         _loc3_ = 1;
         while(_loc3_ < 5)
         {
            while(_movieSelector["mw" + _loc3_].itemLayer.numChildren > 0)
            {
               _movieSelector["mw" + _loc3_].itemLayer.removeChildAt(0);
            }
            _loc3_++;
         }
         _loc5_ = _pageNumber;
         while(_loc5_ < _pageNumber + 4)
         {
            _loc2_ = this["_mw" + (_loc5_ - _pageNumber)];
            if(_loc5_ < _previewImages.length)
            {
               _loc4_ = _streamDefs.getStreamDefItem(_loc5_);
               _loc2_.visible = true;
               _loc2_.itemLayer.addChild(_previewImages[_loc5_]);
               _loc2_.playMovBtn.visible = true;
               LocalizationManager.translateId(_loc2_.movieDescTxt,_loc4_.baseTitleId);
               _loc2_.newTag.visible = _loc4_.isNew;
               _loc1_ = _previewImages[_loc5_].getChildAt(0);
               _loc3_ = 0;
               while(_loc3_ < _loc1_.numChildren)
               {
                  if(_loc1_.getChildAt(_loc3_).name.indexOf("beakerBtn") > 0)
                  {
                     _loc1_.getChildAt(_loc3_).addEventListener("mouseDown",onBeakerDown,false,0,true);
                  }
                  _loc3_++;
               }
            }
            else
            {
               _loc2_.visible = false;
            }
            _loc5_++;
         }
      }
      
      private function onPlay(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         switch(param1.currentTarget.parent.name)
         {
            case "mw1":
               break;
            case "mw2":
               _loc2_ = 1;
               break;
            case "mw3":
               _loc2_ = 2;
               break;
            case "mw4":
               _loc2_ = 3;
         }
         if(_streamDefs.length > _loc2_ + _pageNumber)
         {
            if(_chooseRandom || _isFromTheater)
            {
               _videoPlayer.playVideoIdx(_pageNumber + _loc2_);
               onClose(param1);
            }
            else
            {
               _videoPlayer.init(_streamDefs,_videoPlayerId,_pageNumber + _loc2_,_shouldRepeat,_defaultWidth,_defaultHeight);
               _videoPlayer.setSkinFrame(_videoFrameId);
            }
         }
      }
      
      private function onSideBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         var _loc3_:* = param1.currentTarget.name;
         if("arrowLBtn" !== _loc3_)
         {
            if(_pageNumber + 4 < _streamDefs.length)
            {
               _pageNumber += 4;
               reloadPreviews();
            }
            else
            {
               _pageNumber = 0;
               reloadPreviews();
            }
         }
         else if(_pageNumber - 4 >= 0)
         {
            _pageNumber -= 4;
            reloadPreviews();
         }
         else if(_streamDefs.length > 4)
         {
            _loc2_ = _streamDefs.length % 4;
            _pageNumber = _streamDefs.length;
            _pageNumber -= _loc2_ == 0 ? 4 : _loc2_;
            reloadPreviews();
         }
      }
      
      private function onBeakerDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14808),true,onConfirmPrint,param1.currentTarget.name.split("_"));
      }
      
      private function onConfirmPrint(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            _numPrintItemsToLoad = param1.passback.length - 1;
            _numPrintItemsLoaded = 0;
            _printMediaHolder = [];
            _loadedImages = [];
            _loc2_ = 1;
            while(_loc2_ < param1.passback.length)
            {
               _printMediaHelper = new MediaHelper();
               _printMediaHelper.init(param1.passback[_loc2_],onPrintMediaLoaded,_loc2_);
               _printMediaHolder.push(_printMediaHelper);
               _loc2_++;
            }
         }
      }
      
      private function onPrintMediaLoaded(param1:MovieClip) : void
      {
         var _loc3_:PrintJob = null;
         var _loc2_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         _loadedImages[param1.passback - 1] = param1;
         _numPrintItemsLoaded++;
         if(_numPrintItemsLoaded == _numPrintItemsToLoad)
         {
            DarkenManager.showLoadingSpiral(false);
            _loc3_ = new PrintJob();
            if(_loc3_.start())
            {
               _loc4_ = [];
               _loc2_ = 0;
               while(_loc2_ < _loadedImages.length)
               {
                  _loc5_ = setupPrintSprite(_loadedImages[_loc2_],_loc3_);
                  _loc4_.push(_loc5_.spriteToPrint);
                  _printMediaHolder[_loc2_].destroy();
                  try
                  {
                     _loc3_.addPage(_loc5_.spriteToPrint,new Rectangle(0,0,_loc5_.realW + 2,_loc5_.realH + 2));
                  }
                  catch(e:Error)
                  {
                  }
                  _loc2_++;
               }
               _loc5_ = null;
            }
            _loadedImages = null;
            _printMediaHolder = null;
            _loc3_.send();
            if(_loc4_)
            {
               _loc2_ = 0;
               while(_loc2_ < _loc4_.length)
               {
                  if(_loc4_[_loc2_].parent)
                  {
                     gMainFrame.stage.removeChild(_loc4_[_loc2_]);
                  }
                  _loc2_++;
               }
            }
            _loc4_ = null;
         }
      }
      
      private function setupPrintSprite(param1:MovieClip, param2:PrintJob) : Object
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Sprite = new Sprite();
         param1.scaleX = param1.scaleY = 4;
         _loc3_.addChild(param1);
         param1.x = param1.y = 1;
         var _loc7_:Number = _loc3_.width;
         var _loc9_:Number = _loc3_.height;
         var _loc8_:BitmapData = new BitmapData(_loc3_.width,_loc3_.height,false,4294967295);
         _loc8_.draw(_loc3_);
         var _loc10_:Bitmap = new Bitmap(_loc8_);
         var _loc6_:Sprite = new Sprite();
         _loc6_.addChild(_loc10_);
         _loc10_.x = 0;
         _loc10_.y = 0;
         _loc10_.scaleX = 0.999;
         _loc10_.scaleY = 0.999;
         _loc6_.x = 0;
         _loc6_.y = 0;
         gMainFrame.stage.addChild(_loc6_);
         _loc6_.visible = false;
         if(param2.orientation != "portrait")
         {
            _loc6_.rotation = 90;
            _loc6_.x = _loc6_.width;
            _loc5_ = param2.pageWidth / _loc9_;
            _loc4_ = param2.pageHeight / _loc7_;
         }
         else
         {
            _loc5_ = param2.pageWidth / _loc7_;
            _loc4_ = param2.pageHeight / _loc9_;
         }
         _loc6_.scaleX = _loc6_.scaleY = Math.min(_loc5_,_loc4_);
         return {
            "spriteToPrint":_loc6_,
            "realW":_loc7_,
            "realH":_loc9_
         };
      }
   }
}

