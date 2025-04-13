package game.distanceChallenge
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
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
   import localization.LocalizationManager;
   
   public class DistanceChallenge extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      public static const BACKGROUND_TYPES_TOTAL:int = 6;
      
      public static const BACKGROUND_TYPES_SANDTRAP:int = 1;
      
      public static const BACKGROUND_TYPES_HARDICE:int = 2;
      
      public static const BACKGROUND_TYPES_SNOWDRIFT:int = 3;
      
      public static const BACKGROUND_TYPES_GEYSER:int = 4;
      
      public static const BACKGROUND_TYPES_ASH:int = 5;
      
      public static const BACKGROUND_TYPES_VOLCANO:int = 6;
      
      public var _soundMan:SoundManager;
      
      private var _facts:Array = [{
         "image":"9b1",
         "text":LocalizationManager.translateIdOnly(11394)
      },{
         "image":"9b3",
         "text":LocalizationManager.translateIdOnly(11395)
      },{
         "image":"7b1",
         "text":LocalizationManager.translateIdOnly(11396)
      },{
         "image":"6b1",
         "text":LocalizationManager.translateIdOnly(11397)
      },{
         "image":"9b6",
         "text":LocalizationManager.translateIdOnly(11398)
      },{
         "image":"9b3_2",
         "text":LocalizationManager.translateIdOnly(11399)
      },{
         "image":"3b1",
         "text":LocalizationManager.translateIdOnly(11400)
      },{
         "image":"3b1_2",
         "text":LocalizationManager.translateIdOnly(11401)
      },{
         "image":"9b1_2",
         "text":LocalizationManager.translateIdOnly(11402)
      },{
         "image":"9b4",
         "text":LocalizationManager.translateIdOnly(11403)
      },{
         "image":"9b4_2",
         "text":LocalizationManager.translateIdOnly(11404)
      },{
         "image":"9b5",
         "text":LocalizationManager.translateIdOnly(11405)
      },{
         "image":"9b3_3",
         "text":LocalizationManager.translateIdOnly(11406)
      }];
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerBackgroundSky:Sprite;
      
      public var _layerBackgroundMiddle:Sprite;
      
      public var _layerBackgroundGround:Sprite;
      
      public var _layerBackgroundObstacle:Sprite;
      
      public var _layerBackgroundLauncher:Sprite;
      
      public var _layerPlayer:Sprite;
      
      public var _layerSkyMove:Number;
      
      public var _layerGroundMove:Number;
      
      public var _particles:Array;
      
      public var _sky:Array;
      
      public var _backgroundElements:Array;
      
      public var _activeBackgroundType:int;
      
      public var _addBackgroundGroundX:int;
      
      public var _lastChangeBackgroundGroundX:int;
      
      public var _addMiddleX:int;
      
      public var _lastChangeMiddleX:int;
      
      public var _obstacleOffset:int;
      
      public var _windSound:SoundChannel;
      
      public var _gearsSound:SoundChannel;
      
      public var _nextBackgroundSwitch:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _displayAchievementTimer:Number;
      
      public var _score:Object;
      
      public var _launcher:Object;
      
      public var _transition:Object;
      
      public var _gameOverTimer:Number;
      
      public var _recordDistance:Number;
      
      public var _gemsEarned:int;
      
      public var _lastRot:Number;
      
      public var _player:DistanceChallengePlayer;
      
      public var SFX_ARM_GEARS:Class;
      
      public var SFX_ARM_WIND:Class;
      
      private const _sounds:Array = ["armadillo_bounce.mp3","armadillo_spray.mp3","armadillo_launch.mp3","armadillo_prairie_dog.mp3","aj_armadillo_outro.mp3","armdadillo_collision1.mp3","armdadillo_collision2.mp3","armdadillo_collision3.mp3","armadillo_intro.mp3","armadillo_stinger_success.mp3","armadillo_passby1.mp3","armadillo_passby2.mp3","armadillo_superman_close.mp3","armadillo_superman_open.mp3","armadillo_wonder_woman.mp3","armadillo_cactus_collision.mp3","armadillo_steam.mp3","armadillo_collision_snowman.mp3","armadillo_swing.mp3","aj_ls_steam.mp3","aj_ls_stump_imp.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3","armadillo_bounce.mp3"];
      
      internal var _soundNameArmBounce:String = _sounds[0];
      
      internal var _soundNameArmGeyser:String = _sounds[1];
      
      internal var _soundNameArmLaunch:String = _sounds[2];
      
      internal var _soundNameArmMole:String = _sounds[3];
      
      internal var _soundNameArmOutro:String = _sounds[4];
      
      internal var _soundNameArmCollision1:String = _sounds[5];
      
      internal var _soundNameArmCollision2:String = _sounds[6];
      
      internal var _soundNameArmCollision3:String = _sounds[7];
      
      internal var _soundNameArmIntro:String = _sounds[8];
      
      internal var _soundNameArmSuccess:String = _sounds[9];
      
      internal var _soundNameArmPassBy1:String = _sounds[10];
      
      internal var _soundNameArmPassBy2:String = _sounds[11];
      
      internal var _soundNameArmSpmnClose:String = _sounds[12];
      
      internal var _soundNameArmSpmnOpen:String = _sounds[13];
      
      internal var _soundNameArmWonderwmn:String = _sounds[14];
      
      internal var _soundNameArmCactusClsn:String = _sounds[15];
      
      internal var _soundNameArmSteam:String = _sounds[16];
      
      internal var _soundNameArmSnwmnClsn:String = _sounds[17];
      
      internal var _soundNameArmSwing:String = _sounds[18];
      
      internal var _soundNameArmLsSteam:String = _sounds[19];
      
      internal var _soundNameArmStump:String = _sounds[20];
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function DistanceChallenge()
      {
         super();
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameArmBounce],_soundNameArmBounce,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmGeyser],_soundNameArmGeyser,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmLaunch],_soundNameArmLaunch,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmMole],_soundNameArmMole,0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameArmOutro],_soundNameArmOutro,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmCollision1],_soundNameArmCollision1,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmCollision2],_soundNameArmCollision2,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmCollision3],_soundNameArmCollision3,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmIntro],_soundNameArmIntro,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSuccess],_soundNameArmSuccess,0.62);
         _soundMan.addSoundByName(_audioByName[_soundNameArmPassBy1],_soundNameArmPassBy1,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameArmPassBy2],_soundNameArmPassBy2,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSpmnClose],_soundNameArmSpmnClose,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSpmnOpen],_soundNameArmSpmnOpen,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmWonderwmn],_soundNameArmWonderwmn,1.24);
         _soundMan.addSoundByName(_audioByName[_soundNameArmCactusClsn],_soundNameArmCactusClsn,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSteam],_soundNameArmSteam,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSnwmnClsn],_soundNameArmSnwmnClsn,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmSwing],_soundNameArmSwing,0.58);
         _soundMan.addSoundByName(_audioByName[_soundNameArmLsSteam],_soundNameArmLsSteam,1);
         _soundMan.addSoundByName(_audioByName[_soundNameArmStump],_soundNameArmStump,1);
         _soundMan.addSound(SFX_ARM_WIND,0.2,"SFX_ARM_WIND");
         _soundMan.addSound(SFX_ARM_GEARS,0.2,"SFX_ARM_GEARS");
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
         stage.removeEventListener("keyDown",replayKeyDown);
         stage.removeEventListener("keyDown",greatJobKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",fireKeyDown);
         stage.removeEventListener("mouseDown",mouseClickHandler);
         resetGame();
         _bInit = false;
         removeLayer(_layerBackgroundSky);
         removeLayer(_layerBackgroundMiddle);
         removeLayer(_layerBackgroundGround);
         removeLayer(_layerBackgroundObstacle);
         removeLayer(_layerBackgroundLauncher);
         removeLayer(_layerPlayer);
         removeLayer(_guiLayer);
         _layerBackgroundSky = null;
         _layerBackgroundMiddle = null;
         _layerBackgroundGround = null;
         _layerBackgroundObstacle = null;
         _layerBackgroundLauncher = null;
         _layerPlayer = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            _particles = [];
            _layerBackgroundSky = new Sprite();
            _layerBackgroundMiddle = new Sprite();
            _layerBackgroundGround = new Sprite();
            _layerBackgroundObstacle = new Sprite();
            _layerBackgroundLauncher = new Sprite();
            _layerPlayer = new Sprite();
            _layerBackgroundSky.mouseEnabled = false;
            _layerBackgroundMiddle.mouseEnabled = false;
            _layerBackgroundGround.mouseEnabled = false;
            _layerBackgroundObstacle.mouseEnabled = false;
            _layerBackgroundLauncher.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBackgroundSky);
            addChild(_layerBackgroundMiddle);
            addChild(_layerBackgroundGround);
            addChild(_layerBackgroundLauncher);
            addChild(_layerBackgroundObstacle);
            addChild(_layerPlayer);
            addChild(_guiLayer);
            loadScene("DistanceChallenge/room_main.xroom",_sounds);
            _bInit = true;
         }
         else
         {
            startGame();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         SFX_ARM_GEARS = getDefinitionByName("gears") as Class;
         if(SFX_ARM_GEARS == null)
         {
            throw new Error("Sound not found! name:gears");
         }
         SFX_ARM_WIND = getDefinitionByName("wind") as Class;
         if(SFX_ARM_WIND == null)
         {
            throw new Error("Sound not found! name:wind");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         var _loc2_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         if(_loc2_ != 0)
         {
            _recordDistance = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc2_),0);
         }
         else
         {
            _recordDistance = 0;
         }
         _score = _scene.getLayer("score");
         _guiLayer.addChild(_score.loader);
         _score.loader.content.record.text = _recordDistance;
         _loc5_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",_loc5_.x,_loc5_.y,onCloseButton);
         _launcher = _scene.getLayer("launcher");
         _layerBackgroundLauncher.addChild(_launcher.loader);
         _lastRot = _launcher.loader.content.stringAngle;
         _backgroundElements = new Array(6);
         _sky = [];
         _sky.push(_scene.getLayer("sky"));
         _sky.push(_scene.getLayer("sky_2"));
         _sky[0].loader.y = 0;
         _sky[1].loader.y = 0;
         _loc4_ = 0;
         while(_loc4_ < 6)
         {
            _backgroundElements[_loc4_] = {};
            _backgroundElements[_loc4_].ground = [];
            _backgroundElements[_loc4_].ground.push(_scene.getLayer("ground" + (_loc4_ + 1)));
            _backgroundElements[_loc4_].ground.push(_scene.getLayer("ground" + (_loc4_ + 1) + "_2"));
            _backgroundElements[_loc4_].ground[0].loader.y = _sky[0].height;
            _backgroundElements[_loc4_].ground[1].loader.y = _sky[0].height;
            _backgroundElements[_loc4_].obstacle = [];
            _backgroundElements[_loc4_].obstacle.push(_scene.getLayer("obstacle" + (_loc4_ + 1)));
            _backgroundElements[_loc4_].obstacle.push(_scene.getLayer("obstacle" + (_loc4_ + 1) + "_2"));
            _backgroundElements[_loc4_].obstacle[0].loader.y = _sky[0].height;
            _backgroundElements[_loc4_].obstacle[1].loader.y = _sky[0].height;
            _backgroundElements[_loc4_].middle = [];
            _backgroundElements[_loc4_].middle.push(_scene.getLayer("middle" + (_loc4_ + 1)));
            _backgroundElements[_loc4_].middle.push(_scene.getLayer("middle" + (_loc4_ + 1) + "_2"));
            _backgroundElements[_loc4_].middle[0].loader.y = _sky[0].height - _backgroundElements[_loc4_].middle[0].height;
            _backgroundElements[_loc4_].middle[1].loader.y = _sky[0].height - _backgroundElements[_loc4_].middle[0].height;
            _loc4_++;
         }
         _transition = _scene.getLayer("transition");
         _transition.loader.y = _sky[0].height;
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseDown",mouseClickHandler);
         stage.addEventListener("keyDown",fireKeyDown);
         startGame();
         super.sceneLoaded(param1);
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
      
      private function fireKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               if(activeDlgMC == null)
               {
                  mouseClickHandler(param1);
                  break;
               }
         }
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onGreatJob_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onGreatJob_No();
         }
      }
      
      private function greatJobKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               showGreatJobDlg();
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc8_:* = 0;
         var _loc12_:Object = null;
         var _loc6_:MovieClip = null;
         var _loc4_:Number = NaN;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc11_:Number = NaN;
         var _loc2_:int = 0;
         var _loc5_:Number = NaN;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
            if(_sceneLoaded)
            {
               if(_player && _player._started == false && _launcher.loader.parent != null && _launcher.loader.content && _launcher.loader.content.launcherOn)
               {
                  if(_gearsSound == null)
                  {
                     _gearsSound = _soundMan.play(SFX_ARM_GEARS,0,99999);
                  }
                  if(Math.abs(_launcher.loader.content.stringAngle - _lastRot) > 200)
                  {
                     _soundMan.playByName(_soundNameArmSwing);
                  }
                  _lastRot = _launcher.loader.content.stringAngle;
               }
               if(!_pauseGame)
               {
                  _gameTime += _frameTime;
                  if(_gameOverTimer > 0)
                  {
                     _gameOverTimer -= _frameTime;
                     if(_gameOverTimer <= 0)
                     {
                        _closeBtn.visible = false;
                        stage.addEventListener("keyDown",greatJobKeyDown);
                        _loc6_ = showDlg("longshot_result",[{
                           "name":"continue_btn",
                           "f":showGreatJobDlg
                        }]);
                        _pauseGame = false;
                        _loc6_.x = 450;
                        _loc6_.y = 275;
                        _loc6_.result_score.text = valueTrackerCurrent();
                        _loc8_ = Math.random() * _facts.length;
                        _scene.getLayer(_facts[_loc8_].image).loader.x = 0;
                        _scene.getLayer(_facts[_loc8_].image).loader.y = 0;
                        _loc6_.result_pic.addChild(_scene.getLayer(_facts[_loc8_].image).loader);
                        LocalizationManager.updateToFit(_loc6_.result_fact,_facts[_loc8_].text);
                        _soundMan.playByName(_soundNameArmSuccess);
                        if(valueTrackerCurrent() > _recordDistance)
                        {
                           _recordDistance = valueTrackerCurrent();
                           _score.loader.content.record.text = _recordDistance;
                           valueTrackerCommit();
                           _displayAchievementTimer = 1;
                        }
                     }
                  }
                  _loc4_ = Math.max(_player._clone.loader.x,_loc9_);
                  _player.heartbeat(_frameTime);
                  updateWindVolume();
                  if(_player._started)
                  {
                     _loc3_ = 700;
                     _loc9_ = 50;
                     _loc11_ = (Math.min(_player._clone.loader.x,_loc3_) - _loc9_) / (_loc3_ - _loc9_);
                     _loc4_ = _player._clone.loader.x - _loc4_;
                     if(_loc4_ > 0)
                     {
                        _layerGroundMove += _loc4_ * _loc11_;
                        _loc2_ = _layerGroundMove;
                        if(_loc2_ > 0)
                        {
                           _layerGroundMove -= _loc2_;
                           _layerPlayer.x -= _loc2_;
                           _layerBackgroundGround.x -= _loc2_;
                           _layerBackgroundObstacle.x -= _loc2_;
                           _layerBackgroundLauncher.x -= _loc2_;
                        }
                        if(_launcher.loader.parent && _launcher.loader.x + _launcher.width + _layerBackgroundLauncher.x < 0)
                        {
                           _launcher.loader.parent.removeChild(_launcher.loader);
                        }
                        _layerSkyMove += _loc4_ * _loc11_ * 0.125;
                        _loc2_ = _layerSkyMove;
                        if(_loc2_ > 0)
                        {
                           _layerBackgroundSky.x -= _loc2_;
                           if(_layerBackgroundSky.x < -_sky[0].width)
                           {
                              _layerBackgroundSky.x += _sky[0].width;
                           }
                           _layerSkyMove -= _loc2_;
                        }
                        _loc8_ = _layerBackgroundGround.numChildren - 1;
                        while(_loc8_ >= 0)
                        {
                           _loc12_ = _layerBackgroundGround.getChildAt(_loc8_);
                           if(_loc12_.x + _loc12_.width + _layerBackgroundGround.x < 0)
                           {
                              if(_loc12_.x < _lastChangeBackgroundGroundX)
                              {
                                 _loc12_.parent.removeChild(_loc12_);
                                 _loc12_ = _layerBackgroundObstacle.getChildAt(_loc8_);
                                 _loc12_.parent.removeChild(_loc12_);
                              }
                              else
                              {
                                 _loc5_ = _addBackgroundGroundX;
                                 _loc12_.x = _addBackgroundGroundX;
                                 _addBackgroundGroundX += _loc12_.width;
                                 _loc12_ = _layerBackgroundObstacle.getChildAt(_loc8_);
                                 _loc12_.content.gotoAndPlay("off");
                                 _loc12_.content.armadilloSpeedX = 0;
                                 _loc12_.x = _loc5_ + _obstacleOffset;
                              }
                           }
                           _loc8_--;
                        }
                        if(_addBackgroundGroundX >= _nextBackgroundSwitch)
                        {
                           _loc7_ = 0;
                           _loc10_ = 1;
                           if(_nextBackgroundSwitch < 100800)
                           {
                              _loc7_ = 0;
                              _loc10_ = 1;
                           }
                           else if(_nextBackgroundSwitch <= 208800)
                           {
                              _loc7_ = 2;
                              _loc10_ = 3;
                           }
                           else
                           {
                              _loc7_ = 4;
                              _loc10_ = 5;
                           }
                           _loc8_ = _activeBackgroundType + 1;
                           if(_loc8_ > _loc10_ || _loc8_ < _loc7_)
                           {
                              _loc8_ = _loc7_;
                           }
                           setBackgroundActive(_loc8_);
                        }
                        _layerBackgroundMiddle.x = _layerBackgroundLauncher.x / 4;
                        _loc8_ = _layerBackgroundMiddle.numChildren - 1;
                        while(_loc8_ >= 0)
                        {
                           _loc12_ = _layerBackgroundMiddle.getChildAt(_loc8_);
                           if(_loc12_.x + _backgroundElements[0].ground[0].width * 2 + _layerBackgroundMiddle.x < 0)
                           {
                              if(_loc12_.x < _lastChangeMiddleX)
                              {
                                 _loc12_.parent.removeChild(_loc12_);
                              }
                              else
                              {
                                 _loc12_.x = _addMiddleX;
                                 _loc12_.visible = false;
                              }
                           }
                           else if(_loc12_.visible == false)
                           {
                              if(_loc12_.x <= _lastChangeMiddleX)
                              {
                                 _loc12_.parent.removeChild(_loc12_);
                              }
                              else if(_loc12_.x + _backgroundElements[0].ground[0].width * 2 + _layerBackgroundMiddle.x < _backgroundElements[0].ground[0].width * 2)
                              {
                                 _addMiddleX += _backgroundElements[0].ground[0].width * 2;
                                 _loc12_.visible = true;
                              }
                           }
                           _loc8_--;
                        }
                     }
                     if(_player._started)
                     {
                        _score.loader.content.distance.text = valueTrackerCurrent();
                     }
                     else
                     {
                        _score.loader.content.distance.text = 0;
                     }
                  }
                  if(_particles)
                  {
                     _loc8_ = _particles.length - 1;
                     while(_loc8_ >= 0)
                     {
                        _particles[_loc8_].timeRemaining -= _frameTime;
                        if(_particles[_loc8_].timeRemaining <= 0)
                        {
                           _particles[_loc8_].clone.loader.parent.removeChild(_particles[_loc8_].clone.loader);
                           _scene.releaseCloneAsset(_particles[_loc8_].clone.loader);
                           _particles.splice(_loc8_,1);
                        }
                        _loc8_--;
                     }
                  }
               }
            }
         }
      }
      
      public function updateWindVolume() : void
      {
         var _loc1_:SoundTransform = null;
         if(_windSound && !SBAudio.isMusicMuted)
         {
            _loc1_ = _windSound.soundTransform;
            _loc1_.volume = Math.min(_player._velocity.x / 15000,0.2);
            _windSound.soundTransform = _loc1_;
         }
      }
      
      public function showGreatJobDlg() : void
      {
         stage.removeEventListener("keyDown",greatJobKeyDown);
         stage.addEventListener("keyDown",replayKeyDown);
         hideDlg();
         var _loc1_:MovieClip = showDlg("card_longshot_greatjob",[{
            "name":"button_yes",
            "f":onGreatJob_Yes
         },{
            "name":"button_no",
            "f":onGreatJob_No
         }]);
         _pauseGame = false;
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,_gemsEarned == 1 ? 11433 : 11432,_gemsEarned);
         _loc1_.text_score.text.toLowerCase();
      }
      
      public function startGame() : void
      {
         if(_sceneLoaded)
         {
            _score.loader.content.distance.text = 0;
            _gameOverTimer = 0;
            resetGame();
            _player = new DistanceChallengePlayer(this);
            _obstacleOffset = 700;
            _activeBackgroundType = -1;
            _addBackgroundGroundX = 0;
            _addMiddleX = 0;
            _nextBackgroundSwitch = 0;
            setBackgroundActive(0);
            if(_launcher.loader.parent == null)
            {
               _layerBackgroundLauncher.addChild(_launcher.loader);
            }
            _launcher.loader.content.reset();
            _soundMan.playByName(_soundNameArmIntro);
            _gameTime = 0;
            _lastTime = getTimer();
            _frameTime = 0;
            _layerBackgroundSky.x = 0;
            _layerBackgroundGround.x = 0;
            _layerBackgroundObstacle.x = 0;
            _layerBackgroundLauncher.x = 0;
            _layerBackgroundMiddle.x = 0;
            _layerPlayer.x = 0;
            _layerSkyMove = 0;
            _layerGroundMove = 0;
         }
      }
      
      public function resetGame() : void
      {
         var _loc1_:int = 0;
         if(_windSound != null)
         {
            _windSound.stop();
            _windSound = null;
         }
         if(_gearsSound != null)
         {
            _gearsSound.stop();
            _gearsSound = null;
         }
         if(_particles)
         {
            while(_particles.length > 0)
            {
               _particles[0].clone.loader.parent.removeChild(_particles[0].clone.loader);
               _scene.releaseCloneAsset(_particles[0].clone.loader);
               _particles.splice(0,1);
            }
         }
         if(_transition.loader.parent != null)
         {
            _transition.loader.parent.removeChild(_transition.loader);
         }
         _loc1_ = 0;
         while(_loc1_ < 6)
         {
            if(_sky[0].loader.parent)
            {
               _sky[0].loader.parent.removeChild(_sky[0].loader);
            }
            if(_sky[1].loader.parent)
            {
               _sky[1].loader.parent.removeChild(_sky[1].loader);
            }
            if(_backgroundElements[_loc1_].ground[0].loader.parent)
            {
               _backgroundElements[_loc1_].ground[0].loader.parent.removeChild(_backgroundElements[_loc1_].ground[0].loader);
            }
            if(_backgroundElements[_loc1_].ground[1].loader.parent)
            {
               _backgroundElements[_loc1_].ground[1].loader.parent.removeChild(_backgroundElements[_loc1_].ground[1].loader);
            }
            if(_backgroundElements[_loc1_].obstacle[0].loader.parent)
            {
               _backgroundElements[_loc1_].obstacle[0].loader.parent.removeChild(_backgroundElements[_loc1_].obstacle[0].loader);
            }
            if(_backgroundElements[_loc1_].obstacle[1].loader.parent)
            {
               _backgroundElements[_loc1_].obstacle[1].loader.parent.removeChild(_backgroundElements[_loc1_].obstacle[1].loader);
            }
            if(_backgroundElements[_loc1_].middle[0].loader.parent)
            {
               _backgroundElements[_loc1_].middle[0].loader.parent.removeChild(_backgroundElements[_loc1_].middle[0].loader);
            }
            if(_backgroundElements[_loc1_].middle[1].loader.parent)
            {
               _backgroundElements[_loc1_].middle[1].loader.parent.removeChild(_backgroundElements[_loc1_].middle[1].loader);
            }
            _loc1_++;
         }
         if(_player)
         {
            _player.remove();
            _player = null;
         }
      }
      
      public function setBackgroundActive(param1:int) : void
      {
         if(_activeBackgroundType != param1)
         {
            if(_addBackgroundGroundX > 0)
            {
               _transition.loader.x = _addBackgroundGroundX - _transition.width / 2;
               if(_transition.loader.parent == null)
               {
                  _layerBackgroundLauncher.addChild(_transition.loader);
               }
            }
            _addMiddleX = _addBackgroundGroundX / 4 + 1;
            if(_addMiddleX > 1 && _addMiddleX + _layerBackgroundMiddle.x < 900)
            {
               _addMiddleX = 900 - _layerBackgroundMiddle.x;
            }
            _lastChangeBackgroundGroundX = _addBackgroundGroundX;
            _lastChangeMiddleX = _addMiddleX;
            if(_sky[0].loader.parent == null)
            {
               _layerBackgroundSky.addChild(_sky[0].loader);
               _sky[0].loader.x = 0;
               _layerBackgroundSky.addChild(_sky[1].loader);
               _sky[1].loader.x = _sky[0].width;
            }
            _layerBackgroundGround.addChild(_backgroundElements[param1].ground[0].loader);
            _layerBackgroundObstacle.addChild(_backgroundElements[param1].obstacle[0].loader);
            _layerBackgroundMiddle.addChild(_backgroundElements[param1].middle[0].loader);
            _layerBackgroundGround.addChild(_backgroundElements[param1].ground[1].loader);
            _layerBackgroundObstacle.addChild(_backgroundElements[param1].obstacle[1].loader);
            _backgroundElements[param1].obstacle[0].loader.content.gotoAndPlay("off");
            _backgroundElements[param1].obstacle[1].loader.content.gotoAndPlay("off");
            _backgroundElements[param1].obstacle[0].loader.content.armadilloSpeedX = 0;
            _backgroundElements[param1].middle[0].loader.visible = true;
            _backgroundElements[param1].ground[0].loader.x = _addBackgroundGroundX;
            _backgroundElements[param1].obstacle[0].loader.x = _addBackgroundGroundX + _obstacleOffset;
            _backgroundElements[param1].middle[0].loader.x = _addMiddleX;
            _addBackgroundGroundX += _backgroundElements[param1].ground[0].width;
            _addMiddleX += _backgroundElements[param1].ground[0].width * 2;
            _backgroundElements[param1].obstacle[1].loader.content.armadilloSpeedX = 0;
            _backgroundElements[param1].ground[1].loader.x = _addBackgroundGroundX;
            _backgroundElements[param1].obstacle[1].loader.x = _addBackgroundGroundX + _obstacleOffset;
            _addBackgroundGroundX += _backgroundElements[param1].ground[0].width;
            _addMiddleX += _backgroundElements[param1].ground[0].width * 2;
            _activeBackgroundType = param1;
            _nextBackgroundSwitch += 7200;
         }
      }
      
      public function setGameOver() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = new Array(1000,2000,3000,4000,5000,8000,10000,15000,20000,25000,30000,40000,50000,60000,75000,100000,150000);
         var _loc1_:Array = new Array(1,2,4,6,8,10,15,20,25,35,50,75,100,125,150,200,250);
         _gemsEarned = 300;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(valueTrackerCurrent() < _loc3_[_loc2_])
            {
               _gemsEarned = _loc1_[_loc2_];
               break;
            }
            _loc2_++;
         }
         addGemsToBalance(_gemsEarned);
         _gameOverTimer = 2;
      }
      
      public function addSnowmanHead(param1:Number, param2:Number) : void
      {
         var _loc3_:Object = null;
         if(_particles)
         {
            _loc3_ = {};
            _loc3_.clone = _scene.cloneAsset("snowmanHead");
            _loc3_.clone.loader.x = _layerBackgroundGround.x + param1;
            _loc3_.clone.loader.y = param2;
            _loc3_.clone.loader.contentLoaderInfo.addEventListener("complete",onSnowmanLoad);
            _loc3_.timeRemaining = 5;
            addChild(_loc3_.clone.loader);
            _particles.push(_loc3_);
         }
      }
      
      public function onSnowmanLoad(param1:Event) : void
      {
         param1.target.content.hit(_player._velocity.x,_player._velocity.y);
         param1.target.removeEventListener("complete",onSnowmanLoad);
      }
      
      private function mouseClickHandler(param1:Event) : void
      {
         if(_sceneLoaded)
         {
            if(_player)
            {
               if(!_player._started)
               {
                  if(_launcher.loader.content.launcherOn)
                  {
                     _launcher.loader.content.launch();
                     _player.start();
                     if(_windSound == null)
                     {
                        _windSound = _soundMan.play(SFX_ARM_WIND,0,99999);
                        if(_gearsSound != null)
                        {
                           _gearsSound.stop();
                           _gearsSound = null;
                        }
                     }
                  }
               }
            }
         }
      }
      
      private function onCloseButton() : void
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
      
      private function onGreatJob_Yes() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         _closeBtn.visible = true;
         hideDlg();
         startGame();
      }
      
      private function onGreatJob_No() : void
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

