package game.questParachuteGlider
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gui.LoadingSpiral;
   import localization.LocalizationManager;
   
   public class QuestParachuteGlider extends GameBase implements IMinigame
   {
      private static const OFFSCREEN_ADD_HEIGHT:int = 600;
      
      private static const OFFSCREEN_REMOVE_HEIGHT:int = 600;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const PLAYER_SCREEN_Y:Number = 300;
      
      private static const GAMEOVER_POPUP_X:int = 450;
      
      private static const GAMEOVER_POPUP_Y:int = 275;
      
      private static const LEVEL_SPACING:int = 1650;
      
      private static const TREE1_SPEED_FACTOR:Number = 0.5;
      
      public static const PHANTOMSPEED:Number = 40;
      
      public static const MAX_PHANTOM_MOVE_HORIZONTAL:Number = 200;
      
      public static const MAX_PHANTOM_MOVE_VERTICAL:Number = 250;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_PRELOAD_ANIMS:int = 1;
      
      public static const GAMESTATE_PRELOADING_ANIMS:int = 2;
      
      public static const GAMESTATE_READY_TO_START:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_ENDED:int = 5;
      
      public static const STAGE_OFFSET:Number = 0;
      
      public static const PHANTOM_OFFSET:Number = 28;
      
      public var _gameResult:int;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _levelData:QuestParachuteGliderData;
      
      public var _levelIndex:int;
      
      public var _currentRow:int;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerParallax:Sprite;
      
      public var _layerBackground:Sprite;
      
      public var _layerBranch:Sprite;
      
      public var _layerGems:Sprite;
      
      public var _layerPhantoms:Sprite;
      
      public var _layerWinds:Sprite;
      
      public var _layerGround:Sprite;
      
      public var _layerPlayers:Sprite;
      
      public var _backgroundMoveSpeed:Number;
      
      public var _gameState:int;
      
      public var _players:Array;
      
      public var _maxTotalY:Number;
      
      public var _ground:Object;
      
      private var _levelProgression:Array;
      
      private var _currentLevel:int;
      
      private var _nextLevelAddY:int;
      
      public var _gems:Dictionary;
      
      public var _currentGemID:int;
      
      public var _gemsCollected:Dictionary;
      
      public var _phantoms:Array;
      
      public var _currentPhantomID:int;
      
      public var _winds:Array;
      
      public var _treasure:Object;
      
      public var _gameOverTimer:Number;
      
      private var _delayExitTimer:Number;
      
      private var _phantomIdleSound:SoundChannel;
      
      private var _parachuteIdleSound:SoundChannel;
      
      private var _musicInstance:SoundChannel;
      
      private var _scoreDisplay:Object;
      
      private var _debugDisplay:Object;
      
      private var _debugMsg:Array;
      
      private var _recycleGems:Array;
      
      private var _recyclePhantoms:Array;
      
      private var _recycleWinds:Array;
      
      public var _displayAchievementsTimer:Number;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      public var _controlsMC:Object;
      
      public var _controlsKeyPressed:Boolean;
      
      public var _spiral:LoadingSpiral;
      
      private var _tower:Object;
      
      public var _soundMan:SoundManager;
      
      internal var _soundNameCloudSwirl:String = QuestParachuteGliderData._audio[0];
      
      internal var _soundNamePhantomShock:String = QuestParachuteGliderData._audio[1];
      
      internal var _soundNameTreasureChest:String = QuestParachuteGliderData._audio[2];
      
      internal var _soundNameWindGust:String = QuestParachuteGliderData._audio[3];
      
      internal var _soundNameGemAdded:String = QuestParachuteGliderData._audio[4];
      
      public var SFX_ParachuteIdle:Class;
      
      public var SFX_PhantomIdle:Class;
      
      public var _SFX_Music:SBMusic;
      
      public function QuestParachuteGlider()
      {
         super();
         _levelData = new QuestParachuteGliderData();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("DAVolcano",0.52);
         _soundMan.addSoundByName(_audioByName[_soundNameCloudSwirl],_soundNameCloudSwirl,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNamePhantomShock],_soundNamePhantomShock,1);
         _soundMan.addSoundByName(_audioByName[_soundNameTreasureChest],_soundNameTreasureChest,1);
         _soundMan.addSoundByName(_audioByName[_soundNameWindGust],_soundNameWindGust,0.65);
         _soundMan.addSoundByName(_audioByName[_soundNameGemAdded],_soundNameGemAdded,1);
         _soundMan.addSound(SFX_ParachuteIdle,1,"SFX_ParachuteIdle");
         _soundMan.addSound(SFX_PhantomIdle,1.7,"SFX_PhantomIdle");
      }
      
      private function unloadSounds() : void
      {
         _SFX_Music = null;
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
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _bInit = false;
         resetGame();
         unloadSounds();
         if(_phantomIdleSound)
         {
            _phantomIdleSound.stop();
            _phantomIdleSound = null;
         }
         if(_musicInstance)
         {
            _musicInstance.stop();
            _musicInstance = null;
         }
         if(_parachuteIdleSound)
         {
            _parachuteIdleSound.stop();
            _parachuteIdleSound = null;
         }
         removeLayer(_layerParallax);
         removeLayer(_layerBackground);
         removeLayer(_layerBranch);
         removeLayer(_layerGems);
         removeLayer(_layerPhantoms);
         removeLayer(_layerWinds);
         removeLayer(_layerGround);
         removeLayer(_layerPlayers);
         removeLayer(_guiLayer);
         _layerParallax = null;
         _layerBackground = null;
         _layerBranch = null;
         _layerGems = null;
         _layerPhantoms = null;
         _layerWinds = null;
         _layerGround = null;
         _layerPlayers = null;
         _guiLayer = null;
         MinigameManager.leave(false,_gameResult);
      }
      
      private function init() : void
      {
         _gameResult = 0;
         _displayAchievementsTimer = 1;
         if(!_bInit)
         {
            setGameState(0);
            _layerParallax = new Sprite();
            _layerBackground = new Sprite();
            _layerBackground.mouseEnabled = false;
            _layerBranch = new Sprite();
            _layerGems = new Sprite();
            _layerWinds = new Sprite();
            _layerGround = new Sprite();
            _layerPhantoms = new Sprite();
            _layerPlayers = new Sprite();
            _layerBranch.mouseEnabled = false;
            _layerGems.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerParallax);
            addChild(_layerBackground);
            addChild(_layerBranch);
            addChild(_layerGround);
            addChild(_layerWinds);
            addChild(_layerPhantoms);
            addChild(_layerGems);
            addChild(_layerPlayers);
            addChild(_guiLayer);
            loadScene("QuestParachuteAssets/room_main.xroom",QuestParachuteGliderData._audio);
            _bInit = true;
         }
         else if(_sceneLoaded && MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:* = null;
         var _loc7_:int = 0;
         SFX_ParachuteIdle = getDefinitionByName("WR_parachute_lp") as Class;
         if(SFX_ParachuteIdle == null)
         {
            throw new Error("Sound not found! name:WR_parachute_lp");
         }
         SFX_PhantomIdle = getDefinitionByName("WR_phantom_idle") as Class;
         if(SFX_PhantomIdle == null)
         {
            throw new Error("Sound not found! name:WR_phantom_idle");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _guiLayer.x = 0;
         _guiLayer.y = 0;
         _debugDisplay = null;
         _scoreDisplay = _scene.getLayer("score");
         _scoreDisplay.loader.x = 900 - _scoreDisplay.loader.content.width - 30;
         _scoreDisplay.loader.y = 40;
         _scoreDisplay.loader.content.scorebackground.score.text = 0;
         _guiLayer.addChild(_scoreDisplay.loader);
         _scoreDisplay.loader.content.scorebackground.score.mouseEnabled = false;
         _loc2_ = _scene.getLayer("sky");
         _layerBackground.addChild(_loc2_.loader);
         _tower = _scene.getLayer("tower");
         _layerBackground.addChild(_tower.loader);
         var _loc5_:Array = _scene.getActorList("ActorVolume");
         _ground = {};
         _ground.clone = _scene.getLayer("ground");
         for each(_loc3_ in _loc5_)
         {
            if(_loc3_.name == "ground_volume")
            {
               _ground.volumePoints = _loc3_.points;
               _loc7_ = 0;
               while(_loc7_ < _ground.volumePoints.length - 1)
               {
                  _ground.volumePoints[_loc7_].x -= _ground.clone.loader.x;
                  _ground.volumePoints[_loc7_].y -= _ground.clone.loader.y;
                  _loc7_++;
               }
               break;
            }
         }
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         _treasure = {};
         _treasure.clone = _scene.getLayer("treasure");
         _sceneLoaded = true;
         _leftArrowDown = false;
         _rightArrowDown = false;
         _downArrowDown = false;
         _upArrowDown = false;
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         super.sceneLoaded(param1);
         if(MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:Array = null;
         if(_gameState != param1)
         {
            switch(param1 - 1)
            {
               case 0:
                  _spiral = new LoadingSpiral(_guiLayer,450,275);
                  break;
               case 2:
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
            }
            _gameState = param1;
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc8_:* = null;
         var _loc7_:* = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:* = 0;
         var _loc9_:RandomSeed = null;
         var _loc2_:int = 0;
         if(param1[0] == "ml")
         {
            _loc7_ = uint(int(param1[2]));
            if(_players)
            {
               _loc4_ = 0;
               while(true)
               {
                  if(_loc4_ < _players.length)
                  {
                     if(_players[_loc4_]._netID != _loc7_)
                     {
                        continue;
                     }
                     _players[_loc4_].remove();
                     _players.splice(_loc4_,1);
                  }
                  _loc4_++;
               }
            }
         }
         else if(param1[0] == "ms")
         {
            _dbIDs = [];
            _userNames = [];
            _loc5_ = 1;
            _loc4_ = 0;
            while(_loc4_ < _pIDs.length)
            {
               _dbIDs[_loc4_] = param1[_loc5_++];
               _userNames[_loc4_] = param1[_loc5_++];
               _loc4_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "start")
            {
               _loc3_ = parseInt(param1[3]);
               _loc9_ = new RandomSeed(_loc3_);
               _levelIndex = _loc9_.integer(_levelData._data.length);
               startGame(param1);
               if(_debugDisplay)
               {
                  _debugMsg = param1;
               }
            }
            else if(param1[2] == "pos")
            {
               _loc7_ = uint(int(param1[3]));
               _loc6_ = 4;
               for each(_loc8_ in _players)
               {
                  if(_loc8_._netID == _loc7_)
                  {
                     _loc6_ = _loc8_.receivePositionData(param1,_loc6_);
                     break;
                  }
               }
            }
            else if(param1[2] == "gem")
            {
               _loc7_ = uint(int(param1[3]));
               _loc2_ = int(param1[4]);
               if(_gemsCollected[_loc2_] == null)
               {
                  for each(_loc8_ in _players)
                  {
                     if(_loc8_._netID == _loc7_)
                     {
                        _loc8_.receiveGem(_loc2_);
                        break;
                     }
                  }
                  if(_gems[_loc2_] != null)
                  {
                     gemPickup(_loc2_);
                  }
                  _gemsCollected[_loc2_] = _loc7_;
               }
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc11_:QuestParachuteGliderPlayer = null;
         var _loc8_:Boolean = false;
         var _loc7_:QuestParachuteGliderPlayer = null;
         var _loc5_:Number = NaN;
         var _loc6_:Object = null;
         var _loc9_:Object = null;
         var _loc2_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            if(_displayAchievementsTimer > 0)
            {
               _displayAchievementsTimer -= _frameTime;
               if(_displayAchievementsTimer <= 0)
               {
                  _displayAchievementsTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
            _lastTime = getTimer();
            if(_gameState == 1)
            {
               if(_dbIDs != null)
               {
                  _players = [];
                  _loc3_ = 0;
                  while(_loc3_ < _dbIDs.length)
                  {
                     _loc11_ = new QuestParachuteGliderPlayer(this);
                     _loc11_.preloadAnims(_userNames[_loc3_],_dbIDs[_loc3_]);
                     _players.push(_loc11_);
                     _loc3_++;
                  }
                  setGameState(2);
               }
            }
            else if(_gameState == 2)
            {
               _loc8_ = true;
               for each(_loc11_ in _players)
               {
                  if(_loc11_._waitingForAllLoaded)
                  {
                     _loc8_ = false;
                     break;
                  }
               }
               if(_loc8_)
               {
                  setGameState(3);
               }
            }
            if(!_pauseGame || _players.length > 1)
            {
               if(_gameState == 4 || _gameState == 5)
               {
                  _gameTime += _frameTime;
                  if(_controlsMC && _controlsMC.loader.parent && _gameTime > 3 && _controlsKeyPressed)
                  {
                     _controlsMC.loader.parent.removeChild(_controlsMC.loader);
                     _controlsMC = null;
                  }
                  _loc7_ = heartbeatPlayers();
                  heartbeatPhantoms();
                  heartbeatWinds();
                  heartbeatTrees();
               }
               if(_gameState == 4)
               {
                  if(_loc7_)
                  {
                     _scoreDisplay.loader.content.scorebackground.score.text = _loc7_._gemCount;
                     if(_debugDisplay)
                     {
                        _debugDisplay.loader.content.group.text = String(_loc7_._clone.y);
                     }
                     _loc5_ = -(_loc7_._clone.y - 300);
                     if(_ground.clone.loader.parent != null)
                     {
                        _loc5_ = Math.max(_loc5_,-(_ground.clone.loader.height + _ground.clone.loader.y - 550));
                     }
                     if(_loc5_ > 0)
                     {
                        _loc5_ = 0;
                     }
                     _layerGround.y = _loc5_;
                     _layerPlayers.y = _loc5_;
                     _layerBranch.y = _loc5_;
                     _layerGems.y = _loc5_;
                     _layerPhantoms.y = _loc5_;
                     _layerWinds.y = _loc5_;
                     _layerGround.y = _loc5_;
                     _layerBackground.y = _backgroundMoveSpeed * _loc5_;
                     _tower.loader.y = _layerBackground.y;
                  }
                  while(_currentRow < _levelData._data[_levelIndex].length)
                  {
                     if(_levelData._data[_levelIndex][_currentRow].row)
                     {
                        if(_layerBranch.y - 600 > -50 * _levelData._data[_levelIndex][_currentRow].row)
                        {
                           break;
                        }
                        if(_levelData._data[_levelIndex][_currentRow].gems)
                        {
                           _loc4_ = 0;
                           while(_loc4_ < _levelData._data[_levelIndex][_currentRow].gems.length)
                           {
                              if(_gemsCollected[_currentGemID] == null)
                              {
                                 _loc6_ = _scene.getLayer("gem");
                                 _loc9_ = null;
                                 if(_recycleGems.length > 0)
                                 {
                                    _loc9_ = _recycleGems[0];
                                    _recycleGems.splice(0,1);
                                    _loc9_.clone.content.gotoAndPlay(0);
                                 }
                                 else
                                 {
                                    _loc9_ = {};
                                    _loc9_.clone = _scene.cloneAsset("gem").loader;
                                 }
                                 _loc9_.width = _loc6_.loader.content.width;
                                 _loc9_.height = _loc6_.loader.content.height;
                                 _loc9_.radius = _loc6_.loader.content.width / 2 * 1.1;
                                 _loc9_.clone.x = 25 * _levelData._data[_levelIndex][_currentRow].gems[_loc4_] - 0;
                                 _loc9_.clone.y = 50 * _levelData._data[_levelIndex][_currentRow].row;
                                 _loc9_.centerPointX = _loc9_.clone.x + _loc6_.loader.content.x + _loc6_.loader.content.width / 2;
                                 _loc9_.centerPointY = _loc9_.clone.y + _loc6_.loader.content.y + _loc6_.loader.content.height / 2;
                                 _loc9_.enabled = true;
                                 _gems[_currentGemID] = _loc9_;
                                 _layerGems.addChild(_loc9_.clone);
                              }
                              _currentGemID++;
                              _loc4_++;
                           }
                        }
                     }
                     else if(_levelData._data[_levelIndex][_currentRow].ground)
                     {
                        if(_layerGround.y - 600 > -50 * _levelData._data[_levelIndex][_currentRow].ground)
                        {
                           break;
                        }
                        _layerGround.addChild(_ground.clone.loader);
                        if(_loc7_ && _loc7_._phantomsHit == 0)
                        {
                           _treasure.clone.loader.x = 730;
                           _treasure.clone.loader.y = _ground.clone.loader.y - 36;
                           _layerGround.addChild(_treasure.clone.loader);
                        }
                     }
                     _currentRow++;
                  }
                  if(_gameOverTimer > 0)
                  {
                     _gameOverTimer -= _frameTime;
                     if(_gameOverTimer <= 0)
                     {
                        setGameOver();
                     }
                  }
               }
               else if(_gameState == 5)
               {
                  _loc2_ = 0;
                  for each(_loc11_ in _players)
                  {
                     if(_loc11_._landed)
                     {
                        _loc2_++;
                     }
                  }
                  if(_loc2_ == _players.length)
                  {
                     onExit_Yes();
                  }
               }
            }
         }
      }
      
      private function heartbeatPlayers() : QuestParachuteGliderPlayer
      {
         var _loc3_:* = null;
         var _loc2_:* = null;
         var _loc1_:int = 0;
         for each(_loc3_ in _players)
         {
            _loc3_.heartbeat(_frameTime);
            if(_loc3_._landed)
            {
               _loc1_++;
            }
            if(_loc3_._localPlayer)
            {
               _loc2_ = _loc3_;
            }
         }
         if(_loc1_ > 0)
         {
            if(_treasure.clone.loader.parent && _loc2_ && _loc2_._landed)
            {
               if(_treasure.opened == false)
               {
                  _treasure.opened = true;
                  _treasure.clone.loader.content.gotoAndPlay("on");
                  if(_parachuteIdleSound)
                  {
                     _parachuteIdleSound.stop();
                     _parachuteIdleSound = null;
                  }
                  _loc2_._gemCount += 100;
                  _soundMan.playByName(_soundNameTreasureChest);
                  if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
                  }
               }
            }
            if(_loc2_ && _loc2_._landed)
            {
               if(_gameOverTimer == 0)
               {
                  _gameOverTimer = 1.5;
                  addGemsToBalance(_loc2_._gemCount);
                  if(_players.length > 1)
                  {
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(79,1);
                     }
                  }
               }
            }
         }
         return _loc2_;
      }
      
      private function heartbeatPhantoms() : void
      {
         var _loc1_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc2_:Number = NaN;
         var _loc6_:Boolean = false;
         for each(_loc1_ in _phantoms)
         {
            if(_loc1_.clone)
            {
               if(_loc1_.clone.content && _loc1_.clone.content.transition == null)
               {
                  if(_loc1_.polluteTimer > 0)
                  {
                     _loc1_.polluteTimer -= _frameTime;
                     if(_loc1_.polluteTimer <= 0)
                     {
                        _loc1_.polluteTimer = 0;
                        if(_loc1_.xSpeed > 0)
                        {
                           _loc1_.clone.content.gotoAndPlay("Right");
                           _loc1_.clone.content.currentLoop = "Right";
                        }
                        else if(_loc1_.xSpeed < 0)
                        {
                           _loc1_.clone.content.gotoAndPlay("Left");
                           _loc1_.clone.content.currentLoop = "Left";
                        }
                        else if(_loc1_.ySpeed > 0)
                        {
                           _loc1_.clone.content.gotoAndPlay("Down");
                           _loc1_.clone.content.currentLoop = "Down";
                        }
                        else if(_loc1_.ySpeed < 0)
                        {
                           _loc1_.clone.content.gotoAndPlay("Up");
                           _loc1_.clone.content.currentLoop = "Up";
                        }
                        else
                        {
                           _loc1_.clone.content.gotoAndPlay("Idle");
                           _loc1_.clone.content.currentLoop = "Idle";
                        }
                     }
                  }
                  else
                  {
                     _loc3_ = Number(_loc1_.currentX);
                     _loc4_ = Number(_loc1_.currentY);
                     if(_loc1_.xSpeed != 0)
                     {
                        _loc3_ += _loc1_.xSpeed * _frameTime;
                        if(_loc1_.xSpeed > 0)
                        {
                           if(_loc3_ > _loc1_.x + 200)
                           {
                              _loc1_.xSpeed = -_loc1_.xSpeed;
                              if(_loc1_.clone && _loc1_.clone.content)
                              {
                                 _loc1_.clone.content.transition = "Left";
                              }
                           }
                           else if(_loc1_.clone && _loc1_.clone.content && _loc1_.clone.content.transition == null && _loc1_.clone.content.currentLoop != "Right")
                           {
                              _loc1_.clone.content.gotoAndPlay("Right");
                              _loc1_.clone.content.currentLoop = "Right";
                           }
                        }
                        else if(_loc3_ < _loc1_.x)
                        {
                           _loc1_.xSpeed = -_loc1_.xSpeed;
                           if(_loc1_.clone && _loc1_.clone.content)
                           {
                              _loc1_.clone.content.transition = "Right";
                           }
                        }
                        else if(_loc1_.clone && _loc1_.clone.content && _loc1_.clone.content.transition == null && _loc1_.clone.content.currentLoop != "Left")
                        {
                           _loc1_.clone.content.gotoAndPlay("Left");
                           _loc1_.clone.content.currentLoop = "Left";
                        }
                     }
                     else if(_loc1_.ySpeed != 0)
                     {
                        _loc4_ += _loc1_.ySpeed * _frameTime;
                        if(_loc1_.ySpeed < 0)
                        {
                           if(_loc4_ < _loc1_.y - 250)
                           {
                              _loc1_.ySpeed = -_loc1_.ySpeed;
                              if(_loc1_.clone && _loc1_.clone.content)
                              {
                                 _loc1_.clone.content.transition = "Down";
                              }
                           }
                           else if(_loc1_.clone && _loc1_.clone.content && _loc1_.clone.content.transition == null && _loc1_.clone.content.currentLoop != "Up")
                           {
                              _loc1_.clone.content.gotoAndPlay("Up");
                              _loc1_.clone.content.currentLoop = "Up";
                           }
                        }
                        else if(_loc4_ > _loc1_.y)
                        {
                           _loc1_.ySpeed = -_loc1_.ySpeed;
                           if(_loc1_.clone && _loc1_.clone.content)
                           {
                              _loc1_.clone.content.transition = "Up";
                           }
                        }
                        else if(_loc1_.clone && _loc1_.clone.content && _loc1_.clone.content.transition == null && _loc1_.clone.content.currentLoop != "Down")
                        {
                           _loc1_.clone.content.gotoAndPlay("Down");
                           _loc1_.clone.content.currentLoop = "Down";
                        }
                     }
                     _loc1_.currentX = _loc3_;
                     _loc1_.currentY = _loc4_;
                     if(_loc1_.clone)
                     {
                        _loc1_.clone.x = _loc3_;
                        _loc1_.clone.y = _loc4_;
                     }
                  }
               }
            }
            else if(_layerPhantoms.y - 600 + _loc1_.currentY <= 0)
            {
               if(_loc1_.ySpeed != 0)
               {
                  if(_recyclePhantoms.length > 0)
                  {
                     _loc1_.clone = _recyclePhantoms[0].clone;
                     _recyclePhantoms.splice(0,1);
                     if(_loc1_.ySpeed > 0)
                     {
                        _loc1_.clone.content.gotoAndPlay("Down");
                        _loc1_.clone.content.currentLoop = "Down";
                     }
                     else
                     {
                        _loc1_.clone.content.gotoAndPlay("Up");
                        _loc1_.clone.content.currentLoop = "Up";
                     }
                  }
                  else if(_loc1_.ySpeed > 0)
                  {
                     _loc1_.clone = _scene.cloneAsset("phantom").loader;
                     _loc1_.clone.contentLoaderInfo.addEventListener("complete",onPhantomVerticalDownLoaderComplete);
                  }
                  else
                  {
                     _loc1_.clone = _scene.cloneAsset("phantom").loader;
                     _loc1_.clone.contentLoaderInfo.addEventListener("complete",onPhantomVerticalLoaderComplete);
                  }
               }
               else if(_loc1_.xSpeed != 0)
               {
                  if(_recyclePhantoms.length > 0)
                  {
                     _loc1_.clone = _recyclePhantoms[0].clone;
                     _recyclePhantoms.splice(0,1);
                     if(_loc1_.xSpeed > 0)
                     {
                        _loc1_.clone.content.gotoAndPlay("Right");
                        _loc1_.clone.content.currentLoop = "Right";
                     }
                     else if(_loc1_.xSpeed < 0)
                     {
                        _loc1_.clone.content.gotoAndPlay("Left");
                        _loc1_.clone.content.currentLoop = "Left";
                     }
                  }
                  else if(_loc1_.xSpeed > 0)
                  {
                     _loc1_.clone = _scene.cloneAsset("phantom").loader;
                     _loc1_.clone.contentLoaderInfo.addEventListener("complete",onPhantomHorizontalLoaderComplete);
                  }
                  else
                  {
                     _loc1_.clone = _scene.cloneAsset("phantom").loader;
                     _loc1_.clone.contentLoaderInfo.addEventListener("complete",onPhantomHorizontalLeftLoaderComplete);
                  }
               }
               else if(_recyclePhantoms.length > 0)
               {
                  _loc1_.clone = _recyclePhantoms[0].clone;
                  _recyclePhantoms.splice(0,1);
                  _loc1_.clone.content.gotoAndPlay("Idle");
                  _loc1_.clone.content.currentLoop = "Idle";
               }
               else
               {
                  _loc1_.clone = _scene.cloneAsset("phantom").loader;
                  _loc1_.clone.contentLoaderInfo.addEventListener("complete",onPhantomIdleLoaderComplete);
               }
               _loc1_.clone.x = _loc1_.currentX;
               _loc1_.clone.y = _loc1_.currentY;
               _layerPhantoms.addChild(_loc1_.clone);
            }
         }
         _loc5_ = 0;
         while(_loc5_ < _phantoms.length)
         {
            if(_phantoms[_loc5_].clone && _phantoms[_loc5_].clone.content)
            {
               _loc2_ = _phantoms[_loc5_].y + _layerPhantoms.y;
               if(_loc2_ <= -600)
               {
                  _recyclePhantoms.push(_phantoms[_loc5_]);
                  _phantoms[_loc5_].clone.parent.removeChild(_phantoms[_loc5_].clone);
                  _phantoms.splice(_loc5_,1);
               }
               else if(_loc2_ > 0 && _loc2_ <= 550)
               {
                  _loc6_ = true;
               }
            }
            _loc5_++;
         }
         if(_loc6_)
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
      
      private function heartbeatWinds() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _winds.length)
         {
            if(_winds[_loc1_].clone.y + _winds[_loc1_].height + _layerWinds.y <= -600)
            {
               _recycleWinds.push(_winds[_loc1_]);
               _winds[_loc1_].clone.parent.removeChild(_winds[_loc1_].clone);
               _winds.splice(_loc1_,1);
            }
            _loc1_++;
         }
      }
      
      private function heartbeatTrees() : void
      {
         var _loc2_:Object = null;
         var _loc1_:Number = NaN;
         for(_loc2_ in _gems)
         {
            if(_gems[_loc2_].clone && _gems[_loc2_].clone.parent != null)
            {
               _loc1_ = _gems[_loc2_].clone.y + _layerGems.y;
               if(_loc1_ <= -150)
               {
                  _gems[_loc2_].clone.parent.removeChild(_gems[_loc2_].clone);
                  _gems[_loc2_].clone.content.stop();
                  _recycleGems.push(_gems[_loc2_]);
                  delete _gems[_loc2_];
               }
            }
         }
      }
      
      public function onBranchLoaderComplete(param1:Event) : void
      {
         param1.target.content.gotoAndPlay("off");
         param1.target.removeEventListener("complete",onBranchLoaderComplete);
      }
      
      public function onPhantomVerticalLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Up";
         param1.target.removeEventListener("complete",onPhantomVerticalLoaderComplete);
      }
      
      public function onPhantomVerticalDownLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Down";
         param1.target.removeEventListener("complete",onPhantomVerticalDownLoaderComplete);
      }
      
      public function onPhantomHorizontalLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Right";
         param1.target.removeEventListener("complete",onPhantomHorizontalLoaderComplete);
      }
      
      public function onPhantomHorizontalLeftLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Left";
         param1.target.removeEventListener("complete",onPhantomHorizontalLeftLoaderComplete);
      }
      
      public function onPhantomIdleLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Idle";
         param1.target.removeEventListener("complete",onPhantomIdleLoaderComplete);
      }
      
      public function startGame(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         _gameOverTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _currentLevel = 0;
         _nextLevelAddY = 450;
         _recycleGems = [];
         _recyclePhantoms = [];
         _recycleWinds = [];
         _gems = new Dictionary();
         _gemsCollected = new Dictionary();
         _currentGemID = 0;
         _phantoms = [];
         _currentPhantomID = 0;
         _winds = [];
         _treasure.opened = false;
         _treasure.clone.loader.content.gotoAndPlay("off");
         var _loc6_:int = 4;
         _maxTotalY = _nextLevelAddY;
         _currentRow = 0;
         _loc5_ = 0;
         while(_loc5_ < _levelData._data[_levelIndex].length)
         {
            if(_levelData._data[_levelIndex][_loc5_].ground)
            {
               _ground.clone.loader.x = 0;
               _ground.clone.loader.y = 50 * _levelData._data[_levelIndex][_loc5_].ground;
               _maxTotalY = 50 * _levelData._data[_levelIndex][_loc5_].ground;
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < _levelData._data[_levelIndex].length)
         {
            if(_levelData._data[_levelIndex][_loc5_].phantomidle)
            {
               _loc3_ = 0;
               while(_loc3_ < _levelData._data[_levelIndex][_loc5_].phantomidle.length)
               {
                  createPhantom(0,0,_levelData._data[_levelIndex][_loc5_].row,_levelData._data[_levelIndex][_loc5_].phantomidle[_loc3_]);
                  _loc3_++;
               }
            }
            if(_levelData._data[_levelIndex][_loc5_].phantomhorizontal)
            {
               _loc3_ = 0;
               while(_loc3_ < _levelData._data[_levelIndex][_loc5_].phantomhorizontal.length)
               {
                  createPhantom(40,0,_levelData._data[_levelIndex][_loc5_].row,_levelData._data[_levelIndex][_loc5_].phantomhorizontal[_loc3_]);
                  _loc3_++;
               }
            }
            if(_levelData._data[_levelIndex][_loc5_].phantomvertical)
            {
               _loc3_ = 0;
               while(_loc3_ < _levelData._data[_levelIndex][_loc5_].phantomvertical.length)
               {
                  createPhantom(0,-40,_levelData._data[_levelIndex][_loc5_].row,_levelData._data[_levelIndex][_loc5_].phantomvertical[_loc3_]);
                  _loc3_++;
               }
            }
            if(_levelData._data[_levelIndex][_loc5_].phantomhorizontalLeft)
            {
               _loc3_ = 0;
               while(_loc3_ < _levelData._data[_levelIndex][_loc5_].phantomhorizontalLeft.length)
               {
                  createPhantom(-40,0,_levelData._data[_levelIndex][_loc5_].row,_levelData._data[_levelIndex][_loc5_].phantomhorizontalLeft[_loc3_]);
                  _loc3_++;
               }
            }
            if(_levelData._data[_levelIndex][_loc5_].phantomverticalDown)
            {
               _loc3_ = 0;
               while(_loc3_ < _levelData._data[_levelIndex][_loc5_].phantomverticalDown.length)
               {
                  createPhantom(0,40,_levelData._data[_levelIndex][_loc5_].row,_levelData._data[_levelIndex][_loc5_].phantomverticalDown[_loc3_]);
                  _loc3_++;
               }
            }
            _loc5_++;
         }
         _loc2_ = _scene.getLayer("sky");
         _backgroundMoveSpeed = 0;
         if(_loc2_)
         {
            _backgroundMoveSpeed = (_loc2_.loader.height - 600) / _maxTotalY;
         }
         if(_debugDisplay)
         {
            _debugDisplay.loader.content.level.text = String(_levelIndex + 1);
         }
         var _loc4_:int = parseInt(param1[_loc6_++]);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc6_ = int(_players[_loc5_].init(param1,_loc6_,_scene.cloneAsset("parachute_p" + (_loc5_ + 1)),_loc5_ + 1));
            _loc5_++;
         }
         _parachuteIdleSound = _soundMan.play(SFX_ParachuteIdle,0,99999);
         _musicInstance = _soundMan.playStream(_SFX_Music,0,99999);
         if(_spiral)
         {
            _spiral.destroy();
         }
         _controlsMC = _scene.getLayer("controls");
         if(_controlsMC)
         {
            _controlsKeyPressed = false;
            _controlsMC.loader.x = 0;
            _controlsMC.loader.y = -50;
            _guiLayer.addChild(_controlsMC.loader);
         }
         setGameState(4);
      }
      
      public function createPhantom(param1:Number, param2:Number, param3:int, param4:int) : void
      {
         var _loc5_:Object = {};
         var _loc6_:Number = param4 * 25;
         _loc6_ = _loc6_ - 28 - 0;
         _loc5_.phantomID = _currentPhantomID++;
         _loc5_.xSpeed = param1;
         _loc5_.ySpeed = param2;
         _loc5_.polluteTimer = 0;
         _loc5_.x = _loc6_;
         _loc5_.y = param3 * 50;
         _loc5_.currentX = _loc5_.x;
         _loc5_.currentY = _loc5_.y;
         if(param1 < 0)
         {
            _loc5_.x -= 200;
         }
         if(param2 > 0)
         {
            _loc5_.y += 250;
         }
         _phantoms.push(_loc5_);
      }
      
      public function resetGame() : void
      {
         var _loc4_:* = null;
         var _loc2_:Object = null;
         var _loc1_:* = null;
         if(_players)
         {
            for each(_loc4_ in _players)
            {
               _loc4_.remove();
            }
            if(_players.length > 0)
            {
               _players.splice(0,_players.length);
            }
         }
         if(_gems)
         {
            for(_loc2_ in _gems)
            {
               if(_gems[_loc2_] && _gems[_loc2_].clone)
               {
                  if(_gems[_loc2_].clone.parent)
                  {
                     _gems[_loc2_].clone.parent.removeChild(_gems[_loc2_].clone);
                  }
                  _scene.releaseCloneAsset(_gems[_loc2_].clone);
                  delete _gems[_loc2_];
               }
            }
         }
         if(_recycleGems)
         {
            for each(_loc1_ in _recycleGems)
            {
               if(_loc1_ && _loc1_.clone)
               {
                  if(_loc1_.clone.parent)
                  {
                     _loc1_.clone.parent.removeChild(_loc1_.clone);
                  }
                  _scene.releaseCloneAsset(_loc1_.clone);
               }
            }
            if(_recycleGems.length > 0)
            {
               _recycleGems.splice(0,_recycleGems.length);
            }
         }
         if(_phantoms)
         {
            for each(_loc1_ in _phantoms)
            {
               if(_loc1_ && _loc1_.clone)
               {
                  if(_loc1_.clone.parent)
                  {
                     _loc1_.clone.parent.removeChild(_loc1_.clone);
                  }
                  _scene.releaseCloneAsset(_loc1_.clone);
               }
            }
            if(_phantoms.length > 0)
            {
               _phantoms.splice(0,_phantoms.length);
            }
         }
         if(_recyclePhantoms)
         {
            for each(_loc1_ in _recyclePhantoms)
            {
               if(_loc1_ && _loc1_.clone)
               {
                  if(_loc1_.clone.parent)
                  {
                     _loc1_.clone.parent.removeChild(_loc1_.clone);
                  }
                  _scene.releaseCloneAsset(_loc1_.clone);
               }
            }
            if(_recyclePhantoms.length > 0)
            {
               _recyclePhantoms.splice(0,_recyclePhantoms.length);
            }
         }
         if(_winds)
         {
            for each(_loc1_ in _winds)
            {
               if(_loc1_ && _loc1_.clone)
               {
                  if(_loc1_.clone.parent)
                  {
                     _loc1_.clone.parent.removeChild(_loc1_.clone);
                  }
                  _scene.releaseCloneAsset(_loc1_.clone);
               }
            }
            if(_winds.length > 0)
            {
               _winds.splice(0,_winds.length);
            }
         }
         if(_recycleWinds)
         {
            for each(_loc1_ in _recycleWinds)
            {
               if(_loc1_ && _loc1_.clone)
               {
                  if(_loc1_.clone.parent)
                  {
                     _loc1_.clone.parent.removeChild(_loc1_.clone);
                  }
                  _scene.releaseCloneAsset(_loc1_.clone);
               }
            }
            if(_recycleWinds.length > 0)
            {
               _recycleWinds.splice(0,_recycleWinds.length);
            }
         }
         if(_treasure.clone && _treasure.clone.loader.parent)
         {
            _treasure.clone.loader.parent.removeChild(_treasure.clone.loader);
         }
      }
      
      public function gemPickup(param1:int) : void
      {
         if(_gems[param1].enabled)
         {
            _gems[param1].enabled = false;
            _gems[param1].clone.parent.removeChild(_gems[param1].clone);
            _gems[param1].clone.content.stop();
            _recycleGems.push(_gems[param1]);
            delete _gems[param1];
         }
      }
      
      private function setGameOver() : void
      {
         if(_gameState != 5)
         {
            _displayAchievementsTimer = 1;
            _gameResult = 1;
            _delayExitTimer = 3;
            setGameState(5);
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(10683),false,ExitConfirm);
      }
      
      private function ExitConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            onExit_Yes();
         }
      }
      
      private function onExit_Yes() : void
      {
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
         hideDlg();
      }
   }
}

