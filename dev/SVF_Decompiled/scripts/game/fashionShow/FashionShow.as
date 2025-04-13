package game.fashionShow
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarEvent;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import collection.AccItemCollection;
   import collection.IitemCollection;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import com.sbi.graphics.PaletteHelper;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import item.EquippedAvatars;
   import item.Item;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   
   public class FashionShow extends GameBase implements IMinigame
   {
      private static const BEST_DRESSED_LAND:int = 48;
      
      private static const BEST_DRESSED_OCEAN:int = 66;
      
      private static const ACCESSORY_LIST_LAND:int = 49;
      
      private static const ACCESSORY_LIST_OCEAN:int = 91;
      
      private static const ITEMS_PER_ROUND:int = 50;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MIN_PLAYERS:int = 2;
      
      private static const MAX_PLAYERS:int = 10;
      
      private static const ROUND_TIME:int = 60;
      
      private static const WAITING_FOR_START_STATE:int = 0;
      
      private static const WAITING_FOR_ITEM_LIST_STATE:int = 1;
      
      private static const WAITING_FOR_AVATARS_STATE:int = 2;
      
      private static const WAITING_FOR_COSTUMES_STATE:int = 3;
      
      private static const GAME_READY_STATE:int = 4;
      
      private static const ROUND_INTRO_STATE:int = 5;
      
      private static const ROUND_INTRO_ENDING_STATE:int = 6;
      
      private static const ROUND_STARTED_STATE:int = 7;
      
      private static const VOTING_READY:int = 8;
      
      private static const VOTING_STATE:int = 9;
      
      private static const RESULTS_END_ROUND_STATE:int = 10;
      
      private static const RESULTS_SHOW_WINNERS_STATE:int = 11;
      
      private static const RESULTS_3RD_PLACE_STATE:int = 12;
      
      private static const RESULTS_2ND_PLACE_STATE:int = 13;
      
      private static const RESULTS_1ST_PLACE_STATE:int = 14;
      
      private static const RESULTS_DISCO_LIGHTS_STATE:int = 15;
      
      private static const RESULTS_SHOW_RESULTS:int = 16;
      
      public var _bestDressedOnLand:Boolean;
      
      public var _animIdleID:int;
      
      public var _animCelebrateID:int;
      
      public var _gameQuitting:Boolean;
      
      public var _stageTimer:Number;
      
      public var _roundTimer:Number;
      
      public var _votingTime:Number;
      
      private var _background:Sprite;
      
      private var _foreground:Sprite;
      
      private var _editorLayer:Sprite;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _ui:Object;
      
      public var _soundMan:SoundManager;
      
      public var _nextRoundDialog:MovieClip;
      
      public var _resultsDialog:MovieClip;
      
      private var _sceneLoaded:Boolean;
      
      private var _myPlayerId:int;
      
      private var _myDBId:int;
      
      private var _mySfsId:int;
      
      private var _playerSfsIds:Array;
      
      private var _numPlayers:uint;
      
      private var _bInit:Boolean;
      
      private var _displayAchievementTimer:Number;
      
      private var _players:Array;
      
      private var _aiPlayers:Array;
      
      private var _gameState:int = 0;
      
      private var _interactiveHud:MovieClip;
      
      private var _avatarEditor:FashionShowAvatarEditor;
      
      private var _playerID_WaitingForData:int;
      
      public var _SFX_DressingRoom_Music:SBMusic;
      
      public var _SFX_Voting_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public var _randomizer:RandomSeed;
      
      public var _curtainStage:Object;
      
      public var _timerBlinking:Boolean;
      
      public var _currentResultsIndex:int;
      
      protected var _buttonEmote1:MovieClip;
      
      protected var _buttonEmote2:MovieClip;
      
      protected var _buttonEmote3:MovieClip;
      
      protected var _buttonEmote4:MovieClip;
      
      protected var _lastEmoteTimer:Number;
      
      protected var _lastTimerValue:int;
      
      public var _theme:int;
      
      public var _totalConsecutiveWins:int;
      
      public var _voteButtons:Array;
      
      public var _availableItems:Array;
      
      public var _availableItemColors:Array;
      
      public var _currentDialog:MovieClip;
      
      private var _resultsInfo:Array;
      
      private var _playerNameCache:Array;
      
      private var _aiLandDefIDs:Array;
      
      private var _aiOceanDefIDs:Array;
      
      private var _aiDefIDs:Array;
      
      private var _aiServerPicks:Array;
      
      private var _aiServerNames:Array;
      
      private var _aiEmoteTimer:Number;
      
      private var _aiCurrentEmoteIndex:int;
      
      private var _audio:Array;
      
      internal var _soundNameBDBeep:String;
      
      internal var _soundNameBDClockTick:String;
      
      internal var _soundNameBDCurtainOpen:String;
      
      internal var _soundNameBDLightsOn:String;
      
      internal var _soundNameBDNewTheme:String;
      
      internal var _soundNameBDTimeUp:String;
      
      internal var _soundNameBDTrophyAppear:String;
      
      internal var _soundNameBDVoteText:String;
      
      internal var _soundNameBDWinnerText:String;
      
      internal var _soundNameBDPopupResults:String;
      
      internal var _soundNameBDFlash1:String;
      
      internal var _soundNameBDFlash2:String;
      
      internal var _soundNameBDFlash3:String;
      
      internal var _soundNameBDCheer:String;
      
      public function FashionShow()
      {
         var _loc1_:int = 0;
         _aiLandDefIDs = [8,15,16,5,17,7,6,13,18,1,4];
         _aiOceanDefIDs = [19,21,24,22,18,20,19,21,24,22,18];
         _audio = ["aj_BD_beep.mp3","aj_BD_clockTick.mp3","aj_BD_curtainOpen.mp3","aj_BD_lightsOn.mp3","aj_BD_newTheme.mp3","aj_BD_timeUp.mp3","aj_BD_trophyAppear.mp3","aj_BD_voteText.mp3","aj_BD_winnerText.mp3","aj_BD_popup_results_enter.mp3","aj_BD_flash1.mp3","aj_BD_flash2.mp3","aj_BD_flash3.mp3","aj_BD_cheer.mp3"];
         _soundNameBDBeep = _audio[0];
         _soundNameBDClockTick = _audio[1];
         _soundNameBDCurtainOpen = _audio[2];
         _soundNameBDLightsOn = _audio[3];
         _soundNameBDNewTheme = _audio[4];
         _soundNameBDTimeUp = _audio[5];
         _soundNameBDTrophyAppear = _audio[6];
         _soundNameBDVoteText = _audio[7];
         _soundNameBDWinnerText = _audio[8];
         _soundNameBDPopupResults = _audio[9];
         _soundNameBDFlash1 = _audio[10];
         _soundNameBDFlash2 = _audio[11];
         _soundNameBDFlash3 = _audio[12];
         _soundNameBDCheer = _audio[13];
         super();
         _bestDressedOnLand = true;
         _aiDefIDs = _aiLandDefIDs;
         _animIdleID = 14;
         _animCelebrateID = 23;
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            if(MinigameManager.minigameInfoCache.currMinigameId == 66)
            {
               _bestDressedOnLand = false;
               _aiDefIDs = _aiOceanDefIDs;
               _animIdleID = 32;
               _animCelebrateID = 38;
            }
         }
         _gameQuitting = false;
         _sceneLoaded = false;
         _currentDialog = null;
         _lastEmoteTimer = 0;
         _totalConsecutiveWins = 0;
         _lastTime = getTimer();
         _displayAchievementTimer = 0;
         _playerID_WaitingForData = -1;
         _background = new Sprite();
         _foreground = new Sprite();
         _editorLayer = new Sprite();
         _guiLayer = new Sprite();
         _playerNameCache = new Array(10);
         _loc1_ = 0;
         while(_loc1_ < 10)
         {
            _playerNameCache[_loc1_] = "";
            _loc1_++;
         }
         _players = new Array(10);
         _aiPlayers = new Array(10);
      }
      
      public function start(param1:uint, param2:Array) : void
      {
         _mySfsId = param1;
         _playerSfsIds = param2;
         _numPlayers = param2.length;
         init();
      }
      
      public function init() : void
      {
         _totalConsecutiveWins = 0;
         _lastTime = getTimer();
         _displayAchievementTimer = 0;
         _playerID_WaitingForData = -1;
         if(!_bInit)
         {
            addChild(_background);
            addChild(_foreground);
            addChild(_editorLayer);
            addChild(_guiLayer);
            if(_numPlayers <= 0 || _numPlayers > 10)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            setNewState(0);
            loadScene("FashionShow/main_room.xroom",_audio);
            resetAll();
            addListeners();
         }
      }
      
      private function addListeners() : void
      {
         addEventListener("enterFrame",heartbeat,false,0,true);
      }
      
      private function removeListeners() : void
      {
         removeEventListener("enterFrame",heartbeat);
      }
      
      public function resetAll() : void
      {
         _gameState = 0;
         _totalGameTime = 0;
      }
      
      private function loadSounds() : void
      {
         if(_bestDressedOnLand == false)
         {
            _SFX_DressingRoom_Music = _soundMan.addStream("aj_mus_bestDressedOceanMuffled",0.57);
            _SFX_Voting_Music = _soundMan.addStream("aj_mus_BD_OceanFullSpectrum",0.35);
         }
         else
         {
            _SFX_DressingRoom_Music = _soundMan.addStream("aj_mus_BD_muffled",0.89);
            _SFX_Voting_Music = _soundMan.addStream("aj_mus_BD_FullSpectrum",0.62);
         }
         _soundMan.addSoundByName(_audioByName[_soundNameBDFlash1],_soundNameBDFlash1,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameBDFlash2],_soundNameBDFlash2,0.28);
         _soundMan.addSoundByName(_audioByName[_soundNameBDFlash3],_soundNameBDFlash3,0.33);
         _soundMan.addSoundByName(_audioByName[_soundNameBDCheer],_soundNameBDCheer,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameBDBeep],_soundNameBDBeep,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameBDClockTick],_soundNameBDClockTick,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameBDCurtainOpen],_soundNameBDCurtainOpen,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameBDLightsOn],_soundNameBDLightsOn,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameBDNewTheme],_soundNameBDNewTheme,1.68);
         _soundMan.addSoundByName(_audioByName[_soundNameBDTimeUp],_soundNameBDTimeUp,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBDTrophyAppear],_soundNameBDTrophyAppear,0.34);
         _soundMan.addSoundByName(_audioByName[_soundNameBDVoteText],_soundNameBDVoteText,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameBDWinnerText],_soundNameBDWinnerText,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameBDPopupResults],_soundNameBDPopupResults,0.3);
      }
      
      public function message(param1:Array) : void
      {
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc28_:int = 0;
         var _loc9_:int = 0;
         var _loc20_:String = null;
         var _loc24_:int = 0;
         var _loc14_:int = 0;
         var _loc12_:int = 0;
         var _loc19_:int = 0;
         var _loc22_:int = 0;
         var _loc13_:int = 0;
         var _loc26_:AccItemCollection = null;
         var _loc10_:int = 0;
         var _loc23_:int = 0;
         var _loc25_:int = 0;
         var _loc15_:* = 0;
         var _loc11_:* = false;
         var _loc2_:* = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc29_:int = 0;
         var _loc21_:Object = null;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc27_:int = 0;
         var _loc16_:int = 0;
         if(!_gameQuitting)
         {
            if(param1[0] == "mm")
            {
               _loc17_ = 3;
               if(param1[2] == "uj")
               {
                  _numPlayers = param1[_loc17_++];
                  _loc14_ = 0;
                  while(_loc14_ < _numPlayers)
                  {
                     _loc28_ = int(param1[_loc17_++]);
                     _loc18_ = int(param1[_loc17_++]);
                     _loc9_ = int(param1[_loc17_++]);
                     _loc20_ = param1[_loc17_++];
                     _loc24_ = int(param1[_loc17_++]);
                     if(!_players[_loc18_])
                     {
                        _players[_loc18_] = new FashionShowPlayer();
                        _players[_loc18_].pId = _loc18_;
                        _players[_loc18_].dbId = _loc9_;
                        _players[_loc18_].sfsId = _loc28_;
                        _players[_loc18_].userName = _loc20_;
                        _players[_loc18_].customAvId = _loc24_;
                     }
                     _loc14_++;
                  }
                  setupAvatars();
               }
               else if(param1[2] == "em")
               {
                  if(param1[4] != _myPlayerId + 1)
                  {
                     if(_curtainStage && _curtainStage.loader.content)
                     {
                        _curtainStage.loader.content.showEmote(param1[3],param1[4]);
                     }
                  }
               }
               else if(param1[2] == "go")
               {
                  _loc12_ = parseInt(param1[_loc17_++]);
                  if(_aiServerPicks == null)
                  {
                     _aiServerPicks = [];
                     _aiServerNames = [];
                     _loc19_ = 0;
                     while(_loc19_ < _loc12_)
                     {
                        _aiServerPicks[_loc19_] = parseInt(param1[_loc17_++]);
                        _aiServerNames[_loc19_] = param1[_loc17_++];
                        _aiPlayers[_loc19_] = new FashionShowPlayer();
                        _aiPlayers[_loc19_].pId = -(_loc19_ + 100);
                        _aiPlayers[_loc19_].dbId = -_aiDefIDs[_aiServerPicks[_loc19_]];
                        _aiPlayers[_loc19_].sfsId = -1;
                        _aiPlayers[_loc19_].customAvId = -1;
                        _loc19_++;
                     }
                     setupAvatars();
                  }
                  setNewState(4);
               }
               else if(param1[2] == "pi")
               {
                  _loc18_ = int(param1[_loc17_++]);
                  if(_loc18_ != _myPlayerId)
                  {
                     if(_players[_loc18_] && _players[_loc18_].avtView)
                     {
                        _players[_loc18_].avtView.avatarData.setColors(param1[_loc17_++],param1[_loc17_++],param1[_loc17_++]);
                        _loc22_ = int(param1[_loc17_++]);
                        _loc13_ = int(param1[_loc17_++]);
                        _loc26_ = new AccItemCollection();
                        _loc10_ = 0;
                        while(_loc10_ < _loc22_)
                        {
                           _loc26_.setAccItem(_loc10_,new Item());
                           _loc23_ = int(param1[_loc17_++]);
                           param1[_loc17_++];
                           _loc25_ = int(param1[_loc17_++]);
                           param1[_loc17_++];
                           _loc15_ = uint(param1[_loc17_++]);
                           param1[_loc17_++];
                           _loc11_ = param1[_loc17_++] == 1;
                           param1[_loc17_++];
                           _loc26_.getAccItem(_loc10_).init(Math.abs(_loc23_),_loc25_,_loc15_);
                           if(_loc11_)
                           {
                              _loc26_.getAccItem(_loc10_).forceInUse(true);
                           }
                           _loc26_.getAccItem(_loc10_).isMemberOnly = false;
                           _loc10_++;
                        }
                        _players[_loc18_].avtView.avatarData.itemResponseIntegrate(_loc26_);
                        _loc26_ = null;
                     }
                  }
               }
               else if(param1[2] == "ri")
               {
                  closeAvEditor(true);
                  _theme = param1[_loc17_++];
                  _loc2_ = parseInt(param1[_loc17_++]);
                  _randomizer = new RandomSeed(_loc2_);
                  _loc3_ = parseInt(param1[_loc17_++]);
                  _loc4_ = 0;
                  while(_loc4_ < _players.length)
                  {
                     if(_players[_loc4_])
                     {
                        _players[_loc4_]._active = false;
                     }
                     _loc4_++;
                  }
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_)
                  {
                     _loc29_ = parseInt(param1[_loc17_++]);
                     _players[_loc29_]._active = true;
                     if(!_players[_loc29_].avtView.parent)
                     {
                        positionAvatar(_players[_loc29_],_loc29_,false);
                     }
                     _loc4_++;
                  }
                  _loc4_ = 0;
                  while(_loc4_ < _players.length)
                  {
                     if(_players[_loc4_] == null || _players[_loc4_]._active == false)
                     {
                        _aiPlayers[_loc4_].positionIndex = _loc4_;
                        positionAvatar(_aiPlayers[_loc4_],_aiPlayers[_loc4_].positionIndex,true);
                     }
                     else if(_aiPlayers[_loc4_] && _aiPlayers[_loc4_].positionIndex >= 0)
                     {
                        if(_aiPlayers[_loc4_].avtView.parent)
                        {
                           _aiPlayers[_loc4_].avtView.parent.removeChild(_aiPlayers[_loc4_].avtView);
                           _aiPlayers[_loc4_].positionIndex = -1;
                        }
                     }
                     _loc4_++;
                  }
                  _stageTimer = 2;
                  setNewState(5);
               }
               else if(param1[2] == "rs")
               {
                  if(_gameState == 5)
                  {
                     _roundTimer = parseInt(param1[_loc17_++]);
                     setNewState(6);
                  }
               }
               else if(param1[2] == "vs")
               {
                  _stageTimer = parseInt(param1[_loc17_++]);
                  _votingTime = _stageTimer;
                  setNewState(8);
               }
               else if(param1[2] == "sr")
               {
                  _resultsInfo = [];
                  _loc7_ = parseInt(param1[_loc17_++]);
                  _loc6_ = 0;
                  while(_loc6_ < _loc7_)
                  {
                     _loc21_ = {};
                     _loc21_.isAI = false;
                     _loc21_.pID = parseInt(param1[_loc17_++]);
                     _loc21_.dbID = parseInt(param1[_loc17_++]);
                     _loc21_.votes = parseInt(param1[_loc17_++]);
                     _loc21_.votedCount = parseInt(param1[_loc17_++]);
                     _resultsInfo.push(_loc21_);
                     _loc6_++;
                  }
                  _loc7_ = int(param1[_loc17_++]);
                  _loc6_ = 0;
                  while(_loc6_ < _loc7_)
                  {
                     if(_aiPlayers[_loc6_] && _aiPlayers[_loc6_].positionIndex >= 0)
                     {
                        _loc21_ = {};
                        _loc21_.isAI = true;
                        _loc21_.aiIndex = _loc6_;
                        _loc21_.pID = _aiPlayers[_loc6_].positionIndex;
                        _loc21_.votes = parseInt(param1[_loc17_]);
                        _loc21_.votedCount = parseInt(param1[_loc17_ + 1]);
                        _resultsInfo.push(_loc21_);
                     }
                     _loc17_ += 2;
                     _loc6_++;
                  }
                  _resultsInfo.sortOn("votes",16);
                  _resultsInfo.reverse();
                  _loc5_ = -1;
                  _loc27_ = 0;
                  _loc6_ = 0;
                  while(_loc6_ < _resultsInfo.length)
                  {
                     if(_resultsInfo[_loc6_].votes != _loc5_)
                     {
                        _loc27_++;
                        _loc5_ = int(_resultsInfo[_loc6_].votes);
                     }
                     _resultsInfo[_loc6_].ranking = _loc27_;
                     if(_resultsInfo[_loc6_].pID == _myPlayerId)
                     {
                        if(_loc27_ == 1)
                        {
                           if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                           {
                              _totalConsecutiveWins++;
                              if(_totalConsecutiveWins >= 3)
                              {
                                 if(_bestDressedOnLand)
                                 {
                                    AchievementXtCommManager.requestSetUserVar(294,1);
                                 }
                                 else
                                 {
                                    AchievementXtCommManager.requestSetUserVar(326,1);
                                 }
                              }
                              if(_bestDressedOnLand)
                              {
                                 AchievementXtCommManager.requestSetUserVar(293,1);
                              }
                              else
                              {
                                 AchievementXtCommManager.requestSetUserVar(325,1);
                              }
                              _displayAchievementTimer = 3;
                              MinigameManager.msg(["_a",7]);
                           }
                        }
                        else
                        {
                           _totalConsecutiveWins = 0;
                        }
                     }
                     _loc6_++;
                  }
                  setNewState(10);
               }
            }
            else if(param1[0] == "ml")
            {
               _loc18_ = int(param1[2]);
               playerLeftGame(_loc18_);
               if(_players[_loc18_] && _players[_loc18_].avtView)
               {
                  if(_players[_loc18_].avtView.parent)
                  {
                     _players[_loc18_].avtView.parent.removeChild(_players[_loc18_].avtView);
                  }
                  _players[_loc18_].destroy();
                  _players[_loc18_] = null;
               }
               _numPlayers--;
            }
            else if(param1[0] == "ms")
            {
               _loc17_ = 1;
               _loc16_ = 0;
               _loc16_ = 0;
               while(_loc16_ < _numPlayers)
               {
                  _loc18_ = int(param1[_loc17_++]);
                  _players[_loc18_] = new FashionShowPlayer();
                  _players[_loc18_].pId = _loc18_;
                  _players[_loc18_].dbId = param1[_loc17_++];
                  _players[_loc18_].userName = param1[_loc17_++];
                  _players[_loc18_].customAvId = param1[_loc17_++];
                  _players[_loc18_].sfsId = _playerSfsIds[_loc16_];
                  if(_players[_loc18_].sfsId == _mySfsId)
                  {
                     _myDBId = _players[_loc18_].dbId;
                     _myPlayerId = _players[_loc18_].pId;
                  }
                  _loc16_++;
               }
               setupAvatars();
            }
         }
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function exit() : void
      {
         var _loc2_:int = 0;
         releaseBase();
         stage.removeEventListener("keyDown",practiceKeyDown);
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         removeListeners();
         for each(var _loc3_ in _players)
         {
            if(_loc3_)
            {
               if(_loc3_.avtView && _loc3_.avtView.parent)
               {
                  _loc3_.avtView.parent.removeChild(_loc3_.avtView);
               }
               _loc3_.destroy();
            }
         }
         for each(var _loc1_ in _aiPlayers)
         {
            if(_loc1_)
            {
               if(_loc1_.avtView && _loc1_.avtView.parent)
               {
                  _loc1_.avtView.parent.removeChild(_loc1_.avtView);
               }
               _loc1_.destroy();
            }
         }
         resetAll();
         removeLayer(_background);
         removeLayer(_foreground);
         removeLayer(_editorLayer);
         removeLayer(_guiLayer);
         _background = null;
         _foreground = null;
         _editorLayer = null;
         _guiLayer = null;
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
         _availableItems = null;
         MinigameManager.leave();
         _bInit = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _loc3_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,5,showExitConfirmationDlg);
         _curtainStage = _scene.getLayer("curtainStage");
         if(_bestDressedOnLand == false)
         {
            _curtainStage.loader.content.ocean();
         }
         _background.addChild(_curtainStage.loader);
         _buttonEmote1 = addBtn("BD_emo_happy_btn",_curtainStage.loader.content.emote1.x,_curtainStage.loader.content.emote1.y,buttonEmote1);
         _buttonEmote2 = addBtn("BD_emo_laugh_btn",_curtainStage.loader.content.emote2.x,_curtainStage.loader.content.emote2.y,buttonEmote2);
         _buttonEmote3 = addBtn("BD_emo_cool_btn",_curtainStage.loader.content.emote3.x,_curtainStage.loader.content.emote3.y,buttonEmote3);
         _buttonEmote4 = addBtn("BD_emo_evil_btn",_curtainStage.loader.content.emote4.x,_curtainStage.loader.content.emote4.y,buttonEmote4);
         _buttonEmote1.visible = false;
         _buttonEmote2.visible = false;
         _buttonEmote3.visible = false;
         _buttonEmote4.visible = false;
         _totalGameTime = 0;
         _interactiveHud = _scene.getLayer("interactiveHud").loader.content;
         _guiLayer.addChild(_interactiveHud);
         _sceneLoaded = true;
         for each(var _loc4_ in _players)
         {
            if(_loc4_)
            {
               positionAvatar(_loc4_,_loc4_.pId,false);
            }
         }
         _voteButtons = [];
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn1.x,_curtainStage.loader.content.voteBtn1.y,voteForPlayer1));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn2.x,_curtainStage.loader.content.voteBtn2.y,voteForPlayer2));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn3.x,_curtainStage.loader.content.voteBtn3.y,voteForPlayer3));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn4.x,_curtainStage.loader.content.voteBtn4.y,voteForPlayer4));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn5.x,_curtainStage.loader.content.voteBtn5.y,voteForPlayer5));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn6.x,_curtainStage.loader.content.voteBtn6.y,voteForPlayer6));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn7.x,_curtainStage.loader.content.voteBtn7.y,voteForPlayer7));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn8.x,_curtainStage.loader.content.voteBtn8.y,voteForPlayer8));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn9.x,_curtainStage.loader.content.voteBtn9.y,voteForPlayer9));
         _voteButtons.push(addBtn("BD_voteButton",_curtainStage.loader.content.voteBtn10.x,_curtainStage.loader.content.voteBtn10.y,voteForPlayer10));
         _loc2_ = 0;
         while(_loc2_ < _voteButtons.length)
         {
            _voteButtons[_loc2_].visible = false;
            _loc2_++;
         }
         super.sceneLoaded(param1);
         setNewState(1);
      }
      
      private function playerLeftGame(param1:int) : void
      {
         if(_voteButtons && _voteButtons[param1])
         {
            _voteButtons[param1].visible = false;
         }
         if(_curtainStage && _curtainStage.loader.content)
         {
            _curtainStage.loader.content.closeCurtain(param1 + 1);
         }
      }
      
      private function setNewState(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:* = null;
         if(_gameState != param1)
         {
            switch(_gameState)
            {
               case 0:
               case 1:
               case 2:
               case 3:
                  break;
               case 4:
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                     _musicLoop = null;
                  }
                  _musicLoop = _soundMan.playStream(_SFX_Voting_Music,0,999999);
                  if(_currentDialog != null)
                  {
                     _guiLayer.removeChild(_currentDialog);
                     _currentDialog = null;
                  }
                  hideDlg();
                  break;
               case 5:
                  break;
               case 6:
                  if(_currentDialog != null)
                  {
                     _guiLayer.removeChild(_currentDialog);
                     _currentDialog = null;
                  }
                  hideDlg();
                  _nextRoundDialog = null;
                  break;
               case 7:
                  break;
               case 8:
                  if(_currentDialog != null)
                  {
                     _guiLayer.removeChild(_currentDialog);
                     _currentDialog = null;
                  }
                  hideDlg();
                  break;
               case 9:
                  if(_currentDialog != null)
                  {
                     _guiLayer.removeChild(_currentDialog);
                     _currentDialog = null;
                  }
                  hideDlg();
                  break;
               case 10:
               case 11:
               case 12:
               case 13:
               case 14:
                  break;
               case 15:
                  _buttonEmote1.visible = false;
                  _buttonEmote2.visible = false;
                  _buttonEmote3.visible = false;
                  _buttonEmote4.visible = false;
                  _loc2_ = 0;
                  while(_loc2_ < _resultsInfo.length)
                  {
                     if(_resultsInfo[_loc2_].ranking <= 3)
                     {
                        if(_resultsInfo[_loc2_].pID < 10)
                        {
                           _curtainStage.loader.content.hideTrophy(_resultsInfo[_loc2_].pID + 1);
                        }
                        if(_resultsInfo[_loc2_].isAI)
                        {
                           if(_aiPlayers[_resultsInfo[_loc2_].pID] && _aiPlayers[_resultsInfo[_loc2_].pID].avtView)
                           {
                              _aiPlayers[_resultsInfo[_loc2_].pID].avtView.playAnim(_animIdleID,true);
                           }
                        }
                        else if(_players[_resultsInfo[_loc2_].pID] && _players[_resultsInfo[_loc2_].pID].avtView)
                        {
                           _players[_resultsInfo[_loc2_].pID].avtView.playAnim(_animIdleID,true);
                        }
                     }
                     _loc2_++;
                  }
                  break;
               case 16:
                  if(_currentDialog != null)
                  {
                     _guiLayer.removeChild(_currentDialog);
                     _currentDialog = null;
                  }
                  hideDlg();
                  _resultsDialog = null;
            }
            _gameState = param1;
            switch(_gameState)
            {
               case 0:
                  break;
               case 1:
                  if(_bestDressedOnLand)
                  {
                     ItemXtCommManager.requestShopList(gotItemListCallback,49);
                     break;
                  }
                  ItemXtCommManager.requestShopList(gotItemListCallback,91);
                  break;
               case 2:
                  setupAvatars();
                  break;
               case 3:
                  break;
               case 4:
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                     _musicLoop = null;
                  }
                  _musicLoop = _soundMan.playStream(_SFX_DressingRoom_Music,0,999999);
                  showPracticePopup();
                  break;
               case 5:
                  _aiEmoteTimer = 0;
                  _aiCurrentEmoteIndex = 0;
                  _curtainStage.loader.content.hideAllTrophies();
                  for each(_loc3_ in _players)
                  {
                     if(_loc3_)
                     {
                        stripAvatar(_loc3_);
                     }
                  }
                  for each(_loc3_ in _aiPlayers)
                  {
                     if(_loc3_)
                     {
                        stripAvatar(_loc3_);
                     }
                  }
                  showNextRoundDlg();
                  break;
               case 6:
                  _nextRoundDialog.closeEnvelope();
                  break;
               case 7:
                  if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                  {
                     if(_bestDressedOnLand)
                     {
                        AchievementXtCommManager.requestSetUserVar(292,1);
                     }
                     else
                     {
                        AchievementXtCommManager.requestSetUserVar(324,1);
                     }
                  }
                  _stageTimer = _roundTimer;
                  _lastTimerValue = _stageTimer;
                  _curtainStage.loader.content.closeCurtains();
                  showAvatarEditor(false);
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                     _musicLoop = null;
                  }
                  _musicLoop = _soundMan.playStream(_SFX_DressingRoom_Music,0,999999);
                  break;
               case 8:
                  _soundMan.playByName(_soundNameBDVoteText);
                  closeAvEditor(false);
                  LocalizationManager.translateId(_curtainStage.loader.content.voteInfo.voteInfo.voteInfoText2,_theme);
                  _curtainStage.loader.content.textUpdate();
                  _curtainStage.loader.content.time(0,_votingTime);
                  _buttonEmote1.visible = true;
                  _buttonEmote2.visible = true;
                  _buttonEmote3.visible = true;
                  _buttonEmote4.visible = true;
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                     _musicLoop = null;
                  }
                  _musicLoop = _soundMan.playStream(_SFX_Voting_Music,0,999999);
                  break;
               case 9:
                  _stageTimer = _votingTime;
                  _lastTimerValue = _stageTimer;
                  _curtainStage.loader.content.camerasOn();
                  _soundMan.playByName(_soundNameBDLightsOn);
                  _curtainStage.loader.content.lightsUp();
                  for each(_loc3_ in _players)
                  {
                     if(_loc3_ && _loc3_._active)
                     {
                        if(_loc3_.pId != _myPlayerId)
                        {
                           _voteButtons[_loc3_.pId].visible = true;
                        }
                        _curtainStage.loader.content.openCurtain(_loc3_.pId + 1);
                     }
                  }
                  for each(_loc3_ in _aiPlayers)
                  {
                     if(_loc3_)
                     {
                        if(_loc3_.positionIndex >= 0)
                        {
                           _voteButtons[_loc3_.positionIndex].visible = true;
                           _curtainStage.loader.content.openCurtain(_loc3_.positionIndex + 1);
                        }
                     }
                  }
                  break;
               case 10:
                  _curtainStage.loader.content.endRound();
                  break;
               case 11:
                  _soundMan.playByName(_soundNameBDWinnerText);
                  _curtainStage.loader.content.showWinnersPopup();
                  break;
               case 12:
                  _stageTimer = 0.5;
                  _currentResultsIndex = 0;
                  break;
               case 13:
                  _stageTimer = 0.5;
                  _currentResultsIndex = 0;
                  break;
               case 14:
                  _stageTimer = 0.5;
                  _currentResultsIndex = 0;
                  _soundMan.playByName(_soundNameBDCheer);
                  break;
               case 15:
                  _curtainStage.loader.content.camerasOn();
                  _curtainStage.loader.content.discoLights();
                  break;
               case 16:
                  showResultsDlg();
                  _soundMan.playByName(_soundNameBDPopupResults);
            }
         }
      }
      
      private function showTrophy(param1:int, param2:String) : void
      {
         var _loc3_:Boolean = false;
         _soundMan.playByName(_soundNameBDTrophyAppear);
         while(_currentResultsIndex < _resultsInfo.length)
         {
            if(_resultsInfo[_currentResultsIndex].ranking == param1)
            {
               if(_resultsInfo[_currentResultsIndex].pID < 10)
               {
                  _curtainStage.loader.content.showTrophy(_resultsInfo[_currentResultsIndex].pID + 1,param2);
               }
               if(_resultsInfo[_currentResultsIndex].isAI)
               {
                  if(_aiPlayers[_resultsInfo[_currentResultsIndex].pID] != null && _aiPlayers[_resultsInfo[_currentResultsIndex].pID].avtView != null)
                  {
                     _aiPlayers[_resultsInfo[_currentResultsIndex].pID].avtView.playAnim(_animCelebrateID,true);
                  }
               }
               else if(_players[_resultsInfo[_currentResultsIndex].pID] != null && _players[_resultsInfo[_currentResultsIndex].pID].avtView)
               {
                  _players[_resultsInfo[_currentResultsIndex].pID].avtView.playAnim(_animCelebrateID,true);
               }
               _loc3_ = true;
            }
            _currentResultsIndex++;
         }
         _stageTimer = 0.5;
      }
      
      private function heartbeat(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc9_:FashionShowPlayer = null;
         var _loc5_:int = 0;
         var _loc2_:Number = NaN;
         var _loc7_:int = 0;
         var _loc3_:Number = (getTimer() - _lastTime) / 1000;
         _lastTime = getTimer();
         _totalGameTime += _loc3_;
         if(!_gameQuitting)
         {
            _aiEmoteTimer -= _loc3_;
            if(_aiEmoteTimer <= 0)
            {
               loop1:
               switch(_gameState - 8)
               {
                  case 0:
                  case 1:
                  case 2:
                  case 3:
                  case 4:
                  case 5:
                  case 6:
                  case 7:
                     if(_aiPlayers)
                     {
                        _loc6_ = 0;
                        while(true)
                        {
                           if(_loc6_ >= _aiPlayers.length)
                           {
                              break loop1;
                           }
                           _loc9_ = _aiPlayers[_aiCurrentEmoteIndex];
                           _aiCurrentEmoteIndex++;
                           if(_aiCurrentEmoteIndex >= _aiPlayers.length)
                           {
                              _aiCurrentEmoteIndex = 0;
                           }
                           if(_loc9_ && _loc9_.positionIndex >= 0)
                           {
                              if(Math.random() * 100 < 15)
                              {
                                 _loc5_ = Math.random() * 4 + 1;
                                 _curtainStage.loader.content.showEmote(_loc5_,_loc9_.positionIndex + 1);
                                 break loop1;
                              }
                           }
                           _loc6_++;
                        }
                     }
               }
               _aiEmoteTimer = Math.random() * 6;
            }
            if(_lastEmoteTimer > 0)
            {
               _lastEmoteTimer -= _loc3_;
            }
            switch(_gameState - 6)
            {
               case 0:
                  if(_nextRoundDialog.done)
                  {
                     setNewState(7);
                  }
                  break;
               case 2:
                  if(_curtainStage.loader.content.clock.finished)
                  {
                     setNewState(9);
                  }
                  break;
               case 4:
                  if(_curtainStage.loader.content.clock.finished)
                  {
                     setNewState(11);
                  }
                  break;
               case 5:
                  if(_curtainStage.loader.content.winnersBanner.finished)
                  {
                     setNewState(14);
                  }
                  break;
               case 9:
                  if(_curtainStage.loader.content.discoLightsMC.finished)
                  {
                     setNewState(16);
                     break;
                  }
            }
            if(_avatarEditor)
            {
               if(_avatarEditor.avEditor.curtain.curtainUpSound)
               {
                  _soundMan.playByName(_soundNameBDCurtainOpen);
                  _avatarEditor.avEditor.curtain.curtainUpSound = false;
               }
            }
            else if(_curtainStage && _curtainStage.loader.content && _curtainStage.loader.content.cameraSound)
            {
               _curtainStage.loader.content.cameraSound = false;
               _loc2_ = Math.random() * 100;
               if(_loc2_ > 66)
               {
                  _soundMan.playByName(_soundNameBDFlash1);
               }
               else if(_loc2_ > 33)
               {
                  _soundMan.playByName(_soundNameBDFlash2);
               }
               else
               {
                  _soundMan.playByName(_soundNameBDFlash3);
               }
            }
            if(_stageTimer > 0)
            {
               _stageTimer -= _loc3_;
               if(_stageTimer < 0)
               {
                  _stageTimer = 0;
               }
               if(_avatarEditor)
               {
                  _loc7_ = Math.round(_stageTimer);
                  if(_loc7_ < 10)
                  {
                     _avatarEditor.avEditor.timer.timerObject.timerText.text = "0:0" + _loc7_;
                     if(_loc7_ <= 9)
                     {
                        if(!_timerBlinking)
                        {
                           _timerBlinking = true;
                           _avatarEditor.avEditor.timer.gotoAndPlay("on");
                        }
                     }
                  }
                  else
                  {
                     _avatarEditor.avEditor.timer.timerObject.timerText.text = "0:" + _loc7_;
                  }
                  if(_lastTimerValue - _loc7_ >= 1)
                  {
                     _lastTimerValue = _loc7_;
                     if(_timerBlinking)
                     {
                        _soundMan.playByName(_soundNameBDBeep);
                     }
                     else
                     {
                        _soundMan.playByName(_soundNameBDClockTick);
                     }
                  }
               }
               if(_gameState == 9)
               {
                  _curtainStage.loader.content.time(_votingTime - _stageTimer,_votingTime);
                  if(_lastTimerValue - Math.round(_stageTimer) >= 1)
                  {
                     _lastTimerValue = Math.round(_stageTimer);
                     if((_votingTime - _stageTimer) / _votingTime > 0.65)
                     {
                        _soundMan.playByName(_soundNameBDBeep);
                     }
                     else
                     {
                        _soundMan.playByName(_soundNameBDClockTick);
                     }
                  }
               }
               if(_stageTimer <= 0)
               {
                  switch(_gameState - 5)
                  {
                     case 0:
                        if(_nextRoundDialog)
                        {
                           _nextRoundDialog.openEnvelope();
                           _soundMan.playByName(_soundNameBDNewTheme);
                        }
                        break;
                     case 2:
                        _soundMan.playByName(_soundNameBDTimeUp);
                        clientEndsRound();
                        break;
                     case 4:
                        _soundMan.playByName(_soundNameBDTimeUp);
                        clientEndsVoting();
                        break;
                     case 7:
                        if(_currentResultsIndex < _resultsInfo.length)
                        {
                           showTrophy(3,"bronze");
                           break;
                        }
                        setNewState(15);
                        break;
                     case 8:
                        if(_currentResultsIndex < _resultsInfo.length)
                        {
                           showTrophy(2,"silver");
                           break;
                        }
                        setNewState(12);
                        break;
                     case 9:
                        if(_currentResultsIndex < _resultsInfo.length)
                        {
                           showTrophy(1,"gold");
                           break;
                        }
                        setNewState(13);
                        break;
                  }
               }
            }
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _loc3_;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
         }
      }
      
      public function avEditorCloseButtonDemoMode() : void
      {
         showPracticePopup();
      }
      
      public function avEditorCloseButton() : void
      {
         if(_gameState == 7 && _stageTimer > 2)
         {
            showFinishedDlg();
         }
         else if(_avatarEditor)
         {
            _avatarEditor.sendChangesRequest();
         }
      }
      
      public function clientEndsRound() : void
      {
         _stageTimer = 0;
         var _loc1_:Array = [];
         _loc1_[0] = "re";
         MinigameManager.msg(_loc1_);
         closeAvEditor(false);
      }
      
      public function clientEndsVoting(param1:int = -1) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         LocalizationManager.translateId(_curtainStage.loader.content.voteInfo.voteInfo.voteInfoText1,11444);
         _curtainStage.loader.content.voteInfo.voteInfo.voteInfoText2.text = " ";
         _curtainStage.loader.content.textUpdate();
         _stageTimer = 0;
         _loc5_ = 0;
         while(_loc5_ < _voteButtons.length)
         {
            _voteButtons[_loc5_].visible = false;
            _loc5_++;
         }
         var _loc2_:Array = [];
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         _loc2_[0] = "ve";
         _loc2_[1] = _loc4_;
         _loc6_ = 2;
         _loc5_ = 0;
         while(_loc5_ < _aiPlayers.length)
         {
            if(_aiPlayers[_loc5_] && _aiPlayers[_loc5_].positionIndex >= 0)
            {
               _loc3_ = _randomizer.integer(10);
               _loc4_++;
               _loc2_[_loc6_++] = _loc5_;
               if(_aiPlayers[_loc3_] && _aiPlayers[_loc3_].positionIndex >= 0)
               {
                  _loc2_[_loc6_++] = 2;
                  _loc2_[_loc6_++] = _loc3_;
               }
               else if(_players[_loc3_] && _players[_loc3_]._active)
               {
                  _loc2_[_loc6_++] = 1;
                  _loc2_[_loc6_++] = _loc3_;
               }
               else
               {
                  _loc2_[_loc6_++] = 0;
               }
            }
            _loc5_++;
         }
         _loc2_[1] = _loc4_;
         if(param1 > -1)
         {
            if(_aiPlayers[param1] && _aiPlayers[param1].positionIndex == param1)
            {
               _loc2_[_loc6_++] = 2;
            }
            else
            {
               _loc2_[_loc6_++] = 1;
            }
            _loc2_[_loc6_++] = param1;
         }
         else
         {
            _loc2_[_loc6_++] = 0;
         }
         MinigameManager.msg(_loc2_);
      }
      
      private function createAvatar(param1:FashionShowPlayer) : void
      {
         _playerID_WaitingForData = param1.pId;
         var _loc2_:Avatar = new Avatar();
         _loc2_.init(param1.dbId,-1,"fashionShowAvt" + param1.dbId,1,[0,0,0],param1.customAvId,null,param1.userName,-1,_bestDressedOnLand ? 0 : 1);
         param1.avtView = new AvatarView();
         param1.avtView.init(_loc2_);
         AvatarXtCommManager.requestADForAvatar(param1.dbId,true,avatarAdCallback,_loc2_);
      }
      
      private function createAIAvatar(param1:FashionShowPlayer) : void
      {
         _playerID_WaitingForData = param1.pId;
         var _loc2_:Avatar = new Avatar();
         _loc2_.init(-1,-1,"fashionShowAvt" + param1.dbId,-param1.dbId,[0,0,0],param1.customAvId,null,"",-1,_bestDressedOnLand ? 0 : 1);
         param1.avtView = new AvatarView();
         param1.avtView.init(_loc2_);
         param1.avtView.avatarData.itemResponseIntegrate(ItemXtCommManager.generateBodyModList(-param1.dbId,0,0,false));
         avatarAdCallback(null);
      }
      
      private function getRandomColors(param1:FashionShowPlayer) : Array
      {
         var _loc2_:uint = uint(PaletteHelper.avatarPalette1[_randomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc5_:uint = uint(PaletteHelper.avatarPalette2[_randomizer.integer(PaletteHelper.avatarPalette2.length)]);
         var _loc6_:uint = uint(PaletteHelper.avatarPalette2[_randomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc9_:uint = uint(PaletteHelper.avatarPalette2[_randomizer.integer(PaletteHelper.avatarPalette1.length)]);
         var _loc3_:Array = param1.avtView.avatarData.colors;
         var _loc4_:uint = uint(_loc3_[0]);
         var _loc7_:uint = uint(_loc3_[1]);
         var _loc8_:uint = uint(_loc3_[2]);
         _loc4_ = uint(_loc2_ << 24 | _loc5_ << 16 | (_loc4_ >> 8 & 0xFF) << 8 | _loc4_ & 0xFF);
         _loc7_ = uint(_loc6_ << 24 | (_loc7_ >> 16 & 0xFF) << 16 | (_loc7_ >> 8 & 0xFF) << 8 | _loc7_ & 0xFF);
         _loc8_ = uint(_loc9_ << 24 | (_loc8_ >> 16 & 0xFF) << 16 | (_loc8_ >> 8 & 0xFF) << 8 | _loc8_ & 0xFF);
         return [_loc4_,_loc7_,_loc8_];
      }
      
      private function pickEyeAndPattern(param1:FashionShowPlayer) : void
      {
         var _loc2_:Item = null;
         var _loc4_:int = 0;
         var _loc5_:Vector.<Item> = new Vector.<Item>();
         var _loc3_:Vector.<Item> = new Vector.<Item>();
         _loc4_ = 0;
         while(_loc4_ < param1.playerBodyModList.length)
         {
            _loc2_ = param1.playerBodyModList.getAccItem(_loc4_);
            if(_loc2_.layerId == 2)
            {
               _loc2_.forceInUse(false);
               _loc3_.push(_loc2_);
            }
            else if(_loc2_.layerId == 3)
            {
               _loc2_.forceInUse(false);
               _loc5_.push(_loc2_);
            }
            _loc4_++;
         }
         if(_loc3_.length > 0)
         {
            _loc3_[_randomizer.integer(_loc3_.length)].forceInUse(true);
         }
         if(_loc5_.length > 0)
         {
            _loc5_[_randomizer.integer(_loc5_.length)].forceInUse(true);
         }
      }
      
      private function setupAvatars() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:* = null;
         var _loc1_:Array = null;
         if(_gameState > 1)
         {
            if(_playerID_WaitingForData == -1)
            {
               _loc2_ = true;
               for each(_loc3_ in _players)
               {
                  if(_loc3_)
                  {
                     if(!_loc3_.avtView)
                     {
                        createAvatar(_loc3_);
                        _loc2_ = false;
                        break;
                     }
                  }
               }
               if(_loc2_)
               {
                  for each(_loc3_ in _aiPlayers)
                  {
                     if(_loc3_)
                     {
                        if(!_loc3_.avtView)
                        {
                           createAIAvatar(_loc3_);
                           _loc2_ = false;
                           break;
                        }
                     }
                  }
               }
               if(_gameState < 4)
               {
                  if(_loc2_)
                  {
                     _loc1_ = [];
                     _loc1_[0] = "go";
                     MinigameManager.msg(_loc1_);
                     setNewState(3);
                  }
               }
            }
         }
      }
      
      private function avatarAdCallback(param1:String = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = null;
         if(_myPlayerId == _playerID_WaitingForData)
         {
            _players[_playerID_WaitingForData].playerBodyModList = new AccItemCollection();
            if(_players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod)
            {
               _loc3_ = 0;
               while(_loc3_ < _players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod.numItems)
               {
                  _players[_playerID_WaitingForData].playerBodyModList.pushAccItem(_players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_).clone());
                  _loc3_++;
               }
            }
            _players[_playerID_WaitingForData].avtView.avatarData.itemResponseIntegrate(_players[_playerID_WaitingForData].playerBodyModList);
            if(_players[_playerID_WaitingForData].avtView.avatarData.inventoryClothing)
            {
               _loc2_ = 0;
               while(_loc2_ < _players[_playerID_WaitingForData].avtView.avatarData.inventoryClothing.numItems)
               {
                  _players[_playerID_WaitingForData].avtView.avatarData.inventoryClothing.itemCollection.getAccItem(_loc2_).makeSmallIcon();
                  _loc2_++;
               }
            }
            if(_players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod)
            {
               _loc3_ = 0;
               while(_loc3_ < _players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod.numItems)
               {
                  _players[_playerID_WaitingForData].avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_).makeSmallIcon();
                  _loc3_++;
               }
            }
         }
         if(_playerID_WaitingForData >= 0)
         {
            if(_playerID_WaitingForData < 10)
            {
               _playerNameCache[_playerID_WaitingForData] = _players[_playerID_WaitingForData].avtView.avName;
            }
            stripAvatar(_players[_playerID_WaitingForData]);
            if(_gameState <= 4)
            {
               positionAvatar(_players[_playerID_WaitingForData],_playerID_WaitingForData,false);
            }
         }
         else
         {
            for each(_loc4_ in _aiPlayers)
            {
               if(_loc4_ && _loc4_.pId == _playerID_WaitingForData)
               {
                  _loc4_.playerBodyModList = new AccItemCollection();
                  if(_loc4_.avtView.avatarData.inventoryBodyMod && _loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getCoreArray())
                  {
                     _loc3_ = 0;
                     while(_loc3_ < _loc4_.avtView.avatarData.inventoryBodyMod.numItems)
                     {
                        if(_loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_))
                        {
                           _loc4_.playerBodyModList.pushAccItem(_loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_));
                        }
                        _loc3_++;
                     }
                  }
                  _loc4_.avtView.avatarData.itemResponseIntegrate(_loc4_.playerBodyModList);
                  if(_loc4_.avtView.avatarData.inventoryClothing && _loc4_.avtView.avatarData.inventoryClothing.itemCollection.getCoreArray())
                  {
                     _loc2_ = 0;
                     while(_loc2_ < _loc4_.avtView.avatarData.inventoryClothing.numItems)
                     {
                        if(_loc4_.avtView.avatarData.inventoryClothing.itemCollection.getAccItem(_loc2_))
                        {
                           _loc4_.avtView.avatarData.inventoryClothing.itemCollection.getAccItem(_loc2_).makeSmallIcon();
                        }
                        _loc2_++;
                     }
                  }
                  if(_loc4_.avtView.avatarData.inventoryBodyMod && _loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getCoreArray())
                  {
                     _loc3_ = 0;
                     while(_loc3_ < _loc4_.avtView.avatarData.inventoryBodyMod.numItems)
                     {
                        if(_loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_))
                        {
                           _loc4_.avtView.avatarData.inventoryBodyMod.itemCollection.getAccItem(_loc3_).makeSmallIcon();
                        }
                        _loc3_++;
                     }
                  }
                  stripAvatar(_loc4_);
                  if(_loc4_.positionIndex >= 0)
                  {
                     positionAvatar(_loc4_,_loc4_.positionIndex,true);
                  }
                  break;
               }
            }
         }
         _playerID_WaitingForData = -1;
         setupAvatars();
      }
      
      private function stripAvatar(param1:FashionShowPlayer) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         var _loc2_:Boolean = false;
         var _loc5_:AccItemCollection = null;
         if(param1.avtView)
         {
            if(param1.avtView.avatarData.accShownItems)
            {
               _loc3_ = false;
               _loc2_ = false;
               while(!_loc2_)
               {
                  _loc2_ = true;
                  _loc5_ = param1.avtView.avatarData.accShownItems;
                  _loc4_ = 0;
                  while(_loc4_ < _loc5_.length)
                  {
                     if(_loc5_.getAccItem(_loc4_).layerId > 3)
                     {
                        _loc2_ = false;
                        _loc3_ = true;
                        param1.avtView.avatarData.accStateHideAccessory(_loc5_.getAccItem(_loc4_),false);
                     }
                     _loc4_++;
                  }
               }
               if(_loc3_)
               {
                  param1.avtView.avatarData.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
               }
            }
         }
      }
      
      private function positionAvatar(param1:FashionShowPlayer, param2:int, param3:Boolean) : void
      {
         var _loc4_:Array = null;
         var _loc6_:String = null;
         if(_sceneLoaded)
         {
            _loc4_ = _scene.getActorList("ActorSpawn");
            _loc6_ = "playerAvatar" + (param2 + 1);
            if(param1.avtView)
            {
               if(!param3)
               {
                  if(_aiPlayers[param2] && _aiPlayers[param2].positionIndex >= 0)
                  {
                     playerLeftGame(param2);
                     if(_aiPlayers[param2].avtView.parent)
                     {
                        _aiPlayers[param2].avtView.parent.removeChild(_aiPlayers[param2].avtView);
                        _aiPlayers[param2].positionIndex = -1;
                     }
                  }
               }
               param1.avtView.playAnim(_animIdleID,true);
               param1.avtView.x = 0;
               param1.avtView.y = 0;
               if(!param1.avtView.parent)
               {
                  DisplayObjectContainer(_curtainStage.loader.content[_loc6_].avatar).addChild(param1.avtView);
               }
            }
         }
      }
      
      public function randomizeItemsArray() : Array
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc1_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < _availableItems.length)
         {
            _loc2_.push(_loc4_);
            _loc4_++;
         }
         var _loc6_:Number = _loc2_.length - 1;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _loc1_ = _randomizer.integer(_loc6_);
            _loc3_ = _loc2_[_loc5_];
            _loc2_[_loc5_] = _loc2_[_loc1_];
            _loc2_[_loc1_] = _loc3_;
            _loc5_++;
         }
         return _loc2_;
      }
      
      private function showAvatarEditor(param1:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Item = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = null;
         var _loc7_:int = 0;
         var _loc8_:Item = null;
         var _loc9_:AccItemCollection = new AccItemCollection();
         var _loc10_:Array = [];
         _loc5_ = 0;
         while(_loc5_ < _players[_myPlayerId].playerBodyModList.length)
         {
            _loc9_.pushAccItem(_players[_myPlayerId].playerBodyModList.getAccItem(_loc5_));
            _loc5_++;
         }
         if(param1)
         {
            _loc5_ = 0;
            while(_loc5_ < _availableItems.length)
            {
               _loc4_ = -1;
               _loc3_ = 0;
               _loc6_ = _availableItems[_loc5_];
               if(_loc6_.type == 1)
               {
                  switch(_loc6_.layerId - 5)
                  {
                     case 0:
                        _loc4_ = 5;
                        _loc3_ = 200;
                        break;
                     case 1:
                        _loc4_ = 6;
                        _loc3_ = 200;
                        break;
                     case 2:
                        _loc4_ = 7;
                        _loc3_ = 200;
                        break;
                     case 3:
                     case 4:
                     case 5:
                        _loc4_ = 8;
                        _loc3_ = 200;
                  }
                  if(_loc3_ > 0 && _loc4_ >= 0)
                  {
                     if(_loc10_[_loc4_] == null)
                     {
                        _loc10_[_loc4_] = [];
                     }
                     if(_loc10_[_loc4_].length < _loc3_)
                     {
                        if(_loc6_.icon.numChildren > 0)
                        {
                           _loc10_[_loc4_].push(_loc6_);
                        }
                     }
                  }
               }
               _loc5_++;
            }
            if(_loc10_[8])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[8].length)
               {
                  _loc9_.pushAccItem(_loc10_[8][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[7])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[7].length)
               {
                  _loc9_.pushAccItem(_loc10_[7][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[5])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[5].length)
               {
                  _loc9_.pushAccItem(_loc10_[5][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[6])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[6].length)
               {
                  _loc9_.pushAccItem(_loc10_[6][_loc5_]);
                  _loc5_++;
               }
            }
            _players[_myPlayerId].avtView.avatarData.itemResponseIntegrate(_loc9_);
            _avatarEditor = new FashionShowAvatarEditor();
            _avatarEditor.init(_bestDressedOnLand,_players[_myPlayerId].avtView.avatarData,_editorLayer,null,null,avEditorCloseButtonDemoMode,450,275);
            LocalizationManager.translateId(_avatarEditor.avEditor.themeText.themeInfoText1,11445);
            LocalizationManager.translateId(_avatarEditor.avEditor.themeText.themeInfoText2,11446);
            _avatarEditor.avEditor.textUpdate();
            _avatarEditor.avEditor.timer.timerObject.timerText.text = "";
            _avatarEditor.avEditor.timer.gotoAndPlay("off");
            _timerBlinking = false;
            _stageTimer = 0;
         }
         else
         {
            if(_closeBtn)
            {
               _closeBtn.visible = false;
            }
            _loc2_ = randomizeItemsArray();
            _loc5_ = 0;
            while(_loc5_ < _availableItems.length)
            {
               _loc4_ = -1;
               _loc3_ = 0;
               _loc6_ = _availableItems[_loc2_[_loc5_]];
               if(_loc6_.type == 1)
               {
                  _loc7_ = _randomizer.integer(_availableItemColors[_loc6_.defId].length);
                  _loc6_.color = _availableItemColors[_loc6_.defId][_loc7_];
                  _loc6_.setIconColor(_loc6_.layerId,_loc6_.color);
                  switch(_loc6_.layerId - 5)
                  {
                     case 0:
                        _loc4_ = 5;
                        _loc3_ = 6;
                        break;
                     case 1:
                        _loc4_ = 6;
                        _loc3_ = 18;
                        break;
                     case 2:
                        _loc4_ = 7;
                        _loc3_ = 6;
                        break;
                     case 3:
                     case 4:
                     case 5:
                        _loc4_ = 8;
                        _loc3_ = 18;
                  }
                  if(_loc3_ > 0 && _loc4_ >= 0)
                  {
                     if(_loc10_[_loc4_] == null)
                     {
                        _loc10_[_loc4_] = [];
                     }
                     if(_loc10_[_loc4_].length < _loc3_)
                     {
                        _loc10_[_loc4_].push(_loc6_);
                     }
                  }
               }
               _loc5_++;
            }
            if(_loc10_[8])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[8].length)
               {
                  _loc9_.pushAccItem(_loc10_[8][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[7])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[7].length)
               {
                  _loc9_.pushAccItem(_loc10_[7][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[5])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[5].length)
               {
                  _loc9_.pushAccItem(_loc10_[5][_loc5_]);
                  _loc5_++;
               }
            }
            if(_loc10_[6])
            {
               _loc5_ = 0;
               while(_loc5_ < _loc10_[6].length)
               {
                  _loc9_.pushAccItem(_loc10_[6][_loc5_]);
                  _loc5_++;
               }
            }
            _players[_myPlayerId].avtView.avatarData.itemResponseIntegrate(_loc9_);
            for each(var _loc12_ in _aiPlayers)
            {
               if(_loc12_ && _loc12_.avtView && _loc12_.positionIndex >= 0 && _loc12_.playerBodyModList != null)
               {
                  _loc12_.avtView.avatarData.colors = getRandomColors(_loc12_);
                  pickEyeAndPattern(_loc12_);
                  _loc9_ = new AccItemCollection();
                  _loc5_ = 0;
                  while(_loc5_ < _loc12_.playerBodyModList.length)
                  {
                     _loc9_.pushAccItem(_loc12_.playerBodyModList.getAccItem(_loc5_));
                     _loc5_++;
                  }
                  for each(var _loc11_ in _loc10_)
                  {
                     if(_loc11_ && _loc11_.length > 0)
                     {
                        if(_randomizer.integer(100) <= 80)
                        {
                           _loc6_ = _loc11_[_randomizer.integer(_loc11_.length)];
                           _loc8_ = new Item();
                           _loc8_.init(_loc6_.defId,_loc6_.invIdx,_loc6_.color,EquippedAvatars.forced());
                           _loc8_.isMemberOnly = false;
                           _loc9_.pushAccItem(_loc8_);
                        }
                     }
                  }
                  _loc12_.avtView.avatarData.itemResponseIntegrate(_loc9_);
                  _loc9_ = null;
               }
            }
            _avatarEditor = new FashionShowAvatarEditor();
            _avatarEditor.init(_bestDressedOnLand,_players[_myPlayerId].avtView.avatarData,_editorLayer,avEditorCloseButton,clientEndsRound,null,450,275);
            LocalizationManager.translateId(_avatarEditor.avEditor.themeText.themeInfoText1,11447);
            LocalizationManager.translateId(_avatarEditor.avEditor.themeText.themeInfoText2,_theme);
            _avatarEditor.avEditor.textUpdate();
            _avatarEditor.avEditor.timer.timerObject.timerText.text = "";
            _avatarEditor.avEditor.timer.gotoAndPlay("off");
            _timerBlinking = false;
         }
      }
      
      public function closeAvEditor(param1:Boolean) : void
      {
         var _loc7_:Avatar = null;
         var _loc2_:Array = null;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:Item = null;
         var _loc4_:int = 0;
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         if(_avatarEditor)
         {
            if(_closeBtn)
            {
               _closeBtn.visible = true;
            }
            _avatarEditor.destroy();
            _avatarEditor = null;
            if(!param1)
            {
               LocalizationManager.translateId(_curtainStage.loader.content.voteInfo.voteInfo.voteInfoText1,11444);
               _curtainStage.loader.content.voteInfo.voteInfo.voteInfoText2.text = " ";
               _curtainStage.loader.content.textUpdate();
               _curtainStage.loader.content.time(0,10);
               _curtainStage.loader.content.startRound();
               _loc7_ = _players[_myPlayerId].avtView.avatarData;
               _loc2_ = [];
               _loc2_[0] = "pi";
               _loc2_[1] = _loc7_.colors[0];
               _loc2_[2] = _loc7_.colors[1];
               _loc2_[3] = _loc7_.colors[2];
               _loc2_[4] = 0;
               _loc2_[5] = 8;
               _loc5_ = 6;
               _loc4_ = 0;
               if(_loc7_.inventoryClothing.itemCollection.getCoreArray())
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc7_.inventoryClothing.numItems)
                  {
                     _loc6_ = _loc7_.inventoryClothing.itemCollection.getAccItem(_loc3_);
                     if(_loc6_.getInUse(_loc7_.avInvId))
                     {
                        _loc2_[_loc5_++] = _loc6_.defId;
                        _loc2_[_loc5_++] = _loc6_.layerId;
                        _loc2_[_loc5_++] = _loc6_.invIdx;
                        _loc2_[_loc5_++] = _loc6_.accId;
                        _loc2_[_loc5_++] = _loc6_.color;
                        _loc2_[_loc5_++] = _loc6_.type;
                        _loc2_[_loc5_++] = 1;
                        _loc2_[_loc5_++] = _loc6_.itemStatus;
                        _loc4_++;
                     }
                     _loc3_++;
                  }
               }
               if(_loc7_.inventoryBodyMod.itemCollection.getCoreArray())
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc7_.inventoryBodyMod.numItems)
                  {
                     _loc6_ = _loc7_.inventoryBodyMod.itemCollection.getAccItem(_loc3_);
                     if(_loc6_.getInUse(_loc7_.avInvId))
                     {
                        _loc2_[_loc5_++] = _loc6_.defId;
                        _loc2_[_loc5_++] = _loc6_.layerId;
                        _loc2_[_loc5_++] = _loc6_.invIdx;
                        _loc2_[_loc5_++] = _loc6_.accId;
                        _loc2_[_loc5_++] = _loc6_.color;
                        _loc2_[_loc5_++] = _loc6_.type;
                        _loc2_[_loc5_++] = 1;
                        _loc2_[_loc5_++] = _loc6_.itemStatus;
                        _loc4_++;
                     }
                     _loc3_++;
                  }
               }
               _loc2_[4] = _loc4_;
               MinigameManager.msg(_loc2_);
            }
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Item = null;
         _availableItems = new Array(param1.length);
         var _loc4_:int = 100;
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc6_ = param1.getIitem(_loc5_) as Item;
            _availableItems[_loc5_] = new Item();
            _availableItems[_loc5_].init(_loc6_.defId,_loc4_++,_loc6_.color);
            _availableItems[_loc5_].isMemberOnly = false;
            _availableItems[_loc5_].makeSmallIcon();
            _loc5_++;
         }
         _availableItemColors = param3;
         setNewState(2);
      }
      
      private function voteForPlayer1() : void
      {
         clientEndsVoting(0);
      }
      
      private function voteForPlayer2() : void
      {
         clientEndsVoting(1);
      }
      
      private function voteForPlayer3() : void
      {
         clientEndsVoting(2);
      }
      
      private function voteForPlayer4() : void
      {
         clientEndsVoting(3);
      }
      
      private function voteForPlayer5() : void
      {
         clientEndsVoting(4);
      }
      
      private function voteForPlayer6() : void
      {
         clientEndsVoting(5);
      }
      
      private function voteForPlayer7() : void
      {
         clientEndsVoting(6);
      }
      
      private function voteForPlayer8() : void
      {
         clientEndsVoting(7);
      }
      
      private function voteForPlayer9() : void
      {
         clientEndsVoting(8);
      }
      
      private function voteForPlayer10() : void
      {
         clientEndsVoting(9);
      }
      
      private function showWaitingForOthers() : void
      {
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         _currentDialog = showDlg("BD_Waiting",[],450,275,false);
      }
      
      private function showWaitingDlg() : void
      {
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         _currentDialog = showDlg("BD_nextRound",[],450,275,false);
      }
      
      private function showNextRoundDlg() : void
      {
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         _currentDialog = showDlg("BD_newTheme",[],450,275,false);
         _nextRoundDialog = _currentDialog;
         LocalizationManager.translateId(_nextRoundDialog.envelope.theme.themeText,_theme);
      }
      
      private function showFinishedDlg() : void
      {
         var _loc1_:MovieClip = showDlg("BD_finished",[{
            "name":"button_yes",
            "f":onFinished_Yes
         },{
            "name":"button_no",
            "f":onFinished_No
         }],450,275);
      }
      
      private function onFinished_Yes() : void
      {
         if(_avatarEditor)
         {
            _avatarEditor.sendChangesRequest();
         }
      }
      
      private function onFinished_No() : void
      {
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         if(_closeBtn)
         {
            _closeBtn.visible = false;
         }
      }
      
      private function showResultsDlg() : void
      {
         var _loc8_:int = 0;
         var _loc2_:* = false;
         var _loc13_:String = null;
         var _loc4_:String = null;
         var _loc12_:String = null;
         var _loc7_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc1_:* = 0;
         var _loc3_:* = 0;
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
         hideDlg();
         _currentDialog = showDlg("BD_resultsScreen",[],450,275,false);
         _resultsDialog = _currentDialog;
         _resultsDialog.gotoAndPlay("on");
         _stageTimer = 10;
         var _loc5_:int = -1;
         var _loc9_:* = -1;
         var _loc6_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < 10)
         {
            _loc2_ = _loc8_ < _resultsInfo.length;
            _loc13_ = "votes_" + (_loc8_ + 1);
            _loc4_ = "name_" + (_loc8_ + 1);
            _loc12_ = "gems_" + (_loc8_ + 1);
            _loc7_ = "results_" + (_loc8_ + 1);
            _resultsDialog.resultsPopup[_loc13_].visible = _loc2_;
            _resultsDialog.resultsPopup[_loc4_].visible = _loc2_;
            _resultsDialog.resultsPopup[_loc12_].visible = _loc2_;
            if(_loc2_)
            {
               _loc10_ = 0;
               _loc11_ = "";
               if(_resultsInfo[_loc8_].isAI)
               {
                  _loc11_ = LocalizationManager.translateAvatarName(_aiServerNames[_resultsInfo[_loc8_].aiIndex]);
               }
               else if(_players[_resultsInfo[_loc8_].pID] && _players[_resultsInfo[_loc8_].pID].avtView)
               {
                  _loc11_ = LocalizationManager.translateAvatarName(_players[_resultsInfo[_loc8_].pID].avtView.avName);
               }
               else
               {
                  _loc11_ = LocalizationManager.translateAvatarName(_playerNameCache[_resultsInfo[_loc8_].pID]);
               }
               if(_resultsInfo[_loc8_].votes == _loc5_)
               {
                  _loc1_ = _loc9_;
               }
               else
               {
                  _loc6_++;
                  _loc1_ = _loc8_;
                  _loc9_ = _loc8_;
                  _loc5_ = int(_resultsInfo[_loc8_].votes);
               }
               switch(int(_resultsInfo.length) - 1)
               {
                  case 0:
                     _loc3_ = 6 + _loc1_;
                     break;
                  case 1:
                     _loc3_ = 5 + _loc1_;
                     break;
                  case 2:
                     _loc3_ = 4 + _loc1_;
                     break;
                  case 3:
                     _loc3_ = 3 + _loc1_;
                     break;
                  case 4:
                     _loc3_ = 2 + _loc1_;
                     break;
                  case 5:
                     _loc3_ = 1 + _loc1_;
                     break;
                  default:
                     _loc3_ = _loc1_;
               }
               switch(_loc3_)
               {
                  case 0:
                     _loc10_ = 200;
                     break;
                  case 1:
                     _loc10_ = 150;
                     break;
                  case 2:
                     _loc10_ = 125;
                     break;
                  case 3:
                     _loc10_ = 100;
                     break;
                  case 4:
                     _loc10_ = 75;
                     break;
                  case 5:
                     _loc10_ = 50;
                     break;
                  default:
                     _loc10_ = 25;
               }
               _resultsDialog.resultsPopup[_loc13_].text = _resultsInfo[_loc8_].votes;
               _resultsDialog.resultsPopup[_loc4_].text = _loc6_ + ". " + _loc11_;
               if(_resultsInfo[_loc8_].dbID == _myDBId)
               {
                  _resultsDialog.resultsPopup.highlightPlayer(_loc8_ + 1);
               }
               if(_resultsInfo[_loc8_].votedCount > 0 || _resultsInfo.length < 2)
               {
                  _resultsDialog.resultsPopup[_loc12_].text = _loc10_;
                  if(_resultsInfo[_loc8_].isAI == false && _resultsInfo[_loc8_].dbID == _myDBId)
                  {
                     addGemsToBalance(_loc10_);
                  }
               }
               else
               {
                  LocalizationManager.translateId(_resultsDialog.resultsPopup[_loc12_],11448);
               }
            }
            _loc8_++;
         }
      }
      
      private function emoteButton(param1:int) : void
      {
         var _loc2_:Array = null;
         if(_lastEmoteTimer <= 0)
         {
            _curtainStage.loader.content.showEmote(param1,_myPlayerId + 1);
            _loc2_ = [];
            _loc2_[0] = "em";
            _loc2_[1] = param1;
            _loc2_[2] = _myPlayerId + 1;
            MinigameManager.msg(_loc2_);
            _lastEmoteTimer = 1;
         }
      }
      
      private function buttonEmote1() : void
      {
         emoteButton(1);
      }
      
      private function buttonEmote2() : void
      {
         emoteButton(2);
      }
      
      private function buttonEmote3() : void
      {
         emoteButton(3);
      }
      
      private function buttonEmote4() : void
      {
         emoteButton(4);
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
      
      private function practiceKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               onPracticeOK();
         }
      }
      
      private function showPracticePopup() : void
      {
         stage.addEventListener("keyDown",practiceKeyDown);
         var _loc1_:MovieClip = showDlg("BD_practice",[{
            "name":"button_okay",
            "f":onPracticeOK
         }],450,275,true);
      }
      
      private function onPracticeOK() : void
      {
         stage.removeEventListener("keyDown",practiceKeyDown);
         hideDlg();
         if(_avatarEditor == null)
         {
            showAvatarEditor(true);
         }
      }
      
      private function onExit_Yes() : void
      {
         _gameQuitting = true;
         if(_currentDialog != null)
         {
            _guiLayer.removeChild(_currentDialog);
            _currentDialog = null;
         }
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
      }
   }
}

