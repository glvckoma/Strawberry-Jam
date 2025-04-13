package game.microDucky
{
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gskinner.motion.GTween;
   import localization.LocalizationManager;
   
   public class MicroDucky extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const TYPE_RUBBERDUCK:int = 0;
      
      private static const TYPE_GOLDDUCK:int = 1;
      
      private static const TYPE_FROG:int = 2;
      
      private static const TYPE_LOG:int = 3;
      
      private static const TYPE_TREE:int = 4;
      
      private static const TYPE_LILYPAD:int = 5;
      
      private static const TYPE_CAN:int = 6;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      private var _layerGame:Sprite;
      
      private var _layerPlayer:Sprite;
      
      private var _layerPlayerSub1:Sprite;
      
      private var _layerPlayerSub2:Sprite;
      
      private var _layerPlayerSub3:Sprite;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _theGame:Object;
      
      public var _pet:Object;
      
      public var _petContainer:Object;
      
      public var _currentTween:GTween;
      
      public var _gems:int;
      
      public var _goldDuckies:int;
      
      public var _points:int;
      
      public var _lives:int;
      
      public var _currentColumn:int;
      
      public var _stunTimer:Number;
      
      public var _lastColumnData:Array = new Array(5);
      
      public var _frogJumpIntervalLow:Number = 1;
      
      public var _frogJumpIntervalHigh:Number = 1.4;
      
      public var _vertScrollSpeedLow:Number = 50;
      
      public var _vertScrollSpeedHigh:Number = 90;
      
      public var _horizScrollSpeed:Number = 30;
      
      public var _difficultyRampFactor:Number = 150;
      
      public var _duckSpeed:Number = 0.12;
      
      public var _shakeIntensity:Number = 1.2;
      
      public var _numDucksCreated:int;
      
      public var _readyGo:Boolean;
      
      public var _obstacles:Array = [];
      
      public var _obstaclePool:Array = [];
      
      public var _frogs:Array = [];
      
      public var _frogPool:Array = [];
      
      private var _audio:Array = ["aj_duckPickup1.mp3","aj_duckPickup2.mp3","aj_duckPickup3.mp3","aj_duckPickup4.mp3","aj_duckPickup5.mp3","aj_duckyMove1.mp3","aj_duckyMove2.mp3","aj_duckyMove3.mp3","aj_frogLand1.mp3","aj_frogLand2.mp3","aj_frogLand3.mp3","aj_frogLeap1.mp3","aj_frogLeap2.mp3","aj_frogLeap3.mp3","aj_goldDuckGlowLP.mp3","aj_goldDuckPickup.mp3","aj_playerDamage1.mp3","aj_playerDamage2.mp3","aj_playerFail.mp3","popup_Go.mp3","popup_Ready.mp3","aj_collisionCan.mp3","aj_collisionLillyPad.mp3","aj_collisionBranch.mp3"];
      
      private var _soundNameDuckPickup1:String = _audio[0];
      
      private var _soundNameDuckPickup2:String = _audio[1];
      
      private var _soundNameDuckPickup3:String = _audio[2];
      
      private var _soundNameDuckPickup4:String = _audio[3];
      
      private var _soundNameDuckPickup5:String = _audio[4];
      
      private var _soundNameDuckyMove1:String = _audio[5];
      
      private var _soundNameDuckyMove2:String = _audio[6];
      
      private var _soundNameDuckyMove3:String = _audio[7];
      
      private var _soundNameFrogLand1:String = _audio[8];
      
      private var _soundNameFrogLand2:String = _audio[9];
      
      private var _soundNameFrogLand3:String = _audio[10];
      
      private var _soundNameFrogLeap1:String = _audio[11];
      
      private var _soundNameFrogLeap2:String = _audio[12];
      
      private var _soundNameFrogLeap3:String = _audio[13];
      
      private var _soundNameGoldDuckGlowLP:String = _audio[14];
      
      private var _soundNameGoldDuckPickup:String = _audio[15];
      
      private var _soundNamePlayerDamage1:String = _audio[16];
      
      private var _soundNamePlayerDamage2:String = _audio[17];
      
      private var _soundNamePlayerFail:String = _audio[18];
      
      private var _soundNamePopupGo:String = _audio[19];
      
      private var _soundNamePopupReady:String = _audio[20];
      
      private var _soundNameCollisionCan:String = _audio[21];
      
      private var _soundNameCollisionLillyPad:String = _audio[22];
      
      private var _soundNameCollisionBranch:String = _audio[23];
      
      public var SFX_aj_duckyStreamLP:Class;
      
      public var SC_aj_duckyStreamLP:SoundChannel;
      
      public var SFX_aj_waterRoar:Class;
      
      public var SC_aj_waterRoar:SoundChannel;
      
      public var SC_aj_goldDuckGlowLP:SoundChannel;
      
      public var _soundMan:SoundManager;
      
      public function MicroDucky()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSound(SFX_aj_duckyStreamLP,0.4,"SFX_aj_duckyStreamLP");
         _soundMan.addSound(SFX_aj_waterRoar,0,"SFX_aj_waterRoar");
         _soundMan.addSoundByName(_audioByName[_soundNameDuckPickup1],_soundNameDuckPickup1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckPickup2],_soundNameDuckPickup2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckPickup3],_soundNameDuckPickup3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckPickup4],_soundNameDuckPickup4,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckPickup5],_soundNameDuckPickup5,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckyMove1],_soundNameDuckyMove1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckyMove2],_soundNameDuckyMove2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameDuckyMove3],_soundNameDuckyMove3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLand1],_soundNameFrogLand1,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLand2],_soundNameFrogLand2,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLand3],_soundNameFrogLand3,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLeap1],_soundNameFrogLeap1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLeap2],_soundNameFrogLeap2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameFrogLeap3],_soundNameFrogLeap3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldDuckGlowLP],_soundNameGoldDuckGlowLP,0.75);
         _soundMan.addSoundByName(_audioByName[_soundNameGoldDuckPickup],_soundNameGoldDuckPickup,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerDamage1],_soundNamePlayerDamage1,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerDamage2],_soundNamePlayerDamage2,0.9);
         _soundMan.addSoundByName(_audioByName[_soundNamePlayerFail],_soundNamePlayerFail,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupGo],_soundNamePopupGo,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopupReady],_soundNamePopupReady,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameCollisionCan],_soundNameCollisionCan,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameCollisionLillyPad],_soundNameCollisionLillyPad,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameCollisionBranch],_soundNameCollisionBranch,0.55);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onShowGameOverKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onRetry();
               break;
            case 8:
            case 46:
            case 27:
               onExit();
         }
      }
      
      public function showGameOver() : void
      {
         var _loc1_:MovieClip = showDlg("duckyGame_gameOver",[{
            "name":"button_yes",
            "f":onRetry
         },{
            "name":"button_no",
            "f":onExit
         }]);
         if(_currentTween)
         {
            _currentTween.resetValues();
         }
         if(_goldDuckies > 0)
         {
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,_gems == 1 ? 11619 : 11554,_gems);
            LocalizationManager.translateIdAndInsert(_loc1_.goldenDuckies,_goldDuckies == 1 ? 11621 : 11620,_goldDuckies);
         }
         else
         {
            LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,_gems == 1 ? 11619 : 11554,_gems);
            _loc1_.goldenDuckies.text = "";
         }
         _loc1_.x = 450;
         _loc1_.y = 275;
         stage.addEventListener("keyDown",onShowGameOverKeyDown);
         _soundMan.playByName(_soundNamePlayerFail);
         if(SC_aj_waterRoar)
         {
            SC_aj_waterRoar.stop();
            SC_aj_waterRoar = null;
         }
      }
      
      private function shakeScreen(param1:Number) : void
      {
         var _loc2_:SoundTransform = null;
         x = (Math.random() - 0.5) * param1;
         y = (Math.random() - 0.5) * param1;
         if(SC_aj_waterRoar && !SBAudio.isMusicMuted)
         {
            _loc2_ = SC_aj_waterRoar.soundTransform;
            _loc2_.volume = param1 * 0.1 * 0.17;
            SC_aj_waterRoar.soundTransform = _loc2_;
         }
      }
      
      private function onExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function onRetry() : void
      {
         stage.removeEventListener("keyDown",onShowGameOverKeyDown);
         hideDlg();
         AchievementXtCommManager.requestSetUserVar(316,_points);
         AchievementXtCommManager.requestSetUserVar(317,_points);
         shakeScreen(0);
         _goldDuckies = 0;
         addGemsToBalance(_gems);
         _gems = 0;
         _points = 0;
         _theGame.loader.content.gems.gemsText.text = "x 0";
         _theGame.loader.content.points.text = "0";
         _gameTime = 0;
         _numDucksCreated = 0;
         _petContainer.x = 350;
         _petContainer.y = 240;
         _layerPlayer.x = 0;
         _readyGo = true;
         _theGame.loader.content.readyGo.gotoAndPlay("on");
         _theGame.loader.content.startMovement = false;
         _theGame.loader.content.controls.visible = true;
         if(_stunTimer > 0)
         {
            _stunTimer -= _frameTime;
            _stunTimer = 0;
            _pet.getChildAt(0).pet.setAnim(10);
            _petContainer.stars.gotoAndPlay("off");
         }
         while(_obstacles.length > 0)
         {
            _obstacles[0].clone.parent.removeChild(_obstacles[0].clone);
            _obstaclePool.push(_obstacles[0]);
            _obstacles.splice(0,1);
         }
         while(_frogs.length > 0)
         {
            _frogs[0].clone.parent.removeChild(_frogs[0].clone);
            _frogPool.push(_frogs[0]);
            _frogs.splice(0,1);
         }
         _currentColumn = -1;
      }
      
      public function end(param1:Array) : void
      {
         if(SC_aj_duckyStreamLP)
         {
            SC_aj_duckyStreamLP.stop();
            SC_aj_duckyStreamLP = null;
         }
         if(SC_aj_goldDuckGlowLP)
         {
            SC_aj_goldDuckGlowLP.stop();
            SC_aj_goldDuckGlowLP = null;
         }
         if(SC_aj_waterRoar)
         {
            SC_aj_waterRoar.stop();
            SC_aj_waterRoar = null;
         }
         AchievementXtCommManager.requestSetUserVar(316,_points);
         AchievementXtCommManager.requestSetUserVar(317,_points);
         var _loc2_:* = _pet.getUBits() >> 12 & 0x0F;
         if(_loc2_ == 1)
         {
            AchievementXtCommManager.requestSetUserVar(318,1);
         }
         addGemsToBalance(_gems);
         releaseBase();
         stage.removeEventListener("keyDown",onShowGameOverKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyboardHandler);
         _bInit = false;
         removeLayer(_layerMain);
         removeLayer(_guiLayer);
         _layerMain = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _layerPlayer = new Sprite();
            _layerPlayerSub1 = new Sprite();
            _layerPlayerSub2 = new Sprite();
            _layerPlayerSub3 = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_guiLayer);
            loadScene("MicroDucky/room_main.xroom",_audio);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         SFX_aj_duckyStreamLP = getDefinitionByName("aj_duckyStreamLP") as Class;
         if(SFX_aj_duckyStreamLP == null)
         {
            throw new Error("Sound not found! name:aj_duckyStreamLP");
         }
         SFX_aj_waterRoar = getDefinitionByName("aj_waterRoar") as Class;
         if(SFX_aj_waterRoar == null)
         {
            throw new Error("Sound not found! name:aj_waterRoar");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",749,58,onCloseButton);
         _theGame = _scene.getLayer("theGame");
         _layerMain.addChild(_theGame.loader);
         _layerGame = _theGame.loader.content.duckyGameAll;
         _layerGame.addChild(_layerPlayer);
         _layerPlayer.addChild(_layerPlayerSub3);
         _layerPlayer.addChild(_layerPlayerSub2);
         _layerPlayer.addChild(_layerPlayerSub1);
         _theGame.loader.content.gems.gemsText.text = "x 0";
         _theGame.loader.content.points.text = "0";
         _lives = 3;
         _currentColumn = -1;
         _stunTimer = 0;
         _numDucksCreated = 0;
         SC_aj_duckyStreamLP = _soundMan.play(SFX_aj_duckyStreamLP,0,99999);
         SC_aj_waterRoar = _soundMan.play(SFX_aj_waterRoar,0,99999);
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("keyDown",keyboardHandler);
         startGame();
         super.sceneLoaded(param1);
      }
      
      private function keyboardHandler(param1:KeyboardEvent) : void
      {
         if(!_pauseGame && _stunTimer <= 0 && (_currentTween == null || _currentTween.paused))
         {
            switch(int(param1.keyCode) - 37)
            {
               case 0:
                  _petContainer.x -= 100;
                  if(_petContainer.x + _layerPlayer.x > 0 && !obstacleCollisionCheck())
                  {
                     _petContainer.x += 100;
                     _currentTween = new GTween(_petContainer,_duckSpeed,{"x":_petContainer.x - 100});
                     _pet.getChildAt(0).pet.setAnim(16);
                     _soundMan.playByName(this["_soundNameDuckyMove" + (Math.floor(Math.random() * 3) + 1)]);
                  }
                  else
                  {
                     _petContainer.x += 100;
                     _petContainer.gotoAndPlay("left");
                  }
                  if(_theGame.loader.content.controls.visible)
                  {
                     _theGame.loader.content.controls.visible = false;
                  }
                  break;
               case 1:
                  _petContainer.y -= 85;
                  if(_petContainer.y > 0 && !obstacleCollisionCheck())
                  {
                     _petContainer.y += 85;
                     forceMove(true);
                     _pet.getChildAt(0).pet.setAnim(16);
                     _soundMan.playByName(this["_soundNameDuckyMove" + (Math.floor(Math.random() * 3) + 1)]);
                  }
                  else
                  {
                     _petContainer.y += 85;
                     _petContainer.gotoAndPlay("up");
                  }
                  if(_theGame.loader.content.controls.visible)
                  {
                     _theGame.loader.content.controls.visible = false;
                  }
                  break;
               case 2:
                  _petContainer.x += 100;
                  if(_petContainer.x + _layerPlayer.x < 700 && !obstacleCollisionCheck())
                  {
                     _petContainer.x -= 100;
                     _currentTween = new GTween(_petContainer,_duckSpeed,{"x":_petContainer.x + 100});
                     _pet.getChildAt(0).pet.setAnim(16);
                     _soundMan.playByName(this["_soundNameDuckyMove" + (Math.floor(Math.random() * 3) + 1)]);
                  }
                  else
                  {
                     _petContainer.x -= 100;
                     _petContainer.gotoAndPlay("right");
                  }
                  if(_theGame.loader.content.controls.visible)
                  {
                     _theGame.loader.content.controls.visible = false;
                  }
                  break;
               case 3:
                  _petContainer.y += 85;
                  if(_petContainer.y < 425 && !obstacleCollisionCheck())
                  {
                     _petContainer.y -= 85;
                     forceMove(false);
                     _pet.getChildAt(0).pet.setAnim(16);
                     _soundMan.playByName(this["_soundNameDuckyMove" + (Math.floor(Math.random() * 3) + 1)]);
                  }
                  else
                  {
                     _petContainer.y -= 85;
                     _petContainer.gotoAndPlay("down");
                  }
                  if(_theGame.loader.content.controls.visible)
                  {
                     _theGame.loader.content.controls.visible = false;
                     break;
                  }
            }
         }
      }
      
      private function forceMove(param1:Boolean) : void
      {
         if(_currentTween == null || _currentTween.paused)
         {
            if(param1)
            {
               _currentTween = new GTween(_petContainer,_duckSpeed,{"y":_petContainer.y - 85});
            }
            else
            {
               _currentTween = new GTween(_petContainer,_duckSpeed,{"y":_petContainer.y + 85});
            }
         }
      }
      
      private function obstacleCollisionCheck() : Boolean
      {
         var _loc3_:* = null;
         var _loc1_:int = 0;
         var _loc2_:int = -1;
         for each(_loc3_ in _obstacles)
         {
            if(_loc3_.type != 0 && _loc3_.type != 1 && _petContainer.collision.hitTestObject(_loc3_.clone.collision))
            {
               if(_loc3_.type == 6)
               {
                  _soundMan.playByName(_soundNameCollisionCan);
               }
               else if(_loc3_.type == 5)
               {
                  _soundMan.playByName(_soundNameCollisionLillyPad);
               }
               else
               {
                  _soundMan.playByName(_soundNameCollisionBranch);
               }
               return true;
            }
         }
         for each(_loc3_ in _obstacles)
         {
            if(_loc3_.type != 0 && _loc3_.type != 1 && _petContainer.collision2.hitTestObject(_loc3_.clone.collision))
            {
               _loc1_++;
               _loc2_ = int(_loc3_.type);
            }
         }
         if(_loc1_ > 1)
         {
            if(_loc2_ == 6)
            {
               _soundMan.playByName(_soundNameCollisionCan);
            }
            else if(_loc2_ == 5)
            {
               _soundMan.playByName(_soundNameCollisionLillyPad);
            }
            else
            {
               _soundMan.playByName(_soundNameCollisionBranch);
            }
         }
         return _loc1_ > 1;
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
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc6_:Object = null;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_sceneLoaded)
         {
            _loc4_ = _horizScrollSpeed + _gameTime * _difficultyRampFactor * 0.005;
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_theGame.loader.content.goSound)
            {
               _theGame.loader.content.goSound = false;
               _soundMan.playByName(_soundNamePopupGo);
            }
            if(_theGame.loader.content.readySound)
            {
               _theGame.loader.content.readySound = false;
               _soundMan.playByName(_soundNamePopupReady);
            }
            if(!(_readyGo && !_theGame.loader.content.startMovement))
            {
               if(_pauseGame == false)
               {
                  _gameTime += _frameTime;
                  _readyGo = false;
                  if(_stunTimer > 0)
                  {
                     _stunTimer -= _frameTime;
                     if(_stunTimer <= 0)
                     {
                        _pet.getChildAt(0).pet.setAnim(10);
                        _petContainer.stars.gotoAndPlay("off");
                     }
                  }
                  _loc2_ = Math.floor(_layerPlayer.x / 100);
                  _layerPlayer.x -= _loc4_ * _frameTime;
                  _loc3_ = 0;
                  while(_loc3_ < _frogs.length)
                  {
                     _loc6_ = _frogs[_loc3_];
                     if(_loc6_.clone.x + _layerPlayer.x < -50)
                     {
                        _frogs.splice(_loc3_--,1);
                        _loc6_.clone.parent.removeChild(_loc6_.clone);
                        _frogPool.push(_loc6_);
                     }
                     else
                     {
                        if(_loc6_.jumpInterval > 0)
                        {
                           _loc6_.jumpInterval -= _frameTime;
                           if(_loc6_.jumpInterval <= 0)
                           {
                              _loc6_.clone.jump(_loc6_.jump < 0);
                              _loc6_.collisionEnabled = true;
                              _soundMan.playByName(this["_soundNameFrogLeap" + (Math.floor(Math.random() * 3) + 1)]);
                           }
                        }
                        if(_loc6_.jumpInterval <= 0)
                        {
                           if(_loc6_.jumpType == 0)
                           {
                              _loc6_.clone.y += _loc6_.jump * _frameTime;
                              if(_loc6_.jump > 0)
                              {
                                 if(_loc6_.clone.y >= _loc6_.o1.clone.y)
                                 {
                                    _loc6_.clone.y = _loc6_.o1.clone.y;
                                    _loc6_.jump *= -1;
                                    _loc6_.jumpInterval = _loc6_.jumpIntervalSetting;
                                    _soundMan.playByName(this["_soundNameFrogLand" + (Math.floor(Math.random() * 3) + 1)]);
                                 }
                              }
                              else if(_loc6_.clone.y <= _loc6_.o0.clone.y)
                              {
                                 _loc6_.clone.y = _loc6_.o0.clone.y;
                                 _loc6_.jump *= -1;
                                 _loc6_.jumpInterval = _loc6_.jumpIntervalSetting;
                                 _soundMan.playByName(this["_soundNameFrogLand" + (Math.floor(Math.random() * 3) + 1)]);
                              }
                           }
                           else if(_loc6_.jumpType == 1)
                           {
                              _loc6_.clone.y += _loc6_.jump * _frameTime;
                              if(_loc6_.clone.y - _loc6_.startY >= 170)
                              {
                                 if(_loc6_.clone.y > 550)
                                 {
                                    _loc6_.clone.y = _loc6_.o0.clone.y - 170;
                                 }
                                 else
                                 {
                                    _loc6_.clone.y = _loc6_.startY + 170;
                                 }
                                 _loc6_.startY = _loc6_.clone.y;
                                 _loc6_.jumpInterval = _loc6_.jumpIntervalSetting;
                                 _soundMan.playByName(this["_soundNameFrogLand" + (Math.floor(Math.random() * 3) + 1)]);
                              }
                              else if(_loc6_.startY - _loc6_.clone.y >= 170)
                              {
                                 if(_loc6_.clone.y < 0)
                                 {
                                    _loc6_.clone.y = _loc6_.o2.clone.y + 170;
                                 }
                                 else
                                 {
                                    _loc6_.clone.y = _loc6_.startY - 170;
                                 }
                                 _loc6_.startY = _loc6_.clone.y;
                                 _loc6_.jumpInterval = _loc6_.jumpIntervalSetting;
                                 _soundMan.playByName(this["_soundNameFrogLand" + (Math.floor(Math.random() * 3) + 1)]);
                              }
                           }
                        }
                        if(_petContainer.collision.hitTestObject(_loc6_.clone.collision) && _loc6_.collisionEnabled)
                        {
                           _loc6_.collisionEnabled = false;
                           _stunTimer = 1;
                           _petContainer.stars.gotoAndPlay("on");
                           _pet.getChildAt(0).pet.setAnim(15);
                           _soundMan.playByName(this["_soundNamePlayerDamage" + (Math.floor(Math.random() * 2) + 1)]);
                        }
                     }
                     _loc3_++;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _obstacles.length)
                  {
                     _loc6_ = _obstacles[_loc3_];
                     if(_loc6_.clone.x + _layerPlayer.x < -100)
                     {
                        _obstacles.splice(_loc3_--,1);
                        _obstaclePool.push(_loc6_);
                        _loc6_.clone.parent.removeChild(_loc6_.clone);
                        if(_loc6_.type == 1)
                        {
                           if(SC_aj_goldDuckGlowLP)
                           {
                              SC_aj_goldDuckGlowLP.stop();
                              SC_aj_goldDuckGlowLP = null;
                           }
                        }
                     }
                     else
                     {
                        _loc6_.clone.y += _loc6_.velY * _frameTime;
                        if(_loc6_.clone.y < -85)
                        {
                           _loc6_.clone.y += 595;
                        }
                        else if(_loc6_.clone.y > 500)
                        {
                           _loc6_.clone.y -= 595;
                        }
                        if(_petContainer.collision.hitTestObject(_loc6_.clone.collision))
                        {
                           if(_loc6_.type == 0)
                           {
                              _gems++;
                              _points++;
                              _theGame.loader.content.gems.gemsText.text = "x " + _gems.toString();
                              _theGame.loader.content.points.text = _points.toString();
                              _obstacles.splice(_loc3_--,1);
                              _obstaclePool.push(_loc6_);
                              _loc6_.clone.gotoAndPlay("off");
                              _soundMan.playByName(this["_soundNameDuckPickup" + (Math.floor(Math.random() * 5) + 1)]);
                           }
                           else if(_loc6_.type == 1)
                           {
                              _gems += 15;
                              _points++;
                              _goldDuckies++;
                              _theGame.loader.content.gems.gemsText.text = "x " + _gems.toString();
                              _theGame.loader.content.points.text = _points.toString();
                              _obstacles.splice(_loc3_--,1);
                              _obstaclePool.push(_loc6_);
                              _loc6_.clone.gotoAndPlay("off");
                              addToPetMastery(1);
                              _soundMan.playByName(_soundNameGoldDuckPickup);
                              if(SC_aj_goldDuckGlowLP)
                              {
                                 SC_aj_goldDuckGlowLP.stop();
                                 SC_aj_goldDuckGlowLP = null;
                              }
                           }
                           else
                           {
                              forceMove(_loc6_.velY < 0);
                           }
                        }
                     }
                     _loc3_++;
                  }
                  shakeScreen(Math.max(0,-0.028 * (_layerPlayer.x + _petContainer.x) + 5) * _shakeIntensity);
                  if(_loc2_ > Math.floor(_layerPlayer.x / 100))
                  {
                     createObstacleColumn();
                  }
                  if(!(_petContainer.x + _layerPlayer.x > 0 && _petContainer.x + _layerPlayer.x < 700 && _petContainer.y > 0 && _petContainer.y < 425))
                  {
                     showGameOver();
                  }
               }
            }
         }
      }
      
      public function createObstacleColumn() : void
      {
         var _loc8_:Object = null;
         var _loc13_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:Object = null;
         var _loc12_:int = 0;
         var _loc1_:int = 0;
         var _loc10_:Number = NaN;
         var _loc2_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:Number = 0;
         _currentColumn++;
         if(_currentColumn == 0 || _currentColumn % 2 == 0 && Math.random() < 0.5)
         {
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               _lastColumnData[_loc4_] = 0;
               if(Math.random() < 0.37 || _currentColumn == 0)
               {
                  _loc8_ = getObstacle(0);
                  _layerPlayerSub3.addChild(_loc8_.clone);
                  _loc8_.clone.x = 750 + _currentColumn * 100;
                  _loc8_.clone.y = _loc4_ * 85 + 42.5;
                  _loc8_.velY = _loc6_;
                  _obstacles.push(_loc8_);
               }
               _loc4_++;
            }
         }
         else
         {
            if(_lastColumnData[0] == 0 && _lastColumnData[1] == 1 && _lastColumnData[2] == 0 && _lastColumnData[3] == 1 && _lastColumnData[4] == 0)
            {
               _loc9_ = Math.floor(Math.random() * 2);
            }
            else
            {
               _loc9_ = Math.floor(Math.random() * 3);
            }
            switch(_loc9_)
            {
               case 0:
                  _loc3_ = 0;
                  _loc7_ = 0;
                  if(Math.random() * 0.5 < 0.5)
                  {
                     _loc6_ = (Math.random() * (_vertScrollSpeedHigh - _vertScrollSpeedLow) + _vertScrollSpeedLow) * (Math.random() < 0.5 ? -1 : 1);
                  }
                  _loc4_ = 0;
                  while(_loc4_ < 5)
                  {
                     _loc8_ = getObstacle(Math.floor(Math.random() * 7) + (_loc4_ == 4 ? 4 : 3));
                     _loc12_ = 1;
                     if(_loc8_)
                     {
                        _loc7_++;
                        if(_loc8_.type == 3)
                        {
                           _loc12_ = 2;
                        }
                        if(_loc8_.type == 5)
                        {
                           _loc8_.clone.flower.gotoAndPlay("on");
                        }
                        _layerPlayerSub3.addChild(_loc8_.clone);
                        _loc8_.clone.x = 750 + _currentColumn * 100;
                        _loc8_.clone.y = _loc4_ * 85 + 42.5 * _loc12_;
                        _loc8_.velY = _loc6_;
                        _obstacles.push(_loc8_);
                        if(_loc6_ > 0)
                        {
                           _lastColumnData[_loc4_] == 0;
                        }
                        else
                        {
                           _lastColumnData[_loc4_] == 1;
                        }
                     }
                     else
                     {
                        if(Math.random() < 0.8)
                        {
                           _loc8_ = getObstacle(0);
                           _layerPlayerSub3.addChild(_loc8_.clone);
                           _loc8_.clone.x = 750 + _currentColumn * 100;
                           _loc8_.clone.y = _loc4_ * 85 + 42.5;
                           _loc8_.velY = _loc6_;
                           _obstacles.push(_loc8_);
                        }
                        _lastColumnData[_loc4_] == 0;
                        _loc3_++;
                     }
                     _loc4_ += _loc12_;
                  }
                  if(_loc3_ == 0)
                  {
                     _loc4_ = Math.floor(Math.random() * _loc7_);
                     _loc8_ = _obstacles[_obstacles.length - 1 - _loc4_];
                     _loc8_.clone.parent.removeChild(_loc8_.clone);
                     _obstacles.splice(_obstacles.length - 1 - _loc4_,1);
                     _obstaclePool.push(_loc8_);
                     _lastColumnData[_loc4_] == 0;
                  }
                  break;
               case 1:
                  if(_lastColumnData[0] == 0)
                  {
                     _loc13_ = Math.random() > 0.5 ? 1 : 2;
                  }
                  else if(_lastColumnData[1] == 0 || _lastColumnData[3] == 0)
                  {
                     _loc13_ = Math.random() > 0.5 ? 0 : 2;
                  }
                  else if(_lastColumnData[2] == 0)
                  {
                     _loc13_ = 1;
                  }
                  else if(_lastColumnData[4] == 0)
                  {
                     _loc13_ = Math.random() > 0.5 ? 0 : 1;
                  }
                  else
                  {
                     _loc13_ = Math.floor(Math.random() * 3);
                  }
                  _loc4_ = 0;
                  while(_loc4_ < 5)
                  {
                     _lastColumnData[_loc4_] = 0;
                     _loc4_++;
                  }
                  _lastColumnData[_loc13_] = 1;
                  _lastColumnData[_loc13_ + 2] = 1;
                  _loc8_ = getObstacle(0);
                  _layerPlayerSub3.addChild(_loc8_.clone);
                  _loc8_.clone.x = 750 + _currentColumn * 100;
                  _loc8_.clone.y = (_loc13_ + 1) * 85 + 42.5;
                  _loc8_.velY = 0;
                  _obstacles.push(_loc8_);
                  _loc11_ = getObstacle(2);
                  _frogs.push(_loc11_);
                  _loc10_ = Math.random() * (_frogJumpIntervalHigh - _frogJumpIntervalLow) + _frogJumpIntervalLow;
                  _loc4_ = 0;
                  while(_loc4_ < 2)
                  {
                     _loc8_ = getObstacle(5);
                     _loc8_.clone.flower.gotoAndPlay("off");
                     _layerPlayerSub3.addChild(_loc8_.clone);
                     _loc8_.clone.x = 750 + _currentColumn * 100;
                     _loc8_.clone.y = (_loc13_ + _loc4_ * 2) * 85 + 42.5;
                     _loc8_.velY = 0;
                     _obstacles.push(_loc8_);
                     _loc11_["o" + _loc4_] = _loc8_;
                     _loc4_++;
                  }
                  _layerPlayerSub1.addChild(_loc11_.clone);
                  _loc11_.clone.x = _loc11_.o0.clone.x;
                  _loc11_.clone.y = _loc11_.o0.clone.y;
                  _loc11_.jump = 408;
                  _loc11_.jumpType = 0;
                  _loc11_.jumpInterval = _loc10_;
                  _loc11_.jumpIntervalSetting = _loc10_;
                  break;
               case 2:
                  _lastColumnData[0] = 1;
                  _lastColumnData[1] = 0;
                  _lastColumnData[2] = 1;
                  _lastColumnData[3] = 0;
                  _lastColumnData[4] = 1;
                  _loc10_ = Math.random() * (_frogJumpIntervalHigh - _frogJumpIntervalLow) + _frogJumpIntervalLow;
                  _loc1_ = Math.floor(Math.random() * 3) + 1;
                  if(_loc1_ == 3)
                  {
                     _loc1_ = 4;
                  }
                  _loc4_ = 0;
                  while(_loc4_ < _loc1_)
                  {
                     _loc11_ = getObstacle(2);
                     _frogs.push(_loc11_);
                     _loc4_++;
                  }
                  _loc4_ = 0;
                  while(_loc4_ < 3)
                  {
                     _loc8_ = getObstacle(5);
                     _loc8_.clone.flower.gotoAndPlay("off");
                     _layerPlayerSub3.addChild(_loc8_.clone);
                     _loc8_.clone.x = 750 + _currentColumn * 100;
                     _loc8_.clone.y = _loc4_ * 2 * 85 + 42.5;
                     _loc8_.velY = 0;
                     _obstacles.push(_loc8_);
                     _loc5_ = 0;
                     while(_loc5_ < _loc1_)
                     {
                        _loc11_ = _frogs[_frogs.length - 1 - _loc5_];
                        _loc11_["o" + _loc4_] = _loc8_;
                        _loc5_++;
                     }
                     _loc4_++;
                  }
                  _loc2_ = Math.random() < 0.5 ? 1 : -1;
                  _loc4_ = 0;
                  while(_loc4_ < _loc1_)
                  {
                     _loc11_ = _frogs[_frogs.length - 1 - _loc4_];
                     _loc11_.clone.x = _loc11_.o0.clone.x;
                     _loc11_.jump = 408 * _loc2_;
                     if(_loc1_ == 2)
                     {
                        if(_loc11_.jump > 0)
                        {
                           _loc11_.clone.y = _loc11_.o0.clone.y - 170 * (_loc4_ * 2 + 1);
                        }
                        else
                        {
                           _loc11_.clone.y = _loc11_.o2.clone.y + 170 * (_loc4_ * 2 + 1);
                        }
                     }
                     else if(_loc11_.jump > 0)
                     {
                        _loc11_.clone.y = _loc11_.o0.clone.y - 170 * (_loc4_ + 1);
                     }
                     else
                     {
                        _loc11_.clone.y = _loc11_.o2.clone.y + 170 * (_loc4_ + 1);
                     }
                     _loc11_.jumpType = 1;
                     _loc11_.jumpInterval = _loc10_;
                     _loc11_.jumpIntervalSetting = _loc10_;
                     _loc11_.startY = _loc11_.clone.y;
                     _layerPlayerSub1.addChild(_loc11_.clone);
                     _loc4_++;
                  }
                  _loc8_ = getObstacle(0);
                  _layerPlayerSub3.addChild(_loc8_.clone);
                  _loc8_.clone.x = 750 + _currentColumn * 100;
                  _loc8_.clone.y = 127.5;
                  _loc8_.velY = 0;
                  _obstacles.push(_loc8_);
                  _loc8_ = getObstacle(0);
                  _layerPlayerSub3.addChild(_loc8_.clone);
                  _loc8_.clone.x = 750 + _currentColumn * 100;
                  _loc8_.clone.y = 297.5;
                  _loc8_.velY = 0;
                  _obstacles.push(_loc8_);
            }
         }
      }
      
      public function getObstacle(param1:int) : Object
      {
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         if(param1 > 6)
         {
            return null;
         }
         if(param1 == 2)
         {
            if(_frogPool.length > 0)
            {
               return _frogPool.pop();
            }
         }
         else
         {
            if(param1 == 0 && _numDucksCreated == 39)
            {
               param1 = 1;
               _numDucksCreated = -1;
               SC_aj_goldDuckGlowLP = _soundMan.playByName(_soundNameGoldDuckGlowLP,0,99999);
            }
            _loc2_ = 0;
            while(_loc2_ < _obstaclePool.length)
            {
               if(_obstaclePool[_loc2_].type == param1)
               {
                  _loc3_ = _obstaclePool[_loc2_];
                  _obstaclePool.splice(_loc2_,1);
                  if(param1 == 0 || param1 == 1)
                  {
                     _loc3_.clone.gotoAndPlay("on");
                     _numDucksCreated++;
                  }
                  return _loc3_;
               }
               _loc2_++;
            }
         }
         _loc3_ = {};
         _loc3_.type = param1;
         switch(param1)
         {
            case 0:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_rubberDuck");
               _numDucksCreated++;
               break;
            case 1:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_goldDuck");
               _numDucksCreated++;
               break;
            case 2:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_frog");
               _loc3_.clone.scaleY = 1.6;
               _loc3_.clone.scaleX = 1.6;
               break;
            case 3:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_log");
               break;
            case 4:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_tree");
               break;
            case 5:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_lillypad");
               break;
            case 6:
               _loc3_.clone = GETDEFINITIONBYNAME("duck_can");
         }
         return _loc3_;
      }
      
      public function startGame() : void
      {
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(_closeBtn)
         {
            _closeBtn.visible = true;
         }
         if(_theGame)
         {
            _pet = MinigameManager.getActivePet(petLoaded);
            _theGame.loader.content.petName.text = MinigameManager.getActivePetName();
            _readyGo = true;
            _theGame.loader.content.readyGo.gotoAndPlay("on");
         }
      }
      
      public function petLoaded(param1:MovieClip) : void
      {
         _petContainer = GETDEFINITIONBYNAME("duck_duck");
         _layerPlayerSub2.addChild(_petContainer as DisplayObject);
         _petContainer.duckContainer.addChild(_pet);
         _pet.getChildAt(0).pet.setAnim(10);
         _petContainer.x = 350;
         _petContainer.y = 240;
         _pet.scaleY = 2;
         _pet.scaleX = 2;
         _pet.scaleX *= -1;
      }
      
      public function onCloseButton() : void
      {
         showExitConfirmationDlg();
      }
   }
}

