package game.riverRace
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.Collision;
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class RiverRace extends GameBase implements IMinigame
   {
      private static const WAITING_PLAYER_TEXT:String = "waiting...";
      
      private static const QUIT_PLAYER_TEXT:String = "quit game";
      
      private static const OFFSCREEN_ADD_HEIGHT:int = 600;
      
      private static const OFFSCREEN_REMOVE_HEIGHT:int = 551;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const PLAYER_SCREEN_Y:Number = 400;
      
      private static const TREE1_SPEED_FACTOR:Number = 0.5;
      
      public static const PHANTOMSPEED:Number = 40;
      
      public static const MAX_PHANTOM_MOVE:Number = 400;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_READY_TO_START:int = 1;
      
      public static const GAMESTATE_STARTED:int = 2;
      
      public static const GAMESTATE_ENDED:int = 3;
      
      public static var SFX_Raft:Class;
      
      public static var SFX_Whirlpool:Class;
      
      public var _levels:Array;
      
      public var _waitingForOtherPlayerDisplay:Object;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackground:Sprite;
      
      public var _layerBuoys:Sprite;
      
      public var _layerForeground:Sprite;
      
      public var _layerPlayers:Sprite;
      
      public var _layerLocalPlayer:Sprite;
      
      public var _gameState:int;
      
      public var _players:Array;
      
      public var _river:Array;
      
      public var _riverSegments:Array;
      
      public var _riverCurrentY:int;
      
      public var _levelProgression:Array;
      
      public var _riverCurrentSegment:int;
      
      public var _randomizer:RandomSeed;
      
      public var _levelIndex:int;
      
      public var _currentBuoyIndex:int;
      
      public var _currentBuoyY:int;
      
      public var _progressBar:Object;
      
      public var _maxTotalY:Number;
      
      public var _startingLine:Object;
      
      public var _finishLine:Object;
      
      private var _debugDisplay:Object;
      
      private var _debugLine:MovieClip;
      
      public var _leftArrowDown:Boolean;
      
      public var _rightArrowDown:Boolean;
      
      public var _downArrowDown:Boolean;
      
      public var _upArrowDown:Boolean;
      
      public var _readySetGo:Number;
      
      public var _readyMC:Object;
      
      public var _controlsMC:Object;
      
      public var _currentPlayerIndex:int;
      
      public var _controlsKeyPressed:Boolean;
      
      public var _inactiveBuoys:Array;
      
      public var _inactiveRocks:Array;
      
      public var _inactiveWhirlpools:Array;
      
      public var _arrowOffsetX:Number;
      
      public var _arrowOffsetY:Number;
      
      public var _rocksOffsetX:Number;
      
      public var _rocksOffsetY:Number;
      
      public var _whirlpoolOffsetX:Number;
      
      public var _whirlpoolOffsetY:Number;
      
      public var _resultsPopup:MovieClip;
      
      public var _resultsNames:Array;
      
      public var _resultsTotal:int;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["RR_duck_quack.mp3","RR_insect_jump.mp3","RR_raft_collision.mp3","RR_Turbo.mp3","RR_whirlpool_collision.mp3","RR_Rock_collision.mp3","GS_Ready_blink_Go.mp3"];
      
      private var _soundNameQuack:String = _audio[0];
      
      private var _soundNameInsect:String = _audio[1];
      
      internal var _soundNameCollision:String = _audio[2];
      
      internal var _soundNameTurbo:String = _audio[3];
      
      internal var _soundNameWhirlpoolCollision:String = _audio[4];
      
      internal var _soundNameRockCollision:String = _audio[5];
      
      private var _soundNameReadyGo:String = _audio[6];
      
      private var _SFX_Raft_Instance:SoundChannel;
      
      private var _SFX_Whirlpool_Instance:SoundChannel;
      
      public var _SFX_Quack:Sound;
      
      public var _SFX_Insect:Sound;
      
      public var _SFX_Collision:Sound;
      
      public var _SFX_River_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function RiverRace()
      {
         super();
         _inactiveBuoys = [];
         _inactiveRocks = [];
         _inactiveWhirlpools = [];
         initLevels();
         _players = [];
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_River_Music = _soundMan.addStream("aj_mus_river_race",1);
         _soundMan.addSound(SFX_Whirlpool,1,"SFX_Whirlpool");
         _soundMan.addSound(SFX_Raft,1,"SFX_Raft");
         _soundMan.addSoundByName(_audioByName[_soundNameQuack],_soundNameQuack,1);
         _soundMan.addSoundByName(_audioByName[_soundNameInsect],_soundNameInsect,1);
         _soundMan.addSoundByName(_audioByName[_soundNameCollision],_soundNameCollision,1);
         _soundMan.addSoundByName(_audioByName[_soundNameTurbo],_soundNameTurbo,0.52);
         _soundMan.addSoundByName(_audioByName[_soundNameWhirlpoolCollision],_soundNameWhirlpoolCollision,0.52);
         _soundMan.addSoundByName(_audioByName[_soundNameRockCollision],_soundNameRockCollision,0.52);
         _soundMan.addSoundByName(_audioByName[_soundNameReadyGo],_soundNameReadyGo,0.52);
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               _leftArrowDown = false;
               break;
            case 1:
               _upArrowDown = false;
               break;
            case 2:
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
               _controlsKeyPressed = true;
               _leftArrowDown = true;
               break;
            case 1:
               _controlsKeyPressed = true;
               _upArrowDown = true;
               break;
            case 2:
               _controlsKeyPressed = true;
               _rightArrowDown = true;
               break;
            case 3:
               _controlsKeyPressed = true;
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
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_SFX_Raft_Instance)
         {
            _soundMan.stop(_SFX_Raft_Instance);
            _SFX_Raft_Instance = null;
         }
         if(_SFX_Whirlpool_Instance)
         {
            _soundMan.stop(_SFX_Whirlpool_Instance);
            _SFX_Whirlpool_Instance = null;
         }
         stage.removeEventListener("keyDown",exitGameKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         _bInit = false;
         _riverSegments = null;
         if(_debugLine)
         {
            _debugLine.parent.removeChild(_debugLine);
            _debugLine = null;
         }
         removeLayer(_layerForeground);
         removeLayer(_layerBackground);
         removeLayer(_layerBuoys);
         removeLayer(_layerPlayers);
         removeLayer(_layerLocalPlayer);
         removeLayer(_guiLayer);
         _layerForeground = null;
         _layerBackground = null;
         _layerBuoys = null;
         _layerPlayers = null;
         _layerLocalPlayer = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            setGameState(0);
            _resultsPopup = null;
            _resultsNames = new Array("waiting...","waiting...","waiting...","waiting...");
            _resultsTotal = -1;
            _debugLine = null;
            _layerForeground = new Sprite();
            _layerForeground.mouseEnabled = false;
            _layerBackground = new Sprite();
            _layerBuoys = new Sprite();
            _layerBackground.mouseEnabled = false;
            _layerBuoys.mouseEnabled = false;
            _layerPlayers = new Sprite();
            _layerLocalPlayer = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerBackground);
            addChild(_layerBuoys);
            addChild(_layerPlayers);
            addChild(_layerLocalPlayer);
            addChild(_layerForeground);
            addChild(_guiLayer);
            _riverSegments = [];
            loadScene("RiverRaceAssets/room_main_new.xroom",_audio);
            _bInit = true;
         }
         else if(_sceneLoaded && MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc7_:int = 0;
         var _loc3_:RiverSegment = null;
         var _loc4_:Object = null;
         var _loc6_:String = null;
         var _loc5_:Array = _scene.getActorList("ActorVolume");
         SFX_Raft = getDefinitionByName("RR_raft_ambience") as Class;
         if(SFX_Raft == null)
         {
            throw new Error("Sound not found! name:RR_raft_ambience");
         }
         SFX_Whirlpool = getDefinitionByName("RR_whirlpool") as Class;
         if(SFX_Whirlpool == null)
         {
            throw new Error("Sound not found! name:RR_whirlpool");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_River_Music,0,999999);
         _loc4_ = _scene.getLayer("river_start");
         if(_loc4_)
         {
            _startingLine = _scene.getLayer("startingline");
            _arrowOffsetX = _scene.getLayer("arrows").x - _startingLine.x;
            _arrowOffsetY = _scene.getLayer("arrows").y - _startingLine.y;
            _rocksOffsetX = _scene.getLayer("rocks").x - _startingLine.x;
            _rocksOffsetY = _scene.getLayer("rocks").y - _startingLine.y;
            _whirlpoolOffsetX = _scene.getLayer("whirlpool").x - _startingLine.x;
            _whirlpoolOffsetY = _scene.getLayer("whirlpool").y - _startingLine.y;
            _startingLine.x -= _loc4_.x;
            _startingLine.y -= _loc4_.y;
            _finishLine = _scene.getLayer("finishline");
            _finishLine.x -= _loc4_.x;
            _finishLine.y -= _loc4_.y;
            _loc3_ = new RiverSegment(this);
            _loc3_.init(_loc4_,"river_start",true);
            _riverSegments.push(_loc3_);
         }
         _loc7_ = 1;
         while(_loc7_ <= 2)
         {
            _loc6_ = "river_" + _loc7_;
            _loc4_ = _scene.getLayer(_loc6_);
            if(_loc4_)
            {
               _loc3_ = new RiverSegment(this);
               _loc3_.init(_loc4_,_loc6_,false,_loc7_);
               _riverSegments.push(_loc3_);
            }
            _loc7_++;
         }
         _progressBar = {};
         _progressBar.clone = _scene.getLayer("progress_bar2");
         _progressBar.clone.loader.x = 10;
         _progressBar.clone.loader.y = (550 - _progressBar.clone.height) / 2;
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _sceneLoaded = true;
         _leftArrowDown = false;
         _rightArrowDown = false;
         _downArrowDown = false;
         _upArrowDown = false;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("keyDown",keyHandleDown);
         _controlsMC = _scene.getLayer("controls");
         if(_controlsMC)
         {
            _controlsMC.loader.x = 0;
            _controlsMC.loader.y = -50;
            _guiLayer.addChild(_controlsMC.loader);
            _controlsKeyPressed = false;
         }
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
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
                  startPreGame();
            }
            _gameState = param1;
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc7_:* = null;
         var _loc6_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         if(param1[0] == "ml")
         {
            _loc6_ = uint(int(param1[2]));
            _loc3_ = 0;
            while(true)
            {
               if(_loc3_ < _players.length)
               {
                  if(_players[_loc3_]._netID != _loc6_)
                  {
                     continue;
                  }
                  _players[_loc3_].remove();
                  _players.splice(_loc3_,1);
                  updateGameOverDlg();
               }
               _loc3_++;
            }
         }
         else if(param1[0] == "ms")
         {
            _dbIDs = [];
            _userNames = [];
            _loc4_ = 1;
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _dbIDs[_loc3_] = param1[_loc4_++];
               _userNames[_loc3_] = param1[_loc4_++];
               _loc3_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "start")
            {
               startGame(param1);
            }
            else if(param1[2] == "pos")
            {
               _loc6_ = uint(int(param1[3]));
               _loc5_ = 4;
               for each(_loc7_ in _players)
               {
                  if(_loc7_._netID == _loc6_)
                  {
                     _loc5_ = _loc7_.receivePositionData(param1,_loc5_);
                     break;
                  }
               }
            }
            else if(param1[2] == "playerfinish")
            {
               _loc5_ = 3;
               _loc2_ = parseInt(param1[_loc5_++]);
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  _loc6_ = parseInt(param1[_loc5_++]);
                  for each(_loc7_ in _players)
                  {
                     if(_loc7_._netID == _loc6_ && _loc7_._finishedPlace <= 0 && parseInt(param1[_loc5_]) > 0)
                     {
                        _loc7_.setFinishedPlace(parseInt(param1[_loc5_]),_resultsTotal);
                        if(_loc7_._localPlayer)
                        {
                           addGemsToBalance(_loc7_._gemCount);
                        }
                        _resultsNames[parseInt(param1[_loc5_]) - 1] = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_loc7_._userName,_loc7_._dbID).avName;
                        break;
                     }
                  }
                  _loc5_++;
                  _loc3_++;
               }
               updateGameOverDlg();
            }
            else if(param1[2] == "finish")
            {
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc6_:RiverRacePlayer = null;
         var _loc5_:Number = NaN;
         var _loc3_:RiverSegment = null;
         var _loc2_:Boolean = false;
         var _loc7_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if((!_pauseGame || _players.length > 1) && _gameState == 2)
            {
               if(_readySetGo > 0)
               {
                  _readySetGo -= _frameTime;
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
               _gameTime += _frameTime;
               _loc6_ = heartbeatPlayers();
               if(_loc6_)
               {
                  _loc5_ = _loc6_._clone.loader.y - 400;
                  _loc5_ = Math.min(_loc5_,-550);
                  _loc5_ = Math.max(_loc5_,_riverCurrentY);
                  _layerForeground.y = -_loc5_;
                  _layerBackground.y = -_loc5_;
                  _layerBuoys.y = -_loc5_;
                  _layerPlayers.y = -_loc5_;
                  _layerLocalPlayer.y = -_loc5_;
               }
               if(_riverCurrentSegment <= _levelProgression.length && _river.length < 2)
               {
                  if(_riverCurrentY + _layerBackground.y > -600)
                  {
                     _loc3_ = null;
                     if(_riverCurrentSegment < _levelProgression.length)
                     {
                        _loc3_ = _riverSegments[_levelProgression[_riverCurrentSegment].segment];
                     }
                     else
                     {
                        _loc4_ = 0;
                        while(_loc4_ < _riverSegments.length)
                        {
                           if(_riverSegments[_loc4_]._startEnd)
                           {
                              _loc3_ = _riverSegments[_loc4_];
                              break;
                           }
                           _loc4_++;
                        }
                     }
                     if(_loc3_)
                     {
                        _riverCurrentSegment++;
                        _riverCurrentY -= _loc3_.getHeight() - 1;
                        _loc3_.add(_riverCurrentY);
                        _river.push(_loc3_);
                     }
                  }
               }
               _loc4_ = 0;
               while(_loc4_ < _river.length)
               {
                  if(_river[_loc4_]._scene.y + _layerBackground.y > 551)
                  {
                     _river[_loc4_].remove();
                     _river.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
               _loc2_ = false;
               _loc4_ = 0;
               while(_loc4_ < _river.length)
               {
                  if(_river[_loc4_]._whirlpools)
                  {
                     _loc7_ = 0;
                     while(_loc7_ < _river[_loc4_]._whirlpools.length)
                     {
                        if(_river[_loc4_]._whirlpools[_loc7_].loader.y + _layerBuoys.y > 0 && _river[_loc4_]._whirlpools[_loc7_].loader.y + _layerBuoys.y < 551)
                        {
                           _loc2_ = true;
                           break;
                        }
                        _loc7_++;
                     }
                  }
                  _loc4_++;
               }
               if(_loc2_)
               {
                  if(_SFX_Whirlpool_Instance == null)
                  {
                     _SFX_Whirlpool_Instance = _soundMan.play(SFX_Whirlpool,0,99999);
                  }
               }
               else if(_SFX_Whirlpool_Instance)
               {
                  _soundMan.stop(_SFX_Whirlpool_Instance);
                  _SFX_Whirlpool_Instance = null;
               }
            }
         }
      }
      
      private function heartbeatPlayers() : RiverRacePlayer
      {
         var _loc2_:* = null;
         var _loc1_:* = null;
         for each(_loc2_ in _players)
         {
            if(_readySetGo > 0)
            {
               _loc2_.heartbeat(0);
            }
            else
            {
               _loc2_.heartbeat(_frameTime);
            }
            if(_loc2_._localPlayer)
            {
               _loc1_ = _loc2_;
            }
         }
         return _loc1_;
      }
      
      public function startPreGame() : void
      {
         var _loc1_:* = null;
         _river = [];
         _currentBuoyIndex = 0;
         _currentBuoyY = 0;
         _maxTotalY = 0;
         for each(_loc1_ in _riverSegments)
         {
            if(_loc1_._startEnd)
            {
               _riverCurrentY = -(_loc1_.getHeight() - 1);
               _loc1_.add(_riverCurrentY,true);
               _river.push(_loc1_);
               _layerBackground.x = 0;
               _layerBackground.y = -(_startingLine.loader.y + _startingLine.height - 400);
               _layerBuoys.x = 0;
               _layerBuoys.y = _layerBackground.y;
               _layerForeground.x = 0;
               _layerForeground.y = _layerBackground.y;
               _riverCurrentSegment = 0;
               _layerPlayers.y = _layerBackground.y;
               _layerLocalPlayer.y = _layerBackground.y;
               _maxTotalY += _loc1_.getHeight();
               break;
            }
         }
         if(_waitingForOtherPlayerDisplay == null)
         {
            _waitingForOtherPlayerDisplay = _scene.getLayer("popup_waiting");
            _guiLayer.addChild(_waitingForOtherPlayerDisplay.loader);
         }
         _waitingForOtherPlayerDisplay.loader.visible = true;
         _waitingForOtherPlayerDisplay.loader.x = 450 - _waitingForOtherPlayerDisplay.width / 2;
         _waitingForOtherPlayerDisplay.loader.y = 275 - _waitingForOtherPlayerDisplay.height / 2;
         _waitingForOtherPlayerDisplay.loader.content.gotoAndPlay("on");
      }
      
      public function startGame(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc2_:RiverSegment = null;
         var _loc10_:Object = null;
         var _loc11_:RiverRacePlayer = null;
         if(_waitingForOtherPlayerDisplay && _waitingForOtherPlayerDisplay.loader.parent)
         {
            _waitingForOtherPlayerDisplay.loader.content.gotoAndPlay("off");
            _waitingForOtherPlayerDisplay.loader.visible = false;
         }
         _readySetGo = 3;
         _readyMC = _scene.cloneAsset("ready");
         if(_readyMC)
         {
            _readyMC.loader.x = 450;
            _readyMC.loader.y = 275;
            _guiLayer.addChild(_readyMC.loader);
            _soundMan.playByName(_soundNameReadyGo);
         }
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         var _loc6_:int = 3;
         _levelProgression = [];
         var _loc3_:uint = parseInt(param1[_loc6_++]);
         _randomizer = new RandomSeed(_loc3_);
         _levelIndex = _randomizer.integer(_levels.length);
         var _loc8_:Number = _maxTotalY - -(_riverCurrentY - _currentBuoyY);
         _loc5_ = 0;
         while(_loc5_ < _levels[_levelIndex].length)
         {
            _loc8_ += _levels[_levelIndex][_loc5_].offset;
            _loc5_++;
         }
         _loc5_ = 0;
         var _loc7_:int = 1;
         while(_maxTotalY + 300 < _loc8_)
         {
            _loc2_ = _riverSegments[_loc7_];
            _loc10_ = {};
            _loc10_.segment = _loc7_;
            _levelProgression.push(_loc10_);
            _maxTotalY += _loc2_.getHeight();
            _loc5_++;
            _loc7_++;
            if(_loc7_ > 2)
            {
               _loc7_ = 1;
            }
         }
         _loc2_ = null;
         _loc5_ = 0;
         while(_loc5_ < _riverSegments.length)
         {
            if(_riverSegments[_loc5_]._startEnd)
            {
               _loc2_ = _riverSegments[_loc5_];
               break;
            }
            _loc5_++;
         }
         if(_loc2_)
         {
            _maxTotalY += 2 * _loc2_.getHeight() / 3;
         }
         _guiLayer.addChild(_progressBar.clone.loader);
         var _loc9_:Array = new Array("green","red","blue","yellow");
         _currentPlayerIndex = 1;
         while(_players.length > 0)
         {
            _players.splice(0,1);
         }
         var _loc4_:int = parseInt(param1[_loc6_++]);
         _loc5_ = 0;
         while(_loc5_ < _loc4_)
         {
            _loc11_ = new RiverRacePlayer(this);
            _loc6_ = _loc11_.init(_userNames[_loc5_],_dbIDs[_loc5_],param1,_loc6_,_loc9_[_loc5_]);
            _players.push(_loc11_);
            _loc5_++;
         }
         while(_currentPlayerIndex < 4)
         {
            _progressBar.clone.loader.content.sizeColor("small","none",_currentPlayerIndex++);
         }
         if(_SFX_Raft_Instance == null)
         {
            _SFX_Raft_Instance = _soundMan.play(SFX_Raft,0,99999);
         }
         _resultsTotal = _loc4_;
         setGameState(2);
      }
      
      public function resetGame() : void
      {
         var _loc3_:* = null;
         var _loc1_:* = null;
         for each(_loc3_ in _players)
         {
            _loc3_.remove();
         }
         if(_progressBar.clone.loader.parent)
         {
            _progressBar.clone.loader.removeChild(_progressBar.clone.loader);
         }
         for each(_loc1_ in _river)
         {
            _loc1_.remove();
         }
         _river = null;
      }
      
      public function TestObstacleCollision(param1:Point, param2:int) : Object
      {
         return null;
      }
      
      public function TestShoreCollision(param1:RiverRacePlayer, param2:Point, param3:Point, param4:int) : Point
      {
         var _loc5_:* = null;
         var _loc10_:* = null;
         var _loc9_:int = 0;
         var _loc11_:* = 1;
         var _loc12_:Point = null;
         var _loc8_:Point = null;
         var _loc6_:Point = new Point();
         var _loc7_:Point = new Point();
         var _loc13_:Number = -1;
         for each(_loc5_ in _river)
         {
            if(param2.y - param4 > _loc5_._scene.y && param2.y - param4 < _loc5_._scene.y + _loc5_.getHeight() || param2.y + param4 > _loc5_._scene.y && param2.y + param4 < _loc5_._scene.y + _loc5_.getHeight())
            {
               _loc5_.testObstacleCollision(param1,param2,param3,param4);
               for each(_loc10_ in _loc5_._volumes)
               {
                  _loc13_ = -1;
                  _loc9_ = 0;
                  while(_loc9_ < _loc10_.length - 1)
                  {
                     _loc6_.x = _loc10_[_loc9_].x + _loc5_._scene.x;
                     _loc7_.x = _loc10_[_loc9_ + 1].x + _loc5_._scene.x;
                     _loc6_.y = _loc10_[_loc9_].y + _loc5_._scene.y;
                     _loc7_.y = _loc10_[_loc9_ + 1].y + _loc5_._scene.y;
                     _loc13_ = Collision.movingCircleVsRay(param2,param4,param3,1,_loc6_,_loc7_);
                     if(_loc13_ >= 0)
                     {
                        if(_loc13_ < _loc11_)
                        {
                           _loc11_ = _loc13_;
                           if(_loc12_ == null)
                           {
                              _loc12_ = new Point();
                              _loc8_ = new Point();
                           }
                           if(_loc6_.y < _loc7_.y)
                           {
                              _loc8_.x = _loc7_.x;
                              _loc8_.y = _loc7_.y;
                              _loc12_.y = _loc6_.y - _loc7_.y;
                              _loc12_.x = _loc6_.x - _loc7_.x;
                           }
                           else
                           {
                              _loc8_.x = _loc6_.x;
                              _loc8_.y = _loc6_.y;
                              _loc12_.y = _loc7_.y - _loc6_.y;
                              _loc12_.x = _loc7_.x - _loc6_.x;
                           }
                        }
                     }
                     _loc9_++;
                  }
               }
            }
         }
         if(_loc12_)
         {
            _loc6_.x = 4 * (param2.x - _loc8_.x);
            _loc6_.y = 4 * (param2.y - _loc8_.y);
            _loc12_.x += _loc6_.x;
            _loc12_.y += _loc6_.y;
            if(param3.y >= 0)
            {
               _loc12_.x = -_loc12_.x;
               _loc12_.y = -_loc12_.y;
            }
            _loc12_.normalize(1);
            if(_loc12_.y > 0.1)
            {
               _loc12_.y = 0.1;
            }
         }
         return _loc12_;
      }
      
      public function getPlayerIndex(param1:Boolean) : int
      {
         if(param1)
         {
            return 0;
         }
         return _currentPlayerIndex++;
      }
      
      private function setGameOver(param1:Boolean) : void
      {
         if(_gameState != 3)
         {
            if(param1)
            {
            }
            setGameState(3);
         }
      }
      
      private function exitGameKeyDown(param1:KeyboardEvent) : void
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
      
      private function updateGameOverDlg() : void
      {
         var _loc3_:* = null;
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         if(_resultsPopup == null)
         {
            for each(_loc3_ in _players)
            {
               if(!(_loc3_._localPlayer && _loc3_._finishedPlace > 0))
               {
                  continue;
               }
               _resultsPopup = showDlg("Results",[{
                  "name":"button_exit",
                  "f":onExit_Yes
               }]);
               _resultsPopup.x = 450;
               _resultsPopup.y = 275;
               stage.addEventListener("keyDown",exitGameKeyDown);
               switch(_resultsTotal - 1)
               {
                  case 0:
                     _resultsPopup.gotoAndStop("1_player");
                     break;
                  case 1:
                     _resultsPopup.gotoAndStop("2_player");
                     break;
                  case 2:
                     _resultsPopup.gotoAndStop("3_player");
                     break;
                  default:
                     _resultsPopup.gotoAndStop("4_player");
                     break;
               }
            }
         }
         if(_resultsPopup != null)
         {
            if(_players.length < _resultsTotal)
            {
               _loc2_ = true;
               for each(_loc3_ in _players)
               {
                  if(_loc3_._finishedPlace == -1)
                  {
                     _loc2_ = false;
                     break;
                  }
               }
               if(_loc2_)
               {
                  _loc1_ = 0;
                  while(_loc1_ < _resultsTotal)
                  {
                     if(_resultsNames[_loc1_] == "waiting...")
                     {
                        _resultsNames[_loc1_] = "quit game";
                     }
                     _loc1_++;
                  }
               }
            }
            _loc1_ = 0;
            while(_loc1_ < _resultsTotal)
            {
               switch(_loc1_)
               {
                  case 0:
                     _resultsPopup.player_1.text = "1. " + _resultsNames[_loc1_];
                     break;
                  case 1:
                     _resultsPopup.player_2.text = "2. " + _resultsNames[_loc1_];
                     break;
                  case 2:
                     _resultsPopup.player_3.text = "3. " + _resultsNames[_loc1_];
                     break;
                  case 3:
                     _resultsPopup.player_4.text = "4. " + _resultsNames[_loc1_];
                     break;
               }
               _loc1_++;
            }
         }
         AchievementManager.displayNewAchievements();
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
         stage.removeEventListener("keyDown",exitGameKeyDown);
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
      
      private function initLevels() : void
      {
         _levels = [[{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "boost":4,
            "offset":0
         },{
            "rocks":1,
            "offset":100
         },{
            "rocks":3,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "boost":1,
            "offset":600
         },{
            "rocks":5,
            "offset":0
         },{
            "whirlpool":1,
            "offset":400
         },{
            "boost":1,
            "offset":300
         },{
            "boost":5,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "whirlpool":4,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":100
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":4,
            "offset":600
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "boost":1,
            "offset":0
         },{
            "rocks":4,
            "offset":0
         },{
            "rocks":2,
            "offset":0
         },{
            "whirlpool":5,
            "offset":500
         },{
            "whirlpool":1,
            "offset":0
         },{
            "boost":3,
            "offset":200
         },{
            "boost":1,
            "offset":700
         },{
            "boost":5,
            "offset":0
         },{
            "rocks":2,
            "offset":700
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":100
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":1,
            "offset":600
         },{
            "whirlpool":3,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":4,
            "offset":700
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":5,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":0
         },{
            "rocks":4,
            "offset":0
         }],[{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "rocks":4,
            "offset":0
         },{
            "rocks":1,
            "offset":100
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":3,
            "offset":600
         },{
            "rocks":1,
            "offset":0
         },{
            "whirlpool":3,
            "offset":400
         },{
            "boost":1,
            "offset":300
         },{
            "boost":5,
            "offset":0
         },{
            "boost":4,
            "offset":700
         },{
            "whirlpool":2,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "rocks":4,
            "offset":100
         },{
            "rocks":2,
            "offset":0
         },{
            "boost":1,
            "offset":600
         },{
            "boost":3,
            "offset":0
         },{
            "rocks":2,
            "offset":0
         },{
            "boost":4,
            "offset":700
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         },{
            "whirlpool":4,
            "offset":400
         },{
            "whirlpool":2,
            "offset":0
         },{
            "boost":1,
            "offset":300
         },{
            "boost":5,
            "offset":700
         },{
            "boost":3,
            "offset":0
         },{
            "rocks":1,
            "offset":700
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "rocks":3,
            "offset":100
         },{
            "rocks":5,
            "offset":0
         },{
            "boost":5,
            "offset":600
         },{
            "whirlpool":3,
            "offset":0
         },{
            "boost":1,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "boost":4,
            "offset":700
         },{
            "rocks":3,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         }],[{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":1,
            "offset":700
         },{
            "boost":5,
            "offset":0
         },{
            "rocks":2,
            "offset":0
         },{
            "whirlpool":3,
            "offset":400
         },{
            "boost":3,
            "offset":300
         },{
            "rocks":1,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "whirlpool":2,
            "offset":300
         },{
            "whirlpool":4,
            "offset":0
         },{
            "boost":1,
            "offset":400
         },{
            "boost":5,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "whirlpool":1,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "rocks":4,
            "offset":100
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":2,
            "offset":600
         },{
            "boost":3,
            "offset":0
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":1,
            "offset":700
         },{
            "boost":5,
            "offset":0
         },{
            "whirlpool":3,
            "offset":0
         },{
            "whirlpool":1,
            "offset":400
         },{
            "whirlpool":5,
            "offset":0
         },{
            "boost":2,
            "offset":300
         },{
            "boost":4,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":700
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":1,
            "offset":400
         },{
            "boost":5,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "boost":4,
            "offset":0
         },{
            "rocks":3,
            "offset":100
         },{
            "rocks":1,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "boost":1,
            "offset":600
         },{
            "whirlpool":3,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":3,
            "offset":200
         },{
            "boost":1,
            "offset":500
         },{
            "boost":5,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         }],[{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":4,
            "offset":700
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         },{
            "whirlpool":2,
            "offset":400
         },{
            "whirlpool":4,
            "offset":400
         },{
            "boost":3,
            "offset":300
         },{
            "rocks":1,
            "offset":300
         },{
            "rocks":3,
            "offset":0
         },{
            "whirlpool":5,
            "offset":0
         },{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "whirlpool":3,
            "offset":0
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "rocks":4,
            "offset":100
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":2,
            "offset":600
         },{
            "boost":3,
            "offset":0
         },{
            "boost":4,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "boost":1,
            "offset":0
         },{
            "whirlpool":3,
            "offset":0
         },{
            "whirlpool":2,
            "offset":400
         },{
            "whirlpool":4,
            "offset":0
         },{
            "boost":3,
            "offset":300
         },{
            "rocks":1,
            "offset":0
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":1,
            "offset":700
         },{
            "rocks":2,
            "offset":100
         },{
            "rocks":2,
            "offset":600
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":3,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":3,
            "offset":100
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":4,
            "offset":600
         },{
            "whirlpool":2,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":0
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":3,
            "offset":500
         },{
            "whirlpool":1,
            "offset":100
         },{
            "whirlpool":5,
            "offset":0
         }],[{
            "boost":3,
            "offset":400
         },{
            "boost":1,
            "offset":0
         },{
            "boost":5,
            "offset":0
         },{
            "boost":1,
            "offset":700
         },{
            "boost":3,
            "offset":0
         },{
            "rocks":5,
            "offset":0
         },{
            "whirlpool":3,
            "offset":400
         },{
            "whirlpool":1,
            "offset":400
         },{
            "boost":5,
            "offset":300
         },{
            "rocks":3,
            "offset":300
         },{
            "rocks":2,
            "offset":0
         },{
            "whirlpool":1,
            "offset":300
         },{
            "boost":3,
            "offset":100
         },{
            "boost":1,
            "offset":200
         },{
            "boost":5,
            "offset":500
         },{
            "whirlpool":1,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":3,
            "offset":700
         },{
            "rocks":2,
            "offset":100
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":5,
            "offset":600
         },{
            "boost":2,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "boost":1,
            "offset":0
         },{
            "whirlpool":2,
            "offset":300
         },{
            "whirlpool":5,
            "offset":400
         },{
            "whirlpool":3,
            "offset":400
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":4,
            "offset":700
         },{
            "rocks":3,
            "offset":100
         },{
            "rocks":5,
            "offset":600
         },{
            "rocks":4,
            "offset":0
         },{
            "boost":3,
            "offset":0
         },{
            "boost":5,
            "offset":700
         },{
            "boost":2,
            "offset":0
         },{
            "rocks":3,
            "offset":100
         },{
            "rocks":1,
            "offset":0
         },{
            "boost":1,
            "offset":600
         },{
            "whirlpool":3,
            "offset":0
         },{
            "boost":2,
            "offset":700
         },{
            "rocks":1,
            "offset":0
         },{
            "rocks":3,
            "offset":0
         },{
            "boost":3,
            "offset":500
         },{
            "whirlpool":1,
            "offset":200
         },{
            "whirlpool":4,
            "offset":0
         }]];
      }
   }
}

