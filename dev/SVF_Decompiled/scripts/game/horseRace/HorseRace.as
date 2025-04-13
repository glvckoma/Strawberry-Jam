package game.horseRace
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import collection.IitemCollection;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class HorseRace extends GameBase implements IMinigame
   {
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MAX_PLAYERS:int = 6;
      
      private static const STATE_LOADING_ASSETS:int = 0;
      
      private static const STATE_LOADING_ITEMLISTS:int = 1;
      
      private static const STATE_WAITING_FOR_START:int = 2;
      
      private static const STATE_RACE_INTRO:int = 3;
      
      private static const STATE_WAITING_FOR_INTRO_COMPLETE:int = 4;
      
      public static const STATE_RACING:int = 5;
      
      private static const STATE_RACE_RESULTS:int = 7;
      
      private static const ACCESSORY_LIST_LAND:int = 49;
      
      public var _proMode:int;
      
      public var _gameState:int = 0;
      
      private var _horseRaceData:HorseRaceData;
      
      private var _displayAchievementTimer:Number;
      
      public var _myId:uint;
      
      public var _pIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _availableItems:Array;
      
      public var _availableItemColors:Array;
      
      public var _layerBackgroundGround:Sprite;
      
      public var _layerMidGUI:Sprite;
      
      public var _layerLaneTextures:Sprite;
      
      public var _layerHurdles:Sprite;
      
      public var _layerPlayerMarker:Sprite;
      
      public var _layerPlayerMarkers:Array;
      
      public var _layerPlayer:Sprite;
      
      public var _layerPlayers:Array;
      
      public var _layerAIPlayers:Array;
      
      private var _lastTime:Number;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _gameRandomizer:RandomSeed;
      
      public var _raceRandomizer:RandomSeed;
      
      private var _numPlayers:uint;
      
      private var _newPlayersJoined:Boolean = false;
      
      private var _aiplayers:Array;
      
      private var _players:Array;
      
      public var _myPlayer:HorseRacePlayer;
      
      private var _trackPositions:Array;
      
      public var _theHurdles:Array;
      
      private var _nextHurdleIndex:int;
      
      private var _hurdleClones:Array;
      
      public var _trackTiles:HorseRaceLaneTexture;
      
      public var _aiProfileHard:HorseRaceAIProfile = new HorseRaceAIProfile(90,0.5,50);
      
      public var _aiProfileMed:HorseRaceAIProfile = new HorseRaceAIProfile(75,1,100);
      
      public var _aiProfileEasy:HorseRaceAIProfile = new HorseRaceAIProfile(60,1,150);
      
      public var _aiProfiles:Array = [_aiProfileMed,_aiProfileMed,_aiProfileHard,_aiProfileMed,_aiProfileEasy,_aiProfileHard];
      
      public var _boostButton:MovieClip;
      
      private var _jumpButtonDown:Boolean;
      
      private var _gameGUI:Object;
      
      public var _startingLineX:int;
      
      public var _waitingPopup:MovieClip;
      
      public var _countdownTimer:Number;
      
      public var _lastEmoteTimer:Number;
      
      public var _raceResultsTimer:Number;
      
      public var _trackLength:int;
      
      public var _debugText:TextField;
      
      public var _totalConsecutiveWins:int;
      
      private var _gemsEarned:int;
      
      private var _resultsPopup:MovieClip;
      
      public var _factsOrder:Array;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _factImageMediaObject:MovieClip;
      
      private var _surfaceSoundDefault:int;
      
      private var _surfaceSoundSplash:int;
      
      public var _soundMan:SoundManager;
      
      public var _SFX_Music:SBMusic;
      
      public var _SFX_StartMusic:SBMusic;
      
      public var _SFX_EndMusic:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public var _jumpSounds:Array;
      
      public var _whineSounds:Array;
      
      public var _soundNameHorseJump1:String;
      
      public var _soundNameHorseJump2:String;
      
      public var _soundNameHorseJump3:String;
      
      public var _soundNameHorseTurbo:String;
      
      public var _soundNameHorseWhine1:String;
      
      public var _soundNameHorseWhine2:String;
      
      public var _soundNameHorseWhine3:String;
      
      public var _soundNameHorseWhine4:String;
      
      public var _soundNamePopUp:String;
      
      public var _soundNameHoovesHay:String;
      
      public var _soundNameHoovesMud:String;
      
      public var _soundNameHoovesWater:String;
      
      public var _soundNameHoovesWeeds:String;
      
      public var _soundNameHorse1:String;
      
      public var _soundNameHorse2:String;
      
      public var _soundNameHorse3:String;
      
      public var _soundNamePopUpReadySet:String;
      
      public var _soundNamePopUpGo:String;
      
      public function HorseRace()
      {
         super();
         _displayAchievementTimer = 0;
         _horseRaceData = new HorseRaceData();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_mus_horseRaceLP",0.35);
         _SFX_StartMusic = _soundMan.addStream("aj_musStingerRaceIntro",0.35);
         _SFX_EndMusic = _soundMan.addStream("aj_musStingerRaceOver",0.2);
         _soundNameHorseJump1 = _horseRaceData._audio[0];
         _soundNameHorseJump2 = _horseRaceData._audio[1];
         _soundNameHorseJump3 = _horseRaceData._audio[2];
         _soundNameHorseTurbo = _horseRaceData._audio[3];
         _soundNameHorseWhine1 = _horseRaceData._audio[4];
         _soundNameHorseWhine2 = _horseRaceData._audio[5];
         _soundNameHorseWhine3 = _horseRaceData._audio[6];
         _soundNameHorseWhine4 = _horseRaceData._audio[7];
         _soundNamePopUp = _horseRaceData._audio[8];
         _soundNameHoovesHay = _horseRaceData._audio[9];
         _soundNameHoovesMud = _horseRaceData._audio[10];
         _soundNameHoovesWater = _horseRaceData._audio[11];
         _soundNameHoovesWeeds = _horseRaceData._audio[12];
         _soundNameHorse1 = _horseRaceData._audio[13];
         _soundNameHorse2 = _horseRaceData._audio[14];
         _soundNameHorse3 = _horseRaceData._audio[15];
         _soundNamePopUpReadySet = _horseRaceData._audio[16];
         _soundNamePopUpGo = _horseRaceData._audio[17];
         _jumpSounds = new Array(_soundNameHorseJump1,_soundNameHorseJump2,_soundNameHorseJump3);
         _whineSounds = new Array(_soundNameHorseWhine1,_soundNameHorseWhine2,_soundNameHorseWhine3,_soundNameHorseWhine4);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseJump1],_soundNameHorseJump1,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseJump2],_soundNameHorseJump2,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseJump3],_soundNameHorseJump3,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseTurbo],_soundNameHorseTurbo,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseWhine1],_soundNameHorseWhine1,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseWhine2],_soundNameHorseWhine2,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseWhine3],_soundNameHorseWhine3,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHorseWhine4],_soundNameHorseWhine4,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUp],_soundNamePopUp,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHoovesHay],_soundNameHoovesHay,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHoovesMud],_soundNameHoovesMud,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHoovesWater],_soundNameHoovesWater,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHoovesWeeds],_soundNameHoovesWeeds,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameHorse1],_soundNameHorse1,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameHorse2],_soundNameHorse2,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameHorse3],_soundNameHorse3,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpReadySet],_soundNamePopUpReadySet,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNamePopUpGo],_soundNamePopUpGo,0.25);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         _myId = param1;
         _pIDs = param2;
         _numPlayers = param2.length;
         init();
      }
      
      public function end(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         while(_players.length > 0)
         {
            if(_players[0] != null)
            {
               _players[0].remove();
            }
            _players.splice(0,1);
         }
         while(_aiplayers.length > 0)
         {
            if(_aiplayers[0] != null)
            {
               _aiplayers[0].remove();
            }
            _aiplayers.splice(0,1);
         }
         releaseBase();
         _bInit = false;
         _loc2_ = 0;
         while(_loc2_ < _availableItems.length)
         {
            if(_availableItems[_loc2_])
            {
               _availableItems[_loc2_].destroy();
               _availableItems[_loc2_] = null;
            }
            _loc2_++;
         }
         removeLayer(_layerMidGUI);
         removeLayer(_layerBackgroundGround);
         removeLayer(_layerLaneTextures);
         removeLayer(_layerHurdles);
         removeLayer(_layerPlayer);
         removeLayer(_layerPlayerMarker);
         removeLayer(_guiLayer);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("mouseDown",mouseHandleDown);
         MinigameManager.leave();
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = undefined;
         var _loc5_:Number = param1.length - 1;
         _loc4_ = 0;
         while(_loc4_ < _loc5_)
         {
            _loc2_ = Math.round(Math.random() * _loc5_);
            _loc3_ = param1[_loc4_];
            param1[_loc4_] = param1[_loc2_];
            param1[_loc2_] = _loc3_;
            _loc4_++;
         }
         return param1;
      }
      
      private function init() : void
      {
         var _loc1_:int = 0;
         _gemsEarned = 0;
         _jumpButtonDown = false;
         _lastEmoteTimer = 0;
         _displayAchievementTimer = 0;
         _totalConsecutiveWins = 0;
         _factsOrder = [];
         _loc1_ = 0;
         while(_loc1_ < _horseRaceData._facts.length)
         {
            _factsOrder.push(_loc1_);
            _loc1_++;
         }
         _factsOrder = randomizeArray(_factsOrder);
         _factsIndex = 0;
         _surfaceSoundDefault = 0;
         _surfaceSoundSplash = 0;
         if(!_bInit)
         {
            _factImageMediaObject = null;
            _mediaObjectHelper = null;
            _loadingImage = false;
            _resultsPopup = null;
            _layerMidGUI = new Sprite();
            _layerBackgroundGround = new Sprite();
            _layerLaneTextures = new Sprite();
            _layerHurdles = new Sprite();
            _layerPlayer = new Sprite();
            _layerPlayerMarker = new Sprite();
            _layerPlayerMarkers = new Array(6);
            _layerPlayers = new Array(6);
            _layerAIPlayers = new Array(6);
            _loc1_ = 0;
            while(_loc1_ < 6)
            {
               _layerPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerPlayers[_loc1_]);
               _layerAIPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerAIPlayers[_loc1_]);
               _loc1_++;
            }
            if(_numPlayers <= 0 || _numPlayers > 6)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            _layerMidGUI.mouseEnabled = true;
            _layerBackgroundGround.mouseEnabled = false;
            _layerHurdles.mouseEnabled = false;
            _layerLaneTextures.mouseEnabled = false;
            _layerPlayer.mouseEnabled = false;
            _layerPlayerMarker.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBackgroundGround);
            addChild(_layerLaneTextures);
            addChild(_layerPlayerMarker);
            addChild(_layerHurdles);
            addChild(_layerMidGUI);
            addChild(_layerPlayer);
            addChild(_guiLayer);
            _aiplayers = new Array(6);
            _players = new Array(6);
            loadScene("HorseRace/room_main.xroom",_horseRaceData._audio);
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
            _mediaObjectHelper.init(_horseRaceData._facts[_factsOrder[_factsIndex]].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         if(_factImageMediaObject != null && _resultsPopup)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
         }
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
         if(_resultsPopup)
         {
            _resultsPopup.result_pic.addChild(_factImageMediaObject);
         }
         _loadingImage = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc3_ = 0;
         while(_loc3_ < 6)
         {
            _layerPlayerMarkers[_loc3_] = GETDEFINITIONBYNAME("HorseRace_playerMarker");
            _layerPlayerMarker.addChild(_layerPlayerMarkers[_loc3_]);
            _loc3_++;
         }
         _loc4_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _loc4_ = _scene.getLayer("horseRace_boost");
         _boostButton = addBtn("HorseRace_boost",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onBoostButton);
         _boostButton.visible = false;
         _loc4_ = _scene.getLayer("horseRace_emoButton_cool");
         addBtn("HorseRace_emoButton_cool",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteCoolButton);
         _loc4_ = _scene.getLayer("horseRace_emoButton_sneaky");
         addBtn("HorseRace_emoButton_sneaky",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteSneakyButton);
         _loc4_ = _scene.getLayer("horseRace_emoButton_wink");
         addBtn("HorseRace_emoButton_wink",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteWinkButton);
         _loc4_ = _scene.getLayer("horseRace_emoButton_tongue");
         addBtn("HorseRace_emoButton_tongue",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteTongueButton);
         _loc4_ = _scene.getLayer("horseRace_emoButton_surprise");
         addBtn("HorseRace_emoButton_surprise",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteSurpriseButton);
         _loc4_ = _scene.getLayer("horseRace_emoButton_sleep");
         addBtn("HorseRace_emoButton_sleep",_loc4_.x + _loc4_.width / 2,_loc4_.y + _loc4_.height / 2,onEmoteSleepButton);
         _trackPositions = [];
         _loc4_ = _scene.getLayer("track");
         _trackTiles = new HorseRaceLaneTexture(this,"HorseRace_GroundTile",0,4,0,0,400);
         _trackTiles.reset();
         updateTrack(0);
         _trackPositions.push(_loc4_.loader.content.lane1.y);
         _trackPositions.push(_loc4_.loader.content.lane2.y);
         _trackPositions.push(_loc4_.loader.content.lane3.y);
         _trackPositions.push(_loc4_.loader.content.lane4.y);
         _trackPositions.push(_loc4_.loader.content.lane5.y);
         _trackPositions.push(_loc4_.loader.content.lane6.y);
         _layerBackgroundGround.addChild(_loc4_.loader.content);
         _sceneLoaded = true;
         _hurdleClones = [];
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseDown",mouseHandleDown);
         _waitingPopup = GETDEFINITIONBYNAME("horseRace_waiting");
         _waitingPopup.x = 450;
         _waitingPopup.y = 275;
         _guiLayer.addChild(_waitingPopup);
         _waitingPopup.gotoAndPlay("waiting");
         startGame();
         super.sceneLoaded(param1);
      }
      
      public function message(param1:Array) : void
      {
         var _loc6_:* = 0;
         var _loc16_:int = 0;
         var _loc18_:int = 0;
         var _loc17_:int = 0;
         var _loc3_:int = 0;
         var _loc28_:int = 0;
         var _loc14_:int = 0;
         var _loc2_:* = 0;
         var _loc5_:* = false;
         var _loc26_:Number = NaN;
         var _loc4_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc13_:int = 0;
         var _loc24_:int = 0;
         var _loc27_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc21_:int = 0;
         var _loc25_:String = null;
         var _loc20_:String = null;
         var _loc22_:int = 0;
         var _loc12_:int = 0;
         var _loc15_:int = 0;
         var _loc19_:int = 0;
         var _loc23_:int = 0;
         if(param1[0] == "ml")
         {
            _loc18_ = int(param1[2]);
            if(_players[_loc18_])
            {
               if(_gameState == 3 || _gameState == 4 || _gameState == 5)
               {
                  playerLeftGame(_loc18_);
               }
               else
               {
                  _players[_loc18_].remove();
               }
               _players[_loc18_] = null;
            }
            _numPlayers--;
         }
         else if(param1[0] == "ms")
         {
            _loc16_ = 1;
            _loc14_ = 0;
            _proMode = parseInt(param1[_loc16_++]);
            _loc2_ = parseInt(param1[_loc16_++]);
            _startingLineX = parseInt(param1[_loc16_++]);
            _gameRandomizer = new RandomSeed(_loc2_);
            _loc14_ = 0;
            while(_loc14_ < _numPlayers)
            {
               _loc5_ = param1[_loc16_++] == _myId;
               _loc18_ = int(param1[_loc16_++]);
               _players[_loc18_] = new HorseRacePlayer(this);
               _players[_loc18_].setupHumanPlayer(_loc18_,_loc5_,param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++],param1[_loc16_++]);
               if(_loc5_)
               {
                  _myPlayer = _players[_loc18_];
               }
               _newPlayersJoined = true;
               _loc14_++;
            }
            _loc26_ = Number(param1[_loc16_++]);
            _loc4_ = int(param1[_loc16_++]);
            _loc14_ = 0;
            while(_loc14_ < _loc4_)
            {
               _aiplayers[_loc14_] = new HorseRacePlayer(this);
               _aiplayers[_loc14_].setupAIPlayer(_gameRandomizer.integer(9999999),_loc14_,_startingLineX,param1[_loc16_++]);
               _loc14_++;
            }
         }
         else if(param1[0] == "mm")
         {
            _loc16_ = 3;
            if(param1[2] == "ex")
            {
               hideDlg();
               _loc10_ = showDlg("horseRace_error",[{
                  "name":"exitButton",
                  "f":onErrorExit
               }]);
               _loc10_.x = 450;
               _loc10_.y = 275;
            }
            else if(param1[2] == "uj")
            {
               _numPlayers = param1[_loc16_++];
               _loc13_ = 0;
               while(_loc13_ < _numPlayers)
               {
                  _loc18_ = int(param1[_loc16_++]);
                  _loc24_ = int(param1[_loc16_++]);
                  _loc27_ = int(param1[_loc16_++]);
                  _loc8_ = int(param1[_loc16_++]);
                  _loc9_ = int(param1[_loc16_++]);
                  _loc7_ = int(param1[_loc16_++]);
                  _loc21_ = int(param1[_loc16_++]);
                  _loc25_ = param1[_loc16_++];
                  _loc20_ = param1[_loc16_++];
                  _loc22_ = int(param1[_loc16_++]);
                  if(_players[_loc18_] == null)
                  {
                     _players[_loc18_] = new HorseRacePlayer(this);
                     _players[_loc18_].setupHumanPlayer(_loc18_,false,_loc24_,_loc27_,_loc8_,_loc9_,_loc7_,_loc21_,_loc25_,_loc20_,_loc22_);
                     _newPlayersJoined = true;
                  }
                  _loc13_++;
               }
            }
            else if(param1[2] == "boo")
            {
               _loc6_ = uint(int(param1[_loc16_++]));
               if(_loc6_ < 6 && _players[_loc6_] != null)
               {
                  _players[_loc6_].boost(true);
               }
            }
            else if(param1[2] == "jump")
            {
               _loc6_ = uint(int(param1[_loc16_++]));
               if(_loc6_ < 6 && _players[_loc6_] != null)
               {
                  _players[_loc6_].jump();
               }
            }
            else if(param1[2] == "pos")
            {
               _loc6_ = uint(int(param1[_loc16_++]));
               if(_loc6_ < 6 && _players[_loc6_] != null)
               {
                  _players[_loc6_].receivePositionData(int(param1[_loc16_++]),int(param1[_loc16_++]),int(param1[_loc16_++]));
               }
            }
            else if(param1[2] == "cs")
            {
               _layerPlayerMarkers[_myPlayer._trackLane].pMarkerArrows();
               _soundMan.playByName(_soundNamePopUpReadySet);
               _waitingPopup.gotoAndPlay("ready");
               _countdownTimer = 1.5;
            }
            else if(param1[2] == "em")
            {
               if(_myPlayer != null && param1[4] != _myPlayer._playerID)
               {
                  _loc17_ = 0;
                  while(_loc17_ < _players.length)
                  {
                     if(_players[_loc17_] != null && _players[_loc17_]._playerID == param1[4])
                     {
                        _players[_loc17_].showEmote(param1[3]);
                        break;
                     }
                     _loc17_++;
                  }
               }
            }
            else if(param1[2] == "ri")
            {
               _loc12_ = int(param1[_loc16_++]);
               _loc3_ = int(param1[_loc16_++]);
               _boostButton.carrots(3);
               _raceRandomizer = new RandomSeed(_loc12_);
               _loc17_ = 0;
               while(_loc17_ < _aiplayers.length)
               {
                  _aiplayers[_loc17_].setAIRaceRanomizer(_raceRandomizer.integer(9999999));
                  _aiplayers[_loc17_]._trackLayer.visible = false;
                  _loc17_++;
               }
               _loc15_ = 2;
               _loc17_ = 0;
               while(_loc17_ < _loc3_)
               {
                  _loc28_ = int(param1[_loc16_++]);
                  if(_players[_loc28_] != null)
                  {
                     if(_gameState == 7)
                     {
                        _players[_loc28_].prepareForStart(_startingLineX);
                     }
                     _players[_loc28_]._laneMarkerIndex = _players[_loc28_] == _myPlayer ? 1 : _loc15_++;
                  }
                  _loc17_++;
               }
               _loc17_ = 0;
               while(_loc17_ < _aiplayers.length)
               {
                  if(_players[_loc17_] == null || _players[_loc17_]._trackLayer == null || _players[_loc17_]._trackLayer.visible == false)
                  {
                     _aiplayers[_loc17_].prepareForStart(_startingLineX);
                     _aiplayers[_loc17_]._laneMarkerIndex = _loc15_++;
                  }
                  _loc17_++;
               }
               setGameState(3);
            }
            else if(param1[2] == "rs")
            {
               _boostButton.visible = true;
               if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  AchievementXtCommManager.requestSetUserVar(327,1);
               }
               _loc17_ = 0;
               while(_loc17_ < _players.length)
               {
                  if(_players[_loc17_] != null)
                  {
                     _players[_loc17_].start();
                  }
                  _loc17_++;
               }
               _loc17_ = 0;
               while(_loc17_ < _aiplayers.length)
               {
                  if(_aiplayers[_loc17_]._trackLayer.visible)
                  {
                     _aiplayers[_loc17_].start();
                  }
                  _loc17_++;
               }
               setGameState(5);
            }
            else if(param1[2] == "rr")
            {
               _raceResultsTimer = param1[_loc16_++];
               _raceResultsTimer += 1;
               _loc3_ = int(param1[_loc16_++]);
               _loc17_ = 0;
               while(_loc17_ < 6)
               {
                  _loc19_ = int(param1[_loc16_++]);
                  _aiplayers[_loc19_]._finishPlace = param1[_loc16_++];
                  if(_aiplayers[_loc19_]._finishPlace < 1 || _aiplayers[_loc19_]._finishPlace > 6)
                  {
                     _aiplayers[_loc19_]._finishPlace = 6;
                  }
                  _loc17_++;
               }
               _loc17_ = 0;
               while(_loc17_ < _loc3_)
               {
                  _loc6_ = uint(int(param1[_loc16_++]));
                  _loc23_ = int(param1[_loc16_++]);
                  if(_loc6_ < 6 && _players[_loc6_] != null)
                  {
                     _players[_loc6_]._finishPlace = _loc23_;
                     if(_players[_loc6_]._finishPlace < 1 || _players[_loc6_]._finishPlace > 6)
                     {
                        _players[_loc6_]._finishPlace = 6;
                     }
                  }
                  _loc17_++;
               }
               setGameState(7);
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc5_:HorseRacePlayer = null;
         var _loc3_:Boolean = false;
         var _loc6_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_lastEmoteTimer > 0)
            {
               _lastEmoteTimer -= _frameTime;
            }
            if(_newPlayersJoined)
            {
               if(_gameGUI == null)
               {
                  _gameGUI = _scene.getLayer("gameGUI");
                  _layerMidGUI.addChild(_gameGUI.loader.content);
                  _gameGUI.loader.content.setType(_proMode);
               }
               _loc2_ = 0;
               while(_loc2_ < _players.length)
               {
                  if(_players[_loc2_] != null && _players[_loc2_]._avatar == null)
                  {
                     _players[_loc2_].init(_layerPlayers[_loc2_],_loc2_,_trackPositions[_loc2_]);
                     if(_gameState != 7)
                     {
                        _players[_loc2_].prepareForStart(_startingLineX);
                     }
                  }
                  _loc2_++;
               }
               _loc2_ = 0;
               while(_loc2_ < 6)
               {
                  if(_aiplayers[_loc2_]._avatar == null)
                  {
                     _aiplayers[_loc2_].init(_layerAIPlayers[_loc2_],_loc2_,_trackPositions[_loc2_]);
                     _layerPlayerMarkers[_aiplayers[_loc2_]._trackLane].pMarkerPlayer(_myPlayer._trackLane != _aiplayers[_loc2_]._trackLane ? 1 : 0);
                  }
                  _loc2_++;
               }
               _newPlayersJoined = false;
            }
            switch(_gameState)
            {
               case 0:
                  if(_myPlayer != null && _myPlayer._animsLoaded)
                  {
                     setGameState(1);
                  }
                  break;
               case 1:
                  if(_availableItems != null)
                  {
                     setGameState(2);
                  }
                  break;
               case 2:
               case 3:
                  _loc3_ = true;
                  _loc2_ = 0;
                  while(_loc2_ < _players.length)
                  {
                     if(_players[_loc2_] != null && _players[_loc2_]._avatar != null)
                     {
                        _loc5_ = _players[_loc2_];
                        if(!_loc5_.heartbeatIntro(_frameTime))
                        {
                           _loc3_ = false;
                        }
                        _layerPlayerMarkers[_loc5_._trackLane].x = _loc5_._avatar.x;
                        _layerPlayerMarkers[_loc5_._trackLane].y = _loc5_._avatar.y;
                     }
                     _loc2_++;
                  }
                  _loc2_ = 0;
                  while(_loc2_ < 6)
                  {
                     if(_aiplayers[_loc2_]._trackLayer.visible)
                     {
                        if(!_aiplayers[_loc2_].heartbeatIntro(_frameTime))
                        {
                           _loc3_ = false;
                        }
                        _layerPlayerMarkers[_aiplayers[_loc2_]._trackLane].x = _aiplayers[_loc2_]._avatar.x;
                        _layerPlayerMarkers[_aiplayers[_loc2_]._trackLane].y = _aiplayers[_loc2_]._avatar.y;
                     }
                     _loc2_++;
                  }
                  if(_gameState == 3 && _loc3_)
                  {
                     setGameState(4);
                  }
                  break;
               case 4:
                  if(_countdownTimer > 0)
                  {
                     _countdownTimer -= _frameTime;
                     if(_countdownTimer <= 0)
                     {
                        _soundMan.playByName(_soundNamePopUpReadySet);
                        _waitingPopup.gotoAndPlay("set");
                     }
                  }
                  break;
               case 5:
                  _loc2_ = 0;
                  while(_loc2_ < _players.length)
                  {
                     if(_players[_loc2_] != null && _players[_loc2_]._avatar != null)
                     {
                        _loc5_ = _players[_loc2_];
                        _loc5_.heartbeat(_frameTime);
                        if(_gameGUI != null && _loc5_._laneMarkerIndex > 0 && _loc5_._laneMarkerIndex <= 6)
                        {
                           _gameGUI.loader.content["pMarker" + _loc5_._laneMarkerIndex].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2 + _gameGUI.loader.content.progressBar.width * _loc5_.percentComplete();
                        }
                        _layerPlayerMarkers[_loc5_._trackLane].x = _loc5_._avatar.x;
                        _layerPlayerMarkers[_loc5_._trackLane].y = _loc5_._avatar.y;
                     }
                     _loc2_++;
                  }
                  _loc2_ = 0;
                  while(_loc2_ < 6)
                  {
                     if(_aiplayers[_loc2_]._trackLayer.visible)
                     {
                        _aiplayers[_loc2_].heartbeat(_frameTime);
                        if(_gameGUI != null && _aiplayers[_loc2_]._laneMarkerIndex > 0 && _aiplayers[_loc2_]._laneMarkerIndex <= 6)
                        {
                           _gameGUI.loader.content["pMarker" + _aiplayers[_loc2_]._laneMarkerIndex].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2 + _gameGUI.loader.content.progressBar.width * _aiplayers[_loc2_].percentComplete();
                        }
                        _layerPlayerMarkers[_aiplayers[_loc2_]._trackLane].x = _aiplayers[_loc2_]._avatar.x;
                        _layerPlayerMarkers[_aiplayers[_loc2_]._trackLane].y = _aiplayers[_loc2_]._avatar.y;
                     }
                     _loc2_++;
                  }
                  updateTrack(_myPlayer != null ? _myPlayer._trackX : 0);
                  break;
               case 7:
                  if(_raceResultsTimer > 1)
                  {
                     _raceResultsTimer -= _frameTime;
                     if(_raceResultsTimer <= 1)
                     {
                        _raceResultsTimer = 1;
                     }
                     if(_resultsPopup)
                     {
                        _loc6_ = _raceResultsTimer;
                        LocalizationManager.translateIdAndInsert(_resultsPopup.timerLabelText,11431,_loc6_);
                     }
                     break;
                  }
            }
            updateGroundSurfaceSounds();
            _gameTime += _frameTime;
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
         }
      }
      
      public function updateGroundSurfaceSounds() : void
      {
         var _loc6_:int = 0;
         var _loc1_:SoundChannel = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc9_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc8_:Boolean = false;
         if(_gameState == 2 || _gameState == 3 || _gameState == 4 || _gameState == 5)
         {
            _loc6_ = 0;
            while(_loc6_ < _players.length)
            {
               if(_players[_loc6_] != null && _players[_loc6_]._avatar != null && _players[_loc6_]._jumpingTimer <= 0 && _players[_loc6_]._moveAnimationLooped)
               {
                  _players[_loc6_]._moveAnimationLooped = false;
                  if(_myPlayer != null && _myPlayer._avatar != null && Math.abs(_myPlayer._avatar.x - _players[_loc6_]._avatar.x) < 400)
                  {
                     loop2:
                     switch(_players[_loc6_]._soundSurfaceType)
                     {
                        case 1:
                           switch(_players[_loc6_]._trackLane % 3)
                           {
                              case 0:
                                 _loc5_++;
                                 break loop2;
                              case 1:
                                 _loc7_++;
                                 break loop2;
                              default:
                                 _loc2_++;
                           }
                           break;
                        case 2:
                           _loc3_ = true;
                           break;
                        case 3:
                           _loc9_ = true;
                           break;
                        case 4:
                           _loc4_ = true;
                           break;
                        case 5:
                           _loc8_ = true;
                     }
                  }
               }
               _loc6_++;
            }
            _loc6_ = 0;
            while(_loc6_ < 6)
            {
               if(_aiplayers[_loc6_]._trackLayer.visible && _aiplayers[_loc6_]._jumpingTimer <= 0 && _aiplayers[_loc6_]._moveAnimationLooped)
               {
                  _aiplayers[_loc6_]._moveAnimationLooped = false;
                  if(_myPlayer != null && _myPlayer._avatar != null && Math.abs(_myPlayer._avatar.x - _aiplayers[_loc6_]._avatar.x) < 400)
                  {
                     loop4:
                     switch(_aiplayers[_loc6_]._soundSurfaceType)
                     {
                        case 1:
                           switch(_aiplayers[_loc6_]._trackLane % 3)
                           {
                              case 0:
                                 _loc5_++;
                                 break loop4;
                              case 1:
                                 _loc7_++;
                                 break loop4;
                              default:
                                 _loc2_++;
                           }
                           break;
                        case 2:
                           _loc3_ = true;
                           break;
                        case 3:
                           _loc9_ = true;
                           break;
                        case 4:
                           _loc4_ = true;
                           break;
                        case 5:
                           _loc8_ = true;
                     }
                  }
               }
               _loc6_++;
            }
         }
         if(_loc5_ > 0)
         {
            if(_surfaceSoundDefault < 2)
            {
               _surfaceSoundDefault++;
               _loc1_ = _soundMan.playByName(_soundNameHorse1);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundDefault);
               }
            }
         }
         if(_loc7_ > 0)
         {
            if(_surfaceSoundDefault < 2)
            {
               _surfaceSoundDefault++;
               _loc1_ = _soundMan.playByName(_soundNameHorse2);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundDefault);
               }
            }
         }
         if(_loc2_ > 0)
         {
            if(_surfaceSoundDefault < 2)
            {
               _surfaceSoundDefault++;
               _loc1_ = _soundMan.playByName(_soundNameHorse3);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundDefault);
               }
            }
         }
         if(_surfaceSoundSplash < 2)
         {
            if(_loc3_)
            {
               _surfaceSoundSplash++;
               _loc1_ = _soundMan.playByName(_soundNameHoovesMud);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundSplash);
               }
            }
         }
         if(_surfaceSoundSplash < 2)
         {
            if(_loc9_)
            {
               _surfaceSoundSplash++;
               _loc1_ = _soundMan.playByName(_soundNameHoovesWater);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundSplash);
               }
            }
         }
         if(_surfaceSoundSplash < 2)
         {
            if(_loc4_)
            {
               _surfaceSoundSplash++;
               _loc1_ = _soundMan.playByName(_soundNameHoovesWeeds);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundSplash);
               }
            }
         }
         if(_surfaceSoundSplash < 2)
         {
            if(_loc8_)
            {
               _surfaceSoundSplash++;
               _loc1_ = _soundMan.playByName(_soundNameHoovesHay);
               if(_loc1_)
               {
                  _loc1_.addEventListener("soundComplete",removeSurfaceSoundSplash);
               }
            }
         }
      }
      
      public function startGame() : void
      {
         if(_sceneLoaded)
         {
         }
      }
      
      public function resetGame(param1:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc7_:int = 0;
         var _loc9_:MovieClip = null;
         var _loc11_:Array = null;
         var _loc10_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:Array = null;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         if(_factImageMediaObject && _resultsPopup != null)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
            _factImageMediaObject = null;
         }
         if(!_loadingImage)
         {
            loadNextFactImage();
         }
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         hideDlg();
         _closeBtn.x = 847;
         _closeBtn.y = 1;
         _countdownTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _nextHurdleIndex = 0;
         _theHurdles = [];
         if(_gameGUI)
         {
            _loc5_ = 1;
            while(_loc5_ <= 6)
            {
               _gameGUI.loader.content["pMarker" + _loc5_].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2;
               _loc5_++;
            }
         }
         while(_layerHurdles.numChildren > 0)
         {
            _loc4_ = _layerHurdles.getChildAt(0);
            _layerHurdles.removeChild(_loc4_);
            _hurdleClones.push(_loc4_);
         }
         if(_raceRandomizer != null)
         {
            _loc7_ = 1000;
            _loc9_ = GETDEFINITIONBYNAME("HorseRace_Obstacle1");
            if(_proMode == 1)
            {
               if(_debugText != null)
               {
                  _debugText.text = "Pro Track Index = ";
               }
               _loc11_ = _horseRaceData._data.proTracks;
            }
            else
            {
               if(_debugText != null)
               {
                  _debugText.text = "Beginner Track Index = ";
               }
               _loc11_ = _horseRaceData._data.beginnerTracks;
            }
            _loc10_ = _raceRandomizer.integer(_loc11_.length);
            if(_debugText != null)
            {
               _debugText.text += _loc10_;
            }
            _loc2_ = 0;
            while(_loc2_ < _loc11_[_loc10_].length)
            {
               _loc6_ = _horseRaceData._data.tiles[_loc11_[_loc10_][_loc2_]];
               _loc3_ = 0;
               while(_loc3_ < _loc6_.length)
               {
                  if(_loc6_[_loc3_] <= 5)
                  {
                     _loc8_ = _raceRandomizer.integer(4);
                     _loc9_.setObstacle(_loc6_[_loc3_],_loc8_);
                     _theHurdles.push(new HorseRaceHurdle(_loc8_,_loc6_[_loc3_],_loc9_.width,_loc7_));
                     _loc7_ += _loc9_.width;
                  }
                  else
                  {
                     _loc7_ += _loc6_[_loc3_];
                  }
                  _loc3_++;
               }
               _loc2_++;
            }
            _trackLength = _loc7_ + 1000;
         }
         _layerLaneTextures.x = 0;
         _layerHurdles.x = 0;
         _layerPlayer.x = 0;
         _layerPlayerMarker.x = 0;
         if(param1)
         {
            _trackTiles.reset();
            updateTrack(0);
         }
      }
      
      public function updateTrack(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:MovieClip = null;
         _loc4_ = _layerHurdles.numChildren;
         while(_loc4_ > 0)
         {
            _loc4_--;
            _loc2_ = _layerHurdles.getChildAt(_loc4_);
            if(_loc2_.x + _layerHurdles.x < -_loc2_.width)
            {
               _layerHurdles.removeChild(_loc2_);
               _hurdleClones.push(_loc2_);
            }
         }
         if(_raceRandomizer != null)
         {
            _layerLaneTextures.x -= param1;
            _layerHurdles.x -= param1;
            _layerPlayer.x -= param1;
            _layerPlayerMarker.x -= param1;
            while(_nextHurdleIndex < _theHurdles.length)
            {
               if(_theHurdles[_nextHurdleIndex]._x + _layerHurdles.x >= 1000)
               {
                  break;
               }
               if(_hurdleClones.length > 0)
               {
                  _loc3_ = _hurdleClones[0];
                  _hurdleClones.splice(0,1);
               }
               else
               {
                  _loc3_ = GETDEFINITIONBYNAME("HorseRace_Obstacle1");
               }
               _loc3_.setObstacle(_theHurdles[_nextHurdleIndex]._class,_theHurdles[_nextHurdleIndex]._type);
               _loc3_.x = _theHurdles[_nextHurdleIndex]._x;
               _loc3_.y = 0;
               _layerHurdles.addChild(_loc3_);
               _nextHurdleIndex++;
            }
         }
         _trackTiles.heartbeat(_frameTime,_layerLaneTextures);
      }
      
      private function playerLeftGame(param1:int) : void
      {
         _aiplayers[param1].replacePlayer(_players[param1]);
      }
      
      private function onCloseButton() : void
      {
         _soundMan.playByName(_soundNamePopUp);
         var _loc1_:MovieClip = showDlg("horseRace_leaveGame",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_gemsEarned);
      }
      
      private function onErrorExit() : void
      {
         hideDlg();
         end(null);
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
      
      private function onBoostButton() : void
      {
         var _loc1_:Array = null;
         if(_gameState == 5 && _myPlayer)
         {
            if(_myPlayer.boost(false))
            {
               _boostButton.carrots(_myPlayer._boostsAvailable);
               if(_myPlayer._boostsAvailable <= 0)
               {
                  _boostButton.visible = false;
               }
               _loc1_ = [];
               _loc1_[0] = "boo";
               MinigameManager.msg(_loc1_);
            }
         }
      }
      
      private function onJumpButton() : void
      {
         var _loc1_:Array = null;
         if(_myPlayer != null)
         {
            switch(_gameState - 2)
            {
               case 0:
               case 1:
               case 2:
                  if(_myPlayer.jump())
                  {
                     _loc1_ = [];
                     _loc1_[0] = "jump";
                     MinigameManager.msg(_loc1_);
                  }
                  break;
               case 3:
                  _myPlayer.jump();
            }
         }
      }
      
      private function emoteButton(param1:int) : void
      {
         var _loc2_:Array = null;
         if(_lastEmoteTimer <= 0)
         {
            if(_myPlayer != null)
            {
               _myPlayer.showEmote(param1);
               _loc2_ = [];
               _loc2_[0] = "em";
               _loc2_[1] = param1;
               _loc2_[2] = _myPlayer._playerID;
               MinigameManager.msg(_loc2_);
               _lastEmoteTimer = 1;
            }
         }
      }
      
      private function onEmoteCoolButton() : void
      {
         emoteButton(1);
      }
      
      private function onEmoteSneakyButton() : void
      {
         emoteButton(2);
      }
      
      private function onEmoteWinkButton() : void
      {
         emoteButton(3);
      }
      
      private function onEmoteTongueButton() : void
      {
         emoteButton(4);
      }
      
      private function onEmoteSurpriseButton() : void
      {
         emoteButton(5);
      }
      
      private function onEmoteSleepButton() : void
      {
         emoteButton(6);
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               _jumpButtonDown = false;
         }
      }
      
      private function mouseHandleDown(param1:MouseEvent) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc2_:DisplayObject = null;
         if(_gameGUI != null)
         {
            _loc3_ = stage.getObjectsUnderPoint(new Point(param1.stageX,param1.stageY));
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc2_ = _loc3_[_loc4_];
               while(_loc2_ != null)
               {
                  if(_loc2_ == _gameGUI.loader.content)
                  {
                     return;
                  }
                  _loc2_ = _loc2_.parent;
               }
               _loc4_++;
            }
         }
         onJumpButton();
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 32)
         {
            case 0:
               if(!_jumpButtonDown)
               {
                  _jumpButtonDown = true;
                  onJumpButton();
                  break;
               }
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Item = null;
         _availableItems = new Array(param1.length);
         var _loc4_:int = 100;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc7_ = param1.getIitem(_loc5_) as Item;
            _availableItems[_loc5_] = new Item();
            _availableItems[_loc5_].init(_loc7_.defId,_loc4_++,_loc7_.color);
            _availableItems[_loc5_].makeSmallIcon();
            _loc5_++;
         }
         _availableItemColors = param3;
         _loc6_ = 0;
         while(_loc6_ < 6)
         {
            if(_aiplayers[_loc6_]._avatar != null)
            {
               _aiplayers[_loc6_].initFinalize();
            }
            _loc6_++;
         }
      }
      
      private function removeSurfaceSoundDefault(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeSurfaceSoundDefault);
         _surfaceSoundDefault--;
         if(_surfaceSoundDefault < 0)
         {
            _surfaceSoundDefault = 0;
         }
      }
      
      private function removeSurfaceSoundSplash(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",removeSurfaceSoundSplash);
         _surfaceSoundSplash--;
         if(_surfaceSoundSplash < 0)
         {
            _surfaceSoundSplash = 0;
         }
      }
      
      private function setGameState(param1:int) : void
      {
         var _loc6_:int = 0;
         var _loc2_:Array = null;
         var _loc5_:Array = null;
         var _loc4_:Object = null;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:SoundChannel = null;
         if(_gameState != param1)
         {
            loop3:
            switch(param1)
            {
               case 0:
                  break;
               case 1:
                  resetGame(false);
                  ItemXtCommManager.requestShopList(gotItemListCallback,49);
                  break;
               case 2:
                  _loc2_ = [];
                  _loc2_[0] = "ready";
                  MinigameManager.msg(_loc2_);
                  _loc7_ = _soundMan.playStream(_SFX_StartMusic,0,0);
                  break;
               case 3:
                  if(_gameState == 7)
                  {
                     _loc7_ = _soundMan.playStream(_SFX_StartMusic,0,0);
                     resetGame(true);
                     break;
                  }
                  resetGame(false);
                  break;
               case 4:
                  _loc2_ = [];
                  _loc2_[0] = "intro";
                  MinigameManager.msg(_loc2_);
                  break;
               case 5:
                  _soundMan.playByName(_soundNamePopUpGo);
                  _waitingPopup.gotoAndPlay("goOff");
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _musicLoop = _soundMan.playStream(_SFX_Music,0,99999);
                  break;
               case 7:
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _musicLoop = _soundMan.playStream(_SFX_EndMusic,0,0);
                  hideDlg();
                  _resultsPopup = showDlg("horseRace_results",[],450,275,false);
                  _closeBtn.parent.setChildIndex(_closeBtn,_closeBtn.parent.numChildren - 1);
                  _closeBtn.x = 790;
                  _closeBtn.y = 19;
                  if(_factImageMediaObject)
                  {
                     _resultsPopup.result_pic.addChild(_factImageMediaObject);
                  }
                  LocalizationManager.translateId(_resultsPopup.result_fact,_horseRaceData._facts[_factsOrder[_factsIndex]].text);
                  _loc6_ = 0;
                  while(_loc6_ < 6)
                  {
                     _layerPlayerMarkers[_loc6_].pMarkerBoostOff();
                     _loc6_++;
                  }
                  _loc5_ = [];
                  _loc6_ = 0;
                  while(_loc6_ < _players.length)
                  {
                     if(_players[_loc6_] != null && _players[_loc6_]._avatar != null)
                     {
                        _loc5_.push(_players[_loc6_]);
                     }
                     else if(_aiplayers[_loc6_]._trackLayer.visible)
                     {
                        _loc5_.push(_aiplayers[_loc6_]);
                     }
                     _loc6_++;
                  }
                  _loc5_.sortOn("_finishPlace",[16]);
                  _loc8_ = 1;
                  _loc6_ = 0;
                  while(true)
                  {
                     if(_loc6_ >= 6)
                     {
                        break loop3;
                     }
                     _loc4_ = _resultsPopup["playerTag" + (_loc6_ + 1)];
                     if(_loc6_ < _loc5_.length)
                     {
                        if(_loc6_ > 0 && _loc5_[_loc6_]._finishPlace != _loc5_[_loc6_ - 1]._finishPlace)
                        {
                           _loc8_++;
                        }
                        if(_loc5_[_loc6_] == _myPlayer)
                        {
                           _displayAchievementTimer = 3;
                           _loc4_.setInfo(1,_loc8_);
                           if(_proMode == 1 && _myPlayer._perfectRace)
                           {
                              AchievementXtCommManager.requestSetUserVar(331,1);
                           }
                           if(_loc8_ == 1)
                           {
                              _totalConsecutiveWins++;
                              if(_totalConsecutiveWins == 5)
                              {
                                 if(_proMode == 1)
                                 {
                                    AchievementXtCommManager.requestSetUserVar(329,1);
                                 }
                              }
                              if(_proMode == 1)
                              {
                                 MinigameManager.msg(["_a",24]);
                              }
                              else
                              {
                                 MinigameManager.msg(["_a",23]);
                              }
                              if(gMainFrame.userInfo.userVarCache.getUserVarValueById(328) >= 9)
                              {
                                 AchievementXtCommManager.requestSetUserVar(332,1);
                              }
                              AchievementXtCommManager.requestSetUserVar(328,1);
                              if(_proMode == 1)
                              {
                                 AchievementXtCommManager.requestSetUserVar(330,1);
                              }
                           }
                           else
                           {
                              _totalConsecutiveWins = 0;
                           }
                        }
                        else
                        {
                           _loc4_.setInfo(0,_loc5_[_loc6_]._finishPlace);
                        }
                        _loc4_.gemsEarned.text = "0";
                        _loc3_ = 0;
                        switch(_loc8_ - 1)
                        {
                           case 0:
                              LocalizationManager.translateId(_loc4_.place,11434);
                              _loc3_ = _proMode == 1 ? 150 : 100;
                              break;
                           case 1:
                              LocalizationManager.translateId(_loc4_.place,11435);
                              _loc3_ = _proMode == 1 ? 125 : 75;
                              break;
                           case 2:
                              LocalizationManager.translateId(_loc4_.place,11436);
                              _loc3_ = _proMode == 1 ? 100 : 50;
                              break;
                           case 3:
                              LocalizationManager.translateId(_loc4_.place,11437);
                              _loc3_ = _proMode == 1 ? 75 : 40;
                              break;
                           case 4:
                              LocalizationManager.translateId(_loc4_.place,11438);
                              _loc3_ = _proMode == 1 ? 50 : 30;
                              break;
                           case 5:
                              LocalizationManager.translateId(_loc4_.place,11439);
                              _loc3_ = _proMode == 1 ? 25 : 25;
                        }
                        LocalizationManager.updateToFit(_loc4_.place,_loc4_.place.text + " " + LocalizationManager.translateAvatarName(_loc5_[_loc6_]._name));
                        LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11097,_loc3_);
                        if(_loc5_[_loc6_] == _myPlayer)
                        {
                           _gemsEarned += _loc3_;
                           addGemsToBalance(_loc3_);
                        }
                        _loc4_.setTagWidth();
                        _loc4_.visible = true;
                     }
                     else
                     {
                        _loc4_.visible = false;
                     }
                     _loc6_++;
                  }
            }
            if(_loc7_ != null)
            {
               if(_musicLoop)
               {
                  _musicLoop.stop();
               }
               _musicLoop = _loc7_;
            }
            _gameState = param1;
         }
      }
   }
}

