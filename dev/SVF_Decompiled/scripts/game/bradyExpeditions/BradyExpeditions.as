package game.bradyExpeditions
{
   import Enums.StreamDef;
   import achievement.AchievementXtCommManager;
   import collection.StreamDefCollection;
   import com.sbi.client.KeepAlive;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.popup.SBLeaveCancelPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import giftPopup.GiftPopup;
   import gui.DarkenManager;
   import gui.LoadingSpiral;
   import gui.WindowGenerator;
   import gui.itemWindows.ItemWindowChapterSelect;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import movie.MovieNode;
   import movie.MovieXtCommManager;
   import movie.VideoPlayerOSMF;
   
   public class BradyExpeditions extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const NUM_X_WIN:int = 2;
      
      private static const NUM_Y_WIN:int = 6;
      
      private static const X_WIN_OFFSET:int = 0;
      
      private static const Y_WIN_OFFSET:int = 0;
      
      private static const X_WIN_START:int = 0;
      
      public static var CHOICE_SOUND:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      private var _soundBtn:MovieClip;
      
      private var _videoPlayer:VideoPlayerOSMF;
      
      private var _currMovieNodeDef:MovieNode;
      
      private var _prevMovieNodeDef:MovieNode;
      
      private var _mediaHolder:Array;
      
      private var _iconMediaHolder:Array;
      
      private var _thumbMediaHolder:Array;
      
      private var _prizePopup:GiftPopup;
      
      private var _serialNumber:int;
      
      private var _loadingSpirals:Object;
      
      private var _selectionItemWindow:WindowGenerator;
      
      private var _sceneEvent:Event;
      
      private var _isSkipping:Boolean;
      
      private var _baseNodeDefId:int;
      
      private var _currChoiceHolder:Array;
      
      private var _randomChoiceHolder:Array;
      
      private var _prizeDenItem:DenItem;
      
      private var _wereSoundsMuted:Boolean;
      
      private var _soundMan:SoundManager;
      
      private var _CHOICE_SOUND_INSTANCE:SoundChannel;
      
      public function BradyExpeditions()
      {
         super();
         init();
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         MinigameManager.msg(["hs"]);
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_wereSoundsMuted)
         {
            SBAudio.muteAll();
         }
         else if(SBAudio.isMusicMuted)
         {
            SBAudio.unmuteAll();
         }
         releaseBase();
         MovieXtCommManager.resetAllChosenChapters(_baseNodeDefId);
         _bInit = false;
         removeLayer(_guiLayer);
         _guiLayer = null;
         MinigameManager.leave();
         if(_CHOICE_SOUND_INSTANCE)
         {
            _soundMan.stop(_CHOICE_SOUND_INSTANCE);
            _CHOICE_SOUND_INSTANCE = null;
            _soundMan = null;
         }
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
            _videoPlayer = null;
         }
         _loadingSpirals = null;
         for each(var _loc2_ in _mediaHolder)
         {
            if(_loc2_)
            {
               _loc2_.destroy();
               _loc2_ = null;
            }
         }
         removeEventListeners();
         if(_prizeDenItem)
         {
            _prizeDenItem.destroy();
         }
         _mediaHolder = null;
         _iconMediaHolder = null;
         _thumbMediaHolder = null;
         _currChoiceHolder = null;
         _randomChoiceHolder = null;
         _closeBtn = null;
         _soundBtn = null;
         _popup = null;
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "mm")
         {
            if(param1[2] == "hs")
            {
               _serialNumber = parseInt(param1[3]);
            }
         }
      }
      
      private function init() : void
      {
         _loadingSpirals = {
            "spiral1":new LoadingSpiral(),
            "spiral2":new LoadingSpiral(),
            "spiral3":new LoadingSpiral()
         };
         if(!_bInit)
         {
            _guiLayer = new Sprite();
            addChild(_guiLayer);
            loadScene("BradyExpeditionsAssets/room_main.xroom");
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         _sceneEvent = param1;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(2126,onMediaLoaded,param1);
         _baseNodeDefId = 1;
         CHOICE_SOUND = getDefinitionByName("choiceLoop") as Class;
         if(CHOICE_SOUND == null)
         {
            throw new Error("Sound not found! name:choiceLoop");
         }
         _soundMan = new SoundManager(this);
         _soundMan.addSound(CHOICE_SOUND,0.5,"CHOICE_SOUND");
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         _mediaHolder = [];
         _iconMediaHolder = [];
         _thumbMediaHolder = [];
         _currChoiceHolder = [];
         _randomChoiceHolder = [];
         _popup = MovieClip(param1.getChildAt(0));
         _closeBtn = new (param1.loaderInfo.applicationDomain.getDefinition("closeBtn") as Class)();
         _soundBtn = new (param1.loaderInfo.applicationDomain.getDefinition("soundBtn") as Class)();
         _wereSoundsMuted = SBAudio.isMusicMuted || SBAudio.areSoundsMuted;
         SBAudio.unmuteAll();
         _popup.banner.titleTxt.autoSize = "center";
         KeepAlive.inputReceivedHandler(null);
         setupAdventureSelection();
         _guiLayer.addChild(_popup);
         super.sceneLoaded(_sceneEvent);
      }
      
      private function setupAdventureSelection() : void
      {
         if(_CHOICE_SOUND_INSTANCE == null)
         {
            _CHOICE_SOUND_INSTANCE = _soundMan.play(CHOICE_SOUND,0,99999);
         }
         _popup.bigCloseBtn.addEventListener("mouseDown",onCloseButton,false,0,true);
         _popup.pythonBtnCont.visible = true;
         _popup.videoFrame.visible = false;
         _popup.banner.visible = false;
         _popup.outsideFrame.visible = false;
         hideAllWindows();
         _popup.pythonBtnCont.addEventListener("mouseDown",onPythonDown,false,0,true);
      }
      
      private function onPythonDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.removeEventListener("mouseDown",onPythonDown);
         _popup.pythonBtnCont.visible = false;
         _popup.bigCloseBtn.removeEventListener("mouseDown",onCloseButton);
         _popup.bigCloseBtn.visible = false;
         setupSelectionScreen();
      }
      
      private function setupSelectionScreen() : void
      {
         var nodes:Array;
         if(_CHOICE_SOUND_INSTANCE == null)
         {
            _CHOICE_SOUND_INSTANCE = _soundMan.play(CHOICE_SOUND,0,99999);
         }
         _prevMovieNodeDef = null;
         nodes = MovieXtCommManager.getAllChapters(_baseNodeDefId);
         _popup.outsideFrame.chapterTitle.visible = true;
         _popup.videoFrame.visible = false;
         _popup.banner.visible = false;
         _popup.outsideFrame.visible = true;
         with(_popup.outsideFrame)
         {
            while(xBtn2.numChildren > 0)
            {
               xBtn2.removeChildAt(0);
            }
            xBtn2.addChild(_closeBtn);
            while(volBtn2.numChildren > 0)
            {
               volBtn2.removeChildAt(0);
            }
            volBtn2.addChild(_soundBtn);
         }
         hideAllWindows();
         if(_selectionItemWindow)
         {
            _selectionItemWindow.destroy();
            _selectionItemWindow = null;
         }
         _selectionItemWindow = new WindowGenerator();
         _selectionItemWindow.init(2,6,nodes.length,0,0,0,ItemWindowChapterSelect,nodes,"icon",{
            "mouseDown":chapterSelectDown,
            "mouseOver":null,
            "mouseOut":null,
            "memberOnlyDown":null
         },{"baseDefId":_baseNodeDefId},onSelectionScreenLoaded,false,false);
      }
      
      private function onSelectionScreenLoaded() : void
      {
         _popup.chapterWindow.visible = true;
         while(_popup.chapterWindow.numChildren > 0)
         {
            _popup.chapterWindow.removeChildAt(0);
         }
         _popup.chapterWindow.addChild(_selectionItemWindow);
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _closeBtn.addEventListener("mouseDown",onCloseButton,false,0,true);
         _soundBtn.addEventListener("mouseDown",onSoundBtn,false,0,true);
         _popup.videoFrame.addEventListener("mouseDown",onVideoFrame,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _closeBtn.removeEventListener("mouseDown",onCloseButton);
         _soundBtn.removeEventListener("mouseDown",onSoundBtn);
         _popup.videoFrame.removeEventListener("mouseDown",onVideoFrame);
      }
      
      private function onExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
      }
      
      private function onRetry() : void
      {
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
      }
      
      private function hideAllWindows() : void
      {
         _popup.bigWindow1.visible = false;
         _popup.bigWindow2.visible = false;
         _popup.smWindow1.visible = false;
         _popup.smWindow2.visible = false;
         _popup.smWindow3.visible = false;
         _popup.chapterWindow.visible = false;
      }
      
      private function onMovieFinish() : void
      {
         var _loc1_:MovieNode = null;
         KeepAlive.inputReceivedHandler(null);
         if(_isSkipping)
         {
            return;
         }
         if(_currMovieNodeDef.denRewardId != 0)
         {
            _loc1_ = _currMovieNodeDef.isChapter ? _currMovieNodeDef : _prevMovieNodeDef;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(_loc1_.userVarId,_loc1_.bitIndex))
            {
               _prizeDenItem = new DenItem();
               _prizeDenItem.initShopItem(_currMovieNodeDef.denRewardId,0,true);
               _prizePopup = new GiftPopup();
               _prizePopup.init(this.parent,_prizeDenItem.icon,_prizeDenItem.name,_prizeDenItem.defId,2,2,keptItem,rejectedItem,destroyPrizePopup);
               return;
            }
         }
         showChooseScreen();
      }
      
      private function keptItem() : void
      {
         var _loc1_:Number = (gMainFrame.server.userId + 99) * 3 + (_serialNumber + 49) * 5 + (_currMovieNodeDef.defId + _serialNumber + 24);
         var _loc2_:Number = (_serialNumber + gMainFrame.server.userId) * 3;
         MinigameManager.msg(["hp",_loc1_,_loc2_,_prizeDenItem.version]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
         showChooseScreen();
      }
      
      private function showChooseScreen() : void
      {
         var shuffle:Boolean;
         var i:int;
         if(_currMovieNodeDef && _currMovieNodeDef.numChoices > 0)
         {
            with(_popup.outsideFrame)
            {
               
               while(xBtn2.numChildren > 0)
               {
                  xBtn2.removeChildAt(0);
               }
               xBtn2.addChild(_closeBtn);
               while(volBtn2.numChildren > 0)
               {
                  volBtn2.removeChildAt(0);
               }
               volBtn2.addChild(_soundBtn);
            }
            _popup.videoFrame.visible = false;
            _popup.outsideFrame.visible = true;
            hideAllWindows();
            if(_prevMovieNodeDef && (_currMovieNodeDef.choice1Id == _prevMovieNodeDef.defId || _currMovieNodeDef.choice2Id == _prevMovieNodeDef.defId || _currMovieNodeDef.choice3Id == _prevMovieNodeDef.defId))
            {
               _currMovieNodeDef.hasChosenThisChoice = true;
               _currMovieNodeDef = _prevMovieNodeDef;
            }
            else
            {
               _randomChoiceHolder = [];
               shuffle = true;
            }
            if(_currMovieNodeDef.numChoices == 1)
            {
               if(_currMovieNodeDef.isChapter)
               {
                  AchievementXtCommManager.requestSetUserVar(_currMovieNodeDef.userVarId,_currMovieNodeDef.bitIndex);
               }
               else
               {
                  AchievementXtCommManager.requestSetUserVar(_prevMovieNodeDef.userVarId,_prevMovieNodeDef.bitIndex);
               }
               onChoiceDown(null);
               return;
            }
            if(_CHOICE_SOUND_INSTANCE == null)
            {
               _CHOICE_SOUND_INSTANCE = _soundMan.play(CHOICE_SOUND,0,99999);
            }
            setAndSizeTitleTxt(LocalizationManager.translateIdOnly(_currMovieNodeDef.titleId).split("|")[1]);
            i = 1;
            while(i <= _currMovieNodeDef.numChoices)
            {
               if(_currMovieNodeDef.numChoices > 2)
               {
                  _loadingSpirals["spiral" + i].setNewParent(_popup["smWindow" + i]);
               }
               else
               {
                  _loadingSpirals["spiral" + i].setNewParent(_popup["bigWindow" + i]);
               }
               _loadingSpirals["spiral" + i].visible = true;
               _mediaHelper = new MediaHelper();
               _mediaHolder[i] = _mediaHelper;
               _mediaHelper.init(MovieXtCommManager.getMovieDef(_currMovieNodeDef.getChoiceById(i)).mediaId,onChoicesLoaded,{
                  "index":i,
                  "shuffle":shuffle
               });
               i++;
            }
         }
         else
         {
            if(_currMovieNodeDef)
            {
               AchievementXtCommManager.requestSetUserVar(_currMovieNodeDef.userVarId,_currMovieNodeDef.bitIndex);
            }
            _popup.parent.parent.x = 450;
            _popup.parent.parent.y = 275;
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(11132),true,onReplayConfirm);
            _popup.parent.parent.x = 0;
            _popup.parent.parent.y = 0;
         }
      }
      
      private function onChoicesLoaded(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = MovieClip(param1.getChildAt(0));
         _currChoiceHolder.push(_loc2_);
         if(MovieXtCommManager.getMovieNodeFromTree(_baseNodeDefId,_currMovieNodeDef.getChoiceById(param1.passback.index)).hasChosenThisChoice)
         {
            _loc2_.filters = [new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0])];
         }
         _loc2_.addEventListener("mouseDown",onChoiceDown,false,0,true);
         _loc2_.nextNodeId = _currMovieNodeDef.getChoiceById(param1.passback.index);
         _loc2_.windowIndex = param1.passback.index;
         _loc2_.txt.text = "";
         _mediaHelper = new MediaHelper();
         _iconMediaHolder[param1.passback.index] = _mediaHelper;
         _mediaHelper.init(MovieXtCommManager.getMovieDef(_loc2_.nextNodeId).iconMediaId,onIconsLoaded,_loc2_);
         _mediaHelper = new MediaHelper();
         _thumbMediaHolder[param1.passback.index] = _mediaHelper;
         _mediaHelper.init(MovieXtCommManager.getMovieDef(_loc2_.nextNodeId).thumbMediaId,onThumbsLoaded,_loc2_);
         onChoicesLocalization(LocalizationManager.translateIdOnly(MovieXtCommManager.getMovieDef(_loc2_.nextNodeId).titleId),{
            "currChoice":_loc2_,
            "shuffle":param1.passback.shuffle
         });
         if(_mediaHolder[param1.passback.index])
         {
            _mediaHolder[param1.passback.index].destroy();
         }
      }
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         param1.passback.iconWindow.addChild(MovieClip(param1.getChildAt(0)));
         _iconMediaHolder[param1.passback.windowIndex].destroy();
      }
      
      private function onThumbsLoaded(param1:MovieClip) : void
      {
         param1.passback.thumbItemWindow.addChild(MovieClip(param1.getChildAt(0)));
         _thumbMediaHolder[param1.passback.windowIndex].destroy();
      }
      
      private function onChoicesLocalization(param1:String, param2:Object) : void
      {
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         LocalizationManager.updateToFit(param2.currChoice.txt,param1.split("|")[0]);
         _loadingSpirals["spiral" + param2.currChoice.windowIndex].visible = false;
         var _loc5_:int = int(!!param2.shuffle ? Math.floor(Math.random() * (_currMovieNodeDef.numChoices - 1 + 1)) + 1 : _randomChoiceHolder[param2.currChoice.windowIndex]);
         if(param2.shuffle)
         {
            if(_randomChoiceHolder[param2.currChoice.windowIndex] == null)
            {
               _loc3_ = 0;
               while(_loc3_ < _randomChoiceHolder.length)
               {
                  if(_randomChoiceHolder[_loc3_] == _loc5_)
                  {
                     onChoicesLocalization(param1,param2);
                     return;
                  }
                  _loc3_++;
               }
            }
            _randomChoiceHolder[param2.currChoice.windowIndex] = _loc5_;
         }
         if(_currMovieNodeDef.numChoices > 2)
         {
            _loc4_ = _popup["smWindow" + _loc5_];
         }
         else
         {
            _loc4_ = _popup["bigWindow" + _loc5_];
         }
         if(_loc4_)
         {
            _loc4_.visible = true;
            while(_loc4_.numChildren > 0)
            {
               _loc4_.removeChildAt(0);
            }
            _loc4_.addChild(MovieClip(param2.currChoice));
         }
         _mediaHolder[param2.currChoice.windowIndex] = null;
      }
      
      private function setupStreamLocalization() : void
      {
         var streamDef:StreamDef;
         var streamDefs:StreamDefCollection;
         DarkenManager.showLoadingSpiral(false);
         if(_CHOICE_SOUND_INSTANCE)
         {
            _soundMan.stop(_CHOICE_SOUND_INSTANCE);
            _CHOICE_SOUND_INSTANCE = null;
         }
         streamDef = new StreamDef(_currMovieNodeDef.streamId,_currMovieNodeDef.thumbMediaId,"BradyExpeditions|" + _currMovieNodeDef.streamTitleId,0,_currMovieNodeDef.subtitleId);
         streamDefs = new StreamDefCollection();
         streamDefs.pushStreamDefItem(streamDef);
         _videoPlayer.init(streamDefs,-1,-1,false,768,432,onMovieFinish);
         setAndSizeTitleTxt(LocalizationManager.translateIdOnly(_currMovieNodeDef.streamTitleId));
         _popup.videoFrame.visible = true;
         _popup.outsideFrame.visible = false;
         with(_popup.videoFrame)
         {
            while(xBtn1.numChildren > 0)
            {
               xBtn1.removeChildAt(0);
            }
            xBtn1.addChild(_closeBtn);
            while(volBtn1.numChildren > 0)
            {
               volBtn1.removeChildAt(0);
            }
            volBtn1.addChild(_soundBtn);
         }
      }
      
      private function onchoicesTitleLocalizationReceived(param1:int, param2:String) : void
      {
         param2 = param2.split("|")[1];
         setAndSizeTitleTxt(param2);
      }
      
      private function setAndSizeTitleTxt(param1:String) : void
      {
         var text:String = param1;
         _popup.banner.visible = true;
         _popup.banner.titleTxt.text = text;
         with(_popup.banner)
         {
            m.width = Math.floor(titleTxt.width);
            l.x = titleTxt.x - (l.width - 5);
            m.x = Math.floor(l.x + l.width);
            r.x = m.x + m.width;
         }
      }
      
      private function chapterSelectDown(param1:MouseEvent) : void
      {
         var evt:MouseEvent = param1;
         evt.stopPropagation();
         if(evt.currentTarget.isGray)
         {
            return;
         }
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         _popup.chapterWindow.visible = false;
         _videoPlayer = new VideoPlayerOSMF();
         _popup.outsideFrame.visible = false;
         _popup.outsideFrame.chapterTitle.visible = false;
         _popup.videoFrame.visible = true;
         _selectionItemWindow.destroy();
         with(_popup.videoFrame)
         {
            while(xBtn1.numChildren > 0)
            {
               xBtn1.removeChildAt(0);
            }
            xBtn1.addChild(_closeBtn);
            while(volBtn1.numChildren > 0)
            {
               volBtn1.removeChildAt(0);
            }
            volBtn1.addChild(_soundBtn);
         }
         _popup.videoFrame.addChild(_videoPlayer);
         _popup.videoFrame.addEventListener("mouseDown",onVideoFrame,false,0,true);
         _currMovieNodeDef = evt.currentTarget.getMovieNodeDef();
         setupStreamLocalization();
      }
      
      private function onChoiceDown(param1:MouseEvent) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         KeepAlive.inputReceivedHandler(null);
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         DarkenManager.showLoadingSpiral(true);
         _prevMovieNodeDef = _currMovieNodeDef;
         _currMovieNodeDef = MovieXtCommManager.getMovieNodeFromTree(_baseNodeDefId,param1 != null ? param1.currentTarget.nextNodeId : _currMovieNodeDef.choice1Id);
         _loc2_ = 0;
         while(_loc2_ < _currChoiceHolder.length)
         {
            _loc3_ = _currChoiceHolder[_loc2_];
            _loc3_.removeEventListener("mouseDown",onChoiceDown);
            _loc3_ = null;
            _currChoiceHolder.splice(_loc2_,1);
            _loc2_--;
            _loc2_++;
         }
         hideAllWindows();
         setTimeout(setupStreamLocalization,41.666666666666664);
      }
      
      private function onSoundBtn(param1:MouseEvent) : void
      {
         var _loc2_:SoundTransform = null;
         param1.stopPropagation();
         SBAudio.toggleMuteAll();
         if(_videoPlayer)
         {
            _videoPlayer.toggleSound();
         }
         if(_CHOICE_SOUND_INSTANCE)
         {
            _loc2_ = _CHOICE_SOUND_INSTANCE.soundTransform;
            _loc2_.volume = SBAudio.areSoundsMuted ? 0 : 0.5;
            _CHOICE_SOUND_INSTANCE.soundTransform = _loc2_;
         }
      }
      
      private function onVideoFrame(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseButton(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_popup.chapterWindow.visible || _popup.pythonBtnCont.visible)
         {
            _popup.parent.parent.x = 450;
            _popup.parent.parent.y = 275;
            new SBLeaveCancelPopup(_guiLayer,LocalizationManager.translateIdOnly(11133),true,onConfirmClose);
            _popup.parent.parent.x = 0;
            _popup.parent.parent.y = 0;
         }
         else
         {
            if(_videoPlayer)
            {
               _videoPlayer.destroy();
            }
            setupSelectionScreen();
         }
      }
      
      private function onReplayConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            if(_videoPlayer)
            {
               _videoPlayer.destroy();
            }
            setupAdventureSelection();
         }
         else
         {
            end(null);
         }
      }
      
      private function onConfirmClose(param1:Object) : void
      {
         if(param1.status)
         {
            end(null);
         }
      }
   }
}

