package game.windRider
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import giftPopup.GiftPopup;
   import gui.LoadingSpiral;
   import item.Item;
   import localization.LocalizationManager;
   
   public class WindRider extends GameBase implements IMinigame
   {
      private static const OFFSCREEN_ADD_HEIGHT:int = 900;
      
      private static const OFFSCREEN_REMOVE_HEIGHT:int = 100;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_READY_TO_START:int = 1;
      
      public static const GAMESTATE_STARTED:int = 2;
      
      public static const GAMESTATE_ENDED:int = 3;
      
      public static const GAMESTATE_LOAD_PLAYERS:int = 4;
      
      public static const PHANTOMSPEED:Number = 40;
      
      public static const MAX_PHANTOM_MOVE:Number = 200;
      
      public static const STAGE_OFFSET:Number = 40;
      
      public static const PHANTOM_OFFSET:Number = 20;
      
      public var _levelData:WindRiderData;
      
      public var _levelIndex:int;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      private var _prizeAccessory:Item;
      
      private var _prizePopup:GiftPopup;
      
      public var _layerGround:Sprite;
      
      public var _layerBackground:Sprite;
      
      public var _layerMidground:Sprite;
      
      public var _layerObstacles:Sprite;
      
      public var _layerGems:Sprite;
      
      public var _layerClouds:Sprite;
      
      public var _layerPlayers:Sprite;
      
      public var _lastCloudRow:int;
      
      public var _groundOff:Boolean;
      
      public var _progressBar:Object;
      
      public var _progressBarP1:Object;
      
      public var _progressBarP2:Object;
      
      public var _backgroundMoveSpeed:Number;
      
      public var _foregroundMoveSpeed:Number;
      
      public var _ground:Object;
      
      public var _gameState:int;
      
      public var _players:Array;
      
      private var _scoreDisplay:Object;
      
      private var _debugDisplay:Object;
      
      public var _gameOverTimer:Number;
      
      public var _prizePopupDelay:Number;
      
      public var _gemsActive:Array;
      
      public var _gemsInactive:Array;
      
      public var _cloudsActive:Array;
      
      public var _cloudsInactive:Array;
      
      public var _phantomsActive:Array;
      
      public var _phantomsInactive:Array;
      
      public var _branchesActive:Array;
      
      public var _branchesInactive:Array;
      
      public var _midgroundActive:Array;
      
      public var _midgroundInactive:Array;
      
      public var _midgroundAddY:Number;
      
      public var _treasure:Object;
      
      public var _displayAchievementTimer:Number;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      public var _readySetGo:Number;
      
      public var _readyMC:Object;
      
      public var _controlsMC:Object;
      
      public var _controlsKeyPressed:Boolean;
      
      public var _success:Boolean;
      
      public var _currentDataIndex:int;
      
      public var _currentCloudIndex:int;
      
      public var _playerHeight:int;
      
      public var _foreground:Object;
      
      public var _spiral:LoadingSpiral;
      
      public var _soundMan:SoundManager;
      
      private var _soundNameReadyGo:String = WindRiderData._audio[0];
      
      internal var _soundNameCloudBurst1:String = WindRiderData._audio[1];
      
      internal var _soundNameCloudBurst2:String = WindRiderData._audio[2];
      
      internal var _soundNameCloudBurst3:String = WindRiderData._audio[3];
      
      internal var _soundNamePhantomShock:String = WindRiderData._audio[4];
      
      internal var _soundNameTreasureChest:String = WindRiderData._audio[5];
      
      internal var _soundNameGemAdded:String = WindRiderData._audio[6];
      
      internal var _soundNamePlayerWin:String = WindRiderData._audio[7];
      
      internal var _soundNamePlayerLose:String = WindRiderData._audio[8];
      
      public var SFX_PhantomIdle:Class;
      
      public var _SFX_WindRider_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      private var _phantomIdleSound:SoundChannel;
      
      public function WindRider()
      {
         super();
         _players = [];
         _levelData = new WindRiderData();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_WindRider_Music = _soundMan.addStream("aj_mus_sky_high",0.95);
         _soundMan.addSoundByName(_audioByName[_soundNameReadyGo],_soundNameReadyGo,0.64);
         _soundMan.addSoundByName(_audioByName[_soundNameCloudBurst1],_soundNameCloudBurst1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCloudBurst2],_soundNameCloudBurst2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCloudBurst3],_soundNameCloudBurst3,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomShock],_soundNamePhantomShock,1);
         _soundMan.addSoundByName(_audioByName[_soundNameTreasureChest],_soundNameTreasureChest,1);
         _soundMan.addSoundByName(_audioByName[_soundNameGemAdded],_soundNameGemAdded,0.7);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerWin],_soundNamePlayerWin,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerLose],_soundNamePlayerLose,1);
         _soundMan.addSound(SFX_PhantomIdle,1.7,"SFX_PhantomIdle");
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _controlsKeyPressed = true;
               _leftArrowDown = false;
               break;
            case 1:
               _upArrowDown = false;
               if(_debugDisplay)
               {
                  resetGame();
                  _levelIndex++;
                  if(_levelIndex >= _levelData._data.length)
                  {
                     _levelIndex = 0;
                  }
                  startGame();
               }
               break;
            case 2:
               _controlsKeyPressed = true;
               _rightArrowDown = false;
               break;
            case 3:
               _downArrowDown = false;
         }
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = true;
               break;
            case 1:
               _upArrowDown = true;
               break;
            case 2:
               _rightArrowDown = true;
               break;
            case 3:
               _downArrowDown = true;
         }
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_spiral)
         {
            _spiral.destroy();
         }
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         releaseBase();
         stage.removeEventListener("keyDown",gameOver1KeyDown);
         stage.removeEventListener("keyDown",gameOver2KeyDown);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         resetGame();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_phantomIdleSound)
         {
            _phantomIdleSound.stop();
            _phantomIdleSound = null;
         }
         removeLayer(_layerBackground);
         removeLayer(_layerMidground);
         removeLayer(_layerObstacles);
         removeLayer(_layerGems);
         removeLayer(_layerClouds);
         removeLayer(_layerPlayers);
         removeLayer(_layerGround);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerMidground = null;
         _layerObstacles = null;
         _layerGems = null;
         _layerClouds = null;
         _layerPlayers = null;
         _layerGround = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _spiral = null;
         _displayAchievementTimer = 0;
         _frameTime = -1;
         if(!_bInit)
         {
            setGameState(0);
            _levelIndex = 0;
            _layerBackground = new Sprite();
            _layerMidground = new Sprite();
            _layerBackground.mouseEnabled = false;
            _layerMidground.mouseEnabled = false;
            addChild(_layerBackground);
            addChild(_layerMidground);
            _layerObstacles = new Sprite();
            _layerObstacles.mouseEnabled = false;
            addChild(_layerObstacles);
            _layerClouds = new Sprite();
            _layerClouds.mouseEnabled = false;
            addChild(_layerClouds);
            _layerGround = new Sprite();
            _layerGround.mouseEnabled = false;
            addChild(_layerGround);
            _layerGems = new Sprite();
            _layerGems.mouseEnabled = false;
            addChild(_layerGems);
            _layerPlayers = new Sprite();
            addChild(_layerPlayers);
            _guiLayer = new Sprite();
            addChild(_guiLayer);
            _gemsActive = [];
            _gemsInactive = [];
            _cloudsActive = [];
            _cloudsInactive = [];
            _phantomsActive = [];
            _phantomsInactive = [];
            _branchesActive = [];
            _branchesInactive = [];
            _midgroundActive = [];
            _midgroundInactive = [];
            loadScene("WindRiderAssets/room_main.xroom",WindRiderData._audio);
            _bInit = true;
         }
         else if(_sceneLoaded && MainFrame.isInitialized())
         {
            setGameState(4);
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc6_:Object = null;
         var _loc2_:* = null;
         var _loc5_:int = 0;
         SFX_PhantomIdle = getDefinitionByName("WR_phantom_idle") as Class;
         if(SFX_PhantomIdle == null)
         {
            throw new Error("Sound not found! name:WR_phantom_idle");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_WindRider_Music,0,999999);
         _debugDisplay = null;
         _treasure = _scene.getLayer("treasure");
         _guiLayer.x = 0;
         _guiLayer.y = 0;
         _scoreDisplay = _scene.getLayer("score");
         _scoreDisplay.loader.content.scorebackground.score.text = "0 gems";
         _scoreDisplay.loader.x = 900 - _scoreDisplay.loader.content.width;
         _scoreDisplay.loader.y = 0;
         _guiLayer.addChild(_scoreDisplay.loader);
         _scoreDisplay.loader.content.scorebackground.score.mouseEnabled = false;
         _loc6_ = _scene.getLayer("sky");
         _loc6_.loader.x = 0;
         _loc6_.loader.y = 0;
         _layerBackground.addChild(_loc6_.loader);
         _foreground = _scene.getLayer("foreground");
         _foreground.loader.x = (900 - _foreground.width) / 2;
         _foreground.y = 550 - _foreground.height;
         _foreground.loader.y = _foreground.y;
         _layerMidground.addChild(_foreground.loader);
         _ground = {};
         _ground.clone = _scene.getLayer("ground");
         var _loc3_:Array = _scene.getActorList("ActorVolume");
         for each(_loc2_ in _loc3_)
         {
            if(_loc2_.name == "ground_volume")
            {
               _ground.volumePoints = _loc2_.points;
               _loc5_ = 0;
               while(_loc5_ < _ground.volumePoints.length - 1)
               {
                  _ground.volumePoints[_loc5_].x -= _ground.clone.loader.x;
                  _ground.volumePoints[_loc5_].y -= _ground.clone.loader.y;
                  _loc5_++;
               }
               break;
            }
         }
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         _sceneLoaded = true;
         _leftArrowDown = false;
         _rightArrowDown = false;
         _downArrowDown = false;
         _upArrowDown = false;
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         _progressBar = {};
         _progressBar.clone = _scene.getLayer("progressbar");
         _progressBar.clone.loader.x = 0;
         _progressBar.clone.loader.y = 0;
         _progressBarP1 = {};
         _progressBarP1.clone = _scene.getLayer("progressbar_player1");
         _progressBarP1.clone.loader.x = _progressBar.clone.loader.x + _progressBarP1.clone.x - _progressBar.clone.x;
         _progressBarP1.clone.loader.y = _progressBar.clone.loader.y + _progressBarP1.clone.y - _progressBar.clone.y;
         _progressBarP2 = {};
         _progressBarP2.clone = _scene.getLayer("progressbar_player2");
         _progressBarP2.clone.loader.x = _progressBar.clone.loader.x + _progressBarP2.clone.x - _progressBar.clone.x;
         _progressBarP2.clone.loader.y = _progressBar.clone.loader.y + _progressBarP2.clone.y - _progressBar.clone.y;
         _progressBar.yStart = _progressBarP1.clone.y - _progressBar.clone.y;
         _progressBar.progressHeight = _progressBarP2.clone.y - _progressBarP1.clone.y;
         super.sceneLoaded(param1);
         if(MainFrame.isInitialized())
         {
            setGameState(4);
         }
      }
      
      public function setGameState(param1:int) : void
      {
         if(_gameState != param1)
         {
            if(param1 == 4)
            {
               _spiral = new LoadingSpiral(_guiLayer,450,275);
            }
            else if(param1 == 2)
            {
               MinigameManager.msg(["go"]);
            }
            _gameState = param1;
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1[0] != "ml")
         {
            if(param1[0] == "ms")
            {
               _dbIDs = [];
               _loc2_ = 0;
               while(_loc2_ < _pIDs.length)
               {
                  _dbIDs[_loc2_] = param1[_loc2_ + 1];
                  _loc2_++;
               }
            }
            else if(param1[0] == "mm")
            {
               if(param1[2] == "gw")
               {
                  if(param1[3] == "1")
                  {
                     _prizeAccessory = new Item();
                     _prizeAccessory.init(param1[4],0,param1[6],null,true);
                     _prizePopup = new GiftPopup();
                     _prizePopupDelay = 1;
                  }
                  else
                  {
                     _gameOverTimer = 0.5;
                  }
               }
            }
         }
      }
      
      private function keptItem() : void
      {
         _gameOverTimer = 0.5;
         MinigameManager.msg(["gd","1"]);
         _prizePopup.close();
      }
      
      private function rejectedItem() : void
      {
         _gameOverTimer = 0.5;
         MinigameManager.msg(["gd","0"]);
         _prizePopup.close();
      }
      
      private function destroyPrizePopup() : void
      {
         if(_prizePopup)
         {
            _prizePopup.destroy();
            _prizePopup = null;
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc11_:int = 0;
         var _loc9_:Object = null;
         var _loc7_:int = 0;
         var _loc3_:Number = NaN;
         var _loc6_:WindRiderPlayer = null;
         var _loc13_:int = 0;
         var _loc12_:Number = NaN;
         var _loc5_:int = 0;
         var _loc2_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc14_:* = null;
         var _loc8_:Boolean = false;
         if(_sceneLoaded)
         {
            if(_frameTime < 0)
            {
               _frameTime = 0.1;
            }
            else
            {
               _frameTime = (getTimer() - _lastTime) / 1000;
            }
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
            _lastTime = getTimer();
            if(!_pauseGame || _players.length > 1)
            {
               if(_frameTime > 0)
               {
                  _loc7_ = Math.round(_frameTime / 0.0416666666666667);
                  _loc3_ = _frameTime / _loc7_;
                  _loc11_ = 0;
                  while(_loc11_ < _loc7_)
                  {
                     _loc6_ = null;
                     if(_gameState == 1 || _gameState == 2 || _gameState == 3)
                     {
                        if(_gameState == 2)
                        {
                           if(_readySetGo > 0)
                           {
                              _readySetGo -= _loc3_;
                              if(_readySetGo <= 0)
                              {
                                 if(_readyMC && _readyMC.loader.parent)
                                 {
                                    _readyMC.loader.parent.removeChild(_readyMC.loader);
                                    _scene.releaseCloneAsset(_readyMC.loader);
                                    _readyMC = null;
                                 }
                              }
                           }
                           else if(_controlsMC && _controlsMC.loader.parent && _controlsKeyPressed)
                           {
                              _controlsMC.loader.parent.removeChild(_controlsMC.loader);
                              _controlsMC = null;
                           }
                           _gameTime += _loc3_;
                        }
                        heartbeatPhantoms(_loc3_);
                        _loc6_ = heartbeatPlayers(_loc3_);
                     }
                     if(_gameState == 1 || _gameState == 2)
                     {
                        if(_loc6_)
                        {
                           _loc13_ = (_ground.clone.loader.y - _loc6_._clone.y) / 50;
                           _playerHeight = Math.max(_playerHeight,_loc13_);
                           LocalizationManager.translateIdAndInsert(_scoreDisplay.loader.content.scorebackground.score,11097,_loc6_._gemCount);
                           if(_prizePopupDelay > 0)
                           {
                              _prizePopupDelay -= _frameTime;
                              if(_prizePopupDelay <= 0)
                              {
                                 _prizePopup.init(this.parent,_prizeAccessory.largeIcon,_prizeAccessory.name,_prizeAccessory.defId,2,1,keptItem,rejectedItem,destroyPrizePopup);
                                 _prizePopupDelay = 0;
                              }
                           }
                           else if(_gameOverTimer <= 0)
                           {
                              _loc12_ = -(_loc6_.getScreenY() - 450);
                              if(_ground.clone.loader.parent != null)
                              {
                                 _loc12_ = Math.max(_loc12_,-(_ground.clone.loader.height + _ground.clone.loader.y - 550));
                              }
                              if(_loc12_ > 0)
                              {
                                 _loc12_ = 0;
                              }
                              _layerGround.y = _loc12_;
                              _layerPlayers.y = _loc12_;
                              _layerGems.y = _loc12_;
                              _layerClouds.y = _loc12_;
                              _layerObstacles.y = _loc12_;
                              _layerBackground.y = _backgroundMoveSpeed * _loc12_;
                              _layerMidground.y = -((-_layerBackground.y - _foregroundMoveSpeed) * 1.5);
                              _loc4_ = _midgroundActive.length - 1;
                              while(_loc4_ >= 0)
                              {
                                 if(_midgroundActive[_loc4_].loader.y + _layerMidground.y <= -100)
                                 {
                                    _midgroundInactive.push(_midgroundActive[_loc4_]);
                                    _midgroundActive[_loc4_].loader.parent.removeChild(_midgroundActive[_loc4_].loader);
                                    _midgroundActive.splice(_loc4_,1);
                                 }
                                 _loc4_--;
                              }
                              _loc4_ = _gemsActive.length - 1;
                              while(_loc4_ >= 0)
                              {
                                 if(_gemsActive[_loc4_].loader.y + _layerGems.y >= 900)
                                 {
                                    _gemsInactive.push(_gemsActive[_loc4_]);
                                    _gemsActive[_loc4_].loader.parent.removeChild(_gemsActive[_loc4_].loader);
                                    _gemsActive.splice(_loc4_,1);
                                 }
                                 _loc4_--;
                              }
                              _loc4_ = _cloudsActive.length - 1;
                              while(_loc4_ >= 0)
                              {
                                 if(_cloudsActive[_loc4_].bounceTimer > 0)
                                 {
                                    _cloudsActive[_loc4_].bounceTimer -= _loc3_;
                                    if(_cloudsActive[_loc4_].bounceTimer <= 0)
                                    {
                                       _cloudsActive[_loc4_].bounceTimer = 0;
                                    }
                                 }
                                 if(_cloudsActive[_loc4_].bounceTimer == 0 || _cloudsActive[_loc4_].loader.y + _layerClouds.y >= 900)
                                 {
                                    _cloudsInactive.push(_cloudsActive[_loc4_]);
                                    _cloudsActive[_loc4_].loader.parent.removeChild(_cloudsActive[_loc4_].loader);
                                    _cloudsActive.splice(_loc4_,1);
                                 }
                                 _loc4_--;
                              }
                              _loc4_ = _phantomsActive.length - 1;
                              while(_loc4_ >= 0)
                              {
                                 if(_phantomsActive[_loc4_].phantom.loader.y + _layerObstacles.y >= 900)
                                 {
                                    _phantomsInactive.push(_phantomsActive[_loc4_]);
                                    _phantomsActive[_loc4_].phantom.loader.parent.removeChild(_phantomsActive[_loc4_].phantom.loader);
                                    _phantomsActive.splice(_loc4_,1);
                                 }
                                 _loc4_--;
                              }
                              _loc4_ = _branchesActive.length - 1;
                              while(_loc4_ >= 0)
                              {
                                 if(_branchesActive[_loc4_].loader.y + _layerObstacles.y <= -100)
                                 {
                                    _branchesInactive.push(_branchesActive[_loc4_]);
                                    _branchesActive[_loc4_].loader.parent.removeChild(_branchesActive[_loc4_].loader);
                                    _branchesActive.splice(_loc4_,1);
                                 }
                                 _loc4_--;
                              }
                              while(_currentCloudIndex >= 0)
                              {
                                 if(_levelData._data[_levelIndex][_currentCloudIndex].row)
                                 {
                                    if(_layerClouds.y + 300 < -50 * _levelData._data[_levelIndex][_currentCloudIndex].row)
                                    {
                                       break;
                                    }
                                    if(_levelData._data[_levelIndex][_currentCloudIndex].gems)
                                    {
                                       _loc5_ = 0;
                                       while(_loc5_ < _levelData._data[_levelIndex][_currentCloudIndex].gems.length)
                                       {
                                          if(_gemsInactive.length > 0)
                                          {
                                             _loc9_ = _gemsInactive[0];
                                             _gemsInactive.splice(0,1);
                                          }
                                          else
                                          {
                                             _loc9_ = _scene.cloneAsset("gemSpin");
                                          }
                                          _loc9_.loader.x = 25 * _levelData._data[_levelIndex][_currentCloudIndex].gems[_loc5_] - 40;
                                          _loc9_.loader.y = 50 * _levelData._data[_levelIndex][_currentCloudIndex].row;
                                          _layerGems.addChild(_loc9_.loader);
                                          _gemsActive.push(_loc9_);
                                          _loc5_++;
                                       }
                                    }
                                    if(_levelData._data[_levelIndex][_currentCloudIndex].cloudsL)
                                    {
                                       addClouds(1,_levelData._data[_levelIndex][_currentCloudIndex].row,_levelData._data[_levelIndex][_currentCloudIndex].cloudsL,_currentCloudIndex == _lastCloudRow);
                                    }
                                    if(_levelData._data[_levelIndex][_currentCloudIndex].cloudsS)
                                    {
                                       addClouds(2,_levelData._data[_levelIndex][_currentCloudIndex].row,_levelData._data[_levelIndex][_currentCloudIndex].cloudsS,_currentCloudIndex == _lastCloudRow);
                                    }
                                    if(_levelData._data[_levelIndex][_currentCloudIndex].phantomidle)
                                    {
                                       _loc5_ = 0;
                                       while(_loc5_ < _levelData._data[_levelIndex][_currentCloudIndex].phantomidle.length)
                                       {
                                          addPhantom(0,0,25 * _levelData._data[_levelIndex][_currentCloudIndex].phantomidle[_loc5_],50 * _levelData._data[_levelIndex][_currentCloudIndex].row);
                                          _loc5_++;
                                       }
                                    }
                                    if(_levelData._data[_levelIndex][_currentCloudIndex].treasure)
                                    {
                                       if(_treasure.loader.parent == null)
                                       {
                                          _layerGround.addChild(_treasure.loader);
                                       }
                                       _treasure.loader.x = 25 * _levelData._data[_levelIndex][_currentCloudIndex].treasure[0];
                                       _treasure.loader.y = 50 * _levelData._data[_levelIndex][_currentCloudIndex].row;
                                    }
                                 }
                                 _currentCloudIndex--;
                              }
                              while(_currentDataIndex < _levelData._data[_levelIndex].length)
                              {
                                 if(_levelData._data[_levelIndex][_currentDataIndex].ground)
                                 {
                                    if(_layerGround.y - 900 > -50 * _levelData._data[_levelIndex][_currentDataIndex].ground)
                                    {
                                       break;
                                    }
                                    _layerGround.addChild(_ground.clone.loader);
                                 }
                                 _currentDataIndex++;
                              }
                           }
                           if(_gameOverTimer > 0 && _gameOverTimer != 999)
                           {
                              _loc10_ = _gameOverTimer;
                              _gameOverTimer -= _loc3_;
                              if(_loc10_ >= 1 && _loc10_ < 1)
                              {
                                 AchievementManager.displayNewAchievements();
                              }
                              if(_gameOverTimer <= 0)
                              {
                                 setGameOver();
                              }
                           }
                        }
                     }
                     if(_gameState == 4)
                     {
                        if(_dbIDs != null)
                        {
                           startGame();
                           if(_readyMC && _readyMC.loader.parent)
                           {
                              _readyMC.loader.parent.removeChild(_readyMC.loader);
                              _scene.releaseCloneAsset(_readyMC.loader);
                              _readyMC = null;
                           }
                        }
                     }
                     else if(_gameState == 1)
                     {
                        if(_dbIDs != null)
                        {
                           _loc8_ = true;
                           for each(_loc14_ in _players)
                           {
                              if(_loc14_._animsLoaded == false)
                              {
                                 _loc8_ = false;
                                 break;
                              }
                           }
                           if(_loc8_)
                           {
                              if(_spiral)
                              {
                                 _spiral.destroy();
                                 _spiral = null;
                                 _controlsMC = _scene.getLayer("controls");
                                 if(_controlsMC)
                                 {
                                    _controlsKeyPressed = false;
                                    _controlsMC.loader.x = 0;
                                    _controlsMC.loader.y = -50;
                                    _guiLayer.addChild(_controlsMC.loader);
                                 }
                              }
                              _readyMC = _scene.cloneAsset("ready");
                              if(_readyMC)
                              {
                                 _readyMC.loader.x = 450;
                                 _readyMC.loader.y = 275;
                                 _guiLayer.addChild(_readyMC.loader);
                              }
                              _readySetGo = 3;
                              _soundMan.playByName(_soundNameReadyGo);
                              setGameState(2);
                           }
                        }
                     }
                     _loc11_++;
                  }
               }
            }
         }
      }
      
      private function gameOver1KeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function gameOver2KeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onResetGame();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function setGameOver() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:* = null;
         if(_gameState != 3)
         {
            if(_success)
            {
               _loc1_ = showDlg("card_para_greatjob",[{
                  "name":"button_exit",
                  "f":onExit_Yes
               }]);
               stage.addEventListener("keyDown",gameOver1KeyDown);
            }
            else
            {
               _loc1_ = showDlg("card_skyHigh_Game_Over",[{
                  "name":"button_yes",
                  "f":onResetGame
               },{
                  "name":"button_no",
                  "f":onExit_Yes
               }]);
               stage.addEventListener("keyDown",gameOver2KeyDown);
            }
            for each(_loc2_ in _players)
            {
               if(_loc2_._localPlayer)
               {
                  LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_loc2_._gemCount);
                  break;
               }
            }
            _loc1_.x = 450;
            _loc1_.y = 275;
            setGameState(3);
         }
      }
      
      private function addPhantom(param1:int, param2:int, param3:Number, param4:Number) : void
      {
         var _loc5_:Object = null;
         param3 = param3 - 20 - 40;
         if(_phantomsInactive.length > 0)
         {
            _loc5_ = _phantomsInactive[0];
            _phantomsInactive.splice(0,1);
            _loc5_.phantom.loader.content.transition = "Idle";
         }
         else
         {
            _loc5_ = {};
            _loc5_.phantom = _scene.cloneAsset("phantomOld");
            _loc5_.phantom.loader.contentLoaderInfo.addEventListener("complete",onPhantomIdleLoaderComplete);
         }
         _loc5_.polluteTimer = 0;
         _loc5_.phantom.loader.x = param3;
         _loc5_.phantom.loader.y = param4;
         _loc5_.x = param3;
         _loc5_.y = param4;
         _loc5_.currentX = param3;
         _loc5_.currentY = param4;
         _loc5_.xSpeed = param1;
         _loc5_.ySpeed = param2;
         _layerObstacles.addChild(_loc5_.phantom.loader);
         _phantomsActive.push(_loc5_);
      }
      
      private function heartbeatPhantoms(param1:Number) : void
      {
         var _loc4_:* = null;
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         for each(_loc4_ in _phantomsActive)
         {
            _loc2_ = _loc4_.phantom.loader.y + _loc4_.phantom.loader.parent.y;
            if(_loc4_.polluteTimer > 0)
            {
               _loc4_.polluteTimer -= param1;
               if(_loc4_.polluteTimer <= 0)
               {
                  _loc4_.polluteTimer = 0;
                  _loc4_.phantom.loader.content.gotoAndPlay("Idle");
                  _loc4_.phantom.loader.content.currentLoop = "Idle";
               }
            }
            if(_loc2_ > 0 && _loc2_ <= 550)
            {
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            if(_phantomIdleSound == null)
            {
               _phantomIdleSound = _soundMan.play(SFX_PhantomIdle,0,99999);
            }
         }
         else if(_phantomIdleSound != null)
         {
            _phantomIdleSound.stop();
            _phantomIdleSound = null;
         }
      }
      
      private function heartbeatPlayers(param1:Number) : WindRiderPlayer
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         for each(_loc3_ in _players)
         {
            if(_readySetGo > 0)
            {
               _loc3_.heartbeat(0);
            }
            else
            {
               _loc3_.heartbeat(param1);
            }
            if(_loc3_._localPlayer)
            {
               _loc2_ = _loc3_;
               if(_loc2_._landed)
               {
                  if(_gameOverTimer == 0)
                  {
                     _gameOverTimer = 999;
                     addGemsToBalance(_loc2_._gemCount);
                     _success = true;
                  }
               }
            }
            if(_loc3_._progressbar)
            {
               _loc3_._progressbar.clone.loader.y = _progressBar.yStart + _progressBar.progressHeight * _loc3_._serverPosition.y / _ground.clone.loader.y;
            }
         }
         return _loc2_;
      }
      
      public function playerFell(param1:WindRiderPlayer) : void
      {
         if(_gameOverTimer == 0)
         {
            _gameOverTimer = 0.75;
            addGemsToBalance(param1._gemCount);
         }
      }
      
      public function startGame() : void
      {
         var _loc4_:int = 0;
         var _loc3_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Object = null;
         _readySetGo = 0;
         _groundOff = false;
         _success = false;
         _treasure.loader.content.gotoAndPlay("off");
         if(_debugDisplay)
         {
            _debugDisplay.loader.content.level.text = _levelIndex + 1;
         }
         else
         {
            _levelIndex = Math.random() * _levelData._data.length;
         }
         _playerHeight = 0;
         _gameOverTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = -1;
         _midgroundAddY = 600;
         _lastCloudRow = -1;
         _loc4_ = 0;
         while(_loc4_ < _levelData._data[_levelIndex].length)
         {
            if(_levelData._data[_levelIndex][_loc4_].ground)
            {
               _ground.clone.loader.x = 0;
               _ground.clone.loader.y = 50 * _levelData._data[_levelIndex][_loc4_].ground;
               _loc3_ = 50 * _levelData._data[_levelIndex][_loc4_].ground;
               _currentCloudIndex = _loc4_;
            }
            else if(_lastCloudRow == -1 && (_levelData._data[_levelIndex][_loc4_].cloudsS || _levelData._data[_levelIndex][_loc4_].cloudsL))
            {
               _lastCloudRow = _loc4_;
            }
            _loc4_++;
         }
         _loc2_ = _scene.getLayer("sky");
         _backgroundMoveSpeed = 0;
         _foregroundMoveSpeed = 0;
         if(_loc2_)
         {
            _backgroundMoveSpeed = (_loc2_.loader.height - 550) / _loc3_;
            _foregroundMoveSpeed = _loc2_.loader.height - 550;
         }
         _players = [];
         var _loc7_:WindRiderPlayer = new WindRiderPlayer(this);
         _loc7_.init(_dbIDs[0],_loc1_,_scene.getLayer("parachute_p1"),_progressBarP1);
         _players.push(_loc7_);
         _guiLayer.addChild(_progressBar.clone.loader);
         _guiLayer.addChild(_progressBarP1.clone.loader);
         _currentDataIndex = 0;
         setGameState(1);
      }
      
      public function restartGame() : void
      {
         var _loc4_:int = 0;
         var _loc6_:* = null;
         var _loc3_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Object = null;
         _readySetGo = 3;
         _groundOff = false;
         _success = false;
         _treasure.loader.content.gotoAndPlay("off");
         _musicLoop = _soundMan.playStream(_SFX_WindRider_Music,0,999999);
         if(_readyMC && _readyMC.loader.parent)
         {
            _readyMC.loader.parent.removeChild(_readyMC.loader);
            _scene.releaseCloneAsset(_readyMC.loader);
            _readyMC = null;
         }
         _readyMC = _scene.cloneAsset("ready");
         if(_readyMC)
         {
            _readyMC.loader.x = 450;
            _readyMC.loader.y = 275;
            _guiLayer.addChild(_readyMC.loader);
            _soundMan.playByName(_soundNameReadyGo);
         }
         while(_gemsActive.length > 0)
         {
            if(_gemsActive[0].loader.parent)
            {
               _gemsActive[0].loader.parent.removeChild(_gemsActive[0].loader);
            }
            _gemsInactive.push(_gemsActive[0]);
            _gemsActive.splice(0,1);
         }
         while(_cloudsActive.length > 0)
         {
            if(_cloudsActive[0].loader.parent)
            {
               _cloudsActive[0].loader.parent.removeChild(_cloudsActive[0].loader);
            }
            _cloudsInactive.push(_cloudsActive[0]);
            _cloudsActive.splice(0,1);
         }
         while(_phantomsActive.length > 0)
         {
            if(_phantomsActive[0].phantom.loader.parent)
            {
               _phantomsActive[0].phantom.loader.parent.removeChild(_phantomsActive[0].phantom.loader);
            }
            _phantomsInactive.push(_phantomsActive[0]);
            _phantomsActive.splice(0,1);
         }
         while(_branchesActive.length > 0)
         {
            if(_branchesActive[0].loader.parent)
            {
               _branchesActive[0].loader.parent.removeChild(_branchesActive[0].loader);
            }
            _branchesInactive.push(_branchesActive[0]);
            _branchesActive.splice(0,1);
         }
         while(_midgroundActive.length > 0)
         {
            if(_midgroundActive[0].loader.parent)
            {
               _midgroundActive[0].loader.parent.removeChild(_midgroundActive[0].loader);
            }
            _midgroundInactive.push(_midgroundActive[0]);
            _midgroundActive.splice(0,1);
         }
         if(_debugDisplay)
         {
            _debugDisplay.loader.content.level.text = _levelIndex + 1;
         }
         else
         {
            _levelIndex = Math.random() * _levelData._data.length;
         }
         _playerHeight = 0;
         _gameOverTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = -1;
         _midgroundAddY = 600;
         _lastCloudRow = -1;
         _loc4_ = 0;
         while(_loc4_ < _levelData._data[_levelIndex].length)
         {
            if(_levelData._data[_levelIndex][_loc4_].ground)
            {
               _ground.clone.loader.x = 0;
               _ground.clone.loader.y = 50 * _levelData._data[_levelIndex][_loc4_].ground;
               _loc3_ = 50 * _levelData._data[_levelIndex][_loc4_].ground;
               _currentCloudIndex = _loc4_;
            }
            else if(_lastCloudRow == -1 && (_levelData._data[_levelIndex][_loc4_].cloudsS || _levelData._data[_levelIndex][_loc4_].cloudsL))
            {
               _lastCloudRow = _loc4_;
            }
            _loc4_++;
         }
         _loc2_ = _scene.getLayer("sky");
         _backgroundMoveSpeed = 0;
         _foregroundMoveSpeed = 0;
         if(_loc2_)
         {
            _backgroundMoveSpeed = (_loc2_.loader.height - 550) / _loc3_;
            _foregroundMoveSpeed = _loc2_.loader.height - 550;
         }
         for each(_loc6_ in _players)
         {
            _loc6_.reset();
         }
         _currentDataIndex = 0;
         setGameState(2);
      }
      
      public function resetGame() : void
      {
         while(_players.length > 0)
         {
            _players[0].remove();
            _players.splice(0,1);
         }
         if(_treasure.loader.parent)
         {
            _treasure.loader.parent.removeChild(_treasure.loader);
         }
         if(_progressBar.clone && _progressBar.clone.loader.parent)
         {
            _progressBar.clone.loader.parent.removeChild(_progressBar.clone.loader);
         }
         if(_progressBarP1.clone && _progressBarP1.clone.loader.parent)
         {
            _progressBarP1.clone.loader.parent.removeChild(_progressBarP1.clone.loader);
         }
         if(_progressBarP2.clone && _progressBarP2.clone.loader.parent)
         {
            _progressBarP2.clone.loader.parent.removeChild(_progressBarP2.clone.loader);
         }
         while(_gemsActive.length > 0)
         {
            if(_gemsActive[0].loader.parent)
            {
               _gemsActive[0].loader.parent.removeChild(_gemsActive[0].loader);
            }
            _gemsInactive.push(_gemsActive[0]);
            _gemsActive.splice(0,1);
         }
         while(_cloudsActive.length > 0)
         {
            if(_cloudsActive[0].loader.parent)
            {
               _cloudsActive[0].loader.parent.removeChild(_cloudsActive[0].loader);
            }
            _cloudsInactive.push(_cloudsActive[0]);
            _cloudsActive.splice(0,1);
         }
         while(_phantomsActive.length > 0)
         {
            if(_phantomsActive[0].phantom.loader.parent)
            {
               _phantomsActive[0].phantom.loader.parent.removeChild(_phantomsActive[0].phantom.loader);
            }
            _phantomsInactive.push(_phantomsActive[0]);
            _phantomsActive.splice(0,1);
         }
         while(_branchesActive.length > 0)
         {
            if(_branchesActive[0].loader.parent)
            {
               _branchesActive[0].loader.parent.removeChild(_branchesActive[0].loader);
            }
            _branchesInactive.push(_branchesActive[0]);
            _branchesActive.splice(0,1);
         }
         while(_midgroundActive.length > 0)
         {
            if(_midgroundActive[0].loader.parent)
            {
               _midgroundActive[0].loader.parent.removeChild(_midgroundActive[0].loader);
            }
            _midgroundInactive.push(_midgroundActive[0]);
            _midgroundActive.splice(0,1);
         }
      }
      
      public function addClouds(param1:int, param2:int, param3:Array, param4:Boolean) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Object = null;
         _loc6_ = 0;
         while(_loc6_ < param3.length)
         {
            _loc7_ = null;
            _loc5_ = 0;
            while(_loc5_ < _cloudsInactive.length)
            {
               if(_cloudsInactive[_loc5_].type == param1)
               {
                  _loc7_ = _cloudsInactive[_loc5_];
                  _loc7_.loader.content.gotoAndPlay("off");
                  _cloudsInactive.splice(_loc5_,1);
                  break;
               }
               _loc5_++;
            }
            if(_loc7_ == null)
            {
               _loc7_ = _scene.cloneAsset("branch_" + (4 + param1));
            }
            _loc7_.endCloud = param4;
            _loc7_.type = param1;
            _loc7_.loader.x = 25 * param3[_loc6_] - 40;
            _loc7_.loader.y = 50 * param2;
            _layerClouds.addChild(_loc7_.loader);
            _loc7_.bounceTimer = -1;
            _cloudsActive.push(_loc7_);
            _loc6_++;
         }
      }
      
      public function onPhantomVerticalLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Up";
         param1.target.removeEventListener("complete",onPhantomVerticalLoaderComplete);
      }
      
      public function onPhantomHorizontalLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Right";
         param1.target.removeEventListener("complete",onPhantomHorizontalLoaderComplete);
      }
      
      public function onPhantomIdleLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Idle";
         param1.target.removeEventListener("complete",onPhantomIdleLoaderComplete);
      }
      
      public function onBranchLoaderComplete(param1:Event) : void
      {
         param1.target.content.gotoAndPlay("off");
         param1.target.removeEventListener("complete",onBranchLoaderComplete);
      }
      
      public function gemPickup(param1:int) : void
      {
         _gemsInactive.push(_gemsActive[param1]);
         _gemsActive[param1].loader.parent.removeChild(_gemsActive[param1].loader);
         _gemsActive.splice(param1,1);
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc2_:* = null;
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         for each(_loc2_ in _players)
         {
            _loc2_._clone.visible = false;
         }
      }
      
      private function onExit_Yes() : void
      {
         stage.removeEventListener("keyDown",gameOver1KeyDown);
         stage.removeEventListener("keyDown",gameOver2KeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         var _loc1_:* = null;
         hideDlg();
         for each(_loc1_ in _players)
         {
            _loc1_._clone.visible = true;
         }
      }
      
      private function onResetGame() : void
      {
         stage.removeEventListener("keyDown",gameOver1KeyDown);
         stage.removeEventListener("keyDown",gameOver2KeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         hideDlg();
         restartGame();
      }
      
      public function groundOff() : void
      {
         if(!_groundOff)
         {
            _layerGround.removeChild(_ground.clone.loader);
            _groundOff = true;
         }
      }
      
      public function sendGameWin() : void
      {
         MinigameManager.msg(["gw"]);
      }
   }
}

