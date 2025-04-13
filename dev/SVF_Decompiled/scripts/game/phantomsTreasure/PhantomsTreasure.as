package game.phantomsTreasure
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.BitmapData;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gskinner.motion.GTween;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PhantomsTreasure extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const HINT_STAGE1_RADIUS:Number = 150;
      
      private static const HINT_STAGE2_RADIUS:Number = 35;
      
      private static const HINT_STAGE2_TWEENTIME:Number = 3.5;
      
      private static const HINT_STAGE1_PAUSETIME:Number = 15;
      
      private static const MISS_PENALTY:Number = 20;
      
      private static const MISS_CLICK_DELAY_PENALTY:Number = 0.5;
      
      private static const PT_ACHIEVEMENTID_GAMECOUNT:int = 281;
      
      private static const PT_ACHIEVEMENTID_ITEMCOUNT:int = 282;
      
      private static const PT_ACHIEVEMENTID_LEVELBEST_TIME:int = 283;
      
      private static const PT_ACHIEVEMENT_LEVELBEST_TIME:int = 60;
      
      private static const MAX_HINT_COUNT:int = 3;
      
      private static const POINTS_PER_HINT_REMAINING:int = 300;
      
      private var _background:Sprite;
      
      private var _foreground:Sprite;
      
      private var _levelScore:int;
      
      private var _gemsEarned:int;
      
      private var _allGemsEarned:int;
      
      private var _timeSinceLastFind:Number;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _totalLevelTime:Number;
      
      private var _levelComplete:Boolean;
      
      private var _ui:Object;
      
      private var _hintOverlay:Object;
      
      private var _hintButton:MovieClip;
      
      private var _hintCount:int;
      
      private var _hintActive:Boolean;
      
      private var _hintTimer:Number;
      
      private var _hintCenterX:Number;
      
      private var _hintCenterY:Number;
      
      public var _displayAchievementTimer:Number;
      
      private var _hiddenObjects:Array;
      
      private var _previewObjects:Array;
      
      private var _levelBackground:Object;
      
      private var _missObjects:Array;
      
      private var _clickPenaltyTimer:Number;
      
      public var _soundMan:SoundManager;
      
      public var _factsOrder:Array;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _greatJobPopup:MovieClip;
      
      private var _factImageMediaObject:MovieClip;
      
      public var _levelProgression:Array;
      
      public var _currentStage:int;
      
      public var _backgroundIndex:int;
      
      public var _currentLevel:int;
      
      public var _itemsRemaining:int;
      
      public var _theRipples:Array;
      
      private var _bInit:Boolean;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var _soundNameNewRound:String;
      
      private var _soundNameCorrect:String;
      
      private var _soundNameIncorrect:String;
      
      private var _soundNamePopup:String;
      
      public var _data:PhantomsTreasureData;
      
      public function PhantomsTreasure()
      {
         super();
         _data = new PhantomsTreasureData();
         init();
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         init();
      }
      
      private function init() : void
      {
         var _loc1_:int = 0;
         _hintButton = null;
         _displayAchievementTimer = 0;
         _allGemsEarned = 0;
         _theRipples = [];
         _lastTime = getTimer();
         _factsOrder = [];
         _loc1_ = 0;
         while(_loc1_ < _data._facts.length)
         {
            _factsOrder.push(_loc1_);
            _loc1_++;
         }
         _factsOrder = randomizeArray(_factsOrder);
         _factsIndex = 0;
         if(!_bInit)
         {
            _background = new Sprite();
            _foreground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_foreground);
            addChild(_guiLayer);
            loadScene("PhantomsTreasure/room_main.xroom",_data._audio);
            _mediaObjectHelper = null;
            _loadingImage = false;
            _greatJobPopup = null;
            _factImageMediaObject = null;
            _bInit = true;
         }
      }
      
      public function loadNextFactImage() : void
      {
         if(!_loadingImage)
         {
            _factsIndex++;
            if(_factsIndex >= _factsOrder.length)
            {
               _factsIndex = 0;
            }
            _loadingImage = true;
            if(_mediaObjectHelper != null)
            {
               _mediaObjectHelper.destroy();
            }
            _mediaObjectHelper = new MediaHelper();
            _mediaObjectHelper.init(_data._facts[_factsOrder[_factsIndex]].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         if(_factImageMediaObject != null && _greatJobPopup)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
         }
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
         if(_greatJobPopup)
         {
            _greatJobPopup.result_pic.addChild(_factImageMediaObject);
         }
         _loadingImage = false;
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_mus_phantoms_treasure",0.6);
         _soundNameNewRound = _data._audio[0];
         _soundNameCorrect = _data._audio[1];
         _soundNameIncorrect = _data._audio[2];
         _soundNamePopup = _data._audio[3];
         _soundMan.addSoundByName(_audioByName[_soundNameNewRound],_soundNameNewRound,0.96);
         _soundMan.addSoundByName(_audioByName[_soundNameCorrect],_soundNameCorrect,0.76);
         _soundMan.addSoundByName(_audioByName[_soundNameIncorrect],_soundNameIncorrect,0.86);
         _soundMan.addSoundByName(_audioByName[_soundNamePopup],_soundNamePopup,1);
      }
      
      public function message(param1:Array) : void
      {
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function exit() : void
      {
         cleanUpLevel();
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",showGreatJobKeyDown);
         stage.removeEventListener("keyDown",showFactKeyDown);
         stage.removeEventListener("keyDown",optionsKeyDown);
         removeEventListener("enterFrame",Heartbeat);
         stage.removeEventListener("click",onMouseClick);
         removeLayer(_background);
         removeLayer(_foreground);
         removeLayer(_guiLayer);
         _background = null;
         _foreground = null;
         _guiLayer = null;
         MinigameManager.leave();
         _bInit = false;
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:Number = param1.length - 1;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc2_ = Math.round(Math.random() * _loc5_);
            _loc3_ = int(param1[_loc4_]);
            param1[_loc4_] = param1[_loc2_];
            param1[_loc2_] = _loc3_;
            _loc4_++;
         }
         return param1;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_Music,0,999999);
         _ui = _scene.getLayer("ui");
         _ui.loader.x = 0;
         _ui.loader.y = 0;
         _guiLayer.addChild(_ui.loader);
         _foreground.mouseEnabled = false;
         _hintOverlay = _scene.getLayer("hint");
         _hintOverlay.loader.content.gotoAndPlay("off");
         _hintOverlay.loader.mouseEnabled = false;
         _hintOverlay.loader.mouseChildren = false;
         _foreground.addChild(_hintOverlay.loader);
         addEventListener("enterFrame",Heartbeat);
         stage.addEventListener("click",onMouseClick);
         _loc3_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,5,showOptions);
         _hintButton = addBtn("chest",726,440,hintButtonPressed);
         _totalGameTime = 0;
         _levelProgression = [];
         _currentStage = 0;
         _currentLevel = -1;
         super.sceneLoaded(param1);
         showTitleScreen();
      }
      
      private function Heartbeat(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc7_:GTween = null;
         var _loc5_:Number = (getTimer() - _lastTime) / 1000;
         _lastTime = getTimer();
         _clickPenaltyTimer -= _loc5_;
         if(_pauseGame)
         {
            _hintOverlay.loader.content.pauseGame();
            return;
         }
         _hintOverlay.loader.content.unpauseGame();
         _totalGameTime += _loc5_;
         _timeSinceLastFind += _loc5_;
         if(_levelComplete == false)
         {
            _totalLevelTime += _loc5_;
         }
         if(_totalLevelTime >= 15 && _totalLevelTime - _loc5_ < 15)
         {
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               AchievementXtCommManager.requestSetUserVar(281,1);
               _displayAchievementTimer = 1;
            }
         }
         var _loc3_:int = _totalLevelTime / 60;
         var _loc2_:int = _totalLevelTime - _loc3_ * 60;
         if(_loc3_ < 10)
         {
            _ui.loader.content.time.text = "0" + _loc3_ + ":";
         }
         else
         {
            _ui.loader.content.time.text = _loc3_ + ":";
         }
         if(_loc2_ < 10)
         {
            _ui.loader.content.time.text += "0" + _loc2_;
         }
         else
         {
            _ui.loader.content.time.text += _loc2_;
         }
         if(_hintActive)
         {
            if(_hintTimer > 0)
            {
               _hintTimer -= _loc5_;
               if(_hintTimer <= 0)
               {
                  _loc4_ = _hintCenterX - 35 + Math.random() * 35 * 2;
                  _loc9_ = _hintCenterY - 35 + Math.random() * 35 * 2;
                  if(_loc4_ < 50)
                  {
                     _loc4_ = 50;
                  }
                  if(_loc4_ > 850)
                  {
                     _loc4_ = 850;
                  }
                  if(_loc9_ < 50)
                  {
                     _loc9_ = 50;
                  }
                  if(_loc9_ > 400)
                  {
                     _loc9_ = 400;
                  }
                  _loc7_ = new GTween(_hintOverlay.loader,3.5,{
                     "x":_loc4_,
                     "y":_loc9_
                  });
                  _hintOverlay.loader.content.gotoAndPlay("stage2");
               }
            }
         }
         if(_missObjects)
         {
            _loc6_ = _missObjects.length - 1;
            while(_loc6_ >= 0)
            {
               if(_missObjects[_loc6_].loader["content"] && _missObjects[_loc6_].loader["content"].finished)
               {
                  removeMissObject(_loc6_);
               }
               _loc6_--;
            }
         }
         if(_displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _loc5_;
            if(_displayAchievementTimer <= 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
      }
      
      private function onMouseClick(param1:MouseEvent) : void
      {
      }
      
      private function addRipple() : void
      {
         var _loc1_:PhantomsTreasureRipple = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _theRipples.length)
         {
            if(_theRipples[_loc2_]._rippleComplete)
            {
               _theRipples[_loc2_].rippleIt();
               return;
            }
            _loc2_++;
         }
         _loc1_ = new PhantomsTreasureRipple(_background);
         _loc1_.rippleIt();
         _theRipples.push(_loc1_);
      }
      
      private function addMiss(param1:Number, param2:Number) : void
      {
         var _loc3_:Object = null;
         _loc3_ = _scene.cloneAsset("missobject");
         _loc3_.loader.x = param1;
         _loc3_.loader.y = param2;
         _foreground.addChild(_loc3_.loader);
         _loc3_.loader.contentLoaderInfo.addEventListener("complete",onMissComplete);
         _missObjects.push(_loc3_);
         _soundMan.playByName(_soundNameIncorrect);
      }
      
      private function onBackgroundClick(param1:MouseEvent) : void
      {
         if(_clickPenaltyTimer <= 0 && !_pauseGame && _levelComplete == false)
         {
            addRipple();
            addMiss(param1.stageX,param1.stageY);
            _clickPenaltyTimer = 0.5;
         }
      }
      
      public function onMissComplete(param1:Event) : void
      {
         _totalLevelTime += 20;
         param1.target.content.miss("-20");
         param1.target.removeEventListener("complete",onMissComplete);
      }
      
      private function onHiddenObjectClick(param1:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         if(!_pauseGame && _clickPenaltyTimer <= 0)
         {
            _loc2_ = true;
            _loc3_ = 0;
            while(_loc3_ < _hiddenObjects.length)
            {
               if(param1.currentTarget == _hiddenObjects[_loc3_].loader)
               {
                  if(testForMouseHit(_hiddenObjects[_loc3_],param1.localX,param1.localY))
                  {
                     _soundMan.playByName(_soundNameCorrect);
                     if(_hintActive)
                     {
                        if(_hintCount < 3)
                        {
                           _hintButton.mouseEnabled = true;
                           _hintButton.mouseChildren = true;
                        }
                        _hintActive = false;
                        _hintOverlay.loader.content.gotoAndPlay("stage3");
                     }
                     if(_timeSinceLastFind > 8)
                     {
                        _levelScore += 100;
                     }
                     else if(_timeSinceLastFind > 6)
                     {
                        _levelScore += 200;
                     }
                     else if(_timeSinceLastFind > 4)
                     {
                        _levelScore += 300;
                     }
                     else if(_timeSinceLastFind > 2)
                     {
                        _levelScore += 400;
                     }
                     else
                     {
                        _levelScore += 500;
                     }
                     _timeSinceLastFind = 0;
                     _hiddenObjects[_loc3_].loader["content"].correct();
                     _previewObjects[_loc3_].loader["content"].correct();
                     _itemsRemaining--;
                     param1.currentTarget.removeEventListener("click",onHiddenObjectClick);
                     param1.currentTarget.mouseEnabled = false;
                     param1.currentTarget.content.mouseEnabled = false;
                     param1.currentTarget.mouseChildren = false;
                     param1.currentTarget.content.mouseChildren = false;
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(282,1);
                        _displayAchievementTimer = 1;
                     }
                     if(!_levelComplete && _itemsRemaining == 0)
                     {
                        if(_totalLevelTime <= 60)
                        {
                           if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                           {
                              AchievementXtCommManager.requestSetUserVar(283,1);
                              _displayAchievementTimer = 1;
                           }
                        }
                        _levelComplete = true;
                        if(_hintCount < 3)
                        {
                           _levelScore += 300 * (3 - _hintCount);
                        }
                        _gemsEarned = _levelScore / 100;
                        _allGemsEarned += _gemsEarned;
                        addGemsToBalance(_gemsEarned);
                        showFactPopup();
                     }
                     break;
                  }
                  addMiss(param1.stageX,param1.stageY);
                  break;
               }
               _loc3_++;
            }
            if(_loc2_)
            {
               addRipple();
            }
         }
      }
      
      public function onHiddenComplete(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:String = null;
         _loc3_ = 0;
         while(_loc3_ < _hiddenObjects.length)
         {
            if(param1.target.loader == _hiddenObjects[_loc3_].loader)
            {
               _loc2_ = _backgroundIndex + 1 + "_" + (_hiddenObjects[_loc3_].objectID + 1);
               switch(_backgroundIndex)
               {
                  case 0:
                     Loader(_hiddenObjects[_loc3_].loader).x = _hiddenObjects[_loc3_].loader["content"].positions1[_hiddenObjects[_loc3_].objectID][0];
                     Loader(_hiddenObjects[_loc3_].loader).y = _hiddenObjects[_loc3_].loader["content"].positions1[_hiddenObjects[_loc3_].objectID][1];
                     break;
                  case 1:
                     Loader(_hiddenObjects[_loc3_].loader).x = _hiddenObjects[_loc3_].loader["content"].positions2[_hiddenObjects[_loc3_].objectID][0];
                     Loader(_hiddenObjects[_loc3_].loader).y = _hiddenObjects[_loc3_].loader["content"].positions2[_hiddenObjects[_loc3_].objectID][1];
                     break;
                  case 2:
                     Loader(_hiddenObjects[_loc3_].loader).x = _hiddenObjects[_loc3_].loader["content"].positions3[_hiddenObjects[_loc3_].objectID][0];
                     Loader(_hiddenObjects[_loc3_].loader).y = _hiddenObjects[_loc3_].loader["content"].positions3[_hiddenObjects[_loc3_].objectID][1];
               }
               _hiddenObjects[_loc3_].loader["content"].showObject(_loc2_);
               break;
            }
            _loc3_++;
         }
         param1.target.removeEventListener("complete",onHiddenComplete);
      }
      
      public function onPreviewComplete(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:String = null;
         _loc3_ = 0;
         while(_loc3_ < _previewObjects.length)
         {
            if(param1.target.loader == _previewObjects[_loc3_].loader)
            {
               _loc2_ = _backgroundIndex + 1 + "_" + (_previewObjects[_loc3_].objectID + 1);
               _previewObjects[_loc3_].loader["content"].showPreview(_loc2_);
               break;
            }
            _loc3_++;
         }
         param1.target.removeEventListener("complete",onPreviewComplete);
      }
      
      public function addObject(param1:int, param2:int) : void
      {
         var _loc4_:Object = null;
         var _loc3_:Object = null;
         _loc4_ = _scene.cloneAsset("hiddenobject");
         _loc4_.objectID = param1;
         _loc3_ = _scene.cloneAsset("hiddenobject");
         _loc3_.objectID = param1;
         _loc3_.loader.x = _ui.loader.content.previewPositions[param2][0];
         _loc3_.loader.y = _ui.loader.content.previewPositions[param2][1];
         _loc4_.loader.addEventListener("click",onHiddenObjectClick);
         _background.addChild(_loc4_.loader);
         _loc4_.loader.contentLoaderInfo.addEventListener("complete",onHiddenComplete);
         _hiddenObjects.push(_loc4_);
         _guiLayer.addChild(_loc3_.loader);
         _loc3_.loader.contentLoaderInfo.addEventListener("complete",onPreviewComplete);
         _previewObjects.push(_loc3_);
         switch(param2)
         {
            case 0:
               LocalizationManager.translateId(_ui.loader.content.object1,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 1:
               LocalizationManager.translateId(_ui.loader.content.object2,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 2:
               LocalizationManager.translateId(_ui.loader.content.object3,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 3:
               LocalizationManager.translateId(_ui.loader.content.object4,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 4:
               LocalizationManager.translateId(_ui.loader.content.object5,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 5:
               LocalizationManager.translateId(_ui.loader.content.object6,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 6:
               LocalizationManager.translateId(_ui.loader.content.object7,_data._itemNames[_backgroundIndex].items[param1]);
               break;
            case 7:
               LocalizationManager.translateId(_ui.loader.content.object8,_data._itemNames[_backgroundIndex].items[param1]);
         }
      }
      
      private function setUpLevelProgression() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Array = [];
         _loc1_ = 0;
         while(_loc1_ < _data._levelProgression[_currentStage].items.length)
         {
            _loc2_.push(_loc1_);
            _loc1_++;
         }
         do
         {
            _loc2_ = randomizeArray(_loc2_);
            _loc2_ = randomizeArray(_loc2_);
         }
         while(_loc2_[0] == _levelProgression[_currentStage][0]);
         
         _levelProgression[_currentStage] = _loc2_;
      }
      
      private function setLevel(param1:int) : void
      {
         _currentStage = param1;
         _currentLevel = -1;
         var _loc3_:Array = [];
         _loc3_.push(-1);
         _levelProgression[_currentStage] = _loc3_;
         setUpLevelProgression();
         setNextLevel();
      }
      
      private function setNextLevel() : void
      {
         var _loc1_:int = 0;
         if(_soundMan != null && _musicLoop == null)
         {
            _musicLoop = _soundMan.playStream(_SFX_Music,0,999999);
         }
         _soundMan.playByName(_soundNameNewRound);
         _clickPenaltyTimer = 0;
         _levelScore = 0;
         _gemsEarned = 0;
         _timeSinceLastFind = 0;
         _currentLevel++;
         if(_currentLevel >= _levelProgression[_currentStage].length)
         {
            _currentLevel = 0;
            setUpLevelProgression();
         }
         _ui.loader.content.time.text = "0:00";
         _hintButton.resetHints();
         _hintCount = 0;
         _hintButton.mouseEnabled = true;
         _hintButton.mouseChildren = true;
         _hintActive = false;
         _hintOverlay.loader.content.gotoAndPlay("off");
         _totalLevelTime = 0;
         _levelComplete = false;
         cleanUpLevel();
         _missObjects = [];
         _hiddenObjects = [];
         _previewObjects = [];
         switch(_data._levelProgression[_currentStage].background)
         {
            case 1:
               _backgroundIndex = 0;
               _levelBackground = _scene.getLayer("background1");
               break;
            case 2:
               _backgroundIndex = 1;
               _levelBackground = _scene.getLayer("background2");
               break;
            case 3:
               _backgroundIndex = 2;
               _levelBackground = _scene.getLayer("background3");
         }
         _levelBackground.loader.x = 0;
         _levelBackground.loader.y = 0;
         _background.addChild(_levelBackground.loader);
         _levelBackground.loader.addEventListener("click",onBackgroundClick);
         var _loc2_:Array = [];
         _loc1_ = 0;
         while(_loc1_ < _data._levelProgression[_currentStage].items[_levelProgression[_currentStage][_currentLevel]].length)
         {
            _loc2_.push(_data._levelProgression[_currentStage].items[_levelProgression[_currentStage][_currentLevel]][_loc1_]);
            _loc1_++;
         }
         _loc2_ = randomizeArray(_loc2_);
         _loc2_ = randomizeArray(_loc2_);
         _itemsRemaining = 0;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            addObject(_loc2_[_loc1_] - 1,_loc1_);
            _itemsRemaining++;
            _loc1_++;
         }
         if(_factImageMediaObject && _greatJobPopup != null)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
            _factImageMediaObject = null;
         }
         if(!_loadingImage)
         {
            loadNextFactImage();
         }
         _greatJobPopup = null;
      }
      
      private function endLevel() : void
      {
      }
      
      private function removeMissObject(param1:int) : void
      {
         if(Loader(_missObjects[param1].loader).parent)
         {
            Loader(_missObjects[param1].loader).parent.removeChild(_missObjects[param1].loader);
         }
         _scene.releaseCloneAsset(_missObjects[param1].loader);
         _missObjects.splice(param1,1);
      }
      
      private function cleanUpLevel() : void
      {
         if(_levelBackground)
         {
            if(_levelBackground.loader.parent)
            {
               _levelBackground.loader.parent.removeChild(_levelBackground.loader);
               _levelBackground.loader.removeEventListener("click",onBackgroundClick);
               _levelBackground = null;
            }
         }
         if(_hiddenObjects)
         {
            while(_hiddenObjects.length > 0)
            {
               if(Loader(_hiddenObjects[0].loader).parent)
               {
                  Loader(_hiddenObjects[0].loader).parent.removeChild(_hiddenObjects[0].loader);
               }
               Loader(_hiddenObjects[0].loader).removeEventListener("click",onHiddenObjectClick);
               _scene.releaseCloneAsset(_hiddenObjects[0].loader);
               _hiddenObjects.splice(0,1);
            }
         }
         if(_previewObjects)
         {
            while(_previewObjects.length > 0)
            {
               if(Loader(_previewObjects[0].loader).parent)
               {
                  Loader(_previewObjects[0].loader).parent.removeChild(_previewObjects[0].loader);
               }
               _scene.releaseCloneAsset(_previewObjects[0].loader);
               _previewObjects.splice(0,1);
            }
         }
         if(_missObjects)
         {
            while(_missObjects.length > 0)
            {
               removeMissObject(0);
            }
         }
      }
      
      private function hintButtonPressed() : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(!_pauseGame && _hintActive == false && _hintCount < 3)
         {
            _hintCount++;
            _hintButton.hint(_hintCount);
            _hintButton.mouseEnabled = false;
            _hintButton.mouseChildren = false;
            _loc2_ = 0;
            _loc3_ = 0;
            while(_loc3_ < _hiddenObjects.length)
            {
               if(!_hiddenObjects[_loc3_].loader["content"].collected)
               {
                  _loc2_++;
               }
               _loc3_++;
            }
            if(_loc2_ > 0)
            {
               _loc1_ = Math.random() * _loc2_;
               _loc3_ = 0;
               while(_loc3_ < _hiddenObjects.length)
               {
                  if(!_hiddenObjects[_loc3_].loader["content"].collected)
                  {
                     _loc1_--;
                     if(_loc1_ < 0)
                     {
                        _hintCenterX = Loader(_hiddenObjects[_loc3_].loader).x + _hiddenObjects[_loc3_].loader["width"] / 2;
                        _hintCenterY = Loader(_hiddenObjects[_loc3_].loader).y + _hiddenObjects[_loc3_].loader["height"] / 2;
                        if(_hintCenterX < 50)
                        {
                           _hintCenterX = 50;
                        }
                        if(_hintCenterX > 850)
                        {
                           _hintCenterX = 850;
                        }
                        if(_hintCenterY < 50)
                        {
                           _hintCenterY = 50;
                        }
                        if(_hintCenterY > 400)
                        {
                           _hintCenterY = 400;
                        }
                        break;
                     }
                  }
                  _loc3_++;
               }
            }
            _hintActive = true;
            _hintTimer = 15;
            _hintOverlay.loader.x = _hintCenterX - 150 + Math.random() * 150 * 2;
            _hintOverlay.loader.y = _hintCenterY - 150 + Math.random() * 150 * 2;
            _hintOverlay.loader.content.gotoAndPlay("stage1");
         }
      }
      
      private function testForMouseHit(param1:Object, param2:Number, param3:Number) : Boolean
      {
         var _loc4_:BitmapData = new BitmapData(param1.loader.width,param1.loader.height,true,0);
         _loc4_.draw(param1.loader.content);
         return _loc4_.hitTest(new Point(0,0),1,new Point(param2,param3));
      }
      
      private function optionsKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 8:
            case 46:
            case 27:
               onUnpause();
         }
      }
      
      private function showOptions() : void
      {
         var _loc1_:MovieClip = showDlg("PhTr_Options",[{
            "name":"btn_unpauseGame",
            "f":onUnpause
         },{
            "name":"btn_levelSelect",
            "f":onLevelSelect
         },{
            "name":"btn_exitGame",
            "f":showExitConfirmationDlg
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",optionsKeyDown);
      }
      
      private function onUnpause() : void
      {
         stage.removeEventListener("keyDown",optionsKeyDown);
         hideDlg();
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            exit();
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         exit();
      }
      
      private function onExit_No() : void
      {
         hideDlg();
         showOptions();
      }
      
      private function showTitleScreen() : void
      {
         if(_soundMan != null && _musicLoop == null)
         {
            _musicLoop = _soundMan.playStream(_SFX_Music,0,999999);
         }
         var _loc1_:MovieClip = showDlg("PhTr_TitleScreen",[{
            "name":"btn_level1",
            "f":showLevelSelect
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function showLevelSelect() : void
      {
         var _loc1_:MovieClip = showDlg("PhTr_LevelSelect",[{
            "name":"btn_level1",
            "f":onLevelSelect1
         },{
            "name":"btn_level2",
            "f":onLevelSelect2
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onLevelSelect1() : void
      {
         hideDlg();
         setLevel(0);
      }
      
      private function onLevelSelect2() : void
      {
         hideDlg();
         setLevel(1);
      }
      
      private function showFactKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGreatJob();
         }
      }
      
      private function showFactPopup() : void
      {
         var _loc1_:MovieClip = showDlg("PhTr_Result",[{
            "name":"continue_btn",
            "f":showGreatJob
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",showFactKeyDown);
         _greatJobPopup = _loc1_;
         if(_factImageMediaObject)
         {
            _greatJobPopup.result_pic.addChild(_factImageMediaObject);
         }
         LocalizationManager.translateId(_loc1_.result_factCont.result_fact,_data._facts[_factsOrder[_factsIndex]].text);
         _soundMan.playByName(_soundNamePopup);
      }
      
      private function showGreatJobKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onNextLevel();
               break;
            case 8:
            case 46:
            case 27:
               onLevelSelect();
         }
      }
      
      private function showGreatJob() : void
      {
         stage.removeEventListener("keyDown",showFactKeyDown);
         hideDlg();
         _greatJobPopup = null;
         var _loc1_:MovieClip = showDlg("Great_Job_PhTr",[{
            "name":"button_levelSelect",
            "f":onLevelSelect
         },{
            "name":"button_nextlevel",
            "f":onNextLevel
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",showGreatJobKeyDown);
         LocalizationManager.translateIdAndInsert(_loc1_.text_time,11800,_ui.loader.content.time.text);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11554,_gemsEarned);
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Total,11549,_allGemsEarned);
      }
      
      private function onLevelSelect() : void
      {
         stage.removeEventListener("keyDown",showGreatJobKeyDown);
         hideDlg();
         showLevelSelect();
      }
      
      private function onNextLevel() : void
      {
         stage.removeEventListener("keyDown",showGreatJobKeyDown);
         hideDlg();
         setNextLevel();
      }
   }
}

