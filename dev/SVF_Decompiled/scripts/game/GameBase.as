package game
{
   import com.hurlant.util.Base64;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.JPEGAsyncCompleteEvent;
   import com.sbi.graphics.JpegAsynchEncoder;
   import com.sbi.loader.LoaderCache;
   import com.sbi.loader.LoaderCacheEntry_URL;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.loader.SceneLoader;
   import com.sbi.popup.SBOkPopup;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.ProgressEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.printing.PrintJob;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loadProgress.LoadProgress;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class GameBase extends Sprite
   {
      private var _activeDlgMC:MovieClip;
      
      private var _activeDlg:GuiDialog;
      
      private var _guiButtons:Array;
      
      private var _gemMultiplierMC:MovieClip;
      
      private var _gemMultiplierMediaHelper:MediaHelper;
      
      private var _gameLoader:LoaderCacheEntry_URL;
      
      private var _sceneName:String;
      
      private var _audioFiles:Array;
      
      protected var _audioByName:Dictionary;
      
      protected var _pauseGame:Boolean;
      
      private var _trackerVal:Array;
      
      protected var _scene:SceneLoader;
      
      protected var _closeBtn:MovieClip;
      
      protected var _guiLayer:Sprite;
      
      private var _gameStartTime:int;
      
      public var _totalGemsEarned:int;
      
      protected var _gameIdleTimer:Number;
      
      private var _trackerMain:Array;
      
      private var _lastIdleTimer:Number;
      
      private var _kickPopup:SBOkPopup;
      
      protected var _miniGameDefID:int;
      
      private var _inRoomGame:Boolean;
      
      private var _trackerNum:Array;
      
      private var _onCloseCallback:Function;
      
      protected var pixelsPerIteration:int = 500;
      
      public function GameBase()
      {
         super();
         MinigameManager._pvpPromptReplay = false;
         _miniGameDefID = MinigameManager.minigameInfoCache.currMinigameId;
         _trackerVal = [];
         _trackerNum = [];
         _trackerMain = [];
         if(_miniGameDefID != -1)
         {
            _inRoomGame = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).isInRoomGame;
         }
         else
         {
            _inRoomGame = false;
         }
         _gameIdleTimer = 0;
         _totalGemsEarned = 0;
         _guiButtons = [];
         _audioByName = new Dictionary();
         _gameStartTime = getTimer();
      }
      
      public function get activeDlgMC() : MovieClip
      {
         return _activeDlgMC;
      }
      
      protected function loadScene(param1:String, param2:Array = null) : void
      {
         LoadProgress.show(true);
         _sceneName = param1;
         if(param2 == null)
         {
            param2 = [];
         }
         _audioFiles = param2;
         _gemMultiplierMediaHelper = new MediaHelper();
         _gemMultiplierMediaHelper.init(1067,gemMultiplierMediaHandler);
      }
      
      private function gemMultiplierMediaHandler(param1:MovieClip) : void
      {
         var handleAudioFilePreloaded:Function;
         var i:int;
         var curAudioFilename:String;
         var audioCDNRequest:URLRequest;
         var s:Sound;
         var mc:MovieClip = param1;
         _gemMultiplierMC = mc;
         var audioFilesLeftToLoad:int = int(_audioFiles.length);
         if(audioFilesLeftToLoad == 0)
         {
            audioFilesPreloadComplete();
         }
         handleAudioFilePreloaded = function(param1:Event):void
         {
            var _loc2_:String = null;
            var _loc4_:* = null;
            var _loc5_:Sound = param1.target as Sound;
            if(_loc5_)
            {
               _loc2_ = decodeURI(_loc5_.url);
               _loc4_ = _loc2_.slice(_loc2_.lastIndexOf("/") + 1,_loc2_.lastIndexOf("?"));
               if(_loc4_.substr(-4) != ".mp3")
               {
                  for each(var _loc3_ in _audioFiles)
                  {
                     if(LoaderCache.hashIt(_loc3_) == _loc4_)
                     {
                        _loc4_ = _loc3_;
                        break;
                     }
                  }
               }
               _audioByName[_loc4_] = _loc5_;
            }
            if(--audioFilesLeftToLoad <= 0)
            {
               audioFilesPreloadComplete();
            }
         };
         i = 0;
         while(i < _audioFiles.length)
         {
            curAudioFilename = _audioFiles[i];
            DebugUtility.debugTrace("loading audio file:" + curAudioFilename);
            audioCDNRequest = LoaderCache.fetchCDNURLRequest("audio/" + curAudioFilename);
            s = new Sound();
            s.addEventListener("complete",handleAudioFilePreloaded);
            s.addEventListener("ioError",function(param1:Event):void
            {
               DebugUtility.debugTrace("IOError loading audio file! e:" + param1);
            });
            s.load(audioCDNRequest,new SoundLoaderContext(1,true));
            ++i;
         }
      }
      
      private function audioFilesPreloadComplete() : void
      {
         _gameLoader = new LoaderCacheEntry_URL("roomDefs/" + _sceneName.toLowerCase());
         _gameLoader.addEventListener("OnLoadComplete",loadComplete);
         _gameLoader.load();
      }
      
      private function loadComplete(param1:LoaderEvent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = _gameLoader.data;
         _gameLoader.removeEventListener("OnLoadComplete",loadComplete);
         _scene = new SceneLoader();
         _scene.setScene(_loc2_,true);
         _scene.addEventListener("complete",sceneLoaded,false,0,true);
      }
      
      protected function releaseBase() : void
      {
         var _loc1_:Number = (getTimer() - _gameStartTime) / 1000;
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         if(stage)
         {
            stage.removeEventListener("keyDown",gemMultiplierCloseKeyDown);
            stage.removeEventListener("keyDown",resetKeyIdleTimer,false);
            stage.removeEventListener("mouseDown",resetMouseDownIdleTimer,false);
            stage.removeEventListener("mouseMove",resetMouseMoveIdleTimer,false);
            stage.removeEventListener("enterFrame",gameBaseHeartbeat);
         }
         for each(var _loc2_ in _guiButtons)
         {
            _loc2_.release();
         }
         _guiButtons = [];
         if(_scene)
         {
            _scene.release();
         }
         _gameLoader = null;
      }
      
      protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         LoadProgress.show(false);
         _scene.removeEventListener("complete",sceneLoaded);
         param1 = new Event("complete");
         dispatchEvent(param1);
         var _loc2_:Array = _scene.getActorList("ActorLayer");
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc4_ = _loc2_[_loc3_];
            if(_loc4_.s.content is MovieClip)
            {
               LocalizationManager.findAllTextfields(_loc4_.s.content);
            }
            _loc3_++;
         }
         _lastIdleTimer = getTimer();
         stage.addEventListener("keyDown",resetKeyIdleTimer,false);
         stage.addEventListener("mouseDown",resetMouseDownIdleTimer,false);
         stage.addEventListener("mouseMove",resetMouseMoveIdleTimer,false);
         stage.addEventListener("enterFrame",gameBaseHeartbeat);
      }
      
      private function gameBaseHeartbeat(param1:Event) : void
      {
         var _loc2_:Number = (getTimer() - _lastIdleTimer) / 1000;
         _lastIdleTimer = getTimer();
         if(_inRoomGame == false)
         {
            _gameIdleTimer += _loc2_;
            if(_gameIdleTimer > 180)
            {
               if(_gameIdleTimer > 240)
               {
                  if(this.hasOwnProperty("end"))
                  {
                     this["end"](null);
                  }
               }
               else if(_kickPopup == null)
               {
                  _kickPopup = new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14681),false,onKickWarningPopup);
                  AJAudio.playIdleWarningSound();
               }
            }
         }
      }
      
      private function onKickWarningPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         _kickPopup = null;
         _gameIdleTimer = 0;
      }
      
      private function resetKeyIdleTimer(param1:KeyboardEvent) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private function resetMouseMoveIdleTimer(param1:MouseEvent) : void
      {
         if(_kickPopup == null)
         {
            _gameIdleTimer = 0;
         }
      }
      
      private function resetMouseDownIdleTimer(param1:Event) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private function gemMultiplierClose() : void
      {
         stage.removeEventListener("keyDown",gemMultiplierCloseKeyDown);
         if(_onCloseCallback != null)
         {
            _onCloseCallback();
            _onCloseCallback = null;
         }
      }
      
      private function gemMultiplierCloseKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               gemMultiplierClose();
         }
      }
      
      protected function showGemMultiplierDlg(param1:Function) : MovieClip
      {
         var _loc3_:Number = NaN;
         var _loc2_:MovieClip = null;
         if(_totalGemsEarned > 0)
         {
            _loc3_ = 1;
            if(_miniGameDefID != -1)
            {
               _loc3_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).gemMultiplier;
            }
            if(_loc3_ > 1)
            {
               if(_activeDlg != null)
               {
                  hideDlg();
               }
               if(_activeDlg == null && _gemMultiplierMC)
               {
                  if(_closeBtn)
                  {
                     _closeBtn.visible = false;
                  }
                  _pauseGame = true;
                  _loc2_ = _gemMultiplierMC.getChildAt(0) as MovieClip;
                  _guiLayer.addChild(_loc2_);
                  _onCloseCallback = param1;
                  _activeDlg = new GuiDialog(_loc2_,[{
                     "name":"x_btn",
                     "f":param1
                  }]);
                  stage.addEventListener("keyDown",gemMultiplierCloseKeyDown);
                  _activeDlgMC = _loc2_;
                  _loc2_.x = 450;
                  _loc2_.y = 275;
                  LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,10062,_totalGemsEarned / _loc3_);
                  LocalizationManager.translateIdAndInsert(_loc2_.Gem_Bonus,10063,_loc3_);
                  LocalizationManager.translateIdAndInsert(_loc2_.Gems_Total,10064,_totalGemsEarned);
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      protected function showDlg(param1:String, param2:Array, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Boolean = false) : MovieClip
      {
         var _loc7_:MovieClip = null;
         if(!param5)
         {
            _loc7_ = GETDEFINITIONBYNAME(param1);
            _guiLayer.addChild(_loc7_);
            _loc7_.x = param3;
            _loc7_.y = param4;
         }
         else
         {
            if(_activeDlg != null)
            {
               hideDlg();
            }
            if(_activeDlg == null)
            {
               if(_closeBtn)
               {
                  _closeBtn.visible = false;
               }
               _pauseGame = true;
               _loc7_ = GETDEFINITIONBYNAME(param1);
               _guiLayer.addChild(_loc7_);
               _activeDlg = new GuiDialog(_loc7_,param2);
               _activeDlgMC = _loc7_;
               _activeDlgMC.darkened = param6;
               _activeDlgMC.x = param3;
               _activeDlgMC.y = param4;
               if(param6)
               {
                  DarkenManager.darken(_activeDlgMC);
               }
            }
         }
         return _loc7_;
      }
      
      protected function hideDlg() : void
      {
         if(_activeDlg)
         {
            _activeDlg.release();
            if(_activeDlgMC.darkened)
            {
               DarkenManager.unDarken(_activeDlgMC);
            }
            _guiLayer.removeChild(_activeDlgMC);
            _activeDlg = null;
            _activeDlgMC = null;
            _pauseGame = false;
            if(_closeBtn)
            {
               _closeBtn.visible = true;
            }
         }
      }
      
      protected function addBtn(param1:String, param2:int, param3:int, param4:Function) : MovieClip
      {
         var _loc6_:MovieClip = GETDEFINITIONBYNAME(param1);
         _loc6_.x = param2;
         _loc6_.y = param3;
         _guiLayer.addChild(_loc6_);
         var _loc5_:GuiButton = new GuiButton(_loc6_,param4);
         _guiButtons.push(_loc5_);
         _loc6_.guiBtn = _loc5_;
         return _loc6_;
      }
      
      private function mainTracker() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerNum.push(_trackerMain[_trackerMain.length - 1] - _loc1_ * 7 - 78922);
         numTracker();
      }
      
      protected function loadSound(param1:Class) : Sound
      {
         var _loc3_:Sound = new param1() as Sound;
         var _loc2_:SoundTransform = new SoundTransform(0,0);
         _loc3_.play(0,0,_loc2_);
         return _loc3_;
      }
      
      public function valueTrackerCommit() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
            if(_loc1_ != 0)
            {
               MinigameManager.sendScore(_trackerMain[_trackerMain.length - 1],_trackerVal[_trackerVal.length - 1],_trackerNum[_trackerNum.length - 1],_loc1_,_miniGameDefID);
            }
         }
      }
      
      protected function removeLayer(param1:Sprite) : void
      {
         while(param1.numChildren)
         {
            param1.removeChild(param1.getChildAt(0));
         }
         param1.parent.removeChild(param1);
      }
      
      protected function addToPetMastery(param1:int) : void
      {
         MinigameManager.awardPetMasteryPoints(param1);
      }
      
      private function numTracker() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerVal.push(_trackerNum[_trackerNum.length - 1] - _loc1_ * 9 + 15645);
      }
      
      protected function addGemsToBalance(param1:int) : void
      {
         var _loc2_:Number = 1;
         if(_miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).gemMultiplier;
         }
         if(_loc2_ > 1)
         {
            param1 *= _loc2_;
         }
         _totalGemsEarned += param1;
         MinigameManager.awardGems(param1,_miniGameDefID);
      }
      
      public function valueTrackerCurrent() : Number
      {
         var _loc1_:int = 0;
         if(_trackerMain.length > 0)
         {
            _loc1_ = 0;
            if(_miniGameDefID != -1)
            {
               _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
            }
            return 9999999 - (_trackerMain[_trackerMain.length - 1] - _loc1_ * 5 + MinigameManager.getScoreSN());
         }
         return 0;
      }
      
      public function getScene() : SceneLoader
      {
         return _scene;
      }
      
      public function getPaused() : Boolean
      {
         return _pauseGame;
      }
      
      public function getGuiLayer() : Sprite
      {
         return _guiLayer;
      }
      
      public function valueTracker(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerMain.push(9999999 - (param1 - _loc2_ * 5 + MinigameManager.getScoreSN()));
         if(_trackerMain.length >= 3)
         {
            _trackerMain.shift();
         }
         mainTracker();
      }
      
      protected function printOnePerPage(param1:DisplayObject, param2:int, param3:int, param4:Object, param5:String) : void
      {
         var page:Object;
         var pj:PrintJob;
         var bitmap:BitmapData;
         var activeImage:DisplayObject = param1;
         var xOffset:int = param2;
         var yOffset:int = param3;
         var printBackground:Object = param4;
         var orientation:String = param5;
         var encodeImage:* = function(param1:BitmapData, param2:Function):void
         {
            var encoder:JpegAsynchEncoder;
            var image:BitmapData = param1;
            var callback:Function = param2;
            DarkenManager.showLoadingSpiral(true,true);
            encoder = new JpegAsynchEncoder();
            encoder.addEventListener("progress",function(param1:ProgressEvent):void
            {
               DarkenManager.updateLoadingSpiralPercentage(Math.round(param1.bytesLoaded / param1.bytesTotal * 100) + "%");
            });
            encoder.addEventListener("JPEGAsyncComplete",function(param1:JPEGAsyncCompleteEvent):void
            {
               DarkenManager.showLoadingSpiral(false);
               callback(null,param1.ImageData);
            });
            encoder.PixelsPerIteration = pixelsPerIteration;
            encoder.JPEGAsyncEncoder(90);
            encoder.encode(image);
         };
         var preparePage:* = function(param1:int, param2:int):Object
         {
            var _loc6_:Number = NaN;
            var _loc3_:Number = NaN;
            var _loc13_:Number = NaN;
            var _loc14_:Number = NaN;
            if(printBackground)
            {
               _loc6_ = Number(printBackground.loader.content.scaleX);
               _loc3_ = Number(printBackground.loader.content.scaleY);
            }
            var _loc12_:Sprite = new Sprite();
            _loc12_.scaleX = 1;
            _loc12_.scaleY = 1;
            if(printBackground)
            {
               printBackground.loader.content.scaleX = 4;
               printBackground.loader.content.scaleY = 4;
            }
            var _loc5_:int = activeImage.scaleX;
            var _loc7_:int = activeImage.scaleY;
            activeImage.scaleX = 4;
            activeImage.scaleY = 4;
            if(printBackground)
            {
               _loc12_.addChild(printBackground.loader.content);
            }
            _loc12_.addChild(activeImage);
            _loc12_.x = xOffset;
            _loc12_.y = yOffset;
            var _loc8_:Number = _loc12_.width;
            var _loc15_:Number = _loc12_.height;
            var _loc9_:BitmapData = new BitmapData(_loc12_.width + 20,_loc12_.height + 20);
            _loc9_.draw(_loc12_,null,null,null,null,true);
            var _loc11_:Bitmap = new Bitmap(_loc9_);
            var _loc10_:Sprite = new Sprite();
            _loc10_.addChild(_loc11_);
            _loc11_.x = 0;
            _loc11_.y = 0;
            _loc11_.scaleX = 0.999;
            _loc11_.scaleY = 0.999;
            _loc10_.x = 0;
            _loc10_.y = 0;
            if(orientation != "landscape")
            {
               _loc10_.rotation = 90;
               _loc10_.x = _loc10_.width;
               _loc14_ = param1 / _loc15_;
               _loc13_ = param2 / _loc8_;
            }
            else
            {
               _loc14_ = param1 / _loc8_;
               _loc13_ = param2 / _loc15_;
            }
            _loc10_.scaleX = _loc10_.scaleY = Math.min(_loc14_,_loc13_);
            _loc10_.visible = false;
            gMainFrame.stage.addChild(_loc10_);
            if(printBackground)
            {
               printBackground.loader.content.scaleX = _loc6_;
               printBackground.loader.content.scaleY = _loc3_;
            }
            gMainFrame.stage.removeChild(_loc10_);
            activeImage.scaleX = _loc5_;
            activeImage.scaleY = _loc7_;
            return {
               "sprite":_loc10_,
               "height":Math.floor(_loc15_),
               "width":Math.floor(_loc8_)
            };
         };
         if(gMainFrame.clientInfo.clientPlatform.toLowerCase() != "electron")
         {
            pj = new PrintJob();
            if(pj.start())
            {
               page = preparePage(pj.pageWidth,pj.pageHeight);
               try
               {
                  pj.addPage(page.sprite,new Rectangle(0,0,page.width,page.height));
                  pj.send();
               }
               catch(e:Error)
               {
                  trace(e);
               }
            }
         }
         else
         {
            page = preparePage(3508,2480);
            bitmap = new BitmapData(page.width,page.height);
            bitmap.draw(page.sprite);
            encodeImage(bitmap,function(param1:*, param2:*):void
            {
               var _loc3_:String = Base64.encodeByteArray(param2);
               ExternalInterface.call("ajPrint",{
                  "image":_loc3_,
                  "width":page.width,
                  "height":page.height
               });
            });
         }
      }
   }
}

