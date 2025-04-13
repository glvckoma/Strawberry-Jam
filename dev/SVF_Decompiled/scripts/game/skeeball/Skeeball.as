package game.skeeball
{
   import Box2D.Collision.Shapes.b2CircleDef;
   import Box2D.Collision.Shapes.b2PolygonDef;
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2World;
   import achievement.AchievementXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   
   public class Skeeball extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      public static const GAMESTATE_HOWTOPLAY:int = 9;
      
      private static const SHOW_DEBUG:Boolean = false;
      
      public static var SFX_aj_tickets:Class;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      public var _layerRings:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      private var _world:b2World;
      
      private var _contactListener:Skeeball_ContactListener;
      
      private var _iterations:int = 10;
      
      private var _timeStep:Number = 0.041666666666666664;
      
      private var _phyScale:Number = 0.03333333333333333;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      private var _timeOutTimer:Number;
      
      private var _cueBallBody:b2Body;
      
      private var _shootState:int;
      
      private var _currentPopup:MovieClip;
      
      private var _direction:Point = new Point();
      
      private var _startY:Number;
      
      private var _arrowMeterDirection:int = 1;
      
      private var _cueBallDirection:int = 0;
      
      private var _score:int;
      
      private var _scorePopup:MovieClip;
      
      private var _currentBonus:int = 0;
      
      private var _defaultChildIndex:int;
      
      private var _ball:MovieClip;
      
      private var _bonusHole:Object;
      
      private var _arrowRotSpeed:int = 80;
      
      private var _arrowColorSpeed:int = 140;
      
      private var _velocityLow:int = 100;
      
      private var _velocityHigh:int = 400;
      
      private var _hitTestComplete:Boolean;
      
      private var _scoreMultiplier:int = 1;
      
      private var _numBalls:int;
      
      private var _ticketsWon:int;
      
      private var _gameOver:Boolean;
      
      public var _serialNumber1:int;
      
      public var _serialNumber2:int;
      
      private var _startTextureX:Number;
      
      private var _startTextureY:Number;
      
      private var _highScore:int;
      
      private var _bgContent:Object;
      
      public var _soundMan:SoundManager;
      
      public var _resultsDlg:MovieClip;
      
      private const _audio:Array = ["aj_sb_ballOnBall1.mp3","aj_sb_ballreload.mp3","aj_sb_holeImp.mp3","aj_sb_imp1.mp3","aj_sb_imp2.mp3","aj_sb_imp3.mp3","aj_sb_imp4.mp3","aj_sb_imp5.mp3","aj_sb_launch1.mp3","aj_sb_launch2.mp3","aj_sb_launch3.mp3","aj_sb_roll1.mp3","aj_sb_roll2.mp3","aj_sb_roll3.mp3","aj_sb_roll4.mp3","stinger0.mp3","stinger1.mp3","stinger2.mp3","stinger3.mp3","stinger4.mp3","stinger5.mp3","stingerGold.mp3"];
      
      private var _soundNameBallOnBall1:String = _audio[0];
      
      private var _soundNameBallReload:String = _audio[1];
      
      private var _soundNameHoleImp:String = _audio[2];
      
      private var _soundNameImp1:String = _audio[3];
      
      private var _soundNameImp2:String = _audio[4];
      
      private var _soundNameImp3:String = _audio[5];
      
      private var _soundNameImp4:String = _audio[6];
      
      private var _soundNameImp5:String = _audio[7];
      
      private var _soundNameLaunch1:String = _audio[8];
      
      private var _soundNameLaunch2:String = _audio[9];
      
      private var _soundNameLaunch3:String = _audio[10];
      
      private var _soundNameRoll1:String = _audio[11];
      
      private var _soundNameRoll2:String = _audio[12];
      
      private var _soundNameRoll3:String = _audio[13];
      
      private var _soundNameRoll4:String = _audio[14];
      
      private var _soundNameStinger0:String = _audio[15];
      
      private var _soundNameStinger1:String = _audio[16];
      
      private var _soundNameStinger2:String = _audio[17];
      
      private var _soundNameStinger3:String = _audio[18];
      
      private var _soundNameStinger4:String = _audio[19];
      
      private var _soundNameStinger5:String = _audio[20];
      
      private var _soundNameStingerGold:String = _audio[21];
      
      private var _SFX_aj_tickets_Instance:SoundChannel;
      
      private var _rollSound:SoundChannel;
      
      public function Skeeball()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameBallOnBall1],_soundNameBallOnBall1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameBallReload],_soundNameBallReload,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameHoleImp],_soundNameHoleImp,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameImp1],_soundNameImp1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameImp2],_soundNameImp2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameImp3],_soundNameImp3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameImp4],_soundNameImp4,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameImp5],_soundNameImp5,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLaunch1],_soundNameLaunch1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLaunch2],_soundNameLaunch2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameLaunch3],_soundNameLaunch3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRoll1],_soundNameRoll1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRoll2],_soundNameRoll2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRoll3],_soundNameRoll3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameRoll4],_soundNameRoll4,0.13);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger0],_soundNameStinger0,0.15);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger1],_soundNameStinger1,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger2],_soundNameStinger2,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger3],_soundNameStinger3,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger4],_soundNameStinger4,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStinger5],_soundNameStinger5,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameStingerGold],_soundNameStingerGold,0.1);
         _soundMan.addSound(SFX_aj_tickets,0.15,"SFX_aj_tickets");
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         myId = param1;
         _pIDs = param2;
         init();
      }
      
      public function message(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         if(param1[0] == "ms")
         {
            _serverStarted = true;
            _dbIDs = [];
            _loc3_ = 0;
            while(_loc3_ < _pIDs.length)
            {
               _dbIDs[_loc3_] = param1[_loc3_ + 1];
               _loc3_++;
            }
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "pz")
            {
               _serialNumber1 = (parseInt(param1[3]) + 7) / 3 - 5;
            }
            else if(param1[2] == "pg")
            {
               if(parseInt(param1[3]) == 1)
               {
                  _serialNumber2 = (parseInt(param1[4]) + 7) / 3 - 5;
                  setGameState(4);
               }
               else
               {
                  _loc2_ = showDlg("carnival_lowGems",[{
                     "name":"exitButton",
                     "f":onStart_No
                  }]);
                  _loc2_.x = 450;
                  _loc2_.y = 275;
               }
            }
            else if(param1[2] == "gr")
            {
               _ticketsWon = parseInt(param1[3]);
               showGameOver();
            }
         }
      }
      
      private function doGameOver() : void
      {
         setGameState(6);
         var _loc1_:Array = [];
         var _loc3_:int = (_score + 29) * 7 + (_serialNumber1 + 49) * 5;
         var _loc4_:int = (_score + 49) * 3 + (_serialNumber2 + 83) * 5;
         var _loc2_:int = (_serialNumber1 + _score) * 3 + _score * 3;
         _loc1_[0] = "gr";
         _loc1_[1] = _loc3_;
         _loc1_[2] = _loc4_;
         _loc1_[3] = _loc2_;
         MinigameManager.msg(_loc1_);
      }
      
      public function end(param1:Array) : void
      {
         if(_SFX_aj_tickets_Instance)
         {
            _soundMan.stop(_SFX_aj_tickets_Instance);
            _SFX_aj_tickets_Instance = null;
         }
         hideDlg();
         releaseBase();
         stage.removeEventListener("keyDown",onCarnPlayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         removeEventListener("mouseDown",mouseDownHandler);
         _bInit = false;
         _world = null;
         removeLayer(_layerMain);
         removeLayer(_layerRings);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _layerMain = null;
         _layerRings = null;
         _layerPopups = null;
         _guiLayer = null;
         MinigameManager.leave();
      }
      
      private function init() : void
      {
         var _loc1_:MovieClip = null;
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _layerRings = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_layerRings);
            addChild(_layerPopups);
            addChild(_guiLayer);
            loadScene("SkeeballAssets/room_main.xroom",_audio);
            _bInit = true;
         }
         else if(_sceneLoaded)
         {
            _loc1_ = showDlg("carnival_play",[{
               "name":"button_yes",
               "f":onStart_Yes
            },{
               "name":"button_no",
               "f":onStart_No
            }]);
            _loc1_.x = 450;
            _loc1_.y = 275;
            stage.addEventListener("keyDown",onCarnPlayKeyDown);
         }
      }
      
      private function onCarnPlayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               onStart_Yes();
               break;
            case 8:
            case 46:
            case 27:
               onStart_No();
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc7_:int = 0;
         SFX_aj_tickets = getDefinitionByName("aj_tickets") as Class;
         if(SFX_aj_tickets == null)
         {
            throw new Error("Sound not found! name:aj_tickets");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _bgContent = _scene.getLayer("bg").loader.content;
         _layerMain.addChild(_bgContent as DisplayObject);
         _bgContent.multiplierText.text = "x1";
         _loc7_ = 6;
         while(_loc7_ >= 1)
         {
            _layerRings.addChild(_bgContent["ringb" + _loc7_]);
            _loc7_--;
         }
         _loc7_ = 6;
         while(_loc7_ >= 1)
         {
            _layerRings.addChild(_bgContent["ringf" + _loc7_]);
            _loc7_--;
         }
         _layerRings.addChild(_bgContent.skeeBall_ramp);
         _ball = _bgContent.ball;
         _layerRings.addChild(_ball);
         _startTextureX = _ball.texture.x;
         _startTextureY = _ball.texture.y;
         var _loc2_:b2AABB = new b2AABB();
         _loc2_.lowerBound.Set(-1000,-1000);
         _loc2_.upperBound.Set(1000,1000);
         var _loc5_:b2Vec2 = new b2Vec2(0,10);
         _world = new b2World(_loc2_,_loc5_,true);
         _contactListener = new Skeeball_ContactListener();
         _world.SetContactListener(_contactListener);
         _currentBonus = Math.floor(Math.random() * 7) + 1;
         chooseGlowHole();
         _bgContent.aimArrow.stop();
         _bgContent.aimArrow.rotation = 0;
         _scorePopup = GETDEFINITIONBYNAME("skeeBall_scorePopup");
         _layerPopups.addChild(_scorePopup);
         _highScore = Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(334),0);
         createCollision();
         _soundMan.playByName(_soundNameBallReload);
         stage.addEventListener("enterFrame",heartbeat);
         addEventListener("mouseDown",mouseDownHandler);
         _ball.visible = false;
         _bgContent.aimArrow.visible = false;
         _sceneLoaded = true;
         super.sceneLoaded(param1);
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _score = 0;
         _bgContent.scoreText.text = "0";
         _bgContent.highScoreText.text = _highScore.toString();
         _gameOver = true;
         var _loc6_:MovieClip = showDlg("carnival_play",[{
            "name":"button_yes",
            "f":onStart_Yes
         },{
            "name":"button_no",
            "f":onStart_No
         }]);
         _loc6_.x = 450;
         _loc6_.y = 275;
         stage.addEventListener("keyDown",onCarnPlayKeyDown);
      }
      
      private function setGlowHole(param1:Boolean) : void
      {
         if(_bonusHole)
         {
            if(param1)
            {
               _bgContent.glowOn(_currentBonus == 1 ? 7 : _currentBonus - 1);
            }
            else
            {
               _bgContent.glowOff(_currentBonus == 1 ? 7 : _currentBonus - 1);
            }
         }
      }
      
      private function createPhysicsBall() : void
      {
         var _loc2_:b2BodyDef = null;
         var _loc6_:Object = null;
         var _loc1_:Number = NaN;
         var _loc5_:b2CircleDef = new b2CircleDef();
         _loc5_.density = 1;
         _loc5_.restitution = 0.4;
         _loc5_.friction = 0.5;
         _loc6_ = _ball;
         _loc1_ = _loc6_.marble.width * 0.5 * _loc6_.scaleX;
         _loc5_.radius = _loc1_ * _phyScale;
         _loc2_ = new b2BodyDef();
         _loc2_.position.x = _loc6_.x * _phyScale;
         _loc2_.position.y = _loc6_.y * _phyScale;
         _loc2_.userData = _loc6_;
         _loc5_.isSensor = false;
         _cueBallBody = _world.CreateBody(_loc2_);
         _cueBallBody.SetLinearVelocity(new b2Vec2(_direction.x * _phyScale * 0.5,_direction.y * _phyScale * 0.5));
         _cueBallBody.CreateShape(_loc5_);
         _cueBallBody.SetMassFromShapes();
         _timeOutTimer = 10;
         _soundMan.playByName(this["_soundNameImp" + (Math.floor(Math.random() * 5) + 1)]);
         _rollSound = _soundMan.playByName(this["_soundNameRoll" + (Math.floor(Math.random() * 4) + 1)]);
      }
      
      private function createCollision() : void
      {
         var _loc11_:* = null;
         var _loc2_:Object = null;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc4_:b2Body = null;
         var _loc13_:String = null;
         var _loc15_:b2PolygonDef = new b2PolygonDef();
         var _loc7_:Object = {};
         var _loc8_:int = 0;
         var _loc1_:b2PolygonDef = new b2PolygonDef();
         var _loc12_:b2BodyDef = new b2BodyDef();
         _loc5_ = Number(_bgContent.innerCollision.x);
         _loc3_ = Number(_bgContent.innerCollision.y);
         _loc13_ = "a";
         while(_loc13_ != "h")
         {
            _loc8_ = 0;
            _loc11_ = _bgContent.innerCollision["v" + _loc13_ + "0"];
            _loc2_ = _bgContent.innerCollision["v" + _loc13_ + "1"];
            while(_loc2_)
            {
               _loc10_ = Math.sqrt((_loc2_.x - _loc11_.x) * (_loc2_.x - _loc11_.x) + (_loc2_.y - _loc11_.y) * (_loc2_.y - _loc11_.y)) / 2;
               _loc7_.x = (_loc2_.x + _loc11_.x) / 2;
               _loc7_.y = (_loc2_.y + _loc11_.y) / 2;
               _loc14_ = Math.atan2(_loc11_.y - _loc2_.y,_loc11_.x - _loc2_.x);
               _loc12_.position.Set((_loc7_.x + _loc5_) * _phyScale,(_loc7_.y + _loc3_) * _phyScale);
               _loc1_.SetAsOrientedBox(_loc10_ * _phyScale,0.5 * _phyScale,new b2Vec2(0,0),_loc14_);
               _loc4_ = _world.CreateBody(_loc12_);
               _loc4_.CreateShape(_loc1_);
               _loc4_.SetMassFromShapes();
               _loc8_++;
               _loc11_ = _loc2_;
               _loc2_ = _bgContent.innerCollision["v" + _loc13_ + (_loc8_ + 1)];
            }
            if(_loc13_ != "g" && _loc13_ != "f")
            {
               _loc2_ = _bgContent.innerCollision["v" + _loc13_ + "0"];
               _loc10_ = Math.sqrt((_loc2_.x - _loc11_.x) * (_loc2_.x - _loc11_.x) + (_loc2_.y - _loc11_.y) * (_loc2_.y - _loc11_.y)) / 2;
               _loc7_.x = (_loc2_.x + _loc11_.x) / 2;
               _loc7_.y = (_loc2_.y + _loc11_.y) / 2;
               _loc14_ = Math.atan2(_loc11_.y - _loc2_.y,_loc11_.x - _loc2_.x);
               _loc12_.position.Set((_loc7_.x + _loc5_) * _phyScale,(_loc7_.y + _loc3_) * _phyScale);
               _loc1_.SetAsOrientedBox(_loc10_ * _phyScale,0.1 * _phyScale,new b2Vec2(0,0),_loc14_);
               _loc4_ = _world.CreateBody(_loc12_);
               _loc4_.CreateShape(_loc1_);
               _loc4_.SetMassFromShapes();
            }
            _loc13_ = String.fromCharCode(_loc13_.charCodeAt(0) + 1);
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         if(!_gameOver && !_pauseGame && !_closeBtn.hitTestPoint(mouseX,mouseY,true))
         {
            _shootState++;
            if(_shootState == 2)
            {
               _loc2_ = (_bgContent.aimArrow.currentFrame - 1) * (_velocityHigh - _velocityLow) * 0.01 + _velocityLow;
               _direction.x = Math.cos((_bgContent.aimArrow.rotation - 90) * 3.141592653589793 / 180) * _loc2_;
               _direction.y = Math.sin((_bgContent.aimArrow.rotation - 90) * 3.141592653589793 / 180) * _loc2_;
               _bgContent.aimArrow.visible = false;
               _startY = _ball.y;
               _hitTestComplete = false;
               _rollSound = _soundMan.playByName(this["_soundNameRoll" + (Math.floor(Math.random() * 4) + 1)]);
               _ball.parent.setChildIndex(_bgContent.skeeBall_ramp,_ball.parent.getChildIndex(_ball) - 1);
            }
         }
      }
      
      private function showGameOver() : void
      {
         _resultsDlg = showDlg("carnival_results",[{
            "name":"button_yes",
            "f":onStart_Yes
         },{
            "name":"button_no",
            "f":onStart_No
         }]);
         _resultsDlg.ticketCounter.earnTickets(_ticketsWon);
         _resultsDlg.messageText.text = _ticketsWon;
         _resultsDlg.x = 450;
         _resultsDlg.y = 275;
         stage.addEventListener("keyDown",onCarnPlayKeyDown);
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("carnival_leaveGame",[{
            "name":"button_yes",
            "f":onStart_No
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function onStart_Yes() : void
      {
         stage.removeEventListener("keyDown",onCarnPlayKeyDown);
         _resultsDlg = null;
         if(_SFX_aj_tickets_Instance)
         {
            _soundMan.stop(_SFX_aj_tickets_Instance);
            _SFX_aj_tickets_Instance = null;
         }
         hideDlg();
         var _loc1_:Array = [];
         _loc1_[0] = "pg";
         MinigameManager.msg(_loc1_);
      }
      
      private function onStart_No() : void
      {
         hideDlg();
         end(null);
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc3_:Object = null;
         if(_gameState != param1)
         {
            switch(param1 - 4)
            {
               case 0:
                  hideDlg();
                  _shootState = 0;
                  _gameOver = false;
                  _numBalls = 10;
                  _bgContent.loadBalls(--_numBalls);
                  _soundMan.playByName(_soundNameBallReload);
                  _score = 0;
                  _bgContent.scoreText.text = "0";
                  _bgContent.highScoreText.text = _highScore.toString();
                  _scoreMultiplier = 1;
                  _bgContent.multiplierText.text = "x" + _scoreMultiplier;
                  _loc3_ = _ball;
                  _loc3_.lastPosX = _loc3_.x;
                  _loc3_.lastPosY = _loc3_.y;
                  _ball.visible = true;
                  _bgContent.aimArrow.visible = true;
                  break;
               case 2:
                  if(_score > _highScore)
                  {
                     _highScore = _score;
                     AchievementXtCommManager.requestSetUserVar(334,_highScore);
                  }
                  _gameOver = true;
                  _ball.visible = false;
                  _bgContent.aimArrow.visible = false;
            }
            _gameState = param1;
         }
      }
      
      private function stepPhysics() : void
      {
         var _loc1_:* = null;
         var _loc6_:b2Body = null;
         var _loc5_:int = 0;
         var _loc2_:Skeeball_CustomContactPoint = null;
         var _loc3_:* = undefined;
         var _loc4_:* = undefined;
         var _loc7_:Object = null;
         _loc5_ = 0;
         while(_loc5_ < 2)
         {
            _world.Step(_timeStep,_iterations);
            while(_contactListener.contactStack.length)
            {
               _loc2_ = _contactListener.contactStack.pop();
               _loc3_ = _loc2_.shape1.GetBody().GetUserData();
               _loc4_ = _loc2_.shape2.GetBody().GetUserData();
               _soundMan.playByName(this["_soundNameImp" + (Math.floor(Math.random() * 5) + 1)]);
               if(_cueBallBody && _cueBallBody.GetLinearVelocity().LengthSquared() < 5)
               {
                  if(_rollSound)
                  {
                     _rollSound.stop();
                  }
                  _rollSound = _soundMan.playByName(this["_soundNameRoll" + (Math.floor(Math.random() * 4) + 1)]);
               }
            }
            _loc5_++;
         }
         _loc1_ = _world.GetBodyList();
         while(_loc1_)
         {
            _loc6_ = _loc1_.m_next;
            if(!_loc1_.IsStatic() && _loc1_.GetUserData() is Object)
            {
               _loc7_ = _loc1_.GetUserData();
               _loc7_.x = _loc1_.GetPosition().x / _phyScale;
               _loc7_.y = _loc1_.GetPosition().y / _phyScale;
            }
            _loc1_ = _loc6_;
         }
      }
      
      private function getLeftX() : Number
      {
         if(_ball.y > 255)
         {
            return 265 + (483 - _ball.y) * 0.2632;
         }
         return 325 + (255 - _ball.y) * 0.1538;
      }
      
      private function getRightX() : Number
      {
         if(_ball.y > 255)
         {
            return 627 - (483 - _ball.y) * 0.25;
         }
         return 571 - (255 - _ball.y) * 0.1357;
      }
      
      private function preCheckHoles() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc1_:Object = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         _loc3_ = 5;
         while(_loc3_ <= 7)
         {
            if(_loc3_ == 5)
            {
               _loc2_ = (_ball.x - _bgContent["hole" + _loc3_].x) * (_ball.x - _bgContent["hole" + _loc3_].x) + (_ball.y - _bgContent["hole" + _loc3_].y + 5) * (_ball.y - _bgContent["hole" + _loc3_].y + 5);
            }
            else
            {
               _loc2_ = (_ball.x - _bgContent["hole" + _loc3_].x) * (_ball.x - _bgContent["hole" + _loc3_].x) + (_ball.y - _bgContent["hole" + _loc3_].y + 5) * (_ball.y - _bgContent["hole" + _loc3_].y + 5);
            }
            _loc1_ = _bgContent["hole" + _loc3_];
            if(_loc3_ == 5 && _loc2_ < 150 || _loc2_ < 270)
            {
               _loc1_.ballDrop();
               if(_bonusHole == _loc1_)
               {
                  _scoreMultiplier++;
                  _bgContent.multiplierText.text = "x" + _scoreMultiplier;
                  _soundMan.playByName(_soundNameStingerGold);
               }
               else
               {
                  _soundMan.playByName(_soundNameStinger4);
               }
               _soundMan.playByName(_soundNameHoleImp);
               _loc4_ = 250;
               _score += _loc4_ * _scoreMultiplier;
               doScorePopup(_loc1_.x + _loc1_.parent.x,_loc1_.y + _loc1_.parent.y,_loc4_);
               _bgContent.scoreText.text = _score.toString();
               chooseGlowHole();
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      private function doScorePopup(param1:Number, param2:Number, param3:int) : void
      {
         if(_scoreMultiplier > 1)
         {
            _scorePopup.combo.gotoAndStop("multi");
            _scorePopup.combo.comboNum.text = param3.toString() + " x " + _scoreMultiplier.toString();
         }
         else
         {
            _scorePopup.combo.gotoAndStop("single");
            _scorePopup.combo.comboNum.text = param3.toString();
         }
         _scorePopup.x = param1;
         _scorePopup.y = param2;
         _scorePopup.gotoAndPlay("on");
      }
      
      private function chooseGlowHole() : void
      {
         setGlowHole(false);
         _currentBonus += Math.floor(Math.random() * 6) + 1;
         if(_currentBonus > 7)
         {
            _currentBonus -= 7;
         }
         if(_currentBonus == 1)
         {
            _bonusHole = _bgContent.slidingHole.hole1;
         }
         else
         {
            _bonusHole = _bgContent["hole" + _currentBonus];
         }
         setGlowHole(true);
      }
      
      private function checkHoles() : Boolean
      {
         var _loc2_:Number = NaN;
         var _loc1_:Object = null;
         var _loc5_:int = 0;
         var _loc4_:String = null;
         var _loc3_:int = 0;
         _loc3_ = 1;
         while(_loc3_ <= 4)
         {
            if(_loc3_ == 1)
            {
               _loc2_ = (_ball.x - _bgContent.slidingHole.hole1.x - _bgContent.slidingHole.x) * (_ball.x - _bgContent.slidingHole.hole1.x - _bgContent.slidingHole.x) + (_ball.y - _bgContent.slidingHole.hole1.y - _bgContent.slidingHole.y) * (_ball.y - _bgContent.slidingHole.hole1.y - _bgContent.slidingHole.y);
               _loc1_ = _bgContent.slidingHole.hole1;
               _loc5_ = 300;
               _loc4_ = _soundNameStinger5;
            }
            else
            {
               _loc2_ = (_ball.x - _bgContent["hole" + _loc3_].x) * (_ball.x - _bgContent["hole" + _loc3_].x) + (_ball.y - _bgContent["hole" + _loc3_].y) * (_ball.y - _bgContent["hole" + _loc3_].y);
               _loc1_ = _bgContent["hole" + _loc3_];
               if(_loc3_ == 2)
               {
                  _loc5_ = 25;
                  _loc4_ = _soundNameStinger1;
               }
               else if(_loc3_ == 3)
               {
                  _loc5_ = 50;
                  _loc4_ = _soundNameStinger2;
               }
               else
               {
                  _loc5_ = 100;
                  _loc4_ = _soundNameStinger3;
               }
            }
            if(_loc2_ < 100)
            {
               _loc1_.ballDrop();
               if(_bonusHole == _loc1_)
               {
                  _scoreMultiplier++;
                  _bgContent.multiplierText.text = "x" + _scoreMultiplier;
                  _soundMan.playByName(_soundNameStingerGold);
               }
               else
               {
                  _soundMan.playByName(_loc4_);
               }
               _soundMan.playByName(_soundNameHoleImp);
               _score += _loc5_ * _scoreMultiplier;
               doScorePopup(_loc1_.x + _loc1_.parent.x,_loc1_.y + _loc1_.parent.y,_loc5_);
               _bgContent.scoreText.text = _score.toString();
               chooseGlowHole();
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc10_:Object = null;
         var _loc6_:Number = NaN;
         var _loc9_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc5_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc4_:MovieClip = null;
         if(_sceneLoaded)
         {
            if(_serverStarted)
            {
               _frameTime = (getTimer() - _lastTime) / 1000;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
               _gameTime += _frameTime;
               if(_resultsDlg != null)
               {
                  if(_resultsDlg.ticketCounter.ticketState == 0)
                  {
                     if(_SFX_aj_tickets_Instance)
                     {
                        _soundMan.stop(_SFX_aj_tickets_Instance);
                        _SFX_aj_tickets_Instance = null;
                     }
                  }
                  else if(_SFX_aj_tickets_Instance == null)
                  {
                     _SFX_aj_tickets_Instance = _soundMan.play(SFX_aj_tickets,0,99999);
                  }
               }
               if(_gameState == 4 && !_gameOver)
               {
                  stepPhysics();
                  _loc9_ = _bgContent.aimArrow;
                  if(_shootState == 0)
                  {
                     _loc9_.rotation += _arrowMeterDirection * _arrowRotSpeed * _frameTime;
                     if(_loc9_.rotation > 45)
                     {
                        _arrowMeterDirection *= -1;
                        _loc9_.rotation = 90 - _loc9_.rotation;
                     }
                     else if(_loc9_.rotation < -45)
                     {
                        _arrowMeterDirection *= -1;
                        _loc9_.rotation = -_loc9_.rotation - 90;
                     }
                  }
                  else if(_shootState == 1)
                  {
                     _loc3_ = _loc9_.currentFrame + Math.floor(_arrowMeterDirection * _arrowColorSpeed * _frameTime);
                     if(_loc3_ >= 101)
                     {
                        _loc9_.gotoAndStop(202 - _loc3_);
                        _arrowMeterDirection *= -1;
                     }
                     else if(_loc3_ <= 1)
                     {
                        _loc9_.gotoAndStop(2 - _loc3_);
                        _arrowMeterDirection *= -1;
                     }
                     else
                     {
                        _loc9_.gotoAndStop(_loc3_);
                     }
                  }
                  else
                  {
                     _loc10_ = _ball;
                     _loc5_ = _loc10_.texture.width * 0.5;
                     _loc11_ = _loc10_.marble.width * 0.5;
                     _loc10_.texture.x += _loc10_.x - _loc10_.lastPosX;
                     _loc10_.texture.y += _loc10_.y - _loc10_.lastPosY;
                     if(_loc10_.texture.x > _loc5_ - _loc11_)
                     {
                        _loc10_.texture.x -= _loc5_;
                     }
                     if(_loc10_.texture.x < _loc11_ - _loc5_)
                     {
                        _loc10_.texture.x += _loc5_;
                     }
                     if(_loc10_.texture.y > _loc5_ - _loc11_)
                     {
                        _loc10_.texture.y -= _loc5_;
                     }
                     if(_loc10_.texture.y < _loc11_ - _loc5_)
                     {
                        _loc10_.texture.y += _loc5_;
                     }
                     _loc10_.lastPosX = _loc10_.x;
                     _loc10_.lastPosY = _loc10_.y;
                     if(_cueBallBody == null)
                     {
                        _loc8_ = _ball.y;
                        _ball.x += _direction.x * _frameTime;
                        _ball.y += _direction.y * _frameTime;
                        _ball.scaleX = _ball.scaleY = 1.6923 - (_startY - Math.max(_ball.y,300)) / 180;
                        if(_ball.x < getLeftX())
                        {
                           _ball.x = getLeftX();
                           _direction.x *= -1;
                           _soundMan.playByName(this["_soundNameLaunch" + (Math.floor(Math.random() * 3) + 1)]);
                        }
                        else if(_ball.x > getRightX())
                        {
                           _ball.x = getRightX();
                           _direction.x *= -1;
                           _soundMan.playByName(this["_soundNameLaunch" + (Math.floor(Math.random() * 3) + 1)]);
                        }
                        if(_loc8_ > 255 && _ball.y <= 255)
                        {
                           _direction.y *= 1.7;
                           _direction.y = Math.min(_direction.y,-250);
                           if(_rollSound)
                           {
                              _rollSound.stop();
                              _rollSound = null;
                           }
                           _soundMan.playByName(this["_soundNameLaunch" + (Math.floor(Math.random() * 3) + 1)]);
                        }
                        else if(_ball.y <= 255)
                        {
                           _direction.y += 800 * _frameTime;
                           if(_direction.y >= -10 || _ball.y < 34)
                           {
                              if(_ball.y < 34)
                              {
                                 _ball.y = 34;
                              }
                              if(preCheckHoles())
                              {
                                 _shootState = 0;
                                 _loc9_.gotoAndStop(1);
                                 _bgContent.aimArrow.visible = true;
                                 _ball.scaleX = _ball.scaleY = 1.7;
                                 _ball.x = _bgContent.aimArrow.x;
                                 _ball.y = 483;
                                 _ball.parent.setChildIndex(_ball,_ball.parent.numChildren - 1);
                                 _ball.texture.x = _startTextureX;
                                 _ball.texture.y = _startTextureY;
                                 _loc10_ = _ball;
                                 _loc10_.lastPosX = _loc10_.x;
                                 _loc10_.lastPosY = _loc10_.y;
                                 if(_numBalls == 0)
                                 {
                                    doGameOver();
                                 }
                                 else
                                 {
                                    _bgContent.loadBalls(--_numBalls);
                                    if(_numBalls < 3)
                                    {
                                       if(_numBalls == 2)
                                       {
                                          _soundMan.playByName(_soundNameBallOnBall1);
                                       }
                                    }
                                    else
                                    {
                                       _soundMan.playByName(_soundNameBallReload);
                                    }
                                 }
                              }
                              else
                              {
                                 createPhysicsBall();
                                 _ball.parent.setChildIndex(_bgContent.skeeBall_ramp,_ball.parent.numChildren - 1);
                              }
                           }
                        }
                     }
                     else
                     {
                        if(!_hitTestComplete)
                        {
                           _loc4_ = _bgContent.hitTest_center;
                           if(_loc4_.hitTestPoint(_ball.x,_ball.y,true))
                           {
                              _hitTestComplete = true;
                              _ball.parent.setChildIndex(_bgContent.ringf4,0);
                              _ball.parent.setChildIndex(_bgContent.ringb3,1);
                              _ball.parent.setChildIndex(_ball,2);
                              _ball.parent.setChildIndex(_bgContent.ringb4,3);
                              _ball.parent.setChildIndex(_bgContent.ringf3,4);
                           }
                           _loc4_ = _bgContent.hitTest_middle;
                           if(_loc4_.hitTestPoint(_ball.x,_ball.y,true))
                           {
                              _hitTestComplete = true;
                              _ball.parent.setChildIndex(_bgContent.ringf3,0);
                              _ball.parent.setChildIndex(_bgContent.ringb2,1);
                              _ball.parent.setChildIndex(_ball,2);
                              _ball.parent.setChildIndex(_bgContent.ringb3,3);
                              _ball.parent.setChildIndex(_bgContent.ringf2,4);
                           }
                           _loc4_ = _bgContent.hitTest_outer;
                           if(_loc4_.hitTestPoint(_ball.x,_ball.y,true))
                           {
                              _hitTestComplete = true;
                              _ball.parent.setChildIndex(_bgContent.ringf2,0);
                              _ball.parent.setChildIndex(_bgContent.ringb1,1);
                              _ball.parent.setChildIndex(_ball,2);
                              _ball.parent.setChildIndex(_bgContent.ringb2,3);
                              _ball.parent.setChildIndex(_bgContent.ringf1,4);
                           }
                           if(!_hitTestComplete)
                           {
                              _hitTestComplete = true;
                              _ball.parent.setChildIndex(_bgContent.ringf5,0);
                              _ball.parent.setChildIndex(_bgContent.ringf6,1);
                              _ball.parent.setChildIndex(_ball,2);
                              _ball.parent.setChildIndex(_bgContent.ringb5,3);
                              _ball.parent.setChildIndex(_bgContent.ringb6,4);
                           }
                        }
                        _timeOutTimer -= _frameTime;
                        if(checkHoles() || _ball.y > 230 || _timeOutTimer <= 0)
                        {
                           _world.DestroyBody(_cueBallBody);
                           _cueBallBody = null;
                           _shootState = 0;
                           _loc9_.gotoAndStop(1);
                           _bgContent.aimArrow.visible = true;
                           if(_rollSound)
                           {
                              _rollSound.stop();
                              _rollSound = null;
                           }
                           if(_ball.y > 230)
                           {
                              _soundMan.playByName(_soundNameStinger0);
                              chooseGlowHole();
                              _score += 10 * _scoreMultiplier;
                              doScorePopup(_ball.x,_ball.y,10);
                              _bgContent.scoreText.text = _score.toString();
                           }
                           _ball.scaleX = _ball.scaleY = 1.6923;
                           _ball.x = _bgContent.aimArrow.x;
                           _ball.y = 483;
                           _ball.parent.setChildIndex(_ball,_ball.parent.numChildren - 1);
                           _ball.texture.x = _startTextureX;
                           _ball.texture.y = _startTextureY;
                           _loc10_ = _ball;
                           _loc10_.lastPosX = _loc10_.x;
                           _loc10_.lastPosY = _loc10_.y;
                           if(_numBalls == 0)
                           {
                              doGameOver();
                           }
                           else
                           {
                              _bgContent.loadBalls(--_numBalls);
                              if(_numBalls < 3)
                              {
                                 if(_numBalls == 2)
                                 {
                                    _soundMan.playByName(_soundNameBallOnBall1);
                                 }
                              }
                              else
                              {
                                 _soundMan.playByName(_soundNameBallReload);
                              }
                           }
                        }
                     }
                  }
               }
               else if(_gameState == 6)
               {
               }
            }
         }
      }
   }
}

