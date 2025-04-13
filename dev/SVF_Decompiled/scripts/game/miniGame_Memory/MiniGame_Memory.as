package game.miniGame_Memory
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class MiniGame_Memory extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const COMPLETION_BONUS:int = 20;
      
      private static const STARTUP_REVEAL_TIMER:Number = 4;
      
      private static const BEGIN_HIDE_REVEAL_TIME:Number = 0.5;
      
      private static const BAD_MATCH_TIMER:Number = 0.7;
      
      public const TOTAL_CARD_TYPES:int = 8;
      
      public const GAME_TIME:Number = 60;
      
      public const GRID_WIDTH:int = 125;
      
      public const GRID_HEIGHT:int = 125;
      
      public const GRID_COLUMNS:int = 4;
      
      public const GRID_ROWS:int = 4;
      
      public const DIR_UP:int = 1;
      
      public const DIR_DOWN:int = 2;
      
      public const DIR_LEFT:int = 3;
      
      public const DIR_RIGHT:int = 4;
      
      public const ELASTIC:int = 1;
      
      public const BOUNCEY:int = 2;
      
      public var myId:uint;
      
      public var p1Id:uint;
      
      private var _sceneOffset:Point;
      
      private var _gems:Array;
      
      private var _gemsToRecycle:Array;
      
      public var _layerBackground:Sprite;
      
      private var _layerForeground:Sprite;
      
      private var _layerGems:Sprite;
      
      private var _cardsA:Array;
      
      private var _cardsB:Array;
      
      private var _timerArrow:Object;
      
      private var _slotHighlight:Object;
      
      public var _cardSelect:Sprite;
      
      private var _scoreCtrl:Object;
      
      private var _slots:Array;
      
      private var _slotTypes:Array;
      
      private var _score:int;
      
      protected var _countdown:Object;
      
      private var _gameRevealTimer:Number;
      
      private var _revealed:Boolean;
      
      private var _lastSelectionTimer:Number;
      
      private var _mouseOverSlot:int;
      
      private var _musicPaused:Boolean;
      
      public var _displayAchievementTimer:Number;
      
      public var _misMatched:Boolean;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _gameOver:Boolean;
      
      private var _gameStarted:Boolean;
      
      private var _bInit:Boolean;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["enter.mp3","exit.mp3","group_enter.mp3","group_exit.mp3","roll_over.mp3","memory_time_up.mp3","aj_gem_new.mp3","memory_3_2_1_go.mp3","AJ_doubleUp_stinger.mp3"];
      
      internal var _soundNameEnter:String = _audio[0];
      
      internal var _soundNameExit:String = _audio[1];
      
      internal var _soundNameGroupEnter:String = _audio[2];
      
      internal var _soundNameGroupExit:String = _audio[3];
      
      internal var _soundNameRollOver:String = _audio[4];
      
      internal var _soundNameMemoryTimeUp:String = _audio[5];
      
      internal var _soundNameGemCollect:String = _audio[6];
      
      internal var _soundName321Go:String = _audio[7];
      
      internal var _soundNameYouWon:String = _audio[8];
      
      public var _SFX_Music:SBMusic;
      
      private var _SFX_Music_Instance:SoundChannel;
      
      public function MiniGame_Memory()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("AJ_mus_double_up",1);
         _soundMan.addSoundByName(_audioByName[_soundNameEnter],_soundNameEnter,1);
         _soundMan.addSoundByName(_audioByName[_soundNameExit],_soundNameExit,0.47);
         _soundMan.addSoundByName(_audioByName[_soundNameGroupEnter],_soundNameGroupEnter,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameGroupExit],_soundNameGroupExit,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameRollOver],_soundNameRollOver,1);
         _soundMan.addSoundByName(_audioByName[_soundNameMemoryTimeUp],_soundNameMemoryTimeUp,0.21);
         _soundMan.addSoundByName(_audioByName[_soundNameGemCollect],_soundNameGemCollect,0.25);
         _soundMan.addSoundByName(_audioByName[_soundName321Go],_soundName321Go,1);
         _soundMan.addSoundByName(_audioByName[_soundNameYouWon],_soundNameYouWon,1);
      }
      
      public function getSlotClass(param1:int) : Class
      {
         return _slotTypes[param1].type;
      }
      
      public function getSlotDirection(param1:int) : int
      {
         return _slotTypes[param1].direction;
      }
      
      public function getSlotEnterType(param1:int) : int
      {
         return _slotTypes[param1].enterType;
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         p1Id = param2[0];
         init();
      }
      
      public function end(param1:Array) : void
      {
         if(_gameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         if(_SFX_Music_Instance)
         {
            _SFX_Music_Instance.stop();
            _SFX_Music_Instance = null;
         }
         releaseBase();
         if(_gems)
         {
            while(_gems.length > 0)
            {
               if(_gems[0].loader.parent)
               {
                  _gems[0].loader.parent.removeChild(_gems[0].loader);
               }
               _gems.splice(0,1);
            }
         }
         if(_gemsToRecycle && _gemsToRecycle.length > 0)
         {
            _gemsToRecycle.splice(0,_gemsToRecycle.length);
         }
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         _cardSelect.removeEventListener("click",mouseClickHandler_Back);
         _cardSelect.removeEventListener("mouseOut",mouseOutHandler_Back);
         _cardSelect.removeEventListener("mouseMove",mouseMoveHandler_Back);
         _bInit = false;
         removeLayer(_layerBackground);
         removeLayer(_layerForeground);
         removeLayer(_layerGems);
         removeLayer(_guiLayer);
         _layerBackground = null;
         _layerForeground = null;
         _layerGems = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      public function message(param1:Array) : void
      {
         if(param1[0] == "ml")
         {
            end(param1);
            return;
         }
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         _misMatched = false;
         if(!_bInit)
         {
            _gems = [];
            _gemsToRecycle = [];
            _layerBackground = new Sprite();
            _layerForeground = new Sprite();
            _layerGems = new Sprite();
            _guiLayer = new Sprite();
            _layerForeground.mouseEnabled = false;
            _layerGems.mouseEnabled = false;
            addChild(_layerBackground);
            addChild(_layerForeground);
            addChild(_layerGems);
            addChild(_guiLayer);
            loadScene("MemoryAssets/room_main.xroom",_audio);
            _mouseOverSlot = -1;
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc2_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _sceneOffset = _scene.getOffset(stage);
         _sceneOffset.x = int(_sceneOffset.x);
         _sceneOffset.y = int(_sceneOffset.y);
         var _loc3_:Array = _scene.getActorList("ActorLayer");
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            _loc5_.s.x = _loc5_.s.x - _sceneOffset.x;
            _loc5_.s.y -= _sceneOffset.y;
            if(_loc5_.name == "layerback")
            {
               _loc2_ = _scene.getLayer("layerback");
               _cardSelect = new Sprite();
               _cardSelect.mouseEnabled = true;
               _cardSelect.x = _loc2_.loader.x;
               _cardSelect.y = _loc2_.loader.y;
               _loc2_.loader.x = 0;
               _loc2_.loader.y = 0;
               _cardSelect.addChild(DisplayObject(_loc2_.loader));
               _layerBackground.addChild(_cardSelect);
            }
            else
            {
               _loc5_.s.mouseEnabled = false;
               if(_loc5_.name != "score_gem")
               {
                  var _loc6_:* = _loc5_.layer;
                  if(2 !== _loc6_)
                  {
                     _layerBackground.addChild(_loc5_.s);
                  }
                  else
                  {
                     _layerForeground.addChild(_loc5_.s);
                  }
                  if(_loc5_.name.search("card") >= 0)
                  {
                     _loc5_.s.x = 5000;
                     _loc5_.s.y = 5000;
                  }
               }
            }
            _loc4_++;
         }
         _countdown = _scene.getLayer("countdown");
         _countdown.loader.mouseEnabled = false;
         _countdown.loader.mouseChildren = false;
         _countdown.loader.content.countdowntimer.gotoAndPlay("off");
         _closeBtn = addBtn("CloseButton",850,5,showExitConfirmationDlg);
         _cardsA = [];
         _cardsB = [];
         _loc4_ = 0;
         while(_loc4_ < 8)
         {
            _cardsA[_loc4_] = _scene.getLayer("card" + (_loc4_ + 1) + "a");
            _cardsB[_loc4_] = _scene.getLayer("card" + (_loc4_ + 1) + "b");
            _loc4_++;
         }
         _timerArrow = _scene.getLayer("timerarrow");
         _slotHighlight = {};
         _slotHighlight.layer = _scene.getLayer("slot_highlight");
         _slotHighlight.layer.loader.mouseEnabled = false;
         _slotHighlight.layer.loader.mouseChildren = false;
         _scoreCtrl = _scene.getLayer("gemcount");
         _slotTypes = [{
            "direction":1,
            "enterType":1
         },{
            "direction":3,
            "enterType":1
         },{
            "direction":2,
            "enterType":1
         },{
            "direction":3,
            "enterType":1
         },{
            "direction":4,
            "enterType":1
         },{
            "direction":2,
            "enterType":1
         },{
            "direction":2,
            "enterType":1
         },{
            "direction":4,
            "enterType":1
         }];
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         _cardSelect.addEventListener("click",mouseClickHandler_Back);
         _cardSelect.addEventListener("mouseOut",mouseOutHandler_Back);
         _cardSelect.addEventListener("mouseMove",mouseMoveHandler_Back);
         restart();
         super.sceneLoaded(param1);
      }
      
      private function restart() : void
      {
         var _loc2_:int = 0;
         var _loc6_:* = 0;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:MemoryCard = null;
         _countdown.loader.content.countdowntimer.gotoAndPlay(0);
         _soundMan.playByName(_soundName321Go);
         _timerArrow.loader.transform.matrix = new Matrix();
         _timerArrow.loader.x = _timerArrow.x;
         _timerArrow.loader.y = _timerArrow.y;
         rotateAroundCenter(_timerArrow.loader,new Point(_timerArrow.loader.x + _timerArrow.loader.width / 2,_timerArrow.loader.y + _timerArrow.loader.height / 2),0);
         if(_slotHighlight.tween)
         {
            _slotHighlight.tween.end();
            _slotHighlight.tween = null;
         }
         while(_gems.length > 0)
         {
            if(_gems[0].loader.parent)
            {
               _gems[0].loader.parent.removeChild(_gems[0].loader);
            }
            _gems[0].loader.content.gotoAndStop(0);
            _gemsToRecycle.push(_gems[0]);
            _gems.splice(0,1);
         }
         _slotHighlight.layer.loader.alpha = 0;
         _gameStarted = false;
         _gameOver = false;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _misMatched = false;
         _gameRevealTimer = 4;
         _revealed = false;
         _loc2_ = 0;
         while(_loc2_ < 8)
         {
            _cardsA[_loc2_].loader.alpha = 0;
            _cardsB[_loc2_].loader.alpha = 0;
            _loc2_++;
         }
         if(!_slots)
         {
            _slots = [];
         }
         while(_slots.length > 0)
         {
            _slots[0].remove();
            _slots.splice(0,1);
         }
         var _loc7_:int = Math.floor(Math.random() * 8);
         if(_loc7_ >= 8)
         {
            _loc7_ = 0;
         }
         var _loc8_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < 2)
         {
            _loc6_ = _loc7_;
            _loc3_ = 0;
            while(_loc3_ < 8)
            {
               _loc8_.push(_loc6_ + 8 * _loc2_);
               _loc6_++;
               if(_loc6_ >= 8)
               {
                  _loc6_ = 0;
               }
               _loc3_++;
            }
            _loc2_++;
         }
         var _loc4_:Array = [];
         _loc2_ = 0;
         while(_loc2_ < 5)
         {
            while(_loc8_.length > 0)
            {
               _loc9_ = Math.floor(Math.random() * _loc8_.length);
               _loc1_ = Math.floor(Math.random() * _loc4_.length);
               _loc4_.splice(_loc1_,0,_loc8_[_loc9_]);
               _loc8_.splice(_loc9_,1);
            }
            while(_loc4_.length > 0)
            {
               _loc9_ = Math.floor(Math.random() * _loc4_.length);
               _loc1_ = Math.floor(Math.random() * _loc8_.length);
               _loc8_.splice(_loc1_,0,_loc4_[_loc4_.length - _loc9_ - 1]);
               _loc4_.splice(_loc4_.length - _loc9_ - 1,1);
            }
            _loc2_++;
         }
         _loc9_ = 0;
         _loc2_ = 0;
         while(_loc2_ < 8 * 2)
         {
            _loc5_ = new MemoryCard();
            if(_loc8_[_loc9_] < 8)
            {
               _loc5_.initCard(this,_cardsA[_loc8_[_loc9_]],_loc2_,_loc8_[_loc9_]);
            }
            else
            {
               _loc5_.initCard(this,_cardsB[_loc8_[_loc9_] - 8],_loc2_,_loc8_[_loc9_] - 8);
            }
            _slots.push(_loc5_);
            _loc9_++;
            _loc2_++;
         }
         _score = 0;
         updateScore();
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:Number = NaN;
         var _loc4_:Boolean = false;
         var _loc2_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:Number = NaN;
         if(_SFX_Music_Instance)
         {
            if(_pauseGame)
            {
               if(_musicPaused == false)
               {
                  _soundMan.pauseStream(_SFX_Music);
                  _musicPaused = true;
               }
            }
            else if(_musicPaused == true)
            {
               _soundMan.unpauseStream(_SFX_Music);
               _musicPaused = false;
            }
         }
         _frameTime = (getTimer() - _lastTime) / 1000;
         _loc3_ = 0;
         while(_loc3_ < _slots.length)
         {
            if(_loc3_ == _mouseOverSlot)
            {
               if(_pauseGame || _gameOver || !_slots[_loc3_].isMouseOverHighlightable())
               {
                  mouseOverSlot(-1);
               }
            }
            _slots[_loc3_].heartbeat(_frameTime);
            if(_slots[_loc3_].isMatched() && _slots[_loc3_].getState() == _slots[_loc3_].STATE_IDLE)
            {
               _loc5_ = 0;
               while(_loc5_ < _slots.length)
               {
                  if(_loc5_ != _loc3_)
                  {
                     if(_slots[_loc5_].isMatched() && _slots[_loc5_].getState() == _slots[_loc5_].STATE_IDLE && _slots[_loc3_].getCardType() == _slots[_loc5_].getCardType())
                     {
                        _slots[_loc3_].disable();
                        _slots[_loc5_].disable();
                        break;
                     }
                  }
                  _loc5_++;
               }
            }
            _loc3_++;
         }
         if(!_pauseGame)
         {
            if(!_gameOver)
            {
               if(_gameRevealTimer > 0)
               {
                  if(_gameRevealTimer >= 4)
                  {
                     _gameRevealTimer -= _frameTime;
                     if(_gameRevealTimer < 4)
                     {
                        _loc3_ = 0;
                        while(_loc3_ < _slots.length)
                        {
                           _slots[_loc3_].select(true);
                           _loc3_++;
                        }
                        _revealed = true;
                        _soundMan.playByName(_soundNameGroupEnter);
                     }
                  }
                  else if(_revealed)
                  {
                     _gameRevealTimer -= _frameTime;
                     if(_gameRevealTimer <= 0.5)
                     {
                        _loc3_ = 0;
                        while(_loc3_ < _slots.length)
                        {
                           _slots[_loc3_].unselect(true);
                           _loc3_++;
                        }
                        _revealed = false;
                        _soundMan.playByName(_soundNameGroupEnter);
                     }
                  }
                  else
                  {
                     _gameRevealTimer -= _frameTime;
                     if(_gameRevealTimer <= 0)
                     {
                        _gameRevealTimer = 0;
                     }
                  }
               }
               else if(_gameStarted && _gameTime < 60)
               {
                  _loc8_ = _gameTime;
                  _gameTime += _frameTime;
                  if(_gameTime >= 60)
                  {
                     _gameTime = 60;
                     _soundMan.playByName(_soundNameMemoryTimeUp);
                     setGameOver();
                  }
                  else
                  {
                     if(_lastSelectionTimer > 0)
                     {
                        _lastSelectionTimer -= _frameTime;
                        if(_lastSelectionTimer <= 0)
                        {
                           _lastSelectionTimer = 0;
                           _loc4_ = false;
                           _loc3_ = 0;
                           while(_loc3_ < _slots.length)
                           {
                              if(_slots[_loc3_].isSelected())
                              {
                                 _loc4_ = true;
                                 _slots[_loc3_].unselect();
                              }
                              _loc3_++;
                           }
                           if(_loc4_)
                           {
                              _soundMan.playByName(_soundNameExit);
                           }
                        }
                     }
                     if(_mouseOverSlot == -1)
                     {
                        if(_cardSelect.mouseX > 0 && _cardSelect.mouseX <= _cardSelect.width && _cardSelect.mouseY > 0 && _cardSelect.mouseY <= _cardSelect.height)
                        {
                           _loc2_ = Math.floor(_cardSelect.mouseX / 125);
                           _loc6_ = Math.floor(_cardSelect.mouseY / 125);
                           if(_loc2_ >= 0 && _loc2_ < 4 && _loc6_ >= 0 && _loc6_ < 4)
                           {
                              _loc7_ = _loc6_ * 4 + _loc2_;
                              mouseOverSlot(_loc7_,_loc6_,_loc2_);
                           }
                        }
                     }
                  }
                  _loc9_ = -(_gameTime * 360 / 60);
                  _timerArrow.loader.transform.matrix = new Matrix();
                  _timerArrow.loader.x = _timerArrow.x;
                  _timerArrow.loader.y = _timerArrow.y;
                  rotateAroundCenter(_timerArrow.loader,new Point(_timerArrow.loader.x + _timerArrow.loader.width / 2,_timerArrow.loader.y + _timerArrow.loader.height / 2),_loc9_);
               }
            }
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
      }
      
      private function setGameOver() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Boolean = false;
         if(!_gameOver)
         {
            if(_SFX_Music_Instance)
            {
               _SFX_Music_Instance.stop();
               _SFX_Music_Instance = null;
               _musicPaused = false;
            }
            _loc2_ = 0;
            while(_loc2_ < _slots.length)
            {
               if(!_slots[_loc2_].isMatched() && _slots[_loc2_].isSelected())
               {
                  _slots[_loc2_].unselect();
               }
               _loc2_++;
            }
            _loc1_ = true;
            _loc2_ = 0;
            while(_loc2_ < _slots.length)
            {
               if(_slots[_loc2_].isMatched() == false)
               {
                  _loc1_ = false;
                  break;
               }
               _loc2_++;
            }
            if(_loc1_)
            {
               _soundMan.playByName(_soundNameYouWon);
               _score += 20;
               if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  if(_gameTime <= 15)
                  {
                     AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
                     _displayAchievementTimer = 1;
                  }
                  if(!_misMatched)
                  {
                     AchievementXtCommManager.requestSetUserVar(83,1);
                     _displayAchievementTimer = 1;
                  }
               }
            }
            updateScore();
            addGemsToBalance(_score);
            _gameOver = true;
            showGameOverDlg(_loc1_);
         }
      }
      
      private function mouseClickHandler_Back(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_gameRevealTimer <= 0 && !_pauseGame)
         {
            if(!_gameOver)
            {
               _loc2_ = Math.min(Math.floor(param1.localX / 125),4 - 1);
               _loc3_ = Math.min(Math.floor(param1.localY / 125),4 - 1);
               _loc4_ = _loc3_ * 4 + _loc2_;
               selectSlot(_loc4_,_loc3_,_loc2_);
            }
         }
      }
      
      private function mouseOutHandler_Back(param1:MouseEvent) : void
      {
         mouseOverSlot(-1);
      }
      
      private function mouseMoveHandler_Back(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc2_ = Math.floor(param1.localX / 125);
         _loc3_ = Math.floor(param1.localY / 125);
         if(_gameRevealTimer <= 0 && !_pauseGame && !_gameOver && _loc2_ >= 0 && _loc2_ < 4 && _loc3_ >= 0 && _loc3_ < 4)
         {
            _loc4_ = _loc3_ * 4 + _loc2_;
            mouseOverSlot(_loc4_,_loc3_,_loc2_);
         }
         else
         {
            mouseOverSlot(-1);
         }
      }
      
      private function mouseOverSlot(param1:int, param2:int = -1, param3:int = -1) : void
      {
         if(param1 != _mouseOverSlot)
         {
            if(param1 == -1 || !_slots[param1].isMouseOverHighlightable())
            {
               _slotHighlight.layer.loader.x = 5000;
               _slotHighlight.layer.loader.y = 5000;
               if(_slotHighlight.tween)
               {
                  _slotHighlight.tween.end();
                  _slotHighlight.tween = null;
               }
               _slotHighlight.layer.loader.alpha = 0;
               _mouseOverSlot = -1;
            }
            else
            {
               _mouseOverSlot = param1;
               _slots[_mouseOverSlot].mouseOver(_slotHighlight);
               _soundMan.playByName(_soundNameRollOver);
            }
         }
      }
      
      private function selectSlot(param1:int, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc6_:* = 0;
         var _loc7_:* = 0;
         var _loc8_:Object = null;
         var _loc5_:Boolean = false;
         if(_slots[param1].isSelectable())
         {
            _loc6_ = -1;
            _loc7_ = -1;
            _loc4_ = 0;
            while(_loc4_ < _slots.length)
            {
               if(_slots[_loc4_].isSelected())
               {
                  if(_loc6_ != -1)
                  {
                     _loc7_ = _loc4_;
                     break;
                  }
                  _loc6_ = _loc4_;
               }
               _loc4_++;
            }
            if(_loc6_ != -1 && _loc7_ != -1)
            {
               if(param1 != _loc6_)
               {
                  _slots[_loc6_].unselect();
                  _loc6_ = -1;
               }
               if(param1 != _loc7_)
               {
                  _slots[_loc7_].unselect();
                  _loc7_ = -1;
               }
               _soundMan.playByName(_soundNameExit);
               _lastSelectionTimer = 0;
            }
            if(param1 != _loc6_ && param1 != _loc7_)
            {
               if(_gameStarted == false)
               {
                  if(_SFX_Music_Instance == null)
                  {
                     _SFX_Music_Instance = _soundMan.playStream(_SFX_Music,0,99999);
                     _musicPaused = false;
                  }
                  _gameStarted = true;
               }
               _slots[param1].select();
               if(_loc6_ == -1)
               {
                  _loc6_ = param1;
               }
               else
               {
                  _loc7_ = param1;
               }
               if(_loc6_ != _loc7_ && _loc6_ != -1 && _loc7_ != -1)
               {
                  if(_slots[_loc6_].getCardType() == _slots[_loc7_].getCardType())
                  {
                     _slots[_loc6_].matched();
                     _slots[_loc7_].matched();
                     _soundMan.playByName(_soundNameGemCollect);
                     if(_gemsToRecycle.length > 0)
                     {
                        _loc8_ = _gemsToRecycle[0];
                        _gemsToRecycle.splice(0,1);
                        _loc8_.loader.content.gotoAndPlay("collect");
                     }
                     else
                     {
                        _loc8_ = _scene.cloneAsset("score_gem");
                        _loc8_.loader.contentLoaderInfo.addEventListener("complete",onGemCloneComplete);
                     }
                     _loc8_.loader.mouseEnabled = false;
                     _loc8_.loader.mouseChildren = false;
                     _loc8_.loader.x = _cardSelect.x + _slots[param1]._slot % 4 * 125 + 125 / 2 - 15;
                     _loc8_.loader.y = _cardSelect.y + Math.floor(_slots[param1]._slot / 4) * 125 + 125 / 2 - 25;
                     _layerGems.addChild(_loc8_.loader);
                     _gems.push(_loc8_);
                     _score += 3;
                     updateScore();
                     _loc5_ = true;
                     _loc4_ = 0;
                     while(_loc4_ < _slots.length)
                     {
                        if(_slots[_loc4_].isMatched() == false)
                        {
                           _loc5_ = false;
                           break;
                        }
                        _loc4_++;
                     }
                     if(_loc5_)
                     {
                        setGameOver();
                     }
                  }
                  else
                  {
                     _lastSelectionTimer = 0.7;
                     _misMatched = true;
                  }
               }
            }
         }
      }
      
      public function onGemCloneComplete(param1:Event) : void
      {
         param1.target.content.gotoAndPlay("collect");
         param1.target.removeEventListener("complete",onGemCloneComplete);
      }
      
      public function drawPieMask(param1:Graphics, param2:Number, param3:Number = 50, param4:Number = 0, param5:Number = 0, param6:Number = 0, param7:int = 6) : void
      {
         var lineToRadians:Function;
         var sidesToDraw:int;
         var i:int;
         var graphics:Graphics = param1;
         var percentage:Number = param2;
         var radius:Number = param3;
         var x:Number = param4;
         var y:Number = param5;
         var rotation:Number = param6;
         var sides:int = param7;
         graphics.clear();
         graphics.beginFill(489335,0.5);
         graphics.moveTo(x,y);
         if(sides < 3)
         {
            sides = 3;
         }
         radius /= Math.cos(1 / sides * 3.141592653589793);
         lineToRadians = function(param1:Number):void
         {
            graphics.lineTo(Math.cos(param1) * radius + x,Math.sin(param1) * radius + y);
         };
         sidesToDraw = Math.floor(percentage * sides);
         i = 0;
         while(i <= sidesToDraw)
         {
            lineToRadians(i / sides * (3.141592653589793 * 2) + rotation);
            i++;
         }
         if(percentage * sides != sidesToDraw)
         {
            lineToRadians(percentage * (3.141592653589793 * 2) + rotation);
         }
         graphics.endFill();
      }
      
      public function rotateAroundCenter(param1:*, param2:Point, param3:Number) : void
      {
         var _loc4_:Matrix = param1.transform.matrix;
         _loc4_.tx = _loc4_.tx - param2.x;
         _loc4_.ty -= param2.y;
         _loc4_.rotate(param3 * (3.141592653589793 / 180));
         _loc4_.tx += param2.x;
         _loc4_.ty += param2.y;
         param1.transform.matrix = _loc4_;
      }
      
      private function updateScore() : void
      {
         LocalizationManager.translateIdAndInsert(_scoreCtrl.loader.content.score,11097,_score);
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
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onRetry_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onRetry_No();
         }
      }
      
      private function showGameOverDlg(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         stage.addEventListener("keyDown",replayKeyDown);
         if(param1)
         {
            _loc2_ = showDlg("memory_win",[{
               "name":"button_yes",
               "f":onRetry_Yes
            },{
               "name":"button_no",
               "f":onRetry_No
            }]);
            LocalizationManager.translateIdAndInsert(_loc2_.text_score1,11554,_score);
            LocalizationManager.translateIdAndInsert(_loc2_.text_score,11584,20);
         }
         else
         {
            _loc2_ = showDlg("memory_timeup",[{
               "name":"button_yes",
               "f":onRetry_Yes
            },{
               "name":"button_no",
               "f":onRetry_No
            }]);
            LocalizationManager.translateIdAndInsert(_loc2_.text_score,11432,_score);
         }
         _loc2_.x = 450;
         _loc2_.y = 275;
      }
      
      private function onRetry_Yes() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         hideDlg();
         restart();
      }
      
      private function onRetry_No() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
   }
}

