package game.trueFalse
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarXtCommManager;
   import avatar.UserCommXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.SortLayer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.text.TextFormat;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import gui.SafeChatManager;
   import localization.LocalizationManager;
   
   public class TrueFalse extends GameBase implements IMinigame
   {
      private static const MAX_PLAYERS:int = 20;
      
      private static const ANSWER_DISPLAY_TIME:int = 2000;
      
      private static const ROUND_TIME:int = 10;
      
      private static const WAITING_FOR_START_STATE:int = 0;
      
      private static const QUESTION_STATE:int = 1;
      
      private static const ANSWER_STATE:int = 2;
      
      private static const DANCE_STATE:int = 3;
      
      private static const WAITING_FOR_STATS_STATE:int = 4;
      
      private static const JOININPROGRESS_STATE:int = 5;
      
      private static const QSTATE_OFF:int = 1;
      
      private static const QSTATE_ON:int = 2;
      
      private static const QSTATE_WIN:int = 3;
      
      private static const QSTATE_LOSE:int = 4;
      
      private static const EMOT_DISPLAY_TIME:int = 3;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const TAN_30:Number = 0.5773502691896;
      
      private var _myPlayerId:int;
      
      public var _mySfsId:int;
      
      private var _myScore:int = 0;
      
      private var _numPlayers:uint;
      
      private var _currentLeaderId:int;
      
      private var _players:Array;
      
      private var _playerSfsIds:Array;
      
      private var _gemPayout:Array = [5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,90,100,125,150];
      
      private var _playerStars:Array;
      
      private var _playerStreaks:Array;
      
      private var _playerAnimationLoops:Array;
      
      private var _totalGameTimer:Number;
      
      private var _gameTimer:int;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _displayAchievementTimer:Number;
      
      private var _timerActivated:Boolean;
      
      private var _countdownTime:Number;
      
      public var _gameState:int = 0;
      
      private var _starTimer:Number;
      
      private var _statsTimer:Number;
      
      private var _nextRoundTimer:Number;
      
      private var _nextQuestionTimer:Number;
      
      private var _waitForNextRound:Boolean;
      
      private var _joinInProgress:Boolean;
      
      public var _bg:MovieClip;
      
      private var _bQAOpen:Boolean;
      
      private var _playerStarId:int;
      
      private var _question:String = "";
      
      private var _answer:String = "";
      
      private var _currentRoundQuestion:int;
      
      private var _answersCorrect:int;
      
      private var _myAnswer:int;
      
      private var _correctInARow:int;
      
      private var _totalCorrectInARow:int;
      
      private var _sendServerMyAnswer:Boolean = true;
      
      private var _timeoutCount:int;
      
      private var _gems:int;
      
      private var _gemsEarnedThisRound:int;
      
      private var _tutorialDismissed:Boolean;
      
      public var _background:Sprite;
      
      public var _playerLayer:SortLayer;
      
      private var _foreground:Sprite;
      
      private var _sceneLoaded:Boolean;
      
      private var _normalFormat:TextFormat;
      
      private var _selectedFormat:TextFormat;
      
      private var _leftArrow:Boolean;
      
      private var _rightArrow:Boolean;
      
      private var _upArrow:Boolean;
      
      private var _downArrow:Boolean;
      
      private var _bMouseDown:Boolean;
      
      private var _bInit:Boolean;
      
      private var _offset:Point;
      
      private var _gameStarted:Boolean;
      
      private var _bNewState:Boolean;
      
      private var _canChooseAnswer:Boolean;
      
      private var _firstRoundForPlayer:Boolean;
      
      public var _soundMan:SoundManager;
      
      private const _audio:Array = ["aj_bestGuessCheck.mp3","aj_bestGuessX.mp3","aj_BGconfettiStab.mp3","aj_BGcorrectEnter.mp3","aj_BGcorrectExit.mp3","aj_BGcountDown1.mp3","aj_BGcountDown2.mp3","aj_BGcountDown3.mp3","aj_BGcountDown4.mp3","aj_BGcountDown5.mp3","aj_BGsorryEnter.mp3","aj_BGsorryExit.mp3","aj_BGhudEnter.mp3"];
      
      internal var _soundNameCheck:String = _audio[0];
      
      internal var _soundNameX:String = _audio[1];
      
      private var _soundNameConfettiStab:String = _audio[2];
      
      private var _soundNameCorrectEnter:String = _audio[3];
      
      private var _soundNameCorrectExit:String = _audio[4];
      
      private var _soundNameCountDown1:String = _audio[5];
      
      private var _soundNameCountDown2:String = _audio[6];
      
      private var _soundNameCountDown3:String = _audio[7];
      
      private var _soundNameCountDown4:String = _audio[8];
      
      private var _soundNameCountDown5:String = _audio[9];
      
      private var _soundNameSorryEnter:String = _audio[10];
      
      private var _soundNameSorryExit:String = _audio[11];
      
      private var _soundNameHudEnter:String = _audio[12];
      
      public var SFX_aj_BGtimerLP:Class;
      
      private var _musicSC:SoundChannel;
      
      private var _timerSC:SoundChannel;
      
      private var _SFX_ThinkMusic:SBMusic;
      
      public function TrueFalse()
      {
         super();
      }
      
      private function loadSounds() : void
      {
         _SFX_ThinkMusic = _soundMan.addStream("aj_musBestGuess",0.55);
         _soundMan.addSoundByName(_audioByName[_soundNameCheck],_soundNameCheck,0.29);
         _soundMan.addSoundByName(_audioByName[_soundNameX],_soundNameX,0.29);
         _soundMan.addSoundByName(_audioByName[_soundNameConfettiStab],_soundNameConfettiStab,0.38);
         _soundMan.addSoundByName(_audioByName[_soundNameCorrectEnter],_soundNameCorrectEnter,0.42);
         _soundMan.addSoundByName(_audioByName[_soundNameCorrectExit],_soundNameCorrectExit,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown1],_soundNameCountDown1,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown2],_soundNameCountDown2,0.48);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown3],_soundNameCountDown3,0.5);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown4],_soundNameCountDown4,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameCountDown5],_soundNameCountDown5,0.53);
         _soundMan.addSoundByName(_audioByName[_soundNameSorryEnter],_soundNameSorryEnter,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameSorryExit],_soundNameSorryExit,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameHudEnter],_soundNameHudEnter,0.45);
         _soundMan.addSound(SFX_aj_BGtimerLP,0.18,"aj_BGtimerLP");
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
         _displayAchievementTimer = 0;
         if(!_bInit)
         {
            if(_numPlayers <= 0 || _numPlayers > 20)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            _players = new Array(20);
            _playerStars = [];
            _playerStreaks = [];
            _playerAnimationLoops = [];
            _currentLeaderId = -1;
            _starTimer = 0;
            _statsTimer = 0;
            _nextRoundTimer = 0;
            _nextQuestionTimer = 0;
            _playerStarId = -1;
            _correctInARow = 0;
            _totalCorrectInARow = 0;
            _gems = 0;
            _background = new Sprite();
            _playerLayer = new SortLayer();
            _foreground = new Sprite();
            _guiLayer = new Sprite();
            addChild(_background);
            addChild(_playerLayer);
            addChild(_foreground);
            addChild(_guiLayer);
            loadScene("TrueFalseAssets/game_main.xroom",_audio);
            _myAnswer = -1;
            _countdownTime = 10;
            _waitForNextRound = false;
            _joinInProgress = false;
            _timeoutCount = 0;
            _currentRoundQuestion = 0;
            _answersCorrect = 0;
            _gemsEarnedThisRound = 0;
            setupTextFormats();
            resetAll();
            addListeners();
            setGameState(0);
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         SFX_aj_BGtimerLP = getDefinitionByName("aj_BGtimerLP") as Class;
         if(SFX_aj_BGtimerLP == null)
         {
            throw new Error("Sound not found! name:aj_BGtimerLP");
         }
         _soundMan = new SoundManager(this);
         loadSounds();
         _sceneLoaded = true;
         _totalGameTimer = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _bg = _scene.getLayer("bg").loader.content;
         _bg.questionAnim.question.questionText.text = _bg.questionAnim.question.followUpText.text = "";
         _guiLayer.addChild(_bg.resultsPopup);
         _guiLayer.addChild(_bg.roundJoin);
         _guiLayer.addChild(_bg.guessFalseMC);
         _guiLayer.addChild(_bg.guessTrueMC);
         _guiLayer.addChild(_bg.praiseMC);
         _guiLayer.addChild(_bg.prizeMeterAnim);
         _guiLayer.addChild(_bg.questionAnim);
         _guiLayer.addChild(_bg.timerMCAnim);
         showTutorial();
         var _loc3_:Array = _scene.getActorList("ActorLayer");
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc6_ = _loc3_[_loc4_];
            var _loc9_:* = _loc6_.layer;
            if(2 !== _loc9_)
            {
               _background.addChild(_loc6_.s);
            }
            else
            {
               _foreground.addChild(_loc6_.s);
            }
            _loc4_++;
         }
         if(_waitForNextRound)
         {
            _gameStarted = true;
            setGameState(4);
            _countdownTime += 10;
            _bg.popupOn("waiting");
         }
         else if(_joinInProgress)
         {
            _gameStarted = true;
            setGameState(5);
            _bg.popupOn("join");
         }
         if(!_gameStarted)
         {
            _gameStarted = true;
            setGameState(1);
         }
         _bNewState = true;
         for each(var _loc8_ in _players)
         {
            if(_loc8_)
            {
               _loc7_ = _loc8_.pId;
               if(_loc7_ == _myPlayerId)
               {
                  _players[_loc7_]._avtView.playAnim(14,_loc7_ % 2 != 0);
                  _loc5_ = Math.random() * 150 + 375;
                  _loc2_ = Math.random() * 75 + 400;
                  _players[_loc7_]._avtView.x = _loc5_;
                  _players[_loc7_]._avtView.y = _loc2_;
                  _playerLayer.addChild(_players[_loc7_]._avtView);
                  updatePosition(_loc5_,_loc2_);
               }
               if(_players[_loc7_]._splash == null)
               {
                  _players[_loc7_].addSplash();
               }
               if(!_playerStars[_loc7_])
               {
               }
               if(_playerStreaks[_loc8_.pId] > 0)
               {
               }
            }
         }
         super.sceneLoaded(param1);
      }
      
      public function updatePosition(param1:int, param2:int) : void
      {
         MinigameManager.msg(["au",param1,param2]);
         _timeoutCount = 0;
      }
      
      private function getPlayerFromSfsId(param1:int) : TrueFalsePlayer
      {
         var _loc2_:* = null;
         for each(_loc2_ in _players)
         {
            if(_loc2_ && _loc2_.sfsId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addAvatarMessageForMyself(param1:String, param2:int) : void
      {
         getPlayerFromSfsId(gMainFrame.server.userId)._avtView.addAvatarMessage(param1,param2);
      }
      
      public function handleChatMessage(param1:Array) : void
      {
         var _loc2_:* = null;
         var _loc3_:Boolean = false;
         var _loc6_:String = null;
         var _loc7_:Sprite = null;
         var _loc8_:int = int(param1[3]);
         var _loc9_:int = int(param1[5]);
         if(true)
         {
            _loc2_ = param1[4];
            _loc3_ = false;
            if(_loc9_ == 1)
            {
               _loc6_ = SafeChatManager.safeChatStringForCode(handleChatMessage,[param1],_loc2_,4);
               if(_loc6_ == "")
               {
                  return;
               }
               if(_loc6_)
               {
                  _loc2_ = _loc6_;
               }
               else
               {
                  _loc3_ = true;
               }
            }
            if(!_loc3_)
            {
               switch(_loc9_)
               {
                  case 0:
                  case 1:
                  case 9:
                     _loc2_ = UserCommXtCommManager.adjustCamelCase(_loc2_);
                     if(_loc8_ == gMainFrame.server.userId)
                     {
                        _loc2_ = UserCommXtCommManager.reverseSpecialWords(_loc2_);
                     }
                     getPlayerFromSfsId(_loc8_)._avtView.addAvatarMessage(_loc2_,int(param1[6]));
                     break;
                  case 2:
                     _loc7_ = MinigameManager.emoteForId(int(_loc2_));
                     if(_loc7_)
                     {
                        setAvatarEmote(_loc7_,_loc8_);
                     }
                     else
                     {
                        _loc3_ = true;
                     }
                     _loc2_ = MinigameManager.stringForId(int(_loc2_));
                     break;
                  case 3:
                     MinigameManager.playAnimFromActionString(_loc2_,_loc8_);
                     break;
                  default:
                     _loc3_ = true;
               }
            }
            if(_loc3_)
            {
               DebugUtility.debugTrace("WARNING - got bad chat! msg:" + _loc2_ + " chatType:" + _loc9_ + " from userId:" + _loc8_);
               return;
            }
         }
      }
      
      public function message(param1:Array) : void
      {
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:TrueFalsePlayer = null;
         var _loc11_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:String = null;
         var _loc2_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:int = 0;
         var _loc3_:int = 0;
         if(param1[0] == "mm")
         {
            if(param1[2] == "cm")
            {
               handleChatMessage(param1);
            }
            else if(param1[2] == "td")
            {
               if(!_timerActivated)
               {
                  if(_musicSC)
                  {
                     _musicSC.stop();
                  }
                  if(_timerSC)
                  {
                     _timerSC.stop();
                  }
                  _musicSC = _soundMan.playStream(_SFX_ThinkMusic);
                  _timerSC = _soundMan.play(SFX_aj_BGtimerLP,0,5);
                  _countdownTime = 10;
               }
               _timerActivated = true;
               if(_tutorialDismissed && _players[_myPlayerId] && _players[_myPlayerId]._avtView && _sceneLoaded)
               {
                  _players[_myPlayerId]._avtView.visible = true;
                  _bg.prizeMeterAnim.gotoAndPlay("on");
                  _bg.questionAnim.gotoAndPlay("on");
                  _bg.timerMCAnim.gotoAndPlay("on");
                  _soundMan.playByName(_soundNameHudEnter);
               }
            }
            else if(param1[2] == "au")
            {
               if(_gameStarted)
               {
                  _loc5_ = 3;
                  _loc8_ = int(param1[_loc5_++]);
                  _loc10_ = _players[_loc8_];
                  if(_loc10_ && _loc10_._avtView)
                  {
                     if(_loc10_._avtView.parent == null)
                     {
                        _playerLayer.addChild(_loc10_._avtView);
                        _loc10_._avtView.x = param1[_loc5_++];
                        _loc10_._avtView.y = param1[_loc5_++];
                        _loc10_._avtView.playAnim(14,false,2);
                     }
                     else
                     {
                        _loc10_.setAvatarDestination(param1[_loc5_++],param1[_loc5_++]);
                     }
                  }
               }
            }
            else if(param1[2] == "uj")
            {
               _loc5_ = 3;
               _numPlayers = param1[_loc5_++];
               _loc2_ = 0;
               while(_loc2_ < _numPlayers)
               {
                  _loc11_ = int(param1[_loc5_++]);
                  _loc8_ = int(param1[_loc5_++]);
                  _loc4_ = int(param1[_loc5_++]);
                  _loc9_ = param1[_loc5_++];
                  if(!_players[_loc8_])
                  {
                     _players[_loc8_] = new TrueFalsePlayer(this);
                     _players[_loc8_].pId = _loc8_;
                     _players[_loc8_].dbId = _loc4_;
                     _players[_loc8_].sfsId = _loc11_;
                     _players[_loc8_].userName = _loc9_;
                     _players[_loc8_]._localPlayer = _loc11_ == _mySfsId;
                  }
                  _loc2_++;
               }
               setupAvatars();
            }
            else if(param1[2] == "te")
            {
               if(_gameStarted)
               {
                  if(!_waitForNextRound)
                  {
                     _nextQuestionTimer = 6;
                  }
                  handleEndOfQuestion();
                  _loc5_ = 3;
                  _question = param1[_loc5_++];
                  _answer = param1[_loc5_++];
               }
            }
            else if(_gameStarted)
            {
               _loc5_ = 2;
               _loc7_ = int(param1[_loc5_++]);
               _loc12_ = int(param1[_loc5_++]);
               if(_currentLeaderId != _loc12_)
               {
                  if(_currentLeaderId >= 0)
                  {
                  }
                  _currentLeaderId = _loc12_;
               }
               _question = param1[_loc5_++];
               _answer = param1[_loc5_++];
               _gameTimer = getTimer();
               _bNewState = true;
               setGameState(2);
            }
         }
         else if(param1[0] != "mj")
         {
            if(param1[0] == "ml")
            {
               if(_gameStarted)
               {
                  _loc8_ = int(param1[2]);
                  if(_players[_loc8_] && _players[_loc8_]._avtView && _players[_loc8_]._avtView.parent)
                  {
                     _players[_loc8_]._avtView.parent.removeChild(_players[_loc8_]._avtView);
                     _players[_loc8_].destroy();
                  }
                  _players[_loc8_] = null;
                  if(_currentLeaderId == _loc8_)
                  {
                     _currentLeaderId = -1;
                  }
                  if(_playerStarId == _loc8_)
                  {
                     _playerStarId = -1;
                  }
                  _numPlayers--;
               }
            }
            else if(param1[0] == "ms")
            {
               _loc5_ = 1;
               _loc3_ = 0;
               _loc3_ = 0;
               while(_loc3_ < _numPlayers)
               {
                  _loc8_ = int(param1[_loc5_++]);
                  _players[_loc8_] = new TrueFalsePlayer(this);
                  _players[_loc8_].pId = _loc8_;
                  _players[_loc8_].dbId = param1[_loc5_++];
                  _players[_loc8_].sfsId = _playerSfsIds[_loc3_];
                  if(_players[_loc8_].sfsId == _mySfsId)
                  {
                     _myPlayerId = _players[_loc8_].pId;
                     _players[_loc8_]._localPlayer = true;
                  }
                  _playerStars[_loc8_] = int(param1[_loc5_++]);
                  _playerStreaks[_loc8_] = int(param1[_loc5_++]);
                  _players[_loc8_].userName = param1[_loc5_++];
                  _players[_loc8_]._moveToX = param1[_loc5_++];
                  _players[_loc8_]._moveToY = param1[_loc5_++];
                  if(_gameStarted)
                  {
                     if(!_playerStars[_loc8_])
                     {
                     }
                     if(_playerStreaks[_loc8_] > 0)
                     {
                     }
                  }
                  _loc3_++;
               }
               _countdownTime = param1[_loc5_++];
               if(_numPlayers > 1 && _countdownTime > 0)
               {
                  _timerActivated = true;
               }
               _countdownTime = 10 - _countdownTime;
               if(_countdownTime < 0)
               {
                  _countdownTime += 10 + 6;
               }
               _question = param1[_loc5_++];
               _answer = param1[_loc5_++];
               setupAvatars(true);
               gMainFrame.stage.addEventListener("keyDown",onKeyDownEvt);
               gMainFrame.stage.addEventListener("keyUp",onKeyUpEvt);
               gMainFrame.stage.addEventListener("mouseDown",onMouseDownEvt);
               gMainFrame.stage.addEventListener("mouseUp",onMouseUpEvt);
            }
         }
      }
      
      private function danceAvatars(param1:Boolean) : void
      {
         var _loc2_:* = null;
         for each(_loc2_ in _players)
         {
            if(_loc2_ && _loc2_._avtView && _loc2_._avtView.parent)
            {
               if(param1 && _loc2_._avtView.x < 450 || !param1 && _loc2_._avtView.x >= 450)
               {
                  _loc2_._avtView.playAnim(23);
                  _loc2_._isDancing = true;
               }
            }
         }
      }
      
      private function idleAvatars() : void
      {
         var _loc1_:* = null;
         for each(_loc1_ in _players)
         {
            if(_loc1_ && _loc1_._avtView && _loc1_._avtView.parent)
            {
               if(_loc1_._isDancing)
               {
                  _loc1_._avtView.playAnim(Math.random() < 0.5 ? 16 : 14);
                  _loc1_._isDancing = false;
               }
            }
         }
      }
      
      private function handleEndOfQuestion() : void
      {
         if(_timerSC)
         {
            _timerSC.stop();
         }
         var _loc1_:TrueFalsePlayer = _players[_myPlayerId];
         if(_loc1_ && _loc1_._avtView && _loc1_._avtView.parent)
         {
            _bg.gemBonus.x = _loc1_._avtView.x;
            _bg.gemBonus.y = _loc1_._avtView.y - 100;
         }
         if(_answer == "")
         {
            if(!_joinInProgress && _tutorialDismissed)
            {
               _bg.confirmTrue();
               if(_players[_myPlayerId]._avtView.x < 450)
               {
                  _bg.showCorrect();
                  addGemsToBalance((_correctInARow + 1) * 10);
                  _gems += (_correctInARow + 1) * 10;
                  _gemsEarnedThisRound += (_correctInARow + 1) * 10;
                  _bg.gemsEarned(_gems);
                  _correctInARow = _correctInARow + 1 > 3 ? 3 : _correctInARow + 1;
                  _bg.gemPayout(_correctInARow + 1);
                  _bg.gemBonus.gotoAndPlay("on");
                  _answersCorrect++;
                  AchievementXtCommManager.requestSetUserVar(405,++_totalCorrectInARow);
               }
               else
               {
                  _bg.showIncorrect();
                  _bg.gemPayout(1);
                  _correctInARow = 0;
                  _totalCorrectInARow = 0;
               }
            }
            danceAvatars(true);
         }
         else
         {
            if(!_joinInProgress && _tutorialDismissed)
            {
               _bg.confirmFalse();
               LocalizationManager.translateId(_bg.questionAnim.question.followUpText,parseInt(_answer));
               if(_players[_myPlayerId]._avtView.x >= 450)
               {
                  _bg.showCorrect();
                  addGemsToBalance((_correctInARow + 1) * 10);
                  _gems += (_correctInARow + 1) * 10;
                  _gemsEarnedThisRound += (_correctInARow + 1) * 10;
                  _bg.gemsEarned(_gems);
                  _correctInARow = _correctInARow + 1 > 3 ? 3 : _correctInARow + 1;
                  _bg.gemPayout(_correctInARow + 1);
                  _bg.gemBonus.gotoAndPlay("on");
                  _answersCorrect++;
                  AchievementXtCommManager.requestSetUserVar(405,++_totalCorrectInARow);
               }
               else
               {
                  _bg.showIncorrect();
                  _bg.gemPayout(1);
                  _correctInARow = 0;
                  _totalCorrectInARow = 0;
               }
            }
            danceAvatars(false);
         }
         _bg.timer(0,1);
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function setupAvatars(param1:Boolean = false) : void
      {
         var _loc2_:Avatar = null;
         for each(var _loc3_ in _players)
         {
            if(_loc3_)
            {
               if(!_loc3_._avtView)
               {
                  _loc2_ = new Avatar();
                  _loc2_.init(_loc3_.dbId,-1,"TrueFalseAvt" + _loc3_.dbId,1,[0,0,0],-1,null,_loc3_.userName);
                  _loc3_._avtView = new TrueFalseAvatarView();
                  _loc3_._avtView._chatLayer = _foreground;
                  _loc3_._avtView.init(_loc2_);
                  AvatarXtCommManager.requestAvatarGet(_loc3_.userName,_loc3_.onAgResponse);
                  if(_loc3_.pId == _myPlayerId && !_tutorialDismissed)
                  {
                     _loc3_._avtView.visible = false;
                  }
                  if(_sceneLoaded)
                  {
                     _loc3_.addSplash();
                  }
                  if(param1)
                  {
                     _loc3_._avtView.x = _loc3_._moveToX;
                     _loc3_._avtView.y = _loc3_._moveToY;
                     _playerLayer.addChild(_loc3_._avtView);
                     _loc3_._avtView.playAnim(14,_loc3_.pId % 2 != 0);
                  }
               }
            }
         }
      }
      
      private function openQA() : void
      {
         if(!_bQAOpen)
         {
            _bQAOpen = true;
            _statsTimer = _starTimer = _nextRoundTimer = 0;
         }
      }
      
      private function closeQA() : void
      {
         if(_bQAOpen)
         {
            _bQAOpen = false;
         }
      }
      
      private function endCleanup() : void
      {
         removeListeners();
         if(_musicSC)
         {
            _musicSC.stop();
            _musicSC = null;
         }
         if(_timerSC)
         {
            _timerSC.stop();
            _timerSC = null;
         }
         for each(var _loc1_ in _players)
         {
            if(_loc1_)
            {
               if(_loc1_._avtView && _loc1_._avtView.parent)
               {
                  _loc1_._avtView.parent.removeChild(_loc1_._avtView);
                  _loc1_._avtView.destroy();
               }
               _loc1_._avtView = null;
               _players.splice(_loc1_.pId,1);
            }
         }
         resetAll();
      }
      
      public function resetAll() : void
      {
         setGameState(0);
         _sendServerMyAnswer = true;
         _myAnswer = -1;
         _gameTimer = 0;
         _gameStarted = false;
      }
      
      private function setupTextFormats() : void
      {
         _normalFormat = new TextFormat();
         _normalFormat.color = 16763904;
         _normalFormat.bold = false;
         _normalFormat.size = 20;
         _selectedFormat = new TextFormat();
         _selectedFormat.color = 3941632;
         _selectedFormat.bold = true;
         _selectedFormat.size = 20;
      }
      
      private function addListeners() : void
      {
         addEventListener("enterFrame",heartbeat,false,0,true);
      }
      
      private function removeListeners() : void
      {
         removeEventListener("enterFrame",heartbeat);
         gMainFrame.stage.removeEventListener("keyDown",onKeyDownEvt);
         gMainFrame.stage.removeEventListener("keyUp",onKeyUpEvt);
         gMainFrame.stage.removeEventListener("mouseDown",onMouseDownEvt);
         gMainFrame.stage.removeEventListener("mouseUp",onMouseUpEvt);
      }
      
      private function answerMouseDownHandler(param1:MouseEvent) : void
      {
         if(_myAnswer == -1 && _canChooseAnswer)
         {
            switch(param1.currentTarget.name)
            {
               case "btn1":
                  _myAnswer = 1;
                  _bg.shrine.shrine.answer1.setTextFormat(_selectedFormat);
                  _bg.backlightOn(1);
                  break;
               case "btn2":
                  _myAnswer = 2;
                  _bg.shrine.shrine.answer2.setTextFormat(_selectedFormat);
                  _bg.backlightOn(2);
                  break;
               case "btn3":
                  _myAnswer = 3;
                  _bg.shrine.shrine.answer3.setTextFormat(_selectedFormat);
                  _bg.backlightOn(3);
            }
            messageServerIfNotSpamming();
            _bg.shrine.shrine.btn1.mouseEnabled = false;
         }
      }
      
      private function emotMouseDownHandler(param1:MouseEvent) : void
      {
         _timeoutCount = 0;
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _bg.buttonPress("happy");
               MinigameManager.msg(["se",0]);
               break;
            case "sadButton":
               _bg.buttonPress("sad");
               MinigameManager.msg(["se",1]);
               break;
            case "confusedButton":
               _bg.buttonPress("confused");
               MinigameManager.msg(["se",2]);
               break;
            case "madButton":
               _bg.buttonPress("mad");
               MinigameManager.msg(["se",3]);
         }
      }
      
      private function emotRollOverHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _bg.buttonRollover("happy");
               break;
            case "sadButton":
               _bg.buttonRollover("sad");
               break;
            case "confusedButton":
               _bg.buttonRollover("confused");
               break;
            case "madButton":
               _bg.buttonRollover("mad");
         }
      }
      
      private function emotRollOutHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget.name)
         {
            case "happyButton":
               _bg.buttonIdle("happy");
               break;
            case "sadButton":
               _bg.buttonIdle("sad");
               break;
            case "confusedButton":
               _bg.buttonIdle("confused");
               break;
            case "madButton":
               _bg.buttonIdle("mad");
         }
      }
      
      private function messageServerIfNotSpamming() : void
      {
         if(_myAnswer != -1)
         {
            MinigameManager.msg(["sa",_myAnswer]);
            _timeoutCount = 0;
         }
         else
         {
            trace("myAnswer == -1. Did not message server");
         }
      }
      
      private function onKeyDownEvt(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Point = _players[_myPlayerId]._avatarDirection;
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               if(_loc3_.x >= 0)
               {
                  _leftArrow = true;
                  _loc2_ = true;
                  _loc3_.x = -1;
               }
               break;
            case 1:
               if(_loc3_.y >= 0)
               {
                  _upArrow = true;
                  _loc2_ = true;
                  _loc3_.y = -1;
               }
               break;
            case 2:
               if(_loc3_.x <= 0)
               {
                  _rightArrow = true;
                  _loc2_ = true;
                  _loc3_.x = 1;
               }
               break;
            case 3:
               if(_loc3_.y <= 0)
               {
                  _downArrow = true;
                  _loc2_ = true;
                  _loc3_.y = 1;
                  break;
               }
         }
         if(_loc2_)
         {
            if(Math.abs(_loc3_.x) > 0 && Math.abs(_loc3_.y) > 0)
            {
               _loc3_.y = (_loc3_.y > 0 ? 1 : -1) * 0.5773502691896 * Math.abs(_loc3_.x);
            }
            _loc3_.normalize(1);
         }
      }
      
      private function onMouseDownEvt(param1:MouseEvent) : void
      {
         if(param1.target != _closeBtn)
         {
            _bMouseDown = true;
         }
      }
      
      private function onMouseUpEvt(param1:MouseEvent) : void
      {
         _bMouseDown = false;
      }
      
      private function onKeyUpEvt(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Point = _players[_myPlayerId]._avatarDirection;
         switch(int(param1.keyCode) - 37)
         {
            case 0:
               if(_leftArrow)
               {
                  _leftArrow = false;
                  if(_loc3_.x < 0)
                  {
                     _loc3_.x = _rightArrow ? 1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 1:
               if(_upArrow)
               {
                  _upArrow = false;
                  if(_loc3_.y < 0)
                  {
                     _loc3_.y = _downArrow ? 1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 2:
               if(_rightArrow)
               {
                  _rightArrow = false;
                  if(_loc3_.x > 0)
                  {
                     _loc3_.x = _leftArrow ? -1 : 0;
                     _loc2_ = true;
                  }
               }
               break;
            case 3:
               if(_downArrow)
               {
                  _downArrow = false;
                  if(_loc3_.y > 0)
                  {
                     _loc3_.y = _upArrow ? -1 : 0;
                     _loc2_ = true;
                  }
                  break;
               }
         }
         if(_loc2_)
         {
            _loc3_.normalize(1);
         }
      }
      
      private function heartbeat(param1:Event) : void
      {
         var _loc2_:* = null;
         _frameTime = (getTimer() - _lastTime) / 1000;
         _totalGameTimer += _frameTime;
         if(_frameTime > 0.5)
         {
            _frameTime = 0.5;
         }
         if(_displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _frameTime;
            if(_displayAchievementTimer < 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
         if(_statsTimer > 0)
         {
            _statsTimer -= _frameTime;
            if(_statsTimer <= 0)
            {
               _bg.showResults(_numPlayers);
            }
         }
         else if(_starTimer > 0)
         {
            _starTimer -= _frameTime;
         }
         else if(_nextRoundTimer > 0)
         {
            _nextRoundTimer -= _frameTime;
            if(_nextRoundTimer <= 0)
            {
               _bg.hideResults();
            }
         }
         else if(_nextQuestionTimer > 0)
         {
            _nextQuestionTimer -= _frameTime;
            if(_currentRoundQuestion == 10 && _nextQuestionTimer <= 4)
            {
               showRoundResults();
            }
            if(_nextQuestionTimer <= 0)
            {
               setGameState(1);
               _bNewState = true;
               _countdownTime = 10;
               _waitForNextRound = false;
               idleAvatars();
               if(_tutorialDismissed)
               {
                  hideDlg();
               }
               if(_joinInProgress)
               {
                  _joinInProgress = false;
                  _bg.popupOff();
                  _players[_myPlayerId]._avtView.visible = true;
                  _bg.prizeMeterAnim.gotoAndPlay("on");
                  _bg.questionAnim.gotoAndPlay("on");
                  _bg.timerMCAnim.gotoAndPlay("on");
                  _soundMan.playByName(_soundNameHudEnter);
               }
            }
         }
         _lastTime = getTimer();
         _playerLayer.heartbeat();
         if(_totalGameTimer > 15 && _totalGameTimer - _frameTime <= 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         if(_gameState > 0 && _timerActivated)
         {
            _countdownTime -= _frameTime;
            if(_countdownTime <= 0)
            {
               _countdownTime = 0;
               if(_gameState != 4)
               {
                  MinigameManager.msg(["te",int(_players[_myPlayerId]._avtView.x),int(_players[_myPlayerId]._avtView.y)]);
                  setGameState(4);
                  _bNewState = true;
                  closeQA();
                  _players[_myPlayerId].playIdle();
                  if(_tutorialDismissed)
                  {
                     _currentRoundQuestion++;
                  }
               }
            }
            else if(_countdownTime < 5 && Math.floor(_countdownTime) != Math.floor(_countdownTime + _frameTime))
            {
            }
            _bg.timer(2 * (10 - _countdownTime),10 * 2);
            if(_tutorialDismissed)
            {
               if(_bg.praiseMC.aj_BGcorrectEnter)
               {
                  _soundMan.playByName(_soundNameCorrectEnter);
                  _bg.praiseMC.aj_BGcorrectEnter = false;
               }
               if(_bg.praiseMC.aj_BGcorrectExit)
               {
                  _soundMan.playByName(_soundNameCorrectExit);
                  _bg.praiseMC.aj_BGcorrectExit = false;
               }
               if(_bg.praiseMC.aj_BGsorryEnter)
               {
                  _soundMan.playByName(_soundNameSorryEnter);
                  _bg.praiseMC.aj_BGsorryEnter = false;
               }
               if(_bg.praiseMC.aj_BGsorryExit)
               {
                  _soundMan.playByName(_soundNameSorryExit);
                  _bg.praiseMC.aj_BGsorryExit = false;
               }
               if(_bg.timerMCAnim.aj_BGcountDown1)
               {
                  _soundMan.playByName(_soundNameCountDown1);
                  _bg.timerMCAnim.aj_BGcountDown1 = false;
               }
               else if(_bg.timerMCAnim.aj_BGcountDown2)
               {
                  _soundMan.playByName(_soundNameCountDown2);
                  _bg.timerMCAnim.aj_BGcountDown2 = false;
               }
               else if(_bg.timerMCAnim.aj_BGcountDown3)
               {
                  _soundMan.playByName(_soundNameCountDown3);
                  _bg.timerMCAnim.aj_BGcountDown3 = false;
               }
               else if(_bg.timerMCAnim.aj_BGcountDown4)
               {
                  _soundMan.playByName(_soundNameCountDown4);
                  _bg.timerMCAnim.aj_BGcountDown4 = false;
               }
               else if(_bg.timerMCAnim.aj_BGcountDown5)
               {
                  _soundMan.playByName(_soundNameCountDown5);
                  _bg.timerMCAnim.aj_BGcountDown5 = false;
               }
               if(_bg.aj_BGconfettiStab)
               {
                  _soundMan.playByName(_soundNameConfettiStab);
                  _bg.aj_BGconfettiStab = false;
               }
            }
         }
         switch(_gameState)
         {
            case 0:
               if(_bNewState)
               {
                  _bNewState = false;
               }
               break;
            case 1:
               for each(_loc2_ in _players)
               {
                  if(_loc2_)
                  {
                     _loc2_.heartbeat(_frameTime);
                  }
               }
               if(!_pauseGame)
               {
                  _players[_myPlayerId].followCursorTest(_frameTime,_bMouseDown);
               }
               if(_bNewState && _tutorialDismissed)
               {
                  LocalizationManager.translateId(_bg.questionAnim.question.questionText,parseInt(_question));
                  _bg.questionAnim.question.followUpText.text = "";
                  _bg.newRound();
                  _players[_myPlayerId].setGuess(false);
                  if(_musicSC)
                  {
                     _musicSC.stop();
                  }
                  if(_timerSC)
                  {
                     _timerSC.stop();
                  }
                  if(_tutorialDismissed)
                  {
                     _musicSC = _soundMan.playStream(_SFX_ThinkMusic);
                     _timerSC = _soundMan.play(SFX_aj_BGtimerLP,0,5);
                  }
                  _bNewState = false;
               }
               break;
            case 2:
               if(_bNewState)
               {
                  _canChooseAnswer = false;
                  _bNewState = false;
               }
               _bg.shrine.shrine.btn1.mouseEnabled = true;
               if(_gameTimer + 2000 - getTimer() < 0)
               {
                  _bNewState = true;
                  setGameState(3);
                  _gameTimer = getTimer();
               }
               break;
            case 3:
               if(_bNewState)
               {
                  _bNewState = false;
               }
               if(_gameTimer + 500 - getTimer() < 0)
               {
                  for each(_loc2_ in _players)
                  {
                     if(_loc2_)
                     {
                        if(_loc2_._bCorrect)
                        {
                           _players[_loc2_.pId]._avtView.playAnim(23);
                           if(_loc2_.pId == _myPlayerId)
                           {
                           }
                        }
                        else if(_loc2_.pId == _myPlayerId)
                        {
                        }
                     }
                  }
               }
               if(_gameTimer - 1500 - getTimer() < 0)
               {
                  for each(_loc2_ in _players)
                  {
                     if(_loc2_)
                     {
                        _loc2_._avtView.playAnim(14,Boolean(_loc2_.pId % 2));
                     }
                  }
               }
               if(_gameTimer - getTimer() < 0)
               {
                  _bNewState = true;
                  setGameState(1);
               }
               break;
            case 4:
               if(_bNewState)
               {
                  closeQA();
                  _bNewState = false;
               }
               if(_waitForNextRound)
               {
                  _bg.roundJoin.roundJoin.timerText.text = Math.floor(_countdownTime);
               }
               for each(_loc2_ in _players)
               {
                  if(_loc2_)
                  {
                     _loc2_.heartbeat(_frameTime);
                  }
               }
               if(!_pauseGame)
               {
                  _players[_myPlayerId].followCursorTest(_frameTime,_bMouseDown);
               }
               break;
            case 5:
               for each(_loc2_ in _players)
               {
                  if(_loc2_ && !_loc2_._localPlayer)
                  {
                     _loc2_.heartbeat(_frameTime);
                  }
               }
               break;
            default:
               throw new Error("ERROR: invalid state in TrueFalse game!");
         }
      }
      
      private function setGameState(param1:int) : void
      {
         _gameState = param1;
      }
      
      public function playAnim(param1:Object, param2:int = -2) : void
      {
         var _loc3_:TrueFalsePlayer = null;
         if(param2 == -2)
         {
            _players[_myPlayerId].playAnim(param1);
         }
         else if(param2 > -1)
         {
            _loc3_ = getPlayerFromSfsId(param2);
            if(_loc3_)
            {
               _loc3_.playAnim(param1);
            }
         }
      }
      
      public function setAvatarEmote(param1:Sprite, param2:int = -2) : void
      {
         var _loc3_:TrueFalsePlayer = null;
         if(param2 == -2)
         {
            _players[_myPlayerId].setEmote(param1);
         }
         else if(param2 > -1)
         {
            _loc3_ = getPlayerFromSfsId(param2);
            if(_loc3_)
            {
               _loc3_.setEmote(param1);
            }
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg_TrueFalse",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.Gems_Earned,11554,_gems);
      }
      
      private function showTutorial() : void
      {
         var _loc1_:MovieClip = showDlg("trueFalse_tutorialPopup",[{
            "name":"okBtn",
            "f":onTutorialOK
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function showTimeout() : void
      {
         var _loc1_:MovieClip = showDlg("trueFalsePopup_StillThere",[{
            "name":"okBtn",
            "f":onDismissTimeout
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function showRoundResults() : void
      {
         var _loc1_:MovieClip = showDlg("roundResults_TrueFalse",[]);
         LocalizationManager.translateIdAndInsert(_loc1_.scoreText,21851,_answersCorrect);
         LocalizationManager.translateIdAndInsert(_loc1_.Total_Gems,11554,_gemsEarnedThisRound);
         _currentRoundQuestion = 0;
         _answersCorrect = 0;
         _gemsEarnedThisRound = 0;
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onDismissTimeout() : void
      {
         hideDlg();
         _timeoutCount = 0;
      }
      
      private function onTutorialOK() : void
      {
         hideDlg();
         _closeBtn = addBtn("CloseButton",847,1,showExitConfirmationDlg);
         _tutorialDismissed = true;
         MinigameManager.msg(["td"]);
         if(_countdownTime < 7)
         {
            _joinInProgress = true;
            if(_gameStarted)
            {
               closeQA();
               setGameState(5);
               _bg.popupOn("join");
            }
         }
         else if(_players[_myPlayerId] && _players[_myPlayerId]._avtView)
         {
            _players[_myPlayerId]._avtView.visible = true;
            _bg.prizeMeterAnim.gotoAndPlay("on");
            _bg.questionAnim.gotoAndPlay("on");
            _bg.timerMCAnim.gotoAndPlay("on");
            _soundMan.playByName(_soundNameHudEnter);
         }
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
      
      private function exit() : void
      {
         endCleanup();
         releaseBase();
         MinigameManager.leave();
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
   }
}

